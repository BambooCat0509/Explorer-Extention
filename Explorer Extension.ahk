#Requires AutoHotkey v2.0
#SingleInstance Force
#Include UIA.ahk
CoordMode("Mouse", "Screen")

#HotIf WinActive("ahk_class CabinetWClass")

global g_ClickCount := 0
global g_ClickX := 0, g_ClickY := 0
global g_ClickTimeout := 400   ; 可自行調整(ms)
global g_ClickIsBlank := false

~LButton:: {
	global g_ClickCount, g_ClickX, g_ClickY, g_ClickTimeout, g_ClickIsBlank

	MouseGetPos(&x, &y)

	if (g_ClickCount > 0 && Abs(x - g_ClickX) < 5 && Abs(y - g_ClickY) < 5) {
		g_ClickCount++
	} else {
		g_ClickCount := 1
	}
	g_ClickX := x
	g_ClickY := y
	g_ClickIsBlank := IsBlankAreaUIA(x, y)

	SetTimer(EvaluateLButtonClicks, -g_ClickTimeout)
}

EvaluateLButtonClicks() {
	global g_ClickCount, g_ClickIsBlank

	count := g_ClickCount
	isBlank := g_ClickIsBlank
	g_ClickCount := 0

	if !isBlank
		return

	if (count = 2) {
		Send("!{Up}")
	} else if (count >= 3) {
		Send("!{Left}")
	}
}

#InputLevel 1

MButton:: {
	MouseGetPos(&x, &y)
	if IsOverItemUIA(x, y) {
		Click(x, y, "Left")
		Sleep(50)
		Send("{F2}")
	} else {
		Click(x, y, "Middle")
	}
}

F2:: {
	MouseGetPos(&x, &y)
	if IsOverItemUIA(x, y) {
		Click(x, y, "Left")
		Sleep(50)
	}
	Send("{F2}")
}

#InputLevel 0

#HotIf

GetUIAControlType(x, y) {
	try {
		el := UIA.SmallestElementFromPoint(x, y) ;; 螢幕絕對座標
	} catch {
		return 0
	}
	if !el
		return 0
	try return el.ControlType
	return 0
}

; 空白處: ControlType = 50008 (List)
IsBlankAreaUIA(x, y) {
	return GetUIAControlType(x, y) = 50008
}

; 檔案/資料夾圖示: ControlType = 50007 (ListItem)
IsOverItemUIA(x, y) {
	return GetUIAControlType(x, y) = 50007
}
