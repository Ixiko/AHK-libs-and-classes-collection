; Compiled functions
class ccore{
	taskCallbackBin(){
		; Used by taskHandler. For callback on user task complete. See task.ahk
		; source: see taskCallback.c
		static raw32:=[]
		static raw64:=[3968026707,25905184,1221298504,4278732939,676563728,273386312,138644296,541821772,407079756,549749576,3774826587,2425393296]
		static bin
		if !bin 
			bin:=xlib.mem.rawPut(raw32,raw64)
		return bin
	}
}