/*
Func: iniWrapper_loadAllSections
    Loads all keys from all sections into vars

Parameters:
    iniVar	- ini variable

Returns:
    All keys from all sections will be loaded into variables

Examples:
    [General]
	Key_1=
	Key_2=value
	Key_3=234
	
	> iniWrapper_loadAllSections(ini)
	> msgbox % Key_2
    = value

Required libs:
    ini.ahk
*/
iniWrapper_loadAllSections(ByRef iniVar) {
	global
	
	loop, parse, % ini_getAllSectionNames(iniVar), `,
	{
		lSection := A_LoopField
		loop, parse, % ini_getAllKeyNames(iniVar, lSection), `,
			%A_LoopField% := ini_getValue(iniVar, lSection, A_LoopField)
	}
}

/*
Func: iniWrapper_loadAllSections
    Loads all keys from specified section into vars

Parameters:
    iniVar	- ini variable
    section	- ini section

Returns:
    All keys from specified section will be loaded into variables

Examples:
	[General]
	Key_1=
	Key_2=value
	Key_3=234
	
	[anotherSection]
	Key_11=
	Key_22=value
	Key_33=234
	
	> iniWrapper_loadSection(ini, "anotherSection")
	> msgbox % Key_22
    = value
	> msgbox % Key_2
	= ""

Required libs:
    ini.ahk
*/
iniWrapper_loadSection(ByRef iniVar, section) {
	global
	
	loop, parse, % ini_getAllKeyNames(iniVar, section), `,
		%A_LoopField% := ini_getValue(iniVar, section, A_LoopField)
}

/*
Func: iniWrapper_unloadAllSections
    Unloads all variables of all keys of all sections

Parameters:
    iniVar	- ini variable

Returns:
    All variables of all keys in the ini will be emptied

Examples:
	[General]
	Key_1=
	Key_2=value
	Key_3=234
	
	> iniWrapper_loadSection(ini, "General")
	> msgbox % Key_2
    = value
	> iniWrapper_unloadAllSections(ini)
	> msgbox % Key_2
    = ""

Required libs:
    ini.ahk
*/
iniWrapper_unloadAllSections(ByRef iniVar) {
	global
	
	loop, parse, % ini_getAllSectionNames(iniVar), `,
	{
		lSection := A_LoopField
		loop, parse, % ini_getAllKeyNames(iniVar, lSection), `,
			%A_LoopField% := ""
	}
}


/*
Func: iniWrapper_unloadSection
    Unloads all variables of all keys in specific section

Parameters:
    iniVar	- ini variable
    section	- ini section

Returns:
    All variables of all keys in in specific section will be emptied

Examples:
	[General]
	Key_1=
	Key_2=value
	Key_3=234
	
	[anotherSection]
	Key_11=
	Key_22=value
	Key_33=234
	
	> iniWrapper_loadAllSections(ini)
	> msgbox % Key_22
	= value
	> msgbox % Key_2
    = value
	> iniWrapper_unloadSection(ini, "anotherSection")
	> msgbox % Key_22
	= ""
	> msgbox % Key_2
    = value

Required libs:
    ini.ahk
*/
iniWrapper_unloadSection(ByRef iniVar, section) {
	global
	
	loop, parse, % ini_getAllKeyNames(iniVar, section), `,
		%A_LoopField% := ""
}


/*
Func: iniWrapper_saveAllSections
    Saves all variables from all ini keys to inivar

Parameters:
    iniVar	- ini variable

Returns:
    All keys from all sections will be saved into inivar

Examples:
    [General]
	Key_1=
	Key_2=value
	Key_3=234
	
	> iniWrapper_loadAllSections(ini)
	> msgbox % Key_2
    = value

	> Key_2 := "thisValue"
	> iniWrapper_saveAllSections(ini)
	> iniWrapper_loadAllSections(ini)
	> msgbox % Key_2
    = thisValue
	
Required libs:
    ini.ahk
*/
iniWrapper_saveAllSections(ByRef iniVar) {
	global
	
	loop, parse, % ini_getAllSectionNames(iniVar), `,
	{
		lSection := A_LoopField
		loop, parse, % ini_getAllKeyNames(iniVar, lSection), `,
			ini_replaceValue(iniVar, lSection, A_LoopField, %A_LoopField%)
	}
}


/*
Func: iniWrapper_saveSection
    Saves all variables from a specific section's ini keys to inivar

Parameters:
    iniVar	- ini variable
    section	- ini section

Returns:
    All keys from from a specific section's ini keys to inivar

Examples:
    [General]
	Key_1=
	Key_2=value
	Key_3=234
	
	[anotherSection]
	Key_11=
	Key_22=value
	Key_33=234
	
	> iniWrapper_loadAllSections(ini)
	> msgbox % Key_2
    = value

	> Key_2 := "thisValue"
	> iniWrapper_saveSection(ini, "anotherSection")
	> iniWrapper_loadAllSections(ini)
	> msgbox % Key_2
    = value
	
Required libs:
    ini.ahk
*/
iniWrapper_saveSection(ByRef iniVar, section) {
	global
	
	loop, parse, % ini_getAllKeyNames(iniVar, section), `,
		ini_replaceValue(iniVar, section, A_LoopField, %A_LoopField%)
}