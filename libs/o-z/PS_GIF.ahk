;
; AutoHotkey Version: 1.1.30.00
; Language:       English
; Platform:       Optimized for Windows 10
; Author:         Sam.
;

;;;;;	Reference Documents	;;;;;
; http://www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp
; https://www.w3.org/Graphics/GIF/spec-gif89a.txt
; http://www.martinreddy.net/gfx/2d/GIF-comp.txt
; http://commandlinefanatic.com/cgi-bin/showarticle.cgi?article=art010
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;      PS_GIF v0.0.01a      ;;;;;
;;;;;  Copyright (c) 2018 Sam.  ;;;;;
;;;;;   Last Updated 20180926   ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

class PSGIF extends ExGIFIO{
	LoadGIFFromFile(InputPath){
		tic:=QPC(1)
		Console.Send("Path='" InputPath "'`r`n")
		file:=FileOpen(InputPath,"r-d")
			this.Stats:={}
			this.InputPath:=InputPath
			this.Stats.OriginalFileSize:=file.Length, Console.Send("OriginalFileSize=" this.Stats.OriginalFileSize "`r`n","I")
			this.Stats.FileSize:=file.Length, Console.Send("FileSize=" this.Stats.FileSize "`r`n","I")
			this.Raw:=" ", this.SetCapacity("Raw",this.Stats.FileSize), DllCall("RtlFillMemory","Ptr",this.GetAddress("Raw"),"UInt",this.Stats.FileSize,"UChar",0)
			file.RawRead(this.GetAddress("Raw"),this.Stats.FileSize)
			file.Close()
		this.DataMem:=New MemoryFileIO(this.GetAddress("Raw"),this.Stats.FileSize)
		Console.Send("GIF loaded into memory in " (QPC(1)-tic) " sec.`r`n","-I")
		this._ReadGIF()
		this.Raw:="", this.Delete("Raw"), this.DataMem:=""
		Console.Send("Finished Loading GIF in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	SaveGIFToFile(OutputPath){
		tic:=QPC(1)
		Console.Send("Saving GIF to '" OutputPath "'`r`n","-W")
		this.Raw:=" ", this.SetCapacity("Raw",this.Stats.FileSize), DllCall("RtlFillMemory","Ptr",this.GetAddress("Raw"),"UInt",this.Stats.FileSize,"UChar",0)
		this.DataMem:=New MemoryFileIO(this.GetAddress("Raw"),this.Stats.FileSize)
		this._WriteGIF()
		file:=FileOpen(OutputPath,"w-d")
			file.RawWrite(this.GetAddress("Raw"),this.Stats.FileSize)
		file.Close()
		this.Raw:="", this.Delete("Raw"), this.DataMem:=""
		Console.Send("Finished Saving GIF in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	LoadGIFFromMemory(Address,Size){
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
		Console.Send("GIF loaded into memory in " (QPC(1)-tic) " sec.`r`n","-I")
		this._ReadGIF()
		this.Raw:="", this.Delete("Raw"), this.DataMem:=""
		Console.Send("Finished Loading GIF in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	SaveGIFToVar(Var){
		tic:=QPC(1)
		VarSetCapacity(Var,this.Stats.FileSize,0)
		this.DataMem:=New MemoryFileIO(&Var,this.Stats.FileSize)
		this._WriteGIF()
		this.DataMem:=""
		Console.Send("Finished Saving GIF in " (QPC(1)-tic) " sec.`r`n","-I")
		Return this.Stats.FileSize
	}
	_ReadGIF(){
		tic:=QPC(1)
		this._ReadGIFHeader()
		this._ReadLogicalScreenDescriptor()
		If this.LogicalScreenDescriptor.GlobalColorTableFlag
			this._ReadGlobalColorTable()
		GCE:=""
		While ((flag:=this.DataMem.ReadUChar())<>0x3B)
			{
			If (flag=0x21)	; Extension
				{
				ExtensionID:=this.DataMem.ReadUChar()
				If (ExtensionID=0xF9)	;;;;;	Graphics Control Extension	;;;;;
					GCE:=this._ReadGraphicControlExtension(flag,ExtensionID)
				Else If (ExtensionID=0x01)	;;;;;	Plain Text Extension	;;;;;
					this._ReadPlainTextExtension(flag,ExtensionID,ByRef GCE)
				Else If (ExtensionID=0xFF)	;;;;;	Application Extension	;;;;;
					this._ReadApplicationExtension(flag,ExtensionID)
				Else If (ExtensionID=0xFE)	;;;;;	Comment Extension	;;;;;
					this._ReadCommentExtension(flag,ExtensionID)
				}
			If (flag=0x2C)	;;;;;	Image Descriptor	;;;;;
				this._ReadImage(flag,GCE)
			}
		If (flag=0x3B)	;;;;;	Trailer	;;;;;
			Console.Send("EoF`r`n","-I")
		
		Console.Send("GIF read in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	_WriteGIF(){
		tic:=QPC(1)
		this._WriteGIFHeader()
		this._WriteLogicalScreenDescriptor()
		If this.LogicalScreenDescriptor.GlobalColorTableFlag
			this._WriteGlobalColorTable()
		If IsObject(this.ApplicationExtension)
			Loop, % this.ApplicationExtension.Length()
				this._WriteApplicationExtension(A_Index)
		If IsObject(this.CommentExtension)
			Loop, % this.CommentExtension.Length()
				this._WriteCommentExtension(A_Index)
		If IsObject(this.PlainTextExtension)
			Loop, % this.PlainTextExtension.Length()
				this._WritePlainTextExtension(A_Index)
		If IsObject(this.Frame)
			Loop, % this.Frame.Length()
				this._WriteImage(A_Index)
		FinalSize:=this._WriteTailer()
		this.Stats.FileSize:=FinalSize
		Console.Send("GIF written in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	_ReadGIFHeader(){
		;;;;;	Header Block	;;;;;
		Console.Send("Header Block`r`n","-I")
		this.Header:={}
		this.Header.OffsetToHeader:=this.DataMem.Tell()
			Console.Send("OffsetToHeader = " this.Header.OffsetToHeader "`r`n","I")
		this.Header.Signature:=this.DataMem.Read(3)	; "GIF"
			Console.Send("Signature = '" this.Header.Signature "'`r`n","I")
		this.Header.Version:=this.DataMem.Read(3)	; "89a"
			Console.Send("Version = '" this.Header.Version "'`r`n","I")
		this.Header.LengthOfHeader:=this.DataMem.Tell()-this.Header.OffsetToHeader
			Console.Send("LengthOfHeader = " this.Header.LengthOfHeader "`r`n","I")
		If (this.Header.Signature<>"GIF")
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "This file does not appear to be a valid GIF file.", extra: "Signature """ this.Header.Signature """"}
		If (this.Header.Version<>"89a")
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "This file appears to be a GIF file, but is an unsupported version.  Only version '89a' is currently supported.", extra: "Version """ this.Header.Version """"}
	}
	_WriteGIFHeader(){
		;this.DataMem.Seek(this.Header.OffsetToHeader,0)
		this.DataMem.Seek(0,0)
		this.DataMem.Write(this.Header.Signature,3)	; "GIF"
		this.DataMem.Write(this.Header.Version)		; "89a"
	}
	_ReadLogicalScreenDescriptor(){
		;;;;;	Logical Screen Descriptor	;;;;;
		this.LogicalScreenDescriptor:={}
		Console.Send("Logical Screen Descriptor`r`n","-I")
		this.LogicalScreenDescriptor.OffsetToLogicalScreenDescriptor:=this.DataMem.Tell()
			Console.Send("OffsetToLogicalScreenDescriptor = " this.LogicalScreenDescriptor.OffsetToLogicalScreenDescriptor "`r`n","I")
		this.LogicalScreenDescriptor.CanvasWidth:=this.DataMem.ReadUShort()
			Console.Send("CanvasWidth = " this.LogicalScreenDescriptor.CanvasWidth "`r`n","I")
		this.LogicalScreenDescriptor.CanvasHeight:=this.DataMem.ReadUShort()
			Console.Send("CanvasHeight = " this.LogicalScreenDescriptor.CanvasHeight "`r`n","I")
		tmp:=this.DataMem.ReadUChar()	; Packed Byte
		this.LogicalScreenDescriptor.GlobalColorTableFlag:=GetBits(tmp,0,1)
			Console.Send("GlobalColorTableFlag = " this.LogicalScreenDescriptor.GlobalColorTableFlag "`r`n","I")
		this.LogicalScreenDescriptor.ColorResolution:=GetBits(tmp,1,3)
			Console.Send("ColorResolution = " this.LogicalScreenDescriptor.ColorResolution "`r`n","I")
		this.LogicalScreenDescriptor.SortFlag:=GetBits(tmp,4,1)
			Console.Send("SortFlag = " this.LogicalScreenDescriptor.SortFlag "`r`n","I")
		this.LogicalScreenDescriptor.SizeOfGlobalColorTable:=GetBits(tmp,5,3)
			Console.Send("SizeOfGlobalColorTable = " this.LogicalScreenDescriptor.SizeOfGlobalColorTable "`r`n","I")
		this.LogicalScreenDescriptor.BackgroundColorIndex:=this.DataMem.ReadUChar()
			Console.Send("BackgroundColorIndex = " this.LogicalScreenDescriptor.BackgroundColorIndex "`r`n","I")
		this.LogicalScreenDescriptor.PixelAspectRatio:=this.DataMem.ReadUChar()
			Console.Send("PixelAspectRatio = " this.LogicalScreenDescriptor.PixelAspectRatio "`r`n","I")
		this.LogicalScreenDescriptor.LengthOfLogicalScreenDescriptor:=this.DataMem.Tell()-this.LogicalScreenDescriptor.OffsetToLogicalScreenDescriptor
			Console.Send("LengthOfLogicalScreenDescriptor = " this.LogicalScreenDescriptor.LengthOfLogicalScreenDescriptor "`r`n","I")
	}
	_WriteLogicalScreenDescriptor(){
		;this.DataMem.Seek(this.LogicalScreenDescriptor.OffsetToLogicalScreenDescriptor,0)
		this.DataMem.WriteUShort(this.LogicalScreenDescriptor.CanvasWidth)
		this.DataMem.WriteUShort(this.LogicalScreenDescriptor.CanvasHeight)
		tmp:=PackByte(Sz:=[1,3,1,3],this.LogicalScreenDescriptor.GlobalColorTableFlag,this.LogicalScreenDescriptor.ColorResolution,this.LogicalScreenDescriptor.SortFlag,this.LogicalScreenDescriptor.SizeOfGlobalColorTable)
		this.DataMem.WriteUChar(tmp)	; Packed Byte
		this.DataMem.WriteUChar(this.LogicalScreenDescriptor.BackgroundColorIndex)
		this.DataMem.WriteUChar(this.LogicalScreenDescriptor.PixelAspectRatio)
	}
	_ReadGlobalColorTable(){
		;;;;;	Global Color Table	;;;;;
		this.GlobalColorTable:={}
		Console.Send("Global Color Table`r`n","-I")
		this.GlobalColorTable.OffsetToGlobalColorTable:=this.DataMem.Tell()
			Console.Send("OffsetToGlobalColorTable = " this.GlobalColorTable.OffsetToGlobalColorTable "`r`n","I")
		this.GlobalColorTable.Palette:={}
		Loop, % (2**(this.LogicalScreenDescriptor.SizeOfGlobalColorTable+1))
			{
			Idx:=A_Index-1
			this.GlobalColorTable.Palette[Idx,"RR"]:=this.DataMem.ReadUChar()
			this.GlobalColorTable.Palette[Idx,"GG"]:=this.DataMem.ReadUChar()
			this.GlobalColorTable.Palette[Idx,"BB"]:=this.DataMem.ReadUChar()
			this.GlobalColorTable.Palette[Idx,"AA"]:=0
			}
		;~ Console.Send("Palette = `r`n" st_printArr(this.GlobalColorTable.Palette) "`r`n","I")
		If (Settings.DebugLevelL>1)
			this._PrintPalette(this.GlobalColorTable.Palette)
		this.GlobalColorTable.LengthOfGlobalColorTable:=this.DataMem.Tell()-this.GlobalColorTable.OffsetToGlobalColorTable
			Console.Send("LengthOfGlobalColorTable = " this.GlobalColorTable.LengthOfGlobalColorTable "`r`n","I")
	}
	_PrintPalette(PalObj:=""){
		If !IsObject(PalObj)	; Print the BAM Palette
			PalObj:=this.Palette
		Msg:="[Palette]`r`n"
		Msg.="  PaletteEntry " FormatStr("#",A_Space,3,"R") ": " FormatStr("BB",A_Space,3,"R") " " FormatStr("GG",A_Space,3,"R") " " FormatStr("RR",A_Space,3,"R") " " FormatStr("AA",A_Space,3,"R") "`r`n" "  ---------------------------------`r`n"
		For key,val in PalObj
			Msg.="  PaletteEntry " FormatStr(key,A_Space,3,"R") ": " FormatStr(PalObj[key,"BB"],A_Space,3,"R") " " FormatStr(PalObj[key,"GG"],A_Space,3,"R") " " FormatStr(PalObj[key,"RR"],A_Space,3,"R") " " FormatStr(PalObj[key,"AA"],A_Space,3,"R") "`r`n"
		Console.Send(Msg "`r`n")
	}
	_WriteGlobalColorTable(){
		;this.DataMem.Seek(this.GlobalColorTable.OffsetToGlobalColorTable,0)
		tmp:=this.DataMem.Tell()
		Loop, % (this.GlobalColorTable["Palette"].Length()+1)
			{
			Idx:=A_Index-1
			this.DataMem.WriteUChar(this.GlobalColorTable.Palette[Idx,"RR"])
			this.DataMem.WriteUChar(this.GlobalColorTable.Palette[Idx,"GG"])
			this.DataMem.WriteUChar(this.GlobalColorTable.Palette[Idx,"BB"])
			}
		this.DataMem.Seek(tmp+(3*2**(this.LogicalScreenDescriptor["SizeOfGlobalColorTable"]+1)),0)
	}
	_ReadCommentExtension(flag,ExtensionID){
		;;;;;	Comment Extension	;;;;;
		If !IsObject(this.CommentExtension)
			this.CommentExtension:={}
		Idx:=this.CommentExtension.Length()+1
		Console.Send("Comment Extension`r`n","-I")
		this.CommentExtension[Idx,"OffsetToCommentExtension"]:=this.DataMem.Tell()-2
			Console.Send("OffsetToCommentExtension = " this.CommentExtension[Idx,"OffsetToCommentExtension"] "`r`n","I")
		this.CommentExtension[Idx,"ExtensionIntroducer"]:=flag	; Always 0x21
			Console.Send("ExtensionIntroducer = " this.CommentExtension[Idx,"ExtensionIntroducer"] "`r`n","I")
		this.CommentExtension[Idx,"ExtensionLabel"]:=ExtensionID	; Always 0xFE
			Console.Send("ExtensionLabel = " this.CommentExtension[Idx,"ExtensionLabel"] "`r`n","I")
		this.CommentExtension[Idx,"Text"]:=""
		While (SubBlockSize:=this.DataMem.ReadUChar())
			this.CommentExtension[Idx,"Text"].=this.DataMem.Read(SubBlockSize)
			Console.Send("Comment = '" this.CommentExtension[Idx,"Text"] "'`r`n","I")
		this.CommentExtension[Idx,"LengthOfCommentExtension"]:=this.DataMem.Tell()-this.CommentExtension[Idx,"OffsetToCommentExtension"]
			Console.Send("LengthOfCommentExtension = " this.CommentExtension[Idx,"LengthOfCommentExtension"] "`r`n","I")
	}
	_WriteCommentExtension(Idx){
		;this.DataMem.Seek(this.CommentExtension[Idx,"OffsetToCommentExtension"],0)
		this.DataMem.WriteUChar(this.CommentExtension[Idx,"ExtensionIntroducer"])	; Always 0x21
		this.DataMem.WriteUChar(this.CommentExtension[Idx,"ExtensionLabel"])	; Always 0xFE
		TextArr:=String2Array(this.CommentExtension[Idx,"Text"])
		this._FormatSubBlocks(TextArr,"",0)
		For k,v in TextArr
			this.DataMem.WriteUChar(v)
	}
	_ReadApplicationExtension(flag,ExtensionID){
		;;;;;	Application Extension	;;;;;
		If !IsObject(this.ApplicationExtension)
			this.ApplicationExtension:={}
		Idx:=this.ApplicationExtension.Length()+1
		Console.Send("Application Extension`r`n","-I")
		this.ApplicationExtension[Idx,"OffsetToApplicationExtension"]:=this.DataMem.Tell()-2
			Console.Send("OffsetToApplicationExtension = " this.ApplicationExtension[Idx,"OffsetToApplicationExtension"] "`r`n","I")
		this.ApplicationExtension[Idx,"ExtensionIntroducer"]:=flag	; Always 0x21
			Console.Send("ExtensionIntroducer = " this.ApplicationExtension[Idx,"ExtensionIntroducer"] "`r`n","I")
		this.ApplicationExtension[Idx,"ExtensionLabel"]:=ExtensionID	; Always 0xFF
			Console.Send("ExtensionLabel = " this.ApplicationExtension[Idx,"ExtensionLabel"] "`r`n","I")
		BlockSize:=this.DataMem.ReadUChar()
			Console.Send("BlockSize = " BlockSize "`r`n","I")
		this.ApplicationExtension[Idx,"ApplicationIdentifier"]:=this.DataMem.Read(8)
			Console.Send("ApplicationIdentifier = '" this.ApplicationExtension[Idx,"ApplicationIdentifier"] "'`r`n","I")
		this.ApplicationExtension[Idx,"ApplicationAuthenticationCode"]:=this.DataMem.Read(3)
			Console.Send("ApplicationAuthenticationCode = '" this.ApplicationExtension[Idx,"ApplicationAuthenticationCode"] "'`r`n","I")
		If (this.ApplicationExtension[Idx,"ApplicationIdentifier"] this.ApplicationExtension[Idx,"ApplicationAuthenticationCode"]="NETSCAPE2.0")
			{
			SubBlockSize:=this.DataMem.ReadUChar()
				Console.Send("SubBlockSize = " SubBlockSize "`r`n","I")
			If (SubBlockSize=3)
				{
				this.ApplicationExtension[Idx,"Static"]:=this.DataMem.ReadUChar()	; Always 0x01
					Console.Send("Static = " this.ApplicationExtension[Idx,"Static"] "`r`n","I")
				this.ApplicationExtension[Idx,"LoopCount"]:=this.DataMem.ReadUShort()
					Console.Send("LoopCount = " this.ApplicationExtension[Idx,"LoopCount"] "`r`n","I")
				}
			Else
				throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "Unsupported SubBlock size in Application Extension.", extra: "ApplicationIdentifier """ this.ApplicationExtension[Idx,"ApplicationIdentifier"] """ & ApplicationAuthenticationCode """ this.ApplicationExtension[Idx,"ApplicationAuthenticationCode"] """."}
			}
		Else
			{
			this.ApplicationExtension[Idx,"Data"]:={}
			While (SubBlockSize:=this.DataMem.ReadUChar())
				{
				Loop, %SubBlockSize%
					this.ApplicationExtension[Idx,"Data"].Push(this.DataMem.ReadUChar())
				}
				Console.Send("DataStream = `r`n" st_printArr(this.ApplicationExtension[Idx,"Data"]) "`r`n","I")
			}
		this.ApplicationExtension[Idx,"LengthOfApplicationExtension"]:=this.DataMem.Tell()-this.ApplicationExtension[Idx,"OffsetToApplicationExtension"]
			Console.Send("LengthOfApplicationExtension = " this.ApplicationExtension[Idx,"LengthOfApplicationExtension"] "`r`n","I")
	}
	_WriteApplicationExtension(Idx){
		;this.DataMem.Seek(this.ApplicationExtension[Idx,"OffsetToApplicationExtension"],0)
		this.DataMem.WriteUChar(this.ApplicationExtension[Idx,"ExtensionIntroducer"])	; Always 0x21
		this.DataMem.WriteUChar(this.ApplicationExtension[Idx,"ExtensionLabel"])	; Always 0xFF
		this.DataMem.WriteUChar(11)	; Blocksize - Always 11
		tmp:=this.DataMem.Tell()
		this.DataMem.Write(this.ApplicationExtension[Idx,"ApplicationIdentifier"],8)
		this.DataMem.Seek(tmp+8,0), tmp:=this.DataMem.Tell()
		this.DataMem.Write(this.ApplicationExtension[Idx,"ApplicationAuthenticationCode"],3)
		this.DataMem.Seek(tmp+3,0)
		If (this.ApplicationExtension[Idx,"ApplicationIdentifier"] this.ApplicationExtension[Idx,"ApplicationAuthenticationCode"]="NETSCAPE2.0")
			{
			this.DataMem.WriteUChar(SubBlockSize:=3)
			this.DataMem.WriteUChar(this.ApplicationExtension[Idx,"Static"])	; Always 0x01
			this.DataMem.WriteUShort(this.ApplicationExtension[Idx,"LoopCount"])
			this.DataMem.WriteUChar(0)	; Block Terminator
			}
		Else
			{
			Arr:=this.ApplicationExtension[Idx,"Data"].Clone()
			this._FormatSubBlocks(Arr,"",0)
			For k,v in Arr
				this.DataMem.WriteUChar(v)
			}
	}
	_ReadGraphicControlExtension(flag,ExtensionID){
		;;;;;	Graphics Control Extension	;;;;;
		Console.Send("Graphics Control Extension`r`n","-I")
		GCE:={}
		GCE.OffsetToGraphicsControlExtension:=this.DataMem.Tell()-2
			Console.Send("OffsetToGraphicsControlExtension = " GCE.OffsetToGraphicsControlExtension "`r`n","I")
		GCE.ExtensionIntroducer:=flag	; Always 0x21
			Console.Send("ExtensionIntroducer = " GCE.ExtensionIntroducer "`r`n","I")
		GCE.ExtensionLabel:=ExtensionID	; Always 0xF9
			Console.Send("ExtensionLabel = " GCE.ExtensionLabel "`r`n","I")
		GCE.BlockSize:=this.DataMem.ReadUChar()
			Console.Send("BlockSize = " GCE.BlockSize "`r`n","I")
		tmp:=this.DataMem.ReadUChar()	; Packed Byte
		GCE.Reserved1:=GetBits(tmp,0,3)
			Console.Send("Reserved1 = " GCE.Reserved1 "`r`n","I")
		GCE.DisposalMethod:=GetBits(tmp,3,3)
			Console.Send("DisposalMethod = " GCE.DisposalMethod "`r`n","I")
		GCE.UserInputFlag:=GetBits(tmp,6,1)	; Probably always 0
			Console.Send("UserInputFlag = " GCE.UserInputFlag "`r`n","I")
		GCE.TransparentColorFlag:=GetBits(tmp,7,1)
			Console.Send("TransparentColorFlag = " GCE.TransparentColorFlag "`r`n","I")
		GCE.DelayTime:=this.DataMem.ReadUShort()
			Console.Send("DelayTime = " GCE.DelayTime "`r`n","I")
		GCE.TransparentColorIndex:=this.DataMem.ReadUChar()
			Console.Send("TransparentColorIndex = " GCE.TransparentColorIndex "`r`n","I")
		GCE.BlockTerminator:=this.DataMem.ReadUChar()	; Always 0
			Console.Send("BlockTerminator = " GCE.BlockTerminator "`r`n","I")
		GCE.LengthOfGraphicsControlExtension:=this.DataMem.Tell()-GCE.OffsetToGraphicsControlExtension
			Console.Send("LengthOfGraphicsControlExtension = " GCE.LengthOfGraphicsControlExtension "`r`n","I")
		Return GCE
	}
	_WriteGraphicControlExtension(GCE){
		;this.DataMem.Seek(GCE.OffsetToApplicationExtension,0)
		this.DataMem.WriteUChar(GCE.ExtensionIntroducer)	; Always 0x21
		this.DataMem.WriteUChar(GCE.ExtensionLabel)	; Always 0xF9
		this.DataMem.WriteUChar(GCE.BlockSize)
		tmp:=PackByte(Sz:=[3,3,1,1],GCE.Reserved1,GCE.DisposalMethod,GCE.UserInputFlag,GCE.TransparentColorFlag)
		this.DataMem.WriteUChar(tmp)	; Packed Byte
		this.DataMem.WriteUShort(GCE.DelayTime)
		this.DataMem.WriteUChar(GCE.TransparentColorIndex)
		this.DataMem.WriteUChar(GCE.BlockTerminator)	; Always 0
	}
	_ReadPlainTextExtension(flag,ExtensionID,ByRef GCE){
		;;;;;	Plain Text Extension	;;;;;
		If !IsObject(this.PlainTextExtension)
			this.PlainTextExtension:={}
		Idx:=this.PlainTextExtension.Length()+1
		Console.Send("Plain Text Extension`r`n","-I")
		this.PlainTextExtension[Idx,"OffsetToPlainTextExtension"]:=this.DataMem.Tell()-2
			Console.Send("OffsetToPlainTextExtension = " this.PlainTextExtension[Idx,"OffsetToPlainTextExtension"] "`r`n","I")
		this.PlainTextExtension[Idx,"ExtensionIntroducer"]:=flag	; Always 0x21
			Console.Send("ExtensionIntroducer = " this.PlainTextExtension[Idx,"ExtensionIntroducer"] "`r`n","I")
		this.PlainTextExtension[Idx,"ExtensionLabel"]:=ExtensionID	; Always 0x01
			Console.Send("ExtensionLabel = " this.PlainTextExtension[Idx,"ExtensionLabel"] "`r`n","I")
		this.PlainTextExtension[Idx,"BlockSize"]:=this.DataMem.ReadUChar()
			Console.Send("BlockSize = " this.PlainTextExtension[Idx,"BlockSize"] "`r`n","I")
		this.PlainTextExtension[Idx,"TextGridLeftPosition"]:=this.DataMem.ReadUShort()
			Console.Send("TextGridLeftPosition = " this.PlainTextExtension[Idx,"TextGridLeftPosition"] "`r`n","I")
		this.PlainTextExtension[Idx,"TextGridTopPosition"]:=this.DataMem.ReadUShort()
			Console.Send("TextGridTopPosition = " this.PlainTextExtension[Idx,"TextGridTopPosition"] "`r`n","I")
		this.PlainTextExtension[Idx,"TextGridWidth"]:=this.DataMem.ReadUShort()
			Console.Send("TextGridWidth = " this.PlainTextExtension[Idx,"TextGridWidth"] "`r`n","I")
		this.PlainTextExtension[Idx,"TextGridHeight"]:=this.DataMem.ReadUShort()
			Console.Send("TextGridHeight = " this.PlainTextExtension[Idx,"TextGridHeight"] "`r`n","I")
		this.PlainTextExtension[Idx,"CharacterCellWidth"]:=this.DataMem.ReadUChar()
			Console.Send("CharacterCellWidth = " this.PlainTextExtension[Idx,"CharacterCellWidth"] "`r`n","I")
		this.PlainTextExtension[Idx,"CharacterCellHeight"]:=this.DataMem.ReadUChar()
			Console.Send("CharacterCellHeight = " this.PlainTextExtension[Idx,"CharacterCellHeight"] "`r`n","I")
		this.PlainTextExtension[Idx,"TextForegroundColorIndex"]:=this.DataMem.ReadUChar()
			Console.Send("TextForegroundColorIndex = " this.PlainTextExtension[Idx,"TextForegroundColorIndex"] "`r`n","I")
		this.PlainTextExtension[Idx,"TextBackgroundColorIndex"]:=this.DataMem.ReadUChar()
			Console.Send("TextBackgroundColorIndex = " this.PlainTextExtension[Idx,"TextBackgroundColorIndex"] "`r`n","I")
		this.PlainTextExtension[Idx,"Text"]:=""
		While (SubBlockSize:=this.DataMem.ReadUChar())
			this.PlainTextExtension[Idx,"Text"].=this.DataMem.Read(SubBlockSize)
			Console.Send("Text = '" this.PlainTextExtension[Idx,"Text"] "'`r`n","I")
		this.PlainTextExtension[Idx,"LengthOfPlainTextExtension"]:=this.DataMem.Tell()-this.PlainTextExtension[Idx,"OffsetToPlainTextExtension"]
			Console.Send("LengthOfPlainTextExtension = " this.PlainTextExtension[Idx,"LengthOfPlainTextExtension"] "`r`n","I")
		;;;;;	Graphics Control Extension	;;;;;
		this.PlainTextExtension[Idx,"GCE"]:=GCE
		GCE:=""
	}
	_WritePlainTextExtension(Idx){
		;this.DataMem.Seek(this.PlainTextExtension[Idx,"OffsetToPlainTextExtension"],0)
		If IsObject(this.PlainTextExtension[Idx,"GCE"])
			this._WriteGraphicControlExtension(this.PlainTextExtension[Idx,"GCE"])
		this.DataMem.WriteUChar(this.PlainTextExtension[Idx,"ExtensionIntroducer"])	; Always 0x21
		this.DataMem.WriteUChar(this.PlainTextExtension[Idx,"ExtensionLabel"])	; Always 0x01
		this.DataMem.WriteUChar(this.PlainTextExtension[Idx,"BlockSize"])
		this.DataMem.WriteUShort(this.PlainTextExtension[Idx,"TextGridLeftPosition"])
		this.DataMem.WriteUShort(this.PlainTextExtension[Idx,"TextGridTopPosition"])
		this.DataMem.WriteUShort(this.PlainTextExtension[Idx,"TextGridWidth"])
		this.DataMem.WriteUShort(this.PlainTextExtension[Idx,"TextGridHeight"])
		this.DataMem.WriteUChar(this.PlainTextExtension[Idx,"CharacterCellWidth"])
		this.DataMem.WriteUChar(this.PlainTextExtension[Idx,"CharacterCellHeight"])
		this.DataMem.WriteUChar(this.PlainTextExtension[Idx,"TextForegroundColorIndex"])
		this.DataMem.WriteUChar(this.PlainTextExtension[Idx,"TextBackgroundColorIndex"])
		TextArr:=String2Array(this.PlainTextExtension[Idx,"Text"])
		this._FormatSubBlocks(TextArr,"",0)
		For k,v in TextArr
			this.DataMem.WriteUChar(v)
	}
	_ReadImage(flag,ByRef GCE){
		;;;;;	Image Descriptor	;;;;;
		If !IsObject(this.Frame)
			this.Frame:={}
		Idx:=this.Frame.Length()+1
		Console.Send("Image Descriptor [" Idx "]`r`n","-I")
		this.Frame[Idx,"OffsetToImageDescriptor"]:=this.DataMem.Tell()-1
			Console.Send("OffsetToImageDescriptor = " this.Frame[Idx,"OffsetToImageDescriptor"] "`r`n","I")
		this.Frame[Idx,"ImageSeparator"]:=flag	; Always 0x2C
			Console.Send("ImageSeparator = " this.Frame[Idx,"ImageSeparator"] "`r`n","I")
		this.Frame[Idx,"ImageLeft"]:=this.DataMem.ReadUShort()
			Console.Send("ImageLeft = " this.Frame[Idx,"ImageLeft"] "`r`n","I")
		this.Frame[Idx,"ImageTop"]:=this.DataMem.ReadUShort()
			Console.Send("ImageTop = " this.Frame[Idx,"ImageTop"] "`r`n","I")
		this.Frame[Idx,"ImageWidth"]:=this.DataMem.ReadUShort()
			Console.Send("ImageWidth = " this.Frame[Idx,"ImageWidth"] "`r`n","I")
		this.Frame[Idx,"ImageHeight"]:=this.DataMem.ReadUShort()
			Console.Send("ImageHeight = " this.Frame[Idx,"ImageHeight"] "`r`n","I")
		tmp:=this.DataMem.ReadUChar()	; Packed Byte
		this.Frame[Idx,"LocalColorTableFlag"]:=GetBits(tmp,0,1)
			Console.Send("LocalColorTableFlag = " this.Frame[Idx,"LocalColorTableFlag"] "`r`n","I")
		this.Frame[Idx,"InterlaceFlag"]:=GetBits(tmp,1,1)
			Console.Send("InterlaceFlag = " this.Frame[Idx,"InterlaceFlag"] "`r`n","I")
		this.Frame[Idx,"SortFlag"]:=GetBits(tmp,2,1)
			Console.Send("SortFlag = " this.Frame[Idx,"SortFlag"] "`r`n","I")
		this.Frame[Idx,"Reserved2"]:=GetBits(tmp,3,2)
			Console.Send("Reserved2 = " this.Frame[Idx,"Reserved2"] "`r`n","I")
		this.Frame[Idx,"SizeOfLocalColorTable"]:=GetBits(tmp,5,3)
			Console.Send("SizeOfLocalColorTable = " this.Frame[Idx,"SizeOfLocalColorTable"] "`r`n","I")
		this.Frame[Idx,"LengthOfImageDescriptor"]:=this.DataMem.Tell()-this.Frame[Idx,"OffsetToImageDescriptor"]
			Console.Send("LengthOfImageDescriptor = " this.Frame[Idx,"LengthOfImageDescriptor"] "`r`n","I")
		;;;;;	Graphics Control Extension	;;;;;
		this.Frame[Idx,"GCE"]:=GCE
		GCE:=""
		;;;;;	Local Color Table	;;;;;
		If this.Frame[Idx,"LocalColorTableFlag"]
			{
			Console.Send("Local Color Table`r`n","-I")
			this.Frame[Idx,"OffsetToLocalColorTable"]:=this.DataMem.Tell()
				Console.Send("OffsetToLocalColorTable = " this.Frame[Idx,"OffsetToLocalColorTable"] "`r`n","I")
			this.Frame[Idx,"Palette"]:={}
			Loop, % (2**(this.Frame[Idx,"SizeOfLocalColorTable"]+1))
				{
				Idxi:=A_Index-1
				this.Frame[Idx,"Palette",Idxi,"RR"]:=this.DataMem.ReadUChar()
				this.Frame[Idx,"Palette",Idxi,"GG"]:=this.DataMem.ReadUChar()
				this.Frame[Idx,"Palette",Idxi,"BB"]:=this.DataMem.ReadUChar()
				this.Frame[Idx,"Palette",Idxi,"AA"]:=0
				}
				;~ Console.Send("Local Palette = `r`n" st_printArr(this.Frame[Idx,"Palette"]) "`r`n","I")
			If (Settings.DebugLevelL>1)
				{
				Console.Send("Local Palette = `r`n","I")
				this._PrintPalette(this.Frame[Idx,"Palette"])
				}
			this.Frame[Idx,"LengthOfLocalColorTable"]:=this.DataMem.Tell()-this.Frame[Idx,"OffsetToLocalColorTable"]
			Console.Send("LengthOfLocalColorTable = " this.Frame[Idx,"LengthOfLocalColorTable"] "`r`n","I")
			}
		;;;;;	Image Data	;;;;;
		Console.Send("Image Data`r`n","-I")
		this.Frame[Idx,"OffsetToImageData"]:=this.DataMem.Tell()
			Console.Send("OffsetToImageData = " this.Frame[Idx,"OffsetToImageData"] "`r`n","I")
		this.Frame[Idx,"LZWMinimumCodeSize"]:=this.DataMem.ReadUChar()
			Console.Send("LZWMinimumCodeSize = " this.Frame[Idx,"LZWMinimumCodeSize"] "`r`n","I")
		tmp:={}
		While (SubBlockSize:=this.DataMem.ReadUChar())
			{
			Loop, %SubBlockSize%
				tmp.Push(this.DataMem.ReadUChar())
			}
		;~ Console.Send("Original = `r`n" st_printArr(tmp) "`r`n","")
		this.Frame[Idx,"Data"]:=this._LZWDecompress(tmp,this.Frame[Idx,"LZWMinimumCodeSize"],this.Frame[Idx,"ImageWidth"]*this.Frame[Idx,"ImageHeight"])
			;Console.Send("DataStream = '" Data "'`r`n","I")
		If this.Frame[Idx,"InterlaceFlag"]
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "Interlaced frames are not yet supported.", extra: ""}
		this.Frame[Idx,"LengthOfImageData"]:=this.DataMem.Tell()-this.Frame[Idx,"OffsetToImageData"]
			Console.Send("LengthOfImageData = " this.Frame[Idx,"LengthOfImageData"] "`r`n","I")
	}
	_WriteImage(Idx){
		;;;;;	Graphics Control Extension	;;;;;
		If IsObject(this.Frame[Idx,"GCE"])
			this._WriteGraphicControlExtension(this.Frame[Idx,"GCE"])
		;;;;;	Image Descriptor	;;;;;
		;this.DataMem.Seek(this.Frame[Idx,"OffsetToImageDescriptor"],0)
		this.DataMem.WriteUChar(this.Frame[Idx,"ImageSeparator"])	; Always 0x2C
		this.DataMem.WriteUShort(this.Frame[Idx,"ImageLeft"])
		this.DataMem.WriteUShort(this.Frame[Idx,"ImageTop"])
		this.DataMem.WriteUShort(this.Frame[Idx,"ImageWidth"])
		this.DataMem.WriteUShort(this.Frame[Idx,"ImageHeight"])
		tmp:=PackByte(Sz:=[1, 1, 1, 2, 3],this.Frame[Idx,"LocalColorTableFlag"],this.Frame[Idx,"InterlaceFlag"],this.Frame[Idx,"SortFlag"],this.Frame[Idx,"Reserved2"],this.Frame[Idx,"SizeOfLocalColorTable"])
		this.DataMem.WriteUChar(tmp)	; Packed Byte
		;;;;;	Local Color Table	;;;;;
		If this.Frame[Idx,"LocalColorTableFlag"]
			{
			;this.DataMem.Seek(this.Frame[Idx,"OffsetToLocalColorTable"],0)
			tmp:=this.DataMem.Tell()
			Loop, % (this.Frame[Idx,"Palette"].Length()+1)
				{
				Idxi:=A_Index-1
				this.DataMem.WriteUChar(this.Frame[Idx,"Palette",Idxi,"RR"])
				this.DataMem.WriteUChar(this.Frame[Idx,"Palette",Idxi,"GG"])
				this.DataMem.WriteUChar(this.Frame[Idx,"Palette",Idxi,"BB"])
				}
			this.DataMem.Seek(tmp+(3*2**(this.Frame[Idx,"SizeOfLocalColorTable"]+1)),0)
			}
		;;;;;	Image Data	;;;;;
		;this.DataMem.Seek(this.Frame[Idx,"OffsetToImageData"],0)
		;~ this.DataMem.WriteUChar(this.Frame[Idx,"LZWMinimumCodeSize"])
		Arr:=this.Frame[Idx,"Data"].Clone()
		this.Stats.Filesize-=this.Frame[Idx,"LengthOfImageData"]
		Compressed:=this._LZWCompress(Arr,this.Frame[Idx,"LZWMinimumCodeSize"])	; _LZWCompress() already forms SubBlocks and attaches LZWMinimumCodeSize Header
		this.Frame[Idx,"LengthOfImageData"]:=Compressed.Length()
		this.Stats.Filesize+=this.Frame[Idx,"LengthOfImageData"]
		;~ Console.Send("Compressed = `r`n" st_printArr(Compressed) "`r`n","")
		;this._FormatSubBlocks(Compressed,"",0)
		For k,v in Compressed
			this.DataMem.WriteUChar(v)
	}
	_WriteTailer(){
		this.DataMem.WriteUChar(0x3B)
		Return this.DataMem.Tell()
	}
	_FormatSubBlocks(ByRef Arr,Header:="",Footer:=0){
		CountFull:=(Len:=Arr.Length())//255, Remainder:=(Len-255*CountFull)
		Loop, % CountFull
			Arr.InsertAt((A_Index-1)*255+A_Index,255)
		If (Remainder)
			Arr.InsertAt(CountFull*255+CountFull+1,Remainder)
		If (Header<>"")
			Arr.InsertAt(1,Header)
		If (Footer<>"")
			Arr.Push(Footer)
	}
	_ClearCodeTable(LZWMinimumCodeSize){
		Cnt:=2**LZWMinimumCodeSize, CodeTable:={}, CodeTable.SetCapacity(4096)	; This SetCapacity improves speed but potentially uses more memory than is necessary.
		Loop, % Cnt
			CodeTable[Tmp:=A_Index-1]:=Tmp
		CodeTable["CC"]:=Cnt, CodeTable["EoIC"]:=Cnt+1
		Return CodeTable
	}
	_PackBytes(ByRef CodeStream,LZWMinimumCodeSize){
		BitStream:=""
		Loop, % CodeStream.Length()
			BitStream:=CodeStream[A_Index] BitStream
		While Mod(StrLen(BitStream),8)
			BitStream:="0" BitStream
		ByteStream:={}, ByteStream.SetCapacity(Cnt:=StrLen(BitStream)//8)
		Loop, % Cnt
			{
			Byte:=SubStr(BitStream,-8*A_Index+1,8)
			ByteStream.Push(Bin2Num(Byte))
			}
		this._FormatSubBlocks(ByteStream,LZWMinimumCodeSize,0)
		Return ByteStream
	}
	_LZWCompress(ByRef IndexStream, LZWMinimumCodeSize){
		tic:=QPC(1)
		CodeStream:={}, CodeStream.SetCapacity(IndexStream.Length()), VarSetCapacity(IndexBuffer,500,0), NewLZWMinimumCodeSize:=LZWMinimumCodeSize+1
		; Initialize code table
		CodeTable:=this._ClearCodeTable(LZWMinimumCodeSize)
		; Always start by sending a clear code to the code stream.
		CodeStream.Push(Num2Bin(CodeTable["CC"],NewLZWMinimumCodeSize))
		; Read first index from index stream. This value is now the value for the index buffer
		IndexBuffer.=K:=IndexStream.RemoveAt(1)
		; <LOOP POINT>
		While (IndexStream.Length())
			{
			; GIF format specifies a maximum code of #4095
			If (GetKeyCount(CodeTable)=4095)
				{
				; send the clear code 
				CodeStream.Push(Num2Bin(CodeTable["CC"],NewLZWMinimumCodeSize))
				; clear out all of your old codes
				CodeTable:=this._ClearCodeTable(LZWMinimumCodeSize)
				NewLZWMinimumCodeSize:=LZWMinimumCodeSize+1
				}
			; Get the next index from the index stream to the index buffer. We will call this index, K
			K:=IndexStream.RemoveAt(1)
			Comb:=IndexBuffer A_Space K
			; Is index buffer + K in our code table?
			If (CodeTable.HasKey(Comb)) ; Yes
				{
				; add K to the end of the index buffer
				IndexBuffer:=Comb
				; if there are more indexes, return to LOOP POINT
				Continue
				}
			Else	; No
				{
				; Add a row for index buffer + K into our code table with the next smallest code
				CodeTable[Comb]:=Code:=GetKeyCount(CodeTable)
				; Output the code for just the index buffer to our code steam
				CodeStream.Push(Num2Bin(CodeTable[IndexBuffer],NewLZWMinimumCodeSize))
				If (Code=2**NewLZWMinimumCodeSize)
					NewLZWMinimumCodeSize++
				; Index buffer is set to K
				IndexBuffer:=K
				; K is set to nothing
				K:=""
				; if there are more indexes, return to LOOP POINT
				Continue
				}
			}
		; Output code for contents of index buffer
		If (IndexBuffer<>"")
			CodeStream.Push(Num2Bin(CodeTable[IndexBuffer],NewLZWMinimumCodeSize))
		; Output end-of-information code
		CodeStream.Push(Num2Bin(CodeTable["EoIC"],NewLZWMinimumCodeSize))
		ByteStream:=this._PackBytes(CodeStream,LZWMinimumCodeSize)
		Console.Send("Frame compressed in " (QPC(1)-tic) " sec.`r`n","-I")
		Return ByteStream
	}
	_LZWDecompress(ByRef ByteStream,LZWMinimumCodeSize,CountUncompressedBytes:=1){ ; CountUncompressedBytes is an optional parameter that may be used to preallocate memory.  Width*Height is a good value to use for an LZW compressed GIF frame.
		tic:=QPC(1)
		; turn ByteStream into BitStream
		VarSetCapacity(BitStream,Len:=(f8:=(f:=(A_IsUnicode?2:1))*8)*(ByteLen:=ByteStream.Length())+13*f,0)
		Loop, % ByteLen
			StrPut(Num2Bin(ByteStream[A_Index],8),&BitStream+(Len-A_Index*f8),8)
		StrPut("0000000000000",&BitStream,13)
		VarSetCapacity(BitStream,-1)
		NewLZWMinimumCodeSize:=LZWMinimumCodeSize+1, BitIdx:=StrLen(BitStream)-NewLZWMinimumCodeSize+1
		; Initialize code table
		CodeTable:=this._ClearCodeTable(LZWMinimumCodeSize)
		; let CODE be the first code in the code stream
		CODE_1:=CODE:=Bin2Num(SubStr(BitStream,BitIdx,NewLZWMinimumCodeSize)), BitIdx-=NewLZWMinimumCodeSize
		If (CODE=CodeTable["CC"])
			CODE_1:=CODE:=Bin2Num(SubStr(BitStream,BitIdx,NewLZWMinimumCodeSize)), BitIdx-=NewLZWMinimumCodeSize
		; output {CODE} to index stream
		IndexStream:={}, IndexStream.SetCapacity(CountUncompressedBytes), IndexStream.Push(StrSplit(CodeTable[CODE],A_Space)*)
		; <LOOP POINT>
		While 1 ;(BitIdx>0)
			{
			; let CODE be the next code in the code stream
			CODE:=Bin2Num(SubStr(BitStream,BitIdx,NewLZWMinimumCodeSize))
			If (CODE=CodeTable["CC"])
				{
				CodeTable:=this._ClearCodeTable(LZWMinimumCodeSize)
				BitIdx-=NewLZWMinimumCodeSize:=LZWMinimumCodeSize+1
				CODE_1:=CODE:=Bin2Num(SubStr(BitStream,BitIdx,NewLZWMinimumCodeSize)), BitIdx-=NewLZWMinimumCodeSize
				IndexStream.Push(StrSplit(CodeTable[CODE],A_Space)*)
				Continue
				}
			Else If (CODE=CodeTable["EoIC"])
				Break
			; is CODE in the code table?
			If (CodeTable.HasKey(CODE))	; Yes
				{
				; output {CODE} to index stream
				IndexStream.Push(StrSplit(CodeTable[CODE],A_Space)*)
				; let K be the first index in {CODE}
				K:=CodeTable[CODE]
				K+=0
				}
			Else	; No
				{
				; let K be the first index of {CODE-1}
				K:=CodeTable[CODE_1]
				K+=0
				; output {CODE-1}+K to index stream
				IndexStream.Push(StrSplit(CodeTable[CODE_1] A_Space K,A_Space)*)
				}
			; add {CODE-1}+K to code table
			CodeTable[Val:=GetKeyCount(CodeTable)]:=CodeTable[CODE_1] A_Space K
			CODE_1:=CODE
			If (Val=2**NewLZWMinimumCodeSize-1)
				NewLZWMinimumCodeSize++
			BitIdx-=NewLZWMinimumCodeSize
			}
		Console.Send("Frame decompressed in " (QPC(1)-tic) " sec.`r`n","-I")
		Return IndexStream
	}
}

class ExGIFIO extends ImGIFIO{
	ExportFrames(OutputPath,Format:=""){
		SplitPath, OutputPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		If !Format
			Format:=OutExtension
		Fmt:=StrSplit(Format,","), DV:=[8,3]
		If (Fmt.Length()>1)
			DV:=StrSplit(Fmt[2],"V")
		Ext:=(Fmt[1]?Fmt[1]:"bmp")
		StringLower, Ext, Ext
		Loop, % this.Frame.Length()
			this.ExportFrame(A_Index,OutDir "\" OutNameNoExt "_" SubStr("00000" A_Index,-4) "." Ext,Ext,DV[1],DV[2])
	}
	ExportFrame(Idx,OutputPath,Format:="",BitDepth:=8,Version:=3){
		tic:=QPC(1)
		If !Format
			SplitPath, OutputPath, , , Format
		StringLower, Format, Format
		If (Format="BMP")
			{
			Width:=this.Frame[Idx,"ImageWidth"], Height:=this.Frame[Idx,"ImageHeight"]
			If this.Frame[Idx,"LocalColorTableFlag"]
				PalObj:=this.Frame[Idx,"Palette"], CountOfPaletteEntries:=2**(this.Frame[Idx,"SizeOfLocalColorTable"]+1)
			Else If (this.LogicalScreenDescriptor["GlobalColorTableFlag"])
				PalObj:=this.GlobalColorTable["Palette"], CountOfPaletteEntries:=2**(this.LogicalScreenDescriptor["SizeOfGlobalColorTable"]+1)
			Else
				PalObj:={}
			If this.Frame[Idx,"GCE","TransparentColorFlag"]
				TransColorIndex:=this.Frame[Idx,"GCE","TransparentColorIndex"]
			Else
				TransColorIndex:=0
			BMP:=New PSBMP()
			BMP.LoadBMPFromFrameObj(this.Frame[Idx,"Data"],PalObj,"",Width,Height)
			If (BitDepth=32)
				BMP.SetColorTransparency("","","",255) ; Set Opaque
			BMP.SaveBMPToFile(OutputPath,BitDepth,Version)
			BMP:="", VarSetCapacity(Raw,0)
			}
		Else ;If (Format="GIF")
			{
			Console.Send("Saving frame to '" OutputPath "'`r`n")
			Raw:=" ", VarSetCapacity(Raw,this.Stats.FileSize,0)
			this.DataMem:=New MemoryFileIO(Raw,this.Stats.FileSize)
			FinalSize:=this._WriteGIFFrame(Idx)
			SplitPath, OutputPath, , , OutExtension
			If (OutExtension="GIF")
				{
				file:=FileOpen(OutputPath,"w-d")
					file.RawWrite(&Raw,FinalSize)
				file.Close()
				}
			Else
				{
				pToken:=Gdip_Startup()
				pBitmap_F:=GDIPlus_pBitmapFromBuffer(Raw,FinalSize)
				Error:=Gdip_SaveBitmapToFile(pBitmap_F,OutputPath)
				If (Error<0)
					throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "ErrorLevel=" Error A_Tab "A_LastError=" A_LastError, extra: "Error in Gdip_SaveBitmapToFile() trying to convert and save '" OutputPath "' to file."}
				Gdip_DisposeImage(pBitmap_F)
				Gdip_Shutdown(pToken)
				}
			VarSetCapacity(Raw,0), this.DataMem:=""
			}
		Console.Send("Finished exporting GIF frame #" Idx " in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;	Warning:  This function assumes your colors are 8-bit and number no more than 256!!		;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ExportPalette(Pal,Type,OutPath,CountOfPaletteEntries:="",TransColorIndex:=0){
		tic:=QPC(1)
		If (this.LogicalScreenDescriptor["GlobalColorTableFlag"]) AND ((Pal="G") OR (Pal="Global"))	; Use Global Color Table if there is one
			PalObj:=this.GlobalColorTable["Palette"]
		Else	; Pal should be a Frame#, and whichever palette this frame uses will be exported.
			{
			If this.Frame[Pal,"LocalColorTableFlag"]
				PalObj:=this.Frame[Pal,"Palette"]
			Else If (this.LogicalScreenDescriptor["GlobalColorTableFlag"])
				PalObj:=this.GlobalColorTable["Palette"]
			Else
				PalObj:={}
			}
		If this.Frame[Pal,"GCE","TransparentColorFlag"]
			TransColorIndex:=this.Frame[Pal,"GCE","TransparentColorIndex"]
		If !CountOfPaletteEntries
			CountOfPaletteEntries:=PalObj.Length()+1
		PAL:=New PSPAL()
		PAL.ExportPalette(PalObj,Type,OutPath,CountOfPaletteEntries,TransColorIndex)
		PAL:=""
		Console.Send("Palette exported in " Type " format in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	_WriteGIFFrame(Idx){
		this._WriteGIFHeader()
		this._WriteLogicalScreenDescriptor()
		If this.LogicalScreenDescriptor.GlobalColorTableFlag
			this._WriteGlobalColorTable()
		If IsObject(this.Frame[Idx])
			this._WriteImage(Idx)
		Return this._WriteTailer()	; Returns Final Size
	}
	GetPaletteObject(Parent:="Global",Idx:=1){	; Global | Frame
		If IsObject(this.GlobalColorTable["Palette"]) AND ((Parent="Global") OR (Parent="G") OR (Parent="GlobalColorTable"))
			Return ObjFullyClone(this.GlobalColorTable["Palette"])
		Else If (Parent="Frame") OR (Parent="Local") OR (Parent="L")
			{
			If this.Frame[Idx,"LocalColorTableFlag"] AND IsObject(this.Frame[Idx,"Palette"])
				Return this.Frame[Idx,"Palette"]
			Else If (this.LogicalScreenDescriptor["GlobalColorTableFlag"]) AND IsObject(this.GlobalColorTable["Palette"])
				Return this.GlobalColorTable["Palette"]
			}
		Else
			Return PalObj:={}
	}
	GetGIFObjects(Idx,ByRef FrameObj,ByRef PalObj,ByRef FrameObjUP,ByRef Width,ByRef Height,Byref CenterX,Byref CenterY){	; Idx = Index of Frame and should start at 1
		If !IsObject(this.Frame[Idx])
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "Frame# " Idx " does not exist in the GIF.", extra: "Frames range from " this.Frame.MinIndex() " to " this.Frame.MaxIndex()}
		If IsObject(this.Frame[Idx,"Data"])
			{
			FrameObj:=ObjFullyClone(this.Frame[Idx,"Data"])
			FrameObj.RemoveAt(0)	; FrameObj is defined as 0-indexed
			}
		PalObj:=ObjFullyClone(this.GetPaletteObject("Local",Idx))	; Try Local palette 1st, then look for Global
		FrameObjUP:="", FrameObjUP:={}
		For k,v in FrameObj
			{
			FrameObjUP[k,"RR"]:=PalObj[v,"RR"]
			FrameObjUP[k,"GG"]:=PalObj[v,"GG"]
			FrameObjUP[k,"BB"]:=PalObj[v,"BB"]
			FrameObjUP[k,"AA"]:=PalObj[v,"AA"]
			}
		Width:=this.Frame[Idx,"ImageWidth"]
		Height:=this.Frame[Idx,"ImageHeight"]
		CenterX:=this.Frame[Idx,"ImageLeft"]*-1		; Inverse Origin
		CenterY:=this.Frame[Idx,"ImageTop"]*-1		; Inverse Origin
	}

}

class ImGIFIO extends GIFProperties{
	NewGif(){
		VarSetCapacity(Bin,14,0)
		hNGIF:=New MemoryFileIO(&Bin,14)
		hNGIF.Write("GIF89a",6)
		hNGIF.Seek(13,0)
		hNGIF.WriteUChar(0x3B)
		hNGIF:=""
		this.LoadGIFFromMemory(&Bin,14)
	}
}

class GIFProperties extends GIFTransform{
	DeleteApplicationExtension(Idx:=1){
		Sz:=this.ApplicationExtension[Idx,"LengthOfApplicationExtension"]
		this.ApplicationExtension[Idx]:="", this.ApplicationExtension.RemoveAt(Idx,1)
		If !(this.ApplicationExtension.Length())
			this.Delete("ApplicationExtension")
		this.Stats.FileSize-=Sz
		;Console.Send("Deleted Application Extension #" Idx "`r`n","I")
	}
	AddApplicationExtension(ApplicationIdentifier:="NETSCAPE",ApplicationAuthenticationCode:="2.0",LoopCount:=0,Data:=""){
		If (Data="")
			Data:=[]
		If !IsObject(this.ApplicationExtension)
			this.ApplicationExtension:={}
		Idx:=this.ApplicationExtension.Length()+1
		this.ApplicationExtension[Idx,"OffsetToApplicationExtension"]:=0
		this.ApplicationExtension[Idx,"ExtensionIntroducer"]:=0x21
		this.ApplicationExtension[Idx,"ExtensionLabel"]:=0xFF
		BlockSize:=11
		this.ApplicationExtension[Idx,"ApplicationIdentifier"]:=ApplicationIdentifier
		this.ApplicationExtension[Idx,"ApplicationAuthenticationCode"]:=ApplicationAuthenticationCode
		If (ApplicationIdentifier ApplicationAuthenticationCode="NETSCAPE2.0")
			{
			SubBlockSize:=3+1	;(The +1 is for the Block Terminator - 0x00)
			this.ApplicationExtension[Idx,"Static"]:=0x01
			this.ApplicationExtension[Idx,"LoopCount"]:=LoopCount
			}
		Else
			{
			this.ApplicationExtension[Idx,"Data"]:=Data
			Arr:=Data.Clone()
			this._FormatSubBlocks(Arr,"",0)
			SubBlockSize:=Arr.Length()
			}
		Len:=this.ApplicationExtension[Idx,"LengthOfApplicationExtension"]:=3+BlockSize+SubBlockSize
		this.Stats.FileSize+=Len
		;Console.Send("Added Application Extension #" Idx "`r`n","I")
	}
	DeleteCommentExtension(Idx:=1){
		Sz:=this.CommentExtension[Idx,"LengthOfCommentExtension"]
		this.CommentExtension[Idx]:="", this.CommentExtension.RemoveAt(Idx,1)
		If !(this.CommentExtension.Length())
			this.Delete("CommentExtension")
		this.Stats.FileSize-=Sz
		;Console.Send("Deleted Comment Extension #" Idx "`r`n","I")
	}
	AddCommentExtension(Text:=""){
		If !IsObject(this.CommentExtension)
			this.CommentExtension:={}
		Idx:=this.CommentExtension.Length()+1
		this.CommentExtension[Idx,"OffsetToCommentExtension"]:=0
		this.CommentExtension[Idx,"ExtensionIntroducer"]:=0x21
		this.CommentExtension[Idx,"ExtensionLabel"]:=0xFE
		this.CommentExtension[Idx,"Text"]:=Text
		;;;;;
		TextArr:=String2Array(Text)
		this._FormatSubBlocks(TextArr,"",0)
		SubBlockSize:=TextArr.Length()
		;;;;;
		Len:=this.CommentExtension[Idx,"LengthOfCommentExtension"]:=2+SubBlockSize
		this.Stats.FileSize+=Len
		;Console.Send("Added Comment Extension #" Idx "`r`n","I")
	}
	DeletePlainTextExtension(Idx:=1){
		Sz:=this.PlainTextExtension[Idx,"LengthOfPlainTextExtension"], SzGCE:=0
		If IsObject(this.PlainTextExtension[Idx,"GCE"])
			SzGCE:=this.PlainTextExtension[Idx,"GCE","LengthOfGraphicsControlExtension"]
		this.PlainTextExtension[Idx]:="", this.PlainTextExtension.RemoveAt(Idx,1)
		If !(this.PlainTextExtension.Length())
			this.Delete("PlainTextExtension")
		this.Stats.FileSize-=(Sz+SzGCE)
		;Console.Send("Deleted Plain Text Extension #" Idx "`r`n","I")
	}
	AddPlainTextExtension(Text:="",TextGridLeftPosition:="",TextGridTopPosition:="",TextGridWidth:="",TextGridHeight:="",CharacterCellWidth:="",CharacterCellHeight:="",TextForegroundColorIndex:="",TextBackgroundColorIndex:=""){
		If !IsObject(this.PlainTextExtension)
			this.PlainTextExtension:={}
		Idx:=this.PlainTextExtension.Length()+1
		this.PlainTextExtension[Idx,"OffsetToPlainTextExtension"]:=0
		this.PlainTextExtension[Idx,"ExtensionIntroducer"]:=0x21
		this.PlainTextExtension[Idx,"ExtensionLabel"]:=0x01
		this.PlainTextExtension[Idx,"Text"]:=Text
		BlockSize:=this.PlainTextExtension[Idx,"BlockSize"]:=12
		CanvasWidth:=this.LogicalScreenDescriptor["CanvasWidth"]
		CanvasHeight:=this.LogicalScreenDescriptor["CanvasHeight"]
		BackgroundColorIndex:=this.LogicalScreenDescriptor["BackgroundColorIndex"]
		If (CharacterCellWidth="")
			CharacterCellWidth:=8
		If (CharacterCellHeight="")
			CharacterCellHeight:=16
		If (TextBackgroundColorIndex="")
			TextBackgroundColorIndex:=BackgroundColorIndex
		If (TextForegroundColorIndex="")
			TextForegroundColorIndex:=!BackgroundColorIndex
		If (TextGridWidth="")
			TextGridWidth:=(CanvasWidth//CharacterCellWidth)*CharacterCellWidth, TextGridWidth:=(TextGridWidth=0?1:TextGridWidth)
		If (TextGridHeight="")
			TextGridHeight:=(CanvasHeight//CharacterCellHeight)*CharacterCellHeight, TextGridHeight:=(TextGridHeight=0?1:TextGridHeight)
		If (TextGridLeftPosition="")
			TextGridLeftPosition:=(CanvasWidth-TextGridWidth)//2
		If (TextGridTopPosition="")
			TextGridTopPosition:=(CanvasHeight-TextGridHeight)//2
		this.PlainTextExtension[Idx,"TextGridLeftPosition"]:=TextGridLeftPosition
		this.PlainTextExtension[Idx,"TextGridTopPosition"]:=TextGridTopPosition
		this.PlainTextExtension[Idx,"TextGridWidth"]:=TextGridWidth
		this.PlainTextExtension[Idx,"TextGridHeight"]:=TextGridHeight
		this.PlainTextExtension[Idx,"CharacterCellWidth"]:=CharacterCellWidth
		this.PlainTextExtension[Idx,"CharacterCellHeight"]:=CharacterCellHeight
		this.PlainTextExtension[Idx,"TextForegroundColorIndex"]:=TextForegroundColorIndex
		this.PlainTextExtension[Idx,"TextBackgroundColorIndex"]:=TextBackgroundColorIndex
		;;;;;
		TextArr:=String2Array(Text)
		this._FormatSubBlocks(TextArr,"",0)
		SubBlockSize:=TextArr.Length()
		;;;;;
		Sz:=3+BlockSize+SubBlockSize
		SzGCE:=0	; There is no Graphics Control Extension yet
		this.Stats.FileSize+=(Sz+SzGCE)
		this.PlainTextExtension[Idx,"LengthOfPlainTextExtension"]:=Sz+SzGCE
		;Console.Send("Added Plain Text Extension #" Idx "`r`n","I")
	}
	DeleteGraphicsControlExtension(Idx:=1,Parent:="Frame"){	; Frame | PlainTextExtension
		If IsObject(this[Parent,Idx,"GCE"])
			{
			SzGCE:=this[Parent,Idx,"GCE","LengthOfGraphicsControlExtension"]
			this[Parent,Idx,"GCE"]:="", this[Parent,Idx].Delete("GCE")
			this.Stats.FileSize-=SzGCE
			;Console.Send("Deleted Graphics Control Extension from " Parent " #" Idx "`r`n","I")
			}
	}
	AddGraphicsControlExtension(Idx:=1,Parent:="Frame",DisposalMethod:=0,UserInputFlag:=0,TransparentColorFlag:=0,DelayTime:=0,TransparentColorIndex:=0){	; Frame | PlainTextExtension
		If !IsObject(this[Parent,Idx,"GCE"])
			this[Parent,Idx,"GCE"]:={}
		this[Parent,Idx,"GCE","OffsetToGraphicsControlExtension"]:=0
		this[Parent,Idx,"GCE","ExtensionIntroducer"]:=0x21
		this[Parent,Idx,"GCE","ExtensionLabel"]:=0xF9
		this[Parent,Idx,"GCE","BlockSize"]:=4
		this[Parent,Idx,"GCE","Reserved1"]:=0
		this[Parent,Idx,"GCE","DisposalMethod"]:=DisposalMethod
		this[Parent,Idx,"GCE","UserInputFlag"]:=UserInputFlag	; Probably always 0
		this[Parent,Idx,"GCE","TransparentColorFlag"]:=TransparentColorFlag
		this[Parent,Idx,"GCE","DelayTime"]:=DelayTime
		this[Parent,Idx,"GCE","TransparentColorIndex"]:=TransparentColorIndex
		this[Parent,Idx,"GCE","BlockTerminator"]:=0
		this[Parent,Idx,"GCE","LengthOfGraphicsControlExtension"]:=8
		this.Stats.FileSize+=8
		;Console.Send("Added Graphics Control Extension to " Parent " #" Idx "`r`n","I")
	}
	DeleteLocalColorTable(Idx:=1){
		If !IsObject(this.GlobalColorTable["Palette"]) AND IsObject(this.Frame[Idx,"Palette"])	; Has a Local Color Palette but there is no Global Color Palette
			{
			If !IsObject(this.GlobalColorTable)
				this.GlobalColorTable:={}
			this.GlobalColorTable["Palette"]:=this.GetPaletteObject("Local",Idx)
			this.GlobalColorTable["OffsetToGlobalColorTable"]:=0
			this.GlobalColorTable["LengthOfGlobalColorTable"]:=(this.GlobalColorTable["Palette"].Length()+1)*3
			this.LogicalScreenDescriptor["GlobalColorTableFlag"]:=1
			this.LogicalScreenDescriptor["SizeOfGlobalColorTable"]:=Round((Log(this.GlobalColorTable["Palette"].Length()+1)/Log(2))-1)
			this.Stats.FileSize+=this.GlobalColorTable["LengthOfGlobalColorTable"]
			}
		If IsObject(this.Frame[Idx,"Palette"])
			{
			this.Frame[Idx,"Palette"]:="", this.Frame[Idx].Delete("Palette")
			this.Frame[Idx,"LocalColorTableFlag"]:=0
			this.Frame[Idx,"SizeOfLocalColorTable"]:=0
			this.Frame[Idx,"OffsetToLocalColorTable"]:=0
			this.Stats.FileSize-=this.Frame[Idx,"LengthOfLocalColorTable"]
			this.Frame[Idx,"LengthOfLocalColorTable"]:=0
			;Console.Send("Deleted Local Color Table from Frame #" Idx "`r`n","I")
			}
	}
	AddLocalColorTable(Idx:=1,PalObj:=""){	; Force/Replace only
		If !IsObject(PalObj) AND IsObject(this.GlobalColorTable)
			PalObj:=this.GetPaletteObject("Global")
		If IsObject(PalObj)
			{
			If !IsObject(this.Frame[Idx,"Palette"])
				this.Frame[Idx,"Palette"]:={}
			this.Frame[Idx,"Palette"]:=PalObj
			this.Frame[Idx,"LocalColorTableFlag"]:=1
			this.Frame[Idx,"OffsetToLocalColorTable"]:=0
			this.Frame[Idx,"LengthOfLocalColorTable"]:=(this.Frame[Idx,"Palette"].Length()+1)*3
			this.Frame[Idx,"SizeOfLocalColorTable"]:=Round((Log(this.Frame[Idx,"Palette"].Length()+1)/Log(2))-1)
			this.Stats.FileSize+=this.Frame[Idx,"LengthOfLocalColorTable"]
			;Console.Send("Added Local Color Table to Frame #" Idx "`r`n","I")
			}
	}
	DeleteGlobalColorTable(){
		If IsObject(this.GlobalColorTable)	; There is a Global Color Table to delete
			{
			Loop, % this.Frame.Length()
				{
				If (this.Frame[A_Index,"LocalColorTableFlag"]=0)
					this.AddLocalColorTable(A_Index)
				}
			Sz:=this.GlobalColorTable["LengthOfGlobalColorTable"]
			;this.GlobalColorTable:="", 
			this.Delete["GlobalColorTable"]
			this.LogicalScreenDescriptor["GlobalColorTableFlag"]:=0
			this.LogicalScreenDescriptor["SizeOfGlobalColorTable"]:=0
			this.Stats.FileSize-=Sz
			;Console.Send("Deleted Global Color Table`r`n","I")
			}
	}
	AddGlobalColorTable(PalObj:=""){	; Force/Replace only
		If !IsObject(PalObj)
			{
			Loop, % this.Frame.Length()
				{
				If (this.Frame[A_Index,"LocalColorTableFlag"]=1)
					{
					PalObj:=this.GetPaletteObject("Local",A_Index)
					Break
					}
				}
			}
		If IsObject(PalObj)
			{
			If !IsObject(this.GlobalColorTable)
				this.GlobalColorTable:={}
			this.GlobalColorTable["Palette"]:=PalObj
			this.GlobalColorTable["OffsetToGlobalColorTable"]:=0
			this.LogicalScreenDescriptor["GlobalColorTableFlag"]:=1
			this.LogicalScreenDescriptor["SizeOfGlobalColorTable"]:=N:=Round((Log(this.GlobalColorTable["Palette"].Length()+1)/Log(2))-1)
			this.LogicalScreenDescriptor["ColorResolution"]:=N
			While ((Next:=this.GlobalColorTable["Palette"].Length()+1)<2**(N+1))
				{
				this.GlobalColorTable["Palette",Next]:={}
				this.GlobalColorTable["Palette",Next,"RR"]:=0
				this.GlobalColorTable["Palette",Next,"GG"]:=0
				this.GlobalColorTable["Palette",Next,"BB"]:=0
				this.GlobalColorTable["Palette",Next,"AA"]:=0
				}
			LZWMinimumCodeSize:=Round(Log(this.GlobalColorTable["Palette"].Length()+1)/Log(2))
			Loop, % this.Frame.Length()
				{
				If (this.Frame[A_Index,"LocalColorTableFlag"]=0)
					this.Frame[Idx,"LZWMinimumCodeSize"]:=LZWMinimumCodeSize
				}
			Sz:=this.GlobalColorTable["LengthOfGlobalColorTable"]:=(this.GlobalColorTable["Palette"].Length()+1)*3
			this.Stats.FileSize+=Sz
			;Console.Send("Added Global Color Table`r`n","I")
			}
	}
	ReplaceLogicalScreenDescriptor(CanvasWidth:=0,CanvasHeight:=0,GlobalColorTableFlag:=0,ColorResolution:=0,SortFlag:=0,SizeOfGlobalColorTable:=0,BackgroundColorIndex:=0,PixelAspectRatio:=0){
		If !IsObject(this.LogicalScreenDescriptor)
				this.LogicalScreenDescriptor:={}
		this.LogicalScreenDescriptor.CanvasWidth:=CanvasWidth
		this.LogicalScreenDescriptor.CanvasHeight:=CanvasHeight
		this.LogicalScreenDescriptor.GlobalColorTableFlag:=GlobalColorTableFlag
		this.LogicalScreenDescriptor.ColorResolution:=ColorResolution
		this.LogicalScreenDescriptor.SortFlag:=SortFlag
		this.LogicalScreenDescriptor.SizeOfGlobalColorTable:=SizeOfGlobalColorTable
		this.LogicalScreenDescriptor.BackgroundColorIndex:=BackgroundColorIndex
		this.LogicalScreenDescriptor.PixelAspectRatio:=PixelAspectRatio
		;Console.Send("Set Logical Screen Descriptor`r`n","I")
	}
	DeleteFrame(Idx){
		this.Frame.RemoveAt(Idx)
		; Can decrease this.Stats.FileSize here
	}
	AddFrame(ByRef FrameObj,Idx:=""){	; Leave Idx blank to add frame to end | Currently only uses Global Color Table
		If !IsObject(this.Frame)
			this.Frame:={}
		If (Idx="")
			Idx:=this.Frame.Length()+1
		If !IsObject(this.Frame[Idx])
			this.Frame[Idx]:={}
		Else
			this.Frame.InsertAt(Idx," "), this.Frame[Idx]:={}
		Frm:=ObjFullyClone(FrameObj)
		this.Frame[Idx,"Data"]:=ShiftArray(Frm)
		this.Frame[Idx,"LZWMinimumCodeSize"]:=8
		Sz:=this.Frame[Idx,"Data"].Length()
		this.Stats.FileSize+=(Sz<10?10:Sz)
		;Console.Send("Added Frame #" Idx " to gif`r`n","I")
		Return Idx	; Return where the frame was inserted into GIF
	}
	SetImageDescriptor(Idx,ImageLeft:=0,ImageTop:=0,ImageWidth:=0,ImageHeight:=0,LocalColorTableFlag:=0,InterlaceFlag:=0,SortFlag:=0,SizeOfLocalColorTable:=0){
		If !IsObject(this.Frame[Idx])
			this.Frame[Idx]:={}
		If !this.Frame[Idx,"ImageSeparator"]
			this.Stats.FileSize+=10
		this.Frame[Idx,"ImageSeparator"]:=0x2C
		this.Frame[Idx,"ImageLeft"]:=ImageLeft
		this.Frame[Idx,"ImageTop"]:=ImageTop
		this.Frame[Idx,"ImageWidth"]:=ImageWidth
		this.Frame[Idx,"ImageHeight"]:=ImageHeight
		this.Frame[Idx,"LocalColorTableFlag"]:=LocalColorTableFlag
		this.Frame[Idx,"InterlaceFlag"]:=InterlaceFlag
		this.Frame[Idx,"SortFlag"]:=SortFlag
		this.Frame[Idx,"Reserved2"]:=0
		this.Frame[Idx,"SizeOfLocalColorTable"]:=SizeOfLocalColorTable
		;Console.Send("Set Image Descriptor`r`n","I")
	}
	GetCountOfFrames(){
		Return GetKeyCount(this.Frame)
	}
	GetFileSize(){
		Return this.Stats.FileSize
	}
}

class GIFTransform{
	TransformBackgroundColor(R,G,B,A:=0){
		If (GlobalColorTableFlag:=this.LogicalScreenDescriptor["GlobalColorTableFlag"]=1)	; We have a global color table
			{
			BackgroundColorIndex:=this.LogicalScreenDescriptor["BackgroundColorIndex"]
			this.GlobalColorTable["Palette",BackgroundColorIndex,"RR"]:=R
			this.GlobalColorTable["Palette",BackgroundColorIndex,"GG"]:=G
			this.GlobalColorTable["Palette",BackgroundColorIndex,"BB"]:=B
			this.GlobalColorTable["Palette",BackgroundColorIndex,"AA"]:=A
			}
	}
	TransformTransColor(R,G,B,A:=0){
		GlobalColorTableFlag:=this.LogicalScreenDescriptor["GlobalColorTableFlag"]
		For k,v in this.Frame
			{
			If (TransparentColorFlag:=this.Frame[k,"GCE","TransparentColorFlag"])
				{
				TransparentColorIndex:=this.Frame[k,"GCE","TransparentColorIndex"]
				If (LocalColorTableFlag:=this.Frame[k,"LocalColorTableFlag"])
					{
					this.Frame[k,"Palette",TransparentColorIndex,"RR"]:=R
					this.Frame[k,"Palette",TransparentColorIndex,"GG"]:=G
					this.Frame[k,"Palette",TransparentColorIndex,"BB"]:=B
					this.Frame[k,"Palette",TransparentColorIndex,"AA"]:=A
					}
				Else If (GlobalColorTableFlag)
					{
					this.GlobalColorTable["Palette",TransparentColorIndex,"RR"]:=R
					this.GlobalColorTable["Palette",TransparentColorIndex,"GG"]:=G
					this.GlobalColorTable["Palette",TransparentColorIndex,"BB"]:=B
					this.GlobalColorTable["Palette",TransparentColorIndex,"AA"]:=A
					}
				}
			}
	}
	Unify(Setting:=1){
		tic:=QPC(1)
		MaxXCoord:=0
		MaxYCoord:=0
		Loop, % this.Frame.Length()
			{
			If (this.Frame[A_Index,"ImageLeft"]>MaxXCoord)
				MaxXCoord:=this.Frame[A_Index,"ImageLeft"]
			If (this.Frame[A_Index,"ImageTop"]>MaxYCoord)
				MaxYCoord:=this.Frame[A_Index,"ImageTop"]
			}
		MaxWidth:=this.LogicalScreenDescriptor["CanvasWidth"]
		MaxHeight:=this.LogicalScreenDescriptor["CanvasHeight"]
		Loop, % this.Frame.Length()
			{
			;~ this.Stats.FileSize-=this.Frame[A_Index,"Data"].Length()
			If this.Frame[A_Index,"GCE","TransparentColorFlag"]
				PalEntry:=this.Frame[A_Index,"GCE","TransparentColorIndex"]
			Else
				PalEntry:=this.LogicalScreenDescriptor["BackgroundColorIndex"]
			InsertLeft:=this.Frame[A_Index,"ImageLeft"]	;(MaxXCoord - this.Frame[A_Index,"ImageLeft"])
			InsertTop:=this.Frame[A_Index,"ImageTop"]	;(MaxYCoord - this.Frame[A_Index,"ImageTop"])
			this._InsertRC(this.Frame[A_Index],PalEntry,InsertTop,0,InsertLeft,0)
			this.Frame[A_Index,"ImageWidth"]+=InsertLeft
			this.Frame[A_Index,"ImageHeight"]+=InsertTop
			If (this.Frame[A_Index,"ImageWidth"]>MaxWidth)
				MaxWidth:=this.Frame[A_Index,"ImageWidth"]
			If (this.Frame[A_Index,"ImageHeight"]>MaxHeight)
				MaxHeight:=this.Frame[A_Index,"ImageHeight"]
			If (Setting=2)
				{
				If (MaxWidth>MaxHeight)
					MaxHeight:=MaxWidth
				If (MaxHeight.MaxWidth)
					MaxWidth:=MaxHeight
				}
			this.Stats.FileSize+=this.Frame[A_Index,"Data"].Length()
			}
		Loop, % this.Frame.Length()
			{
			;~ this.Stats.FileSize-=this.Frame[A_Index,"Data"].Length()
			If this.Frame[A_Index,"GCE","TransparentColorFlag"]
				PalEntry:=this.Frame[A_Index,"GCE","TransparentColorIndex"]
			Else
				PalEntry:=this.LogicalScreenDescriptor["BackgroundColorIndex"]
			InsertRight:=(MaxWidth-this.Frame[A_Index,"ImageWidth"])
			InsertBottom:=(MaxHeight-this.Frame[A_Index,"ImageHeight"])
			this._InsertRC(this.Frame[A_Index],PalEntry,0,InsertBottom,0,InsertRight)
			this.Frame[A_Index,"ImageWidth"]:=MaxWidth
			this.Frame[A_Index,"ImageHeight"]:=MaxHeight
			this.Frame[A_Index,"ImageLeft"]:=0
			this.Frame[A_Index,"ImageTop"]:=0
			this.Stats.FileSize+=this.Frame[A_Index,"Data"].Length()
			}
		this.LogicalScreenDescriptor["CanvasWidth"]:=MaxWidth
		this.LogicalScreenDescriptor["CanvasHeight"]:=MaxHeight
		
		Console.Send("Unified frames in " (QPC(1)-tic) " sec.`r`n","-I")
	}
	_InsertRC(ByRef FrameObj,PalEntry,Top,Bottom,Left,Right){
		Width:=FrameObj["ImageWidth"]
		Height:=FrameObj["ImageHeight"]
		If (Top>0) AND (Width*Top>0)
			{
			Loop, % (Width*Top)
				FrameObj["Data"].InsertAt(1,PalEntry)
			Height+=Top
			}
		If (Bottom>0) AND (Width*Bottom>0)
			Loop % (Width*Bottom)
				FrameObj["Data"].Push(PalEntry)
			Height+=Bottom
		If (Left>0) AND (Height>0)
			{
			Loop, %Height%
				{
				Index:=(A_Index-1)*Width+(A_Index-1)*Left+1
				Loop, %Left%
					{
					FrameObj["Data"].InsertAt(Index,PalEntry)
					}
				}
			Width+=Left
			}
		If (Right>0) AND (Height>0)
			{
			Loop, %Height%
				{
				Index:=(A_Index)*Width+(A_Index-1)*Right+1
				Loop, %Right%
					{
					FrameObj["Data"].InsertAt(Index,PalEntry)
					}
				}
			Width+=Right
			}
	}
}

