; Gets the path to an .exe file by name


/*
MsgBox, % GetAppImagePath("Autohotkey")
*/

GetAppImagePath(appname) {

	headers:= {	"DISPLAYNAME"                  	: 1
					,	"VERSION"                         	: 2
					, 	"PUBLISHER"             	         	: 3
					, 	"PRODUCTID"                    	: 4
					, 	"REGISTEREDOWNER"        	: 5
					, 	"REGISTEREDCOMPANY"    	: 6
					, 	"LANGUAGE"                     	: 7
					, 	"SUPPORTURL"                    	: 8
					, 	"SUPPORTTELEPHONE"       	: 9
					, 	"HELPLINK"                        	: 10
					, 	"INSTALLLOCATION"          	: 11
					, 	"INSTALLSOURCE"             	: 12
					, 	"INSTALLDATE"                  	: 13
					, 	"CONTACT"                        	: 14
					, 	"COMMENTS"                    	: 15
					, 	"IMAGE"                            	: 16
					, 	"UPDATEINFOURL"            	: 17}

   appImages := GetAppsInfo({mask: "IMAGE", offset: A_PtrSize*(headers["IMAGE"] - 1) })
   Loop, Parse, appImages, "`n"
	If Instr(A_loopField, appname)
		return A_loopField

return ""
}

GetAppsInfo(infoType)  {

	static CLSID_EnumInstalledApps := "{0B124F8F-91F0-11D1-B8B5-006008059382}"
        , IID_IEnumInstalledApps  := "{1BC752E1-9046-11D1-B8B3-006008059382}"

        , DISPLAYNAME := 0x00000001
        , VERSION := 0x00000002
        , PUBLISHER := 0x00000004
        , PRODUCTID := 0x00000008
        , REGISTEREDOWNER := 0x00000010
        , REGISTEREDCOMPANY := 0x00000020
        , LANGUAGE := 0x00000040
        , SUPPORTURL := 0x00000080
        , SUPPORTTELEPHONE := 0x00000100
        , HELPLINK := 0x00000200
        , INSTALLLOCATION := 0x00000400
        , INSTALLSOURCE := 0x00000800
        , INSTALLDATE := 0x00001000
        , CONTACT := 0x00004000
        , COMMENTS := 0x00008000
        , IMAGE := 0x00020000
        , READMEURL := 0x00040000
        , UPDATEINFOURL := 0x00080000

   pEIA := ComObjCreate(CLSID_EnumInstalledApps, IID_IEnumInstalledApps)

   while DllCall(NumGet(NumGet(pEIA+0) + A_PtrSize*3), Ptr, pEIA, PtrP, pINA) = 0  {
      VarSetCapacity(APPINFODATA, size := 4*2 + A_PtrSize*18, 0)
      NumPut(size, APPINFODATA)
      mask := infoType.mask
      NumPut(%mask%, APPINFODATA, 4)

      DllCall(NumGet(NumGet(pINA+0) + A_PtrSize*3), Ptr, pINA, Ptr, &APPINFODATA)
      ObjRelease(pINA)
      if !(pData := NumGet(APPINFODATA, 8 + infoType.offset))
         continue
      res .= StrGet(pData, "UTF-16") . "`n"
      DllCall("Ole32\CoTaskMemFree", Ptr, pData)  ; not sure, whether it's needed
   }
   Return res
}