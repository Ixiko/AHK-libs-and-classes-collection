AhkDllThread(dll="AutoHotkey.dll",obj=0){
	static
	local v,v1,v2
	static init, DynaCall:="DynaCall", MemoryLoadLibrary:="MemoryLoadLibrary",MemoryFreeLibrary:="MemoryFreeLibrary"
			,ResourceLoadLibrary:="ResourceLoadLibrary", MemoryGetProcAddress:="MemoryGetProcAddress"

	static functions ="
(Join
ahkKey:s|ahkFunction:s=sssssssssss|ahkPostFunction:i=sssssssssss|
ahkdll:ui=sss|ahktextdll:ui=sss|ahkReady:|ahkReload:ui=|
ahkTerminate:i|addFile:ui=sucuc|addScript:ui=si|ahkExec:ui=s|
ahkassign:ui=ss|ahkExecuteLine:ui=uiuiui|ahkFindFunc:ui=s|
ahkFindLabel:ui=s|ahkgetvar:s=sui|ahkLabel:ui=sui|ahkPause:s
)"
  static AhkDllThreadfunc ="
(Join`r`n
#Persistent
#NoTrayIcon
Return
AhkDllThread(dll=""AutoHotkey.dll"",obj=0,map=""""){
	static
	local v,v1,v2
	static functions = ""ahkKey:s|ahkFunction:s=sssssssssss|ahkPostFunction:i=sssssssssss|""
							. ""ahkdll:ui=sss|ahktextdll:ui=sss|ahkReady:|ahkReload:ui=|""
							. ""ahkTerminate:i|addFile:ui=sucuc|addScript:ui=si|ahkExec:ui=s|""
							. ""ahkassign:ui=ss|ahkExecuteLine:ui=uiuiui|ahkFindFunc:ui=s|""
							. ""ahkFindLabel:ui=s|ahkgetvar:s=sui|ahkLabel:ui=sui|ahkPause:s""
	If !dll {
		Loop `% i
		{
			idx:=A_Index
			`%MemoryFreeLibrary`%(dllmodule`%A_Index`%)
			obj`%A_Index`%:="""",dll`%A_Index`%:="""",dllmodule`%A_Index`%:=""""
		}
		i=0
		return
	} else if (!FileExist(dll)){
		MsgBox File: `%dll`% does not exist`, provide correct path for AutoHotkey.dll
		ExitApp
	}
	i++
	dllmodule`%i`%:= MemoryLoadLibrary(dll)
	if IsObject(obj)
    object:=obj
	else
    object := Object()
  object[""""]:=dllmodule`%i`%
	Loop,Parse,functions,|
	{
		StringSplit,v,A_LoopField,:
		object[map="""" ? v1 : !InStr(map,v1) ? v1 : SubStr(map,InStr(map,v1)+StrLen(v1)+1,InStr(map,A_Space,0,InStr(map,v1)))]:=DynaCall(MemoryGetProcAddress(dllmodule`%i`%,v1),v2)
	}
  obj`%i`%:=object
	dll`%i`%:=dll
	return &obj`%i`%
}
)"
  If !(dll){
    If !AHK_H{
			return DllCall(dll "\ahkFunction","Str","AhkDllThread","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","CDecl Str")
		}
		Loop % i
		{
			idx:=A_Index
			%MemoryFreeLibrary%(dllmodule%A_Index%)
			obj%A_Index%:="",dll%A_Index%:="",dllmodule%A_Index%:=""
		}
		i=0
		return
	} else if (!FileExist(dll) && !A_IsCompiled){
		MsgBox File: %dll%`ndoes not exist`, provide correct path for AutoHotkey.dll
		ExitApp
	}
	If !AHK_H{
    If (init || init:=DllCall("LoadLibrary","Str",dll)){
			If DllCall(dll "\ahktextdll","Str",AhkDllThreadfunc,"Str","","Str","","Cdecl UInt")
				Return Object(0+DllCall(dll "\ahkFunction","Str","AhkDllThread","Str",dll,"Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","CDecl Str"))
			else
				Return 0,ErrorLevel:="Could not load AutoHotkey.dll"
		} else {
			MsgBox Could not load %dll%
			Return 0
		}
	}
	i++
	dllmodule%i%:=A_IsCompiled ? %ResourceLoadLibrary%(dll) : %MemoryLoadLibrary%(dll)
	if IsObject(obj)
    object:=obj
	else
    object := Object()
  object[""]:=dllmodule%i%
	Loop,Parse,functions,|
	{
		StringSplit,v,A_LoopField,:
		object[map="" ? v1 : !InStr(map,v1) ? v1 : SubStr(map,InStr(map,v1)+StrLen(v1)+1,InStr(map,A_Space,0,InStr(map,v1)))]:=%DynaCall%(%MemoryGetProcAddress%(dllmodule%i%,v1),v2)
	}
  obj%i%:=object
	dll%i%:=dll
	return obj%i%
}


/*
AhkDllThread(dll=""){
	static
	static ResourceLoadLibrary:="ResourceLoadLibrary"
	static functions:="ahkdll|ahktextdll|ahkReady|ahkReload|ahkTerminate|addFile|addScript|assign|ahkExecuteLine|ahkFindFunc|ahkFindLabel|ahkgetvar|ahkLabel|ahkPause"
	If !(dll){
		Loop % i
		{
			idx:=A_Index
			Loop,Parse,functions,|
				DynaCall(dll%idx% . "\" . A_LoopField)
			MemoryFreeLibrary(dllmodule%A_Index%)
			obj%A_Index%=
			dll%A_Index%=
			dllmodule%A_Index%=
		}
		i=0
		return
	}
	i++
	dllmodule%i%:=A_IsCompiled ? %ResourceLoadLibrary%(dll) : MemoryLoadLibrary(dll)
	object := Object()
	Loop,Parse,functions,|
		object[A_LoopField]:=MemoryGetProcAddress(dllmodule%i%,A_LoopField)
	DynaCall(object.ahkdll,"Str","","Str","","Str","","CDecl UInt")
	DynaCall(object.ahktextdll,"Str","","Str","","Str","","CDecl UInt")
	DynaCall(object.ahkReady,"Cdecl Int")
	DynaCall(object.ahkReload,"Cdecl Int")
	DynaCall(object.ahkTerminate,"Int",0,"Cdecl Int")
	DynaCall(object.addFile,"Str","","uchar",0,"uchar",0,"CDecl UInt")
	DynaCall(object.addScript,"Str","","Int",0,"Int",0,"CDecl UInt")
	DynaCall(object.ahkassign,"Str","","Str","")
	DynaCall(object.ahkExecuteLine,"UInt",0,"UInt",0,"UInt",0,"CDecl UInt")
	DynaCall(object.ahkFindFunc,"Str","","CDecl UInt")
	DynaCall(object.ahkFunction,"Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","CDecl Str")
   DynaCall(object.ahkPostFunction,"Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","CDecl Str")
	DynaCall(object.ahkgetvar,"Str","","UInt",0,"CDecl Str")
	DynaCall(object.ahkLabel,"Str","","CDecl UInt")
	DynaCall(object.ahkPause,"Str","")
	obj%i%:=object
	dll%i%:=dll
	return obj%i%
}