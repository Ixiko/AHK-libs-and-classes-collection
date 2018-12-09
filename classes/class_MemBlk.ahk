/* Class: MemBlk
 *     - Minimal struct wrapper. Wraps VarSetCapacity-NumPut/NumGet routines.
 * License:
 *     WTFPL[http://wtfpl.net/]
 * CONSTRUCTION:
 *     buf := new MemBlk( size [, fill := 0 ] )
 * Parameter(s):
 *     size  [in]      - size of the memory block in bytes
 *     fill  [in, opt] - same as VarSetCapacity's 'FillByte' parameter
 * PROPERTIES:
 *     __Ptr     [read-only] - returns the address of the buffer
 *     Size      [read-only] - returns the size of the buffer in bytes
 * METHODS:
 *     PutNumType( num [, at ] ) - Similar to NumPut(). Where 'NumType' can be
 *                                 one of the following specified directly as
 *                                 part of the method name: UInt, Int, Int64,
 *                                 Short, UShort, Char, UChar, Double, or Float.
 *                                 Parameters 'num' and 'at' is similar to that
 *                                 of NumPut's 'num' and 'offset' respectively.
 *                                 An address may be specified for 'at'. If 'at'
 *                                 is omitted, the object's internal pointer/pos
 *                                 is used. Each call to this method advances the
 *                                 internal pointer/pos to allow omission of 'at'
 *                                 for subsequent calls, simulates nested NumPuts.
 *                                 Return value is the same with NumPut.
 *     GetNumType( at := 0 )     - Similar to NumGet(). Unlike PutNumType's 'at'
 *                                 parameter, 'at' here must be an offset only,
 *                                 defaults to 0.
 */
class MemBlk
{
	__New(size, fill:=0)
	{
		ObjSetCapacity(this, "_Buf", size)
		this.__Pos := (ptr := this.__Ptr) + 0
		
		;// Initialize
		if (fill >= 0 && fill <= 255)
			DllCall("RtlFillMemory", "Ptr", ptr, "UPtr", size, "UChar", fill)
	}

	__Get(key:="", args*)
	{
		if !key
			return ObjGetAddress(this, "_Buf")
	}

	__Call(method, args*)
	{
		if (method = "Put" || method = "Get")
			method .= "UPtr"

		if (method ~= "i)^Put(U?(Int|Short|Char|Ptr)|Int64|Double|Float)$")
		{
			num := args[1], at := Round(Abs(args[2]) != "" ? args[2] : this.__Pos)
			return this._PutAt(num, at, SubStr(method, 4))
		}

		else if (method ~= "i)^Get(U?(Int|Short|Char|Ptr)|Int64|Double|Float)$")
		{
			at := Round(args[1])
			return this._GetAt(at, SubStr(method, 4))
		}
	}

	Size {
		get {
			return ObjGetCapacity(this, "_Buf")
		}
		set {
			return value
		}
	}

	__Ptr {
		get {
			return ObjGetAddress(this, "_Buf")
		}
		set {
			return value
		}
	}

	_PutAt(num, at:=0, type:="UPtr")
	{
		ptr := this.__Ptr
		addr := (at >= ptr && at < ptr + this.Size) ? at : ptr + at
		return this.__Pos := NumPut(num, addr + 0, type)
	}

	_GetAt(at:=0, type:="UPtr")
	{
		ptr := this.__Ptr
		addr := (at >= ptr && at < ptr + this.Size) ? at : ptr + at
		return NumGet(addr + 0, type)
	}
}