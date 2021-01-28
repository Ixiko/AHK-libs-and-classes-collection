wText(text){
    oWord := ComObjActive("Word.Application") 
    oWord.Selection.TypeText(text)
    }