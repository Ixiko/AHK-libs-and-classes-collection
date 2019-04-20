wLink(text = 0, URL = 0){
	if text or URL <> 0
	{
		oWord := ComObjActive("Word.Application") 
	    oWord.ActiveDocument.Hyperlinks.Add(oWord.Selection.Range
        , URL
        ,"",""
        , text) 
	}
	Else
	{
    	InputBox, URL, wordLink.ahk, URL?
    	InputBox, text, wordLink.ahk, Text to display?
    	oWord := ComObjActive("Word.Application") 
    	oWord.ActiveDocument.Hyperlinks.Add(oWord.Selection.Range
    	    , URL
    	    ,"",""
    	    , text) 
	}
}