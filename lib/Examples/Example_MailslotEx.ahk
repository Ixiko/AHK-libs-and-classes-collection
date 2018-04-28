#Include MailslotEx.ahk

server := new MailslotEx("test_slot", "r") ; create a server Mailslot
client := new MailslotEx("test_slot", "w") ; create a client Mailslot

data := "The quick brown fox jumps over the lazy dog"

; call the .FStream() method to get a writer object for more control on write
; operation
writer := client.FStream()
writer.WriteUShort(10) ; write UShort
writer.WriteUInt(12)   ; write a UInt
writer.Write(data)     ; write string
writer := "" ; release the object to flush the data

if server.MsgCount ; check first if there are messages available
{
	MsgBox % server._GetInfo("Size") ; size of the first message in bytes
	
	; now we retrieve a reader object for reading
	reader := server.FStream()
	MsgBox % reader.ReadUShort()
	MsgBox % reader.ReadUInt()
	MsgBox % reader.Read()
	reader := ""
}

client := ""
server := "" ; closes the handle to the Mailslot

ExitApp