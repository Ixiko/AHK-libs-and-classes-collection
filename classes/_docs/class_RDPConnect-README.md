# RDPTools
An AHK library for automating RDP client connections

##RDPConnect
A class library that automates the various windows associated with the windows RDP client (mstsc.exe)  
Pass it an address, username / domain string and password string and it attempts to open the connection and log in for you.  
Will fire a callback on success or failure.  
Additionally, can be instructed to not fire the callback until the desktop is ready for interaction (Waits for pixel of pre-determined color to exist at coordinate 0,0).  

Usage: ```this.rdp := new RDPConnect(address, login, password, MyBoundFunc, {[options]})```  
eg: ```this.rdp := new RDPConnect(address, login, password, this.MyMethod.Bind(this), {WaitForDesktopColor: "0xFFFFFF"})```

Callback Parameters:  
```
MyMethod(e, pid, hwnd)
e : The event that happened.
	0 is "success", other values are errors (eg bad address, bad credentials)
	use GetErrorName to get a human-friendly reason for the failure
pid : The Process ID of the RDP session. All RDP windows for one connection will share the same PID
hwnd: The Window Handle of the session window.
	On connect, hwnd will be the HWND of the session window
	On disconnect (User logged off), hwnd will be unset (e will still be 0, as this is a "success")
```

RDPConnect uses ```ControlSend``` for all sending of keyboard input directly to the HWND of the RDP window(s), so it should be (reasonably) immune to the user performing other functions whilst RDPConnect is connecting.

WARNING: Whilst RDPConnect does not store any passwords, in order to use it, you will probably need to store passwords on your disk.  
RDPConnect is NOT RECOMMENDED for use-cases where you wish to keep your password(s) private. It's primary use-case is intended for test environments and the like, where password secrecy is not an issue.
