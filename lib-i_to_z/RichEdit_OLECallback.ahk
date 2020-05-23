;#include Gdip_All.ahk
;****************************
;RN_SetOLECallback by DigiDon
;Adapted from AutoIt RichEdit class
;
; In the sample we just add
;----->OLECallbackVars()
;----->RN_SetOLECallback(RE2.HWND)
;****************************
	;			MSDN OLECallback Mehods
	;*****************************
	; ContextSensitiveHelp
	; DeleteObject
	; GetClipboardData
	; GetContextMenu
	; GetDragDropEffect
	; GetInPlaceContext
	; GetNewStorage
	; QueryAcceptData
	; QueryInsertObject
	; ShowContainerUI
	;*****************************
	;			IMPLEMENTATION
	;*****************************
	; IUnknown method
	;!!!!!!!!!!!!!!!!!
	; QueryInterface
	; AddRef
	; Release
	;!!!!!!!!!!!!!!!!!
	; GetNewStorage
	; GetInPlaceContext
	; ShowContainerUI
	; QueryInsertObject
	; DeleteObject
	; QueryAcceptData
	; ContextSensitiveHelp
	; GetClipboardData
	; GetDragDropEffect
	; GetContextMenu
;****************************
RN_SetOLECallback(P_HWND) {
global

	If $pObj_RichCom
		return

	VarSetCapacity($pCall_RichCom, A_PtrSize*20, 0)

	NumPut($__RichCom_Object_QueryInterface, $pCall_RichCom, 0,"Ptr")
	NumPut($__RichCom_Object_AddRef, $pCall_RichCom, A_PtrSize*1,"Ptr")
	NumPut($__RichCom_Object_Release, $pCall_RichCom, A_PtrSize*2,"Ptr")
	NumPut($__RichCom_Object_GetNewStorage, $pCall_RichCom, A_PtrSize*3,"Ptr")
	NumPut($__RichCom_Object_GetInPlaceContext, $pCall_RichCom, A_PtrSize*4,"Ptr")
	NumPut($__RichCom_Object_ShowContainerUI, $pCall_RichCom, A_PtrSize*5,"Ptr")
	NumPut($__RichCom_Object_QueryInsertObject, $pCall_RichCom, A_PtrSize*6,"Ptr")
	NumPut($__RichCom_Object_DeleteObject, $pCall_RichCom, A_PtrSize*7,"Ptr")
	NumPut($__RichCom_Object_QueryAcceptData, $pCall_RichCom, A_PtrSize*8,"Ptr")
	NumPut($__RichCom_Object_ContextSensitiveHelp, $pCall_RichCom, A_PtrSize*9,"Ptr")
	NumPut($__RichCom_Object_GetClipboardData, $pCall_RichCom, A_PtrSize*10,"Ptr")
	NumPut($__RichCom_Object_GetDragDropEffect, $pCall_RichCom, A_PtrSize*11,"Ptr")
	NumPut($__RichCom_Object_GetContextMenu, $pCall_RichCom, A_PtrSize*12,"Ptr")
	NumPut(&$pCall_RichCom, $pObj_RichComObject, 0,"Ptr")
	NumPut(1, $pObj_RichComObject, A_PtrSize,"int")
	$pObj_RichCom := &$pObj_RichComObject
	;https://wiki.winehq.org/List_Of_Windows_Messages
	$EM_SETOLECALLBACK = 0x446
	SendMessage, % $EM_SETOLECALLBACK , 0, &$pObj_RichComObject,,ahk_id %P_HWND%

	if (ErrorLevel ="FAIL" or ErrorLevel=0) {
		; msgbox EM_SETOLECALLBACK FAILED
		return false
		}
	Return true
}

OLECallbackVars() {
global
	; #VARIABLES# =====================================================================================
	$_GCR_S_OK = 0
	$_GCR_E_NOTIMPL = 0x80004001
	$_GCR_E_INVALIDARG = 0x80070057
	$Debug_RE := False
	; $_GRE_sRTFClassName, $h_GUICtrlRTF_lib, $_GRE_Version, $_GRE_TwipsPeSpaceUnit := 1440 ; inches
	$_GRE_sRTFClassName:=""
	$h_GUICtrlRTF_lib:=""
	$_GRE_Version:=""
	$_GRE_TwipsPeSpaceUnit := 1440 ; inches
	; $_GRE_hUser32dll, $_GRE_CF_RTF, $_GRE_CF_RETEXTOBJ
	$_GRE_hUser32dll:=""
	$_GRE_CF_RTF:=""
	$_GRE_CF_RETEXTOBJ:=""
	;DigiDon: Not implemented yet
	$_GRC_StreamFromFileCallback := RegisterCallback("__GCR_StreamFromFileCallback")
	$_GRC_StreamFromVarCallback := RegisterCallback("__GCR_StreamFromVarCallback")
	$_GRC_StreamToFileCallback := RegisterCallback("__GCR_StreamToFileCallback")
	$_GRC_StreamToVarCallback := RegisterCallback("__GCR_StreamToVarCallback")
	$_GRC_sStreamVar:=""
	$gh_RELastWnd:=""
	VarSetCapacity($pObj_RichComObject, A_PtrSize+4, 0)
	$pCall_RichCom:=""
	$pObj_RichCom:=""
	;We could also preload the DLL, is it the right method?
	; hMod := DllCall( "GetModuleHandle", Str,"kernel32.dll" )
	; $hLib_RichCom_OLE32 := DllCall( "GetProcAddress", Ptr, hMod, Str, "OLE32" )
	$__RichCom_Object_QueryInterface := RegisterCallback("__RichCom_Object_QueryInterface")
	$__RichCom_Object_AddRef := RegisterCallback("__RichCom_Object_AddRef")
	$__RichCom_Object_Release := RegisterCallback("__RichCom_Object_Release")
	$__RichCom_Object_GetNewStorage := RegisterCallback("__RichCom_Object_GetNewStorage")
	$__RichCom_Object_GetInPlaceContext := RegisterCallback("__RichCom_Object_GetInPlaceContext")
	$__RichCom_Object_ShowContainerUI := RegisterCallback("__RichCom_Object_ShowContainerUI")
	$__RichCom_Object_QueryInsertObject := RegisterCallback("__RichCom_Object_QueryInsertObject")
	$__RichCom_Object_DeleteObject := RegisterCallback("__RichCom_Object_DeleteObject")
	$__RichCom_Object_QueryAcceptData := RegisterCallback("__RichCom_Object_QueryAcceptData")
	$__RichCom_Object_ContextSensitiveHelp := RegisterCallback("__RichCom_Object_ContextSensitiveHelp")
	$__RichCom_Object_GetClipboardData := RegisterCallback("__RichCom_Object_GetClipboardData")
	$__RichCom_Object_GetDragDropEffect := RegisterCallback("__RichCom_Object_GetDragDropEffect")
	$__RichCom_Object_GetContextMenu := RegisterCallback("__RichCom_Object_GetContextMenu")
}

; #INTERNAL_USE_ONLY# ===========================================================================================================
__RichCom_Object_QueryInterface($pObject, $REFIID, $ppvObj) {
	;~ '/////////////////////////////////////
	;~ '// OLE stuff, don't use yourself..
	;~ '/////////////////////////////////////
	;~ '// Useless procedure, never called..
	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_QueryInterface
	; Description ...:
	; Syntax.........: __RichCom_Object_QueryInterface($pObject, $REFIID, $ppvObj)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================
global
	;AHK COULD BE
	; msgbox __RichCom_Object_QueryInterface
	; return ComObjQuery($pObject, $REFIID)
	Return $_GCR_S_OK
}   ;==>__RichCom_Object_QueryInterface

__RichCom_Object_AddRef($pObject) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_AddRef
	; Description ...:
	; Syntax.........: __RichCom_Object_AddRef($pObject)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

	NumPut(NumGet($pObject + 0,A_PtrSize, "Int")+1, $pObject + 0, A_PtrSize, "Int")

	Return NumGet($pObject + 0,A_PtrSize, "Int")
}   ;==>__RichCom_Object_AddRef

__RichCom_Object_Release($pObject) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_Release
	; Description ...:
	; Syntax.........: __RichCom_Object_Release($pObject)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

	If ( NumGet($pObject + 0,A_PtrSize, "Int") > 0 ) {
		NumPut(NumGet($pObject + 0,A_PtrSize, "Int")-1, $pObject + 0, A_PtrSize, "Int")
		Return NumGet($pObject + 0,A_PtrSize, "Int")
	}
}   ;==>__RichCom_Object_Release

__RichCom_Object_GetInPlaceContext($pObject, $lplpFrame, $lplpDoc, $lpFrameInfo) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_GetInPlaceContext
	; Description ...:
	; Syntax.........: __RichCom_Object_GetInPlaceContext($pObject, $lplpFrame, $lplpDoc, $lpFrameInfo)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

global
	Return $_GCR_E_NOTIMPL
}   ;==>__RichCom_Object_GetInPlaceContext

__RichCom_Object_ShowContainerUI($pObject, $fShow) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_ShowContainerUI
	; Description ...:
	; Syntax.........: __RichCom_Object_ShowContainerUI($pObject, $fShow)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================
global
	Return $_GCR_E_NOTIMPL
}   ;==>__RichCom_Object_ShowContainerUI

__RichCom_Object_QueryInsertObject($pObject, $lpclsid, $lpstg, $cp) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_QueryInsertObject
	; Description ...:
	; Syntax.........: __RichCom_Object_QueryInsertObject($pObject, $lpclsid, $lpstg, $cp)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

global
	; msgbox __RichCom_Object_QueryInsertObject
	;MSDN SAYS
	; The member is called when pasting and when reading Rich Text Format (RTF).
	Return $_GCR_S_OK
}   ;==>__RichCom_Object_QueryInsertObject

__RichCom_Object_DeleteObject($pObject, $lpoleobj) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_DeleteObject
	; Description ...:
	; Syntax.........: __RichCom_Object_DeleteObject($pObject, $lpoleobj)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

global
	Return $_GCR_S_OK
	; Return $_GCR_E_NOTIMPL
}   ;==>__RichCom_Object_DeleteObject

__RichCom_Object_QueryAcceptData($pObject, $lpdataobj, $lpcfFormat, $reco, $fReally, $hMetaPict) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_QueryAcceptData
	; Description ...:
	; Syntax.........: __RichCom_Object_QueryAcceptData($pObject, $lpdataobj, $lpcfFormat, $reco, $fReally, $hMetaPict)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

	global
	$fFormat:=NumGet($lpcfFormat + 0,0,"UInt")
	static CF_BITMAP=2
	static CF_DIB=8
	static CF_DIBV5=17
	static CF_TIFF=6
	static CF_ENHMETAFILE=14
	static CF_METAFILEPICT=3
	static CF_PALETTE=9
	static CF_DSPBITMAP:=0x0082
	static CF_DSPMETAFILEPICT:=0x0083
	static CF_DSPENHMETAFILE:=0x008E
	static CF_GDIOBJFIRST:=0x0300
	static CF_GDIOBJLAST:=0x03FF
		if (A_OSVersion="WIN_7") {
			if $bAcceptData
				Return $_GCR_S_OK
			else if !$fReally
			if ($lpcfFormat == CF_DIB || $lpcfFormat == CF_DIBV5
		  || $lpcfFormat == CF_BITMAP || $lpcfFormat == CF_TIFF
		  || $lpcfFormat == CF_ENHMETAFILE || $lpcfFormat == CF_METAFILEPICT
		  || $lpcfFormat == CF_PALETTE || $lpcfFormat == CF_DSPBITMAP
		  || $lpcfFormat == CF_DSPMETAFILEPICT || $lpcfFormat == CF_DSPENHMETAFILE
		  || ($lpcfFormat >= CF_GDIOBJFIRST && $lpcfFormat <= CF_GDIOBJLAST))
				{
				; msgbox $lpcfFormat %$lpcfFormat%
				MsgBox % "If you wish to add an image on Windows 7 or older, you must do a right click and select add image."
				Return $_GCR_E_INVALIDARG
				}
				; msgbox accepted $lpcfFormat %$lpcfFormat%
			}

Return $_GCR_S_OK
}   ;==>__RichCom_Object_QueryAcceptData

__RichCom_Object_ContextSensitiveHelp($pObject, $fEnterMode) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_ContextSensitiveHelp
	; Description ...:
	; Syntax.........: __RichCom_Object_ContextSensitiveHelp($pObject, $fEnterMode)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

global
	Return $_GCR_E_NOTIMPL
}   ;==>__RichCom_Object_ContextSensitiveHelp

__RichCom_Object_GetClipboardData($pObject, $lpchrg, $reco, $lplpdataobj) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_GetClipboardData
	; Description ...:
	; Syntax.........: __RichCom_Object_GetClipboardData($pObject, $lpchrg, $reco, $lplpdataobj)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

global
	Return $_GCR_E_NOTIMPL
}   ;==>__RichCom_Object_GetClipboardData

__RichCom_Object_GetDragDropEffect($pObject, $fDrag, $grfKeyState, $pdwEffect) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_GetDragDropEffect
	; Description ...:
	; Syntax.........: __RichCom_Object_GetDragDropEffect($pObject, $fDrag, $grfKeyState, $pdwEffect)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

global
	Return $_GCR_E_NOTIMPL
}   ;==>__RichCom_Object_GetDragDropEffect

__RichCom_Object_GetContextMenu($pObject, $seltype, $lpoleobj, $lpchrg, $lphmenu) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_GetContextMenu
	; Description ...:
	; Syntax.........: __RichCom_Object_GetContextMenu($pObject, $seltype, $lpoleobj, $lpchrg, $lphmenu)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================

global
	Menu, ContextMenu,Show
	Return $_GCR_E_NOTIMPL
	; MenuHdanle:=MenuGetHandle("ContextMenu")
	; msgbox MenuHdanle %MenuHdanle%
	; msgbox lphmenu %$lphmenu%
	; NumPut(MenuHdanle,$lphmenu+0,0,"Int")
	; msgbox % NumGet($lphmenu+0,0,"Int")

	; msgbox % IsObject($pObject)
	; __RichCom_Object_AddRef($pObject)
	; msgbox return
	; msgbox % $_GCR_S_OK
	; Return $_GCR_S_OK
	; Return MenuHdanle
	; Return $E_INVALIDARG
	; msgbox here
	; Menu, ContextMenu, Show
	; Return $_GCR_E_NOTIMPL
}   ;==>__RichCom_Object_GetContextMenu

__RichCom_Object_GetNewStorage($pObject, $pPstg) {

	; #INTERNAL_USE_ONLY# ===========================================================================================================
	; Name...........: __RichCom_Object_GetNewStorage
	; Description ...:
	; Syntax.........: __RichCom_Object_GetNewStorage($pObject, $lplpstg)
	; Parameters ....:
	; Return values .:
	; Author ........:
	; Modified.......:
	; Remarks .......:
	; Related .......:
	; Link ..........:
	; Example .......:
	; ===============================================================================================================================
global
	; 0x10|2|0x1000
	; STGM_SHARE_EXCLUSIVE | STGM_CREATE | STGM_READWRITE
	; 0x00000010L;0x00001000L;0x00000002L
	; STGM_TRANSACTED :0x00010000L
	; STGM_READWRITE or STGM_SHARE_EXCLUSIVE or STGM_CREATE
	Local $lpLockBytes:=0
	Local $aSc := DllCall("OLE32\CreateILockBytesOnHGlobal", "Ptr", 0, "int", 1, "ptr*", $lpLockBytes, "Uint")

	If $aSc
		Return $aSc

	local $ppstgOpen:=0
	$aSc := DllCall("OLE32\StgCreateDocfileOnILockBytes", "Ptr", $lpLockBytes, "Uint", 0x10 | 2 | 0x1000, "Uint", 0, "ptr*", $ppstgOpen, "Uint")
	NumPut($ppstgOpen, $pPstg+0, 0, "Ptr")

	If ($aSc) {
		ObjRelease($lpLockBytes)
	}
	Return $aSc
}   ;==>__RichCom_Object_GetNewStorage

RN_InsertObject(HRE, FilePath) { ; Insert files as OLE objects

	; ================================================================================================================================
	; Insert files as OLE objects
	; How to Use OLE in Rich Edit Controls <- msdn.microsoft.com/en-us/library/windows/desktop/dd387916(v=vs.85).aspx
	; ================================================================================================================================
   ; EM_GETOLEINTERFACE := 0x43C

   HR := DllCall("SendMessage", "Ptr", HRE, "UInt", 0x043C, "Ptr", 0, "PtrP", IRichEditOle, "UInt")
   If (HR = 0) {
      ErrorLevel := Format("0x{:08X}", HR)
      Return False
   }
   ; OutputDebug, EM_GETOLEINTERFACE - %ErrorLevel% - %IRichEditOle%
   ; msdn.microsoft.com/en-us/library/windows/desktop/aa378977(v=vs.85).aspx
	HR := DllCall("Ole32.dll\CreateILockBytesOnHGlobal", "Ptr", 0, "Int", 1, "PtrP", ILockBytes, "UInt")
   If (HR) {
      ErrorLevel := Format("0x{:08X}", HR)
      ObjRelease(IRichEditOle)
      Return False
   }
   ; OutputDebug, CreateILockBytesOnHGlobal - %ErrorLevel% - %ILockBytes%
   ; msdn.microsoft.com/en-us/library/windows/desktop/aa380324(v=vs.85).aspx
   ; STGM_READWRITE = 0x02, STGM_SHARE_EXCLUSIVE = 0x10, STGM_CREATE = 0x1000
	HR := DllCall("Ole32.dll\StgCreateDocfileOnILockBytes", "Ptr", ILockBytes, "UInt", 0x1012, "UInt", 0, "PtrP", IStorage, "UInt")
   If (HR) {
      ErrorLevel := Format("0x{:08X}", HR)
      ObjRelease(ILockBytes)
      ObjRelease(IRichEditOle)
      Return False
   }
   ; OutputDebug, StgCreateDocfileOnILockBytes - %ErrorLevel% - %IStorage%
   GetClientSite := NumGet(NumGet(IRichEditOle + 0, "UPtr") + (A_PtrSize * 3), "UPtr")
   HR := DllCall(GetClientSite, "Ptr", IRichEditOle, "PtrP", IOleClientSite, "UInt")
   If (HR) {
      ErrorLevel := Format("0x{:08X}", HR)
      ObjRelease(IStorage)
      ObjRelease(ILockBytes)
      ObjRelease(IRichEditOle)
      Return False
   }
   ; OutputDebug, GetClientSite - %ErrorLevel% - %IOleClientSite%
   VarSetCapacity(FORMATETC, A_PtrSize = 8 ? 32 : 20, 0)
   NumPut( 1, FORMATETC, A_PtrSize = 8 ? 16 : 8 , "UInt") ; DVASPECT_CONTENT
   NumPut(-1, FORMATETC, A_PtrSIze = 8 ? 20 : 12, "Int")  ; all data
   NumPut( 0, FORMATETC, A_PtrSize = 8 ? 24 : 16, "UInt") ; TYMED_NULL
   VarSetCapacity(CLSID_NULL, 16, 0)
   VarSetCapacity(IID_IOleObject, 16, 0)
   DllCall("Ole32.dll\CLSIDFromString", "WStr", "{00000112-0000-0000-C000-000000000046}", "Ptr", &IID_IOleObject)
   OLERENDER_DRAW := 1
   HR := DllCall("Ole32.dll\OleCreateFromFile", "Ptr", &CLSID_NULL, "WStr", FilePath, "Ptr", &IID_IOleObject
                                              , "UInt", OLERENDER_DRAW, "Ptr", &FORMATETC, "Ptr", IOleClientSite
                                              , "Ptr", IStorage, "PtrP", IOleObject, "UInt")
   If (HR) {
      ErrorLevel := Format("0x{:08X}", HR)
      ObjRelease(IStorage)
      ObjRelease(ILockBytes)
      ObjRelease(IOleClientSite)
      ObjRelease(IRichEditOle)
      Return False
   }
   ; OutputDebug, OleCreateFromFile - %ErrorLevel% - %IOleObject%
   DllCall("Ole32.dll\OleSetContainedObject", "Ptr", IOleObject, "UInt", 1, "UInt")
   ; OutputDebug, OleSetContainedObject - %ErrorLevel%
   VarSetCapacity(CLSID_USER, 16, 0)
   GetUserClassID := NumGet(NumGet(IOleObject + 0, "UPtr") + (A_PtrSize * 15), "UPtr")
   HR := DllCall(GetUserClassID, "Ptr", IOleObject, "Ptr", &CLSID_USER, "UInt")
   If (HR) {
      ErrorLevel := Format("0x{:08X}", HR)
      ObjRelease(IStorage)
      ObjRelease(ILockBytes)
      ObjRelease(IOleClientSite)
      ObjRelease(IOleObject)
      ObjRelease(IRichEditOle)
      Return False
   }
   ; CLSID :=  Format("{:016X} {:016X}", NumGet(CLSID_USER, "Int64"), NumGet(CLSID_USER, 8, "Int64"))
   ; OutputDebug, GetUserClassID - %ErrorLevel% - %CLSID%
   SizeOfREOBJECT := A_PtrSize = 8 ? (A_PtrSize * 9) : (A_PtrSize * 10) + 16
   VarSetCapacity(REOBJECT, SizeOfREOBJECT, 0)
   Addr := &REOBJECT
   Addr := NumPut(SizeOfREOBJECT, Addr + 0, "UInt")
   Addr := NumPut(0xFFFFFFFF, Addr + 0, "UInt") ; REO_CP_SELECTION
   Addr := NumPut(NumGet(CLSID_USER, 0, "Int64"), Addr + 0, "Int64")
   Addr := NumPut(NumGet(CLSID_USER, 8, "Int64"), Addr + 0, "Int64")
   Addr := NumPut(IOleObject, Addr + 0, "UPtr")
   Addr := NumPut(IStorage, Addr + 0, "UPtr")
   Addr := NumPut(IOleClientSite, Addr + 0, "UPtr")
   Addr += 8 ; sizel = 0
   Addr := NumPut(1, Addr + 0, "UPtr") ; DVASPECT_CONTENT
   Addr := NumPut(3, Addr + 0, "UPtr") ; REO_RESIZABLE | REO_BELOWBASELINE
   InsertObject := NumGet(NumGet(IRichEditOle + 0, "UPtr") + (A_PtrSize * 7), "UPtr")
   HR := DllCall(InsertObject, "Ptr", IRichEditOle, "Ptr", &REOBJECT, "UInt")
   ObjRelease(ILockBytes)
   ObjRelease(IStorage)
   ObjRelease(IOleClientSite)
   ObjRelease(IRichEditOle)
   ObjRelease(IOleObject)
   Return !(ErrorLevel := Format("0x{:08X}", HR))
}


