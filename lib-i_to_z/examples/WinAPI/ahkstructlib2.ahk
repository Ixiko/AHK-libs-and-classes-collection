; *********************************
; AHK Function Library - Structures
; Version 2.02
; - by Corrupt
; - Updated June 1, 2008
; *********************************
;
; *********************************
;  Comments, suggestions, etc... welcome :)
; *********************************
;
; *********************************
; Create a new structure
; *********************************
; Params: "Structure Name", "VarType", "VarName", "Type", "Name", etc...
; - Currently a maximum of 32 variables in a structure is supported
;   (to add support for more, add to the list below)
;
; Optional alternate syntax allowed: "Structure Name", "VarName As Type", "VarName As Type", ...
; - mixing of the 2 different syntax styles in the same call is not currently supported
; *********************************
StructCreate(struct_name ,s_type1, s_var1 ,s_type2="", s_var2="" ,s_type3="", s_var3=""
,s_type4="" , s_var4=""  ,s_type5="" , s_var5=""  ,s_type6="" , s_var6=""  ,s_type7="" , s_var7=""
,s_type8="" , s_var8=""  ,s_type9="" , s_var9=""  ,s_type10="", s_var10="" ,s_type11="", s_var11=""
,s_type12="", s_var12="" ,s_type13="", s_var13="" ,s_type14="", s_var14="" ,s_type15="", s_var15=""
,s_type16="", s_var16="" ,s_type17="", s_var17="" ,s_type18="", s_var18="" ,s_type19="", s_var19=""
,s_type20="", s_var20="" ,s_type21="", s_var21="" ,s_type22="", s_var22="" ,s_type23="", s_var23=""
,s_type24="", s_var24="" ,s_type25="", s_var25="" ,s_type26="", s_var26="" ,s_type27="", s_var27=""
,s_type28="", s_var28="" ,s_type29="", s_var29="" ,s_type30="", s_var30="" ,s_type31="", s_var31=""
,s_type32="", s_var32=""){
  Global
  Local struct_sizeA, struct_sizeB, struct_temp1, struct_temp2, struct_temp3, struct_temp4
  , struct_temp40, struct_temp41, struct_temp42, struct_temp5, struct_temp6, struct_templast
  struct_sizeA = 0
  If (!A_AhkScriptProcessID) {
    Process, Exist
    A_AhkScriptProcessID = %ErrorLevel%i
  }
  struct_temp3 = %struct_name%_%A_AhkScriptProcessID%
  %struct_name%= init
  %struct_name%=
  ; Process elements
  Loop, 32 {
    struct_temp42 := s_type%A_Index%
    struct_temp41 := s_var%A_Index%
    struct_temp5 = 1
    ; check for As syntax
    StringReplace, struct_temp42, struct_temp42, %A_Tab%, %A_Space%, All
    If (InStr(struct_temp42, " as ")) {
      StringReplace, struct_temp42, struct_temp42, %A_Space%As%A_Space%, `,
      struct_temp4 = %struct_temp42%
      StringSplit, struct_temp4, struct_temp4, `,, %A_Space%
      struct_temp4 := s_var%A_Index%
      struct_temp5 = 2
    }
    Loop, %struct_temp5%
    {
      If (A_Index = "2") {
        struct_temp41 = %struct_temp4%
        StringReplace, struct_temp41, struct_temp41, %A_Tab%, %A_Space%, All
        StringReplace, struct_temp41, struct_temp41, %A_Space%As%A_Space%, `,
        struct_temp4 = %struct_temp41%
        StringSplit, struct_temp4, struct_temp4, `,, %A_Space%
      }
      ; Check Type (u - unsigned, p - pointer)
      If (struct_temp42="Int" OR struct_temp42="long")
        struct_temp2 = 4
      Else If (struct_temp42="UInt" OR struct_temp42="dword" OR struct_temp42="hwnd")
        struct_temp2 = 4u
      Else If (struct_temp42="Str")
        struct_temp2 = 4up
      Else If (struct_temp42="Short")
        struct_temp2 = 2
      Else If (struct_temp42="UShort" OR struct_temp42="word")
        struct_temp2 = 2u
      Else If (struct_temp42="UChar" OR struct_temp42="byte")
        struct_temp2 = 1u
      Else If (struct_temp42="Char")
        struct_temp2 = 1
      Else If (struct_temp42="Int64")
        struct_temp2 = 8
      Else If (struct_temp42="UInt64")
        struct_temp2 = 8u
      Else
        struct_temp2 = 4p
      If struct_temp41=
      {
        struct_temp6 = 1
        break
      }
      ; ** Create variables **
      struct_temp1 := "?" . struct_temp41
      If (!InStr(struct_temp2, "p"))
        %struct_name%%struct_temp1% = 0
      Else {
        %struct_name%%struct_temp1%=init
        %struct_name%%struct_temp1%=
      }
      ; ** Create reference **
      %struct_temp3% := %struct_temp3% . struct_temp2 . ":" . struct_temp41 "|"
      struct_sizeA += struct_temp2
    }
    If (struct_temp6)
      break
  }
  VarSetCapacity(%struct_name%, struct_sizeA, 0)
Return, True
}


; *********************************
; Retrieve a value from the structure
; *********************************
; Params: struct_name or struct?varname
; - specifying struct_name will retrieve/update values for all variables in the structure
; - specifying struct?varname will retrieve/update only the variable specified   
; *********************************
struct?(s_query)
{
  Global
  Local struct_sizeA, struct_sizeB, struct_temp1, struct_temp2, struct_temp3, struct_temp4, struct_temp5,

struct_temp6
  , struct_temp0, struct_temp00, struct_temp01, struct_temp02
  StringSplit, struct_temp, s_query, ?
  struct_temp3 = %struct_temp1%_%A_AhkScriptProcessID%
  If (!%struct_temp3%) {
    VarSetCapacity(%struct_temp3%, 0)
    ErrorLevel = Invalid_Struct
    Return
  }
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
    If (struct_temp02 = struct_temp2 OR struct_temp2 = "") {
      struct_temp5 := ExtractIntegerSL(%struct_temp1%, (struct_sizeA - struct_temp01), !InStr(struct_temp01, "u"),

struct_temp01)
      If (InStr(struct_sizeB, "p"))
        DllCall("lstrcpyA", "Str", %struct_temp1%?%struct_temp02%, "UInt", struct_temp5)
      Else
        %struct_temp1%?%struct_temp02% = %struct_temp5%
      If (struct_temp02 = struct_temp2)
        Return, %struct_temp1%?%struct_temp02%
    }
  }
  Return
}

; *********************************
; Send a value to the structure
; *********************************
; Params: struct_name or struct?varname
; - specifying struct_name will send/update values from all variables in the structure
; - specifying struct?varname will send/update only the variable specified   
; *********************************

struct@(s_modify, s_value="")
{
  Global
  Local struct_sizeA, struct_sizeB, struct_temp1, struct_temp2, struct_temp3, struct_temp4, struct_temp0
  StringSplit, struct_temp, s_modify, ?
  struct_temp3 = %struct_temp1%_%A_AhkScriptProcessID%
  If (!%struct_temp3%) {
    VarSetCapacity(%struct_temp3%, 0)
    ErrorLevel = Invalid_Struct
    Return
  }
  struct_sizeA = 0
  Loop, Parse, %struct_temp3%, |
  {
    Loop, Parse, A_LoopField, :
    {
      If (A_Index = "1") {
        struct_sizeA += A_LoopField
        struct_sizeB = %A_LoopField%
        struct_temp4 = %A_LoopField%
        EnvAdd, struct_sizeB, 0
      }
      Else {
        If (A_LoopField = struct_temp2 OR struct_temp2="") {
          If struct_temp2<>
            %struct_temp1%?%A_LoopField% = %s_value%
          If (InStr(struct_temp4, "p"))
            InsertIntegerSL(&%struct_temp1%?%A_LoopField%, %struct_temp1%, (struct_sizeA - struct_sizeB),

struct_sizeB)
          Else
            InsertIntegerSL(%struct_temp1%?%A_LoopField%, %struct_temp1%, (struct_sizeA - struct_sizeB),

struct_sizeB)
        }
      }
    }
  }
Return
}

; ********************************* 
; Required functions - ExtractInteger, InsertInteger
; - original versions from Version 1.0.44.06 of the AutoHotkey help file
; by Chris Mallett
; // Renamed in case someone is using a modified version of these functions
; // somewhere else in their code
; *********************************
ExtractIntegerSL(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4)
; pSource is a string (buffer) whose memory area contains a raw/binary integer at pOffset.
; The caller should pass true for pSigned to interpret the result as signed vs. unsigned.
; pSize is the size of PSource's integer in bytes (e.g. 4 bytes for a DWORD or Int).
; pSource must be ByRef to avoid corruption during the formal-to-actual copying process
; (since pSource might contain valid data beyond its first binary zero).
{
   Loop %pSize%  ; Build the integer by adding up its bytes.
      result += *(&pSource + pOffset + A_Index-1) << 8*(A_Index-1)
   if (!pIsSigned OR pSize > 4 OR result < 0x80000000)
      return result  ; Signed vs. unsigned doesn't matter in these cases.
   ; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart:
   return -(0xFFFFFFFF - result + 1)
}
; *********************************
InsertIntegerSL(pInteger, ByRef pDest, pOffset = 0, pSize = 4)
; The caller must ensure that pDest has sufficient capacity.  To preserve any existing contents in pDest,
; only pSize number of bytes starting at pOffset are altered in it.
{
   Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data.
      DllCall("RtlFillMemory", "UInt", &pDest + pOffset + A_Index-1, "UInt", 1, "UChar", pInteger >> 8*(A_Index-1)

& 0xFF)
}
; *********************************

