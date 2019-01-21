;This file contains a bunch of functions used for checking/setting various windows settings
;from 7plus.ahk
;==========================================================
;Getter functions: Return 1 when enabled, 0 when disabled, or -1 when not used on this OS.
;==========================================================

/*
Settings that require explorer restart:
Remove user directories (new explorer window is enough)
Remove explorer libraries (possibly logoff)
cycle through windows
Show all tray notification icons
thumbnail hover time

settings that require reboot:
Disable UAC
*/
Class WindowsSettings
{
	GetShowAllNotifications()
	{
		RegRead, ShowAllTray, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer, EnableAutoTray
		return ShowAllTray = 1 ? 0 : 1
	}

	GetRemoveUserDir()
	{
		RegRead, RemoveUserDir, HKCR, CLSID\{59031a47-3f72-44a7-89c5-5595fe6b30ee}\ShellFolder, Attributes
		return RemoveUserDir = 0xf084012d ? 0 : 1
	}

	GetRemoveWMP()
	{
		if(A_OSVersion = "WIN_XP")
			RegRead, RemoveWMP, HKCR, CLSID\{CE3FB1D1-02AE-4a5f-A6E9-D9F1B4073E6C}
		else
			RegRead, RemoveWMP, HKCR, SystemFileAssociations\Directory.Audio\shellex\ContextMenuHandlers\WMPShopMusic
		return RemoveWMP = "" ? 1 : 0
	}

	GetRemoveOpenWith()
	{
		RegRead, RemoveOpenWith, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer, NoInternetOpenWIth
		return RemoveOpenWith = 1 ? 1 : 0
	}

	GetRemoveCrashReporting()
	{
		RegRead, RemoveCrashReporting, HKLM, Software\Microsoft\Windows\Windows Error Reporting, DontShowUI
		return RemoveCrashReporting = 1 ? 1 : 0
	}

	GetShowExtensions()
	{
		RegRead, ShowExtensions, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt 
		return ShowExtensions = 1 ? 0 : 1
	}

	GetShowHiddenFiles()
	{
		RegRead, ShowHiddenFiles, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden 
		return ShowHiddenFiles = 2 ? 0 : 1
	}

	GetShowSystemFiles()
	{
		RegRead, ShowSystemFiles, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden 
		return ShowSystemFiles
	}

	GetDisableUAC()
	{
		if(WinVer >= WIN_Vista)
		{
			RegRead, DisableUAC, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System, EnableLUA 
			return DisableUAC = 0 ? 1 : 0
		}
		return -1
	}	

	GetClassicExplorerView()
	{
		if(A_OSVersion = "WIN_XP")
		{
			RegRead, ClassicView, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced, WebView
			return ClassicView = 0 ? 1 : 0
		}
		return -1
	}

	GetRemoveLibraries()
	{
		if(WinVer >= WIN_7)
		{
			RegRead, RemoveLibraries, HKCR, CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder, Attributes
			return  RemoveLibraries = 0xb090010d ? 1 : 0	
		}
		return -1
	}

	GetCycleThroughTaskbarGroup()
	{
		if(WinVer >= WIN_7)
		{
			RegRead, ActivateBehavior, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, LastActiveClick
			return ActivateBehavior = 1
		
		}
		return -1
	}

	;This function actually returns a time in ms.
	GetThumbnailHoverTime()
	{
		if(WinVer >= WIN_7)
		{
			RegRead, ThumbnailHoverTime, HKCU, Control Panel\Mouse, MouseHoverTime
			return ThumbnailHoverTime = "" ? 400 : ThumbnailHoverTime	
		}
		return -1
	}
	
	;Returns true if minimize animation is disabled
	GetDisableMinimizeAnim()
	{
		RegRead, Animate, HKCU, Control Panel\Desktop\WindowMetrics , MinAnimate
		return Animate = 0
	}
	;======================================================================================
	;Setter functions: Return 1 when PC needs to be restarted to apply a setting, and 2 when explorer needs to be restarted, 0/"" otherwise
	;======================================================================================
	
	; TODO: Check if permissions are properly set
	; TODO: Additional steps for wmp context menus
	SetShowAllNotifications(ShowAllNotifications)
	{
		RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer, EnableAutoTray, % ShowAllNotifications = 1 ? 0 : 1
		return 2
	}	

	SetRemoveUserDir(RemoveUserDir)
	{
		RegGivePermissions("hkcr\CLSID\{59031a47-3f72-44a7-89c5-5595fe6b30ee}\ShellFolder")
		RegWrite, REG_DWORD, HKCR, CLSID\{59031a47-3f72-44a7-89c5-5595fe6b30ee}\ShellFolder, Attributes, % RemoveUserDir ? 0xf094012d : 0xf084012d
		RegRevokePermissions("hkcr\CLSID\{59031a47-3f72-44a7-89c5-5595fe6b30ee}\ShellFolder")
		return 2
	}

	SetRemoveWMP(RemoveWMP)
	{
		if(A_OSVersion = "WIN_XP")
			run, % "regsvr32 " (RemoveWMP ?"/u " : "") "/s wmpshell.dll",, Hide
		else
		{
			if(RemoveWMP)
			{
				RegDelete, HKCR, SystemFileAssociations\Directory.Audio\shellex\ContextMenuHandlers\WMPShopMusic
				RegWrite, REG_SZ, HKCR, SystemFileAssociations\audio\shell\Enqueue, LegacyDisable
				RegWrite, REG_SZ, HKCR, SystemFileAssociations\audio\shell\Play, LegacyDisable
			}
			else
			{
				RegDelete, HKCR, SystemFileAssociations\audio\shell\Enqueue, LegacyDisable
				RegDelete, HKCR, SystemFileAssociations\audio\shell\Play, LegacyDisable
				RegWrite, REG_SZ, HKCR, SystemFileAssociations\Directory.Audio\shellex\ContextMenuHandlers\WMPShopMusic,, {8A734961-C4AA-4741-AC1E-791ACEBF5B39}
			}
		}
		return 0
	}		

	SetRemoveOpenWith(RemoveOpenWith)
	{
		RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer, NoInternetOpenWIth, % RemoveOpenWith
		return 0
	}

	SetRemoveCrashReporting(RemoveCrashReporting)
	{		
		RegWrite, REG_DWORD, HKLM, Software\Microsoft\Windows\Windows Error Reporting, DontShowUI, % RemoveCrashReporting
		return 0
	}

	SetShowExtensions(ShowExtensions)
	{		
		RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, % ShowExtensions = 1 ? 0 : 1
		return 0
	}

	SetShowHiddenFiles(ShowHiddenFiles)
	{
		RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, % ShowHiddenFiles
		return 0
	}

	SetShowSystemFiles(ShowSystemFiles)
	{		
		RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden, % ShowSystemFiles
		return 0
	}

	SetDisableUAC(DisableUAC)
	{
		if(WinVer >= WIN_Vista)
		{
			RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System, EnableLUA, % DisableUAC = 1 ? 0 : 1
			return 1
		}
		return 0
	}

	SetClassicExplorerView(ClassicExplorerView)
	{
		if(A_OSVersion = "WIN_XP")
			RegWrite, REG_DWORD, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Advanced, WebView, % ClassicExplorerView = 1 ? 0 : 1
		return 0
	}

	SetRemoveLibraries(RemoveLibraries)
	{
		if(WinVer >= WIN_7)
		{
			RegGivePermissions("HKCR\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder")
			RegGivePermissions("HKCR\Folder\ShellEx\ContextMenuHandlers\Library Location")
			RegWrite, REG_DWORD, HKCR, CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder, Attributes, % RemoveLibraries = 1 ? 0xb090010d : 0xb080010d
			if(RemoveLibraries)
				RegDelete, HKCR, Folder\ShellEx\ContextMenuHandlers\Library Location
			else
				RegWrite, REG_SZ, HKCR,  Folder\ShellEx\ContextMenuHandlers\Library Location,, {3dad6c5d-2167-4cae-9914-f99e41c12cfa}
			RegRevokePermissions("HKCR\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder")
			RegRevokePermissions("HKCR\Folder\ShellEx\ContextMenuHandlers\Library Location")
			return 1
		}
		return 0
	}

	SetCycleThroughTaskbarGroup(CycleThroughTaskbarGroup)
	{
		if(WinVer >= WIN_7)
		{
			RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, LastActiveClick, % CycleThroughTaskbarGroup
			return 2
		}
		return 0
	}

	SetThumbnailHoverTime(ThumbnailHoverTime)
	{
		if(WinVer >= WIN_7)
		{
			RegWrite, REG_SZ, HKCU, Control Panel\Mouse, MouseHoverTime, % ThumbnailHoverTime
			return 2
		}
		return 0
	}

	SetDisableMinimizeAnim(Disabled)
	{
		VarSetCapacity(struct, 8, 0)	
		NumPut(8, struct, 0, "UInt")
		NumPut(!Disabled, struct, 4, "Int")
		DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION 0x0049 SPIF_SENDWININICHANGE 0x0002
	}
}