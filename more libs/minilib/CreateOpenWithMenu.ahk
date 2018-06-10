; ==================================================================================================================================
; Creates an 'open with' menu for the passed file.
; Parameters:
;     FilePath    -  Fully qualified path of a single file.
;     Recommended -  Show only recommended apps (True/False).
;                    Default: True
;     ShowMenu    -  Immediately show the menu (True/False).
;                    Default: False
;     MenuName    -  The name of the menu.
;                    Default: OpenWithMenu
;     Others      -  Name of the submenu holding not recommended apps (if Recommended has been set to False).
;                    Default: Others
; Return values:
;     On success the function returns the menu's name unless ShowMenu has been set to True.
;     If the menu couldn't be created, the function returns False.
; Remarks:
;     Requires AHK 1.1.23.07+ and Win Vista+!!!
;     The function registers itself as the menu handler.
; Credits:
;     Based on code by querty12 -> autohotkey.com/boards/viewtopic.php?p=86709#p86709.
;     I hadn't even heard anything about the related API functions before.
; MSDN:
;     SHAssocEnumHandlers -> msdn.microsoft.com/en-us/library/bb762109%28v=vs.85%29.aspx
;     SHCreateItemFromParsingName -> msdn.microsoft.com/en-us/library/bb762134%28v=vs.85%29.aspx
; ==================================================================================================================================
CreateOpenWithMenu(FilePath, Recommended := True, ShowMenu := False, MenuName := "OpenWithMenu", Others := "Others") {
   Static RecommendedHandlers := []
        , OtherHandlers := []
        , HandlerID := A_TickCount
        , HandlerFunc := 0
        , ThisMenuName := ""
        , ThisOthers := ""
   ; -------------------------------------------------------------------------------------------------------------------------------
   Static IID_IShellItem := 0, BHID_DataObject := 0, IID_IDataObject := 0
        , Init := VarSetCapacity(IID_IShellItem, 16, 0) . VarSetCapacity(BHID_DataObject, 16, 0)
          . VarSetCapacity(IID_IDataObject, 16, 0)
          . DllCall("Ole32.dll\IIDFromString", "WStr", "{43826d1e-e718-42ee-bc55-a1e261c37bfe}", "Ptr", &IID_IShellItem)
          . DllCall("Ole32.dll\IIDFromString", "WStr", "{B8C0BD9F-ED24-455c-83E6-D5390C4FE8C4}", "Ptr", &BHID_DataObject)
          . DllCall("Ole32.dll\IIDFromString", "WStr", "{0000010e-0000-0000-C000-000000000046}", "Ptr", &IID_IDataObject)
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; Handler call
   If (Recommended = HandlerID) {
      AssocHandlers := A_ThisMenu = ThisMenuName ? RecommendedHandlers : OtherHandlers
      If (AssocHandler := AssocHandlers[A_ThisMenuItemPos]) && FileExist(FilePath) {
         AssocHandlerInvoke := NumGet(NumGet(AssocHandler + 0, "UPtr"), A_PtrSize * 8, "UPtr")
         If !DllCall("Shell32.dll\SHCreateItemFromParsingName", "WStr", FilePath, "Ptr", 0, "Ptr", &IID_IShellItem, "PtrP", Item) {
            BindToHandler := NumGet(NumGet(Item + 0, "UPtr"), A_PtrSize * 3, "UPtr")
            If !DllCall(BindToHandler, "Ptr", Item, "Ptr", 0, "Ptr", &BHID_DataObject, "Ptr", &IID_IDataObject, "PtrP", DataObj) {
               DllCall(AssocHandlerInvoke, "Ptr", AssocHandler, "Ptr", DataObj)
               ObjRelease(DataObj)
            }
            ObjRelease(Item)
         }
      }
      Try Menu, %ThisMenuName%, DeleteAll
      For Each, AssocHandler In RecommendedHandlers
         ObjRelease(AssocHandler)
      For Each, AssocHandler In OtherHandlers
         ObjRelease(AssocHandler)
      RecommendedHandlers:= []
      OtherHandlers:= []
      Return
   }
   ; -------------------------------------------------------------------------------------------------------------------------------
   ; User call
   If !FileExist(FilePath)
      Return False
   ThisMenuName := MenuName
   ThisOthers := Others
   SplitPath, FilePath, , , Ext
   For Each, AssocHandler In RecommendedHandlers
      ObjRelease(AssocHandler)
   For Each, AssocHandler In OtherHandlers
      ObjRelease(AssocHandler)
   RecommendedHandlers:= []
   OtherHandlers:= []
   Try Menu, %ThisMenuName%, DeleteAll
   Try Menu, %ThisOthers%, DeleteAll
   ; Try to get the default association
   Size := VarSetCapacity(FriendlyName, 520, 0) // 2
   DllCall("Shlwapi.dll\AssocQueryString", "UInt", 0, "UInt", 4, "Str", "." . Ext, "Ptr", 0, "Str", FriendlyName, "UIntP", Size)
   HandlerID := A_TickCount
   HandlerFunc := Func(A_ThisFunc).Bind(FilePath, HandlerID)
   Filter := !!Recommended ; ASSOC_FILTER_NONE = 0, ASSOC_FILTER_RECOMMENDED = 1
   ; Enumerate the apps and build the menu
   If DllCall("Shell32.dll\SHAssocEnumHandlers", "WStr", "." . Ext, "UInt", Filter, "PtrP", EnumHandler)
      Return False
   EnumHandlerNext := NumGet(NumGet(EnumHandler + 0, "UPtr"), A_PtrSize * 3, "UPtr")
   While (!DllCall(EnumHandlerNext, "Ptr", EnumHandler, "UInt", 1, "PtrP", AssocHandler, "UIntP", Fetched) && Fetched) {
      VTBL := NumGet(AssocHandler + 0, "UPtr")
      AssocHandlerGetUIName := NumGet(VTBL + 0, A_PtrSize * 4, "UPtr")
      AssocHandlerGetIconLocation := NumGet(VTBL + 0, A_PtrSize * 5, "UPtr")
      AssocHandlerIsRecommended := NumGet(VTBL + 0, A_PtrSize * 6, "UPtr")
      UIName := ""
      If !DllCall(AssocHandlerGetUIName, "Ptr", AssocHandler, "PtrP", StrPtr, "UInt") {
         UIName := StrGet(StrPtr, "UTF-16")
         DllCall("Ole32.dll\CoTaskMemFree", "Ptr", StrPtr)
      }
      If (UIName <> "") {
         If !DllCall(AssocHandlerGetIconLocation, "Ptr", AssocHandler, "PtrP", StrPtr, "IntP", IconIndex := 0, "UInt") {
            IconPath := StrGet(StrPtr, "UTF-16")
            DllCall("Ole32.dll\CoTaskMemFree", "Ptr", StrPtr)
         }
         If (SubStr(IconPath, 1, 1) = "@") {
            VarSetCapacity(Resource, 4096, 0)
            If !DllCall("Shlwapi.dll\SHLoadIndirectString", "WStr", IconPath, "Ptr", &Resource, "UInt", 2048, "PtrP", 0)
               IconPath := StrGet(&Resource, "UTF-16")
         }
         ItemName := StrReplace(UIName, "&", "&&")
         If (Recommended || !DllCall(AssocHandlerIsRecommended, "Ptr", AssocHandler, "UInt")) {
            If (UIName = FriendlyName) {
               If RecommendedHandlers.Length() {
                  Menu, %ThisMenuName%, Insert, 1&, %ItemName%, % HandlerFunc
                  RecommendedHandlers.InsertAt(1, AssocHandler)
               }
               Else {
                  Menu, %ThisMenuName%, Add, %ItemName%, % HandlerFunc
                  RecommendedHandlers.Push(AssocHandler)
               }
               Menu, %ThisMenuName%, Default, %ItemName%
            }
            Else {
               Menu, %ThisMenuName%, Add, %ItemName%, % HandlerFunc
               RecommendedHandlers.Push(AssocHandler)
            }
            Try Menu, %ThisMenuName%, Icon, %ItemName%, %IconPath%, %IconIndex%
         }
         Else {
            Menu, %ThisOthers%, Add, %ItemName%, % HandlerFunc
            OtherHandlers.Push(AssocHandler)
            Try Menu, %ThisOthers%, Icon, %ItemName%, %IconPath%, %IconIndex%
         }
      }
      Else
         ObjRelease(AssocHandler)
   }
   ObjRelease(EnumHandler)
   ; All done
   If !RecommendedHandlers.Length() && !OtherHandlers.Length()
      Return False
   If OtherHandlers.Length()
      Menu, %ThisMenuName%, Add, %ThisOthers%, :%ThisOthers%
   If (ShowMenu)
      Menu, %ThisMenuName%, Show
   Else
      Return ThisMenuName
}