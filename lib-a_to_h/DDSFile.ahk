global DDS_PIXELFORMAT := "DWORD dwSize; DWORD dwFlags; DWORD dwFourCC; DWORD dwRGBBitCount; DWORD dwRBitMask; "
.  "DWORD dwGBitMask; DWORD dwBBitMask; DWORD dwABitMask;"

global DDS_HEADER := struct("DWORD dwSize; DWORD  dwFlags; DWORD dwHeight; DWORD dwWidth; DWORD dwPitchOrLinearSize; "
.  "DWORD dwDepth; DWORD dwMipMapCount; DWORD dwReserved1[11]; DDS_PIXELFORMAT ddspf; DWORD dwCaps; DWORD dwCaps2; "
.  "DWORD dwCaps3; DWORD dwCaps4; DWORD dwReserved2;")

DDS_PIXELFORMAT := struct(DDS_PIXELFORMAT)
global DDPF_RGB := 0x00000040
global DDPF_ALPHAPIXELS := 0x00000001
global BITMAPINFOHEADER := "DWORD biSize, LONG biWidth, LONG biHeight, WORD biPlanes, WORD biBitCount, DWORD biCompression,"
. " DWORD biSizeImage, LONG biXPelsPerMeter, LONG biYPelsPerMeter, DWORD biClrUsed, DWORD biClrImportant"
BITMAPINFOHEADER := struct(BITMAPINFOHEADER)
global BITMAPFILEHEADER := struct("WORD bfType; DWORD bfSize; DWORD bfReserved; DWORD bfOffBits;")

setFilePixelFormat(format = "RGB")
{
	if (format = "RGB") 	{
			DDS_PIXELFORMAT.dwFlags := DDPF_RGB 
			DDS_PIXELFORMAT.dwSize := DDS_PIXELFORMAT.size()	
			DDS_PIXELFORMAT.dwRGBBitCount := 16
			DDS_PIXELFORMAT.dwRBitMask := 0xF800
			DDS_PIXELFORMAT.dwGBitMask := 0x07e0
			DDS_PIXELFORMAT.dwBBitMask := 0x001F			
		}
	else if (format = "RGB24") 	{
			DDS_PIXELFORMAT.dwFlags := DDPF_RGB 
			DDS_PIXELFORMAT.dwSize := DDS_PIXELFORMAT.size()	
			DDS_PIXELFORMAT.dwRGBBitCount := 24
			DDS_PIXELFORMAT.dwRBitMask := 0x00FF0000
			DDS_PIXELFORMAT.dwGBitMask := 0x0000FF00
			DDS_PIXELFORMAT.dwBBitMask := 0x000000FF		
		}		
	else if (format = "XRGB") 	{
			DDS_PIXELFORMAT.dwFlags := DDPF_RGB 
			DDS_PIXELFORMAT.dwSize := DDS_PIXELFORMAT.size()	
			DDS_PIXELFORMAT.dwRGBBitCount := 16
			DDS_PIXELFORMAT.dwRBitMask := 0x00007C00  
			DDS_PIXELFORMAT.dwGBitMask := 0x000003E0
			DDS_PIXELFORMAT.dwBBitMask := 0x0000001F
		}	
			
	else if (format = "ARGB16") 	{
			DDS_PIXELFORMAT.dwFlags := DDPF_RGB | DDPF_ALPHAPIXELS
			DDS_PIXELFORMAT.dwSize := DDS_PIXELFORMAT.size()	
			DDS_PIXELFORMAT.dwRGBBitCount := 16
			DDS_PIXELFORMAT.dwRBitMask := 0x00007C00  
			DDS_PIXELFORMAT.dwGBitMask := 0x000003E0
			DDS_PIXELFORMAT.dwBBitMask := 0x0000001F
			DDS_PIXELFORMAT.dwABitMask := 0x00008000
		}		
		
	else if (format = "ARGB")	{	
			DDS_PIXELFORMAT.dwFlags := DDPF_RGB | DDPF_ALPHAPIXELS
			DDS_PIXELFORMAT.dwSize := DDS_PIXELFORMAT.size("ddpfPixelFormat")	
			DDS_PIXELFORMAT.dwRGBBitCount := 32
			DDS_PIXELFORMAT.dwRBitMask := 0x00FF0000
			DDS_PIXELFORMAT.dwGBitMask := 0x0000FF00
			DDS_PIXELFORMAT.dwBBitMask := 0x000000FF
			DDS_PIXELFORMAT.dwABitMask := 0xFF000000
		}	
	else if (format = "ABGR")	{	
			DDS_PIXELFORMAT.dwFlags := DDPF_RGB | DDPF_ALPHAPIXELS
			DDS_PIXELFORMAT.dwSize := DDS_PIXELFORMAT.size("ddpfPixelFormat")	
			DDS_PIXELFORMAT.dwRGBBitCount := 32
			DDS_PIXELFORMAT.dwRBitMask := 0x000000FF 
			DDS_PIXELFORMAT.dwGBitMask := 0x0000FF00
			DDS_PIXELFORMAT.dwBBitMask := 0x00FF0000
			DDS_PIXELFORMAT.dwABitMask := 0xFF000000
		}		
}	

getFilePixelFormat(byref fileHeader)
{
	if (fileHeader.ddspf.dwRGBBitCount = 32)
	{
		if fileHeader.ddspf.dwRBitMask =  0x00FF0000
			return "ARGB"
		else if fileHeader.ddspf.dwRBitMask = 0x000000FF 
			return	"ABGR"
	}
	else if (fileHeader.ddspf.dwRGBBitCount = 24)
		return "RGB24"
	else
	{
		if (fileHeader.ddspf.dwRBitMask = 0xF800)
			return "RGB"
		else if (fileHeader.ddspf.dwRBitMask = 0x00007C00)
		{
			if (fileHeader.ddspf.dwRGBAlphaBitMask = 0x00008000)
				return "ARGB16"
			else return	"XRGB"	
		}
	}
}

class DDSDump
{	
	__delete() {
		dllcall("VirtualFree", uint, this.data, uint, 0, uint, (MEM_RELEASE := 0x8000) )
	}
}

makeDumpStructArray(byref lst)
{
	static dump := struct("DWORD ww; DWORD hh; DWORD bypp; DWORD pData, BOOL isOptimized")
	
	VarSetCapacity(dumpStructArray, dump.size() * lst._MaxIndex())
	dump[] := &dumpStructArray
	
	for k, v in lst
	{
		dump.ww := v.h
		dump.hh := v.w
		dump.bypp := v.bypp
		dump.pData := v.data
		dump.isOptimized := v.optimized
		dump[] += dump.size()
	}
	return &dumpStructArray
}	

loadDumpCollection(dir, byref lst)
{
	FileGetAttrib, att, %dir%
	if not instr(att, "D")
		return loadCompiledDumpCollection(file, lst)
	
	loop, %dir%\*.dds, 0, 0
	{
		file := FileOpen(A_loopfilefullpath, "r")
		print("Loading dump: " A_loopfilename " bytes`n")
		file.seek(4)
								
		Newmem(DDS_HEADER)
		file.RawRead(DDS_HEADER[], DDS_HEADER.size())
		if not DDS_HEADER.dwWidth
			continue
							
		;pdata := DllCall("GlobalAlloc", "uint", 0x0040, "uint", file.Length - DDS_HEADER.size(), ptr)
		pdata := dllcall("VirtualAlloc", uint, 0, uint, file.Length - DDS_HEADER.size(), "Int", 0x00001000 ;| 0x00002000
									   , uint, (PAGE_READWRITE := 0x04) )				
		file.RawRead(pdata+0, file.Length - DDS_HEADER.size() - 4)
		file.close()
					
		textdump := new DDSDump()
		textdump.w := DDS_HEADER.dwWidth   
		textdump.h := DDS_HEADER.dwHeight
		textdump.bypp := DDS_HEADER.dwPitchOrLinearSize/DDS_HEADER.dwWidth 
		textdump.bitdepth := DDS_HEADER.ddspf.dwRGBBitCount
		textdump.data := pdata
		textdump.fname := A_loopfilename 	
		textdump.optimized := False		
		lst.insert(textdump)				
	}
	;return makeDumpStructArray(lst)
}	

loadCompiledDumpCollection(file, byref lst)
{
	if not fileexist(file)
		return
	
	FileGetAttrib, att, %file%
	if instr(att, "D")
		return loadDumpCollection(file, lst)
	
	header := DDS_HEADER.clone()
	
	f := fileopen(file, "r")
	if not isobject(f)
		return 0
		
	n_files := f.readUshort()
	samples := f.readUshort()
	files := []
	offsets := []
	loop, %n_files%
	{
		VarSetCapacity(data, 518, 0)
		f.rawread(&data, 518)
		entry := {}
		entry.name := strget(&data, "UTF-8")
		entry.offset := numget(data, 510, "uint")
		entry.size := numget(data, 514, "uint")
		files.insert( entry ) 		
	}
		
	for k, v in files 
	{
		print( v.name " " v.offset " " v.size "`n")
			
		f.seek(v.offset + 4)
							
		print( "read: " f.RawRead(header[], header.size()) " bytes`n")
		;if not DDS_HEADER.dwWidth
			;continue
		print("Dumpsize: " header.dwSize ": " header.dwWidth "x" header.dwHeight "`n")
					
		;pdata := DllCall("GlobalAlloc", "uint", 0x0040, "uint", file.Length - DDS_HEADER.size(), ptr)
		pdata := dllcall("VirtualAlloc", uint, 0, uint, v.size - header.size() - 4, "Int", 0x00001000 ;| 0x00002000
									   , uint, (PAGE_READWRITE := 0x04) )		
									   
		f.RawRead(pdata+0, v.size - 4 - header.size())
										
		textdump := new DDSDump()
		textdump.w := header.dwWidth   
		textdump.h := header.dwHeight
		textdump.bypp := header.dwPitchOrLinearSize/header.dwWidth 
		textdump.bitdepth := header.ddspf.dwRGBBitCount
		textdump.data := pdata
		textdump.fname := v.name  	
		textdump.optimized := True	
		textdump.samples := samples	
		lst.insert(textdump)		
	}			
	f.close()
	;return makeDumpStructArray(lst)
}

LoadTextureDumps(path = "")
{
	g_textSwap.dumps := []
	if not path
		path := g_textSwap.path
	
	if fileexist(path "\Dumps\dump._dds")		
		g_textSwap.pDumpArray := loadCompiledDumpCollection(g_textSwap.path "\Dumps\dump._dds", g_textSwap.dumps)
	else 
		g_textSwap.pDumpArray := loadDumpCollection(g_textSwap.path "\Dumps", g_textSwap.dumps)	
				
	for kk, vv in g_textSwap.dumps {
		if not vv.replacement
			vv.replacement := path "\Replacements\" vv.fname
		}			
}

compareSurfaceData(byref dump, byref desc, samples = 8, optimized = False)
{
	static RtlCompareMemory := dllcall("GetProcAddress", uint, dllcall("GetModuleHandle", str, "ntdll.dll"), astr, "RtlCompareMemory")
	
	if ( (desc.dwWidth != dump.w) or (desc.dwHeight != dump.h) 
	      or ((desc.lPitch/desc.dwWidth) != dump.bypp) )
		return False	
		
	jump := round(desc.dwHeight/samples)	
	
	if not optimized {	
	loop, %samples%
		{		
			if dllcall(RtlCompareMemory, "uint", dump.data + dump.w * dump.bypp * jump * (A_index - 1)
								       , "uint", desc.lpSurface + desc.lPitch * jump * (A_index - 1)
									   , "uint", dump.w * dump.bypp, uint) < dump.w * dump.bypp								   
				return False				
		}		
	}
	else {
		loop, %samples%
		{	
			if dllcall(RtlCompareMemory, "uint", dump.data + dump.w * dump.bypp * (A_index - 1)
								       , "uint", desc.lpSurface + desc.lPitch * jump * (A_index - 1)
									   , "uint", dump.w * dump.bypp, uint) < dump.w * dump.bypp								   
				return False				
		}		
	}	
	return true		
}
