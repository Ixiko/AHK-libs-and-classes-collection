;
; AutoHotkey Version: 1.1.30.00
; Language:       English
; Platform:       Optimized for Windows 10
; Author:         Sam.
;

;;;;;	Reference Documents	;;;;;
; http://www.fileformat.info/format/bmp/egff.htm
; https://msdn.microsoft.com/en-us/library/dd183381.aspx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;      PS_BMP v0.0.01a      ;;;;;
;;;;;  Copyright (c) 2018 Sam.  ;;;;;
;;;;;   Last Updated 20180925   ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


/*
Global Console:=New PushLog("//////////////////////////////////////////////////`r`n///// PS_BMP v0.00a, Copyright (c) 2018 Sam. /////`r`n//////////////////////////////////////////////////","",2)


try {

hBMP:=New PSBMP()
;~ hBMP.LoadBMPFromFile("C:\Programs\AutoHotkey Scripts\PS BAM\MooseN\AMOOG1\AMOOG100000.bmp")
;~ hBMP.LoadBMPFromFile("C:\Users\spschmit\Desktop\Discovery.bmp")
;~ hBMP.LoadBMPFromFile("C:\Programs\AutoHotkey Scripts\PS_BMP\EE Examples\1CHELMX6.bmp")
hBMP.LoadBMPFromFile("C:\Programs\AutoHotkey Scripts\PS_Quantization\Arches_12.5.bmp")
;~ hBMP.LoadBMPFromFile("C:\Programs\AutoHotkey Scripts\PS_BMP\Test32.bmp")
hBMP.SetColorTransparency(0,255,0,0) ; 100% Transparency for TransColor
hBMP.SetColorTransparency(0,0,0,128) ; 50% Transparency for Shadow Color
hBMP.SaveBMPToFile(A_ScriptDir "\Test.bmp",24,3)


} catch e {
	; throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "", extra: ""}
	Console.Send("Exception thrown!`n`nWhat	=	" e.what "`nFile	=	" e.file "`nLine	=	" e.line "`nMessage	=	" e.message "`nExtra	=	" e.extra "`r`n","E")
	ThrowMsg(16,"Error!","Exception thrown!`n`nWhat	=	" e.what "`nFile	=	" e.file "`nLine	=	" e.line "`nMessage	=	" e.message "`nExtra	=	" e.extra)
	}



OnExit:
hBMP:=""
Console:=""
ExitApp
*/

class PSBMP{
	LoadBMPFromFile(InputPath){
		tic:=QPC(1)
		Console.Send("Loading image from '" InputPath "'`r`n","-W")
		file:=FileOpen(InputPath,"r-d")
			this.Stats:={}
			this.InputPath:=InputPath
			this.Stats.OriginalFileSize:=file.Length, Console.Send("OriginalFileSize=" this.Stats.OriginalFileSize "`r`n","I")
			this.Stats.FileSize:=file.Length, Console.Send("FileSize=" this.Stats.FileSize "`r`n","I")
			this.Raw:=" ", this.SetCapacity("Raw",this.Stats.FileSize), DllCall("RtlFillMemory","Ptr",this.GetAddress("Raw"),"UInt",this.Stats.FileSize,"UChar",0)
			file.RawRead(this.GetAddress("Raw"),this.Stats.FileSize)
			file.Close()
		this.DataMem:=New MemoryFileIO(this.GetAddress("Raw"),this.Stats.FileSize)
		Console.Send("Image loaded into memory in " (QPC(1)-tic) " sec.`r`n","-I")
		this._ReadBMP()
		this.Raw:="", this.Delete("Raw"), this.DataMem:=""
		Console.Send("Finished Loading image in " (QPC(1)-tic) " sec.`r`n`r`n","-I")
	}
	SaveBMPToFile(OutputPath,BitDepth:=8,Version:=3){
		tic:=QPC(1)
		Console.Send("Saving image to '" OutputPath "'`r`n")
		Sz:=this._CalculateFileSize(BitDepth,Version)
		this.Raw:=" ", this.SetCapacity("Raw",Sz), DllCall("RtlFillMemory","Ptr",this.GetAddress("Raw"),"UInt",Sz,"UChar",0)
		this.DataMem:=New MemoryFileIO(this.GetAddress("Raw"),Sz)
		this._WriteBMP(BitDepth,Version)
		file:=FileOpen(OutputPath,"w-d")
			file.RawWrite(this.GetAddress("Raw"),Sz)
		file.Close()
		this.Raw:="", this.Delete("Raw"), this.DataMem:=""
		Console.Send("Finished Saving image in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	LoadBMPFromMemory(Address,Size){
		tic:=QPC(1)
		this.Stats:={}
		;this.InputPath:=InputPath
		this.Stats.OriginalFileSize:=Size, Console.Send("OriginalFileSize=" this.Stats.OriginalFileSize "`r`n","I")
		this.Stats.FileSize:=Size, Console.Send("FileSize=" this.Stats.FileSize "`r`n","I")
		this.Raw:=" ", this.SetCapacity("Raw",this.Stats.FileSize), DllCall("RtlFillMemory","Ptr",this.GetAddress("Raw"),"UInt",this.Stats.FileSize,"UChar",0)
		tmp:=New MemoryFileIO(Address+0,Size)
		tmp.RawRead(this.GetAddress("Raw"),this.Stats.FileSize)
		tmp:=""
		this.DataMem:=New MemoryFileIO(this.GetAddress("Raw"),this.Stats.FileSize)
		Console.Send("Image loaded into memory in " (QPC(1)-tic) " sec.`r`n","-I")
		this._ReadBMP()
		this.Raw:="", this.Delete("Raw"), this.DataMem:=""
		Console.Send("Finished Loading image in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	SaveBMPToVar(ByRef Var,BitDepth:=8,Version:=3){
		tic:=QPC(1)
		Sz:=this._CalculateFileSize(BitDepth,Version)
		VarSetCapacity(Var,Sz,0)
		this.DataMem:=New MemoryFileIO(&Var,Sz)
		this._WriteBMP(BitDepth,Version)
		this.DataMem:=""
		Console.Send("Finished Saving image in " (QPC(1)-tic) " sec.`r`n","-I")
		Return Sz
	}
	LoadBMPFromFrameObj(ByRef FrameObj,ByRef PalObj,ByRef FrameObjUP,Width,Height){
		this.FileHeader:={}
			this.FileHeader.FileType:="BM"
		this.BitmapHeader:={}
			this.BitmapHeader.Compression:=0
			this.BitmapHeader.Width:=Width
			this.BitmapHeader.Height:=Height
		this.Palette:={}
		If (IsObject(PalObj))
			{
			Clone:=ObjFullyClone(PalObj)
			While (Clone.MinIndex()>0)
				Clone.RemoveAt(Clone.MinIndex()-1,1)
			this.Palette:=Clone
			}
		this.Frame:={}
		If (IsObject(FrameObj))
			{
			Clone:=ObjFullyClone(FrameObj)
			While (Clone.MinIndex()>0)
				Clone.RemoveAt(Clone.MinIndex()-1,1)
			this.Frame:=Clone
			}
		this.FrameUP:={}
		If (IsObject(FrameObjUP))
			{
			Clone:=ObjFullyClone(FrameObjUP)
			While (Clone.MinIndex()>0)
				Clone.RemoveAt(Clone.MinIndex()-1,1)
			this.FrameUP:=Clone
			}
	}
	GetBMPObjects(ByRef FrameObj,ByRef PalObj,ByRef FrameObjUP,ByRef Width,ByRef Height){
		If IsObject(this.Frame)
			FrameObj:=ObjFullyClone(this.Frame)
		If IsObject(this.Palette)
			PalObj:=ObjFullyClone(this.Palette)
		If IsObject(this.FrameUP)
			FrameObjUP:=ObjFullyClone(this.FrameUP)
		Width:=this.BitmapHeader.Width
		Height:=this.BitmapHeader.Height
	}
	GetFileSize(){
		Return this.Stats.FileSize
	}
	SetColorTransparency(R:=0,G:=255,B:=0,Alpha:=255){
		If (R="") AND (G="") AND (B="")	; Set Alpha of ALL colors
			{
			If IsObject(this.Palette)
				For k,v in this.Palette
						v["AA"]:=Alpha
			If IsObject(this.FrameUP)
				For k,v in this.FrameUP
						v["AA"]:=Alpha
			}
		Else
			{
			If IsObject(this.Palette)
				For k,v in this.Palette
					If (v["RR"]=R) AND (v["GG"]=G) AND (v["BB"]=B)
						v["AA"]:=Alpha
			If IsObject(this.FrameUP)
				For k,v in this.FrameUP
					If (v["RR"]=R) AND (v["GG"]=G) AND (v["BB"]=B)
						v["AA"]:=Alpha
				}
		}
	TransformTransparency(From:="",To:=255){
		If (From="")
			{
			If IsObject(this.Palette)
				For k,v in this.Palette
						v["AA"]:=(To=-1?v["AA"]^255:To)
			If IsObject(this.FrameUP)
				For k,v in this.FrameUP
						v["AA"]:=(To=-1?v["AA"]^255:To)
			}
		Else
			{
			If IsObject(this.Palette)
				For k,v in this.Palette
					If (v["AA"]=From)
						v["AA"]:=(To=-1?v["AA"]^255:To)
			If IsObject(this.FrameUP)
				For k,v in this.FrameUP
					If (v["AA"]=From)
						v["AA"]:=(To=-1?v["AA"]^255:To)
			}
	}
	_ReadBMP(){
		tic:=QPC(1)
		this._ReadFileHeader()
		If (this.FileHeader.FileType="BM")
			{
			this._ReadBitmapHeader()
			PaletteLength:=(this.FileHeader.BitmapOffset-this.BitmapHeader.Size-14)
			If PaletteLength AND (this.BitmapHeader.Compression<>3)
				this._ReadPalette()
			If !(this.BitmapHeader.Compression) AND IsObject(this.Palette) AND (this.BitmapHeader.BitsPerPixel=8)	; Might be our special transport format that stores alpha data in the padding bytes of the Palette.  Let's read this one manually.
				this._ReadImage8UC()
			Else
				this._ReadImageGDI()	; For all others, might as well let GDI do the work.  The only format I'm aware of that this might not work optimally on is RGB101010 (for 32bit bitmaps), as we will only get back 8-bit colors.  IDK if GDI properly translates the quantum values.
			Console.Send("BMP read in " (QPC(1)-tic) " sec.`r`n","-I")
			}
		Else
			{
			this._ReadOtherGDI()
			Console.Send("Image read via GDIP in " (QPC(1)-tic) " sec.`r`n","-I")
			}
	}
	_ReadOtherGDI(){
		this.FileHeader:={}
			this.FileHeader.FileType:="BM"
		this.BitmapHeader:={}
			this.BitmapHeader.Compression:=0
		LocalShutDown:=0
		If !pToken
			pToken:=Gdip_Startup(), LocalShutDown:=1
		pBitmap:=GDIPlus_pBitmapFromBuffer(this.Raw,this.Stats.FileSize,this.GetAddress("Raw"))
		Width:=this.BitmapHeader.Width:=Gdip_GetImageWidth(pBitmap)
		Height:=this.BitmapHeader.Height:=Gdip_GetImageHeight(pBitmap)
		this.Frame:={}, this.FrameUP:={}, this.FrameUP.SetCapacity(Width*Height)
		Index:=A:=R:=G:=B:=0
		Loop, % Abs(Height)
			{
			Idx:=A_Index-1
			Loop, %Width%
				{
				ARGB:=Gdip_GetPixel(pBitmap,A_Index-1,Idx)
				Gdip_FromARGB(ARGB,A,R,G,B)
				this.FrameUP[Index,"RR"]:=R
				this.FrameUP[Index,"GG"]:=G
				this.FrameUP[Index,"BB"]:=B
				this.FrameUP[Index,"AA"]:=A
				Index++
				}
			}
		Gdip_DisposeImage(pBitmap)
		If LocalShutDown
			Gdip_Shutdown(pToken)
	}
	_WriteBMP(BitDepth,Version){
		tic:=QPC(1)
		If (this.FileHeader.FileType="BM") AND (BitDepth=8) AND (Version=3)
			this._WriteFile8V3()
		Else If (this.FileHeader.FileType="BM") AND (BitDepth=24) AND (Version=3)
			this._WriteFile24V3()
		Else If (this.FileHeader.FileType="BM") AND (BitDepth=32) AND (Version=5)
			this._WriteFile32V5()
		Else
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "Bit Depth or BMP Version Number not supported.", extra: "BitDepth=" BitDepth A_Tab "Version=" Version}
		Console.Send("Image written in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	_ReadFileHeader(){
		;;;;;	File Header Block	;;;;;
		Console.Send("File Header Block`r`n","-I")
		this.FileHeader:={}
		this.Stats.OffsetToFileHeader:=this.DataMem.Tell()
			Console.Send("OffsetToFileHeader = " this.Stats.OffsetToFileHeader "`r`n","I")
		this.FileHeader.FileType:=this.DataMem.Read(2)
		If (this.FileHeader.FileType="BM")	; Is >= BMP Version 2
			{
				Console.Send("FileType = " this.FileHeader.FileType "`r`n","I")
			this.FileHeader.FileSize:=this.DataMem.ReadUInt()
				Console.Send("FileSize = " this.FileHeader.FileSize "`r`n","I")
			this.FileHeader.Reserved1:=this.DataMem.ReadUShort()
				Console.Send("Reserved1 = " this.FileHeader.Reserved1 "`r`n","I")
			this.FileHeader.Reserved2:=this.DataMem.ReadUShort()
				Console.Send("Reserved2 = " this.FileHeader.Reserved2 "`r`n","I")
			this.FileHeader.BitmapOffset:=this.DataMem.ReadUInt()
				Console.Send("BitmapOffset = " this.FileHeader.BitmapOffset "`r`n","I")
			}
		Else If (this.FileHeader.FileType="BA")	; Is OS/2 Bitmap
			{
			this.BMPFormat:="OS/2 Bitmap"
				Console.Send("BMPFormat = '" this.BMPFormat "'`r`n","I")
			}
		Else
			{
			this.DataMem.Seek(0,0)
			this.FileHeader.Type:=this.DataMem.ReadWORD()
			If (this.FileHeader.Type=0)	; Is Version 1 Device-Dependent Bitmap (Microsoft Windows 1.x)
				{
				this.FileHeader.FileType:=this.FileHeader.Type
					Console.Send("Type = " this.FileHeader.Type "`r`n","I")
				this.FileHeader.Width:=this.DataMem.ReadWORD()
					Console.Send("Width = " this.FileHeader.Width "`r`n","I")
				this.FileHeader.Height:=this.DataMem.ReadWORD()
					Console.Send("Height = " this.FileHeader.Height "`r`n","I")
				this.FileHeader.ByteWidth:=this.DataMem.ReadWORD()
					Console.Send("ByteWidth = " this.FileHeader.ByteWidth "`r`n","I")
				this.FileHeader.Planes:=this.DataMem.ReadBYTE()
					Console.Send("Planes = " this.FileHeader.Planes "`r`n","I")
				this.FileHeader.BitsPerPixel:=this.DataMem.ReadBYTE()
					Console.Send("BitsPerPixel = " this.FileHeader.BitsPerPixel "`r`n","I")
				this.BMPFormat:="Microsoft Windows 1.x Device-Dependent Bitmap Version 1"
					Console.Send("BMPFormat = '" this.BMPFormat "'`r`n","I")
				Console.Send("External palette for Microsoft Windows 1.x BMP not loaded.  Image data will not be read." "`r`n","W")
				}
			Else	; Is Unknown Bitmap FileType
				{
				path:=this.InputPath
				SplitPath, path, , , OutExtension
				this.BMPFormat:="Unknown Bitmap FileType: " OutExtension
				Console.Send("BMPFormat = '" this.BMPFormat "'`r`n","I")
				}
			}
	}
	_WriteFile8V3(){	;;;;;	8-bit Paletted Windows 3.x BMP	;;;;;
		; http://www.fileformat.info/format/bmp/egff.htm
		/* BMP Version 3 (Microsoft Windows 3.x)
		Offset	Type	Size	Data	Description
		0	WORD	2	FileType	File type, always 4D42h ("BM")
		2	DWORD	4	FileSize	Size of the file in bytes
		6	WORD	2	Reserved1	Always 0
		8	WORD	2	Reserved2	Always 0
		10	DWORD	4	BitmapOffset	Starting position of image data in bytes
		14	DWORD	4	Size	Size of this header in bytes
		18	LONG	4	Width	Image width in pixels
		22	LONG	4	Height	Image height in pixels
		26	WORD	2	Planes	Number of color planes
		28	WORD	2	BitsPerPixel	Number of bits per pixel
		30	DWORD	4	Compression	Compression methods used
		34	DWORD	4	SizeOfBitmap	Size of bitmap in bytes
		38	LONG	4	HorzResolution	Horizontal resolution in pixels per meter
		42	LONG	4	VertResolution	Vertical resolution in pixels per meter
		46	DWORD	4	ColorsUsed	Number of colors in the image
		50	DWORD	4	ColorsImportant	Minimum number of important colors
		*/
		Width:=this.BitmapHeader.Width, Height:=this.BitmapHeader.Height, ScanLinePadding:=0
		While (Mod(Width+ScanLinePadding,4)>0)
			ScanLinePadding++
		FileSize:=1078+Width*Height+ScanLinePadding*Height
		this.DataMem.Seek(0,0)
		this.DataMem.Write("BM",2)
		this.DataMem.WriteUInt(FileSize)
		this.DataMem.WriteUShort(0)
		this.DataMem.WriteUShort(0)
		this.DataMem.WriteUInt(1078)
		this.DataMem.WriteUInt(40)
		this.DataMem.WriteInt(Width)
		this.DataMem.WriteInt(Height)
		this.DataMem.WriteUShort(1)
		this.DataMem.WriteUShort(8)
		this.DataMem.WriteUInt(0)
		this.DataMem.WriteUInt(0)
		this.DataMem.WriteInt(0)
		this.DataMem.WriteInt(0)
		If !GetKeyCount(this.Palette) OR !GetKeyCount(this.Frame)	;!(this.Palette.Length()) OR !(this.Frame.Length())
			{
			Console.Send("Quantizing image color depth to 8-bit.  For large numbers of colors this could take a while...`r`n","I")
			this._QuantizeImage(8)
			}
		this.DataMem.WriteUInt(NumPal:=(this.Palette.Length()+1))
		this.DataMem.WriteUInt(NumPal)
		this.DataMem.Seek(54,0)
		;~ Console.Send("this.Palette = `r`n" st_printArr(this.Palette) "`r`n","I")
		Loop, %NumPal%
			{
			Index:=A_Index-1
			this.DataMem.WriteUChar(this.Palette[Index,"BB"])
			this.DataMem.WriteUChar(this.Palette[Index,"GG"])
			this.DataMem.WriteUChar(this.Palette[Index,"RR"])
			this.DataMem.WriteUChar(this.Palette[Index,"AA"])
			}
		this.DataMem.Seek(1078,0)
		; Here we need to figure out how to flip the rows of pixels and add ScanLinePadding
		Output:=[], Data:=[], Index:=0
		For key, value in this.Frame
			{
			If (Index<Width)
				Data[Index]:=value, Index++
			If (Index=Width)
				{
				Loop, % (ScanLinePadding)
					Data.Push(0)
				Output.InsertAt(0,ShiftArray(Data)*)
				Index:=0, Data:="", Data:=[]
				}
			}
		For key, value in Output
			this.DataMem.WriteUChar(value)
	}
	_WriteFile24V3(){	;;;;;	24-bit Windows 3.x BMP	;;;;;
		; http://www.fileformat.info/format/bmp/egff.htm
		/* BMP Version 3 (Microsoft Windows 3.x)
		Offset	Type	Size	Data	Description
		0	WORD	2	FileType	File type, always 4D42h ("BM")
		2	DWORD	4	FileSize	Size of the file in bytes
		6	WORD	2	Reserved1	Always 0
		8	WORD	2	Reserved2	Always 0
		10	DWORD	4	BitmapOffset	Starting position of image data in bytes
		14	DWORD	4	Size	Size of this header in bytes
		18	LONG	4	Width	Image width in pixels
		22	LONG	4	Height	Image height in pixels
		26	WORD	2	Planes	Number of color planes
		28	WORD	2	BitsPerPixel	Number of bits per pixel
		30	DWORD	4	Compression	Compression methods used
		34	DWORD	4	SizeOfBitmap	Size of bitmap in bytes
		38	LONG	4	HorzResolution	Horizontal resolution in pixels per meter
		42	LONG	4	VertResolution	Vertical resolution in pixels per meter
		46	DWORD	4	ColorsUsed	Number of colors in the image
		50	DWORD	4	ColorsImportant	Minimum number of important colors
		*/
		Width:=this.BitmapHeader.Width, Height:=this.BitmapHeader.Height, ScanLinePadding:=0
		While (Mod(Width*3+ScanLinePadding,4)>0)
			ScanLinePadding++
		FileSize:=54+Width*Height*3+ScanLinePadding*Height
		this.DataMem.Seek(0,0)
		this.DataMem.Write("BM",2)
		this.DataMem.WriteUInt(FileSize)
		this.DataMem.WriteUShort(0)
		this.DataMem.WriteUShort(0)
		this.DataMem.WriteUInt(54)
		this.DataMem.WriteUInt(40)
		this.DataMem.WriteInt(Width)
		this.DataMem.WriteInt(Height)
		this.DataMem.WriteUShort(1)
		this.DataMem.WriteUShort(24)
		this.DataMem.WriteUInt(0)
		this.DataMem.WriteUInt(0)
		this.DataMem.WriteInt(0)
		this.DataMem.WriteInt(0)
		this.DataMem.WriteUInt(0)
		this.DataMem.WriteUInt(0)
		this.DataMem.Seek(54,0)
		If !(this.FrameUP.Length())
			{
			this.FrameUP:="", this.FrameUP:={}, this.FrameUP.SetCapacity(this.Frame.Length()+1)
			Loop, % this.Frame.Length()+1	; B/C 0-indexed
				{
				Index:=A_Index-1
				tmp:=this.Frame[Index]
				this.FrameUP[Index,"RR"]:=this.Palette[tmp,"RR"]
				this.FrameUP[Index,"GG"]:=this.Palette[tmp,"GG"]
				this.FrameUP[Index,"BB"]:=this.Palette[tmp,"BB"]
				this.FrameUP[Index,"AA"]:=this.Palette[tmp,"AA"]
				}
			}
		; Here we need to figure out how to flip the rows of pixels and add ScanLinePadding
		If (Height>0)
			Output:=this._Flip(this.FrameUP,Width,Height)
		Else
			Output:=this.FrameUP
		Index:=0
		For key, value in Output
			{
			If (Index<Width)
				{
				this.DataMem.WriteUChar(value["BB"])
				this.DataMem.WriteUChar(value["GG"])
				this.DataMem.WriteUChar(value["RR"])
				Index++
				}
			If (Index=Width)
				{
				Loop, % (ScanLinePadding)
					this.DataMem.WriteUChar(0)
				Index:=0
				}
			}
	}
	_WriteFile32V5(){	;;;;;	32-bit Windows 5.x BMP	;;;;;
		; http://www.fileformat.info/format/bmp/egff.htm
		/* BMP Version 5 (Microsoft Windows 5.x)
		Offset	Type	Size	Data	Description
		0	WORD	2	FileType	File type, always 4D42h ("BM")
		2	DWORD	4	FileSize	Size of the file in bytes
		6	WORD	2	Reserved1	Always 0
		8	WORD	2	Reserved2	Always 0
		10	DWORD	4	BitmapOffset	Starting position of image data in bytes
		14	DWORD	4	Size	Size of this header in bytes
		18	LONG	4	Width	Image width in pixels
		22	LONG	4	Height	Image height in pixels
		26	WORD	2	Planes	Number of color planes
		28	WORD	2	BitsPerPixel	Number of bits per pixel
		30	DWORD	4	Compression	Compression methods used
		34	DWORD	4	SizeOfBitmap	Size of bitmap in bytes
		38	LONG	4	HorzResolution	Horizontal resolution in pixels per meter
		42	LONG	4	VertResolution	Vertical resolution in pixels per meter
		46	DWORD	4	ColorsUsed	Number of colors in the image
		50	DWORD	4	ColorsImportant	Minimum number of important colors
		54	DWORD	4	RedMask	Mask identifying bits of red component
		58	DWORD	4	GreenMask	Mask identifying bits of green component
		62	DWORD	4	BlueMask	Mask identifying bits of blue component
		66	DWORD	4	AlphaMask	Mask identifying bits of alpha component
		70	DWORD	4	CSType	Color space type
		74	LONG	4	RedX	X coordinate of red endpoint
		78	LONG	4	RedY	Y coordinate of red endpoint
		82	LONG	4	RedZ	Z coordinate of red endpoint
		86	LONG	4	GreenX	X coordinate of green endpoint
		90	LONG	4	GreenY	Y coordinate of green endpoint
		94	LONG	4	GreenZ	Z coordinate of green endpoint
		98	LONG	4	BlueX	X coordinate of blue endpoint
		102	LONG	4	BlueY	Y coordinate of blue endpoint
		106	LONG	4	BlueZ	Z coordinate of blue endpoint
		110	DWORD	4	GammaRed	Gamma red coordinate scale value
		114	DWORD	4	GammaGreen	Gamma green coordinate scale value
		118	DWORD	4	GammaBlue	Gamma blue coordinate scale value
		122	DWORD	4	Intent	Rendering intent for bitmap
		126	DWORD	4	ProfileData	Offset to profile data
		130	DWORD	4	ProfileSize	Size of embedded profile data
		134	DWORD	4	Reserved3	Always 0
		*/
		Width:=this.BitmapHeader.Width, Height:=this.BitmapHeader.Height
		FileSize:=(138+Width*Height*4)
		this.DataMem.Seek(0,0)
		this.DataMem.Write("BM",2)
		this.DataMem.WriteUInt(FileSize)
		this.DataMem.WriteUShort(0)
		this.DataMem.WriteUShort(0)
		this.DataMem.WriteUInt(138)
		this.DataMem.WriteUInt(124)
		this.DataMem.WriteInt(Width)
		this.DataMem.WriteInt(Height)
		this.DataMem.WriteUShort(1)
		this.DataMem.WriteUShort(32)
		this.DataMem.WriteUInt(3)
		this.DataMem.WriteUInt(Width*Height*4)
		this.DataMem.WriteInt(0)
		this.DataMem.WriteInt(0)
		this.DataMem.WriteUInt(0)
		this.DataMem.WriteUInt(0) ; ColorsImportant
		this.DataMem.WriteUInt(16711680)
		this.DataMem.WriteUInt(65280)
		this.DataMem.WriteUInt(255)
		this.DataMem.WriteUInt(4278190080)
		this.DataMem.WriteUInt(1934772034) ; (sRGB)
		this.DataMem.Seek(138,0)
		If !(this.FrameUP.Length())
			{
			this.FrameUP:="", this.FrameUP:={}, this.FrameUP.SetCapacity(this.Frame.Length()+1)
			Loop, % this.Frame.Length()+1	; B/C 0-indexed
				{
				Index:=A_Index-1
				tmp:=this.Frame[Index]
				this.FrameUP[Index,"RR"]:=this.Palette[tmp,"RR"]
				this.FrameUP[Index,"GG"]:=this.Palette[tmp,"GG"]
				this.FrameUP[Index,"BB"]:=this.Palette[tmp,"BB"]
				this.FrameUP[Index,"AA"]:=this.Palette[tmp,"AA"]
				}
			}
		; Here we need to figure out how to flip the rows of pixels
		If (Height>0)
			Output:=this._Flip(this.FrameUP,Width,Height)
		Else
			Output:=this.FrameUP
		For key, value in Output
			{
			this.DataMem.WriteUChar(value["BB"])
			this.DataMem.WriteUChar(value["GG"])
			this.DataMem.WriteUChar(value["RR"])
			this.DataMem.WriteUChar(value["AA"])
			}
	}
	_ReadBitmapHeader(){
		;;;;;	Bitmap Header Block	;;;;;
		Console.Send("Bitmap Header Block`r`n","-I")
		this.BitmapHeader:={}
		this.Stats.OffsetToBitmapHeader:=this.DataMem.Tell()
			Console.Send("OffsetToBitmapHeader = " this.Stats.OffsetToBitmapHeader "`r`n","I")
		this.BitmapHeader.Size:=this.DataMem.ReadUInt()
			Console.Send("Size = " this.BitmapHeader.Size "`r`n","I")
		If (this.BitmapHeader.Size=12)	; BMP Version 2 (Microsoft Windows 2.x)
			{
			this.BitmapHeader.Width:=this.DataMem.ReadShort()
				Console.Send("Width = " this.BitmapHeader.Width "`r`n","I")
			this.BitmapHeader.Height:=this.DataMem.ReadShort()
				Console.Send("Height = " this.BitmapHeader.Height "`r`n","I")
			}
		Else
			{
			this.BitmapHeader.Width:=this.DataMem.ReadInt()
				Console.Send("Width = " this.BitmapHeader.Width "`r`n","I")
			this.BitmapHeader.Height:=this.DataMem.ReadInt()
				Console.Send("Height = " this.BitmapHeader.Height "`r`n","I")
			}
		this.BitmapHeader.Planes:=this.DataMem.ReadUShort()
			Console.Send("Planes = " this.BitmapHeader.Planes "`r`n","I")
		this.BitmapHeader.BitsPerPixel:=this.DataMem.ReadShort()
			Console.Send("BitsPerPixel = " this.BitmapHeader.BitsPerPixel "`r`n","I")
		If (this.BitmapHeader.Size>12)	; /* Fields added for Windows 3.x follow this line */
			{
			this.BitmapHeader.Compression:=this.DataMem.ReadUInt()
				Console.Send("Compression = " this.BitmapHeader.Compression "`r`n","I")
			this.BitmapHeader.SizeOfBitmap:=this.DataMem.ReadUInt()
				Console.Send("SizeOfBitmap = " this.BitmapHeader.SizeOfBitmap "`r`n","I")
			this.BitmapHeader.HorzResolution:=this.DataMem.ReadInt()
				Console.Send("HorzResolution = " this.BitmapHeader.HorzResolution "`r`n","I")
			this.BitmapHeader.VertResolution:=this.DataMem.ReadInt()
				Console.Send("VertResolution = " this.BitmapHeader.VertResolution "`r`n","I")
			this.BitmapHeader.ColorsUsed:=this.DataMem.ReadUInt()
				Console.Send("ColorsUsed = " this.BitmapHeader.ColorsUsed "`r`n","I")
			this.BitmapHeader.ColorsImportant:=this.DataMem.ReadUInt()
				Console.Send("ColorsImportant = " this.BitmapHeader.ColorsImportant "`r`n","I")
			}
		If ((this.BitmapHeader.Size=40) AND (this.BitmapHeader.Compression=3)) OR (this.BitmapHeader.Size>40)	; /* Fields added for BMP Version 3 (Microsoft Windows NT) follow this line */
			{
			this.BitmapHeader.RedMask:=this.DataMem.ReadUInt()
				Console.Send("RedMask = " this.BitmapHeader.RedMask "`r`n","I")
			this.BitmapHeader.GreenMask:=this.DataMem.ReadUInt()
				Console.Send("GreenMask = " this.BitmapHeader.GreenMask "`r`n","I")
			this.BitmapHeader.BlueMask:=this.DataMem.ReadUInt()
				Console.Send("BlueMask = " this.BitmapHeader.BlueMask "`r`n","I")
			}
		If (this.BitmapHeader.Size>=108)
			{
			this.BitmapHeader.AlphaMask:=this.DataMem.ReadUInt()
				Console.Send("AlphaMask = " this.BitmapHeader.AlphaMask "`r`n","I")
			tmp:=this.DataMem.Tell()
			this.BitmapHeader.CSType:=this.DataMem.ReadUInt()
			this.DataMem.Seek(tmp,0)
			Str:=strI(this.DataMem.Read(4))
				Console.Send("CSType = " this.BitmapHeader.CSType " (" Str ")" "`r`n","I")
			this.BitmapHeader.RedX:=this.DataMem.ReadInt()
				Console.Send("RedX = " this.BitmapHeader.RedX "`r`n","I")
			this.BitmapHeader.RedY:=this.DataMem.ReadInt()
				Console.Send("RedY = " this.BitmapHeader.RedY "`r`n","I")
			this.BitmapHeader.RedZ:=this.DataMem.ReadInt()
				Console.Send("RedZ = " this.BitmapHeader.RedZ "`r`n","I")
			this.BitmapHeader.GreenX:=this.DataMem.ReadInt()
				Console.Send("GreenX = " this.BitmapHeader.GreenX "`r`n","I")
			this.BitmapHeader.GreenY:=this.DataMem.ReadInt()
				Console.Send("GreenY = " this.BitmapHeader.GreenY "`r`n","I")
			this.BitmapHeader.GreenZ:=this.DataMem.ReadInt()
				Console.Send("GreenZ = " this.BitmapHeader.GreenZ "`r`n","I")
			this.BitmapHeader.BlueX:=this.DataMem.ReadInt()
				Console.Send("BlueX = " this.BitmapHeader.BlueX "`r`n","I")
			this.BitmapHeader.BlueY:=this.DataMem.ReadInt()
				Console.Send("BlueY = " this.BitmapHeader.BlueY "`r`n","I")
			this.BitmapHeader.BlueZ:=this.DataMem.ReadInt()
				Console.Send("BlueZ = " this.BitmapHeader.BlueZ "`r`n","I")
			this.BitmapHeader.GammaRed:=this.DataMem.ReadUInt()
				Console.Send("GammaRed = " this.BitmapHeader.GammaRed "`r`n","I")
			this.BitmapHeader.GammaGreen:=this.DataMem.ReadUInt()
				Console.Send("GammaGreen = " this.BitmapHeader.GammaGreen "`r`n","I")
			this.BitmapHeader.GammaBlue:=this.DataMem.ReadUInt()
				Console.Send("GammaBlue = " this.BitmapHeader.GammaBlue "`r`n","I")
			}
		If (this.BitmapHeader.Size>=124)
			{
			this.BitmapHeader.Intent:=this.DataMem.ReadUInt()
				Console.Send("Intent = " this.BitmapHeader.Intent "`r`n","I")
			this.BitmapHeader.ProfileData:=this.DataMem.ReadUInt()
				Console.Send("ProfileData = " this.BitmapHeader.ProfileData "`r`n","I")
			this.BitmapHeader.ProfileSize:=this.DataMem.ReadUInt()
				Console.Send("ProfileSize = " this.BitmapHeader.ProfileSize "`r`n","I")
			this.BitmapHeader.Reserved3:=this.DataMem.ReadUInt()
				Console.Send("Reserved3 = " this.BitmapHeader.Reserved3 "`r`n","I")
			}
		If (this.BitmapHeader.Size="12")
			this.BMPFormat:="Windows 2.x BMP"
		Else If (this.BitmapHeader.Size="108")
			this.BMPFormat:="Windows 4.x BMP"
		Else If (this.BitmapHeader.Size="124")
			this.BMPFormat:="Windows 5.x BMP"
		Else If (this.BitmapHeader.Size="40")
			{
			If (this.BitmapHeader.Compression="3")
				this.BMPFormat:="Windows NT BMP"
			Else If (this.BitmapHeader.Compression="0") OR (this.BitmapHeader.Compression="1") OR (this.BitmapHeader.Compression="2")
				this.BMPFormat:="Windows 3.x BMP"
			Else
				this.BMPFormat:="Unknown Bitmap Compression: " this.BitmapHeader.Compression
			}
		Else
			this.BMPFormat:="Unknown Bitmap Header Size: " this.BitmapHeader.Size
		Console.Send("BMPFormat = '" this.BMPFormat "'`r`n","I")
	}
	_ReadPalette(){
		;;;;;	Palette	;;;;;
		Console.Send("Palette`r`n","-I")
		this.Stats.OffsetToPalette:=this.DataMem.Tell()
			Console.Send("OffsetToPalette = " this.Stats.OffsetToPalette "`r`n","I")
		PaletteLength:=(this.FileHeader.BitmapOffset-this.BitmapHeader.Size-14)
		this.DataMem.Seek(this.BitmapHeader.Size+14,"0")
		PaletteElementCount:=(this.BitmapHeader.Size=12?3:4)
		this.Palette:={}, this.Stats.PaletteHasAlpha:=0
		Console.Send("PaletteEntry " FormatStr("#",A_Space,3,"R") ": ","I"), Console.Send(FormatStr("BB",A_Space,3,"R") " ","-I"), Console.Send(FormatStr("GG",A_Space,3,"R") " ","-I"), Console.Send(FormatStr("RR",A_Space,3,"R") " ","-I"), Console.Send(FormatStr("AA",A_Space,3,"R") "`r`n","-I")
		Loop, % PaletteLength/PaletteElementCount
			{
			Index:=A_Index-1
			this.Palette[Index,"BB"]:=this.DataMem.ReadUChar()
			this.Palette[Index,"GG"]:=this.DataMem.ReadUChar()
			this.Palette[Index,"RR"]:=this.DataMem.ReadUChar()
			this.Palette[Index,"AA"]:=(PaletteElementCount=3?0:this.DataMem.ReadUChar())
			If (this.Palette[Index,"AA"]>0) AND (this.Palette[Index,"AA"]<>"")
				this.Stats.PaletteHasAlpha:=1
			Console.Send("PaletteEntry " FormatStr(Index,A_Space,3,"R") ": ","I"), Console.Send(FormatStr(this.Palette[Index,"BB"],A_Space,3,"R") " ","-I"), Console.Send(FormatStr(this.Palette[Index,"GG"],A_Space,3,"R") " ","-I"), Console.Send(FormatStr(this.Palette[Index,"RR"],A_Space,3,"R") " ","-I"), Console.Send(FormatStr(this.Palette[Index,"AA"],A_Space,3,"R") "`r`n","-I")
			}
		Console.Send("PaletteHasAlpha = " this.Stats.PaletteHasAlpha "`r`n","I")
	}
	_ReadImage8UC(){	; 8-bit, paletted, uncompressed
		;;;;;	Image Data	;;;;;
		Console.Send("Image Data`r`n","-I")
		this.DataMem.Seek(this.FileHeader.BitmapOffset,0)
		this.Stats.OffsetToFrameData:=this.FileHeader.BitmapOffset
		ScanLinePadding:=0, Width:=this.BitmapHeader.Width, Height:=this.BitmapHeader.Height
		this.Frame:={}, this.Frame.SetCapacity(Width*Height), this.FrameUP:={}, this.FrameUP.SetCapacity(Width*Height)
		While (Mod(Width+ScanLinePadding,4)>0)
			ScanLinePadding++
		Index:=0
		Loop, % Abs(Height)
			{
			Loop, %Width%
				{
				tmp:=this.Frame[Index]:=this.DataMem.ReadUChar()
				this.FrameUP[Index,"RR"]:=this.Palette[tmp,"RR"]
				this.FrameUP[Index,"GG"]:=this.Palette[tmp,"GG"]
				this.FrameUP[Index,"BB"]:=this.Palette[tmp,"BB"]
				this.FrameUP[Index,"AA"]:=this.Palette[tmp,"AA"] ;^255
				Index++
				}
			this.DataMem.Seek(ScanLinePadding,1)	; Skip ScanLinePadding
			}
		If (Height>0)
			{
			this.Frame:=this._Flip(this.Frame,Width,Height)
			this.FrameUP:=this._Flip(this.FrameUP,Width,Height)
			}
	}
	_ReadImageGDI(){
		;;;;;	Image Data	;;;;;
		Console.Send("Image Data`r`n","-I")
		this.DataMem.Seek(this.FileHeader.BitmapOffset,0)
		this.Stats.OffsetToFrameData:=this.FileHeader.BitmapOffset
		Width:=this.BitmapHeader.Width, Height:=this.BitmapHeader.Height
		this.Frame:={}, this.FrameUP:={}, this.FrameUP.SetCapacity(Width*Height)
		If !pToken
			pToken:=Gdip_Startup(), LocalShutDown:=1
		pBitmap:=GDIPlus_pBitmapFromBuffer(this.Raw,this.Stats.FileSize,this.GetAddress("Raw"))
		Index:=A:=R:=G:=B:=0
		Loop, % Abs(Height)
			{
			Idx:=A_Index-1
			Loop, %Width%
				{
				ARGB:=Gdip_GetPixel(pBitmap,A_Index-1,Idx)
				Gdip_FromARGB(ARGB,A,R,G,B)
				this.FrameUP[Index,"RR"]:=R
				this.FrameUP[Index,"GG"]:=G
				this.FrameUP[Index,"BB"]:=B
				this.FrameUP[Index,"AA"]:=A
				Index++
				}
			}
		Gdip_DisposeImage(pBitmap)
		If LocalShutDown
			Gdip_Shutdown(pToken)
	}
	_CalculateFileSize(BitDepth:=8,Version:=3){
		Width:=this.BitmapHeader.Width, Height:=this.BitmapHeader.Height, ScanLinePadding:=0
		If (BitDepth=8) AND (Version=3)
			{
			While (Mod(Width+ScanLinePadding,4)>0)
				ScanLinePadding++
			Return (1078+Width*Height+ScanLinePadding*Height)
			}
		Else If (BitDepth=24) AND (Version=3)
			{
			While (Mod(Width*3+ScanLinePadding,4)>0)
				ScanLinePadding++
			Return (54+Width*Height*3+ScanLinePadding*Height)
			}
		Else If (BitDepth=32) AND (Version=5)
			Return (138+Width*Height*4)
		Else
			Return this.Stats.FileSize
	}
	_QuantizeImage(BitDepth){
		tic:=QPC(1)
		CountOfPaletteEntries:=1<<BitDepth
		If (GetKeyCount(this.FrameUP))	; If we have un-paletted data
			{
			Quant:=New PS_Quantization()
			If (this.Palette[0,"RR"]=0) AND (this.Palette[0,"GG"]=255) AND (this.Palette[0,"BB"]=0) AND (this.Palette[0,"AA"]=0)
				Quant.AddReservedColor(0,255,0,0)
			If (this.Palette[0,"RR"]=0) AND (this.Palette[0,"GG"]=0) AND (this.Palette[0,"BB"]=0) AND (this.Palette[0,"AA"]=0)
				Quant.AddReservedColor(0,0,0,0)
			For k,v in this.FrameUP
				Quant.AddColor(v["RR"],v["GG"],v["BB"],v["AA"])
			Console.Send("ColorCount = " Quant.GetColorCount() "`r`n","I")
			Quant.Quantize(CountOfPaletteEntries)
			this.Palette:="", this.Palette:=Quant.GetPaletteObj()
			this.Frame:="", this.Frame:={}, this.Frame.SetCapacity(this.FrameUP.Length()+1)
			Loop, % this.FrameUP.Length()+1	; B/C 0-indexed
				{
				Index:=A_Index-1
				Idx:=this.Frame[Index]:=Quant.GetQuantizedColorIndex(this.FrameUP[Index,"RR"],this.FrameUP[Index,"GG"],this.FrameUP[Index,"BB"],this.FrameUP[Index,"AA"])
				this.FrameUP[Index,"RR"]:=this.Palette[Idx,"RR"]
				this.FrameUP[Index,"GG"]:=this.Palette[Idx,"GG"]
				this.FrameUP[Index,"BB"]:=this.Palette[Idx,"BB"]
				this.FrameUP[Index,"AA"]:=this.Palette[Idx,"AA"]
				}
			Console.Send("Total Error: " Quant.GetTotalError() "`r`n","I")
			Quant:=""
			Console.Send("Image quantized in " (QPC(1)-tic) " sec.`r`n","-I")
			}
		Else If (GetKeyCount(this.Frame))	; If all we have is paletted data
			{
			Quant:=New PS_Quantization()
			For k,v in this.Frame
				Quant.AddColor(this.Palette[v,"RR"],this.Palette[v,"GG"],this.Palette[v,"BB"],this.Palette[v,"AA"])
			Console.Send("ColorCount = " Quant.GetColorCount() "`r`n","I")
			Quant.Quantize(CountOfPaletteEntries)
			PalObj:=Quant.GetPaletteObj()
			this.FrameUP:="", this.FrameUP:={}, this.FrameUp.SetCapacity(this.Frame.Length()+1)
			Loop, % this.Frame.Length()+1	; B/C 0-indexed
				{
				Index:=A_Index-1
				this.Frame[Index]:=Quant.GetQuantizedColorIndex(this.Palette[Index,"RR"],this.Palette[Index,"GG"],this.Palette[Index,"BB"],this.Palette[Index,"AA"])
				this.FrameUP[Index,"RR"]:=this.PalObj[Index,"RR"]
				this.FrameUP[Index,"GG"]:=this.PalObj[Index,"GG"]
				this.FrameUP[Index,"BB"]:=this.PalObj[Index,"BB"]
				this.FrameUP[Index,"AA"]:=this.PalObj[Index,"AA"]
				}
			this.Palette:="", this.Palette:=PalObj
			Console.Send("Total Error: " Quant.GetTotalError() "`r`n","I")
			Quant:=""
			Console.Send("Image quantized in " (QPC(1)-tic) " sec.`r`n","-I")
			}
		Else
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "Bitmap has no data to quantize.", extra: ""}
		
		
	}
	_Flip(ByRef FrameObj,Width,Height){	; Width (in bytes) should include any scanline padding if present
		NewFrameobj:={}, Origin:=FrameObj.MinIndex(), NewFrameObj.SetCapacity(FrameObj.MaxIndex()-Origin+1)
		Loop, % Abs(Height)
			{
			Idx:=A_Index-1, Line:={}
			Loop, %Width%
				Line.Push(FrameObj[Origin+A_Index-1+Idx*Width])
			NewFrameObj.InsertAt(Origin,Line*)
			}
		Return NewFrameObj
	}
}


/*
strI(str){ ; https://github.com/Masonjar13/AHK-Library/blob/master/Lib/strI.ahk
    VarSetCapacity(nStr,sLen:=strLen(str))
    Loop, %sLen%
        nStr.=SubStr(str,sLen--,1)
    Return nStr
}

;;;;; Core Background Functions ;;;;;

ThrowMsg(Options="",Title="",Text="",Timeout=""){
	If (Title="") AND (Text="") AND (Timeout=""){
		Gui +OwnDialogs
		MsgBox % Options
		}
	Else{
		Gui +OwnDialogs
		MsgBox, % Options , % Title , % Text , % Timeout
		}
}

QPC(R:=0){ ; By SKAN, http://goo.gl/nf7O4G, CD:01/Sep/2014 | MD:01/Sep/2014
  Static P:=0, F:=0, Q:=DllCall("QueryPerformanceFrequency","Int64P",F)
  Return !DllCall("QueryPerformanceCounter","Int64P",Q)+(R?(P:=Q)/F:(Q-P)/F) 
}

FormatStr(String:="",Filler:="",Length:=0,Justify:="R"){
	tmp:=""
	Loop, % Length
		tmp.=Filler
	If (Justify="R")
		Return SubStr(tmp String,(Length-1)*-1)
	Else If (Justify="C")
		Return (StrLen(String)>=Length?SubStr(String tmp,1,Length):SubStr(SubStr(tmp,1,(Length-StrLen(String))//2) String tmp,1,Length))
	Else ;If (Justify="L")
		Return SubStr(String tmp,1,Length)
}

st_printArr(array, depth=5, indentLevel=""){
	list:=""
   for k,v in Array
   {
      list.= indentLevel "[" k "]"
      if (IsObject(v) && depth>1)
         list.="`r`n" st_printArr(v, depth-1, indentLevel . "    ")
      Else
         list.=" => " v
      list.="`r`n"
   }
   return rtrim(list)
}

ShiftArray(Arr){  ; Converts a <1-based linear array to 1-based
	While Arr.MinIndex()<1
		I:=Arr.MinIndex(), Arr.InsertAt(I,""), Arr.Delete(I)
	Return Arr
}

ObjFullyClone(obj){	; https://autohotkey.com/board/topic/103411-cloned-object-modifying-original-instantiation/?p=638500
    nobj:=ObjClone(obj)
    For k,v in nobj
        If IsObject(v)
            nobj[k]:=ObjFullyClone(v)
    Return nobj
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include <PushLog>
#Include, lib
#Include, MemoryFileIO_v2.1.ahk


;;;;;;;;;;;;;;;;;;;;;;;;;	Gdip	;;;;;;;;;;;;;;;;;;;;;;;;;
GDIPlus_pBitmapFromBuffer(ByRef Buffer,nSize,BufferAddress:="") {
 pStream:=pBitmap:=""
 hData:=DllCall("GlobalAlloc",UInt,2,UInt,nSize), pData:=DllCall("GlobalLock",UInt,hData)
 DllCall("RtlMoveMemory",UInt,pData,UInt,(BufferAddress?BufferAddress:&Buffer),UInt,nSize)
 DllCall("GlobalUnlock",UInt,hData)
 DllCall("ole32\CreateStreamOnHGlobal",UInt,hData,Int,True,UIntP,pStream)
 DllCall("gdiplus\GdipCreateBitmapFromStream",UInt,pStream,UIntP,pBitmap)
 DllCall(NumGet(NumGet(1*pStream)+8),UInt,pStream) ; IStream::Release
Return pBitmap
}
*/
