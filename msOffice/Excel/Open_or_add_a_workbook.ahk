; Usage:
; F11 hotkey        - Open a workbook in the active instance of Excel.
; F12 hotkey        - Open a workbook in a new instance of Excel.
; Win+F11 hotkey    - Create a new blank workbook in the active instance of Excel.
; Win+F12 hotkey    - Create a new blank workbook in a new instance of Excel.
; Ctrl+F11 hotkey   - Create a new workbook in the active instance of Excel using 'FilePath' as the workbook template.
; Ctrl+F12 hotkey   - Create a new workbook in a new instance of Excel using 'FilePath' as the workbook template.

; The workbook to use for this example.
FilePath := A_ScriptDir "\Test.xlsx"
return  ; End of Auto-execute section.

; Excel hotkeys
#IfWinActive, ahk_class XLMAIN

; F11 hotkey - Open a workbook in the active instance of Excel.
F11::
    xlApp := Excel_Get()                        ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    xlApp.Workbooks.Open( FilePath )            ; Open the workbook specified by 'FilePath'.
    xlApp := ""                                 ; Done using this COM object so clear the variable.
return

; F12 hotkey - Open a workbook in a new instance of Excel.
F12::
    xlApp := ComObjCreate("Excel.Application")  ; Create an instance of Excel.
    xlApp.Visible := true                       ; Make Excel visible.
    xlApp.Workbooks.Open( FilePath )            ; Open the workbook specified by 'FilePath'.
    xlApp := ""                                 ; Done using this COM object so clear the variable.
return

; Win+F11 hotkey - Create a new blank workbook in the active instance of Excel.
#F11::
    xlApp := Excel_Get()                        ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    xlApp.Workbooks.Add()                       ; Create a new blank workbook.
    xlApp := ""                                 ; Done using this COM object so clear the variable.
return

; Win+F12 hotkey - Create a new blank workbook in a new instance of Excel.
#F12::
    xlApp := ComObjCreate("Excel.Application")  ; Create an instance of Excel.
    xlApp.Visible := true                       ; Make Excel visible.
    xlApp.Workbooks.Add()                       ; Create a new blank workbook.
    xlApp := ""                                 ; Done using this COM object so clear the variable.
return

; Ctrl+F11 hotkey - Create a new workbook in the active instance of Excel using 'FilePath' as the workbook template.
^F11::
    xlApp := Excel_Get()                        ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    xlApp.Workbooks.Add( FilePath )             ; Create a new workbook using 'FilePath' as the template.
    xlApp := ""                                 ; Done using this COM object so clear the variable.
return

; Ctrl+F12 hotkey - Create a new workbook in a new instance of Excel using 'FilePath' as the workbook template.
^F12::
    xlApp := ComObjCreate("Excel.Application")  ; Create an instance of Excel.
    xlApp.Visible := true                       ; Make Excel visible.
    xlApp.Workbooks.Add( FilePath )             ; Create a new workbook using 'FilePath' as the template.
    xlApp := ""                                 ; Done using this COM object so clear the variable.
return

; Turn off context-sensitive hotkeys.
#If

; Press {Escape} to exit this script.
Esc::ExitApp

; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
; <Paste the Excel_Get function definition here>
