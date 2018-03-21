ExtractIconFromExecutable(aFilespec, aIconNumber, aWidth, aHeight){
	static LOAD_LIBRARY_AS_DATAFILE,RT_ICON,RT_GROUP_ICON
	if !RT_ICON
    LOAD_LIBRARY_AS_DATAFILE:=2,RT_ICON:=11,RT_GROUP_ICON := RT_ICON + 11
	hicon := 0
	; If the module is already loaded as an executable, LoadLibraryEx returns its handle.
	; Otherwise each call will receive its own handle to a data file mapping.
	if ( hdatafile := LoadLibraryEx(aFilespec, 0, LOAD_LIBRARY_AS_DATAFILE) ){
		group_icon_id := (aIconNumber < 0 ? -aIconNumber : ResourceIndexToId(hdatafile, RT_GROUP_ICON, aIconNumber ? aIconNumber : 1))

		;~ HRSRC hres
		;~ HGLOBAL hresdata
		;~ LPVOID presdata

		; MSDN indicates resources are unloaded when the *process* exits, but also states
		; that the pointer returned by LockResource is valid until the *module* containing
		; the resource is unloaded. Testing seems to indicate that unloading a module indeed
		; unloads or invalidates any resources it contains.
		if ((hres := FindResource(hdatafile, group_icon_id, RT_GROUP_ICON))
			&& (hresdata := LoadResource(hdatafile, hres))
			&& (presdata := LockResource(hresdata)))
		{
			; LookupIconIdFromDirectoryEx seems to use whichever is larger of aWidth or aHeight,
			; so one or the other may safely be -1. However, since this behaviour is undocumented,
			; treat -1 as "same as other dimension":
			icon_id := LookupIconIdFromDirectoryEx(presdata, TRUE, aWidth == -1 ? aHeight : aWidth, aHeight == -1 ? aWidth : aHeight, 0)
			if (icon_id
				&& (hres := FindResource(hdatafile, icon_id, RT_ICON))
				&& (hresdata := LoadResource(hdatafile, hres))
				&& (presdata := LockResource(hresdata)))
			{
				hicon := CreateIconFromResourceEx(presdata, SizeofResource(hdatafile, hres), TRUE, 0x30000, 0, 0, 0)
			}
		}

		; Decrements the executable module's reference count or frees the data file mapping.
		FreeLibrary(hdatafile)
	}

	; L20: Fall back to ExtractIcon if the above method failed. This may work on some versions of Windows where
	; ExtractIcon supports 16-bit "executables" (such as ICL files) that cannot be loaded by LoadLibraryEx.
	; However, resource ID -1 is not supported, and if multiple icon sizes exist in the file, the first is used
	; rather than the most appropriate.
	if (!hicon)
		hicon := ExtractIcon(0, aFilespec, aIconNumber > 0 ? aIconNumber - 1 : aIconNumber < -1 ? aIconNumber : 0)

	return hicon
}
