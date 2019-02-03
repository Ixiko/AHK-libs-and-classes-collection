#NoEnv

;MsgBox % Clipboard := GetLocation()

GetLocation(RefreshNetworkList = 0)
{
 Suffix := A_IsUnicode ? "W" : "A", UPtr := A_PtrSize ? "UPtr" : "UInt", StrGetFunc := "StrGet", StrPutFunc := "StrPut"
 hWLAN := DllCall("LoadLibrary","Str","wlanapi")
 APIVersion := 0, DllCall("wlanapi\WlanOpenHandle","UInt",2,"UInt",0,"UInt*",APIVersion,"UInt*",hClientHandle)
 If (APIVersion >= 2) ;correct version of the WLAN API
 {
  If Not DllCall("wlanapi\WlanEnumInterfaces","UInt",hClientHandle,"UInt",0,UPtr . "*",pEnum), Offset := 8
  {
   Loop, % NumGet(pEnum + 0) ;loop over each interface, looking for one that is available
   {
    VarSetCapacity(GUID,16,10), DllCall("RtlMoveMemory",UPtr,&GUID,UPtr,pEnum + Offset,"UInt",16), Offset += 528
    If NumGet(pEnum + Offset) ;WLAN_INTERFACE_STATE
    {
     Found := 1
     Break
    }
    Offset += 4
   }
   DllCall("wlanapi\WlanFreeMemory",UPtr,pEnum) ;;cleanup if call succeeded (only case where buffer is allocated)
   If Found ;compatible interface found
   {
    If RefreshNetworkList
    {
     DllCall("wlanapi\WlanScan","UInt",hClientHandle,UPtr,&GUID,"UInt",0,"UInt",0,"Int",0) ;scan for networks
     Sleep, 4000 ;wait while the scan completes (4 seconds is the standard upper limit for network drivers passing the Windows logo requirements)
    }
    If Not DllCall("wlanapi\WlanGetNetworkBssList","UInt",hClientHandle,UPtr,&GUID,"UInt",0,"UInt",0,"Int",0,"UInt",0,UPtr . "*",pWLANBSSList)
    {
     Offset := 8, JSON := "{""version"":""1.1.0"",""host"":""AutoHotkeyScript"",""request_address"":true,""address_language"":""en_GB"",""radio_type"":""unknown"",""request_address"":true,""wifi_towers"":["
     Loop, % NumGet(pWLANBSSList + 4) ;loop over each wireless network, collecting information from each
     {
      Offset += 4
      SSID := IsFunc("StrGet") ? %StrGetFunc%(pWLANBSSList + Offset,"","CP0") : DllCall("MulDiv","UInt",pWLANBSSList + Offset,"UInt",1,"UInt",1,"Str"), Offset += 36
      MACAddress := ""
      SetFormat, IntegerFast, Hex
      Loop, 6
       MACAddress .= SubStr("0" . SubStr(NumGet(pWLANBSSList + Offset,A_Index - 1,"UChar"),3),-1) . "-"
      SetFormat, IntegerFast, D
      MACAddress := SubStr(MACAddress,1,-1), Offset += 8
      StringUpper, MACAddress, MACAddress
      If (NumGet(pWLANBSSList + Offset) = 2) ;Is an "Ad Hoc" network, should be skipped over
      {
       Offset += 312
       Continue
      }
      Offset += 12, LinkQuality := (NumGet(pWLANBSSList + Offset) / 2) - 100, Offset += 300 ;signal strength
      JSON .= "{""mac_address"":""" . MACAddress . """,""signal_strength"":" . Round(LinkQuality) . ",""ssid"":""" . SSID . """},"
     }
     JSON := SubStr(JSON,1,-1) . "]}"
     DllCall("wlanapi\WlanFreeMemory",UPtr,pWLANBSSList) ;cleanup if call succeeded (only case where buffer is allocated)
    }
    Else
     UseIPAddress := 1
   }
   Else
    UseIPAddress := 1
  }
   Else
    UseIPAddress := 1
 }
 Else
  UseIPAddress := 1
 If UseIPAddress ;use IP address only for geolocation
  JSON := "{""version"":""1.1.0"",""host"":""AutoHotkeyScript"",""request_address"":true,""address_language"":""en_GB"",""radio_type"":""unknown"",""request_address"":true}"
 DllCall("wlanapi\WlanCloseHandle","UInt",hClientHandle,"UInt",0), DllCall("FreeLibrary",UPtr,hWLAN) ;cleanup

 hModule := DllCall("LoadLibrary","Str","WinINet")
 If Not ((hInternet := DllCall("WinINet\InternetOpen" . Suffix,"Str","","UInt",0,UPtr,0,UPtr,0,"UInt",0)) && (hConnect := DllCall("WinINet\InternetConnect" . Suffix,UPtr,hInternet,"Str","www.google.com","Int",80,UPtr,0,UPtr,0,"UInt",3,"UInt",0,"UInt*",0)) && (hRequest := DllCall("WinINet\HttpOpenRequest" . Suffix,UPtr,hConnect,"Str","POST","Str","/loc/json","Str","HTTP/1.1",UPtr,0,UPtr,0,"UInt",0,"UInt",0)))
  Return, "Error: Could not open request."
 If A_IsUnicode
  %StrPutFunc%(JSON . "",&JSON,"UTF-8")
 If Not DllCall("WinINet\HttpSendRequest" . Suffix,"UInt",hRequest,UPtr,0,"UInt",0,UPtr,&JSON,"UInt",StrLen(JSON))
  Return, "Error: Could not send request."
 VarSetCapacity(Buffer,1024,0)
 While, (!DllCall("WinINet\InternetReadFile",UPtr,hRequest,UPtr,&Buffer,"UInt",1024,"UInt*",BytesRead) || BytesRead)
  Result .= SubStr(Buffer,1)
 If A_IsUnicode
  Result := %StrGetFunc%(&Result,"UTF-8")
 DllCall("WinINet\InternetCloseHandle",UPtr,hRequest), DllCall("WinINet\InternetCloseHandle",UPtr,hInternet), DllCall("WinINet\InternetCloseHandle",UPtr,hConnect), DllCall("FreeLibrary",UPtr,hModule)

 RegExMatch(Result,"iS)""location""\s*:\s*\{((?:[^\}]*\{[^\}]*\}[^\}]*)*)\}",Location)
 RegExMatch(Location1,"iS)""latitude""\s*:\s*([\d\.-]+)",Temp1), Result := "Latitude" . A_Tab . Temp11 . "`n"
 RegExMatch(Location1,"iS)""longitude""\s*:\s*([\d\.-]+)",Temp1), Result .= "Longitude" . A_Tab . Temp11 . "`n"
 RegExMatch(Location1,"iS)""altitude""\s*:\s*([\d\.-]+)",Temp1), Result .= "Altitude" . A_Tab . Temp11 . "`n"
 ParseList := "Country,Country_Code,Region,County,City,Street,Street_Number,Postal_Code"
 Loop, Parse, ParseList, `,
 {
  StringReplace, Temp1, A_LoopField, _, %A_Space%, All
  RegExMatch(Location1,"iS)""" . A_LoopField . """\s*:\s*""([^""]*)""",Temp2), Result .= Temp1 . A_Tab . Temp21 . "`n"
 }
 ;units are in meters
 RegExMatch(Location1,"iS)""accuracy""\s*:\s*([\d\.-]+)",Temp1), Result .= "Accuracy" . A_Tab . Temp11 . "`n"
 RegExMatch(Location1,"iS)""altitude_accuracy""\s*:\s*([\d\.-]+)",Temp1), Result .= "Altitude Accuracy" . A_Tab . Temp11
 Return, Result
}