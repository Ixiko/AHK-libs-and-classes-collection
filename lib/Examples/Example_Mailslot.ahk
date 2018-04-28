#Include Mailslot.ahk

server := new Mailslot("test_slot", "r")
client := new Mailslot("test_slot", "w")

; Simple usage
for i, msg in ["Auto", "Hot", "key"]
	client.Enqueue(msg)

; now we read the messages
MsgBox % server.MsgCount ; total number of messages waiting to be read
while server.MsgCount
	MsgBox % server.Dequeue()

; Writing and reading raw binary data

; Prepare the data
enc := "CP0"
BytesPerChar := (enc = "UTF-16" || enc = "CP1200") ? 2 : 1
str := "The quick brown fox jumps over the lazy dog"
sizeof_String := StrPut(str, "CP0") * BytesPerChar
bytes := VarSetCapacity(data, 6 + sizeof_String)
StrPut(str, NumPut(12, NumPut(10, data, 0, "UShort"), "UInt"), enc)

; write the data
client.FWrite(data, bytes)

; read the data
if server.MsgCount
{
	server.FRead(msg)
	MsgBox % NumGet(msg, 0, "UShort")
	MsgBox % NumGet(msg, 2, "UInt")
	MsgBox % StrGet(&msg + 6, enc)
}

client := ""
server := "" ; closes the Mailslot handle
ExitApp