#Requires AutoHotkey v2.0
#SingleInstance Force
#Include UIA.ahk
SendMode "Input"
CoordMode("Mouse", "Screen")

if (!A_IsAdmin) {
	try {
		if (A_IsCompiled) {
			Run('*RunAs "' A_ScriptFullPath '" /restart')
		} else {
			Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
		}
	}
	ExitApp
}

Global LClickCount  := 0
Global RClickCount  := 0
Global X_LastClick  := 0
Global Y_LastClick  := 0
Global ClickBias    := 5
Global Interval     := 30
Global ClickTimeout := 250
Global BlankClick   := false

#HotIf (IsExplorerFocus())

	#InputLevel 1
	
		F2:: {
			MouseGetPos(&x, &y)
		
			if (IsItemUIA(x, y)) {
				Click(x, y, "Left")
				Sleep(Interval)
			}
		
			Send("{F2}")
		}
	
	#InputLevel 0

#HotIf (IsExplorerTarget())

	#InputLevel 1
	
		$MButton:: {
			MouseGetPos(&x, &y)
		
			if (IsItemUIA(x, y)) {
				Click(x, y, "Left")
				Sleep(Interval)
				Send("{F2}")
			} else {
				Click(x, y, "Middle")
			}
		}
	
		$+MButton:: {
			MouseGetPos(&x, &y)
		
			if (IsItemUIA(x, y)) {
				if (IsFolderUIA(x, y)) {
					Click(x, y, "Middle")
				} else {
					Click(x, y, "Left")
					Sleep(Interval)
					Send("{F2}")
				}
			} else {
				Click(x, y, "Middle")
			}
		}
	
		$^MButton:: {
			MouseGetPos(&x, &y, &WinID)
		
			if (IsItemUIA(x, y)) {
				if (IsFolderUIA(x, y)) {
					KeyWait "Ctrl"
					Click(x, y, "Middle")
					Sleep(Interval)
					SwitchExplorerTab(WinID)
				} else {
					Click(x, y, "Left")
					Sleep(Interval)
					Send("{F2}")
				}
			} else {
				Click(x, y, "Middle")
			}
		}
	
	#InputLevel 0

#HotIf (IsExplorerTarget() || IsFuncMenuTarget())

	~RButton::
	~LButton:: {
		Global LClickCount, ClickBias, X_LastClick, Y_LastClick, ClickTimeout, BlankClick
	
		MouseGetPos(&x, &y)
		if (IsFuncMenuTarget()) {
			if (LClickCount > 0) {
				LClickCount++
			}
		} else if (LClickCount > 0
			&& Abs(x - X_LastClick) < ClickBias
			&& Abs(y - Y_LastClick) < ClickBias) {
			LClickCount++
			X_LastClick := x
			Y_LastClick := y
			BlankClick  := IsBlankUIA(x, y)
		} else {
			LClickCount := 1
			X_LastClick := x
			Y_LastClick := y
			BlankClick  := IsBlankUIA(x, y)
		}
	
		SetTimer(EvalClicks, -ClickTimeout)
	}

	EvalClicks() {
		Global LClickCount, BlankClick

		if (!BlankClick) {
			return
		}
		if (LClickCount >= 2 && WinExist("ahk_class #32768")) {
			Send("{Escape}")
			Sleep(Interval)
		}

		if (LClickCount = 2) {
			Send("!{Up}")
		} else if (LClickCount >= 3) {
			Send("!{Left}")
		}

		LClickCount := 0
	}

#HotIf

GetControlType( x, y ) {
	try {
		element := UIA.SmallestElementFromPoint(x, y) ;; 螢幕絕對座標
	} catch {
		return 0
	}

	if (!element) {
		return 0
	}

	try {
		return element.ControlType
	}

	return 0
}

IsDesktop() {
	MouseGetPos(, , &WinID)

	try {
		AhkClass := WinGetClass("ahk_id " WinID)
	} catch {
		return false
	}

	return (AhkClass = "Progman" || AhkClass = "WorkerW")
}

IsExplorerFocus(  ) {
	return (WinActive("ahk_class CabinetWClass"))
}

IsExplorerTarget(  ) {
	MouseGetPos(, , &WinID)

	try {
		return (WinGetClass("ahk_id " WinID) = "CabinetWClass")
	} catch {
		return false
	}
}

IsFuncMenuTarget(  ) {
	MouseGetPos(, , &WinID)

	try {
		return (WinGetClass("ahk_id " WinID) = "#32768")
	} catch {
		return false
	}
}

; 空白處 : ControlType = 50008 (List)
; 快速存取 : ControlType = 50024 (TreeItem)
; 文字編輯區域 : ControlType = 50004 (Edit)
; 檔案/資料夾圖示 : ControlType = 50007 (ListItem)
; 分頁列 : ControlType = 50018 (Tab)
; 所有分頁項目 : ControlType = 50019 (TabItem)

IsBlankUIA( x, y ) {
	return (GetControlType(x, y) = 50008)
}

IsCacheUIA( x, y ) {
	return (GetControlType(x, y) = 50024)
}

IsItemUIA( x, y ) {
	return (GetControlType(x, y) = 50004 || GetControlType(x, y) = 50007)
}

SwitchExplorerTab( WinID, targetIndex := -999 ) {
	try {
		element := UIA.ElementFromHandle(WinID)
	} catch {
		return false
	}
	try {
		tabControl := element.FindFirst({ControlType: 50018})
	} catch {
		return false
	}
	if (!tabControl) {
		return false
	}
	try {
		tabItems := tabControl.FindAll({ControlType: 50019})
	} catch {
		return false
	}

	if (targetIndex = -999) {
		targetIndex := tabItems.Length
	}

	if (targetIndex < 1 || targetIndex > tabItems.Length) {
		return false
	}

	try {
		tabItems[targetIndex].SelectionItemPattern.Select()
	} catch {
		return false
	}

	return true
}

IsFolderUIA( x, y ) {
	MouseGetPos(&x, &y, &WinID)

	try {
		element := UIA.SmallestElementFromPoint(x, y)
		if (!element || element.ControlType != 50007) {
			return -1
		}
		itemName := element.Name
	} catch {
		return -1
	}
	if (itemName = "") {
		return -1
	}

	; 走訪同HWND的所有Shell視窗(含各分頁)，用名稱查出項目物件並讀取IsFolder
	try {
		for win in ComObject("Shell.Application").Windows() {
			try {
				if (win.HWND != WinID) {
					continue
				}
				folderItem := win.Document.Folder.ParseName(itemName)
				if (IsObject(folderItem)) {
					return folderItem.IsFolder ? 1 : 0
				}
			}
		}
	}

	return -1
}