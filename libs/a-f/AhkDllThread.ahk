#include <_MemoryLibrary>
AhkDllThread_IsH(){ ; FileGetVersionInfo Written by SKAN modified by HotKeyIt www.autohotkey.com/forum/viewtopic.php?p=233188#233188
 Static HexVal:="msvcrt\s" (A_IsUnicode?"w":"") "printf",AHK:=A_AhkPath?A_AhkPath:A_ScriptFullPath
 If ((FSz:=DllCall("Version\GetFileVersionInfoSize","Str",AHK,"UInt",0)) && VarSetCapacity(FVI,FSz,0) && VarSetCapacity(Trans,8*(A_IsUnicode?2:1)))
  && DllCall("Version\GetFileVersionInfo","Str",AHK,"Int",0,"UInt",FSz,"UInt",&FVI) 
  && DllCall("Version\VerQueryValue","UInt",&FVI,"Str","\VarFileInfo\Translation","UIntP",Translation,"UInt",0)
  && DllCall(HexVal,"Str",Trans,"Str","`%08X","UInt",NumGet(Translation+0))
  && DllCall("Version\VerQueryValue","UInt",&FVI,"Str","\StringFileInfo\" SubStr(Trans,-3) SubStr(Trans,1,4) "\InternalName","UIntP",InfoPtr,"UInt",0)
    Return StrGet(InfoPtr+0,DllCall("lstrlen" (A_IsUnicode?"W":"A"),"PTR",InfoPtr)) = "AutoHotkey_H"
				|| StrGet(InfoPtr+0,DllCall("lstrlen" (A_IsUnicode?"W":"A"),"PTR",InfoPtr)) = " "
}
AhkDllThread(dll="AutoHotkey.dll",obj=0){
  static init,ahkfunction,hLib,dllptr,libScript,ahkexec,DynaCall:="DynaCall", MemoryLoadLibrary:="MemoryLoadLibrary",MemoryFreeLibrary:="MemoryFreeLibrary"
      ,ResourceLoadLibrary:="ResourceLoadLibrary", MemoryGetProcAddress:="MemoryGetProcAddress"
  static AHK_H:=AhkDllThread_IsH()
  static base:={__Delete:"AhkDllThread"}
  static functions :="
(Join
ahkFunction:s=sssssssssss|ahkPostFunction:i=sssssssssss|
ahkdll:ut=sss|ahktextdll:ut=sss|ahkReady:|ahkReload:ui=|
ahkTerminate:i|addFile:ut=sucuc|addScript:ut=si|ahkExec:ui=s|
ahkassign:ui=ss|ahkExecuteLine:ut=utuiui|ahkFindFunc:ut=s|
ahkFindLabel:ut=s|ahkgetvar:s=sui|ahkLabel:ui=sui|ahkPause:s
)"
  static AhkDllThreadfunc :="
(Join`r`n
" (!A_IsCompiled ? "#include <_MemoryLibrary>" : "") "
#Persistent
SetBatchLines,-1
#NoTrayIcon
Return
AhkDllThreadDLL(dll=""AutoHotkey.dll"",obj=0){
  static functions := ""ahkFunction:s=sssssssssss|ahkPostFunction:i=sssssssssss|""
              . ""ahkdll:ut=sss|ahktextdll:ut=sss|ahkReady:|ahkReload:ui=|""
              . ""ahkTerminate:i|addFile:ut=sucuc|addScript:ut=si|ahkExec:ui=s|""
              . ""ahkassign:ui=ss|ahkExecuteLine:ut=utuiui|ahkFindFunc:ui=s|""
              . ""ahkFindLabel:ui=s|ahkgetvar:s=sui|ahkLabel:ui=sui|ahkPause:s""
  If (dll=""0""){
    object:=""""
    return
  } else If (!FileExist(dll) && obj=0){
    MsgBox File: `%dll`% does not exist`, provide correct path for AutoHotkey.dll
    ExitApp
  }
  object:={"""":new _MemoryLibrary(obj?obj:dll)}
  Loop,Parse,functions,|
  {
    StringSplit,v,A_LoopField,:
    object[map="""" ? v1 : !InStr(map,v1) ? v1 : SubStr(map,InStr(map,v1)+StrLen(v1)+1,InStr(map,A_Space,0,InStr(map,v1)))]:=DynaCall(object[""""].GetProcAddress(v1),v2)
  }
  object.base:=Object(" (&base) ")
  return &object
}
)"
  If IsObject(dll){
    dll.ahkterminate()
    If !AHK_H {
      dll[""].Free(),dll:=""
    } else %MemoryFreeLibrary%(dll[""])
    return
  } else if (!FileExist(dll) && !A_IsCompiled){
    MsgBox File: %dll%`ndoes not exist`, provide correct path for AutoHotkey.dll
    ExitApp
  }
  If !AHK_H{
    If (init || ((hLib:=new _MemoryLibrary(A_IsCompiled?(dllptr:=DllCall("LockResource","ptr",DllCall("LoadResource","ptr",lib,"ptr",DllCall("FindResource","ptr",lib:=DllCall("GetModuleHandle","ptr",0,"ptr"),"str",dll,"ptr",10,"ptr"),"ptr"),"ptr")):dll)) && (Init:=hLib.GetProcAddress("ahktextdll")) && (!A_IsCompiled||LibScript:=(!(res:=DllCall("FindResource","ptr",lib:=DllCall("GetModuleHandle","ptr",0,"ptr"),"str",">AUTOHOTKEY SCRIPT<","ptr",10,"ptr"))?(res:=DllCall("FindResource","ptr",lib,"str",">AHK WITH ICON<","ptr",10,"ptr")):res)?StrGet(DllCall("LockResource","ptr",DllCall("LoadResource","ptr",lib,"ptr",res,"ptr"),"ptr"),DllCall("SizeofResource","ptr",lib,"ptr",res,"uint"),"UTF-8"):""))){
      If (ahkfunction || (DllCall(init,"Str",AhkDllThreadfunc "`n" LibScript,"Str","","Str","","Cdecl UInt") && (ahkfunction:=hLib.GetProcAddress("ahkFunction")) && (ahkExec:=hLib.GetProcAddress("ahkExec")))){
        return Object(0+DllCall(ahkfunction,"Str","AhkDllThreadDLL","Str",dll,"Str",A_IsCompiled?dllptr:"","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","CDecl Str"))
        ;reset internal return memory in autoHotkey.dll and release object
        ,DllCall(ahkfunction,"Str","AhkDllThreadDLL","Str","0","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","Str","","CDecl Str")
      } else {
        MsgBox Could not load script in %dll%
        Return 0
      }
    } else {
      MsgBox Could not load %dll%
      Return 0
    }
  }
  object:=IsObject(obj)?obj:{},object[""]:= A_IsCompiled ? %ResourceLoadLibrary%(dll) : %MemoryLoadLibrary%(dll)
  Loop,Parse,functions,|
  {
    StringSplit,v,A_LoopField,:
    object[map="" ? v1 : !InStr(map,v1) ? v1 : SubStr(map,InStr(map,v1)+StrLen(v1)+1,InStr(map,A_Space,0,InStr(map,v1)))]:=%DynaCall%(%MemoryGetProcAddress%(object[""],v1),v2)
  }
  return object,object.base:=base
}