/*
	Function: ContextMenu
			  Show context menu for path.

	Parameters:
			  Path	 - File system path or PIDL.
 */

Shell_ContextMenu(Path) {
   COM_Init()
   If Path is not Integer
		DllCall("shell32\SHParseDisplayName", "Uint", COM_Unicode4Ansi(wPath,Path), "Uint", 0, "UintP", pidl, "Uint", 0, "Uint", 0)
   else DllCall("shell32\SHGetFolderLocation", "Uint", 0, "int", sPath, "Uint", 0, "Uint", 0, "UintP", pidl)

   DllCall("shell32\SHBindToParent", "Uint", pidl, "Uint", COM_GUID4String(IID_IShellFolder,"{000214E6-0000-0000-C000-000000000046}"), "UintP", psf, "UintP", pidlChild)
   DllCall(NumGet(NumGet(1*psf)+40), "Uint", psf, "Uint", 0, "Uint", 1, "UintP", pidlChild, "Uint",COM_GUID4String(IID_IContextMenu,"{000214E4-0000-0000-C000-000000000046}"), "Uint", 0, "UintP", pcm)
   COM_Release(psf)
   COM_CoTaskMemFree(pidl)

   hMenu := DllCall("CreatePopupMenu")
   DllCall(NumGet(NumGet(1*pcm)+12), "Uint", pcm, "Uint", hMenu, "Uint", 0, "Uint", 3, "Uint", 0x7FFF, "Uint", 0)   ; QueryContextMenu
   DetectHiddenWindows, On
   Process, Exist
   WinGet, hAHK, ID, ahk_pid %ErrorLevel%
   WinActivate, ahk_id %hAHK%
   Global   pcm2 := COM_QueryInterface(pcm,IID_IContextMenu2:="{000214F4-0000-0000-C000-000000000046}")
   Global   pcm3 := COM_QueryInterface(pcm,IID_IContextMenu3:="{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}")
   Global   WPOld:= DllCall("SetWindowLong", "Uint", hAHK, "int",-4, "int",RegisterCallback("WindowProc"))
   DllCall("GetCursorPos", "int64P", pt)
   DllCall("InsertMenu", "Uint", hMenu, "Uint", 0, "Uint", 0x0400|0x800, "Uint", 2, "Uint", 0)
   DllCall("InsertMenu", "Uint", hMenu, "Uint", 0, "Uint", 0x0400|0x002, "Uint", 1, "Uint", &sPath)
   idn := DllCall("TrackPopupMenu", "Uint", hMenu, "Uint", 0x0100, "int", pt << 32 >> 32, "int", pt >> 32, "Uint", 0, "Uint", hAHK, "Uint", 0)
   NumPut(VarSetCapacity(ici,64,0),ici), NumPut(0x4000|0x20000000,ici,4), NumPut(1,NumPut(hAHK,ici,8),12), NumPut(idn-3,NumPut(idn-3,ici,12),24), NumPut(pt,ici,56,"int64")
   DllCall(NumGet(NumGet(1*pcm)+16), "Uint", pcm, "Uint", &ici)   ; InvokeCommand
;   VarSetCapacity(sName,259), DllCall(NumGet(NumGet(1*pcm)+20), "Uint", pcm, "Uint", idn-3, "Uint", 1, "Uint", 0, "str", sName, "Uint", 260)   ; GetCommandString
   DllCall("GlobalFree", "Uint", DllCall("SetWindowLong", "Uint", hAHK, "int", -4, "int", WPOld))
   DllCall("DestroyMenu", "Uint", hMenu)
   COM_Release(pcm3)
   COM_Release(pcm2)
   COM_Release(pcm)
   pcm2:=pcm3:=WPOld:=0
}

WindowProc(hWnd, nMsg, wParam, lParam)
{
   Critical
   Global   pcm2, pcm3, WPOld
   If   pcm3
   {
      If   !DllCall(NumGet(NumGet(1*pcm3)+28), "Uint", pcm3, "Uint", nMsg, "Uint", wParam, "Uint", lParam, "UintP", lResult)
         Return   lResult
   }
   Else If   pcm2
   {
      If   !DllCall(NumGet(NumGet(1*pcm2)+24), "Uint", pcm2, "Uint", nMsg, "Uint", wParam, "Uint", lParam)
         Return   0
   }
   Return   DllCall("user32.dll\CallWindowProcA", "Uint", WPOld, "Uint", hWnd, "Uint", nMsg, "Uint", wParam, "Uint", lParam)
}

