;
; AutoHotkey Version: 1.1.30.01
; Language:       English
; Platform:       Optimized for Windows 10
; Author:         Sam.
;

;;;;;	Reference Documents	;;;;;
; https://github.com/Sampsca/MemoryFileIO
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62067
; https://autohotkey.com/docs/objects/File.htm
; https://docs.microsoft.com/en-us/windows/desktop/devnotes/rtlmovememory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;	Dependencies	;;;;;
; https://github.com/Sampsca/PS_ExceptionHandler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;          MemoryFileIO          ;;;;;
;;;;;  Copyright (c) 2016-2019 Sam.  ;;;;;
;;;;;     Last Updated 20190328      ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;////////////////////////////////////////////////
;///////////// Class MemoryFileIO ///////////////
;////////////////////////////////////////////////
;;; Provides Input/Output File Object syntax for in-memory files and buffers.
;;; Usage is very similar to the File Object syntax: 
;;; 	https://autohotkey.com/docs/objects/File.htm
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; New MemoryFileIO() ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Creates a new instance of the class.
;;; Syntax:  Instance := New MemoryFileIO(VarOrAddress [, Size, DefaultEncoding, StoreBufferInternally])
;;; Pass a buffer (by variable name or memory address) to VarOrAddress that you will be performing read/write
;;; 	operations on.  If the buffer is passed by address, VarSize should be the size of the buffer in bytes.  If
;;; 	VarOrAddress is passed a variable and VarSize is not given, the size will be determined by VarSetCapacity()
;;; 	which may return a size 1 byte larger than intended due to an ending null terminator in the buffer.
;;; This class will bound all reads/writes to the memory already allocated to the input variable or address+Size
;;; 	upon creating the instance of the class, UNLESS StoreBufferInternally=1.  If StoreBufferInternally=0, you
;;; 	will need to use VarSetCapacity() to initialize enough memory for your needs BEFORE creating a new
;;; 	instance with your variable.
;;; If StoreBufferInternally=1, the memory buffer will be stored internally in the class and will be dynamically
;;; 	resized as required.  If VarOrAddress was passed a valid variable or memory address, the internal buffer
;;; 	will be initialized to a copy of this buffer.  Otherwise, an empty internal buffer will be initialized of Size
;;; 	bytes, unless Size is also not specified in which case a blank internal buffer will be initialized.  Note
;;; 	that changing the buffer size will invalidate any previously saved pointers to it.  See .GetBufferAddress().
;;; DefaultEncoding defaults to A_FileEncoding if not specified.
;;; This class will raise an exception on error.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Read ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Reads a string of characters from the file and advances the file pointer.
;;; Syntax:  String := Instance.Read([Characters, Encoding = None])
;;; Characters:	The maximum number of characters to read. If omitted, 
;;;		the rest of the file is read and returned as one string.
;;; Encoding: The source encoding; for example, "UTF-8", "UTF-16" or "CP936".
;;;		Specify an empty string or "CP0" to use the system default ANSI code page.
;;; Returns: A string.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Write ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Writes a string of characters to the file and advances the file pointer.
;;; Syntax:  NumWritten := Instance.Write(String [, Characters, Encoding])
;;; String: A string.
;;; Characters: The maximum number of characters to write. If omitted, 
;;;		all of String is written.
;;; Encoding: The target encoding; for example, "UTF-8", "UTF-16" or "CP936".
;;;		Specify an empty string or "CP0" to use the system default ANSI code page.
;;; Returns: The number of bytes (not characters) that were written.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; ReadNum ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Reads a number from the file and advances the file pointer.
;;; Syntax:  Num := Instance.ReadNumType()
;;; NumType: One of the following specified directly as part of the method name:
;;; 	UInt, Int, Int64, Short, UShort, Char, UChar, Double, Float, Ptr, UPtr
;;; 	DWORD, Long, WORD, or BYTE
;;; Returns: A number if successful.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; WriteNum ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Writes a number to the file and advances the file pointer.
;;; Syntax:  Instance.WriteNumType(Num)
;;; NumType: One of the following specified directly as part of the method name:
;;; 	UInt, Int, Int64, Short, UShort, Char, UChar, Double, Float, Ptr, UPtr
;;; 	DWORD, Long, WORD, or BYTE
;;; Num: A number.
;;; Returns: The number of bytes that were written. For instance, WriteUInt 
;;; 	returns 4 if successful.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; RawRead ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copies raw binary data from the file to another memory address or variable.
;;; 	If a var is specified, it is expanded automatically when necessary.
;;; 	If a var is specified that contains only an integer, that integer is 
;;; 	considered the address.
;;; Syntax:  Instance.RawRead(VarOrAddress, Bytes)
;;; VarOrAddress: A variable or memory address to which the data will be copied.
;;; Bytes: The maximum number of bytes to read.
;;; Returns: The number of bytes that were read.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; RawWrite ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Write raw binary data to the file from another memory address or variable.
;;; 	If a var is specified that contains only an integer, that integer is 
;;; 	considered the address.  If VarOrAddress is a variable and Bytes is
;;; 	greater than the capacity of VarOrAddress, Bytes is reduced to the capacity
;;; 	of VarOrAddress (unless the buffer is being stored internally in the class).
;;; Syntax:  Instance.RawWrite(VarOrAddress, Bytes)
;;; VarOrAddress: A variable containing the data or the address of the data in memory.
;;; Bytes: The number of bytes to write.
;;; Returns: The number of bytes that were written.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Seek ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Moves the file pointer.
;;; Syntax:	Instance.Seek(Distance [, Origin])
;;; 	Instance.Position := Distance
;;; 	Instance.Pos := Distance
;;; Distance: Distance to move, in bytes. Lower values are closer to the 
;;; 	beginning of the file.
;;; Origin: Starting point for the file pointer move. Must be one of the following:
;;; 	0 (SEEK_SET): Beginning of the file. Distance must be zero or greater.
;;; 	1 (SEEK_CUR): Current position of the file pointer.
;;; 	2 (SEEK_END): End of the file. Distance should usually be negative.
;;; 	If omitted, Origin defaults to SEEK_END when Distance is negative 
;;; 	and SEEK_SET otherwise.
;;; Returns one of the following values:
;;; 	-1 : Pointer was instructed to move before beginning of file.
;;; 		 Automatically moved to beginning of file instead.
;;; 	1  : Pointer is still in bounds or if EoF was reached.
;;; 	2  : Pointer was instructed to move past EoF.
;;; 		 Automatically moved to EoF instead.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Tell ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Syntax:	Pos := Instance.Tell()
;;; 	Pos := Instance.Position
;;; 	Pos := Instance.Pos
;;; Returns: The current position of the file pointer, where 0 is the 
;;; 	beginning of the file.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; Length ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Retrieves the size of the file.  Setting a new size is not directly supported.
;;; Syntax:	FileSize := Instance.Length
;;; Returns: 	The size of the file, in bytes.
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; AtEoF ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Syntax:	IsAtEoF := Instance.AtEoF
;;; Returns: A non-zero value if the file pointer has reached the 
;;; 	end of the file, otherwise zero.
;;; Note that in the current implementation, only Seek() adjusts the value of AtEoF.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; Encoding ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Retrieves or sets the text encoding used by this method.
;;; Encoding defaults to A_FileEncoding which defaults to the system 
;;; 	default ANSI code page ("CP0") if not specified.
;;; Syntax:	Encoding := Instance.Encoding
;;; 		Instance.Encoding := Encoding
;;; Encoding: 	A numeric code page identifier (see MSDN) or 
;;; 	one of the following strings:
;;; 	UTF-8: Unicode UTF-8, equivalent to CP65001.
;;; 	UTF-16: Unicode UTF-16 with little endian byte order, equivalent to CP1200.
;;; 	CPnnn: a code page with numeric identifier nnn.
;;; Setting Encoding never causes a BOM to be added or removed.
;;;
;////////////////////////////////////////////////
;//////////// Supplemental Methods //////////////
;////////////////////////////////////////////////
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; GetBufferAddress ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; If the buffer has been resized, any previously saved pointers to it will be
;;; 	invalidated.  This method can be used to find the current address.
;;; Syntax:  Address := Instance.GetBufferAddress()
;;; Returns: The current memory address of the buffer.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; GetBufferSize ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Syntax:  Size := Instance.GetBufferSize()
;;; Returns: The current size (in bytes) of the memory buffer.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; CopyBufferToVar ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copies the entire current buffer into the given variable, resizing it if necessary.
;;; Syntax:  Size := Instance.CopyBufferToVar(Var)
;;; Returns: The new size (in bytes) of Var.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; CopyBufferToAddress ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copies the current buffer to the given memory address.  There must already be enough space reserved
;;; 	at the given address to hold the entire buffer.
;;; Syntax:  NumWritten := Instance.CopyBufferToAddress(DestinationAddress)
;;; Returns: The number of bytes written to DestinationAddress.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; ResizeInternalBuffer ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Adjusts the capacity of the current buffer to RequestedCapacity.  Only the capacity of an internal
;;; 	buffer can be resized in this way.
;;; Syntax:  GrantedCapacity := Instance.ResizeInternalBuffer(RequestedCapacity)
;;; Returns: The new capacity of the buffer.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; ResizeExternalVarContainingBuffer ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Resizes the non-object variable containing the external memory buffer.  The current contents are preserved.
;;; Syntax:  NumWritten := Instance.ResizeExternalVarContainingBuffer(Var,CurrentCapacity,RequestedCapacity)
;;; Var: The variable containing the external buffer.
;;; CurrentCapacity:  The current capacity of this variable.
;;; RequestedCapacity:  The desired capacity of this variable.
;;; Returns: The new address referenced by Var.
;;;
;////////////////////////////////////////////////
;/////////////// Internal Methods ///////////////
;////////////////////////////////////////////////
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; _BCopy ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copies binary data from one address to another.
;;; Syntax:  Instance._BCopy(Source,Destination,Length)
;;; Source:  Address of buffer to be copied.
;;; Destination:  Address of where the buffer will be copied to.
;;; Length:  Length of the binary buffer to copy.
;;; Returns: N/A
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; NumTypes ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; Name      Size    Alias ;;;;;;;;;;;;
;;;;;;;;;;;; UInt      4       DWORD ;;;;;;;;;;;;
;;;;;;;;;;;; Int       4       Long  ;;;;;;;;;;;;
;;;;;;;;;;;; Int64     8             ;;;;;;;;;;;;
;;;;;;;;;;;; Short     2             ;;;;;;;;;;;;
;;;;;;;;;;;; UShort    2       WORD  ;;;;;;;;;;;;
;;;;;;;;;;;; Char      1             ;;;;;;;;;;;;
;;;;;;;;;;;; UChar     1       BYTE  ;;;;;;;;;;;;
;;;;;;;;;;;; Double    8             ;;;;;;;;;;;;
;;;;;;;;;;;; Float     4             ;;;;;;;;;;;;
;;;;;;;;;;;; Ptr       A_PtrSize     ;;;;;;;;;;;;
;;;;;;;;;;;; UPtr      A_PtrSize     ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Declare class:
Class MemoryFileIO{
	__New(ByRef VarOrAddress, Size:="", DefaultEncoding:="", StoreBufferInternally:=0){
		If VarOrAddress is not integer ; Is a Variable not an Address
			this.Address:=&VarOrAddress
		Else
			this.Address:=VarOrAddress
		this.Position:=0
		this.Length:=(Size=""?VarSetCapacity(VarOrAddress):Size)
		this.AtEoF:=0
		this.Encoding:=(DefaultEncoding=""?A_FileEncoding:DefaultEncoding)
		If (this.Internal:=((!VarOrAddress AND !Size)?1:StoreBufferInternally))
			{
			this.Raw:=" ", this.SetCapacity("Raw",this.Length)
			If (this.Address>0) AND (VarOrAddress<>"") ; Copy an existing buffer into the internal one
				this._BCopy(this.Address,this.GetAddress("Raw"),this.Length)
			Else ; Initialize an empty internal write buffer
				DllCall("RtlFillMemory","Ptr",this.GetAddress("Raw"),"UInt",this.Length,"UChar",0)
			this.Address:=this.GetAddress("Raw")
			}
	}
	ReadUInt(){
		If (this.Position+4>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "UInt"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=4
		Return Num
	}
	ReadDWORD(){
		If (this.Position+4>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "UInt"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=4
		Return Num
	}
	ReadInt(){
		If (this.Position+4>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "Int"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=4
		Return Num
	}
	ReadLong(){
		If (this.Position+4>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "Int"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=4
		Return Num
	}
	ReadInt64(){
		If (this.Position+8>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "Int64"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=8
		Return Num
	}
	ReadShort(){
		If (this.Position+2>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "Short"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=2
		Return Num
	}
	ReadUShort(){
		If (this.Position+2>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "UShort"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=2
		Return Num
	}
	ReadWORD(){
		If (this.Position+2>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "UShort"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=2
		Return Num
	}
	ReadChar(){
		If (this.Position+1>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "Char"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position++
		Return Num
	}
	ReadUChar(){
		If (this.Position+1>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "UChar"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position++
		Return Num
	}
	ReadBYTE(){
		If (this.Position+1>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "UChar"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position++
		Return Num
	}
	ReadDouble(){
		If (this.Position+8>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "Double"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=8
		Return Num
	}
	ReadFloat(){
		If (this.Position+4>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "Float"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=4
		Return Num
	}
	ReadPtr(){
		If (this.Position+A_PtrSize>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "Ptr"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=A_PtrSize
		Return Num
	}
	ReadUPtr(){
		If (this.Position+A_PtrSize>this.Length) OR ((Num:=NumGet(this.Address+0, this.Position, "UPtr"))="")
			throw Exception("Invalid memory read.",,"Val='" Num "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		this.Position+=A_PtrSize
		Return Num
	}
	WriteUInt(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+4)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "UInt"), this.Position+=4
		Return 4
	}
	WriteDWORD(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+4)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "UInt"), this.Position+=4
		Return 4
	}
	WriteInt(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+4)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "Int"), this.Position+=4
		Return 4
	}
	WriteLong(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+4)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "Int"), this.Position+=4
		Return 4
	}
	WriteInt64(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+8)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "Int64"), this.Position+=8
		Return 8
	}
	WriteShort(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+2)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "Short"), this.Position+=2
		Return 2
	}
	WriteUShort(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+2)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "UShort"), this.Position+=2
		Return 2
	}
	WriteWORD(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+2)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "UShort"), this.Position+=2
		Return 2
	}
	WriteChar(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+1)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "Char"), this.Position++
		Return 1
	}
	WriteUChar(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+1)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz) ;(this.Position>=this.Length?1:0)
		NumPut(Number, this.Address+0, this.Position, "UChar"), this.Position++
		Return 1
	}
	WriteBYTE(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+1)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "UChar"), this.Position++
		Return 1
	}
	WriteDouble(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+8)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "Double"), this.Position+=8
		Return 8
	}
	WriteFloat(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+4)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "Float"), this.Position+=4
		Return 4
	}
	WritePtr(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+A_PtrSize)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "Ptr"), this.Position+=A_PtrSize
		Return A_PtrSize
	}
	WriteUPtr(Number){
		If (Number="") OR ((Expand:=((NewSz:=this.Position+A_PtrSize)>this.Length)) AND !this.Internal)
			throw Exception("Invalid memory write.",,"Number='" Number "' at offset " this.Position " of " this.Length-1 "`n`n" Traceback())
		If Expand
			this.ResizeInternalBuffer(NewSz)
		NumPut(Number, this.Address+0, this.Position, "UPtr"), this.Position+=A_PtrSize
		Return A_PtrSize
	}
	Tell(){
		Return this.Position
	}
	Position(){ ; Does not work as a method since it is overwritten by the property with the same name.
		Return this.Position
	}
	Pos(){
		Return this.Position
	}
	Length(){ ; Does not work as a method since it is overwritten by the property with the same name.
		Return this.Length
	}
	Read(Length:="", Encoding:=""){
		Encoding:=(Encoding=""?this.Encoding:Encoding) ; Set default encoding if not specified
		CharLen:=((Encoding="utf-16"||Encoding="cp1200")?2:1) ; calculate length of each character in bytes
		If (Length="")
			Length:=this.Length/CharLen ; convert length of Length from bytes to chars
		Length:=(this.Position+Length*CharLen>this.Length?(this.Length-this.Position)/CharLen:Length)
		Length:=(Length<0?0:Length)
		Str:=StrGet(this.Address+this.Position, Length, Encoding)
		this.Seek(Length*CharLen,1)
		Return Str
	}
	Write(String, Length:="", Encoding:=""){
		Encoding:=(Encoding=""?this.Encoding:Encoding) ; Set default encoding if not specified
		CharLen:=((Encoding="utf-16"||Encoding="cp1200")?2:1) ; Calculate length of each character in bytes
		Length:=(Length=""?StrLen(String):(Length<0?0:Length)) ; Length of string, in chars
		If ((NewSz:=(this.Position+Length*CharLen))>this.Length) ; String is too long to fit in buffer
			{
			If this.Internal ; We can expand buffer
				this.ResizeInternalBuffer(NewSz) ; Expand the buffer
			Else ; We can't expand, so truncate String to number of chars that can fit into the buffer
				Length:=(this.Length-this.Position)/CharLen ; Length (in characters) that will fit into the buffer
			}
		NumWritten:=StrPut(SubStr(String,1,Length),this.Address+this.Position,Length,Encoding)
		this.Seek(Bytes:=NumWritten*CharLen,1)
		Return Bytes
	}
	RawRead(ByRef VarOrAddress,Bytes){
		Bytes:=(this.Position+Bytes>this.Length?this.Length-this.Position:Bytes)
		If VarOrAddress is not integer ; Is a Variable not an Address
			{
			If (VarSetCapacity(VarOrAddress)<Bytes)
				VarSetCapacity(VarOrAddress,Bytes)
			this._BCopy(this.Address+this.Position,&VarOrAddress,Bytes)
			}
		Else ; Is an Address not a Variable
			this._BCopy(this.Address+this.Position,VarOrAddress,Bytes)
		this.Seek(Bytes,1)
		Return Bytes
	}
	RawWrite(ByRef VarOrAddress,Bytes){
		If (this.Position+Bytes>this.Length) ; Too many bytes to fit in buffer
			{
			If this.Internal ; We can expand the buffer
				this.ResizeInternalBuffer(this.Position+Bytes) ; Expand the buffer
			Else ; We can't expand, so truncate number of bytes to what can fit in the buffer
				Bytes:=this.Length-this.Position ; Number of bytes that can fit in the buffer
			}
		If VarOrAddress is not integer ; Is a Variable not an Address
			{
			Bytes:=((Szz:=VarSetCapacity(VarOrAddress))<Bytes?Szz:Bytes) ; Ensures Bytes is not greater than the size of VarOrAddress
			this._BCopy(&VarOrAddress,this.Address+this.Position,Bytes)
			}
		Else ; Is an Address not a Variable
			this._BCopy(VarOrAddress,this.Address+this.Position,Bytes)
		this.Seek(Bytes,1)
		Return Bytes
	}
	Seek(Distance, Origin:=""){
		If (Origin="")
			Origin:=(Distance<1?2:0)
		If (Origin=0)
			this.Position:=Distance
		Else If (Origin=1)
			this.Position+=Distance
		Else If (Origin=2)
			this.Position:=this.Length+Distance
		If (this.Position<1)
			{
			this.Position:=0
			this.AtEoF:=0
			Return -1 ; Returns -1 if Position was moved before beginning of file
			}
		Else If (this.Position>=this.Length)
			{
			this.Position:=this.Length
			this.AtEoF:=1
			If (this.Position>this.Length)
				Return 2 ; Returns 2 if EoF was passed
			Else
				Return 1 ; Returns 1 if EoF was reached
			}
		Else
			{
			this.AtEoF:=0
			Return 1 ; Returns 1 if Position is still in bounds
			}
	}
	GetBufferAddress(){
		Return this.Address
	}
	GetBufferSize(){
		Return this.Length
	}
	CopyBufferToVar(ByRef Var){
		VarSetCapacity(Var,this.Length)
		this._BCopy(this.Address,&Var,this.Length)
		Return this.Length ; The new length of Var
	}
	CopyBufferToAddress(DestinationAddress){
		this._BCopy(this.Address,DestinationAddress,this.Length)
		Return this.Length ; The number of bytes written to DestinationAddress
	}
	ResizeInternalBuffer(RequestedCapacity){
		If this.Internal ; Buffer if stored internally
			{
			NewCapacity:=this.SetCapacity("Raw",RequestedCapacity), this.Address:=this.GetAddress("Raw")
			Return this.Length:=(NewCapacity<>""?NewCapacity:this.Length) ; Returns the new capacity
			}
		If (RequestedCapacity=this.Length) ; It's okay to not change the capacity
			Return this.Length
		throw Exception("The capacity of external buffers passed by address cannot be updated.",,"RequestedCapacity='" Num "', CurrentCapacity='" this.Length "'" "`n`n" Traceback())
	}
	ResizeExternalVarContainingBuffer(ByRef Var,CurrentCapacity,RequestedCapacity){
		VarSetCapacity(tmp,CurrentCapacity)
		this._BCopy(&Var,&tmp,CurrentCapacity)
		VarSetCapacity(Var,RequestedCapacity,0)
		this._BCopy(&tmp,&Var,CurrentCapacity)
		this.Address:=&Var, this.Length:=RequestedCapacity
		this.Seek(0,1)
		Return this.Address ; Returns the new address referenced by Var
	}
	_BCopy(Source,Destination,Length){
		DllCall("RtlMoveMemory","Ptr",Destination,"Ptr",Source,"UInt",Length) ;https://msdn.microsoft.com/en-us/library/windows/hardware/ff562030(v=vs.85).aspx
	}
}

#Include <PS_ExceptionHandler>				;can be found in AHK-libs-and-classes-collection\lib-i_to_z
