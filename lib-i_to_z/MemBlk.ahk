/* Library: MemBlk/MemBlkView
 *     Wrapper for the VarSetCapacity -> NumPut/NumGet/StrPut/StrGet routines
 * Version:
 *     1.1.00.00 [updated 03/22/2015]
 * License:
 *     WTFPL [http://www.wtfpl.net/]
 * Requirements:
 *     Latest version of AutoHotkey v1.1+ OR v2.0-a
 * Installation:
 *     Use #Include MemBlk.ahk or copy into a function library folder and then
 *     use #Include <MemBlk>
 * Links:
 *     GitHub      - http://goo.gl/qNh3Ta
 *     Forum topic - http://goo.gl/Pt4Z3U
 */


/* Class: MemBlk
 *     A MemBlk object is used to represent a raw binary data buffer. This class
 *     extends from MemBlkView allowing you to directly manipulate its contents.
 */
class MemBlk extends MemBlkView
{
	/* Constructor: __New
	 *     Instantiates an object that represents a memory-block array
	 * Syntax:
	 *     oBuf := new MemBlk( size [ , FillByte := 0 ] )
	 * Parameter(s):
	 *     oBuf       [retval] - a MemBlk object
	 *     size           [in] - size of the buffer in bytes
	 *     FillByte  [in, opt] - similar to VarSetCapacity's 'FillByte' parameter
	 */
	__New(size, FillByte:=0)
	{
		ObjSetCapacity(this, "_Buffer", size)
		base.__New(ObjGetAddress(this, "_Buffer"),, size)
		
		if (FillByte >= 0 && FillByte <= 255) ; UChar range
			DllCall("RtlFillMemory", "Ptr", this[], "UPtr", size, "UChar", FillByte)
	}
}
/* Class: MemBlkView
 *     Provides an interface for reading data from and writing it to a buffer or
 *     memory address. API is similar to that of AutoHotkey's File object.
 */
class MemBlkView
{
	/* Constructor: __New
	 *     Instantiates an object that respresents a view into a buffer.
	 * Syntax:
	 *     oView := new MemBlkView( ByRef VarOrAddress [ , offset := 0, length ] )
	 * Parameter(s):
	 *     oView             [retval] - a MemBlkView object
	 *     VarOrAddress   [in, ByRef] - variable(initialized by VarSetCapacity)
	 *                                  or a memory address
	 *     offset           [in, opt] - an offset, in bytes, which is added to
	 *                                  'VarOrAddress' for the new view object
	 *                                  to reference. Defaults to 0 if omitted.
	 *     length           [in, opt] - length of the view, in bytes. This parameter
	 *                                  is required when 'VarOrAddress' is a memory
	 *                                  address, else, an exception is thrown.
	 * Remarks:
	 *     An exception is thrown if the 'offset' and 'length' result in the
	 *     specified view extending past the end of the buffer.
	 */
	__New(ByRef VarOrAddr, offset:=0, length:="")
	{
		this.__Ptr := (IsByRef(VarOrAddr) ? &VarOrAddr : VarOrAddr) + offset
		
		if (length == "")
		{
			if !IsByRef(VarOrAddr)
				throw Exception("Parameter 'length' must be specified when passing an address", -1, VarOrAddr)
			length := VarSetCapacity(VarOrAddr)
		}
		if IsByRef(VarOrAddr) && ((offset + length) > VarSetCapacity(VarOrAddr))
			throw Exception("Trying to create view that extends past the buffer", -1, offset + length)

		this.Size := (this[] + length) - this[]
		this.Pos := 0
	}
	/* Property: Size
	 *     Size of the view in bytes. This property is read-only
	 * Syntax:
	 *     size := oView.Size
	 */

	/* Property: Pos
	 *     The current position of the view pointer, where 0 is the beginning of
	 *     the view
	 * Syntax:
	 *     pos := oView.Pos
	 */
	__Get(key:="", args*)
	{
		if !key || (key > 0 && key <= this.Size)
			return this.__Ptr + Round(key)
	}
	
	__Call(name, args*)
	{
		if (name = "Put" || name = "Get")
			name .= "UPtr"
		else if (name = "Read" || name = "Write")
			name .= "CP0"

		if (name ~= "i)^((Put|Get)(U?(Char|Short|Int|Ptr)|Double|Float|Int64)|(Read|Write)(UTF(8|16)|CP\d+))$")
		{
			static ObjPush := Func(A_AhkVersion<"2" ? "ObjInsert" : "ObjPush")

			n := InStr("RW", SubStr(name, 1, 1)) ? InStr(name, "r") : 0
			%ObjPush%(args, SubStr(name, 4 + n)) ; num type OR encoding
			return this[n ? "_Str" : "_Num"](SubStr(name, 1, 3 + n), args*)
		}
	}
	/* Method: Put[NumType]
	 *     Store a number in binary format and advances the view pointer
	 * Syntax:
	 *     oView.PutNumType( num [ , offset ] )
	 * Parameter(s):
	 *     NumType          - One of the following specified directly as part of
	 *                        the method name: UInt, Int, Int64, Short, UShort,
	 *                        Char, UChar, Double, Float, UPtr or Ptr. Defaults
	 *                        to 'UPtr' if omitted.
	 *     num         [in] - a number
	 *     offset [in, opt] - the offset, in bytes, from the view's start point.
	 *                        If omitted, 'num' is written at the current position
	 *                        of the view pointer.
	 */

	/* Method: Get[NumType]
	 *     Reads a number from the view and advances the view pointer
	 * Syntax:
	 *     num := oView.GetNumType()
	 * Parameter(s):
	 *     num     [retval] - a number
	 *     NumType          - same as that of .PutNumType()
	 *     offset [in, opt] - the offset, in bytes, from the view's start point.
	 *                        If omitted, 'num' is read from the current position
	 *                        of the view pointer.
	 */
	_Num(action, args*)
	{
		static sizeof := { "Char":1, "Short":2, "Int":4, "Float":4, "Double":8, "Int64":8, "Ptr":A_PtrSize }
		static ObjRemoveAt := Func(A_AhkVersion<"2" ? "ObjRemove" : "ObjRemoveAt")
		
		; Process args
		if (action = "Put")
		{
			num := %ObjRemoveAt%(args, 1)
			if sizeof[ LTrim(num, "Uu") ]
				throw Exception("Too few parameters passed to method", -1, "Put" . num . "()")
		}
		ptr := this[]
		at   := ObjHasKey(args, 1) && ((args[1]+0) != "") ? %ObjRemoveAt%(args, 1) : ptr + this.Pos
		type := ObjHasKey(args, 1) && sizeof[LTrim(args[1], "Uu")] ? args[1] : "UPtr"
		
		if (at != (ptr + this.Pos)) && (at >= 0 && at < this.Size) ; offset
			at += ptr

		if (action = "Put")
			return (n := NumPut(num, at + 0, type), this.Pos := n-ptr, n) ; rightmost for v2.0-a

		this.Seek(sizeof[ LTrim(type, "Uu") ], 1)
		return NumGet(at + 0, type)
	}
	/* Method: Write[Encoding]
	 *     Copies a string into the view and advances the view pointer
	 * Syntax:
	 *     chars := oView.WriteEncoding( str [ , length ] )
	 * Parameter(s):
	 *     Encoding           - source/target encoding in the following format:
	 *                          'CPnnn' or 'UTFn' specified directly as part of
	 *                          the method name. Defaults to 'CP0' if omitted.
	 *     chars     [retval] - the number of characters written
	 *     str           [in] - a string
	 *     length   [in, opt] - Similar to StrPut()'s 'Length' parameter.
	 */

	/* Method: Read[Encoding]
	 *     Copies a string from the view and advances the view pointer
	 * Syntax:
	 *     str := oView.ReadEncoding( [ length ] )
	 * Parameter(s):
	 *     Encoding           - same as that of .Write[Encoding]()
	 *     str       [retval] - the requested string after performing any necessary
	 *                          conversion
	 *     length   [in, opt] - Similar to StrGet()'s 'Length' parameter.
	 */
	_Str(action, args*)
	{
		enc := "CP0" ; default encoding
		for i, arg in args
		{
			if (arg ~= "i)^UTF-?(8|16)|CP\d+$")
			{
				if InStr(enc := arg, "UTF")
					args[i] := enc := "UTF-" . Abs(SubStr(enc, 4)) ; normalizes if it contains a dash
				break
			}
		}
		static ObjRemoveAt := Func(A_AhkVersion<"2" ? "ObjRemove" : "ObjRemoveAt")
		addr := this[] + this.Pos
		str := action="Read" ? StrGet(addr, args*) : %ObjRemoveAt%(args, 1)

		BytesPerChar := (enc = "UTF-16" || enc = "CP1600") ? 2 : 1
		this.Seek(StrPut(str, enc) * BytesPerChar, 1)

		return action="Read" ? str : StrPut(str, addr, args*)
	}
	/* Method: RawRead
	 *     Copies raw binary data from the the view into the specified buffer
	 *     or memory address. Data is read from the current position of the view
	 *     pointer.
	 * Syntax:
	 *     BytesRead := oView.RawRead( ByRef VarOrAddress, bytes )
	 * Parameter(s):
	 *     BytesRead         [retval] - number of bytes that were read
	 *     VarOrAddress   [in, ByRef] - variable or memory address to which the
	 *                                  data will be copied
	 *     bytes                 [in] - maximum number of bytes to read
	 */
	RawRead(ByRef dest, bytes)
	{
		if ((this.Pos + bytes) > this.Size) ; exceeds view's capacity
			bytes := this.Size - this.Pos
		if IsByRef(dest) && (!VarSetCapacity(dest) || (VarSetCapacity(dest) < bytes))
		{
			if (bytes < (A_IsUnicode ? 6 : 3)) ; minimum allowed is 3 TCHARS
				VarSetCapacity(dest, 128), VarSetCapacity(dest, 0) ; force ALLOC_MALLOC method
			VarSetCapacity(dest, bytes, 0) ; initialize or adjust if capacity is 0 or < bytes
		}
		DllCall("RtlMoveMemory", "Ptr", IsByRef(dest) ? &dest : dest, "Ptr", this[] + this.Pos, "UPtr", bytes)
		return bytes
	}
	/* Method: RawWrite
	 *     Write raw binary data into the view. Data is written at the current
	 *     position of the view pointer.
	 * Syntax:
	 *     BytesWritten := oView.RawWrite( ByRef VarOrAddress, bytes )
	 * Parameter(s):
	 *     BytesWritten      [retval] - number of bytes that were written
	 *     VarOrAddress   [in, ByRef] - variable containing the data or the
	 *                                  address of the data in memory
	 *     bytes                 [in] - maximum number of bytes to write
	 */
	RawWrite(ByRef src, bytes)
	{
		if ((this.Pos + bytes) > this.Size)
			bytes := this.Size - this.Pos
		DllCall("RtlMoveMemory", "Ptr", this[] + this.Pos, "Ptr", IsByRef(src) ? &src : src, "UPtr", bytes)
		return bytes
	}
	/* Method: Seek
	 *     Moves the view pointer
	 * Syntax:
	 *     oView.Seek( distance [ , origin := 0 ] )
	 * Parameter(s):
	 *     distance      [in] - distance to move, in bytes.
	 *     origin   [in, opt] - starting point for the view pointer move. Must
	 *                          be one of the following:
	 *                              0 - beginning of the view
	 *                              1 - current position of the pointer
	 *                              2 - end of the view, 'distance' should usually
	 *                                  be negative
	 *                          If ommitted, 'origin' defaults to 2 if 'distance'
	 *                          is negative and 0 otherwise.
	 */
	Seek(distance, origin:=0)
	{
		if (distance < 0 && origin != 2)
			origin := 2
		start := origin == 0 ? this[]              ; start
		      :  origin == 1 ? this[] + this.Pos   ; current
		      :  origin == 2 ? this[] + this.Size  ; end
		      :  0
		return start ? this.Pos := start + distance - this[] : 0
	}
}