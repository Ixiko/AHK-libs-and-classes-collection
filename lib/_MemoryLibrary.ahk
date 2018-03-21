/*
SetBatchLines,-1
start:=A_TickCount
Loop 10
  MemLib:=new _MemoryLibrary("X:\AutoHotkey.dll")
  ,MemLib.Free() ;,MemLib:=""  
MsgBox % A_TickCount-start
ExitApp
If (!FileExist("X:\AutoHotkey.dll")){
  MsgBox AutoHotkey.dll was not found
  ExitApp
}
IF !(MemLib:=new _MemoryLibrary("X:\AutoHotkey.dll"))
  MsgBox, AutoHotkey.dll could not be loaded
;Second method by passing the data pointer
FileRead,data,*c X:\AutoHotkey.dll
NewMemLib:=new _MemoryLibrary(&data)

DllCall(MemLib.GetProcAddress("ahktextdll"),"Str","MsgBox Hello from Thread","Str","","Str","") ; start first AutoHotkey.dll thread
DllCall(NewMemLib.GetProcAddress("ahktextdll"),"Str","MsgBox Hello from other Thread in %A_ScriptDir%","Str","","Str","") ; start another AutoHotkey.dll thread
Sleep 1000
MsgBox,0, AutoHotkey.dll started, press OK to terminate.
DllCall(MemLib.GetProcAddress("ahkterminate")),     	MemLib.Free()
DllCall(NewMemLib.GetProcAddress("ahkterminate")),      NewMemLib.Free()
MsgBox AutoHotkey.dll threads terminated and memory freed
*/
#Include <_Struct>
Class _MemoryLibrary {
  static MEMORYMODULE :=(A_PtrSize=8?"
  (LTrim
    _MemoryLibrary.IMAGE_NT_HEADERS64 *hdrs;
  )":"
  (LTrim
    _MemoryLibrary.IMAGE_NT_HEADERS32 *hdrs;
  )") "
  (LTrim

    uchar *cdbs;
    HMODULE *mdls;
    int nummdls;
    int init;
  )"
  static IMAGE_RESOURCE_DIRECTORY_ENTRY := "
  (LTrim
    union {
      DWORD   Name;
      WORD    Id;
    };
    union {
      DWORD   OffsetToData;
    };
  )"

  static IMAGE_RESOURCE_DATA_ENTRY := "
  (LTrim
    DWORD   OffsetToData;
    DWORD   Size;
    DWORD   CodePage;
    DWORD   Reserved;
  )"

  static IMAGE_RESOURCE_DIRECTORY:="
  (LTrim
    DWORD   Characteristics;
    DWORD   TimeDateStamp;
    WORD    MajorVersion;
    WORD    MinorVersion;
    WORD    NumberOfNamedEntries;
    WORD    NumberOfIdEntries;
  )"
  static IMAGE_BASE_RELOCATION :="
  (LTrim
    DWORD   VirtualAddress;
    DWORD   SizeOfBlock;
  )"

  static _ACTCTX := "
  (LTrim
    ULONG   cbSize;
    DWORD   dwFlags;
    LPCWSTR lpSource;
    USHORT  wProcessorArchitecture;
    LANGID  wLangId;
    LPCTSTR lpAssemblyDirectory;
    LPCTSTR lpResourceName;
    LPCTSTR lpApplicationName;
    HMODULE hModule;
  )"

  static IMAGE_IMPORT_DESCRIPTOR :="
  (LTrim
    union {
      DWORD   Characteristics;            // 0 for terminating null import descriptor
      DWORD   OriginalFirstThunk;         // RVA to original unbound IAT (PIMAGE_THUNK_DATA)
    };
    DWORD   TimeDateStamp;                  // 0 if not bound,
                        // -1 if bound, and real date\time stamp
                        //     in IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT (new BIND)
                        // O.W. date/time stamp of DLL bound to (Old BIND)

    DWORD   ForwarderChain;                 // -1 if no forwarders
    DWORD   Name;
    DWORD   FirstThunk;                     // RVA to IAT (if bound this IAT has actual addresses)
  )"

  static IMAGE_DOS_HEADER :="      ; DOS .EXE header
  (LTrim
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

  static IMAGE_FILE_HEADER :="
  (LTrim
    WORD    Machine;
    WORD    NumberOfSections;
    DWORD   TimeDateStamp;
    DWORD   PointerToSymbolTable;
    DWORD   NumberOfSymbols;
    WORD    SizeOfOptionalHeader;
    WORD    Characteristics;
  )"

  static IMAGE_NUMBEROF_DIRECTORY_ENTRIES:=16

  static IMAGE_DATA_DIRECTORY :="
  (LTrim
    DWORD   VirtualAddress;
    DWORD   Size;
  )"

  static IMAGE_OPTIONAL_HEADER64 := "
  (LTrim
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
    _MemoryLibrary.IMAGE_DATA_DIRECTORY DataDirectory[" _MemoryLibrary.IMAGE_NUMBEROF_DIRECTORY_ENTRIES "];
  )"

  static IMAGE_OPTIONAL_HEADER32 := "
  (LTrim
    //
    // Standard fields.
    //

    WORD    Magic;
    BYTE    MajorLinkerVersion;
    BYTE    MinorLinkerVersion;
    DWORD   SizeOfCode;
    DWORD   SizeOfInitializedData;
    DWORD   SizeOfUninitializedData;
    DWORD   AddressOfEntryPoint;
    DWORD   BaseOfCode;
    DWORD   BaseOfData;

    //
    // NT additional fields.
    //

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
    _MemoryLibrary.IMAGE_DATA_DIRECTORY DataDirectory[" _MemoryLibrary.IMAGE_NUMBEROF_DIRECTORY_ENTRIES "];
  )"
  static IMAGE_NT_HEADERS64 := "
  (LTrim
    DWORD Signature;
    _MemoryLibrary.IMAGE_FILE_HEADER FileHeader;
    _MemoryLibrary.IMAGE_OPTIONAL_HEADER64 OptionalHeader;
  )"

  static IMAGE_NT_HEADERS32 := "
  (LTrim
    DWORD Signature;
    _MemoryLibrary.IMAGE_FILE_HEADER FileHeader;
    _MemoryLibrary.IMAGE_OPTIONAL_HEADER32 OptionalHeader;
  )"

  static IMAGE_SECTION_HEADER :="
  (LTrim
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
  static IMAGE_EXPORT_DIRECTORY :="
  (LTrim
    DWORD   Characteristics;
    DWORD   TimeDateStamp;
    WORD    MajorVersion;
    WORD    MinorVersion;
    DWORD   Name;
    DWORD   Base;
    DWORD   NumberOfFunctions;
    DWORD   NumberOfNames;
    DWORD   AddressOfFunctions;     // RVA from base of image
    DWORD   AddressOfNames;         // RVA from base of image
    DWORD   AddressOfNameOrdinals;  // RVA from base of image
  )"
  static IMAGE_IMPORT_BY_NAME :="
  (LTrim
    WORD    Hint;
    BYTE    Name[1];
  )"

  __New(DataPTR){
    static Is64:=A_PtrSize=8?"64":"32",MEM_RESERVE:=0x2000,PAGE_EXECUTE_READWRITE:=0x40,MEM_COMMIT:=4096
    If DataPTR is not digit
    {	
      FileRead,Data,*c %DataPTR%
      DataPTR:=&Data
    }
		dh:=new _Struct(this.IMAGE_DOS_HEADER,DataPTR)
    if (dh.e_magic != IMAGE_DOS_SIGNATURE:=23117){
      MsgBox ERROR: e_magic not found
      return
    }
    oh := new _Struct(this["IMAGE_NT_HEADERS" Is64],DataPTR + dh.e_lfanew)
    if (oh.Signature != IMAGE_NT_SIGNATURE:=17744){
      MsgBox ERROR: Signature not found
      return
    }
    ; reserve memory for image of library
    code := DllCall("VirtualAlloc","PTR",oh.OptionalHeader.ImageBase,"PTR",oh.OptionalHeader.SizeOfImage
            ,"UINT",MEM_RESERVE,"UINT",PAGE_EXECUTE_READWRITE,"PTR")

    if (code = 0) {  ; try to allocate memory at arbitrary position
      code := DllCall("VirtualAlloc","PTR",0,"PTR",oh.OptionalHeader.SizeOfImage
        ,"UINT",MEM_RESERVE,"UINT",PAGE_EXECUTE_READWRITE,"PTR")
      if (code = 0){
        MsgBox ERROR: loading Library
        return
      }
    }
    this.MM := new _Struct(this.MEMORYMODULE,DllCall("HeapAlloc","PTR",DllCall("GetProcessHeap","PTR"),"UINT", 0,"PTR", sizeof(this.MEMORYMODULE),"PTR"))
    ,this.MM.cdbs[""]:=code,this.MM.nummdls := 0,this.MM.Alloc("mdls",4),this.MM.init := 0
    ,DllCall("VirtualAlloc","PTR",code,"PTR",oh.OptionalHeader.SizeOfImage,"UINT",MEM_COMMIT,"UINT",PAGE_EXECUTE_READWRITE,"PTR")
    ; commit memory for headers
    ,hdrs := DllCall("VirtualAlloc","PTR",code,"PTR",dh.e_lfanew + oh.OptionalHeader.SizeOfHeaders,"UINT",MEM_COMMIT,"UINT",PAGE_EXECUTE_READWRITE,"PTR")
    ; copy PE header to code
    ,DllCall("RtlMoveMemory","PTR",hdrs, "PTR",dh[""],"PTR", dh.e_lfanew + oh.OptionalHeader.SizeOfHeaders)
    ,this.MM.hdrs[""] := hdrs + dh.e_lfanew
    ; update position
    ,this.MM.hdrs.OptionalHeader.ImageBase := code
    ; copy sections from DLL file block to new memory location
    ,this.CopySections(DataPTR, oh)
    ; adjust base address of imported data
    ,locationDelta := code - oh.OptionalHeader.ImageBase
    if (locationDelta != 0)
      this.PerformBaseRelocation(locationDelta)
    ; load required dlls and adjust function table of imports
    if (!this.BuildImportTable()) {
        MsgBox ERROR: BuildImportTable failed
        Return
    }
    ; mark memory pages depending on section headers and release
    ; sections that are marked as "discardable"
    this.FinalizeSections()
    ; get entry point of loaded library
    if (this.MM.hdrs.OptionalHeader.AddressOfEntryPoint != 0){
      DllEntry := code + this.MM.hdrs.OptionalHeader.AddressOfEntryPoint
      if (DllEntry = 0) {
        MsgBox ERROR: DllEntry not found
        Return
      }
      ; notify library about attaching to process
      successfull := DllCall(DllEntry,"PTR",code, "UInt",DLL_PROCESS_ATTACH:=1,"UInt", 0,"CHAR")
      if (!successfull){
        MsgBox ERROR attaching process
        Return
      }
      this.MM.init := 1
    }
  }


  GetProcAddress(name){
    cdbs := this.MM.cdbs[""],idx:=-1,i:=0,directory := this.MM.hdrs.OptionalHeader.DataDirectory[ 1 + IMAGE_DIRECTORY_ENTRY_EXPORT:=0]
    if (directory.Size = 0) ; no export table found
      return 0
    exports :=new _Struct(this.IMAGE_EXPORT_DIRECTORY,cdbs + directory.VirtualAddress)
    if (exports.NumberOfNames = 0 || exports.NumberOfFunctions = 0)  ; DLL doesn't export anything
      return 0
    ; search function name in list of exported names
    nameRef := cdbs + exports.AddressOfNames,ordinal := cdbs + exports.AddressOfNameOrdinals
    While (i<exports.NumberOfNames) {
      if (name=StrGet(cdbs + NumGet(nameRef+0,"UInt"),"CP0")) {
        idx := NumGet(ordinal+0,"Short")
        break
      }
      i++, nameRef+=4, ordinal+=2
    }
    if (idx = -1) ; exported symbol not found
      return 0
    if (idx > exports.NumberOfFunctions) ; name <-> ordinal number don't match
      return 0
    ; AddressOfFunctions contains the RVAs to the "real" functions
    return cdbs + NumGet(cdbs + exports.AddressOfFunctions + (idx*4),"UInt")
  }
  Free(){
    i:=0
    if (this.MM.init != 0) { ; notify library about detaching from process
      DllEntry := this.MM.cdbs[""] + this.MM.hdrs.OptionalHeader.AddressOfEntryPoint
      ,DllCall(DllEntry,"Ptr",this.MM.cdbs[""],"UInt", DLL_PROCESS_DETACH:=0, "UInt",0)
      ,this.MM.init := 0
    }
    if (this.MM.nummdls != 0) { ; free previously opened libraries
      Loop % this.MM.nummdls
        if (this.MM.mdls[A_Index] != INVALID_HANDLE_VALUE:=-1)
          DllCall("FreeLibrary","PTR",this.MM.mdls[A_Index])
      this.MM._SetCapacity("mdls",0)
    }
    if (this.MM.cdbs[""] != 0) ;release memory of library
      DllCall("VirtualFree","PTR",this.MM.cdbs[""],"PTR", 0,"UINT", MEM_RELEASE:=32768)
    DllCall("HeapFree","PTR",DllCall("GetProcessHeap","PTR"),"UINT", 0,"PTR", this.MM[""])
  }
  
  ; Private functions
  CopySections(data, oh){
    static PAGE_EXECUTE_READWRITE:=64,MEM_COMMIT:=4096
    cdbs := this.MM.cdbs[""]
    section:=new _Struct(this.IMAGE_SECTION_HEADER,this.MM.hdrs.OptionalHeader[""]+this.MM.hdrs.FileHeader.SizeOfOptionalHeader)
    While ((A_Index-1)<this.MM.hdrs.FileHeader.NumberOfSections){
      if (section.SizeOfRawData = 0) { ; section doesn't contain data in the dll itself, but may define ; uninitialized data
        size := oh.OptionalHeader.SectionAlignment
        if (size > 0) ; section is empty
          dest := DllCall("VirtualAlloc","PTR",cdbs + section.VirtualAddress,"PTR",size,"UINT",MEM_COMMIT,"UINT",PAGE_EXECUTE_READWRITE,"PTR")
          ,section.PhysicalAddress := dest,DllCall("RtlFillMemory","PTR",dest,"UINT", size,"CHAR", 0)
        section[]:=section[""]+sizeof(section)
        continue
      }
      ; commit memory block and copy data from dll
      dest := DllCall("VirtualAlloc","PTR",cdbs + section.VirtualAddress,"PTR",section.SizeOfRawData,"UINT",MEM_COMMIT,"UINT",PAGE_EXECUTE_READWRITE,"PTR")
      ,DllCall("RtlMoveMemory","PTR",dest,"PTR",data + section.PointerToRawData,"PTR", section.SizeOfRawData)
      ,section.PhysicalAddress := dest,section[]:=section[""]+sizeof(section)
    }
  }

  FinalizeSections(){
    static ProtectionFlags := [[[PAGE_NOACCESS:=1, PAGE_WRITECOPY:=8],[PAGE_READONLY:=2, PAGE_EXECUTE_READWRITE:=64]], [[PAGE_EXECUTE:=16, PAGE_EXECUTE_READWRITE:=64],[PAGE_EXECUTE_READ:=32, PAGE_EXECUTE_READWRITE:=64]]]
    i:=0
    section := new _Struct(this.IMAGE_SECTION_HEADER,this.MM.hdrs.OptionalHeader[""] + this.MM.hdrs.FileHeader.SizeOfOptionalHeader)
    ,imageOffset := A_PtrSize=8?(NumGet(this.MM.hdrs.OptionalHeader.ImageBase[""]+4,"UInt") & 0xffffffff)<<32:0
    ; loop through all sections and change access flags
    While (i<this.MM.hdrs.FileHeader.NumberOfSections){
      protect:=0, VarSetCapacity(oldProtect,8), size:=0
      ,executable := (section.Characteristics & IMAGE_SCN_MEM_EXECUTE:=536870912) != 0
      ,readable :=   (section.Characteristics & IMAGE_SCN_MEM_READ:=1073741824) != 0
      ,writeable :=  (section.Characteristics & IMAGE_SCN_MEM_WRITE:=2147483648) != 0
      if (section.Characteristics & IMAGE_SCN_MEM_DISCARDABLE:=33554432) {
        ; section is not needed any more and can safely be freed
        DllCall("VirtualFree","PTR",section.PhysicalAddress | imageOffset, "PTR",section.SizeOfRawData,"UINT", MEM_DECOMMIT:=16384)
        ,i++, section[]:=section[""]+sizeof(section)
        continue
      }
      ; determine protection flags based on characteristics
      protect := ProtectionFlags[executable+1,readable+1,writeable+1]
      if (section.Characteristics & IMAGE_SCN_MEM_NOT_CACHED:=67108864)
        protect |= PAGE_NOCACHE:=512
      ; determine size of region
      size := section.SizeOfRawData
      if (size = 0)
        if (section.Characteristics & IMAGE_SCN_CNT_INITIALIZED_DATA:=64)
          size := this.MM.hdrs.OptionalHeader.SizeOfInitializedData
        else if (section.Characteristics & IMAGE_SCN_CNT_UNINITIALIZED_DATA:=128)
          size := this.MM.hdrs.OptionalHeader.SizeOfUninitializedData
      if (size > 0) ; change memory access flags
        if (DllCall("VirtualProtect","PTR",section.PhysicalAddress | imageOffset,"PTR", size,"UINT", protect,"PTR", &oldProtect) = 0)
          break
      i++, section[]:=section[""]+sizeof(section)
    }
  }
  PerformBaseRelocation(delta){
    cdbs := this.MM.cdbs[""],this.MM.hdrs.OptionalHeader.DataDirectory[idx+1]
    ,directory := this.MM.hdrs.OptionalHeader.DataDirectory[ 1 + IMAGE_DIRECTORY_ENTRY_BASERELOC:=5] ; +1 because _Struct is 1 based
    if (directory.Size > 0) {
      relocation:=new _Struct(this.IMAGE_BASE_RELOCATION,cdbs + directory.VirtualAddress)
      While (relocation.VirtualAddress > 0 ) {
        dest := cdbs + relocation.VirtualAddress
        ,relInfo := relocation[""] + IMAGE_SIZEOF_BASE_RELOCATION:=sizeof(this.IMAGE_BASE_RELOCATION)
        While ((A_Index-1)<((relocation.SizeOfBlock-IMAGE_SIZEOF_BASE_RELOCATION) / 2)){
          type := NumGet(relInfo+0,"UShort") >> 12 ; the upper 4 bits define the type of relocation
          ,offset := NumGet(relInfo+0,"UShort") & 0xfff ; the lower 12 bits define the offset
          If ((type=IMAGE_REL_BASED_HIGHLOW:=3) || (A_PtrSize=8 && type=IMAGE_REL_BASED_DIR64:=10)) ; change complete 32/64 bit address
            patchAddrHL := dest + offset,NumPut(NumGet(patchAddrHL+0,"PTR")+delta,patchAddrHL+0,"PTR")
          relInfo+=2
        }
        relocation[] := relocation[""] + relocation.SizeOfBlock ; advance to next relocation block
      }
    }
  }

  BuildImportTable(){
    result := 1,VarSetCapacity(lpCookie,A_PtrSize,00),cdbs := this.MM.cdbs[""]
    ,directory := this.MM.hdrs.OptionalHeader.DataDirectory[ 1 + IMAGE_DIRECTORY_ENTRY_IMPORT:=1] ; +1 because _Struct is 1 based
    ,resource := this.MM.hdrs.OptionalHeader.DataDirectory[ 1 + IMAGE_DIRECTORY_ENTRY_RESOURCE:=2] ; +1 because _Struct is 1 based
    if (directory.Size > 0) 
    {
      importDesc := new _Struct(this.IMAGE_IMPORT_DESCRIPTOR,cdbs + directory.VirtualAddress)
      ;~ MsgBox % resource.size
      if (resource.Size) ; Following will be used to resolve manifest in module
      {
        resDir := new _Struct(this.IMAGE_RESOURCE_DIRECTORY,cdbs + resource.VirtualAddress)
        ,resDirTemp := new _Struct(this.IMAGE_RESOURCE_DIRECTORY)
        ,resDirEntry := new _Struct(this.IMAGE_RESOURCE_DIRECTORY_ENTRY,resDir[""] + sizeof(this.IMAGE_RESOURCE_DIRECTORY))
        ,resDirEntryTemp := new _Struct(this.IMAGE_RESOURCE_DIRECTORY_ENTRY)
        ,resDataEntry := new _Struct(this.IMAGE_RESOURCE_DATA_ENTRY)
        ,actctx :=new _Struct(this._ACTCTX) ; ACTCTX Structure
        ,actctx.cbSize :=  sizeof(actctx)
        ; Path to temp directory + our temporary file name
        ,VarSetCapacity(buf,1024)
        ,tempPathLength := DllCall("GetTempPath","UINT",256,"PTR", &buf,"UINT")
        ,DllCall("RtlMoveMemory","PTR",(&buf) + tempPathLength*2,"PTR",&_temp_:="AutoHotkey.MemoryModule.temp.manifest","PTR",74)
        ,actctx.lpSource[""]:=&buf
        ; Enumerate Resources
        ,i := 0
        While (i < resDir.NumberOfIdEntries + resDir.NumberOfNamedEntries){
          ; Resolve current entry
          resDirEntry[] := resDir[""] + sizeof(this.IMAGE_RESOURCE_DIRECTORY) + (i*sizeof(this.IMAGE_RESOURCE_DIRECTORY_ENTRY))
          ; If entry is directory and Id is 24 = RT_MANIFEST
          if ((resDirEntry.OffsetToData & 0x80000000) && resDirEntry.Id = 24)
          {
            resDirEntryTemp[] := resDir[""] + (resDirEntry.OffsetToData & 0x7FFFFFFF) + sizeof(this.IMAGE_RESOURCE_DIRECTORY)
            ,resDirTemp[] := resDir[""] + (resDirEntryTemp.OffsetToData & 0x7FFFFFFF)
            ,resDirEntryTemp[] := resDir[""] + (resDirEntryTemp.OffsetToData & 0x7FFFFFFF) + sizeof(this.IMAGE_RESOURCE_DIRECTORY)
            ,resDataEntry[] := resDir[""] + resDirEntryTemp.OffsetToData
            ; Write manifest to temportary file
            ; Using FILE_ATTRIBUTE_TEMPORARY will avoid writing it to disk
            ; It will be deleted after CreateActCtx has been called.
            ,hFile := DllCall("CreateFile,","STR",buf,"UINT",GENERIC_WRITE:=1073741824,"UINT",0,"PTR",0,"UINT",CREATE_ALWAYS:=2,"UINT",FILE_ATTRIBUTE_TEMPORARY:=256,"PTR",0,"PTR")
            if (hFile = INVALID_HANDLE_VALUE:=-1)
              break ; failed to create file, continue and try loading without CreateActCtx
            VarSetCapacity(byteswritten,A_PtrSize,0)
            ,DllCall("WriteFile","PTR",hFile,"PTR",(cdbs + resDataEntry.OffsetToData),"UINT",resDataEntry.Size,"PTR",&byteswritten,"PTR",0)
            ,DllCall("CloseHandle","PTR",hFile)
            if (NumGet(byteswritten,"PTR") = 0)
              break ; failed to write data, continue and try loading
            hActCtx := DllCall("CreateActCtx","PTR",actctx[""],"PTR")
            ; Open file and automatically delete on CloseHandle (FILE_FLAG_DELETE_ON_CLOSE)
            ,hFile := DllCall("CreateFile","STR",buf,"UINT",GENERIC_WRITE:=1073741824,"UINT",FILE_SHARE_DELETE:=4,"PTR",0,"UINT",OPEN_EXISTING:=3,"UINT",FILE_ATTRIBUTE_TEMPORARY:=256|FILE_FLAG_DELETE_ON_CLOSE:=67108864,"PTR",0,"PTR")
            ,DllCall("CloseHandle","PTR",hFile)
            if (hActCtx = INVALID_HANDLE_VALUE:=-1)
              break ; failed to create context, continue and try loading
            DllCall("ActivateActCtx","PTR",hActCtx,"PTR",&lpCookie) ;  Don't care if this fails since we would countinue anyway
            break ; Break since a dll can have only 1 manifest
          }
          i++
        }
      }
      thunkData:=new _Struct(this.IMAGE_IMPORT_BY_NAME)
      While (!DllCall("IsBadReadPtr","PTR",importDesc[""], "PTR", sizeof(this.IMAGE_IMPORT_DESCRIPTOR)) && importDesc.Name){
        if (!(handle := DllCall("LoadLibraryA","PTR",(cdbs + importDesc.Name),"PTR")) && !result := 0)
            break
        If (this.Capacity("mdls")<NewmdlsSize:=(this.MM.nummdls+1)*sizeof("HMODULE")){
          VarSetCapacity(backupmdls,this.MM.nummdls*sizeof("HMODULE"))
          ,DllCall("RtlMoveMemory","PTR",&backupmdls,"PTR",this.MM.mdls[""],"PTR",this.MM.nummdls*sizeof("HMODULE"))
          ,this.MM.Alloc("mdls",NewmdlsSize),DllCall("RtlMoveMemory","PTR",this.MM.mdls[""],"PTR",&backupmdls,"PTR",NewmdlsSize)
        }
        if (this.Capacity("mdls") = 0 && !result:=0)
          break
        this.MM.mdls[++this.MM.nummdls] := handle
        
        if (importDesc.OriginalFirstThunk)
          thunkRef := cdbs + importDesc.OriginalFirstThunk,funcRef := cdbs + importDesc.FirstThunk
        else ; no hint table
          thunkRef := cdbs + importDesc.FirstThunk,funcRef := cdbs + importDesc.FirstThunk
        While NumGet(thunkRef+0,"PTR"){
          if (NumGet(thunkRef+A_PtrSize-1,"UCHAR") & IMAGE_ORDINAL_FLAG_AS_CHAR:=0x80)
            NumPut(DllCall("GetProcAddress","PTR",handle,"PTR", NumGet(thunkRef+0,"PTR") & 0xffff,"PTR"),funcRef+0,"PTR")
          else
            thunkData[] := cdbs + NumGet(thunkRef+0,"PTR"),NumPut(DllCall("GetProcAddress","PTR",handle,"PTR", thunkData.Name[""],"PTR"),funcRef+0,"PTR")
          if (NumGet(funcRef+0,"PTR") = 0 && !result:=0)
            break
          thunkRef+=A_PtrSize,funcRef+=A_PtrSize
        }
        if (!result)
          break
        importDesc[]:=importDesc[""]+sizeof(importDesc)
      }
    }
    if (NumGet(lpCookie,"PTR"))
      DllCall("DeactivateActCtx","UINT",0,"PTR",&lpCookie)
    return result
  }
}