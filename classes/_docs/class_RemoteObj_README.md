RemoteObj.ahk
=============

Access objects remotely over a network


Dependencies
------------

* [AutoHotkey-JSON\Jxon.ahk](https://github.com/cocobelgica/AutoHotkey-JSON)
* [Socket.ahk](https://github.com/G33kDude/Socket.ahk)


Publishing an Object to the Network
-----------------------------------

```AutoHotkey
ObjToPublish := new Test() ; This is the object that will be published
Bind_Addr := "127.0.0.1" ; Only accept connections from localhost
Bind_Port := 1337 ; Listen for connections on port 1337

Server := new RemoteObj(ObjToPublish, [Bind_Addr, Bind_Port])

class Test {
	InputBox(Prompt) {
		InputBox, Out, % this.Title, %Prompt%
		return Out
	}
}
```


Connecting to a Published Object
--------------------------------

```AutoHotkey
Remote_Addr := "127.0.0.1" ; Connect to local host
Remote_Port := 1337 ; Connect to port 1337

Remote := new RemoteObjClient([Remote_Addr, Remote_Port])

Remote.Title := "Hello World!"
MsgBox, % Remote.InputBox("Type something!")
```
