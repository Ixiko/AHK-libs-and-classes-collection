ResGet(ByRef data,dll,name,type:=10,lang:=""){
  static TH32CS_SNAPMODULE,MODULEENTRY32,me32,fullpath
  if !TH32CS_SNAPMODULE
    TH32CS_SNAPMODULE:=0x00000008,MODULEENTRY32:="DWORD dwSize;th32ModuleID;th32ProcessID;GlblcntUsage;ProccntUsage;BYTE *modBaseAddr;DWORD modBaseSize;HMODULE hModule;TCHAR szModule[256];TCHAR szExePath[260]"
    ,me32 := Struct(MODULEENTRY32,{dwSize:sizeof(MODULEENTRY32)}),VarSetCapacity(fullpath,520)
	GetFullPathNameW(dll,260,fullpath),VarSetCapacity(fullpath,-1)
	If (hSnap:=CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,GetCurrentProcessId())) && Module32FirstW(hSnap,me32[])
		while (A_Index=1 || Module32NextW(hSnap,me32[]))
			if StrGet(me32.szExePath[""])=fullpath && hModule:= me32.modBaseAddr["",""]
        break
  if hSnap
		CloseHandle(hSnap)
  if !hModule && !hModule:=LoadLibrary(fullpath)
		return 0
  if (hResource:=lang=""?DllCall("FindResource","PTR",hModule,name+0=""?"Str":"PTR",name,type+0=""?"Str":"PTR",type,"PTR"):DllCall("FindResourceEx","PTR",hModule,name+0=""?"Str":"PTR",name,type+0=""?"Str":"PTR",type,"Uint",lang,"PTR"))
      && pdata:=LockResource(hResData:=LoadResource(hModule,hResource))
      VarsetCapacity(data,sz:=SizeofResource(hModule,hResource)),RtlMoveMemory(&data,pData,sz)
	if (hModule != me32.modBaseAddr["",""]),FreeLibrary(hModule)
	return sz
}