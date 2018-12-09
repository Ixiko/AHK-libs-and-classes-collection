class IPC {

	static __INIT__ := IPC.__INIT_CLASS__()
	__CHECK_INIT__ := IPC.__INIT_CLASS__()

	__New(target, handler:="") {
		this.Insert("_", [])

		this.target := target
		if handler
			this.handler := handler

		IPC.__[this.target] := &this

	}

	__Delete() {
		IPC.__.Remove(this.target)
	}

	__Set(k, v, p*) {

		if (k = "__CHECK_INIT__")
			return v

		if (k = "target") {
			dhw := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if !(v:=WinExist(v))
				throw Exception("Target script does not exist.", -1)
			DetectHiddenWindows, % dhw

		} else if (k = "handler") {
			if (v && !IsFunc(v))
				throw Exception("Invalid Handler", -1)

		}

		return this._[k] := v
	}

	class __Get extends IPC.__PROPERTIES__
	{

		__(k, p*) {
			if this._.HasKey(k)
				return this._[k, p*]
		}
	}

	send(ByRef data) {

		VarSetCapacity(CDS, 3*A_PtrSize, 0)
		szBytes := (StrLen(data) + 1) * (A_IsUnicode ? 2 : 1)

		NumPut(szBytes, CDS, A_PtrSize)
		NumPut(&data, CDS, 2*A_PtrSize)

		dhw := A_DetectHiddenWindows
		DetectHiddenWindows, On
		SendMessage, 0x4a, % A_ScriptHwnd, &CDS,, % "ahk_id " this.target
		DetectHiddenWindows, % dhw

		return ErrorLevel
	}

	receive(data) {
		if !this.handler
			return
		return (this.handler).(this, data)
	}

	__onCOPYDATA(lParam) {
		static sender , data

		StrAddress := NumGet(lParam + 2*A_PtrSize)
		COD := StrGet(StrAddress)

		if (sender:=(IPC.__.HasKey(this) ? IPC.__[this] : "")) {
			data := COD
			SetTimer, IPC_onCOPYDATA, -1
		}
		return true

		IPC_onCOPYDATA:
		Object(sender).receive(data)
		sender := "" , data := ""
		return

	}

	__INIT_CLASS__() {
		static init

		if init
			return
		init := true
		IPC.__ := [] , IPC._ := []
		IPC.base := {__Set:IPC.__baseSet, __Get:IPC.__baseGet}

		IPC.monitor := true
		return
	}

	__baseSet(k, v, p*) {

		if (k = "monitor") {
			args := (v ? [0x4a, "IPC.__onCOPYDATA"] : [0x4a, ""])
			OnMessage(args*)
		}

		return this._[k] := v
	}

	class __baseGet extends IPC.__PROPERTIES__
	{

		__(k, p*) {
			if this._.HasKey(k)
				return this._[k, p*]
		}

		monitor() {
			return (OnMessage(0x4a) = "IPC.__onCOPYDATA") ? true : false
		}
	}

	class __PROPERTIES__
	{
		__Call(target, name, params*) {
			if !(name ~= "i)^(base|__Class)$") {
				return ObjHasKey(this, name)
				       ? this[name].(target, params*)
				       : this.__.(target, name, params*)
			}
		}
	}
}


DynaRun2(s,pn:="",pr:="",exe:=""){
static AhkPath,h2o
if !AhkPath
AhkPath:="""" A_AhkPath """" (A_IsCompiled||(A_IsDll&&DllCall(A_AhkPath "\ahkgetvar","Str","A_IsCompiled","CDecl"))?" /E":"")
,h2o:="B29C2D1CA2C24A57BC5E208EA09E162F(){`nPLACEHOLDERB29C2D1CA2C24A57BC5E208EA09E162FVarSetCapacity(dmp,sz:=StrLen(hex)//2,0)`nLoop,Parse,hex`nIf (""""!=h.=A_LoopField) && !Mod(A_Index,2)`nNumPut(""0x"" h,&dmp,A_Index/2-1,""UChar""),h:=""""`nreturn ObjLoad(&dmp)`n}`n"
if (-1=p1:=DllCall("CreateNamedPipe","str",pf:="\\.\pipe\" (pn!=""?pn:"AHK" A_TickCount),"uint",2,"uint",0,"uint",255,"uint",0,"uint",0,"Ptr",0,"Ptr",0))
|| (-1=p2:=DllCall("CreateNamedPipe","str",pf,"uint",2,"uint",0,"uint",255,"uint",0,"uint",0,"Ptr",0,"Ptr",0))
Return 0
Run % (exe?exe:AhkPath) " """ pf """ " (IsObject(pr)?"": " " pr),,UseErrorLevel HIDE,P
If ErrorLevel
return DllCall("CloseHandle","Ptr",p1),DllCall("CloseHandle","Ptr",p2),0
If IsObject(pr) {
sz:=ObjDump(pr,dmp),hex:=BinToHex(&dmp,sz)
While % _hex:=SubStr(Hex,1 + (A_Index-1)*16370,16370)
_s.= "hex" (A_Index=1?":":".") "=""" _hex """`n"
Arg:=StrReplace(h2o,"PLACEHOLDERB29C2D1CA2C24A57BC5E208EA09E162F",_s) "global A_Args:=B29C2D1CA2C24A57BC5E208EA09E162F()`n"
}
DllCall("ConnectNamedPipe","Ptr",p1,"Ptr",0),DllCall("CloseHandle","Ptr",p1),DllCall("ConnectNamedPipe","Ptr",p2,"Ptr",0)
if !DllCall("WriteFile","Ptr",p2,"Wstr",s:=(A_IsUnicode?chr(0xfeff):"﻿") Arg s,"UInt",StrLen(s)*(A_IsUnicode?2:1)+(A_IsUnicode?4:3),"uint*",0,"Ptr",0)
P:=0
DllCall("CloseHandle","Ptr",p2)
Return P
}