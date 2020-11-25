class DWM
{
  __new(){
		DllCall("LoadLibrary","str","dwmapi.dll")
		this._i:={1:DwmEnableBlurBehindWindow,2:DwmEnableComposition,3:DwmEnableMMCSS,4:DwmExtendFrameIntoClientArea,5:DwmGetColorizationColor,6:DwmGetColorizationColor,7:DwmGetCompositionTimingInfo,8:DwmGetWindowAttribute,9:DwmIsCompositionEnabled,10:DwmModifyPreviousDxFrameDuration,11:DwmQueryThumbnailSourceSize,12:DwmRegisterThumbnail,13:DwmSetDxFrameDuration,14:DwmSetPresentParameters,15:DwmSetWindowAttribute,16:DwmUnregisterThumbnail,17:DwmUpdateThumbnailProperties,18:DwmSetIconicThumbnail,19:DwmSetIconicLivePreviewBitmap,20:DwmInvalidateIconicBitmaps,21:DwmAttachMilContent,22:DwmDetachMilContent,23:DwmGetGraphicsStreamTransformHint,24:DwmGetGraphicsStreamTransformHint,25:DwmGetTransportAttributes}
	}
	__call(aName,aParam*){
		if aName is Integer
			if this._i.HasKey(aName)
				return this[this._i[aName]](aParam*)
	}
	__get(aName){
		if this._i.haskey(aName)
			return this[this._i[aName]]()
	}
/*
	DwmDefWindowProc(hwnd,msg,wParam,lParam,plResult){
	}
*/
	DwmEnableBlurBehindWindow(hwnd,pBlurBehind){
	return Dllcall("Dwmapi\DwmEnableBlurBehindWindow","ptr",hwnd,"ptr",pBlurBehind)
	}
	DwmEnableComposition(uCompositionAction){
	return Dllcall("Dwmapi\DwmEnableComposition","uint",uCompositionAction)
	}
	DwmEnableMMCSS(fEnableMMCSS){
	return Dllcall("Dwmapi\DwmEnableMMCSS","int",fEnableMMCSS)
	}
	DwmExtendFrameIntoClientArea(hWnd,pMarInset){
	return Dllcall("Dwmapi\DwmExtendFrameIntoClientArea","ptr",hWnd,"ptr",pMarInset)
	}
	DwmGetColorizationColor(ByRef crColorization,ByRef fOpaqueBlend){
	return Dllcall("Dwmapi\DwmGetColorizationColor","uint*",crColorization,"int*",fOpaqueBlend)
	}
	DwmGetCompositionTimingInfo(hwnd,ByRef pTimingInfo){
	return Dllcall("Dwmapi\DwmGetCompositionTimingInfo","ptr",hwnd,"ptr",pTimingInfo)
	}
	DwmGetWindowAttribute(hwnd,dwAttribute,cbAttribute){
	Dllcall("Dwmapi\DwmGetWindowAttribute","ptr",hwnd,"uint",dwAttribute,"ptr*",Attribute,"uint",cbAttribute)
	return Attribute
	}
	DwmIsCompositionEnabled(){
	Dllcall("Dwmapi\DwmIsCompositionEnabled","int*",pfEnabled)
	return 
	}
	DwmModifyPreviousDxFrameDuration(hwnd,cRefreshes,fRelative){
	return Dllcall("Dwmapi\DwmModifyPreviousDxFrameDuration","ptr",hwnd,"int",cRefreshes,"int",fRelative)
	}
	DwmQueryThumbnailSourceSize(hThumbnail){
	Dllcall("Dwmapi\DwmQueryThumbnailSourceSize","ptr",hThumbnail,"int64*",size)
	return [size&0xFFFFFFFF,size>>32]
	}
	DwmRegisterThumbnail(hwndDestination,hwndSource){
	Dllcall("Dwmapi\DwmRegisterThumbnail","ptr",hwndDestination,"ptr",hwndSource,"ptr*",hThumbnailId)
	return hThumbnailId
	}
	DwmSetDxFrameDuration(hwnd,cRefreshes){
	return Dllcall("Dwmapi\DwmSetDxFrameDuration","ptr",hwnd,"int",cRefreshes)
	}
	DwmSetPresentParameters(hwnd,pPresentParams){
	return Dllcall("Dwmapi\DwmSetPresentParameters","ptr",hwnd,"ptr",pPresentParams)
	}
	DwmSetWindowAttribute(hwnd,dwAttribute,pvAttribute,cbAttribute){
	return Dllcall("Dwmapi\DwmSetWindowAttribute","ptr",hwnd,"uint",dwAttribute,"ptr",pvAttribute,"uint",cbAttribute)
	}
	DwmUnregisterThumbnail(hThumbnailId){
	return Dllcall("Dwmapi\DwmUnregisterThumbnail","ptr",hThumbnailId)
	}
	DwmUpdateThumbnailProperties(hThumbnailId,ptnProperties){
	return Dllcall("Dwmapi\DwmUpdateThumbnailProperties","ptr",hThumbnailId,"ptr",ptnProperties)
	}
	DwmSetIconicThumbnail(hwnd,hbmp,dwSITFlags){
	return Dllcall("Dwmapi\DwmSetIconicThumbnail","ptr",hwnd,"ptr",hbmp,"uint",dwSITFlags)
	}
	DwmSetIconicLivePreviewBitmap(hwnd,hbmp,pptClient,dwSITFlags){
	return Dllcall("Dwmapi\DwmSetIconicLivePreviewBitmap","ptr",hwnd,"ptr",hbmp,"ptr",pptClient,"uint",dwSITFlags)
	}
	DwmInvalidateIconicBitmaps(hwnd){
	return Dllcall("Dwmapi\DwmInvalidateIconicBitmaps","ptr",hwnd)
	}
	DwmAttachMilContent(hwnd){
	return Dllcall("Dwmapi\DwmAttachMilContent","ptr",hwnd)
	}
	DwmDetachMilContent(hwnd){
	return Dllcall("Dwmapi\DwmDetachMilContent","ptr",hwnd)
	}
	DwmGetGraphicsStreamTransformHint(uIndex,pTransform){
	return Dllcall("Dwmapi\DwmGetGraphicsStreamTransformHint","uint",uIndex,"ptr",pTransform)
	}
	DwmGetGraphicsStreamTransformHint(uIndex,pClientUuid){
	return Dllcall("Dwmapi\DwmGetGraphicsStreamTransformHint","uint",uIndex,"ptr",pClientUuid)
	}
	DwmGetTransportAttributes(ByRef pfIsRemoting,ByRef pfIsConnected,ByRef pDwGeneration){
	return Dllcall("Dwmapi\DwmGetTransportAttributes","int*",pfIsRemoting,"int*",pfIsConnected,"uint*",pDwGeneration)
	}
}
