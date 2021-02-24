; ----------------------------------------------------------------------------------------------------------------------
; Name .........: SysProcInfo library
; Description ..: System and process performance information library.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Unicode
; Author .......: Cyruz (http://ciroprincipe.info) - Thanks to Sean & Laszlo.
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Jan. 12, 2014 - v0.1 - First version.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: SysProcInfo_ToggleTimer
; Description ..: Sets itself as a timer and periodically call the library functions, returning the results as object.
; Parameters ...: aParams* is a variadic required to work with timers. Allowed parameters, to be passed in the following
; ..............: strict sequential order, are:
; ..............: ACTION - Timer verb, can be "START" or "STOP". If "STOP" avoid the next parameters.
; ..............: MODE   - Requested info. Can be 1 for system, 2 for processes, 3 for both.
; ..............: HWND   - Handle of the window that will be notified.
; ..............: MSG    - Message that will be sent to the window to be notified.
; ..............: TIME   - Timer timeout.
; ..............: ARRPID - Array of PID of the processes we need info. Required only if MODE = 2 or = 3.
; Return .......: Nonzero on success, zero on error.
; ..............: -1 if the function is not called following the START -> STOP order convention.
; ..............: -2 if the wrong number of parameters is passed.
; ..............: -3 if the timer verb is different from "START" or "STOP".
; How to call ..: The function can be called in two ways, to start and stop the timer:
; ..............: 1. SysProcInfo_ToggleTimer("START", MODE, HWND, MSG, TIME, ARRPID)
; ..............: 2. SysProcInfo_ToggleTimer("STOP")
; How to use ...: Write a function to monitor MSG and receive notifications. The notification will be sent with the
; ..............: following value of wParam/lParam:
; ..............: wParam - 0
; ..............: lParam - Object address, use "obj := Object(lParam)" to get a reference to the object.
; Remarks ......: The object structure is:
; ..............: obj.SystemData                            - Object containing system performance information.
; ..............: obj.SystemData.SystemTimes                - Percentage of total CPU Load.
; ..............: obj.SystemData.MemoryLoad                 - Percentage of physical memory in use.
; ..............: obj.SystemData.CommitTotal                - Number of pages currently committed by the system.
; ..............: obj.SystemData.CommitLimit                - Max number of pages that can be committed by the system.
; ..............: obj.SystemData.CommitPeak                 - Max number of pages committed since last reboot.
; ..............: obj.SystemData.PhysicalTotal              - The amount of actual physical memory, in pages.
; ..............: obj.SystemData.PhysicalAvailable          - The amount of available physical memory, in pages.
; ..............: obj.SystemData.PhysicalUsed               - The amount of used physical memory, in pages.
; ..............: obj.SystemData.SystemCache                - The amount of system cache memory, in pages.
; ..............: obj.SystemData.KernelTotal                - Memory in paged and nonpaged kernel pools, in pages.
; ..............: obj.SystemData.KernelPaged                - Memory currently in the paged kernel pool, in pages.
; ..............: obj.SystemData.KernelNonpaged             - Memory currently in the nonpaged kernel pool, in pages.
; ..............: obj.SystemData.PageSize                   - The size of a page, in bytes.
; ..............: obj.SystemData.HandleCount                - The current number of open handles.
; ..............: obj.SystemData.ProcessCount               - The current number of processes.
; ..............: obj.SystemData.ThreadCount                - The current number of threads.
; ..............: obj.ProcData[]                            - Array of objects containing processes performance info.
; ..............: obj.ProcData[].Pid                        - Process identifier.
; ..............: obj.ProcData[].ProcessTimes               - Process CPU Load Time.
; ..............: obj.ProcData[].PageFaultCount             - The number of page faults.
; ..............: obj.ProcData[].PeakWorkingSetSize         - The peak working set size, in bytes.
; ..............: obj.ProcData[].WorkingSetSize             - The current working set size, in bytes.
; ..............: obj.ProcData[].QuotaPeakPagedPoolUsage    - The peak paged pool usage, in bytes.
; ..............: obj.ProcData[].QuotaPagedPoolUsage        - The current paged pool usage, in bytes.
; ..............: obj.ProcData[].QuotaPeakNonPagedPoolUsage - The peak nonpaged pool usage, in bytes.
; ..............: obj.ProcData[].QuotaNonPagedPoolUsage     - The current nonpaged pool usage, in bytes.
; ..............: obj.ProcData[].PagefileUsage              - The Commit Charge value in bytes for this process.
; ..............: obj.ProcData[].PeakPagefileUsage          - The peak value in bytes of the process Commit Charge.
; ..............: obj.ProcData[].ReadOperationCount         - The number of read operations performed.
; ..............: obj.ProcData[].WriteOperationCount        - The number of write operations performed.
; ..............: obj.ProcData[].OtherOperationCount        - The number of I/O operations performed (no read/write).
; ..............: obj.ProcData[].ReadTransferCount          - The number of bytes read.
; ..............: obj.ProcData[].WriteTransferCount         - The number of bytes written.
; ..............: obj.ProcData[].OtherTransferCount         - The number of bytes transferred (no read/write).
; ..............: obj.ProcData[].CycleTime                  - Sum of the cycle time of all threads of the process.
; ..............: obj.ProcData[].HandleCount                - Number of open handles that belong to the process.
; ..............: obj.ProcData[].GdiHandles                 - Number of GDI handles that belong to the process.
; ..............: obj.ProcData[].UserHandles                - Number of USER handles that belong to the process.
; ..............: obj.ProcData[].PriorityClass              - Priority class for the process.
; ----------------------------------------------------------------------------------------------------------------------
SysProcInfo_ToggleTimer(aParams*){
    Static B_RUNNING, B_FIRSTRUN, N_MODE, H_WND, N_MESSAGE, N_TIME, A_PIDS, A_PROCS, OBJ_INFO, P_TIMER

    If ( aParams[1] == "START" )
    {   ; Called by the user.
        If ( B_RUNNING )
            Return -1
        If ( aParams[2]  < 1 || aParams[2] > 3          )
        || ( aParams[2] == 1 && aParams.MaxIndex() != 5 )
        || ( aParams[2]  > 1 && aParams.MaxIndex() != 6 )
        || ( aParams[2]  > 1 && !isObject(aParams[6])   )
            Return -2

        ; Parameters parsing.
        N_MODE := aParams[2], H_WND := aParams[3], N_MESSAGE := aParams[4], N_TIME := aParams[5], A_PIDS := aParams[6]

        B_RUNNING := 1, B_FIRSTRUN := 1, A_PROCS := Object(), OBJ_INFO := Object()
        Loop % A_PIDS.MaxIndex()
            A_PROCS[A_Index] := DllCall( "OpenProcess", UInt,0x0400|0x0010, Int,0, UInt,A_PIDS[A_Index] )

        Return P_TIMER := DllCall( "SetTimer", Ptr,0, UInt,0, UInt,N_TIME, Ptr,RegisterCallback(A_ThisFunc) )
    }
    Else If ( aParams[1] == "STOP" )
    {   ; Called by the user.
        If ( !B_RUNNING )
            Return -1
        If ( aParams.MaxIndex() > 1 )
            Return -2

        Loop % A_PROCS.MaxIndex()
            DllCall( "CloseHandle", Ptr,A_PROCS[A_Index] )

        B_RUNNING := 0
        A_PIDS := "", A_PROCS := "", OBJ_INFO := "" ; Release objects.

        Return DllCall( "KillTimer", Ptr,0, Ptr,P_TIMER )
    }
    Else
    {   ; Called by the timer.
        If aParams[1] is not xdigit ; Return an error if the first parameter is not a hwnd.
            Return -3

        f := A_FormatInteger
        SetFormat, Float, 6.2
        If ( N_MODE == 1 || N_MODE == 3 )
        {
            OBJ_INFO.SystemData             := SysProcInfo_GetSystemMemoryStatus()
            OBJ_INFO.SystemData.SystemTimes := SysProcInfo_GetSystemTimes()
        }
        If ( N_MODE == 2 || N_MODE == 3 )
        {
            If (B_FIRSTRUN)
                OBJ_INFO.ProcData := Object()
            Loop % A_PROCS.MaxIndex()
            {
                If ( B_FIRSTRUN )
                    nOldKernTime := 0
                  , nOldUserTime := 0
                Else
                    nOldKernTime := OBJ_INFO.ProcData[A_Index].OldKernTime
                  , nOldUserTime := OBJ_INFO.ProcData[A_Index].OldUserTime

                OBJ_INFO.ProcData[A_Index]              := SysProcInfo_GetProcessMemoryInfo(A_PROCS[A_Index])
                OBJ_INFO.ProcData[A_Index].Pid          := A_PIDS[A_Index]
                OBJ_INFO.ProcData[A_Index].ProcessTimes := SysProcInfo_GetProcessTimes( A_PROCS[A_Index], nOldKernTime
                                                                                      , nOldUserTime )
                OBJ_INFO.ProcData[A_Index].OldKernTime  := nOldKernTime ; Needed because of ByRef limitations.
                OBJ_INFO.ProcData[A_Index].OldUserTime  := nOldUserTime ; Needed because of ByRef limitations.
            }
        }
        SetFormat, Integer, %f%

        (B_FIRSTRUN) ? B_FIRSTRUN := 0
                     : DllCall( "SendNotifyMessage", Ptr,H_WND, UInt,N_MESSAGE, Ptr,0, Ptr,Object(OBJ_INFO) )
    }
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: SysProcInfo_GetSystemTimes
; Description ..: Returns the percentage of the total CPU Load. Call it repeateadly for consistent results.
; Thanks .......: Sean and Laszlo: http://www.autohotkey.com/community/viewtopic.php?t=18913
; ----------------------------------------------------------------------------------------------------------------------
SysProcInfo_GetSystemTimes(){
    Static nOldIdleTime, nOldKernTime, nOldUserTime, nNewIdleTime, nNewKernTime, nNewUserTime
    nOldIdleTime := nNewIdleTime, nOldKernTime := nNewKernTime, nOldUserTime := nNewUserTime
    DllCall( "GetSystemTimes", Int64P,nNewIdleTime, Int64P,nNewKernTime, Int64P,nNewUserTime )
    Return (1 - (nNewIdleTime-nOldIdleTime)/(nNewKernTime-nOldKernTime + nNewUserTime-nOldUserTime)) * 100
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: SysProcInfo_GetSystemMemoryStatus
; Description ..: Retrieves information about the system's current usage of both physical and virtual memory.
; Return .......: An object containing system performance information, structured like the following:
; ..............: obj.MemoryLoad        - Percentage of physical memory in use.
; ..............: obj.CommitTotal       - Number of pages currently committed by the system.
; ..............: obj.CommitLimit       - Max number of pages that can be committed by the system.
; ..............: obj.CommitPeak        - Max number of pages committed since last reboot.
; ..............: obj.PhysicalTotal     - The amount of actual physical memory, in pages.
; ..............: obj.PhysicalAvailable - The amount of available physical memory, in pages.
; ..............: obj.PhysicalUsed      - The amount of used physical memory, in pages.
; ..............: obj.SystemCache       - The amount of system cache memory, in pages.
; ..............: obj.KernelTotal       - Memory in paged and nonpaged kernel pools, in pages.
; ..............: obj.KernelPaged       - Memory currently in the paged kernel pool, in pages.
; ..............: obj.KernelNonpaged    - Memory currently in the nonpaged kernel pool, in pages.
; ..............: obj.PageSize          - The size of a page, in bytes.
; ..............: obj.HandleCount       - The current number of open handles.
; ..............: obj.ProcessCount      - The current number of processes.
; ..............: obj.ThreadCount       - The current number of threads.
; ----------------------------------------------------------------------------------------------------------------------
SysProcInfo_GetSystemMemoryStatus(){
    nSz := VarSetCapacity(PERFORMANCEINFO, (A_PtrSize == 4) ? 56 : 104), NumPut(nSz, PERFORMANCEINFO, 0)
    DllCall( "psapi.dll\GetPerformanceInfo", Ptr,&PERFORMANCEINFO, UInt,nSz )
    nPhysUsed := NumGet(PERFORMANCEINFO, A_PtrSize*4, "UPtr") - NumGet(PERFORMANCEINFO, A_PtrSize*5, "UPtr")
    nMemLoad  := Ceil((nPhysUsed*100) / NumGet(PERFORMANCEINFO, A_PtrSize*4, "UPtr"))
    Return { "MemoryLoad":        nMemLoad  ; Not present in the WinAPI PERFORMANCE_INFORMATION structure.
           , "CommitTotal":       NumGet( PERFORMANCEINFO, A_PtrSize,                  "UPtr" )
           , "CommitLimit":       NumGet( PERFORMANCEINFO, A_PtrSize *  2,             "UPtr" )
           , "CommitPeak":        NumGet( PERFORMANCEINFO, A_PtrSize *  3,             "UPtr" )
           , "PhysicalTotal":     NumGet( PERFORMANCEINFO, A_PtrSize *  4,             "UPtr" )
           , "PhysicalAvailable": NumGet( PERFORMANCEINFO, A_PtrSize *  5,             "UPtr" )
           , "PhysicalUsed":      nPhysUsed ; Not present in the WinAPI PERFORMANCE_INFORMATION structure.
           , "SystemCache":       NumGet( PERFORMANCEINFO, A_PtrSize *  6,             "UPtr" )
           , "KernelTotal":       NumGet( PERFORMANCEINFO, A_PtrSize *  7,             "UPtr" )
           , "KernelPaged":       NumGet( PERFORMANCEINFO, A_PtrSize *  8,             "UPtr" )
           , "KernelNonpaged":    NumGet( PERFORMANCEINFO, A_PtrSize *  9,             "UPtr" )
           , "PageSize":          NumGet( PERFORMANCEINFO, A_PtrSize * 10,             "UPtr" )
           , "HandleCount":       NumGet( PERFORMANCEINFO, A_PtrSize * 11,             "UInt" )
           , "ProcessCount":      NumGet( PERFORMANCEINFO, (A_PtrSize == 4) ? 48 : 92, "UInt" )
           , "ThreadCount":       NumGet( PERFORMANCEINFO, (A_PtrSize == 4) ? 52 : 96, "UInt" ) }
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: SysProcInfo_GetProcessTimes
; Description ..: Returns the CPU Load time for the specified process. Call it repeateadly for consistent results.
; Parameters ...: hProc        - Handle to the process with PROCESS_QUERY_INFORMATION and PROCESS_VM_READ access.
; ..............: nOldKernTime - Old kernel time. Seed 0 on start.
; ..............: nOldUserTime - Old user time. Seed 0 on start.
; Thanks .......: Sean and Laszlo: http://www.autohotkey.com/community/viewtopic.php?t=18913
; ----------------------------------------------------------------------------------------------------------------------
SysProcInfo_GetProcessTimes(hProc, ByRef nOldKernTime, ByRef nOldUserTime){
    DllCall( "GetProcessTimes", Ptr,hProc, Int64P,nCreationTime, Int64P,nExitTime, Int64P,nNewKernTime
                              , Int64P,nNewUserTime )
    nProcTime    := (nNewKernTime-nOldKernTime + nNewUserTime-nOldUserTime)*1.e-5
    nOldKernTime := nNewKernTime, nOldUserTime := nNewUserTime
    Return nProcTime
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: SysProcInfo_GetProcessMemoryInfo
; Description ..: Retrieves information about the memory usage of the specified process.
; Parameters ...: hProc - Handle to the process with PROCESS_QUERY_INFORMATION and PROCESS_VM_READ access.
; Return .......: An object containing process information, structured like the following:
; ..............: obj.Pid                        - Process identifier.
; ..............: obj.ProcessTimes               - Process CPU Load Time.
; ..............: obj.PageFaultCount             - The number of page faults.
; ..............: obj.PeakWorkingSetSize         - The peak working set size, in bytes.
; ..............: obj.WorkingSetSize             - The current working set size, in bytes.
; ..............: obj.QuotaPeakPagedPoolUsage    - The peak paged pool usage, in bytes.
; ..............: obj.QuotaPagedPoolUsage        - The current paged pool usage, in bytes.
; ..............: obj.QuotaPeakNonPagedPoolUsage - The peak nonpaged pool usage, in bytes.
; ..............: obj.QuotaNonPagedPoolUsage     - The current nonpaged pool usage, in bytes.
; ..............: obj.PagefileUsage              - The Commit Charge value in bytes for this process.
; ..............: obj.PeakPagefileUsage          - The peak value in bytes of the process Commit Charge.
; ..............: obj.ReadOperationCount         - The number of read operations performed.
; ..............: obj.WriteOperationCount        - The number of write operations performed.
; ..............: obj.OtherOperationCount        - The number of I/O operations performed (no read/write).
; ..............: obj.ReadTransferCount          - The number of bytes read.
; ..............: obj.WriteTransferCount         - The number of bytes written.
; ..............: obj.OtherTransferCount         - The number of bytes transferred (no read/write).
; ..............: obj.CycleTime                  - Sum of the cycle time of all threads of the process.
; ..............: obj.HandleCount                - Number of open handles that belong to the process.
; ..............: obj.GdiHandles                 - Number of GDI handles that belong to the process.
; ..............: obj.UserHandles                - Number of USER handles that belong to the process.
; ..............: obj.PriorityClass              - Priority class for the process.
; ----------------------------------------------------------------------------------------------------------------------
SysProcInfo_GetProcessMemoryInfo(hProc){
    nSz := VarSetCapacity( PROCMEMCOUNTERS, (A_PtrSize == 4) ? 40 : 72, 0 ), NumPut( nSz, PROCMEMCOUNTERS, 0 )
    VarSetCapacity( IOCOUNTERS, 48, 0 )
    DllCall( "psapi.dll\GetProcessMemoryInfo",  Ptr,hProc, Ptr,&PROCMEMCOUNTERS, UInt,nSz )
    DllCall( "GetProcessIoCounters",            Ptr,hProc, Ptr,&IOCOUNTERS                )
    DllCall( "QueryProcessCycleTime",           Ptr,hProc, UInt64P,nCycleTime             )
    DllCall( "GetProcessHandleCount",           Ptr,hProc, UIntP,nHandleCount             )
    nGdiHandles := DllCall( "GetGuiResources",  Ptr,hProc, UInt,0                         )
    nUsrHandles := DllCall( "GetGuiResources",  Ptr,hProc, UInt,1                         )
    nPriority   := DllCall( "GetPriorityClass", Ptr,hProc                                 )
    Return { "PageFaultCount":             NumGet( PROCMEMCOUNTERS, 4,                          "UInt"   )
           , "PeakWorkingSetSize":         NumGet( PROCMEMCOUNTERS, 8,                          "UPtr"   )
           , "WorkingSetSize":             NumGet( PROCMEMCOUNTERS, (A_PtrSize == 4) ? 12 : 16, "UPtr"   )
           , "QuotaPeakPagedPoolUsage":    NumGet( PROCMEMCOUNTERS, (A_PtrSize == 4) ? 16 : 24, "UPtr"   )
           , "QuotaPagedPoolUsage":        NumGet( PROCMEMCOUNTERS, (A_PtrSize == 4) ? 20 : 32, "UPtr"   )
           , "QuotaPeakNonPagedPoolUsage": NumGet( PROCMEMCOUNTERS, (A_PtrSize == 4) ? 24 : 40, "UPtr"   )
           , "QuotaNonPagedPoolUsage":     NumGet( PROCMEMCOUNTERS, (A_PtrSize == 4) ? 28 : 48, "UPtr"   )
           , "PagefileUsage":              NumGet( PROCMEMCOUNTERS, (A_PtrSize == 4) ? 32 : 56, "UPtr"   )
           , "PeakPagefileUsage":          NumGet( PROCMEMCOUNTERS, (A_PtrSize == 4) ? 36 : 64, "UPtr"   )
           , "ReadOperationCount":         NumGet( IOCOUNTERS,      0,                          "UInt64" )
           , "WriteOperationCount":        NumGet( IOCOUNTERS,      8,                          "UInt64" )
           , "OtherOperationCount":        NumGet( IOCOUNTERS,      16,                         "UInt64" )
           , "ReadTransferCount":          NumGet( IOCOUNTERS,      24,                         "UInt64" )
           , "WriteTransferCount":         NumGet( IOCOUNTERS,      32,                         "UInt64" )
           , "OtherTransferCount":         NumGet( IOCOUNTERS,      40,                         "UInt64" )
           , "CycleTime":                  nCycleTime
           , "HandleCount":                nHandleCount
           , "GdiHandles":                 nGdiHandles
           , "UserHandles":                nUsrHandles
           , "PriorityClass":              nPriority                                                     }
}

/* EXAMPLE CODE:
#Persistent
#SingleInstance force
Run, calc.exe,,, pid1
Run, cmd.exe,,, pid2
arrPid := [ pid1, pid2 ]
nMsg := DllCall( "RegisterWindowMessage", Str,"AUTOHOTKEY_SYSPROCINFO_LIBRARY" )
OnMessage(nMsg, "AHKNOTIFY")
OnExit, Quit
SysProcInfo_ToggleTimer("START", 3, A_ScriptHwnd, nMsg, 1000, arrPid)
Return

Quit:
SysProcInfo_ToggleTimer("STOP")
ExitApp

AHKNOTIFY(wParam, lParam)
{
    obj := Object(lParam)
    FileAppend, % "`n==="
                . "`nSystem Times: "                               	obj.SystemData.SystemTimes
                . "`nMemoryLoad: "                                	obj.SystemData.MemoryLoad
                . "`nCommitTotal: "                                	obj.SystemData.CommitTotal
                . "`nCommitLimit: "                                	obj.SystemData.CommitLimit
                . "`nCommitPeak: "                                	obj.SystemData.CommitPeak
                . "`nPhysicalTotal: "                                	obj.SystemData.PhysicalTotal
                . "`nPhysicalAvailable: "                         	obj.SystemData.PhysicalAvailable
                . "`nPhysicalUsed: "                                	obj.SystemData.PhysicalUsed
                . "`nSystemCache: "                               	obj.SystemData.SystemCache
                . "`nKernelTotal: "                                  	obj.SystemData.KernelTotal
                . "`nKernelPaged: "                                 	obj.SystemData.KernelPaged
                . "`nKernelNonpaged: "                            	obj.SystemData.KernelNonpaged
                . "`nPageSize: "                                      	obj.SystemData.PageSize
                . "`nHandleCount: "                               	obj.SystemData.HandleCount
                . "`nProcessCount: "                                	obj.SystemData.ProcessCount
                . "`nThreadCount: "                               	obj.SystemData.ThreadCount
                , test.txt
    FileAppend, % "`n---"
                . "`nPid: "                                               	obj.ProcData[1].Pid
                . "`nProcessTimes: "                               	obj.ProcData[1].ProcessTimes
                . "`nPageFaultCount: "             	    	    	obj.ProcData[1].PageFaultCount
                . "`nPeakWorkingSetSize: "            	    	 	obj.ProcData[1].PeakWorkingSetSize
                . "`nWorkingSetSize: "               	    	 	 	obj.ProcData[1].WorkingSetSize
                . "`nQuotaPeakPagedPoolUsage: "       		obj.ProcData[1].QuotaPeakPagedPoolUsage
                . "`nQuotaPagedPoolUsage: "          	     	obj.ProcData[1].QuotaPagedPoolUsage
                . "`nQuotaPeakNonPagedPoolUsage: "  	obj.ProcData[1].QuotaPeakNonPagedPoolUsage
                . "`nQuotaNonPagedPoolUsage: "      	  	obj.ProcData[1].QuotaNonPagedPoolUsage
                . "`nPagefileUsage: "                	    	     	obj.ProcData[1].PagefileUsage
                . "`nPeakPagefileUsage: "           	    	  	obj.ProcData[1].PeakPagefileUsage
                . "`nReadOperationCount: "                    	obj.ProcData[1].ReadOperationCount
                . "`nWriteOperationCount: "                   	obj.ProcData[1].WriteOperationCount
                . "`nOtherOperationCount: "                   	obj.ProcData[1].OtherOperationCount
                . "`nReadTransferCount: "                      	obj.ProcData[1].ReadTransferCount
                . "`nWriteTransferCount: "                      	obj.ProcData[1].WriteTransferCount
                . "`nOtherTransferCount: "                     	obj.ProcData[1].OtherTransferCount
                . "`nCycleTime: "                                   	obj.ProcData[1].CycleTime
                . "`nHandleCount: "                               	obj.ProcData[1].HandleCount
                . "`nGdiHandles: "                                 	obj.ProcData[1].GdiHandles
                . "`nUserHandles: "                                 	obj.ProcData[1].UserHandles
                . "`nPriorityClass: "                                 	obj.ProcData[1].PriorityClass
                . "`n---"
                . "`nPid: "                           	    	    		obj.ProcData[2].Pid
                . "`nProcessTimes: "           	    	          	obj.ProcData[2].ProcessTimes
                . "`nPageFaultCount: "                            	obj.ProcData[2].PageFaultCount
                . "`nPeakWorkingSetSize: "                        	obj.ProcData[2].PeakWorkingSetSize
                . "`nWorkingSetSize: "                            	obj.ProcData[2].WorkingSetSize
                . "`nQuotaPeakPagedPoolUsage: "         	obj.ProcData[2].QuotaPeakPagedPoolUsage
                . "`nQuotaPagedPoolUsage: "                	obj.ProcData[2].QuotaPagedPoolUsage
                . "`nQuotaPeakNonPagedPoolUsage: "  	obj.ProcData[2].QuotaPeakNonPagedPoolUsage
                . "`nQuotaNonPagedPoolUsage: "          	obj.ProcData[2].QuotaNonPagedPoolUsage
                . "`nPagefileUsage: "                             	obj.ProcData[2].PagefileUsage
                . "`nPeakPagefileUsage: "                       	obj.ProcData[2].PeakPagefileUsage
                . "`nReadOperationCount: "                    	obj.ProcData[2].ReadOperationCount
                . "`nWriteOperationCount: "                   	obj.ProcData[2].WriteOperationCount
                . "`nOtherOperationCount: "                   	obj.ProcData[2].OtherOperationCount
                . "`nReadTransferCount: "             	        	obj.ProcData[2].ReadTransferCount
                . "`nWriteTransferCount: "                       	obj.ProcData[2].WriteTransferCount
                . "`nOtherTransferCount: "                      	obj.ProcData[2].OtherTransferCount
                . "`nCycleTime: "                                    	obj.ProcData[2].CycleTime
                . "`nHandleCount: "                               	obj.ProcData[2].HandleCount
                . "`nGdiHandles: "                                  	obj.ProcData[2].GdiHandles
                . "`nUserHandles: "                                   	obj.ProcData[2].UserHandles
                . "`nPriorityClass: "                                 	obj.ProcData[2].PriorityClass
                . "`n===`n"
                , test.txt
}
*/
