;**************************
;HTML2RTF Converter for AutoHotKey
;Made by DigiDon from Hanleyk1's code
;**************************

sRTF_To_HTML(ByRef sRTF) {
	global wc
    sReturnString := ""
    sConvertedString := ""

	try {
        ; 'Instantiate the Word application,
        ; â€˜set visible to false and create a document
        MyWord:=ComObjActive("Word.Application")
        MyWord.Visible := False
		NotesDoc := MyWord.Documents.Add()
        wc.SetRTF(sRTF)
        MyWord.Selection.Paste()
        MyWord.Selection.WholeStory()
        MyWord.Selection.Copy()
        sConvertedString := wc.GetHTML()
        sReturnString := sConvertedString

	If (MyWord=!"")
		{
            MyWord.Quit(0)
            MyWord := ""
		}
    }
	catch e {
	If (MyWord=!"")
		{
            MyWord.Quit(0)
            MyWord := ""
		}
	MsgBox % "Error converting Rich Text to HTML"
	}
	Return sReturnString
}

sHTML_To_RTF(ByRef sHTML) {
	global wc

    sReturnString := ""
    sConvertedString := ""

	try {
        ; 'Instantiate the Word application,
        ; â€˜set visible to false and create a document
        MyWord:=ComObjActive("Word.Application")
        MyWord.Visible := False
		NotesDoc := MyWord.Documents.Add()
        wc.SetHTML(sHTML)
        MyWord.Selection.Paste()
        MyWord.Selection.WholeStory()
        MyWord.Selection.Copy()
        sConvertedString := wc.GetRTF()
        sReturnString := sConvertedString

	If (MyWord=!"")
		{
            MyWord.Quit(0)
            MyWord := ""
		}
    }
	catch e {
	If (MyWord=!"")
		{
            MyWord.Quit(0)
            MyWord := ""
		}
	MsgBox % "Error converting HTML to Rich Text"
	}
	Return sReturnString
}