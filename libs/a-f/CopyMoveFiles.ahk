;********************Copy / Move files***********************************
;CopyMoveFiles(fSource,fTarget,"copy")
CopyMoveFiles(Source,Destination,Method){                                                         	;--

	Method:= (Method="copy")?("0x2"):("0x1")
	ghwnd:=A_ScriptHwnd,flags:=0x8
	Destination:=Trim(Destination,"|") "|",Source:=Trim(Source,"|") "|"
	VarSetCapacity(sPtr,StrPut(Source,"UTF-8"),0)
	VarSetCapacity(dPtr,StrPut(Destination,"UTF-8"),0)
	for a,b in StrSplit(Source)
		NumPut(b="|"?0:Asc(b),&sPtr,A_Index-1,"UChar")
	for a,b in StrSplit(Destination)
		NumPut(b="|"?0:Asc(b),&dPtr,A_Index-1,"UChar")
	VarSetCapacity(SHFILEOPSTRUCT,30,0)                  	; Encoding SHFILEOPSTRUCT
	NextOffset:=NumPut(ghwnd,&SHFILEOPSTRUCT) 	; hWnd of calling GUI
	NextOffset:=NumPut(Method,NextOffset+0)          	; File operation- JG changed here- 1=copy 2=move
	NextOffset:=NumPut(&sPtr,NextOffset+0)             	; Source file / pattern
	NextOffset:=NumPut(&dPtr,NextOffset+0)            	; Target file / folder
	NextOffset:=NumPut(flags,NextOffset+0,0,"Short")	; options
	SetFormat,integer,H
	Ret:=DllCall("Shell32\SHFileOperationA",UInt,&SHFILEOPSTRUCT)

	if(Ret){
		m(ret,"some error")
		ExitApp
	}
	SetFormat,integer,D
}