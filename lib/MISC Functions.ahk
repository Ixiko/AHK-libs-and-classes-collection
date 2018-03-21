;-------------------------------------------------------------------------
;    My collection rare and maybe very useful functions
;-------------------------------------------------------------------------

;{Command - line interaction
CMDret_RunReturn(CMDin, WorkingDir=0) {

/*
; ******************************************************************
; CMDret-AHK functions
; version 1.10 beta
;
; Updated: Dec 5, 2006
; by: corrupt
; Code modifications and/or contributions made by:
; Laszlo, shimanov, toralf, Wdb
; ******************************************************************
; Usage:
; CMDin - command to execute
; WorkingDir - full path to working directory (Optional)
; ******************************************************************
; Known Issues:
; - If using dir be sure to specify a path (example: cmd /c dir c:\)
; or specify a working directory
; - Running 16 bit console applications may not produce output. Use
; a 32 bit application to start the 16 bit process to receive output
; ******************************************************************
; Additional requirements:
; - none
; ******************************************************************
; Code Start
; ******************************************************************

*/

  Global cmdretPID
  tcWrk := WorkingDir=0 ? "Int" : "Str"
  idltm := A_TickCount + 20
  CMsize = 1
  VarSetCapacity(CMDout, 1, 32)
  VarSetCapacity(sui,68, 0)
  VarSetCapacity(pi, 16, 0)
  VarSetCapacity(pa, 12, 0)
  Loop, 4 {
    DllCall("RtlFillMemory", UInt,&pa+A_Index-1, UInt,1, UChar,12 >> 8*A_Index-8)
    DllCall("RtlFillMemory", UInt,&pa+8+A_Index-1, UInt,1, UChar,1 >> 8*A_Index-8)
  }
  IF (DllCall("CreatePipe", "UInt*",hRead, "UInt*",hWrite, "UInt",&pa, "Int",0) <> 0) {
    Loop, 4
      DllCall("RtlFillMemory", UInt,&sui+A_Index-1, UInt,1, UChar,68 >> 8*A_Index-8)
    DllCall("GetStartupInfo", "UInt", &sui)
    Loop, 4 {
      DllCall("RtlFillMemory", UInt,&sui+44+A_Index-1, UInt,1, UChar,257 >> 8*A_Index-8)
      DllCall("RtlFillMemory", UInt,&sui+60+A_Index-1, UInt,1, UChar,hWrite >> 8*A_Index-8)
      DllCall("RtlFillMemory", UInt,&sui+64+A_Index-1, UInt,1, UChar,hWrite >> 8*A_Index-8)
      DllCall("RtlFillMemory", UInt,&sui+48+A_Index-1, UInt,1, UChar,0 >> 8*A_Index-8)
    }
    IF (DllCall("CreateProcess", Int,0, Str,CMDin, Int,0, Int,0, Int,1, "UInt",0, Int,0, tcWrk, WorkingDir, UInt,&sui, UInt,&pi) <> 0) {
      Loop, 4
        cmdretPID += *(&pi+8+A_Index-1) << 8*A_Index-8
      Loop {
        idltm2 := A_TickCount - idltm
        If (idltm2 < 10) {
          DllCall("Sleep", Int, 10)
          Continue
        }
        IF (DllCall("PeekNamedPipe", "uint", hRead, "uint", 0, "uint", 0, "uint", 0, "uint*", bSize, "uint", 0 ) <> 0 ) {
          Process, Exist, %cmdretPID%
          IF (ErrorLevel OR bSize > 0) {
            IF (bSize > 0) {
              VarSetCapacity(lpBuffer, bSize+1)
              IF (DllCall("ReadFile", "UInt",hRead, "Str", lpBuffer, "Int",bSize, "UInt*",bRead, "Int",0) > 0) {
                IF (bRead > 0) {
                  TRead += bRead
                  VarSetCapacity(CMcpy, (bRead+CMsize+1), 0)
                  CMcpy = a
                  DllCall("RtlMoveMemory", "UInt", &CMcpy, "UInt", &CMDout, "Int", CMsize)
                  DllCall("RtlMoveMemory", "UInt", &CMcpy+CMsize, "UInt", &lpBuffer, "Int", bRead)
                  CMsize += bRead
                  VarSetCapacity(CMDout, (CMsize + 1), 0)
                  CMDout=a
                  DllCall("RtlMoveMemory", "UInt", &CMDout, "UInt", &CMcpy, "Int", CMsize)
                  VarSetCapacity(CMDout, -1)   ; fix required by change in autohotkey v1.0.44.14
                }
              }
            }
          }
          ELSE
            break
        }
        ELSE
          break
        idltm := A_TickCount
      }
      cmdretPID=
      DllCall("CloseHandle", UInt, hWrite)
      DllCall("CloseHandle", UInt, hRead)
    }
  }
  IF (StrLen(CMDout) < TRead) {
    VarSetCapacity(CMcpy, TRead, 32)
    TRead2 = %TRead%
    Loop {
      DllCall("RtlZeroMemory", "UInt", &CMcpy, Int, TRead)
      NULLptr := StrLen(CMDout)
      cpsize := Tread - NULLptr
      DllCall("RtlMoveMemory", "UInt", &CMcpy, "UInt", (&CMDout + NULLptr + 2), "Int", (cpsize - 1))
      DllCall("RtlZeroMemory", "UInt", (&CMDout + NULLptr), Int, cpsize)
      DllCall("RtlMoveMemory", "UInt", (&CMDout + NULLptr), "UInt", &CMcpy, "Int", cpsize)
      TRead2 --
      IF (StrLen(CMDout) > TRead2)
        break
    }
  }
  StringTrimLeft, CMDout, CMDout, 1
  Return, CMDout
}


;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Date or Time funchtions

PrettyTickCount(timeInMilliSeconds) { ;takes a time in milliseconds and displays it in a readable fashion
   ElapsedHours := SubStr(0 Floor(timeInMilliSeconds / 3600000), -1)
   ElapsedMinutes := SubStr(0 Floor((timeInMilliSeconds - ElapsedHours * 3600000) / 60000), -1)
   ElapsedSeconds := SubStr(0 Floor((timeInMilliSeconds - ElapsedHours * 3600000 - ElapsedMinutes * 60000) / 1000), -1)
   ElapsedMilliseconds := SubStr(0 timeInMilliSeconds - ElapsedHours * 3600000 - ElapsedMinutes * 60000 - ElapsedSeconds * 1000, -2)
   returned := ElapsedHours "h:" ElapsedMinutes "m:" ElapsedSeconds "s." ElapsedMilliseconds
   return returned
}

TimePlus(one, two) {
   returned:=0
   returned+=Mod(one, 100) + Mod(two, 100)
   ;one/=100
   ;two/=100
   returned+=one
   return returned
}


;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Get - functions for retreaving informations - missing something - see Gui - retreaving ...
GetProcesses() {
   d = `n  ; string separator
   s := 4096  ; size of buffers and arrays (4 KB)

   Process, Exist  ; sets ErrorLevel to the PID of this running script
   ; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
   h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel)
   ; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
   DllCall("Advapi32.dll\OpenProcessToken", "UInt", h, "UInt", 32, "UIntP", t)
   VarSetCapacity(ti, 16, 0)  ; structure of privileges
   NumPut(1, ti, 0)  ; one entry in the privileges array...
   ; Retrieves the locally unique identifier of the debug privilege:
   DllCall("Advapi32.dll\LookupPrivilegeValueA", "UInt", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
   NumPut(luid, ti, 4, "int64")
   NumPut(2, ti, 12)  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
   ; Update the privileges of this process with the new access token:
   DllCall("Advapi32.dll\AdjustTokenPrivileges", "UInt", t, "Int", false, "UInt", &ti, "UInt", 0, "UInt", 0, "UInt", 0)
   DllCall("CloseHandle", "UInt", h)  ; close this process handle to save memory

   hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; increase performance by preloading the libaray
   s := VarSetCapacity(a, s)  ; an array that receives the list of process identifiers:
   c := 0  ; counter for process idendifiers
   DllCall("Psapi.dll\EnumProcesses", "UInt", &a, "UInt", s, "UIntP", r)
   Loop, % r // 4  ; parse array for identifiers as DWORDs (32 bits):
   {
      id := NumGet(a, A_Index * 4)
      ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
      h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id)
      VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
      e := DllCall("Psapi.dll\GetModuleBaseNameA", "UInt", h, "UInt", 0, "Str", n, "UInt", s)
      DllCall("CloseHandle", "UInt", h)  ; close process handle to save memory
      if (n && e)  ; if image is not null add to list:
         l .= n . d, c++
   }
   DllCall("FreeLibrary", "UInt", hModule)  ; unload the library to free memory
   Sort, l, C  ; uncomment this line to sort the list alphabetically
   ;MsgBox, 0, %c% Processes, %l%
   return l
}


;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Graphic functions
LoadPicture(aFilespec, aWidth:=0, aHeight:=0, ByRef aImageType:="", aIconNumber:=0, aUseGDIPlusIfAvailable:=1) {
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

GetImageDimensionProperty(ImgPath, Byref width, Byref height, PropertyName="dimensions") {

    Static DimensionIndex
    SplitPath, ImgPath , FileName, DirPath,
    objShell := ComObjCreate("Shell.Application")
    objFolder := objShell.NameSpace(DirPath)
    objFolderItem := objFolder.ParseName(FileName)

    if !DimensionIndex {
        Loop
            DimensionIndex := A_Index
        Until (objFolder.GetDetailsOf(objFolder.Items, A_Index) = PropertyName) || (A_Index > 300)
    }

    if (DimensionIndex = 301)
        Return

    dimensions := objFolder.GetDetailsOf(objFolderItem, DimensionIndex)
    width := height := ""
    pos := len := 0
    loop 2
    {
        pos := RegExMatch(dimensions, "O)\d+", oM, pos+len+1)
        if (A_Index = 1)
            width := oM.Value(0), len := oM.len(0)
        else
            height := oM.Value(0)
    }
}

GetImageDimensions(ImgPath, Byref width, Byref height) {
    DHW := A_DetectHiddenWIndows
    DetectHiddenWindows, ON
    Gui, AnimatedGifControl_GetImageDimensions: Add, Picture, hwndhWndImage, % ImgPath
    GuiControlGet, Image, AnimatedGifControl_GetImageDimensions:Pos, % hWndImage
    Gui, AnimatedGifControl_GetImageDimensions: Destroy
    DetectHiddenWindows, % DHW
    width := ImageW,     height := ImageH
}

Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r) {
	Region := Gdip_GetClipRegion(pGraphics)
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r)-1, y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r)-1, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r)-1, y+h-(2*r)-1, 2*r, 2*r)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_DeleteRegion(Region)
	Return E
}

Redraw(hwnd=0) {

    ;This function redraws the overlay window(s) using the position, text and scrolling settings
    global MainOverlay, PreviewOverlay, PreviewWindow, MainWindow
	outputdebug redraw
	;Called without parameters, recursive calls for both overlays
	if(hwnd=0)
	{
		if(MainOverlay && PreviewOverlay)
		{
			Redraw(MainWindow)
			Redraw(PreviewWindow)
			return
		}
		Else
		{
			msgbox Redraw() called with invalid window handle
			Exit
		}
	}
	;Get Position of overlay area and text position
	GetOverlayArea(x,y,w,h,hwnd)
	GetAbsolutePosition(CenterX,CenterY,hwnd)
	GetDrawingSettings(text,font,FontColor,style,BackColor,hwnd)

	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
	hbm := CreateDIBSection(w, h)

	; Get a device context compatible with the screen
	hdc := CreateCompatibleDC()

	; Select the bitmap into the device context
	obm := SelectObject(hdc, hbm)

	; Get a pointer to the graphics of the bitmap, for use with drawing functions
	G := Gdip_GraphicsFromHDC(hdc)

	; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
	Gdip_SetSmoothingMode(G, 4)
	Gdip_SetTextRenderingHint(G, 1)
	; Create a partially transparent, black brush (ARGB = Transparency, red, green, blue) to draw a rounded rectangle with
	pBrush := Gdip_BrushCreateSolid(backcolor)
	hFont := Font("", style "," font )
	size := Font_DrawText(text, hdc, hFont, "CALCRECT")		;measure the text, use already created font
	StringSplit, size, size, .
	FontWidth := size1,	FontHeight := size2
	DrawX:=CenterX-Round(FontWidth/2)
	DrawY:=CenterY-Round(FontHeight/2)

	corners:=min(Round(min(FontWidth,FontHeight)/5),20)
	Gdip_FillRoundedRectangle(G, pBrush, DrawX, DrawY, FontWidth, FontHeight, corners)
	; Delete the brush as it is no longer needed and wastes memory
	Gdip_DeleteBrush(pBrush)

	Options = x%DrawX% y%DrawY% cff%FontColor% %style% r4
	Gdip_TextToGraphics(G, text, Options, Font)


	; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
	; With some simple maths we can place the gui in the centre of our primary monitor horizontally and vertically at the specified heigth and width
	if(hwnd=PreviewWindow)
		UpdateLayeredWindow(PreviewOverlay, hdc, x, y, w, h)
	else if(hwnd=MainWindow)
		UpdateLayeredWindow(MainOverlay, hdc, x, y, w, h)

	; Select the object back into the hdc
	SelectObject(hdc, obm)

	; Now the bitmap may be deleted
	DeleteObject(hbm)

	; Also the device context related to the bitmap may be deleted
	DeleteDC(hdc)

	; The graphics may now be deleted
	Gdip_DeleteGraphics(G)
}

CreateSurface(monitor := 0, window := 0) {
	global DrawSurface_Hwnd

	if(monitor = 0) {
		if(window) {
			WinGetPos, sX, sY, sW, sH, ahk_id %window%
		} else {
			WinGetPos, sX, sY, sW, sH, Program Manager
		}
	} else {
		Sysget, MonitorInfo, Monitor, %monitor%
		sX := MonitorInfoLeft, sY := MonitorInfoTop
		sW := MonitorInfoRight - MonitorInfoLeft
		sH := MonitorInfoBottom - MonitorInfoTop
	}

	Gui DrawSurface:Color, 0xFFFFFF
	Gui DrawSurface: +E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop
	WinGet, DrawSurface_Hwnd, ID,
	WinSet, TransColor, 0xFFFFFF

	Gui DrawSurface:Show, x%sX% y%sY% w%sW% h%sH%
	Sleep, 100
	Gui DrawSurface:Submit

	return DrawSurface_Hwnd
}

ShowSurface() {
	WinGet, active_win, ID, A
	Gui DrawSurface:Show
	WinActivate, ahk_id %active_win%
}

HideSurface() {
	Gui DrawSurface:Submit
}

WipeSurface(hwnd) {
	DllCall("InvalidateRect", UInt, hwnd, UInt, 0, Int, 1)
    DllCall("UpdateWindow", UInt, hwnd)
}

StartDraw(wipe := true) {
	global DrawSurface_Hwnd

	if(wipe)
		WipeSurface(DrawSurface_Hwnd)

    HDC := DllCall("GetDC", Int, DrawSurface_Hwnd)

    return HDC
}

EndDraw(hdc) {
	global DrawSurface_Hwnd
	DllCall("ReleaseDC", Int, DrawSurface_Hwnd, Int, hdc)
}

SetPen(color, thickness, hdc) {
	global DrawSurface_Hwnd

	static pen := 0

	if(pen) {
		DllCall("DeleteObject", Int, pen)
		pen := 0
	}

	pen := DllCall("CreatePen", UInt, 0, UInt, thickness, UInt, color)
    DllCall("SelectObject", Int, hdc, Int, pen)
}

DrawLine(hdc, rX1, rY1, rX2, rY2) {
	DllCall("MoveToEx", Int, hdc, Int, rX1, Int, rY1, UInt, 0)
	DllCall("LineTo", Int, hdc, Int, rX2, Int, rY2)
}

DrawRectangle(hdc, left, top, right, bottom) {
	DllCall("MoveToEx", Int, hdc, Int, left, Int, top, UInt, 0)
    DllCall("LineTo", Int, hdc, Int, right, Int, top)
    DllCall("LineTo", Int, hdc, Int, right, Int, bottom)
    DllCall("LineTo", Int, hdc, Int, left, Int, bottom)
    DllCall("LineTo", Int, hdc, Int, left, Int, top-1)
}

SetAlpha(hwnd, alpha) {
    DllCall("UpdateLayeredWindow","uint",hwnd,"uint",0,"uint",0
        ,"uint",0,"uint",0,"uint",0,"uint",0,"uint*",alpha<<16|1<<24,"uint",2)
}
;Screenshot - functions maybe useful
Screenshot(outfile, screen) {
    pToken := Gdip_Startup()
    raster := 0x40000000 + 0x00CC0020 ; get layered windows

    pBitmap := Gdip_BitmapFromScreen(screen,raster)

    Gdip_SetBitmapToClipboard(pBitmap)
    Gdip_SaveBitmapToFile(pBitmap, outfile)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)

    PlaceTooltip("Screenshot copied and saved.")
}

DrawRectangle(startNewRectangle := false) {
static lastX, lastY
static xorigin, yorigin

if (startNewRectangle) {
  MouseGetPos, xorigin, yorigin
}

CoordMode, Mouse, Screen
MouseGetPos, currentX, currentY

; Has the mouse moved?
if (lastX lastY) = (currentX currentY)
return

lastX := currentX
lastY := currentY

x := Min(currentX, xorigin)
w := Abs(currentX - xorigin)
y := Min(currentY, yorigin)
h := Abs(currentY - yorigin)

Gui, ScreenshotSelection:Show, % "NA X" x " Y" y " W" w " H" h
Gui, ScreenshotSelection:+LastFound
}

TakeScreenshot() {
    static UserProfile
    if (UserProfile = "") {
      EnvGet, UserProfile, UserProfile
    }
    CoordMode, Mouse, Screen
    MouseGetPos, begin_x, begin_y
    DrawRectangle(true)
    SetTimer, rectangle, 10
    KeyWait, RButton

    SetTimer, rectangle, Off
    Gui, ScreenshotSelection:Cancel
    MouseGetPos, end_x, end_y

    Capture_x := Min(end_x, begin_x)
    Capture_y := Min(end_y, begin_y)
    Capture_width := Abs(end_x - begin_x)
    Capture_height := Abs(end_y - begin_y)

    area := Capture_x . "|" . Capture_y . "|" . Capture_width . "|" Capture_height ; X|Y|W|H

    FormatTime, CurrentDateTime,, yyyy-MM-ddTHH-mm-ss

    filename := UserProfile "\downloads\screenshot " CurrentDateTime ".png"

    Screenshot(filename,area)
return
}

;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------GUI FUNCTIONS SECTION--------------------------------------------------------------------------------------------------------------------------------------------------------
    ;{Gui - Customizable full gui functions
HtmlBox(Html, Title="", Timeout=0, Permanent=False, GUIOptions="Resize MaximizeBox Minsize420x320", ControlOptions="W400 H300", Margin=10, Hotkey=True) {
    ;AutoHotkey_L 1.1.04+
    ;Timeout : The seconds to make the HTML window disappear.
    ;Permanent : if this is True, closing the GUI window does not destroy it but it is hidden.
    ;Return Value: the handle of the created window(Hwnd).

    static HtmlBoxInfo := [], WindowHideStack := [] , WB , ExecCmd := { a : "selectall", c : "copy",  p : "print", v : "paste" }
    Gui, New, LabelHtmlBox HWNDHwndHtml %GUIOptions%, % Title     ;v1.1.04+
    Gui, Margin, %Margin%, %Margin%
    Gui, Add, ActiveX, vWB HwndHwndHtmlControl %ControlOptions%, Shell.Explorer    ;v1.1.03+
    WB.silent := true
    WB.Navigate("about:blank")
    Loop
       Sleep 10
    Until   (WB.readyState=4 && WB.document.readyState="complete" && !WB.busy)
    WB.document.write(html)
    Gui, Show
    If Timeout {
        ExecuteTime := A_TickCount + Timeout * 1000
        loop % (WindowHideStack.MaxIndex() ? WindowHideStack.MaxIndex() + 1 : 1) {
            if (!(WindowHideStack[A_Index].ExecuteTime) && (A_Index = 1)) || (WindowHideStack[A_Index].ExecuteTime > ExecuteTime) {
                Inserted := True, WindowHideStack.Insert(A_Index, { ExecuteTime: ExecuteTime, Hwnd : HwndHtml })    ;increment the rest
                if (A_Index = 1)
                    SetTimer, HtmlBoxClose, % Timeout * -1 * 1000
            }
        } Until (Inserted)
        if !Inserted
            WindowHideStack.Insert({ ExecuteTime: ExecuteTime, Hwnd : HwndHtml })    ;insert it at the very end
    }
    HtmlBoxInfo[HwndHtml] := { HwndWindow : HwndHtml, Margin : Margin, HwndHtmlControl : HwndHtmlControl, Permanent: Permanent, doc : WB.document }
    If Hotkey {
        Hotkey, IfWinActive, ahk_id %HwndHtml%
        For key in ExecCmd
            Hotkey, ^%key%, HtmlBoxExecCommand
        Hotkey, IfWinActive
    }
Return HwndHtml
    HtmlBoxSize:
        If (A_EventInfo = 1)  ; The window has been minimized.  No action needed.
            Return
        GuiControl, Move, % HtmlBoxInfo[Trim(A_GUI)].HwndHtmlControl
                  , % "H" (A_GuiHeight - HtmlBoxInfo[A_GUI].margin * 2) " W" ( A_GuiWidth - HtmlBoxInfo[A_GUI].margin * 2)
    Return
    HtmlBoxEscape:
    HtmlBoxClose:
        if (_HwndHtml := WindowHideStack[WindowHideStack.MinIndex()].Hwnd)  {     ;this means it's called from the timer, so the least index is removed
            WindowHideStack.Remove(WindowHideStack.MinIndex())
            if (NextTimer := WindowHideStack[WindowHideStack.MinIndex()].ExecuteTime)        ;this means a next timer exists
                SetTimer,, % A_TickCount - NextTimer < 0 ? A_TickCount - NextTimer : -1        ;v1.1.01+
        } else
            _HwndHtml := HtmlBoxInfo[A_GUI].HwndWindow
        DHW := A_DetectHiddenWindows
        DetectHiddenWindows, ON
        if WinExist("ahk_id " _HwndHtml) {        ;in case timeout is set and the user closes before the timeout
            if !HtmlBoxInfo[_HwndHtml].Permanent {
                Gui, %_HwndHtml%:Destroy
                WB := ""
                HtmlBoxInfo.Remove(_HwndHtml, "")
            } else
                Gui, %_HwndHtml%:Hide
        }
        DetectHiddenWindows, % DHW
    Return
    HtmlBoxExecCommand:        ;this is called when the user presses one of the hotkeys
        HtmlBoxInfo[WinExist("A")].doc.ExecCommand(ExecCmd[SubStr(A_ThisHotkey, 2)])
    Return
}

EditBox(Text, Title="", Timeout=0, Permanent=False, GUIOptions="Resize MaximizeBox Minsize420x320", ControlOptions="VScroll W400 H300", Margin=10) {
    ;AutoHotkey_L 1.1.04+
    ;Timeout : The seconds to make the edit window disappear.
    ;Permanent : if this is True, closing the GUI window does not destroy it but it is hidden.
    ;Return Value: the handle of the created window(Hwnd).

    Static EditBoxInfo := [], WindowHideStack := []
    Gui, New, LabelEditBox HWNDHwndEdit %GUIOptions%, % Title     ;v1.1.04+
    Gui, Margin, %Margin%, %Margin%
    Gui, Add, Edit, HwndHwndEditControl %ControlOptions%, % Text
    ControlFocus,, ahk_id %HwndEditControl%
    Gui, Show
    If Timeout {
        WindowHideStack[A_TickCount + Timeout * 1000] := HwndEdit
        SetTimer, EditBoxClose, % Timeout * -1 * 1000
    }
    EditBoxInfo[HwndEdit] := { HwndWindow : HwndEdit, Margin : Margin, HwndEditControl : HwndEditControl }
Return HwndEdit

    EditBoxSize:
        If (A_EventInfo = 1)  ; The window has been minimized.  No action needed.
            Return
        GuiControl, Move, % EditBoxInfo[Trim(A_GUI)].HwndEditControl
                  , % "H" (A_GuiHeight - EditBoxInfo[A_GUI].margin * 2) " W" ( A_GuiWidth - EditBoxInfo[A_GUI].margin * 2)
    Return
    EditBoxEscape:
    EditBoxClose:
        if (HwndEdit := WindowHideStack.Remove(WindowHideStack.MinIndex(), "")) { ;this means it's called from the timer, so the least index is removed
            if (NextTimer := WindowHideStack.MinIndex())        ;this means a next timer exists
                SetTimer,, % A_TickCount - NextTimer < 0 ? A_TickCount - NextTimer : -1        ;v1.1.01+
        } else
            HwndEdit := EditBoxInfo[A_GUI].HwndWindow
        if !Permanent {
            Gui, %HwndEdit%:Destroy
            EditBoxInfo.Remove(HwndEdit, "")
        } else
            Gui, %HwndEdit%:Hide
    Return
}

Popup(title,action,close=true,image="",w=197,h=46) {
    SysGet, Screen, MonitorWorkArea
    ScreenRight-=w+3
    ScreenBottom-=h+4
    SplashImage,%image%,CWe0dfe3 b1 x%ScreenRight% y%ScreenBottom% w%w% h%h% C00 FM8 FS8, %action%,%title%,Popup
    WinSet, Transparent, 216, Popup
    if close
        SetTimer, ClosePopup, -2000
    return
}

ClosePopup: ;{
    WinGet,WinID,ID,Popup
    MouseGetPos,,,MouseWinID
    ifEqual,WinID,%MouseWinID%
    {
        SetTimer, ClosePopup, -2000
    }else{
        SplashImage, Off
    }
    return
;}

GetTextSize(str, size, font,ByRef height,ByRef width) {         ;Funktion zur Berechnung von Breite und Höhe je nach Textlänge
        Gui temp: Font, s%size%, %font%
        Gui temp:Add, Text, , %str%
        GuiControlGet T, temp:Pos, Static1
        Gui temp:Destroy
        height = % TH
        width = % TW
        }

AddGraphicButtonPlus(ImgPath, Options="", Text="") {
    hGdiPlus := DllCall("LoadLibrary", "Str", "gdiplus.dll")
    VarSetCapacity(si, 16, 0), si := Chr(1)
    DllCall("gdiplus\GdiplusStartup", "UIntP", pToken, "UInt", &si, "UInt", 0)
    VarSetCapacity(wFile, StrLen(ImgPath)*2+2)
    DllCall("kernel32\MultiByteToWideChar", "UInt", 0, "UInt", 0, "Str", ImgPath, "Int", -1, "UInt", &wFile, "Int", VarSetCapacity(wFile)//2)
    DllCall("gdiplus\GdipCreateBitmapFromFile", "UInt", &wFile, "UIntP", pBitmap)
    if (pBitmap) {
        DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UInt", pBitmap, "UIntP", hBM, "UInt", 0)
        DllCall("gdiplus\GdipDisposeImage", "Uint", pBitmap)
    }
    DllCall("gdiplus\GdiplusShutdown" , "UInt", pToken)
    DllCall("FreeLibrary", "UInt", hGdiPlus)

    if Text =
    {
        VarSetCapacity(oBM, 24)
        DllCall("GetObject","uint",hBM,"int",24,"uint",&oBM)
        Options := "W" NumGet(oBM,4,"int") " H" NumGet(oBM,8,"int") " +128 " Options
    }

    Gui, Add, Button, %Options% hwndhwnd, %Text%

    SendMessage, 0xF7, 0, hBM,, ahk_id %hwnd%  ; BM_SETIMAGE
    if ErrorLevel ; delete previous image
        DllCall("DeleteObject", "uint", ErrorLevel)

    return hBM
}

AddGraphicButtonPlus(ImgPath, Options="", Text="") {
    hGdiPlus := DllCall("LoadLibrary", "Str", "gdiplus.dll")
    VarSetCapacity(si, 16, 0), si := Chr(1)
    DllCall("gdiplus\GdiplusStartup", "UIntP", pToken, "UInt", &si, "UInt", 0)
    VarSetCapacity(wFile, StrLen(ImgPath)*2+2)
    DllCall("kernel32\MultiByteToWideChar", "UInt", 0, "UInt", 0, "Str", ImgPath, "Int", -1, "UInt", &wFile, "Int", VarSetCapacity(wFile)//2)
    DllCall("gdiplus\GdipCreateBitmapFromFile", "UInt", &wFile, "UIntP", pBitmap)
    if (pBitmap) {
        DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UInt", pBitmap, "UIntP", hBM, "UInt", 0)
        DllCall("gdiplus\GdipDisposeImage", "Uint", pBitmap)
    }
    DllCall("gdiplus\GdiplusShutdown" , "UInt", pToken)
    DllCall("FreeLibrary", "UInt", hGdiPlus)

    if Text =
    {
        VarSetCapacity(oBM, 24)
        DllCall("GetObject","uint",hBM,"int",24,"uint",&oBM)
        Options := "W" NumGet(oBM,4,"int") " H" NumGet(oBM,8,"int") " +128 " Options
    }

    Gui, Add, Button, %Options% hwndhwnd, %Text%

    SendMessage, 0xF7, 0, hBM,, ahk_id %hwnd%  ; BM_SETIMAGE
    if ErrorLevel ; delete previous image
        DllCall("DeleteObject", "uint", ErrorLevel)

    return hBM
}

hicon := DllCall("LoadImage", "uInt", 0, "Str", "Icon.ico", "uInt", 2, "Int", 16, "Int", 16, "uInt", 0x10)

;}

    ;{Gui - changing functions
FadeGui(guihwnd, fading_time, inout) {

	AW_BLEND := 0x00080000
	AW_HIDE  := 0x00010000

	if inout	= "out"
		DllCall("user32\AnimateWindow", "ptr", guihwnd, "uint", fading_time, "uint", AW_BLEND|AW_HIDE)    ; Fade Out
	if inout = "in"
		DllCall("user32\AnimateWindow", "ptr", guihwnd, "uint", fading_time, "uint", AW_BLEND)    ; Fade In

return
}

ShadowBorder(handle) {
    DllCall("user32.dll\SetClassLongPtr", "ptr", handle, "int", -26, "ptr", DllCall("user32.dll\GetClassLongPtr", "ptr", handle, "int", -26, "uptr") | 0x20000)
}

FrameShadow(handle) {
    DllCall("dwmapi.dll\DwmIsCompositionEnabled", "int*", DwmEnabled)
    if !(DwmEnabled)
        DllCall("user32.dll\SetClassLongPtr", "ptr", handle, "int", -26, "ptr", DllCall("user32.dll\GetClassLongPtr", "ptr", handle, "int", -26) | 0x20000)
    else {
        VarSetCapacity(MARGINS, 16, 0) && NumPut(1, NumPut(1, NumPut(1, NumPut(1, MARGINS, "int"), "int"), "int"), "int")
        DllCall("dwmapi.dll\DwmSetWindowAttribute", "ptr", handle, "uint", 2, "ptr*", 2, "uint", 4)
        DllCall("dwmapi.dll\DwmExtendFrameIntoClientArea", "ptr", handle, "ptr", &MARGINS)
    }
}


;}

    ;{Gui - retreaving informations functuions
GetParent(hWnd) {
	return DllCall("GetParent", "Ptr", hWnd, "Ptr")
}

GetWindow(hWnd,uCmd) {
	return DllCall( "GetWindow", "Ptr", hWnd, "uint", uCmd, "Ptr")
}

GetForegroundWindow() {
	return DllCall("GetForeGroundWindow", "Ptr")
}

IsWindowVisible(hWnd) {
	return DllCall("IsWindowVisible","Ptr",h)
}

IsFullScreen() {
  WinGet, Style, Style, A ; active window
  return !(Style & 0x40000) ; 0x40000 = WS_SIZEBOX
}

IsClosed(win, wait) {
	WinWaitClose, ahk_id %win%,, %wait%
	return ((ErrorLevel = 1) ? False : True)
}

IsControlFocused(hwnd) {
    VarSetCapacity(GuiThreadInfo, 48) , NumPut(48, GuiThreadInfo, 0)
    Return DllCall("GetGUIThreadInfo", uint, 0, str, GuiThreadInfo) ? (hwnd = NumGet(GuiThreadInfo, 12)) ? True : False : False
}

IsOverTitleBar(x, y, hWnd) { ; This function is from http://www.autohotkey.com/forum/topic22178.html
   SendMessage, 0x84,, (x & 0xFFFF) | (y & 0xFFFF) << 16,, ahk_id %hWnd%
   if ErrorLevel in 2,3,8,9,20,21
      return true
   else
      return false
}

WinGetPosEx(hWindow,ByRef X="",ByRef Y="",ByRef Width="",ByRef Height="",ByRef Offset_X="",ByRef Offset_Y="")  {  ;Gets the position, size, and offset of a window.

/*
;
; Function: WinGetPosEx
;
; Description:
;
;   Gets the position, size, and offset of a window. See the *Remarks* section
;   for more information.
;
; Parameters:
;
;   hWindow - Handle to the window.
;
;   X, Y, Width, Height - Output variables. [Optional] If defined, these
;       variables contain the coordinates of the window relative to the
;       upper-left corner of the screen (X and Y), and the Width and Height of
;       the window.
;
;   Offset_X, Offset_Y - Output variables. [Optional] Offset, in pixels, of the
;       actual position of the window versus the position of the window as
;       reported by GetWindowRect.  If moving the window to specific
;       coordinates, add these offset values to the appropriate coordinate
;       (X and/or Y) to reflect the true size of the window.
;
; Returns:
;
;   If successful, the address of a RECTPlus structure is returned.  The first
;   16 bytes contains a RECT structure that contains the dimensions of the
;   bounding rectangle of the specified window.  The dimensions are given in
;   screen coordinates that are relative to the upper-left corner of the screen.
;   The next 8 bytes contain the X and Y offsets (4-byte integer for X and
;   4-byte integer for Y).
;
;   Also if successful (and if defined), the output variables (X, Y, Width,
;   Height, Offset_X, and Offset_Y) are updated.  See the *Parameters* section
;   for more more information.
;
;   If not successful, FALSE is returned.
;
; Requirement:
;
;   Windows 2000+
;
; Remarks, Observations, and Changes:
;
; * Starting with Windows Vista, Microsoft includes the Desktop Window Manager
;   (DWM) along with Aero-based themes that use DWM.  Aero themes provide new
;   features like a translucent glass design with subtle window animations.
;   Unfortunately, the DWM doesn't always conform to the OS rules for size and
;   positioning of windows.  If using an Aero theme, many of the windows are
;   actually larger than reported by Windows when using standard commands (Ex:
;   WinGetPos, GetWindowRect, etc.) and because of that, are not positioned
;   correctly when using standard commands (Ex: gui Show, WinMove, etc.).  This
;   function was created to 1) identify the true position and size of all
;   windows regardless of the window attributes, desktop theme, or version of
;   Windows and to 2) identify the appropriate offset that is needed to position
;   the window if the window is a different size than reported.
;
; * The true size, position, and offset of a window cannot be determined until
;   the window has been rendered.  See the example script for an example of how
;   to use this function to position a new window.
;
; * 20150906: The "dwmapi\DwmGetWindowAttribute" function can return odd errors
;   if DWM is not enabled.  One error I've discovered is a return code of
;   0x80070006 with a last error code of 6, i.e. ERROR_INVALID_HANDLE or "The
;   handle is invalid."  To keep the function operational during this types of
;   conditions, the function has been modified to assume that all unexpected
;   return codes mean that DWM is not available and continue to process without
;   it.  When DWM is a possibility (i.e. Vista+), a developer-friendly messsage
;   will be dumped to the debugger when these errors occur.
;
; * 20160105 (Ben Allred): Adjust width and height for offset calculations if
;   DPI is in play.
;
; Credit:
;
;   Idea and some code from *KaFu* (AutoIt forum)
;
;-------------------------------------------------------------------------------
    */

    Static Dummy5693
          ,RECTPlus
          ,S_OK:=0x0
          ,DWMWA_EXTENDED_FRAME_BOUNDS:=9

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Get the window's dimensions
    ;   Note: Only the first 16 bytes of the RECTPlus structure are used by the
    ;   DwmGetWindowAttribute and GetWindowRect functions.
    VarSetCapacity(RECTPlus,24,0)
    DWMRC:=DllCall("dwmapi\DwmGetWindowAttribute"
        ,PtrType,hWindow                                ;-- hwnd
        ,"UInt",DWMWA_EXTENDED_FRAME_BOUNDS             ;-- dwAttribute
        ,PtrType,&RECTPlus                              ;-- pvAttribute
        ,"UInt",16)                                     ;-- cbAttribute

    if (DWMRC<>S_OK)
        {
        if ErrorLevel in -3,-4  ;-- Dll or function not found (older than Vista)
            {
            ;-- Do nothing else (for now)
            }
         else
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Unknown error calling "dwmapi\DwmGetWindowAttribute".
                RC=%DWMRC%,
                ErrorLevel=%ErrorLevel%,
                A_LastError=%A_LastError%.
                "GetWindowRect" used instead.
               )

        ;-- Collect the position and size from "GetWindowRect"
        DllCall("GetWindowRect",PtrType,hWindow,PtrType,&RECTPlus)
        }

    ;-- Populate the output variables
    X:=Left :=NumGet(RECTPlus,0,"Int")
    Y:=Top  :=NumGet(RECTPlus,4,"Int")
    Right   :=NumGet(RECTPlus,8,"Int")
    Bottom  :=NumGet(RECTPlus,12,"Int")
    Width   :=Right-Left
    Height  :=Bottom-Top
    OffSet_X:=0
    OffSet_Y:=0

    ;-- If DWM is not used (older than Vista or DWM not enabled), we're done
    if (DWMRC<>S_OK)
        Return &RECTPlus

    ;-- Collect dimensions via GetWindowRect
    VarSetCapacity(RECT,16,0)
    DllCall("GetWindowRect",PtrType,hWindow,PtrType,&RECT)
    GWR_Width :=NumGet(RECT,8,"Int")-NumGet(RECT,0,"Int")
        ;-- Right minus Left
    GWR_Height:=NumGet(RECT,12,"Int")-NumGet(RECT,4,"Int")
        ;-- Bottom minus Top

    ;-- Adjust width and height for offset calculations if DPI is in play
    ;   See https://msdn.microsoft.com/en-us/library/windows/desktop/dn280512(v=vs.85).aspx
    ;   The current version of AutoHotkey is PROCESS_SYSTEM_DPI_AWARE (contains "<dpiAware>true</dpiAware>" in its manifest)
    ;   DwmGetWindowAttribute returns DPI scaled sizes
    ;   GetWindowRect does not
    ; get monitor handle where the window is at so we can get the monitor name
    hMonitor := DllCall("MonitorFromRect",PtrType,&RECT,UInt,2) ; MONITOR_DEFAULTTONEAREST = 2 (Returns a handle to the display monitor that is nearest to the rectangle)
    ; get monitor name so we can get a handle to the monitor device context
    VarSetCapacity(MONITORINFOEX,104)
    NumPut(104,MONITORINFOEX)
    DllCall("GetMonitorInfo",PtrType,hMonitor,PtrType,&MONITORINFOEX)
    monitorName := StrGet(&MONITORINFOEX+40)
    ; get handle to monitor device context so we can get the dpi adjusted and actual screen sizes
    hdc := DllCall("CreateDC",Str,monitorName,PtrType,0,PtrType,0,PtrType,0)
    ; get dpi adjusted and actual screen sizes
    dpiAdjustedScreenHeight := DllCall("GetDeviceCaps",PtrType,hdc,Int,10) ; VERTRES = 10 (Height, in raster lines, of the screen)
    actualScreenHeight := DllCall("GetDeviceCaps",PtrType,hdc,Int,117) ; DESKTOPVERTRES = 117
    ; delete hdc as instructed
    DllCall("DeleteDC",PtrType,hdc)
    ; calculate dpi adjusted width and height
    dpiFactor := actualScreenHeight/dpiAdjustedScreenHeight ; this will be 1.0 if DPI is 100%
    dpiAdjusted_Width := Ceil(Width/dpiFactor)
    dpiAdjusted_Height := Ceil(Height/dpiFactor)

    ;-- Calculate offsets and update output variables
    NumPut(Offset_X:=(dpiAdjusted_Width-GWR_Width)//2,RECTPlus,16,"Int")
    NumPut(Offset_Y:=(dpiAdjusted_Height-GWR_Height)//2,RECTPlus,20,"Int")
    Return &RECTPlus
    }

screenDims() {
	W := A_ScreenWidth
	H := A_ScreenHeight
	DPI := A_ScreenDPI
	Orient := (W>H)?"L":"P"
	;MsgBox % "W: "W "`nH: "H "`nDPI: "DPI
	return {W:W, H:H, DPI:DPI, OR:Orient}
}

GetFocusedControl()  {   ; This script retrieves the ahk_id (HWND) of the active window's focused control.

        ; This script requires Windows 98+ or NT 4.0 SP3+.
        /*
        typedef struct tagGUITHREADINFO {
        DWORD cbSize;
        DWORD flags;
        HWND  hwndActive;
        HWND  hwndFocus;
        HWND  hwndCapture;
        HWND  hwndMenuOwner;
        HWND  hwndMoveSize;
        HWND  hwndCaret;
        RECT  rcCaret;
        } GUITHREADINFO, *PGUITHREADINFO;
        */

    guiThreadInfoSize := 8 + 6 * A_PtrSize + 16
   VarSetCapacity(guiThreadInfo, guiThreadInfoSize, 0)
   NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
   ; DllCall("RtlFillMemory" , "PTR", &guiThreadInfo, "UInt", 1 , "UChar", guiThreadInfoSize)   ; Below 0xFF, one call only is needed
   If(DllCall("GetGUIThreadInfo" , "UInt", 0   ; Foreground thread
         , "PTR", &guiThreadInfo) = 0)
   {
      ErrorLevel := A_LastError   ; Failure
      Return 0
   }
   focusedHwnd := NumGet(guiThreadInfo,8+A_PtrSize, "Ptr") ; *(addr + 12) + (*(addr + 13) << 8) +  (*(addr + 14) << 16) + (*(addr + 15) << 24)
   Return focusedHwnd
}

HWNDToClassNN(hwnd) {
	win := DllCall("GetParent", "PTR", hwnd, "PTR")
	WinGet ctrlList, ControlList, ahk_id %win%
	; Built an array indexing the control names by their hwnd
	Loop Parse, ctrlList, `n
	{
		ControlGet hwnd1, Hwnd, , %A_LoopField%, ahk_id %win%
		if(hwnd1=hwnd)
			return A_LoopField
	}
}

XPGetFocussed() {
  WinGet ctrlList, ControlList, A
  ctrlHwnd:=GetFocusedControl()
  ; Built an array indexing the control names by their hwnd
  Loop Parse, ctrlList, `n
  {
    ControlGet hwnd, Hwnd, , %A_LoopField%, A
    hwnd += 0   ; Convert from hexa to decimal
    if(hwnd=ctrlHwnd)
      return A_LoopField
  }
}

GetControls(hwnd, controls="") {
	if !isobject(controls)
		controls:=[]

	if isobject(hwnd){
		for k,v in hwnd
			controls:=GetControls(v, controls)
		return controls
	}

	winget,classnn,ControlList,ahk_id %hwnd%
	winget,controlId,controllisthwnd,ahk_id %hwnd%
	loop,parse,classnn,`n
	{
		controls[a_index]:=[]
		controls[a_index]["ClassNN"]:=a_loopfield
	}

	loop,parse,controlId,`n
	{
		controls[a_index]["Hwnd"]:=a_loopfield
		controlgetText,txt,,ahk_id %a_loopfield%
		controls[a_index]["text"]:=txt
	}
	return controls
}

GetOtherControl(refHwnd,shift,controls,type="hwnd") {
	for k,v in controls
		if v[type]=refHwnd
			return controls[k+shift].hwnd
}

GetClientRect(hwnd) {
	VarSetCapacity(rc, 16)
	result := DllCall("GetClientRect", "PTR", hwnd, "PTR", &rc, "UINT")
	return {x : NumGet(rc, 0, "int"), y : NumGet(rc, 4, "int"), w : NumGet(rc, 8, "int"), h : NumGet(rc, 12, "int")}
}

ListControls(hwnd, obj=0, arr="") {
	if !isobject(arr)
		arr:=[]

	if isobject(hwnd){
		for k,v in hwnd
			arr:=ListControls(v, 1, arr)
		goto ListControlsReturn
	}

	str=
	arr:=GetControls(hwnd)
ListControlsReturn:
	if obj
		return arr

	for k,v in arr
		str.="""" v["Hwnd"] """,""" v["ClassNN"] """,""" v["text"] """`n"
	return str
}

getProcessBaseAddress(WindowTitle, MatchMode=3)	{      ;WindowTitle can be anything ahk_exe ahk_class etc

	mode :=  A_TitleMatchMode
	SetTitleMatchMode, %MatchMode%	;mode 3 is an exact match
	WinGet, hWnd, ID, %WindowTitle%
	; AHK32Bit A_PtrSize = 4 | AHK64Bit - 8 bytes
	BaseAddress := DllCall(A_PtrSize = 4
		? "GetWindowLong"
		: "GetWindowLongPtr", "Uint", hWnd, "Uint", -6)
	SetTitleMatchMode, %mode%	; In case executed in autoexec

	return BaseAddress
}


;}

    ;{Gui - interacting
WinWaitForMinimized(ByRef winID, timeOut = 1000) {
  ; Function:  WinWaitForMinimized
;              waits for the window winID to minimize or until timeout,
;              whichever comes first (used to delay other actions until a
;              minimize message is handled and completed)
; Parm1:     winID - ID of window to wait for minimization
; Parm2:     timeOut - optional - timeout in milliseconds to wait
; wait until minimized (or timeOut)
   iterations := timeOut/10
   loop,%iterations%
   {
      WinGet,winMinMax,MinMax,ahk_id %winID%
      if (winMinMax = -1)
         break
      sleep 10
   }
}

CenterWindow(aWidth,aHeight) {
  ; Given a the window's width and height, calculates where to position its upper-left corner
  ; so that it is centered EVEN IF the task bar is on the left side or top side of the window.
  ; This does not currently handle multi-monitor systems explicitly, since those calculations
  ; require API functions that don't exist in Win95/NT (and thus would have to be loaded
  ; dynamically to allow the program to launch).  Therefore, windows will likely wind up
  ; being centered across the total dimensions of all monitors, which usually results in
  ; half being on one monitor and half in the other.  This doesn't seem too terrible and
  ; might even be what the user wants in some cases (i.e. for really big windows).

	static rect:=Struct("left,top,right,bottom"),SPI_GETWORKAREA:=48,pt:=Struct("x,y")
	DllCall("SystemParametersInfo","Int",SPI_GETWORKAREA,"Int", 0,"PTR", rect[],"Int", 0)  ; Get desktop rect excluding task bar.
	; Note that rect.left will NOT be zero if the taskbar is on docked on the left.
	; Similarly, rect.top will NOT be zero if the taskbar is on docked at the top of the screen.
	pt.x := rect.left + (((rect.right - rect.left) - aWidth) / 2)
	pt.y := rect.top + (((rect.bottom - rect.top) - aHeight) / 2)
	return pt
}

Result := DllCall("SetWindowPos", "UInt", Gui2, "UInt", Gui1, "Int", Gui1X + 300, "Int", Gui1Y, "Int", "", "Int", "", "Int", 0x01)

TryKillWin(win) {
	static funcs := ["Win32_SendMessage", "Win32_TaskKill", "Win32_Terminate"]

	if(IsClosed(win, 0.5)) {
		IdleGui("Window is already closed", "", 3, true)
		return
	}

	for i, v in funcs {
		IdleGui("Trying " . v . "...", "Closing...", 10, false)
		if(%v%(win)) {
			IdleGuiClose()
			return true
		}
	}
	return false
}

Win32_SendMessage(win) {
	static wm_msgs := {"WM_CLOSE":0x0010, "WM_QUIT":0x0012, "WM_DESTROY":0x0002}
	for k, v in wm_msgs {
		SendMessage, %v%, 0, 0,, ahk_id %win%
		if(IsClosed(win, 1))
			break
	}
	if(IsClosed(win, 1))
		return true
	return false
}

Win32_TaskKill(win) {
	WinGet, win_pid, PID, ahk_id %win%
	cmdline := "taskkill /pid " . win_pid . " /f"
	Run, %cmdline%,, Hide UseErrorLevel
	if(ErrorLevel != 0 or !IsClosed(win, 5))
		return false
	return true
}

Win32_Terminate(win) {
	WinGet, win_pid, PID, ahk_id %win%
	handle := DllCall("Kernel32\OpenProcess", UInt, 0x0001, UInt, 0, UInt, win_pid)
	if(!handle)
		return false
	result := DllCall("Kernel32\TerminateProcess", UInt, handle, Int, 0)
	if(!result)
		return false
	return IsClosed(win, 5)
}

TabActivate(no) {
	global GuiWinTitle
	SendMessage, 0x1330, %no%,, SysTabControl321, %GuiWinTitle%
	Sleep 50
	SendMessage, 0x130C, %no%,, SysTabControl321, %GuiWinTitle%
	return
}

FocuslessScroll(Function inside) {
;Directives
#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 100 ;Avoid warning when mouse wheel turned very fast
;Autoexecute code
MinLinesPerNotch := 1
MaxLinesPerNotch := 5
AccelerationThreshold := 100
AccelerationType := "L" ;Change to "P" for parabolic acceleration
StutterThreshold := 10
;Function definitions
;See above for details
FocuslessScroll(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold) {
	SetBatchLines, -1 ;Run as fast as possible
	CoordMode, Mouse, Screen ;All coords relative to screen

	;Stutter filter: Prevent stutter caused by cheap mice by ignoring successive WheelUp/WheelDown events that occur to close together.
	If(A_TimeSincePriorHotkey < StutterThreshold) ;Quickest succession time in ms
		If(A_PriorHotkey = "WheelUp" Or A_PriorHotkey ="WheelDown")
			Return

	MouseGetPos, m_x, m_y,, ControlClass2, 2
	ControlClass1 := DllCall( "WindowFromPoint", "int64", (m_y << 32) | (m_x & 0xFFFFFFFF), "Ptr") ;32-bit and 64-bit support

	lParam := (m_y << 16) | (m_x & 0x0000FFFF)
	wParam := (120 << 16) ;Wheel delta is 120, as defined by MicroSoft

	;Detect WheelDown event
	If(A_ThisHotkey = "WheelDown" Or A_ThisHotkey = "^WheelDown" Or A_ThisHotkey = "+WheelDown" Or A_ThisHotkey = "*WheelDown")
		wParam := -wParam ;If scrolling down, invert scroll direction

	;Detect modifer keys held down (only Shift and Control work)
	If(GetKeyState("Shift","p"))
		wParam := wParam | 0x4
	If(GetKeyState("Ctrl","p"))
		wParam := wParam | 0x8

	;Adjust lines per notch according to scrolling speed
	Lines := LinesPerNotch(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType)

	If(ControlClass1 != ControlClass2)
	{
		Loop %Lines%
		{
			SendMessage, 0x20A, wParam, lParam,, ahk_id %ControlClass1%
			SendMessage, 0x20A, wParam, lParam,, ahk_id %ControlClass2%
		}
	}
	Else ;Avoid using Loop when not needed (most normal controls). Greately improves momentum problem!
	{
		SendMessage, 0x20A, wParam * Lines, lParam,, ahk_id %ControlClass1%
	}
}
LinesPerNotch(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType) {
	T := A_TimeSincePriorHotkey
	;All parameters are the same as the parameters of FocuslessScroll()
	;Return value: Returns the number of lines to be scrolled calculated from the current scroll speed.
	;Normal slow scrolling, separationg between scroll events is greater than AccelerationThreshold miliseconds.
	If((T > AccelerationThreshold) Or (T = -1)) ;T = -1 if this is the first hotkey ever run
	{
		Lines := MinLinesPerNotch
	}
	;Fast scrolling, use acceleration
	Else
	{
		If(AccelerationType = "P")
		{
			;Parabolic scroll speed curve
			;f(t) = At^2 + Bt + C
			A := (MaxLinesPerNotch-MinLinesPerNotch)/(AccelerationThreshold**2)
			B := -2 * (MaxLinesPerNotch - MinLinesPerNotch)/AccelerationThreshold
			C := MaxLinesPerNotch
			Lines := Round(A*(T**2) + B*T + C)
		}
		Else
		{
			;Linear scroll speed curve
			;f(t) = Bt + C
			B := (MinLinesPerNotch-MaxLinesPerNotch)/AccelerationThreshold
			C := MaxLinesPerNotch
			Lines := Round(B*T + C)
		}
	}
	Return Lines
}
;All hotkeys with the same parameters can use the same instance of FocuslessScroll(). No need to have separate calls unless each hotkey requires different parameters (e.g. you want to disable acceleration for Ctrl-WheelUp and Ctrl-WheelDown).
;If you want a single set of parameters for all scrollwheel actions, you can simply use *WheelUp:: and *WheelDown:: instead.
#MaxThreadsPerHotkey 6 ;Adjust to taste. The lower the value, the lesser the momentum problem on certain smooth-scrolling GUI controls (e.g. AHK helpfile main pane, WordPad...), but also the lesser the acceleration feel. The good news is that this setting does no affect most controls, only those that exhibit the momentum problem. Nice.
;Scroll with acceleration
WheelUp::
WheelDown::FocuslessScroll(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
;Ctrl-Scroll zoom with no acceleration (MaxLinesPerNotch = MinLinesPerNotch).
^WheelUp::
^WheelDown::FocuslessScroll(MinLinesPerNotch, MinLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
;If you want zoom acceleration, replace above line with this:
;FocuslessScroll(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
#MaxThreadsPerHotkey 1 ;Restore AHK's default  value i.e. 1
;End: Focusless Scroll
}

FocuslessScrollHorizontal(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold) {
    SetBatchLines, -1 ;Run as fast as possible
    CoordMode, Mouse, Screen ;All coords relative to screen

    ;Stutter filter: Prevent stutter caused by cheap mice by ignoring successive WheelUp/WheelDown events that occur to close together.
    If(A_TimeSincePriorHotkey < StutterThreshold) ;Quickest succession time in ms
        If(A_PriorHotkey = "WheelUp" Or A_PriorHotkey ="WheelDown")
            Return

    MouseGetPos, m_x, m_y,, ControlClass2, 2
    ControlClass1 := DllCall( "WindowFromPoint", "int64", (m_y << 32) | (m_x & 0xFFFFFFFF), "Ptr") ;32-bit and 64-bit support

    ctrlMsg := 0x114    ; WM_HSCROLL
    wParam := 0         ; Left

    ;Detect WheelDown event
    If(A_ThisHotkey = "WheelDown" Or A_ThisHotkey = "^WheelDown" Or A_ThisHotkey = "+WheelDown" Or A_ThisHotkey = "*WheelDown")
        wParam := 1 ; Right

    ;Adjust lines per notch according to scrolling speed
    Lines := LinesPerNotch(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType)

    Loop %Lines%
    {
        SendMessage, ctrlMsg, wParam, 0,, ahk_id %ControlClass1%
        If(ControlClass1 != ControlClass2)
            SendMessage, ctrlMsg, wParam, 0,, ahk_id %ControlClass2%
    }
}

Menu_Show( hMenu, hWnd=0, mX="", mY="", Flags=0x1 ) {
 ; http://ahkscript.org/boards/viewtopic.php?p=7088#p7088
 ; Flags: TPM_RECURSE := 0x1, TPM_RETURNCMD := 0x100, TPM_NONOTIFY := 0x80
 VarSetCapacity( POINT, 8, 0 ), DllCall( "GetCursorPos", UInt,&Point )
 mX := ( mX <> "" ) ? mX : NumGet( Point,0 )
 mY := ( mY <> "" ) ? mY : NumGet( Point,4 )
Return DllCall( "TrackPopupMenu", UInt,hMenu, UInt,Flags ; TrackPopupMenu()  goo.gl/CosNig
               , Int,mX, Int,mY, UInt,0, UInt,hWnd ? hWnd : WinActive("A"), UInt,0 )

/*
..but the catch is: To get handle ( hMenu ) for a Menuname, it has to be attached to a MenuBar.
There already is a function from lexikos, which does this: MI_GetMenuHandle(), and can be used as follows:


Code: [Alles auswählen] [Download] (Script.ahk)GeSHi © Codebox Plus

hViewmenu := MI_GetMenuHandle( "view" ) ; Get it from: http://www.autohotkey.net/~Lexikos/lib/MI.ahk
...
...
GuiContextMenu:
 Menu_Show( hViewMenu )
Return
*/
}

MoveTogether(wParam, lParam, _, hWnd) { ; Move Gui's together - using DeferWindowPos
;-------------------------------------------------------------------------------
    static init := OnMessage(0x00A1, "MoveTogether") ; WM_NCLBUTTONDOWN
    global Handles

    IfNotEqual, wParam, 2, Return ; HTCAPTION (only part of title bar)
    M_old_X := lParam & 0xFFFF, M_old_Y := lParam >> 16 & 0xFFFF
    WinActivate, ahk_id %hWnd%

    For each, Handle in Handles
        WinGetPos, W%A_Index%_old_X
                ,  W%A_Index%_old_Y
                ,  W%A_Index%_W
                ,  W%A_Index%_H
                ,  ahk_id %Handle%

    While GetKeyState("LButton") {
        MouseGetPos, M_new_X, M_new_Y

        ; get dX and dY from mouse, remember X and Y for next iteration
        dX := M_new_X - M_old_X, M_old_X := M_new_X
    ,   dY := M_new_Y - M_old_Y, M_old_Y := M_new_Y

        ; calc new X and Y for W[i], updating old X and Y
        Loop, % Handles.Length()
            W%A_Index%_new_X := W%A_Index%_old_X += dX
        ,   W%A_Index%_new_Y := W%A_Index%_old_Y += dY

        ; DeferWindowPos cycle
        hDWP := DllCall("BeginDeferWindowPos", "Int", Handles.Length(), "Ptr")
        For each, Handle in Handles
            hDWP := DllCall("DeferWindowPos", "Ptr", hDWP
                , "Ptr", Handle, "Ptr", 0
                , "Int", W%A_Index%_new_X
                , "Int", W%A_Index%_new_Y
                , "Int", W%A_Index%_W
                , "Int", W%A_Index%_H
                , "UInt", 0x0214, "Ptr")
        DllCall("EndDeferWindowPos", "Ptr", hDWP)
    }
}

MoveTogether(wParam, lParam:="", _:="", hWnd:="") { ; V2 -
;-------------------------------------------------------------------------------
   static init := OnMessage(0x00A1, "MoveTogether") ; WM_NCLBUTTONDOWN
   static Handles
   if isObject(wParam)
     return Handles := wParam
   IfNotEqual, wParam, 2, Return ; HTCAPTION (only part of title bar)
   ;---------------------------------------------
   Prev_CoordModeMouse := A_CoordModeMouse
   CoordMode, Mouse, Screen    ; for MouseGetPos
   ;---------------------------------------------
   M_old_X := lParam & 0xFFFF, M_old_Y := lParam >> 16 & 0xFFFF
   WinActivate, ahk_id %hWnd%

   Win := {}
   For each, Handle in Handles
   {  WinGetPos, X, Y, W, H, ahk_id %Handle%
      Win[Handle] := {X:X,Y:Y,W:W,H:H}
   }

   While GetKeyState("LButton", "P") {
      MouseGetPos, M_new_X, M_new_Y

      ; get dX and dY from mouse, remember X and Y for next iteration
      dX := M_new_X - M_old_X, M_old_X := M_new_X
    , dY := M_new_Y - M_old_Y, M_old_Y := M_new_Y

      ; DeferWindowPos cycle
      if (dX || dY) {
         if GetKeyState("Shift", "P")
            WinMove, ahk_id %hWnd%, , Win[hWnd].X += dX, Win[hWnd].Y += dY
         else {
            hDWP := DllCall("BeginDeferWindowPos", "Int", Handles.Length(), "Ptr")
            For each, Handle in Handles
               hDWP := DllCall("DeferWindowPos", "Ptr", hDWP
                    , "Ptr", Handle, "Ptr", 0
                    , "Int", Win[Handle].X += dX
                    , "Int", Win[Handle].Y += dY
                    , "Int", Win[Handle].W
                    , "Int", Win[Handle].H
                    , "UInt", 0x0214, "Ptr")
            DllCall("EndDeferWindowPos", "Ptr", hDWP)
         }
      }
   }
   CoordMode, Mouse, %Prev_CoordModeMouse%
}


;}
;-----------------------------------------------END OF GUI SECTION------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Filesystem
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
InvokeVerb(path, menu, validate=True) {
    ;by A_Samurai
    ;v 1.0.1 http://sites.google.com/site/ahkref/custom-functions/invokeverb
    objShell := ComObjCreate("Shell.Application")
    if InStr(FileExist(path), "D") || InStr(path, "::{") {
        objFolder := objShell.NameSpace(path)
        objFolderItem := objFolder.Self
    } else {
        SplitPath, path, name, dir
        objFolder := objShell.NameSpace(dir)
        objFolderItem := objFolder.ParseName(name)
    }
    if validate {
        colVerbs := objFolderItem.Verbs
        loop % colVerbs.Count {
            verb := colVerbs.Item(A_Index - 1)
            retMenu := verb.name
            StringReplace, retMenu, retMenu, &
            if (retMenu = menu) {
                verb.DoIt
                Return True
            }
        }
        Return False
    } else
        objFolderItem.InvokeVerbEx(Menu)
}

Function_Eject(Drive){
	Try
	{

		hVolume := DllCall("CreateFile"
		    , Str, "\\.\" . Drive
		    , UInt, 0x80000000 | 0x40000000  ; GENERIC_READ | GENERIC_WRITE
		    , UInt, 0x1 | 0x2  ; FILE_SHARE_READ | FILE_SHARE_WRITE
		    , UInt, 0
		    , UInt, 0x3  ; OPEN_EXISTING
		    , UInt, 0, UInt, 0)
		if hVolume <> -1
		{
		    DllCall("DeviceIoControl"
		        , UInt, hVolume
		        , UInt, 0x2D4808   ; IOCTL_STORAGE_EJECT_MEDIA
		        , UInt, 0, UInt, 0, UInt, 0, UInt, 0
		        , UIntP, dwBytesReturned  ; Unused.
		        , UInt, 0)
		    DllCall("CloseHandle", UInt, hVolume)

		}

		Return 1
	}
	Catch
	{

		Return 0
	}
}

FileGetDetail(FilePath, Index) { ; Bestimmte Dateieigenschaft per Index abrufen
   Static MaxDetails := 350
   SplitPath, FilePath, FileName , FileDir
   If (FileDir = "")
      FileDir := A_WorkingDir
   Shell := ComObjCreate("Shell.Application")
   Folder := Shell.NameSpace(FileDir)
   Item := Folder.ParseName(FileName)
   Return Folder.GetDetailsOf(Item, Index)
}

FileGetDetails(FilePath) { ; Array der konkreten Dateieigenschaften erstellen
   Static MaxDetails := 350
   Shell := ComObjCreate("Shell.Application")
   Details := []
   SplitPath, FilePath, FileName , FileDir
   If (FileDir = "")
      FileDir := A_WorkingDir
   Folder := Shell.NameSpace(FileDir)
   Item := Folder.ParseName(FileName)
   Loop, %MaxDetails% {
      If (Value := Folder.GetDetailsOf(Item, A_Index - 1))
         Details[A_Index - 1] := [Folder.GetDetailsOf(0, A_Index - 1), Value]
   }
   Return Details
}

GetDetails() { ; Array der möglichen Dateieigenschaften erstellen
   Static MaxDetails := 350
   Shell := ComObjCreate("Shell.Application")
   Details := []
   Folder := Shell.NameSpace(A_ScriptDir)
   Loop, %MaxDetails% {
      If (Value := Folder.GetDetailsOf(0, A_Index - 1)) {
         Details[A_Index - 1] := Value
         Details[Value] := A_Index - 1
      }
   }
   Return Details
}

Start(Target, Minimal = false, Title = "") { ; Programme oder Scripte einfacher starten
   cPID = -1
   if Minimal
      Run %ComSpec% /c "%Target%", A_WorkingDir, Min UseErrorLevel, cPID
   else
      Run %ComSpec% /c "%Target%", A_WorkingDir, UseErrorLevel, cPID
   if ErrorLevel = 0
   {
      if (Title <> "")
      {
         WinWait ahk_pid %cPID%,,,2
         WinSetTitle, %Title%
      }
      return, 0
   }
   else
      return, -1
}

IsFileEqual(filename1, filename2) { ;Returns whether or not two files are equal
    ;TODO make this work for big files, too (this version reads it all into memory first)
   FileRead, file1, %filename1%
   FileRead, file2, %filename2%

   return file1==file2
}

WatchDirectory(p*) {  ;Watches a directory/file for file changes

    ;By HotKeyIt
    ;Docs: http://www.autohotkey.com/forum/viewtopic.php?p=398565#398565

    global _Struct
   ;Structures
   static FILE_NOTIFY_INFORMATION:="DWORD NextEntryOffset,DWORD Action,DWORD FileNameLength,WCHAR FileName[1]"
   static OVERLAPPED:="ULONG_PTR Internal,ULONG_PTR InternalHigh,{struct{DWORD offset,DWORD offsetHigh},PVOID Pointer},HANDLE hEvent"
   ;Variables
   static running,sizeof_FNI=65536,WatchDirectory:=RegisterCallback("WatchDirectory","F",0,0) ;,nReadLen:=VarSetCapacity(nReadLen,8)
   static timer,ReportToFunction,LP,nReadLen:=VarSetCapacity(LP,(260)*(A_PtrSize/2),0)
   static @:=Object(),reconnect:=Object(),#:=Object(),DirEvents,StringToRegEx="\\\|.\.|+\+|[\[|{\{|(\(|)\)|^\^|$\$|?\.?|*.*"
   ;ReadDirectoryChanges related
   static FILE_NOTIFY_CHANGE_FILE_NAME=0x1,FILE_NOTIFY_CHANGE_DIR_NAME=0x2,FILE_NOTIFY_CHANGE_ATTRIBUTES=0x4
         ,FILE_NOTIFY_CHANGE_SIZE=0x8,FILE_NOTIFY_CHANGE_LAST_WRITE=0x10,FILE_NOTIFY_CHANGE_CREATION=0x40
         ,FILE_NOTIFY_CHANGE_SECURITY=0x100
   static FILE_ACTION_ADDED=1,FILE_ACTION_REMOVED=2,FILE_ACTION_MODIFIED=3
         ,FILE_ACTION_RENAMED_OLD_NAME=4,FILE_ACTION_RENAMED_NEW_NAME=5
   static OPEN_EXISTING=3,FILE_FLAG_BACKUP_SEMANTICS=0x2000000,FILE_FLAG_OVERLAPPED=0x40000000
         ,FILE_SHARE_DELETE=4,FILE_SHARE_WRITE=2,FILE_SHARE_READ=1,FILE_LIST_DIRECTORY=1
   If p.MaxIndex(){
      If (p.MaxIndex()=1 && p.1=""){
         for i,folder in #
            DllCall("CloseHandle","Uint",@[folder].hD),DllCall("CloseHandle","Uint",@[folder].O.hEvent)
            ,@.Remove(folder)
         #:=Object()
         DirEvents:=new _Struct("HANDLE[1000]")
         DllCall("KillTimer","Uint",0,"Uint",timer)
         timer=
         Return 0
      } else {
         if p.2
            ReportToFunction:=p.2
         If !IsFunc(ReportToFunction)
            Return -1 ;DllCall("MessageBox","Uint",0,"Str","Function " ReportToFunction " does not exist","Str","Error Missing Function","UInt",0)
         RegExMatch(p.1,"^([^/\*\?<>\|""]+)(\*)?(\|.+)?$",dir)
         if (SubStr(dir1,0)="\")
            StringTrimRight,dir1,dir1,1
         StringTrimLeft,dir3,dir3,1
         If (p.MaxIndex()=2 && p.2=""){
            for i,folder in #
               If (dir1=SubStr(folder,1,StrLen(folder)-1))
                  Return 0 ,DirEvents[i]:=DirEvents[#.MaxIndex()],DirEvents[#.MaxIndex()]:=0
                           @.Remove(folder),#[i]:=#[#.MaxIndex()],#.Remove(i)
            Return 0
         }
      }
      if !InStr(FileExist(dir1),"D")
         Return -1 ;DllCall("MessageBox","Uint",0,"Str","Folder " dir1 " does not exist","Str","Error Missing File","UInt",0)
      for i,folder in #
      {
         If (dir1=SubStr(folder,1,StrLen(folder)-1) || (InStr(dir1,folder) && @[folder].sD))
               Return 0
         else if (InStr(SubStr(folder,1,StrLen(folder)-1),dir1 "\") && dir2){ ;replace watch
            DllCall("CloseHandle","Uint",@[folder].hD),DllCall("CloseHandle","Uint",@[folder].O.hEvent),reset:=i
         }
      }
      LP:=SubStr(LP,1,DllCall("GetLongPathName","Str",dir1,"Uint",&LP,"Uint",VarSetCapacity(LP))) "\"
      If !(reset && @[reset]:=LP)
         #.Insert(LP)
      @[LP,"dir"]:=LP
      @[LP].hD:=DllCall("CreateFile","Str",StrLen(LP)=3?SubStr(LP,1,2):LP,"UInt",0x1,"UInt",0x1|0x2|0x4
                  ,"UInt",0,"UInt",0x3,"UInt",0x2000000|0x40000000,"UInt",0)
      @[LP].sD:=(dir2=""?0:1)

      Loop,Parse,StringToRegEx,|
         StringReplace,dir3,dir3,% SubStr(A_LoopField,1,1),% SubStr(A_LoopField,2),A
      StringReplace,dir3,dir3,%A_Space%,\s,A
      Loop,Parse,dir3,|
      {
         If A_Index=1
            dir3=
         pre:=(SubStr(A_LoopField,1,2)="\\"?2:0)
         succ:=(SubStr(A_LoopField,-1)="\\"?2:0)
         dir3.=(dir3?"|":"") (pre?"\\\K":"")
               . SubStr(A_LoopField,1+pre,StrLen(A_LoopField)-pre-succ)
               . ((!succ && !InStr(SubStr(A_LoopField,1+pre,StrLen(A_LoopField)-pre-succ),"\"))?"[^\\]*$":"") (succ?"$":"")
      }
      @[LP].FLT:="i)" dir3
      @[LP].FUNC:=ReportToFunction
      @[LP].CNG:=(p.3?p.3:(0x1|0x2|0x4|0x8|0x10|0x40|0x100))
      If !reset {
         @[LP].SetCapacity("pFNI",sizeof_FNI)
         @[LP].FNI:=new _Struct(FILE_NOTIFY_INFORMATION,@[LP].GetAddress("pFNI"))
         @[LP].O:=new _Struct(OVERLAPPED)
      }
      @[LP].O.hEvent:=DllCall("CreateEvent","Uint",0,"Int",1,"Int",0,"UInt",0)
      If (!DirEvents)
         DirEvents:=new _Struct("HANDLE[1000]")
      DirEvents[reset?reset:#.MaxIndex()]:=@[LP].O.hEvent
      DllCall("ReadDirectoryChangesW","UInt",@[LP].hD,"UInt",@[LP].FNI[],"UInt",sizeof_FNI
               ,"Int",@[LP].sD,"UInt",@[LP].CNG,"UInt",0,"UInt",@[LP].O[],"UInt",0)
      Return timer:=DllCall("SetTimer","Uint",0,"UInt",timer,"Uint",50,"UInt",WatchDirectory)
   } else {
      Sleep, 0
      for LP in reconnect
      {
         If (FileExist(@[LP].dir) && reconnect.Remove(LP)){
            DllCall("CloseHandle","Uint",@[LP].hD)
            @[LP].hD:=DllCall("CreateFile","Str",StrLen(@[LP].dir)=3?SubStr(@[LP].dir,1,2):@[LP].dir,"UInt",0x1,"UInt",0x1|0x2|0x4
                  ,"UInt",0,"UInt",0x3,"UInt",0x2000000|0x40000000,"UInt",0)
            DllCall("ResetEvent","UInt",@[LP].O.hEvent)
            DllCall("ReadDirectoryChangesW","UInt",@[LP].hD,"UInt",@[LP].FNI[],"UInt",sizeof_FNI
               ,"Int",@[LP].sD,"UInt",@[LP].CNG,"UInt",0,"UInt",@[LP].O[],"UInt",0)
         }
      }
      if !( (r:=DllCall("MsgWaitForMultipleObjectsEx","UInt",#.MaxIndex()
               ,"UInt",DirEvents[],"UInt",0,"UInt",0x4FF,"UInt",6))>=0
               && r<#.MaxIndex() ){
         return
      }
      DllCall("KillTimer", UInt,0, UInt,timer)
      LP:=#[r+1],DllCall("GetOverlappedResult","UInt",@[LP].hD,"UInt",@[LP].O[],"UIntP",nReadLen,"Int",1)
      If (A_LastError=64){ ; ERROR_NETNAME_DELETED - The specified network name is no longer available.
         If !FileExist(@[LP].dir) ; If folder does not exist add to reconnect routine
            reconnect.Insert(LP,LP)
      } else
         Loop {
            FNI:=A_Index>1?(new _Struct(FILE_NOTIFY_INFORMATION,FNI[]+FNI.NextEntryOffset)):(new _Struct(FILE_NOTIFY_INFORMATION,@[LP].FNI[]))
            If (FNI.Action < 0x6){
               FileName:=@[LP].dir . StrGet(FNI.FileName[""],FNI.FileNameLength/2,"UTF-16")
               If (FNI.Action=FILE_ACTION_RENAMED_OLD_NAME)
                     FileFromOptional:=FileName
               If (@[LP].FLT="" || RegExMatch(FileName,@[LP].FLT) || FileFrom)
                  If (FNI.Action=FILE_ACTION_ADDED){
                     FileTo:=FileName
                  } else If (FNI.Action=FILE_ACTION_REMOVED){
                     FileFrom:=FileName
                  } else If (FNI.Action=FILE_ACTION_MODIFIED){
                     FileFrom:=FileTo:=FileName
                  } else If (FNI.Action=FILE_ACTION_RENAMED_OLD_NAME){
                     FileFrom:=FileName
                  } else If (FNI.Action=FILE_ACTION_RENAMED_NEW_NAME){
                     FileTo:=FileName
                  }
          If (FNI.Action != 4 && (FileTo . FileFrom) !="")
                  @[LP].Func(FileFrom=""?FileFromOptional:FileFrom,FileTo)
            }
         } Until (!FNI.NextEntryOffset || ((FNI[]+FNI.NextEntryOffset) > (@[LP].FNI[]+sizeof_FNI-12)))
      DllCall("ResetEvent","UInt",@[LP].O.hEvent)
      DllCall("ReadDirectoryChangesW","UInt",@[LP].hD,"UInt",@[LP].FNI[],"UInt",sizeof_FNI
               ,"Int",@[LP].sD,"UInt",@[LP].CNG,"UInt",0,"UInt",@[LP].O[],"UInt",0)
      timer:=DllCall("SetTimer","Uint",0,"UInt",timer,"Uint",50,"UInt",WatchDirectory)
      Return
   }
   Return
}

SelectFolder() {		;eine andere FileSelect function von just me
   ; Common Item Dialog -> msdn.microsoft.com/en-us/library/bb776913%28v=vs.85%29.aspx
   ; IFileDialog        -> msdn.microsoft.com/en-us/library/bb775966%28v=vs.85%29.aspx
   ; IShellItem         -> msdn.microsoft.com/en-us/library/bb761140%28v=vs.85%29.aspx
   Static OsVersion := DllCall("GetVersion", "UChar")
   Static Show := A_PtrSize * 3
   Static SetOptions := A_PtrSize * 9
   Static GetResult := A_PtrSize * 20
   SelectedFolder := ""
   If (OsVersion < 6) { ; IFileDialog requires Win Vista+
      FileSelectFolder, SelectedFolder
      Return SelectedFolder
   }
   If !(FileDialog := ComObjCreate("{DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7}", "{42f85136-db7e-439c-85f1-e4075d135fc8}"))
      Return ""
   VTBL := NumGet(FileDialog + 0, "UPtr")
   DllCall(NumGet(VTBL + SetOptions, "UPtr"), "Ptr", FileDialog, "UInt", 0x00000028, "UInt") ; FOS_NOCHANGEDIR | FOS_PICKFOLDERS
   If !DllCall(NumGet(VTBL + Show, "UPtr"), "Ptr", FileDialog, "Ptr", 0, "UInt") {
      If !DllCall(NumGet(VTBL + GetResult, "UPtr"), "Ptr", FileDialog, "PtrP", ShellItem, "UInt") {
         GetDisplayName := NumGet(NumGet(ShellItem + 0, "UPtr"), A_PtrSize * 5, "UPtr")
         If !DllCall(GetDisplayName, "Ptr", ShellItem, "UInt", 0x80028000, "PtrP", StrPtr) ; SIGDN_DESKTOPABSOLUTEPARSING
            SelectedFolder := StrGet(StrPtr, "UTF-16"), DllCall("Ole32.dll\CoTaskMemFree", "Ptr", StrPtr)
         ObjRelease(ShellItem)
      }
   }
   ObjRelease(FileDialog)
   Return SelectedFolder
}

SelectFolderEx(StartingFolder := "", Prompt := "", OwnerHwnd := 0, OkBtnLabel := "") {

; ==================================================================================================================================
; Shows a dialog to select a folder.
; Depending on the OS version the function will use either the built-in FileSelectFolder command (XP and previous)
; or the Common Item Dialog (Vista and later).
; Parameter:
;     StartingFolder -  the full path of a folder which will be preselected.
;     Prompt         -  a text used as window title (Common Item Dialog) or as text displayed withing the dialog.
;     ----------------  Common Item Dialog only:
;     OwnerHwnd      -  HWND of the Gui which owns the dialog. If you pass a valid HWND the dialog will become modal.
;     BtnLabel       -  a text to be used as caption for the apply button.
;  Return values:
;     On success the function returns the full path of selected folder; otherwise it returns an empty string.
; MSDN:
;     Common Item Dialog -> msdn.microsoft.com/en-us/library/bb776913%28v=vs.85%29.aspx
;     IFileDialog        -> msdn.microsoft.com/en-us/library/bb775966%28v=vs.85%29.aspx
;     IShellItem         -> msdn.microsoft.com/en-us/library/bb761140%28v=vs.85%29.aspx
; ==================================================================================================================================


   Static OsVersion := DllCall("GetVersion", "UChar")
        , IID_IShellItem := 0
        , InitIID := VarSetCapacity(IID_IShellItem, 16, 0)
                  & DllCall("Ole32.dll\IIDFromString", "WStr", "{43826d1e-e718-42ee-bc55-a1e261c37bfe}", "Ptr", &IID_IShellItem)
        , Show := A_PtrSize * 3
        , SetOptions := A_PtrSize * 9
        , SetFolder := A_PtrSize * 12
        , SetTitle := A_PtrSize * 17
        , SetOkButtonLabel := A_PtrSize * 18
        , GetResult := A_PtrSize * 20
   SelectedFolder := ""
   If (OsVersion < 6) { ; IFileDialog requires Win Vista+, so revert to FileSelectFolder
      FileSelectFolder, SelectedFolder, *%StartingFolder%, 3, %Prompt%
      Return SelectedFolder
   }
   OwnerHwnd := DllCall("IsWindow", "Ptr", OwnerHwnd, "UInt") ? OwnerHwnd : 0
   If !(FileDialog := ComObjCreate("{DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7}", "{42f85136-db7e-439c-85f1-e4075d135fc8}"))
      Return ""
   VTBL := NumGet(FileDialog + 0, "UPtr")
   ; FOS_CREATEPROMPT | FOS_NOCHANGEDIR | FOS_PICKFOLDERS
   DllCall(NumGet(VTBL + SetOptions, "UPtr"), "Ptr", FileDialog, "UInt", 0x00002028, "UInt")
   If (StartingFolder <> "")
      If !DllCall("Shell32.dll\SHCreateItemFromParsingName", "WStr", StartingFolder, "Ptr", 0, "Ptr", &IID_IShellItem, "PtrP", FolderItem)
         DllCall(NumGet(VTBL + SetFolder, "UPtr"), "Ptr", FileDialog, "Ptr", FolderItem, "UInt")
   If (Prompt <> "")
      DllCall(NumGet(VTBL + SetTitle, "UPtr"), "Ptr", FileDialog, "WStr", Prompt, "UInt")
   If (OkBtnLabel <> "")
      DllCall(NumGet(VTBL + SetOkButtonLabel, "UPtr"), "Ptr", FileDialog, "WStr", OkBtnLabel, "UInt")
   If !DllCall(NumGet(VTBL + Show, "UPtr"), "Ptr", FileDialog, "Ptr", OwnerHwnd, "UInt") {
      If !DllCall(NumGet(VTBL + GetResult, "UPtr"), "Ptr", FileDialog, "PtrP", ShellItem, "UInt") {
         GetDisplayName := NumGet(NumGet(ShellItem + 0, "UPtr"), A_PtrSize * 5, "UPtr")
         If !DllCall(GetDisplayName, "Ptr", ShellItem, "UInt", 0x80028000, "PtrP", StrPtr) ; SIGDN_DESKTOPABSOLUTEPARSING
            SelectedFolder := StrGet(StrPtr, "UTF-16"), DllCall("Ole32.dll\CoTaskMemFree", "Ptr", StrPtr)
         ObjRelease(ShellItem)
   }  }
   If (FolderItem)
      ObjRelease(FolderItem)
   ObjRelease(FileDialog)
   Return SelectedFolder
}

;}

;{Files - search inside
listfunc(file){
	fileread, z, % file
	StringReplace, z, z, `r, , All			; important
	z := RegExReplace(z, "mU)""[^`n]*""", "") ; strings
	z := RegExReplace(z, "iU)/\*.*\*/", "") ; block comments
	z := RegExReplace(z, "m);[^`n]*", "")  ; single line comments
	p:=1 , z := "`n" z
	while q:=RegExMatch(z, "iU)`n[^ `t`n,;``\(\):=\?]+\([^`n]*\)[ `t`n]*{", o, p)
		lst .= Substr( RegExReplace(o, "\(.*", ""), 2) "`n"
		, p := q+Strlen(o)-1

	Sort, lst
	return lst
}

;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Hooks-Messaging
OnMessageEx(MsgNumber, params*) {
    ;version 1.0.2 by A_Samurai http://sites.google.com/site/ahkref/custom-functions/onmessageex
    Static Functions := {}

    ;determine whether this is an on-message call
    FunctionName := params.1, OnMessage := True, DHW := A_DetectHiddenWindows
    DetectHiddenWindows, ON
    if ObjMaxIndex(params) <> 3            ;if the number of optional parameters are not three
        OnMessage := False
    else if FunctionName not between 0 and 4294967295    ;if the second parameter is not between 0 to 4294967295
        OnMessage := False
    else if !WinExist("ahk_id " params.3)    ;if the third parameter is not an existing Hwnd of a window/control
        OnMessage := False
    DetectHiddenWindows, % DHW

    if !OnMessage {
    ;if the function is manually called,
        Priority := params.2 ? params.2 : (params.2 = 0) ? 0 : 1
        If FunctionName    {
            ;if FunctionName is specified, it means to register it or if the priority is set to 0, remove it

            ;prepare for the function stack object
            Functions[MsgNumber] := Functions[MsgNumber] ? Functions[MsgNumber] : []

            ;check if there is already the same function in the stack object
            For index, oFunction in Functions[MsgNumber] {
                if (oFunction.Func = FunctionName) {
                    oRemoved := ObjRemove(Functions[MsgNumber], Index)
                    Break
                }
            }
            ;if the priority is 0, it means to remvoe the function
            if (Priority = 0)
                Return oRemoved.Func

            ;check if there is a function already registered for this message
            if (PrevFunc := OnMessage(MsgNumber)) && (PrevFunc <> A_ThisFunc) {
                ;this means there is one, so add this function to the stack object
                ObjInsert(Functions[MsgNumber], {Func: PrevFunc, Priority: 1})
            }

            ;find out the priority in each registered function and insert it before the element of the same priority
            IndexToInsert := 1
            For Index, oFunction in Functions[MsgNumber] {
                IndexToInsert := Index
            } Until (oFunction.Priority = Priority)

            ;retrieve the function name in the first priority for the return value
            FirstFunc := Functions[MsgNumber][ObjMinIndex(Functions[MsgNumber])].Func

            ;insert the given function in the function stack object
            if IsObject(FunctionName) {
                ;an object is passed for the second parameter
                ThisObj := Object(FunctionName.1), ThisMethod := FunctionName.2, AutoRemove := ObjHasKey(FunctionName, 3) ? FunctionName.3 : False
                If IsFunc(ThisObj[ThisMethod])    ;chceck if the method exists
                    ObjInsert(Functions[MsgNumber], IndexToInsert, {Func: FunctionName.2, Priority: Priority, ObjectAddress: FunctionName.1, AutoRemove: AutoRemove})
                else         ;if the passed function name is not a function, return false
                    return False
            } else {
                if IsFunc(FunctionName)    ;chceck if the function exists
                    ObjInsert(Functions[MsgNumber], IndexToInsert, {Func: FunctionName, Priority: Priority})
                else        ;if the passed function name is not a function, return false
                    return False
            }

            ;register it
            if (PrevFunc <> A_ThisFunc)
                OnMessage(MsgNumber, A_ThisFunc)

            Return FirstFunc
        } Else if ObjHasKey(params, 1) && (FunctionName = "") {
            ;if FunctionName is explicitly empty, remove the function and return its name

            ;remove the lowest priority function (the last element) in the object of the specified message.
            oRemoved := ObjRemove(Functions[MsgNumber], ObjMaxIndex(Functions[MsgNumber]))

            ;if there are no more registered functions, remove the registration of this function for this message
            if !ObjMaxIndex(Functions[MsgNumber])
                OnMessage(MsgNumber, "")

            Return oRemoved.Func
        } Else     ;return the registered function of the lowest priority for this message
            Return Functions[MsgNumber][ObjMaxIndex(Functions[MsgNumber])].Func
    } Else {
    ;if this is an on-message call,
        wParam := MsgNumber, lParam := params.1, msg := params.2, Hwnd := params.3
        For Index, Function in Functions[msg] {
            ThisFunc := Function.Func
            if ObjHasKey(Function, "ObjectAddress") {
                ;if it is an object method
                ThisObj := Object(Function.ObjectAddress)
                ThisObj[ThisFunc](wParam, lParam, msg, Hwnd)
                if Function.AutoRemove {        ;this means if the method no longer exists, remove it
                    If !IsFunc(ThisFunc) {
                        ObjRemove(Functions[MsgNumber], ThisFunc)

                        ;if there are no more registered functions, remove the registration of this function for this message
                        if !ObjMaxIndex(Functions[MsgNumber])
                            OnMessage(MsgNumber, "")
                    }
                }
            } else     ;if it is a function
                %ThisFunc%(wParam, lParam, msg, Hwnd)
        }
    }
}

ReceiveData(wParam, lParam) {
; By means of OnMessage(), this function has been set up to be called automatically whenever new data
; arrives on the connection.

   global ShowRecieved
   global ReceivedData

   Gui, Submit, NoHide
   socket := wParam

    ReceivedDataSize = 4096 ; Large in case a lot of data gets buffered due to delay in processing previous data.
    Loop  ; This loop solves the issue of the notification message being discarded due to thread-already-running.
    {
        VarSetCapacity(ReceivedData, ReceivedDataSize, 0)  ; 0 for last param terminates string for use with recv().
        ReceivedDataLength := DllCall("Ws2_32\recv", "UInt", socket, "Str", ReceivedData, "Int", ReceivedDataSize, "Int", 0)
        if ReceivedDataLength = 0  ; The connection was gracefully closed,
            ExitApp  ; The OnExit routine will call WSACleanup() for us.
        if ReceivedDataLength = -1
        {
            WinsockError := DllCall("Ws2_32\WSAGetLastError")
            if WinsockError = 10035  ; WSAEWOULDBLOCK, which means "no more data to be read".
                return 1
            if WinsockError <> 10054 ; WSAECONNRESET, which happens when Network closes via system shutdown/logoff.
                ; Since it's an unexpected error, report it.  Also exit to avoid infinite loop.
                MsgBox % "recv() indicated Winsock error " . WinsockError
            ExitApp  ; The OnExit routine will call WSACleanup() for us.
        }
        ; Otherwise, process the data received.
        ; Msgbox %ReceivedData%
        Loop, parse, ReceivedData, `n, `r
        {
           	ReceivedData=%A_LoopField%
           	if (ReceivedData!="")
           	{
				GoSub ParseData
				GoSub UseData
			}
        }
	}
    return 1  ; Tell the program that no further processing of this message is needed.
}

HDrop(fnames,x=0,y=0) {	;Drop files to another app

			/*
		Return a handle to a structure describing files to be droped.
		Use it with PostMessage to send WM_DROPFILES messages to windows.
		fnames is a list of paths delimited by `n or `r`n
		x and y are the coordinates where files are droped in the window.
		Eg. :
		; Open autoexec.bat in an existing Notepad window.
		PostMessage, 0x233, HDrop("C:\autoexec.bat"), 0,, ahk_class Notepad
		PostMessage, 0x233, HDrop(A_MyDocuments), 0,, ahk_class MSPaintApp
		*/
	fns:=RegExReplace(fnames,"\n$")
   fns:=RegExReplace(fns,"^\n")
   hDrop:=DllCall("GlobalAlloc","UInt",0x42,"UInt",20+StrLen(fns)+2)
   p:=DllCall("GlobalLock","UInt",hDrop)
   NumPut(20, p+0)  ;offset
   NumPut(x,  p+4)  ;pt.x
   NumPut(y,  p+8)  ;pt.y
   NumPut(0,  p+12) ;fNC
   NumPut(0,  p+16) ;fWide
   p2:=p+20
   Loop,Parse,fns,`n,`r
   {
      DllCall("RtlMoveMemory","UInt",p2,"Str",A_LoopField,"UInt",StrLen(A_LoopField))
      p2+=StrLen(A_LoopField)+1
   }
   DllCall("GlobalUnlock","UInt",hDrop)
   Return hDrop
}

WM_MOVE(wParam, lParam, nMsg, hWnd) { ;UpdateLayeredWindow
   If   A_Gui
   &&   DllCall("UpdateLayeredWindow", "Uint", hWnd, "Uint", 0, "int64P", (lParam<<48>>48)&0xFFFFFFFF|(lParam&0xFFFF0000)<<32>>16, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0)
   WinGetPos, GuiX, GuiY,,, WinTitle
   if (GuiY)
    Gui, 2: Show, x%GuiX% y%GuiY%
   else
    Gui, 2: Show, Center
   Return   0
}

OnMessage(0x46, "WM_WINDOWPOSCHANGING")
WM_WINDOWPOSCHANGING(wParam, lParam) {
    if (A_Gui = 1 && !(NumGet(lParam+24) & 0x2)) ; SWP_NOMOVE=0x2
    {
        x := NumGet(lParam+8),  y := NumGet(lParam+12)
        x += 10,  y += 30
        Gui, 2:Show, X%x% Y%y% NA
    }
}
;or
Move:
PostMessage, 0xA1, 2,,, A
Return
WM_WINDOWPOSCHANGING(wParam, lParam) {
	global

	If (A_Gui = 1 && !(NumGet(lParam+24) & 0x2))
	{
		x := NumGet(lParam+8),  y := NumGet(lParam+12)

		Result := DllCall("SetWindowPos", "UInt", Gui2, "UInt", Gui1, "Int", x-50, "Int", y-50, "Int", "", "Int", "", "Int", 0x01)
	}
	SetTimer, OnTop, 10

	Result := DllCall("SetWindowPos", "UInt", Gui1, "UInt", Gui2, "Int", "", "Int", "", "Int", "", "Int", "", "Int", 0x03)
	;Tooltip, %Result%
	Return
}

CallNextHookEx(nCode, wParam, lParam, hHook = 0) {
   Return DllCall("CallNextHookEx", "Uint", hHook, "int", nCode, "Uint", wParam, "Uint", lParam)
}

;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Internet - Functions
DownloadFile(url, file, info="") {
    static vt
    if !VarSetCapacity(vt)
    {
        VarSetCapacity(vt, A_PtrSize*11), nPar := "31132253353"
        Loop Parse, nPar
            NumPut(RegisterCallback("DL_Progress", "F", A_LoopField, A_Index-1), vt, A_PtrSize*(A_Index-1))
    }
    global _cu, descr
    SplitPath file, dFile
    SysGet m, MonitorWorkArea, 1
    y := mBottom-62-2, x := mRight-330-2, VarSetCapacity(_cu, 100), VarSetCapacity(tn, 520)
    , DllCall("shlwapi\PathCompactPathEx", "str", _cu, "str", url, "uint", 50, "uint", 0)
    descr := (info = "") ? _cu : info . ": " _cu
    Progress Hide CWFAFAF7 CT000020 CB445566 x%x% y%y% w330 h62 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11,, %descr%, AutoHotkeyProgress, Tahoma
    if (0 = DllCall("urlmon\URLDownloadToCacheFile", "ptr", 0, "str", url, "str", tn, "uint", 260, "uint", 0x10, "ptr*", &vt))
        FileCopy %tn%, %file%
    else
        ErrorLevel := -1
    Progress Off
    return ErrorLevel
}

NewLinkMsg(VideoSite, VideoName = "") {
   global lng

   TmpMsg := % lng.MSG_NEW_LINK_FOUND . VideoSite . "`r`n"
   if (VideoName <> "")
      TmpMsg := TmpMsg . lng.MSG_NEW_LINK_FILENAME . VideoName . "`r`n`r`n"

	MsgBox 36, %ProgramName%, % TmpMsg lng.MSG_NEW_LINK_ASK, 50
	IfMsgBox Yes
		return, 0
	else
		return, -1
}

;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Math functions
Min(x, y) {
  return x < y ? x : y
}

Max(x, y) {
  return x > y ? x : y
}


;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Objekt Functions
ObjMerge(OrigObj, MergingObj, MergeBase=True) {
    If !IsObject(OrigObj) || !IsObject(MergingObj)
        Return False
    For k, v in MergingObj
        ObjInsert(OrigObj, k, v)
    if MergeBase && IsObject(MergingObj.base) {
        If !IsObject(OrigObj.base)
            OrigObj.base := []
        For k, v in MergingObj.base
            ObjInsert(OrigObj.base, k, v)
    }
    Return True
}

evalRPN("3 4 2 * 1 5 - 2 3 ^ ^ / +")
evalRPN(s){ ;Parsing/RPN calculator algorithm
	stack := []
	out := "For RPN expression: '" s "'`r`n`r`nTOKEN`t`tACTION`t`t`tSTACK`r`n"
	Loop Parse, s
		If A_LoopField is number
			t .= A_LoopField
		else
		{
			If t
				stack.Insert(t)
				, out .= t "`tPush num onto top of stack`t" stackShow(stack) "`r`n"
				, t := ""
			If InStr("+-/*^", l := A_LoopField)
			{
				a := stack.Remove(), b := stack.Remove()
				stack.Insert(	 l = "+" ? b + a
						:l = "-" ? b - a
						:l = "*" ? b * a
						:l = "/" ? b / a
						:l = "^" ? b **a
						:0	)
				out .= l "`tApply op " l " to top of stack`t" stackShow(stack) "`r`n"
			}
		}
	r := stack.Remove()
	out .= "`r`n The final output value is: '" r "'"
	clipboard := out
	return r
}
StackShow(stack){
	for each, value in stack
		out .= A_Space value
	return subStr(out, 2)
}


;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{String - Array Operations
Sort2DArray(Byref TDArray, KeyName, Order=1) {
   ;TDArray : a two dimensional TDArray
   ;KeyName : the key name to be sorted
   ;Order: 1:Ascending 0:Descending

    For index2, obj2 in TDArray {
        For index, obj in TDArray {
            if (lastIndex = index)
                break
            if !(A_Index = 1) &&  ((Order=1) ? (TDArray[prevIndex][KeyName] > TDArray[index][KeyName]) : (TDArray[prevIndex][KeyName] < TDArray[index][KeyName])) {
               tmp := TDArray[index][KeyName]
               TDArray[index][KeyName] := TDArray[prevIndex][KeyName]
               TDArray[prevIndex][KeyName] := tmp
            }
            prevIndex := index
        }
        lastIndex := prevIndex
    }
}

SortArray(Array, Order="A") {
    ;Order A: Ascending, D: Descending, R: Reverse
    MaxIndex := ObjMaxIndex(Array)
    If (Order = "R") {
        count := 0
        Loop, % MaxIndex
            ObjInsert(Array, ObjRemove(Array, MaxIndex - count++))
        Return
    }
    Partitions := "|" ObjMinIndex(Array) "," MaxIndex
    Loop {
        comma := InStr(this_partition := SubStr(Partitions, InStr(Partitions, "|", False, 0)+1), ",")
        spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)
        if (Order = "A") {
            Loop, % epos - spos {
                if (Array[pivot] > Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))
            }
        } else {
            Loop, % epos - spos {
                if (Array[pivot] < Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))
            }
        }
        Partitions := SubStr(Partitions, 1, InStr(Partitions, "|", False, 0)-1)
        if (pivot - spos) > 1    ;if more than one elements
            Partitions .= "|" spos "," pivot-1        ;the left partition
        if (epos - pivot) > 1    ;if more than one elements
            Partitions .= "|" pivot+1 "," epos        ;the right partition
    } Until !Partitions
}

GetNestedTag(data,tag,occurrence="1") {

	; AHK Forum Topic : http://www.autohotkey.com/forum/viewtopic.php?t=77653
   ; Documentation   : http://www.autohotkey.net/~hugov/functions/GetNestedTag.html

	 Start:=InStr(data,tag,false,1,occurrence)
	 RegExMatch(tag,"i)<([a-z]*)",basetag) ; get yer basetag1 here
	 Loop
		{
		 Until:=InStr(data, "</" basetag1 ">", false, Start, A_Index) + StrLen(basetag1) + 3
 		 Strng:=SubStr(data, Start, Until - Start)

		 StringReplace, strng, strng, <%basetag1%, <%basetag1%, UseErrorLevel ; start counting to make match
		 OpenCount:=ErrorLevel
		 StringReplace, strng, strng, </%basetag1%, </%basetag1%, UseErrorLevel
		 CloseCount:=ErrorLevel
		 If (OpenCount = CloseCount)
		 	Break

		 If (A_Index > 250) ; for safety so it won't get stuck in an endless loop,
		 	{                 ; it is unlikely to have over 250 nested tags
		 	 strng=
		 	 Break
		 	}
		}
	 If (StrLen(strng) < StrLen(tag)) ; something went wrong/can't find it
	 	strng=
	 Return strng
	}

GetHTMLbyID(HTMLSource, ID, Format=0) {
	;Format 0:Text 1:HTML 2:DOM
	ComError := ComObjError(false), `(oHTML := ComObjCreate("HtmlFile")).write(HTMLSource)
	if (Format = 2) {
		if (innerHTML := oHTML.getElementById(ID)["innerHTML"]) {
			`(oDOM := ComObjCreate("HtmlFile")).write(innerHTML)
			Return oDOM, ComObjError(ComError)
		} else
			Return "", ComObjError(ComError)
	} else
	Return (result := oHTML.getElementById(ID)[(Format ? "innerHTML" : "innerText")]) ? result : "", ComObjError(ComError)
}

GetHTMLbyTag(HTMLSource, Tag, Occurrence=1, Format=0) {
	;Format 0:Text 1:HTML 2:DOM
	ComError := ComObjError(false), `(oHTML := ComObjCreate("HtmlFile")).write(HTMLSource)
	if (Format = 2) {
		if (innerHTML := oHTML.getElementsByTagName(Tag)[Occurrence-1]["innerHTML"]) {
			`(oDOM := ComObjCreate("HtmlFile")).write(innerHTML)
			Return oDOM, ComObjError(ComError)
		} else
			Return "", ComObjError(ComError)
	}
	return (result := oHTML.getElementsByTagName(Tag)[Occurrence-1][(Format ? "innerHTML" : "innerText")]) ? result : "", ComObjError(ComError)
}

GetXmlElement(xml, pathToElement) {
   Loop, parse, pathToElement, .,
   {
      elementName:=A_LoopField
      regex=<%elementName%>(.*)</%elementName%>

      RegExMatch(xml, regex, xml)
      ;TODO switch to use xml1, instead of parsing stuff out
      ;errord("nolog", xml1)
      xml := StringTrimLeft(xml, strlen(elementName)+2)
      xml := StringTrimRight(xml, strlen(elementName)+3)
   }

   return xml
}

sXMLget( xml, node, attr = "" ) {
;by infogulch - simple solution get information out of xml and html
;  supports getting the values from a nested nodes; does NOT support decendant/ancestor or sibling
;  for something more than a little complex, try Titan's xpath: http://www.autohotkey.com/forum/topic17549.html
   RegExMatch( xml
      , (attr ? ("<" node "\b[^>]*\b" attr "=""(?<match>[^""]*)""[^>]*>") : ("<" node "\b[^>/]*>(?<match>(?<tag>(?:[^<]*(?:<(\w+)\b[^>]*>(?&tag)</\3>)*)*))</" node ">"))
      , retval )
   return retvalMatch
}

parseJSON(txt) {
	out := {}
	Loop																		; Go until we say STOP
	{
		ind := A_index															; INDex number for whole array
		ele := strX(txt,"{",n,1, "}",1,1, n)									; Find next ELEment {"label":"value"}
		if (n > strlen(txt)) {
			break																; STOP when we reach the end
		}
		sub := StrSplit(ele,",")												; Array of SUBelements for this ELEment
		Loop, % sub.MaxIndex()
		{
			StringSplit, key, % sub[A_Index] , : , `"							; Split each SUB into label (key1) and value (key2)
			out[ind,key1] := key2												; Add to the array
		}
	}
	return out
}

AddTrailingBackslash(ptext) {
	if (SubStr(ptext, 0, 1) <> "\")
		return, ptext . "\"
	return, ptext
}

CheckQuotes(Path) {
   if (InStr(Path, A_Space, false) <> 0)
   {
      Path = "%Path%"
   }
   return, Path
}

ReplaceForbiddenChars(S_IN, ReplaceByStr = "") {
   S_OUT := ""
   Replace_RegEx := "im)[\/:*?""<>|]*"

   S_OUT := RegExReplace(S_IN, Replace_RegEx, "")
   if (S_OUT = 0)
      return, S_IN
   if (ErrorLevel = 0) and (S_OUT <> "")
      return, S_OUT
}

cleanlines(ByRef txt) {
	Loop, Parse, txt, `n, `r
	{
		i := A_LoopField
		if !(i){
			continue
		}
		newtxt .= i "`n"
	}
	txt := newtxt
	return txt
}

cleancolon(txt) {
	if substr(txt,1,1)=":" {
		txt:=substr(txt,2)
		txt = %txt%
	}
	return txt
}

cleanspace(ByRef txt) {
	StringReplace txt,txt,`n`n,%A_Space%, All
	StringReplace txt,txt,%A_Space%.%A_Space%,.%A_Space%, All
	loop
	{
		StringReplace txt,txt,%A_Space%%A_Space%,%A_Space%, UseErrorLevel
		if ErrorLevel = 0
			break
	}
	return txt
}

uriEncode(str) { ; A function to escape characters like & for use in URLs.

    f = %A_FormatInteger%
    SetFormat, Integer, Hex
    If RegExMatch(str, "^\w+:/{0,2}", pr)
        StringTrimLeft, str, str, StrLen(pr)
    StringReplace, str, str, `%, `%25, All
    Loop
        If RegExMatch(str, "i)[^\w\.~%/:]", char)
           StringReplace, str, str, %char%, % "%" . SubStr(Asc(char),3), All
        Else Break
    SetFormat, Integer, %f%
    Return, pr . str
}

ParseJsonStrToArr(json_data) { ;this one works fine , cutting all {} in different arrays but forgets the last data is'nt put in {...
   ;i am changing the code a little bit for further programming, Insert changes to InsertAt

   arr := []
   pos :=1
   i:= 0
   While pos:=RegExMatch(json_data,"((?:{)[\s\S][^{}]+(?:}))", j, pos+StrLen(j))
   {
	i += 1
    arr.InsertAt(i,j1)                      ; insert json string to array  arr=[{"id":"a1","subject":"s1"},{"id":"a2","subject":"s2"},{"id":"a3","subject":"s3"}]
   }
   return arr
}

EnsureEndsWith(string, char) {  ;Ensure that the string given ends with a given char
   if ( StringRight(string, strlen(char)) <> char )
      string .= char

   return string
}

EnsureStartsWith(string, char) { ;Ensure that the string given starts with a given char
   if ( StringLeft(string, strlen(char)) <> char )
      string := char . string

   return string
}

StrPutVar(string, ByRef var, encoding) {    ;Convert the data to some Enc, like UTF-8, UTF-16, CP1200 and so on
   ;{-------------------------------------------------------------------------------
    ;
    ; Function: StrPutVar
    ; Description:
    ;		Convert the data to some Enc, like UTF-8, UTF-16, CP1200 and so on
    ; Syntax: StrPutVar(Str, ByRef Var [, Enc = ""])
    ; Parameters:
    ;		Str - String
    ;		Var - The name of the variable
    ;		Enc - Encoding
    ; Return Value:
    ;		String in a particular encoding
    ; Example:
    ;		None
    ;
    ;-------------------------------------------------------------------------------
    ;}


    VarSetCapacity( var, StrPut(string, encoding)
        * ((encoding="cp1252"||encoding="utf-16") ? 2 : 1) )
    return StrPut(string, &var, encoding)
}

Ansi2Unicode(ByRef sString, ByRef wString, CP = 0) {
     nSize := DllCall("MultiByteToWideChar"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &sString
      , "int",  -1
      , "Uint", 0
      , "int",  0)

   VarSetCapacity(wString, nSize * 2)

   DllCall("MultiByteToWideChar"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &sString
      , "int",  -1
      , "Uint", &wString
      , "int",  nSize)
}

Unicode2Ansi(ByRef wString, ByRef sString, CP = 0) {
     nSize := DllCall("WideCharToMultiByte"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &wString
      , "int",  -1
      , "Uint", 0
      , "int",  0
      , "Uint", 0
      , "Uint", 0)

   VarSetCapacity(sString, nSize)

   DllCall("WideCharToMultiByte"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &wString
      , "int",  -1
      , "str",  sString
      , "int",  nSize
      , "Uint", 0
      , "Uint", 0)
}


;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Keys - Hotkeys - Hotstring - Functions
DelaySend(Key, Interval=200, SendMethod="Send") { ; Tastenanschläge verzögert absenden

	/*
	Sends keystrokes with a specified delay. It will be useful for an application which does not accept key presses sent too quickly.
	Remarks
	It remembers the sent count and completes them all.
	Requirements
	AutoHotkey_L v1.1.01 or later.  Tested on: Windows 7 64bit, AutoHotkey 32bit Unicode 1.1.05.01.
	*/

	static KeyStack := []
    KeyStack[Key] := IsObject(KeyStack[Key]) ? KeyStack[Key] : {base: {LastTickCount: 0}}
    ObjInsert( KeyStack[Key], { Key: Key, Interval: Interval, SendMethod: SendMethod })
    Gosub, Label_DelaySend
    Return

    Label_DelaySend:
        For Key in KeyStack {
            if !(MinIndex := KeyStack[Key].MinIndex())
                Continue
            Span := A_TickCount - KeyStack[Key].LastTickCount
            if (Span < KeyStack[Key][MinIndex].Interval)    ;loaded too early
                SetTimer,, % -1 * (KeyStack[Key][KeyStack[Key].MinIndex()].Interval - Span)     ;[v1.1.01+]
            else {
                SendMethod := KeyStack[Key][MinIndex].SendMethod
                SendingKey := KeyStack[Key][MinIndex].Key
                if (SendMethod = "SendInput")
                    SendInput, % SendingKey
                Else if (SendMethod = "SendPlay")
                    SendPlay, % SendingKey
                Else if (SendMethod = "SendRaw")
                    SendRaw, % SendingKey
                Else if (SendMethod = "SendEvent")
                    SendEvent, % SendingKey
                Else
                    Send, % SendingKey

                ObjRemove(KeyStack[Key], MinIndex)    ;decrement other elements
                if KeyStack[Key].MinIndex() ;if there is a next queue
                    SetTimer,, % -1 * KeyStack[Key][KeyStack[Key].MinIndex()].Interval        ;[v1.1.01+]
                KeyStack[Key].base.LastTickCount := A_TickCount
            }
        }
    Return
}

;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Hinweise - Messages
ShowTrayBalloon(TipTitle = "", TipText = "", ShowTime = 5000, TipType = 1) {
   global cfg

   if (not cfg.ShowBalloons)
      return, 0
   gosub, RemoveTrayTip
   if (TipText <> "")
   {
      Title := (TipTitle <> "") ? TipTitle : ProgramName
      TrayTip, %Title%, %TipText%, 10, %TipType%+16
      SetTimer, RemoveTrayTip, %ShowTime%
   }
   else
   {
      gosub, RemoveTrayTip
      return, 0
   }
   return, 0

   RemoveTrayTip:
      SetTimer, RemoveTrayTip, Off
      TrayTip
   return
}

CreateWindow(key) {       ;-Hotkey Window
        GetTextSize(key,35,Verdana,height,width)
        bgTopPadding = 40
        bgWidthPadding = 100
        bgHeight = % height + bgTopPadding
        bgWidth = % width + bgWidthPadding
        padding = 20
        yPlacement = % A_ScreenHeight – bgHeight – padding
        xPlacement = % A_ScreenWidth – bgWidth – padding

        Gui, Color, 46bfec
        Gui, Margin, 0, 0
        Gui, Add, Picture, x0 y0 w%bgWidth% h%bgHeight%, C:\Users\IrisDaniela\Pictures\bg.png
        Gui, +LastFound +AlwaysOnTop -Border -SysMenu +Owner -Caption +ToolWindow
        Gui, Font, s35 cWhite, Verdana
        Gui, Add, Text, xm y20 x25 ,%key%
        Gui, Show, x%xPlacement% y%yPlacement%
        SetTimer, RemoveGui, 5000
        }

GetTextSize(str, size, font,ByRef height,ByRef width) {         ;Funktion zur Berechnung von Breite und Höhe je nach Textlänge
        Gui temp: Font, s%size%, %font%
        Gui temp:Add, Text, , %str%
        GuiControlGet T, temp:Pos, Static1
        Gui temp:Destroy
        height = % TH
        width = % TW
        }

        RemoveGui:
        Gui, Destroy
        return

#7::
CreateWindow(“Win + 7”)
return

;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Systemfunktionen
CreateNamedPipe(Name, OpenMode=3, PipeMode=0, MaxInstances=255) {
    return DllCall("CreateNamedPipe","str","\\.\pipe\" Name,"uint",OpenMode
        ,"uint",PipeMode,"uint",MaxInstances,"uint",0,"uint",0,"uint",0,"uint",0)
}

RestoreCursors() {
   SPI_SETCURSORS := 0x57
   DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
}

SetSystemCursor( Cursor = "", cx = 0, cy = 0 ) {
	BlankCursor := 0, SystemCursor := 0, FileCursor := 0
	SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
		,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
		,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
		,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP
	If Cursor =
	{
		VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )
		BlankCursor = 1
	}
	Else If SubStr( Cursor,1,4 ) = "IDC_"
	{
		Loop, Parse, SystemCursors, `,
		{
			CursorName := SubStr( A_Loopfield, 6, 15 )
			CursorID := SubStr( A_Loopfield, 1, 5 )
			SystemCursor = 1
			If ( CursorName = Cursor )
			{
				CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )
				Break
			}
		}
		If CursorHandle =
		{
			Msgbox,, SetCursor, Error: Invalid cursor name
			CursorHandle = Error
		}
	}
	Else If FileExist( Cursor )
	{
		SplitPath, Cursor,,, Ext
		If Ext = ico
			uType := 0x1
		Else If Ext in cur,ani
			uType := 0x2
		Else
		{
			Msgbox,, SetCursor, Error: Invalid file type
			CursorHandle = Error
		}
		FileCursor = 1
	}
	Else
	{
		Msgbox,, SetCursor, Error: Invalid file path or cursor name
		CursorHandle = Error
	}
	If CursorHandle != Error
	{
		Loop, Parse, SystemCursors, `,
		{
			If BlankCursor = 1
			{
				Type = BlankCursor
				%Type%%A_Index% := DllCall( "CreateCursor"
					, Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
				CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
				DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
			}
			Else If SystemCursor = 1
			{
				Type = SystemCursor
				CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )
				%Type%%A_Index% := DllCall( "CopyImage"
					, Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0 )
				CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
				DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
			}
			Else If FileCursor = 1
			{
				Type = FileCursor
				%Type%%A_Index% := DllCall( "LoadImageA"
					, UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10 )
				DllCall( "SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5 ) )
			}
		}
	}
}

SetTimerF( Function, Period=0, ParmObject=0, Priority=0 ) {  ;Starts a timer that can call functions and object methods
 Static current,tmrs:=Object() ;current will hold timer that is currently running
 If IsFunc( Function ) || IsObject( Function ){
    if IsObject(tmr:=tmrs[Function]) ;destroy timer before creating a new one
       ret := DllCall( "KillTimer", UInt,0, UInt, tmr.tmr)
       , DllCall("GlobalFree", UInt, tmr.CBA)
       , tmrs.Remove(Function)
    if (Period = 0 || Period ? "off")
       return ret ;Return as we want to turn off timer
    ; create object that will hold information for timer, it will be passed trough A_EventInfo when Timer is launched
    tmr:=tmrs[Function]:=Object("func",Function,"Period",Period="on" ? 250 : Period,"Priority",Priority
                        ,"OneTime",(Period<0),"params",IsObject(ParmObject)?ParmObject:Object()
                        ,"Tick",A_TickCount)
    tmr.CBA := RegisterCallback(A_ThisFunc,"F",4,&tmr)
    return !!(tmr.tmr  := DllCall("SetTimer", UInt,0, UInt,0, UInt
                        , (Period && Period!="On") ? Abs(Period) : (Period := 250)
                        , UInt,tmr.CBA)) ;Create Timer and return true if a timer was created
            , tmr.Tick:=A_TickCount
 }
 tmr := Object(A_EventInfo) ;A_Event holds object which contains timer information
 if IsObject(tmr) {
    DllCall("KillTimer", UInt,0, UInt,tmr.tmr) ;deactivate timer so it does not run again while we are processing the function
    If (!tmr.active && tmr.Priority<(current.priority ? current.priority : 0)) ;Timer with higher priority is already current so return
       Return (tmr.tmr:=DllCall("SetTimer", UInt,0, UInt,0, UInt, 100, UInt,tmr.CBA)) ;call timer again asap
    current:=tmr
    tmr.tick:=ErrorLevel :=Priority ;update tick to launch function on time
    func := tmr.func.(tmr.params*) ;call function
    current= ;reset timer
    if (tmr.OneTime) ;One time timer, deactivate and delete it
       return DllCall("GlobalFree", UInt,tmr.CBA)
             ,tmrs.Remove(tmr.func)
    tmr.tmr:= DllCall("SetTimer", UInt,0, UInt,0, UInt ;reset timer
            ,((A_TickCount-tmr.Tick) > tmr.Period) ? 0 : (tmr.Period-(A_TickCount-tmr.Tick)), UInt,tmr.CBA)
 }
}

TaskDialog(Instruction, Content := "", Title := "", Buttons := 1, IconID := 0, IconRes := "", Owner := 0x10010) {
    Local hModule, LoadLib, Ret

    If (IconRes != "") {
        hModule := DllCall("GetModuleHandle", "Str", IconRes, "Ptr")
        LoadLib := !hModule
            && hModule := DllCall("LoadLibraryEx", "Str", IconRes, "UInt", 0, "UInt", 0x2, "Ptr")
    } Else {
        hModule := 0
        LoadLib := False
    }

    DllCall("TaskDialog"
        , "Ptr" , Owner        ; hWndParent
        , "Ptr" , hModule      ; hInstance
        , "Ptr" , &Title       ; pszWindowTitle
        , "Ptr" , &Instruction ; pszMainInstruction
        , "Ptr" , &Content     ; pszContent
        , "Int" , Buttons      ; dwCommonButtons
        , "Ptr" , IconID       ; pszIcon
        , "Int*", Ret := 0)    ; *pnButton

    If (LoadLib) {
        DllCall("FreeLibrary", "Ptr", hModule)
    }

    Return {1: "OK", 2: "Cancel", 4: "Retry", 6: "Yes", 7: "No", 8: "Close"}[Ret]
}

TaskDialogDirect(Instruction, Content := "", Title := "", CustomButtons := "", CommonButtons := 0, MainIcon := 0, Flags := 0, Owner := 0x10010, VerificationText := "", ExpandedText := "", FooterText := "", FooterIcon := 0, Width := 0) {
    Static x64 := A_PtrSize == 8, Button := 0, Checked := 0

    If (CustomButtons != "") {
        Buttons := StrSplit(CustomButtons, "|")
        cButtons := Buttons.Length()
        VarSetCapacity(pButtons, 4 * cButtons + A_PtrSize * cButtons, 0)
        Loop %cButtons% {
            iButtonText := &(b%A_Index% := Buttons[A_Index])
            NumPut(100 + A_Index, pButtons, (4 + A_PtrSize) * (A_Index - 1), "Int")
            NumPut(iButtonText, pButtons, (4 + A_PtrSize) * A_Index - A_PtrSize, "Ptr")
        }
    } Else {
        cButtons := 0
        pButtons := 0
    }

    NumPut(VarSetCapacity(TDC, (x64) ? 160 : 96, 0), TDC, 0, "UInt") ; cbSize
    NumPut(Owner, TDC, 4, "Ptr") ; hwndParent
    NumPut(Flags, TDC, (x64) ? 20 : 12, "Int") ; dwFlags
    NumPut(CommonButtons, TDC, (x64) ? 24 : 16, "Int") ; dwCommonButtons
    NumPut(&Title, TDC, (x64) ? 28 : 20, "Ptr") ; pszWindowTitle
    NumPut(MainIcon, TDC, (x64) ? 36 : 24, "Ptr") ; pszMainIcon
    NumPut(&Instruction, TDC, (x64) ? 44 : 28, "Ptr") ; pszMainInstruction
    NumPut(&Content, TDC, (x64) ? 52 : 32, "Ptr") ; pszContent
    NumPut(cButtons, TDC, (x64) ? 60 : 36, "UInt") ; cButtons
    NumPut(&pButtons, TDC, (x64) ? 64 : 40, "Ptr") ; pButtons
    NumPut(&VerificationText, TDC, (x64) ? 92 : 60, "Ptr") ; pszVerificationText
    NumPut(&ExpandedText, TDC, (x64) ? 100 : 64, "Ptr") ; pszExpandedInformation
    NumPut(FooterIcon, TDC, (x64) ? 124 : 76, "Ptr") ; pszFooterIcon
    NumPut(&FooterText, TDC, (x64) ? 132 : 80, "Ptr") ; pszFooter
    NumPut(Width, TDC, (x64) ? 156 : 92, "UInt") ; cxWidth

    If (DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC, "Int*", Button, "Int", 0, "Int*", Checked) == 0) {
        Return (VerificationText == "") ? Button : [Button, Checked]
    } Else {
        Return "ERROR"
    }
}

getProcesses(ignoreSelf := True, searchNames := "") { ; searchNames comma separated list. If these processes exist, then they will be retrieved in the array


	s := 100096  ; 100 KB will surely be HEAPS

	array := []
	PID := DllCall("GetCurrentProcessId")
	; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
	h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", PID, "Ptr")
	; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
	DllCall("Advapi32.dll\OpenProcessToken", "Ptr", h, "UInt", 32, "PtrP", t)
	VarSetCapacity(ti, 16, 0)  ; structure of privileges
	NumPut(1, ti, 0, "UInt")  ; one entry in the privileges array...
	; Retrieves the locally unique identifier of the debug privilege:
	DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
	NumPut(luid, ti, 4, "Int64")
	NumPut(2, ti, 12, "UInt")  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
	; Update the privileges of this process with the new access token:
	r := DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
	DllCall("CloseHandle", "Ptr", t)  ; close this access token handle to save memory
	DllCall("CloseHandle", "Ptr", h)  ; close this process handle to save memory

	hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; increase performance by preloading the library
	s := VarSetCapacity(a, s)  ; an array that receives the list of process identifiers:
	DllCall("Psapi.dll\EnumProcesses", "Ptr", &a, "UInt", s, "UIntP", r)
	Loop, % r // 4  ; parse array for identifiers as DWORDs (32 bits):
	{
	   currentPID := NumGet(a, A_Index * 4, "UInt")
	   if (ignoreSelf && currentPID = PID)
			continue ; this is own script
	   ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
	   h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", currentPID, "Ptr")
	   if !h
	      continue
	   VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
	   e := DllCall("Psapi.dll\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
	   if !e    ; fall-back method for 64-bit processes when in 32-bit mode:
	      if e := DllCall("Psapi.dll\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
	         SplitPath n, n
	   DllCall("CloseHandle", "Ptr", h)  ; close process handle to save memory
	  	if searchNames
	  	{
			  if n not in %searchNames%
			  	continue
	  	}
	   if (n && e)  ; if image is not null add to list:
	   		array.insert({"Name": n, "PID": currentPID})
	}
	DllCall("FreeLibrary", "Ptr", hModule)  ; unload the library to free memory
	return array
}

GetProcessWorkingDir(PID) {
  static PROCESS_ALL_ACCESS:=0x1F0FFF,MEM_COMMIT := 0x1000,MEM_RELEASE:=0x8000,PAGE_EXECUTE_READWRITE:=64
        ,GetCurrentDirectoryW,init:=MCode(GetCurrentDirectoryW,"8BFF558BECFF75088B450803C050FF15A810807CD1E85DC20800")
  nDirLength := VarSetCapacity(nDir, 512, 0)
  hProcess := DllCall("OpenProcess", "UInt", PROCESS_ALL_ACCESS, "Int",0, "UInt", PID)
  if !hProcess
    return
  pBufferRemote := DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "PTR", nDirLength + 1, "UInt", MEM_COMMIT, "UInt", PAGE_EXECUTE_READWRITE, "Ptr")

  pThreadRemote := DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "PTR", 26, "UInt", MEM_COMMIT, "UInt", PAGE_EXECUTE_READWRITE, "Ptr")
  DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", pThreadRemote, "Ptr", &GetCurrentDirectoryW, "PTR", 26, "Ptr", 0)

  If hThread := DllCall("CreateRemoteThread", "PTR", hProcess, "UInt", 0, "UInt", 0, "PTR", pThreadRemote, "PTR", pBufferRemote, "UInt", 0, "UInt", 0)
  {
    DllCall("WaitForSingleObject", "PTR", hThread, "UInt", 0xFFFFFFFF)
    DllCall("GetExitCodeThread", "PTR", hThread, "UIntP", lpExitCode)
    If lpExitCode {
      DllCall("ReadProcessMemory", "PTR", hProcess, "PTR", pBufferRemote, "Str", nDir, "UInt", lpExitCode*2, "UInt", 0)
      VarSetCapacity(nDir,-1)
    }
    DllCall("CloseHandle", "PTR", hThread)
  }
  DllCall("VirtualFreeEx","PTR",hProcess,"PTR",pBufferRemote,"PTR",nDirLength + 1,"UInt",MEM_RELEASE)
  DllCall("VirtualFreeEx","PTR",hProcess,"PTR",pThreadRemote,"PTR",31,"UInt",MEM_RELEASE)
  DllCall("CloseHandle", "PTR", hProcess)

  return nDir
}

GetProcessName(hwnd) {
	WinGet, ProcessName, processname, ahk_id %hwnd%
	return ProcessName
}

GetModuleFileNameEx( pid ) {
   if A_OSVersion in WIN_95,WIN_98,WIN_ME
   {
      MsgBox, This Windows version (%A_OSVersion%) is not supported.
      return
   }

   /*
      #define PROCESS_VM_READ           (0x0010)
      #define PROCESS_QUERY_INFORMATION (0x0400)
   */
   h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", pid, "Ptr")
   if ( ErrorLevel or h_process = 0 )
   {
      outputdebug [OpenProcess] failed. PID = %pid%
      return
   }

   name_size := A_IsUnicode ? 510 : 255
   VarSetCapacity( name, name_size )

   result := DllCall( "psapi.dll\GetModuleFileNameEx", "Ptr", h_process, "uint", 0, "str", name, "uint", name_size )
   if ( ErrorLevel or result = 0 )
      outputdebug, [GetModuleFileNameExA] failed

   DllCall( "CloseHandle", "Ptr", h_process )
   return, name
}

GlobalVarsScript(var="",size=102400,ByRef object=0) {
  global
  static globalVarsScript
  If (var="")
    Return globalVarsScript
  else if !size {
    If !InStr(globalVarsScript,var ":= CriticalObject(" CriticalObject(object,1) "," CriticalObject(object,2) ")`n"){
      If !CriticalObject(object,1)
        object:=CriticalObject(object)
      globalVarsScript .= var ":= CriticalObject(" CriticalObject(object,1) "," CriticalObject(object,2) ")`n"
    }
  } else {
    Loop,Parse,Var,|
    If !InStr(globalVarsScript,"Alias(" A_LoopField "," GetVar(%A_LoopField%) ")`n"){
      %A_LoopField%:=""
      If size
        VarSetCapacity(%A_LoopField%,size)
      globalVarsScript:=globalVarsScript . "Alias(" A_LoopField "," GetVar(%A_LoopField%) ")`n"
    }
  }
  Return globalVarsScript
}

patternScan(pattern, haystackAddress, haystackSize) {

		; Parameters
			; pattern
			;			A string of two digit numbers representing the hex value of each byte of the pattern. The '0x' hex-prefix is not required
			;			?? Represents a wildcard byte (can be any value)
			;			All of the digit groups must be 2 characters long i.e 05, 0F, and ??, NOT 5, F or ?
			;			Spaces, tabs, and 0x hex-prefixes are optional
			; haystackAddress
			;			The memory address of the binary haystack eg &haystack
			; haystackAddress
			;			The byte length of the binary haystack

			; Return values
			;  0  	Not Found
			; -1 	An odd number of characters were passed via pattern
			;		Ensure you use two digits to represent each byte i.e. 05, 0F and ??, and not 5, F or ?
			; -2   	No valid bytes in the needle/pattern
			; int 	The offset from haystackAddress of the start of the found pattern

		StringReplace, pattern, pattern, 0x,, All
		StringReplace, pattern, pattern, %A_Space%,, All
		StringReplace, pattern, pattern, %A_Tab%,, All
		pattern := RTrim(pattern, "?")				; can pass patterns beginning with ?? ?? - but why not just start the pattern with the first known byte
		loopCount := bufferSize := StrLen(pattern) / 2
		if Mod(StrLen(pattern), 2)
			return -1
		VarSetCapacity(binaryNeedle, bufferSize)
		aOffsets := [], startGap := 0
		loop, % loopCount
		{
			hexChar := SubStr(pattern, 1 + 2 * (A_Index - 1), 2)
			if (hexChar != "??") && (prevChar = "??" || A_Index = 1)
				binNeedleStartOffset := A_index - 1
			else if (hexChar = "??" && prevChar != "??" && A_Index != 1)
			{

				aOffsets.Insert({ "binNeedleStartOffset": binNeedleStartOffset
								, "binNeedleSize": A_Index - 1 - binNeedleStartOffset
								, "binNeedleGap": !aOffsets.MaxIndex() ? 0 : binNeedleStartOffset - startGap + 1}) ; equals number of wildcard bytes between two sub needles
				startGap := A_index
			}

			if (A_Index = loopCount) ; last char cant be ??
				aOffsets.Insert({ "binNeedleStartOffset": binNeedleStartOffset
								, "binNeedleSize": A_Index - binNeedleStartOffset
								, "binNeedleGap": !aOffsets.MaxIndex() ? 0 : binNeedleStartOffset - startGap + 1})
			prevChar := hexChar
			if (hexChar != "??")
			{
				numput("0x" . hexChar, binaryNeedle, A_index - 1, "UChar")
				realNeedleSize++
			}
		}
		if !realNeedleSize
			return -2 ; no valid bytes in the needle

		haystackOffset := 0
		aOffset := aOffsets[arrayIndex := 1]
		loop
		{
			if (-1 != foundOffset := scanInBuf(haystackAddress, &binaryNeedle + aOffset.binNeedleStartOffset, haystackSize, aOffset.binNeedleSize, haystackOffset))
			{
				; either the first subneedle was found, or the current subneedle is the correct distance from the previous subneedle
				; The scanInBuf returned 'foundOffset' is relative to haystackAddr regardless of haystackOffset
				if (arrayIndex = 1 || foundOffset = haystackOffset)
				{
					if (arrayIndex = 1)
					{
						currentStartOffstet := aOffset.binNeedleSize + foundOffset ; save the offset of the match for the first part of the needle - if remainder of needle doesn't match,  resume search from here
						tmpfoundAddress := foundOffset
					}
					if (arrayIndex = aOffsets.MaxIndex())
						return foundAddress := tmpfoundAddress - aOffsets[1].binNeedleStartOffset  ;+ haystackAddress ; deduct the first needles starting offset - in case user passed a pattern beginning with ?? eg "?? ?? 00 55"
					prevNeedleSize := aOffset.binNeedleSize
					aOffset := aOffsets[++arrayIndex]
					haystackOffset := foundOffset + prevNeedleSize + aOffset.binNeedleGap   ; move the start of the haystack ready for the next needle - accounting for previous needle size and any gap/wildcard-bytes between the two needles
					continue
				}
				; else the offset of the found subneedle was not the correct distance from the end of the previous subneedle
			}
			if (arrayIndex = 1) ; couldn't find the first part of the needle
				return 0
			; the subsequent subneedle couldn't be found.
			; So resume search from the address immediately next to where the first subneedle was found
			aOffset := aOffsets[arrayIndex := 1]
			haystackOffset := currentStartOffstet
		}

	}

scanInBuf(haystackAddr, needleAddr, haystackSize, needleSize, StartOffset = 0) {
		;Doesn't WORK with AHK 64 BIT, only works with AHK 32 bit
	;taken from:
	;http://www.autohotkey.com/board/topic/23627-machine-code-binary-buffer-searching-regardless-of-null/
	; -1 not found else returns offset address (starting at 0)
	; The returned offset is relative to the haystackAddr regardless of StartOffset
		static fun

		; AHK32Bit a_PtrSize = 4 | AHK64Bit - 8 bytes
		if (a_PtrSize = 8)
		  return -1

		ifequal, fun,
		{
		  h =
		  (  LTrim join
		     5589E583EC0C53515256579C8B5D1483FB000F8EC20000008B4D108B451829C129D9410F8E
		     B10000008B7D0801C78B750C31C0FCAC4B742A4B742D4B74364B74144B753F93AD93F2AE0F
		     858B000000391F75F4EB754EADF2AE757F3947FF75F7EB68F2AE7574EB628A26F2AE756C38
		     2775F8EB569366AD93F2AE755E66391F75F7EB474E43AD8975FC89DAC1EB02895DF483E203
		     8955F887DF87D187FB87CAF2AE75373947FF75F789FB89CA83C7038B75FC8B4DF485C97404
		     F3A775DE8B4DF885C97404F3A675D389DF4F89F82B45089D5F5E5A595BC9C2140031C0F7D0
		     EBF0
		  )
		  varSetCapacity(fun, strLen(h)//2)
		  loop % strLen(h)//2
		     numPut("0x" . subStr(h, 2*a_index-1, 2), fun, a_index-1, "char")
		}

		return DllCall(&fun, "uInt", haystackAddr, "uInt", needleAddr
		              , "uInt", haystackSize, "uInt", needleSize, "uInt", StartOffset)
	}

hexToBinaryBuffer(hexString, byRef buffer) {
	StringReplace, hexString, hexString, 0x,, All
	StringReplace, hexString, hexString, %A_Space%,, All
	StringReplace, hexString, hexString, %A_Tab%,, All
	if !length := strLen(hexString)
	{
		msgbox nothing was passed to hexToBinaryBuffer
		return 0
	}
	if mod(length, 2)
	{
		msgbox Odd Number of characters passed to hexToBinaryBuffer`nEnsure two digits are used for each byte e.g. 0E
		return 0
	}
	byteCount := length/ 2
	VarSetCapacity(buffer, byteCount)
	loop, % byteCount
		numput("0x" . substr(hexString, 1 + (A_index - 1) * 2, 2), buffer, A_index - 1, "UChar")
	return byteCount

}


;}

;{Systemfunktionen - dll
GetDllBase(DllName, PID = 0) {
    TH32CS_SNAPMODULE := 0x00000008
    INVALID_HANDLE_VALUE = -1
    VarSetCapacity(me32, 548, 0)
    NumPut(548, me32)
    snapMod := DllCall("CreateToolhelp32Snapshot", "Uint", TH32CS_SNAPMODULE
                                                 , "Uint", PID)
    If (snapMod = INVALID_HANDLE_VALUE) {
        Return 0
    }
    If (DllCall("Module32First", "Uint", snapMod, "Uint", &me32)){
        while(DllCall("Module32Next", "Uint", snapMod, "UInt", &me32)) {
            If !DllCall("lstrcmpi", "Str", DllName, "UInt", &me32 + 32) {
                DllCall("CloseHandle", "UInt", snapMod)
                Return NumGet(&me32 + 20)
            }
        }
    }
    DllCall("CloseHandle", "Uint", snapMod)
    Return 0
}

getProcessBassAddressFromModules(process) {

/*
	http://stackoverflow.com/questions/14467229/get-base-address-of-process
	Open the process using OpenProcess -- if successful, the value returned is a handle to the process, which is just an opaque token used by the kernel to identify a kernel object. Its exact integer value (0x5c in your case) has no meaning to userspace programs, other than to distinguish it from other handles and invalid handles.
	Call GetProcessImageFileName to get the name of the main executable module of the process.
	Use EnumProcessModules to enumerate the list of all modules in the target process.
	For each module, call GetModuleFileNameEx to get the filename, and compare it with the executable's filename.
	When you've found the executable's module, call GetModuleInformation to get the raw entry point of the executable.
*/


	_MODULEINFO := "
					(
					  LPVOID lpBaseOfDll;
					  DWORD  SizeOfImage;
					  LPVOID EntryPoint;
				  	)"
	Process, Exist, %process%
	if ErrorLevel 							; PROCESS_QUERY_INFORMATION + PROCESS_VM_READ
		hProc := DllCall("OpenProcess", "uint", 0x0400 | 0x0010 , "int", 0, "uint", ErrorLevel)
	if !hProc
		return -2
	VarSetCapacity(mainExeNameBuffer, 2048 * (A_IsUnicode ? 2 : 1))
	DllCall("psapi\GetModuleFileNameEx", "uint", hProc, "Uint", 0
				, "Ptr", &mainExeNameBuffer, "Uint", 2048 / (A_IsUnicode ? 2 : 1))
	mainExeName := StrGet(&mainExeNameBuffer)
	; mainExeName = main executable module of the process
	size := VarSetCapacity(lphModule, 4)
	loop
	{
		DllCall("psapi\EnumProcessModules", "uint", hProc, "Ptr", &lphModule
				, "Uint", size, "Uint*", reqSize)
		if ErrorLevel
			return -3, DllCall("CloseHandle","uint",hProc)
		else if (size >= reqSize)
			break
		else
			size := VarSetCapacity(lphModule, reqSize)
	}
	VarSetCapacity(lpFilename, 2048 * (A_IsUnicode ? 2 : 1))
	loop % reqSize / A_PtrSize ; sizeof(HMODULE) - enumerate the array of HMODULEs
	{
		DllCall("psapi\GetModuleFileNameEx", "uint", hProc, "Uint", numget(lphModule, (A_index - 1) * 4)
				, "Ptr", &lpFilename, "Uint", 2048 / (A_IsUnicode ? 2 : 1))
		if (mainExeName = StrGet(&lpFilename))
		{
			moduleInfo := struct(_MODULEINFO)
			DllCall("psapi\GetModuleInformation", "uint", hProc, "Uint", numget(lphModule, (A_index - 1) * 4)
				, "Ptr", moduleInfo[], "Uint", SizeOf(moduleInfo))
			;return moduleInfo.SizeOfImage, DllCall("CloseHandle","uint",hProc)
			return moduleInfo.lpBaseOfDll, DllCall("CloseHandle","uint",hProc)
		}
	}
	return -1, DllCall("CloseHandle","uint",hProc) ; not found
}

;}

;{Systemfunktionen - using COMObjecte
getURL(t) {     using shell.application
	If	psh	:=	COM_CreateObject("Shell.Application") {
		If	psw	:=	COM_Invoke(psh,	"Windows") {
			Loop, %	COM_Invoke(psw,	"Count")
				If	url	:=	(InStr(COM_Invoke(psw,"Item[" A_Index-1 "].LocationName"),t) && InStr(COM_Invoke(psw,"Item[" A_Index-1 "].FullName"), "iexplore.exe")) ? COM_Invoke(psw,"Item[" A_Index-1 "].LocationURL") :
					Break
			COM_Release(psw)
		}
		COM_Release(psh)
	}
	Return	url
}


;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{UI Automation
CreatePropertyCondition(propertyId, ByRef var, type :="Variant") {     ;möge diese hier funktionieren
		If (A_PtrSize=8) {
			if (type!="Variant")
			UIA_Variant(var,type,var)
			return UIA_Hr(DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId, "ptr",&var, "ptr*",out))? new UIA_PropertyCondition(out):
		} else {
			if (type<>8)
				return UIA_Hr(DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId, "int64",type, "int64", var, "ptr*",out))? new UIA_PropertyCondition(out):
			else
			{
				vart:=DllCall("oleaut32\SysAllocString", "wstr",var,"ptr")
				return UIA_Hr(DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId, "int64",type, "ptr", vart, "ptr", 0, "ptr*",out))? new UIA_PropertyCondition(out):
			}
		}
	}

CreatePropertyCondition(propertyId, ByRef var, type := "Variant") {        ;oder diese besser sein
        ; CREDITS: Elgin, http://ahkscript.org/boards/viewtopic.php?f=5&t=6979&p=43985#p43985
        ; Parameters:
        ;   propertyId  - An ID number of the property to check.
        ;   var         - The value to check for.  Can be a variant, number, or string.
        ;   type        - The data type.  Can be the string "Variant", or one of standard
        ;                 variant type such as VT_I4, VT_BSTR, etc.
        local out:="", hr, bstr
        If (A_PtrSize = 8)
        {
            if (type!="Variant")
                UIA_Variant(var,type,var)
            hr := DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId, "ptr",&var, "ptr*",out)
            if (type!="Variant")
                UIA_VariantClear(&var)
            return UIA_Hr(hr)? new UIA_PropertyCondition(out):
        }
        else ; 32-bit.
        {
            if (type <> 8)
                return UIA_Hr(DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId
                            , "int64",type, "int64",var, "ptr*",out))? new UIA_PropertyCondition(out):
            else ; It's type is VT_BSTR.
            {
                bstr := DllCall("oleaut32\SysAllocString", "wstr",var, "ptr")
                hr := DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId
                            , "int64",type, "ptr",bstr, "ptr",0, "ptr*",out)
                DllCall("oleaut32\SysFreeString", "ptr", bstr)
                return UIA_Hr(hr)? new UIA_PropertyCondition(out):
            }
        }
    }

CreatePropertyConditionEx(propertyId, ByRef var, type := "Variant", flags := 0x1) {
        ; PropertyConditionFlags_IgnoreCase = 0x1
        local out:="", hr, bstr

        If (A_PtrSize = 8) {
            if (type!="Variant")
                UIA_Variant(var,type,var)
            hr := DllCall(this.__vt(24), "ptr",this.__Value, "int",propertyId
                        , "ptr",&var, "uint",flags, "ptr*",out)
            if (type!="Variant")
                UIA_VariantClear(&var)
            return UIA_Hr(hr)? new UIA_PropertyCondition(out):
        }
        else ; 32-bit.
        {
            if (type <> 8)
                return UIA_Hr(DllCall(this.__vt(24), "ptr",this.__Value, "int",propertyId
                            , "int64",type, "int64",var
                            , "uint",flags, "ptr*",out))? new UIA_PropertyCondition(out):
            else ; It's type is VT_BSTR.
            {
                bstr := DllCall("oleaut32\SysAllocString", "wstr",var, "ptr")
                hr := DllCall(this.__vt(24), "ptr",this.__Value, "int",propertyId
                            , "int64",type, "ptr",bstr, "ptr",0, "uint",flags, "ptr*",out)
                DllCall("oleaut32\SysFreeString", "ptr", bstr)
                return UIA_Hr(hr)? new UIA_PropertyCondition(out):
            }
        }
    }

getControlNameByHwnd(_, controlHwnd) {
	UIAutomation := ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}", "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
	DllCall(NumGet(NumGet(UIAutomation+0)+6*A_PtrSize), "Ptr", UIAutomation, "Ptr", controlHwnd, "Ptr*", IUIAutomationElement)
	DllCall(NumGet(NumGet(IUIAutomationElement+0)+29*A_PtrSize), "Ptr", IUIAutomationElement, "Ptr*", automationId)
	ret := StrGet(automationId,, "UTF-16")
	DllCall("oleaut32\SysFreeString", "Ptr", automationId)
	ObjRelease(IUIAutomationElement)
	ObjRelease(UIAutomation)
	return ret
}

;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{ACC (MSAA) verschiedene Varianten

Acc_Get(Cmd, ChildPath="", ChildID=0, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="") {
	static properties := {Action:"DefaultAction", DoAction:"DoDefaultAction", Keyboard:"KeyboardShortcut"}
	AccObj :=   IsObject(WinTitle)? WinTitle
			:   Acc_ObjectFromWindow( WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText), 0 )
	if ComObjType(AccObj, "Name") != "IAccessible"
		ErrorLevel := "Could not access an IAccessible Object"
	else {
		StringReplace, ChildPath, ChildPath, _, %A_Space%, All
		AccError:=Acc_Error(), Acc_Error(true)
		Loop Parse, ChildPath, ., %A_Space%
			try {
				if A_LoopField is digit
					Children:=Acc_Children(AccObj), m2:=A_LoopField ; mimic "m2" output in else-statement
				else
					RegExMatch(A_LoopField, "(\D*)(\d*)", m), Children:=Acc_ChildrenByRole(AccObj, m1), m2:=(m2?m2:1)
				if Not Children.HasKey(m2)
					throw
				AccObj := Children[m2]
			} catch {
				ErrorLevel:="Cannot access ChildPath Item #" A_Index " -> " A_LoopField, Acc_Error(AccError)
				if Acc_Error()
					throw Exception("Cannot access ChildPath Item", -1, "Item #" A_Index " -> " A_LoopField)
				return
			}
		Acc_Error(AccError)
		StringReplace, Cmd, Cmd, %A_Space%, , All
		properties.HasKey(Cmd)? Cmd:=properties[Cmd]:
		try {
			if (Cmd = "Location")
				AccObj.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
			      , ret_val := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
			else if (Cmd = "Object")
				ret_val := AccObj
			else if Cmd in Role,State
				ret_val := Acc_%Cmd%(AccObj, ChildID+0)
			else if Cmd in ChildCount,Selection,Focus
				ret_val := AccObj["acc" Cmd]
			else
				ret_val := AccObj["acc" Cmd](ChildID+0)
		} catch {
			ErrorLevel := """" Cmd """ Cmd Not Implemented"
			if Acc_Error()
				throw Exception("Cmd Not Implemented", -1, Cmd)
			return
		}
		return ret_val, ErrorLevel:=0
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}
Acc_Error(p="") {
   static setting:=0
   return p=""?setting:setting:=p
}
Acc_ChildrenByRole(Acc, Role) {
   if ComObjType(Acc,"Name")!="IAccessible"
      ErrorLevel := "Invalid IAccessible Object"
   else {
      Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
      if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
         Loop %cChildren% {
            i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i)
            if NumGet(varChildren,i-8)=9
               AccChild:=Acc_Query(child), ObjRelease(child), Acc_Role(AccChild)=Role?Children.Insert(AccChild):
            else
               Acc_Role(Acc, child)=Role?Children.Insert(child):
         }
         return Children.MaxIndex()?Children:, ErrorLevel:=0
      } else
         ErrorLevel := "AccessibleChildren DllCall Failed"
   }
   if Acc_Error()
      throw Exception(ErrorLevel,-1)
}

getControlNameByHwnd(winHwnd,controlHwnd) { ;ACC Version wahrscheinlich
	bufSize=1024
	winget,processID,pid,ahk_id %winHwnd%
	VarSetCapacity(var1,bufSize)
	getName:=DllCall( "RegisterWindowMessage", "str", "WM_GETCONTROLNAME" )
	dwResult:=DllCall("GetWindowThreadProcessId", "UInt", winHwnd)
	hProcess:=DllCall("OpenProcess", "UInt", 0x8 | 0x10 | 0x20, "Uint", 0, "UInt", processID)
	otherMem:=DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "PTR", bufSize, "UInt", 0x3000, "UInt", 0x0004, "Ptr")

	SendMessage,%getName%,%bufSize%,%otherMem%,,ahk_id %controlHwnd%
	DllCall("ReadProcessMemory","UInt",hProcess,"UInt",otherMem,"Str",var1,"UInt",bufSize,"UInt *",0)
	DllCall("CloseHandle","Ptr",hProcess)
	DllCall("VirtualFreeEx","Ptr", hProcess,"UInt",otherMem,"UInt", 0, "UInt", 0x8000)
	return var1

}

;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Internet Explorer/Chrome/FireFox/HTML Funktionen
; AutoHotkey_L: von jethrow
IEGet(name="") {
   IfEqual, Name,, WinGetTitle, Name, ahk_class IEFrame ; Get active window if no parameter
   Name := (Name="New Tab - Windows Internet Explorer")? "about:Tabs":RegExReplace(Name, " - (Windows|Microsoft) Internet Explorer")
   for WB in ComObjCreate("Shell.Application").Windows
      if WB.LocationName=Name and InStr(WB.FullName, "iexplore.exe")
         return WB
}
; AHK Basic:
IEGet(name="") {
   IfEqual, Name,, WinGetTitle, Name, ahk_class IEFrame ; Get active window if no parameter
   Name := (Name="New Tab - Windows Internet Explorer") ? "about:Tabs":RegExReplace(Name, " - (Windows|Microsoft) Internet Explorer")
   oShell := COM_CreateObject("Shell.Application") ; Contains reference to all explorer windows
   Loop, % COM_Invoke(oShell, "Windows.Count") {
      if pwb := COM_Invoke(oShell, "Windows", A_Index-1)
         if COM_Invoke(pwb, "LocationName")=name and InStr(COM_Invoke(pwb, "FullName"), "iexplore.exe")
            Break
      COM_Release(pwb), pwb := ""
   }
   COM_Release(oShell)
   return, pwb
}
; AutoHotkey_L:
WBGet(WinTitle="ahk_class IEFrame", Svr#=1) { ; based on ComObjQuery docs
	static	msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
	,	IID := "{0002DF05-0000-0000-C000-000000000046}" ; IID_IWebBrowserApp
;	,	IID := "{332C4427-26CB-11D0-B483-00C04FD90119}" ; IID_IHTMLWindow2
	SendMessage msg, 0, 0, Internet Explorer_Server%Svr#%, %WinTitle%
	if (ErrorLevel != "FAIL") {
		lResult:=ErrorLevel, VarSetCapacity(GUID,16,0)
		if DllCall("ole32\CLSIDFromString", "wstr","{332C4425-26CB-11D0-B483-00C04FD90119}", "ptr",&GUID) >= 0 {
			DllCall("oleacc\ObjectFromLresult", "ptr",lResult, "ptr",&GUID, "ptr",0, "ptr*",pdoc)
			return ComObj(9,ComObjQuery(pdoc,IID,IID),1), ObjRelease(pdoc)
		}
	}
}
; AHK Basic:
WBGet(WinTitle="ahk_class IEFrame", Svr#=1) { ; based on Sean's GetWebBrowser function
	static msg, IID := "{332C4427-26CB-11D0-B483-00C04FD90119}" ; IID_IWebBrowserApp
	if Not msg
		msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
	SendMessage msg, 0, 0, Internet Explorer_Server%Svr#%, %WinTitle%
	if (ErrorLevel != "FAIL") {
		lResult:=ErrorLevel, GUID:=COM_GUID4String(IID_IHTMLDocument2,"{332C4425-26CB-11D0-B483-00C04FD90119}")
		DllCall("oleacc\ObjectFromLresult", "Uint",lResult, "Uint",GUID, "int",0, "UintP",pdoc)
		return COM_QueryService(pdoc,IID,IID), COM_Release(pdoc)
	}
}
;
wb := WBGet()				;inner HTML
MsgBox % wb.document.documentElement.innerHTML
WBGet(WinTitle="ahk_class IEFrame", Svr#=1) { ; based on ComObjQuery docs
   static   msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
         ,  IID := "{332C4427-26CB-11D0-B483-00C04FD90119}" ; IID_IWebBrowserApp
   SendMessage msg, 0, 0, Internet Explorer_Server%Svr#%, %WinTitle%
   if (ErrorLevel != "FAIL") {
      lResult:=ErrorLevel, VarSetCapacity(GUID,16,0)
      if DllCall("ole32\CLSIDFromString", "wstr","{332C4425-26CB-11D0-B483-00C04FD90119}", "ptr",&GUID) >= 0 {
         DllCall("oleacc\ObjectFromLresult", "ptr",lResult, "ptr",&GUID, "ptr",0, "ptr*",pdoc)
         return ComObj(9,ComObjQuery(pdoc,IID,IID),1), ObjRelease(pdoc)
      }
   }
}
; Firefox
SetTitleMatchMode 2
MsgBox % Acc_Get("Value", "4.20.2.4.2", 0, "Firefox")
MsgBox % Acc_Get("Value", "application1.property_page1.tool_bar2.combo_box1.editable_text1", 0, "Firefox")
Acc_Get(Cmd, ChildPath="", ChildID=0, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="") {
	static properties := {Action:"DefaultAction", DoAction:"DoDefaultAction", Keyboard:"KeyboardShortcut"}
	AccObj :=   IsObject(WinTitle)? WinTitle
			:   Acc_ObjectFromWindow( WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText), 0 )
	if ComObjType(AccObj, "Name") != "IAccessible"
		ErrorLevel := "Could not access an IAccessible Object"
	else {
		StringReplace, ChildPath, ChildPath, _, %A_Space%, All
		AccError:=Acc_Error(), Acc_Error(true)
		Loop Parse, ChildPath, ., %A_Space%
			try {
				if A_LoopField is digit
					Children:=Acc_Children(AccObj), m2:=A_LoopField ; mimic "m2" output in else-statement
				else
					RegExMatch(A_LoopField, "(\D*)(\d*)", m), Children:=Acc_ChildrenByRole(AccObj, m1), m2:=(m2?m2:1)
				if Not Children.HasKey(m2)
					throw
				AccObj := Children[m2]
			} catch {
				ErrorLevel:="Cannot access ChildPath Item #" A_Index " -> " A_LoopField, Acc_Error(AccError)
				if Acc_Error()
					throw Exception("Cannot access ChildPath Item", -1, "Item #" A_Index " -> " A_LoopField)
				return
			}
		Acc_Error(AccError)
		StringReplace, Cmd, Cmd, %A_Space%, , All
		properties.HasKey(Cmd)? Cmd:=properties[Cmd]:
		try {
			if (Cmd = "Location")
				AccObj.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
			      , ret_val := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
			else if (Cmd = "Object")
				ret_val := AccObj
			else if Cmd in Role,State
				ret_val := Acc_%Cmd%(AccObj, ChildID+0)
			else if Cmd in ChildCount,Selection,Focus
				ret_val := AccObj["acc" Cmd]
			else
				ret_val := AccObj["acc" Cmd](ChildID+0)
		} catch {
			ErrorLevel := """" Cmd """ Cmd Not Implemented"
			if Acc_Error()
				throw Exception("Cmd Not Implemented", -1, Cmd)
			return
		}
		return ret_val, ErrorLevel:=0
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}
Acc_Error(p="") {
   static setting:=0
   return p=""?setting:setting:=p
}
Acc_ChildrenByRole(Acc, Role) {
   if ComObjType(Acc,"Name")!="IAccessible"
      ErrorLevel := "Invalid IAccessible Object"
   else {
      Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
      if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
         Loop %cChildren% {
            i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i)
            if NumGet(varChildren,i-8)=9
               AccChild:=Acc_Query(child), ObjRelease(child), Acc_Role(AccChild)=Role?Children.Insert(AccChild):
            else
               Acc_Role(Acc, child)=Role?Children.Insert(child):
         }
         return Children.MaxIndex()?Children:, ErrorLevel:=0
      } else
         ErrorLevel := "AccessibleChildren DllCall Failed"
   }
   if Acc_Error()
      throw Exception(ErrorLevel,-1)
}
VARIANTstruct() { ;so wahrscheinlich nicht funktionsfähig
	DllCall("LoadLibrary",str,"oleacc", ptr)

	VarSetCapacity(Point, 8, 0)
	DllCall("GetCursorPos", ptr, &Point)

	DllCall("oleacc\AccessibleObjectFromPoint", "int64", NumGet(Point, 0, "int64"), ptrp, pAccessible, ptr, &varChild)

	; get vtable for IAccessible
	vtAccessible :=  NumGet(pAccessible+0, "ptr")

	; call get_accName() through the vtable
	hr := DllCall(NumGet(vtAccessible+0, 10*A_PtrSize, "ptr"), ptr, pAccessible,"int64", 3, "int64", 0,"int64", 0 ptrp, pvariant)
	; variant's type is VT_I4 = 3
	; variant's value is CHILDID_SELF = 0

	; get_accName returns the following hresult error with 64 bit ahk
	hr_facility := (0x07FF0000 & hr) >>16	; shows facility = 7 "win32"
	hr_code := 0x0000ffff & hr		; code 1780 "RPC_X_NULL_REF_POINTER"

}

;}
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;{Variablen Handling
ComVar(Type:=0xC) { ; open to learn how it works
    ;   ComVar: Creates an object which can be used to pass a value ByRef.
    ;   ComVar[] retrieves the value.
    ;   ComVar[] := Val sets the value.
    ;   ComVar.ref retrieves a ByRef object for passing to a COM function.

    static base := { __Get: "ComVarGet", __Set: "ComVarSet" }
    ; Create an array of 1 VARIANT.  This method allows built-in code to take
    ; care of all conversions between VARIANT and AutoHotkey internal types.
    arr := ComObjArray(Type, 1)
    ; Retrieve a pointer to the VARIANT.
    arr_data := NumGet(ComObjValue(arr)+8+A_PtrSize)
    ; Store the array and an object which can be used to pass the VARIANT ByRef.
    return { ref: ComObject(0x4000|Type, arr_data), _: arr, base: base }
}
ComVarGet(cv, p*) { ; Called when script accesses an unknown field.
    if p.MaxIndex() = "" ; No name/parameters, i.e. cv[]
        return cv._[0]
}
ComVarSet(cv, v, p*) { ; Called when script sets an unknown field.
    if p.MaxIndex() = "" ; No name/parameters, i.e. cv[]:=v
        return cv._[0] := v
}



;}

;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;----- NOT SORTED FUNCTION OR FUNCTION I CANT IDENTIFY - but looks interesting
Highlight(reg, delay=1500 {

    ;{-------------------------------------------------------------------------------
    ;
    ; Function: Highlight
    ; Description:
    ;		Show a red rectangle outline to highlight specified region, it's useful to debug
    ; Syntax: Highlight(region [, delay = 1500])
    ; Parameters:
    ;		reg - The region for highlight
    ;		delay - Show time (milliseconds)
    ; Return Value:
    ;		 Real string without variable(s) - "this string has real variable"
    ; Related:
    ;		SendSpiCall, SendWapiCall
    ; Remarks:
    ;		#Include, Gdip.ahk
    ; Example:
    ;		Highlight("100,200,300,400")
    ;		Highlight("100,200,300,400", 1000)
    ;
    ;-------------------------------------------------------------------------------
    ;}

    global @reg_global
; Start gdi+
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
	}

	StringSplit, g_coors, @reg_global, `,
	; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
	Width := g_coors3
	Height := g_coors4
    ; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	Gui, 1: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop

	; Show the window
	Gui, 1: Show, NA

	; Get a handle to this window we have created in order to update it later
	hwnd1 := WinExist()

	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
	hbm := CreateDIBSection(Width, Height)

	; Get a device context compatible with the screen
	hdc := CreateCompatibleDC()

	; Select the bitmap into the device context
	obm := SelectObject(hdc, hbm)

	; Get a pointer to the graphics of the bitmap, for use with drawing functions
	G := Gdip_GraphicsFromHDC(hdc)

	; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
	Gdip_SetSmoothingMode(G, 4)


	; Create a slightly transparent (66) blue pen (ARGB = Transparency, red, green, blue) to draw a rectangle
	; This pen is wider than the last one, with a thickness of 10
	pPen := Gdip_CreatePen(0xffff0000, 2)

	; Draw a rectangle onto the graphics of the bitmap using the pen just created
	; Draws the rectangle from coordinates (250,80) a rectangle of 300x200 and outline width of 10 (specified when creating the pen)

	StringSplit, reg_coors, reg, `,
	x := reg_coors1
	y := reg_coors2
	w := reg_coors3 - reg_coors1
	h := reg_coors4 - reg_coors2

	Gdip_DrawRectangle(G, pPen, x, y, w, h)

	; Delete the brush as it is no longer needed and wastes memory
	Gdip_DeletePen(pPen)

	; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
	; So this will position our gui at (0,0) with the Width and Height specified earlier
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)

	; Select the object back into the hdc
	SelectObject(hdc, obm)

	; Now the bitmap may be deleted
	DeleteObject(hbm)

	; Also the device context related to the bitmap may be deleted
	DeleteDC(hdc)

	; The graphics may now be deleted
	Gdip_DeleteGraphics(G)
	Sleep, %delay%
	Gui, 1: Show, Hide
	Gdip_Shutdown(pToken)
}

monitorInfo(){
	sysget,monitorCount,monitorCount
	arr:=[],sorted:=[]
	loop % monitorCount {
		sysget,mon,monitor,% a_index
		arr.insert({l:monLeft,r:monRight,b:monBottom,t:monTop,w:monRight-monLeft+1,h:monBottom-monTop+1})
		k:=a_index
		while strlen(k)<3
			k:="0" k
		sorted[monLeft k]:=a_index
	}
	arr2:=[]
	for k,v in sorted
		arr2.insert(arr[v])
	return arr2
}
/*
	return [current monitor, monitor count]
*/
whichMonitor(x="",y="",byref monitorInfo=""){
	CoordMode,mouse,screen
	if (x="" || y="")
		mousegetpos,x,y
	if !IsObject(monitorInfo)
		monitorInfo:=monitorInfo()

	for k,v in monitorInfo
		if (x>=v.l&&x<=v.r&&y>=v.t&&y<=v.b)
			return [k,monitorInfo.maxIndex()]
}

# 23 Un/Fold #Region
command.name.23.$(ahk)=Toggle Fold #Region
command.23.*.ahk=dostring local text = editor:GetText() tReg = {} pos, iEnd = text:find('#[Rr][Ee][Gg][Ii][Oo][Nn]') \
if pos ~= nil then table.insert(tReg, pos) while true do \
pos, iEnd = text:find('#[Rr][Ee][Gg][Ii][Oo][Nn]', iEnd) \
if pos == nil then break end table.insert(tReg, pos) end \
for i=1, #tReg do editor:GotoPos(tReg[i]) editor.CurrentPos = tReg[i] \
scite.MenuCommand(IDM_EXPAND) end end
command.mode.23.*=subsystem:lua
command.shortcut.23.*.ahk=Ctrl+Alt+F12

;{AutoHotKey ControlClick Double Click Example
ControlClick2(X, Y, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="")  {
  hwnd:=ControlFromPoint(X, Y, WinTitle, WinText, cX, cY
                             , ExcludeTitle, ExcludeText)
  PostMessage, 0x201, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONDOWN
  PostMessage, 0x202, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONUP
  PostMessage, 0x203, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONDBLCLCK
  PostMessage, 0x202, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONUP
}

ControlFromPoint(X, Y, WinTitle="", WinText="", ByRef cX="", ByRef cY="", ExcludeTitle="", ExcludeText="") {
    static EnumChildFindPointProc=0
    if !EnumChildFindPointProc
        EnumChildFindPointProc := RegisterCallback("EnumChildFindPoint","Fast")

    if !(target_window := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText))
        return false

    VarSetCapacity(rect, 16)
    DllCall("GetWindowRect","uint",target_window,"uint",&rect)
    VarSetCapacity(pah, 36, 0)
    NumPut(X + NumGet(rect,0,"int"), pah,0,"int")
    NumPut(Y + NumGet(rect,4,"int"), pah,4,"int")
    DllCall("EnumChildWindows","uint",target_window,"uint",EnumChildFindPointProc,"uint",&pah)
    control_window := NumGet(pah,24) ? NumGet(pah,24) : target_window
    DllCall("ScreenToClient","uint",control_window,"uint",&pah)
    cX:=NumGet(pah,0,"int"), cY:=NumGet(pah,4,"int")
    return control_window
}

EnumChildFindPoint(aWnd, lParam) {
    if !DllCall("IsWindowVisible","uint",aWnd)
        return true
    VarSetCapacity(rect, 16)
    if !DllCall("GetWindowRect","uint",aWnd,"uint",&rect)
        return true
    pt_x:=NumGet(lParam+0,0,"int"), pt_y:=NumGet(lParam+0,4,"int")
    rect_left:=NumGet(rect,0,"int"), rect_right:=NumGet(rect,8,"int")
    rect_top:=NumGet(rect,4,"int"), rect_bottom:=NumGet(rect,12,"int")
    if (pt_x >= rect_left && pt_x <= rect_right && pt_y >= rect_top && pt_y <= rect_bottom)
    {
        center_x := rect_left + (rect_right - rect_left) / 2
        center_y := rect_top + (rect_bottom - rect_top) / 2
        distance := Sqrt((pt_x-center_x)**2 + (pt_y-center_y)**2)
        update_it := !NumGet(lParam+24)
        if (!update_it)
        {
            rect_found_left:=NumGet(lParam+8,0,"int"), rect_found_right:=NumGet(lParam+8,8,"int")
            rect_found_top:=NumGet(lParam+8,4,"int"), rect_found_bottom:=NumGet(lParam+8,12,"int")
            if (rect_left >= rect_found_left && rect_right <= rect_found_right
                && rect_top >= rect_found_top && rect_bottom <= rect_found_bottom)
                update_it := true
            else if (distance < NumGet(lParam+28,0,"double")
                && (rect_found_left < rect_left || rect_found_right > rect_right
                 || rect_found_top < rect_top || rect_found_bottom > rect_bottom))
                 update_it := true
        }
        if (update_it)
        {
            NumPut(aWnd, lParam+24)
            DllCall("RtlMoveMemory","uint",lParam+8,"uint",&rect,"uint",16)
            NumPut(distance, lParam+28, 0, "double")
        }
    }
    return true
}
;}

/* EXAMPLES

ImageFile := A_ScriptDir "\logo.gif"
if !FileExist(ImageFile)
    UrlDownloadToFile, http://www.autohotkey.com/docs/images/AutoHotkey_logo.gif, % ImageFile

GetImageDimensions(ImageFile, w, h)
msgbox % "Width:`t" w "`nHeight:`t" h

----------------------------------------------------------------------------------------------------

HTML =
(
<p align="center">Copyright 2011 A_Samurai. All rights reserved.</p>
<p>Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:</p>
<ul>
    <li>Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.</li>
    <li>Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.</li>
</ul>
<p>THIS SOFTWARE IS PROVIDED BY A_Samurai ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL A_Samurai OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
    OF THE POSSIBILITY OF SUCH DAMAGE.</p>
<p>The views and conclusions contained in the software and documentation are those of the authors and should not be
    interpreted as representing official policies, either expressed or implied, of A_Samurai.</p>
)
HtmlBox(HTML, "Free BSD Licence")

----------------------------------------------------------------------------------------------

#persistent
;this is the same as right clicking on the folder and selecting Copy.
if InvokeVerb(A_MyDocuments "\AutoHotkey", "Copy")
    msgbox copied
else
    msgbox not copied

;Opens the property window of Recycle Bin
InvokeVerb("::{645ff040-5081-101b-9f08-00aa002f954e}", "Properties")


path := A_ScriptDir "\Test"
FileCreateDir, % path
;this is the same as right clicking on the folder and selecting Delete.
InvokeVerb(path, "Delete")

---------------------------------------------------------------------------------------------------
;istControlFocused
Gui, Margin, 20, 20
Gui, Add, Text,, Set focus to one of the fields and press F1
Gui, Add, Edit, w100 hwndHwndEdit, Test
Gui, Add, Edit, w100 hwndHwndEdit2, Test2
Gui, Show, % "x" A_ScreenWidth // 2 - 120
Gui, 2:Margin, 20, 20
Gui, 2:Add, Text,, Set focus to one of the fields and press F1
Gui, 2:Add, Edit, w100 hwndHwndEdit3, Test4
Gui, 2:Add, Edit, w100 hwndHwndEdit4, Test3
Gui, 2:Show, % "x" A_ScreenWidth // 2 + 120
return
F1:: msgbox % IsControlFocused(HwndEdit) ? "Edit1 is focused." : "Edit1 is not focused."
GuiClose:
2GuiClose:
ExitApp

-------------------------------------------------------------------------------------------------------
;ObjMerge
ObjD := { test1 : "MyFunc"}
ObjA := { a: "aaa", b: "bbb", c: "ccc", base: ObjD}
ObjC := { test2 : "MyFunc"}
ObjB := { 1: "111", 2: "222", a: "new", base: ObjC}

if ObjMerge(ObjA, ObjB)
    For k, v in ObjA
        list .= "key: " k " value: "v "`n"
msgbox % list
ObjA.test1("hi")
ObjA.test2("hello")

MyFunc(this, params*) {
    msgbox % A_ThisFunc ": " params.1
}

--------------------------------------------------------------------------------------------------------

#Persistent
Gui, Font, s20
Gui, Margin, 30, 30
Gui, Add, Text,, Click Here
Gui, Show
OnMessage(0x200, "MyFuncA")     ;a function registered via OnMessage() will be added in the list when OnMessageEx() is called for the first time.
OnMessageEx(0x200, "MyFuncB")
OnMessageEx(0x200, "MyFuncC")
OnMessageEx(0x201, "MyFuncD")
OnMessageEx(0x201, "MyFuncE")
OnMessageEx(0x201, "MyFuncF")
OnMessageEx(0x201, "MyFuncD")   ;a duplicated item will be removed and the function is inserted again
Return
GuiClose:
ExitApp

F1::msgbox % "Function Removed: " OnMessageEx(0x200, "")    ;removes the function in the lowest priority for 0x200
F2::msgbox % "Function Removed: " OnMessageEx(0x201, "")    ;removes the function in the lowest priority for 0x201
F3::msgbox % "The lowest priority function for 0x200 is: " OnMessageEx(0x200)
F4::msgbox % "The lowest priority function for 0x201 is: " OnMessageEx(0x201)
F5::msgbox % "Function Removed: " OnMessageEx(0x201, "MyFuncF", 0)    ;removes MyFuncF from 0x201

MyFuncA(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex - 200, , 1
    SetTimer, RemoveToolTipA, -1000
    Return
    RemoveToolTipA:
        tooltip,,,,1
    Return
}
MyFuncB(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex,, 2
    SetTimer, RemoveToolTipB, -1000
    Return
    RemoveToolTipB:
        tooltip,,,,2
    Return
}
MyFuncC(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex + 200 ,, 3
    SetTimer, RemoveToolTipC, -1000
    Return
    RemoveToolTipC:
        tooltip,,,,3
    Return
}
MyFuncD(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex - 200, mousey - 80, 4
    SetTimer, RemoveToolTipD, -1000
    Return
    RemoveToolTipD:
        tooltip,,,,4
    Return
}
MyFuncE(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex, mousey - 80, 5
    SetTimer, RemoveToolTipE, -1000
    Return
    RemoveToolTipE:
        tooltip,,,,5
    Return
}
MyFuncF(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex + 200 , mousey - 80, 6
    SetTimer, RemoveToolTipF, -1000
    Return
    RemoveToolTipF:
        tooltip,,,,6
    Return
}

-----------------------------------------------------------------------------------------------------------

#Persistent
Gui, Font, s20
Gui, Margin, 30, 30
Gui, Add, Text,, Click Here
Gui, Show

Obj := {MyMethodA : Func("MyFuncA"), MyMethodB : Func("MyFuncB")}
OnMessageEx(0x200, [&Obj, "MyMethodA"])
OnMessageEx(0x201, [&Obj, "MyMethodB", False])

Return
GuiClose:
ExitApp

F1::Obj.MyMethodA := ""     ;remove the function reference. That is, the method no longer exists
F2::Obj.MyMethodB := ""     ;since the Auto-Remove option is disabled, this function name is still stored in the stack object.
F3::msgbox % "Function Removed: " OnMessageEx(0x201, "MyMethodB", 0)        ;to manually remove it

MyFuncA(this, wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex - 200, , 1
    SetTimer, RemoveToolTipA, -1000
    Return
    RemoveToolTipA:
        tooltip,,,,1
    Return
}
MyFuncB(this, wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex - 200, mousey - 80, 2
    SetTimer, RemoveToolTipB, -1000
    Return
    RemoveToolTipB:
        tooltip,,,,2
    Return
}

-----------------------------------------------------------------------------------------------------------------------

TDArray := [{Name:"File1", Path:"C:\tmp\File1.txt", Type:"txt", CreationDate:20101111}
        ,    {Name:"Folder2", Path:"C:\tmp\Folder2", Type:"Folder", CreationDate:20070725}
        ,    {Name:"test", Path:"D:\Projects\test.csv", Type:"CSV", CreationDate:20090228}
        ,    {Name:"001", Path:"E:\images\001.jpg", Type:"jpg", CreationDate:20100501}
        ,    {Name:"Windows", Path:"C:\Windows\", Type:21, CreationDate:20111010}]


Sort2DArray(TDArray, "Name")
For index, obj in TDArray
   list3 .= TDArray[index].Name . "`n"
msgbox % list3

Sort2DArray(TDArray, "CreationDate", 0)
For index, obj in TDArray
   list4 .= TDArray[index].CreationDate . "`n"
msgbox % list4

---------------------------------------------------------------------------------------------------------------------------

Array1 := [ "b", "f", "e", "c", "d", "a", "h", "g" ]
Array2 := [ "100", "333", "987", "54", "1", "0", "-263", "543" ]

SortArray(Array1)
Loop, % Array1.MaxIndex()
    list1 .= Array1[A_Index] . "`n"
msgbox % list1

SortArray(Array2, "D")
Loop, % Array2.MaxIndex()
    list2 .= Array2[A_Index] . "`n"
msgbox % list2

SortArray(Array1, "R")
Loop, % Array1.MaxIndex()
    list3 .= Array1[A_Index] . "`n"
msgbox % list3

-----------------------------------------------------------------------------------------------------------------------------

$a::DelaySend("a", 1500)
$s::DelaySend("s", 500)
$d::DelaySend("d", 200, "SendInput")

^Right::DelaySend("{Media_Next}", 500)
^Left::DelaySend("{Media_Prev}", 500)

----------------------------------------------------------------------------------------------------------------------------
;EditBox

Text =
(
    Copyright 2011 A_Samurai. All rights reserved.

    Redistribution and use in source and binary forms, with or without modification, are
    permitted provided that the following conditions are met:

       1. Redistributions of source code must retain the above copyright notice, this list of
          conditions and the following disclaimer.

       2. Redistributions in binary form must reproduce the above copyright notice, this list
          of conditions and the following disclaimer in the documentation and/or other materials
          provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY A_Samurai ''AS IS'' AND ANY EXPRESS OR IMPLIED
    WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
    FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL A_Samurai OR
    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    The views and conclusions contained in the software and documentation are those of the
    authors and should not be interpreted as representing official policies, either expressed
    or implied, of A_Samurai.
)
EditBox(Text, "Free BSD Licence")

-----------------------------------------------------------------------------------------------------------------------------------
;Dateieigenschaften anzeigen

#NoEnv
SetBatchLines, -1
FilePath := A_ScriptDir . "\ACC.ahk" ; anpassen
Breite := 162  ; Win7 x64 Deutsch
Höhe   := 164  ; Win7 x64 Deutsch
Gui, Margin, 20, 20
Gui, Add, Text, , %FilePath%
Gui, Add, ListView, w600 r20 Grid vLV +E0x010000, Index|Name|Inhalt
Gui, Add, Button, vBTN1 gListDetails, Liste der möglichen Eigenschaften
GuiControlGet, BTN1, Pos
Gui, Add, Button, x+20 yp wp vBTN2 gFileDetails, Eigenschaften der Datei
GuiControl, Move, BTN2, % "x" . (620 - BTN1W)
Gui, Show, , Dateieigenschaften

GuiCLose:
ExitApp

FileDetails:
   LV_Delete()
   FileDetails := FileGetDetails(FilePath)
   For I, V In FileDetails
      LV_Add("", I, V*)
   LV_ModifyCol(1, "AutoHdr")
   LV_ModifyCol(2, "AutoHdr")
   LV_ModifyCol(3, "AutoHdr")
   MsgBox, 0, Breite & Höhe, % FilePath . "`r`n"
                             . "Breite:`t" . FileGetDetail(FilePath, Breite) . "`r`n"
                             . "Höhe:`t" . FileGetDetail(FilePath, Höhe)
Return

ListDetails:
   LV_Delete()
   Details := GetDetails()
   For I, V In Details
      If I Is Integer
         LV_Add("", I, V)
   LV_ModifyCol(1, "AutoHdr")
   LV_ModifyCol(2, "AutoHdr")
Return

;-------------------------------------------------------------------------------------------------------------------------



*/
