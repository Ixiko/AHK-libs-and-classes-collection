addComment(text){
    oWord := ComObjActive("Word.Application") 
    oWord.ActiveDocument.Comments.Add(Range:=oWord.Selection.Range,  Text:=text)
}