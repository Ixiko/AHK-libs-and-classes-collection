/*! TheGood
    AHKHID - An AHK implementation of the HID functions.
    AHKHID Example 1
    Last updated: August 22nd, 2010
    
    List all the HID devices connected to the computer.
    This example shows how to use all the AHKHID_GetDev functions (like AHKHID_GetDevInfo()).
    _________________________________________________
    1. Simply run the script.
    2. Press Ctrl+c on a selected item to copy its name.
*/

;Check if the OS is Windows Vista or higher
bVista := (DllCall("GetVersion") & 0xFF >= 6)

;Create GUI
Gui +Resize -MaximizeBox -MinimizeBox
Gui, Add, Tab2, x6 y10 w460 h190 vMyTabs, Keyboards|Mice|Other
Gui, Tab, 1
Gui, Add, ListView, x16 y40 w440 h150 vlvwKeyb gLV_Event AltSubmit, Name|Type|SubType|Keyboard Mode|Number of Function Keys|Number of Indicators|Number of Keys Total
Gui, Tab, 2
Gui, Add, ListView, x16 y40 w440 h150 vlvwMouse gLV_Event AltSubmit, Name|Mouse ID|Number of Buttons|Sample Rate
If bVista
    LV_InsertCol(5, "", "Has Horizontal Wheel")
Gui, Tab, 3
Gui, Add, ListView, x16 y40 w440 h150 vlvwOther gLV_Event, Name|Vendor ID|Product ID|Version Number|Usage Page|Usage

;Set up the constants
AHKHID_UseConstants()

;Get count
iCount := AHKHID_GetDevCount()
	
;Retrieve info for each device
Loop %iCount% {
    
    HID0 += 1
    
    ;Get device handle, type and name
    HID%HID0%_Handle := AHKHID_GetDevHandle(HID0)
    HID%HID0%_Type   := AHKHID_GetDevType(HID0)
    HID%HID0%_Name   := AHKHID_GetDevName(HID0)
    
    ;Get device info
    If (HID%HID0%_Type = RIM_TYPEMOUSE) {
        HID%HID0%_ID            := AHKHID_GetDevInfo(HID0, DI_MSE_ID)
        HID%HID0%_Buttons       := AHKHID_GetDevInfo(HID0, DI_MSE_NUMBEROFBUTTONS)
        HID%HID0%_SampleRate    := AHKHID_GetDevInfo(HID0, DI_MSE_SAMPLERATE)
        If bVista ;Only supported in Windows Vista and higher
            HID%HID0%_HWheel    := AHKHID_GetDevInfo(HID0, DI_MSE_HASHORIZONTALWHEEL)
    } Else If (HID%HID0%_Type = RIM_TYPEKEYBOARD) {
        HID%HID0%_KBType        := AHKHID_GetDevInfo(HID0, DI_KBD_TYPE)
        HID%HID0%_KBSubType     := AHKHID_GetDevInfo(HID0, DI_KBD_SUBTYPE)
        HID%HID0%_KeyboardMode  := AHKHID_GetDevInfo(HID0, DI_KBD_KEYBOARDMODE)
        HID%HID0%_FunctionKeys  := AHKHID_GetDevInfo(HID0, DI_KBD_NUMBEROFFUNCTIONKEYS)
        HID%HID0%_Indicators    := AHKHID_GetDevInfo(HID0, DI_KBD_NUMBEROFINDICATORS)
        HID%HID0%_KeysTotal     := AHKHID_GetDevInfo(HID0, DI_KBD_NUMBEROFKEYSTOTAL)
    } Else If (HID%HID0%_Type = RIM_TYPEHID) {
        HID%HID0%_VendorID      := AHKHID_GetDevInfo(HID0, DI_HID_VENDORID)
        HID%HID0%_ProductID     := AHKHID_GetDevInfo(HID0, DI_HID_PRODUCTID)
        HID%HID0%_VersionNumber := AHKHID_GetDevInfo(HID0, DI_HID_VERSIONNUMBER)
        HID%HID0%_UsagePage     := AHKHID_GetDevInfo(HID0, DI_HID_USAGEPAGE)
        HID%HID0%_Usage         := AHKHID_GetDevInfo(HID0, DI_HID_USAGE)
    }
}

;Add to listviews according to type
Loop %HID0% {
    If (HID%A_Index%_Type = RIM_TYPEMOUSE) {
        Gui, ListView, lvwMouse
        If bVista ;Only supported in Windows Vista and higher
            LV_Add("",HID%A_Index%_Name, HID%A_Index%_ID, HID%A_Index%_Buttons, HID%A_Index%_SampleRate, HID%A_Index%_HWheel)
        Else LV_Add("",HID%A_Index%_Name, HID%A_Index%_ID, HID%A_Index%_Buttons, HID%A_Index%_SampleRate)
    } Else If (HID%A_Index%_Type = RIM_TYPEKEYBOARD) {
        Gui, ListView, lvwKeyb
        LV_Add("", HID%A_Index%_Name, HID%A_Index%_KBType, HID%A_Index%_KBSubType, HID%A_Index%_KeyboardMode
        , HID%A_Index%_FunctionKeys, HID%A_Index%_Indicators, HID%A_Index%_KeysTotal)
    } Else If (HID%A_Index%_Type = RIM_TYPEHID) {
        Gui, ListView, lvwOther
        LV_Add("", HID%A_Index%_Name, HID%A_Index%_VendorID, HID%A_Index%_ProductID, HID%A_Index%_VersionNumber
        , HID%A_Index%_UsagePage, HID%A_Index%_Usage)
    }
}

;Adjust column width
Gui, ListView, lvwMouse
Loop 5
    LV_ModifyCol(A_Index, "AutoHdr")
Gui, ListView, lvwKeyb
Loop 7
    LV_ModifyCol(A_Index, "AutoHdr")
Gui, ListView, lvwOther
Loop 6
    LV_ModifyCol(A_Index, "AutoHdr")
Gui, Show
Return

GuiSize:
    Anchor("MyTabs", "wh")
    Anchor("lvwKeyb", "wh")
    Anchor("lvwMouse", "wh")
    Anchor("lvwOther", "wh")
Return

GuiEscape:
GuiClose:
ExitApp

;Catch Ctrl+c presses to copy selected device name to clipboard
LV_Event:
    If (A_GuiEvent = "K") {
        If GetKeyState("c", "P") And GetKeyState("Ctrl", "P") {
            Gui, ListView, %A_GuiControl%
            LV_GetText(s, LV_GetNext())
            ClipBoard := s
        }
    } Else If (A_GuiEvent = "DoubleClick") {
        Gui, ListView, %A_GuiControl%
        LV_GetText(s, LV_GetNext())
        ClipBoard := s
    }
Return

;Anchor by Titan, adapted by TheGood
;http://www.autohotkey.com/forum/viewtopic.php?p=377395#377395
Anchor(i, a = "", r = false) {
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff, ptr
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), ptr := A_PtrSize ? "Ptr" : "UInt", z := true
	If (!WinExist("ahk_id" . i)) {
		GuiControlGet, t, Hwnd, %i%
		If ErrorLevel = 0
			i := t
		Else ControlGet, i, Hwnd, , %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), ptr, &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp, "UInt") {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl, "UInt"), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1), "UInt") == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "UInt", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48, "UInt"), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52, "UInt")
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb, "UInt"), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}
