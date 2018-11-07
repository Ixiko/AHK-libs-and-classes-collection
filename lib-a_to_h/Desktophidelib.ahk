RR(path,name){
	RegRead,a,% path, % name
	Return a
}
Settings(){
	Global delay,runState
	Gui, Settings:New
	Gui, Settings: Color, 0xFFFFFF, 0xFEFEFA
	Gui, Settings:Font,s11,Segoe UI
	Gui, Settings:Add, Text,Section h24 0x200 w300,Delay before hiding the desktop in seconds: 
	Gui, Settings:Add, Edit, w65 x+8
	Gui, Settings:Add, UpDown, vdelay Range3-9999 0x80 gDelayChange, %delay%
	Gui, Settings:Add, Text, h24 0x200 xs w300,Run at Windows start up: 
	Gui, Settings:Add, Checkbox, x+8 vrunState gRunState Checked%runState%
	Gui, Settings:Show, AutoSize, Auto-Hide Desktop Settings
	ControlSend, Edit1, {End},Auto-Hide Desktop Settings
}
ShowDesk() {
	
	;from https://github.com/Lateralus138/Auto-Hide-Desktop/blob/master/hdlib.ahk
	DetectHiddenWindows, on
    id:=WinExist("ahk_class Shell_TrayWnd")
    ControlGet,id2,Hwnd,,SysListView321,ahk_class Progman
    If !id2
        ControlGet,id2,Hwnd,,SysListView321,ahk_class WorkerW
	ControlGet,id3,Hwnd,,,ahk_class Button
	If !IsVisible(id)
		WinShow, ahk_id %id%
	If !IsVisible(id2)
		WinShow, ahk_id %id2%
	If !IsVisible(id3)
		WinShow, ahk_id %id3%
	return
}
ToggleDeskIcons(idle_time) {
	
	;from https://github.com/Lateralus138/Auto-Hide-Desktop/blob/master/hdlib.ahk
	DetectHiddenWindows, On
    ControlGet,id,Hwnd,,SysListView321,ahk_class Progman
    If !id
        ControlGet,id,Hwnd,,SysListView321,ahk_class WorkerW
	If (A_TimeIdlePhysical >= idle_time)
		{
			If IsVisible(id)
				WinHide, ahk_id %id%
			Return "Desktop icons are hidden."	
		}
    Else
        {
			If !IsVisible(id)
				WinShow, ahk_id %id%
			Return
        }
		
		
}
ToggleTaskbar(idle_time) {
	DetectHiddenWindows, on
    id:=WinExist("ahk_class Shell_TrayWnd")
	ControlGet,id2,Hwnd,,,ahk_class Button
	If (A_TimeIdlePhysical >= idle_time)
		{
			If IsVisible(id)
				WinHide, ahk_id %id%
			If IsVisible(id2)
				WinHide, ahk_id %id2%
			Return "Taskbar is hidden."	
		}
    Else
        {
			If !IsVisible(id)
				WinShow, ahk_id %id%
			If !IsVisible(id2)
				WinShow, ahk_id %id2%	
			Return
        }
}
IsVisible(id){
	Return DllCall("IsWindowVisible","UInt",id)
}