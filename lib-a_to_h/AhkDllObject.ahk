AhkDllObject(dll="AutoHotkey.dll",obj=0){
	static
	static functions ="
(Join
ahkKey:s|ahkFunction:s=sssssssssss|ahkPostFunction:s=sssssssssss|
ahkdll:ui=sss|ahktextdll:ui=sss|ahkReady:|ahkReload:ui=|
ahkTerminate:i|addFile:ui=sucuc|addScript:ui=sucuc|ahkExec:ui=s|
ahkassign:ui=ss|ahkExecuteLine:ui=uiuiui|ahkFindFunc:ui=s|
ahkFindLabel:ui=s|ahkgetvar:s=sui|ahkLabel:ui=sui|ahkPause:s
)"
	If !(dll){
		Loop % i
		{
			idx:=A_Index
			Loop,Parse,functions,|
				DynaCall(dll%idx% . "\" . A_LoopField)
			DllCall(dll%A_Index% . "\ahkTerminate")
			DllCall("FreeLibrary","UInt",dllmodule%A_Index%)
			obj%A_Index%=
			dll%A_Index%=
			dllmodule%A_Index%=
		}
		i=0
		return
	} else {
    Loop % i
      If (dll=dll%A_Index%)
        return obj%A_Index%
  }
	i++
	dllmodule%i%:=DllCall("LoadLibrary","str",dll)
  if IsObject(obj)
    object:=obj
	else
    object := Object()
	Loop,Parse,functions,|
	{
		object[f:=SubStr(A_LoopField,1,InStr(A_LoopField,":")-1)] := DynaCall(dll "\" f,SubStr(A_LoopField,InStr(A_LoopField,":")+1))
	}
	obj%i%:=object
	dll%i%:=dll
	return obj%i%
}