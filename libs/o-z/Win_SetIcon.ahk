Win_SetIcon( Hwnd, Icon="", Flag=1){

	/*                              	DESCRIPTION

			Link:				https://autohotkey.com/board/topic/44104-module-win-125-set-of-window-functions/page-2

	*/

	/*                              	EXAMPLE(s)

				#Persistent
				Run, Notepad
				Sleep 1000
				hNotepad := WinExist("Untitled")

				Win_SetIcon( hNotepad, "icon.ico")
				sleep 2000
				hOld := Win_SetIcon( hNotepad, "cd.ico")
				Sleep 2000
				Win_SetIcon( hN)	 ;doesn't remove taskbar icon...
				return

				-------------------------------------------------------------------------------------------------------------

				#Persistent
				SetBatchLines, -1

				; Taken from http://www.autohotkey.com/forum/viewtopic.php?t=8795&start=285
				Gui +LastFound
				hWnd := WinExist()

				DllCall( "RegisterShellHookWindow", UInt,hWnd )
				MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
				OnMessage( MsgNum, "ShellMessage" )
				Return

				ShellMessage( wParam,lParam )
				{
					If ( wParam = 1 ) ;  HSHELL_WINDOWCREATED := 1
					{
					WinGetTitle, Title, ahk_id %lParam%
					If  ( Title = "Wavosaur" )
						Win_SetIcon( lParam, "C:\Wavosaur.ico")
					If  ( Title = "Irfanview" )
						Win_SetIcon( lParam, "C:\IrfanView.ico")
					}
				}


	*/

	static WM_SETICON = 0x80, LR_LOADFROMFILE=0x10, IMAGE_ICON=1

	if Flag not in 0,1
		return A_ThisFunc "> Unsupported Flag: " Flag

	if Icon !=
		hIcon := Icon+0 != "" ? Icon : DllCall("LoadImage", "Uint", 0, "str", Icon, "uint",IMAGE_ICON, "int", 32, "int", 32, "uint", LR_LOADFROMFILE)

	SendMessage, WM_SETICON, %Flag%, hIcon, , ahk_id %Hwnd%
	return ErrorLevel
}
