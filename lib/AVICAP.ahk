AVICAP_Startup()
{
	DllCall("LoadLibrary", "str", "avicap32.dll")
}

AVICAP_SetCam(CamWinhWnd)
{
	WinGetPos,,, W, H, ahk_id %CamWinhWnd%
	WS_CHILD := 0x40000000
	WS_VISIBLE := 0x10000000 
	lpszWindowName := "test"
	capHWnd := DLLCall("avicap32\capCreateCaptureWindowA", "str", lpszWindowName, "int", WS_VISIBLE | WS_CHILD, "int", 0, "int", 0, "int", W, "int", H, "int", CamWinhWnd, "int", 0)
  

	WM_CAP := 0x400
	WM_CAP_DRIVER_CONNECT := WM_CAP + 10
	WM_CAP_SET_PREVIEW := WM_CAP + 50
	WM_CAP_SET_PREVIEWRATE := WM_CAP + 52
	WM_CAP_SET_SCALE := WM_CAP + 53
	SelectedDriver := 0
	
	SendMessage, WM_CAP_DRIVER_CONNECT, %SelectedDriver%, 0, , ahk_id %capHwnd%
	while(!ErrorLevel)
		SendMessage, WM_CAP_DRIVER_CONNECT, %SelectedDriver%, 0, , ahk_id %capHwnd%
	SendMessage, WM_CAP_SET_SCALE, 1, 0, , ahk_id %capHwnd%
	FPS := 500
	MSC := round((1/FPS)*1000)
	SendMessage, WM_CAP_SET_PREVIEWRATE, MSC, 0, , ahk_id %capHwnd%
	SendMessage, WM_CAP_SET_PREVIEW, 1, 0, , ahk_id %capHwnd%
	return, capHwnd
}

AVICAP_GrabImage(ImageFile, capHWnd)
{
	WM_CAP_START := 0x0400
	WM_CAP_FILE_SAVEDIB := WM_CAP_START + 25
	SendMessage, WM_CAP_FILE_SAVEDIB, 0, &imagefile, , ahk_id %capHwnd%
	return, ErrorLevel
}
