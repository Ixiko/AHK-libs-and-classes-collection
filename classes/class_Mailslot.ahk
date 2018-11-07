/*
# Mailslot / MailslotEx

Wrapper for Windows [Mailslot](http://msdn.microsoft.com/en-us/library/windows/desktop/aa365576%28v=vs.85%29.aspx) API

Requires AutoHotkey v1.1.16.05+ OR v2.0-a056+

License: [WTFPL](http://wtfpl.net)

- - -

# Mailslot.ahk

#### Common Properties

`Name` - name of the mailslot, w/o the `\\.\mailslot\` prefix

`Filename` - see [Mailslot names](http://goo.gl/8Y0Cp9)

<br>

### Mailslot.Server

#### Constructor

``server := new Mailslot( name , option := "r" )``

_option_ must be the letter _r_ (for read). Specify an integer after _r_ (e.g.: `r128`) to set the maximum size of a single message that can be written to the mailslot, in bytes. If _r_ is uppercase, the mailslot handle can be inherited by child processes.

#### Properties

`MsgCount` - the total number of messages waiting to be read

`Timeout` - the amount of time, in milliseconds, a read operation can wait for a message to be written to the mailslot before a time-out occurs.

`__Handle` - handle to the mailslot

#### Methods

`Dequeue( [ wait := 0 , encoding := "CP0" ] )` - returns the first available message as text. For _wait_, see _Timeout_ property above.

`FRead( ByRef VarOrAdress [ , bytes := -1 , wait := 0 ] )` - read the first available message(as raw binary data) from the mailsot into memory. If _bytes_ is omitted the entire message is read. Otherwise, specify the maximum number of bytes to read. Returns the number of bytes that were read. Usage is similar to [RawRead](http://ahkscript.org/docs/objects/File.htm#RawRead_7).

`_GetInfo( info )` - retrieves information about the mailslot. _info_ can be any of the following words:

 * `write_limit OR limit` - the maximum message size, in bytes, allowed for this mailslot
 * `msg_size OR size` - the size of the next message, in bytes.
 * `msg_count OR count` - the total number of messages waiting to be read
 * `read_timeout OR timeout` - The amount of time, in milliseconds, a read operation can wait for a message to be written to the mailslot before a time-out occurs

<br>

### Mailslot.Client

#### Constructor

``client := new Mailslot( name , option := "w" )``

_option_ must be a string in the following form: `wMachine`. To write to a mailslot on the local computer, specify a period (.) for _Machine_, if _Machine_ is omitted (the default), a  period is assumed. Specify an asterisk (*) for _Machine_ to put a message into every mailslot with a given name in the system's primary domain.

#### Methods

`Enqueue( string [ , encoding := "CP0" ] )` - enqueues a message into the mailslot.

`FWrite( VarOrAddress , bytes )` - write raw binary data into the mailslot. Usage is similar to [RawWrite](http://ahkscript.org/docs/objects/File.htm#RawWrite_8)

<br>

- - -

# MailslotEx.ahk

Extends `Mailslot.ahk` to provide a FileObject-like API for read/write operation

#### Methods

`Slot.FStream( encoding := "CP0" )` - returns a _MailslotEx.Reader_ object if _Slot_ is a server mailslot. Otherwise, a _MailslotEx.Writer_ object if _Slot_ is a client mailslot.

**Remarks:**

 * Calling `FStream()` on a server mailslot will read the first available message into a buffer and subsequent read operations will operate on this buffer.
 * The caller must release the _.Writer_ object to flush the data into the mailslot

<br>

### MailslotEx.Reader

The `MailslotEx.Reader` class exposes the following methods. Usage is similar to their conterparts as documented [here](http://ahkscript.org/docs/objects/File.htm#File_Object_AHK_L_42+):

 * `Read( [ chars ] )`
 * `ReadLine()`
 * `ReadNum()`
 * `RawRead( VarOrAddress , bytes )`
 * `Seek( distance [ , origin := 0 ] )`

<br>

### MailslotEx.Writer

The `MailslotEx.Writer` class exposes the following methods and properties. Usage is similar to their conterparts as documented [here](http://ahkscript.org/docs/objects/File.htm#File_Object_AHK_L_42+):

 * `Write( string )`
 * `WriteLine( [ string ] )`
 * `WriteNum( num )`
 * `RawWrite( VarOrAddress , bytes )`
 * `__Handle`
 * `Encoding`
*/
class Mailslot {
	__New(name:="", options:="r0")
	{
		if (name == "")
			name := A_ScriptName

		options := Trim(options, " `t`r`n")
		if (options ~= "^[Rr]\d*?$")
			return new this.base.Server(name, LTrim(options, "Rr"), SubStr(options, 1, 1) == "R")
		else if (options ~= "i)^w(\.|\*|[^\r\n]+)?$")
			return new this.base.Client(name, SubStr(options, 2))
		else
			return
	}

	class Server
	{
		__New(name, limit:="0", inherit_handle:=0)
		{
			filename := "\\.\mailslot\" . name
			hSlot := DllCall("CreateMailslot", "Str", filename, "UInt", Round(limit), "UInt", 0, "Ptr", 0)
			if (hSlot == -1) ;// INVALID_HANDLE_VALUE
				return false ;// throw Exception() ??

			if inherit_handle
				DllCall("SetHandleInformation", "Ptr", hSlot, "UInt", 1, "UInt", 1)

			this.__Handle := hSlot
			this.Name     := name
			this.Filename := filename
		}

		__Delete()
		{
			DllCall("CloseHandle", "Ptr", this.__Handle)
		}

		Dequeue(wait:=0, encoding:="CP0")
		{
			if read := this.FRead(buf, this._GetInfo("Size"), wait)
			{
				enc := RTrim(encoding, "-RAWraw")
				length := read // ((enc = "UTF-16" || enc = "CP1200") ? 2 : 1)
				return StrGet(&buf, length, enc)
			}
		}

		FRead(ByRef buf, bytes:=-1, wait:=0)
		{
			hSlot := this.__Handle
			VarSetCapacity(tmp_buf, size := this._GetInfo("Size"))
			if (wait != this.Timeout)
				this.Timeout := wait
			if DllCall("ReadFile", "Ptr", hSlot, "Ptr", &tmp_buf, "UInt", size, "UIntP", read := 0, "Ptr", 0)
			{
				if (bytes < 0 || bytes > read)
					bytes := read
				if IsByRef(buf)
					VarSetCapacity(buf, bytes), pBuf := &buf
				else
					pBuf := buf + 0
				DllCall("RtlMoveMemory", "Ptr", pBuf, "Ptr", &tmp_buf, "UPtr", bytes)
				return read
			}
		}

		MsgCount {
			get {
				if ((count := this._GetInfo("count")) != "") ;// msg_count
					return count
			}
			set {
				return
			}
		}

		Timeout {
			get {
				return this._GetInfo("timeout") ;// read_timeout
			}
			set {
				hSlot := this.__Handle
				prev := this._GetInfo("timeout")
				return DllCall("SetMailslotInfo", "Ptr", hSlot, "UInt", Round(value)) ? prev : ""
			}
		}

		_GetInfo(which) ;// which := [ limit(write), size(msg size), count, timeout ]
		{
			; if !(which := SubStr(which, which ~= "i)^(write_)?\Klimit|(msg_)?\K(size|count)|(read_)?\Ktimeout$"))
			; 	return
			hSlot := this.__Handle
			if DllCall("GetMailslotInfo", "Ptr", hSlot, "UIntP", limit, "UIntP", size, "UIntP", count, "UIntP", timeout)
			{
				; though unreliable, InStr() should be faster than the commented
				; RegEx above. I reckon that most usage of this method will be
				; inside loops, esp. for 'msg_count' and 'msg_size'.
				if pos := InStr(which, "_")
					which := SubStr(which, pos + 1)
				return (%which%) ;// '()' for v1.1+
			}
		}
	}

	class Client
	{
		__New(name, machine:=".")
		{
			if (machine == "")
				machine := "."

			this.Name     := name
			this.Machine  := machine
			this.Filename := "\\" . machine . "\mailslot\" . name
		}

		Enqueue(data, encoding:="CP0")
		{
			if fSlot := FileOpen(this.Filename, "w")
			{
				fSlot.Encoding := encoding
				return fSlot.Write(data)
			}
		}

		FWrite(ByRef buf, bytes)
		{
			if fSlot := FileOpen(this.Filename, "w")
				return fSlot.RawWrite(buf, bytes)
		}
	}
}