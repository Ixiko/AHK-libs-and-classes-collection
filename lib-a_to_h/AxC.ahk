;AxC : Pack and Unpack Binary files
;Started by SKAN! , Mar 12 2008 04:27 PM
/*                              	DESCRIPTION
	
			Link: https://autohotkey.com/board/topic/27052-axc-pack-and-unpack-binary-files/
	
			AxC_Pack( packfile, files ) 
			The main function - creates an AxC file.
			
			packfile : the fullpath and name of the packfile to be created, eg. A_ScriptDir . "\MyCab.AxC"
			files : a pipe delimited list of files ( with fullpath ) to be packed into the AxC file
			
			hint: you may build a AxC file with three lines of code as shown is the example code below
			
			Loop, c:\project1\projectfiles\*.* 
			   files .= ( A_Index=1 ? "" : "|" ) . A_LoopFileLongPath 
			AxC_Pack( "pngs.axc" , files  )
			Return value: CSV based lookup table that was appended to the end of AxC file. You might want to save it for later reference like shown in the example below:
			
			Loop, c:\project1\projectfiles\*.* 
			   files .= ( A_Index=1 ? "" : "|" ) . A_LoopFileLongPath 
			FileAppend, % AxC_Pack( "myaxc.axc", files ), myaxc.csv
			Note: This library has AxC_GetCSV() function that will fetch the CSV lookup table from a valid AxC file.
			
			
			
			AxC_UnPackAll( packfile, folder ) 
			Unpacks all the files available in an AxC file.
			
			packfile - the fullpath and name of the packfile to be unpacked.
			folder - the fullpath to target folder where files would be unpacked. the target folder would be created if neccessary.
			progress - the dynamic function name that will display a progress bar ( requires AutoHotkey 1.0.47.06 ). You will have to remove comment marker ( ; ) on line 22.
			
			The default progress function name is axm_progress and you may insert the following function in your code:
			
			axm_progress( file,f,fls ) 
			progress,% (f/fls*100),%file%,unpacking %f%/%fls% files,AxC Unpacker,tahoma fs8
			ifequal,f,%fls%,progress,off
			
			Return value: the number of files unpacked.
			
			[*:25dtn2pf]Variant: AxC_ExtractAll() does not use the Lookup table, does not check the header and no CRC32 hash.
			
			
			
			AxC_UnPack( packfile, destination ) 
			Unpacks a single file available in an AxC file.
			
			packfile - the fullpath and name of the packfile to be unpacked.
			destination - the fullpath to the destination file. The calling script should make sure that the target folder exists before calling this function.
			
			
			[*:25dtn2pf]Variant: AxC_Extract() does not use the Lookup table, does not check the header and no CRC32 hash.
			[*:25dtn2pf]Variant: AxC_OffsetToFile() is same as above but uses offset instead of filename
			
			
			AxC_UnPackToMem( packfile, filename, byref bin ) 
			loads a single file available in an AxC file into AutoHotkey memory.
			
			packfile - the fullpath and name of the packfile to be unpacked.
			filename - the filename (no path) as displayed in a the CSV lookup table. 
			bin - variable to be passed to recieve the binary contents
			
			
			[*:25dtn2pf]Variant: AxC_ExtractToMem() does not use the Lookup table, does not check the header and no CRC32 hash.
			[*:25dtn2pf]Variant: AxC_OffsetToMem() is same as above but uses offset instead of filename
			
			
			AxC_GetCSV( packfile ) 
			Fetches a copy of CSV lookup table embedded at the tail of AxC file
			
			packfile - the fullpath and name of the packfile.
			
	*/
axc_pack(packfile,files) {                ; take care of the following binary line SKAN .. 
  crc:="U‹ì‹E…À~8‹USV‰E‹EWŠ" chr(10) "jB^‹ø¶ÙÁï3ûÀ÷Ç€ÿÿÿt3EÉNuäÿMuÙ_^[]Ã‹E]Ã"
  ls:="_llseek",lr:="_lread",,lc:="_lclose",lt:="_lcreat",lw:="_lwrite",u:="uint",i:="int"
  s:="str",varsetcapacity(b,16,0),numput(0x20437841,b),numput(0x3f666666,b,4),f:=0
  h:=dllcall(lt,s,packfile,i,0),dllcall(lw,u,h,s,b,u,16),q:="""",c:=",",lf:="`n"
  z:=chr(strlen(crc)),dllcall(lw,u,h,s,z,i,1),dllcall(lw,u,h,s,crc,u,strlen(crc))
  loop,parse,files,|
{ filegetsize,sz,%a_loopfield%
  if (sz<1||sz>(16*1024*1024))
     continue
  filegettime,mt,%a_loopfield%,m
  filegetattrib,at,%a_loopfield%
  fileread,bin,%a_loopfield%
  splitpath,a_loopfield,fil,dir,ext,filne
  crv:=dllcall(&CRC,str,bin,uint,sz,int,-1,uint,0x04C11DB7,"cdecl uint"),nl:=strlen(fil)+1
  varsetcapacity(x,4,0),numput(nl+sz,x),dllcall(lw,u,h,s,x,u,4),dllcall(lw,u,h,s,fil,u,nl)
  f:=f+1,cp:=dllcall(ls,u,h,i,0,i,1),dllcall(lw,u,h,s,bin,u,sz)
  csv.=q fil q c cp c sz c crv c mt c at lf    
} stringtrimright,csv,csv,1
  numput((cl:=strlen(csv)),x),dllcall(lw,u,h,s,csv,u,cl),dllcall(lw,u,h,s,x,u,4)
  dllcall(ls,u,h,i,8,i,0),numput(f,x),dllcall(lw,u,h,s,x,u,4),dllcall(lc,u,h)
return csv
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
axc_unpackall(packfile,dir="",progress="axm_progress") {
  ifequal,dir,,setenv,dir,%a_workingdir%
  ifnotexist,%dir%,filecreatedir,%dir%
  ls:="_llseek",lr:="_lread",lo:="_lopen",lc:="_lclose",u:="uint",i:="int",s:="str"
  lt:="_lcreat",lw:="_lwrite",h:=dllcall(lo,s,packfile,i,0),varsetcapacity(x,4,0)
  varsetcapacity(hdr,16),dllcall(lr,u,h,s,hdr,i,16),fls=numget(hdr,8),f:=0
  if (h<1||(numget(hdr)<>0x20437841)||(numget(hdr,4)<>0x3f666666)||fls<1)+(axc:=0) 
{ dllcall(lc,u,h)
  return -1
} dllcall(lr,u,h,s,hdr,i,1),z:=asc(hdr),varsetcapacity(crc,z),dllcall(lr,u,h,s,crc,i,z)
  dllcall(ls,u,h,u,-0,i,2),dllcall(ls,u,h,u,-0,i,2),dllcall(ls,u,h,i,0,i,1)
  dllcall(ls,u,h,i,-4,i,2),dllcall(lr,u,h,s,x,i,4),z:=numget(x),dllcall(ls,u,h,i,-z-4,i,2)
  varsetcapacity(csv,z),dllcall(lr,u,h,s,csv,i,z)
  loop,parse,csv,`n
{ loop, parse, a_loopfield, csv
  f%A_Index%:=a_loopfield
  dllcall(ls,u,h,i,f2,i,0),varsetcapacity(bin,f3),dllcall(lr,u,h,s,bin,i,f3)
  If ((e:=dllcall(&CRC,s,bin,u,f3,i,-1,u,0x04C11DB7,"cdecl uint")+0)<>f4)
{ msgbox,16,Checksum Error!,CRC32 failed on %f1% %e%
  continue
} tf:=dir "\" f1,h2:=dllcall(lt,s,tf,i,0),f:=f+1
  ;ifnotequal,progress,,setenv,dummy,% %progress%(tf,a_index,fls)
  dllcall(lw,u,h2,s,bin,u,f3),dllcall(lc,u,h2)
  filesettime,%f5%,%tf%,c
  filesettime,%f5%,%tf%,m  
  filesetattrib,+%f6%,%tf%
} Return f+dllcall(lc,u,h)
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
axc_unpack(packfile,dest="") {
  ls:="_llseek",lr:="_lread",lo:="_lopen",lc:="_lclose",u:="uint",i:="int",s:="str"
  lt:="_lcreat",lw:="_lwrite",h:=dllcall(lo,s,packfile,i,0),varsetcapacity(x,4,0)
  varsetcapacity(hdr,16),dllcall(lr,u,h,s,hdr,i,16),fls=numget(hdr,8)
  if (h<1||(numget(hdr)<>0x20437841)||(numget(hdr,4)<>0x3f666666)||fls<1)+(axc:=0) 
{ dllcall(lc,u,h)
  return -1
} dllcall(lr,u,h,s,hdr,i,1),z:=asc(hdr),varsetcapacity(crc,z),dllcall(lr,u,h,s,crc,i,z)
  dllcall(ls,u,h,u,-0,i,2),dllcall(ls,u,h,u,-0,i,2),dllcall(ls,u,h,i,0,i,1)
  dllcall(ls,u,h,i,-4,i,2),dllcall(lr,u,h,s,x,i,4),z:=numget(x),dllcall(ls,u,h,i,-z-4,i,2)
  varsetcapacity(csv,z),dllcall(lr,u,h,s,csv,i,z)
  splitpath,dest,fil,dir
  loop,parse,csv,`n
{ if (subStr(a_loopfield,2,instr(a_loopfield,"""",0,2)-2)=fil)
{ loop,parse,a_loopfield,csv
  f%a_index%:=a_loopfield  
  dllcall(ls,u,h,i,f2,i,0),varsetcapacity(bin,f3),dllcall(lr,u,h,s,bin,i,f3)
  If ((e:=dllcall(&CRC,s,bin,u,f3,i,-1,u,0x04C11DB7,"cdecl uint")+0)<>f4)
{ msgbox,16,Checksum Error!,CRC32 failed on %f1% %e%
  dllcall(lc,u,h)
  return -3
} h2:=dllcall(lt,s,dest,i,0),dllcall(lw,u,h2,s,bin,u,f3),dllcall(lc,u,h2),dllcall(lc,u,h)
  filesettime,%f5%,%tf%,c
  filesettime,%f5%,%tf%,m  
  filesetattrib,+%f6%,%tf%
  return dest
}} return dllcall(lc,u,h)
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
axc_unpacktomem(packfile,fil,byref bin) {
  ls:="_llseek",lr:="_lread",lo:="_lopen",lc:="_lclose",u:="uint",i:="int",s:="str"
  lt:="_lcreat",lw:="_lwrite",h:=dllcall(lo,s,packfile,i,0),varsetcapacity(x,4,0)
  varsetcapacity(hdr,16),dllcall(lr,u,h,s,hdr,i,16),fls=numget(hdr,8)
  if (h<1||(numget(hdr)<>0x20437841)||(numget(hdr,4)<>0x3f666666)||fls<1)+(axc:=0) 
{ dllcall(lc,u,h)
  return -1
} dllcall(lr,u,h,s,hdr,i,1),z:=asc(hdr),varsetcapacity(crc,z),dllcall(lr,u,h,s,crc,i,z)
  dllcall(ls,u,h,u,-0,i,2),dllcall(ls,u,h,u,-0,i,2),dllcall(ls,u,h,i,0,i,1)
  dllcall(ls,u,h,i,-4,i,2),dllcall(lr,u,h,s,x,i,4),z:=numget(x),dllcall(ls,u,h,i,-z-4,i,2)
  varsetcapacity(csv,z),dllcall(lr,u,h,s,csv,i,z)
  loop,parse,csv,`n
{ if ( subStr(a_loopfield,2,instr(a_loopfield,"""",0,2)-2)=fil)
{ loop,parse,a_loopfield,csv
  f%a_index%:=a_loopfield  
  dllcall(ls,u,h,i,f2,i,0),varsetcapacity(bin,f3),dllcall(lr,u,h,s,bin,i,f3)
  if ((e:=dllcall(&CRC,s,bin,u,f3,i,-1,u,0x04C11DB7,"cdecl uint")+0)<>f4)
{ msgbox,16,Checksum Error!,CRC32 failed on %f1% %e%
  varsetcapacity(bin,0),dllcall(lc,u,h)
  return -3
} dllcall(lc,u,h)
   return f3
}} return -2
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
axc_extractall(packfile,dir="") {
  ls:="_llseek",lr:="_lread",lo:="_lopen",lc:="_lclose",u:="uint",i:="int",s:="str"
  lt:="_lcreat",lw:="_lwrite",varsetcapacity(x,4,0),varsetcapacity(tfil,256,0)
  h:=dllcall(lo,s,packfile,i,0),dllcall(ls,u,h,u,8,i,0),dllcall(lr,u,h,s,x,i,4)
  f:=numget(x),dllcall(ls,u,h,u,4,i,1),dllcall(lr,u,h,s,x,i,1)
  csz:=numget(x,0,"uchar"),dllcall(ls,u,h,u,csz,i,1)
  ifequal,dir,,setenv,dir,%a_workingdir%
  ifnotexist,%dir%,filecreatedir,%dir%
  loop %f%
{ ix:=a_index,dllcall(lr,u,h,s,x,i,4),varsetcapacity(tfil,256)
  dllcall(lr,u,h,s,tfil,u,256),nl:=strlen(tfil)+1,sz:=numget(x)-nl,tfil:=substr(tfil,1,nl)
  varsetcapacity(bin,sz,0),  dllcall(ls,u,h,u,-256+nl,i,1),dllcall(lr,u,h,s,bin,u,sz)
  h2:=dllcall(lt,s,dir "\" tfil,i,0),dllcall(lw,u,h2,s,bin,u,sz),dllcall(lc,u,h2)
} return ix-f
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
axc_extract(packfile,dest="") { 
  ls:="_llseek",lr:="_lread",lo:="_lopen",lc:="_lclose",u:="uint",i:="int",s:="str"
  lt:="_lcreat",lw:="_lwrite",varsetcapacity(x,4,0),varsetcapacity(tfil,256,0)
  h:=dllcall(lo,s,packfile,i,0),dllcall(ls,u,h,u,8,i,0),dllcall(lr,u,h,s,x,i,4)
  f:=numget(x),dllcall(ls,u,h,u,4,i,1),dllcall(lr,u,h,s,x,i,1)
  csz:=numget(x,0,"uchar"),dllcall(ls,u,h,u,csz,i,1)
  splitpath,dest,fil,dir
  loop %f%
{ dllcall(lr,u,h,s,x,i,4),dllcall(lr,u,h,s,tfil,u,256)
  nl:=strlen(tfil)+1,sz:=numget(x)-nl,tfil:=substr(tfil,1,nl)
  if (tfil!=fil)
{ dllcall(ls,u,h,u,-256+numget(x),i,1)
  continue
} dllcall(ls,u,h,u,-256+nl,i,1),varsetcapacity(bin,sz,0),dllcall(lr,u,h,s,bin,u,sz)
  h2:=dllcall(lt,s,dest,i,0),dllcall(lw,u,h2,s,bin,u,sz),dllcall(lc,u,h2),fnd:=1
  break
} dllcall(lc,u,h)
return fnd ? dest : ""    
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
axc_extracttomem(packfile,fil,byref bin) { 
  ls:="_llseek",lr:="_lread",lo:="_lopen",lc:="_lclose",u:="uint",i:="int",s:="str"
  lt:="_lcreat",lw:="_lwrite",varsetcapacity(x,4,0),varsetcapacity(tfil,256,0)
  h:=dllcall(lo,s,packfile,i,0),dllcall(ls,u,h,u,8,i,0),dllcall(lr,u,h,s,x,i,4)
  f:=numget(x),dllcall(ls,u,h,u,4,i,1),dllcall(lr,u,h,s,x,i,1)
  csz:=numget(x,0,"uchar"),dllcall(ls,u,h,u,csz,i,1)
  loop %f%
{ dllcall(lr,u,h,s,x,i,4),dllcall(lr,u,h,s,tfil,u,256)
  nl:=strlen(tfil)+1,sz:=numget(x)-nl,tfil:=substr(tfil,1,nl)
  if (tfil!=fil)
{ dllcall(ls,u,h,u,-256+numget(x),i,1)
  continue
} dllcall(ls,u,h,u,-256+nl,i,1),varsetcapacity(bin,sz,0)
  Return dllcall(lr,u,h,s,bin,u,sz)+dllcall(lc,u,h2)+dllcall(lc,u,h)
} return dllcall(lc,u,h)    
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
axc_getcsv(packfile) {
  ls:="_llseek",lr:="_lread",lo:="_lopen",lc:="_lclose",u:="uint",i:="int",s:="str"
  lt:="_lcreat",lw:="_lwrite",h:=dllcall(lo,s,packfile,i,0),varsetcapacity(x,4,0)
  varsetcapacity(hdr,16),dllcall(lr,u,h,s,hdr,i,16),fls=numget(hdr,8)
  if (h<1||(numget(hdr)<>0x20437841)||(numget(hdr,4)<>0x3f666666)||fls<1)+(axc:=0) 
{ dllcall(lc,u,h)
  return -1
} dllcall(ls,u,h,i,-0,i,2),dllcall(ls,u,h,i,-0,i,2),dllcall(ls,u,h,i,0,i,1)
dllcall(ls,u,h,i,-4,i,2),dllcall(lr,u,h,s,x,i,4),sz:=numget(x),dllcall(ls,u,h,i,-sz-4,i,2)
  varsetcapacity(csv,sz),dllcall(lr,u,h,s,csv,i,sz),dllcall(lc,u,h)
return csv  
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
axc_offsettofile(packfile,offset,sz,dest) {
  h:=dllcall("_lopen",str,packfile,int,0),varsetcapacity(x,4,0),varsetcapacity(hdr,16)
  dllcall("_lread",uint,h,str,hdr,int,16),fls=numget(hdr,8),varsetcapacity(bin,sz)
  if (h<1||(numget(hdr)<>0x20437841)||(numget(hdr,4)<>0x3f666666)||fls<1)+(axc:=0) 
{ dllcall("_lclose",uint,h)
  return -1
} dllcall("_llseek",uint,h,uint,offset,int,0),dllcall("_lread",uint,h,str,bin,int,sz)
  h2:=dllcall("_lcreat",str,dest,int,0),bytes:=dllcall("_lwrite",uint,h2,str,bin,uint,sz)
return dllcall("_lclose",uint,h) + dllcall("_lclose",uint,h2) + bytes 
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
axc_offsettomem(packfile,offset,sz,byref bin) {
  h:=dllcall("_lopen",str,packfile,int,0),varsetcapacity(x,4,0),varsetcapacity(hdr,16)
  dllcall("_lread",uint,h,str,hdr,int,16),fls=numget(hdr,8),varsetcapacity(bin,sz)
  if (h<1||(numget(hdr)<>0x20437841)||(numget(hdr,4)<>0x3f666666)||fls<1)+(axc:=0) 
{ dllcall("_lclose",uint,h)
  return -1
} dllcall("_llseek",uint,h,uint,offset,int,0)
return dllcall("_lread",uint,h,str,bin,int,sz) + dllcall("_lclose",uint,h) 
} ;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -




	