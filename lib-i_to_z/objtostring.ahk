;===Description=========================================================================
/*
Object from/to file or string - another way to set/get/edit/store data structures. By Learning one.
http://www.autohotkey.com/board/topic/66496-object-fromto-file-or-string-data-structures/

Very easy for both humans and machines to read and write. Fast, simple, flexible.
Hierarchy in data structure string is defined by using indentation, more precisely; tab character. Can be changed.

Functions, obligatory parameters, and return values:
	ObjFromFile(FilePath)		; creates object from file. 	Returns: object
	ObjToFile(Object, FilePath)	; saves object to file. 		Returns: 1 if there was a problem or 0 otherwise
	ObjFromStr(String) 			; creates object from string. 	Returns: object
	ObjToStr(Object) 			; converts object to string. 	Returns: string
*/

/*
;===How to use example==================================================================
DataPath := A_ScriptDir "\AppData.txt"

if !FileExist(DataPath)
	Gosub, CreateDemoFile		; first time creation

oData := ObjFromFile(DataPath)	; creates (loads) object from file

MsgBox, % oData.Version "`n" oData.Menu.Item1.Action "`n" oData["Tip of the day?"]	; get some data
MsgBox, % ObjToStr(oData)		; get and see all data - converts whole object to string

oData.Version := "3.33"			; modify
;oData.Menu.Remove("Item2")		; remove (delete)
oData.Sounds := "Yes"			; add

MsgBox, % ObjToStr(oData)		; see all after modifications
ObjToFile(oData, DataPath)		; save modified object (data structure) back to file. Ready to load next time.
ExitApp


;===Subroutines=========================================================================
CreateDemoFile:
SomeData =			; demo data structure
(
Date modified = 05.05.2011.
Hotkeys
	Win + C = Calculator
	Win + P = Paint
Menu
	Item1
		Action = C:\
		Text = C disk
	Item2
		Action = C:\Script.ahk
		Icon = AHK.png
	Skin = Black
Tip of the day? = No
Version = 1.00
)
FileAppend, %SomeData%, %DataPath%, UTF-8	; save to file
SomeData := ""		; not needed any more
return


;===Hotkeys=============================================================================
Escape::ExitApp

*/

;===Functions===========================================================================
ObjFromStr(String, Indent="`t", Rows="`n", Equal="=") {		; creates object from string which represents data structure.
	obj := Object(), kn := Object()	; kn means "key names" - simple array object
	IndentLen := StrLen(Indent)
	Loop, parse, String, %Rows%
	{
		if A_LoopField is space
			continue
		Field := RTrim(A_LoopField, " `t`r")
		
		CurLevel := 1, k := "", v := ""	; clear, reset
		While (SubStr(Field,1,IndentLen) = Indent) {
			StringTrimLeft, Field, Field, %IndentLen%
			CurLevel++
		}
		
		EqualPos := InStr(Field, Equal)
		if (EqualPos = 0)
			k := Field
		else
			k := SubStr(Field, 1, EqualPos-1), v := SubStr(Field, EqualPos+1)
		
		k := Trim(k, " `t`r"), v := Trim(v, " `t`r")
		kn[CurLevel] := k
		if !(EqualPos = 0) {	; key-value
			if (CurLevel = 1)
				obj[kn.1] := v
			else if (CurLevel = 2)
				obj[kn.1][k] := v
			else if (CurLevel = 3)
				obj[kn.1][kn.2][k] := v
			else if (CurLevel = 4)
				obj[kn.1][kn.2][kn.3][k] := v
			else if (CurLevel = 5)
				obj[kn.1][kn.2][kn.3][kn.4][k] := v
			else if (CurLevel = 6)
				obj[kn.1][kn.2][kn.3][kn.4][kn.5][k] := v
			else if (CurLevel = 7)
				obj[kn.1][kn.2][kn.3][kn.4][kn.5][kn.6][k] := v		; etc...
		}
		else {	; sub-object
			if (CurLevel = 1)
				obj.Insert(kn.1,Object())
			else if (CurLevel = 2)
				obj[kn.1].Insert(kn.2,Object())
			else if (CurLevel = 3)
				obj[kn.1][kn.2].Insert(kn.3,Object())
			else if (CurLevel = 4)
				obj[kn.1][kn.2][kn.3].Insert(kn.4,Object())
			else if (CurLevel = 5)
				obj[kn.1][kn.2][kn.3][kn.4].Insert(kn.5,Object())
			else if (CurLevel = 6)
				obj[kn.1][kn.2][kn.3][kn.4][kn.5].Insert(kn.6,Object())		; etc...
		}
	}
	return obj
}

ObjToStr(Obj, Indent="`t", Rows="`n", Equal=" = ", Depth=7, CurIndent="") {	; converts object to string
    For k,v in Obj
        ToReturn .= CurIndent . k . (IsObject(v) && depth>1 ? Rows . ObjToStr(v, Indent, Rows, Equal, Depth-1, CurIndent . Indent) : Equal . v) . Rows
    return RTrim(ToReturn, Rows)
}	; http://www.autohotkey.com/forum/post-426623.html#426623

ObjFromFile(FilePath, Indent="`t", Rows="`n", Equal="=") {		; creates object from file
	if !FileExist(FilePath)
		return
	FileRead, String, %FilePath%
	return ObjFromStr(String, Indent, Rows, Equal)	; creates and returns object from string
}

ObjToFile(Obj, FilePath, Indent="`t", Rows="`n", Equal=" = ", Depth=7) {	; saves object to file
	if FileExist(FilePath)
		FileDelete, %FilePath%	; delete old
	FileAppend, % ObjToStr(Obj, Indent, Rows, Equal, Depth), %FilePath%, UTF-8	; store new
	return ErrorLevel
}