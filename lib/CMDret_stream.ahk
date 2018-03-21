; ******************************************************************
; CMDret-AHK functions by corrupt
;
; CMDret_Stream
; version 0.03 beta
; Updated: Feb 19, 2007
;
; CMDret code modifications and/or contributions have been made by:
; Laszlo, shimanov, toralf, Wdb
; ******************************************************************
; Usage:
; CMDin - command to execute
; CMDname - type of output to process (Optional)
; WorkingDir - full path to working directory (Optional)
; ******************************************************************
; Known Issues:
; - If using dir be sure to specify a path (example: cmd /c dir c:\)
; or specify a working directory
; - Running 16 bit console applications may not produce output. Use
; a 32 bit application to start the 16 bit process to receive output
; ******************************************************************
; Additional requirements:
; - Your script must also contain a CMDret_Output function
;
; CMDret_Output(CMDout, CMDname="")
; Usage:
; CMDout - each line of output returned (1 line each time)
; CMDname - type of output to process (Optional)
; ******************************************************************
; Code Start
; ******************************************************************

CMDret_Stream(CMDin, CMDname="", WorkingDir=0)
{
  Global cmdretPID
  tcWrk := WorkingDir=0 ? "Int" : "Str"
  idltm := A_TickCount + 20
  LivePos = 1
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
        If (idltm2 < 15) {
          DllCall("Sleep", Int, 15)
          Continue
        }
        IF (DllCall("PeekNamedPipe", "uint", hRead, "uint", 0, "uint", 0, "uint", 0, "uint*", bSize, "uint", 0 ) <> 0 ) {
          Process, Exist, %cmdretPID%
          IF (ErrorLevel OR bSize > 0) {
            IF (bSize > 0) {
              VarSetCapacity(lpBuffer, bSize+1, 0)
              IF (DllCall("ReadFile", "UInt",hRead, "Str", lpBuffer, "Int",bSize, "UInt*",bRead, "Int",0) > 0) {
                IF (bRead > 0) {
                  IF (StrLen(lpBuffer) < bRead) {
                    VarSetCapacity(CMcpy, bRead, 32)
                    bRead2 = %bRead%
                    Loop {
                      DllCall("RtlZeroMemory", "UInt", &CMcpy, Int, bRead)
                      NULLptr := StrLen(lpBuffer)
                      cpsize := bread - NULLptr
                      DllCall("RtlMoveMemory", "UInt", &CMcpy, "UInt", (&lpBuffer + NULLptr + 2), "Int", (cpsize - 1))
                      DllCall("RtlZeroMemory", "UInt", (&lpBuffer + NULLptr), Int, cpsize)
                      DllCall("RtlMoveMemory", "UInt", (&lpBuffer + NULLptr), "UInt", &CMcpy, "Int", cpsize)
                      bRead2 --
                      IF (StrLen(lpBuffer) > bRead2)
                        break
                    }
                  }
              VarSetCapacity(lpBuffer, -1)
                  CMDout .= lpBuffer
                  bRead = 0
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
        LiveFound := RegExMatch(CMDout, "m)^(.*)", LiveOut, LivePos)
        If (LiveFound)
          SetTimer, cmdretSTR, 5
      }
      cmdretPID=
      DllCall("CloseHandle", UInt, hWrite)
      DllCall("CloseHandle", UInt, hRead)
    }
  }
  StringTrimLeft, LiveRes, CMDout, %LivePos%
  If LiveRes <>
    Loop, Parse, LiveRes, `n
    {
      FileLine = %A_LoopField%
      StringTrimRight, FileLine, FileLine, 1
      CMDret_Output(FileLine, CMDname)
    }
  StringTrimLeft, CMDout, CMDout, 1
  cmdretPID = 0
  Return, CMDout
cmdretSTR:
SetTimer, cmdretSTR, Off
If (LivePosLast <> LiveFound) {
  FileLine = %LiveOut1%
  LivePos := LiveFound + StrLen(FileLine) + 1
  LivePosLast := LivePos
  CMDret_Output(FileLine, CMDname)
}
Return
}