class RemoteObj
{
	__New(Obj, Address)
	{
		this.Obj := Obj
		this.Server := new SocketTCP()
		this.Server.OnAccept := this.OnAccept.Bind(this)
		this.Server.Bind(Address)
		this.Server.Listen()
	}
	
	OnAccept(Server)
	{
		Sock := Server.Accept()
		Text := Sock.RecvLine()
		Query := Jxon_Load(Text)
		
		if (Query.Action == "__Get")
			RetVal := this.Obj[Query.Key]
		else if (Query.Action == "__Set")
			RetVal := this.Obj[Query.Key] := Query.Value
		else if (Query.Action == "__Call")
			RetVal := this.Obj[Query.Name].Call(this.Obj, Query.Params*)
		
		Sock.SendText(Jxon_Dump({"RetVal": RetVal}) "`r`n")
		Sock.Disconnect()
	}
}

class RemoteObjClient
{
	__New(Addr)
	{
		ObjRawSet(this, "__Addr", Addr)
	}
	
	__Get(Key)
	{
		return RemoteObjSend(this.__Addr, {"Action": "__Get", "Key": Key})
	}
	
	__Set(Key, Value)
	{
		return RemoteObjSend(this.__Addr, {"Action": "__Set", "Key": Key, "Value": Value})
	}
	
	__Call(Name, Params*)
	{
		return RemoteObjSend(this.__Addr, {"Action": "__Call", "Name": Name, "Params": Params})
	}
}

RemoteObjSend(Addr, Obj)
{
	Sock := new SocketTCP()
	Sock.Connect(Addr)
	Sock.SendText(Jxon_Dump(Obj) "`r`n")
	RetVal := Jxon_Load(Sock.RecvLine()).RetVal
	Sock.Disconnect()
	return RetVal
}