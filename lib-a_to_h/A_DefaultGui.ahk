; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

A_DefaultGui(wParam := "") {
   ; majkinetor : A_DefaultGui()  -> www.autohotkey.com/board/topic/24532-function-a-defaultgui/
   ; Lexikos    : GetDefaultGui() -> www.autohotkey.com/board/topic/84414-ahk-l-get-the-current-default-gui-name/
   
   Static Msg := 0				             ; has to be 0, otherwise If (wParam = Msg) is true
   Static DefaultGui
   static first_call := true
   
   If (wParam = Msg) {                       ; called by OnMessage
      DefaultGui := A_Gui
      Return 0
   }
   
   if(first_call) {       
	 first_call := false                     
	 if(OnMessage(msg) != "")                ; safety check that the script doesn't already
	    return, "", ErrorLevel := 1          ; monitor the msg through some other function
	 try DllCall("User32.dll\RegisterWindowMessage", "Str", "GetDefaultGui", "UInt")
	 catch
		return, "", ErrorLevel := 2          ; and that RegisterWindowMessage worked
   }
   
   LastFoundWindow := WinExist()             ; save the Last Found Window, if any
   
   Gui, +LastFoundExist                      ; check if the default Gui exists,
   If !WinExist()							 ; if not, it has to be created
      ;Gui, New, +LastFound +hwndHDESTROY
		; sets the new default gui window, we don't want that
		; 
      Gui, +LastFound +hwndHDESTROY
   
   OnMessage(Msg, A_ThisFunc)            	; get the current default Gui
   try DllCall("User32.dll\SendMessage", "Ptr", WinExist(), "UInt", Msg, "Ptr", Msg, "Ptr", 0)
   catch
	   return, "", ErrorLevel := 3
   
   OnMessage(Msg, "")
   
   If (HDESTROY)                             ; if the dummy Gui has been created, destroy it
      Gui, %HDESTROY%: Destroy
   
   If (LastFoundWindow) {                    ; if the Last Found Window had been set, restore it ...
	  A_DetectHiddenWindowsOld := A_DetectHiddenWindows
      DetectHiddenWindows, On                ; precaution: window to be restored can be hidden
      WinExist("ahk_id" LastFoundWindow)
	  DetectHiddenWindows, % A_DetectHiddenWindowsOld
   }
   Else                                      ; ... otherwise clear it
      Gui, %A_ThisFunc%_NonexistentGui: +LastFoundExist
   Return DefaultGui, ErrorLevel := 0
}
