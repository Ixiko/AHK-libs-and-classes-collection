SystemProcessInformation()
{
	static SYSTEM_INFORMATION_CLASS := 0x5

	if (DllCall("ntdll\NtQuerySystemInformation", "int", SYSTEM_INFORMATION_CLASS, "ptr", 0, "uint", 0, "uint*", size) != 0) {
		size := VarSetCapacity(buf, size, 0)
		if (DllCall("ntdll\NtQuerySystemInformation", "int", SYSTEM_INFORMATION_CLASS, "ptr", &buf, "uint", size, "uint*", 0) != 0)
			return (ErrorLevel := 2) & 0
		addr := &buf, SYSTEM_PROCESS_INFORMATION := {}
		while (addr)
		{
			SYSTEM_PROCESS_INFORMATION[A_Index, "NumberOfThreads"]              :=        NumGet(addr +   4, "uint" )                             ;   4 |   4
			SYSTEM_PROCESS_INFORMATION[A_Index, "WorkingSetPrivateSize"]        :=        NumGet(addr +   8, "int64")                             ;   8 |   8
			SYSTEM_PROCESS_INFORMATION[A_Index, "HardFaultCount"]               :=        NumGet(addr +  16, "uint" )                             ;  16 |  16
			SYSTEM_PROCESS_INFORMATION[A_Index, "NumberOfThreadsHighWatermark"] :=        NumGet(addr +  20, "uint" )                             ;  20 |  20
			SYSTEM_PROCESS_INFORMATION[A_Index, "CycleTime"]                    :=        NumGet(addr +  24, "int64")                             ;  24 |  24
			SYSTEM_PROCESS_INFORMATION[A_Index, "CreateTime"]                   :=        NumGet(addr +  32, "int64")                             ;  32 |  32
			SYSTEM_PROCESS_INFORMATION[A_Index, "UserTime"]                     :=        NumGet(addr +  40, "int64")                             ;  40 |  40
			SYSTEM_PROCESS_INFORMATION[A_Index, "KernelTime"]                   :=        NumGet(addr +  48, "int64")                             ;  48 |  48
			SYSTEM_PROCESS_INFORMATION[A_Index, "ImageName"]                    := StrGet(NumGet(addr +  56 + A_PtrSize *  1, "ptr"  ), "utf-16") ;  60 |  64
			SYSTEM_PROCESS_INFORMATION[A_Index, "BasePriority"]                 :=        NumGet(addr +  56 + A_PtrSize *  2, "int"  )            ;  64 |  72
			SYSTEM_PROCESS_INFORMATION[A_Index, "UniqueProcessId"]              :=        NumGet(addr +  56 + A_PtrSize *  3, "ptr"  )            ;  68 |  80
			SYSTEM_PROCESS_INFORMATION[A_Index, "InheritedFromUniqueProcessId"] :=        NumGet(addr +  56 + A_PtrSize *  4, "ptr*" )            ;  72 |  88
			SYSTEM_PROCESS_INFORMATION[A_Index, "HandleCount"]                  :=        NumGet(addr +  56 + A_PtrSize *  5, "uint" )            ;  76 |  96
			SYSTEM_PROCESS_INFORMATION[A_Index, "SessionId"]                    :=        NumGet(addr +  60 + A_PtrSize *  5, "uint" )            ;  80 | 100
			SYSTEM_PROCESS_INFORMATION[A_Index, "UniqueProcessKey"]             :=        NumGet(addr +  64 + A_PtrSize *  5, "ptr*" )            ;  84 | 104
			SYSTEM_PROCESS_INFORMATION[A_Index, "PeakVirtualSize"]              :=        NumGet(addr +  64 + A_PtrSize *  6, "uptr" )            ;  88 | 112
			SYSTEM_PROCESS_INFORMATION[A_Index, "VirtualSize"]                  :=        NumGet(addr +  64 + A_PtrSize *  7, "uptr" )            ;  92 | 120
			SYSTEM_PROCESS_INFORMATION[A_Index, "PageFaultCount"]               :=        NumGet(addr +  64 + A_PtrSize *  8, "uint" )            ;  96 | 128
			SYSTEM_PROCESS_INFORMATION[A_Index, "PeakWorkingSetSize"]           :=        NumGet(addr +  64 + A_PtrSize *  9, "uptr" )            ; 100 | 136
			SYSTEM_PROCESS_INFORMATION[A_Index, "WorkingSetSize"]               :=        NumGet(addr +  64 + A_PtrSize * 10, "uptr" )            ; 104 | 144
			SYSTEM_PROCESS_INFORMATION[A_Index, "QuotaPeakPagedPoolUsage"]      :=        NumGet(addr +  64 + A_PtrSize * 11, "ptr*" )            ; 108 | 152
			SYSTEM_PROCESS_INFORMATION[A_Index, "QuotaPagedPoolUsage"]          :=        NumGet(addr +  64 + A_PtrSize * 12, "uptr" )            ; 112 | 160
			SYSTEM_PROCESS_INFORMATION[A_Index, "QuotaPeakNonPagedPoolUsage"]   :=        NumGet(addr +  64 + A_PtrSize * 13, "ptr*" )            ; 116 | 168
			SYSTEM_PROCESS_INFORMATION[A_Index, "QuotaNonPagedPoolUsage"]       :=        NumGet(addr +  64 + A_PtrSize * 14, "uptr" )            ; 120 | 176
			SYSTEM_PROCESS_INFORMATION[A_Index, "PagefileUsage"]                :=        NumGet(addr +  64 + A_PtrSize * 15, "uptr" )            ; 124 | 184
			SYSTEM_PROCESS_INFORMATION[A_Index, "PeakPagefileUsage"]            :=        NumGet(addr +  64 + A_PtrSize * 16, "uptr" )            ; 128 | 192
			SYSTEM_PROCESS_INFORMATION[A_Index, "PrivatePageCount"]             :=        NumGet(addr +  64 + A_PtrSize * 17, "uptr" )            ; 132 | 200
			SYSTEM_PROCESS_INFORMATION[A_Index, "ReadOperationCount"]           :=        NumGet(addr +  64 + A_PtrSize * 18, "int64")            ; 136 | 208
			SYSTEM_PROCESS_INFORMATION[A_Index, "WriteOperationCount"]          :=        NumGet(addr +  72 + A_PtrSize * 18, "int64")            ; 144 | 216
			SYSTEM_PROCESS_INFORMATION[A_Index, "OtherOperationCount"]          :=        NumGet(addr +  80 + A_PtrSize * 18, "int64")            ; 152 | 224
			SYSTEM_PROCESS_INFORMATION[A_Index, "ReadTransferCount"]            :=        NumGet(addr +  88 + A_PtrSize * 18, "int64")            ; 160 | 232
			SYSTEM_PROCESS_INFORMATION[A_Index, "WriteTransferCount"]           :=        NumGet(addr +  96 + A_PtrSize * 18, "int64")            ; 168 | 240
			SYSTEM_PROCESS_INFORMATION[A_Index, "OtherTransferCount"]           :=        NumGet(addr + 104 + A_PtrSize * 18, "int64")            ; 176 | 248

			if !(NumGet(addr + 0, "uint"))
				break
			addr += NumGet(addr + 0, "uint")
		}
		return SYSTEM_PROCESS_INFORMATION
	}
	return (ErrorLevel := 1) & 0
}