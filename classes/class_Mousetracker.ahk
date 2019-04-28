; ----------------------------------------------------------------------------------------------------------------------
; Name .........: MouseTracker class library
; Description ..: Track mouse when entering and leaving GUIs/Controls.
; AHK Version ..: AHK_L 1.1.30.01 x32/64 ANSI/Unicode
; Author .......: cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Feb. 24, 2019 - v0.1   - First version.
; ..............: Feb. 27, 2019 - v0.2   - Implemented multi handle tracking.
; ..............: Feb. 27, 2019 - v0.2.1 - Fixed issue with WM_MOUSEMOVE events not flagged as managed.
; Remarks ......: Uses the following functions, structures and messages from Win32 API.
; ..............: "WM_MOUSEMOVE" Win32 message:
; ..............: https://docs.microsoft.com/en-us/windows/desktop/inputdev/wm-mousemove
; ..............: "WM_MOUSELEAVE" Win32 message:
; ..............: https://docs.microsoft.com/en-us/windows/desktop/inputdev/wm-mouseleave
; ..............: "TrackMouseEvent" Win32 function:
; ..............: https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-trackmouseevent
; ..............: "TRACKMOUSEEVENT" Win32 structure:
; ..............: https://docs.microsoft.com/en-us/windows/desktop/api/winuser/ns-winuser-tagtrackmouseevent
; ----------------------------------------------------------------------------------------------------------------------

/*

* Simple usage example:
-----------------------

	#Include <MouseTracker>
    Global logStr

	Gui, +LastFound
	Gui, Add, Edit, vLog1 +HWNDhLog1 w500 r40
	Gui, Show, AutoSize x10 y10

	MouseTracker.Track([hLog1, Func("cbME"), ""])
	Return

	GuiClose()
	{
		MouseTracker.UnTrack()
		ExitApp
	}

	cbME( aGui, aGuiCtrl, wParam, lParam, Msg, hWnd )
	{
		logStr .= "MOUSE ENTER: " hWnd "`n"
		GuiControl,, Log1, %logStr%
		MouseTracker.Track([hWnd, "", Func("cbML")])
	}

	cbML( aGui, aGuiCtrl, wParam, lParam, Msg, hWnd )
	{
		logStr .= "MOUSE LEAVE: " hWnd "`n"
		GuiControl,, Log1, %logStr%
		MouseTracker.Track([hWnd, Func("cbME"), ""])
	}


* Complex usage example:
------------------------

	#Include <MouseTracker>
    Global logStr, hGui, hEntered
	
	Gui, +HWNDhGui
	Gui, Add, Edit,     vLog1 +HWNDhLog1 w500 r40
	Gui, Add, Progress, vPro1 +HWNDhPro1 w248 h100 BackgroundFF0000
	Gui, Add, Progress, vPro2 +HWNDhPro2 w248 h100 x+2 BackgroundFF0000
	Gui, Show, AutoSize x10 y10

	MouseTracker.Track([hPro1, Func("cbME"), ""], [hPro2, Func("cbME"), ""])
	Return

	GuiClose()
	{
		MouseTracker.UnTrack()
		ExitApp
	}

	cbME( aGui, aGuiCtrl, wParam, lParam, Msg, hWnd )
	{
		logStr .= "MOUSE ENTER: " hWnd "`n"
		GuiControl,, Log1, %logStr%

		GuiControlGet, %aGuiCtrl%, Pos
        VarSetCapacity(POINT, 8, 0)
        NumPut(%aGuiCtrl%x, POINT, 0, "Int")
        NumPut(%aGuiCtrl%y, POINT, 4, "Int")
        DllCall( "User32.dll\ClientToScreen", Ptr,hGui, Ptr,&POINT )

		Gui, OV: +Owner%hGui% -Caption +Toolwindow
		Gui, OV: Margin, 0, 0
		Gui, OV: Add, Progress, +HWNDhPro3 w248 h100 Background0000FF
		Gui, OV: Show, % "w" 248 " h" 100 " x" NumGet(POINT, 0, "Int") " y" NumGet(POINT, 4, "Int") NA

		hEntered := hWnd
		MouseTracker.Track([hPro3, "", Func("cbML")])
	}

	cbML( aGui, aGuiCtrl, wParam, lParam, Msg, hWnd )
	{
		logStr .= "MOUSE LEAVE: " hWnd "`n"
		GuiControl,, Log1, %logStr%

		Gui, OV: Destroy

		MouseTracker.Track([hEntered, Func("cbME"), ""])
	}

*/

; Name .........: MouseTracker - PUBLIC STATIC CLASS
; Description ..: Manages mouse tracking on GUIs and Controls through WM_MOUSEMOVE and WM_MOUSELEAVE.
Class MouseTracker {
	Static WM_MOUSEMOVE         := 0x0200
	     , WM_MOUSELEAVE        := 0x02A3
		 , FN_MOUSEENTER        := "__MT_MOUSEMOVE"
         , FN_MOUSELEAVE        := "__MT_MOUSELEAVE"
	     , TME_LEAVE            := 0x00000002
		 , TME_CANCEL           := 0x80000000
	     , TME_CBSIZE_OFFT      := 0
	     , TME_DWFLAGS_OFFT     := 4
	     , TME_HWNDTRACK_OFFT   := 8
	     , TME_DWHOVERTIME_OFFT := A_PtrSize == 8 ? 16 : 12
	     , TME_CBSIZE           := A_PtrSize == 8 ? 24 : 16
		 , TME_DWHOVERTIME      := 1 ; Arbitrary value.
		 , FLAGS_CANCEL_LEAVE   := 0x80000000|0x00000002i
		 , TIMER_SAFE_VALUE     := Abs(StrReplace(A_BatchLines, "ms"))+1

	; Disallow instantiation.
	__New( )
	{
		Return False
	}

    ; Name .........: Track - PUBLIC STATIC METHOD
    ; Description ..: Initialize mouse tracking on the desired handle.
    ; Parameters ...: arrTracking* = Variadic parameter accepting a series of request arrays.
	; ..............: Request array form is: [ hWnd, cbEnter, cbLeave ]
	; ............... hWnd    = Handle to the GUI or Control to be checked for mouse tracking.
	; ..............: cbEnter = Callback - Fires when the mouse is hovering the desired handle.
	; ..............: cbLeave = Callback - Fires when the mouse has left the desired handle.
	; ..............:                      Fires if mouse is not on the handle when called.
	; Remarks ......: The functions used as callbacks must accept 6 parameters:
	; ..............: A_Gui, A_GuiControl, wParam, lParam, Msg, hWnd.
	; ..............: For info about those parameter, please check "OnMessage" in AutoHotkey documentation.
	; ..............: Tracking lasts only for one event, it must be reinstantiated in the callbacks if required.
	; ..............: Please keep tracking reinstantiation code as last line in the callback to avoid issues.
	Track( arrTracking* )
	{
		; Initialize memory and requests object during first call.
		If ( !MouseTracker.p_TME )
		{
			If ( (MouseTracker.p_TME := DllCall("LocalAlloc", UInt,0x0040, UInt,MouseTracker.TME_CBSIZE)) == "" )
				Return False
		    NumPut(MouseTracker.TME_CBSIZE,      MouseTracker.p_TME+0, MouseTracker.TME_CBSIZE_OFFT,      "UInt")
		  , NumPut(MouseTracker.TME_DWHOVERTIME, MouseTracker.p_TME+0, MouseTracker.TME_DWHOVERTIME_OFFT, "UInt")
		  , MouseTracker.Requests := {}		
		}

		Loop % arrTracking.Length()
		{
			; Get single request array from parameters array:
			; arrRequest[1] = hWnd GUI/Control.
			; arrRequest[2] = Mouse Enter Callback.
			; arrRequest[3] = Mouse Leave Callback.
			arrRequest := arrTracking[A_Index]

			; Create the request object, available globally, if not present. Request is identified by the hWnd:
			; { hWnd : { "cb_ME" : Callback_Mouse_Enter , "cb_ML" " Callback_Mouse_Leave } }
			If ( !MouseTracker.Requests[arrRequest[1]] )
				MouseTracker.Requests[arrRequest[1]] := { "cb_ME":0, "cb_ML":0 }

			; Track mouse leave. We implemented it monitoring the WM_MOUSELEAVE message. This 
			; kind of tracking must be requested with the "TrackMouseEvent" Win32 system call.
			If ( arrRequest[3] != "" ) ; arrRequest[3] = Mouse Leave Callback.
			{
				; Cancel a previous tracking request if it's of the same type of the new one.
				If ( MouseTracker.Requests[arrRequest[1]].cb_ML )
					NumPut( arrRequest[1]
					      , MouseTracker.p_TME+0
						  , MouseTracker.TME_HWNDTRACK_OFFT
						  , "Ptr" )
				  , NumPut( MouseTracker.FLAGS_CANCEL_LEAVE
				          , MouseTracker.p_TME+0
						  , MouseTracker.TME_DWFLAGS_OFFT
						  , "UInt" )
				  , DllCall("TrackMouseEvent", Ptr,MouseTracker.p_TME)
				  , OnMessage(MouseTracker.WM_MOUSELEAVE, "")

			   ; Issue a new request with the desired tracking values.
			    NumPut( arrRequest[1]
			          , MouseTracker.p_TME+0
					  , MouseTracker.TME_HWNDTRACK_OFFT
					  , "Ptr")
			  , NumPut( MouseTracker.TME_LEAVE
			          , MouseTracker.p_TME+0
					  , MouseTracker.TME_DWFLAGS_OFFT
					  , "UInt" )
			  , DllCall("TrackMouseEvent", Ptr,MouseTracker.p_TME)

				; Add the Mouse Leave Callback to the request object.
			    MouseTracker.Requests[arrRequest[1]].cb_ML := arrRequest[3]
			  , b_ML := True ; Flag WM_MOUSELEAVE monitoring as required.
			}

			; Track mouse enter. We implemented it monitoring the WM_MOUSEMOVE message. This message
			; is normally sent to all windows when the mouse is hovering them. We ditched monitoring
			; of the WM_MOUSEHOVER message because its usage is quirky and prone to errors.
			If ( arrRequest[2] != "" ) ; arrRequest[2] = Mouse Enter Callback.
				MouseTracker.Requests[arrRequest[1]].cb_ME := arrRequest[2]
			  , b_MM := True ; Flag WM_MOUSEMOVE monitoring as required.
		}

		; Start monitoring if flagged as required.
		If ( b_ML )
			OnMessage(MouseTracker.WM_MOUSELEAVE, MouseTracker.FN_MOUSELEAVE)
		If ( b_MM )
			OnMessage(MouseTracker.WM_MOUSEMOVE,  MouseTracker.FN_MOUSEENTER)
			
		Return True
	}

    ; Name .........: UnTrack - PUBLIC STATIC METHOD
    ; Description ..: Disable all message management and free memory.
	UnTrack()
	{
		OnMessage(MouseTracker.WM_MOUSEMOVE,  "")
		OnMessage(MouseTracker.WM_MOUSELEAVE, "")
		DllCall("LocalFree", Ptr,MouseTracker.p_TME)
		MouseTracker.p_TME    := 0
		MouseTracker.Requests := ""
	}
}

; Name .........: __HT_MOUSEMOVE - PRIVATE FUNCTION
; Description ..: Manage WM_MOUSEMOVE message.
__MT_MOUSEMOVE( wParam, lParam, Msg, hWnd ) {
	If ( !MouseTracker.Requests[hWnd].cb_ME )
		Return

	OnMessage(MouseTracker.WM_MOUSEMOVE, "")
  , objBf := MouseTracker.Requests[hWnd].cb_ME.Bind(A_Gui, A_GuiControl, wParam, lParam, Msg, hWnd)
  , MouseTracker.Requests[hWnd].cb_ME := 0 ; Avoid entering this function again for the same hWnd.
	
	; Call the BoundFounc object after the function returned.
	SetTimer, % objBf, % -(MouseTracker.TIMER_SAFE_VALUE)

	Return
}

; Name .........: __HT_MOUSELEAVE - PRIVATE FUNCTION
; Description ..: Manage WM_MOUSELEAVE message.
__MT_MOUSELEAVE( wParam, lParam, Msg, hWnd ) {
	OnMessage(MouseTracker.WM_MOUSELEAVE, "")
  , objBf := MouseTracker.Requests[hWnd].cb_ML.Bind(A_Gui, A_GuiControl, wParam, lParam, Msg, hWnd)
  , MouseTracker.Requests[hWnd].cb_ML := 0 ; Important for the "previous tracking request" check.

	; Call the BoundFounc object after the function returned.
	SetTimer, % objBf, % -(MouseTracker.TIMER_SAFE_VALUE)

	Return
}