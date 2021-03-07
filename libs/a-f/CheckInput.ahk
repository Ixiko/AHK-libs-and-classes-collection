; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=378371#p378371
; Author:
; Date:
; for:     	AHK_L

/*

#NoEnv
SetBatchLines, -1
Gui, Margin, 100, 50
Gui, Add, Edit, w100 vNeuerTabName hwndHEDT
SubclassControl(HEDT, "CheckInput")
Gui, Show, , Edit Test
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
ExitApp

*/

; ======================================================================================================================
CheckInput(HWND, Msg, wParam, lParam, SubclassID, RefData) {
   Static Err1 := "Die Namen dürfen nicht mit einer Ziffer beginnen!"
        , Err2 := "Die Namen dürfen nur Buchstaben, Ziffern und den Unterstrich enthalten!"
        , Err3 := "Einfügen ist hier nicht erlaubt!"
   Switch Msg {
      Case 0x0102:   ; WM_CHAR -----------------------------------------------------------------------------------------
         If (wParam != 0x08) { ; BACKSPACE
            If (wParam < 0x40) && (wParam > 0x29) {
               DllCall("SendMessage", "Ptr", HWND, "UInt", 0x00B0, "IntP", Start, "Ptr", 0)
               If (Start = 0) {
                  EM_SHOWBALLOONTIP(HWND, "Ungültiges Zeichen!", Err1, 3)
                  Return 0
               }
            }
            If !RegExMatch(Chr(wParam), "[\wÄÖÜäöüß]") {
               EM_SHOWBALLOONTIP(HWND, "Ungültiges Zeichen!", Err2, 3)
               Return 0
            }
         }
      Case 0x0302:   ; WM_PASTE ----------------------------------------------------------------------------------------
            EM_SHOWBALLOONTIP(HWND, "Unzulässige Aktion!", Err3, 3)
            Return 0
      Case 0x0002:   ; WM_DESTROY --------------------------------------------------------------------------------------
         SubclassControl(HWND, "") ; remove the subclass procedure
   }
   Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", HWND, "UInt", Msg, "Ptr", wParam, "Ptr", lParam)
}
; ======================================================================================================================
; SubclassControl    Installs, updates, or removes the subclass callback for the specified control.
; Parameters:        HCTRL    -  Handle to the control.
;                    FuncName -  Name of the callback function as string.
;                                If you pass an empty string (""), the subclass callback will be removed.
;                    RefData  -  Optional integer value passed to the callback function.
; Return value:      Non-zero if the subclass callback was successfully installed, updated, or removed; otherwise False.
; Remarks:           The callback function must have exactly six parameters, see
;                    SUBCLASSPROC -> msdn.microsoft.com/en-us/library/bb776774(v=vs.85).aspx
; ======================================================================================================================
SubclassControl(HCTRL, FuncName, RefData := 0) {
   Static ControlCB := []
   If ControlCB.HasKey(HCTRL) {
      DllCall("RemoveWindowSubclass", "Ptr", HCTRL, "Ptr", ControlCB[HCTRL], "Ptr", HCTRL)
      DllCall("GlobalFree", "Ptr", ControlCB[HCTRL], "Ptr")
      ControlCB.Remove(HCTRL, "")
      If (FuncName = "")
         Return True
   }
   If !DllCall("IsWindow", "Ptr", HCTRL, "UInt")
   Or !IsFunc(FuncName) || (Func(FuncName).MaxParams <> 6)
   Or !(CB := RegisterCallback(FuncName, , 6))
      Return False
   If !DllCall("SetWindowSubclass", "Ptr", HCTRL, "Ptr", CB, "Ptr", HCTRL, "Ptr", RefData)
      Return (DllCall("GlobalFree", "Ptr", CB, "Ptr") & 0)
   Return (ControlCB[HCTRL] := CB)
}
; ======================================================================================================================
; Displays a balloon tip associated with an edit control.
; Title  -  the title of the balloon tip.
; Text   -  the balloon tip text.
; Icon   -  the icon to associate with the balloon tip, one of the keys defined in Icons.
; ======================================================================================================================
EM_SHOWBALLOONTIP(HWND, Title, Text, Icon := 0) {
   ; EM_SHOWBALLOONTIP = 0x1503 -> http://msdn.microsoft.com/en-us/library/bb761668(v=vs.85).aspx
   Static Icons := {0: 0, 1: 1, 2: 2, 3: 3, NONE: 0, INFO: 1, WARNING: 2, ERROR: 3}
   NumPut(VarSetCapacity(EBT, 4 * A_PtrSize, 0), EBT, 0, "UInt")
   If !(A_IsUnicode) {
      VarSetCapacity(WTitle, StrLen(Title) * 4, 0)
      VarSetCapacity(WText, StrLen(Text) * 4, 0)
      StrPut(Title, &WTitle, "UTF-16")
      StrPut(Text, &WText, "UTF-16")
   }
   If !Icons.HasKey(Icon)
      Icon := 0
   NumPut(A_IsUnicode ? &Title : &WTitle, EBT, A_PtrSize, "Ptr")
   NumPut(A_IsUnicode ? &Text : &WText, EBT, A_PtrSize * 2, "Ptr")
   NumPut(Icons[Icon], EBT, A_PtrSize * 3, "UInt")
   Return DllCall("SendMessage", "Ptr", HWND, "UInt", 0x1503, "Ptr", 0, "Ptr", &EBT, "Ptr")
}