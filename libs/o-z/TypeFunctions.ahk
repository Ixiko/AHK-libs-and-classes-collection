;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
; Library:      Type Functions
; Description:  Functions related to AHK variable types
; Online Ref.:  http://www.autohotkey.com/forum/viewtopic.php?t=59341
;
; Last Update:  17/June/2010 16:15
;
; Created by:   MasterFocus
;               http://www.autohotkey.net/~MasterFocus/AHK/
;
; This library contains 5 functions. One of them consists of an independent
; version of a previous function. For usage and dependencies, see each
; function's documentation (located directly above it). There is also an
; example section at the bottom of this file.
;
; This library is licensed under GNU LGPL (v3.0).
; Please refer to my webpage when giving credits.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;
;
;

;========================================================================
; 
; Function:     IsType
; Description:  Indicates if a given input is of a certain type
;
; + Required parameters:
; - p_Input     The variable/value/string to be checked
; - p_Type      A string of one exact AHK variable type
;
; The function returns true if the input is of that type, false otherwise.
;
;========================================================================

IsType( p_Input , p_Type )
{
  If InStr("integer,float,number,digit,xdigit,alpha,upper,lower,alnum,space,time",p_Type,false)
    If p_Input is %p_Type%
      Return 1
  Return 0
}

;
;
;

;========================================================================
; 
; Function:     VarTypes
; Description:  Returns a CSV string with the types of the given input
;
; + Required parameters:
; - p_Input     The variable/value/string to be checked
;
; The function returns a CSV string containing all AHK variable types that
; fit to the given input, or blank if none do.
;
;========================================================================

VarTypes( p_Input )
{
  static st_Types := "integer,float,number,digit,xdigit,alpha,upper,lower,alnum,space,time"
  Loop, Parse, st_Types, `,
    If p_Input is %A_LoopField%
      l_Output .= "," A_LoopField
  Return SubStr(l_Output,2)
}

;
;
;

;========================================================================
; 
; Function:     SameTypes
; Description:  Returns a CSV string with all common variable types found
;
; + Required parameters:
; - p_Input1    The first variable/value/string to be checked
; - p_Input2    The second variable/value/string to be checked
;
; + Dependencies:
; - VarTypes()
;
; The function returns a CSV string containing all AHK variable types that
; fit to both input values, or blank if none do.
;
;========================================================================

SameTypes( p_Input1 , p_Input2 )
{
  If ( (l_Type1 := VarTypes(p_Input1)) && (l_Type2 := VarTypes(p_Input2)) )
    Loop, Parse, l_Type1, `,
      If InStr(l_Type2,A_LoopField)
        l_Output .= "," A_LoopField
  Return SubStr(l_Output,2)
}

;
;
;

;========================================================================
; 
; Function:     SameTypes02
; Description:  An independent version of SomeTypes()
;
; This function is the same as SameTypes(), without any dependencies.
;
;========================================================================

SameTypes02( p_Input1 , p_Input2 )
{
  static st_Types := "integer,float,number,digit,xdigit,alpha,upper,lower,alnum,space,time"
  Loop, Parse, st_Types, `,
  {
    If p_Input1 is %A_LoopField%
      l_Type1 .= "," A_LoopField
    If p_Input2 is %A_LoopField%
      l_Type2 .= "," A_LoopField
  }
  If ( (l_Type1 := SubStr(l_Type1,2)) && (l_Type2 := SubStr(l_Type2,2)) )
    Loop, Parse, l_Type1, `,
      If InStr(l_Type2,A_LoopField)
        l_Output .= "," A_LoopField
  Return SubStr(l_Output,2)
}

;
;
;

;========================================================================
; 
; Function:     CommonTypes
; Description:  Returns a CSV string with all common variable types found
;
; + Required parameters:
; - p_InputList   A CSV string of literal variable names (see remarks below)
;
; + Dependencies:
; - VarTypes()
;
; The function returns a CSV string containing all AHK variable types that
; fit to all input values, or blank if none do. The input list must be a
; CSV string of literal variable names and/or values. If you want to check
; the common variable types for 3 variables named 'var1', 'var2' and 'var3',
; you must pass the string "var1,var2,var3" as the input list.
;
;========================================================================

CommonTypes( p_InputList )
{
  l_ValidTypes := "integer,float,number,digit,xdigit,alpha,upper,lower,alnum,space,time"
  Loop, Parse, p_InputList, `,
  {
    If !( l_CurrentTypes := VarTypes(%A_LoopField%) )
      Return
    Loop, Parse, l_CurrentTypes, `,
      If InStr(l_ValidTypes,A_LoopField)
        l_NewValidTypes .= "," A_LoopField
    l_ValidTypes := l_NewValidTypes  ,  l_NewValidTypes := ""
  }
  Return SubStr(l_ValidTypes,2)
}

;
;
;

/************************************************************************
/ *** Example Section
/ This commented section contains usage examples for 4 of 5 functions

text := "* EXAMPLES *"
text .= "`n"
text .= "`nvar1 = " ( var1 := "AB4D" ) ": " VarTypes( var1 )
text .= "`nvar2 = " ( var2 := "8df3K" ) ": " VarTypes( var2 )
text .= "`nvar3 = " ( var3 := "2345" ) ": " VarTypes( var3 )
text .= "`n"
text .= "`n" "SameTypes(var1,var2): " SameTypes(var1,var2)
text .= "`n" "SameTypes02(var1,var3): " SameTypes02(var1,var3)
text .= "`n"
text .= "`n" "CommonTypes(""var1,var2,var3""): " CommonTypes("var1,var2,var3")
text .= "`n" "CommonTypes(""var3,var1,var2""): " CommonTypes("var3,var1,var2")

MsgBox %text%

************************************************************************/