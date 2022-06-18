﻿#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, +Resize +MinSize250x80

Gui, Margin, 7, 7
Gui, Font,, Courier New
Gui, Add, Edit, R9 W400 vInputText
Gui, Font
Gui, Add, Button, vParseButton gParseStruct Y+2, &Parse
Gui, Add, Button, vCopyButton gParseAndCopy X+0, && &Copy
Gui, Add, Checkbox, vGenGetters Checked X+5 YP+5, &Get
Gui, Add, Checkbox, vGenSetters Checked X+0, &Set
Gui, Add, Checkbox, vGenCtor    Checked X+0, &VarSetCapacity
Gui, Add, Edit, vStructName X+0 YP-4, struct
Gui, Font,, Courier New
Gui, Add, Edit, XM Y+4 R12 W400 vOutputText

GuiControlGet, StructName, Pos
GuiControl, Move, StructName, % "W" 414-StructNameX-7

Gui, Show, W414, Struct Parser

DelimNameAndTypeWithNewline := false

return

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
   

GuiEscape:
GuiClose:
    ExitApp

GuiSize:
;     Anchor("InputText" ,  "w h0.5")
;     , Anchor("ParseButton", "y0.5"), Anchor("GenGetters", "y0.5")
;     , Anchor("GenGetters", "y0.5"), Anchor("GenSetters", "y0.5")
;     , Anchor("GenCtor", "y0.5"), Anchor("StructName", "y0.5 w1")
;     , Anchor("OutputText",  "w h0.5 y0.5")
    ; InputText is rarely used for more than a paste target,
    ; so resize only OutputText vertically.
    Anchor("InputText", "w")
    , Anchor("StructName", "w")
    , Anchor("OutputText", "h w")
    return


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




;; anchor
/*
	Function: Anchor
		Defines how controls should be automatically positioned relative to the new dimensions of a window when resized.

	Parameters:
		cl - a control HWND, associated variable name or ClassNN to operate on
		a - (optional) one or more of the anchors: 'x', 'y', 'w' (width) and 'h' (height),
			optionally followed by a relative factor, e.g. "x h0.5"
		r - (optional) true to redraw controls, recommended for GroupBox and Button types

	Examples:
> "xy" ; bounds a control to the bottom-left edge of the window
> "w0.5" ; any change in the width of the window will resize the width of the control on a 2:1 ratio
> "h" ; similar to above but directrly proportional to height

	Remarks:
		To assume the current window size for the new bounds of a control (i.e. resetting) simply omit the second and third parameters.
		However if the control had been created with DllCall() and has its own parent window,
			the container AutoHotkey created GUI must be made default with the +LastFound option prior to the call.
		For a complete example see anchor-example.ahk.

	License:
		- Version 4.60a <http://www.autohotkey.net/~Titan/#anchor>
		- Simplified BSD License <http://www.autohotkey.net/~Titan/license.txt>
*/
Anchor(i, a = "", r = false) {
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
	If (!WinExist("ahk_id" . i)) {
		GuiControlGet, t, Hwnd, %i%
		If ErrorLevel = 0
			i := t
		Else ControlGet, i, Hwnd, , %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), "UInt", &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp) {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1)) == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52)
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}

