; ==============================================================================
; ==============================================================================
; HotKeyFormat(input)
; Formats readable hotkeystring to AHK Send format
; ==============================================================================
; ==============================================================================

HotKeyFormat(input)
{
  StringLower, tempstr, input
  shift:=False
  control:=False
  alt:=False

  ifinstring, tempstr, shift-
  {
    shift:=True
    StringReplace, tempstr, tempstr, shift-, , All
  }
  ifinstring, tempstr, ctrl-
  {
    control:=True
    StringReplace, tempstr, tempstr, ctrl-, , All
  }
  ifinstring, tempstr, alt-
  {
    alt:=True
    StringReplace, tempstr, tempstr, alt-, , All
  }
  ifinstring, tempstr, win-
  {
    lwin:=True
    StringReplace, tempstr, tempstr, win-, , All
  }
  output:= Trim(tempstr)
  if shift
  {
    output:="+" output
  }
  if Control
  {
    output:="^" output
  }
  if Alt
  {
    output:="!" output
  }
  if lWin
  {
    output:="#" output
  }
  output:= Trim(output)
  return output
}


; ==============================================================================
; ==============================================================================
; IsInsideVisibleArea(x,y,w,h)
; Checks if the coordinates are inside the visible area
; ==============================================================================
; ==============================================================================

IsInsideVisibleArea(x,y,w,h)
{
  isVis:=0
  SysGet, MonitorCount, MonitorCount
  Loop, %MonitorCount%
  {
    SysGet, Monitor%A_Index%, MonitorWorkArea, %A_Index%
    if (x+w-10>Monitor%A_Index%Left) and (x+10<Monitor%A_Index%Right) and (y+20>Monitor%A_Index%Top) and (y+20<Monitor%A_Index%Bottom)
      isVis:=1
  }
  return, IsVis
}


; ==============================================================================
; ==============================================================================
; LogLine(TxtLn,LogFile="Default")
; makes buffered write of TxtLn to LogFile
;
; LogWrite()
; writes log-buffer to disk; called via timer by LogLine or manually to flush 
; buffer
; ==============================================================================
; ==============================================================================

LogLine(TxtLn,LogFile="Default")
{
  global LogWriteBuffer
  FormatTime, TimeStr,, HH:mm:ss
  LogWriteBuffer[LogFile].= TimeStr "::" A_MSec ": " TxtLn "`n"
  If !LogWriteBuffer["Timer"]
  {
    LogWriteBuffer["Timer"]:=1
    SetTimer, LogWrite, -3000
  }
}

LogWrite()
{
  global LogWriteBuffer
  for LogFile, LogStr in LogWriteBuffer
  {
    If (LogFile="Default")
    {
      FileAppend, %LogStr%, % LogWriteBuffer["DefaultLogFile"]
      LogWriteBuffer["Default"]:=""  
    }
    else
    If (LogFile="Timer")
    {
    }
    else
    If (LogFile<>"DefaultLogFile" and LogStr<>"")
    {
      FileAppend, %LogStr%, %LogFile%
      LogWriteBuffer[LogFile]:=""  
    }
  }
  LogWriteBuffer["Timer"]:=0
}


; ==============================================================================
; ==============================================================================
; MsgBox(Text,Title="",Options=0,Timeout=0)
; Wrapper for msgbox command
; ==============================================================================
; ==============================================================================

MsgBox(Text,Title="",Options=0,Timeout=0)
{
  MsgBox, % Options, %Title%, %Text%, %Timeout%
}


