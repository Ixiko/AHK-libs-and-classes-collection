; Block hook and send input.
class sendHook extends SendInputW {
	static ctr:=0
	__new(str){
		base.__new(str,0)
		sendHook.initHook()
		sendHook.ctr++
	}
	initHook(){
		if !sendHook.hook
			sendHook.hook:= new kbhook("blockHook")
		return
	}
	send(str:=""){
		local r
		if !sendHook.hook
			sendHook.initHook()
		sendHook.hook.start()
		r:=base.send(str)
		sendHook.hook.stop()
		return r
	}
	__delete(){
		if (!--sendHook.ctr && sendHook.hook)
			sendHook.hook.clear(),sendHook.hook:=""
		return
	}
}
; Includes:
#Include inputUnicode.ahk
#Include SendInput.ahk
#Include %A_ScriptDir%/../../classes/kbdhook/kbhook.ahk