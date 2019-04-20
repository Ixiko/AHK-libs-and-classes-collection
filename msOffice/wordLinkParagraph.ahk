wordLinkParagraph(URL, text){
	oWord := ComObjActive("Word.Application") 
	oWord.ActiveDocument.Hyperlinks.Add(oWord.Selection.Range
		, URL
		,"",""
		, text) 
	}

