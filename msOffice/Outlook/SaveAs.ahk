; This script saves the active mail item to a specific folder.
; The two hotkeys are the same except they use different folders.

#IfWinActive ahk_exe OUTLOOK.EXE
#1::  ; Win+1 hotkey  -  Save As C:\FolderA
    OutLookSaveAs2("C:\FolderA")  ; Call the OutLookSaveAs2 function
return

#2::  ; Win+2 hotkey  -  Save As C:\FolderB
    OutLookSaveAs2("C:\FolderB")  ; Call the OutLookSaveAs2 function
return

; Saves the selected Mail Item as:
;   <FolderPath>\<Subject>(n).msg
; 'n' is a number that is appended if the file already exists.
OutLookSaveAs2(FolderPath)
{
    ; Constants
    static olExplorer := 34
    static olInspector := 35
    static olMail := 43
    static olMSG := 3
    
    olApp := ComObjCreate("Outlook.Application")  ; Gets or creates an instance of Outlook.
    objWindow := olApp.ActiveWindow  ; Get the active window so we can determine if an Explorer or Inspector window is active.
    if (objWindow.Class = olExplorer)  ; 'Explorer' -- The main Outlook window.
    {
        MySelection := objWindow.Selection
        if (MySelection.Count > 0)
            objMailItem := MySelection.Item(1)  ; Gets only the first item if multiple items are selected.
    }
    else if (objWindow.Class = olInspector)  ; 'Inspector' -- The email is open in its own window.
        objMailItem := objWindow.CurrentItem
    if (objMailItem.Class != olMail)  ; If objMailItem is not an email. 
        return
    FileName := objMailItem.Subject  ; Gets the subject from the mail item
    FileName := RemoveIllegalChars(FileName)  ; Remove characters that are not allowed in file names
    FilePath := FindFreeName(FolderPath, FileName, "msg")  ; Find a file that doesn't already exist
    objMailItem.SaveAs(FilePath, olMSG)  ; Save the message.
}

; Find an unused file name.
FindFreeName(FileDir, FileName, FileExt)
{
    FilePath := FileDir "\" FileName "." FileExt
    if FileExist(FilePath)  ; If the file exists, loop until an unused name is found.
    {
        Loop,
        {
            FilePath := FileDir "\" FileName "(" (A_Index + 1) ")." FileExt
            if !FileExist(FilePath)
                break
        }
    }
    return, FilePath
}

; Removes characters that are not allowed in file names (\ / : * ? " < > |)
RemoveIllegalChars(FileName)
{
    for i, Char in ["\", "/", ":", "*", "?", """", "<", ">", "|"]
        FileName := StrReplace(FileName, Char)
    return FileName
}
