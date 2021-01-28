/*
Title: Spell v2.0 (Preview)

Group: Introduction

    The Spell library is a wrapper for the Hunspell API with additional
    functions to support custom libraries.

Group: Compatibility

    This library was designed to run on most versions of Windows (Windows XP+)
    and on all versions of AutoHotkey including AutoHotkey Basic (ANSI) and
    AutoHotkey v1.1+ (ANSI and Unicode, 32-bit and 64-bit).

Group: Credit:

    Credit and thanks to *majkinetor* for developing the original Spell library.
    Thanks to *Prodigy* (AutoIt forum) for the idea to use the NHunspell API for
    version 2.0 of this library and for guidance to the syntax of some of API
    functions.  Thanks to *ProgAndy* (AutoIt German forum) for providing a copy
    of the NHunspell DLL files.

Group: Functions:
*/

;------------------------------
;
; Function: Spell_Add
;
; Description:
;
;   Add a word or list or words to the dictionary which is/are valid until the
;   spell object is destroyed.
;
; Parameters:
;
;   hSpell - Variable that contains the current dictionary information.
;
;   p_Word - Word or list of words (delimited by a LF (line feed) or CR+LF
;       (carriage return and line feed)) to add to the dictionary.
;
;   p_AddCase - [Optional] See the *Add Case* section for more information.
;
; Add Case:
;
;   Preface: For the most part, the affix file (Ex: en_US.aff) contains the
;   rules that determine how words in a dictionary are treated.  What may be
;   true for words in one dictionary (Ex: en_US) may not be true for words in
;   other dictionaries (Ex: en_GB).  The p_AddCase parameter was added to deal
;   with possible shortcomings in all dictionaries but it has only been tested
;   using the en_US dictionary files.  Be sure to test thoroughly.
;
;   Mixed case words (Ex: "Kevin" or "KevinWasHere") added to the dictionary may
;   be treated as case sensitive.  Under most circumstances this is the desired
;   behavior.  However, there are certain words or group of words that are
;   commonly (and validly) used in other forms.  One example is a list of
;   commands and/or key words for a programming language.  For many programming
;   languages, the commands and/or key words are not case sensitive, so adding
;   different variations of the command/key word to the dictionary might reduce
;   the number of "word not found" errors when running a spell check on the
;   source code.
;
;   The p_AddCase parameter will add up to 3 additional words to the dictionary
;   for every word found in the p_Word parameter.  The following options are
;   available.
;
;   U - Add an all uppercase version of the word(s) to the dictionary.  Ex:
;       "KEVIN".  Note: Most dictionaries automatically recognize an all
;       uppercase version of every word so this option is usually superfluous.
;       Be sure to test your dictionary to be sure.
;
;   L - Add an all lowercase version of the word(s) to the dictionary.  Ex:
;       "kevin".  Observation: For the English (US) dictionary, this option
;       provides the most value out of all the options.  I suspect this may be
;       true for other dictionaries.
;
;   T - Add a title case (first letter is uppercase, all others are lowercase)
;       version of the word(s) to the dictionary.  Ex: "Kevin".  Note:  Most
;       dictionaries automatically recognize a title case version of a word if a
;       lowercase version of the word exists so this option may be unnecessary
;       if the word is already all lowercase or if the "L" option is specified.  Be sure to test your dictionary to be sure.
;
;   A - Add an all uppercase, an all lowercase, and a title case version of the
;       word(s) to the dictionary.  This option is the same as "ULT".
;
;   To use more than one option, just add it next to the previous option.  For
;   example, "UL".
;
;   The additional word will not be added if the original word is already in
;   that case.  For example, if the original word is already all lowercase (Ex:
;   "kevin"), then the all lowercase version of the word is not added.
;
;   Important: This function uses the AutoHotkey
;   <StringUpper at http://www.autohotkey.com/docs/commands/StringLower.htm> and
;   <StringLower at http://www.autohotkey.com/docs/commands/StringLower.htm>
;   commands to convert the word(s) to uppercase, lowercase, and title case.
;   The rules and limitations of these commands could affect the results for
;   some words.
;
; Returns:
;
;   The number of words added to the dictionary.
;
; Calls To Other Functions:
;
; * <Spell_ANSI2Unicode>
;
; Remarks:
;
;   The performance of this function is excellent under almost all
;   circumstances.  However, when adding a very large number of words (>2000?),
;   performance can be improved by setting
;   *<SetBatchLines at http://ahkscript.org/docs/commands/SetBatchLines.htm>*
;   to a higher value before calling this function.  For example:
;
;       (start code)
;       SetBatchLines 100ms
;       Spell_Add(hSpell,...)
;       SetBatchLines 10ms  ;-- This is the system default
;       (end)
;
;-------------------------------------------------------------------------------
Spell_Add(ByRef hSpell,p_Word,p_AddCase="")
    {
    ;-- Initialize
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"
    StrType:=A_IsUnicode ? "Str":A_PtrSize ? "WStr":"UInt"
    l_Count:=0

    ;-- Parameters
    StringUpper p_AddCase,p_AddCase
        ;-- Just in case StringCaseSense is On

    ;-- Process p_Word
    Loop Parse,p_Word,`n,`r
        {
        ;-- Drop null/blank words
        if A_LoopField is Space
            Continue

        ;-- Assign and AutoTrim
        ;   Note: This variable only contains a single word initially but
        ;   additional words can be added later.
        l_ListOfWords=%A_LoopField%

        ;-- Add case version(s) of the word?
        if p_AddCase
            {
            l_OriginalWord:=l_ListOfWords
            if p_AddCase Contains A,U
                {
                StringUpper l_UCWord,l_OriginalWord
                if not (l_OriginalWord==l_UCWord)
                    l_ListOfWords.="`n" . l_UCWord
                }

            if p_AddCase Contains A,L
                {
                StringLower l_LCWord,l_OriginalWord
                if not (l_OriginalWord==l_LCWord)
                    l_ListOfWords.="`n" . l_LCWord
                }

            if p_AddCase Contains A,T
                {
                StringUpper l_TCWord,l_OriginalWord,T
                if not (l_OriginalWord==l_TCWord)
                    l_ListOfWords.="`n" . l_TCWord
                }
            }

        ;-- Add 'em
        Loop Parse,l_ListOfWords,`n
            {
            l_Count++
            l_Word:=A_LoopField
            DllCall(NumGet(hSpell,16)
                ,PtrType,NumGet(hSpell,0)
                ,StrType,A_PtrSize ? l_Word:Spell_ANSI2Unicode(&l_Word,wString)
                ,"Cdecl")
            }
        }

    Return l_Count
    }


;------------------------------
;
; Function: Spell_AddCustom
;
; Description:
;
;   Add a word to a custom dictionary file.
;
; Parameters:
;
;   p_CustomDic - Path to a custom dictionary file.
;
;   p_Word - Word or list of words (delimited by a LF (line feed) or CR+LF
;       (carriage return and line feed)) to add.
;
;   p_EOL - End-Of-Line (EOL) characters. [Optional] The default is CR+LF.
;
; Returns:
;
;   The number of words loaded to the custom dictionary file if successful
;   (can be 0) or -1 if there was an error (custom dictionary file not found or
;   error writing to the custom dictionary file).
;
; Remarks:
;
; * This function does _not_ update the active dictionary.  If needed, call
;   <Spell_Add> to add the word(s) to the active dictionary.
;
; * The custom dictionary file must already exist, even if it's empty.  The file
;   must be in a Unix (EOL=LF) or DOS/Windows (EOL=CR+LF) format.  This function
;   will add a word followed by the characters in p_EOL parameter
;   (default=CR+LR) to the end of the file.  If editing the custom dictionary
;   file manually, make sure there is a LF or CR+LF after the last word.
;
; * This function (via the
;   *<FileAppend at http://ahkscript.org/docs/commands/FileAppend.htm>* command)
;   uses the default file encoding which is the system default ANSI code page.
;   For AutoHotkey v1.1+, this default can be changed by calling the
;   *<FileEncoding at http://ahkscript.org/docs/commands/FileEncoding.htm>*
;   command any time before calling this function.
;
;-------------------------------------------------------------------------------
Spell_AddCustom(p_CustomDic,p_Word,p_EOL="`r`n")
    {
    IfNotExist %p_CustomDic%
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Custom dictionary file not found: %p_CustomDic%
           )

        Return -1
        }

    ;-- Initialize
    l_Count:=0

    ;-- Process p_Word
    Loop Parse,p_Word,`n,`r
        {
        ;-- Drop null/blank words
        if A_LoopField is Space
            Continue

        ;-- Assign and AutoTrim
        l_Word=%A_LoopField%

        ;-- Count it
        l_Count++

        ;-- Save it
        FileAppend % l_Word . p_EOL,*%p_CustomDic%
        if ErrorLevel
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Unable to add word to custom dictionary file: %p_CustomDic%
               )

            Return -1
            }
        }

    Return l_Count
    }


;-----------------------------
;
; Function: Spell_ANSI2Unicode
;
; Description:
;
;   Maps a character string (ANSI) to a UTF-16 (wide character) string.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   lpMultiByteStr - Address to a character string (ANSI).
;
;   WideCharStr - Variable to store the UTF-16 (wide character) string.
;
;-------------------------------------------------------------------------------
Spell_ANSI2Unicode(lpMultiByteStr,ByRef WideCharStr)
    {
    Static CP_ACP:=0    ;-- The system default Windows ANSI code page.

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Collect size, in characters
    nSize:=DllCall("MultiByteToWideChar"
            ,"UInt",CP_ACP
                ;-- CodePage [UINT,in]
            ,"UInt",0
                ;-- dwFlags [DWORD,in]
            ,PtrType,lpMultiByteStr
                ;-- lpMultiByteStr [LPCSTR,in].  Pointer to the character
                ;   string to convert.
            ,"Int",-1
                ;-- cbMultiByte [Int,in].  Size, in bytes, of the string
                ;   indicated by the lpMultiByteStr parameter.  -1=Process the
                ;   entire string, including terminating null.
            ,PtrType,0
                ;-- lpWideCharStr [LPWSTR,out].  Pointer to a buffer that
                ;   receives the converted string.  Not used here.
            ,"Int",0)
                ;-- cchWideChar [Int,in].  Size, in characters, of the buffer
                ;   indicated by lpWideCharStr.  If 0, the function returns the
                ;   required buffer size, in characters, including any
                ;   terminating null character.

    ;-- Convert
    VarSetCapacity(WideCharStr,nSize*2,0)  ;-- Size in bytes
    DllCall("MultiByteToWideChar"
            ,"UInt",CP_ACP
                ;-- CodePage [UINT,in]
            ,"UInt",0
                ;-- dwFlags [DWORD,in]
            ,PtrType,lpMultiByteStr
                ;-- lpMultiByteStr [LPCSTR,in].  Pointer to the character
                ;   string to convert.
            ,"Int",nSize
                ;-- cbMultiByte [Int,in].  Size, in bytes, of the string
                ;   indicated by the lpMultiByteStr parameter.
            ,"Str",WideCharStr
                ;-- lpWideCharStr [LPWSTR,out].  Pointer to a buffer that
                ;   receives the converted string.
            ,"Int",nSize)
                ;-- cchWideChar [Int,in].  Size, in characters, of the buffer
                ;   indicated by lpWideCharStr.

    Return &WideCharStr
    }


;------------------------------
;
; Function: Spell_Init
;
; Description:
;
;   Initialize Hunspell.
;
; Parameters:
;
;   hSpell - Variable that will contain the current dictionary information.
;
;   p_Aff - Path to affix file.
;
;   p_Dic - Path to dictionary file.
;
;   DLLPath - Path to the folder of the Hunspell DLL files (Ex: "lib\") or the
;       full path and file name of the Hunspell DLL file (Ex:
;       "lib\Hunspellx86.dll") . [Optional]  If null or not specified, the
;       Hunspell DLL files must be located in the local folder or in the path.
;
; Returns:
;
;   TRUE if initialization was successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Spell_ANSI2Unicode>
;
; Remarks:
;
;   hSpell map :
;
;       (begin code)
;       Offset  Description
;       ------  -----------
;
;          0    Handle to the spell object
;          8    Handle to the Hunspell DLL library module
;         16    Address to the HunspellAdd function
;         24    Address to the HunspellAddWithAffix function
;         32    Address to the HunspellAnalyze function
;         40    Address to the HunspellFree function
;         48    Address to the HunspellGenerate function
;         56    Address to the HunspellInit function
;         64    Address to the HunspellSpell function
;         72    Address to the HunspellStem function
;         80    Address to the HunspellSuggest function
;         88    Address to the HyphenFree function
;         96    Address to the HyphenHyphenate function
;        104    Address to the HyphenInit function
;        112    Address to the MyThesFree function
;        120    Address to the MyThesInit function
;        128    Address to the MyThesLookup function
;        ---
;        136    Total bytes
;       (end code)
;
;   This map is the same for all versions of AutoHotkey.  Addresses and handles
;   are 4 bytes for the 32-bit versions of AutoHotkey and 8 bytes for the 64-bit
;   version.  All of the API functions are mapped but only key spell functions
;   are used by the Spell library.
;
;   As the name implies, this function should be called first.  If key
;   dictionary or library files are not found, this function will display a
;   strong error message and will return FALSE.  If this function returns FALSE,
;   _do not_ call any other library function.  Calling other library functions
;   when Hunspell has not been initialized may (read: will) cause AutoHotkey to
;   crash.
;
;-------------------------------------------------------------------------------
Spell_Init(ByRef hSpell,p_Aff,p_Dic,DLLPath="")
    {
    ;-- Initialize
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"
    VarSetCapacity(hSpell,136,0)

    ;-- Convert DLLPath if needed
    if DLLPath is Space  ;-- Null or not specified
        DLLPath:=(A_PtrSize=8) ? "Hunspellx64.dll":"Hunspellx86.dll"
     else
        if InStr(FileExist(DLLPath),"D")  ;-- Path is a folder
            {
            ;-- Append backslash if needed
            if (SubStr(DLLPath,0)<>"\")
                DllPath.="\"

            ;-- Add DLL
            DLLPath.=(A_PtrSize=8) ? "Hunspellx64.dll":"Hunspellx86.dll"
            }

    ;-- Check to see if the files exist
    IfNotExist %DLLPath%
        {
        MsgBox
            ,0x10  ;-- 0x0 (OK button) + 0x10 (Stop icon)
            ,Spell Library Error,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Unable to find the Hunspell DLL file.  Initialization
                aborted.
               )

        Return False
        }

    if !FileExist(p_Aff) or !FileExist(p_Dic)
        {
        MsgBox
            ,0x10  ;-- 0x0 (OK button) + 0x10 (Stop icon)
            ,Spell Library Error,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Unable to find the dictionary and/or affix file.  Initialization
                aborted.
               )

        Return False
        }

    if p_CustomDic and !FileExist(p_CustomDic)
        {
        MsgBox
            ,0x10  ;-- 0x0 (OK button) + 0x10 (Stop icon)
            ,Spell Library Error,
               (ltrim join`s
                Function: %A_ThisFunc% -
                A custom dictionary file has been specified but it cannot be
                found.  Initialization aborted.
               )

        Return False
        }

    ;-- Load DLL library into the address space of the current process
    ;   Programming note: Return type is necessary for x64
    if not hModule:=DllCall("LoadLibrary","Str",DLLPath,PtrType)
        {
        MsgBox
            ,0x10  ;-- 0x0 (OK button) + 0x10 (Stop icon)
            ,Spell Library Error,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Unable to load the Hunspell DLL file.  %A_Space%
               )

        Return False
        }

    ;-- Store the handle to the DLL module
    NumPut(hModule,hSpell,8)

    ;-- Store function addresses
    ;   Note: When calling "GetProcAddress", return type is necessary for x64
    StrType:=A_IsUnicode ? "AStr":"Str"
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HunspellAdd",PtrType),         hSpell,16)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HunspellAddWithAffix",PtrType),hSpell,24)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HunspellAnalyze",PtrType),     hSpell,32)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HunspellFree",PtrType),        hSpell,40)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HunspellGenerate",PtrType),    hSpell,48)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HunspellInit",PtrType),        hSpell,56)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HunspellSpell",PtrType),       hSpell,64)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HunspellStem",PtrType),        hSpell,72)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HunspellSuggest",PtrType),     hSpell,80)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HyphenFree",PtrType),          hSpell,88)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HyphenHyphenate",PtrType),     hSpell,96)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"HyphenInit",PtrType),          hSpell,104)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"MyThesFree",PtrType),          hSpell,112)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"MyThesInit",PtrType),          hSpell,120)
    NumPut(DllCall("GetProcAddress",PtrType,hModule,StrType,"MyThesLookup",PtrType),        hSpell,128)

    ;-- Initialize and store the handle to the Spell object
    DataType:=A_IsUnicode ? "Str":A_PtrSize ? "WStr":"UInt"
    RC:=DllCall(NumGet(hSpell,56)
        ,DataType,A_PtrSize ? p_Aff:Spell_ANSI2Unicode(&p_Aff,wAff)
        ,DataType,A_PtrSize ? p_Dic:Spell_ANSI2Unicode(&p_Dic,wDic)
        ,"UInt",0
        ,"Cdecl")

    NumPut(RC,hSpell,0)
    Return True
    }


;------------------------------
;
; Function: Spell_InitCustom
;
; Description:
;
;   Add words from a custom dictionary file to the active dictionary.  Words are
;   valid until spell object is destroyed.
;
; Parameters:
;
;   hSpell - Variable that contains the current dictionary information.
;
;   p_CustomDic - Path to a custom dictionary file.
;
;   p_AddCase - See <Spell_Add> for the syntax/rules of this parameter.
;       [Optional]
;
; Returns:
;
;   The number of words loaded to the spell object if successful (can be 0) or
;   -1 if there was an error reading the custom dictionary file.
;
; Calls To Other Functions:
;
; * <Spell_Add>
;
; Remarks:
;
; * This function must be called _after_ <Spell_Init>.
;
; * The custom dictionary file must be in Unix (EOL=LF) or DOS/Windows
;   (EOL=CR+LF) format.
;
;-------------------------------------------------------------------------------
Spell_InitCustom(ByRef hSpell,p_CustomDic,p_AddCase="")
    {
    FileRead l_ListOfWords,%p_CustomDic%
    if ErrorLevel
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Unable to read from custom dictionary: %p_CustomDic%
           )

        Return -1
        }

    Return Spell_Add(hSpell,l_ListOfWords,p_AddCase)
    }


;------------------------------
;
; Function: Spell_Spell
;
; Description:
;
;   Check the spelling of the specified word.
;
; Returns:
;
;   TRUE if the word was found in the active dictionary, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Spell_ANSI2Unicode>
;
;-------------------------------------------------------------------------------
Spell_Spell(ByRef hSpell,p_Word)
    {
    Static Dummy0250
          ,FirstCall:=True
          ,PtrType
          ,StrType

    ;-- Set values for the dynamic static variables
    if FirstCall
        {
        PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"
        StrType:=A_IsUnicode ? "Str":A_PtrSize ? "WStr":"UInt"
        FirstCall:=False
        }

    ;-- Word in the dictionary?
    Return DllCall(NumGet(hSpell,64)
        ,PtrType,NumGet(hSpell,0)
        ,StrType,A_PtrSize ? p_Word:Spell_ANSI2Unicode(&p_Word,wString)
        ,"Cdecl")
    }


;------------------------------
;
; Function: Spell_Suggest
;
; Description:
;
;   Suggest words for a misspelled word.
;
; Parameters:
;
;   hSpell - Variable that contains the current dictionary information.
;
;   p_Word - Word for which to look up for suggestions.
;
;   r_SuggestList - [Output] Variable that is loaded with a newline ("`n")
;       delimited list of suggest words.
;
; Returns:
;
;   Number of words in r_SuggestList.
;
; Calls To Other Functions:
;
; * <Spell_ANSI2Unicode>
; * <Spell_Unicode2ANSI>
;
;-------------------------------------------------------------------------------
Spell_Suggest(ByRef hSpell,p_Word,ByRef r_SuggestList)
    {
    Static Dummy3522
          ,FirstCall:=True
          ,PtrSize
          ,PtrType
          ,StrType

    ;-- Set values for the dynamic static variables
    if FirstCall
        {
        PtrSize:=A_PtrSize ? A_PtrSize:4
        PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"
        StrType:=A_IsUnicode ? "Str":A_PtrSize ? "WStr":"UInt"
        FirstCall:=False
        }

    ;-- Initialize
    r_SuggestList:=""

    ;-- Get suggest words
    RC:=DllCall(NumGet(hSpell,80)
        ,PtrType,NumGet(hSpell,0)
        ,StrType,A_PtrSize ? p_Word:Spell_ANSI2Unicode(&p_Word,wString)
        ,"Cdecl " . PtrType)

    ;-- Return 0 if there are no suggest words
    if (RC=0)
        Return 0

    ;-- Build a list of suggest words
    pArrayOfPointers:=RC
    l_Count:=0
    Loop
        {
        ;-- Get the address to the next suggest word.  Break if there are no more.
        if not pSuggestWord:=NumGet(pArrayOfPointers+((A_Index-1)*PtrSize))
            Break

        ;-- Count it
        l_Count++

        ;-- Extract the suggest word from memory
        if A_IsUnicode
            {
            nSize:=DllCall("lstrlenW",PtrType,pSuggestWord)
                ;-- Length of string in characters.  Size does NOT include the
                ;   terminating null character.

            VarSetCapacity(l_SuggestWord,nSize*2,0)
            DllCall("lstrcpynW"
                ,"Str",l_SuggestWord                    ;-- lpString1 [out]
                ,PtrType,pSuggestWord                   ;-- lpString2 [in]
                ,"Int",nSize+1)                         ;-- iMaxLength [in]

            VarSetCapacity(l_SuggestWord,-1)
            }
         else
            Spell_Unicode2ANSI(pSuggestWord,l_SuggestWord)

        ;-- Add it to the list
        r_SuggestList.=(StrLen(r_SuggestList) ? "`n":"") . l_SuggestWord
        }

    Return l_Count
    }


;-----------------------------
;
; Function: Spell_Unicode2ANSI
;
; Description:
;
;   Maps a UTF-16 (wide character) string to a character string (ANSI).
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   lpWideCharStr - Address to a UTF-16 (wide character) string.
;
;   MultiByteStr - Variable to store character string (ANSI).
;
;-------------------------------------------------------------------------------
Spell_Unicode2ANSI(lpWideCharStr,ByRef MultiByteStr)
    {
    Static CP_ACP:=0    ;-- The system default Windows ANSI code page.

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Collect size
    nSize:=DllCall("WideCharToMultiByte"
            ,"UInt",CP_ACP
                ;-- CodePage [UINT,in]
            ,"UInt",0
                ;-- dwFlags [DWORD,in]
            ,PtrType,lpWideCharStr
                ;-- lpWideCharStr [LPCWSTR,in].  Pointer to Unicode string.
            ,"Int",-1
                ;-- cchWideChar [Int,in].  Size, in characters, of the string
                ;   indicated by lpWideCharStr.  -1=String is null terminated.
            ,PtrType,0
                ;-- lpMultiByteStr [LPSTR,out].  Pointer to a buffer that
                ;   receives the converted string.  Not used/specified here.
            ,"Int",0
                ;-- cbMultiByte [Int,in].  Size, in bytes, of the buffer
                ;   indicated by lpMultiByteStr.  When set to 0, the function
                ;   returns the required buffer size for lpMultiByteStr.
            ,PtrType,0
                ;-- lpDefaultChar [LPCSTR,in].  Not used.
            ,PtrType,0)
                ;-- lpUsedDefaultChar [LPBOOL,out].  Not used.

    ;-- Convert to ANSI
    VarSetCapacity(MultiByteStr,nSize,0)  ;-- Size includes terminating null
    DllCall("WideCharToMultiByte"
            ,"UInt",CP_ACP
                ;-- CodePage [UINT,in]
            ,"UInt",0
                ;-- dwFlags [DWORD,in]
            ,PtrType,lpWideCharStr
                ;-- lpWideCharStr [LPCWSTR,in].  Pointer to Unicode string.
            ,"Int",nSize
                ;-- cchWideChar [Int,in].  Size, in characters, of the string
                ;   indicated by lpWideCharStr.  For this function, nSize
                ;   includes the terminating null if found.
            ,"Str",MultiByteStr
                ;-- lpMultiByteStr [LPSTR,out].  Pointer to a buffer that
                ;   receives the converted string.
            ,"Int",nSize
                ;-- cbMultiByte [Int,in].  Size, in bytes, of the buffer
                ;   indicated by lpMultiByteStr.
            ,PtrType,0
                ;-- lpDefaultChar [LPCSTR,in].  Not used.
            ,PtrType,0)
                ;-- lpUsedDefaultChar [LPBOOL,out].  Not used.

    Return &MultiByteStr
    }


;------------------------------
;
; Function: Spell_Uninit
;
; Description:
;
;   Frees the spell object and the memory allocated to the dynamic link library
;   (DLL).
;
;-------------------------------------------------------------------------------
Spell_Uninit(ByRef hSpell)
    {
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"
    DllCall(NumGet(hSpell,40),PtrType,NumGet(hSpell,0),"Cdecl")
    DllCall("FreeLibrary",PtrType,NumGet(hSpell,8))
    }
