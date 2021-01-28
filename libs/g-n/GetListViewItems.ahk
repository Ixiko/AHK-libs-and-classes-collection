GetListViewItemText(item_index, sub_index, ctrl_id, win_id) {
        ;const
        MAX_TEXT = 260

        VarSetCapacity(szText, MAX_TEXT, 0)
        VarSetCapacity(szClass, MAX_TEXT, 0)
        ControlGet, hListView, Hwnd, , %ctrl_id%, ahk_id %win_id%
        DllCall("GetClassName", UInt,hListView, Str,szClass, Int,MAX_TEXT)
        if (DllCall("lstrcmpi", Str,szClass, Str,"SysListView32") == 0 || DllCall("lstrcmpi", Str,szClass, Str,"TListView") == 0)
        {
            GetListViewText(hListView, item_index, sub_index, szText, MAX_TEXT)
        }

        return %szText%
    }

GetListViewText(hListView, iItem, iSubItem, ByRef lpString, nMaxCount) {
        ;const
        NULL = 0
        PROCESS_ALL_ACCESS = 0x001F0FFF
        INVALID_HANDLE_VALUE = 0xFFFFFFFF
        PAGE_READWRITE = 4
        FILE_MAP_WRITE = 2
        MEM_COMMIT = 0x1000
        MEM_RELEASE = 0x8000
        LV_ITEM_mask = 0
        LV_ITEM_iItem = 4
        LV_ITEM_iSubItem = 8
        LV_ITEM_state = 12
        LV_ITEM_stateMask = 16
        LV_ITEM_pszText = 20
        LV_ITEM_cchTextMax = 24
        LVIF_TEXT = 1
        LVM_GETITEM = 0x1005
        SIZEOF_LV_ITEM = 0x28
        SIZEOF_TEXT_BUF = 0x104
        SIZEOF_BUF = 0x120
        SIZEOF_INT = 4
        SIZEOF_POINTER = 4

        ;var
        result := 0
        hProcess := NULL
        dwProcessId := 0

        if lpString <> NULL && nMaxCount > 0
        {
            DllCall("lstrcpy", Str,lpString, Str,"")
            DllCall("GetWindowThreadProcessId", UInt,hListView, UIntP,dwProcessId)
            hProcess := DllCall("OpenProcess", UInt,PROCESS_ALL_ACCESS, Int,false, UInt,dwProcessId)
            if hProcess <> NULL
            {
                ;var
                lpProcessBuf := NULL
                hMap := NULL
                hKernel := DllCall("GetModuleHandle", Str,"kernel32.dll", UInt)
                pVirtualAllocEx := DllCall("GetProcAddress", UInt,hKernel, Str,"VirtualAllocEx", UInt)

                if pVirtualAllocEx == NULL
                {
                    hMap := DllCall("CreateFileMapping", UInt,INVALID_HANDLE_VALUE, Int,NULL, UInt,PAGE_READWRITE, UInt,0, UInt,SIZEOF_BUF, UInt)
                    if hMap <> NULL
                        lpProcessBuf := DllCall("MapViewOfFile", UInt,hMap, UInt,FILE_MAP_WRITE, UInt,0, UInt,0, UInt,0, UInt)
                }
                else
                {
                    lpProcessBuf := DllCall("VirtualAllocEx", UInt,hProcess, UInt,NULL, UInt,SIZEOF_BUF, UInt,MEM_COMMIT, UInt,PAGE_READWRITE)
                }

                if lpProcessBuf <> NULL
                {
                    ;var
                    VarSetCapacity(buf, SIZEOF_BUF, 0)

                    InsertIntegerSL(LVIF_TEXT, buf, LV_ITEM_mask, SIZEOF_INT)
                    InsertIntegerSL(iItem, buf, LV_ITEM_iItem, SIZEOF_INT)
                    InsertIntegerSL(iSubItem, buf, LV_ITEM_iSubItem, SIZEOF_INT)
                    InsertIntegerSL(lpProcessBuf + SIZEOF_LV_ITEM, buf, LV_ITEM_pszText, SIZEOF_POINTER)
                    InsertIntegerSL(SIZEOF_TEXT_BUF, buf, LV_ITEM_cchTextMax, SIZEOF_INT)

                    if DllCall("WriteProcessMemory", UInt,hProcess, UInt,lpProcessBuf, UInt,&buf, UInt,SIZEOF_BUF, UInt,NULL) <> 0
                        if DllCall("SendMessage", UInt,hListView, UInt,LVM_GETITEM, Int,0, Int,lpProcessBuf) <> 0
                            if DllCall("ReadProcessMemory", UInt,hProcess, UInt,lpProcessBuf, UInt,&buf, UInt,SIZEOF_BUF, UInt,NULL) <> 0
                            {
                                DllCall("lstrcpyn", Str,lpString, UInt,&buf + SIZEOF_LV_ITEM, Int,nMaxCount)
                                result := DllCall("lstrlen", Str,lpString)
                            }
                }

                if lpProcessBuf <> NULL
                    if pVirtualAllocEx <> NULL
                        DllCall("VirtualFreeEx", UInt,hProcess, UInt,lpProcessBuf, UInt,0, UInt,MEM_RELEASE)
                    else
                        DllCall("UnmapViewOfFile", UInt,lpProcessBuf)

                if hMap <> NULL
                    DllCall("CloseHandle", UInt,hMap)

                DllCall("CloseHandle", UInt,hProcess)
            }
        }
        return result
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
      DllCall("RtlFillMemory", "UInt", &pDest + pOffset + A_Index-1, "UInt", 1, "UChar", pInteger >> 8*(A_Index-1) & 0xFF)
}
; *********************************