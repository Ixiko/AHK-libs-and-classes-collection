FilePath := A_ScriptDir "\New Microsoft Word Document.docx"  ; Path to a Word document.
if FileOpen(FilePath, "rw") ; FileOpen fails if the file is already open.
    FileStatus := "not open"
else
    FileStatus := "already open"
MsgBox, 64, File Status, % "The file is " FileStatus ".`n`n(" FilePath ")"
