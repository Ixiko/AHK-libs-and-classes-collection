AhkExported(){
  static init,functions
  If !init{
    init:=Object(),functions:="ahkFunction:s==sssssssssss|ahkPostFunction:s==sssssssssss|ahkassign:ui==ss|ahkExecuteLine:t==tuiui|ahkFindFunc:t==s|ahkFindLabel:t==s|ahkgetvar:s==sui|ahkLabel:ui==sui|ahkPause:i==s"
    If (DllCall((exe:=!A_AhkPath?A_ScriptFullPath:A_AhkPath) "\ahkgetvar","Str","A_AhkPath","UInt",0,"CDecl Str"))
      functions.="|addFile:t==si|addScript:t==si|ahkExec:ui==s"
    Loop,Parse,functions,|
		{v:=StrSplit(A_LoopField,":"),init[v.1]:=DynaCall(exe "\" v.1,v.2)
		If (v.1="ahkFunction")
			init["_" v.1]:=DynaCall(exe "\" v.1,"s==stttttttttt")
		else if (v.1="ahkPostFunction")
			init["_" v.1]:=DynaCall(exe "\" v.1,"i==stttttttttt")
		}
  }
  return init
}