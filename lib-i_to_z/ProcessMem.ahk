
getProcessHandle(pid,mode=0x001F0FFF){
	return DllCall("OpenProcess",UInt,mode,UInt,0,UInt,pid,UInt)
}
releaseProcessHandle(hProcess){
	DllCall("psapi\CloseProcess","Int",hProcess)
}
getPEName(pid){
	hModule=0
	dwNeed=0
	l=0
	max:=VarSetCapacity(s,256,0)
	hProcess:=getProcessHandle(pid,0x410)	;�ʂ邢�A�N�Z�X���łȂ��Ƌ��ۂ��邱�Ƃ�����	if(DllCall("psapi\EnumProcessModules","Int",hProcess,"Int*",hModule,"Int",4,"UInt*",dwNeed,"Int")<>0){
		l:=DllCall("psapi\GetModuleFileNameExA","Int",hProcess,"Int",hModule,"Str",s,"Int",max,"Int")
	}
	releaseProcessHandle(hProcess)
	return s
}
readProcMem(pid,addr,len){
	if(len="Int64"){
		type=Int64 *
		size=8
	}else If len in Int,UInt
	{
		type=%len% *
		size=4
	}else If len in Short,UShort
	{
		type=%len% *
		size=2
	}else If len in Char,UChar
	{
		type=%len% *
		size=1
	}else{
		type=Str
		size:=VarSetCapacity(s,len)+1
	}
	hProcess:=getProcessHandle(pid)
	DllCall("ReadProcessMemory","Int",hProcess,"Int",addr,type,res,"Int",size,"Int",0)
	releaseProcessHandle(hProcess)
	return res
}
writeProcMem(pid,addr,val){
	StringLen,size,val
	if val is integer
	{
		IfInString,val,0x
		{
			if(size>10){
				type=Int64 *
				size=8
			}else if(size>6){
				type=Int *
				size=4
			}else if(size>4){
				type=Short *
				size=2
			}else{
				type=Char *
				size=1
			}
		}else{
			type=Int *
			size=4
		}
	}else{
		type=Str
		size++
	}
	hProcess:=getProcessHandle(pid)
	DllCall("WriteProcessMemory","Int",hProcess,"Int",addr,type,val,"Int",size,"Int",0)
	releaseProcessHandle(hProcess)
}


