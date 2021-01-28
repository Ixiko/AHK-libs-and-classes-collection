; *********************************
; Debug plugin
; *********************************
; AHK Function Library - Structures
; Version 2.01
; - by Corrupt
; - July 1, 2006
; *********************************

; *********************************
; Retrieve a list of all variable names and values in a structure
; *********************************
; "StructName", "DelimChar", "V"
; - DelimChar may be character(s) to use to separate variable and value
; - The info for each variable is separated by a `n character
; - This function retrieves the values stored in the structure by default.
; "V" can be specified as the 3rd param to retrieve the values from the
; associated variables instead.
; *********************************
struct_enum(s_query, struct_delim2="", struct_local="")
{
  Global
  Local struct_sizeA, struct_sizeB, struct_temp1, struct_temp2, struct_temp3, struct_temp4, struct_temp5, struct_temp6
  , struct_temp0, struct_temp00, struct_temp01, struct_temp02, struct_temp7, struct_temp8
  StringSplit, struct_temp, s_query, ?
  struct_temp3 = %struct_temp1%_%A_AhkScriptProcessID%
  If (!%struct_temp3%) {
    VarSetCapacity(%struct_temp3%, 0)
    ErrorLevel = Invalid_Struct
    Return
  }
  If struct_delim2=
    struct_delim2 = `=
  struct_sizeA = 0
  Loop, Parse, %struct_temp3%, |
  {
    StringSplit, struct_temp0, A_LoopField, :
    If struct_temp00 = 0
      break
    struct_sizeA += struct_temp01
    struct_temp4 := !InStr(struct_temp01, "u")
    struct_sizeB = %struct_temp01%
    EnvAdd, struct_temp01, 0
    If struct_local = V
      struct_temp5 := %struct_temp1%?%struct_temp02%
    Else {
      struct_temp5 := ExtractIntegerSL(%struct_temp1%, (struct_sizeA - struct_temp01), struct_temp4, struct_temp01)
      If (InStr(struct_sizeB, "p"))
      {
        struct_temp7 = %struct_temp5%
        struct_temp8 := DllCall("lstrlen", "UInt", struct_temp7)
        VarSetCapacity(struct_temp5, struct_temp8, 0)
        DllCall("RtlMoveMemory", "Str", struct_temp5, "UInt", struct_temp7, "Int", struct_temp8)
      }
    }
    struct_temp6 = %struct_temp6%`n%struct_temp02%%struct_delim2%%struct_temp5%
  }
  Return, struct_temp6
}
; *********************************