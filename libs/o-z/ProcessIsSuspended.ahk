#NoEnv

; Taken from the Process Hacker source code, by wj32 and dmex
; Thanks to jeeswg for fixing the 32-bit incompatibility 

ProcessIsSuspended(pid, ByRef isPartiallySuspended := 0) {
	static initialBufferSize := 0x4000, cbSYSTEM_THREAD_INFORMATION := A_PtrSize == 8 ? 80 : 64
	static SystemProcessInformation := 5, STATUS_BUFFER_TOO_SMALL := 0xC0000023, STATUS_INFO_LENGTH_MISMATCH := 0xC0000004
	static Waiting := 5, Suspended := 5
	static UniqueProcessIdOffset := A_PtrSize == 8 ? 80 : 68, NumberOfThreadsOffset := 4, ThreadsArrayOffset := A_PtrSize == 8 ? 256 : 184
	static ThreadStateOffset := A_PtrSize == 8 ? 68 : 52, WaitReasonOffset := A_PtrSize == 8 ? 72 : 56
	bufferSize := initialBufferSize

	VarSetCapacity(ProcessBuffer, bufferSize)
	
	Loop {
		status := DllCall("ntdll\NtQuerySystemInformation", "UInt", SystemProcessInformation, "Ptr", &ProcessBuffer, "UInt", bufferSize, "UInt*", bufferSize, "UInt")
		if (status == STATUS_BUFFER_TOO_SMALL || status == STATUS_INFO_LENGTH_MISMATCH) {
			VarSetCapacity(ProcessBuffer, bufferSize)
		}
		else {
			break
		}
	}

	if (status < 0)	{
		return -1
	}

	if (bufferSize <= 0x100000) initialBufferSize := bufferSize

	isSuspended := pid > 0
	isPartiallySuspended := False
	ThisEntryOffset := 0

	Loop {
		if (NumGet(ProcessBuffer, ThisEntryOffset + UniqueProcessIdOffset, "Ptr") == pid) {
			Loop % NumGet(ProcessBuffer, ThisEntryOffset + NumberOfThreadsOffset, "UInt") {
				ThisThreadsOffset := ThisEntryOffset + ThreadsArrayOffset + (cbSYSTEM_THREAD_INFORMATION * (A_Index - 1))
				ThreadState := NumGet(ProcessBuffer, ThisThreadsOffset + ThreadStateOffset, "UInt")
				WaitReason := NumGet(ProcessBuffer, ThisThreadsOffset + WaitReasonOffset, "UInt")
				if (ThreadState != Waiting || WaitReason != Suspended) {
					isSuspended := False
				} else {
					isPartiallySuspended := True
				}
			}
			return isSuspended
		}
	} until (!(NextEntryOffset := NumGet(ProcessBuffer, ThisEntryOffset, "UInt")), ThisEntryOffset += NextEntryOffset)
	
	return -1
}

;MsgBox % ProcessIsSuspended(560)