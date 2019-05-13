;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.
 * 
 * Mini-Framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
 */
; End:License ;}
; http://www.autohotkey.com/board/topic/70061-dllcall-type-list/?hl=ulong#entry443673
; http://www.autohotkey.com/board/topic/55150-class-structfunc-sizeof-updated-010412-ahkv2/
; https://github.com/HotKeyIt/_Struct
class MfStruct
{
;{ sizeof
;{ sizeof Description
;: Title: sizeof function by HotKeyIt
;

; Function: sizeof
; Description:
;      sizeof() is based on AHK_L Objects and supports both, ANSI and UNICODE version, so to use it you will require <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>Lexikos AutoHotkey_L.exe</a> or other versions based on it that supports objects.
; 
; nsizeof is used to calculate the size of structures or data types. 
; Visit <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>sizeof at AutoHotkey</a> forum, any feedback is welcome.
; Syntax: size:= sizeof(Structure_Definition or Structure_Object)
; Parameters:
;	   Field types - All AutoHotkey and Windows Data Types are supported
; AutoHotkey Data Types
;  Int, Uint, Int64, UInt64, Char, UChar, Short, UShort, Fload and Double.
; Windows Data Types
;  - note, TCHAR UCHAR and CHAR return actual character rather than the value, use Asc() function to find out the value/code
; Windows Data types: Asc(char)
; ATOM,BOOL,BOOLEAN,BYTE,CHAR,COLORREF,DWORD,DWORDLONG,DWORD_PTR,
; DWORD32,DWORD64,FLOAT,HACCEL,HALF_PTR,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,
; HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,
; HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRESULT,HRGN,HRSRC,HSZ,HWINSTA,HWND,INT,
; INT_PTR,INT32,INT64,LANGID,LCID,LCTYPE,LGRPID,LONG,LONGLONG,LONG_PTR,LONG32,LONG64,LPARAM,LPBOOL,
; LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,
; LPWORD,LPWSTR,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,
; PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,
; PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_64,POINTER_SIGNED,POINTER_UNSIGNED,PSHORT,PSIZE_T,
; PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,
; PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,
; SHORT,SIZE_T,SSIZE_T,TBYTE,TCHAR,UCHAR,UHALF_PTR,UINT,UINT_PTR,UINT32,UINT64,ULONG,ULONGLONG,
; ULONG_PTR,ULONG32,ULONG64,USHORT,USN,WCHAR,WORD,WPARAM
;	   Parameters - Description
;	   size - The size of structure or data type
;	   Structure_Definition - C/C++ syntax or usual definition (must not be multiline) e.g. "Int x,Int y", C/C++ definitions must be multiline.
; Return Value:
;     sizeof returns size of structures or data types
; Remarks:
;		None.
; Related:
; Example:
;		file:
; End:sizeof Description ;}
sizeof(_TYPE_,parent_offset=0,_align_total_=0){
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
     ,HDDEDATA:" A_PtrSize ",HDESK:" A_PtrSize ",HDROP:" A_PtrSize ",HDWP:" A_PtrSize ",HENHMETAFILE:" A_PtrSize ",HFONT:" A_PtrSize "
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
				,_total_union_size_,_uix_,_union_,_union_size_
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
        Return MfStruct.sizeof(_defobj_,parent_offset)
      } else Return MfStruct.sizeof(%_TYPE_%,parent_offset)
  } else _defobj_:=""    
  If InStr(_TYPE_,"`n") {   ; C/C++ style definition, convert
    _offset_:=""            ; This will hold new structure
    _struct_:=[]            ; This will keep track if union is structure
    _union_:=0              ; This will keep track of union depth
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
            If Instr(A_LoopField,"{"){  ; Union, also check if it is a structure
              _union_++,_struct_.Insert(_union_,RegExMatch(A_LoopField,"i)^\s*struct\s*\{"))
            } else If InStr(A_LoopField,"}") ; end of union/struct
              _offset_.="}"
            else { ; not starting or ending struct or union so add definitions and apply Data Type.
              If _union_ ; add { or struct{
                  Loop % _union_
                    _ArrName_.=(_struct_[A_Index]?"struct":"") "{"
              _offset_.=(_offset_ ? "," : "") _ArrName_ ((_ArrType_ && A_Index!=1)?(_LF_ " "):"") RegExReplace(A_LoopField,"\s+"," ")
              _ArrName_:="",_union_:=0
            }
        }
      }
    }
    _TYPE_:=_offset_
    _offset_:=parent_offset           ; Init size/offset to 0 or parent_offset
  }
  
  ; Following keep track of union size/offset
  _union_:=[]               ; keep track of union level, required to reset offset after union is parsed
  _struct_:=[]              ; for each union level keep track if it is a structure (because here offset needs to increase
  _union_size_:=[]        ; keep track of highest member within the union or structure, used to calculate new offset after union
  _total_union_size_:=0   ; used in combination with above, each loop the total offset is updated if current data size is higher
  _align_total_:=0
  ; Parse given structure definition and calculate size
  ; Structures will be resolved by recrusive calls (a structure must be global)
  Loop,Parse,_TYPE_,`,`;,%A_Space%%A_Tab%`n`r
  {
    If ("" = _LF_ := A_LoopField)
      continue
    ; Check for STARTING union and set union helpers
    While (_match_:=RegExMatch(_LF_,"i)^\s*(struct|union)?\s*\{\K"))
        _union_.Insert(_offset_)
        ,_union_size_.Insert(0)
        ,_struct_.Insert(RegExMatch(_LF_,"i)^\s*struct\s*\{")?1:0)
        ,_LF_:=SubStr(_LF_,_match_)
      
    _LF_BKP_:=_LF_ ;to check for ending brackets = union,struct
    StringReplace,_LF_,_LF_,},,A
    
    If InStr(_LF_,"*") ; It's a pointer, size will be always A_PtrSize
      _offset_ += (Mod(_offset_ + A_PtrSize,A_PtrSize)?A_PtrSize-Mod(_offset_ + A_PtrSize,A_PtrSize):0) + A_PtrSize
      ,_align_total_:=_align_total_<A_PtrSize?A_PtrSize:_align_total_
    else {
      ; Split array type and optionally the size of array, e.g. "TCHAR chr[5]"
      RegExMatch(_LF_,"^\s*(?<ArrType_>[\w\d\._#@]+)?\s*(?<ArrName_>[\w\d\._#@]+)?\s*\[?(?<ArrSize_>\d+)?\]?\s*$",_)
      If (!_ArrName_ && !_ArrSize_ && !InStr( _types_  ,"," _ArrType_ ":"))
        _ArrName_:=_ArrType_,_ArrType_:="UInt"
      If InStr(_ArrType_,"."){ ;check for object that holds structure definition
        Loop,Parse,_ArrType_,.
          If A_Index=1
            _defobj_:=%A_LoopField%
          else _defobj_:=_defobj_[A_LoopField]
        _ArrType_:=_defobj_
      }
      If (_idx_:=InStr( _types_  ,"," _ArrType_ ":")){ ; AHK or Windows data type
        ; find out the size in _types_ and add to total size
        _padding_:=SubStr( _types_  , _idx_+StrLen(_ArrType_)+2 , 1 )
        _offset_ += (Mod(_offset_ + _padding_,_padding_)?_padding_-Mod(_offset_ + _padding_,_padding_):0) + (_padding_ * (_ArrSize_?_ArrSize_:1))
        _align_total_:=_align_total_<_padding_?_padding_:_align_total_
      } else { ; resolve structure
			_offset_ += MfStruct.sizeof(_defobj_?_defobj_:%_ArrType_%,_offset_)-_offset_ - MfStruct.sizeof(_defobj_?_defobj_:%_ArrType_%)
        _offset_ += MfStruct.sizeof(_defobj_?_defobj_:%_ArrType_%) * (_ArrSize_?_ArrSize_:1) ; %Array1% will resolve to global variable
	  }
    }
    ; It's a union or struct, check if new member is higher then previous members
    If (_uix_:=_union_.MaxIndex())
          _union_size_[_uix_]:=(_offset_ - _union_[_uix_]>_union_size_[_uix_])
                                            ?(_offset_ - _union_[_uix_]):_union_size_[_uix_]

    ; It's a union and not struct
    If (_uix_ && !_struct_[_struct_.MaxIndex()])
      _offset_:=_union_[_uix_]

    ; Check for ENDING union and reset offset and union helpers
    While (SubStr(_LF_BKP_,0)="}"){
      If !(_uix_:=_union_.MaxIndex()){
        MsgBox,0, Incorrect structure, missing opening braket {`nProgram will exit now `n%_TYPE_%
        ExitApp
      }
      _offset_:=_union_[_uix_] ; reset offset because we left a union or structure
      ; Increase total size of union/structure if necessary
      _total_union_size_ := _union_size_[_uix_]>_total_union_size_?_union_size_[_uix_]:_total_union_size_
      ,_union_.Remove() ,_struct_.Remove() ,_union_size_.Remove() ; remove latest items
      ,_LF_BKP_:=SubStr(_LF_BKP_,1,StrLen(_LF_BKP_)-1)
      If !_union_.MaxIndex(){ ; leaving top union, add offset
        if Mod(_total_union_size_,_align_total_.1)
					_total_union_size_ += _align_total_.1-Mod(_total_union_size_,_align_total_.1)
				_offset_+=_total_union_size_
        _total_union_size_:=0
      }
    }
  }
  _offset_+=_align_total_?Mod(_offset_,_align_total_):0
  Return _offset_
}
; End:sizeof ;}
;{ Class _Struct Description
;: Title: _Struct by HotKeyIt
; http://www.autohotkey.net/~HotKeyIt/AutoHotkey/_Struct.htm

; Function: _Struct
; Description:
;      _Struct is based on AHK_L objects and supports both, ANSI and UNICODE version. To use it you will require <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>Lexikos AutoHotkey_L.exe</a> or other versions based on it.
; 
; new _Struct is used to create new structure. A structure must be defined as a global variable or an item of global class (e.g. "MyClass.Struct").
; _Struct can handle structure in structure as well as Arrays of structures and Vectors.
; Visit <a href=http://www.autohotkey.com/forum/viewtopic.php?t=43049>_Struct on AutoHotkey</a> forum, any feedback is welcome.
; Syntax: MyStruct:= new _Struct(Structure_Definition,Address,initialization)
; Parameters:
;	   General Design - Class _Struct will create Object(s) that will manage fields of structure(s), for example
; left,top,right,bottom
; RC := new _Struct("RECT")
; will create a RECT structure with fields left,top,right,bottom of type UInt. To pass the structure its pointer to a function, DllCall or SendMessage use RC[""].
; 
; To access fields you can use usual Object syntax: RC.left, RC.right ...
; To set a field of the structure use RC.top := 100.
;	   Field types - Following AutoHotkey and Windows Data Types are supported:
; 
; AutoHotkey Data Types:
; Int, Uint, Int64, UInt64, Char, UChar, Short, UShort, Fload and Double.
; 
; Windows Data Types:
; ATOM,BOOL,BOOLEAN,BYTE,CHAR,COLORREF,DWORD,DWORDLONG,DWORD_PTR,
; DWORD32,DWORD64,FLOAT,HACCEL,HALF_PTR,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,
; HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,
; HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRESULT,HRGN,HRSRC,HSZ,HWINSTA,HWND,INT,
; INT_PTR,INT32,INT64,LANGID,LCID,LCTYPE,LGRPID,LONG,LONGLONG,LONG_PTR,LONG32,LONG64,LPARAM,LPBOOL,
; LPBYTE,LPCOLORREF,LPCSTR,LPCTSTR,LPCVOID,LPCWSTR,LPDWORD,LPHANDLE,LPINT,LPLONG,LPSTR,LPTSTR,LPVOID,
; LPWORD,LPWSTR,LRESULT,PBOOL,PBOOLEAN,PBYTE,PCHAR,PCSTR,PCTSTR,PCWSTR,PDWORD,PDWORDLONG,PDWORD_PTR,
; PDWORD32,PDWORD64,PFLOAT,PHALF_PTR,PHANDLE,PHKEY,PINT,PINT_PTR,PINT32,PINT64,PLCID,PLONG,PLONGLONG,
; PLONG_PTR,PLONG32,PLONG64,POINTER_32,POINTER_64,POINTER_SIGNED,POINTER_UNSIGNED,PSHORT,PSIZE_T,
; PSSIZE_T,PSTR,PTBYTE,PTCHAR,PTSTR,PUCHAR,PUHALF_PTR,PUINT,PUINT_PTR,PUINT32,PUINT64,PULONG,PULONGLONG,
; PULONG_PTR,PULONG32,PULONG64,PUSHORT,PVOID,PWCHAR,PWORD,PWSTR,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,
; SHORT,SIZE_T,SSIZE_T,TBYTE,TCHAR,UCHAR,UHALF_PTR,UINT,UINT_PTR,UINT32,UINT64,ULONG,ULONGLONG,
; ULONG_PTR,ULONG32,ULONG64,USHORT,USN,WCHAR,WORD,WPARAM
;	   Structure Definition - Description
;	   User defined - To create a user defined structure you will need to pass a string of predefined types and field names.
; Default type is UInt, so for example for a RECT structure type can be omited: "left,top,right,left", which is the same as "Uint left,Uint top,Uint right,Uint bottom"
; 
; You can also use structures very similar to C#/C++ syntax, see example.
;	   Global - Global variables can be used to save structures, easily pass name of that variable as first parameter, e.g. new _Struct("MyStruct") where MyStruct must be a global variable with structure definition. Also new _Struct(MyStruct) can be used if variable is accessible.
;	   Array - To create an array of structures include a digit in the end of your string enclosed in squared brackets.
; For example "RECT[2]" would create an array of 2 structures.
; This feature can also be used for user defined arrays, for example "Int age,TCHAR name[10]".
;	   Union - Using {} you can create union, for example: 
; _AHKVar:="{Int64 ContentsInt64,Double ContentsDouble,object},...
;	   Struct - Using struct{} you can create structures in union or in structures.
;	   Pointer - To create a pointer you can use *, for example: CHR:="char *str" will hold a pointer to a character. Same way you can have a structure in structure so you can call it recursive, for example Label.NextLabel.NextLabel.NextLabel.JumpToLine
;	   Parameters - Description
;	   MyStruct - This is a variable that will hold the object representing the strucuture which is returned by new _Struct(...).
;	   Structure_Definition - C/C++ syntax or one-line definition e.g. "Int x,Int y".
;	   pointer - Pass a pointer as second parameter to occupy existing strucure.
;	   Initialization - Pass an object to initialize structure, e.g. {left:100,top:20}. If pointer is not used initialization can be specified in second parameter.
;	   Methods - Description
;	   Strct.Type(itm) - Returns type of item or structure
;	   Strct.AhkType(itm) - Returns AHK type of item or structure to be used with NumGet and NumPut as well as DllCall
;	   Strct.Size() - Returns size of structure, same as sizeof(MyStruct)
;	   Strct.SizeT(itm) - Returns size of an item
;	   Strct.Offset(itm) - Returns offset for items
;	   Strct.Encoding(itm) - Returns encoding for items, to be used with StrGet and StrPut
;	   Strct.Alloc(itm,size[,ptrsize]) - Allocates memory in bytes, ptrsize is used to create pointers
;	   Strct.Capacity(itm) - Returns memory capacity for items.
;	   Strct.IsPointer(itm) - Returns whether the item is a pointer (defined using *).
; Return Value:
;     A class object representing your structure
; Remarks:
;		NOTE!!! accessing a field that does not exist will cause recrusive calls and will crash your script, these errors are not catched for performance reasons.
; TCHAR, UCHAR and CHAR return actual character rather than the value, use Asc() function to find out the value/code.
; Related:
; Example:
;		file:Struct_Example.ahk
;
; End:Class _Struct Description ;}
Class _Struct {
	; Data Sizes
  static PTR:=A_PtrSize,UPTR:=A_PtrSize,SHORT:=2,USHORT:=2,INT:=4,UINT:=4,__int64:=8,INT64:=8,UINT64:=8,DOUBLE:=8,FLOAT:=4,CHAR:=1,UCHAR:=1,VOID:=A_PtrSize
    ,TBYTE:=A_IsUnicode?2:1,TCHAR:=A_IsUnicode?2:1,HALF_PTR:=A_PtrSize=8?4:2,UHALF_PTR:=A_PtrSize=8?4:2,INT32:=4,LONG:=4,LONG32:=4,LONGLONG:=8
    ,LONG64:=8,USN:=8,HFILE:=4,HRESULT:=4,INT_PTR:=A_PtrSize,LONG_PTR:=A_PtrSize,POINTER_64:=A_PtrSize,POINTER_SIGNED:=A_PtrSize
    ,BOOL:=4,SSIZE_T:=A_PtrSize,WPARAM:=A_PtrSize,BOOLEAN:=1,BYTE:=1,COLORREF:=4,DWORD:=4,DWORD32:=4,LCID:=4,LCTYPE:=4,LGRPID:=4,LRESULT:=4,PBOOL:=4
    ,PBOOLEAN:=A_PtrSize,PBYTE:=A_PtrSize,PCHAR:=A_PtrSize,PCSTR:=A_PtrSize,PCTSTR:=A_PtrSize,PCWSTR:=A_PtrSize,PDWORD:=A_PtrSize,PDWORDLONG:=A_PtrSize
  static PDWORD_PTR:=A_PtrSize,PDWORD32:=A_PtrSize,PDWORD64:=A_PtrSize,PFLOAT:=A_PtrSize,PHALF_PTR:=A_PtrSize
    ,UINT32:=4,ULONG:=4,ULONG32:=4,DWORDLONG:=8,DWORD64:=8,ULONGLONG:=8,ULONG64:=8,DWORD_PTR:=A_PtrSize,HACCEL:=A_PtrSize,HANDLE:=A_PtrSize
    ,HBITMAP:=A_PtrSize,HBRUSH:=A_PtrSize,HCOLORSPACE:=A_PtrSize,HCONV:=A_PtrSize,HCONVLIST:=A_PtrSize,HCURSOR:=A_PtrSize,HDC:=A_PtrSize
    ,HDDEDATA:=A_PtrSize,HDESK:=A_PtrSize,HDROP:=A_PtrSize,HDWP:=A_PtrSize,HENHMETAFILE:=A_PtrSize,HFONT:=A_PtrSize
  static HGDIOBJ:=A_PtrSize,HGLOBAL:=A_PtrSize,HHOOK:=A_PtrSize,HICON:=A_PtrSize,HINSTANCE:=A_PtrSize,HKEY:=A_PtrSize,HKL:=A_PtrSize
    ,HLOCAL:=A_PtrSize,HMENU:=A_PtrSize,HMETAFILE:=A_PtrSize,HMODULE:=A_PtrSize,HMONITOR:=A_PtrSize,HPALETTE:=A_PtrSize,HPEN:=A_PtrSize
    ,HRGN:=A_PtrSize,HRSRC:=A_PtrSize,HSZ:=A_PtrSize,HWINSTA:=A_PtrSize,HWND:=A_PtrSize,LPARAM:=A_PtrSize,LPBOOL:=A_PtrSize,LPBYTE:=A_PtrSize
    ,LPCOLORREF:=A_PtrSize,LPCSTR:=A_PtrSize,LPCTSTR:=A_PtrSize,LPCVOID:=A_PtrSize,LPCWSTR:=A_PtrSize,LPDWORD:=A_PtrSize,LPHANDLE:=A_PtrSize
    ,LPINT:=A_PtrSize,LPLONG:=A_PtrSize,LPSTR:=A_PtrSize,LPTSTR:=A_PtrSize,LPVOID:=A_PtrSize,LPWORD:=A_PtrSize,LPWSTR:=A_PtrSize,PHANDLE:=A_PtrSize
  static PHKEY:=A_PtrSize,PINT:=A_PtrSize,PINT_PTR:=A_PtrSize,PINT32:=A_PtrSize,PINT64:=A_PtrSize,PLCID:=A_PtrSize,PLONG:=A_PtrSize,PLONGLONG:=A_PtrSize
    ,PLONG_PTR:=A_PtrSize,PLONG32:=A_PtrSize,PLONG64:=A_PtrSize,POINTER_32:=A_PtrSize,POINTER_UNSIGNED:=A_PtrSize,PSHORT:=A_PtrSize,PSIZE_T:=A_PtrSize
    ,PSSIZE_T:=A_PtrSize,PSTR:=A_PtrSize,PTBYTE:=A_PtrSize,PTCHAR:=A_PtrSize,PTSTR:=A_PtrSize,PUCHAR:=A_PtrSize,PUHALF_PTR:=A_PtrSize,PUINT:=A_PtrSize
    ,PUINT_PTR:=A_PtrSize,PUINT32:=A_PtrSize,PUINT64:=A_PtrSize,PULONG:=A_PtrSize,PULONGLONG:=A_PtrSize,PULONG_PTR:=A_PtrSize,PULONG32:=A_PtrSize
    ,PULONG64:=A_PtrSize,PUSHORT:=A_PtrSize,PVOID:=A_PtrSize,PWCHAR:=A_PtrSize,PWORD:=A_PtrSize,PWSTR:=A_PtrSize,SC_HANDLE:=A_PtrSize
    ,SC_LOCK:=A_PtrSize,SERVICE_STATUS_HANDLE:=A_PtrSize,SIZE_T:=A_PtrSize,UINT_PTR:=A_PtrSize,ULONG_PTR:=A_PtrSize,ATOM:=2,LANGID:=2,WCHAR:=2,WORD:=2
	; Data Types
  static _PTR:="PTR",_UPTR:="UPTR",_SHORT:="Short",_USHORT:="UShort",_INT:="Int",_UINT:="UInt"
    ,_INT64:="Int64",_UINT64:="UInt64",_DOUBLE:="Double",_FLOAT:="Float",_CHAR:="Char",_UCHAR:="UChar"
    ,_VOID:="PTR",_TBYTE:=A_IsUnicode?"USHORT":"UCHAR",_TCHAR:=A_IsUnicode?"USHORT":"UCHAR",_HALF_PTR:=A_PtrSize=8?"INT":"SHORT"
    ,_UHALF_PTR:=A_PtrSize=8?"UINT":"USHORT",_BOOL:="Int",_INT32:="Int",_LONG:="Int",_LONG32:="Int",_LONGLONG:="Int64",_LONG64:="Int64"
    ,_USN:="Int64",_HFILE:="UInt",_HRESULT:="UInt",_INT_PTR:="PTR",_LONG_PTR:="PTR",_POINTER_64:="PTR",_POINTER_SIGNED:="PTR",_SSIZE_T:="PTR"
    ,_WPARAM:="PTR",_BOOLEAN:="UCHAR",_BYTE:="UCHAR",_COLORREF:="UInt",_DWORD:="UInt",_DWORD32:="UInt",_LCID:="UInt",_LCTYPE:="UInt"
  static _LGRPID:="UInt",_LRESULT:="UInt",_PBOOL:="UPTR",_PBOOLEAN:="UPTR",_PBYTE:="UPTR",_PCHAR:="UPTR",_PCSTR:="UPTR",_PCTSTR:="UPTR"
    ,_PCWSTR:="UPTR",_PDWORD:="UPTR",_PDWORDLONG:="UPTR",_PDWORD_PTR:="UPTR",_PDWORD32:="UPTR",_PDWORD64:="UPTR",_PFLOAT:="UPTR",___int64:="Int64"
    ,_PHALF_PTR:="UPTR",_UINT32:="UInt",_ULONG:="UInt",_ULONG32:="UInt",_DWORDLONG:="UInt64",_DWORD64:="UInt64",_ULONGLONG:="UInt64"
    ,_ULONG64:="UInt64",_DWORD_PTR:="UPTR",_HACCEL:="UPTR",_HANDLE:="UPTR",_HBITMAP:="UPTR",_HBRUSH:="UPTR",_HCOLORSPACE:="UPTR"
    ,_HCONV:="UPTR",_HCONVLIST:="UPTR",_HCURSOR:="UPTR",_HDC:="UPTR",_HDDEDATA:="UPTR",_HDESK:="UPTR",_HDROP:="UPTR",_HDWP:="UPTR"
  static _HENHMETAFILE:="UPTR",_HFONT:="UPTR",_HGDIOBJ:="UPTR",_HGLOBAL:="UPTR",_HHOOK:="UPTR",_HICON:="UPTR",_HINSTANCE:="UPTR",_HKEY:="UPTR"
    ,_HKL:="UPTR",_HLOCAL:="UPTR",_HMENU:="UPTR",_HMETAFILE:="UPTR",_HMODULE:="UPTR",_HMONITOR:="UPTR",_HPALETTE:="UPTR",_HPEN:="UPTR"
    ,_HRGN:="UPTR",_HRSRC:="UPTR",_HSZ:="UPTR",_HWINSTA:="UPTR",_HWND:="UPTR",_LPARAM:="UPTR",_LPBOOL:="UPTR",_LPBYTE:="UPTR",_LPCOLORREF:="UPTR"
    ,_LPCSTR:="UPTR",_LPCTSTR:="UPTR",_LPCVOID:="UPTR",_LPCWSTR:="UPTR",_LPDWORD:="UPTR",_LPHANDLE:="UPTR",_LPINT:="UPTR",_LPLONG:="UPTR"
    ,_LPSTR:="UPTR",_LPTSTR:="UPTR",_LPVOID:="UPTR",_LPWORD:="UPTR",_LPWSTR:="UPTR",_PHANDLE:="UPTR",_PHKEY:="UPTR",_PINT:="UPTR"
  static _PINT_PTR:="UPTR",_PINT32:="UPTR",_PINT64:="UPTR",_PLCID:="UPTR",_PLONG:="UPTR",_PLONGLONG:="UPTR",_PLONG_PTR:="UPTR",_PLONG32:="UPTR"
    ,_PLONG64:="UPTR",_POINTER_32:="UPTR",_POINTER_UNSIGNED:="UPTR",_PSHORT:="UPTR",_PSIZE_T:="UPTR",_PSSIZE_T:="UPTR",_PSTR:="UPTR"
    ,_PTBYTE:="UPTR",_PTCHAR:="UPTR",_PTSTR:="UPTR",_PUCHAR:="UPTR",_PUHALF_PTR:="UPTR",_PUINT:="UPTR",_PUINT_PTR:="UPTR",_PUINT32:="UPTR"
    ,_PUINT64:="UPTR",_PULONG:="UPTR",_PULONGLONG:="UPTR",_PULONG_PTR:="UPTR",_PULONG32:="UPTR",_PULONG64:="UPTR",_PUSHORT:="UPTR"
    ,_PVOID:="UPTR",_PWCHAR:="UPTR",_PWORD:="UPTR",_PWSTR:="UPTR",_SC_HANDLE:="UPTR",_SC_LOCK:="UPTR",_SERVICE_STATUS_HANDLE:="UPTR"
    ,_SIZE_T:="UPTR",_UINT_PTR:="UPTR",_ULONG_PTR:="UPTR",_ATOM:="Ushort",_LANGID:="Ushort",_WCHAR:="Ushort",_WORD:="UShort"
    
  ; Following is used internally only to simplify setting field helpers
  ; the corresponding key can be set to invalid type (for string integer and vice versa) to set default if necessary, e.g. ___InitField(N,"")
  ___InitField(_this,N,offset=" ",encoding=0,AHKType=0,isptr=" ",type=0,arrsize=0,memory=0){ ; N = Name of field
    static _prefixes_:={offset:"`b",isptr:"`r",AHKType:"`n",type:"`t",encoding:"`f",memory:"`v",arrsize:" "}
          ,_testtype_:={offset:"integer",isptr:"integer",AHKType:"string",type:"string",encoding:"string",arrsize:"integer"}
          ,_default_:={offset:0,isptr:0,AHKType:"UInt",type:"UINT",encoding:"CP0",memory:"",arrsize:1}
    for _key_,_value_ in _prefixes_
    {
      _typevalid_:=0
      If (_testtype_[_key_]="Integer"){
        If %_key_% is integer
          useDefault:=1,_typevalid_:=1
        else if !_this.HasKey(_value_ N)
          useDefault:=1
      } else {
        If %_key_% is not integer
          useDefault:=1,_typevalid_:=1
        else if !_this.HasKey(_value_ N)
          useDefault:=1
      }
      If (useDefault) ; item does not exist or user supplied a valid type
        If (_key_="encoding")
          _this[_value_ N]:=_typevalid_?(InStr(",LPTSTR,LPCTSTR,TCHAR,","," %_key_% ",")?(A_IsUnicode?"UTF-16":"CP0")
                                        :InStr(",LPWSTR,LPCWSTR,WCHAR,","," %_key_% ",")?"UTF-16":"CP0")
                                      :_default_[_key_]
        else {
          _this[_value_ N]:=_typevalid_?%_key_%:_default_[_key_]
         }
    }
  }
  
  ; Struct Contstructor
  ; Memory, offset and definitions are saved in following character + given key/name
  ;   `a = Allocated Memory
  ;   `b = Byte Offset (related to struct address)
  ;   `f = Format (encoding for string data types)
  ;   `n = New data type (AHK data type)
  ;   `r = Is Pointer (requred for __GET and __SET)
  ;   `t = Type (data type, also when it is name of a Structure it is used to resolve structure pointers dynamically
  ;   `v = Memory used to save string and pointer memory
  __NEW(_TYPE_,_pointer_=0,_init_=0){
    static _base_:={__GET:MfStruct._Struct.___GET,__SET:MfStruct._Struct.___SET,__SETPTR:MfStruct._Struct.___SETPTR,__Clone:MfStruct._Struct.___Clone,__NEW:MfStruct._Struct.___NEW
          ,IsPointer:MfStruct._Struct.IsPointer,Offset:MfStruct._Struct.Offset,Type:MfStruct._Struct.Type,AHKType:MfStruct._Struct.AHKType,Encoding:MfStruct._Struct.Encoding
          ,Capacity:MfStruct._Struct.Capacity,Alloc:MfStruct._Struct.Alloc,Size:MfStruct._Struct.Size,SizeT:MfStruct._Struct.SizeT}
		local _,_ArrType_,_ArrName_:="",_ArrSize_,_align_total_,_defobj_,_IsPtr_,_key_,_LF_,_LF_BKP_,_match_,_offset_:=""
					,_struct_,_StructSize_,_total_union_size_,_union_,_union_size_,_value_
		
		If (RegExMatch(_TYPE_,"^[\w\d\._]+$") && !MfStruct._Struct.HasKey(_TYPE_)){ ; structures name was supplied, resolve to global var and run again
      If InStr(_TYPE_,"."){ ;check for object that holds structure definition
        Loop,Parse,_TYPE_,.
          If A_Index=1
            _defobj_:=%A_LoopField%
          else _defobj_:=_defobj_[A_LoopField]
        _TYPE_:=_defobj_
      } else _TYPE_:=%_TYPE_%,_defobj_:=""
    } else _defobj_:=""
    ; If a pointer is supplied, save it in key [""] else reserve and zero-fill memory + set pointer in key [""]
    If (_pointer_ && !IsObject(_pointer_))
      this[""] := _pointer_,this["`a"]:=0,this["`a`a"]:= MfStruct.sizeof(_TYPE_)
    else
      this._SetCapacity("`a",_StructSize_:= MfStruct.sizeof(_TYPE_)) ; Set Capacity in key ["`a"]
      ,this[""]:=this._GetAddress("`a") ; Save pointer in key [""]
      ,DllCall("RtlZeroMemory","UPTR",this[""],"UInt",this["`a`a"]:=_StructSize_) ; zero-fill memory
    ; C/C++ style structure definition, convert it
    If InStr(_TYPE_,"`n") {
      _struct_:=[] ; keep track of structures (union is just removed because {} = union, struct{} = struct
      _union_:=0   ; init to 0, used to keep track of union depth
      Loop,Parse,_TYPE_,`n,`r`t%A_Space%%A_Tab% ; Parse each line
      {
        _LF_:=""
        Loop,Parse,A_LoopField,`,`;,`t%A_Space%%A_Tab% ; Parse each item
        {
          If RegExMatch(A_LoopField,"^\s*//") ;break on comments and continue main loop
              break
          If (A_LoopField){ ; skip empty lines
              If (!_LF_ && _ArrType_:=RegExMatch(A_LoopField,"[\w\d_]\s+[\w\d_]")) ; new line, find out data type and save key in _LF_ Data type will be added later
                _LF_:=RegExReplace(A_LoopField,"[\w\d_]\K\s+.*$")
              If Instr(A_LoopField,"{"){ ; Union, also check if it is a structure
                _union_++,_struct_.Insert(_union_,RegExMatch(A_LoopField,"i)^\s*struct\s*\{"))
              } else If InStr(A_LoopField,"}") ; end of union/struct
                _offset_.="}"
              else { ; not starting or ending struct or union so add definitions and apply Data Type.
                If _union_ ; add { or struct{
                    Loop % _union_
                      _ArrName_.=(_struct_[A_Index]?"struct":"") "{"
                _offset_.=(_offset_ ? "," : "") _ArrName_ ((_ArrType_ && A_Index!=1)?(_LF_ " "):"") RegExReplace(A_LoopField,"\s+"," ")
                _ArrName_:="",_union_:=0
              }
          }
        }
      }
      _TYPE_:=_offset_
    }

    _offset_:=0                 
    _union_:=[]                 ; keep track of union level, required to reset offset after union is parsed
    _struct_:=[]                ; for each union level keep track if it is a structure (because here offset needs to increase
    _union_size_:=[]          ; keep track of highest member within the union or structure, used to calculate new offset after union
    _total_union_size_:=0     ; used in combination with above, each loop the total offset is updated if current data size is higher
    _align_total_:=0			; used to calculate alignment for total size of structure
	
    this["`t"]:=0,this["`r"]:=0 ; will identify a Structure Pointer without members

    ; Parse given structure definition and create struct members
    ; User structures will be resolved by recrusive calls (!!! a structure must be a global variable)
    Loop,Parse,_TYPE_,`,`;,%A_Space%%A_Tab%`n`r
    {
      If ("" = _LF_ := A_LoopField)
        Continue
      _IsPtr_:=0
      ; Check for STARTING union and set union helpers
      While (_match_:=RegExMatch(_LF_,"i)^\s*(struct|union)?\s*\{\K"))
        _union_.Insert(_offset_)
        ,_union_size_.Insert(0)
        ,_struct_.Insert(RegExMatch(_LF_,"i)^\s*struct\s*\{")?1:0)
        ,_LF_:=SubStr(_LF_,_match_)
       
      _LF_BKP_:=_LF_ ;to check for ending brackets = union,struct
      StringReplace,_LF_,_LF_,},,A ;remove all closing brackets (these will be checked later)
      
      ; Check if item is a pointer and remove * for further processing, separate key will store that information
      While % (InStr(_LF_,"*")){
        StringReplace,_LF_,_LF_,*
        _IsPtr_:=A_Index
      }

      ; Split off data type, name and size (only data type is mandatory)
      RegExMatch(_LF_,"^\s*(?<ArrType_>[\w\d\._]+)?\s*(?<ArrName_>[\w\d_]+)?\s*\[?(?<ArrSize_>\d+)?\]?\s*\}*\s*$",_)
      If (!_ArrName_ && !_ArrSize_){
        ; If (_ArrType_=_TYPE_ || (_ArrType_ "*") =_TYPE_ || ("*" _ArrType_=_TYPE_)) {
        If RegExMatch(_TYPE_,"^\**" _ArrType_ "\**$"){
          MfStruct._Struct.___InitField(this,"",0,_ArrType_,_IsPtr_?"PTR":MfStruct._Struct.HasKey("_" _ArrType_)?MfStruct._Struct["_" _ArrType_]:"PTR",_IsPtr_,_ArrType_)
          this.base:=_base_
          If (IsObject(_init_)||IsObject(_pointer_)){ ; Initialization of structures members, e.g. MfStruct._Struct(_RECT,{left:10,right:20})
            for _key_,_value_ in IsObject(_init_)?_init_:_pointer_
            {
              If !this["`r"] ; It is not a pointer, assign value
                this[_key_] := _value_
              else if (_value_<>"") ; It is not empty
                If _value_ is integer ; It is a new pointer
                  this[_key_][""]:=_value_
            }
          }
          Return this ;:= new MfStruct._Struct(%_ArrType_%,_pointer_)   ;only Data type was supplied, object/structure has got no members/keys
        } else
          _ArrName_:=_ArrType_,_ArrType_:="UInt"
      }
      If InStr(_ArrType_,"."){ ;check for object that holds structure definition
        Loop,Parse,_ArrType_,.
          If A_Index=1
            _defobj_:=%A_LoopField%
          else _defobj_:=_defobj_[A_LoopField]
      }
      if (!_IsPtr_ && !MfStruct._Struct.HasKey(_ArrType_)){  ; _ArrType_ not found resolve to global variable (must contain struct definition)
          ; If (A_PtrSize=8)
			_offset_ += MfStruct.sizeof(_defobj_?_defobj_:%_ArrType_%,_offset_)-_offset_ - MfStruct.sizeof(_defobj_?_defobj_:%_ArrType_%)
          MfStruct._Struct.___InitField(this,_ArrName_,_offset_,_ArrType_,0,0,_ArrType_,_ArrSize_)
          ; update current union size
        If _union_.MaxIndex()
          _union_size_[_union_.MaxIndex()]:=(_offset_ + MfStruct._Struct[this["`n" _ArrName_]] - _union_[_union_.MaxIndex()]>_union_size_[_union_.MaxIndex()])
                                            ?(_offset_ + MfStruct._Struct[this["`n" _ArrName_]] - _union_[_union_.MaxIndex()]):_union_size_[_union_.MaxIndex()]
        ; if not a union or a union + structure then offset must be moved (when structure offset will be reset below
        If (!_union_.MaxIndex()||_struct_[_struct_.MaxIndex()])
          _offset_+=this[" " _ArrName_] * MfStruct.sizeof(_defobj_?_defobj_:%_ArrType_%) ; move offset
          ;Continue
          
      } else {
        If ((_IsPtr_ || MfStruct._Struct.HasKey(_ArrType_)))
			_offset_+=Mod(_offset_,(_IsPtr_?A_PtrSize:MfStruct._Struct[_ArrType_]))=0
                      ?0:(_IsPtr_?A_PtrSize:MfStruct._Struct[_ArrType_])-Mod(_offset_,(_IsPtr_?A_PtrSize
                      :MfStruct._Struct[_ArrType_]))
        MfStruct._Struct.___InitField(this,_ArrName_,_offset_,_ArrType_,_IsPtr_?"PTR":MfStruct._Struct.HasKey(_ArrType_)?MfStruct._Struct["_" _ArrType_]:_ArrType_,_IsPtr_,_ArrType_,_ArrSize_)
        ; update current union size
        If _union_.MaxIndex()
          _union_size_[_union_.MaxIndex()]:=(_offset_ + MfStruct._Struct[this["`n" _ArrName_]] - _union_[_union_.MaxIndex()]>_union_size_[_union_.MaxIndex()])
                                            ?(_offset_ + MfStruct._Struct[this["`n" _ArrName_]] - _union_[_union_.MaxIndex()]):_union_size_[_union_.MaxIndex()]
        ; if not a union or a union + structure then offset must be moved (when structure offset will be reset below
        If (!_union_.MaxIndex()||_struct_[_struct_.MaxIndex()])
          _offset_+=_IsPtr_?A_PtrSize:(MfStruct._Struct.HasKey(_ArrType_)?MfStruct._Struct[_ArrType_]:%_ArrType_%)*this[" " _ArrName_]
      }
      
      
      ; Check for ENDING union and reset offset and union helpers
      While (SubStr(_LF_BKP_,0)="}"){
        If !_union_.MaxIndex(){
          MsgBox,0, Incorrect structure, missing opening braket {`nProgram will exit now `n%_TYPE_%
          ExitApp
        } ; Increase total size of union/structure if necessary
        _offset_:=_union_[_union_.MaxIndex()] ; reset offset because we left a union or structure
        ,_total_union_size_ := _union_size_[_union_.MaxIndex()]>_total_union_size_?_union_size_[_union_.MaxIndex()]:_total_union_size_
        _union_._Remove(),_struct_._Remove(),_union_size_._Remove(),_LF_BKP_:=SubStr(_LF_BKP_,1,StrLen(_LF_BKP_)-1) ; remove latest items
        If !_union_.MaxIndex(){ ; leaving top union, add offset
					if Mod(_total_union_size_,_align_total_.1)
						_total_union_size_ += _align_total_.1-Mod(_total_union_size_,_align_total_.1)
          _offset_+=_total_union_size_,_total_union_size_:=0
        }
      }
    }
	this.base:=_base_ ; apply new base which uses below functions and uses ___GET for __GET and ___SET for __SET
    If (IsObject(_init_)||IsObject(_pointer_)){ ; Initialization of structures members, e.g. MfStruct._Struct(_RECT,{left:10,right:20})
      for _key_,_value_ in IsObject(_init_)?_init_:_pointer_
      {
        If !this["`r" _key_] ; It is not a pointer, assign value
          this[_key_] := _value_
        else if (_value_<>"") ; It is not empty
          if _value_ is integer ; It is a new pointer
            this[_key_][""]:=_value_
      }
    }
    Return this
  }
  SizeT(_key_=""){
    return MfStruct.sizeof(this["`t" _key_])
  }
  Size(){
    return MfStruct.sizeof(this)
  }
  IsPointer(_key_=""){
    return this["`r" _key_] 
  }
  Type(_key_=""){
    return this["`t" _key_] 
  }
  AHKType(_key_=""){
    return this["`n" _key_] 
  }
  Offset(_key_=""){
    return this["`b" _key_] 
  }
  Encoding(_key_=""){
    return this["`b" _key_] 
  }
  Capacity(_key_=""){
    return this._GetCapacity("`v" _key_)
  }
  Alloc(_key_="",size="",ptrsize=0){
    If _key_ is integer
      ptrsize:=size,size:=_key_,_key_:=""
   If size is integer
      SizeIsInt:=1
    If ptrsize {
      If (this._SetCapacity("`v" _key_,!SizeIsInt?A_PtrSize+ptrsize:size + (size//A_PtrSize)*ptrsize)="")
        MsgBox % "Memory for pointer ." _key_ ". of size " (SizeIsInt?size:A_PtrSize) " could not be set!"
      else {
        DllCall("RtlZeroMemory","UPTR",this._GetAddress("`v" _key_),"UInt",this._GetCapacity("`v" _key_))
			  If (this[" " _key_]>1){
					ptr:=this[""] + this["`b" _key_]
					If (this["`r" _key_] || InStr(",LPSTR,LPCSTR,LPTSTR,LPCTSTR,LPWSTR,LPCWSTR,","," this["`t" _key_] ","))
						NumPut(ptrs:=this._GetAddress("`v" _key_),ptr+0,"PTR")
					else if _key_
						this[_key_,""]:=ptrs:=this._GetAddress("`v" _key_)
					else this[""]:=ptr:=this._GetAddress("`v" _key_),ptrs:=this._GetAddress("`v" _key_)+(SizeIsInt?size:A_PtrSize)
				} else {
	        If (this["`r" _key_] || InStr(",LPSTR,LPCSTR,LPTSTR,LPCTSTR,LPWSTR,LPCWSTR,","," this["`t" _key_] ","))
	          NumPut(ptr:=this._GetAddress("`v" _key_),this[""] + this["`b" _key_],"PTR")
	        else this[""]:=ptr:=this._GetAddress("`v" _key_)
	        ptrs:=ptr+(size?size:A_PtrSize)
				}
        Loop % SizeIsInt?(size//A_PtrSize):1
          NumPut(ptrs+(A_Index-1)*ptrsize,ptr+(A_Index-1)*A_PtrSize,"PTR")
      }
    } else {
      If (this._SetCapacity("`v" _key_,SizeIsInt?size:A_PtrSize)=""){
        MsgBox % "Memory for pointer ." _key_ ". of size " (SizeIsInt?size:A_PtrSize) " could not be set!"
      } else
          NumPut(ptr:=this._GetAddress("`v" _key_),this[""] + this["`b" _key_],"PTR"),DllCall("RtlZeroMemory","UPTR",ptr,"UInt",SizeIsInt?size:A_PtrSize)
    }
    return ptr
  }
  ___NEW(init*){
    this:=this.base
    newobj := this.__Clone(1) ;clone structure and keep pointer (1), it will be changed below
    If (init.MaxIndex() && !IsObject(init.1))
      newobj[""] := init.1
    else If (init.MaxIndex()>1 && !IsObject(init.2))
      newobj[""] := init.2
    else
      newobj._SetCapacity("`a",_StructSize_ := MfStruct.sizeof(this)) ; Set Capacity in key ["`a"]
      ,newobj[""]:=newobj._GetAddress("`a") ; Save pointer in key [""]
      ,DllCall("RtlZeroMemory","UPTR",newobj[""],"UInt",_StructSize_) ; zero-fill memory
    If (IsObject(init.1)||IsObject(init.2))
      for _key_,_value_ in IsObject(init.1)?init.1:init.2
          newobj[_key_] := _value_
    return newobj
  }
  
  ; Clone structure and move pointer for new structure
  ___Clone(offset){
    static _base_:={__GET:MfStruct._Struct.___GET,__SET:MfStruct._Struct.___SET,__SETPTR:MfStruct._Struct.___SETPTR,__Clone:MfStruct._Struct.___Clone,__NEW:MfStruct._Struct.___NEW
          ,IsPointer:MfStruct._Struct.IsPointer,Offset:MfStruct._Struct.Offset,Type:MfStruct._Struct.Type,AHKType:MfStruct._Struct.AHKType,Encoding:MfStruct._Struct.Encoding
          ,Capacity:MfStruct._Struct.Capacity,Alloc:MfStruct._Struct.Alloc,Size:MfStruct._Struct.Size,SizeT:MfStruct._Struct.SizeT}
    If offset=1
      return this
    newobj:={} ; new structure object
    for _key_,_value_ in this ; copy all values/objects
      If (_key_!="`a")
        newobj[_key_]:=_value_ ; add key to new object and assign value
    newobj._SetCapacity("`a",_StructSize_ := MfStruct.sizeof(this)) ; Set Capacity in key ["`a"]
    ,newobj[""]:=newobj._GetAddress("`a") ; Save pointer in key [""]
    ,DllCall("RtlZeroMemory","UPTR",newobj[""],"UInt",_StructSize_) ; zero-fill memory
    If this["`r"]{ ; its a pointer so we need too move internal memory
      NumPut(NumGet(this[""],"PTR")+A_PtrSize*(offset-1),newobj[""],"Ptr")
      newobj.base:=_base_ ;assign base of MfStruct._Struct
    } else ; do not use internal memory, simply assign new pointer to new structure
      newobj.base:=_base_,newobj[]:=this[""] + MfStruct.sizeof(this)*(offset-1)
    return newobj ; return new object
  }
  ___GET(_key_="",p*){
    If (_key_="")           ; Key was not given so structure[] has been called, return pointer to structure
      Return this[""]
		else if !(idx:=p.MaxIndex())
			_field_:=_key_,opt:="~"
		else {
		  ObjInsert(p,1,_key_)
			opt:=ObjRemove(p),_field_:=_key_:=ObjRemove(p)
			for key_,value_ in p
				this:=this[value_]
		}
    If this["`t"] ; structure without keys/members
      _key_:="" ; set _key_ empty so items below will resolve to our structure
    If (opt!="~"){
      If (opt=""){
        If _field_ is integer
          return (this["`r"]?NumGet(this[""],"PTR"):this[""]) + MfStruct.sizeof(this["`t"])*(_field_-1)
        else return this["`r" _key_]?NumGet(this[""]+this["`b" _key_],"PTR"):this[""]+this["`b" _key_] ;+MfStruct.sizeof(this["`t" _key_])*(_field_-1)
      } else If opt is integer
      { ;offset to a item e.g. struct.a[100] ("Uint a[100]")
		; MsgBox % "ja " 
        If (MfStruct._Struct.HasKey("_" this["`t" _key_]) && this[" " _key_]>1) {
				  If (InStr( ",CHAR,UCHAR,TCHAR,WCHAR," , "," this["`t" _key_] "," )){  ; StrGet 1 character only
					Return StrGet(this[""]+this["`b" _key_]+(opt-1) * MfStruct.sizeof(this["`t" _key_]),1,this["`f" _key_])
				  } else if InStr( ",LPSTR,LPCSTR,LPTSTR,LPCTSTR,LPWSTR,LPCWSTR," , "," this["`t" _key_] "," ){ ; StrGet string
					Return StrGet(NumGet(this[""]+this["`b" _key_]+(opt-1)*A_PtrSize,"PTR"),this["`f" _key_])
				  } else {
					Return NumGet(this[""]+this["`b" _key_]+(opt-1) * MfStruct.sizeof(this["`t" _key_]),this["`n" _key_])
				  }
				} else Return new MfStruct._Struct(this["`t" _key_],this[""]+this["`b" _key_]+(opt-1) * MfStruct.sizeof(this["`t" _key_]))
      } else
        return this[_key_][opt]
    } else If _field_ is integer
    { ; array access (must be listed first because otherwise this["`r" _key_] cannot be resolved
      If (_key_){ ; Offset for item
        return this.__Clone(_field_)
      } else if this["`r"] {
        Pointer:=""
        Loop % (this["`r"]-1) ; dip into one step and return a new structure
          pointer.="*"
        If pointer
          Return new MfStruct._Struct(pointer this["`t"],NumGet(this[""],"PTR")+A_PtrSize*(_field_-1))
        else Return new MfStruct._Struct(pointer this["`t"],NumGet(this[""],"PTR") + MfStruct.sizeof(this["`t"])*(_field_-1)).1
      } else if MfStruct._Struct.HasKey("_" this["`t"]) {
        ; If this[" "]
          ; Return new MfStruct._Struct(this["`t"],this[""])
        ; else 
				If (InStr( ",CHAR,UCHAR,TCHAR,WCHAR," , "," this["`t"] "," )){  ; StrGet 1 character only
          Return StrGet(this[""] + MfStruct.sizeof(this["`t"])*(_field_-1),1,this["`f"])
        } else if InStr(",LPSTR,LPCSTR,LPTSTR,LPCTSTR,LPWSTR,LPCWSTR," , "," this["`t"] "," ){ ; StrGet string
					Return StrGet(NumGet(this[""]+A_PtrSize*(_field_-1),"PTR"),this["`f"])
        } else { ; resolve pointer
            Return NumGet(this[""] + MfStruct.sizeof(this["`t"])*(_field_-1),this["`n"])
        }
      } else {
			
				; return this.__Clone(_field_)
				; listVars
				; MsgBox % this[""] "+" MfStruct.sizeof(this["`t"])*(_field_-1) "-" this["`t"]
        Return new MfStruct._Struct(this["`t"],this[""] + MfStruct.sizeof(this["`t"])*(_field_-1))
      }
    } else If this["`r" _key_] { ;pointer
      Pointer:=""
      Loop % (this["`r" _key_]-1) ; dip into one step and return a new structure
          pointer.="*"
      If (_key_=""){
        return this[1][_field_]
      } else {
        Return new MfStruct._Struct(pointer this["`t" _key_],NumGet(this[""]+this["`b" _key_],"PTR"))
      }
    } else if MfStruct._Struct.HasKey("_" this["`t" _key_]) { ; default data type, not pointer
      If (this[" " _key_]>1)
        Return new MfStruct._Struct(this["`t" _key_],this[""] + this["`b" _key_])
      else If (InStr( ",CHAR,UCHAR,TCHAR,WCHAR," , "," this["`t" _key_] "," )){  ; StrGet 1 character only
        Return StrGet(this[""]+this["`b" _key_],1,this["`f" _key_])
      } else if InStr( ",LPSTR,LPCSTR,LPTSTR,LPCTSTR,LPWSTR,LPCWSTR," , "," this["`t" _key_] "," ){ ; StrGet string
        Return StrGet(NumGet(this[""]+this["`b" _key_],"PTR"),this["`f" _key_])
      } else {
        Return NumGet(this[""]+this["`b" _key_],this["`n" _key_])
      }
    } else { ; the field is a non pointer structure
      Return new MfStruct._Struct(this["`t" _key_],this[""]+this["`b" _key_])
    }
  }
  ___SET(_key_,p*){ ;="",_value_=-0x8000000000000000 ,opt="~"){
    If !(idx:=p.MaxIndex()) ; Set new Pointer, here a value was assigned e.g. struct[]:=&var
      return this[""] :=_key_,this._SetCapacity("`a",0) ; free internal memory, it will not be used anymore
    else if (idx=1)
			_value_:=p.1,opt:="~"
		else if (idx>1){
      ObjInsert(p,1,_key_)
			If (p[idx]="")
				opt:=ObjRemove(p),_value_:=ObjRemove(p),_key_:=ObjRemove(p)
      else _value_:=ObjRemove(p),_key_:=ObjRemove(p),opt:="~"
			for key_,value_ in p
				this:=this[value_]
    }
    If this["`t"] ; structure without members
      _field_:=_key_,_key_:="" ; set _key_ empty so it will resolve to our structure
    else _field_:=_key_
    If this["`r" _key_] { ; Pointer
			If opt is integer
        return NumPut(opt,this[""] + this["`b" _key_],"PTR")
      else if this.HasKey("`t" _key_) {
        Pointer:=""
        Loop % (this["`r" _key_]-1) ; dip into one step and return a new structure
          pointer.="*"
        If _key_
          Return (new MfStruct._Struct(pointer this["`t" _key_],NumGet(this[""] + this["`b" _key_],"PTR"))).1:=_value_
        else Return (new MfStruct._Struct(pointer this["`t"],NumGet(this[""],"PTR")))[_field_]:=_value_
      } else If _field_ is Integer
       if (_key_="") ; replace this for the operation
        _this:=this,this:=this.__Clone(_Field_)
      If InStr( ",LPSTR,LPCSTR,LPTSTR,LPCTSTR,LPWSTR,LPCWSTR," , "," this["`t" _key_] "," )
        StrPut(_value_,NumGet(NumGet(this[""]+this["`b" _key_],"PTR"),"PTR"),this["`f" _key_]) ; StrPut char to addr+A_PtrSize
      else if InStr( ",TCHAR,CHAR,UCHAR,WCHAR," , "," this["`t" _key_] "," ){ ; same as above but for 1 Character only
        StrPut(_value_,NumGet(this[""]+this["`b" _key_],"PTR"),this["`f" _key_]) ; StrPut char to addr
      } else
        NumPut(_value_,NumGet(this[""]+this["`b" _key_],"PTR"),this["`n" _key_])
      If _field_ is integer ; restore this after operation
        this:=_this
    } else if (RegExMatch(_field_,"^\d+$") && _key_="") {
      if InStr( ",LPSTR,LPCSTR,LPTSTR,LPCTSTR,LPWSTR,LPCWSTR," , "," this["`t"] "," ){ 
        StrPut(_value_,NumGet(this[""]+A_PtrSize*(_field_-1),"PTR"),this["`f"]) ; StrPut string to addr
      } else if InStr( ",TCHAR,CHAR,UCHAR,WCHAR," , "," this["`t" _key_] "," ){
        StrPut(_value_,this[""] + MfStruct.sizeof(this["`t"])*(_field_-1),this["`f"])
      } else
        NumPut(_value_,this[""] + MfStruct.sizeof(this["`t"])*(_field_-1),this["`n"]) ; NumPut new value to key
    } else if opt is integer
    {
      return NumPut(opt,this[""] + this["`b" _key_],"PTR")
    } else if InStr( ",LPSTR,LPCSTR,LPTSTR,LPCTSTR,LPWSTR,LPCWSTR," , "," this["`t" _key_] "," ){ 
      StrPut(_value_,NumGet(this[""] + this["`b" _key_],"PTR"),this["`f" _key_]) ; StrPut string to addr
    } else if InStr( ",TCHAR,CHAR,UCHAR,WCHAR," , "," this["`t" _key_] "," ){
      StrPut(_value_,this[""] + this["`b" _key_],this["`f" _key_]) ; StrPut character key
    } else
      NumPut(_value_,this[""]+this["`b" _key_],this["`n" _key_]) ; NumPut new value to key
    Return _value_
  }
}
}