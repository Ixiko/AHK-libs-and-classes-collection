;---------------------------------------------------------------------------
; v0.9.0 BETA
;---------------------------------------------------------------------------
;	Syntax
;---------------------------------------------------------------------------
;	(READ)
;		obj.Key[ Section, File]						; IniRead
;		obj.Key[ Section]							; IniRead - obj.Key[File] is not acceptable. obj.Key["", File] is properly.
;		obj.Key										; IniRead
;		obj[""]										; IniRead - read entire section
;
;	(WRITE)
;		obj.Key[ Section, File] := value			; IniWrite
;		obj.Key[ Section] := value					; IniWrite
;		obj.Key := value							; IniWrite
;		obj[""] := value							; IniWrite - write entire section
;
;	(DELETE)
;		obj.Key[ Section, File, 1]					; IniDelete - Key delete
;		obj[ "", Section, File, 1]					; IniDelete - delete entire section
;		obj._Del(File, Section, Key)				; IniDelete, Filename, Section [, Key] equivalent
;		
;
; 	[Key]
; 	The key name in the .ini file.
;
; 	[Section]
; 	The section name in the .ini file, which is the heading phrase that appears in square brackets (do not include the brackets in this parameter).
;
; 	[File]
; 	The name of the .ini file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
;
; 	[Value]
; 	The string or number that will be written to the right of Key's equal sign (=).
;
;---------------------------------------------------------------------------
;	Functions
;---------------------------------------------------------------------------
;	obj._Def(kind, value) - Set new default values. See description below.
;	* [Kind]
; 		which item you want to change
; 		1,File or F for File
; 		2,Section or S for Section
;	* [Value]
;		New value to be set. If this parametr is "" or omited then currently value is returned
;
;---------------------------------------------------------------------------
;	Description
;---------------------------------------------------------------------------
; * Initialize
;	obj := new __ini(file, Section)
;	Section and file: set defaults value, if omited or "" default defaults will be used
;	It's same as:
;	obj := new __ini
;	obj._Def("s", "sectionname")
;	obj._Def("f", "filename")
;
; *	"Section" and "File" are optional parametrs. If they are "" or not exist then they will be set to defaults value
; 	Section default = General
; 	File default    = Settings.Ini
;
; *	You Can change default value by
;	obj := new __ini(file, Section)
;	obj._Def("F", "New_value")
;	By this way you can create object for each file/section and call obj.Key without specifying each time Section and file.
;
; *	If You want Key to be Variable then you can put it inside square brackets
; 	obj.Key[ Section, File] ---> obj[KeyVar, Section, File]
;	While Key is "" then read/write/delete entire section
;
; *	All parametrs must be inside square brackets exluding "Key"
;
; * Do not overwrite __ini!!!
;-----------------------------------------------------
Class __ini
{
	__new(file="", section="", p*) {
		__ini[&this, "File"]    := "Settings.ini"
		__ini[&this, "Section"] := "General"
		If (file!="")
			This._Def("F", File)
		If (section!="")
			This._Def("S", Section)
	}

	_Def(kind, value="") {
		If (Value = "")
		{
			If Kind in 1,File,F
				return __ini[&this, "File"]
			Else If Kind in 2,Section,S
				return __ini[&this, "Section"]
		}
		If Kind in 1,File,F
			__ini[&this, "File"] := Value
		Else If Kind in 2,Section,S
			__ini[&this, "Section"] := Value
	}

	_Del(File, Section, Key="") {
		file    := (file="")?__ini[&this, "File"]:file
		section := (section="")?__ini[&this, "Section"]:section
		;~ msgbox,% "File: " file "`nSection: " Section "`nKey: " key
		If (Key = "")
			IniDelete,% File,% Section
		else
			IniDelete,% File,% Section,% Key
	}

	__Set(key, p*) {
		If (p.MaxIndex() = 3) ; obj.Key[ Section, File] := value
		{
			Section	:= p[1]
			File 	:= p[2]
			value	:= p[3]
		}
		Else If (p.MaxIndex() = 2) ; obj.Key[ Section] := value
		{
			Section	:= p[1]
			File 	:= ""
			value	:= p[2]
		}
		Else If (p.MaxIndex() = 1) ; obj.Key := value
		{
			Section	:= ""
			File 	:= ""
			value	:= p[1]
		}


		file    := (file="")?__ini[&this, "File"]:file
		section := (section="")?__ini[&this, "Section"]:section
		;~ msgbox,% "File: " file "`nSection: " Section "`nKey: " key
		If (key = "")
			iniwrite,% value,% file,% section
		else
			iniwrite,% value,% file,% section,% key
		return ""
	}

	__Get(key, section="", file="", Del="") {
		If (Del = 1)
		{
			This._Del(File, Section, Key)
			return
		}
		
		file    := (file="")?__ini[&this, "File"]:file
		section := (section="")?__ini[&this, "Section"]:section
		;~ msgbox,% "File: " file "`nSection: " Section "`nKey: " key
		If (key = "")
			IniRead, val,% File,% section
		else
			IniRead, val,% File,% section,% Key
		return val
	}

	__Delete() {
		__ini.Remove(&this, "")
	}
}