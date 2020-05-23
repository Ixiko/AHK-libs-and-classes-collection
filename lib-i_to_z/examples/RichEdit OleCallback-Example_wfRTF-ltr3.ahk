DetectHiddenWindows, On


global toggle := toggle

;OnMessage(0x0111, "MyFunc")
drw := Clr_LoadLibrary("System.Drawing")
;showinfo(drw, "drw")
asm := Clr_LoadLibrary("EventHelper.dll")
helper := Clr_CreateObject(asm, "EventHelper")
;showinfo(helper, "helper")
forms := Clr_LoadLibrary("System.Windows.Forms")
;forms2 := Clr_LoadLibrary("System.Windows.Forms")
;showinfo(forms2, "forms2")
oform := Clr_CreateObject(forms, "System.Windows.Forms.Form")
;showinfo(oform, "oform")

oform.Text := "WinForms in AHK - RTF"
oform.Width := 800
oform.Height := 600


;****************First GroupBox Section
oGB1 := Clr_CreateObject(forms, "System.Windows.Forms.GroupBox")
;showinfo(ogb1, "ogb1")
oGB1.Height := 40
oGB1.Width := 186


;****************Second GroupBox Section
oGB2 := Clr_CreateObject(forms, "System.Windows.Forms.GroupBox")
oGB2.Height := oform.Height - 100
oGB2.Width := oform.Width - 20
oGB2.AutoSize := True
oGB2.AutoSizeMode := 1
oGB2.Top := oGB1.Bottom + 5
;oGB2.Dock := 5
oGB2.Anchor := 14

;;;;
oBtn1 := CLR_CreateObject(forms, "System.Windows.Forms.Button")
oBtn1.Text := "Open"
oBtn1.Width := 60
oBtn1.Height := 30
oBtn1.Left := 2
oBtn1.Top := 10

oBtn2 := CLR_CreateObject(forms, "System.Windows.Forms.Button")
oBtn2.Text := "Save"
oBtn2.Width := 60
oBtn2.Height := 30
oBtn2.Left := oBtn1.Right + 2
oBtn2.Top := oBtn1.Top

;;;;;;;;;;;Button for RTL
oBtn3 := CLR_CreateObject(forms, "System.Windows.Forms.Button")
oBtn3.Text := "RTL"
oBtn3.Width := 60
oBtn3.Height := 30
oBtn3.Left := oBtn2.Right + 2
oBtn3.Top := oBtn2.Top
;;;;;;;;;;;;;;

;;;;;;;;;;;Button for LTR
;~ oBtn4 := CLR_CreateObject(forms, "System.Windows.Forms.Button")
;~ oBtn4.Text := "LTR"
;~ oBtn4.Width := 60
;~ oBtn4.Height := 30
;~ oBtn4.Left := oBtn3.Right + 2
;~ oBtn4.Top := oBtn3.Top
;;;;;;;;;;;;;;


;*************************RichTextBox Section
global oRT := Clr_CreateObject(forms, "System.Windows.Forms.RichTextBox")
;showinfo(oRT, "oRT")
;~ oRT.Left := 20
;~ oRT.Top := oGB1.Bottom + 10
oRT.Width := oGB2.Height - 10
oRT.Height := oGB2.Height -10
;oRT.Height := oform.Height -150
oRT.AutoSize := True
oRT.ScrollBars := 2
oRT.Dock := 5
oRT.AllowDrop := True
;************************See the ENUMS at the end of the script*************************;

;;;;;;;;;;;;;;;
;Try to get its handle

;************************Dialog experiments *************************;
;~ global oFD := Clr_CreateObject(forms, "System.Windows.Forms.FontDialog")
;~ ;showinfo(ofd, "ofd")

;************************ Event handlers for the buttons *******************************;
; "Open" is oBtn1, "Save" is oBtn2
helper.AddHandler(oBtn1, "Click", "" RegisterCallback("EventHandler",,, 1))
helper.AddHandler(oBtn2, "Click", "" RegisterCallback("EventHandler",,, 2))
helper.AddHandler(oBtn3, "Click", "" RegisterCallback("EventHandler",,, 3))
;helper.AddHandler(oBtn4, "Click", "" RegisterCallback("EventHandler",,, 4))
;****************************************************************************************;

;****************************** Set the hierarchy ***************************************;
/*
Both groupboxes belong to the parent form "oform"; the buttons "oBtn1" and "oBtn2" belong
to the first groupbox "oGB1"; and the RichEdit belongs to the second groupbox "oGB2."
*/

oGB2.Parent := oform
oGB1.Parent := oform
oBtn1.Parent := oGB1
oBtn2.Parent := oGB1
oBtn3.Parent := oGB1
;oBtn4.Parent := oGB1
oRT.Parent := oGB2

;****************************************************************************************;

oform.ShowDialog()


;OnMessage(0x0111, "MyFunc")
oform.Dispose()
;msgbox done

ExitApp

ShowInfo(object, objname) {
vartype := ComObjType(object)
name := ComObjType(object, "Name")
IID     := ComObjType(object, "IID")
clsid := ComObjType(object, "CLSID")
cname := ComObjtype(object, "Class")
msgbox %objname%'s class is %cname%`r`nName is %name%`r`nCLSID is %clsid%`r`nIID is %IID%`r`n`r`nVT is %vartype%
}

; Our event handler is called with a SAFEARRAY of parameters.  This
; makes it much easier to get the type and value of each parameter.
EventHandler(pprm) {
    ; Wrap the SAFEARRAY pointer in an object for easy access.
    prm := ComObject(0x200C, pprm)
    ; Show parameters:
    info := A_EventInfo
    ;MsgBox, 0, Button Clicked, % "Button #" A_EventInfo " clicked."
    prm := ""
    pprm := ""
    If (info == 1) {
        SetWorkingDir, %A_ScriptDir%
        oRT.Text := ""
        Clipboard := ""
        FileSelectFile, rtfFile,,,,RichText Files (*.rtf)
        If(rtffile<>"")
            RTFtoClip(rtfFile)
        else {
            ;msgbox You did not pick a file!`nTry again.
            return
        }
        ;msgbox %rtfFile% was selected
        sleep, 200
        ControlClick, WindowsForms10.RichEdit20W.app.0.1f550a4_r31_ad11, WinForms in AHK - RTF
        oRT.Paste()
        Send, ^{HOME}
        rtffile := ""
        TomDoc := ""
        TomFile := ""
        RE := ""
    }
    Else If (info == 2) {
        FileSelectFile, myfile, S24, %A_ScriptDir%, Save as RTF (with extension!!!), Documents (*.rtf)
        If(myfile<>"")
            oRT.SaveFile(myfile)
        else
            return
        info =
        myfile =
    }
    Else If (info == 3) {
         toggle := !toggle
         If (toggle)
            oRT.RightToLeft := true
         else
            oRT.RightToLeft := false
    }
    else
        Return
}

Escape::
GuiClose:
;****************** Collect garbage ********************;
oform.Dispose()
asm := ""
forms := ""
helper := ""
;*******************************************************;
ExitApp
;;;;;;;;;;;;;;;;;;;;;;;

   ; ===================================================================================================================
   ChooseFont(RE) { ; Choose font dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
      DC := DllCall("User32.dll\GetDC", "Ptr", RE.GuiHwnd, "Ptr")
      LP := DllCall("GetDeviceCaps", "Ptr", DC, "UInt", 90, "Int") ; LOGPIXELSY
      DllCall("User32.dll\ReleaseDC", "Ptr", RE.GuiHwnd, "Ptr", DC)
      ; Get current font
      Font := RE.GetFont()
      ; LF_FACENAME = 32
      VarSetCapacity(LF, 92, 0)             ; LOGFONT structure
      Size := -(Font.Size * LP / 72)
      NumPut(Size, LF, 0, "Int")            ; lfHeight
      If InStr(Font.Style, "B")
         NumPut(700, LF, 16, "Int")         ; lfWeight
      If InStr(Font.Style, "I")
         NumPut(1, LF, 20, "UChar")         ; lfItalic
      If InStr(Font.Style, "U")
         NumPut(1, LF, 21, "UChar")         ; lfUnderline
      If InStr(Font.Style, "S")
         NumPut(1, LF, 22, "UChar")         ; lfStrikeOut
      NumPut(Font.CharSet, LF, 23, "UChar") ; lfCharSet
      StrPut(Font.Name, &LF + 28, 32)
      ; CF_BOTH = 3, CF_INITTOLOGFONTSTRUCT = 0x40, CF_EFFECTS = 0x100, CF_SCRIPTSONLY = 0x400
      ; CF_NOVECTORFONTS = 0x800, CF_NOSIMULATIONS = 0x1000, CF_LIMITSIZE = 0x2000, CF_WYSIWYG = 0x8000
      ; CF_TTONLY = 0x40000, CF_FORCEFONTEXIST =0x10000, CF_SELECTSCRIPT = 0x400000
      ; CF_NOVERTFONTS =0x01000000
      Flags := 0x00002141 ; 0x01013940
      Color := RE.GetBGR(Font.Color)
      CF_Size := (A_PtrSize = 8 ? (A_PtrSize * 10) + (4 * 4) + A_PtrSize : (A_PtrSize * 14) + 4)
      VarSetCapacity(CF, CF_Size, 0)                     ; CHOOSEFONT structure
      NumPut(CF_Size, CF, "UInt")                        ; lStructSize
      NumPut(RE.GuiHwnd, CF, A_PtrSize, "UPtr")		      ; hwndOwner (makes dialog modal)
      NumPut(&LF, CF, A_PtrSize * 3, "UPtr")	            ; lpLogFont
      NumPut(Flags, CF, (A_PtrSize * 4) + 4, "UInt")     ; Flags
      NumPut(Color, CF, (A_PtrSize * 4) + 8, "UInt")     ; rgbColors
      OffSet := (A_PtrSize = 8 ? (A_PtrSize * 11) + 4 : (A_PtrSize * 12) + 4)
      NumPut(4, CF, Offset, "Int")                       ; nSizeMin
      NumPut(160, CF, OffSet + 4, "Int")                 ; nSizeMax
      ; Call ChooseFont Dialog
      If !DllCall("Comdlg32.dll\ChooseFont", "Ptr", &CF, "UInt")
         Return false
      ; Get name
      Font.Name := StrGet(&LF + 28, 32)
   	; Get size
   	Font.Size := NumGet(CF, A_PtrSize * 4, "Int") / 10
      ; Get styles
   	Font.Style := ""
   	If NumGet(LF, 16, "Int") >= 700
   	   Font.Style .= "B"
   	If NumGet(LF, 20, "UChar")
         Font.Style .= "I"
   	If NumGet(LF, 21, "UChar")
         Font.Style .= "U"
   	If NumGet(LF, 22, "UChar")
         Font.Style .= "S"
      OffSet := A_PtrSize * (A_PtrSize = 8 ? 11 : 12)
      FontType := NumGet(CF, Offset, "UShort")
      If (FontType & 0x0100) && !InStr(Font.Style, "B") ; BOLD_FONTTYPE
         Font.Style .= "B"
      If (FontType & 0x0200) && !InStr(Font.Style, "I") ; ITALIC_FONTTYPE
         Font.Style .= "I"
      If (Font.Style = "")
         Font.Style := "N"
      ; Get character set
      Font.CharSet := NumGet(LF, 23, "UChar")
      ; We don't use the limited colors of the font dialog
      ; Return selected values
      Return RE.SetFont(Font)
   }


;;;;;;;;;;;;;;;;;;;;;;;;

/* ENUMS, etc.
ScrollBars Enum
Both				3	Display both a horizontal and a vertical scroll bar when needed.
ForcedBoth			19	Always display both a horizontal and a vertical scroll bar.
ForcedHorizontal	17	Always display a horizontal scroll bar.
ForcedVertical		18	Always display a vertical scroll bar.
Horizontal			1	Display a horizontal scroll bar only when text is longer than the width of the control.
None	0			No scroll bars are displayed.
Vertical			2	Display a vertical scroll bar only when text is longer than the height of the control.

*/

#Include %A_ScriptDir%\RichEdit OleCallback-Example_RTFtoClipCallback3.ahk
#Include %A_ScriptDir%\..\RichEdit OleCallback.ahk
#Include %A_ScriptDir%\..\..\lib-a_to_h\Gdip_All.ahk
