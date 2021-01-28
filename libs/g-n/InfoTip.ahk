Infotip(fnText := "",fnX := 0,fnY := 0,fnRelocateOnScreen := 1,fnName := "",fnIsWarning := 0,fnDestroyDelay := 5000,ByRef fnInfotipX := 0,ByRef fnInfotipY := 0,ByRef fnInfotipW := 0,ByRef fnInfotipH := 0,ByRef fnInfotipID := "0x")
{
	; creates a tooltip-like message box
	; MsgBox fnText: %fnText%`n`nfnX: %fnX%`n`nfnY: %fnY%`n`nfnRelocateOnScreen: %fnRelocateOnScreen%`n`nfnName: %fnName%`n`nfnIsWarning: %fnIsWarning% `n`nfnDestroyDelay: %fnDestroyDelay%


	; declare local, global, static variables
	Global InfotipBackgroundColour, InfotipFont, InfotipFontSize, InfotipFontColour


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If fnX is not number
			Throw, Exception("fnX is not number")
		If fnY is not number
			Throw, Exception("fnY is not number")
		If fnRelocateOnScreen not in 0,1,2,3 ; 0 - specified position; 1 - entirely on screen; 2 - position by center of box; 3 - center on primary monitor
			Throw, Exception("fnRelocateOnScreen not in 0,1,2,3")


		; initialise variables
		SysGet, TotalScreenW, 78 ; SM_CXVIRTUALSCREEN ; get total screen width
		SysGet, TotalScreenH, 79 ; SM_CYVIRTUALSCREEN ; get total screen height
		
		If !fnName
			fnName := "Infotip"
		
		If (fnDestroyDelay > 0 && fnDestroyDelay < 100)
			fnDestroyDelay := 100
		
		If !InfotipFontSize
			InfotipFontSize := 12
		
		If !InfotipFontColour
			InfotipFontColour := "C000000"
		
		If !InfotipFont
			InfotipFont := "Courier"


		; destroy any existing infotip
		Gui, %fnName%: Destroy
		
		
		; no new infotip when no text
		If fnText
		{
			; set background colour
			BackgroundColour := fnIsWarning ? "880000" : InfotipBackgroundColour
			FontColour       := fnIsWarning ? "FFFFFF" : InfotipFontColour
			
			
			; create the infotip
			Gui, %fnName%:
				+AlwaysOnTop
				-Caption          ; removes title bar and window border
				+Disabled         ; prevents the user from interacting
				+Hwnd%fnName%Hwnd ; stores the infotip's Hwnd ID in %fnName%Hwnd ; see also PostMessage\SendMessage
				+Owner            ; avoids a taskbar button
			
			
			Gui, %fnName%: Margin, 5, 5
			Gui, %fnName%: Color, %BackgroundColour%
			Gui, %fnName%: Font, S%InfotipFontSize% C%FontColour% W%InfotipFontWeight%, %InfotipFont%
			Gui, %fnName%: Add, Text,, %fnText%
			Gui, %fnName%: Show, X%fnX% Y%fnY% NoActivate, %fnName%
			
			
			; find the current position
			WinGetPos, %fnName%X, %fnName%Y, %fnName%W, %fnName%H, %fnName% ahk_class AutoHotkeyGUI ahk_exe AutoHotkey.exe
			
			
			; make sure the infotip is not bigger than the entire screen
			If (%fnName%W >= TotalScreenW)
				%fnName%W := TotalScreenW-200
			
			If (%fnName%H >= TotalScreenH)
				%fnName%H := TotalScreenH-200
				
				
			; relocate infotip to be entirely on-screen
			If fnRelocateOnScreen
			{
				; when beyond the left edge
				If (%fnName%X < 0)
					%fnName%X := 0
				
				; when beyond the top edge
				If (%fnName%Y < 0)
					%fnName%Y := 0

				; when beyond the right edge
				OverlapX := %fnName%X+%fnName%W-TotalScreenW
				If (OverlapX > 0)
					%fnName%X -= OverlapX
				
				; when beyond the bottom edge
				OverlapY := %fnName%Y+%fnName%H-TotalScreenH
				If (OverlapY > 0)
					%fnName%Y -= OverlapY
				
				; when position by center of box
				If (fnRelocateOnScreen = 2)
				{
					%fnName%X -= %fnName%W/2
					%fnName%Y -= %fnName%H/2
				}
				
				; when centered on screen
				If (fnRelocateOnScreen = 3)
				{
					%fnName%X := Floor((A_ScreenWidth-%fnName%W)/2)
					%fnName%Y := Floor((A_ScreenHeight-%fnName%H)/2)
				}
			}
				
			; make the move
			WinMove, %fnName% ahk_class AutoHotkeyGUI ahk_exe AutoHotkey.exe,, %fnName%X, %fnName%Y
			
			; set ByRef values
			fnInfotipX  := %fnName%X
			fnInfotipY  := %fnName%Y
			fnInfotipW  := %fnName%W
			fnInfotipH  := %fnName%H
			fnInfotipID := %fnName%Hwnd
			
			
			; destroy
			If fnDestroyDelay > 0
			{
				Sleep, %fnDestroyDelay%
				Gui, %fnName%: Destroy
			}
		}
	}
	Catch, ThrownValue
	{
		; capture error values
		ErrorMessage := ThrownValue.Message, ErrorWhat := ThrownValue.What, ErrorExtra := ThrownValue.Extra, ErrorFile := ThrownValue.File, ErrorLine := ThrownValue.Line
		RethrowMessage := "Error at line " ErrorLine " of " ErrorWhat (ErrorMessage ? ": `n`n" ErrorMessage : "") (ErrorExtra ? "`n" ErrorExtra : "") ; (ErrorFile ? "`n`n" ErrorFile  : "")

		
		; set return value
		ReturnValue := !ReturnValue


		; take action on the error
		; MsgBox, 8500, %ApplicationName%, %RethrowMessage%`n`nOpen containing file?`n`n%ErrorFile%
		; IfMsgBox, Yes
			; Run, Edit %ErrorFile%


		; rethrow error to caller
		Throw, RethrowMessage
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
params := xxx
ReturnValue := Infotip(params)
MsgBox, Infotip`n`nReturnValue: %ReturnValue%
*/