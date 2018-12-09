class LoadPictureType {
	static IMAGE_BITMAP:=0, IMAGE_ICON:=1, IMAGE_CURSOR:=2
	doAutoFreeHandles:=false
	__new(Filename, options:="", ImageType:=0, bkColor:=0x000000, xHotspot:=0, yHotspot:=0,keepBITMAP:=false){
		this.keepBITMAP:=keepBITMAP
		bkColor:=this.rgbToBgr(bkColor)
		this.hImg:=this.LoadPicture(Filename,options)
		this.type:=ImageType
		if (ImageType==LoadPictureType.IMAGE_BITMAP)
			return this
		else if (ImageType==LoadPictureType.IMAGE_ICON)
			this.makeIcon(bkColor)
		else if (ImageType==LoadPictureType.IMAGE_CURSOR)
			this.makeCursor(bkColor,xHotspot, yHotspot)
		else{
			this.deleteObject(this.hImg)
			throw Exception("Invalid image type: " ImageType ".")
		}
	}
	getBitmap(){
		; The BITMAP contains data for the bitmap, see _getBitmap(.) method for more details.
		if (!this.BITMAP && this.type==IMAGE_BITMAP)
			this.BITMAP:=this._getBitmap(this.hImg)	; havn't tried this with an icon or cursor handle
		if this.BITMAP
			return this.BITMAP
	}
	setAutoFreeHandles(bool:=true){
		return this.doAutoFreeHandles:=bool
	}
	getHandle(){
		return this.hImg
	}
	freeHandle(){
		if !this.hImg
			return
		if (this.type==this.IMAGE_BITMAP)
			this.deleteObject(this.hImg)
		else if (this.type==this.IMAGE_ICON)
			this.destroyIcon(this.hImg)
		else if (this.type==this.IMAGE_CURSOR)
			this.destroyCursor(this.hImg)
		return this.hImg:=""
	}
	; Internal methods.
	__Delete(){
		(this.doAutoFreeHandles ? this.freeHandle() : "")
	}
	LoadPicture(Filename,options:=""){
		local hBitmap
		if !hBitmap:=LoadPicture(Filename,options)
			throw Exception("LoadPicture failed.")
		return hBitmap
	}
	makeIcon(bkColor){	
		local hIcon:=this.createIconIndirect(this.hImg, true, bkColor)
		this.deleteSourceBitmap() ;  conditional
		this.hImg:=hIcon
		return
	}
	makeCursor(bkColor, xHotspot:=0, yHotspot:=0){
		local hCursor:=this.createIconIndirect(this.hImg, false, bkColor, xHotspot, yHotspot)
		this.deleteSourceBitmap() ;  conditional
		this.hImg:=hCursor
		return
	}
	deleteSourceHBITMAP:=true
	deleteSourceBitmap(){
		if this.deleteSourceHBITMAP
			this.deleteObject(this.hImg)
		return
	}
	createIconIndirect(hBitmap, fIcon:=1, bkColor:=0x000000, xHotspot:=0, yHotspot:=0){
		/*
		ICONINFO:				sz				o
		BOOL    fIcon;			4				0
		DWORD   xHotspot;		4				4
		DWORD   yHotspot;		4				8
		pad						ps=4?0:4			
		HBITMAP hbmMask;		ps				ps=4?12:16
		HBITMAP hbmColor;		ps				ps=4?16:24
		
		total:					ps=4?20:32
		*/
		
		local bmps:=this.andXOrBitmap(hBitmap,bkColor)
		local ICONINFO
		VarSetCapacity(ICONINFO, A_PtrSize==4?20:32,0)
		NumPut(fIcon, 			ICONINFO, 				   0, "Int")
		NumPut(xHotspot, 		ICONINFO, 				   4, "Int")
		NumPut(yHotspot, 		ICONINFO, 				   8, "Int")
		NumPut(bmps.hbmMask, 	ICONINFO, A_PtrSize==4?12:16, "Ptr")
		NumPut(bmps.hbmColor, 	ICONINFO, A_PtrSize==4?16:24, "Ptr")
		
		local hIcon := DllCall("User32.dll\CreateIconIndirect", "Ptr", &ICONINFO, "Ptr")
		if !hIcon
			throw Exception("CreateIconIndirect failed, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".")
		local k, obj
		for k, obj in bmps.disposableObjects
			this.deleteObject(obj)
		return hIcon
	}
	andXOrBitmap(hBitmap,bkColor){
		; Logic ported from:
		;	https://www.experts-exchange.com/questions/20259566/CreateIconIndirect.html#a6763928
		; Scope: this is the reference from __new()
		local r:=LoadPictureType ; For convenience - r - reference 
		local BITMAP:=r._getBitmap(hBitmap)
		if (BITMAP.bitsPixel != 24)
			BITMAP := r.convertBITMAPtoXbpp(24,BITMAP, hBitmap)
		(this.keepBITMAP ? this.BITMAP:=BITMAP :"")
		local hClientDC:=r.getDc()
		local hDCCreate         	:=	r.createCompatibleDC(hClientDC)
		local hDCImage          	:=	r.createCompatibleDC(hClientDC)	
		local hDCAnd	            :=	r.createCompatibleDC(hClientDC)
		local hDCXOr    	        :=	r.createCompatibleDC(hClientDC)

		local hDDB          		:=	r.createCompatibleBitmap(hClientDC, BITMAP.w, BITMAP.h)
		local hXOrBitmap		    :=	r.createCompatibleBitmap(hClientDC, BITMAP.w, BITMAP.h)
		local hAndBitmap     		:=	r.createBitmap(BITMAP.w, BITMAP.h, BITMAP.widthBytes, 1, 0)
		
		local BITMAPINFO
		r.BITMAPtoStruct(BITMAP, BITMAPINFO) ; BITMAPINFO is byref
		r.setDIBits(hDCCreate, hDDB, 0, BITMAP.h, BITMAP.bits, &BITMAPINFO, 0)
		r.deleteDC(hDCCreate)
		
		; Create the AND Mask bitmap
		local hOldAndBitmap     := r.selectObject(hDCAnd, hAndBitmap)
		local hOldImageBitmap   := r.selectObject(hDCImage, hDDB)
		local hOldXorBitmap     := r.selectObject(hDCXOr, hXOrBitmap)
		; Create the monochrome mask bitmap from the source image using the background color
		local crOld := r.setBkColor(hDCImage, bkColor)
		static SRCCOPY:=0x00CC0020
		r.bitBlt(hDCAnd, 0, 0, BITMAP.w, BITMAP.h, hDCImage, 0, 0, SRCCOPY)
		r.setBkColor(hDCImage, crOld)
		
		; Create the XOR color bitmap
		r.bitBlt(hDCXOr, 0, 0, BITMAP.w, BITMAP.h, hDCImage, 0, 0, SRCCOPY)
		r.bitBlt(hDCXOr, 0, 0, BITMAP.w, BITMAP.h, hDCAnd, 0, 0, 0x220326)
		
		r.selectObject(hDCImage, hOldImageBitmap)
		r.selectObject(hDCAnd, hOldAndBitmap)
		r.selectObject(hDCXOr, hOldXorBitmap)

		r.deleteDC(hDCXOr)
		r.deleteDC(hDCImage)
		r.deleteDC(hDCAnd)

		r.releaseDC(0,hClientDC)		
		return {hbmMask:hAndBitmap, hbmColor:hXOrBitmap, disposableObjects:[hDDB,hAndBitmap,hXOrBitmap]}
	}
	convertBITMAPtoXbpp(bpp, BITMAP, hBitmap){
		local r:=LoadPictureType ; For convenience - r - reference 
		local hClientDC			:= r.getDc()
		BITMAP.bitsPixel:=bpp	
		local BITMAPINFO
		r.BITMAPtoStruct(BITMAP, BITMAPINFO) ; BITMAPINFO is byref
		local newHBITMAP 		:= r.CreateDIBSection(&BITMAPINFO,hClientDC).1	; Returns [hDIB, ppvBits]
		local hDCSource			:= r.createCompatibleDC(hClientDC)
		local hDCDest			:= r.createCompatibleDC(hClientDC)	
		local hOldhBitmap		:= r.selectObject(hDCSource, hBitmap)
		local hOldnewHBITMAP    := r.selectObject(hDCDest, newHBITMAP)
		static SRCCOPY:=0x00CC0020
		r.bitBlt(hDCDest, 0, 0, BITMAP.w, BITMAP.h, hDCSource, 0, 0, SRCCOPY)
		r.selectObject(hDCSource, hOldhBitmap)
		r.selectObject(hDCDest, hOldnewHBITMAP)
		r.deleteDC(hDCSource)
		r.deleteDC(hDCDest)
		r.releaseDC(0,hClientDC)
		r.deleteObject(hOldhBitmap)
		r.deleteObject(hOldnewHBITMAP)
		return r._getBitmap(newHBITMAP)
	}
	BITMAPtoStruct(BITMAP, ByRef BITMAPINFO){
		; Create bitmap info struct
		VarSetCapacity(BITMAPINFO, 40, 0)
		/*
		DWORD biSize;					4
		LONG  biWidth;					4
		LONG  biHeight;					4	
		WORD  biPlanes;					2
		WORD  biBitCount;				2
		DWORD biCompression;			4
		DWORD biSizeImage;				4
		LONG  biXPelsPerMeter;			4
		LONG  biYPelsPerMeter;			4
		DWORD biClrUsed;				4
		DWORD biClrImportant;			4	
		Total:							40
		*/
		static BI_RGB:=0
		static biSize:=40
		NumPut(biSize, 				BITMAPINFO,  0, "Uint")			; biSize
		NumPut(BITMAP.w,			BITMAPINFO,  4, "Uint")			; biWidth
		NumPut(BITMAP.h, 			BITMAPINFO,  8, "Uint")			; biHeight;
		NumPut(BITMAP.planes,		BITMAPINFO, 12, "Ushort")       ; biPlanes;
		NumPut(BITMAP.bitsPixel,	BITMAPINFO, 14, "Ushort")       ; biBitCount;
		NumPut(BI_RGB, 				BITMAPINFO, 16, "Uint")     	; biCompression;
		return
	}
	getDC(hWnd:=0){
		local hDc
		if !(hDc:=DllCall("User32.dll\GetDC", "Ptr", hWnd, "Ptr"))
			throw Exception("Failed to get the device context, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return hDc
	}
	deleteDC(hDc){
		if !DllCall("Gdi32.dll\DeleteDC", "Ptr", hDc)
			throw Exception("Failed to delete the device context, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return true
	}
	createCompatibleDC(hDc){
		local hRet
		if !(hRet:=DllCall("Gdi32.dll\CreateCompatibleDC", "Ptr", hDc, "Ptr"))
			throw Exception("Failed to create a compatible device context, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return hRet
	}
	createCompatibleBitmap(hdc,w,h){
		local hBitmap
		if !(hBitmap:=DllCall("Gdi32.dll\CreateCompatibleBitmap", "Ptr", hdc, "Int", w, "Int", h, "Ptr"))
			throw Exception("Failed to create a compatible bitmap, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return hBitmap
	}
	setDIBits(hdc,hbmp,uStartScan,cScanLines,lpvBits,lpbmi,fuColorUse){
		static DIB_RGB_COLORS:=0
		local nLines
		if !(nLines:=DllCall("Gdi32.dll\SetDIBits", "Ptr", hdc, "Ptr", hbmp, "Uint", uStartScan, "Uint", cScanLines, "Ptr", lpvBits, "Ptr", lpbmi, "Uint", fuColorUse))
			throw Exception("Failed to set DIBbits, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return nLines
	}
	CreateDIBSection(BITMAPINFO, hDC){
		; URL:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/dd183494(v=vs.85).aspx (CreateDIBSection function)
		; Note:
		;	- If the function succeeds, the return value is a handle to the newly created DIB, and *ppvBits points to the bitmap bit values.
		;	  If the function fails, the return value is NULL, and *ppvBits is NULL.
		;
		static DIB_RGB_COLORS:=0 ; iUsage
		local ppvBits
		local hDIB:=DllCall("Gdi32.dll\CreateDIBSection", "Ptr", hDC, "Ptr", BITMAPINFO, "Uint", DIB_RGB_COLORS, "PtrP", ppvBits, "Ptr", 0, "Uint", 0, "Ptr")
		if !hDIB
			throw exception("CreateDIBSection failed, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return [hDIB,ppvBits]
	}
	selectObject(hdc, hgdiobj){
		static HGDI_ERROR:=0xFFFFFFFF
		local hRet:=DllCall("Gdi32.dll\SelectObject", "Ptr", hDc, "Ptr", hgdiobj, "Ptr")
		if (hRet==HGDI_ERROR)
			throw Exception("Failed to select object, Error: " HGDI_ERROR ", ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		else if !hRet
			throw Exception("Failed to select object, Error: NULL,  ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return hRet
	}
	setBkColor(hDc,bkColor){
		static CLR_INVALID:=0xFFFFFFFF
		local prevBkColor:=DllCall("Gdi32.dll\SetBkColor", "Ptr", hDc, "Uint", bkColor)
		if (prevBkColor==CLR_INVALID)
			throw Exception("Failed to select object, Error: CLR_INVALID =" CLR_INVALID "  ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return prevBkColor
	}
	bitBlt(hdcDest, nXDest, nYDest, nWidth, nHeight, hdcSrc, nXSrc, nYSrc, dwRop){
		if !DllCall("Gdi32.dll\BitBlt", "Ptr", hdcDest, "Int", nXDest, "Int", nYDest, "Int", nWidth, "Int",nHeight, "Ptr", hdcSrc, "Int",nXSrc, "Int", nYSrc, "UInt", dwRop)
			throw Exception("BitBlt failed,  ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return true
	}
	releaseDC(hWnd,hDc){
		if !DllCall("User32.dll\ReleaseDC", "Ptr", hWnd, "Ptr", hDC)
			throw  Exception("Failed to release device context,  ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return true
	}
	deleteObject(hObject){
		if !DllCall("Gdi32.dll\DeleteObject", "Ptr", hObject)
			throw Exception("Failed to delete object,  ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return true
	}
	destroyCursor(hCursor){
		if !DllCall("User32.dll\DestroyCursor", "Ptr", hCursor)
			throw Exception("Failed to destroy cursor,  ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return true
	}
	destroyIcon(hIcon){
		if !DllCall("User32.dll\DestroyIcon", "Ptr", hIcon)
			throw Exception("Failed to destroy icon,  ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return true
	}
	_getBitmap(hBitmap){
		; Url:
		; 	- https://msdn.microsoft.com/en-us/library/windows/desktop/dd144904%28v=vs.85%29.aspx 	(GetObject function)
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/dd183371(v=vs.85).aspx		(BITMAP structure)
		/*
		typedef struct tagBITMAP {
		  LONG   bmType;
		  LONG   bmWidth;
		  LONG   bmHeight;
		  LONG   bmWidthBytes;
		  WORD   bmPlanes;
		  WORD   bmBitsPixel;
		  LPVOID bmBits;
		} BITMAP, *PBITMAP;
		*/
		
		static pBits:=A_PtrSize==4?20:24
		local BITMAP,cbBuffer,nBytes
		
		if !(cbBuffer:=DllCall("Gdi32.dll\GetObject", "Ptr", hBitmap, "Int", cbBuffer, "Ptr",0))	; Get the requiered size of the buffer (BITMAP)
			throw Exception("Failed to get the requiered buffer size, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		VarSetCapacity(BITMAP,cbBuffer,0)
		if !(nBytes:=DllCall("Gdi32.dll\GetObject", "Ptr", hBitmap, "Int", cbBuffer, "Ptr", &BITMAP) == cbBuffer)	; Get the BITMAP
			throw Exception("Failed to get the bitmap object, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		
		BITMAP	:=	{type:				NumGet(&BITMAP,		 0, 	"Int")						 ; bmType
					,w:					NumGet(&BITMAP,		 4, 	"Int")						 ; bmWidth
					,h:					NumGet(&BITMAP,		 8, 	"Int")                       ; bmHeight
					,widthBytes:		NumGet(&BITMAP,		12,		"Int")                       ; bmWidthBytes
					,planes:			NumGet(&BITMAP,		16,	 "UShort")                       ; bmPlanes
					,bitsPixel:			NumGet(&BITMAP,		18,  "UShort")                       ; bmBitsPixel
					,bits:				NumGet(&BITMAP,	 pBits, 	"Ptr")}                      ; bmBits
		
		return BITMAP
	}
	createBitmap(w,h,widthBytes,cBitsPerPel:=32, lpvBitsIsNull:=false){
		static cPlanes:=1
		local hBitmap, lpvBits,pBits
		if lpvBitsIsNull
			pBits:=0
		else
			VarSetCapacity(lpvBits, widthBytes*h*cBitsPerPel,0), pBits:=&lpvBits
		if !(hBitmap:=DllCall("Gdi32.dll\CreateBitmap", "Int", w, "Int", h, "Uint", cPlanes, "Uint", cBitsPerPel, "Ptr",  pBits, "Ptr"))
			throw Exception("Failed to create bitmap, ErrorLevel: " ErrorLevel " Last error: " A_LastError ".",-1)
		return hBitmap
	}
	rgbToBgr(rgb){
		return (rgb&0x0000ff)<<16 | ((rgb&0x00ff00)>>8)<<8 | (rgb>>16)
	}
}

