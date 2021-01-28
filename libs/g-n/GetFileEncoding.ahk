/*
Returns the encoding of a file
Author	: R3gX
Link	: http://www.autohotkey.com/forum/viewtopic.php?t=71966
*/

GetFileEncoding(File){
	Attribs := FileExist(File)
	If (!Attribs || InStr(Attribs, "D"))
	{	; If there are no attributes or the file has a folder attribute
		MsgBox, 262160, File encoding :, The file is not valid!`n%File%, 2
		Return
	}
	oFile := FileOpen(File, "r")	; Opens the file to be read
	oFile.Close()
	Return, oFile.Encoding
}