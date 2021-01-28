/*
;fWaitForHungWindow(),fReplaceAtPos(),fCPULoad(),CreateNamedPipe()
;fAffinitySet(),fAffinityGet(),fGetPID(),fGlobalMemoryStatusEx()
;fEnumProcesses(),fSetIOPriority(),fSeDebugPrivilege(),fGetUsageCPUCores(),fEmptyMem(),fThumbMake(),fThumbRemove(),fConvertBase()
sDlls := "ntdll,advapi32,psapi,dwmapi,msvcrt"
#Include <Functions>
*/
Global sPtr := (A_PtrSize ? "Ptr" : "UInt")
      ,sUPtr := (A_PtrSize ? "UPtr" : "UInt")
      ,sUPtrP := (A_PtrSize ? "UPtr*" : "UInt*")
      ,sPtrP := (A_PtrSize ? "Ptr*" : "Int*")
      ,Ptr := (A_PtrSize ? Ptr : UInt)

;load dlls into memory
If sDlls
  {
  Global ntdll,advapi32,psapi,dwmapi,msvcrt
  Loop Parse,sDlls,`,
    %A_LoopField% := LoadLibrary(A_LoopField)
  }

/*
LoadLibrary & FreeLibrary by Bentschi
https://autohotkey.com/board/topic/90266-funktionen-loadlibrary-freelibrary-schnellere-dllcalls/
https://github.com/ahkscript/ASPDM/blob/master/Local-Client/Test_Packages/loadlibrary/Lib/loadlibrary.ahk

Speedup DllCall (excluded: "User32.dll", "Kernel32.dll", "ComCtl32.dll" & "Gdi32.dll")
See DllCall>Performance section

Ex:
Global psapi := LoadLibrary("psapi")
DllCall(psapi.EmptyWorkingSet,"UInt",h)
When done:
FreeLibrary("psapi")
*/
LoadLibrary(sDllName)
  {
  Static ref := {}
        ,iPtrSize92 := (A_PtrSize=4) ? 92 : 108
        ,iPtrSize96 := (A_PtrSize=4) ? 96 : 112
        ,iPtrSize100 := (A_PtrSize=4) ? 100 : 116
        ,sIsUni := (A_IsUnicode) ? "W" : "A"
  If (!(ptr := p := DllCall("LoadLibrary","Str",sDllName,sPtr)))
    Return 0
  ref[ptr,"count"] := (ref[ptr]) ? ref[ptr,"count"]+1 : 1
  p += NumGet(p+0,0x3c,"Int")+24
  o := {_ptr:ptr,__delete:func("FreeLibrary"),_ref:ref[ptr]}
  If (NumGet(p+0,iPtrSize92,"Uint")<1 || (ts := NumGet(p+0,iPtrSize96,"Uint")+ptr)=ptr || (te := NumGet(p+0,iPtrSize100,"Uint")+ts)=ts)
    Return o
  n := ptr+NumGet(ts+0,32,"Uint")
  Loop % NumGet(ts+0,24,"Uint")
    {
    If (p := NumGet(n+0,(A_Index-1)*4,"Uint"))
      {
      o[f := StrGet(ptr+p,"cp0")] := DllCall("GetProcAddress",sPtr,ptr,"AStr",f,sPtr)
      If (Substr(f,0)==(sIsUni))
        o[Substr(f,1,-1)] := o[f]
      }
    }
  Return o
  }
/*
FreeLibrary(lib)
  {
  Static sPtr := (A_PtrSize ? "Ptr" : "UInt")
  If (lib._ref.count > =1)
    lib._ref.count -= 1
  If (lib._ref.count < 1)
    DllCall("FreeLibrary",sPtr,lib._ptr)
  }
*/

;returns hProc from PID,name.exe,name
fOpenProcess(sFlags,siProc := "")
  {
  Static bInheritHandle := False

  If siProc Is Integer
    Return DllCall("OpenProcess",UInt,sFlags,Int,bInheritHandle,Int,siProc)

  Process Exist,%siProc%
  If ErrorLevel
    Return DllCall("OpenProcess",UInt,sFlags,Int,bInheritHandle,Int,ErrorLevel)

  Process Exist,%siProc%.exe
  If ErrorLevel
    Return DllCall("OpenProcess",UInt,sFlags,Int,bInheritHandle,Int,ErrorLevel)

  Return False
  }

/*
Set process IO Priority
-1 makes it blank in process hacker, and 7 in process explorer (Critical?).
0=very low 1=low 2=normal 3=high (default: 0)

sets pid 11441 to very low io
fSetIOPriority(11441)
supposed to set process to high (high doesn't work for some reason)
fSetIOPriority("explorer.exe",3)

made by ChoGGi, and thanks to ReactOS DDK ntddk.h
*/

fSetIOPriority(sProc,iPriority := 0)
  {
  ;ProcessIoPriority = 0x21,INFO_LENGTH = 4,PROCESS_SET_INFORMATION = 0x200
  hProc := fOpenProcess(0x200,sProc)

  DllCall(ntdll.NtSetInformationProcess,sPtr,hProc,Int,0x21
    ,sUPtrP,iPriority,UInt,4)

  DllCall("CloseHandle",sPtr,hProc)
  }

/*
5=normal, 1=very low

https://msdn.microsoft.com/en-us/library/windows/desktop/hh448387.aspx
The memory priority of a process serves
as a hint to the memory manager when it trims pages from the working set.
*/
fSetPagePriority(sProc,iPriority := 1)
  {
  ;ProcessPagePriority = 0x27,INFO_LENGTH = 4,PROCESS_SET_INFORMATION = 0x200
  hProc := fOpenProcess(0x200,sProc)

  DllCall(ntdll.NtSetInformationProcess,sPtr,hProc,Int,0x27
    ,sUPtrP,iPriority,UInt,4)

  DllCall("CloseHandle",sPtr,hProc)
  }

/*
NtSetInformationProcess(
  IN HANDLE               ProcessHandle,
  IN PROCESS_INFORMATION_CLASS ProcessInformationClass,
  IN PVOID                ProcessInformation,
  IN ULONG                ProcessInformationLength
);

NtQuerySystemInformation(
  _In_      SYSTEM_INFORMATION_CLASS SystemInformationClass,
  _Inout_   PVOID                    SystemInformation,
  _In_      ULONG                    SystemInformationLength,
  _Out_opt_ PULONG                   ReturnLength
);

https://msdn.microsoft.com/library/ms684320.aspx
HANDLE WINAPI OpenProcess(
  _In_ DWORD dwDesiredAccess,
  _In_ BOOL  bInheritHandle,
  _In_ DWORD dwProcessId
);
PROCESS_SET_INFORMATION (0x0200)
PROCESS_QUERY_INFORMATION (0x0400)
0x0200 (512) + 0x0400 (1024) = 1536

https://msdn.microsoft.com/library/ms686223.aspx
BOOL WINAPI SetProcessAffinityMask(
  _In_ HANDLE    hProcess,
  _In_ DWORD_PTR dwProcessAffinityMask
);

https://msdn.microsoft.com/library/ms683213.aspx
BOOL WINAPI GetProcessAffinityMask(
  _In_  HANDLE     hProcess,
  _Out_ PDWORD_PTR lpProcessAffinityMask,
  _Out_ PDWORD_PTR lpSystemAffinityMask
);



Affinity_Set(CPUmask,{PID/Process name})
By SKAN
https://autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/page-7#post_id_191053
*/
fAffinitySet(sProc,sCPU)
  {
  If !InStr(sCPU,"0x")
    sCPU := "0x" sCPU
  ;PROCESS_SET_INFORMATION := 0x200
  hProc := fOpenProcess(0x200,sProc)

  DllCall("SetProcessAffinityMask",sPtr,hProc,sUPtr,sCPU)
  DllCall("CloseHandle",sPtr,hProc)
  }

/*
SetFormat IntegerFast,Hex
ProcAff := fAffinityGet("dopus.exe")
ProcAff := StrReplace(ProcAff,"0x")
msgbox %ProcAff%
Return

https://autohotkey.com/boards/viewtopic.php?t=18233
By Coco
*/
fAffinityGet(sProc)
  {
  ;PROCESS_QUERY_INFORMATION := 0x400
  hProc := fOpenProcess(0x400,sProc)

  VarSetCapacity(PAf,8,0)
  ;VarSetCapacity(PAf,8,0),VarSetCapacity(SAf,8,0)
  ;DllCall("GetProcessAffinityMask",sPtr,hPr,sUPtrP,&PAf,"UPtrP",&SAf)
  DllCall("GetProcessAffinityMask",sPtr,hProc,sPtr,&PAf)
  DllCall("CloseHandle",sPtr,hProc)
  Return NumGet(PAf,0,"Int64")
  }

/*
https://msdn.microsoft.com/library/ms686714.aspx
terminates without unloading dlls

By ChoGGi

fTerminateProcess(sProc)
  {
  hProc := fOpenProcess(0x1,sProc)
  DllCall("TerminateProcess",sPtr,hProc,"Int",0)
  DllCall("CloseHandle","Int",hProc)
  }
*/

/*
By heresy
https://autohotkey.com/board/topic/30042-run-ahk-scripts-with-less-half-or-even-less-memory-usage/

PROCESS_SET_QUOTA (0x0100) 256
PROCESS_QUERY_LIMITED_INFORMATION (0x1000) 4096
*/
fEmptyMem(sProc)
  {
  ;SETQUOTA_QUERYLIMITEDINFO := 0x1100
  ;hProc := fOpenProcess(0x1100,sProc)
  hProc := fOpenProcess(0x1000|0x100,sProc)

  DllCall(psapi.EmptyWorkingSet,sPtr,hProc)
  DllCall("CloseHandle",sPtr,hProc)
  }

/*
returns list of processes
PID|PID
or fEnumProcesses(1)
PID:processname.exe|PID:processname.exe


https://autohotkey.com/board/topic/79151-ahk-task-manager/
By EmanResu
*/
fEnumProcesses(bWhich := 0)
  {
  Static iPtrSize64 := (A_PtrSize=8 ? "64" : "60")
        ,iPtrSize80 := (A_PtrSize=8 ? "80" : "68")
	VarSetCapacity(pSPIBuf,0,0)
	VarSetCapacity(ReturnLength,A_PtrSize,0)

	;SystemProcessInformation := 0x5
	; Get the required size of the buffer
	DllCall(ntdll.NtQuerySystemInformation, UInt, 0x5, Ptr, &pSPIBuf
    , UInt, 0 , Ptr, &ReturnLength)

	bufSize := NumGet(ReturnLength)
	VarSetCapacity(pSPIBuf,bufSize,0)

	DllCall(ntdll.NtQuerySystemInformation, UInt, 0x5, Ptr, &pSPIBuf
    , UInt, bufSize, Ptr, &ReturnLength)

	pCur := NumGet(&pSPIBuf,0,"UInt")
  oProcList := {}
  If bWhich
    {
    Loop
      {
      ;oProcList[procname] := pid
      oProcList[(NumGet(&pSPIBuf+pCur,iPtrSize80))] := StrGet(NumGet(&pSPIBuf+pCur,iPtrSize64))
      ;out of entries?
      If !NumGet(&pSPIBuf+pCur,0,"UInt")
        Return oProcList
      ;next entry
      pCur += NumGet(&pSPIBuf+pCur,0,"UInt")
      }
    }
  Loop
    {
    oProcList[(NumGet(&pSPIBuf+pCur,iPtrSize80))] := 1

    If !NumGet(&pSPIBuf+pCur,0,"UInt")
      Return oProcList
    pCur += NumGet(&pSPIBuf+pCur,0,"UInt")
    }
  }
/*
so we can change service processes

from ahk manual
Process function Example #4:
*/
fSeDebugPrivilege()
  {
  Static iScriptPID := DllCall("GetCurrentProcessId")
  ;PROCESS_QUERY_INFORMATION := 0x400
  ;h := DllCall("OpenProcess",sPtr,PROCESS_QUERY_INFORMATION,"Int",false,"UInt",iScriptPID,sPtr)
  h := fOpenProcess(0x400,iScriptPID)

  ; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
  DllCall(advapi32.OpenProcessToken,sPtr,h,"UInt",32,sPtrP,t)
  VarSetCapacity(ti,16,0)  ; structure of privileges
  NumPut(1,ti,0,"UInt")  ; one entry in the privileges array...
  ; Retrieves the locally unique identifier of the debug privilege:
  DllCall(advapi32.LookupPrivilegeValue,sPtr,0,"Str","SeDebugPrivilege","Int64P",luid)
  NumPut(luid,ti,4,"Int64")
  NumPut(2,ti,12,"UInt")  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
  ; Update the privileges of this process with the new access token:
  r := DllCall(advapi32.AdjustTokenPrivileges,sPtr,t,"Int",false,sPtr,&ti,"UInt",0,sPtr,0,sPtr,0)
  DllCall("CloseHandle",sPtr,t)  ; close this access token handle to save memory
  DllCall("CloseHandle",sPtr,h)  ; close this process handle to save memory
  Return r
  }

/*
https://autohotkey.com/board/topic/31384-vistas-live-thumnail-view
By skrommel

WinGet source,Id,A
Gui +HwndThumbnailId
fThumbMake(source,ThumbnailId)

fThumbMake(thumb window,AHK window)
*/
fThumbMake(pSource,pTarget,iZoom := .5)
  {
  ;fileappend %pSource%`n,1.txt
  VarSetCapacity(thumbnail,4,0)
  DllCall(dwmapi.DwmRegisterThumbnail,"UInt",pTarget,"UInt",pSource,"UInt",&thumbnail)
  thumbnail := NumGet(thumbnail)

  /*
  DWM_TNP_RECTDESTINATION (0x00000001)
  Indicates a value for rcDestination has been specified.
  DWM_TNP_RECTSOURCE (0x00000002)
  Indicates a value for rcSource has been specified.
  DWM_TNP_OPACITY (0x00000004)
  Indicates a value for opacity has been specified.
  DWM_TNP_VISIBLE (0x00000008)
  Indicates a value for fVisible has been specified.
  DWM_TNP_SOURCECLIENTAREAONLY (0x00000010)
  Indicates a value for fSourceClientAreaOnly has been specified.
  */

  dwFlags := 0x1 | 0x2 | 0x10
  opacity := 255
  fVisible := 1
  fSourceClientAreaOnly := 1


  WinGetPos wx,wy,ww,wh,ahk_id %pTarget%

  VarSetCapacity(dskThumbProps,45,0)
  ;struct _DWM_THUMBNAIL_PROPERTIES
  NumPut(dwFlags,dskThumbProps,0,"UInt")
  NumPut(0,dskThumbProps,4,"Int")
  NumPut(0,dskThumbProps,8,"Int")
  NumPut(ww,dskThumbProps,12,"Int")
  NumPut(wh,dskThumbProps,16,"Int")
  NumPut(0,dskThumbProps,20,"Int")
  NumPut(0,dskThumbProps,24,"Int")
  NumPut(ww/iZoom,dskThumbProps,28,"Int")
  NumPut(wh/iZoom,dskThumbProps,32,"Int")
  /*
int xDest - the x-coordinate of the rendered thumbnail inside the destination window
int yDest - the y-coordinate of the rendered thumbnail inside the destination window
int wDest - the width of the rendered thumbnail inside the destination window
int hDest - the height of the rendered thumbnail inside the destination window
int xSource - the x-coordinate of the area that will be shown inside the thumbnail
int ySource - the y-coordinate of the area that will be shown inside the thumbnail
int wSource - the width of the area that will be shown inside the thumbnail
int hSource - the height of the area that will be shown inside the thumbnail

NumPut(xDest, dskThumbProps, 4, "Int")
NumPut(yDest, dskThumbProps, 8, "Int")
NumPut(wDest+xDest, dskThumbProps, 12, "Int")
NumPut(hDest+yDest, dskThumbProps, 16, "Int")

NumPut(xSource, dskThumbProps, 20, "Int")
NumPut(ySource, dskThumbProps, 24, "Int")
NumPut(wSource+xSource, dskThumbProps, 28, "Int")
NumPut(hSource+ySource, dskThumbProps, 32, "Int")
  */

  NumPut(opacity,dskThumbProps,36,"UChar")
  NumPut(fVisible,dskThumbProps,37,"Int")
  NumPut(fSourceClientAreaOnly,dskThumbProps,41,"Int")
  ;blah := ww ":" wh
  ;FileAppend %blah%`n,1.txt
  DllCall(dwmapi.DwmUpdateThumbnailProperties,"UInt",thumbnail,"UInt",&dskThumbProps)
  Return thumbnail
  }

fThumbRemove(thumbnail)
  {
  ;Return DllCall(dwmapi.DwmUnregisterThumbnail,"UInt",thumbnail)
  DllCall(dwmapi.DwmUnregisterThumbnail,"UInt",thumbnail)
  }

/*
https://github.com/jNizM/AHK_Scripts/blob/master/src/performance_counter/NtQuery_CPU_Usage.ahk
By jNizM
https://msdn.microsoft.com/library/ms724509.aspx

iCores := fGetUsageCPUCores().MaxIndex()
iCPULoad := fGetUsageCPUCores()
Loop % iCores
  MsgBox % iCPULoad[A_Index]
*/

fGetUsageCPUCores()
  {
  Static LI := {}
  ;SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION := 0x8
  size := VarSetCapacity(buf,0,0)
  DllCall(ntdll.NtQuerySystemInformation, "Int", 0x8, sPtr, &buf, "UInt", 0, "UInt*", size)
  size := VarSetCapacity(buf,size,0)
  If DllCall(ntdll.NtQuerySystemInformation, "Int", 0x8, sPtr, &buf, "UInt", size, "UInt*", 0)
    Return "*" ErrorLevel
  CI := {}, Offset := 0, CPU_COUNT := size / 48
  Loop % CPU_COUNT
    {
    CI[A_Index, "IT"] := NumGet(buf, Offset +  0, "UInt64")    ; IdleTime
    CI[A_Index, "KT"] := NumGet(buf, Offset +  8, "UInt64")    ; KernelTime
    CI[A_Index, "UT"] := NumGet(buf, Offset + 16, "UInt64")    ; UserTime
    Offset += 48
    }
  CPU_USAGE := {}
  Loop % CPU_COUNT
    CPU_USAGE[A_Index] := 100 - (CI[A_Index].IT - LI[A_Index].IT) / (CI[A_Index].KT - LI[A_Index].KT + CI[A_Index].UT - LI[A_Index].UT) * 100
  Return CPU_USAGE, LI := CI
  }

;fGetProcessTimes("processchanger.exe")
;msgbox % Round(fGetProcessTimes("processchanger.exe"))
;Sean and Laszlo: http://www.autohotkey.com/community/viewtopic.php?t=18913
fGetProcessTimes(sProc)
  {
  Static nOldKernTime := 0,nOldUserTime := 0
  ;PROCESS_QUERY_INFORMATION := 0x400
  hProc := fOpenProcess(0x400,sProc)

  DllCall( "GetProcessTimes", Ptr,hProc, Int64P,nCreationTime, Int64P,nExitTime, Int64P,nNewKernTime
                            , Int64P,nNewUserTime )
  nProcTime    := (nNewKernTime-nOldKernTime + nNewUserTime-nOldUserTime)*1.e-5
  nOldKernTime := nNewKernTime, nOldUserTime := nNewUserTime
  DllCall("CloseHandle", "Uint", hProc)
  Return nProcTime
  }


/*
by jNizM
https://autohotkey.com/boards/viewtopic.php?t=142

GSMEx := fGlobalMemoryStatusEx()
TotalPhys := GSMEx.TotalPhys / 1048576
AvailPhys := GSMEx.AvailPhys / 1048576
iFoundPos := InStr(TotalPhys,".")
TotalPhys := SubStr(TotalPhys,1,iFoundPos - 1) " MB"
iFoundPos := InStr(AvailPhys,".")
AvailPhys := SubStr(AvailPhys,1,iFoundPos - 1) " MB"
UsedPercent := GSMEx.MemoryLoad " %"
msgbox TotalPhys: %TotalPhys%`nAvailPhys: %AvailPhys%`nUsedPercent: %UsedPercent%
*/

fGlobalMemoryStatusEx() ; https://msdn.microsoft.com/library/aa366589.aspx
  {
  Static MSEX, init := NumPut(VarSetCapacity(MSEX,64,0),MSEX,"UInt")
  If !DllCall("GlobalMemoryStatusEx",sPtr,&MSEX)
    Throw Exception("Call to GlobalMemoryStatusEx failed: " A_LastError,-1)
  Return {MemoryLoad: NumGet(MSEX,4,"UInt"),TotalPhys: NumGet(MSEX,8,"UInt64"),AvailPhys: NumGet(MSEX,16,"UInt64")}
  }

fMemoryLoad()
  {
  Static MSEX, init := NumPut(VarSetCapacity(MSEX,64,0),MSEX,"UInt")
  If !DllCall("GlobalMemoryStatusEx",sPtr,&MSEX)
    Throw Exception("Call to GlobalMemoryStatusEx failed: " A_LastError,-1)
  Return NumGet(MSEX,4,"UInt")
  }

/*
oRandList := [1,2,4,8,10,20,40,80,100,200,400,800]
iAffinity := fRandItem(oRandList)
fAffinitySet(iAffinity,iScriptPID)
*/
fRandItem(oInput)
  {
  Random iRandNum,1,% oInput.length()
  Return oInput[iRandNum]
  }

;wait upto iTimeOutMS for hProc to not be hung
fWaitForHungWindow(sWinId,iTimeOutMS := 15000)
  {
  Return DllCall("SendMessageTimeout","UInt",sWinId,"UInt",0x0,"Int",0,"Int",0,"UInt",0x2,"UInt",iTimeOutMS,"UInt*",0)
  }

/*
https://autohotkey.com/boards/viewtopic.php?t=17236
replace a substring at pos
*/
fReplaceAtPos(sString,iPosition,iLength := 1)
  {
  ;IfGreater iPosition, % StrLen(sString) + 1 - iLength
  If (iPosition > StrLen(sString) + 1 - iLength)
    Return sString
  Return SubStr(sString,1,iPosition - 1) "`n" SubStr(sString,iPosition + iLength)
  }

/*
	Function:	SetHook
	Parameter:
    oHandler	- Name of the function to call on shell events. Omit to disable the active hook.
    hProc	- defaults to script hwnd
	Handler:
		Event		- Event for which handler is called.
		Param		- Parameter of the handler. Parameters are given bellow for each reason.
 >	OnShell(Reason, Param) {
 >		static WINDOWCREATED=1, WINDOWDESTROYED=2, WINDOWACTIVATED=4, GETMINRECT=5, REDRAW=6, TASKMAN=7, APPCOMMAND=12
 >	}

	Param:
		WINDOWACTIVATED	-	The HWND handle of the activated window.
		WINDOWREPLACING	-	The HWND handle of the window replacing the top-level window.
		WINDOWCREATED	-	The HWND handle of the window being created.
		WINDOWDESTROYED	-	The HWND handle of the top-level window being destroyed.
		TASKMAN			-	Can be ignored.
		REDRAW			-	The HWND handle of the window that needs to be redrawn.
	Remarks:
		Requires explorer to be set as a shell in order to work.
		GETMINRECT		-	A pointer to a RECT structure.
	Returns:
		0 on failure, name of the previous hook procedure on success.
	Reference:
		<http://msdn.microsoft.com/library/ms644989.aspx>
 */
fShellHook(oHandler := "",hProc := 0)
  {
	If !hProc
    hProc := A_ScriptHwnd

	If !oHandler
		Return DllCall("DeregisterShellHookWindow","Uint",hProc)

	If !DllCall("RegisterShellHookWindow","UInt",hProc)
		Return 0
	Return OnMessage(DllCall("RegisterWindowMessage","Str","SHELLHOOK"),oHandler)
  }
/*
iNum := 42
. "to Binary:`t`t"      ConvertBase(iNum, 10, 2)
. "to Octal:`t`t"       ConvertBase(iNum, 10, 8)
. "to Hexadecimal:`t"   ConvertBase(iNum, 10, 16)
iHex := 2A
. "to Decimal:`t"       ConvertBase(iHex, 16, 10)
. "to Octal:`t`t"       ConvertBase(iHex, 16, 8)
. "to Binary:`t`t"      ConvertBase(iHex, 16, 2)
or in 1 function to convert base from 2 to 36

https://autohotkey.com/boards/viewtopic.php?t=3607
By jNizM
*/
fConvertBase(iNum,InputBase := 10,OutputBase := 16)
  {
  VarSetCapacity(s,65,0)
  If A_IsUnicode
    {
    value := DllCall(msvcrt._wcstoui64, "Str", iNum, "UInt", 0, "UInt", InputBase, "CDECL Int64")
    DllCall(msvcrt._i64tow, "Int64", value, "Str", s, "UInt", OutputBase, "CDECL")
    Return 0xs
    }
  value := DllCall(msvcrt._strtoui64, "Str", iNum, "UInt", 0, "UInt", InputBase, "CDECL Int64")
  DllCall(msvcrt._i64toa, "Int64", value, "Str", s, "UInt", OutputBase, "CDECL")
  Return 0xs
  }
