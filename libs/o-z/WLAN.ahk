; By: ahklerner & Sean <- he did the hard stuff
; see forum post for more info 
; http://www.autohotkey.com/forum/viewtopic.php?t=33726


;Test Script Showing available interfaces.

hWlan := WLAN_Init()
hClientHandle := WLAN_WlanOpenHandle()
pEnum := WLAN_WlanEnumInterfaces(hClientHandle)
InterfaceCount := NumGet(pEnum+0)
 
Loop, % InterfaceCount
	{
	CurrentItem := NumGet(pEnum+4) ;<- shouldn't A_Index be in there somewhere ?
	Interface_%A_Index%_GUID  := Wlan_String4GUID(pEnum+8+(A_Index-1)*532)
	Interface_%A_Index%_DESC  := Wlan_Ansi4Unicode(pEnum+8+(A_Index-1)*532+16)
	Interface_%A_Index%_STATE := NumGet(pEnum+8+(A_Index-1)*532+528)
	}

pInterfaceGuid := WLAN_GUID4String(GUID,Interface_1_GUID)

MsgBox % "hClientHandle: " . hClientHandle 
 . "`npEnum: " . pEnum 
 . "`nInterfaceCount: " . InterfaceCount 
 . "`nCurrentItem: " . CurrentItem 
 . "`nInterface_1_GUID: " . Interface_1_GUID
 . "`nInterface_1_DESC: " . Interface_1_DESC 
 . "`nInterface_1_STATE: " . Interface_1_STATE 
 . "`npInterfaceGuid: " . pInterfaceGuid 
 . "`npNetworkList: " . pNetworkList 

pNetworkList := WLAN_WlanGetAvailableNetworkList(hClientHandle,pInterfaceGuid,dwFlags)

dwNumberOfItems := NumGet(pNetworkList, 0, "UInt")

dwIndex := NumGet(pNetworkList, 4, "UInt")
struct := &pNetworkList + 8, struct_Network_length := 1
MsgBox % "dwNumberOfItems: " . dwNumberOfItems
 . "`n dwIndex: " . dwIndex
 
;VarSetCapacity(struct, 628, 0)
; typedef struct _WLAN_AVAILABLE_NETWORK {
    struct_strProfileName_ptr := &struct + 0, struct_strProfileName_type := "UInt", struct_strProfileName_length := 256
    dot11Ssid := NumGet(struct, 512, "UInt")
    dot11BssType := NumGet(struct, 548, "UInt")
    uNumberOfBssids := NumGet(struct, 552, "UInt")
    bNetworkConnectable := NumGet(struct, 556, "Int")
    wlanNotConnectableReason := NumGet(struct, 560, "UInt")
    uNumberOfPhyTypes := NumGet(struct, 564, "UInt")
    struct_dot11PhyTypes_ptr := &struct + 568, struct_dot11PhyTypes_type := "UInt", struct_dot11PhyTypes_length := 8
    bMorePhyTypes := NumGet(struct, 600, "Int")
    wlanSignalQuality := NumGet(struct, 604, "UInt")
    bSecurityEnabled := NumGet(struct, 608, "Int")
    dot11DefaultAuthAlgorithm := NumGet(struct, 612, "UInt")
    dot11DefaultCipherAlgorithm := NumGet(struct, 616, "UInt")
    dwFlags := NumGet(struct, 620, "UInt")
    dwReserved := NumGet(struct, 624, "UInt")

MsgBox % "`n dot11Ssid: " . dot11Ssid
 . "`n dot11BssType: " . dot11BssType
 . "`n uNumberOfBssids: " . uNumberOfBssids
 . "`n bNetworkConnectable: " . bNetworkConnectable
 . "`n wlanNotConnectableReason: " . wlanNotConnectableReason
 . "`n uNumberOfPhyTypes: " . uNumberOfPhyTypes
 . "`n struct_dot11PhyTypes_ptr: " . struct_dot11PhyTypes_ptr
 . "`n bMorePhyTypes: " . bMorePhyTypes
 . "`n bSecurityEnabled: " . bSecurityEnabled
 . "`n wlanSignalQuality: " . wlanSignalQuality
 . "`n dot11DefaultAuthAlgorithm: " . dot11DefaultAuthAlgorithm
 . "`n dot11DefaultCipherAlgorithm: " . dot11DefaultCipherAlgorithm
 . "`n dwFlags: " . dwFlags
 . "`n dwReserved: " . dwReserved
 


WLAN_WlanFreeMemory(pNetworkList)
WLAN_WlanFreeMemory(pEnum)
WLAN_WlanCloseHandle(hClientHandle)
WLAN_UnInit(hWlan)
ExitApp

;========================================================================================================================
/* 
typedef struct _WLAN_AVAILABLE_NETWORK_LIST {
  DWORD dwNumberOfItems;
  DWORD dwIndex;
  WLAN_AVAILABLE_NETWORK Network[1];
} WLAN_AVAILABLE_NETWORK_LIST, 
 *PWLAN_AVAILABLE_NETWORK_LIST;
 
 VarSetCapacity(struct, 12, 0)

; typedef struct _WLAN_AVAILABLE_NETWORK_LIST {
    dwNumberOfItems := NumGet(struct, 0, "UInt")
    dwIndex := NumGet(struct, 4, "UInt")
    struct_Network_ptr := &struct + 8, struct_Network_length := 1
; }

; typedef struct _WLAN_AVAILABLE_NETWORK_LIST {
    NumPut(dwNumberOfItems, struct, 0, "UInt")
    NumPut(dwIndex, struct, 4, "UInt")
    struct_Network_ptr := &struct + 8, struct_Network_length := 1
; }





;struct = pointer to individual network
VarSetCapacity(struct, 628, 0)
; typedef struct _WLAN_AVAILABLE_NETWORK {
    struct_strProfileName_ptr := &struct + 0, struct_strProfileName_type := "UInt", struct_strProfileName_length := 256
    dot11Ssid := NumGet(struct, 512, "UInt")
    dot11BssType := NumGet(struct, 548, "UInt")
    uNumberOfBssids := NumGet(struct, 552, "UInt")
    bNetworkConnectable := NumGet(struct, 556, "Int")
    wlanNotConnectableReason := NumGet(struct, 560, "UInt")
    uNumberOfPhyTypes := NumGet(struct, 564, "UInt")
    struct_dot11PhyTypes_ptr := &struct + 568, struct_dot11PhyTypes_type := "UInt", struct_dot11PhyTypes_length := 8
    bMorePhyTypes := NumGet(struct, 600, "Int")
    wlanSignalQuality := NumGet(struct, 604, "UInt")
    bSecurityEnabled := NumGet(struct, 608, "Int")
    dot11DefaultAuthAlgorithm := NumGet(struct, 612, "UInt")
    dot11DefaultCipherAlgorithm := NumGet(struct, 616, "UInt")
    dwFlags := NumGet(struct, 620, "UInt")
    dwReserved := NumGet(struct, 624, "UInt")
; }

; typedef struct _WLAN_AVAILABLE_NETWORK {
    struct_strProfileName_ptr := &struct + 0, struct_strProfileName_type := "UInt", struct_strProfileName_length := 256
    NumPut(dot11Ssid, struct, 512, "UInt")
    NumPut(dot11BssType, struct, 548, "UInt")
    NumPut(uNumberOfBssids, struct, 552, "UInt")
    NumPut(bNetworkConnectable, struct, 556, "Int")
    NumPut(wlanNotConnectableReason, struct, 560, "UInt")
    NumPut(uNumberOfPhyTypes, struct, 564, "UInt")
    struct_dot11PhyTypes_ptr := &struct + 568, struct_dot11PhyTypes_type := "UInt", struct_dot11PhyTypes_length := 8
    NumPut(bMorePhyTypes, struct, 600, "Int")
    NumPut(wlanSignalQuality, struct, 604, "UInt")
    NumPut(bSecurityEnabled, struct, 608, "Int")
    NumPut(dot11DefaultAuthAlgorithm, struct, 612, "UInt")
    NumPut(dot11DefaultCipherAlgorithm, struct, 616, "UInt")
    NumPut(dwFlags, struct, 620, "UInt")
    NumPut(dwReserved, struct, 624, "UInt")
; }



typedef struct _WLAN_AVAILABLE_NETWORK {
  WCHAR strProfileName[256];
  DOT11_SSID dot11Ssid;
  DOT11_BSS_TYPE dot11BssType;
  ULONG uNumberOfBssids;
  BOOL bNetworkConnectable;
  WLAN_REASON_CODE wlanNotConnectableReason;
  ULONG uNumberOfPhyTypes;
  DOT11_PHY_TYPE dot11PhyTypes[WLAN_MAX_PHY_TYPE_NUMBER];
  BOOL bMorePhyTypes;
  WLAN_SIGNAL_QUALITY wlanSignalQuality;
  BOOL bSecurityEnabled;
  DOT11_AUTH_ALGORITHM dot11DefaultAuthAlgorithm;
  DOT11_CIPHER_ALGORITHM dot11DefaultCipherAlgorithm;
  DWORD dwFlags;
  DWORD dwReserved;
} WLAN_AVAILABLE_NETWORK, 
 *PWLAN_AVAILABLE_NETWORK;
 */ 
;========================================================================================================================
WLAN_WlanAllocateMemory(dwMemorySize){
	;http://msdn.microsoft.com/en-us/library/ms706603(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanAllocateMemory", "UInt", dwMemorySize)
}

WLAN_WlanCloseHandle(hClientHandle){
	;http://msdn.microsoft.com/en-us/library/ms706610(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanCloseHandle", "UInt", hClientHandle, "UInt", 0)
}

WLAN_WlanConnect(hClientHandle,pInterfaceGuid,pConnectionParameters){
	;http://msdn.microsoft.com/en-us/library/ms706613(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanConnect", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", pConnectionParameters, "UInt", 0)
}

WLAN_WlanDeleteProfile(hClientHandle,pInterfaceGuid,strProfileName){
	;http://msdn.microsoft.com/en-us/library/ms706617(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanDeleteProfile", "UInt", hClientHandle, "UInt", pInterfaceGuid, "Uint", Wlan_Unicode4Ansi(strProfileName,strProfileName), "UInt", 0)
}

WLAN_WlanDisconnect(hClientHandle,pInterfaceGuid){
	;http://msdn.microsoft.com/en-us/library/ms706714(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanDisconnect", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", 0)
}

WLAN_WlanEnumInterfaces(hClientHandle){
	;http://msdn.microsoft.com/en-us/library/ms706716(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanEnumInterfaces", "UInt", hClientHandle, "UInt", 0, "UInt*", pInterfaceList)=0
		Return   pInterfaceList
}

WLAN_WlanExtractPsdIEDataList(hClientHandle,dwIeDataSize, pRawIeData,strFormat){
	;http://msdn.microsoft.com/en-us/library/ms706720(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanExtractPsdIEDataList", "UInt", hClientHandle, "UInt", dwIeDataSize, "Uint", pRawIeData, "Uint", Wlan_Unicode4Ansi(strFormat,strFormat), "UInt", 0, "UInt*",pPsdIEDataList)=0
		Return   pPsdIEDataList
}

WLAN_WlanFreeMemory(pMemory){
	;http://msdn.microsoft.com/en-us/library/ms706722(VS.85).aspx
	DllCall("Wlanapi.dll\WlanFreeMemory", "UInt", pMemory)
}

WLAN_WlanGetAvailableNetworkList(hClientHandle,pInterfaceGuid,dwFlags){
	;http://msdn.microsoft.com/en-us/library/ms706749(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanGetAvailableNetworkList", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", dwFlags, "UInt", 0, "UInt*", pAvailableNetworkList)=0
		Return   pAvailableNetworkList
}

WLAN_WlanGetFilterList(hClientHandle,wlanFilterListType){
	;http://msdn.microsoft.com/en-us/library/ms706729(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanGetFilterList", "UInt", hClientHandle, "Uint", wlanFilterListType, "UInt", 0, "UInt*", pNetworkList)=0
		Return   pNetworkList
}

WLAN_WlanGetInterfaceCapability(hClientHandle,pInterfaceGuid){
	;http://msdn.microsoft.com/en-us/library/ms706733(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanGetInterfaceCapability", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", 0, "UInt*", pCapability)=0
		Return   pCapability
}

WLAN_WlanGetNetworkBssList(hClientHandle,pInterfaceGuid,pDot11Ssid,dot11BssType,bSecurityEnabled){
	;http://msdn.microsoft.com/en-us/library/ms706735(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanGetNetworkBssList", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", pDot11Ssid, "UInt", dot11BssType, "Int", bSecurityEnabled, "UInt", 0, "UInt*", pWlanBssList)=0
		Return   pWlanBssList
} 

WLAN_WlanGetProfile(hClientHandle,pInterfaceGuid,strProfileName,ByRef dwFlags,ByRef dwGrantedAccess){
	;http://msdn.microsoft.com/en-us/library/ms706738(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanGetProfile", "UInt", hClientHandle, "UInt", pInterfaceGuid, "Uint", Wlan_Unicode4Ansi(strProfileName,strProfileName), "UInt", 0, "Uint*", pstrProfileXml, "UInt*", dwFlags, "UInt*", dwGrantedAccess)=0
		Return   Wlan_Ansi4Unicode(pstrProfileXml) . WLAN_WlanFreeMemory(pstrProfileXml)
}

WLAN_WlanGetProfileCustomUserData(hClientHandle,pInterfaceGuid,strProfileName,ByRef dwDataSize){
	;http://msdn.microsoft.com/en-us/library/ms706740(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanGetProfileCustomUserData","UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", Wlan_Unicode4Ansi(strProfileName,strProfileName), "UInt", 0, "UInt*", dwDataSize, "UInt*", pData)=0
		Return   pData
}

WLAN_WlanGetProfileList(hClientHandle,pInterfaceGuid){
	;http://msdn.microsoft.com/en-us/library/ms706743(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanGetProfileList", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", 0, "UInt*", pProfileList)=0
		Return   pProfileList
}

WLAN_WlanGetSecuritySettings(hClientHandle,SecurableObject, ByRef ValueType,ByRef dwGrantedAccess){
	;http://msdn.microsoft.com/en-us/library/ms706746(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanGetSecuritySettings", "UInt", hClientHandle, "UInt", SecurableObject, "UInt*", ValueType, "UInt*", pstrCurrentSDDL, "UInt*", dwGrantedAccess)=0
		Return   Wlan_Ansi4Unicode(pstrCurrentSDDL) . WLAN_WlanFreeMemory(pstrCurrentSDDL)
}

WLAN_WlanIhvControl(hClientHandle,pInterfaceGuid,Type,dwInBufferSize,pInBuffer,dwOutBufferSize,pOutBuffer){
	;http://msdn.microsoft.com/en-us/library/ms706754(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanIhvControl","UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", Type, "UInt", dwInBufferSize, "UInt", pInBuffer, "UInt", dwOutBufferSize, "UInt", pOutBuffer, "UInt*", dwBytesReturned)=0
		Return   dwBytesReturned
}

WLAN_WlanOpenHandle(dwClientVersion = 1, ByRef dwNegotiatedVersion = ""){   ; 2 for Vista
	;http://msdn.microsoft.com/en-us/library/ms706759(VS.85).aspx
	If   DllCall("wlanapi\WlanOpenHandle", "Uint", dwClientVersion, "Uint", 0, "Uint*", dwNegotiatedVersion, "Uint*", hClientHandle)=0
		Return   hClientHandle
}

WLAN_WlanQueryAutoConfigParameter(hClientHandle,OpCode,ByRef dwDataSize,ByRef WlanOpcodeValueType){
	;http://msdn.microsoft.com/en-us/library/ms706761(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanQueryAutoConfigParameter", "UInt", hClientHandle, "UInt", OpCode, "UInt", 0, "UInt*", dwDataSize, "UInt*", pData, "UInt*", WlanOpcodeValueType)=0
		Return   pData
}

WLAN_WlanQueryInterface(hClientHandle,pInterfaceGuid,OpCode,ByRef dwDataSize,ByRef WlanOpcodeValueType){
	;http://msdn.microsoft.com/en-us/library/ms706765(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanQueryInterface", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", OpCode, "UInt", 0, "UInt*", dwDataSize, "UInt*", pData, "UInt*", WlanOpcodeValueType)=0
		Return   pData
}

WLAN_WlanReasonCodeToString(dwReasonCode){
	;http://msdn.microsoft.com/en-us/library/ms706768(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanReasonCodeToString", "UInt", dwReasonCode, "UInt", VarSetCapacity(String,1024*2)//2, "UInt", &String, "UInt", 0)=0
		Return   Wlan_Ansi4Unicode(&String)
}

WLAN_WlanRegisterNotification(hClientHandle,dwNotifSource,bIgnoreDuplicate,funcCallback,pCallbackContext){
	;http://msdn.microsoft.com/en-us/library/ms706771(VS.85).aspx
	If   DllCall("Wlanapi.dll\WlanRegisterNotification", "UInt", hClientHandle, "UInt", dwNotifSource, "Int", bIgnoreDuplicate, "UInt", funcCallback, "UInt", pCallbackContext, "UInt", 0, "UInt*", dwPrevNotifSource)=0
		Return   dwPrevNotifSource
}

WLAN_WlanRenameProfile(hClientHandle, pInterfaceGuid, strOldProfileName, strNewProfileName){
	;http://msdn.microsoft.com/en-us/library/ms706773(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanRenameProfile", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", Wlan_Unicode4Ansi(strOldProfileName,strOldProfileName), "UInt", Wlan_Unicode4Ansi(strNewProfileName,strNewProfileName), "UInt", 0)
}

WLAN_WlanSaveTemporaryProfile(hClientHandle,pInterfaceGuid,strProfileName, strAllUserProfileSecurity,dwFlags,bOverWrite){
	;http://msdn.microsoft.com/en-us/library/ms706778(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSaveTemporaryProfile", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", Wlan_Unicode4Ansi(strProfileName,strProfileName), "UInt", Wlan_Unicode4Ansi(strAllUserProfileSecurity,strAllUserProfileSecurity), "UInt", dwFlags, "Int", bOverWrite, "UInt", 0)
}
   
WLAN_WlanScan(hClientHandle, pInterfaceGuid, pDot11Ssid, pIeData){
	;http://msdn.microsoft.com/en-us/library/ms706783(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanScan", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", pDot11Ssid, "UInt", pIeData, "UInt", 0)
}

WLAN_WlanSetAutoConfigParameter(hClientHandle,OpCode,dwDataSize,pData){
	;http://msdn.microsoft.com/en-us/library/ms706786(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetAutoConfigParameter", "UInt", hClientHandle, "UInt", OpCode, "UInt", dwDataSize, "UInt", pData, "UInt", 0)
}

WLAN_WlanSetFilterList(hClientHandle,wlanFilterListType,pNetworkList){
	;http://msdn.microsoft.com/en-us/library/ms706788(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetFilterList", "UInt", hClientHandle, "UInt", wlanFilterListType, "UInt", pNetworkList, "UInt", 0)
}
   
WLAN_WlanSetInterface(hClientHandle,pInterfaceGuid,OpCode,dwDataSize,pData){
	;http://msdn.microsoft.com/en-us/library/ms706791(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetInterface", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", OpCode, "UInt", dwDataSize, "UInt", pData, "UInt", 0)
}

WLAN_WlanSetProfile(hClientHandle, pInterfaceGuid, dwFlags, strProfileXml, strAllUserProfileSecurity, bOverwrite,ByRef dwReasonCode){
	;http://msdn.microsoft.com/en-us/library/ms706795(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetProfile", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", dwFlags, "UInt", Wlan_Unicode4Ansi(strProfileXml,strProfileXml), "UInt", Wlan_Unicode4Ansi(strAllUserProfileSecurity,strAllUserProfileSecurity), "UInt", bOverwrite, "UInt", 0, "UInt*", dwReasonCode)
}

WLAN_WlanSetProfileCustomUserData(hClientHandle,pInterfaceGuid,strProfileName,dwDataSize,pData){
	;http://msdn.microsoft.com/en-us/library/ms706822(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetProfileCustomUserData", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", Wlan_Unicode4Ansi(strProfileName,strProfileName), "UInt", dwDataSize, "UInt", pData, "UInt", 0)
}

WLAN_WlanSetProfileEapUserData(hClientHandle,pInterfaceGuid,strProfileName,eapType,dwFlags,dwEapUserDataSize,pbEapUserData){
	;http://msdn.microsoft.com/en-us/library/ms706797(VS.85).aspx	
	Return   DllCall("Wlanapi.dll\WlanSetProfileEapUserData", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", Wlan_Unicode4Ansi(strProfileName,strProfileName), "UInt", eapType, "UInt", dwFlags, "UInt", dwEapUserDataSize, "UInt", pbEapUserData, "UInt", 0)
}

WLAN_WlanSetProfileEapXmlUserData(hClientHandle,pInterfaceGuid,strProfileName,dwFlags,strEapXmlUserData){
	;http://msdn.microsoft.com/en-us/library/ms706802(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetProfileEapXmlUserData", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", Wlan_Unicode4Ansi(strProfileName,strProfileName), "UInt", dwFlags, "UInt", Wlan_Unicode4Ansi(strEapXmlUserData,strEapXmlUserData), "UInt", 0)
}

WLAN_WlanSetProfileList(hClientHandle,pInterfaceGuid,dwItems,pwstrProfileNames){
	;http://msdn.microsoft.com/en-us/library/ms706805(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetProfileList", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", dwItems, "UInt", pwstrProfileNames, "UInt", 0)
}

WLAN_WlanSetProfilePosition(hClientHandle,pInterfaceGuid,strProfileName,dwPosition){
	;http://msdn.microsoft.com/en-us/library/ms706810(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetProfilePosition", "UInt", hClientHandle, "UInt", pInterfaceGuid, "UInt", Wlan_Unicode4Ansi(strProfileName,strProfileName), "UInt", dwPosition, "UInt", 0)
}

WLAN_WlanSetPsdIEDataList(hClientHandle,strFormat,pPsdIEDataList){
	;http://msdn.microsoft.com/en-us/library/ms706815(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetPsdIEDataList", "UInt", hClientHandle, "UInt", Wlan_Unicode4Ansi(strFormat,strFormat), "UInt", pPsdIEDataList, "UInt", 0)
}
   
WLAN_WlanSetSecuritySettings(hClientHandle,SecurableObject,strModifiedSDDL){
	;http://msdn.microsoft.com/en-us/library/ms706819(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanSetSecuritySettings", "UInt", hClientHandle, "UInt", SecurableObject, "UInt", Wlan_Unicode4Ansi(strModifiedSDDL,strModifiedSDDL))
}

WLAN_WlanUIEditProfile(dwClientVersion,strProfileName,pInterfaceGuid,hWnd,wlStartPage,ByRef dwReasonCode){
	;http://msdn.microsoft.com/en-us/library/ms706825(VS.85).aspx
	Return   DllCall("Wlanapi.dll\WlanUIEditProfile", "UInt", dwClientVersion, "UInt", Wlan_Unicode4Ansi(strProfileName,strProfileName), "UInt", pInterfaceGuid, "UInt", hWnd, "UInt", wlStartPage, "UInt", 0, "UInt*", dwReasonCode)
}

WLAN_Init(){
   Return   DllCall("LoadLibrary", "str", "wlanapi.dll")
}

WLAN_UnInit(hWlan){
      DllCall("FreeLibrary", "UInt", hWlan)
}

Wlan_GUID4String(ByRef GUID, String)
{
   VarSetCapacity(GUID,16,0)
   If   DllCall("ole32\IIDFromString", "Uint", Wlan_Unicode4Ansi(String,String), "Uint", &GUID)=0
   Return   &GUID
}

Wlan_String4GUID(pGUID)
{
   VarSetCapacity(String,38*2+1,0)
   If   DllCall("ole32\StringFromGUID2", "Uint", pGUID, "Uint", &String, "int", 39)
   Return   Wlan_Ansi4Unicode(&String)
}

Wlan_Ansi4Unicode(pString)
{
   nSize:=   DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0), VarSetCapacity(sString,nSize)
   If   DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize, "Uint", 0, "Uint", 0)
   Return   sString
}

Wlan_Unicode4Ansi(ByRef wString, sString)
{
   nSize:=   DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0), VarSetCapacity(wString,nSize*2)
   If   DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize)
   Return   &wString
} 
