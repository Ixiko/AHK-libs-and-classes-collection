#NoEnv
SetBatchLines, -1

#Include %A_ScriptDir%\..\..\class_Socket.ahk

/*
	The purpose of this script is to test the garbage collection.
	If a socket is not disconnected, it will stay in memory. If a
	socket is disconnected from either client or server side, it
	will be immediately garbage collected. This is visible by using
	a monitoring program such as Process Explorer from SysInternals.
*/

global DC_SERV := True
global DC_CLI := False

Server := new SocketTCP()
Server.OnAccept := Func("OnAccept")
Server.Bind(["0.0.0.0", 8000])
Server.Listen()

Loop
{
	x := new SocketTCP()
	x.Connect(["127.0.0.1", 8000])
	x.SendText(A_Index)
	Sleep, 10
	if (DC_CLI)
		x.Disconnect()
}
return

OnAccept(Server)
{
	Sock := Server.Accept()
	ToolTip, % Sock.RecvText()
	if (DC_SERV)
		Sock.Disconnect()
}
