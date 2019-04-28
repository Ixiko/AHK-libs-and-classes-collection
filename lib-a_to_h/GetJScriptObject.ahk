
/*
JS := GetJScripObject()
code := "function s(a,b){return a+b}; var a1 = 1, a2 = 2; s(a1, a2)"
MsgBox, % JS.(code)

JS := CreateScriptObj()
MsgBox, % JS.(code)
*/

GetJScripObject()  {   ; Here we create temp file to get a custom COM server using Windows Script Components (WSC) technology.
   VarSetCapacity(tmpFile, ((MAX_PATH := 260) - 14) << !!A_IsUnicode, 0)
   DllCall("GetTempFileName", Str, A_Temp, Str, "AHK", UInt, 0, Str, tmpFile)
   
   FileAppend,
   (
   <component>
   <public><method name='eval'/></public>
   <script language='JScript'></script>
   </component>
   ), % tmpFile
   
   JS := ObjBindMethod( ComObjGet("script:" . tmpFile), "eval" ) ; ComObjGet("script:" . tmpFile) is the way to invoke com-object without registration in the system
   FileDelete, % tmpFile
   Return JS
}

CreateScriptObj() {
   static doc := ComObjCreate("htmlfile")
   doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")
   return ObjBindMethod(doc.parentWindow, "eval")
}