/*
str=
(
History: r/o ruptured appendicitis. 

CT of the abdomen and pelvis without/with contrast enhancement shows:
- Minor or non-specific lung parenchymal change. 
- Long segmental wall thickening/edema of the colon from cecum to (less severe) descending colon. Inflammatory or infectious process is considered first. Suggest endoscope correlation. 
- the appendix is not well-identified. 
- No definite focal lesions in the liver, spleen, pancreas, both adrenal glands and kidneys. 
)
arr1:=[],arr2:=[]
rxms(str,"(\.\s*)|(-+\s+)|(\n?\d+\W\s+)","sarr1[] marr2[]")
str:=""
for k,v in arr1
	str.=substr(v,1,1) substr(v,2) arr2[k]
msgbox % str
;~ msgbox % arr.maxindex()
;~ loop,parse,str,% rxms(str,"(\.\s*)|(-+\s+)\","s d")
	;~ msgbox % a_loopfield
*/
RXMS(ByRef _String, _Needle, _Options="") ; http://www.autohotkey.com/forum/viewtopic.php?p=470488, updated 23-10-2012
{
	Local _ , _1, _2, _3, _4, _5 := 1, _FoundPos := 0, _Matches := 0, _Splits := 0, _Output, _OutputPos, _OutputLen, _Error, _Delimiter, _PrevErrorLevel := ErrorLevel, _Literal := """", _Commands := "m|p|s|r|d|t|c|e|u|i|x", _Documentation := "http://www.autohotkey.com/forum/viewtopic.php?p=470488"
	;---------------------------------OPTIONS:-----------------------------------------------------------
	; DEFAULT                 USER DEFAULT             NAME                    ABOUT
	, _m := "",               _m_user := 0             ;m = Matches            Name of global pseudo-array in which to store matching patterns. Append [] to indicate an AutoHotkey_L array; otherwise, optionally include * as the location for the item number. Indicate multiple arrays by separating each with a comma; optionally indicate a particular subpattern for each after a colon
	, _s := "",               _s_user := 0             ;s = Splits             Name of global pseudo-array in which to split the string. Use [] and * as with m option. 0 switches to split mode for r and d without actually creating an array
	, _p := "",               _p_user := 1             ;p = Pattern            Name or number of subpattern to use as a match instead of using the entire needle
	, _r := "",               _r_user := "`n"          ;r = Return             Return a string containing all instances delimited by the string passed to the r option
	, _d := "",               _d_user := "FirstUnused" ;d = Delimiter          Stores all matches or splits as a delimited list in the ByRef _String variable, for a parsing loop or StringSplit
	, _t := "",               _t_user := "\s*"         ;t = Trim               A regular expression to trim from the beginning and end of each split segment
	, _c := "",               _c_user := "ms"          ;c = Consolidate        Blank entries are excluded from pseudoarrays, r and d outputs, and match/split counts. Includes entries that become blank after trimming (t option)
	, _e := "aex",            _e_user := ""            ;e = Error Behavior     Choose what the function will do upon encountering an error. Indicate/omit a, e, p, and/or x to turn on/off alerts (via msgbox), exiting (stops the current thread), pausing the script, or errorlevel setting, respectively
	, _u := "",               _u_user := "Splits"      ;u = Use match/splits   [Only applies with r or d]: Forces these options to use match or split segments. If not indicated, r and d will use whichever has a nonblank pseudoarray option declared, matches if both
	, _i := False,            _i_user := True          ;i = Ignore non-subpat  [Only applies with p]: Omits segments of the match that do not match subpattern p from the split segments as well
	, _x := True,             _x_user := False         ;x = Trim Extremities   [Only applies with t]: Indicates whether the t option will trim from the string extremities, i.e. beginning of the first split and end of last split
	;---------------------------------USER CONFIGURATIONS:-----------------------------------------------
	, _UserConfig_Foo := "bar"
	;----------------------------------------------------------------------------------------------------
	While (_5 := RegExMatch(_Options, "i)(?:^|\s)(?:!(\w+)|(\+|-)?(" _Commands ")(" _Literal "(?:[^" _Literal "]|" _Literal _Literal ")*" _Literal "(?=\s|$)|\S*))", _, _5 + StrLen(_)))
		If (_1 <> "")
			_Options := SubStr(_Options, 1, _5 + StrLen(_)) _UserConfig_%_1% SubStr(_Options, _5 + StrLen(_))
		Else If (_4 <> "") {
			If (InStr(_4, _Literal) = 1) and (_4 <> _Literal) and (SubStr(_4, 0, 1) = _Literal) and (_4 := SubStr(_4, 2, -1))
				StringReplace, _4, _4, %_Literal%%_Literal%, %_Literal%, All
			_%_3% := _4
		} Else
			_%_3% := _2 = "+" ? True : _2 = "-" ? False : _%_3%_user
	If RegExMatch(_p, "\W")
		_Error := "Illegal Subpattern Name [1]: The subpattern (p option) """ _p """ was indicated.`nRegular expression subpattern names may only contain letters, numbers, and underscores."
	Else If (_%_p% := True) and RegExMatch("", _Needle, _)
		_Error := "Null Needle [2]: The following needle was given:`n" _Needle "`nThe needle cannot match a blank string."
	Else If ErrorLevel
		_Error := "Regular Expression Error [3]: The following needle was given:`n" _Needle "`nThis needle caused " (StrLen(ErrorLevel) > 4 ? "the following RegEx compile error:`n" ErrorLevel : "RegEx execution error #" SubStr(ErrorLevel, 2) ".") "`nConsult AutoHotkey or PCRE documentation for more information about this error."
	Else If (_p <> "") and _%_p%
		_Error := "Missing Subpattern [4]: The following needle was given:`n" _Needle "`n""" _p """ was indicated for a subpattern (p option), but the needle does not contain this subpattern."
	Else If RegExMatch(_s, (InStr(A_AhkVersion, "1.1") = 1 ? "^\[|\[(?!\](?::|$))|(?<!\[)\]|" : "") "[^\w#_$?\[\]]")
		_Error := "Unsupported Split Variable Name [5]: """ _s """ was given as the name of the split output variable (s option).`nThis variable name contains inappropriate chraracters. Allowed are letters, numbers, #, @, _, ?, and $."
	Else If (_d <> "")
		If (_r <> "")
			_Error := "Invalid Option Combination [6]: You may not specify both r (return array as a string) and d (return a delimited list)."
		Else If (StrLen(_d) = 1) {
			If InStr(_String, _d)
				_Error := "Problematic Delimiter Assignment [7]: The d option was specified with ASCII character #" Asc(_d) " as a delimiter, but this character exists in the given string.`nIf you want to avoid this error, use the r option instead."
			Else
				_Delimiter := _d
		} Else If (_d <> "CSV")
			Loop
				If !InStr(_String, Chr(A_Index)) {
					_Delimiter := Chr(A_Index)
					Break
				} Else If (A_Index = 255)
					_Error := "No Available Delimiter [8]: The d option failed to find a unique delimiter for the string because the string contains all 255 ASCII characters."
	If _s and !_Error
		If ("[]" = SubStr(_s, -1)) {
			If (InStr(_s, "_") = 1)
				_Error := "Conflicting Split Output Name [9]: The output variable """ _s """ may conflict with a local RXMS() variable. Please use a variable name that doesn't begin with an underscore."
			Else If (InStr(A_AhkVersion, "1.0") = 1)
				_Error := "Split Object Not Supported [10]: The split output variable """ _s """ appears to be in object format. However, the current script is running with AutoHotkey ver. " A_AhkVersion ", which does not support objects. Run the script again with a newer AutoHotkey version."
			Else
				_s := SubStr(_s, 1, -2), _1 := "Object", %_s% := %_1%()
		} Else If !InStr(_s, "*")
			_s .= "*"
	If _m and !_Error {
		If !InStr(_m, ":")
			_m .= ":" _p
		Loop, Parse, _m, `,
			If !_Error
				Loop, Parse, A_LoopField, :
					If (A_Index = 1) {
						If (A_LoopField <> "")
							If (InStr(A_LoopField, "_") = 1)
								_Error := "Conflicting Match Output Name [11]: The output variable """ A_LoopField """ may conflict with a local RXMS() variable. Please use a variable name that doesn't begin with an underscore."
							Else If RegExMatch(_ := A_LoopField, (InStr(A_AhkVersion, "1.1") = 1 ? "^\[|\[(?!\](?::|$))|(?<!\[)\]|" : "") "[^\w#_$?\[\]]")
								_Error := "Unsupported Match Variable Name [12]: The output variable name """ A_LoopField """ contains inappropriate chraracters. Allowed are letters, numbers, #, @, _, ?, and $."
							Else {
								If ("[]" = SubStr(_, -1)) {
									If (InStr(A_AhkVersion, "1.0") = 1)
										_Error := "Match Object Not Supported [13]: The match output variable """ _ """ appears to be in object format. However, the current script is running with AutoHotkey ver. " A_AhkVersion ", which does not support objects. Run the script again with a newer AutoHotkey version."
									Else
										_ := SubStr(_, 1, -2), _1 := "Object", %_% := %_1%()
								} Else If !InStr(_, "*")
									_ .= "*"
								If !InStr(_Output, "," _ ":") and (_ <> _s) {
									_Output .= "," _ ":"
									Continue
								} Else
									_Error := "Duplicate Output Array [14]: The output array """ A_LoopField """ was given twice.`nPlease choose a unique name for each output array."
							}
						Break
					} Else {
						If RegExMatch(A_LoopField, "\W")
							_Error := "Illegal Multi-Match Subpattern Name [15]: The multi-match (after a colon) subpattern """ A_LoopField """ was indicated.`nRegular expression subpattern names may only contain letters, numbers, and underscores."
						Else If (A_LoopField <> "") and (_%A_LoopField% := True) and !RegExMatch("", _Needle, _) and _%A_LoopField%
							_Error := "Missing Multi-Match Subpattern [16]: The following needle was given:`n" _Needle "`n""" A_LoopField """ was indicated as a subpattern for one of the matching output arrays, but the needle does not contain this subpattern."
						Else
							_Output .= A_LoopField
						Break
					}
		StringTrimLeft, _m, _Output, 1
	}
	If !_Error {
		If !RegExMatch(_Needle, "^(?:[ \t]*(?:i|m|s|x|A|D|J|U|X|P|S|C|`n|`r|`a)[ \t]*)+\)", _)
			_Needle := "P)" _Needle
		Else If !InStr(_, "P", True)
			_Needle := "P" _Needle
		_Output := 1, _u := ((_s = "") or (_m <> "") or (SubStr(_u, 1, 1) = "m")) and (SubStr(_u, 1, 1) <> "s") ? 1 : 0, _4 := _s or !(_u & 1) ? 1 : "", _2 := "", _3 := 1
		If (_d <> "") or (_r <> "")
			_u += 2
		If (StrLen(_d) <= 1) or (_d = "CSV")
			_u += 4
		While (_FoundPos := RegExMatch(_String, _Needle, _Output, _FoundPos + _Output)) or _4-- {
			If (_p = "")
				_OutputPos := _FoundPos, _OutputLen := _Output
			If (_4 <> 0) and (_m or (_u & 1)) and (_OutputLen%_p% or !InStr(_c, "m")) {
				If _m or ((_u & 1) and (_u & 4))
					_Matches += 1
				If _m
					Loop, Parse, _m, :`,
						If (A_Index & 1)
							_ := A_LoopField
						Else If InStr(_, "*") {
							StringReplace, _, _, *, %_Matches%, All
							%_% := SubStr(_String, _OutputPos%A_LoopField%, _OutputLen%A_LoopField%)
						} Else
							%_%[_Matches] := SubStr(_String, _OutputPos%A_LoopField%, _OutputLen%A_LoopField%)
				If (_u & 2) and (_u & 1)
					_2 .= (_r <> "") ? _r SubStr(_String, _OutputPos%_p%, _OutputLen%_p%) : (_d <> "CSV") ? _Delimiter SubStr(_String, _OutputPos%_p%, _OutputLen%_p%) : "," CSV(SubStr(_String, _OutputPos%_p%, _OutputLen%_p%))
			}
			If _s or !(_u & 1) {
				_1 := _4 ? SubStr(_String, _3, (_i ? _FoundPos : _OutputPos%_p%) - _3) : SubStr(_String, _3)
				If (_t <> "")
					_1 := RegExReplace(_1, "^" (A_Index > 1 or _x ? _t : "") "([\s\S]*?)" (_4 or _x ? _t : "") "$", "$1") 
				If (_1 <> "") or !InStr(_c, "s") {
					If _s or ((_u & 4) and !(_u & 1))
						_Splits += 1
					If _s
						If InStr(_s, "*") {
							StringReplace, _, _s, *, %_Splits%, All
							%_% := _1
						} Else
							%_s%[_Splits] := _1
					If (_u & 2) and !(_u & 1)
						_2 .= (_r <> "") ? _r _1 : (_d <> "CSV") ? _Delimiter _1 : "," CSV(_1) 
				}
				If (_4 = 0)
					Break
				_3 := _i ? _FoundPos + _Output : _OutputPos%_p% + _OutputLen%_p%
			}
			If !_Output
				If (_FoundPos >= StrLen(_String))
					Break
				Else
					_Output := 1
		}
	}
	If !_Error {
		If _m
			Loop, Parse, _m, :`,
				If (A_Index & 1) and InStr(A_LoopField, "*") {
					StringReplace, _, A_LoopField, *, 0, All
					%_% := _Matches
				}
		If _s and InStr(_s, "*") {
			StringReplace, _s, _s, *, 0, All
			%_s% := _Splits
		}
		If (_d <> "")
			StringTrimLeft, _String, _2, 1
		ErrorLevel := InStr(_e, "e") ? False : _PrevErrorLevel
		Return (_r <> "") ? SubStr(_2, StrLen(_r) + 1) : !(_u & 4) ? _Delimiter : (_u & 1) ? _Matches : _Splits
	}
	If InStr(_e, "a") {
		MsgBox, 262164, % A_ScriptName " - " A_ThisFunc "(): " SubStr(_Error, 1, InStr(_Error, ":") - 1), % SubStr(_Error, InStr(_Error, ":") + 2) "`n`nView the RXMS() documentation online?"
		IfMsgBox YES
		{
			Run, %_Documentation%, , UseErrorLevel
			If ErrorLevel
				MsgBox, 262144, %A_ScriptName% - %A_ThisFunc%(): Alert, % "Your web browser was unable to open the AutoHotkey forums. The url`n`n" (Clipboard := _Documentation) "`n`nhas been copied to your clipboard."
		}
	}
	ErrorLevel := InStr(_e, "e") ? SubStr(_Error, 1, InStr(_Error, ":") - 1) : _PrevErrorLevel
	If InStr(_e, "p")
		Pause, On
	If InStr(_e, "x")
		Exit
}

; The below function is only needed with the CSV option. If you don't plan on using that then you can easily comment out the two instances of CSV() in the RXMS() function.
CSV(Text, Delimiter=",", Literal="""")
{
	If (SubStr(Text, 1, 1) = Literal) or InStr(Text, Delimiter) or InStr(Text, "`n") or InStr(Text, "`r") {
		StringReplace, Text, Text, %Literal%, %Literal%%Literal%, All
		Text := Literal Text Literal
	}
	Return Text
}