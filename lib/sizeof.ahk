;: Title: sizeof function by HotKeyIt
;

; Function: sizeof
; Description:
;      sizeof() is based on AHK_L Objects and supports both, ANSI and UNICODE version, so to use it you will require <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>Lexikos AutoHotkey_L.exe</a> or other versions based on it that supports objects.<br><br>nsizeof is used to calculate the size of structures or data types. <br>Visit <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>sizeof at AutoHotkey</a> forum, any feedback is welcome.
; Syntax: size:= sizeof(Structure_Definition or Structure_Object)
; Parameters:
;	   Field types - All AutoHotkey and Windows Data Types are supported<br>AutoHotkey Data Types<br> Int, Uint, Int64, UInt64, Char, UChar, Short, UShort, Fload and Double.<br>Windows Data Types<br> - note, TCHAR UCHAR and CHAR return actual character rather than the value, use Asc() function to find out the value/code<br>Windows Data types: Asc(char)<br>ATOM,BOOL,BOOLEAN,BYTE,CHAR,COLORREF,DWORD,DWORDLONG,DWORD_PTR,<br>DWORD32,DWORD64,FLOAT,HACCEL,HALF_PTR,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,<br>HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,<br>HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRESULT,HRGN,HRSRC,HSZ,HWINSTA,HWND,INT,<br>INT_PTR,INT32,INT64,LANGID,LCID,LCTYPE,LGRPID,LONG,LONGLONG,LONG_PTR,LONG32,LONG64,LPARAM,LPBOOL,<br>LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,<br>LPWORD,LPWSTR,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,<br>PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,<br>PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_64,POINTER_SIGNED,POINTER_UNSIGNED,PSHORT,PSIZE_T,<br>PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,<br>PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,<br>SHORT,SIZE_T,SSIZE_T,TBYTE,TCHAR,UCHAR,UHALF_PTR,UINT,UINT_PTR,UINT32,UINT64,ULONG,ULONGLONG,<br>ULONG_PTR,ULONG32,ULONG64,USHORT,USN,WCHAR,WORD,WPARAM
;	   <b>Parameters</b> - <b>Description</b>
;	   size - The size of structure or data type
;	   Structure_Definition - C/C++ syntax or usual definition (must not be multiline) e.g. "Int x,Int y", C/C++ definitions must be multiline.
; Return Value:
;     sizeof returns size of structures or data types
; Remarks:
;		None.
; Related:
; Example:
;		file:

sizeof(_TYPE_,parent_offset=0,ByRef _align_total_=0){
  ;Windows and AHK Data Types, used to find out the corresponding size
  static _types__:="
  (LTrim Join
    ,ATOM:2,LANGID:2,WCHAR:2,WORD:2,PTR:" A_PtrSize ",UPTR:" A_PtrSize ",SHORT:2,USHORT:2,INT:4,UINT:4,INT64:8,UINT64:8,DOUBLE:8,FLOAT:4,CHAR:1,UCHAR:1,__int64:8
    ,TBYTE:" (A_IsUnicode?2:1) ",TCHAR:" (A_IsUnicode?2:1) ",HALF_PTR:" (A_PtrSize=8?4:2) ",UHALF_PTR:" (A_PtrSize=8?4:2) ",INT32:4,LONG:4,LONG32:4,LONGLONG:8
    ,LONG64:8,USN:8,HFILE:4,HRESULT:4,INT_PTR:" A_PtrSize ",LONG_PTR:" A_PtrSize ",POINTER_64:" A_PtrSize ",POINTER_SIGNED:" A_PtrSize "
    ,BOOL:4,SSIZE_T:" A_PtrSize ",WPARAM:" A_PtrSize ",BOOLEAN:1,BYTE:1,COLORREF:4,DWORD:4,DWORD32:4,LCID:4,LCTYPE:4,LGRPID:4,LRESULT:4,PBOOL:" A_PtrSize "
    ,PBOOLEAN:" A_PtrSize ",PBYTE:" A_PtrSize ",PCHAR:" A_PtrSize ",PCSTR:" A_PtrSize ",PCTSTR:" A_PtrSize ",PCWSTR:" A_PtrSize ",PDWORD:" A_PtrSize "
    ,PDWORDLONG:" A_PtrSize ",PDWORD_PTR:" A_PtrSize ",PDWORD32:" A_PtrSize ",PDWORD64:" A_PtrSize ",PFLOAT:" A_PtrSize ",PHALF_PTR:" A_PtrSize "
    ,UINT32:4,ULONG:4,ULONG32:4,DWORDLONG:8,DWORD64:8,ULONGLONG:8,ULONG64:8,DWORD_PTR:" A_PtrSize ",HACCEL:" A_PtrSize ",HANDLE:" A_PtrSize "
     ,HBITMAP:" A_PtrSize ",HBRUSH:" A_PtrSize ",HCOLORSPACE:" A_PtrSize ",HCONV:" A_PtrSize ",HCONVLIST:" A_PtrSize ",HCURSOR:" A_PtrSize ",HDC:" A_PtrSize "
     ,HDDEDATA:" A_PtrSize ",HDESK:" A_PtrSize ",HDROP:" A_PtrSize ",HDWP:" A_PtrSize ",HENHMETAFILE:" A_PtrSize ",HFONT:" A_PtrSize ",USAGE:" 2 "
   )"
  static _types_:=_types__ "
  (LTrim Join
     ,HGDIOBJ:" A_PtrSize ",HGLOBAL:" A_PtrSize ",HHOOK:" A_PtrSize ",HICON:" A_PtrSize ",HINSTANCE:" A_PtrSize ",HKEY:" A_PtrSize ",HKL:" A_PtrSize "
     ,HLOCAL:" A_PtrSize ",HMENU:" A_PtrSize ",HMETAFILE:" A_PtrSize ",HMODULE:" A_PtrSize ",HMONITOR:" A_PtrSize ",HPALETTE:" A_PtrSize ",HPEN:" A_PtrSize "
     ,HRGN:" A_PtrSize ",HRSRC:" A_PtrSize ",HSZ:" A_PtrSize ",HWINSTA:" A_PtrSize ",HWND:" A_PtrSize ",LPARAM:" A_PtrSize ",LPBOOL:" A_PtrSize ",LPBYTE:" A_PtrSize "
     ,LPCOLORREF:" A_PtrSize ",LPCSTR:" A_PtrSize ",LPCTSTR:" A_PtrSize ",LPCVOID:" A_PtrSize ",LPCWSTR:" A_PtrSize ",LPDWORD:" A_PtrSize ",LPHANDLE:" A_PtrSize "
     ,LPINT:" A_PtrSize ",LPLONG:" A_PtrSize ",LPSTR:" A_PtrSize ",LPTSTR:" A_PtrSize ",LPVOID:" A_PtrSize ",LPWORD:" A_PtrSize ",LPWSTR:" A_PtrSize "
     ,PHANDLE:" A_PtrSize ",PHKEY:" A_PtrSize ",PINT:" A_PtrSize ",PINT_PTR:" A_PtrSize ",PINT32:" A_PtrSize ",PINT64:" A_PtrSize ",PLCID:" A_PtrSize "
     ,PLONG:" A_PtrSize ",PLONGLONG:" A_PtrSize ",PLONG_PTR:" A_PtrSize ",PLONG32:" A_PtrSize ",PLONG64:" A_PtrSize ",POINTER_32:" A_PtrSize "
     ,POINTER_UNSIGNED:" A_PtrSize ",PSHORT:" A_PtrSize ",PSIZE_T:" A_PtrSize ",PSSIZE_T:" A_PtrSize ",PSTR:" A_PtrSize ",PTBYTE:" A_PtrSize "
     ,PTCHAR:" A_PtrSize ",PTSTR:" A_PtrSize ",PUCHAR:" A_PtrSize ",PUHALF_PTR:" A_PtrSize ",PUINT:" A_PtrSize ",PUINT_PTR:" A_PtrSize "
     ,PUINT32:" A_PtrSize ",PUINT64:" A_PtrSize ",PULONG:" A_PtrSize ",PULONGLONG:" A_PtrSize ",PULONG_PTR:" A_PtrSize ",PULONG32:" A_PtrSize "
     ,PULONG64:" A_PtrSize ",PUSHORT:" A_PtrSize ",PVOID:" A_PtrSize ",PWCHAR:" A_PtrSize ",PWORD:" A_PtrSize ",PWSTR:" A_PtrSize ",SC_HANDLE:" A_PtrSize "
     ,SC_LOCK:" A_PtrSize ",SERVICE_STATUS_HANDLE:" A_PtrSize ",SIZE_T:" A_PtrSize ",UINT_PTR:" A_PtrSize ",ULONG_PTR:" A_PtrSize ",VOID:" A_PtrSize "
     )"
  local _,_ArrName_:="",_ArrType_,_ArrSize_,_defobj_,_idx_,_LF_,_LF_BKP_,_match_,_offset_,_padding_,_struct_
				,_total_union_size_,_uix_,_union_,_union_size_,_in_struct_,_mod_,_max_size_,_struct_align_
	_offset_:=parent_offset           ; Init size/offset to 0 or parent_offset

  If IsObject(_TYPE_){    ; If structure object - check for offset in structure and return pointer + last offset + its data size
    return _TYPE_["`a`a"]
  }
  
  If RegExMatch(_TYPE_,"^[\w\d\._]+$"){ ; structures name was supplied, resolve to global var and run again
      If InStr(_types_,"," _TYPE_ ":")
        Return SubStr(_types_,InStr(_types_,"," _TYPE_ ":") + 2 + StrLen(_TYPE_),1)
      else If InStr(_TYPE_,"."){ ;check for object that holds structure definition
        Loop,Parse,_TYPE_,.
          If A_Index=1
            _defobj_:=%A_LoopField%
          else _defobj_:=_defobj_[A_LoopField]
        Return sizeof(_defobj_,parent_offset)
      } else Return sizeof(%_TYPE_%,parent_offset)
  } else _defobj_:=""    
  If InStr(_TYPE_,"`n") {   ; C/C++ style definition, convert
    _offset_:=""            ; This will hold new structure
    ,_struct_:=[]            ; This will keep track if union is structure
    ,_union_:=0              ; This will keep track of union depth
    Loop,Parse,_TYPE_,`n,`r`t%A_Space%%A_Tab%
    {
      _LF_:=""
      Loop,Parse,A_LoopField,`,`;,`t%A_Space%%A_Tab%
      {
        If RegExMatch(A_LoopField,"^\s*//") ;break on comments and continue main loop
            break
        If (A_LoopField){ ; skip empty lines
            If (!_LF_ && _ArrType_:=RegExMatch(A_LoopField,"[\w\d_#@]\s+[\w\d_#@]")) ; new line, find out data type and save key in _LF_ Data type will be added later
              _LF_:=RegExReplace(A_LoopField,"[\w\d_#@]\K\s+.*$")
            If Instr(A_LoopField,"{"){ ; Union, also check if it is a structure
              _union_++,_struct_.Insert(_union_,RegExMatch(A_LoopField,"i)^\s*struct\s*\{"))
            } else If InStr(A_LoopField,"}") ; end of union/struct
              _offset_.="}"
            else { ; not starting or ending struct or union so add definitions and apply Data Type.
              If _union_ ; add { or struct{
                  Loop % _union_
                    _ArrName_.=(_struct_[A_Index]?"struct":"") "{"
              _offset_.=(_offset_ ? "," : "") _ArrName_ ((_ArrType_ && A_Index!=1)?(_LF_ " "):"") RegExReplace(A_LoopField,"\s+"," ")
              ,_ArrName_:="",_union_:=0
            }
        }
      }
    }
    _TYPE_:=_offset_
    ,_offset_:=parent_offset           ; Init size/offset to 0 or parent_offset
  }
  
  ; Following keep track of union size/offset
  _union_:=[]               ; keep track of union level, required to reset offset after union is parsed
  ,_struct_:=[]              ; for each union level keep track if it is a structure (because here offset needs to increase
  ,_union_size_:=[]          ; keep track of highest member within the union or structure, used to calculate new offset after union
  ,_struct_align_:=[]        ; keep track of alignment before structure
  ,_total_union_size_:=0     ; used in combination with above, each loop the total offset is updated if current data size is higher
  ;,_align_total_:=0          ; used to calculate alignment for total size of structure
  ,_in_struct_:=1
  ; Parse given structure definition and calculate size
  ; Structures will be resolved by recrusive calls (a structure must be global)
  Loop,Parse,_TYPE_,`,`; ;,%A_Space%%A_Tab%`n`r
  {
    _in_struct_+=StrLen(A_LoopField)+1
    If ("" = _LF_ := trim(A_LoopField,A_Space A_Tab "`n`r"))
      continue
    _LF_BKP_:=_LF_ ;to check for ending brackets = union,struct
    ; Check for STARTING union and set union helpers
    While (_match_:=RegExMatch(_LF_,"i)^(struct|union)?\s*\{\K"))
      ; correct offset for union/structure, sizeof_maxsize returns max size of union or structure
        _max_size_:=sizeof_maxsize(SubStr(_TYPE_,_in_struct_-StrLen(A_LoopField)-1+(StrLen(_LF_BKP_)-StrLen(_LF_))))
        ,_union_.Insert(_offset_+=(_mod_:=Mod(_offset_,_max_size_))?Mod(_max_size_-_mod_,_max_size_):0)
        ,_union_size_.Insert(0)
        ,_struct_align_.Insert(_align_total_>_max_size_?_align_total_:_max_size_)
        ,_struct_.Insert(RegExMatch(_LF_,"i)^struct\s*\{")?(1,_align_total_:=0):0)
        ,_LF_:=SubStr(_LF_,_match_)
    StringReplace,_LF_,_LF_,},,A
    
    If InStr(_LF_,"*"){ ; It's a pointer, size will be always A_PtrSize
      _offset_ += (_mod_:=Mod(_offset_ + A_PtrSize,A_PtrSize)?A_PtrSize-_mod_:0) + A_PtrSize
      ,_align_total_:=_align_total_<A_PtrSize?A_PtrSize:_align_total_
    } else {
      ; Split array type and optionally the size of array, e.g. "TCHAR chr[5]"
      RegExMatch(_LF_,"^(?<ArrType_>[\w\d\._#@]+)?\s*(?<ArrName_>[\w\d\._#@]+)?\s*\[?(?<ArrSize_>\d+)?\]?\s*$",_)
      If (!_ArrName_ && !_ArrSize_ && !InStr( _types_  ,"," _ArrType_ ":"))
        _ArrName_:=_ArrType_,_ArrType_:="UInt"
      If InStr(_ArrType_,"."){ ;check for object that holds structure definition
        Loop,Parse,_ArrType_,.
          If A_Index=1
            _defobj_:=%A_LoopField%
          else _defobj_:=_defobj_[A_LoopField]
        ; _ArrType_:=_defobj_                                                                     ;                   ??????????????????????????????????????
      }
      If (_idx_:=InStr( _types_  ,"," _ArrType_ ":")) ; AHK or Windows data type
        _padding_:=SubStr( _types_  , _idx_+StrLen(_ArrType_)+2 , 1 ),_align_total_:=_align_total_<_padding_?_padding_:_align_total_
      else _padding_:= sizeof(_defobj_?_defobj_:%_ArrType_%,0,_align_total_),_max_size_:=sizeof_maxsize(_defobj_?_defobj_:%_ArrType_%)
      if (_max_size_){
        if (_mod_:=Mod(_offset_,_max_size_))
          _offset_ += Mod(_max_size_-_mod_,_max_size_)
      } else if _mod_:=Mod(_offset_,_padding_)
        _offset_ += Mod(_padding_-_mod_,_padding_)
      _offset_ += (_padding_ * (_ArrSize_?_ArrSize_:1))
      _max_size_:=0
    }
    ; It's a union or struct, check if new member is higher then previous members
    If (_uix_:=_union_.MaxIndex()) && (_max_size_:=_offset_ - _union_[_uix_])>_union_size_[_uix_]
      _union_size_[_uix_]:=_max_size_
    _max_size_:=0
    ; It's a union and not struct
    If (_uix_ && !_struct_[_uix_])
      _offset_:=_union_[_uix_]

    ; Check for ENDING union and reset offset and union helpers
    While (SubStr(_LF_BKP_,0)="}"){
      If !(_uix_:=_union_.MaxIndex()){
        MsgBox,0, Incorrect structure, missing opening braket {`nProgram will exit now `n%_TYPE_%
        ExitApp
      }
      ; reset offset and align because we left a union or structure
      if (_uix_>1 && _struct_[_uix_-1]){
        If (_mod_:=Mod(_offset_,_struct_align_[_uix_]))
          _offset_+=Mod(_struct_align_[_uix_]-_mod_,_struct_align_[_uix_])
      } else _offset_:=_union_[_uix_]
      ; a member of union/struct is smaller than previous align, restore
      if (_struct_[_uix_] &&_struct_align_[_uix_]>_align_total_)
        _align_total_ := _struct_align_[_uix_]
      ; Increase total size of union/structure if necessary
      _total_union_size_ := _union_size_[_uix_]>_total_union_size_?_union_size_[_uix_]:_total_union_size_
      ,_union_.Remove() ,_struct_.Remove() ,_union_size_.Remove(),_struct_align_.Remove() ; remove latest items
      ,_LF_BKP_:=SubStr(_LF_BKP_,1,StrLen(_LF_BKP_)-1)
      If (_uix_=1){ ; leaving top union, add offset
        if (_mod_:=Mod(_total_union_size_,_align_total_))
          _total_union_size_ += Mod(_align_total_-_mod_,_align_total_)
        _offset_+=_total_union_size_,_total_union_size_:=0
      }
    }
  }
  _offset_+= Mod(_align_total_ - Mod(_offset_,_align_total_),_align_total_)
  Return _offset_
}
sizeof_maxsize(s){
  static _types__:="
  (LTrim Join
    ,ATOM:2,LANGID:2,WCHAR:2,WORD:2,PTR:" A_PtrSize ",UPTR:" A_PtrSize ",SHORT:2,USHORT:2,INT:4,UINT:4,INT64:8,UINT64:8,DOUBLE:8,FLOAT:4,CHAR:1,UCHAR:1,__int64:8
    ,TBYTE:" (A_IsUnicode?2:1) ",TCHAR:" (A_IsUnicode?2:1) ",HALF_PTR:" (A_PtrSize=8?4:2) ",UHALF_PTR:" (A_PtrSize=8?4:2) ",INT32:4,LONG:4,LONG32:4,LONGLONG:8
    ,LONG64:8,USN:8,HFILE:4,HRESULT:4,INT_PTR:" A_PtrSize ",LONG_PTR:" A_PtrSize ",POINTER_64:" A_PtrSize ",POINTER_SIGNED:" A_PtrSize "
    ,BOOL:4,SSIZE_T:" A_PtrSize ",WPARAM:" A_PtrSize ",BOOLEAN:1,BYTE:1,COLORREF:4,DWORD:4,DWORD32:4,LCID:4,LCTYPE:4,LGRPID:4,LRESULT:4,PBOOL:" A_PtrSize "
    ,PBOOLEAN:" A_PtrSize ",PBYTE:" A_PtrSize ",PCHAR:" A_PtrSize ",PCSTR:" A_PtrSize ",PCTSTR:" A_PtrSize ",PCWSTR:" A_PtrSize ",PDWORD:" A_PtrSize "
    ,PDWORDLONG:" A_PtrSize ",PDWORD_PTR:" A_PtrSize ",PDWORD32:" A_PtrSize ",PDWORD64:" A_PtrSize ",PFLOAT:" A_PtrSize ",PHALF_PTR:" A_PtrSize "
    ,UINT32:4,ULONG:4,ULONG32:4,DWORDLONG:8,DWORD64:8,ULONGLONG:8,ULONG64:8,DWORD_PTR:" A_PtrSize ",HACCEL:" A_PtrSize ",HANDLE:" A_PtrSize "
     ,HBITMAP:" A_PtrSize ",HBRUSH:" A_PtrSize ",HCOLORSPACE:" A_PtrSize ",HCONV:" A_PtrSize ",HCONVLIST:" A_PtrSize ",HCURSOR:" A_PtrSize ",HDC:" A_PtrSize "
     ,HDDEDATA:" A_PtrSize ",HDESK:" A_PtrSize ",HDROP:" A_PtrSize ",HDWP:" A_PtrSize ",HENHMETAFILE:" A_PtrSize ",HFONT:" A_PtrSize ",USAGE:" 2 "
   )"
  static _types_:=_types__ "
  (LTrim Join
     ,HGDIOBJ:" A_PtrSize ",HGLOBAL:" A_PtrSize ",HHOOK:" A_PtrSize ",HICON:" A_PtrSize ",HINSTANCE:" A_PtrSize ",HKEY:" A_PtrSize ",HKL:" A_PtrSize "
     ,HLOCAL:" A_PtrSize ",HMENU:" A_PtrSize ",HMETAFILE:" A_PtrSize ",HMODULE:" A_PtrSize ",HMONITOR:" A_PtrSize ",HPALETTE:" A_PtrSize ",HPEN:" A_PtrSize "
     ,HRGN:" A_PtrSize ",HRSRC:" A_PtrSize ",HSZ:" A_PtrSize ",HWINSTA:" A_PtrSize ",HWND:" A_PtrSize ",LPARAM:" A_PtrSize ",LPBOOL:" A_PtrSize ",LPBYTE:" A_PtrSize "
     ,LPCOLORREF:" A_PtrSize ",LPCSTR:" A_PtrSize ",LPCTSTR:" A_PtrSize ",LPCVOID:" A_PtrSize ",LPCWSTR:" A_PtrSize ",LPDWORD:" A_PtrSize ",LPHANDLE:" A_PtrSize "
     ,LPINT:" A_PtrSize ",LPLONG:" A_PtrSize ",LPSTR:" A_PtrSize ",LPTSTR:" A_PtrSize ",LPVOID:" A_PtrSize ",LPWORD:" A_PtrSize ",LPWSTR:" A_PtrSize "
     ,PHANDLE:" A_PtrSize ",PHKEY:" A_PtrSize ",PINT:" A_PtrSize ",PINT_PTR:" A_PtrSize ",PINT32:" A_PtrSize ",PINT64:" A_PtrSize ",PLCID:" A_PtrSize "
     ,PLONG:" A_PtrSize ",PLONGLONG:" A_PtrSize ",PLONG_PTR:" A_PtrSize ",PLONG32:" A_PtrSize ",PLONG64:" A_PtrSize ",POINTER_32:" A_PtrSize "
     ,POINTER_UNSIGNED:" A_PtrSize ",PSHORT:" A_PtrSize ",PSIZE_T:" A_PtrSize ",PSSIZE_T:" A_PtrSize ",PSTR:" A_PtrSize ",PTBYTE:" A_PtrSize "
     ,PTCHAR:" A_PtrSize ",PTSTR:" A_PtrSize ",PUCHAR:" A_PtrSize ",PUHALF_PTR:" A_PtrSize ",PUINT:" A_PtrSize ",PUINT_PTR:" A_PtrSize "
     ,PUINT32:" A_PtrSize ",PUINT64:" A_PtrSize ",PULONG:" A_PtrSize ",PULONGLONG:" A_PtrSize ",PULONG_PTR:" A_PtrSize ",PULONG32:" A_PtrSize "
     ,PULONG64:" A_PtrSize ",PUSHORT:" A_PtrSize ",PVOID:" A_PtrSize ",PWCHAR:" A_PtrSize ",PWORD:" A_PtrSize ",PWSTR:" A_PtrSize ",SC_HANDLE:" A_PtrSize "
     ,SC_LOCK:" A_PtrSize ",SERVICE_STATUS_HANDLE:" A_PtrSize ",SIZE_T:" A_PtrSize ",UINT_PTR:" A_PtrSize ",ULONG_PTR:" A_PtrSize ",VOID:" A_PtrSize "
     )"
  max:=0,i:=0
  s:=trim(s,"`n`r`t ")
  If InStr(s,"}"){
    Loop,Parse,s
      if (A_LoopField="{")
        i++
      else if (A_LoopField="}"){
        if --i<1{
          end:=A_Index
          break
        }
      }
    if end
      s:=SubStr(s,1,end)
  }
  Loop,Parse,s,`n,`r
  {
    _struct_:=(i:=InStr(A_LoopField," //"))?SubStr(A_LoopField,1,i):A_LoopField
    Loop,Parse,_struct_,`;`,{},%A_Space%%A_Tab%
      if A_LoopField&&!InStr(".union.struct.","." A_LoopField ".")
        if (!InStr(A_LoopField,A_Tab)&&!InStr(A_LoopField," "))
          max:=max<4?4:max
        else if (sizeof(A_LoopField,0,size:=0) && max<size)
          max:=size
  }
  return max
}