#NoEnv
KFPROPS := ["Name", "ID", "CSIDL", "LocalizedName", "Category", "Path", "ParsingName", "Parent", "RelativePath"
          , "Description", "ToolTip", "Icon", "Security", "Attributes", "Flags", "Type"]
; ---------------------------------------------------------------------------------------------------
KF := EnumKnownFolders()
; ---------------------------------------------------------------------------------------------------
Gui, Main:New
Gui, Font, s10, Lucida Console
Gui, Add, ListView, w1200 r30 Grid vMainLV gMainLVLabel, Index|ID|CSIDL|Name|Localized Name|Category
For I, F In KF
   LV_Add("", I, F.ID, F.CSIDL, F.Name, F.LocalizedName, F.Category)
Loop, % LV_GetCount("Column")
   LV_ModifyCol(A_Index, "AutoHdr")
LV_ModifyCol(1, "Integer")
Gui, Show, , KnownFolders
; ---------------------------------------------------------------------------------------------------
Gui, Props:New, +OwnerMain
Gui, Font, s10, Lucida Console
Gui, Add, ListView, w1200 r20 Grid vPropsLV, Property|Value
Return
; ---------------------------------------------------------------------------------------------------
MainGuiClose:
ExitApp
; ---------------------------------------------------------------------------------------------------
PropsGuiClose:
PropsGuiEscape:
Gui, Main:-Disabled
Gui, Hide
Return
; ---------------------------------------------------------------------------------------------------
MainLVLabel:
Gui, ListView, MainLV
If (A_GuiEvent = "DoubleClick") && (A_EventInfo = LV_GetNext()) {
   Gui, Props:Default
   Gui, ListView, PropsLV
   LV_Delete()
   FolderProps := KF[A_EventInfo]
   For I, N In KFPROPS
      LV_Add("", N, FolderProps[N])
   LV_ModifyCol(1, "AutoHdr")
   LV_ModifyCol(2, "AutoHdr")
   Gui, Main:+Disabled
   Gui, Show, , Properties
}
Return
; ==================================================================================================
EnumKnownFolders() {
   Local
   Static Categories := ["VIRTUAL", "FIXED", "COMMON", "PERUSER"]
   If !(IKFM := IKnownFoldersManager_Create())
      Return False
   If !IKnownFoldersManager_GetFolderIds(IKFM, KFID, CID)
      Return False
   KnownFolders := {}
   PKNID := KFID ; pointer to the current KNOWNFOLDERID
   Loop, %CID% {
      If !IKnownFoldersManager_GetFolder(IKFM, PKNID, IKF)
         Continue
      Properties := {ID: StringFromGUID2(PKNID)}
      If IKnownFoldersManager_FolderIdToCsidl(IKFM, PKNID, CSIDL)
         Properties.CSIDL := CSIDL
      If IKnownFolder_GetFolderDefinition(IKF, KFD) {
         Properties.Category := Categories[NumGet(KFD, Offset := 0, "UInt")]
         Properties.Name := StrGet(NumGet(KFD, Offset += A_PtrSize, "UPtr"), "UTF-16")
         Properties.Description := StrGet(NumGet(KFD, Offset += A_PtrSize, "UPtr"), "UTF-16")
         Properties.Parent := StringFromGUID2(&KFD + (Offset += A_PtrSize))
         Properties.RelativePath := StrGet(NumGet(KFD, Offset += 16, "UPtr"), "UTF-16")
         Properties.ParsingName := StrGet(NumGet(KFD, Offset += A_PtrSize, "UPtr"), "UTF-16")
         ToolTip := StrGet(NumGet(KFD, Offset += A_PtrSize, "UPtr"), "UTF-16")
         If (SubStr(ToolTip, 1, 1) = "@")
            ToolTip := GetMUIString(ToolTip)
         Properties.ToolTip := ToolTip
         LocalName := StrGet(NumGet(KFD, Offset += A_PtrSize, "UPtr"), "UTF-16")
         If (SubStr(LocalName, 1, 1) = "@")
            LocalName := GetMUIString(LocalName)
         Properties.LocalizedName := LocalName
         Properties.Icon := StrGet(NumGet(KFD, Offset += A_PtrSize, "UPtr"), "UTF-16")
         Properties.Security := StrGet(NumGet(KFD, Offset += A_PtrSize, "UPtr"), "UTF-16")
         Properties.Attributes := Format("0x{:08X}", NumGet(KFD, Offset += A_PtrSize, "UInt"))
         Properties.Flags := Format("0x{:08X}", NumGet(KFD, Offset += 4, "UInt"))
         Properties.Type := StringFromGUID2(&KFD + (Offset += 4))
         FreeKnownFolderDefinitionFields(&KFD)
      }
      If IKnownFolder_GetPath(IKF, Path)
         Properties.Path := Path
      KnownFolders[A_Index] := Properties
      ObjRelease(IKF)
      PKNID += 16 ; switch to the next KNOWNFOLDERID
   }
   DllCall("Ole32.dll\CoTaskMemFree", "Ptr", KFID)
   Return KnownFolders
}
; ======================================================================================================================
; IKnownFoldersManager interface
; docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-iknownfoldermanager
; ======================================================================================================================
; Creates a IKNOWNFOLDERSMANAGER interface and returns its pointer on success.
; ----------------------------------------------------------------------------------------------------------------------
IKnownFoldersManager_Create() {
   Local
   Static SCLSID_KnownFoldersManager := "{4DF0C730-DF9D-4AE3-9153-AA6B82E9795A}"
        , SIID_IKnownFoldersManager  := "{8BE2D872-86AA-4d47-B776-32CCA40C7018}"
   If !(IKFM := ComObjCreate(SCLSID_KnownFoldersManager, SIID_IKnownFoldersManager))
      Return False
   Return IKFM
}
; ----------------------------------------------------------------------------------------------------------------------
; Gets the legacy CSIDL value that is the equivalent of a given KNOWNFOLDERID.
; docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfoldermanager-folderidtocsidl
; ----------------------------------------------------------------------------------------------------------------------
IKnownFoldersManager_FolderIdToCsidl(IKFM, PKNID, ByRef CSIDL) {
   Local
   FolderIdToCsidl := NumGet(NumGet(IKFM + 0, "Uptr"), A_PtrSize * 4, "UPtr")
   Return !DllCall(FolderIdToCsidl, "Ptr", IKFM, "Ptr", PKNID, "IntP", CSIDL := 0, "UInt")
}
; ----------------------------------------------------------------------------------------------------------------------
; Gets an array of all registered known folder IDs. This can be used in enumerating all known folders.
; docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfoldermanager-getfolderids
; ----------------------------------------------------------------------------------------------------------------------
IKnownFoldersManager_GetFolderIds(IKFM, ByRef KFID, ByRef CID) {
   Local
   GetFolderIds := NumGet(NumGet(IKFM + 0, "Uptr"), A_PtrSize * 5, "UPtr")
   Return !DllCall(GetFolderIds, "Ptr", IKFM, "PtrP", KFID, "IntP", CID, "UInt")
}
; ----------------------------------------------------------------------------------------------------------------------
; Gets an object that represents a known folder identified by its KNOWNFOLDERID.
; docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfoldermanager-getfolder
; ----------------------------------------------------------------------------------------------------------------------
IKnownFoldersManager_GetFolder(IKFM, PFolderID, ByRef IKF) {
   Local
   GetFolder := NumGet(NumGet(IKFM + 0, "Uptr"), A_PtrSize * 6, "UPtr")
   Return !DllCall(GetFolder, "Ptr", IKFM, "Ptr", PFolderID, "PtrP", IKF, "UInt")
}
; ----------------------------------------------------------------------------------------------------------------------
; Releases the IKNOWNFOLDERSMANAGER interface.
; ----------------------------------------------------------------------------------------------------------------------
IKnownFoldersManager_Release(IKFM) {
   Return ObjRelease(IKFM)
}
; ======================================================================================================================
; IKnownFolder interface
; docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-iknownfolder
; ======================================================================================================================
; Retrieves a structure that contains the defining elements of a known folder,
; which includes the folder's category, name, path, description, tooltip, icon, and other properties.
; docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfolder-getfolderdefinition
; ----------------------------------------------------------------------------------------------------------------------
IKnownFolder_GetFolderDefinition(IKF, ByRef KFD) {
   Local
   GetFolderDefinition := NumGet(NumGet(IKF + 0, "Uptr"), A_PtrSize * 11, "UPtr")
   VarSetCapacity(KFD, 40 + (A_PtrSize * 9), 0)
   Return !DllCall(GetFolderDefinition, "Ptr", IKF, "Ptr", &KFD, "UInt")
}
; ----------------------------------------------------------------------------------------------------------------------
; Retrieves the path of a known folder as a string.
; docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfolder-getpath
; ----------------------------------------------------------------------------------------------------------------------
IKnownFolder_GetPath(IKF, ByRef Path, Flags := 0) {
   Local
   GetPath := NumGet(NumGet(IKF + 0, "Uptr"), A_PtrSize * 6, "UPtr")
   Path := ""
   If !(HR := DllCall(GetPath, "Ptr", IKF, "UInt", Flags, "PtrP", KFP, "UInt")) {
      Path := StrGet(KFP, "UTF-16")
      DllCall("Ole32.dll\CoTaskMemFree", "Ptr", KFP)
   }
   Return !HR
}
; ======================================================================================================================
; Auxiliary functions
; ======================================================================================================================
ExpandEnvironmentStrings(Str) {
   If (Chars := DllCall("ExpandEnvironmentStrings", "Ptr", &Str, "Ptr", 0, "UInt", 0, "Int")) {
      VarSetCapacity(Expanded, ++Chars << !!A_IsUnicode, 0)
      DllCall("ExpandEnvironmentStrings", "Ptr", &Str, "Str", Expanded, "UInt", Chars, "Int")
      Return Expanded
   }
   Return Str
}
; ======================================================================================================================
FreeKnownFolderDefinitionFields(KFD) {
   Static OffSets := [A_PtrSize, A_PtrSize, A_PtrSize + 16, A_PtrSize, A_PtrSize, A_PtrSize, A_PtrSize, A_PtrSize]
   Offset := 0
   For I, V In Offsets {
      Offset += V
      DllCall("Ole32.dll\CoTaskMemFree", "Ptr", NumGet(KFD + OffSet, "UPtr"))
   }
}
; ======================================================================================================================
GetMUIString(ResPath) {
   If InStr(ResPath, "%")
      ResPath := ExpandEnvironmentStrings(ResPath)
   ResStr := ""
   ResSplit := StrSplit(ResPath, [",", ";"], "@-")
   HMUI := DllCall("LoadLibraryEx", "Str", ResSplit[1], "Ptr", 0, "UInt", 0x00000020, "UPtr")
   If (Size := DllCall("LoadStringW", "Ptr", HMUI, "UInt", ResSplit[2], "PtrP", ResPtr, "Int", 0, "Int"))
      ResStr := StrGet(ResPtr, Size, "UTF-16")
   DllCall("FreeLibrary", "Ptr", HMUI)
   Return (ResStr ? ResStr : ResPath)
}
; ======================================================================================================================
StringFromGUID2(PGUID) {
   VarSetCapacity(SGUID, 128, 0)
   CC := DllCall("Ole32.dll\StringFromGUID2", "Ptr", PGUID, "Ptr", &SGUID, "Int", 64, "Int")
   Return StrGet(&SGUID, CC, "UTF-16")
}
; ======================================================================================================================