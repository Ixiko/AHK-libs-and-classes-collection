EnumToolbarButtons(ctrlhwnd, is_apply_scale:=false) {
	; Thanks to LabelControl code from 
	; https://www.donationcoder.com/Software/Skrommel/
	;
	; ctrlhwnd is the toolbar hwnd.
	; Return an array of objects, with element:
	; * .x .y .w .h (button position relative to the toolbar)
	; * .cmd  (command id of the button)
	; * .text  (text displayed on the button)
	;
	; is_apply_scale should keep false; true is only for testing purpose
	
	arbtn := []

	ControlGetPos, ctrlx, ctrly, ctrlw, ctrlh, , ahk_id %ctrlhwnd%
	
	WinGet, pid_target, PID, ahk_id %ctrlhwnd%
	hpRemote := DllCall( "OpenProcess" 
	                    , "uint", 0x18    ; PROCESS_VM_OPERATION|PROCESS_VM_READ 
	                    , "int", false 
	                    , "uint", pid_target ) 
    ; hpRemote: Remote process handle
	if(!hpRemote) {
		tooltip, % "Autohotkey: Cannot OpenProcess(pid=" . pid_target . ")"
		return
	}
	remote_buffer := DllCall( "VirtualAllocEx" 
                    , "uint", hpRemote 
                    , "Ptr", 0          ; LPVOID lpAddress ("uint" tolerable) 
                    , "uint", 0x1000    ; size to allocate, 4KB
                    , "uint", 0x1000         ; MEM_COMMIT 
                    , "uint", 0x4 )          ; PAGE_READWRITE 
	x1=
	x2=
	y1=
	WM_USER:=0x400
	TB_GETSTATE:=WM_USER+18
	TB_GETBITMAP     :=     (WM_USER + 44) ; only for test
	TB_GETBUTTONSIZE :=     (WM_USER + 58) ; only for test
	TB_GETBUTTON:=WM_USER+23
	TB_GETBUTTONTEXTW := WM_USER+75 ; I always get UTF-16 string from the toolbar // ANSI: WM_USER+45
	TB_GETITEMRECT:=WM_USER+29
	TB_BUTTONCOUNT:=WM_USER+24
	SendMessage, %TB_BUTTONCOUNT%,0,0, , ahk_id %ctrlhwnd%
	buttons := ErrorLevel
;tooltip, buttons=%buttons%	 ; OK
	
	VarSetCapacity( rect, 16, 0 ) 
	VarSetCapacity( BtnStruct, 32, 0 ) ; Winapi TBBUTTON struct(32 bytes on x64, 20 bytes on x86)
	/*
		typedef struct _TBBUTTON {
		    int       iBitmap; 
		    int       idCommand; 
		    BYTE      fsState; 
		    BYTE      fsStyle; 
		#ifdef _WIN64
		    BYTE      bReserved[6]     // padding for alignment
		#elif defined(_WIN32)
		    BYTE      bReserved[2]     // padding for alignment
		#endif
		    DWORD_PTR dwData; 
		    INT_PTR   iString; 
		} TBBUTTON, NEAR* PTBBUTTON, FAR* LPTBBUTTON; 
	*/

	Loop,%buttons%
	{
		; Try to get button text. Two steps: 
		; 1. get command-id from button-index,
		; 2. get button text from comand-id
		SendMessage, %TB_GETBUTTON%, % A_Index-1, remote_buffer, , ahk_id %ctrlhwnd%
		ReadRemoteBuffer(hpRemote, remote_buffer, BtnStruct, 32)
		idButton := NumGet(BtnStruct, 4, "int")
		;
;		SendMessage, %TB_GETSTATE%, %idButton%, 0, , ahk_id %ctrlhwnd% ; hope that 4KB is enough ; just a test
		SendMessage, %TB_GETBUTTONTEXTW%, %idButton%, remote_buffer, , ahk_id %ctrlhwnd% ; hope that 4KB is enough
		btntextchars := ErrorLevel
		if(btntextchars>0){
			btntextbytes := A_IsUnicode ? btntextchars*2 : btntextchars
			VarSetCapacity(BtnTextBuf, btntextbytes+2, 0) ; +2 is for trailing-NUL
			ReadRemoteBuffer(hpRemote, remote_buffer, BtnTextBuf, btntextbytes)
			BtnText := StrGet(&BtnTextBuf, "UTF-16")
		} else {
			BtnText := ""
		}
		;FileAppend, % A_Index . ":" . idButton . "(" . btntextchars . ")" . BtnText . "`n", _emeditor_toolbar_buttons.txt ; debug

		SendMessage,%TB_GETITEMRECT%,% A_Index-1, remote_buffer, , ahk_id %ctrlhwnd%

		ReadRemoteBuffer(hpRemote, remote_buffer, rect, 16)
		oldx1:=x1
		oldx2:=x2
		oldy1:=y1
		x1 := NumGet(rect, 0, "int") 
		x2 := NumGet(rect, 8, "int") 
		y1 := NumGet(rect, 4, "int") 
		y2 := NumGet(rect, 12, "int")
		
		if(is_apply_scale) {
			scale := Get_DPIScale()
			x1 /= scale
			y1 /= scale
			x2 /= scale
			y2 /= scale
		}

		If (x1=oldx1 And y1=oldy1 And x2=oldx2)
			Continue
		If (x2-x1<10)
			Continue
		If (x1>ctrlw Or y1>ctrlh)
			Continue
	
		arbtn.Insert( {"x":x1, "y":y1, "w":x2-x1, "h":y2-y1, "cmd":idButton, "text":BtnText} )
		;line:=100000000+Floor((ctrly+y1)/same)*10000+(ctrlx+x1)
		;lines=%lines%%line%%A_Tab%%ctrlid%%A_Tab%%class%`n
	}
	result := DllCall( "VirtualFreeEx" 
	             , "uint", hpRemote 
	             , "uint", remote_buffer 
	             , "uint", 0 
	             , "uint", 0x8000 )     ; MEM_RELEASE 
	result := DllCall( "CloseHandle", "uint", hpRemote )
	return arbtn
}

ReadRemoteBuffer(hpRemote, RemoteBuffer, ByRef LocalVar, bytes) {
	result := DllCall( "ReadProcessMemory" 
	            , "Ptr", hpRemote 
	            , "Ptr", RemoteBuffer 
	            , "Ptr", &LocalVar 
	            , "uint", bytes 
	            , "uint", 0 ) 
}
