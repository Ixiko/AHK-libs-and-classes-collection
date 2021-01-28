; Title:	TCwdx
;			Functions to work with Total Commander content plugins


;-----------------------------------------------------------------
; Function: FindIni
;			Find full path of the TC wincmd.ini 
;
; Returns:	
;			Path if ini is found or nothing otherwise
;
TCwdx_FindIni() {
	RegRead, ini, HKEY_CURRENT_USER, Software\Ghisler\Total Commander, IniFileName
	if FileExist(ini)
		return ini

	EnvGet COMMANDER_PATH, COMMANDER_PATH
	if (COMMANDER_PATH != ""){
		ini = %COMMANDER_PATH%\wincmd.ini
		if FileExist(ini)
			return ini
	}
}


;-----------------------------------------------------------------
; Function: GetPluginsFromDir
;			Get list of plugins from directory (no wincmd.ini is used)
;
; Parameters:
;			path -	Base path. Plugnins should be in folders with equal name as their own.
;
; Returns:	
;			String in Ini_ format: name=path
;
TCwdx_GetPluginsFromDir( path ) {
	loop, %path%\*, 2
	{
		tcPlug :=  A_LoopFileFullPath "\" A_LoopFileName ".wdx"
		if FileExist(tcPlug)
			res .= A_LoopFileName "=" tcPlug "`n"
	}
	return SubStr(res, 1, -1)
}

;-----------------------------------------------------------------
; Function: GetPlugins
;			Get list of installed tc plugins.
;
; Parameters:
;			pIni	-	TC wincmd.ini path or "" to try to get ini location from registry or using
;						machine environment variable COMMANDER_PATH
;
; Returns:	
;			String in Ini_ format: name=path or ERR if ini can not be found
;
TCwdx_GetPlugins( pIni="" ) {
	if pini =
		pIni := TCwdx_FindIni()
	if !FileExist(pIni)
		return "ERR"

	VarSetCapacity(dest, 512) 

	inSec := 0
	Loop, read, %pIni%
	{
		s := A_LoopReadLine
		if (!inSec){
		   inSec := InStr(s,"[ContentPlugins]")
		   continue
		}
		
		if *&s=91				;if next line starts with [
			break

		j:=InStr(s, "="), n := SubStr(s, 1, j-1), v:= SubStr(s, j+1)
		if n is Integer	
		{
			DllCall("ExpandEnvironmentStrings", "str", v, "str", dest, "int", 512), v:=dest
			if !FileExist(v)
				continue
			res .= SubStr(v, InStr(v, "\", false, 0)+1, -4) "=" v "`n"
		}
	}
	return SubStr(res, 1, -1)
}
;-----------------------------------------------------------------
; Function: LoadPlugin
;			Load plugin dll into the memory	and sets its default params
;
; Parameters:
;			tcplug	- Path to TC content plugin
;
;		
TCwdx_LoadPlugin(tcplug) {
	h := DllCall("LoadLibrary", "str", tcplug),  TCwdx_SetDefaultParams(tcplug)
 	return 	h
}

;-----------------------------------------------------------------
; Function: UnloadPlugin
;			Unloads plugin dll
;
; Parameters:
;			htcplug	- Handle returned by LoadPlugin function
;
TCwdx_UnloadPlugin(htcplug){
	return 	DllCall("FreeLibrary", "UInt", htcplug) 
}

;-----------------------------------------------------------------
; Function: GetPluginFields
;			Get list of plugin fields.
;
; Parameters:
;			tcplug	-	Path to TC content plugin.
;			format	-	If omited, only field names will be returned, if set to "ini" string will be in Ini_ format, field=index|unit1|unit2...|unitN
;						or field=index if there is no unit for given field, if "menu", string will be in ShowMenu format with "|" as item separator and root 
;						of the menu named "tcFields".
;
; Returns:	
;			String with fields on each line									 
;
TCwdx_GetPluginFields( tcplug, format="" ) {
	if format = ""
		 format = 0			;def
	else if format = "ini"
		 format = 1			;ini
	else format = 2			;menu

	VarSetCapacity(name,512), VarSetCapacity(units,512)
	loop {
		r := DllCall(tcplug "\ContentGetSupportedField", "int", A_Index-1, "uint", &name, "uint", &units, "uint", 512)
		IfEqual, r, 0, break										;ft_nomorefields=0
		VarSetCapacity(name,-1) , VarSetCapacity(units,-1)
		Tr(name), Tr(units)

		IfEqual, r, 7, SetEnv, units								;multiple fields are not units

		if format = 0
			     res .= name "`n"
		else if format = 1
			     res .= name "=" A_Index-1 (units !="" ? "|" units : "")  "`n"
		else 
			if (units != "") 
				 res .= name "=<" name ">|",   resu .= "[" name "]`n" units "`n" 				;!!!for show menu mod <> instead []
			else res .= name "|"

	}

	StringTrimRight, res, res, 1
	if format = 2
		res := "[tcFields]`n" res "`n" resu

	return res
}

;-----------------------------------------------------------------
; Function: GetField
;			Get field data
;
; Parameters:
;			FileName -	File name for which info is to be retreived
;			tcplug	 -	Path to TC content plugin
;			fi		 -	Field index, by default 0
;			ui		 -  Unit index, by default 0
;
; Returns:	
;			Field data
;
TCwdx_GetField(FileName, tcplug, fi=0, ui=0){
	static i=0, info, st

	if (!i++)
		VarSetCapacity(info,256), VarSetCapacity(st, 16)		;reserve buffers only on first call
	type := DllCall(tcplug "\ContentGetValue", "astr", FileName, "int", fi, "int", ui, "uint", &info, "int", 256, "int", 0)

	if (type <=0 or type=9) 
		return
	goto TCwdx_Type_%type%

	TCwdx_Type_1:									;ft_numeric_32
	TCwdx_Type_6:
		return NumGet(info, 0, "Int")		
	TCwdx_Type_2:									;ft_numeric_64	A 64-bit signed number
		return NumGet(info, 0, "Int64")
	TCwdx_Type_3:									;ft_numeric_floating	A double precision floating point number
		return NumGet(info, 0, "Double")
	TCwdx_Type_4:									;ft_date	A date value (year, month, day)
		return NumGet(info, 0, "UShort") "." NumGet(info, 2, "UShort") "." NumGet(info, 4, "UShort")
	TCwdx_Type_5:									;A time value (hour, minute, second). Date and time are in local time.
		return NumGet(info, 0, "UShort") "." NumGet(info, 2, "UShort") "." NumGet(info, 4, "UShort")
	TCWdx_Type_7:
	TCwdx_Type_8:
		VarSetCapacity(info,-1)						;ft_string
		Tr(info)
		return info
	TCwdx_Type_10:									;A timestamp of type FILETIME, as returned e.g. by FindFirstFile(). It is a 64-bit value representing the number of 100-nanosecond.
		r := DllCall("FileTimeToSystemTime", "uint", &info, "uint", &st)
		ifEqual r, 0, return
		return NumGet(st, 0, "UShort") "." NumGet(st, 2, "UShort") "." NumGet(st, 6, "UShort") " " NumGet(st, 8, "UShort") "." NumGet(st, 10 ,"UShort") "." NumGet(st, 12, "UShort")
}

;-----------------------------------------------------------------
; Function: GetIndices
;			Get index of field and optionaly its unit
;
; Parameters:
;			tcplug	 -	Path to TC content plugin
;			field	 -	Field for which index is to be returned. If unit is to be returned, use "Field.Unit" notation.
;			fi		 -	Reference to variable to receive field index or empty string if field is not found.
;			ui		 -	Optional Reference to variable to receive unit index or empty string if field is not found.
;						If unit is is not requested ui will be set to 0.
;
TCwdx_GetIndices(tcplug, field, ByRef fi, ByRef ui="."){

	fi := "", ui = 0
	if j := InStr(field, ".") 
		unit := SubStr(field, j+1), field := SubStr(field, 1, j-1)

	VarSetCapacity(name,512), VarSetCapacity(units,512)
	loop {
		r := DllCall(tcplug "\ContentGetSupportedField", "int", A_Index-1, "uint", &name, "uint", &units, "uint", 512)
		IfEqual, r, 0, return										;ft_nomorefields=0

		VarSetCapacity(name,-1), VarSetCapacity(units,-1)
		Tr(name), Tr(units)

		if (name=field) {
			fi := A_Index - 1
			if (ui != ".") and (unit != "") {
				VarSetCapacity(units,-1) 
				loop, parse, units, |
					if (A_LoopField=unit) {
						ui := A_Index - 1
						return
					}
				ui := ""
			}
			return
		}
	}	
}

;-----------------------------------------------------------------
; Function: SetDefaultParams
;			Mandatory function for some plugins (like ShellDetails)
;
; Parameters:
;			tcplug	- Path to tc content plugin
;
TCwdx_SetDefaultParams(tcplug){
	VarSetCapacity(dps, 272, 0)
	NumPut(272, dps, "Int"), NumPut(30, dps, 4), NumPut(1, dps, 8)

	SplitPath, tcplug, , dir, , name
	name = %dir%\%name%.ini
	DllCall("lstrcpyA", "uint", &dps+12, "astr", name)
	r := DllCall(tcplug "\ContentSetDefaultParams", "uint", &dps)	
}