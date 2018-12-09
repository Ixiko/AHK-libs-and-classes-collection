WinGetAll(Which="Title", DetectHidden="Off"){
O_DHW := A_DetectHiddenWindows, O_BL := A_BatchLines ;Save original states
DetectHiddenWindows, % (DetectHidden != "off" && DetectHidden) ? "on" : "off"
SetBatchLines, -1
    WinGet, all, list ;get all hwnd
    If (Which="Title") ;return Window Titles
    {
        Loop, %all%
        {
            WinGetTitle, WTitle, % "ahk_id " all%A_Index%
            If WTitle ;Prevent to get blank titles
                Output .= WTitle "`n"        
        }
    }
    Else If (Which="Process") ;return Process Names
    {
        Loop, %all%
        {
            WinGet, PName, ProcessName, % "ahk_id " all%A_Index%
            Output .= PName "`n"
        }
    }
    Else If (Which="Class") ;return Window Classes
    {
        Loop, %all%
        {
            WinGetClass, WClass, % "ahk_id " all%A_Index%
            Output .= WClass "`n"
        }
    }
    Else If (Which="hwnd") ;return Window Handles (Unique ID)
    {
        Loop, %all%
            Output .= all%A_Index% "`n"
    }
    Else If (Which="PID") ;return Process Identifiers
    {
        Loop, %all%
        {
            WinGet, PID, PID, % "ahk_id " all%A_Index%
            Output .= PID "`n"        
        }
        Sort, Output, U N ;numeric order and remove duplicates
    }
DetectHiddenWindows, %O_DHW% ;back to original state
SetBatchLines, %O_BL% ;back to original state
    Sort, Output, U ;remove duplicates
	arr:=[]
	loop,parse,output,`n
		if (trim(a_loopfield)!="")
			arr.insert("" a_loopfield)
	return arr
}
