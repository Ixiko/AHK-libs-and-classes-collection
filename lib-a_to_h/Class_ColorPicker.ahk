; AutoHotkey Version: 1.1.12.00
; Language:       	English
; Dev Platform:   	Windows 7 Home Premium x64
; Original Author:	Joe DF  |  http://joedf.co.nr  |  joedf@users.sourceforge.net
; Date:           	August 20th, 2013
; Link:			https://autohotkey.com/boards/viewtopic.php?t=65
;
; Script Function:
;   Color Dialog script.
;
; Extended and rewritten as a class for the PoE-TradeMacro script (https://github.com/PoE-TradeMacro/POE-TradeMacro)
; Author:			Eruyome
; Date:			October 7th, 2017
; Class function:
;	Color picker UI with color preview (including opacity).
;	Returns an array with:
;		ARGB hex value (0x00000000)
;		RGB hex value (000000)
;		Alpha value in percent (100)

class ColorPicker
{
	__New(RGBv = "", Av = "", PickerTitle = "Color Picker", bgImage = "") 
	{		
		/*
			RBGv:		RGB hex value (000000 - FFFFFF).
			Av:			Alpha/Opacity (0 - 100) %.
			PickerTitle:	Window title.
			bgImage:		Optional background image for the color preview.
		*/
		
		global
		RGBv	:= this.ValidateRGBColor(RGBv, "FFFFFF")
		Av	:= (not StrLen(Av) > 0) ? 85 : this.ValidateOpacity(Av, 100)
		
		RegexMatch(RGBv, "i)(.{2})(.{2})(.{2})", match)
		RegexMatch(this.hexToRgb(RGBv), "i)(\d+),\s?(\d+),\s?(\d+)", match)
		Rval	:= match1
		Gval	:= match2
		Bval	:= match3
		Aval	:= Av
		ARGBval	:= this.rgbaToARGBHex(Rval, Gval, Bval, Aval)
		RGBval	:=	
		hasImage	:= FileExist(bgImage)		
		
		ColorPickerResultARGBHex	:= ARGBval
		ColorPickerResultColor	:= RegexReplace(ARGBval, "i)^.{4}")
		ColorPickerResultTrans	:= Aval
		
		;Destroy GUIs in case they still exist
		Gui, GDIColorPicker:Destroy
		Gui, GDIColorPickerPreview:Destroy
		
		;Create Color Dialog GUI
		Gui, GDIColorPicker:Add, Text, x0 y10 w75 h20 +Right, Red
		Gui, GDIColorPicker:Add, Text, x0 y30 w75 h20 +Right, Green
		Gui, GDIColorPicker:Add, Text, x0 y50 w75 h20 +Right, Blue
		Gui, GDIColorPicker:Add, Text, x0 y70 w75 h20 +Right, Alpha/Opacity		
		Gui, GDIColorPicker:Add, Slider, x75 y10 w190 h20 AltSubmit +NoTicks +Range0-255 vsR gColorPickerSliderSub, %Rval%
		Gui, GDIColorPicker:Add, Slider, x75 y30 w190 h20 AltSubmit +NoTicks +Range0-255 vsG gColorPickerSliderSub, %Gval%
		Gui, GDIColorPicker:Add, Slider, x75 y50 w190 h20 AltSubmit +NoTicks +Range0-255 vsB gColorPickerSliderSub, %Bval%
		Gui, GDIColorPicker:Add, Slider, x75 y70 w190 h20 AltSubmit +NoTicks +Range0-100 vsA gColorPickerSliderSub, %Aval%
		Gui, GDIColorPicker:Add, Edit, x265 y10 w45 h20 gColorPickerEditSub veR +Limit3 +Number, %Rval%
		Gui, GDIColorPicker:Add, UpDown, Range0-255 vuR gColorPickerUpDownSub, %Rval%
		Gui, GDIColorPicker:Add, Edit, x265 y30 w45 h20 gColorPickerEditSub veG +Limit3 +Number, %Gval%
		Gui, GDIColorPicker:Add, UpDown, Range0-255 vuG gColorPickerUpDownSub, %Gval%
		Gui, GDIColorPicker:Add, Edit, x265 y50 w45 h20 gColorPickerEditSub veB +Limit3 +Number, %Bval%
		Gui, GDIColorPicker:Add, UpDown, Range0-255 vuB gColorPickerUpDownSub, %Bval%
		Gui, GDIColorPicker:Add, Edit, x265 y70 w45 h20 gColorPickerEditSub veA +Limit3 +Number, %Aval%
		Gui, GDIColorPicker:Add, UpDown, Range0-100 vuA gColorPickerUpDownSub, %Aval%
		If (hasImage) {
			Gui, GDIColorPicker:Add, Picture, vPbg w80 h80 x315 y10, %bgImage%
			Gui, GDIColorPicker:Add, Button, x315 y100 w80 h20 gColorPickerButtonToggleBg, Toggle BG
			showImage := true
		}		
		Gui, GDIColorPicker:Add, Button, x115 y100 w80 h20 vbS gColorPickerButtonSave, Save
		Gui, GDIColorPicker:Add, Button, x+10 y100 w80 h20 gColorPickerButtonCancel, Cancel
		Gui, GDIColorPicker:+LastFound
		Gui, GDIColorPicker:Show, w401 h125, % PickerTitle
		GuiControl, Hide, Pbg

		MainhWnd := WinExist()

		Gui, GDIColorPickerPreview: New, +AlwaysOnTop -resize -SysMenu -Caption
		gui, GDIColorPickerPreview: color, blue
		Gui, GDIColorPickerPreview: Show, x315 y10 w80 h80
		Gui, GDIColorPickerPreview: +LastFound
		SubhWnd := WinExist()
		DllCall("SetParent", "uint", SubhWnd, "uint", MainhWnd)
		WinSet, Style, -0xC00000, A
		WinActivate, ahk_id %MainhWnd%
		GoSub, ColorPickerSetValues
		
		; wait until the GUI is closed to return the picked color values
		WinWaitClose, ahk_id %MainhWnd%
		Results := [ColorPickerResultARGBHex, ColorPickerResultColor, ColorPickerResultTrans]
		
		Return Results
		
		/* 
			GUI Labels
		*/
		ColorPickerEditSub:
			;Get Values
			GuiControlGet, Rval, GDIColorPicker:, eR
			GuiControlGet, Gval, GDIColorPicker:, eG
			GuiControlGet, Bval, GDIColorPicker:, eB
			GuiControlGet, Aval, GDIColorPicker:, eA
			;Set preview
			GoSub ColorPickerSetValues
			;Make Everything else aware
			GuiControl, GDIColorPicker:, uR, %Rval%
			GuiControl, GDIColorPicker:, uG, %Gval%
			GuiControl, GDIColorPicker:, uB, %Bval%
			GuiControl, GDIColorPicker:, uA, %Aval%
			GuiControl, GDIColorPicker:, sR, %Rval%
			GuiControl, GDIColorPicker:, sG, %Gval%
			GuiControl, GDIColorPicker:, sB, %Bval%
			GuiControl, GDIColorPicker:, sA, %Aval%	
		Return

		ColorPickerUpDownSub:
			;Get Values
			GuiControlGet, Rval, GDIColorPicker:, uR
			GuiControlGet, Gval, GDIColorPicker:, uG
			GuiControlGet, Bval, GDIColorPicker:, uB
			GuiControlGet, Aval, GDIColorPicker:, uA
			;Set preview
			GoSub ColorPickerSetValues
			;Make Everything else aware
			GuiControl, GDIColorPicker:, eR, %Rval%
			GuiControl, GDIColorPicker:, eG, %Gval%
			GuiControl, GDIColorPicker:, eB, %Bval%
			GuiControl, GDIColorPicker:, eA, %Aval%
			GuiControl, GDIColorPicker:, sR, %Rval%
			GuiControl, GDIColorPicker:, sG, %Gval%
			GuiControl, GDIColorPicker:, sB, %Bval%
			GuiControl, GDIColorPicker:, sA, %Aval%
		Return

		ColorPickerSliderSub:
			;Get Values
			GuiControlGet, Rval, GDIColorPicker:, sR
			GuiControlGet, Gval, GDIColorPicker:, sG
			GuiControlGet, Bval, GDIColorPicker:, sB
			GuiControlGet, Aval, GDIColorPicker:, sA
			;Set preview
			GoSub ColorPickerSetValues
			;Make Everything else aware
			GuiControl,, eR, %Rval%
			GuiControl,, eG, %Gval%
			GuiControl,, eB, %Bval%
			GuiControl,, eA, %Aval%
			GuiControl,, uR, %Rval%
			GuiControl,, uG, %Gval%
			GuiControl,, uB, %Bval%
			GuiControl,, uA, %Aval%
		Return

		ColorPickerSetValues:
			;Convert values to Hex
			ARGBval	:= this.rgbaToARGBHex(Rval, Gval, Bval, Aval)
			RGBVal	:= RegexReplace(ARGBval, "i)^.{4}")
			
			; remove "0x" and alpha value and convert alpha value to 0-255
			windowColor	:= RegexReplace(ARGBval, "i)^.{4}")
			alpha		:= Aval / 100 * 255
			Gui, GDIColorPickerPreview:Color, %windowColor%
			WinSet, Transparent, %alpha%, ahk_id %SubhWnd%
			
			;Display Tooltip
			ToolTip Red: %Rval%`nGreen: %Gval%`nBlue: %Bval%`nOpacity: %Aval%`%`nHex: %ARGBval%
			;Make tooltip disappear after 375 ms (3/8th of a second)
			SetTimer, ColorPickerRemoveToolTip, 375
			;Apply colour to preview
			GuiControl, +Background%ARGBval%, pC
		Return

		ColorPickerRemoveToolTip:
			SetTimer, ColorPickerRemoveToolTip, Off ;Turn timer off
			ToolTip ;Turn off tooltip
		Return

		ColorPickerButtonSave:
			ColorPickerResultARGBHex	:= ARGBval
			ColorPickerResultColor	:= RegexReplace(ARGBval, "i)^.{4}")
			ColorPickerResultTrans	:= Aval
			
			;Remove '0x' prefix to hex color code, saving it directly to the clipboard
			StringReplace, Clipboard, ARGBval, 0x
			;Display Last selected values... (these values can later be used), and Notify the user
			output := "RGBA: (" Rval ", " Gval ", " Bval ", " Round(Aval / 100, 2) ")`nARGB Hex: " ARGBval "`nCopied to Clipboard!"
			;MsgBox, 64, Simple Color Dialog, % output
			
			Gui, GDIColorPicker:Destroy
			Gui, GDIColorPickerPreview:Destroy			
		Return
		
		ColorPickerButtonCancel:
			Gui, GDIColorPicker:Destroy
			Gui, GDIColorPickerPreview:Destroy
		Return
		
		ColorPickerButtonToggleBg:
			GuiControl, % ( showImage ) ? "hide" : "show", Pbg
			showImage := showImage ? false : true
		Return
		
		GDIColorPickerPreviewGuiEscape:
			Gui, GDIColorPickerPreview:Destroy
		Return
	}
	
	rgbaToARGBHex(r, g, b, a) {
		; convert percent alpha to 0-255
		a := (a / 100) * 255
		if (a < 1) {
			a := Floor(a)
		} else {
			a := Ceil(a)
		}
		
		; won't work without IntegerFast when called from a Label
		SetFormat, IntegerFast, % (f := A_FormatInteger) = "D" ? "H" : f
		h := a + 0 . r + 0 . g + 0 . b + 0
		SetFormat, Integer, %f%
		
		res := "0x" . RegExReplace(RegExReplace(h, "0x(.)(?=$|0x)", "0$1"), "0x")
		Return, res
	}	
	
	hexToRgb(s, d = "") {
		SetFormat, Integer, % (f := A_FormatInteger) = "H" ? "D" : f
		Loop, % StrLen(s := RegExReplace(s, "^(?:0x|#)")) // 2
			c%A_Index% := 0 + (h := "0x" . SubStr(s, A_Index * 2 - 1, 2))
		SetFormat, Integer, %f%
		Return, c1 . (d := d = "" ? "," : d) . c2 . d . c3
	}
	
	ValidateRGBColor(Color, Default) {
		StringUpper, Color, Color
		RegExMatch(Trim(Color), "i)(^[0-9A-F]{6}$)", hex)
		Return StrLen(hex) ? hex : Default
	}
	
	ValidateOpacity(Opacity, Default) {
		Opacity := Opacity + 0	; convert string to int
		If (not RegExMatch(Opacity, "i)[0-9]+")) {
			Opacity := Default
		}
		If (Opacity > 100) {
			Opacity := 100
		} Else If (Opacity < 0) {
			Opacity := 0
		}
		
		Return Opacity
	}
}