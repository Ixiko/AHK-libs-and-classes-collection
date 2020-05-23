#include getError.ahk

/* Print Output for AHK v2
Example:

*/

print := new printClass()
print(msg) {
	global print
	print._println(msg)
}

rprint(msg) {
	global print
	print._print(msg)
}

hprint(msg) {
	global print
	print._printHex(msg)
}

eprint(errorCode) {
	global print
	print._printError(errorCode)
}

;~ gprint := new printClass(forceGUI := true)
;~ gprint(args*) {
	;~ global gprint
	;~ gprint._print(args*)
;~ }


class printClass {	
	__New(forceGUI := false) {
		if !WinExist("SciTE4AutoHotkey") or forceGUI {
			this.SciTE4Autohotkey := 0
			this.output := GuiCreate(,'Output for "' A_ScriptName '"')
			this.output.SetFont(,"Consolas")
			this.outputEditCtrl := this.output.Add("Edit", "r20 w800 ReadOnly -Wrap", "")
			
			this.output.Opt("+Resize")
			
			this.output.OnEvent("Size", () => this._onResize())
			this.output.Show()

			WinWait("ahk_id " this.output.Hwnd)
			
			this.Hwnd := this.output.Hwnd
		} else
			this.SciTE4Autohotkey := 1
		
		this.hModule := DllCall("LoadLibrary", "Str", "msvcrt.dll")
		return this
	}
	
	_onResize() {
		this.outputEditCtrl.move("w" (this.output.ClientPos.w-20) " h" (this.output.ClientPos.h-10), true)
	}
	
	_print(msg) {
		if !this.SciTE4AutoHotkey {
			this.outputEditCtrl.Value := this.outputEditCtrl.Value msg
			PostMessage( 0x115, 7, , "Edit1", 'Output for "' A_ScriptName '"') 
		}
		else
			fileappend(msg, "*")
	}
	
	_println(msg) {
		this._print(msg "`n")
	}
	
	_printError(msg) {
		this._println(getError(msg))
	}
	
	_printHex(msg) {
		if !msg 
			return
		
		static patternPart := "[\s|(|)|\[|\]|:|;|,|{|}|^|\|]" 
		static pattern := "(?<=" patternPart ")([0-9]+)(?=" patternPart ")"
		msg := " " msg " "
		r := 1
		loop {
			r := RegExMatch(msg, pattern, m, r)
			if r {
				hex := m[1] > 10 ? this._convert(m[1], 10, 16) : m[1]
				msg := RegExReplace(msg, pattern, hex, , 1, r)
				r := r + 1
			}
		} until (!r)
		msg := SubStr(msg, 2, -1)
		
		this._println(msg)
	}
	
	_convert(numstr, inputBase, outputBase) {
		u := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
		v := A_IsUnicode ? "_i64tow"    : "_i64toa"
		VarSetCapacity(s, 65, 0)
		value := DllCall("msvcrt.dll\" u, "Str", numstr, "UInt", 0, "UInt", inputBase, "CDECL Int64")
		DllCall("msvcrt.dll\" v, "Int64", value, "Str", numstr, "UInt", outputBase, "CDECL")	
		return "0x" StrUpper(numstr)
	}
	
	__Delete() {
		DllCall("FreeLibrary", "Ptr", this.hModule)
	}
}
