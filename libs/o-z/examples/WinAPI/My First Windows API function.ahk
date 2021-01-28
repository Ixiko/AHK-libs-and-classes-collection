; Language:       English
; Platform:       Win9x/NT
; Author:         Dr. Shajul <mail@shajul.net>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/* 
BOOL WINAPI GetDiskFreeSpaceEx(
  __in_opt   LPCTSTR lpDirectoryName,
  __out_opt  PULARGE_INTEGER lpFreeBytesAvailable,
  __out_opt  PULARGE_INTEGER lpTotalNumberOfBytes,
  __out_opt  PULARGE_INTEGER lpTotalNumberOfFreeBytes
);
 */
 
VarSetCapacity(bytesfree,8)
VarSetCapacity(bytesA,8)
VarSetCapacity(totalbytes,8)
;ret := DllCall("shell32.dll\SHGetDiskFreeSpaceExA", "Str", "M:\Temp", "UInt64P", bytesfree, "UInt64P", totalbytes, "UInt64P", bytesA)
ret := DllCall("GetDiskFreeSpaceEx", str, "M:\Temp", UInt64P, bytesA, UInt64P, totalbytes, UInt64P, bytesfree)
MsgBox, Errorlevel`: %Errorlevel%`nret`: %ret%`nbytesA`: %bytesA%`ntotalbytes`: %totalbytes%`nbytesfree`: %bytesfree%`n