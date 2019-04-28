/*
#Persistent

CreateGui()
Gui, thisGuia: Show
Return

thisGuiaGuiClose:
ExitApp
Return 

thisGuiaGuiEscape:
ExitApp
Return 

CreateGui() {

    thisFntSize := 25
    bgrColor := "000022"
    txtColor := "ffeedd"
    Gui, thisGuia: -DPIScale +Owner +hwndhGui
    Gui, thisGuia: Margin, % thisFntSize*2, % thisFntSize*2
    Gui, thisGuia: Color, c%bgrColor%
    Gui, thisGuia: Font, s%thisFntSize% Q5, Arial
    Gui, thisGuia: Add, Text, c%txtColor% , This is a demo. Enjoy.
    WinSet, AlwaysOnTop, On, ahk_id %hGui%
    SetAcrylicGlassEffect(bgrColor, 125, hGui)
}
*/

ConvertToBGRfromRGB(RGB) { ; Get numeric BGR value from numeric RGB value or HTML color name
  ; HEX values
  BGR := SubStr(RGB, -1, 2) SubStr(RGB, 1, 4) 
  Return BGR 
}

SetAcrylicGlassEffect(thisColor, thisAlpha, hWindow) {
  ; based on https://github.com/jNizM/AHK_TaskBar_SetAttr/blob/master/scr/TaskBar_SetAttr.ahk
  ; by jNizM
    If (SafeModeExec=1 || OSDacrylicEffect=0 || thisAlpha>250)
       Return
    initialAlpha := thisAlpha
    If (thisAlpha<16)
       thisAlpha := 16
    thisColor := ConvertToBGRfromRGB(thisColor)
    thisAlpha := Format("{1:#x}", thisAlpha)
    gradient_color := thisAlpha . thisColor

    Static init, accent_state := 4, ver := DllCall("GetVersion") & 0xff < 10
    Static pad := A_PtrSize = 8 ? 4 : 0, WCA_ACCENT_POLICY := 19
    accent_size := VarSetCapacity(ACCENT_POLICY, 16, 0)
    NumPut(accent_state, ACCENT_POLICY, 0, "int")

    If (RegExMatch(gradient_color, "0x[[:xdigit:]]{8}"))
       NumPut(gradient_color, ACCENT_POLICY, 8, "int")

    VarSetCapacity(WINCOMPATTRDATA, 4 + pad + A_PtrSize + 4 + pad, 0)
    && NumPut(WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0, "int")
    && NumPut(&ACCENT_POLICY, WINCOMPATTRDATA, 4 + pad, "ptr")
    && NumPut(accent_size, WINCOMPATTRDATA, 4 + pad + A_PtrSize, "uint")
    If !(DllCall("user32\SetWindowCompositionAttribute", "ptr", hWindow, "ptr", &WINCOMPATTRDATA))
       Return 0 
    thisOpacity := (initialAlpha<16) ? 60 + initialAlpha*9 : 250
    WinSet, Transparent, %thisOpacity%, ahk_id %hWindow%
    Return 1
}

