#Include %A_ScriptDir%\..\class_Struct.ahk
id:
{ ; Struct() examples
        
MsgBox Example1
        gosub Example1
MsgBox Example2
        gosub Example2
MsgBox Example3
        gosub Example3
MsgBox Example4
        gosub Example4
MsgBox Example5
        gosub Example5
MsgBox Example6
        gosub Example6
MsgBox Example7
        gosub Example7
MsgBox Example8
        gosub Example8
MsgBox Example9
        gosub Example9
MsgBox Example10
        gosub Example10
}ExitApp
Example1:
{
; Simple user defined structure (Use number for characters, so StrGet/StrSet will be used) 
        ;typedef struct {
        ;  TCHAR    char[2];
        ;  int      code[2];
        ;} ASCIICharacter;
        MyChar := new _Struct("Char char[2],int code[2]") ;create structure, type for code could be omited
        MyChar.char.1:="A"
        MyChar.char.2:="B"
        MyChar.code.1 := 64
        MyChar.code.2 := 65
        MsgBox % MyChar.char.1 " = " MyChar.code.1 "`n" MyChar.char.2 " = " MyChar.code.2
}return
Example2:
{
; Simple array of 26 characters
        ;~ MsgBox % sizeof(tchar)
        String:=new _Struct("TCHAR char[26]")
        Loop 26
           string["char"][A_Index]:=Chr(A_Index+64)
        Loop 3
           MsgBox % String["char"][A_Index*2] ;show some characters
        MsgBox % StrGet(string[],26) ;get complete string
}return
Example3:
{
; Array of structures
        user:="LPTSTR Id, LPTSTR Name"
        users := new _Struct("user[2]") ; array of structs
        MsgBox % users.Size()
        VarSetCapacity(mem1,1000)
        users.1.id[""]:=&mem1
        users.1.name[""]:=(&mem1)+200
        users.2.id[""]:=(&mem1)+400
        users.2.name[""]:=(&mem1)+600
        users.1.Id := "Id1" ,   users.1.Name := "Name 1"
        users.2.Id := "Id2",   users.2.Name := "Name 2"
        MsgBox % users.1.Id " " users.1.Name "`n" users.2.Id " " users.2.Name
}return
Example4:
{
; Vector example
        Vector:="a,b,c,d"
        v:=new _Struct("Vector[2]") ;create an array of Vertors
        MsgBox % IsObject(v)
        MsgBox % sizeof("Vector[2]") "-" sizeof(v)
        v.1.a:=1 ;set some keys
        v.2.c:=10 ;set some keys
        MsgBox % v.1.a "`n" v.2.c ;show values
        
        VarSetCapacity(newmem,sizeof(v)) ;resevere some memory for new structure
        v[]:=&newmem ;set new memory address
        MsgBox % v.1.a "`n" v.2.c ;show new structure
        v.1.a:=1
        v.2.c:=10
        MsgBox % v.1.a "`n" v.2.c ;now values are filled
}return
Example5:
{
; RECT example
        ;Example using RECT structure to move a window
        Gui,+LastFound
        hwnd:=WinExist()                         ;get window handle
        _RECT:="left,top,right,bottom"
        RC:=new _Struct(_RECT)                      ;create structure
        Gui,Add,Text,,Press Escape to continue
        Gui,Show,w200 h100                      ;show window
        DllCall("GetWindowRect","Uint",hwnd,"Uint",rc[]) ;get window position
        rc.right  := rc.right - rc.left         ;Set rc.right to be the width
        rc.bottom := rc.bottom - rc.top         ;Set rc.bottom to be the height
        While DllCall("GetCursorPos","Uint",rc[])
              && DllCall("MoveWindow","Uint",hwnd
                          ,"int",rc.left,"int",rc.top,"int",rc.right,"int",rc.bottom,"Int",1)
           If GetKeyState("Escape","P")
                break
        Gui,Destroy
        rc:=""
}return
Example6:
{
; FindFirstFile && FindNextFile && FileTimeToSystemTime
        _FILETIME := "dwLowDateTime,dwHighDateTime"
        _SYSTEMTIME := "WORD wYear,WORD wMonth,WORD wDayOfWeek,WORD wDay,WORD wHour,WORD wMinute,WORD wSecond,WORD Milliseconds"
        _WIN32_FIND_DATA := "dwFileAttributes,_FILETIME ftCreationTime,_FILETIME ftLastAccessTime,_FILETIME ftLastWriteTime,UInt nFileSizeHigh,nFileSizeLow,dwReserved0,dwReserved1,TCHAR cFileName[260],TCHAR cAlternateFileName[14]"

        file:=new _Struct("_WIN32_FIND_DATA[2]")
        time:=new _Struct("_SYSTEMTIME")
        ;~ MsgBox % IsObject(time)
        ;~ MsgBox % IsObject(file) "-" IsObject(time) "-" file[] "-" file.1[]
        DllCall("FindFirstFile","Str",A_ScriptFullPath,"Uint",file.1[""])
        DllCall("FindFirstFile","Str",A_AhkPath,"UInt",file.2[""])
        MsgBox % StrGet(file.1.cFileName[""])
        MsgBox % "A_ScriptFullPath:`t" StrGet(file.1.cFileName[""]) "`t" StrGet(file.1.cAlternateFileName[""]) "`nA_AhkPath:`t" StrGet(file.2.cFileName[""]) "`t" StrGet(file.2.cAlternateFileName[""])

        handle:=DllCall("FindFirstFile","Str","C:\*","Uint",file.2[""])
        Loop {
           If !DllCall("FindNextFile","Uint",handle,"Uint",file.2[""])
              break
           DllCall("FileTimeToSystemTime","Uint",file.2.ftLastWriteTime[""],"Uint",time[""])
           ToolTip % StrGet(file.2.cFileName[""]) "`n" StrGet(file.2.cAlternateFileName[""]) "`n" file.2.nFileSizeHigh " - " file.2.nFileSizeLow
                 . "`n" time.wYear . "-" time.wMonth . "-" time.wDay
                 . "`n" time.wDayOfWeek
                 . "`n" time.wHour . ":" time.wMinute   . ":" time.wSecond . ":" time.Milliseconds
           Sleep, 200
        }
        ToolTip
        DllCall("FindClose","Uint",handle)
}return
Example7:
{
; Predefinition of structures
        MyStruct:=new _Struct("a,b,c,d")
        MyStruct.a:=1
        MsgBox % MyStruct.a

; C/C++ like syntax 
        NewStruct:="
        (
           TCHAR char[11];   // Array of 11 characters
           TCHAR char2[11];   // Another array of 11 characters
           LPTSTR string;    // String 
           Int integer;      // Integer
           PTR pointer;      // Pointer
        )"

        MyStruct:=new _Struct(NewStruct)
        VarSetCapacity(string,100)
        MyStruct.string[""] := &string
        MyStruct.char.1:="A" ;set first char
        MyStruct.char2.1:="ABC" ;here only first characters will be writter to the array char2
        MyStruct.string := "New String"
        MyStruct.integer := 100
        MyStruct.pointer := &MyStruct

        MsgBox % MyStruct.char.1 "`n"
              . StrGet(MyStruct.char2[""]) "`n"
              . MyStruct.String "`n"
              . MyStruct.integer "`n"
              . MyStruct.pointer "`n"
}return
Example8:
{
;Pointer example 
        ;Create a variable containing a string
        var:="AutoHotKey"
        MsgBox % sizeof("*UInt p")
        ;Create a pointer that will point to the variable/string
        VarSetCapacity(v,A_PtrSize),NumPut(&var,v,"PTR")
        s:=new _Struct("*Uint p",&v)
        MsgBox % s.p[""] "-" s[]
        MsgBox % StrGet(s.p["",""])

        ;assign another pointer
        anothervar:="AutoHotkey_L"
        s.p[""]:=&anothervar
        MsgBox % StrGet(s.p["",""])

        ;Using LPTSTR you can assign a string directly
        VarSetCapacity(string,100)
        s:=new _Struct("LPTSTR p")
        s.p[""]:=&string
        s.p:="String"
        MsgBox % s.p
        s.p[""]:=&var
        MsgBox % s.p
}return
Example9:
{
; PROCESSENTRY32
        MAX_PATH:=260
        _PROCESSENTRY32:="
        (Q
          DWORD     dwSize;
          DWORD     cntUsage;
          DWORD     th32ProcessID;
          ULONG_PTR th32DefaultHeapID;
          DWORD     th32ModuleID;
          DWORD     cntThreads;
          DWORD     th32ParentProcessID;
          LONG      pcPriClassBase;
          DWORD     dwFlags;
          TCHAR     szExeFile[" MAX_PATH "];
        )"
        VarSetCapacity(string,260)
        pEntry:= new _Struct(_PROCESSENTRY32)
        pEntry.dwSize := sizeof(_PROCESSENTRY32)
        hSnapshot:=DllCall("CreateToolhelp32Snapshot","UInt",TH32CS_SNAPALL:=0x0000001F,"PTR",0)
        DllCall("Process32First" (A_IsUnicode?"W":""),"PTR",hSnapshot,"PTR",pEntry[""])
        While % (A_Index=1 || DllCall("Process32Next" (A_IsUnicode?"W":""),"PTR",hSnapshot,"PTR",pEntry[""])) {
          ToolTip % pEntry.cntUsage "`n" pEntry.th32ProcessID
          . "`n" pEntry.th32DefaultHeapID "`n" pEntry.th32ModuleID
          . "`n" pEntry.cntThreads "`n" pEntry.th32ParentProcessID
          . "`n" pEntry.pcPriClassBase "`n" pEntry.dwFlags "`n" StrGet(pEntry.szExeFile[""])
          Sleep, 200
        }
        ToolTip
}return
Example10:
{
; MODULEENTRY32 
        MAX_PATH:=260
        MAX_MODULE_NAME32:=255
        _MODULEENTRY32:="
        (Q
          DWORD   dwSize;
          DWORD   th32ModuleID;
          DWORD   th32ProcessID;
          DWORD   GlblcntUsage;
          DWORD   ProccntUsage;
          BYTE    *modBaseAddr;
          DWORD   modBaseSize;
          HMODULE hModule;
          TCHAR   szModule[" MAX_MODULE_NAME32 + 1 "];
          TCHAR   szExePath[" MAX_PATH "];
        )"

        ListProcessModules(DllCall("GetCurrentProcessId"))
Return

ListProcessModules(dwPID)
{
  global _Struct
  static TH32CS_SNAPMODULE:=0x00000008,INVALID_HANDLE_VALUE:=-1
  hModuleSnap := new _Struct("HANDLE")
  me32 := new _Struct("_MODULEENTRY32")

  ;  Take a snapshot of all modules in the specified process.
  hModuleSnap := DllCall("CreateToolhelp32Snapshot","UInt", TH32CS_SNAPMODULE,"PTR", dwPID )
  if( hModuleSnap = INVALID_HANDLE_VALUE )
  {
    MsgBox % "CreateToolhelp32Snapshot (of modules)"
    return FALSE
  }

  ; Set the size of the structure before using it.
  me32.dwSize := sizeof("_MODULEENTRY32")

  ;  Retrieve information about the first module,
  ;  and exit if unsuccessful

  if( !DllCall("Module32First" (A_IsUnicode?"W":""),"PTR", hModuleSnap,"PTR", me32[""] ) )
  {
    MsgBox % "Module32First" ;  // Show cause of failure
    DllCall("CloseHandle","PTR", hModuleSnap ) ;     // Must clean up the snapshot object!
    return  FALSE
  }

  ;//  Now walk the module list of the process,
  ;//  and display information about each module
  while(A_Index=1 || DllCall("Module32Next" (A_IsUnicode?"W":""),"PTR",hModuleSnap,"PTR", me32[""] ) )
  {
    ToolTip % "`tMODULE NAME`t=`t"       StrGet(me32.szModule[""])
            . "`n`texecutable`t=`t"    StrGet(me32.szExePath[""])
            . "`n`tprocess ID`t=`t"    me32.th32ProcessID
            . "`n`tref count (g)`t=`t"   me32.GlblcntUsage
            . "`n`tref count (p)`t=`t" me32.ProccntUsage
            . "`n`tbase address`t=`t"    me32.modBaseAddr[""]
            . "`n`tbase size`t=`t"     me32.modBaseSize
    Sleep, 1000
  }

  ;//  Do not forget to clean up the snapshot object.
  DllCall("CloseHandle","PTR",hModuleSnap)
  return TRUE
}

}





