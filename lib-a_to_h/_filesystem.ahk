MountVirtualDisk(path = "")
{	
	splitpath, path, , , ext	
	
	version := dllcall("GetVersion", uint) & 0xffff
	version := version & 0xff "." (version>>8) & 0xff 
	version += 0	
				
	if ( (version > 6.1) or ( (version = 6.1) and (ext = "vhd") ) )
		return MountVirtualDiskNative(path)	
	else
		return MountVirtualDiskD(path)
}	

MountVirtualDiskD(path = "")
{
	setformat, integer, D
	if not path
		{
			try 
				{
					runwait, DTLite.exe -unmount dt`,0
					return errorlevel
				}	
			catch 
				return -1
		}	
	letters = ABCDEFGHJKLMNOPQRSTUVXZ
	stringsplit, driveletter, letters, ,
	
	try 
		{
			runwait, DTLite.exe -mount dt`,0`,"%path%"
			if errorlevel = -1
				return errorlevel
		}
	catch
		return -2
		
	runwait, DTLite.exe -get_letter dt`, 0		
	driveindex := errorlevel + 1
	drive_ := driveletter%driveindex%
	return drive_
}	

MountVirtualDiskNative(path = "")
{
	static h_virtualDisk := False
	
	if not path
		{
			return dllcall("VirtDisk.dll\DetachVirtualDisk", uint, h_virtualDisk, uint, 0, uint, 0)	
			h_virtualDisk := false
		}	
		
	if h_virtualDisk 
		dllcall("VirtDisk.dll\DetachVirtualDisk", uint, h_virtualDisk, uint, 0, uint, 0)	
	
	DriveGet, Before, list		

	VarSetCapacity(VIRTUAL_STORAGE_TYPE, 20)
	numput((VIRTUAL_STORAGE_TYPE_DEVICE_UNKNOWN := 0), VIRTUAL_STORAGE_TYPE, "uint") 
	/* should work with VIRTUAL_STORAGE_TYPE_DEVICE_VHD = 2, but doesn't
	 */	
		
	VarSetCapacity(h_disk, 4)	
		
	err := dllcall("VirtDisk.dll\OpenVirtualDisk", ptr, &VIRTUAL_STORAGE_TYPE, str, Path
	  , uint, (VIRTUAL_DISK_ACCESS_ATTACH_RO  := 0x00010000) | (VIRTUAL_DISK_ACCESS_GET_INFO := 0x00080000) | (VIRTUAL_DISK_ACCESS_DETACH := 0x00040000) 
	  , uint, 0, uint, 0, ptr, &h_disk, uint)
  
	if err
		return 1

	VarSetCapacity(ATTACH_VIRTUAL_DISK_PARAMETERS, 8, 0)
	numput(1, ATTACH_VIRTUAL_DISK_PARAMETERS, "int")
	
	err := dllcall("VirtDisk.dll\AttachVirtualDisk", uint, numget(h_disk, "uint"), uint, 0
	  , uint, (ATTACH_VIRTUAL_DISK_FLAG_READ_ONLY := 0x00000001), uint, 0
	  , ptr, &ATTACH_VIRTUAL_DISK_PARAMETERS, uint, 0)
	  
	if err
		return 2  
	else
		h_virtualDisk :=  numget(h_disk, "uint")
	
	StartTime := A_TickCount
	DriveGet, after, list
	while ! (strlen(before) < strlen(after))
		{
			DriveGet, after, list
			if (A_TickCount - StartTime) > 1000
				{
					msgbox, 52, ,Could not retrieve path of newlly mounted image. Continue waiting?
					ifmsgbox, No
						return 3
					else
						StartTime := A_TickCount
				}	
		}	

	loop, parse, after
		if !instr(before, A_loopfield)
			return A_loopfield
}

PathRemoveFileSpec(file) {
	dllcall("Shlwapi.dll\PathRemoveFileSpecW", str, file, str)	
	return file 
}	

rmDirTree(root)
{
	loop, %root%\*, 2, 0		
		rmDirTree(A_LoopFileFullPath)		
	fileremovedir, %root%, 0
}	

deleteLater(file = "")
{
	if not file
		{
			file := A_ScriptFullPath
			if instr(A_ScriptFullPath, A_temp) != 1
				return -1
		}
		
	err := dllcall("MoveFileExW", str, file, uint, 0
				  , uint, (MOVEFILE_DELAY_UNTIL_REBOOT := 0x4), uint)
				  
	if not err
		return A_lasterror
	else return 0
}		
	 
ShellUnzip(arch, dest)
{    
    names := []
    shell := ComObjCreate("Shell.Application")  
    items := shell.Namespace( arch ).Items()
    loop, % items.Count {
        item := items.Item(A_index - 1)
        name := item.name
        names.insert(name)
    }    
    shell.Namespace( dest ).CopyHere( shell.Namespace( arch ).items, 16)           
}

GetParentDir() {
	try 
	{
		fs := ComObjCreate("Scripting.FileSystemObject")
		return fs.GetParentFolderName( fs.GetParentFolderName(A_scriptfullpath) )
	}
	catch
	{
		Path = %A_ScriptDir%
	    Parent := SubStr(Path, 1, InStr(SubStr(Path,1,-1), "\", 0, 0)-1)
		return parent
	}
}	

CreateSimbolicLink(lnk, target, dir=1)
{
	if dir { 
		fileremovedir, %lnk%
		filecreatedir, %target%	
	}
	return "Succes= " dllcall("CreateSymbolicLinkW", str, lnk, str, target, uint, dir) " code= " A_lasterror
}

CreateShortCutsFolder(folder, icon, index=0)
{
	if fileexist(folder)
	{
		msgbox,16, ,%folder% already exists
		return
	}
	
	filecreatedir, %folder%
	FileSetAttrib +S, %folder%, 2
	ini=%folder%\desktop.ini
	IniWrite %icon%, %ini%, .ShellClassInfo, IconFile
	IniWrite 0          , %ini%, .ShellClassInfo, IconIndex
	IniWrite 0          , %ini%, .ShellClassInfo, ConfirmFileOp
	FileSetAttrib +SH, %folder%\desktop.ini, 2
	return folder
}