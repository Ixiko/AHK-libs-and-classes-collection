wordLink(){
	InputBox, URL, wordLink.ahk, URL?
	InputBox, text, wordLink.ahk, Text to display?
	oWord := ComObjActive("Word.Application") 
	oWord.ActiveDocument.Hyperlinks.Add(oWord.Selection.Range
		, URL
		,"",""
		, text) 
	}
