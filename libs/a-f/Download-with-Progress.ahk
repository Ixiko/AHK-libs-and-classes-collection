/*	Allows showing a progress download bar
	Usage: Download(url, file)
*/

Download(url, file) {
/*		Credits to joedf
		autohotkey.com/board/topic/17915-urldownloadtofile-progress/?p=584346
*/
	overwriteflag:=1

	static vt
	if !VarSetCapacity(vt)
	{
		VarSetCapacity(vt, A_PtrSize*11), nPar := "31132253353"
		Loop Parse, nPar
			NumPut(RegisterCallback("DL_Progress", "F", A_LoopField, A_Index-1), vt, A_PtrSize*(A_Index-1))
	}
	global _cu
	SplitPath file, dFile
	SysGet m, MonitorWorkArea, 1
	y := mBottom-52-2, x := mRight-330-2, VarSetCapacity(_cu, 100), VarSetCapacity(tn, 520)
	, DllCall("shlwapi\PathCompactPathEx", "str", _cu, "str", url, "uint", 50, "uint", 0)
	Progress Hide CW1A1A1A CTFFFFFF CB666666 x%x% y%y% w330 h52 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11,, %_cu%, AutoHotkeyProgress, Tahoma
	if (0 = DllCall("urlmon\URLDownloadToCacheFile", "ptr", 0, "str", url, "str", tn, "uint", 260, "uint", 0x10, "ptr*", &vt))
	{
		FileCopy %tn%, %file%, %overwriteflag%
	}
	else
	{
		ErrorLevel := 1
	}
	Progress Off
	return !ErrorLevel
}

DL_Progress( pthis, nP=0, nPMax=0, nSC=0, pST=0 ) {
	global _cu
	if A_EventInfo = 6
	{
		Progress Show
		Progress % P := 100*nP//nPMax, % "Downloading: " Round(np/1024,1) " KB / " Round(npmax/1024) " KB [ " P "`% ]", %_cu%
	}
	return 0
}
