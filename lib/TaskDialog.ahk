; ======================================================================================================================
; TaskDialog -> msdn.microsoft.com/en-us/library/bb760540&#40;v=vs.85&#41;.aspx
; Main:     String to be used for the main instruction &#40;mandatory&#41;.
; Extra:    String used for additional text that appears below the main instruction &#40;optional&#41;.
;           Default: 0 - no additional text.
; Title:    String to be used for the task dialog title &#40;optional&#41;.
;           Default: "" - A_ScriptName.
; Buttons:  Specifies the push buttons displayed in the dialog box &#40;optional&#41;.
;           This parameter may be a combination of the integer values defined in TDBTNS or a list of string keys
;           separated by pipe &#40;|&#41;, space, comma, or LF &#40;`n&#41;.
;           list of the string keys.
;           Default: 0 - OK button
; Icon:     Specifies the icon to display in the task dialog &#40;optional&#41;.
;           This parameter can be one of the keys defined in TDICON or a HICON handle to a 32*32 sized icon.
;           Default: 0 - no icon
; Width:    Specifies the width of the task dialog's client area, in pixels.
;           If you pass -1 the width of the task dialog is determined by the width of its content &#40;Extra&#41; area.
;           Default: 0 - the task dialog manager will calculate the ideal width.
; Parent:   HWND of the owner window of the task dialog to be created&#40;optional&#41;.
;           If a valid window handle is specified, the task dialog will become modal.
;           Pass -1 to set the task dialog 'AlwaysOnTop'.
;           Default: 0 - no owner window
; Timeout:  Timeout in seconds, which can contain a decimal point.
;           Due to the use of the TDN_TIMER notification the precision will be about 200 ms.
;           Default: 0 - no timeout
; Returns:  An integer value identifying the button pressed by the user:
;           -1 = Timeout, 1 = OK, 2 = CANCEL, 4 = RETRY, 6 = YES, 7 = NO, 8 = CLOSE
;           If the function fails, ErrorLevel will be set and the return value will be 0.
; Remarks:  Depending on the settings of TaskDialogUseMsgBoxOnXP&#40;&#41; the function can display a MsgBox instead of
;           the task dialog on Win XP. In that case you should only use icons and in particular button combinations
;           also supported by the MsgBox command:
;              Icon:    1/"WARN", 2/"ERROR", 3/"INFO", "QUESTION"
;              Buttons: 1/"OK", 9/"OK|CANCEL", 6/"YES|NO", 14/"YES|NO|CANCEL", 24/"RETRY|CANCEL"
;           Other icons won't be shown, other button combinations won't show all specified buttons.
; Version:  2014-09-26
; ======================================================================================================================
TaskDialog&#40;Main, Extra := "", Title := "", Buttons := 0, Icon := 0, Width := 0, Parent := 0, TimeOut := 0&#41; {
   Static TDCB      := RegisterCallback&#40;"TaskDialogCallback", "Fast"&#41;
        , TDCSize   := &#40;4 * 8&#41; + &#40;A_PtrSize * 16&#41;
        , TDBTNS    := {OK: 1, YES: 2, NO: 4, CANCEL: 8, RETRY: 16, CLOSE: 32}
        , TDF       := {HICON_MAIN: 0x0002, ALLOW_CANCEL: 0x0008, CALLBACK_TIMER: 0x0800, SIZE_TO_CONTENT: 0x01000000}
        , TDICON    := {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9
                      , WARN: 1, ERROR: 2, INFO: 3, SHIELD: 4, BLUE: 5, YELLOW: 6, RED: 7, GREEN: 8, GRAY: 9
                      , QUESTION: 0}
        , HQUESTION := DllCall&#40;"User32.dll\LoadIcon", "Ptr", 0, "Ptr", 0x7F02, "UPtr"&#41;
        , DBUX      := DllCall&#40;"User32.dll\GetDialogBaseUnits", "UInt"&#41; & 0xFFFF
        , OffParent := 4
        , OffFlags  := OffParent + &#40;A_PtrSize * 2&#41;
        , OffBtns   := OffFlags + 4
        , OffTitle  := OffBtns + 4
        , OffIcon   := OffTitle + A_PtrSize
        , OffMain   := OffIcon + A_PtrSize
        , OffExtra  := OffMain + A_PtrSize
        , OffCB     := &#40;4 * 7&#41; + &#40;A_PtrSize * 14&#41;
        , OffCBData := OffCB + A_PtrSize
        , OffWidth  := OffCBData + A_PtrSize
   ; -------------------------------------------------------------------------------------------------------------------
   If &#40;&#40;DllCall&#40;"Kernel32.dll\GetVersion", "UInt"&#41; & 0xFF&#41; < 6&#41; {
      If TaskDialogUseMsgBoxOnXP&#40;&#41;
         Return TaskDialogMsgBox&#40;Main, Extra, Title, Buttons, Icon, Parent, Timeout&#41;
      Else {
         MsgBox, 16, %A_ThisFunc%, You need at least Win Vista / Server 2008 to use %A_ThisFunc%&#40;&#41;.
         ErrorLevel := "You need at least Win Vista / Server 2008 to use " . A_ThisFunc . "&#40;&#41;."
         Return 0
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Flags := Width = 0 ? TDF.SIZE_TO_CONTENT : 0
   If &#40;Title = ""&#41;
      Title := A_ScriptName
   BTNS := 0
   If Buttons Is Integer
      BTNS := Buttons & 0x3F
   Else
      For Each, Btn In StrSplit&#40;Buttons, ["|", " ", ",", "`n"]&#41;
         BTNS |= &#40;B := TDBTNS[Btn]&#41; ? B : 0
   ICO := &#40;I := TDICON[Icon]&#41; ? 0x10000 - I : 0
   If Icon Is Integer
      If &#40;&#40;Icon & 0xFFFF&#41; <> Icon&#41; ; caller presumably passed HICON
         ICO := Icon
   If &#40;Icon = "Question"&#41;
      ICO := HQUESTION
   If &#40;ICO > 0xFFFF&#41;
      Flags |= TDF.HICON_MAIN
   AOT := Parent < 0 ? !&#40;Parent := 0&#41; : False ; AlwaysOnTop
   ; -------------------------------------------------------------------------------------------------------------------
   PTitle := A_IsUnicode ? &Title : TaskDialogToUnicode&#40;Title, WTitle&#41;
   PMain  := A_IsUnicode ? &Main : TaskDialogToUnicode&#40;Main, WMain&#41;
   PExtra := Extra = "" ? 0 : A_IsUnicode ? &Extra : TaskDialogToUnicode&#40;Extra, WExtra&#41;
   VarSetCapacity&#40;TDC, TDCSize, 0&#41; ; TASKDIALOGCONFIG structure
   NumPut&#40;TDCSize, TDC, "UInt"&#41;
   NumPut&#40;Parent, TDC, OffParent, "Ptr"&#41;
   NumPut&#40;BTNS, TDC, OffBtns, "Int"&#41;
   NumPut&#40;PTitle, TDC, OffTitle, "Ptr"&#41;
   NumPut&#40;ICO, TDC, OffIcon, "Ptr"&#41;
   NumPut&#40;PMain, TDC, OffMain, "Ptr"&#41;
   NumPut&#40;PExtra, TDC, OffExtra, "Ptr"&#41;
   If &#40;AOT&#41; || &#40;TimeOut > 0&#41; {
      If &#40;TimeOut > 0&#41; {
         Flags |= TDF.CALLBACK_TIMER
         TimeOut := Round&#40;Timeout * 1000&#41;
      }
      TD := {AOT: AOT, Timeout: Timeout}
      NumPut&#40;TDCB, TDC, OffCB, "Ptr"&#41;
      NumPut&#40;&TD, TDC, OffCBData, "Ptr"&#41;
   }
   NumPut&#40;Flags, TDC, OffFlags, "UInt"&#41;
   If &#40;Width > 0&#41;
      NumPut&#40;Width * 4 / DBUX, TDC, OffWidth, "UInt"&#41;
   If !&#40;RV := DllCall&#40;"Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC, "IntP", Result, "Ptr", 0, "Ptr", 0, "UInt"&#41;&#41;
      Return TD.TimedOut ? -1 : Result
   ErrorLevel := "The call of TaskDialogIndirect&#40;&#41; failed!`nReturn value: " . RV . "`nLast error: " . A_LastError
   Return 0
}
; ======================================================================================================================
; Call this function once passing 1/True if you want a MsgBox to be displayed instead of the task dialog on Win XP.
; ======================================================================================================================
TaskDialogUseMsgBoxOnXP&#40;UseIt := ""&#41; {
   Static UseMsgBox := False
   If &#40;UseIt <> ""&#41;
      UseMsgBox := !!UseIt
   Return UseMsgBox
}
; ======================================================================================================================
; Internally used functions
; ======================================================================================================================
TaskDialogMsgBox&#40;Main, Extra, Title := "", Buttons := 0, Icon := 0, Parent := 0, TimeOut := 0&#41; {
   Static MBICON := {1: 0x30, 2: 0x10, 3: 0x40, WARN: 0x30, ERROR: 0x10, INFO: 0x40, QUESTION: 0x20}
        , TDBTNS := {OK: 1, YES: 2, NO: 4, CANCEL: 8, RETRY: 16}
   BTNS := 0
   If Buttons Is Integer
      BTNS := Buttons & 0x1F
   Else
      For Each, Btn In StrSplit&#40;Buttons, ["|", " ", ",", "`n"]&#41;
         BTNS |= &#40;B := TDBTNS[Btn]&#41; ? B : 0
   Options := 0
   Options |= &#40;I := MBICON[Icon]&#41; ? I : 0
   Options |= Parent = -1 ? 262144 : Parent > 0 ? 8192 : 0
   If &#40;&#40;BTNS & 14&#41; = 14&#41;
      Options |= 0x03 ; Yes/No/Cancel
   Else If &#40;&#40;BTNS & 6&#41; = 6&#41;
      Options |= 0x04 ; Yes/No
   Else If &#40;&#40;BTNS & 24&#41; = 24&#41;
      Options |= 0x05 ; Retry/Cancel
   Else If &#40;&#40;BTNS & 9&#41; = 9&#41;
      Options |= 0x01 ; OK/Cancel
   Main .= Extra <> "" ? "`n`n" . Extra : ""
   MsgBox, % Options, %Title%, %Main%, %TimeOut%
   IfMsgBox, OK
      Return 1
   IfMsgBox, Cancel
      Return 2
   IfMsgBox, Retry
      Return 4
   IfMsgBox, Yes
      Return 6
   IfMsgBox, No
      Return 7
   IfMsgBox, TimeOut
      Return -1
   Return 0
}
; ======================================================================================================================
TaskDialogToUnicode&#40;String, ByRef Var&#41; {
   VarSetCapacity&#40;Var, StrPut&#40;String, "UTF-16"&#41; * 2, 0&#41;
   StrPut&#40;String, &Var, "UTF-16"&#41;
   Return &Var
}
; ======================================================================================================================
TaskDialogCallback&#40;H, N, W, L, D&#41; {
   Static TDM_CLICK_BUTTON := 0x0466
        , TDN_CREATED := 0
        , TDN_TIMER   := 4
   TD := Object&#40;D&#41;
   If &#40;N = TDN_TIMER&#41; && &#40;W > TD.Timeout&#41; {
      TD.TimedOut := True
      PostMessage, %TDM_CLICK_BUTTON%, 2, 0, , ahk_id %H% ; IDCANCEL = 2
   }
   Else If &#40;N = TDN_CREATED&#41; && TD.AOT {
      DHW := A_DetectHiddenWindows
      DetectHiddenWindows, On
      WinSet, AlwaysOnTop, On, ahk_id %H%
      DetectHiddenWindows, %DHW%
   }
   Return 0
}