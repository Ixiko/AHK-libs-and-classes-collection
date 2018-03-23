ahkthread_free(obj:=""){
  static objects
  if !objects
    objects:=[]
  if obj=""
      objects:=[]
  else if !IsObject(obj)
	return objects
  else If objects.HasKey(obj)
	objects.Remove(obj)
}
ahkthread_release(o){
  o.ahkterminate(o.timeout?o.timeout:0),MemoryFreeLibrary(o[""])
}
ahkthread(s:="",p:="",IsFile:=0,dll:=""){
  static ahkdll,ahkmini,base,functions
  if !base
    base:={__Delete:"ahkthread_release"},UnZipRawMemory(LockResource(LoadResource(0,hRes:=DllCall("FindResource","PTR",0,"Str","F903E44B8A904483A1732BA84EA6191F","PTR",10,"PTR"))),SizeofResource(0,hRes),ahkdll)
    ,UnZipRawMemory(LockResource(LoadResource(0,hRes:=DllCall("FindResource","PTR",0,"Str","FC2328B39C194A4788051A3B01B1E7D5","PTR",10,"PTR"))),SizeofResource(0,hRes),ahkmini)
    ,functions:={_ahkFunction:"s==stttttttttt",_ahkPostFunction:"i==stttttttttt",ahkFunction:"s==sssssssssss",ahkPostFunction:"i==sssssssssss",ahkdll:"ut==ss",ahktextdll:"ut==ss",ahkReady:"",ahkReload:"i==i",ahkTerminate:"i==i",addFile:"ut==sucuc",addScript:"ut==si",ahkExec:"ui==s",ahkassign:"ui==ss",ahkExecuteLine:"ut==utuiui",ahkFindFunc:"ut==s",ahkFindLabel:"ut==s",ahkgetvar:"s==sui",ahkLabel:"ui==sui",ahkPause:"i==s",ahkIsUnicode:""}
  obj:={(""):lib:=MemoryLoadLibrary(dll=""?&ahkdll:dll="FC2328B39C194A4788051A3B01B1E7D5"?&ahkmini:dll),base:base}
  for k,v in functions
    obj[k]:=DynaCall(MemoryGetProcAddress(lib,A_Index>2?k:SubStr(k,2)),v)
  If !(s+0!="" || s=0)
    obj.hThread:=obj[IsFile?"ahkdll":"ahktextdll"](s,"",p)
  ahkthread_free(true)[obj]:=1 ; keep dll loadded even if returned object is freed
  return obj
}