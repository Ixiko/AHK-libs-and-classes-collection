; ----------------------------------------------------------------------------------------------------------------------
; Function .....: AnchorL
; Description ..: Defines controls positioning on window resize.
; Parameters ...: i - a control HWND, associated variable name or ClassNN to operate on.
; ..............: a - (optional) one or more of the anchors: 'x', 'y', 'w' (width) and 'h' (height), optionally followed 
; ..............:     by a relative factor, e.g. "x h0.5".
; ..............: r - (optional) true to redraw controls, recommended for GroupBox and Button types.
; AHK Version ..: AHK_L x32/64 ANSI/Unicode
; Author .......: polyethene <http://www.autohotkey.net/~polyethene/#anchor>
; License ......: CC0 1.0 <http://creativecommons.org/publicdomain/zero/1.0/>
; Version ......: 4.60a
; Remarks ......: To assume the current window size for the new bounds of a control (i.e. resetting) simply omit the 
; ..............: second and third parameters. However if the control had been created with DllCall() and has its own 
; ..............: parent window, the container AutoHotkey created GUI must be made default with the +LastFound option 
; ..............: prior to the call. For a complete example see anchor-example.ahk.
; ----------------------------------------------------------------------------------------------------------------------
AnchorL(i, a:="", r:=False) {
	Static c, cs := 12, cx := 255, cl := 0, g, gs := 8, gl := 0, gpi, gw, gh, z := 0, k := 0xffff
	If ( z == 0 )
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := True
	If ( !WinExist("ahk_id" i) ) {
		GuiControlGet, t, Hwnd, %i%
		If ( ErrorLevel == 0 )
			i := t
		Else ControlGet, i, Hwnd,, %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall( "GetWindowInfo", Ptr,gp:=DllCall("GetParent",Ptr,i), Ptr,&gi )
  , giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If ( gp != gpi ) {
		gpi := gp
		Loop, %gl%
			If ( NumGet(g, cb := gs * (A_Index - 1)) == gp ) {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If ( !gf )
			NumPut(gp, g, gl), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh,, ahk_id %i%
	Loop, %cl%
		If ( NumGet(c, cb := cs * (A_Index - 1)) == i ) {
			If ( !a )
			{
				cf := 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
		  , cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If ( A_Index > 1 )
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
				  , d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall( "SetWindowPos", Ptr,i, Ptr,0, Int,dx, Int,dy, Int,InStr(a,"w")?dw:cw, Int,InStr(a,h)?dh:ch, Int,4 )
			If ( r != 0 )
				DllCall( "RedrawWindow", Ptr,i, Ptr,0, Ptr,0, UInt,0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If ( cf != 1 )
		cb := cl, cl += cs
	bx := NumGet(gi, 48), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52)
	If ( cf == 1 )
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
  , NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}
