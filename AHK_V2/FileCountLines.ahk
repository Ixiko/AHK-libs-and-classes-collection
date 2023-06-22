; ===========================================================================================================================================================================
; Count the number of lines in a text file.
; Tested with AutoHotkey v2.0-a132
; ===========================================================================================================================================================================

FileCountLines(FileName)
{
	try
		File := FileOpen(FileName, "r-d")
	catch as Err
	{
		MsgBox("Can't open '" FileName "`n`n" Type(Err) ": " Err.Message)
		return
	}

	CountLines := 0
	while !(File.AtEOF)
	{
		File.ReadLine()
		CountLines++
	}
	File.Close()

	return CountLines
}

; ===========================================================================================================================================================================

MsgBox(FileCountLines("C:\Windows\Logs\CBS\CBS.log"))
