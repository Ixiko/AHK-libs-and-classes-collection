; Hotkey_IfControlActive(ControlDesc, KeyName [, VariantType, VariantTitle, VariantText])

; hkEditInit is called by my main hotkey script.
hkEditInit:
    Hotkey_IfControlActive("Edit", "^BS")
    Hotkey_IfControlActive("Edit", "^Delete")
    Hotkey_IfControlActive("Edit", "+Delete")
    Hotkey_IfControlActive("Edit", "$^c")
    Hotkey_IfControlActive("Edit", "$^x")
    Hotkey_IfControlActive("Edit", "$^v")
return

; NOTE: This even works on Edit controls super-imposed on ListViews!
;   (e.g. when renaming a file in Explorer)

; TODO: Improve word selection (to be more 'selective')

; Delete word left/right.
^BS::       Send % Edit_TextIsSelected("A") ? "{Delete}" : "^+{Left}{Delete}"
^Delete::   Send % Edit_TextIsSelected("A") ? "{Delete}" : "^+{Right}{Delete}"

; Delete line.
+Delete::
    if (Edit_TextIsSelected("A"))
        Send {Delete}
    else
        Edit_DeleteLine(0, "A")
return

; Copy line.
$^c::
    if (Edit_TextIsSelected("A"))
        Send ^c
    else
        Edit_CopyLine()
return

; Cut line.
$^x::
    if (Edit_TextIsSelected("A") or Edit_SelectLine(0, true, "A"))
        Send ^x
return

; Paste line.
$^v::   Send % (SubStr(Clipboard,0)="`n") ? "{Home}^v" : "^v"

Edit_CopyLine()
{
    ControlGetFocus, focus, A
    if (SubStr(focus,1,4)="Edit") {
        ControlGet, line, CurrentLine,, %focus%, A
        ControlGet, line, Line, %line%, %focus%, A
        Clipboard := line "`r`n"
    }
}