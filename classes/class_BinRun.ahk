;#Include <_Struct>
Class _BinRun {
  static IMAGE_DOS_HEADER :="
  (
    WORD   e_magic;                     // Magic number
    WORD   e_cblp;                      // Bytes on last page of file
    WORD   e_cp;                        // Pages in file
    WORD   e_crlc;                      // Relocations
    WORD   e_cparhdr;                   // Size of header in paragraphs
    WORD   e_minalloc;                  // Minimum extra paragraphs needed
    WORD   e_maxalloc;                  // Maximum extra paragraphs needed
    WORD   e_ss;                        // Initial (relative) SS value
    WORD   e_sp;                        // Initial SP value
    WORD   e_csum;                      // Checksum
    WORD   e_ip;                        // Initial IP value
    WORD   e_cs;                        // Initial (relative) CS value
    WORD   e_lfarlc;                    // File address of relocation table
    WORD   e_ovno;                      // Overlay number
    WORD   e_res[4];                    // Reserved words
    WORD   e_oemid;                     // OEM identifier (for e_oeminfo)
    WORD   e_oeminfo;                   // OEM information; e_oemid specific
    WORD   e_res2[10];                  // Reserved words
    LONG   e_lfanew;                    // File address of new exe header
  )"
  ,IMAGE_FILE_HEADER :="
  (
    WORD    Machine;
    WORD    NumberOfSections;
    DWORD   TimeDateStamp;
    DWORD   PointerToSymbolTable;
    DWORD   NumberOfSymbols;
    WORD    SizeOfOptionalHeader;
    WORD    Characteristics;
  )"
  ,IMAGE_DATA_DIRECTORY :="
  (
    DWORD   VirtualAddress;
    DWORD   Size;
  )"
  ,IMAGE_OPTIONAL_HEADER64:="
  (
    WORD        Magic;
    BYTE        MajorLinkerVersion;
    BYTE        MinorLinkerVersion;
    DWORD       SizeOfCode;
    DWORD       SizeOfInitializedData;
    DWORD       SizeOfUninitializedData;
    DWORD       AddressOfEntryPoint;
    DWORD       BaseOfCode;
    ULONGLONG   ImageBase;
    DWORD       SectionAlignment;
    DWORD       FileAlignment;
    WORD        MajorOperatingSystemVersion;
    WORD        MinorOperatingSystemVersion;
    WORD        MajorImageVersion;
    WORD        MinorImageVersion;
    WORD        MajorSubsystemVersion;
    WORD        MinorSubsystemVersion;
    DWORD       Win32VersionValue;
    DWORD       SizeOfImage;
    DWORD       SizeOfHeaders;
    DWORD       CheckSum;
    WORD        Subsystem;
    WORD        DllCharacteristics;
    ULONGLONG   SizeOfStackReserve;
    ULONGLONG   SizeOfStackCommit;
    ULONGLONG   SizeOfHeapReserve;
    ULONGLONG   SizeOfHeapCommit;
    DWORD       LoaderFlags;
    DWORD       NumberOfRvaAndSizes;
    _BinRun.IMAGE_DATA_DIRECTORY DataDirectory[16]; // IMAGE_NUMBEROF_DIRECTORY_ENTRIES
  )"
  ,IMAGE_OPTIONAL_HEADER32 :="
  (
    WORD    Magic;
    BYTE    MajorLinkerVersion;
    BYTE    MinorLinkerVersion;
    DWORD   SizeOfCode;
    DWORD   SizeOfInitializedData;
    DWORD   SizeOfUninitializedData;
    DWORD   AddressOfEntryPoint;
    DWORD   BaseOfCode;
    DWORD   BaseOfData;
    DWORD   ImageBase;
    DWORD   SectionAlignment;
    DWORD   FileAlignment;
    WORD    MajorOperatingSystemVersion;
    WORD    MinorOperatingSystemVersion;
    WORD    MajorImageVersion;
    WORD    MinorImageVersion;
    WORD    MajorSubsystemVersion;
    WORD    MinorSubsystemVersion;
    DWORD   Win32VersionValue;
    DWORD   SizeOfImage;
    DWORD   SizeOfHeaders;
    DWORD   CheckSum;
    WORD    Subsystem;
    WORD    DllCharacteristics;
    DWORD   SizeOfStackReserve;
    DWORD   SizeOfStackCommit;
    DWORD   SizeOfHeapReserve;
    DWORD   SizeOfHeapCommit;
    DWORD   LoaderFlags;
    DWORD   NumberOfRvaAndSizes;
    _BinRun.IMAGE_DATA_DIRECTORY DataDirectory[16]; //IMAGE_NUMBEROF_DIRECTORY_ENTRIES
  )"
  ,IMAGE_NT_HEADERS:="
  (
    DWORD Signature;
    _BinRun.IMAGE_FILE_HEADER FileHeader;
    _BinRun.IMAGE_OPTIONAL_HEADER" (A_PtrSize=8?64:32) " OptionalHeader;
  )"
  ,IMAGE_NT_HEADERS32:="
  (
    DWORD Signature;
    _BinRun.IMAGE_FILE_HEADER FileHeader;
    _BinRun.IMAGE_OPTIONAL_HEADER32 OptionalHeader;
  )"
  ,IMAGE_NT_HEADERS64:="
  (
    DWORD Signature;
    _BinRun.IMAGE_FILE_HEADER FileHeader;
    _BinRun.IMAGE_OPTIONAL_HEADER64 OptionalHeader;
  )"
  ,IMAGE_SECTION_HEADER:="
  (
    BYTE    Name[8];
    union {
        DWORD   PhysicalAddress;
        DWORD   VirtualSize;
    };
    DWORD   VirtualAddress;
    DWORD   SizeOfRawData;
    DWORD   PointerToRawData;
    DWORD   PointerToRelocations;
    DWORD   PointerToLinenumbers;
    WORD    NumberOfRelocations;
    WORD    NumberOfLinenumbers;
    DWORD   Characteristics;
  )"
  ,FLOATING_SAVE_AREA :="
  (
    DWORD   ControlWord;
    DWORD   StatusWord;
    DWORD   TagWord;
    DWORD   ErrorOffset;
    DWORD   ErrorSelector;
    DWORD   DataOffset;
    DWORD   DataSelector;
    BYTE    RegisterArea[80]; //SIZE_OF_80387_REGISTERS
    DWORD   Cr0NpxState;
  )"
  ,PROCESS_INFORMATION :="
  (
    HANDLE hProcess;
    HANDLE hThread;
    DWORD  dwProcessId;
    DWORD  dwThreadId;
  )"
  ,STARTUPINFO :="
  (
    DWORD  cb;
    LPTSTR lpReserved;
    LPTSTR lpDesktop;
    LPTSTR lpTitle;
    DWORD  dwX;
    DWORD  dwY;
    DWORD  dwXSize;
    DWORD  dwYSize;
    DWORD  dwXCountChars;
    DWORD  dwYCountChars;
    DWORD  dwFillAttribute;
    DWORD  dwFlags;
    WORD   wShowWindow;
    WORD   cbReserved2;
    LPBYTE lpReserved2;
    HANDLE hStdInput;
    HANDLE hStdOutput;
    HANDLE hStdError;
  )"
  ,M128A:="ULONGLONG Low;LONGLONG High"
  ,_XMM_SAVE_AREA32 :="
  (
      WORD ControlWord;
      WORD StatusWord;
      BYTE TagWord;
      BYTE Reserved1;
      WORD ErrorOpcode;
      DWORD ErrorOffset;
      WORD ErrorSelector;
      WORD Reserved2;
      DWORD DataOffset;
      WORD DataSelector;
      WORD Reserved3;
      DWORD MxCsr;
      DWORD MxCsr_Mask;
      _BinRun.M128A FloatRegisters[8];
      _BinRun.M128A XmmRegisters[16];
      BYTE Reserved4[96];
  )"
  ,CONTEXT64:="
  (
      DWORD64 P1Home;
      DWORD64 P2Home;
      DWORD64 P3Home;
      DWORD64 P4Home;
      DWORD64 P5Home;
      DWORD64 P6Home;
      DWORD ContextFlags;
      DWORD MxCsr;
      WORD SegCs;      
      WORD SegDs;      
      WORD SegEs;      
      WORD SegFs;      
      WORD SegGs;      
      WORD SegSs;      
      DWORD EFlags;    
      DWORD64 Dr0;     
      DWORD64 Dr1;     
      DWORD64 Dr2;     
      DWORD64 Dr3;     
      DWORD64 Dr6;     
      DWORD64 Dr7;     
      DWORD64 Rax;     
      DWORD64 Rcx;     
      DWORD64 Rdx;     
      DWORD64 Rbx;     
      DWORD64 Rsp;     
      DWORD64 Rbp;     
      DWORD64 Rsi;     
      DWORD64 Rdi;     
      DWORD64 R8;      
      DWORD64 R9;      
      DWORD64 R10;     
      DWORD64 R11;     
      DWORD64 R12;     
      DWORD64 R13;     
      DWORD64 R14;     
      DWORD64 R15;     
      DWORD64 Rip;     
      union {
          _BinRun._XMM_SAVE_AREA32 FltSave; 
          struct {
              _BinRun.M128A Header[2];     
              _BinRun.M128A Legacy[8];     
              _BinRun.M128A Xmm0;          
              _BinRun.M128A Xmm1;          
              _BinRun.M128A Xmm2;          
              _BinRun.M128A Xmm3;          
              _BinRun.M128A Xmm4;          
              _BinRun.M128A Xmm5;          
              _BinRun.M128A Xmm6;          
              _BinRun.M128A Xmm7;          
              _BinRun.M128A Xmm8;          
              _BinRun.M128A Xmm9;          
              _BinRun.M128A Xmm10;         
              _BinRun.M128A Xmm11;         
              _BinRun.M128A Xmm12;         
              _BinRun.M128A Xmm13;         
              _BinRun.M128A Xmm14;         
              _BinRun.M128A Xmm15;         
          };
      };
      _BinRun.M128A VectorRegister[26];    
      DWORD64 VectorControl;       
      DWORD64 DebugControl;        
      DWORD64 LastBranchToRip;     
      DWORD64 LastBranchFromRip;   
      DWORD64 LastExceptionToRip;  
      DWORD64 LastExceptionFromRip;
  )"
  ,CONTEXT32:="
  (
    DWORD ContextFlags;
    DWORD   Dr0;
    DWORD   Dr1;
    DWORD   Dr2;
    DWORD   Dr3;
    DWORD   Dr6;
    DWORD   Dr7;
    _BinRun.FLOATING_SAVE_AREA FloatSave;
    DWORD   SegGs;
    DWORD   SegFs;
    DWORD   SegEs;
    DWORD   SegDs;
    DWORD   Edi;
    DWORD   Esi;
    DWORD   Ebx;
    DWORD   Edx;
    DWORD   Ecx;
    DWORD   Eax;
    DWORD   Ebp;
    DWORD   Eip;
    DWORD   SegCs;              // MUST BE SANITIZED
    DWORD   EFlags;             // MUST BE SANITIZED
    DWORD   Esp;
    DWORD   SegSs;
    BYTE    ExtendedRegisters[512]; // MAXIMUM_SUPPORTED_EXTENSION
  )"
  __New(pData,cmdLine="",cmdLineScript="",ExeToUse=""){
    static IMAGE_NT_SIGNATURE:=17744,IMAGE_DOS_SIGNATURE:=23117,PAGE_EXECUTE_READWRITE:=64,CREATE_SUSPENDED:=4
    static MEM_COMMIT:=4096,MEM_RESERVE:=8192
    If pData
      If pData is not digit
      {	
        ; Try first reading the file from Resource
        If res := DllCall("FindResource","PTR",lib:=DllCall("GetModuleHandle","PTR",0,"PTR"),"Str",pData,"PTR",10,"PTR")
          VarSetCapacity(data,sz :=DllCall("SizeofResource","PTR",lib,"PTR",res))
          ,DllCall("RtlMoveMemory","PTR",&data,"PTR",DllCall("LockResource","PTR",hres:=DllCall("LoadResource","PTR",lib,"PTR",res,"PTR"),"PTR"),"PTR",sz)
          ,DllCall("FreeResource","PTR",hres)
          ,BinRun_Uncompress(data)
        else ; else try reading file from disc etc...
          FileRead,Data,*c %pData%
        pData:=&Data
      }
    
    If InStr(cmdLine,"`n"){ ; a script was given, first line contains the cmdLine
      PipeName := "\\.\pipe\AHK" A_TickCount
      __PIPE_GA_ := DllCall("CreateNamedPipe","str",PipeName,"UInt",2,"UInt",0,"UInt",255,"UInt",0,"UInt",0,"PTR",0,"PTR",0)
      __PIPE_    := DllCall("CreateNamedPipe","str",PipeName,"UInt",2,"UInt",0,"UInt",255,"UInt",0,"UInt",0,"PTR",0,"PTR",0)
      if (__PIPE_=-1 or __PIPE_GA_=-1)
        Return 0
      Script:=(A_IsUnicode ? chr(0xfeff) : (chr(239) . chr(187) . chr(191))) SubStr(cmdLine,InStr(cmdLine,"`n")+1)
      cmdLine:=Trim(SubStr(cmdLine,1,InStr(cmdLine,"`n")),"`n`r") A_Space PipeName
    }
  
    IDH:=new _Struct(_BinRun.IMAGE_DOS_HEADER,pData)
    if (IDH.e_magic != IMAGE_DOS_SIGNATURE){
      MsgBox ERROR: e_magic not found
      return
    }
    INH := new _Struct(_BinRun.IMAGE_NT_HEADERS,pData + IDH.e_lfanew)
    
    if (INH.Signature != IMAGE_NT_SIGNATURE){
      MsgBox ERROR: Signature not found
      return
    }

    
    If (A_PtrSize=8&&INH.OptionalHeader.magic=267) ; x86 on x64
      pNtHeader:=new _Struct(_BinRun.IMAGE_NT_HEADERS32,pData + IDH.e_lfanew),ctx:=new _Struct(_BinRun.Context32),Force32Bit:=1
      ,ctx.ContextFlags := (A_PtrSize=8?0x100000:0x10000) | 0x2 ;CONTEXT_INTEGER
      ,UsedExe:=ExeToUse?ExeToUse:A_WinDir "\Microsoft.NET\Framework\v2.0.50727\vbc.exe"
    else if (A_PtrSize=4&&INH.OptionalHeader.magic=523) ; x64 on x86 not possible
      Return false
    else 
      pNtHeader:=INH,UsedExe:=ExeToUse?ExeToUse:A_IsCompiled?A_ScriptFullPath:A_AhkPath
      ,ctx:=new _Struct(A_PtrSize=8?_BinRun.Context64:_BinRun.Context32),ctx.ContextFlags := (A_PtrSize=8?0x100000:0x10000) | 0x2 ;CONTEXT_INTEGER
    pi:=new _Struct(_BinRun.PROCESS_INFORMATION)
    si:=new _Struct(_BinRun.STARTUPINFO),si.cb:=sizeof(si)
    if DllCall("CreateProcess","PTR",0,"STR","""" UsedExe """" A_Space cmdLine (cmdLineScript?A_Space cmdLineScript:"")
              ,"PTR",0,"PTR",0,"int",0,"Int",CREATE_SUSPENDED,"PTR",0,"PTR",0,"PTR",si[],"PTR",pi[]){
        if DllCall((Force32Bit?"Wow64":"") "GetThreadContext","PTR",pi.hThread,"PTR", ctx[]){
            pPebImageBase:=ctx[A_PtrSize=8&&!Force32Bit?"Rdx":"Ebx"] + (Force32Bit?4:A_PtrSize)*2
            if DllCall("ReadProcessMemory","PTR",pi.hProcess, "PTR", pPebImageBase,"PTR*", dwImagebase,"PTR", (Force32Bit?4:A_PtrSize),"Uint*",NumberOfBytes){
                DllCall("ntdll\NtUnmapViewOfSection","PTR",pi.hProcess, "PTR",dwImagebase)
                pImagebase := DllCall("VirtualAllocEx","PTR",pi.hProcess, "PTR",pNtHeader.OptionalHeader.ImageBase, "PTR",pNtHeader.OptionalHeader.SizeOfImage,"UInt", MEM_COMMIT|MEM_RESERVE,"UInt", PAGE_EXECUTE_READWRITE,"PTR")
                if (pImagebase)
                {
                    if DllCall("WriteProcessMemory","PTR",pi.hProcess,"PTR",pImagebase,"PTR",pData,"PTR",pNtHeader.OptionalHeader.SizeOfHeaders,"UInt*",NumberOfBytes){
                        pSecHeader :=new _Struct(_BinRun.IMAGE_SECTION_HEADER)
                        pSecHeader[] :=pNtHeader.OptionalHeader[""]+pNtHeader.FileHeader.SizeOfOptionalHeader
                        counter := 0
                        while (++counter < pNtHeader.FileHeader.NumberOfSections+1){
                            DllCall("WriteProcessMemory","PTR",pi.hProcess,"PTR",pImagebase + pSecHeader.VirtualAddress,"PTR",pData + pSecHeader.PointerToRawData,"PTR",pSecHeader.SizeOfRawData,"UInt*", NumberOfBytes)
                            pSecHeader[]:=pSecHeader[]+sizeof(pSecHeader)
                        }
                        if DllCall("WriteProcessMemory","PTR",pi.hProcess,"PTR",pPebImageBase,"PTR",pNtHeader.OptionalHeader.ImageBase[""],"PTR",(Force32Bit?4:A_PtrSize),"UInt*",NumberOfBytes){
                            ctx[A_PtrSize=8&&!Force32Bit?"Rcx":"Eax"] := pImagebase + pNtHeader.OptionalHeader.AddressOfEntryPoint
                            if DllCall((Force32Bit?"Wow64":"") "SetThreadContext","PTR",pi.hThread, "PTR",ctx[]){
                                if DllCall("ResumeThread","PTR",pi.hThread){
                                  if (Script){ ; use pipe to pass script to new executable
                                    DllCall("ConnectNamedPipe","PTR",__PIPE_GA_,"PTR",0)
                                    DllCall("CloseHandle","PTR",__PIPE_GA_)
                                    DllCall("ConnectNamedPipe","PTR",__PIPE_,"PTR",0)
                                    if !DllCall("WriteFile","PTR",__PIPE_,"str",script,"UInt",(StrLen(script)+1)*(A_IsUnicode ? 2 : 1),"UInt*",0,"PTR",0)
                                    Return DllCall("CloseHandle","PTR",__PIPE_),0
                                    DllCall("CloseHandle","PTR",__PIPE_)
                                  }
                                  return pi.dwProcessId
                                }
                            }
                        }
                    }
                }
            }
        }
        DllCall("TerminateProcess","PTR",pi.hProcess,"UInt", 0)
    }
    return FALSE
  }
}
BinRun(pData,cmdLine="",cmdLineScript="",ExeToUse=""){
  return new _BinRun(pData,cmdLine,cmdLineScript,ExeToUse)
}
BinRun_Uncompress( ByRef D ) {  ; Shortcode version of VarZ_Decompress() of VarZ 2.0 wrapper
; VarZ 2.0 by SKAN, 27-Sep-2012. http://www.autohotkey.com/community/viewtopic.php?t=45559
 IfNotEqual, A_Tab, % ID:=NumGet(D,"UInt"), IfNotEqual, ID, 0x5F5A4C,  Return 0, ErrorLevel := -1
 savedHash := NumGet(D,4,"UInt"), TZ := NumGet(D,10,"UInt"), DZ := NumGet(D,14,"UInt")
 DllCall( "shlwapi\HashData", UInt,&D+8, UInt,DZ+10, UIntP,Hash, UInt,4 )
 IfNotEqual, Hash, %savedHash%, Return 0, ErrorLevel := -2
 VarSetCapacity( TD,TZ,0 ), NTSTATUS := DllCall( "ntdll\RtlDecompressBuffer", UShort
 , NumGet(D,8,"UShort"), PTR, &TD, UInt,TZ, PTR,&D+18, UInt,DZ, UIntP,Final, UInt )
 IfNotEqual, NTSTATUS, 0, Return 0, ErrorLevel := NTSTATUS
 VarSetCapacity( D,Final,0 ), DllCall( "RtlMoveMemory", PTR,&D, PTR,&TD, PTR,Final )
 If NumGet(D,"UInt")=0x315F5A4C && NumPut(0x005F5A4C,D,"UInt")
  Return BinRun_Uncompress( D )
Return Final, VarSetCapacity( D,-1 )
}