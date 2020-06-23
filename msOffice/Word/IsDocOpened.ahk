; Link:   	https://gist.github.com/tmplinshi/652d241abc86914c2bd817590a771621
; Author:	
; Date:   	
; for:     	


; 判断 word 文件是否已经打开
IsDocOpened(FileName) {
	; 确保 FileName 是完整路径
	if !InStr(FileName, ":")
		FileName := A_ScriptDir "\" FileName

	try {
		oWord := ComObjActive("Word.Application")
		oWord.Documents(FileName)
		return true
	}
	return false
}