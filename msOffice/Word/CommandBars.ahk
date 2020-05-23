; This script shows some actions using CommandBars and CommandBarControl objects. Use the F7 hotkey to display the
; available controls. Then use FindControl, as shown with the F9 and F10 hotkeys below, to execute a control action. The
; use of CommandBars in some Microsoft Office applications has been superseded by the ribbon, but CommandBars can be
; used nevertheless (tested with Office 2010).

; Word context-sensitive hotkeys
#IfWinActive, ahk_class OpusApp

; Show all CommandBarControl items. 
F7::
    TrayTip, Getting Controls, Getting all commandbar controls from Word. This may take a brief moment.
    
    ; Find all command bar controls. Gather their type, ID numbers, and caption.
    Controls := []
    FoundControls := ComObjActive("Word.Application").CommandBars.FindControls()
    for CommandBarControl in FoundControls
    {
        ; Store each item using the Id as the key. This array will ensure duplicate items are removed; only one item is
        ; stored per ID. It also allows the items to be listed in order.
        try Controls[CommandBarControl.Id] := { Type:       CommandBarControl.Type
                                              , Caption:    CommandBarControl.Caption }
    }
    
    ; Make and format the list of items.
    Spaces := "                "  ; 16 spaces
    List := "ID          Type    Caption`r`n"
         .  "------------------------------------`r`n"
    for ID, Control in Controls
    {
        List .= SubStr(ID Spaces, 1, 11) A_Space            ; ID - Max 12 characters wide (11 + 1 space)
             .  SubStr(Control.Type Spaces, 1, 7) A_Space   ; Type - Max 8 characters wide (7 + 1 space)
             .  Control.Caption "`r`n"                      ; Caption
    }
    
    ; Use Notepad to display the text.
    Run, Notepad,,, NotepadPID
    WinWait, % "ahk_pid " NotepadPID  ; Wait for the Notepad window.
    ControlSetText, Edit1, % List  ; Set control text. Use the "Last Found" window.
    TrayTip, Getting Controls, Done getting controls.
return

; Minimize/un-minimize the ribbon. (Same as pressing Ctrl+F1)
F8::ComObjActive("Word.Application").CommandBars.ExecuteMso("MinimizeRibbon")

; Align Left -- Type (1) and ID (120) were found with the F7 hotkey above.
F9::ComObjActive("Word.Application").CommandBars.FindControl(1, 120).Execute

; Align Right -- Type (1) and ID (121) were found with the F7 hotkey above.
F10::ComObjActive("Word.Application").CommandBars.FindControl(1, 121).Execute

#If  ; Turn off context-sensitive hotkeys.

Esc::ExitApp  ; Press Escape to exit this script.

; References:
; https://access-programmers.co.uk/forums/showthread.php?t=244692
; CommandBars Members (Office) - https://msdn.microsoft.com/EN-US/library/office/ff864138.aspx
; CommandBarControl Members (Office) - https://msdn.microsoft.com/EN-US/library/office/ff860607.aspx
; CommandBars.ExecuteMso Method (Office) - https://msdn.microsoft.com/en-us/library/office/ff862419.aspx
; CommandBars.FindControl Method (Office) - https://msdn.microsoft.com/en-us/library/office/ff860267.aspx
