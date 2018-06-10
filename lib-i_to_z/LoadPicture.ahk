LoadPicture(aFilespec, aWidth:=0, aHeight:=0, ByRef aImageType:="", aIconNumber:=0, aUseGDIPlusIfAvailable:=1){
; Returns NULL on failure.
; If aIconNumber > 0, an HICON or HCURSOR is returned (both should be interchangeable), never an HBITMAP.
; However, aIconNumber==1 is treated as a special icon upon which LoadImage is given preference over ExtractIcon
; for .ico/.cur/.ani files.
; Otherwise, .ico/.cur/.ani files are normally loaded as HICON (unless aUseGDIPlusIfAvailable is true or
; something else unusual happened such as file contents not matching file's extension).  This is done to preserve
; any properties that HICONs have but HBITMAPs lack, namely the ability to be animated and perhaps other things.
;
; Loads a JPG/GIF/BMP/ICO/etc. and returns an HBITMAP or HICON to the caller (which it may call
; DeleteObject()/DestroyIcon() upon, though upon program termination all such handles are freed
; automatically).  The image is scaled to the specified width and height.  If zero is specified
; for either, the image's actual size will be used for that dimension.  If -1 is specified for one,
; that dimension will be kept proportional to the other dimension's size so that the original aspect
; ratio is retained.
	static IMAGE_ICON,IMAGE_BITMAP,IMAGE_CURSOR,LR_LOADFROMFILE,LR_CREATEDIBSECTION,GdiplusStartupInput,gdi_input,CLR_DEFAULT,GENERIC_READ,OPEN_EXISTING,GMEM_MOVEABLE,LR_COPYRETURNORG,bitmap,ii,LR_COPYDELETEORG,INVALID_HANDLE_VALUE,IID_IPicture
	if !IMAGE_ICON
    IMAGE_ICON:=1,IMAGE_BITMAP:=0,IMAGE_CURSOR:=2,LR_LOADFROMFILE:=16, LR_CREATEDIBSECTION:=8192
    ,GdiplusStartupInput :="UINT32 GdiplusVersion;PTR DebugEventCallback;BOOL SuppressBackgroundThread;BOOL SuppressExternalCodecs"
    ,gdi_input:=Struct(GdiplusStartupInput),CLR_DEFAULT:=4278190080,GENERIC_READ:=2147483648
    ,OPEN_EXISTING:=3,GMEM_MOVEABLE:=2,LR_COPYRETURNORG:=4
    ,bitmap:=Struct("LONG bmType;LONG bmWidth;LONG bmHeight;LONG bmWidthBytes;WORD bmPlanes;WORD bmBitsPixel;LPVOID bmBits") ;BITMAP
    ,ii:=Struct("BOOL fIcon;DWORD xHotspot;DWORD yHotspot;HBITMAP hbmMask;HBITMAP hbmColor") ; ICONINFO
    ,LR_COPYDELETEORG:=8,INVALID_HANDLE_VALUE:=-1,VarSetCapacity(IID_IPicture,16,0) CLSIDFromString("{7BF80980-BF32-101A-8BBB-00AA00300CAB}", &IID_IPicture)
	hbitmap := 0
	,aImageType := -1 ; The type of image currently inside hbitmap.  Set default value for output parameter as "unknown".

	if (aFilespec="") ; Allow blank filename to yield NULL bitmap (and currently, some callers do call it this way).
		return 0
		
	; Lexikos: Negative values now indicate an icon's integer resource ID.
	;if (aIconNumber < 0) ; Allowed to be called this way by GUI and others (to avoid need for validation of user input there).
	;	aIconNumber = 0 ; Use the default behavior, which is "load icon or bitmap, whichever is most appropriate".

	file_ext := SubStr(aFilespec, InStr(aFilespec,".",1,-1) + 1)

	; v1.0.43.07: If aIconNumber is zero, caller didn't specify whether it wanted an icon or bitmap.  Thus,
	; there must be some kind of detection for whether ExtractIcon is needed instead of GDIPlus/OleLoadPicture.
	; Although this could be done by attempting ExtractIcon only after GDIPlus/OleLoadPicture fails (or by
	; somehow checking the internal nature of the file), for performance and code size, it seems best to not
	; to incur this extra I/O and instead make only one attempt based on the file's extension.
	; Must use ExtractIcon() if either of the following is true:
	; 1) Caller gave an icon index of the second or higher icon in the file.  Update for v1.0.43.05: There
	;    doesn't seem to be any reason to allow a caller to explicitly specify ExtractIcon as the method of
	;    loading the *first* icon from a .ico file since LoadImage is likely always superior.  This is
	;    because unlike ExtractIcon/Ex, LoadImage: 1) Doesn't distort icons, especially 16x16 icons 2) is
	;    capable of loading icons other than the first by means of width and height parameters.
	; 2) The target file is of type EXE/DLL/ICL/CPL/etc. (LoadImage() is documented not to work on those file types).
	;    ICL files (v1.0.43.05): Apparently ICL files are an unofficial file format. Someone on the newsgroups
	;    said that an ICL is an "ICon Library... a renamed 16-bit Windows .DLL (an NE format executable) which
	;    typically contains nothing but a resource section. The ICL extension seems to be used by convention."
	; L17: Support negative numbers to mean resource IDs. These are supported by the resource extraction method directly, and by ExtractIcon if aIconNumber < -1.
	; Icon library: Unofficial dll container, see notes above. (*.icl)
	; Control panel extension/applet (ExtractIcon is said to work on these). (*.cpl)
	; Screen saver (ExtractIcon should work since these are really EXEs). (*.src)
	If (ExtractIcon_was_used := aIconNumber > 1 || aIconNumber < 0 || file_ext = "exe" || file_ext="dll" || file_ext="icl" || file_ext="cpl" || file_ext="scr"){
		; v1.0.44: Below are now omitted to reduce code size and improve performance. They are still supported
		; indirectly because ExtractIcon is attempted whenever LoadImage() fails further below.
		;|| !_tcsicmp(file_ext, _T("drv")) ; Driver (ExtractIcon is said to work on these).
		;|| !_tcsicmp(file_ext, _T("ocx")) ; OLE/ActiveX Control Extension
		;|| !_tcsicmp(file_ext, _T("vbx")) ; Visual Basic Extension
		;|| !_tcsicmp(file_ext, _T("acm")) ; Audio Compression Manager Driver
		;|| !_tcsicmp(file_ext, _T("bpl")) ; Delphi Library (like a DLL?)
		; Not supported due to rarity, code size, performance, and uncertainty of whether ExtractIcon works on them.
		; Update for v1.0.44: The following are now supported indirectly because ExtractIcon is attempted whenever
		; LoadImage() fails further below.
		;|| !_tcsicmp(file_ext, _T("nil")) ; Norton Icon Library 
		;|| !_tcsicmp(file_ext, _T("wlx")) ; Total/Windows Commander Lister Plug-in
		;|| !_tcsicmp(file_ext, _T("wfx")) ; Total/Windows Commander File System Plug-in
		;|| !_tcsicmp(file_ext, _T("wcx")) ; Total/Windows Commander Plug-in
		;|| !_tcsicmp(file_ext, _T("wdx")) ; Total/Windows Commander Plug-in
		
		aImageType := IMAGE_ICON

		; L17: Manually extract the most appropriately sized icon resource for the best results.
		,hbitmap := ExtractIconFromExecutable(aFilespec, aIconNumber, aWidth, aHeight)

		if (hbitmap < 2) ; i.e. it's NULL or 1. Return value of 1 means "incorrect file type".
			return 0 ; v1.0.44: Fixed to return NULL vs. hbitmap, since 1 is an invalid handle (perhaps rare since no known bugs caused by it).
		;else continue on below so that the icon can be resized to the caller's specified dimensions.
	}	else if (aIconNumber > 0) ; Caller wanted HICON, never HBITMAP, so set type now to enforce that.
		aImageType := IMAGE_ICON ; Should be suitable for cursors too, since they're interchangeable for the most part.
	else if (file_ext) ; Make an initial guess of the type of image if the above didn't already determine the type.
	{
		if (file_ext = "ico")
			aImageType := IMAGE_ICON
		else if (file_ext="cur" || file_ext="ani")
			aImageType := IMAGE_CURSOR
		else if (file_ext="bmp")
			aImageType := IMAGE_BITMAP
		;else for other extensions, leave set to "unknown" so that the below knows to use IPic or GDI+ to load it.
	}
	;else same comment as above.

	if ((aWidth = -1 || aHeight = -1) && (!aWidth || !aHeight))
		aWidth := aHeight := 0 ; i.e. One dimension is zero and the other is -1, which resolves to the same as "keep original size".
	keep_aspect_ratio := aWidth = -1 || aHeight = -1
	
	; Caller should ensure that aUseGDIPlusIfAvailable==false when aIconNumber > 0, since it makes no sense otherwise.
	if (aUseGDIPlusIfAvailable && !(hinstGDI := LoadLibrary("gdiplus"))) ; Relies on short-circuit boolean order for performance.
		aUseGDIPlusIfAvailable := false ; Override any original "true" value as a signal for the section below.
	if (!hbitmap && aImageType > -1 && !aUseGDIPlusIfAvailable)
	{
		; Since image hasn't yet be loaded and since the file type appears to be one supported by
		; LoadImage() [icon/cursor/bitmap], attempt that first.  If it fails, fall back to the other
		; methods below in case the file's internal contents differ from what the file extension indicates.
		if (keep_aspect_ratio) ; Load image at its actual size.  It will be rescaled to retain aspect ratio later below.
		{
			desired_width := 0
			,desired_height := 0
		}
		else
		{
			desired_width := aWidth
			,desired_height := aHeight
		}
		; For LoadImage() below:
		; LR_CREATEDIBSECTION applies only when aImageType == IMAGE_BITMAP, but seems appropriate in that case.
		; Also, if width and height are non-zero, that will determine which icon of a multi-icon .ico file gets
		; loaded (though I don't know the exact rules of precedence).
		; KNOWN LIMITATIONS/BUGS:
		; LoadImage() fails when requesting a size of 1x1 for an image whose orig/actual size is small (e.g. 1x2).
		; Unlike CopyImage(), perhaps it detects that division by zero would occur and refuses to do the
		; calculation rather than providing more code to do a correct calculation that doesn't divide by zero.
		; For example:
		; LoadImage() Success:
		;   Gui, Add, Pic, h2 w2, bitmap 1x2.bmp
		;   Gui, Add, Pic, h1 w1, bitmap 4x6.bmp
		; LoadImage() Failure:
		;   Gui, Add, Pic, h1 w1, bitmap 1x2.bmp
		; LoadImage() also fails on:
		;   Gui, Add, Pic, h1, bitmap 1x2.bmp
		; And then it falls back to GDIplus, which in the particular case above appears to traumatize the
		; parent window (or its picture control), because the GUI window hangs (but not the script) after
		; doing a FileSelectFolder.  For example:
		;   Gui, Add, Button,, FileSelectFile
		;   Gui, Add, Pic, h1, bitmap 1x2.bmp   Causes GUI window to hang after FileSelectFolder (due to LoadImage failing then falling back to GDIplus i.e. GDIplus is somehow triggering the problem).
		;   Gui, Show
		;   return
		;   ButtonFileSelectFile:
		;   FileSelectFile, outputvar
		;   return
		if (hbitmap := LoadImage(0, aFilespec, aImageType, desired_width, desired_height, LR_LOADFROMFILE | LR_CREATEDIBSECTION))
		{
			; The above might have loaded an HICON vs. an HBITMAP (it has been confirmed that LoadImage()
			; will return an HICON vs. HBITMAP is aImageType is IMAGE_ICON/CURSOR).  Note that HICON and
			; HCURSOR are identical for most/all Windows API uses.  Also note that LoadImage() will load
			; an icon as a bitmap if the file contains an icon but IMAGE_BITMAP was passed in (at least
			; on Windows XP).
			if (!keep_aspect_ratio) ; No further resizing is needed.
				return hbitmap
			; Otherwise, continue on so that the image can be resized via a second call to LoadImage().
		}
		; v1.0.40.10: Abort if file doesn't exist so that GDIPlus isn't even attempted. This is done because
		; loading GDIPlus apparently disrupts the color palette of certain games, at least old ones that use
		; DirectDraw in 256-color depth.
		else if (GetFileAttributes(aFilespec) = 0xFFFFFFFF) ; For simplicity, we don't check if it's a directory vs. file, since that should be too rare.
			return 0
		; v1.0.43.07: Also abort if caller wanted an HICON (not an HBITMAP), since the other methods below
		; can't yield an HICON.
		else if (aIconNumber > 0)
		{
			; UPDATE for v1.0.44: Attempt ExtractIcon in case its some extension that's
			; was recognized as an icon container (such as AutoHotkeySC.bin) and thus wasn't handled higher above.
			;hbitmap = (HBITMAP)ExtractIcon(g_hInstance, aFilespec, aIconNumber - 1)

			; L17: Manually extract the most appropriately sized icon resource for the best results.
			hbitmap := ExtractIconFromExecutable(aFilespec, aIconNumber, aWidth, aHeight)

			if (hbitmap < 2) ; i.e. it's NULL or 1. Return value of 1 means "incorrect file type".
				return 0
			ExtractIcon_was_used := true
		}
		;else file exists, so continue on so that the other methods are attempted in case file's contents
		; differ from what the file extension indicates, or in case the other methods can be successful
		; even when the above failed.
	}

	; pic := 0 is also used to detect whether IPic method was used to load the image.
	
	if (!hbitmap) ; Above hasn't loaded the image yet, so use the fall-back methods.
	{
		; At this point, regardless of the image type being loaded (even an icon), it will
		; definitely be converted to a Bitmap below.  So set the type:
		aImageType := IMAGE_BITMAP
		; Find out if this file type is supported by the non-GDI+ method.  This check is not foolproof
		; since all it does is look at the file's extension, not its contents.  However, it doesn't
		; need to be 100% accurate because its only purpose is to detect whether the higher-overhead
		; calls to GdiPlus can be avoided.
		
		if (aUseGDIPlusIfAvailable || !file_ext || file_ext!="jpg"
			&& file_ext!="jpeg" && file_ext!="gif") ; Non-standard file type (BMP is already handled above).
			if (!hinstGDI) ; We don't yet have a handle from an earlier call to LoadLibary().
				hinstGDI := LoadLibrary("gdiplus")
		; If it is suspected that the file type isn't supported, try to use GdiPlus if available.
		; If it's not available, fall back to the old method in case the filename doesn't properly
		; reflect its true contents (i.e. in case it really is a JPG/GIF/BMP internally).
		; If the below LoadLibrary() succeeds, either the OS is XP+ or the GdiPlus extensions have been
		; installed on an older OS.
		if (hinstGDI)
		{
			; LPVOID and "int" are used to avoid compiler errors caused by... namespace issues?
			
			gdi_input.Fill()
			if !GdiplusStartup(getvar(token:=0), gdi_input[], 0)
			{
				if !GdipCreateBitmapFromFile(aFilespec, getvar(pgdi_bitmap:=0))
				{
					if GdipCreateHBITMAPFromBitmap(pgdi_bitmap, hbitmap, CLR_DEFAULT)
						hbitmap := 0 ; Set to NULL to be sure.
					GdipDisposeImage(pgdi_bitmap) ; This was tested once to make sure it really returns Gdiplus::Ok.
				}
				; The current thought is that shutting it down every time conserves resources.  If so, it
				; seems justified since it is probably called infrequently by most scripts:
				GdiplusShutdown(token)
			}
			FreeLibrary(hinstGDI)
		}
		else ; Using old picture loading method.
		{
			; Based on code sample at http:;www.codeguru.com/Cpp/G-M/bitmap/article.php/c4935/
			hfile := CreateFile(aFilespec, GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0)
			if (hfile = INVALID_HANDLE_VALUE)
				return 0
			size := GetFileSize(hfile, 0)
			if !(hglobal := GlobalAlloc(GMEM_MOVEABLE, size)){
				CloseHandle(hfile)
				return 0
			}
			if !(hlocked := GlobalLock(hglobal)){
				CloseHandle(hfile)
				,GlobalFree(hglobal)
				return 0
			}
			; Read the file into memory:
			ReadFile(hfile, hlocked, size, getvar(size), 0)
			,GlobalUnlock(hglobal)
			,CloseHandle(hfile)
			if (0 > CreateStreamOnHGlobal(hglobal, FALSE, getvar(stream:=0)) || !stream )  ; Relies on short-circuit boolean order.
			{
				GlobalFree(hglobal)
				return 0
			}

			; Specify TRUE to have it do the GlobalFree() for us.  But since the call might fail, it seems best
			; to free the mem ourselves to avoid uncertainty over what it does on failure:
			if (0 > OleLoadPicture(stream, size, FALSE, &IID_IPicture,getvar(pic:=0)))
				pic:=0
			
			DllCall(NumGet(NumGet(stream+0)+8),"PTR",stream) ;->Release()
			,GlobalFree(hglobal)
			if !pic
				return 0
			DllCall(NumGet(NumGet(pic+0)+12),"PTR",pic,"PTR*",hbitmap)
			; Above: MSDN: "The caller is responsible for this handle upon successful return. The variable is set
			; to NULL on failure."
			if (!hbitmap)
			{
				DllCall(NumGet(NumGet(pic+0)+8),"PTR",pic)
				return 0
			}
			; Don't pic->Release() yet because that will also destroy/invalidate hbitmap handle.
		} ; IPicture method was used.
	} ; IPicture or GDIPlus was used to load the image, not a simple LoadImage() or ExtractIcon().

	; Above has ensured that hbitmap is now not NULL.
	; Adjust things if "keep aspect ratio" is in effect:
	if (keep_aspect_ratio)
	{
		ii.Fill()
		if (aImageType = IMAGE_BITMAP)
			hbitmap_to_analyze := hbitmap
		else ; icon or cursor
		{
			if (GetIconInfo(hbitmap, ii[])) ; Works on cursors too.
				hbitmap_to_analyze := ii.hbmMask ; Use Mask because MSDN implies hbmColor can be NULL for monochrome cursors and such.
			else
			{
				DestroyIcon(hbitmap)
				return 0 ; No need to call pic->Release() because since it's an icon, we know IPicture wasn't used (it only loads bitmaps).
			}
		}
		; Above has ensured that hbitmap_to_analyze is now not NULL.  Find bitmap's dimensions.
		bitmap.Fill()
		,GetObject(hbitmap_to_analyze, sizeof(_BITMAP), bitmap[]) ; Realistically shouldn't fail at this stage.
		if (aHeight = -1)
		{
			; Caller wants aHeight calculated based on the specified aWidth (keep aspect ratio).
			if (bitmap.bmWidth) ; Avoid any chance of divide-by-zero.
				aHeight := (bitmap.bmHeight / bitmap.bmWidth) * aWidth + 0.5 ; Round.
		}
		else
		{
			; Caller wants aWidth calculated based on the specified aHeight (keep aspect ratio).
			if (bitmap.bmHeight) ; Avoid any chance of divide-by-zero.
				aWidth := (bitmap.bmWidth / bitmap.bmHeight) * aHeight + 0.5 ; Round.
		}
		if (aImageType != IMAGE_BITMAP)
		{
			; It's our responsibility to delete these two when they're no longer needed:
			DeleteObject(ii.hbmColor)
			,DeleteObject(ii.hbmMask)
			; If LoadImage() vs. ExtractIcon() was used originally, call LoadImage() again because
			; I haven't found any other way to retain an animated cursor's animation (and perhaps
			; other icon/cursor attributes) when resizing the icon/cursor (CopyImage() doesn't
			; retain animation):
			if (!ExtractIcon_was_used)
			{
				DestroyIcon(hbitmap) ; Destroy the original HICON.
				; Load a new one, but at the size newly calculated above.
				; Due to an apparent bug in Windows 9x (at least Win98se), the below call will probably
				; crash the program with a "divide error" if the specified aWidth and/or aHeight are
				; greater than 90.  Since I don't know whether this affects all versions of Windows 9x, and
				; all animated cursors, it seems best just to document it here and in the help file rather
				; than limiting the dimensions of .ani (and maybe .cur) files for certain operating systems.
				return LoadImage(0, aFilespec, aImageType, aWidth, aHeight, LR_LOADFROMFILE)
			}
		}
	}


	if (pic) ; IPicture method was used.
	{
		; The below statement is confirmed by having tested that DeleteObject(hbitmap) fails
		; if called after pic->Release():
		; "Copy the image. Necessary, because upon pic's release the handle is destroyed."
		; MSDN: CopyImage(): "[If either width or height] is zero, then the returned image will have the
		; same width/height as the original."
		; Note also that CopyImage() seems to provide better scaling quality than using MoveWindow()
		; (followed by redrawing the parent window) on the static control that contains it:
		hbitmap_new := CopyImage(hbitmap, IMAGE_BITMAP, aWidth, aHeight ; We know it's IMAGE_BITMAP in this case.
														, (aWidth || aHeight) ? 0 : LR_COPYRETURNORG) ; Produce original size if no scaling is needed.
		,DllCall(NumGet(NumGet(pic+0)+8),"PTR",pic)
		; No need to call DeleteObject(hbitmap), see above.
	}
	else ; GDIPlus or a simple method such as LoadImage or ExtractIcon was used.
	{
		if (!aWidth && !aHeight) ; No resizing needed.
			return hbitmap
		; The following will also handle HICON/HCURSOR correctly if aImageType == IMAGE_ICON/CURSOR.
		; Also, LR_COPYRETURNORG|LR_COPYDELETEORG is used because it might allow the animation of
		; a cursor to be retained if the specified size happens to match the actual size of the
		; cursor.  This is because normally, it seems that CopyImage() omits cursor animation
		; from the new object.  MSDN: "LR_COPYRETURNORG returns the original hImage if it satisfies
		; the criteria for the copy—that is, correct dimensions and color depth—in which case the
		; LR_COPYDELETEORG flag is ignored. If this flag is not specified, a new object is always created."
		; KNOWN BUG: Calling CopyImage() when the source image is tiny and the destination width/height
		; is also small (e.g. 1) causes a divide-by-zero exception.
		; For example:
		;   Gui, Add, Pic, h1 w-1, bitmap 1x2.bmp   Crash (divide by zero)
		;   Gui, Add, Pic, h1 w-1, bitmap 2x3.bmp   Crash (divide by zero)
		; However, such sizes seem too rare to document or put in an exception handler for.
		hbitmap_new := CopyImage(hbitmap, aImageType, aWidth, aHeight, LR_COPYRETURNORG | LR_COPYDELETEORG)
		; Above's LR_COPYDELETEORG deletes the original to avoid cascading resource usage.  MSDN's
		; LoadImage() docs say:
		; "When you are finished using a bitmap, cursor, or icon you loaded without specifying the
		; LR_SHARED flag, you can release its associated memory by calling one of [the three functions]."
		; Therefore, it seems best to call the right function even though DeleteObject might work on
		; all of them on some or all current OSes.  UPDATE: Evidence indicates that DestroyIcon()
		; will also destroy cursors, probably because icons and cursors are literally identical in
		; every functional way.  One piece of evidence:
		;> No stack trace, but I know the exact source file and line where the call
		;> was made. But still, it is annoying when you see 'DestroyCursor' even though
		;> there is 'DestroyIcon'.
		; "Can't be helped. Icons and cursors are the same thing" (Tim Robinson (MVP, Windows SDK)).
		;
		; Finally, the reason this is important is that it eliminates one handle type
		; that we would otherwise have to track.  For example, if a gui window is destroyed and
		; and recreated multiple times, its bitmap and icon handles should all be destroyed each time.
		; Otherwise, resource usage would cascade upward until the script finally terminated, at
		; which time all such handles are freed automatically.
	}
	return hbitmap_new
}