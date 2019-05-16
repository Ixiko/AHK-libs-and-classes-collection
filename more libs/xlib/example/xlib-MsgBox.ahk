;#include <xlib>
ctId:=DllCall("Kernel32.dll\GetCurrentThreadId","Uint")
mbctr:=0
Loop
	ToolTip("The script is running: " A_TickCount "`nScript thread Id: " ctId "`nPress F1 to show a MsgBox`nEsc to exit script.") , Sleep(10)
F1::wMsgBox("Hello from MsgBox in new thread!", "xMsgBox #" (++mbctr) " @ " A_TickCount, 0x40+[0,1,2,4,6][random(1,5)], func("myCallback").bind(mbctr))

esc::exitapp

myCallback(mbNumber,n,ref){
	Msgbox("The user clicked on button: " ref.getResult() " on MsgBox #" mbNumber ".`nThread id: " DllCall("Kernel32.dll\GetCurrentThreadId","Uint"),"Script Callback.") 
}

wMsgBox(Text:="",Title:="",Options:="",callback:=""){
	; Wrapper function for xMsgBox. Opens a message box in a new thread. Automatic clean up after optional callback.
	local xMB
	xMB := new xMsgBox(Options, Title, Text, true, callback)
	xMB.Destroy()	; Ensures self references are released when the callback returns.
	return
}
class xMsgBox extends xlib.threadHandler {
	
	__new(Options:="", Title:="", Text:="",showOnCreate:=true,callback:=""){
		base.__new(1)
		this.options:=Options
		this.title:=Title
		this.text:=Text
		this.params:=this.makeParams()
		this.callback:=callback
		if showOnCreate
			this.show()
			
	}
	getResult(){
		return this.params.get("ret")
	}
	show(){
		local restart
		if this.init && this.isThreadRunning(1)
			return
		if this.init
			return this.restartTask(1)
		if !this.callback
			this.createTask(this.pmb,this.params.pointer, true)
		else
			this.registerTaskCallback(this.pmb,this.params.pointer,this.callback, true)
		this.init:=true
	}
	makeParams(){
		static sizeOfMbStruct:= A_PtrSize*3+8
		/*
		typedef struct INOUTDATA {
			MsgBox mbFn;
			LPCTSTR lpText;
			LPCTSTR	lpCaption;
			unsigned int uType;
			int ret;
		}io, *pIO;
		*/
		local mbPtr, mbStruct
		mbPtr:=xlib.ui.getFnPtrFromLib("User32.Dll","MessageBox",true)
		mbStruct:= new xlib.struct(sizeOfMbStruct,,"mbStruct")
		mbStruct.Build(  ["Ptr", mbPtr,						"mbFn"]
						,["Ptr", this.GetAddress("text"),	"lpText"]
						,["Ptr", this.GetAddress("title"),	"lpCaption"]
						,["Uint",this.options,				"uType"]
						,["Int",0,							"ret"])
		return mbStruct
	}
	destroy(){
		if this.init && this.isThreadRunning(1)
			return this.autoReleaseCallbackStruct(1)
		this.callbackStructs:=[]
	}
	mbBin(){
		/* c source:
		#include <windef.h>
		typedef int __stdcall (*MsgBox)(HWND,LPCTSTR,LPCTSTR,UINT);

		typedef struct INOUTDATA {
			MsgBox mbFn;
			LPCTSTR lpText;
			LPCTSTR	lpCaption;
			unsigned int uType;
			int ret;
		}io, *pIO;

		void mb(pIO data){
			MsgBox mb=data->mbFn;
			data->ret = (*mb)(0,data->lpText,data->lpCaption, data->uType);
			return;
		}
		*/
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366887(v=vs.85).aspx 	(VirtualAlloc function)
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366786(v=vs.85).aspx 	(Memory Protection Constants)
		static flProtect:=0x40, flAllocationType:=0x1000 ; PAGE_EXECUTE_READWRITE ; MEM_COMMIT	
		static raw32:=[]
		static raw64:=[3968026707,1368082464,1233863688,1099648024,3414771728,335530289,1209811849,1528874115,2425393347,2425393296,2425393296,2425393296]
		static bin
		if !bin
			bin:=xlib.mem.rawPut(raw32,raw64)
		return bin
	}
	pmb {
		get{
			return xMsgBox.mbBin()
		}
	}
}