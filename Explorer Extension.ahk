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

Global X_LastClick  := 0
Global Y_LastClick  := 0
Global ClickCount   := 0
Global ClickBias    := 5
Global Interval     := 5
Global ClickTimeout := 250
Global BlankClick   := false

#HotIf (IsExplorerFocus())

	#InputLevel 1
	
		$F2:: {
			MouseGetPos(&x, &y)
		
			if (IsListItemUIA(x, y)) {
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
		
			if (IsListItemUIA(x, y)) {
				Click(x, y, "Left")
				Sleep(Interval)
				Send("{F2}")
			} else if (element := IsTreeItemUIA(x, y)) {
				if (GetTreeItemPosition(element, &x, &y)) {
					Send("+{RButton}")
					Sleep(Interval)
					option := "M"
				
					if (MenuOptionCheck(option)) {
						Send(option)
					} else {
						Send("{Escape}")
					}
				}
			} else {
				Click(x, y, "Middle")
			}
		}
	
		$+MButton:: {
			KeyWait "Shift"
			MouseGetPos(&x, &y)
		
			if (IsListItemUIA(x, y)) {
				if (IsFolderUIA(x, y)) {
					Click(x, y, "Middle")
				} else {
					Click(x, y, "Left")
					Sleep(Interval)
					Send("{F2}")
				}
			} else if (element := IsTreeItemUIA(x, y)) {
				if (GetTreeItemPosition(element, &x, &y)) {
					Click(x, y, "Middle")
				}
			} else {
				Send("+{MButton}")
			}
		}
	
		$^MButton:: {
			KeyWait "Ctrl"
			MouseGetPos(&x, &y, &WinID)
		
			if (IsListItemUIA(x, y)) {
				if (IsFolderUIA(x, y)) {
					Click(x, y, "Middle")
					Sleep(Interval)
					SwitchExplorerTab(WinID)
				} else {
					Click(x, y, "Left")
					Sleep(Interval)
					Send("{F2}")
				}
			} else if (element := IsTreeItemUIA(x, y)) {
				if (GetTreeItemPosition(element, &x, &y)) {
					Click(x, y, "Middle")
				}
				Sleep(Interval)
				SwitchExplorerTab(WinID)
			} else {
				Send("^{MButton}")
			}
		}
	
		$!MButton:: {
			KeyWait "Alt"
			MouseGetPos(&x, &y, &WinID)
		
			if (element := IsTreeItemUIA(x, y)) {
				if (GetTreeItemPosition(element, &x, &y)) {
					Send("+{RButton}")
					Sleep(Interval)
					option := "R"
				
					if (MenuOptionCheck(option)) {
						Send(option)
					} else {
						Send("{Escape}")
					}
				}
			} else {
				Send("!{MButton}")
			}
		}
	
	#InputLevel 0

#HotIf (IsExplorerTarget() || IsFuncMenuTarget())

	$~RButton::
	$~LButton:: {
		Global ClickCount, ClickBias, X_LastClick, Y_LastClick, ClickTimeout, BlankClick
	
		MouseGetPos(&x, &y)
		if (IsFuncMenuTarget()) {
			if (ClickCount > 0) {
				ClickCount++
			}
		} else if (ClickCount > 0
			&& Abs(x - X_LastClick) < ClickBias
			&& Abs(y - Y_LastClick) < ClickBias) {
			ClickCount++
			X_LastClick := x
			Y_LastClick := y
			BlankClick  := IsBlankUIA(x, y)
		} else {
			ClickCount := 1
			X_LastClick := x
			Y_LastClick := y
			BlankClick  := IsBlankUIA(x, y)
		}
	
		SetTimer(EvalClicks, -ClickTimeout)
	}

	EvalClicks() {
		Global ClickCount, BlankClick

		if (!BlankClick) {
			return
		}
		if (ClickCount >= 2 && WinExist("ahk_class #32768")) {
			Send("{Escape}")
			Sleep(Interval)
		}

		if (ClickCount = 2) {
			Send("!{Up}")
		} else if (ClickCount >= 3) {
			Send("!{Left}")
		}

		ClickCount := 0
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

; 分頁列 : ControlType = 50018 (Tab)
; 空白處 : ControlType = 50008 (List)
; 快速存取 : ControlType = 50024 (TreeItem)
; 文字編輯區域 : ControlType = 50004 (Edit)
; 所有分頁項目 : ControlType = 50019 (TabItem)
; 檔案/資料夾圖示 : ControlType = 50007 (ListItem)

IsBlankUIA( x, y ) {
	return (GetControlType(x, y) = 50008)
}

IsListItemUIA( x, y ) {
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

GetTreeItemPosition( element, &x, &y ) {
	try {
		location := element.Location
	} catch {
		return false
	}
	x := location.x + 20
	y := location.y + (location.h // 2)
	return true
}

IsTreeItemUIA( x, y ) {
	try {
		element := UIA.SmallestElementFromPoint(x, y)
		if (element && element.ControlType = 50024) {
			return element
		}
	}

	; Explorer 放 TreeItem 的容器
	; 第8層: ControlType=50033  ClassName=ShellTabWindowClass  Name=Explorer 
	; 第7層: ControlType=50033  ClassName=DUIViewWndClassName  Name=
	; 第6層: ControlType=50033  ClassName=HWNDView             Name=檔案總管窗格
	; 第5層: ControlType=50033  ClassName=Element              Name=[資料夾配置] 窗格
	; 第4層: ControlType=50033  ClassName=ProperTreeHost       Name=控制主機
	; 第3層: ControlType=50023  ClassName=SysTreeView32        Name=瀏覽窗格
	; 第2層: ControlType=50024  ClassName=                     Name=桌面
	; 第1層: ControlType=50024  ClassName=                     Name=本機

	try {
		container := UIA.SmallestElementFromPoint(x, y)
		loop 6 { ;; 8~3層
			if (!container) {
				return 0
			}
			if (container.ControlType = 50023) {
				break
			}
			container := container.Parent
		}
		if (!container || container.ControlType != 50023) {
			return 0
		}

		for element in container.FindAll({ControlType: 50024}) {
			location := element.Location
			if (y >= location.y && y <= location.y + location.h) {
				return element
			}
		}
	}

	return 0
}

MenuOptionCheck( option ) {
	menuHwnd := WinExist("ahk_class #32768")
	if (!menuHwnd) {
		return false
	}

	try {
		menu := UIA.ElementFromHandle(menuHwnd)
	} catch {
		return false
	}
	if (!menu) {
		return false
	}

	try {
		items := menu.FindAll({ControlType: 50011})
	} catch {
		return false
	}

	for item in items {
		try {
			if (InStr(item.Name, option)) {
				return true
			}
		}
	}
	return false
}