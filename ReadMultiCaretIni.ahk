; LintaList Include
; Purpose: Read MultiCaret INI
; Version: 1.0
; Date:    20160401

/*
[editor.exe]
str=___
key=^d
clr=del
*/

ReadMultiCaretIni()
	{
	 Global MultiCaret
	 ini=%A_ScriptDir%\multicaret.ini
	 IfNotExist, %ini%
		MultiCaretIni(ini)
	 ; IniRead, OutputVarSectionNames, Filename
	 ; IniRead, OutputVar, Filename, Section, Key [, Default]
	 IniRead, SectionNames, %ini%
	 MultiCaret:={}
	 keys:="str,key,clr"
	 Loop, parse, SectionNames, `n
		{
		 section:=A_LoopField
		 Loop, parse, keys, CSV
			IniRead, %A_LoopField%, %ini%, %section%, %A_LoopField%, %A_Space%
		 if str
		 	MultiCaret[section,"str"]:=str
		 if key
			MultiCaret[section,"key"]:=key
		 if clr
			MultiCaret[section,"clr"]:=clr
		 str:="",key:="",clr:=""
		}
	}

; create ini if not present, that way we don't overwrite any user changes in future updates
MultiCaretIni(ini)
	{
FileAppend,
(
`; -------------------------------------------------------------------------------------------
`; Lintalist - MultiCaret setup for text editors that support multi-caret/edit using shortcuts
`; Use the name of the editor executable as [section] name
`; followed by three keys: 
`; str= string to use as placeholder to be able to "select word + select next occurrence"
`; key= shortcut key used by editor for "select word" in AHK notation (^=ctrl +=shift !=alt)
`; clr= key to send when all "words" are selected, using {Del} or {BS} clears the text
`;
`; ------------------------------------------------------------------------------------------

[atom.exe]
str=___
key=^d
clr={del}
[brackets.exe]
str=___
key=^b
clr={del}
[code.exe]
str=___
key=^d
clr={del}
[everedit.exe]
str=___
key=^d
clr={del}
[komodo.exe]
str=___
key=^d
clr={del}
[sublime_text.exe]
str=___
key=^d
clr={del}
[textadept.exe]
str=___
key=^+d
clr={del}
[uedit32.exe]
str=___
key=^;
clr={del}
[uedit64.exe]
str=___
key=^;
clr={del}
)
, %ini%
	}