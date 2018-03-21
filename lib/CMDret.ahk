; ****************************************************************** 
; CMDret-AHK functions 
; version 1.10 beta 
; 
; Updated: Dec 5, 2006 
; by: corrupt 
; Code modifications and/or contributions made by: 
; Laszlo, shimanov, toralf, Wdb  
; ****************************************************************** 
; Usage: 
; CMDin - command to execute
; WorkingDir - full path to working directory (Optional) 
; ****************************************************************** 
; Known Issues: 
; - If using dir be sure to specify a path (example: cmd /c dir c:\)
; or specify a working directory    
; - Running 16 bit console applications may not produce output. Use 
; a 32 bit application to start the 16 bit process to receive output  
; ****************************************************************** 
; Additional requirements: 
; - none 
; ****************************************************************** 
; Code Start 
; ****************************************************************** 

CMDret_RunReturn(CMDin, WorkingDir=0) 
{ 
  Global cmdretPID
  tcWrk := WorkingDir=0 ? "Int" : "Str"
  idltm := A_TickCount + 20 
  CMsize = 1 
  VarSetCapacity(CMDout, 1, 32) 
  VarSetCapacity(sui,68, 0) 
  VarSetCapacity(pi, 16, 0) 
  VarSetCapacity(pa, 12, 0) 
  Loop, 4 { 
    DllCall("RtlFillMemory", UInt,&pa+A_Index-1, UInt,1, UChar,12 >> 8*A_Index-8) 
    DllCall("RtlFillMemory", UInt,&pa+8+A_Index-1, UInt,1, UChar,1 >> 8*A_Index-8) 
  } 
  IF (DllCall("CreatePipe", "UInt*",hRead, "UInt*",hWrite, "UInt",&pa, "Int",0) <> 0) { 
    Loop, 4 
      DllCall("RtlFillMemory", UInt,&sui+A_Index-1, UInt,1, UChar,68 >> 8*A_Index-8) 
    DllCall("GetStartupInfo", "UInt", &sui) 
    Loop, 4 { 
      DllCall("RtlFillMemory", UInt,&sui+44+A_Index-1, UInt,1, UChar,257 >> 8*A_Index-8) 
      DllCall("RtlFillMemory", UInt,&sui+60+A_Index-1, UInt,1, UChar,hWrite >> 8*A_Index-8) 
      DllCall("RtlFillMemory", UInt,&sui+64+A_Index-1, UInt,1, UChar,hWrite >> 8*A_Index-8) 
      DllCall("RtlFillMemory", UInt,&sui+48+A_Index-1, UInt,1, UChar,0 >> 8*A_Index-8) 
    }
    IF (DllCall("CreateProcess", Int,0, Str,CMDin, Int,0, Int,0, Int,1, "UInt",0, Int,0, tcWrk, WorkingDir, UInt,&sui, UInt,&pi) <> 0) {
      Loop, 4 
        cmdretPID += *(&pi+8+A_Index-1) << 8*A_Index-8 
      Loop { 
        idltm2 := A_TickCount - idltm 
        If (idltm2 < 10) { 
          DllCall("Sleep", Int, 10) 
          Continue 
        } 
        IF (DllCall("PeekNamedPipe", "uint", hRead, "uint", 0, "uint", 0, "uint", 0, "uint*", bSize, "uint", 0 ) <> 0 ) { 
          Process, Exist, %cmdretPID% 
          IF (ErrorLevel OR bSize > 0) { 
            IF (bSize > 0) { 
              VarSetCapacity(lpBuffer, bSize+1) 
              IF (DllCall("ReadFile", "UInt",hRead, "Str", lpBuffer, "Int",bSize, "UInt*",bRead, "Int",0) > 0) { 
                IF (bRead > 0) { 
                  TRead += bRead 
                  VarSetCapacity(CMcpy, (bRead+CMsize+1), 0) 
                  CMcpy = a 
                  DllCall("RtlMoveMemory", "UInt", &CMcpy, "UInt", &CMDout, "Int", CMsize) 
                  DllCall("RtlMoveMemory", "UInt", &CMcpy+CMsize, "UInt", &lpBuffer, "Int", bRead) 
                  CMsize += bRead 
                  VarSetCapacity(CMDout, (CMsize + 1), 0) 
                  CMDout=a    
                  DllCall("RtlMoveMemory", "UInt", &CMDout, "UInt", &CMcpy, "Int", CMsize) 
                  VarSetCapacity(CMDout, -1)   ; fix required by change in autohotkey v1.0.44.14 
                } 
              } 
            } 
          } 
          ELSE 
            break 
        } 
        ELSE 
          break 
        idltm := A_TickCount 
      } 
      cmdretPID= 
      DllCall("CloseHandle", UInt, hWrite) 
      DllCall("CloseHandle", UInt, hRead) 
    }
  } 
  IF (StrLen(CMDout) < TRead) { 
    VarSetCapacity(CMcpy, TRead, 32) 
    TRead2 = %TRead% 
    Loop { 
      DllCall("RtlZeroMemory", "UInt", &CMcpy, Int, TRead) 
      NULLptr := StrLen(CMDout) 
      cpsize := Tread - NULLptr 
      DllCall("RtlMoveMemory", "UInt", &CMcpy, "UInt", (&CMDout + NULLptr + 2), "Int", (cpsize - 1)) 
      DllCall("RtlZeroMemory", "UInt", (&CMDout + NULLptr), Int, cpsize) 
      DllCall("RtlMoveMemory", "UInt", (&CMDout + NULLptr), "UInt", &CMcpy, "Int", cpsize) 
      TRead2 -- 
      IF (StrLen(CMDout) > TRead2) 
        break 
    } 
  } 
  StringTrimLeft, CMDout, CMDout, 1 
  Return, CMDout 
} 
