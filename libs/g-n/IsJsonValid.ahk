; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=81247
; Author:
; Date:
; for:     	AHK_L

/*

	json = {"key":"value"}
	MsgBox, % IsJsonValid(json)
	json = {"key":"value}
	MsgBox, % IsJsonValid(json)

*/


isJsonValid(string) {
	static doc := ComObjCreate("htmlfile")
		, __ := doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
		, parse := ObjBindMethod(doc.parentWindow.JSON, "parse")
   try %parse%(string)
   catch
      return false
   return true
}
return