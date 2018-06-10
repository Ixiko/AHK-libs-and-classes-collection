; ==================================================================================================================================
; IDataObject interface -> msdn.microsoft.com/en-us/library/ms688421(v=vs.85).aspx
; Partial implementation.
; Requires: IEnumFORMATETC.ahk
; ==================================================================================================================================
IDataObject_GetData(pDataObj, ByRef FORMATETC, ByRef Size, ByRef Data) {
   ; GetData -> msdn.microsoft.com/en-us/library/ms678431(v=vs.85).aspx
   Static GetData := A_PtrSize * 3
   Data := ""
   , Size := -1
   , VarSetCapacity(STGMEDIUM, 24, 0) ; 64-bit
   , pVTBL := NumGet(pDataObj + 0, "UPtr")
   If !DllCall(NumGet(pVTBL + GetData, "UPtr"), "Ptr", pDataObj, "Ptr", &FORMATETC, "Ptr", &STGMEDIUM, "Int") {
      If (NumGet(STGMEDIUM, "UInt") = 1) { ; TYMED_HGLOBAL
         hGlobal := NumGet(STGMEDIUM, A_PtrSize, "UPtr")
         , pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "UPtr")
         , Size := DllCall("GlobalSize", "Ptr", hGlobal, "UPtr")
         , VarSetCapacity(Data, Size, 0)
         , DllCall("RtlMoveMemory", "Ptr", &Data, "Ptr", pGlobal, "Ptr", Size)
         , DllCall("GlobalUnlock", "Ptr", hGlobal)
         , DllCall("Ole32.dll\ReleaseStgMedium", "Ptr", &STGMEDIUM)
         Return True
      }
      DllCall("Ole32.dll\ReleaseStgMedium", "Ptr", &STGMEDIUM)
   }
   Return False
}
; ==================================================================================================================================
IDataObject_QueryGetData(pDataObj, ByRef FORMATETC) {
   ; QueryGetData -> msdn.microsoft.com/en-us/library/ms680637(v=vs.85).aspx
   Static QueryGetData := A_PtrSize * 5
   pVTBL := NumGet(pDataObj + 0, "UPtr")
   Return !DllCall(NumGet(pVTBL + QueryGetData, "UPtr"), "Ptr", pDataObj, "Ptr", &FORMATETC, "Int")
}
; ==================================================================================================================================
IDataObject_SetData(pDataObj, ByRef FORMATETC, ByRef STGMEDIUM) {
   ; SetData -> msdn.microsoft.com/en-us/library/ms686626(v=vs.85).aspx
   Static SetData := A_PtrSize * 7
   pVTBL := NumGet(pDataObj + 0, "UPtr")
   Return !DllCall(NumGet(pVTBL + SetData, "UPtr"), "Ptr", pDataObj, "Ptr", &FORMATETC, "Ptr", &STGMEDIUM, "Int", True, "Int")
}
; ==================================================================================================================================
IDataObject_EnumFormatEtc(pDataObj, DataDir := 1) {
   ; EnumFormatEtc -> msdn.microsoft.com/en-us/library/ms683979(v=vs.85).aspx
   ; DATADIR_GET = 1, DATADIR_SET = 2
   Static EnumFormatEtc := A_PtrSize * 8
   pVTBL := NumGet(pDataObj + 0, "UPtr")
   If !DllCall(NumGet(pVTBL + EnumFormatEtc, "UPtr"), "Ptr", pDataObj, "UInt", DataDir, "PtrP", ppenumFormatEtc, "Int")
      Return ppenumFormatEtc
   Return False
}
; ==================================================================================================================================
; Auxiliary functions to get/set data of the data object.
; ==================================================================================================================================
; FORMATETC structure -> msdn.microsoft.com/en-us/library/ms682242(v=vs.85).aspx
; ==================================================================================================================================
IDataObject_CreateFormatEtc(ByRef FORMATETC, Format, Aspect := 1, Index := -1, Tymed := 1) {
   ; DVASPECT_CONTENT = 1, Index all data = -1, TYMED_HGLOBAL = 1
   VarSetCapacity(FORMATETC, 32, 0) ; 64-bit
   , NumPut(Format, FORMATETC, 0, "UShort")
   , NumPut(Aspect, FORMATETC, A_PtrSize = 8 ? 16 : 8 , "UInt")
   , NumPut(Index, FORMATETC, A_PtrSIze = 8 ? 20 : 12, "Int")
   , NumPut(Tymed, FORMATETC, A_PtrSize = 8 ? 24 : 16, "UInt")
   Return &FORMATETC
}
; ==================================================================================================================================
IDataObject_ReadFormatEtc(ByRef FORMATETC, ByRef Format, ByRef Device, ByRef Aspect, ByRef Index, ByRef Tymed) {
   Format := NumGet(FORMATETC, OffSet := 0, "UShort")
   , Device := NumGet(FORMATETC, Offset += A_PtrSize, "UPtr")
   , Aspect := NumGet(FORMATETC, Offset += A_PtrSize, "UInt")
   , Index  := NumGet(FORMATETC, Offset += 4, "Int")
   , Tymed  := NumGet(FORMATETC, Offset += 4, "UInt")
}
; ==================================================================================================================================
; Get/Set format data.
; ==================================================================================================================================
IDataObject_GetDroppedFiles(pDataObj, ByRef DroppedFiles) {
   ; msdn.microsoft.com/en-us/library/bb773269(v=vs.85).aspx
   IDataObject_CreateFormatEtc(FORMATETC, 15) ; CF_HDROP
   DroppedFiles := []
   If IDataObject_GetData(pDataObj, FORMATETC, Size, Data) {
      Offset := NumGet(Data, 0, "UInt")
      CP := NumGet(Data, 16, "UInt") ? "UTF-16" : "CP0"
      Shift := (CP = "UTF-16")
      While (File := StrGet(&Data + Offset, CP)) {
         DroppedFiles.Push(File)
         Offset += (StrLen(File) + 1) << Shift
      }
   }
   Return DroppedFiles.Length()
}
; ==================================================================================================================================
IDataObject_GetLogicalDropEffect(pDataObj, ByRef DropEffect) {
   Static LogicalDropEffect := DllCall("RegisterClipboardFormat", "Str", "Logical Performed DropEffect")
   IDataObject_CreateFormatEtc(FORMATETC, LogicalDropEffect)
   DropEffect := ""
   If IDataObject_GetData(pDataObj, FORMATETC, Size, Data) {
      DropEffect := NumGet(Data, "UChar")
      Return True
   }
   Return False
}
; ==================================================================================================================================
IDataObject_GetPerformedDropEffect(pDataObj, ByRef DropEffect) {
   Static PerformedDropEffect := DllCall("RegisterClipboardFormat", "Str", "Performed DropEffect")
   IDataObject_CreateFormatEtc(FORMATETC, PerformedDropEffect)
   DropEffect := ""
   If IDataObject_GetData(pDataObj, FORMATETC, Size, Data) {
      DropEffect := NumGet(Data, "UChar")
      Return True
   }
   Return False
}
; ==================================================================================================================================
IDataObject_GetPreferredDropEffect(pDataObj, ByRef DropEffect) {
   Static PreferredDropEffect := DllCall("RegisterClipboardFormat", "Str", "Preferred DropEffect")
   IDataObject_CreateFormatEtc(FORMATETC, PreferredDropEffect)
   DropEffect := ""
   If IDataObject_GetData(pDataObj, FORMATETC, Size, Data) {
      DropEffect := NumGet(Data, "UChar")
      Return True
   }
   Return False
}
; ==================================================================================================================================
IDataObject_GetText(pDataObj, ByRef Txt) {
   Static CF_NATIVE := A_IsUnicode ? 13 : 1 ; CF_UNICODETEXT : CF_TEXT
   IDataObject_CreateFormatEtc(FORMATETC, CF_NATIVE)
   Txt := ""
   If IDataObject_GetData(pDataObj, FORMATETC, Size, Data) {
      Txt := StrGet(Data, Size >> !!A_IsUnicode)
      Return True
   }
   Return False
}
; ==================================================================================================================================
IDataObject_SetLogicalDropEffect(pDataObj, DropEffect) {
   Static LogicalDropEffect := DllCall("RegisterClipboardFormat", "Str", "Logical Performed DropEffect")
   IDataObject_CreateFormatEtc(FORMATETC, LogicalDropEffect)
   , VarSetCapacity(STGMEDIUM, 24, 0) ; 64-bit
   , NumPut(1, STGMEDIUM, "UInt") ; TYMED_HGLOBAL
   , hMem := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 4, "UPtr") ; 0x42 = GMEM_MOVEABLE (0x02) | GMEM_ZEROINIT (0x40)
   , pMem := DllCall("GlobalLock", "Ptr", hMem, "UPtr")
   , NumPut(DropEffect, pMem + 0, "UChar")
   , DllCall("GlobalUnlock", "Ptr", hMem)
   , NumPut(hMem, STGMEDIUM, A_PtrSize, "UPtr")
   Return IDataObject_SetData(pDataObj, FORMATETC, STGMEDIUM)
}
; ==================================================================================================================================
IDataObject_SetPerformedDropEffect(pDataObj, DropEffect) {
   Static PerformedDropEffect := DllCall("RegisterClipboardFormat", "Str", "Performed DropEffect")
   IDataObject_CreateFormatEtc(FORMATETC, PerformedDropEffect)
   , VarSetCapacity(STGMEDIUM, 24, 0) ; 64-bit
   , NumPut(1, STGMEDIUM, "UInt") ; TYMED_HGLOBAL
   , hMem := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 4, "UPtr") ; 0x42 = GMEM_MOVEABLE (0x02) | GMEM_ZEROINIT (0x40)
   , pMem := DllCall("GlobalLock", "Ptr", hMem, "UPtr")
   , NumPut(DropEffect, pMem + 0, "UChar")
   , DllCall("GlobalUnlock", "Ptr", hMem)
   , NumPut(hMem, STGMEDIUM, A_PtrSize, "UPtr")
   Return IDataObject_SetData(pDataObj, FORMATETC, STGMEDIUM)
}
; ==================================================================================================================================
IDataObject_SetPreferredDropEffect(pDataObj, DropEffect) {
   Static PreferredDropEffect := DllCall("RegisterClipboardFormat", "Str", "Preferred DropEffect")
   IDataObject_CreateFormatEtc(FORMATETC, PreferredDropEffect)
   , VarSetCapacity(STGMEDIUM, 24, 0) ; 64-bit
   , NumPut(1, STGMEDIUM, "UInt") ; TYMED_HGLOBAL
   , hMem := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 4, "UPtr") ; 0x42 = GMEM_MOVEABLE (0x02) | GMEM_ZEROINIT (0x40)
   , pMem := DllCall("GlobalLock", "Ptr", hMem, "UPtr")
   , NumPut(DropEffect, pMem + 0, "UChar")
   , DllCall("GlobalUnlock", "Ptr", hMem)
   , NumPut(hMem, STGMEDIUM, A_PtrSize, "UPtr")
   Return IDataObject_SetData(pDataObj, FORMATETC, STGMEDIUM)
}
; ==================================================================================================================================
IDataObject_SetText(pDataObj, ByRef Txt) {
   Static SizeT := A_IsUnicode ? 2 : 1
   Static CF_NATIVE := A_IsUnicode ? 13 : 1 ; CF_UNICODETEXT : CF_TEXT
   Size := (StrLen(Txt)+ 1) * SizeT
   IDataObject_CreateFormatEtc(FORMATETC, CF_NATIVE)
   , VarSetCapacity(STGMEDIUM, 24, 0) ; 64-bit
   , NumPut(1, STGMEDIUM, "UInt") ; TYMED_HGLOBAL
   , hMem := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", Size, "UPtr") ; 0x42 = GMEM_MOVEABLE (0x02) | GMEM_ZEROINIT (0x40)
   , pMem := DllCall("GlobalLock", "Ptr", hMem, "UPtr")
   , StrPut(Txt, pMem + 0)
   , DllCall("GlobalUnlock", "Ptr", hMem)
   , NumPut(hMem, STGMEDIUM, A_PtrSize, "UPtr")
   Return IDataObject_SetData(pDataObj, FORMATETC, STGMEDIUM)
}
; ==================================================================================================================================
IDataObject_SHFileOperation(pDataObj, TargetPath, Operation, HWND := 0) {
   ; SHFileOperation -> msdn.microsoft.com/en-us/library/bb762164(v=vs.85).aspx
   If Operation Not In 1,2
      Return False
   IDataObject_CreateFormatEtc(FORMATETC, 15) ; CF_HDROP
   If IDataObject_GetData(pDataObj, FORMATETC, Size, Data) {
      Offset := NumGet(Data, 0, "UInt") ; offset of the file list
      IsUnicode := NumGet(Data, 16, "UInt") ; 1: Unicode, 0: ANSI
      TargetLen := StrPut(TargetPath, IsUnicode ? "UTF-16" : "CP0") + 2
      VarSetCapacity(Target, TargetLen << !!IsUnicode, 0)
      StrPut(TargetPath, &Target, IsUnicode ? "UTF-16" : "CP0")
      SHFOSLen := A_PtrSize * (A_PtrSize = 8 ? 7 : 8)
      VarSetCapacity(SHFOS, SHFOSLen, 0) ; SHFILEOPSTRUCT
      NumPut(HWND, SHFOS, 0, "UPtr")
      NumPut(Operation, SHFOS, A_PtrSize, "UInt") ; FO_MOVE = 1, FO_COPY = 2, so we have to swap the DropEffect
      NumPut(&Data + Offset, SHFOS, A_PtrSize * 2, "UPtr")
      NumPut(&Target, SHFOS, A_PtrSize * 3, "UPtr")
      NumPut(0x0200, SHFOS, A_PtrSize * 4, "UInt") ; FOF_NOCONFIRMMKDIR
      If (IsUnicode)
         Return DllCall("Shell32.dll\SHFileOperationW", "Ptr", &SHFOS, "Int")
      Else
         Return DllCall("Shell32.dll\SHFileOperationA", "Ptr", &SHFOS, "Int")
   }
}
; ==================================================================================================================================
#Include *i IEnumFORMATETC.ahk
; ==================================================================================================================================