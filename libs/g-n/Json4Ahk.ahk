; ----------------------------------------------------------------------------------------------------------------------
; Name .........: Json4Ahk library
; Description ..: Provide 2 simple functions to deal with JSON.
; AHK Version ..: AHK_L 1.1.13.01 x32 Unicode (ScriptControl COM object is not x64 compatible)
; Author .......: Wicked (http://www.autohotkey.com/board/topic/95262-obj-json-obj/#entry600438)
; Lib. Author ..: Cyruz  (http://ciroprincipe.info)
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Jan. 17, 2014 - v0.1 - First version.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Json4Ahk_Encode
; Description ..: Encode an AHK object into a JSON string.
; Parameters ...: objAhk - AutoHotkey object to encode.
; Return .......: JSON string describing the object.
; ----------------------------------------------------------------------------------------------------------------------
Json4Ahk_Encode(objAhk) { 
	For x, y in objAhk
		s .= ((a := (objAhk.SetCapacity(0) == (objAhk.MaxIndex() - objAhk.MinIndex() + 1))) ? "" : """" x """:")
		  .  (IsObject(y) ? %A_ThisFunc%(y) : """" y """") ","
	Return ((a) ? "[" RTrim(s, ",") "]" : "{" RTrim(s, ",") "}")
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Json4Ahk_Decode
; Description ..: Decode a JSON string into an AHK object.
; Parameters ...: sJson - JSON string describing the object.
; ..............: sKey  - Optional key to retrieve.
; Return .......: AutoHotkey object or requested value.
; ----------------------------------------------------------------------------------------------------------------------
Json4Ahk_Decode(sJson, sKey:="") {
    Static oJson := ComObjCreate("ScriptControl")
	oJson.Language:="JScript"
	Return oJson.Eval("(" sJson ((sKey != "") ? ")." sKey : ")"))
}
