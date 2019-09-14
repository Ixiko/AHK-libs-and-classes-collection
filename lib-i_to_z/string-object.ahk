/*==Description=========================================================================

String-object-file (data structures in YAML-like style)
Author:		Learning one (Boris Mudrinić)
Contact:	https://dl.dropboxusercontent.com/u/171417982/AHK/Learning one contact.png
AHK forum:	http://www.autohotkey.com/board/topic/104854-string-object-file-data-structures-in-yaml-like-style/


=== License ===
Redistribution and use (both commercial and non-commercial) in source and binary forms, are permitted free of charge if you give a credit to the author. Author is not responsible for any damages arising from use or redistribution of his work. If redistributed in source form, you are not allowed to remove comments from this file.


=== See also ===
- Yaml Parser (++JSON) by HotKeyIt: http://www.autohotkey.com/board/topic/65582-ahk-lv2-yaml-yaml-parser-json/
- JSON module by Coco: http://ahkscript.org/boards/viewtopic.php?f=6&t=627&p=4988
- JSON-like (de)serializer by VxE: http://ahkscript.org/boards/viewtopic.php?f=6&t=30&p=99
- Json <---> Object by lordkrandel: http://www.autohotkey.com/board/topic/61328-lib-json-ahk-l-json-object/
- Object from/to file or string by Learning one (obsolete): http://www.autohotkey.com/board/topic/66496-object-fromto-file-or-string-data-structures/
- YAML on wikipedia: http://en.wikipedia.org/wiki/YAML
- Learn Yaml in 5 minutes: http://yaml.codeplex.com/wikipage?title=Yaml in 5 minutes


=== Documentation ===
One function does it all; just call StrObj() function and it will automatically conclude what do you want to do, depending on type of your input.
Here's how to use it and what it does:

Object := StrObj(String)	; String to Object (constructs object from string)
String := StrObj(Obj)		; Object to String (converts object to string)
Object := StrObj(File)		; File to Object (constructs object from file)

ErrorLevel := StrObj(Obj,OutFile)		; saves Object to File
ErrorLevel := StrObj(String,OutFile)	; saves String to File
ErrorLevel := StrObj(File,OutFile)		; saves File to File

Learn from examples.
Warning: although strings which are used to construct objects are in YAML format, there is no full YAML support!
For full YAML support use HotKeyIt's Yaml Parser but be prepared for some surprizes like this: http://www.autohotkey.com/board/topic/65582-ahk-lv2-yaml-yaml-parser-json/page-7#entry640399


Formatting rules for string which are used to construct object;
To build SIMPE ARRAY like ["avocado", "banana", "mango"], use "- value" format (like a list). Your string has to look like this;
	String:= "
	(`
	- avocado
	- banana
	- mango
	)"
	Object := StrObj(String)	; String to Object (constructs object from string)

To build ASSOCIATIVE ARRAY like {FirstName: "John", LastName: "Smith"}, use "key: value" format. Your string has to look like this;
	String:= "
	(`
	FirstName: John	
	LastName: Smith
	)"
	Object := StrObj(String)	; String to Object (constructs object from string)


HIERARCHY in data structure is defined by using indentation, more precisely; tab character. 
So, to build more complex object like {Customer: {FirstName: "John", LastName: "Smith"}, Fruits: ["avocado", "banana", "mango"]}, combine all above like this;
	String:= "
	(`
	Customer:
		FirstName: John	
		LastName: Smith
	Fruits:
		- avocado
		- banana
		- mango
	)"
	Object := StrObj(String)	; String to Object (constructs object from string)


=== Tips for continuation sections ===
If you are using indented continuation sections, always use expression assignment. More info here; http://www.autohotkey.com/board/topic/104735-continuation-sections-left-tabs-in-the-first-line/
Example:
			String:= "
			(`
			- avocado
			- banana
			- mango
			)"

Use accent (`) option in continuation sections;
- it treats each backtick character literally rather than as an escape character.
- it prevents the translation of any explicitly specified escape sequences such as `n and `t.
Example:
	String:= "
	(`
	Name: Item	
	Description: This item does 3 things:`n1) thing 1`n2) thing 2`n3) thing 3
	)"


=== Example 1 - simple array ===
String := "
(`
- avocado
- banana
- mango
)"

Obj := StrObj(String)
MsgBox % Obj.2	; returns "banana"


=== Example 2 - associative array ===
String := "
(`
FirstName: John	
LastName: Smith
Nick: Jonny
)"

Obj := StrObj(String)
MsgBox % Obj.LastName	; returns "Smith"


=== Example 3 - complex ===
String := "
(`
FirstName: John	
LastName: Smith
Nick: Jonny
Parents:
	- Anna
	- Joe
PhoneNumbers:
	-
		Number: 212 555-1234
		Type: fixed
	- 
		Number: 099 555-4567
		Type: mobile
Skills:
	Music: plays guitar
	Programming: knows AHK, C++, HTML
	Spots: good in Kiteboarding, Windsurfing and Swimming
)"
TestFileFullPath := A_ScriptDir "\StrObj test.txt"
OnExit, ExitSub

Obj := StrObj(String)					; String to Object (constructs object from string)

MsgBox % Obj.Parents.2					; returns "Joe"
MsgBox % Obj.PhoneNumbers.MaxIndex()	; returns "2"
MsgBox % Obj.PhoneNumbers.2.Type		; returns "mobile"

Obj.PhoneNumbers.2.Number := "099 123-456"	; sets new value
Obj.Skills.Programming .= ", Lua"			; appends value
Obj.YearOfBirth := 1982						; inserts new key and sets its value

MsgBox % StrObj(Obj)				; converts modified object to a string and displays it in a MsgBox
StrObj(Obj,TestFileFullPath)		; saves modified object to File
Run, % TestFileFullPath
return

F1::
Obj := StrObj(TestFileFullPath)		; File to Object (constructs object from file)
MsgBox % StrObj(Obj)				; converts object to a string and displays it in a MsgBox
return
F2::Run, % TestFileFullPath
Esc::ExitApp
ExitSub:
FileDelete, % TestFileFullPath	; clear testing mess
ExitApp


=== Example 4 - reverse ===
Obj := ["avocado", "banana", "mango"]
MsgBox % StrObj(Obj)	; converts object to string and displays it in MsgBox

Obj := {FirstName: "John", LastName: "Smith"}
MsgBox % StrObj(Obj)	; converts object to string and displays it in MsgBox

Obj := {Customer: {FirstName: "John", LastName: "Smith"}, Fruits: ["avocado", "banana", "mango"]}
MsgBox % StrObj(Obj)	; converts object to string and displays it in MsgBox


=== Example 5 - NewLine and Tab characters ===
String:= "
(`
- avocado
- ba`nna`nna
- man`t`t`tgo
)"
Obj := StrObj(String)	; String to Object

MsgBox % Obj.2
;		MsgBox above displays:
;		ba
;		na
;		na

MsgBox % Obj.3
;		MsgBox above displays:
;		man			go

MsgBox % StrObj(Obj)	; Object to String
;		MsgBox above displays:
;		- avocado
;		- ba`nna`nna
;		- man`t`t`tgo


=== Example 6 - changing default options ===
String := "
(`
Items:
	-
		Action: %A_WinDir%
		Text: Windows
	-
		Action: C:\Script.ahk
		Text: Script
Name: Test menu
)"

Obj := StrObj(String)

;Use default options;
MsgBox % StrObj(Obj)

;Use custom options;
StrObj.Indent := "  "	; change indentation option to 2 spaces. (Default = `t)
MsgBox % StrObj(Obj)
*/


Class StrObj {		; String-object-file (data structures in YAML-like style). By Learning one
	static Version := 1.01, Author := "Learning one", WebSite := "http://www.autohotkey.com/board/topic/104854-string-object-file-data-structures-in-yaml-like-style/"

	static Indent := "`t"
	static EscapedIndent := "``t"			; when converting object to string 
	static NewLine := "`n"					; when parsing a string (reading)
	static EscapedNewLine := "``n"			; when converting object to string 

	static NewLineInOutputString := "`r`n"	; when writing to a string
	static Omit := "`r"						; omitted when parsing a string (reading) 
	static Equal := ":"						; Equal is a sign which delimits key from its value; key: value
	static DerefValues := 1
	static SmartIndentTrim := 1				; useful in [indented continuation sections] and [overindented text in .txt files] which contain YAML-like string
	static FileAppendEncoding := "UTF-8"

	Auto(Input,SaveToFileFullPath="") {						; Automatically concludes what user wants to do. Called by StrObj() function
		Att := FileExist(Input)
		if (Att != "" and InStr(Att, "D") = 0) {			; Input is FILE - user wants to read that file, construct object from its contents (string) and return object
			FileRead, FileContents, % Input
			ReturnValue := this.StrToObj(FileContents)		; returns object
			if (SaveToFileFullPath != "") 					; user actually wants to save String (FileContents) to a file
				ToSave := RTrim(FileContents, " `t`n`r"), SaveToFile := 1
		}
		else if (IsObject(Input) = 1) {						; Input is OBJECT - user wants to convert it to string and return that string
			ReturnValue := this.ObjToStr(Input)				; returns string
			if (SaveToFileFullPath != "")					; user actually wants to save String (ReturnValue) to a file
				ToSave := ReturnValue, SaveToFile := 1	
		}
		else {												; Input is STRING - user wants to construct object from that string and return that object
			ReturnValue := this.StrToObj(Input)				; returns object
			if (SaveToFileFullPath != "")					; user actually wants to save String (Input) to a file
				ToSave := RTrim(Input, " `t`n`r"), SaveToFile := 1
		}
		
		if (SaveToFile = 1) {								; Return value:  0 = no problems (Successful). Anything else = problems (failure). 
			if (FileExist(SaveToFileFullPath) != "") {		; SaveToFileFullPath already exists - delete it first
				FileDelete, % SaveToFileFullPath
				if (ErrorLevel > 0)							; ErrorLevel is set to the number of files that failed to be deleted (if any) or 0 otherwise.
					return ErrorLevel
			}
			FileAppend, % ToSave, % SaveToFileFullPath, % this.FileAppendEncoding
			return ErrorLevel 								; ErrorLevel is set to 1 if there was a problem or 0 otherwise.
		}
		
		return ReturnValue									; if user was not saving to a file, function will return him object or string
	}

	StrToObj(String) {		; Creates object from YAML-like string.
		
		;=== Preparation ===
		Indent := this.Indent
		NewLine := this.NewLine
		Omit := this.Omit
		Equal := this.Equal
		DerefValues := this.DerefValues
		SmartIndentTrim := this.SmartIndentTrim
		obj := [], KeyNames := [], Items := [], LastDepth := 0, CurNum := [0,0,0,0,0,0,0,0,0,0], IndentLen := StrLen(Indent)
		
		;=== SmartIndentTrim ===
		if (SmartIndentTrim = 1) {	; useful in [indented continuation sections] and [overindented text in .txt files] which contain YAML-like string
			Counter := 0, IntentsToTrim := 100000	; IntentsToTrim can be any arbitrary big number... It's unlikely user will have so many tabs  at the left (indentation)
			
			;=== See how many indents at the left have to be trimmed and store it in IntentsToTrim variable ===
			; If you are using indented continuation sections, always use expression assignment. More info here; http://www.autohotkey.com/board/topic/104735-continuation-sections-left-tabs-in-the-first-line/
			; Count only left tabs in the first not-blank line (not in all lines) because first not-blank line must always be at the highest level...
			Loop, parse, String, % NewLine , % Omit
			{
				if A_LoopField is space	; ignore
					continue
				Field := A_LoopField, IndentsInThisLine := 0, FirstLineDetected := 1
				While (SubStr(Field,1,IndentLen) = Indent) {
					Field := SubStr(Field, IndentLen+1)	; removes first %IndentLen% characters
					IndentsInThisLine += 1
				}
				if (IndentsInThisLine < IntentsToTrim)
					IntentsToTrim := IndentsInThisLine
				if (FirstLineDetected = 1)
					break
			}
			
			;=== If there are extra indents in this string to trim at the left ===
			if (IntentsToTrim < 100000 and IntentsToTrim > 0) {		; there are extra indents in this string to trim at the left
				NewString := ""
				Loop, parse, String, % NewLine , % Omit
				{
					Field := SubStr(A_LoopField, IntentsToTrim+1)	; removes first %IntentsToTrim% characters
					NewString .= Field NewLine
				}
				String := SubStr(NewString,1, StrLen(NewString)-StrLen(NewLine))	; overwrite String with NewString, which hasn't got extra indents at the left
			}
		}
		
		;=== Extract data from string ===
		Loop, parse, String, % NewLine , % Omit
		{
			CurDepth := 1, IsPreviousItemValueObject := 0
			if A_LoopField is space
				continue
			Field := RTrim(A_LoopField, " `t`r")
			While (SubStr(Field,1,IndentLen) = Indent) {
				Field := SubStr(Field, IndentLen+1)	; removes first %IndentLen% characters
				CurDepth += 1
			}
			
			if (CurDepth != LastDepth) {	; Indent change
				if (CurDepth < LastDepth)	; <--- Decreased indent
					CurNum[LastDepth] := 0	; 		restart numbering for LastDepth
				if (CurDepth > LastDepth) {	; ---> Increased indent
					CurNum[CurDepth] := 0	; 		restart numbering for CurDepth
					if (CurDepth > 1)
						IsPreviousItemValueObject := 1
				}
				LastDepth := CurDepth
			}
			
			if (SubStr(Field,1,1) = "-") {		; if FirstChar is "-"
				CurNum[CurDepth] += 1
				NewItem := CurNum[CurDepth]  ": " Trim(SubStr(Field,2), " `t`r")	; Exa: "- Joe" --> "2: Joe"
			}
			else
				NewItem := Field	; Exa: "FirstName: John"
			
			EqualPos := InStr(NewItem, Equal)
			k := SubStr(NewItem, 1, EqualPos-1), v := SubStr(NewItem, EqualPos+1)
			k := Trim(k, " `t`r"), v := Trim(v, " `t`r")	; k=key, v=value
			
			if (DerefValues = 1)
				Transform, v, Deref, % v
			
			KeyNames[CurDepth] := k
			
			DepthNames := []
			Loop, % CurDepth
				DepthNames.Insert(KeyNames[A_Index])	; DepthNames exa: ["PhoneNumbers", "1", "Type"]
			
			Items.Insert([DepthNames,v])				; Items structure: DepthNames,value
			if (IsPreviousItemValueObject = 1) {
				PreviousItemNum := Items.MaxIndex() - 1
				Items[PreviousItemNum].2 := []			; value becomes object
			}		
		}
		
		;=== Construct object ===
		For k,v in Items	; Items structure: DepthNames,value
		{
			n := v.1			; n = DepthNames. Exa: ["PhoneNumbers", "1", "Type"]
			value := v.2		; values. Exa: "Joe"
			
			if value is Integer
				value := value*1	;  assigns a pure number instead of string - important for some COM methods
			
			CurLevel := n.MaxIndex()
			if (CurLevel = 1)
				obj[n.1] := value
			else if (CurLevel = 2)
				obj[n.1][n.2] := value
			else if (CurLevel = 3)
				obj[n.1][n.2][n.3] := value
			else if (CurLevel = 4)
				obj[n.1][n.2][n.3][n.4] := value
			else if (CurLevel = 5)
				obj[n.1][n.2][n.3][n.4][n.5] := value
			else if (CurLevel = 6)
				obj[n.1][n.2][n.3][n.4][n.5][n.6] := value
			else if (CurLevel = 7)
				obj[n.1][n.2][n.3][n.4][n.5][n.6][n.7] := value
			else if (CurLevel = 8)
				obj[n.1][n.2][n.3][n.4][n.5][n.6][n.7][n.8] := value
			else if (CurLevel = 9)
				obj[n.1][n.2][n.3][n.4][n.5][n.6][n.7][n.8][n.9] := value	; etc
		}
		return obj
	}
	
	ObjToStr(Obj, Depth=9, CurIndent="") {	; Converts object to YAML-like string.
		For k,v in Obj
		{
			if (IsObject(v) = 1 and Depth>1 ) {
				middlepart := this.NewLineInOutputString StrObj.ObjToStr(v, Depth-1, CurIndent this.Indent)
				if k is Integer
					ToReturn .= CurIndent "-" A_Space middlepart
				else {
					StringReplace, k, k, % this.Indent, % this.EscapedIndent, all
					StringReplace, k, k, % this.NewLine, % this.EscapedNewLine, all										
					ToReturn .= CurIndent k this.Equal A_Space middlepart
				}				
			}
			else {
				StringReplace, v, v, % this.Indent, % this.EscapedIndent, all
				StringReplace, v, v, % this.NewLine, % this.EscapedNewLine, all
				
				if k is Integer
					ToReturn .= CurIndent "-" A_Space v this.NewLineInOutputString
				else {
					StringReplace, k, k, % this.Indent, % this.EscapedIndent, all
					StringReplace, k, k, % this.NewLine, % this.EscapedNewLine, all										
					ToReturn .= CurIndent k this.Equal A_Space v this.NewLineInOutputString
				}
			}
		}
		return RTrim(ToReturn, NewLineInOutputString)
	}	; http://www.autohotkey.com/forum/post-426623.html#426623	
}

StrObj(Input,SaveToFileFullPath="") {					; Part of [Class StrObj]
	return StrObj.Auto(Input,SaveToFileFullPath)
}