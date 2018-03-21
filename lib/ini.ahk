/*
_______________________________________________________________________________
_______________________________________________________________________________

Title: Basic ini string functions
    Operate on variables instead of files. An easy to use ini parser.
_______________________________________________________________________________
_______________________________________________________________________________

License:

(C) Copyright 2009, 2010 Tuncay
    
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

(see lgplv3.png)

See the file COPYING.txt and COPYING.LESSER.txt for license and copying conditions.

About: Introduction

    Ini files are used mostly as configuration files. In general, they have the
    ".ini"-extension. It is a simple standardized organization of text data. 
    Many other simple programs use them for storing text.    
    
    AutoHotkey provides three commands IniDelete, IniRead and IniWrite. These
    commands are stable, but they have some disadvantages. First disadvantage
    is, that they access the file directly. The file on the disk is opened, 
    load into memory and then read or manipulated and then saved with every 
    single command.    

    With the custom functions I wrote here, the user accessess on variables 
    instead of files. This is super fast, in comparison to disk access. Ini 
    files can be created by Ahk just like any other variable. But Ahk itself 
    does not have any function to operate on ini strings (variables). If you 
    read often from ini file, then this might for you. 
    
    No other framework or library is required, no special object files are 
    created; just work on ordinary ini file contents or variables. The load
    and save functions are added for comfort reason and are not really needed.
    
    * *First do this:*
    
    > FileRead, ini, config.ini
    
    * *or load default file with:*
    
    > ini_load(ini)
    
    * *or create the content yourself:*
    
    (Start Code)
    ini =
    (
    [Tip]
    TimeStamp = 20090716194758
    [Recent File List]
    File1=F:\testfile.ahk
    File2=Z:\tempfile.tmp
    )
    (End Code)
    
    In this example "Tip" and "Recent File List" are name of the sections. The
    file consist in this example of 2 sections. Every section contains variables,
    so called "keys". Every key is a part of a section. In this example, the 
    section "Tip" have one key "TimeStamp". And every key has a content, 
    called value. The "TimeStamp" key have the value "20090716194758".
    
    After that, you can access and modify the content of the ini variable with 
    the following functions. But the modifications are only temporary and must 
    me saved to disk. This should be done by overwriting the source (not 
    appending).
    
    *Notes*: A keys content (the value) goes until end of line. Any space 
    surroounding the value is at default lost. For best compatibility, the
    names of section and key should consist of alpha (a-z), num (0-9) and the
    underscore only. In general, the names are case insensitiv.

Links:
    * Discussion: [http://www.autohotkey.com/forum/viewtopic.php?t=46226]
    * License: [http://www.gnu.org/licenses/lgpl-3.0.html]

Date:
    2010-02-05

Revision:
    0.15.1
    
Status:
    Stable

Developers:
    * Tuncay, [tuncay.d@gmx.de] (Author)
    * Mystiq (Tester and Co-Author of an important regex)
    * Fry (Tester)

License:
    GNU Lesser General Public License 3.0 or higher [http://www.gnu.org/licenses/lgpl-3.0.html]
    
Category:
    String Manipulation

Type:
    Library

Tested AutoHotkey Version:
    1.0.48.05

Tested Platform:
    2000/XP

Standalone (such as no need for extern file or library):
    Yes

StdLibConform (such as use of prefix and no globals use):
    Yes

Related:
    *Format Specifications (not strictly implemented)*
    * Wikipedia - INI file [http://en.wikipedia.org/wiki/INI_file]
    * Cloanto Implementation of INI File Format [http://www.cloanto.com/specs/ini.html]
    
    *AutoHotkey Commands*
    * IniRead: [http://www.autohotkey.com/docs/commands/IniRead.htm]
    * IniWrite: [http://www.autohotkey.com/docs/commands/IniWrite.htm]
    * IniDelete: [http://www.autohotkey.com/docs/commands/IniDelete.htm]
    
    *Other Community Solutions*
    * INI Library by Titan: [http://www.autohotkey.com/forum/viewtopic.php?t=26141]
    * [Class] IniFile by bmcclure: [http://www.autohotkey.com/forum/viewtopic.php?t=41506]
    * [module] Ini by majkinetor: [http://www.autohotkey.com/forum/viewtopic.php?t=22495]
    * Auto read,load and save by Superfraggle: [http://www.autohotkey.com/forum/viewtopic.php?t=21346]
    * globalsFromIni by Tuncay: [http://www.autohotkey.com/forum/viewtopic.php?t=27928]
    * Read .INI file in one go by Smurth: [http://www.autohotkey.com/forum/viewtopic.php?t=36601]

About: Examples
    
Usage:
    
    (Code)
    value := ini_getValue(ini, "Section", "Key")                    ; <- Get value of a key.
    value := ini_getValue(ini, "", "Key")                           ; <- Get value of first found key.
    key := ini_getKey(ini, "Section", "Key")                        ; <- Get key/value pair.
    section := ini_getSection(ini, "Section")                       ; <- Get full section with all keys.
    
    ini_replaceValue(ini, "Section", "Key", A_Now)                  ; -> Update value of a key.
    ini_replaceKey(ini, "Section", "Key")                           ; -> Delete a key.
    ini_replaceSection(ini, "Section", "[Section1]Key1=0`nKey2=1")  ; -> Replace a section with all its keys.
    
    ini_insertValue(ini, "Section", "Key" ",ListItem")              ; -> Add a value to existing value.
    ini_insertKey(ini, "Section", "Key=" . A_Now)                   ; -> Add a key/value pair.
    ini_insertSection(ini, "Section", "Key1=ini`nKey2=Tuncay")      ; -> Add a section.
    
    keys := ini_getAllKeyNames(ini, "Section")                      ; <- Get a list of all key names.
    sections := ini_getAllSectionNames(ini)                         ; <- Get a list of all section names.
    (End Code)
    
Sample Script:

    Simple script for storing and showing how often it was executed.
    
    (Code)
    #NoEnv
    SendMode Input
    SetWorkingDir %A_ScriptDir%

    ; ----- User Configuration -----
    #Include ini/ini.ahk
    ConfigFilePath := "settings.ini"


    ; ----- Main -----
    IfNotExist, %ConfigFilePath%
        createConfigFile(ConfigFilePath)
        
    FileRead, ini, %ConfigFilePath%
    value := ini_getValue(ini, "Config", "Started")
    value++
    ini_replaceValue(ini, "Config", "Started", value)
    updateConfigFile(ConfigFilePath, ini)

    FileRead, ini, %ConfigFilePath%
    value := ini_getValue(ini, "Config", "Started")
    MsgBox This script was started %value% time/s.


    RETURN ; End of AutoExec-section


    createConfigFile(Path)
    {
        Template =
        (LTrim
        [Config]
        Started=0
        )
        FileAppend, %Template%, %Path%
        Return
    }


    updateConfigFile(Path, ByRef Content)
    {
        FileDelete, %Path%
        FileAppend, %Content%, %Path%
        Return
    }
    (End Code)

About: Functions

Parameters:
    Content         - Content of an ini file (also this can be one section
                        only).
    Section         - Unique name of the section. Some functions support the
                        default empty string "". This leads to look up at 
                        first found section. 
    Key             - Name of the variable under the section.
    Replacement     - New content to use.
    PreserveSpace   - Should be set to 1 if spaces around the value of a key
                        should be saved, otherwise they are lost. The
                        surrounding single or double quotes are also lost.

    The 'get' functions returns the desired contents without touching the 
    variable.
    
    The 'replace' and 'insert' functions changes the desired content directly
    and returns 1 for success and 0 otherwise.
    
    There are some more type of functions and parameters. But these are not listed
    here.

Remarks:
    On success, ErrorLevel is set to '0'. Otherwise ErrorLevel is set to '1' if
    key under desired section is not found.
    
    The functions are not designed to be used in all situations. On rare 
    conditions, the result could be corrupt or not usable. In example, there 
    is no handling of commas inside the key or section names.
    Any "\E" would end the literal sequence and switch back to regex. The
    "\E" sequence is not escaped, because its very uncommon to use backslashes
    inside key and section names. To workaround this, replace at every key or
    section name the "\E" part with "\E\\E\Q":
    
    > Name := "Folder\Edit\Test1"
    > IfInString, Name, \
    > {
    >     StringReplace, Name, Name, \E, \E\\E\Q, All
    > }
    > MsgBox % ini_getValue(ini, "paths", Name)

    This allows us to work with regex, but then at the end it should be closed 
    with "\Q" again.
    > ; Used regex at keyname: "Time.*"
    > value := ini_getValue(ini, "Tip", "\ETime.*\Q")
*/


/*
_______________________________________________________________________________
_______________________________________________________________________________

Section: Parse

About: About

Brief:
    Main functions for getting, setting and updating section or key.
_______________________________________________________________________________
_______________________________________________________________________________
*/


; .............................................................................
; Group: Get
;   Functions for reading data.
; .............................................................................


/*
Func: ini_getValue
    Read and return a value from a key

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section.
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost. The
                        surrounding single or double quotes are also lost.
                        Default is deleting surrounding spaces and quotes.

Returns:
    On success the content of desired key is returned, otherwise an empty string.

Examples:
    > value := ini_getValue(ini, "Tip", "TimeStamp")
    > MsgBox %value%
    *Output:*
    > 20090716194758
*/
ini_getValue(ByRef _Content, _Section, _Key, _PreserveSpace = False)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
    {
         _Section = \[\s*?\Q%_Section%\E\s*?]
    }
    ; Note: The regex of this function was rewritten by Mystiq.
    RegEx = `aiU)(?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*\R\s*\Q%_Key%\E\s*=(.*)(?=\R|$)
/*
    RegEx := "`aiU)"
      . "(?:\R|^)\s*" . _Section . "\s*"         ;-- section
      . "(?:"
      . "\R\s*"                           ;-- empty lines
      . "|\R\s*[\w\s]+\s*=\s*.*?\s*(?=\R)"      ;-- OR other key=value pairs
      . "|\R\s*[;#].*?(?=\R)"                  ;-- OR commented lines
      . ")*"
      . "\R\s*\Q" . _Key . "\E\s*=(.*)(?=\R|$)"   ;-- match
*/
   
    If RegExMatch(_Content, RegEx, Value)
    {
        If Not _PreserveSpace
        {
            Value1 = %Value1% ; Trim spaces.
            FirstChar := SubStr(Value1, 1, 1)
            If (FirstChar = """" AND SubStr(Value1, 0, 1)= """"
                OR FirstChar = "'" AND SubStr(Value1, 0, 1)= "'")
            {
                StringTrimLeft, Value1, Value1, 1
                StringTrimRight, Value1, Value1, 1
            }
        }
        ErrorLevel = 0
    }
    Else
    {
        ErrorLevel = 1
        Value1 =
    }
    Return Value1
}


/*
Func: ini_getKey
    Read and return a complete key with key name and content.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section.

Returns:
    On success the key and value pair in one string is returned, otherwise an empty string.

Examples:
    > key := ini_getKey(ini, "Tip", "TimeStamp")
    > MsgBox %key%
    *Output:*
    > TimeStamp = 20090716194758
*/
ini_getKey(ByRef _Content, _Section, _Key)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
   
    ; Note: The regex of this function was rewritten by Mystiq.
    RegEx = `aiU)(?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*\R(\s*\Q%_Key%\E\s*=.*)(?=\R|$)
    If RegExMatch(_Content, RegEx, Value)
        ErrorLevel = 0
    Else
    {
        ErrorLevel = 1
        Value1 =
    }
    Return Value1
}


/*
Func: ini_getSection
    Read and return a complete section with section name.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. (An enmpty string "" is not
                        working.)

Returns:
    On success the entire section in one string is returned, otherwise an empty string.
    
Examples:
    > section := ini_getSection(ini, "Tip")
    > MsgBox %section% 
    *Output:*
    > [Tip]
    > TimeStamp = 20090716194758
*/
ini_getSection(ByRef _Content, _Section)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    RegEx = `aisUS)^.*(%_Section%\s*\R?.*)(?:\R*\s*(?:\[.*?|\R))?$
    If RegExMatch(_Content, RegEx, Value)
        ErrorLevel = 0
    Else
    {
        ErrorLevel = 1
        Value1 =
    }
    Return Value1
}

/*
Func: ini_getAllValues
    Read and get a new line separated list of all values in one go.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - *Optional* Unique name of the section.
    Count           - *Variable Optional* The number of found values/keys.

Returns:
    On success a comma separated list with all name of keys is returned, 
    otherwise an empty string. If section is specified, only those from that
    section is returned, otherwise from all sections.

Remarks:
    Other than the other getAll-functions list separator, this function uses
    the new line "`n" character instead the comma "," for separating values.
    Also other than the other getValue functions, this does not provide any
    preserveSpaces option, as it allways preserves surrounding spaces and
    quotes.

Examples:
    > values := ini_getAllValues(ini, "Recent File List")
    > MsgBox %values%
    *Output:*
    > F:\testfile.ahk
    > Z:\tempfile.tmp
*/
ini_getAllValues(ByRef _Content, _Section = "", ByRef _count = "")
{
    RegEx = `aisUmS)^(?=.*)(?:\s*\[\s*?.*\s*?]\s*|\s*?.+\s*?=(.*))(?=.*)$
    If (_Section != "")
        Values := RegExReplace(ini_getSection(_Content, _Section), RegEx, "$1`n", Match)
    Else
        Values := RegExReplace(_Content, RegEx, "$1`n", Match)
    If Match
    {
        Values := RegExReplace(Values, "`aS)\R+", "`n")
        ; Workaround, sometimes it catches sections. Whitespaces only should be eliminated also.
        Values := RegExReplace(Values, "`aS)\[.*?]\R+|\R+$|\R+ +$", "") 
        StringReplace, Values, Values, `n, `n, UseErrorLevel
        _count := ErrorLevel ? ErrorLevel : 0
        StringTrimLeft, Values, Values, 1
        ErrorLevel = 0
    }
    Else
    {
        ErrorLevel = 1
        _count = 0
        Values =
    }
    Return Values
}


/*
Func: ini_getAllKeyNames
    Read and get a comma separated list of all key names in one go.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - *Optional* Unique name of the section.
    Count           - *Variable Optional* The number of found keys.

Returns:
    On success a comma separated list with all name of keys is returned, 
    otherwise an empty string. If section is specified, only those from that
    section is returned, otherwise from all sections.
    
Examples:
    > keys := ini_getAllKeyNames(ini, "Recent File List")
    > MsgBox %keys%
    *Output:*
    > File1,File2
*/
ini_getAllKeyNames(ByRef _Content, _Section = "", ByRef _count = "")
{
    RegEx = `aisUmS)^.*(?:\s*\[\s*?.*\s*?]\s*|\s*?(.+)\s*?=.*).*$
    If (_Section != "")
        KeyNames := RegExReplace(ini_getSection(_Content, _Section), RegEx, "$1", Match)
    Else
        KeyNames := RegExReplace(_Content, RegEx, "$1", Match)
    If Match
    {
        KeyNames := RegExReplace(KeyNames, "S)\R+", ",")
        ; Workaround, sometimes it catches sections. Whitespaces only should be eliminated also.
        KeyNames := RegExReplace(KeyNames, "S)\[.*?],+|,+$|,+ +", "") 
        StringReplace, KeyNames, KeyNames, `,, `,, UseErrorLevel
        _count := ErrorLevel ? ErrorLevel : 0
        StringTrimLeft, KeyNames, KeyNames, 1
        ErrorLevel = 0
    }
    Else
    {
        ErrorLevel = 1
        _count = 0
        KeyNames =
    }
    Return KeyNames
}


/*
Func: ini_getAllSectionNames
    Read and get a comma separated list of all section names in one go.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Count           - *Variable Optional* The number of found sections.

Returns:
    On success a comma separated list with all name of sections is returned, 
    otherwise an empty string.
    
Examples:
    > sections := ini_getAllSectionNames(ini)
    > MsgBox %sections%
    *Output:*
    > Tip,Recent File List
*/
ini_getAllSectionNames(ByRef _Content, ByRef _count = "")
{
    RegEx = `aisUmS)^.*(?:\s*\[\s*?(.*)\s*?]\s*|.+=.*).*$
    SectionNames := RegExReplace(_Content, RegEx, "$1", MatchNum)
    If MatchNum
    {
        SectionNames := RegExReplace(SectionNames, "S)\R+", ",", _count)
        ; Workaround, whitespaces only should be eliminated.
        SectionNames := RegExReplace(SectionNames, "S),+ +", "") 
        StringReplace, SectionNames, SectionNames, `,, `,, UseErrorLevel
        _count := ErrorLevel ? ErrorLevel : 0
        _count := _count ? _count : 0
        StringTrimRight, SectionNames, SectionNames, 1
        ErrorLevel = 0
    }
    Else
    {
        ErrorLevel = 1
        _count = 0
        SectionNames =
    }
    Return SectionNames
}


; .............................................................................
; Group: Replace
;   Functions for replacing existing data.
; .............................................................................


/*
Func: ini_replaceValue
    Updates the value of a key.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section. 
    Replacement     - *Optional* New content to use. If not specified, the 
                        content will be replaced with no content. That means
                        it is deleted/set to empty string.
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost. The
                        surrounding single or double quotes are also lost.
                        Default is deleting surrounding spaces.

Returns:
    Returns 1 if key is updated to new value, and 0 otherwise (opposite of 
    ErrorLevel). 
    
Examples:
    > ini_replaceValue(ini, "Tip", "TimeStamp", 2009)
    > value := ini_getValue(ini, "Tip", "TimeStamp")
    > MsgBox %value%
    *Output:*
    > 2009
*/
ini_replaceValue(ByRef _Content, _Section, _Key, _Replacement = "", _PreserveSpace = False)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    If Not _PreserveSpace
    {
        _Replacement = %_Replacement% ; Trim spaces.
        FirstChar := SubStr(_Replacement, 1, 1)
        If (FirstChar = """" AND SubStr(_Replacement, 0, 1)= """"
            OR FirstChar = "'" AND SubStr(_Replacement, 0, 1)= "'")
        {
            StringTrimLeft, _Replacement, _Replacement, 1
            StringTrimRight, _Replacement, _Replacement, 1
        }
    }
    ; Note: The regex of this function was written by Mystiq.
    RegEx = `aiU)((?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*\R\s*\Q%_Key%\E\s*=).*((?=\R|$))
    _Content := RegExReplace(_Content, RegEx, "$1" . _Replacement . "$2", isReplaced, 1)
    If isReplaced
        ErrorLevel = 0
    Else
        ErrorLevel = 1
    Return isReplaced
}


/*
Func: ini_replaceKey
    Changes complete key with its name and value.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section.
    Replacement     - *Optional* New content to use. If not specified, the 
                        content will be replaced with no content. That means
                        it is deleted/set to empty string.
                      The replacement should contain an equality sign.
                      (Expected form: "keyName=value")

Returns:
    Returns 1 if key is updated to new value, and 0 otherwise (opposite of 
    ErrorLevel). 
    
Examples:
    > ini_replaceKey(ini, "Tip", "TimeStamp", "TimeStamp=1980")
    > value := ini_getValue(ini, "Tip", "TimeStamp")
    > MsgBox %value%
    *Output:*
    > 1980
*/
ini_replaceKey(ByRef _Content, _Section, _Key, _Replacement = "")
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    If _Replacement !=
    {
        _Replacement = %_Replacement%
        _Replacement = `n%_Replacement%
    }
    ; Note: The regex of this function was written by Mystiq.
    RegEx = `aiU)((?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*)\R\s*\Q%_Key%\E\s*=.*((?=\R|$))
    _Content := RegExReplace(_Content, RegEx, "$1" . _Replacement . "$2", isReplaced, 1)
    If isReplaced
        ErrorLevel = 0
    Else
        ErrorLevel = 1
    Return isReplaced
}

/*
Func: ini_replaceSection
    Changes complete section with all its keys and contents.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Replacement     - *Optional* New content to use. If not specified, the 
                        content will be replaced with no content. That means
                        it is deleted/set to empty string.
                      The replacement should contain everything what a section
                      contains, like the "[" and "]" before and after section
                      name and all keys with its equality sign and value.
                      (Expected form: "[sectionName]`nkeyName=value")

Returns:
    Returns 1 if key is updated to new value, and 0 otherwise (opposite of 
    ErrorLevel). 
    
Examples:
    > ini_replaceSection(ini, "Tip", "TimeStamp", "[Section1]`nKey1=Hello`nKey2=You!")
    > value := ini_getValue(ini, "Section1", "Key1")
    > MsgBox %value%
    *Output:*
    > Hello
*/
ini_replaceSection(ByRef _Content, _Section, _Replacement = "")
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    RegEx = `aisU)^(\s*?.*)%_Section%\s*\R?.*(\R*\s*(?:\[.*|\R))?$ 
    _Content := RegExReplace(_Content, RegEx, "$1" . _Replacement . "$2", isReplaced, 1)
    If isReplaced
        ErrorLevel = 0
    Else
        ErrorLevel = 1
    Return isReplaced
}


; .............................................................................
; Group: Insert
;   Functions for adding new data.
; .............................................................................


/*
Func: ini_insertValue
    Adds value to the end of existing value of specified key.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. If it is specified to "", 
                        then section is ignored and first found key is get.
    Key             - Name of the variable under the section.
    Value           - Value to be inserted at end of currently existing value.
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost. The
                        surrounding single or double quotes are also lost.
                        Default is deleting surrounding spaces.

Returns:
    Returns 1 if value is inserted, and 0 otherwise (opposite of ErrorLevel).
    
Examples:
    > ini_insertValue(ini, "Recent File List", "File1", ", " . A_ScriptName)
    > value := ini_getValue(ini, "Recent File List", "File1")
    > MsgBox %value%
    *Output:*
    > F:\testfile.ahk, ini.ahk
*/
ini_insertValue(ByRef _Content, _Section, _Key, _Value, _PreserveSpace = False)
{
    If (_Section = "")
        _Section = (?:\[.*])?
    Else
         _Section = \[\s*?\Q%_Section%\E\s*?]
    If Not _PreserveSpace
    {
        _Value = %_Value% ; Trim spaces.
        FirstChar := SubStr(_Value, 1, 1)
        If (FirstChar = """" AND SubStr(_Value, 0, 1)= """"
            OR FirstChar = "'" AND SubStr(_Value, 0, 1)= "'")
        {
            StringTrimLeft, _Value, _Value, 1
            StringTrimRight, _Value, _Value, 1
        }
    }
    ; Note: The regex of this function was written by Mystiq.
    RegEx = S`aiU)((?:\R|^)\s*%_Section%\s*(?:\R\s*|\R\s*.+\s*=\s*.*?\s*(?=\R)|\R\s*[;#].*?(?=\R))*\R\s*\Q%_Key%\E\s*=.*?)((?=\R|$))
    _Content := RegExReplace(_Content, RegEx, "$1" . _Value . "$2", isInserted, 1)
    If isInserted
        ErrorLevel = 0
    Else
        ErrorLevel = 1
    Return isInserted
}


/*
Func: ini_insertKey
    Adds a key pair with its name and value, if key does not already exists.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section. (An enmpty string "" is not
                        working.)
    Key             - Key and value pair splitted by an equality sign.

Returns:
    Returns 1 if key is inserted, and 0 otherwise (opposite of ErrorLevel).

Remarks:
    Currently, it works as a workaround with different function calls instead 
    of one regex call. This makes it slower against the other functions.
    
Examples:
    > ini_insertKey(ini, "Tip", "TimeNow=" . 20090925195317)
    > value := ini_getValue(ini, "Tip", "TimeNow")
    > MsgBox %value%
    *Output:*
    > 20090925195317
*/
ini_insertKey(ByRef _Content, _Section, _Key)
{
    StringLeft, K, _Key, % InStr(_Key, "=") - 1
    sectionCopy := ini_getSection(_Content, _Section)
    keyList := ini_getAllKeyNames(sectionCopy)
    isInserted = 0
    If K Not In %keyList%
    {
        sectionCopy .= "`n" . _Key
        isInserted = 1
    }
    If isInserted
    {
        ini_replaceSection(_Content, _Section, sectionCopy)
        ErrorLevel = 0 
    }
    Else
    {
        ErrorLevel = 1
    } 
    Return isInserted
}

/*
Func: ini_insertSection
    Adds a section and its keys, if section does not exist already.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section to be added and checked if
                        it is already existing.
    Keys            - *Optional* Set of key value pairs. Every key and value 
                        pair should be at its own line divided by a new line 
                        character.

Returns:
    Returns 1 if section and the keys are inserted, and 0 otherwise (opposite 
    of ErrorLevel).
    
Examples:
    > ini_insertSection(ini, "Tip", "Files", "Name1=Programs`nPath1=C:\Program Files")
    > value := ini_getValue(ini, "Files", "Name1")
    > MsgBox %value%
    *Output:*
    > Programs
*/
ini_insertSection(ByRef _Content, _Section, _Keys = "")
{
    RegEx = `aisU)^.*\R*\[\s*?\Q%_Section%\E\s*?]\s*\R+.*$
    If Not RegExMatch(_Content, RegEx)
    {
        _Content = %_Content%`n[%_Section%]`n%_Keys%
        isInserted = 1
        ErrorLevel = 0
    }
    Else
    {
        isInserted = 0
        ErrorLevel = 1
    }
    Return isInserted
}


/*
_______________________________________________________________________________
_______________________________________________________________________________

Section: Additional

About: About

Brief:
    Other functions besides the core ones.
_______________________________________________________________________________
_______________________________________________________________________________

*/

; .............................................................................
; Group: File
;   Related routines about file handling with some comfort.
; .............................................................................

/*
Func: ini_load
    Reads an ini file into a variable and resolves any part of the path.

Parameters:
    Content         - *Variable* On success, the file is loaded into this 
                        variable.
    Path            - *Optional* Source filename or -path to look for. It
                        can contain wildcards. If this is an existing directory 
                        (or contains backslash at the end), then default 
                        filename is appended. Default filename is ScriptName 
                        with ".ini" extension (in example "script.ini").
                        Relative Pathes are solved to current WorkingDir. 
                        Every part of the path (like filename and -extension) 
                        are optional. Default extension is logically ".ini". 
                        Binary files are not loaded. Empty string is resolved 
                        to "ScriptPathNoExt + .ini".
    convertNewLine  - *Optional* If this is true, all "`r`n" (CRLF) new line
                        sequence of files content will be replaced with "`n" 
                        (LF) only. Normally this is not necessary.

Returns:
    The resolved full path which was searched for. If file exists, the full 
    path with correct case from the disk is get.

Remarks:
    This function is not necessary to work with the ini-library. In fact, in 
    the heart, it does nothing else than FileRead. The filled variable is an
    ordinary string. You can work with custom functions other from this library
    on these variables, as if you would do allways.
    
    If file is not found or content is binary, or at any other reason ErrorLevel
    is set to 1 and Content is set to "" (empty).

Examples:
    > ; Load content of default file into variable "ini".
    > path := ini_load(ini)
    > MsgBox %path%
    *Output:*
    > E:\Tuncay\AutoHotkey\scriptname.ini
*/
ini_load(ByRef _Content, _Path = "", _convertNewLine = false)
{
    ini_buildPath(_Path)
    error := true ; If file is found next, then its set to false.
    Loop, %_Path%, 0, 0
    {
        _Path := A_LoopFileLongPath
        error := false
        Break
    }    
    If (error = false)
    {
        FileRead, _Content, %_Path%
        If (ErrorLevel)
        {
            error := true
        }
        Else
        {
            FileGetSize, fileSize, %_Path%
            If (fileSize != StrLen(_Content))
            {
                error := true
            }
        }
    }
    If (error)
    {
        _Content := ""
    }
    Else If (_convertNewLine)
    {
        StringReplace, _Content, _Content, `r`n, `n, All
    }
    ErrorLevel := error
    Return _Path
}


/*
Func: ini_save
    Writes an ini file from variable to disk.

Parameters:
    Content         - *Variable* Ini content to save at given path on disk.
    Path            - *Optional* Source filename or -path to look for. It
                        can contain wildcards. If this is an existing directory 
                        (or contains backslash at the end), then default 
                        filename is appended. Default filename is ScriptName 
                        with ".ini" extension (in example "script.ini").
                        Relative Pathes are solved to current WorkingDir. 
                        Every part of the path (like filename and -extension) 
                        are optional. Default extension is logically ".ini". 
                        Binary files are not loaded. Empty string is resolved 
                        to "ScriptPathNoExt + .ini".
    convertNewLine  - *Optional* If this is true, all "`n" (LF) new line
                        sequence of files content will be replaced with "`r`n"
                        (CRLF). Normally, Windows default new line sequence is
                        "`r`n". (Source is not changed with this option.)
    overwrite       - *Optional* If this mode is enabled (true at default), 
                        the source file will be updated. Otherwise, the
                        file is saved to disk only if source does not exist
                        already.

Returns:
    The resolved full path which was searched for.

Remarks:
    If overwrite mode is enabled and file could not be deleted, then ErrorLevel 
    is set to 1. Otherwise, if overwriting an existing file is not allowed 
    (overwrite = false) and file is existing, then ErrorLevel will be set to 1 
    also.

Examples:
    > ; Write and update content of ini variable to default file.
    > path := ini_save(ini)
    > MsgBox %path%
    *Output:*
    > E:\Tuncay\AutoHotkey\scriptname.ini
*/
ini_save(ByRef _Content, _Path = "", _convertNewLine = true, _overwrite = true)
{
    ini_buildPath(_Path)
    error := false
    If (_overwrite)
    {
        Loop, %_Path%, 0, 0
        {
            _Path := A_LoopFileLongPath
            Break
        }    
        If FileExist(_Path)
        {
            FileDelete, %_Path%
            If (ErrorLevel)
            {
                error := true
            }
        }
    }
    Else If FileExist(_Path)
    {
        error := true
    }
    If (error = false)
    {
        If (_convertNewLine)
        {
            FileAppend, %_Content%, %_Path%
        }
        Else
        {
            FileAppend, %_Content%, *%_Path%
        }
        If (ErrorLevel)
        {
            error := true
        }
    }
    ErrorLevel := error
    Return _Path
}

; An internally used function, made not for public.
ini_buildPath(ByRef _path)
{
    ; Set to default wildcard if filename or exension are not set.
    If (_Path = "")
    {
        _Path := RegExReplace(A_ScriptFullPath, "S)\..*?$") . ".ini"
    }
    Else If (SubStr(_Path, 0, 1) = "\")
    {
        _Path .= RegExReplace(A_ScriptName, "S)\..*?$") . ".ini"
    }
    Else
    {
        If (InStr(FileExist(_Path), "D"))
        {
            ; If the current path is a directory, then add default file pattern to the directory.
            _Path .= "\" . RegExReplace(A_ScriptName, "S)\..*?$") . ".ini"
        }
        Else
        {
            ; Check all parts of path and use defaults, if any part is not specified.
            SplitPath, _Path,, fileDir, fileExtension, fileNameNoExt
            If (fileDir = "")
            {
                fileDir := A_WorkingDir
            }
            If (fileExtension = "")
            {
                fileExtension := "ini"
            }
            If (fileNameNoExt = "")
            {
                fileNameNoExt := RegExReplace(A_ScriptName, "S)\..*?$")
            }
            _Path := fileDir . "\" . fileNameNoExt . "." . fileExtension
        }
    }
    Return 0
}

; .............................................................................
; Group: Edit
;   These manipulates the whole ini structure (or an extracted section only).
; .............................................................................

/*
Func: ini_repair
    Repair and build an ini from scratch. Leave out comments and trim unneeded 
    whitespaces.

Parameters:
    Content         - Content of an ini file (also this can be one 
                        section only).
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost. 
                        Default is deleting surrounding spaces.
    CommentSymbols  - *Optional* List of characters which are should be treated 
                        as comment symbols. Every single character in list is 
                        a symbol. Default are ";" and "#", in example defined 
                        as ";#". 
    LineDelim       - *Optional* A sequence of characters which should be the
                        delimiter as the line end symbol. Default is "`n", a
                        new line.

Returns:
    The new formatted ini string with trimmed whitespaces and without comments.

Remarks:
    Other than the most other functions here, the ini Content variable is not
    a byref and will not manipulated directly. The return value is the new ini.
    The LineDelim option can be leaved as is. Internally all commands of 
    AutoHotkey like MsgBox or FileAppend are working correctly with this.
    
    What it does is, building a new ini content string from an existing one.
    The reason to use this function is, if anyone have problems with the 
    source ini because of whitespaces or comments and formatting. The new
    resulting ini is consistently reduced to standard ini format (at least,
    it should).
    Dublicate key entries in same section are merged into one key. The last
    instance overwrites just the one before.

Examples:
    (code)
    ini =
    (
    
        [ malformed section  ]
city   =  Berlin'
whatever='this ; is nasty'

     [bad]
cat    =     'miao'

    )
    ini := ini_repair(ini, true)
    MsgBox %ini%
    (end)

    *Output:*
    (code)
[malformed section]
city=  Berlin'
whatever='this 
[bad]
cat=     'miao'
    (end)
*/
ini_repair(_Content, _PreserveSpace = False, _CommentSymbols = ";#", _LineDelim = "`n")
{
    If (_CommentSymbols != "")
    {
        regex = `aiUSm)(?:\R\s*|(s*|\t*))[%_CommentSymbols%].*?(?=\R)
        _Content := RegExReplace(_Content, regex, "$1")
    }
    Loop, Parse, _Content, `n, `r
    {
        If (RegExMatch(A_LoopField, "`aiSm)\[\s*(.+?)\s*]", Match))
        {
            newIni .= _LineDelim . "[" . Match1 . "]"
            section := Match1
            KeyList := ""
        }
        Else If (RegExMatch(A_LoopField, "`aiSm)\s*(\b(?:.+?|\s?)\b)\s*=(.*)", Match))
        {
            If (_PreserveSpace = false)
            {
                Match2 = %Match2%
            }
            If Match1 Not in %KeyList% ; Disallowes dublicate.
            {
                KeyList .= "," . Match1
            }
            Else
            {
                ; As a workaround it should be just deleted, because if set 
                ; here the surrounding whitespaces are lost.
                ini_replaceKey(newIni, section, Match1, "")
            }
            newIni .= _LineDelim . Match1 . "=" . Match2
        }
    }
    StringReplace, newIni, newIni, %_LineDelim%
    If (newIni != "")
    {
        ErrorLevel := 0
    }
    Else
    {
        ErrorLevel := 1
    }
    Return newIni
}


/*
Func: ini_mergeKeys
    Merge two ini sources into first one. Adds new sections and keys and 
    processess existing keys.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only). This is the destination where new 
                        sections and keys are added into.
    source          - *Variable* This is also an ini content from which to 
                        retrieve the new data. These will be added into Content 
                        variable.
    updateMode      - *Optional* Defines how existing keys should be processed.
                        Default is ('1') overwriting last instance with newest 
                        one. 

        updateMode: '1' - ("Default") Replace existng key with newest/last one
                    from source.
        
        updateMode: '2' - Append everything to existing key in Content.
        
        updateMode: '3' - Replace only if source is higher than destination key
                    in Content.
        
        updateMode: '4' - Exclude keys in Content, which exists in both sources.
        
        updateMode: '0' - ("Or any other value") Does not manipulate existing keys
                    in Content, leaving them in their orginal state. Just add 
                    new unknown keys to Content.
                        
Returns:
    Returns the steps taken to manipulate the destination Content. Every added or 
    manipulated key and section are rising by 1 the return value. 0 if nothing is
    changed.

Remarks:    
    ErrorLevel is set to '1' if something is changed in Content, '0' otherwise.
    
    The Content variable is updated with the content from source. This means, new
    sections and keys are added allways. In a conflict where same key was found 
    in source again, in case it is existing in Content already, then the variable
    updateMode defines how they should be processed. Default is, to use last found
    key.

Examples:
    (code)
    ini1=
    (LTrim
        [vasara]
        tuni=1232
        edg=94545
        k=1
    )
    ini2=
    (LTrim
        [vasara]
        tuni=9999
        c=
        edg=5
        [taitos]
        isa=17
    )
    ini_mergeKeys(ini1, ini2)
    MsgBox %ini1%
    (end)
    *Output:*
    (code)
        [vasara]
        tuni=9999
        edg=5
        k1
        c=
        [taitos]
        isa=17
    (end)
*/
ini_mergeKeys(ByRef _Content, ByRef _source, _updateMode = 1)
{
    steps := 0
    laststep := 0
    destSectionNames := ini_getAllSectionNames(_Content), sourceSectionNames := ini_getAllSectionNames(_source)
    Loop, Parse, sourceSectionNames, `,
    {
        sectionName := A_LoopField
        sourceSection := ini_getSection(_source, sectionName)
        If sectionName Not In %destSectionNames%
        {
            _Content .= "`n" . sourceSection
            steps++
            Continue
        }
        Else
        {
            destSection := ini_getSection(_Content, sectionName), destKeyNames := ini_getAllKeyNames(destSection), sourceKeyNames := ini_getAllKeyNames(sourceSection)
            Loop, Parse, sourceKeyNames, `,
            {
                keyName := A_LoopField
                If keyName Not In %destKeyNames%
                {
                    destSection .= "`n" . ini_getKey(sourceSection, sectionName, keyName)
                    steps++
                    Continue
                }
                Else If (_updateMode = 1)
                {
                    ini_replaceValue(destSection, sectionName, keyName, ini_getValue(sourceSection, sectionName, keyName))
                    steps++
                }
                Else If (_updateMode = 2)
                {
                    ini_replaceValue(destSection, sectionName, keyName, ini_getValue(destSection, sectionName, keyName) . ini_getValue(sourceSection, sectionName, keyName))
                    steps++
                }
                Else If (_updateMode = 3)
                {
                    If ((sourceValue := ini_getValue(sourceSection, sectionName, keyName)) > ini_getValue(destSection, sectionName, keyName))
                    {
                        ini_replaceValue(destSection, sectionName, keyName, sourceValue)
                        steps++
                    }
                }
                Else If (_updateMode = 4)
                {
                    ini_replaceKey(destSection, sectionName, keyName, "")
                    steps++
                }
            }
            If (laststep != steps)
            {
                laststep := steps
                ini_replaceSection(_Content, sectionName, destSection)
            }
        }
    }
    If (steps > 0)
    {
        ErrorLevel := 0
    }
    Else
    {
        ErrorLevel := 1
    }
    Return steps
}


; .............................................................................
; Group: Convert
;   Export and import functions to convert ini structure.
; .............................................................................


/*
Func: ini_exportToGlobals
    Creates global variables from the ini structure.

Parameters:
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    CreateIndexVars - *Optional* If this is set to 'true', some additional 
                        variables are created. These are variables for indexed
                        access of sections and keys. The scheme how the variables
                        named are described below under Remarks.
    Prefix          - *Optional* This is the leading part of all created variable
                        names. (Default: "ini")
    Seperator       - *Optional* This is part of all created variable names. It
                        is added between every section and key part and the 
                        leading part to separate them. (Default: "_")
    SectionSpaces   - *Optional* Every space inside section name will be replaced
                        by this character or string. This is needed for creating
                        AutoHotkey variables, which cannot hold spaces at name.
                        Default is to delete any space with empty value: "".
    PreserveSpace   - *Optional* Should be set to 1 if spaces around the value 
                        of a key should be saved, otherwise they are lost.
                        Surrounding quotes (" or ') are also lost, if not set
                        to 1. Default is deleting surrounding spaces and quotes.

Returns:
    Gets count of all created keys (attention, keys in sense of ini keys, not variables). 

Remarks:
    Creates global variables from ini source. The scheme for building the variables is
    following: 
    
    > Prefix  +  Seperator  +  SectionName  + Seperator  +  KeyName
    >   ini   +      _      +      Tip      +     _      + TimeStamp
    > --------------------------------------------------------------
    > ini_Tip_TimeStamp := "20090716194758"
    
    Standard prefix to every variable is "ini" and all parts are delimited by the 
    separator "_". The SectionSpaces parameter deletes at default every space from 
    name of section, because spaces inside ahk variable names are not allowed.

CreateIndexVars:    
    These variables are created additionally to the other variables, if option 
    CreateIndexVars is set to true (or 1 or any other value evaluating to true).
    
    Scheme for sections
    > Prefix  +  Seperator  +  Index
    >   ini   +      _      +    1
    > ------------------------------
    > ini_1 := "Tip"
    
    Scheme for keys
    > Prefix  +  Seperator  +  SectionName  + Index
    >   ini   +      _      +      Tip      +   1
    > ---------------------------------------------
    > ini_Tip1 := "20090716194758"
    
    The index "0" contains number of all elements.

Examples:
    > ini_exportToGlobals(ini, 0)
    > ListVars
    > Msgbox % ini_RecentFileList_File2
    *Output:*
    > Z:\tempfile.tmp
    
    The example would create all these variables with following 
    values:
    > ini_RecentFileList_File1 := "F:\testfile.ahk"
    > ini_RecentFileList_File2 := "Z:\tempfile.tmp"
    > ini_Tip_TimeStamp := "20090716194758"
    
    These variables would be created in addition to the above ones, if 
    CreateIndexVars option was set to true:
    > ini_0 := "2"
    > ini_1 := "Tip"
    > ini_2 := "RecentFileList"
    > ini_RecentFileList0 := "2"
    > ini_RecentFileList1 := "File1"
    > ini_RecentFileList2 := "File2"
    > ini_Tip0 := "1"
    > ini_Tip1 := "TimeStamp"
*/
ini_exportToGlobals(ByRef _Content, _CreateIndexVars = false, _Prefix = "ini", _Seperator = "_", _SectionSpaces = "", _PreserveSpace = False)
{
    Global
    Local secCount := 0, keyCount := 0, i := 0, Section, Section1, currSection, Pair, Pair1, Pair2, FirstChar
    If (_Prefix != "")
    {
        _Prefix .= _Seperator
    }
    Loop, Parse, _Content, `n, `r
    {
        If (Not RegExMatch(A_LoopField, "`aiSm)\[\s*(.+?)\s*]", Section))
        {
            If (RegExMatch(A_LoopField, "`aiSm)\s*(\b(?:.+?|\s?)\b)\s*=(.*)", Pair))
            {
                If (!_PreserveSpace)
                {
                    StringReplace, Pair1, Pair1, %A_Space%, , All
                    Pair2 = %Pair2% ; Trim spaces.
                    FirstChar := SubStr(Pair2, 1, 1)
                    If (FirstChar = """" AND SubStr(Pair2, 0, 1)= """"
                        OR FirstChar = "'" AND SubStr(Pair2, 0, 1)= "'")
                    {
                        StringTrimLeft, Pair2, Pair2, 1
                        StringTrimRight, Pair2, Pair2, 1
                    }
                }
                StringReplace, currSection, currSection, %A_Space%, %_SectionSpaces%, All
                %_Prefix%%currSection%%_Seperator%%Pair1% := Pair2 ; ini_section_key := value
                keyCount++
                If (_CreateIndexVars)
                {
                    %_Prefix%%currSection%0++
                    i := %_Prefix%%currSection%0
                    %_Prefix%%currSection%%i% := Pair1
                }
            }
        }
        Else
        {
            currSection := Section1
            If (_CreateIndexVars)
            {
                StringReplace, currSection, currSection, %A_Space%, %_SectionSpaces%, All
                secCount++
                %_Prefix%%secCount% := currSection
            }
        }
    }
    If (_CreateIndexVars)
    {
        %_Prefix%0 := secCount
    }
    If (secCount = 0 AND keyCount = 0)
    {
        ErrorLevel = 1
    }
    Else
    {
        ErrorLevel = 0
    }
    Return keyCount
}


/*
_______________________________________________________________________________
_______________________________________________________________________________

Section: Aliases

About: About

Brief:
    Function wrappers to work with existing commands or functions via "Basic 
    ini string functions". They try to mimic the interface for look and feel of
    original. This can help to migrate others to this library with lesser
    possible work.
_______________________________________________________________________________
_______________________________________________________________________________
*/

; .............................................................................
; Group: AutoHotkey
;   Built-in Commands of AutoHotkey.
; .............................................................................

/*
Func: Ini_Read
    Reads a value. Alias of IniRead.

Parameters:
    OutputVar       - *Variable* The name of the variable in which to store the retrieved 
                        value. If the value cannot be retrieved, the variable 
                        is set to the value indicated by the Default parameter 
                        (described below). 
    Content         - *Variable* Content of an ini file (also this can be one 
                        section only).
    Section         - Unique name of the section.
    Key             - Name of the variable under the section.
    Default         - *Optional* The value to store in OutputVar if the 
                        requested key is not found. If omitted, it defaults to 
                        the word ERROR.

Returns:
    Does not return anything.
    
Remarks:
    ErrorLevel is not set by this function (backed up and restored).

    In Ahk you had to specify the filename of the ini file. Here you need to 
    give the content, instead of.
    Compared to "Basic ini string functions" the parameter section is not 
    allowed to be set to an empty string anymore.

Related:
    * IniRead: [http://www.autohotkey.com/docs/commands/IniRead.htm]
    
Examples:
    > FileRead, ini, C:\Temp\myfile.ini
    > Ini_Read(OutputVar, ini, "section2", "key")
    > MsgBox %OutputVar%
*/
Ini_Read(ByRef _OutputVar, ByRef _Content, _Section, _Key, _Default = "ERROR")
{
    If (_Section != "")
    {
        BackupErrorLevel := ErrorLevel
        _OutputVar := ini_getValue(_Content, _Section, _Key)
        If ErrorLevel
        {
            _OutputVar := _Default
        }
        ErrorLevel := BackupErrorLevel
    }
    Else
    {
        _OutputVar := _Default
    }
    Return 
}


/*
Func: Ini_Write
    Writes a value. Alias of IniWrite.

Parameters:
    Value           - The string or number that will be written to the right 
                        of Key's equal sign (=).
    Content         - *Variable* Content of an ini file .
    Section         - Unique name of the section.
    Key             - Name of the variable under the section.

Returns:
    Does not return anything.
    
Remarks:
    ErrorLevel is set to 1 if there was a problem or 0 otherwise.

    In Ahk you had to specify the filename of the ini file. Here you need to 
    give the content, instead of.
    Compared to "Basic ini string functions" the parameter section is not 
    allowed to be set to an empty string anymore.

Related:
    * IniWrite: [http://www.autohotkey.com/docs/commands/IniWrite.htm]
    
Examples:
    > FileRead, ini, C:\Temp\myfile.ini
    > Ini_Write("this is a new value", ini, "section2", "key")
    > FileDelete, C:\Temp\myfile.ini
    > FileAppend, %ini%, C:\Temp\myfile.ini
*/
Ini_Write(_Value, ByRef _Content, _Section, _Key)
{
    If (_Section = "")
    {
        ErrorLevel = 1
    }
    Else
    {
        ini_replaceValue(_Content, _Section, _Key, _Value)
    }
    Return 
}


/*
Func: Ini_Delete
    Deletes a value or section. Alias of IniDelete.

Parameters:
    Content         - *Variable* Content of an ini file.
    Section         - Unique name of the section.
    Key             - *Optional* Name of the variable under the section.

Returns:
    Does not return anything.
    
Remarks:
    ErrorLevel is set to 1 if there was a problem or 0 otherwise.

    In Ahk you had to specify the filename of the ini file. Here you need to 
    give the content, instead of.
    Compared to "Basic ini string functions" the parameter section is not 
    allowed to be set to an empty string anymore.

Related:
    * IniDelete: [http://www.autohotkey.com/docs/commands/IniDelete.htm]
    
Examples:
    > FileRead, ini, C:\Temp\myfile.ini
    > Ini_Delete(ini, "section2", "key")
    > FileDelete, C:\Temp\myfile.ini
    > FileAppend, %ini%, C:\Temp\myfile.ini
*/
Ini_Delete(ByRef _Content, _Section, _Key = "")
{
    If (_Section = "")
    {
        ErrorLevel = 1
    }
    Else
    {
        If (_Key != "")
        {
            ini_replaceKey(_Content, _Section, _Key, "")
        }
        Else
        {
            ini_replaceSection(_Content, _Section, "")
        }
    }
    Return 
}
