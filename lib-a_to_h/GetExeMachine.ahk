;
; File encoding:  UTF-8
;

GetExeMachine(exepath){
	if exe := FileOpen(exepath, "r")
	{
		exe.Seek(60), exe.Seek(exe.ReadUInt()+4)
		return exe.ReadUShort()
	}
}
