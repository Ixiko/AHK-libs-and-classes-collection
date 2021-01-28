ClipSave(mode = 1)
{
    global
    if (mode = 1)
        clipboard_backup := clipboard
    else if (mode = 2)
    	clipboard_backup := ClipboardAll
}

Copy()
{
	global
	clipboard =
	Send ^c
	ClipWait, 4
}

ClipRestore()
{
    global
    clipboard := clipboard_backup
}

ClipClear()
{
    global
    clipboard = ;nothing
}

IsTextSelected()
{

    ; BlockInput, on 
    clipSave() 
    clipClear()
    Send, ^c 
    ClipWait, 2 
    if StrLen(clipboard) > 0
    { 
        msgbox % clipboard "`n" strlen(clipboard)
        return 1
    }
    else
        return 0
    clipRestore()
}