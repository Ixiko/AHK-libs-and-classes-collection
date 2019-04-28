/*
#NoEnv
SetBatchLines, -1
headers := [ "DISPLAYNAME", "VERSION", "PUBLISHER", "PRODUCTID"
           , "REGISTEREDOWNER", "REGISTEREDCOMPANY", "LANGUAGE", "SUPPORTURL"
           , "SUPPORTTELEPHONE", "HELPLINK", "INSTALLLOCATION", "INSTALLSOURCE"
           , "INSTALLDATE", "CONTACT", "COMMENTS", "IMAGE", "UPDATEINFOURL" ]
data := []           
for k, v in headers  {
   columns .= (A_Index = 1 ? "" : "|") . v
   data.Push( GetAppsInfo({ mask: v, offset: A_PtrSize*(k - 1) }) )
}
Gui, +Resize -DPIScale
Gui, Margin, 0, 0
Gui, Add, ListView,, % columns
LV_ModifyCol("", "AutoHdr")
listViewArr := []
for k, v in data
   for i, j in v
      listViewArr[i, k] := j
   
for k, v in listViewArr
   LV_Add("", v*)
Gui, Show, w1400 h900
Return

GuiSize:
   GuiControl, Move, SysListView321, w%A_GuiWidth% h%A_GuiHeight%
   Return
   
GuiClose:
   ExitApp
   */
   
GetAppsInfo(infoType)  {
   static CLSID_EnumInstalledApps := "{0B124F8F-91F0-11D1-B8B5-006008059382}"
        , IID_IEnumInstalledApps  := "{1BC752E1-9046-11D1-B8B3-006008059382}"
        
        , AIM_DISPLAYNAME       := 0x00000001
        , AIM_VERSION           := 0x00000002
        , AIM_PUBLISHER         := 0x00000004
        , AIM_PRODUCTID         := 0x00000008
        , AIM_REGISTEREDOWNER   := 0x00000010
        , AIM_REGISTEREDCOMPANY := 0x00000020
        , AIM_LANGUAGE          := 0x00000040
        , AIM_SUPPORTURL        := 0x00000080
        , AIM_SUPPORTTELEPHONE  := 0x00000100
        , AIM_HELPLINK          := 0x00000200
        , AIM_INSTALLLOCATION   := 0x00000400
        , AIM_INSTALLSOURCE     := 0x00000800
        , AIM_INSTALLDATE       := 0x00001000
        , AIM_CONTACT           := 0x00004000
        , AIM_COMMENTS          := 0x00008000
        , AIM_IMAGE             := 0x00020000
        , AIM_READMEURL         := 0x00040000
        , AIM_UPDATEINFOURL     := 0x00080000
        
   pEIA := ComObjCreate(CLSID_EnumInstalledApps, IID_IEnumInstalledApps)
   arr := []
   while DllCall(NumGet(NumGet(pEIA+0) + A_PtrSize*3), Ptr, pEIA, PtrP, pINA) = 0  {
      VarSetCapacity(APPINFODATA, size := 4*2 + A_PtrSize*18, 0)
      NumPut(size, APPINFODATA)
      mask := "AIM_" . infoType.mask
      NumPut(%mask%, APPINFODATA, 4)
      DllCall(NumGet(NumGet(pINA+0) + A_PtrSize*3), Ptr, pINA, Ptr, &APPINFODATA)
      ObjRelease(pINA)
      if !pData := NumGet(APPINFODATA, 8 + infoType.offset)  {
         arr.Push("")
         continue
      }
      arr.Push( StrGet(pData, "UTF-16") )
      DllCall("Ole32\CoTaskMemFree", Ptr, pData)  ; not sure, whether it's needed
   }
   Return arr
}