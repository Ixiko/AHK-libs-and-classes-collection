wNewLine(){
	oWord := ComObjActive("Word.Application") 
	oWord.Selection.TypeParagraph
}