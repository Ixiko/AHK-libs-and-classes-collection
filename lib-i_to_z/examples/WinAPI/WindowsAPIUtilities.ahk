/*
Script:	Windows API Utilities
Desc:		A program to look up an enumeration constant, data type or structure defined in the Windows API,
				and to parse a structure, which is useful for DllCall in AHK.
Author:	hughman (at) gmail.com
	Enum - by hughman
	Struct - by hughman
	DataType - PhiLho, intergrated by hughman
	StructParse - Lexikos, intergrated by hughman
Date: 		19/09/2009
Version:	1.0
*/

defFile_Enum := "WindowsEnum.txt"
defFile_DataType := "WindowsDataTypes.txt"
defFile_Struct := "WindowsStruct.txt"

GUI_MARGIN := 10
GUI_WIDTH := 800
GUI_HEIGHT := 600
SB_HEIGHT := 20
TAB_CXITEM := 80
TAB_CYITEM := 24
TAB_CXRECT := GUI_WIDTH ;- GUI_MARGIN * 2
TAB_CYRECT := GUI_HEIGHT - GUI_MARGIN - TAB_CYITEM - SB_HEIGHT
TAB_WIDTH := TAB_CXRECT
TAB_HEIGHT := TAB_CYITEM + TAB_CYRECT

Gui, Margin, %GUI_MARGIN%, %GUI_MARGIN%
Gui, Add, StatusBar, h%SB_HEIGHT%
SB_SetParts(150, 150, 150, 350)
Gui, Add, Tab2, x0 w%TAB_WIDTH% h%TAB_HEIGHT% +Theme +0x400 hwnd$hTab, Enum|DataType|Struct|StructParse	; TCS_FIXEDWIDTH=0x400
SendMessage, 0x1329, 0, TAB_CXITEM|TAB_CYITEM<<16,, ahk_id %$hTab%	;TCM_SETITEMSIZE=0x1329

Gosub @Gui_Tab1
Gosub @Gui_Tab2
Gosub @Gui_Tab3
Gosub @Gui_Tab4
Gui, Tab

Gui, Add, Button, x660 y5 w120 h28 g@SearchInMSDN, Search in MSDN
Gui, Show, w%GUI_WIDTH% h%GUI_HEIGHT%, Windows API Utilities
Return

GuiEscape:
GuiClose:
ExitApp

@SearchInMSDN:
	If Keyword
		Run, http://social.msdn.microsoft.com/Search/en-US?query=%Keyword%
	Else
		Run, http://msdn.microsoft.com/en-us/default.aspx
Return
; ===================================================
; Tab1 - Enum
; ===================================================
@Gui_Tab1:
	Gui, Tab, 1
	W := GUI_WIDTH - GUI_MARGIN * 2
	Gui, Add, Edit, w%W% v$edInputEnum g@OnSearchEnum
	H := TAB_CYRECT - GUI_MARGIN * 3 - 20
	Gui, Add, ListView, wp h%H% -Multi AltSubmit v$lvEnum g@ListView_OnEvent, Name|Value
	LV_ModifyCol(1, 300)
	Gosub, @AddItem_Enum
Return

@AddItem_Enum:
	GuiControl, -Redraw, $lvEnum
	Loop, Read,%defFile_Enum%
	{
		If RegExMatch(A_LoopReadLine, "^\s+$") ||  (A_LoopReadLine = "")
			Continue
		RegExMatch(A_LoopReadLine, "(?P<Name>.+)(\s*?)=(\s*?)(?P<Value>.+)", _)
		LV_Add("", _Name, _Value)
	}
	LV_ModifyCol(1, "Sort")
	Loop % cntEnum := LV_GetCount()
	{
		 LV_GetText(Enum%A_Index%?Name, A_Index, 1)
		 LV_GetText(Enum%A_Index%?Value, A_Index, 2)
	}
	GuiControl, +Redraw, $lvEnum
	SB_SetText("Enum: "cntEnum, 1)
Return

@OnSearchEnum:
	Gui, Submit, NoHide
	len := StrLen($edInputEnum)
	LV_Delete()
	GuiControl, -Redraw, $lvEnum
	Loop %cntEnum%
	{
		StringLeft, part, Enum%A_Index%?Name, len
		If (part = $edInputEnum)
			LV_Add("", Enum%A_Index%?Name, Enum%A_Index%?Value)
	}
	GuiControl, +Redraw, $lvEnum
Return

@ListView_OnEvent:
	If (A_GuiEvent == "I")
	{
		curRow := LV_GetNext()
		LV_GetText(Keyword, curRow, 1)
		LV_GetText(Value, curRow, 2)
		Clipboard := Value
		SB_SetText("Keyword: " . Keyword, 4)
	}
Return


; ===================================================
; Tab2 - DataType
; ===================================================
@Gui_Tab2:
	Gui, Tab, 2
	Gui Add, Edit, w200 Section v$edInputDataType g@OnSearchDataType
	Gui Add, ListBox, wp h%H% v$lbDataType g@lbDataType_OnClick +Sort
	W := TAB_CXRECT - GUI_MARGIN * 3 - 200
	H := TAB_CYRECT - GUI_MARGIN * 2
	Gui Add, GroupBox, ys w%W% h%H%
	Gui Add, Text, x240 ys+30 w100 Section, Equivalence
	W := W - 140
	Gui Add, Edit, xp+110 yp w%W% v$edEquivalence
	Gui Add, Text, xs w100 Section, AutoHotkey Format
	Gui Add, Edit, xp+110 yp w%W% v$edAHKFormat
	Gui Add, Text, xs w100 Section, Description
	Gui Add, Edit, xp+110 yp w%W% h160 v$edDescription
	Gui Add, Text, xs w100 Section, Include file where it is defined
	Gui Add, Edit, xp+110 yp w%W% v$edIncludeFile
	Gui Add, Text, xs w100, Definition
	Gui Add, Edit, xp+110 yp w%W% h200 v$edDataTypeDef
	Gosub, @AddDataType
Return

@AddDataType:
	#equiv?V0 = N/A
	#equiv?S8 = Char
	#equiv?U8 = UChar
	#equiv?S16 = Short
	#equiv?U16 = UShort
	#equiv?S32 = Int
	#equiv?U32 = UInt
	#equiv?F32 = Float
	#equiv?S64 = Int64
	#equiv?U64 = UInt64
	#equiv?D64 = Double

	GuiControl -Redraw, $lbDataType
	cntDataType := 0
	Loop Read, %defFile_DataType%
	{
		StringLeft fc, A_LoopReadLine, 1
		If (fc = ";")
			Continue   ; Comment
		If (fc = "")
		{
			; Start of a definition
			defPos := 0
			cntDataType++
			Continue
		}
		defPos++
		If (defPos = 1) {
			DataType := DataType%A_Index% := A_LoopReadLine
			GuiControl, , $lbDataType, %A_LoopReadLine%
		} Else If (defPos = 2) {
			DataType_%DataType%_Equivalence := A_LoopReadLine
		} Else If (defPos = 3) {
			DataType_%DataType%_Description := A_LoopReadLine
		} Else If (defPos = 4) {
			DataType_%DataType%_IncludeFile := A_LoopReadLine
		} Else If (defPos > 4) {
			DataType_%DataType%_Definition .= A_LoopReadLine . "`n"
		}
	}
	SB_SetText("DataType: " . cntDataType, 2)
	GuiControl +Redraw, $lbDataType
Return

@OnSearchDataType:
	Gui Submit, NoHide
	len := StrLen($edInputDataType)
	itemNb := 0
	Loop %cntDataType%
	{
		StringLeft, part, DataType%A_Index%, len
		If (part = $edInputDataType)
		{
			GuiControl, Choose, $lbDataType, % DataType%A_Index%
			Goto @lbDataType_OnClick
			Break
		}
	}
Return

@lbDataType_OnClick:
	GuiControlGet, Keyword, , $lbDataType
	GuiControl, , $edEquivalence, % DataType_%Keyword%_Equivalence
	Equiv := DataType_%Keyword%_Equivalence
	GuiControl, , $edAHKFormat, % #equiv?%Equiv%
	GuiControl, , $edDescription, % DataType_%Keyword%_Description
	GuiControl, , $edIncludeFile, % DataType_%Keyword%_IncludeFile
	GuiControl, , $edDataTypeDef, % DataType_%Keyword%_Definition
	SB_SetText("Keyword: " . Keyword, 4)
Return


; ===================================================
; Tab3 - Struct
; ===================================================
@Gui_Tab3:
	Gui, Tab, 3
	Gui Add, Edit, w200 Section v$edStruct g@OnSearchStruct
	H := TAB_CYRECT - GUI_MARGIN * 3 - 20
	Gui Add, ListBox, wp h%H% v$lbStruct g@ListBox_OnClick +Sort
	W := TAB_CXRECT - GUI_MARGIN * 3 - 200
	H := TAB_CYRECT - GUI_MARGIN * 2
	Gui Add, Edit, ys w%W% h%H% v$edStructDef
	Gosub @AddStruct
Return

@AddStruct:
	FileRead, fc, WindowsStruct.txt
	pos := 0
	Loop
	{
		If !pos := RegExMatch(fc, "ism)(?P<Struct>^Type(?P<Tag>.+?)\r\n(.+?)End Type)\s*", _, pos + 1)
			Break
		cntStruct++
		_Tag = %_Tag%
		Struct%A_Index% := _Tag
		Struct_%_Tag% := _Struct
		GuiControl, , $lbStruct, %_Tag%
	}
	SB_SetText("Struct: " . cntStruct, 3)
Return

@OnSearchStruct:
	Gui Submit, NoHide
	len := StrLen($edStruct)
	Loop %cntStruct%
	{
		StringLeft, part, Struct%A_Index%, len
		If (part = $edStruct)
		{
			GuiControl, Choose, $lbStruct, % Struct%A_Index%
			Gosub @ListBox_OnClick
			Break
		}
	}
Return

@ListBox_OnClick:
	GuiControlGet, Keyword, , $lbStruct
	GuiControl, , $edStructDef, % Struct_%Keyword%
	SB_SetText("Keyword: " . Keyword, 4)
Return


; ===================================================
; Tab4 - StructParse
; ===================================================
@Gui_Tab4:
	Gui, Tab, 4
	W := TAB_CXRECT/2 - GUI_MARGIN * 2 - 50
	Gui, Add, Edit, w%W% h%H% Section vInputText
	Gui, Add, Button, ys w100 Section vParseButton gParseStruct, &Parse
	Gui, Add, Button, wp vCopyButton gParseAndCopy, && &Copy
	Gui, Add, Checkbox, wp vGenGetters Checked, &Get
	Gui, Add, Checkbox, wp vGenSetters Checked, &Set
	Gui, Add, Checkbox, wp vGenCtor Checked, &VarSetCapacity
	Gui, Add, Edit, wp vStructName, struct
	Gui, Add, Edit, ys w%W% h%H% vOutputText

	GuiControlGet, StructName, Pos
	GuiControl, Move, StructName, % "W" 414-StructNameX-7
	DelimNameAndTypeWithNewline := false
Return

ParseAndCopy:
    gosub ParseStruct
    Clipboard := RegExReplace(OutputText, "(?<!`r)`n", "`r`n")
return

ParseStruct:
    Gui, Submit, NoHide
   
    OutputText =
    OutputGetters =
    OutputSetters =
   
    if StructName =
        StructName = struct
   
    ; Remove comments and directives from consideration.
    InputText := RegExReplace(InputText, "`a)//.*|#.*|/\*.*?\*/")
   
    pos := 1
    namespace = ; short string to keep track of unions, etc.
    indent =
   
    indent_amount = 4
   
    offset = 0
   
    ; for union support
    union_offsets = ; (list)
    union_ends = ; (list)
   
    Loop
    {
        i := RegExMatch(InputText, "s).*?({|;|})", t, pos)
        if ! i
            break
       
        ; Move cursor to end of this bit.
        pos := i+StrLen(t)
       
        ; Remove leading whitespace (previous regex excludes trailing space.)
        t := RegExReplace(t, "(?:^\s+)")
       
        if (t1 = "{")
        {   ; Enter block.
           
            ; Mark the beginning of the block.
            if GenGetters
                OutputGetters .= indent . "; " . t . "`n"
            if GenSetters
                OutputSetters .= indent . "; " . t . "`n"

            ; Indent output.
            Loop, %indent_amount%
                indent .= " "
           
            ; Add block info to namespace, if relevant.
            if (RegExMatch(t, "^union(?:\s+(\w*))s*{$")) {
                last_block = u
                StackPush(union_offsets, offset)
                StackPush(union_ends, offset)
            } else
                last_block = .
               
            namespace .= last_block
        }
        else if (t1 = "}")
        {   ; Exit block.

            ; Un-indent output.
            indent := SubStr(indent, 1, -indent_amount)
           
            ; Mark the end of the block.
            if GenGetters
                OutputGetters .= indent . "; }`n"
            if GenSetters
                OutputSetters .= indent . "; }`n"

            if (last_block = "u")
            {   ; End union.
                offset := StackPop(union_ends, offset)
                StackPop(union_offsets)
            }

            ; Remove block info char from namespace.
            if (StrLen(namespace))
            {
                StringTrimRight, namespace, namespace, 1
                ; Update current immediate block.
                last_block := SubStr(namespace, 0) ; 0=last char
            }
            else
                last_block := ""

            ; Omit declarations following a block (e.g. "struct x { int y } declarations;")
            i := RegExMatch(InputText, "s).*?({|;|})", t, pos)
            if (t1 = ";")
                pos := i+StrLen(t)
        }
        else if (t != ";")
        {
            if ! ParseField(t)
                return
        }   

        if (t != "{" && last_block = "u")
        {   ; Determine end of union by its largest item.
            end := StackPop(union_ends)
            if (end="" or offset > end)
                end := offset
            StackPush(union_ends, end)
            ; Reset offset to beginning of union.
            offset := StackPeek(union_offsets, offset)
        }
    }
    if GenCtor
        OutputText .= "VarSetCapacity(" StructName ", " offset ", 0)`n`n"
    if GenGetters
        OutputText .= OutputGetters "`n"
    if GenSetters
        OutputText .= OutputSetters "`n"

;     OutputText .= "`nStdOut( "
;     Loop, Parse, NameList, `,
;     {
;         if (A_Index>1)
;             OutputText = %OutputText% ", %A_LoopField%=" %A_LoopField%
;         else
;             OutputText = %OutputText%"%A_LoopField%=" %A_LoopField%
;     }
;     OutputText .= " )"
   
    GuiControl,, OutputText, %OutputText%
    return
   

AppendField(name, size, type="", length="") ; length=array length
{
    local delim, pos, text, StructName_
   
    if StructName != struct
        StructName_ = %StructName%_
   
    if (name && type)
    {
        if length =
        {
            text = %StructName_%%name%
            if GenGetters
                OutputGetters .= indent text " := NumGet(" StructName ", " offset ", """ type """)`n"
            if GenSetters
                OutputSetters .= indent "NumPut(" text ", " StructName ", " offset ", """ type """)`n"
            NameList .= (NameList ? "," : "") . name
        }
        else
        {
            if GenGetters
            {
                OutputGetters .= indent StructName_ name "[%index%] := NumGet(" StructName ", " offset " + index"
                if size != 1
                    OutputGetters .= "*" size
                OutputGetters .= ", """ type """)"
                    . (DelimNameAndTypeWithNewline ? "`n  " indent : ", ") . StructName_ name "_length := " length "`n"
            }
            if GenSetters
            {
                OutputSetters .= indent "NumPut(" StructName_ name "[%index%], " StructName ", " offset " + index"
                if size != 1
                    OutputSetters .= "*" size
                OutputSetters .= ", """ type """)`n"
            }
        }
    }
    else
    {
        text := indent StructName "_" name "_ptr := &" StructName " + " offset
        if (type)
            text .= (DelimNameAndTypeWithNewline ? "`n  " indent : ", ")
                . StructName "_" name "_type := """ type """"
        if (length)
            text .= (DelimNameAndTypeWithNewline ? "`n  " indent : ", ")
                . StructName "_" name "_length := " length
        if GenGetters
            OutputGetters .= text "`n"
        if GenSetters
            OutputSetters .= text "`n"
    }
    if length
        offset += size*length
    else
        offset += size
}

StackPush(ByRef stack, item)
{
    if stack
        stack .= ","
    stack .= item
}

StackPop(ByRef stack, defval="")
{
    if (pos := InStr(stack, ","))
    {
        item := SubStr(stack, pos+1)
        stack := SubStr(stack, 1, pos-1)
        return item
    }
    else if stack
    {
        item := stack
        stack := ""
        return item
    }
    return defval
}

StackPeek(ByRef stack, defval="")
{
    if (pos := InStr(stack, ","))
        return SubStr(stack, pos+1)
    else if stack
        return stack
    else
        return defval
}

; Parses a field string "type identifier[arraylength];"
; Returns:
;   name
;   size - size, in bytes, of the field.
;   type - NumGet/DllCall-compatible type string.
ParseField(t)
{
    local m, mtype, msep, mname, mlength, userlength
        , typelist, name, size, type
   
    static Types = "Int,UInt,Short,UShort,Char,UChar,Int64,Float,Double"
         , IntSize = 4      , IntTypes = "int,INT,LONG"
         , UIntSize = 4     , UIntTypes = "unsigned int,unsigned long,UINT,ULONG,DWORD,COLORREF,HANDLE,HBITMAP,HBRUSH,HDC,HICON,HISTANCE,HMENU,HWND,ULONG_PTR,LPARAM,WPARAM"
         , ShortSize = 2    , ShortTypes = "short"
         , UShortSize = 2   , UShortTypes = "unsigned short,WORD,ATOM,USHORT,WCHAR"
         , CharSize = 1     , CharTypes = "char"
         , UCharSize = 1    , UCharTypes = "unsigned char,byte,BYTE,UCHAR,TCHAR" ; assume compiled with multi-byte, not unicode...
         , Int64Size = 8    , Int64Types = "int64,LONGLONG,ULONGLONG"
         , FloatSize = 4    , FloatTypes = "FLOAT"
         , DoubleSize = 8   , DoubleTypes = "DOUBLE"
   
    if (RegExMatch(t, "^\s*(?<type>(?:[\w]+[ \t])*[\w]+)(?<sep>[\s\*]+)(?<name>\w+)(?:\[(?<length>\w+)\])?\s*;", m))
    {
        name := mname
       
        if (mtype = "bool") {
            if (mtype=="BOOL") ; BOOL is an alias for int.
                AppendField(name, 4, "Int")
            else ; bool (C++) is 1 byte.
                AppendField(name, 1, "UChar")
            return true
        }
        if (InStr(msep, "*") or SubStr(mtype,1,2)="LP")
        {   ; Add 32-bit pointer to something.
            AppendField(name, 4, "UInt")
            return true
        }
        if ((mtype = "POINTL" or mtype = "POINT") && mlength="")
        {   ; Add individual X and Y fields.
            AppendField(name . "_X", 4, "Int")
            AppendField(name . "_Y", 4, "Int")
            return true
        }
        if (mtype = "RECT" && mlength="")
        {   ; Add individual struct fields.
            AppendField(name . "_left",     4, "Int")
            AppendField(name . "_top",      4, "Int")
            AppendField(name . "_right",    4, "Int")
            AppendField(name . "_bottom",   4, "Int")
            return true
        }
       
        if StartsWith(mtype, "LP") && !EndsWith(mtype, "STR")
        {
            type := "UInt", size := 4
        }
        else
        {   ; Get DllCall-compatible type if possible.
            Loop, Parse, Types, `,
            {
                typelist := %A_LoopField%Types
                if mtype in %typelist%
                {
                    type := A_LoopField
                    size := %A_LoopField%Size
                    break
                }
            }
        }
   
        if mlength
        if mlength is not integer
        {
            if ! RegExMatch(mlength, "\W")
                if DEF_%mlength%
                    mlength := DEF_%mlength%
           
            if mlength is not integer
            {
mlength_TryAgain:
                InputBox, userlength, Constant, Unknown value '%mlength%' used as array length. Please enter the value of '%mlength%'.,,, 150
                if userlength =
                    return
                if userlength is not integer
                    goto mlength_TryAgain
               
                DEF_%mlength% := mlength := userlength
            }
        }
    }
   
    if ! size
    {
        ; Ask the user to enter details for this field.
        size = 4
        type = UInt ; Most common.
        if ! PromptForStuff(t, name, size, type)
            return false
    }
   
    AppendField(name, size, type, mlength)
    return true
}

PromptForStuff(t, ByRef name, ByRef size, ByRef type, message="")
{
    static retval, tname, tsize, ttype
   
    if ! message
        message = Failed to parse field:`n  %t%`n`nPlease enter the necessary details.

    Gui, 2:Default
    Gui, +Owner1
    Gui, +LabelPFS +LastFound
    Gui, Add, Text, W300, %message%
    Gui, Add, Text, , Name:
    Gui, Add, Edit, W300 vtname, %name%
    Gui, Add, Text, , Size:
    Gui, Add, Edit, W300 vtsize, %size%
    Gui, Add, Text, , NumGet-compatible Type:
    Gui, Add, Edit, W300 vttype, %type%
    Gui, Add, Button, gPFSOK Default, OK
   
    retval = 0
   
    Gui, Show,, Parse Error
    Gui, 1:+Disabled
   
    WinWaitClose, % "ahk_id " . WinExist()
   
    name := tname
    size := tsize
    type := ttype
   
    Gui, 1:Default
    Gui, 1:-Disabled
    Gui, 1:Show
   
    Gui, 2:Destroy
   
    return retval

PFSEscape:
    Gui, 2:Cancel
    return
PFSOK:
    Gui, 2:Submit
    retval = 1
    return
}


; Case-sensitive by default because we're parsing C++ code.
EndsWith(A, B, CaseSensitive=true)
{
    if (StrLen(A) < StrLen(B))
        return false
   
    return CaseSensitive
        ? (SubStr(A, -(StrLen(B)-1)) == B)
        : (SubStr(A, -(StrLen(B)-1)) = B)
}

StartsWith(A, B, CaseSensitive=true)
{
    if (StrLen(A) < StrLen(B))
        return false
   
    return CaseSensitive
        ? (SubStr(A, 1, StrLen(B)) == B)
        : (SubStr(A, 1, StrLen(B)) = B)
}

Spaces(count)
{
    Loop, %count%
        str .= " "
    return str
}