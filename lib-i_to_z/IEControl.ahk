IEAdd(mgH, x, y, w, h, u)
{
   Global pwb, hCtrl

   CoInitialize()

   GUID4String(CLSID_WebBrowser, "{8856F961-340A-11D0-A96B-00C04FD705A2}")
   GUID4String(IID_IWebBrowser2, "{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}")

   hModule := DllCall("LoadLibrary", "str", "atl.dll")
   DllCall(DllCall("GetProcAddress", "Uint", hModule, "str", "AtlAxWinInit"))
   DllCall("FreeLibary", "Uint", hModule)

   hCtrl := DllCall("CreateWindowEx"
      , "Uint", 0x200            ; WS_EX_CLIENTEDGE
      , "str",  "AtlAxWin"         ; ClassName
      , "str",  CLSID_WebBrowser      ; WindowName
      , "Uint", 0x10000000 | 0x40000000 | 0x04200000   ; WS_VISIBLE | WS_CHILD | ...
      , "int",  x            ; Left
      , "int",  y            ; Top
      , "int",  w            ; Width
      , "int",  h            ; Height
      , "Uint", mgH            ; hWndParent
      , "Uint", 0            ; hMenu
      , "Uint", 0            ; hInstance
      , "Uint", 0)

   DllCall("atl\AtlAxGetControl", "Uint", hCtrl, "UintP", punk)
   pwb := QueryInterface(punk, IID_IWebBrowser2)
   Release(punk)

   IELoadURL(u)
   Return pwb
}

IEMove(x, y, w, h)
{
   Global hCtrl
   WinMove, ahk_id %hCtrl%, , x, y, w, h
}

IELoadURL(u)
{
   Global pwb
   Ansi2Unicode(u, wUrl)
   DllCall(VTable(pwb, 11), "Uint", pwb, "str", wUrl, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0)
}

IEGoBack()
{
   Global pwb
   DllCall(VTable(pwb, 7), "Uint", pwb)
}

IEGoForward()
{
   Global pwb
   DllCall(VTable(pwb, 8), "Uint", pwb)
}

IEGoHome()
{
   Global pwb
   DllCall(VTable(pwb, 9), "Uint", pwb)
}

IEGoSearch()
{
   Global pwb
   DllCall(VTable(pwb, 10), "Uint", pwb)
}

IEGoRefresh()
{
   Global pwb
   DllCall(VTable(pwb, 12), "Uint", pwb)
}

IEGoStop()
{
   Global pwb
   DllCall(VTable(pwb, 14), "Uint", pwb)
}

IEGetTitle()
{
   Global pwb
   DllCall(VTable(pwb, 29), "Uint", pwb, "UintP", pName)
   Unicode2Ansi(pName, sName)
   SysFreeString(pName)
   Return sName
}

IEGetURL()
{
   Global pwb
   DllCall(VTable(pwb, 30), "Uint", pwb, "UintP", pUrl)
   Unicode2Ansi(pUrl, sUrl)
   SysFreeString(pUrl)
   Return sUrl
}

IEVisible()
{
   Global pwb
   DllCall(VTable(pwb, 40), "Uint", pwb, "intP", bVis)
   DllCall(VTable(pwb, 41), "Uint", pwb, "int" , bVis ^ 1)
}

IEOffline()
{
   Global pwb
   DllCall(VTable(pwb, 47), "Uint", pwb, "intP", bOff)
   DllCall(VTable(pwb, 48), "Uint", pwb, "int" , bOff ^ 1)
}

IEOpen()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 1, "Uint", 0, "Uint", 0, "Uint", 0)
}

IENew()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 2, "Uint", 0, "Uint", 0, "Uint", 0)
}

IESave()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 3, "Uint", 0, "Uint", 0, "Uint", 0)
}

IESaveAs()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 4, "Uint", 0, "Uint", 0, "Uint", 0)
}

IEPrint()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 6, "Uint", 0, "Uint", 0, "Uint", 0)
}

IEPrintPreview()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 7, "Uint", 0, "Uint", 0, "Uint", 0)
}

IEPageSetup()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 8, "Uint", 0, "Uint", 0, "Uint", 0)
}

IEProperties()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 10, "Uint", 0, "Uint", 0, "Uint", 0)
}

IECut()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 11, "Uint", 0, "Uint", 0, "Uint", 0)
}

IECopy()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 12, "Uint", 0, "Uint", 0, "Uint", 0)
}

IEPaste()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 13, "Uint", 0, "Uint", 0, "Uint", 0)
}

IESelectAll()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 17, "Uint", 0, "Uint", 0, "Uint", 0)
}

IEFind()
{
   Global pwb
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 32, "Uint", 0, "Uint", 0, "Uint", 0)
}

IEDoFontSize(s)
{
   Global pwb
   VarSetCapacity(var, 8 * 2)
   EncodeInteger(&var + 0, 3)
   EncodeInteger(&var + 8, s - 1)
   DllCall(VTable(pwb, 54), "Uint", pwb, "Uint", 19, "Uint", 2, "Uint", &var, "Uint", &var)
}

IEInternetOptions()
{
   CGID_MSHTML(2135)
}

IEViewSource()
{
   CGID_MSHTML(2139)
}

IEAddToFavorites()
{
   CGID_MSHTML(2261)
}

IEMakeDesktopShortcut()
{
   CGID_MSHTML(2266)
}

IESendEMail()
{
   CGID_MSHTML(2288)
}

IEClearHistory()
{
/*
   GUID4String( CLSID_CUrlHistory, "{3C374A40-BAE4-11CF-BF7D-00AA006946EE}")
   GUID4String(IID_IUrlHistoryStg, "{3C374A41-BAE4-11CF-BF7D-00AA006946EE}")
   puh := CreateObject(CLSID_CUrlHistory, IID_IUrlHistoryStg)
   DllCall(VTable(puh, 9), "Uint", puh)
   DllCall(VTable(puh, 2), "Uint", puh)
*/
   IEGetHistory(1)
}

IEGetHistory(bDelete = 0)
{
   GUID4String( CLSID_CUrlHistory, "{3C374A40-BAE4-11CF-BF7D-00AA006946EE}")
   GUID4String(IID_IUrlHistoryStg, "{3C374A41-BAE4-11CF-BF7D-00AA006946EE}")

   puh := CreateObject(CLSID_CUrlHistory, IID_IUrlHistoryStg)

   DllCall(VTable(puh, 7), "Uint", puh, "UintP", psu)

   VarSetCapacity(var, 40)
   EncodeInteger(&var, VarSetCapacity(var))
   
   Loop
   {
      If DllCall(VTable(psu, 3), "Uint", psu, "Uint", 1, "Uint", &var, "Uint", 0)
         Break

      pUrl   := DecodeInteger(&var + 4)
      pTitle := DecodeInteger(&var + 8)

      If !bDelete
      {
         Unicode2Ansi(pUrl  , sUrl  )
         Unicode2Ansi(pTitle, sTitle)
         sHistory .= sUrl . "|" . sTitle . "`n"
      }
      Else
         DllCall(VTable(puh, 4), "Uint", puh, "Uint", pUrl, "Uint", 0)

      SysFreeString(pUrl  )
      SysFreeString(pTitle)
   }

   DllCall(VTable(psu, 2), "Uint", psu)
   DllCall(VTable(puh, 2), "Uint", puh)

   Return sHistory
}

IECleanup(pwb)
{
   Release(pwb)
   CoUninitialize()
}

CGID_MSHTML(nCmd, nOpt = 0)
{
   Global pwb
   GUID4String(CGID_MSHTML          , "{DE4BA900-59CA-11CF-9592-444553540000}")
   GUID4String(IID_IOleCommandTarget, "{B722BCCB-4E68-101B-A2BC-00AA00404770}")
   pct := QueryInterface(pwb, IID_IOleCommandTarget)
   DllCall(VTable(pct, 4), "Uint", pct, "str", CGID_MSHTML, "Uint", nCmd, "Uint", nOpt, "Uint", 0, "Uint", 0)
   Release(pct)
}

#Include CoHelper.ahk