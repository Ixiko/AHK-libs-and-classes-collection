#Include %A_LineFile%\..\Mailslot.ahk

class MailslotEx extends Mailslot
{
	class Server extends Mailslot.Server
	{
		FStream(encoding:="CP0")
		{
			return new MailslotEx.Reader(this, encoding)
		}
	}

	class Client extends Mailslot.Client
	{
		FStream(encoding:="CP0")
		{
			return new MailslotEx.Writer(this, encoding)
		}
	}

	class Reader
	{
		__New(slot, encoding:="CP0")
		{
			ObjSetCapacity(this, "_", bytes := slot._GetInfo("Size"))
			addr := ObjGetAddress(this, "_")
			if !(read := slot.FRead(addr + 0, bytes))
				return

			this.__Slot   := &slot
			this.__Ptr    := addr + 0
			this.Pos      := addr + 0
			this.Size     := read + 0
			this.Encoding := RTrim(encoding, "-RAWraw") ;// StrGet doesn't seem to recognize the 'RAW' suffix
		}

		__Get(key:="", args*)
		{
			if !key
				return ObjGetAddress(this, "_")
		}

		__Call(method, args*)
		{
			if (method ~= "i)^Read(U?(Int|Short|Char|Ptr)|Int64|Double|Float)$")
				return this.ReadNum(SubStr(method, 5))
		}

		Read(chars:=-1)
		{
			enc := this.Encoding
			BytesPerChar := (enc = "UTF-16" || enc = "CP1200") ? 2 : 1
			
			bytes_left := (this.__Ptr + this.Size) - this.Pos
			chars_left := bytes_left // BytesPerChar
			if (chars < 0 || chars > chars_left) ;// read rest of buffer from current pos
				chars := chars_left
			
			str := StrGet(this.Pos, chars, enc)
			this.Seek((StrPut(str, enc) - 1) * BytesPerChar, 1)
			return str
		}

		ReadLine()
		{
			enc := this.Encoding
			BytesPerChar := (enc = "UTF-16" || enc = "CP1200") ? 2 : 1
			
			length := ((this.__Ptr + this.Size) - this.Pos) // BytesPerChar
			str := StrGet(this.Pos, length, enc)
			ln := SubStr(str, 1, (p := InStr(str, "`n")) ? p : StrLen(str))
			this.Seek((StrPut(str, enc) - 1) * BytesPerChar, 1)
			return ln
		}

		RawRead(ByRef buf, bytes)
		{
			VarSetCapacity(buf, bytes)
			DllCall("RtlMoveMemory", "Ptr", &buf, "Ptr", this.Pos, "UPtr", bytes)
		}

		Seek(distance, origin:=0)
		{
			if (distance < 0 && origin != 2)
				origin := 2
			start := origin == 0 ? this.__Ptr
			      :  origin == 1 ? this.Pos
			      :  origin == 2 ? this.__Ptr + this.Size
			      :  0
			return start ? this.Pos := start + distance : 0
		}

		ReadNum(NumType:="UPtr")
		{
			static sizeof := { "Char": 1, "Short": 2, "Int": 4, "Int64": 8
			                 , "Float":  4, "Double": 8, "Ptr": A_PtrSize }
			ptr := this.Pos, this.Seek(sizeof[ LTrim(NumType, "Uu") ], 1)
			return NumGet(ptr + 0, NumType)
		}
	}

	class Writer
	{
		__New(slot, encoding:="CP0")
		{
			if !(fSlot := FileOpen(slot.Filename, "w"))
				return

			this.__Slot   := &slot
			this.__Stream := fSlot
			this.Encoding := encoding ;// set encoding after opening the file to avoid BOM
		}

		__Delete()
		{
			this.__Stream.Close()
		}

		__Call(method, args*)
		{
			if (method ~= "i)^Write(Line|U?(Int|Short|Char)|Int64|Double|Float)?$")
			{
				fSlot := this.__Stream
				return fSlot[method](args*)
			}
		}

		RawWrite(ByRef buf, bytes)
		{
			fSlot := this.__Stream
			return fSlot.RawWrite(buf, bytes)
		}

		__Handle {
			get {
				return this.__Stream.__Handle
			}
		}

		Encoding {
			get {
				return this.__Stream.Encoding
			}
			set {
				return this.__Stream.Encoding := value
			}
		}
	}
}