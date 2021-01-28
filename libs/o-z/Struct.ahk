;: Title: Struct.ahk by HotKeyIt
;

; Function: Struct
; Description:
;      Struct is based on AHK_L Objects and supports both, ANSI and UNICODE version, so to use it you will require <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>Lexikos AutoHotkey_L.exe</a> or other versions based on it that supports objects.<br><br>Struct is used to create new structure. You can create predefined structures that are saved as static variables inside the function or pass you own structure definition.<br>Struct.ahk supportes structure in structure as well as Arrays of structures and Vectors.<br>Visit <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>Struct.ahk at AutoHotkey</a> forum, any feedback is welcome.
; Syntax: Struct(Structure_Definition,Address)
; Parameters:
;	   General Design - Struct function will create Object(s) that will manage fields of structure(s), for example RC := Struct("RECT") creates a RECT structure with fields left,top,right,bottom. To pass structure its pointer to a function or DllCall or SendMessage you will need to use RC[""] or RC[].<br><br>To access fields you can use usual Object syntax: RC.left, RC.right ...<br>To set a field of the structure use RC.top := 100.
;	   Field types - All AutoHotkey and Windows Data Types are supported<br>AutoHotkey Data Types<br> Int, Uint, Int64, UInt64, Char, UChar, Short, UShort, Fload and Double.<br>Windows Data Types<br> - note, TCHAR and CHAR return actual character rather than the value, where UCHAR will return the value of character: Asc(char)<br>ATOM,BOOL,BOOLEAN,BYTE,CHAR,COLORREF,DWORD,DWORDLONG,DWORD_PTR,<br>DWORD32,DWORD64,FLOAT,HACCEL,HALF_PTR,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,<br>HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,<br>HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRESULT,HRGN,HRSRC,HSZ,HWINSTA,HWND,INT,<br>INT_PTR,INT32,INT64,LANGID,LCID,LCTYPE,LGRPID,LONG,LONGLONG,LONG_PTR,LONG32,LONG64,LPARAM,LPBOOL,<br>LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,<br>LPWORD,LPWSTR,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,<br>PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,<br>PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_64,POINTER_SIGNED,POINTER_UNSIGNED,PSHORT,PSIZE_T,<br>PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,<br>PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,<br>SHORT,SIZE_T,SSIZE_T,TBYTE,TCHAR,UCHAR,UHALF_PTR,UINT,UINT_PTR,UINT32,UINT64,ULONG,ULONGLONG,<br>ULONG_PTR,ULONG32,ULONG64,USHORT,USN,WCHAR,WORD,WPARAM
;	   <b>Mode</b> - <b>Description</b>
;	   User defined - To create a user defined structure you will need to pass a string of predefined types and field names.<br>Default type is UInt, so for example for a RECT structure type can be omited: <b>"left,top,right,left"</b>, which is the same as <b>"Uint left,Uint top,Uint right,Uint bottom"</b><br><br>You can also use Structure contstructor that can be obtained by calling Struct("")<br>Using constructor you can define structures very similar to C#/C++ syntax, see example how to use.
;	   Global - Global variables can be used to save structures, easily pass name of that variable as first parameter, e.g. Struct("MyStruct") where MyStruct must be a global variable with structure definition.
;	   Static - Struct() function holds some example structure definitions like RECT or POINT, to create such a structure you will need to pass a string containing the name of desired structure, same as for Global mode, for example p:=Struct("POINT").<br>You can also define static structures dynamically, therefore enter Name of structure followed by : before structure definition, e.g. Struct("MyStruct:length,width").
;	   Array - To create an array of structures include a digit in the end of your string enclosed in squared brackets.<br>For example "RECT[2]" would create an array of 2 structures.<br>This feature can also be used for user defined arrays, for example "Int age,TCHAR name[10]".
;	   Union - Using {} you can create union, for example: <br>AHKVar:="{Int64 ContentsInt64,Double ContentsDouble,object},...
;	   Pointer - To create a pointer you can use *, for example: CHR:="char *str" will hold a pointer to a character. Same way you can have a structure in structure so you can call for example Label.NextLabel.NextLabel.JumpToLine
;	   <b>Other</b> - <b>Special call modes</b>
;	   Struct:=Struct(StructObject,<b>pointer</b>) - Pass a pointer as second parameter to occupy existing strucure.
;	   <b>size</b>:=Struct(StructObject) - Pass a structure prevoiusly create with Struct() to receive the size of your sructure.
;	   <b>ConstructorObj</b><br>:=Struct("") - get contstructor object that can be used to define and create structures
; Return Value:
;     In create mode Structure Object is returned, else you can receive the size of your structure
; Remarks:
;		Sctruct_Count() and Struct_getVar() are used internally by Struct. , Struct_Get() and Struct_Put() are meta functions used to set and get fields of structure, these do not need to be called by the user.<br><br><b>NOTE!!! accessing a field that does not exist will crash your application, these errors are not catched for performance reasons.</b>
; Related:
; Example:
;		file:Struct_Example.ahk
;
Struct(_def,_obj="",_name="",_offset=0,_TypeArray=0,_Encoding=0){
	static ;static mode, so structure definitions can be declared statically if waited
  ;argument size
  static PTR:=A_PtrSize,UPTR:=PTR,SHORT:=2,USHORT:=SHORT,INT:=4,UINT:=INT,INT64:=8,UINT64:=INT64,DOUBLE:=INT64,FLOAT:=INT,CHAR:=1,UCHAR:=CHAR
  ;base for user structures
  static _Struct:=Object("base",Object("__Get","Struct","__Set","Struct")) ;struct will be global, used to create structures
  ;struct constructor object
  static _base:=Object("__Get","Struct_Get","__Set","Struct_Put"),data_types:=Object("SHORT",2,"USHORT",2,"INT",4,"UINT",4,"INT64",8,"UINT64",8,"DOUBLE",8,"FLOAT",4,"CHAR",1,"UCHAR",1)
  ;Windows Data Types
  static VOID="PTR",TBYTE=A_IsUnicode?"USHORT":"UCHAR",TCHAR=A_IsUnicode?"USHORT":"UCHAR",HALF_PTR=A_PtrSize=8?"INT":"SHORT",UHALF_PTR=A_PtrSize=8?"UINT":"USHORT"
  			,INT32="Int",LONG="Int",LONG32="Int",LONGLONG="Int64",LONG64="Int64",USN="Int64",HFILE="PTR",HRESULT="PTR",INT_PTR="PTR",LONG_PTR="PTR",POINTER_64="PTR",POINTER_SIGNED="PTR"
  			,BOOL="Int",INT32="Int",LONG="Int",LONG32="Int",LONGLONG="Int64",LONG64="Int64",USN="Int64",HFILE="PTR",HRESULT="PTR",INT_PTR="PTR",LONG_PTR="PTR",POINTER_64="PTR",POINTER_SIGNED="PTR"
  			,SSIZE_T="PTR",WPARAM="PTR",BOOLEAN="UCHAR",BYTE="UCHAR",COLORREF="UInt",DWORD="UInt",DWORD32="UInt",LCID="UInt",LCTYPE="UInt",LGRPID="UInt",LRESULT="UInt",PBOOL="UInt",PBOOLEAN="UInt"
  			,PBYTE="UInt",PCHAR="UInt",PCSTR="UInt",PCTSTR="UInt",PCWSTR="UInt",PDWORD="UInt",PDWORDLONG="UInt",PDWORD_PTR="UInt",PDWORD32="UInt",PDWORD64="UInt",PFLOAT="UInt",PHALF_PTR="UInt",UINT32="UInt"
  			,ULONG="UInt",ULONG32="UInt",DWORDLONG="UInt64",DWORD64="UInt64",ULONGLONG="UInt64",ULONG64="UInt64",DWORD_PTR="UPTR",HACCEL="UPTR",HANDLE="UPTR",HBITMAP="UPTR",HBRUSH="UPTR"
  			,HCOLORSPACE="UPTR",HCONV="UPTR",HCONVLIST="UPTR",HCURSOR="UPTR",HDC="UPTR",HDDEDATA="UPTR",HDESK="UPTR",HDROP="UPTR",HDWP="UPTR",HENHMETAFILE="UPTR",HFONT="UPTR",HGDIOBJ="UPTR",HGLOBAL="UPTR"
  			,HHOOK="UPTR",HICON="UPTR",HINSTANCE="UPTR",HKEY="UPTR",HKL="UPTR",HLOCAL="UPTR",HMENU="UPTR",HMETAFILE="UPTR",HMODULE="UPTR",HMONITOR="UPTR",HPALETTE="UPTR",HPEN="UPTR",HRGN="UPTR",HRSRC="UPTR"
  			,HSZ="UPTR",HWINSTA="UPTR",HWND="UPTR",LPARAM="UPTR",LPBOOL="UPTR",LPBYTE="UPTR",LPCOLORREF="UPTR",LPCSTR="UPTR",LPCTSTR="UPTR",LPCVOID="UPTR",LPCWSTR="UPTR",LPDWORD="UPTR",LPHANDLE="UPTR",LPINT="UPTR"
  			,LPLONG="UPTR",LPSTR="UPTR",LPTSTR="UPTR",LPVOID="UPTR",LPWORD="UPTR",LPWSTR="UPTR",PHANDLE="UPTR",PHKEY="UPTR",PINT="UPTR",PINT_PTR="UPTR",PINT32="UPTR",PINT64="UPTR",PLCID="UPTR",PLONG="UPTR",PLONGLONG="UPTR"
  			,PLONG_PTR="UPTR",PLONG32="UPTR",PLONG64="UPTR",POINTER_32="UPTR",POINTER_UNSIGNED="UPTR",PSHORT="UPTR",PSIZE_T="UPTR",PSSIZE_T="UPTR",PSTR="UPTR",PTBYTE="UPTR",PTCHAR="UPTR",PTSTR="UPTR",PUCHAR="UPTR",PUHALF_PTR="UPTR"
  			,PUINT="UPTR",PUINT_PTR="UPTR",PUINT32="UPTR",PUINT64="UPTR",PULONG="UPTR",PULONGLONG="UPTR",PULONG_PTR="UPTR",PULONG32="UPTR",PULONG64="UPTR",PUSHORT="UPTR",PVOID="UPTR",PWCHAR="UPTR",PWORD="UPTR",PWSTR="UPTR"
  			,SC_HANDLE="UPTR",SC_LOCK="UPTR",SERVICE_STATUS_HANDLE="UPTR",SIZE_T="UPTR",UINT_PTR="UPTR",ULONG_PTR="UPTR",ATOM="Ushort",LANGID="Ushort",WCHAR="Ushort",WORD="Ushort"
  ;Join DataTypes
  static _AHK:="UChar,Short,UShort,Int,UInt,Float,Double,Int64,UInt64,UPTR,PTR,"
        ,_WIN:="BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCVOID,LPDWORD,LPHANDLE,LPINT,LPLONG,LPVOID,LPWORD,,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE"
        ,_WINS:="LPSTR,LPCSTR"
        ,_WINT:="LPTSTR,LPCTSTR"
        ,_WINW:="LPWSTR,LPCWSTR"
        ,_WINC:="CHAR,TCHAR"
  ;Common structures
	static RECT="left,top,right,bottom",POINT="x,y",POINTS="Short x,Short y",FILETIME="dwLowDateTime,dwHighDateTime"
  			,SYSTEMTIME="WORD wYear,WORD wMonth,WORD wDayOfWeek,WORD wDay,WORD wHour,WORD wMinute,WORD wSecond,WORD Milliseconds"
  			,WIN32_FIND_DATA="dwFileAttributes,FILETIME ftCreationTime,FILETIME ftLastAccessTime,FILETIME ftLastWriteTime,nFileSizeHigh,nFileSizeLow,dwReserved0,dwReserved1,TCHAR cFileName[260],TCHAR cAlternateFileName[14]"
  ;AHK structures
  static AHKLine="UChar ActionType,UChar Argc,UShort FileIndex,LineNumber,Arg,Attribute,*AHKLine PrevLine,*AHKLine NextLine,RelatedLine,ParentLine"
  			,AHKLabel="LPTSTR name,*AHKLine JumpToLine,*AHKLabel PrevLabel,*AHKLabel NextLabel"
  			,AHKArgStruct="UChar type,UChar is_expression,UShort length,text,{*AHKDerefType deref,*AHKVar var},*AHKExprTokenType postfix"
  			,AHKDerefType="marker,{*AHKVar var,*AHKFunc func},Char is_function,UChar param_count,UShort length"
  			,AHKExprTokenType="{Int64 value_int64,Double value_double,*AHKVar var,marker},buf,Int symbol,*AHKExprTokenType circuit_token"
  			,AHKFuncParam="*AHKVar var,UShort is_byref,UShort default_type,{default_str,Int64 default_int64,Double default_double}"
  			,AHKRCCallbackFunc="na1,na2,na3,callfuncptr,na4,Short na5,UChar actual_param_count,UChar create_new_thread,event_info,*AHKFunc func"
  			,AHKFunc="PTR vTable,PTR name,{PTR BIF,*AHKLine JumpToLine},*AHKFuncParam Param,Int ParamCount,Int MinParams,*AHKVar var,*AHKVar LazyVar,Int VarCount,Int VarCountMax,Int LazyVarCount,Int Instances,*AHKFunc NextFunc,Char DefaultVarType,Char IsBuiltIn"
  			,AHKVar="{Int64 ContentsInt64,Double ContentsDouble,object},Contents,{Length,AliasFor},{Capacity,BIV},UChar HowAllocated,UChar Attrib,Char IsLocal,UChar Type,Name"
	;local variables
  local _k,_v,_enum,_size,_subdef,_split,_split1,_split2,_split3,_StructObj,_union,_unionoff,_unionoffset=0,_pointer,_suboffset,_field,_array
  If IsObject(_def){ ;used as structure creator + get size of structure + internal recrusive calls
		If (_name=1){ ;correct offset for structures in structures
            for _k,_v in _def
				If IsObject(_v)
					_v[""]:=(_def[""])+_v[""],Struct(_v,0,1)
		} else If (_name=2){ ;set pointer back to offset
      for _k,_v in _def
				If IsObject(_v)
          Struct(_v,0,2),_v[""]:=_v[""]-_def[""]
    } else if (_obj && _name=""){ ;constructor create structure
      Return Struct(_obj)
    } else if (_obj && _name){ ;constructor define structure
        _split2:=_obj,_split1:=_name
      	Loop,Parse,_split1,`n,`r`t%A_Space%
      	{
          _field=
          Loop,parse,A_LoopField,`,`;,`t%A_Space%
          {
            If RegExMatch(A_LoopField,"^\s*//") ;break on comments
              break
            If (A_LoopField){
              If (!_field && _split3:=RegExMatch(A_LoopField,"\w\s+\w"))
                _field:=RegExReplace(A_LoopField,"\w\K\s+.*$")
              If Instr(A_LoopField,"{")
                _union++
              else If InStr(A_LoopField,"}")
                _split.="}"
              else {
                If _union
                  Loop % _union
                    _array.="{"
                _split.=(_split ? "," : "") _array ((_split3 && A_Index!=1)?(_field " "):"") RegExReplace(A_LoopField,"\s+"," ")
                _array:="",_union:=""
              }
            }
          }
        }
        %_split2%:=_split
        Return
    } else ;Struct_GetSize used to count size of Structure
			Return Struct_GetSize(_def) ;had to be excluded from Struct() since it needs to use local mode
    Return
	} else if _def= ;return structure constructor object
    return _struct
  If InStr(_def,":") && RegExMatch(_subdef:=SubStr(_def,1,InStr(_def,":")-1),"^\w+$") ;define static structure
		StringTrimLeft,_def,_def,% InStr(_def,":"),%_subdef%:=SubStr(_def,InStr(_def,":")+1)
  _StructObj:=IsObject(_obj) ? _obj : Object() ;create object for new structure
  If (IsObject(_obj) && _name) ;create new object and use it in this function
		_StructObj[_name,""]:=_offset,_StructObj:=_StructObj[_name]
  _subdef:=((RegExMatch(_def,"^\w+$") && (%_def%)) ? (%_def%) : _def) ;resolve definition
  If RegExMatch(_subdef,"^(\w+)\s*\[(\d+)\]$",_split){ ;array
    If _split1 in Short,UShort,Int,UInt,Float,Double,Int64,UInt64,UPTR,PTR,BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCVOID,LPDWORD,LPHANDLE,LPINT,LPLONG,LPVOID,LPWORD,,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE,
      _split3 := 1 ;NumPut/NumGet
    else if _split1 in TCHAR,Char,UChar
      _split3 := 2,_Encoding := (_split1="TCHAR" ? (A_IsUnicode ? "UTF-16" : "CP0") : "CP0") ;Asc/Chr
    else if _split1 in LPCSTR,LPCTSTR,LPCWSTR,LPSTR,LPTSTR,LPWSTR
    {
      _split3 := 3 ;StrGet/StrPut
      if _split1 in LPTSTR,LPCTSTR
        _Encoding := A_IsUnicode ? "UTF-16" : "CP0"
      else if _split1 in LPWSTR,LPCWSTR
        _Encoding := "UTF-16"
      else
        _Encoding := "CP0"
    }
    if _split1 in BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,LPWORD,LPWSTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE,TCHAR
      _split1:=%_split1%
    Loop % _split2
        _field.=(_field ? "," : "") _split1 " " A_Index
    Return Struct(_field,_obj,"",0,_split3,_Encoding)
  }
  _offset:=0
  Loop,Parse,_subdef,`,,%A_Space%
  {
    If (Asc(A_LoopField)=123 && _union && _unionoff:=1){
      StringTrimLeft,_field,A_LoopField,1
    } else if (Asc(A_LoopField)=123 && (_union:=1)){
      StringTrimLeft,_field,A_LoopField,1
    } else if (SubStr(A_LoopField,0)="}"){
      StringTrimRight,_field,A_LoopField,% SubStr(A_LoopField,-1)="}}"?2:1
    } else
      _field:=A_LoopField
    If (Asc(_field)=123 && _unionoff:=1){
      StringTrimLeft,_field,_field,1
    }
    _field :=RegExReplace(_field,"\}+$")
    If ( InStr(_field,"*") && _pointer:=1)
      _field:=RegExReplace(_field,"(\s)?\*(\s)?","$1$2")
    else _pointer:=0
    _split1:="",_split2:="",_split3:="" ; empty before filling in RegExMatch
    RegExMatch(_field,"^([^\s]+)\s*([A-Za-z0-9_]+)?\[?(\d+)?\]?$",_split)
    If (!_pointer && RegExMatch(_split2,"^[A-Za-z0-9_]+$") && %_split1%){
      If _split1 not in Char,UChar,Short,UShort,Int,UInt,Float,Double,Int64,UInt64,UPTR,PTR,BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,LPWORD,LPWSTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE,TCHAR
      {
        If _split3{
          _StructObj[_split2 ? _split2 : _split1,""]:=_offset
          Loop % _split3
          {
            _size:=Struct(_split1,_StructObj[_split2 ? _split2 : _split1],A_Index,_offset) ;create structure in structure
            If (_union)
              _union:=_union<(_size-_offset)?_size-_offset:_union,_unionoffset:=(_unionoff?(_unionoffset+(_size-_offset)):0)
            else
              _offset+=_size
          }
          _StructObj[_split2 ? _split2 : _split1].base:=_base
          Continue
        } else {
          _size:=Struct(_split1,_StructObj,_split2 ? _split2 : _split1,_offset) ;create structure in structure
          If (_union)
              _union:=_union<(_size-_offset)?_size-_offset:_union,_unionoffset:=(_unionoff?(_unionoffset+(_size-_offset)):0)
          else
            _offset+=_size
          Continue
        }
      }
    }
    If (!_split3 && !pointer){ ;not an array so set operator
      If _TypeArray {
        _StructObj["`f" (_split2 ? _split2 : _split1)] := _TypeArray ;NumPut/NumGet
        , _StructObj["`v" (_split2 ? _split2 : _split1)] := _Encoding
      } else If !_split2 ;no type given, default to Uint
        _StructObj["`f" _split1] := 1 ;NumPut/NumGet
        , _StructObj["`v" _split1] := 0
      else If _split1 in UChar,Short,UShort,Int,UInt,Float,Double,Int64,UInt64,UPTR,PTR,BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCVOID,LPDWORD,LPHANDLE,LPINT,LPLONG,LPVOID,LPWORD,,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE
        _StructObj["`f" _split2] := 1 ;NumPut/NumGet
        , _StructObj["`v" _split2] := 0
      else if _split1 in TCHAR,CHAR
        _StructObj["`f" _split2] := 2 ;Asc/Chr
        , _StructObj["`v" _split2] := _split1="TCHAR" ? (A_IsUnicode ? "UTF-16" : "CP0") : "CP0"
      else if _split1 in LPCSTR,LPCTSTR,LPCWSTR,LPSTR,LPTSTR,LPWSTR
      {
        _StructObj["`f" _split2] := 3 ;StrGet/StrPut
        if _split1 in LPTSTR,LPCTSTR
          _StructObj["`v" _split2] := A_IsUnicode ? "UTF-16" : "CP0"
        else if _split1 in LPWSTR,LPCWSTR
          _StructObj["`v" _split2] := "UTF-16"
        else
          _StructObj["`v" _split2] := "CP0"
      }
    }
    ; ListVars
    ; If GetKeyState("CTRL","P")
    ; MsgBox
    if (_split2!="" || _split3){ ;a type was given in _split1 or array 
      If _split3
        _TypeArray:=_split1
      if _split1 in BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,LPWORD,LPWSTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE,TCHAR
        _split1:=%_split1% ;Resolve Windows Data Types
    }
    _split:=_split2 ? _split2 : _split1
    If (_split3 && !_pointer){
      _field=
      Loop % _split3
        _field.=(_field ? "," : "") (_split2 ? (_split1) : "") " " A_Index
      _split3=
      If _TypeArray in UChar,Short,UShort,Int,UInt,Float,Double,Int64,UInt64,UPTR,PTR,BOOL,INT32,LONG,LONG32,LONGLONG,LONG64,USN,HFILE,HRESULT,INT_PTR,LONG_PTR,POINTER_64,POINTER_SIGNED,SSIZE_T,WPARAM,BOOLEAN,BYTE,COLORREF,DWORD,DWORD32,LCID,LCTYPE,LGRPID,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,UINT32,ULONG,ULONG32,DWORDLONG,DWORD64,UINT64,ULONGLONG,ULONG64,DWORD_PTR,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWINSTA,HWND,LPARAM,LPBOOL,LPBYTE,LPCOLORREF,LPCVOID,LPDWORD,LPHANDLE,LPINT,LPLONG,LPVOID,LPWORD,,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_UNSIGNED,PSHORT,PSIZE_T,PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SIZE_T,UINT_PTR,ULONG_PTR,ATOM,LANGID,WCHAR,WORD,HALF_PTR,UHALF_PTR,TBYTE
        _split3 := 1 ;NumPut/NumGet
      else if _TypeArray in TCHAR,CHAR
        _split3 := 2,_Encoding := (_TypeArray="TCHAR" ? (A_IsUnicode ? "UTF-16" : "CP0") : "CP0") ;Asc/Chr
      else if _TypeArray in LPCSTR,LPCTSTR,LPCWSTR,LPSTR,LPTSTR,LPWSTR
      {
        _split3 := 3 ;StrGet/StrPut
        if _TypeArray in LPTSTR,LPCTSTR
          _Encoding := A_IsUnicode ? "UTF-16" : "CP0"
        else if _TypeArray in LPWSTR,LPCWSTR
          _Encoding := "UTF-16"
        else
          _Encoding := "CP0"
      }
      _size:=Struct(_field,_StructObj,_split,_offset,_split3,_Encoding) ;create structure in structure
       If (_union)
        _union:=_union<(_size-_offset)?_size-_offset:_union,_unionoffset:=(_unionoff?(_unionoffset+(_size-_offset)):0)
      else
        _offset+=_size
      _TypeArray=
      Continue
    }
    _StructObj._Insert("`t" _split,"") ;local memory for strings
    _StructObj["`a" _split] := _pointer ;true if field is a pointer
    _StructObj["`n" _split] := _offset+_unionoffset ;offset
    _StructObj["`r" _split] := (_split2 ? _split1 : "UInt") ;type
    _offset:=_offset+(_union ? 0 : (_pointer ? A_PtrSize : (_split2 ? %_split1% : 4))) ;current offset
    If (_union){
      If (_split2=""){
        If _union<4
        _union:=4,_unionoffset:=(_unionoff?(_unionoffset+4):0)
      } else if (_pointer) {
        If (_union<A_PtrSize)
          _union:=A_PtrSize,_unionoffset:=(_unionoff?(_unionoffset+A_PtrSize):0)
      } else if _split1 is digit
        _union:=_union<_split1?_split1:_union,_unionoffset:=(_unionoff?(_unionoffset+_split1):0)
      else
        _union:=_union<%_split1%?%_split1%:_union,_unionoffset:=(_unionoff?(_unionoffset+%_split1%):0)
      If (_unionoff && _unionoffset>_union)
        _union:=_unionoffset
    }
    If (SubStr(A_LoopField,0)="}" && (_unionoff?((_unionoff:=0)+(_unionoffset:=0)):1) || SubStr(A_LoopField,-1)="}}")
      _offset:=_offset+_union,_union:=0
  }
  If (!_obj) ;create memory for main structure only
		_StructObj._SetCapacity("`n",_offset)
		,_StructObj[""]:=_StructObj._GetAddress("`n")
    ,DllCall("RtlFillMemory","UPTR",_StructObj[""],"UInt",_offset,"UChar",0)
	 else if !IsObject(_obj)
		_StructObj[""]:=_obj
	If !_name
		Struct(_StructObj,0,1) ;correct offset for structures in structures
  _StructObj.base:=_base
	return IsObject(_obj) ? _offset : _StructObj ;Struct() is used by it self to create structures then offset must be returned.
}

Struct_GetSize(_object,o=0){
  static PTR:=A_PtrSize,UPTR:=A_PtrSize,Short:=2,UShort:=2,Int:=4,UInt:=4,Int64:=8,UInt64:=8,Double:=8,Float:=4,Char:=1,Uchar:=1
  for _k,_v in _object
  {
    If (Asc(_k)=13){ ;`r
      If _object["`a" SubStr(_k,2)]
        _v=UInt
      p:=_object["`n" SubStr(_k,2)]
      If (p_%p%="" || %_v%>p_%p%){
        If p_%p%
          o:=o-p_%p%
        p_%p%:=%_v%
        o:=o + %_v%
      }else if !p_%p%
        o:=o + %_v%
    } else if IsObject(_v){
      size:=Struct_GetSize(_v)
      p:=Abs(_v[""] - _object[""])
      If (p_%p%="" || size>p_%p%){
        If p_%p%
          o:=o-p_%p%
        p_%p%:=size
        o:=o + size
      }else if !p_%p%
        o:=o + size
    }
	}
  Return o
}

Struct_Get(o,_k="",opt="~"){
  If _k=
    Return o[""]
  else If (o["`a" _k]){ ;Pointer
    If (opt="~")
      Return Struct(o["`r" _k],NumGet(o[""]+0,o["`n" _k]+0))
    else
      Return o[_k][opt]
  } else if (o["`f" _k]!=2) {
    Return NumGet(o[""]+0,o["`n" _k]+0,o["`r" _k])
  } else
    Return StrGet(o[""]+o["`n" _k],1,o["`v" _k])
}

Struct_Put(o,_k="",_v=9223372036854775809,opt="~"){
  If ((var:=_v)=9223372036854775809){
    Struct(o,0,2) ;set pointer back to offset
    ,o._SetCapacity("`n",0)
    ,o[""]:=_k ;set new address
    ,Struct(o,0,1) ;set offset back to pointer
    Return
  } else If (o["`a" _k]) {
    v:=Struct("AHKVar",Struct_getVar(_v))
    If ((v.Contents && StrGet(v.Contents)="")||(v.Attrib!=0&&v.ContentsInt64=_v)){ ;its a value not a string, assume new address
      NumPut(_v,o[""]+o["`n" _k],(A_PtrSize=8?"UInt64":"UInt"))
    } else {
      o._SetCapacity("`t" _k,(o["`v" _k]="CP0" ? 1 : 2)*StrLen(_v)+2)
      StrPut(_v,o._GetAddress("`t" _k),StrLen(_v)+1,o["`v" _k])
      NumPut(o._GetAddress("`t" _k),o[""]+o["`n" _k],(A_PtrSize=8?"UInt64":"UInt"))
    }
  } else if (o["`f" _k]=1){
    NumPut(_v,o[""]+0,o["`n" _k]+0,o["`r" _k])
  } else if (o["`f" _k]=3){  
    v:=Struct("AHKVar",Struct_getVar(_v))
    If ((v.Contents && StrGet(v.Contents)="")||(v.Attrib!=0&&v.ContentsInt64=_v)){ ;its a value not a string, assume new address
      NumPut(_v,o[""]+o["`n" _k],(A_PtrSize=8?"UInt64":"UInt"))
    } else {
      o._SetCapacity("`t" _k,(o["`v" _k]="CP0" ? 1 : 2)*StrLen(_v)+2)
      StrPut(_v,o._GetAddress("`t" _k),StrLen(_v)+1,o["`v" _k])
      NumPut(o._GetAddress("`t" _k),o[""]+o["`n" _k],(A_PtrSize=8?"UInt64":"UInt"))
    }
  } else if (o["`f" _k] = 2) {
    StrPut(_v,o[""]+o["`n" _k],StrLen(_v),o["`v" _k])
  }
  Return _v
}
Struct_getVar(var) {
  static getVarFuncHex:=(A_PtrSize=4)?"8B4C24088B0933C08379080375028B018B4C2404998901895104C3":"488B02837810037507488B00488901C348C70100000000C3"
         ,pcb,pFunc:=NumGet((pcb:=RegisterCallback("Struct_getVar"))+28+(A_PtrSize=4?0:20),0,"UInt")
         ,pcb:=DllCall("GlobalFree","UPTR",pCb),init:=Struct_getVar("")
   if !(pbin := DllCall("GlobalAlloc","UPTR",0,"uint",StrLen(getVarFuncHex)//2))
      return 0 
	Loop % StrLen(getVarFuncHex)//2
      NumPut(("0x" . SubStr(getVarFuncHex,2*A_Index-1,2)), pbin-1, A_Index, "char")  
	DllCall("VirtualProtect", "PTR", pbin, "UINT", StrLen(getVarFuncHex)//2, uint, 0x40, uintp, 0)
	NumPut(1,pFunc+25+((5+(A_AhkVersion<"1.1.00.00"))*A_PtrSize),0,"char")
  NumPut(pbin,pFunc+A_PtrSize*(A_AhkVersion>="1.1.00.00"?2:1))
}