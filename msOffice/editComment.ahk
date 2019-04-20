eComment(){
    oWord := ComObjActive("Word.Application")
    oWord.ActiveDocument.Comments(oWord.ActiveDocument.Comments.Count).Edit
}