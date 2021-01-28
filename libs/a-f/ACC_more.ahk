;------------------------------------------------------------------------------
; http://www.autohotkey.com/forum/topic24234.html
; ACC.ahk Standard Library
; by Sean
;------------------------------------------------------------------------------


class ACC_OBJID{								;https://msdn.microsoft.com/en-us/library/windows/desktop/dd373606(v=vs.85).aspx
    static    WINDOW                      	:=    0x00000000
    static    SYSMENU                      	:=    0xFFFFFFFF
    static    TITLEBAR                       	:=    0xFFFFFFFE
    static    MENU                           	:=    0xFFFFFFFD
    static    CLIENT                          	:=    0xFFFFFFFC
    static    VSCROLL                       	:=    0xFFFFFFFB
    static    HSCROLL                       	:=    0xFFFFFFFA
    static    SIZEGRIP                       	:=    0xFFFFFFF9
    static    CARET                           	:=    0xFFFFFFF8
    static    CURSOR                        	:=    0xFFFFFFF7
    static    ALERT                            	:=    0xFFFFFFF6
    static    SOUND                         	:=    0xFFFFFFF5
    static    QUERYCLASSNAMEIDX  	:=    0xFFFFFFF4
    static    NATIVEOM                    	:=    0xFFFFFFF0
}
class ACC_STATE {							;https://msdn.microsoft.com/en-us/library/windows/desktop/dd373609(v=vs.85).aspx
    static    NORMAL                   	:=        0
    static    UNAVAILABLE            	:=        0x1
    static    SELECTED                  	:=        0x2
    static    FOCUSED                 	:=        0x4
    static    PRESSED                    	:=        0x8
    static    CHECKED                  	:=        0x10
    static    MIXED                       	:=        0x20
    static    INDETERMINATE        	:=        this.MIXED
    static    READONLY                	:=        0x40
    static    HOTTRACKED           	:=        0x80
    static    DEFAULT                   	:=        0x100
    static    EXPANDED                	:=        0x200
    static    COLLAPSED               	:=        0x400
    static    BUSY                         	:=        0x800
    static    FLOATING                 	:=        0x1000
    static    MARQUEED               	:=        0x2000
    static    ANIMATED                	:=        0x4000
    static    INVISIBLE                   	:=        0x8000
    static    OFFSCREEN              	:=        0x10000
    static    SIZEABLE                   	:=        0x20000
    static    MOVEABLE                	:=        0x40000
    static    SELFVOICING            	:=        0x80000
    static    FOCUSABLE              	:=        0x100000
    static    SELECTABLE               	:=        0x200000
    static    LINKED                      	:=        0x400000
    static    TRAVERSED                	:=        0x800000
    static    MULTISELECTABLE     	:=        0x1000000
    static    EXTSELECTABLE         	:=        0x2000000
    static    ALERT_LOW               	:=        0x4000000
    static    ALERT_MEDIUM         	:=        0x8000000
    static    ALERT_HIGH              	:=        0x10000000
    static    PROTECTED              	:=        0x20000000
    static    VALID                        	:=        0x7fffffff
}
class ACC_ROLE {								;https://msdn.microsoft.com/en-us/library/windows/desktop/dd373608(v=vs.85).aspx
    static    TITLEBAR                               	:=        0x1
    static    MENUBAR                             	:=        0x2
    static    SCROLLBAR                           	:=        0x3
    static    GRIP                                      	:=        0x4
    static    SOUND                                 	:=        0x5
    static    CURSOR                                	:=        0x6
    static    CARET                                   	:=        0x7
    static    ALERT                                    	:=        0x8
    static    WINDOW                              	:=        0x9
    static    CLIENT                                  	:=        0xa
    static    MENUPOPUP                         	:=        0xb
    static    MENUITEM                            	:=        0xc
    static    TOOLTIP                               	:=        0xd
    static    APPLICATION                        	:=        0xe
    static    DOCUMENT                          	:=        0xf
    static    PANE                                     	:=        0x10
    static    CHART                                  	:=        0x11
    static    DIALOG                                	:=        0x12
    static    BORDER                                	:=        0x13
    static    GROUPING                           	:=        0x14
    static    SEPARATOR                           	:=        0x15
    static    TOOLBAR                              	:=        0x16
    static    STATUSBAR                            	:=        0x17
    static    TABLE                                    	:=        0x18
    static    COLUMNHEADER                  	:=        0x19
    static    ROWHEADER                          	:=        0x1a
    static    COLUMN                              	:=        0x1b
    static    ROW                                     	:=        0x1c
    static    CELL                                      	:=        0x1d
    static    LINK                                      	:=        0x1e
    static    HELPBALLOON                      	:=        0x1f
    static    CHARACTER                          	:=        0x20
    static    LIST                                       	:=        0x21
    static    LISTITEM                                	:=        0x22
    static    OUTLINE                               	:=        0x23
    static    OUTLINEITEM                        	:=        0x24
    static    PAGETAB                               	:=        0x25
    static    PROPERTYPAGE                     	:=        0x26
    static    INDICATOR                           	:=        0x27
    static    GRAPHIC                               	:=        0x28
    static    STATICTEXT                           	:=        0x29
    static    TEXT                                      	:=        0x2a
    static    PUSHBUTTON                       	:=        0x2b
    static    CHECKBUTTON                    	:=        0x2c
    static    RADIOBUTTON                     	:=        0x2d
    static    COMBOBOX                          	:=        0x2e
    static    DROPLIST                              	:=        0x2f
    static    PROGRESSBAR                       	:=        0x30
    static    DIAL                                      	:=        0x31
    static    HOTKEYFIELD                        	:=        0x32
    static    SLIDER                                    	:=        0x33
    static    SPINBUTTON                         	:=        0x34
    static    DIAGRAM                              	:=        0x35
    static    ANIMATION                          	:=        0x36
    static    EQUATION                           	:=        0x37
    static    BUTTONDROPDOWN           	:=        0x38
    static    BUTTONMENU                      	:=        0x39
    static    BUTTONDROPDOWNGRID   	:=        0x3a
    static    WHITESPACE                         	:=        0x3b
    static    PAGETABLIST                         	:=        0x3c
    static    CLOCK                                 	:=        0x3d
    static    SPLITBUTTON                        	:=        0x3e
    static    IPADDRESS                            	:=        0x3f
    static    OUTLINEBUTTON                  	:=        0x40
}
class ACC_NAVDIR {						;https://msdn.microsoft.com/en-us/library/windows/desktop/dd373600(v=vs.85).aspx
    static    MIN                                       	:=    0x0
    static    UP                                         	:=    0x1
    static    DOWN                                  	:=    0x2
    static    LEFT                                      	:=    0x3
    static    RIGHT                                   	:=    0x4
    static    NEXT                                     	:=    0x5
    static    PREVIOUS                              	:=    0x6
    static    FIRSTCHILD                           	:=    0x7
    static    LASTCHILD                            	:=    0x8
    static    MAX                                      	:=    0x9
}
class ACC_SELECTIONFLAG {			;https://msdn.microsoft.com/en-us/library/windows/desktop/dd373634(v=vs.85).aspx
    static    NONE                                    	:= 0x0
    static    TAKEFOCUS                          	:= 0x1
    static    TAKESELECTION                    	:= 0x2
    static    EXTENDSELECTION               	:= 0x4
    static    ADDSELECTION                    	:= 0x8
    static    REMOVESELECTION              	:= 0x10
    static    VALID                                    	:= 0x1f
}
class ACC_EVENT {							;https://msdn.microsoft.com/en-us/library/windows/desktop/dd318066(v=vs.85).aspx
    static MIN                                          	:= 0x00000001
    static MAX                                         	:= 0x7FFFFFFF
    static SYSTEM_SOUND                       	:= 0x0001
    static SYSTEM_ALERT                         	:= 0x0002
    static SYSTEM_FOREGROUND           	:= 0x0003
    static SYSTEM_MENUSTART                	:= 0x0004
    static SYSTEM_MENUEND                  	:= 0x0005
    static SYSTEM_MENUPOPUPSTART     	:= 0x0006
    static SYSTEM_MENUPOPUPEND        	:= 0x0007
    static SYSTEM_CAPTURESTART            	:= 0x0008
    static SYSTEM_CAPTUREEND              	:= 0x0009
    static SYSTEM_MOVESIZESTART         	:= 0x000A
    static SYSTEM_MOVESIZEEND            	:= 0x000B
    static SYSTEM_CONTEXTHELPSTART   	:= 0x000C
    static SYSTEM_CONTEXTHELPEND     	:= 0x000D
    static SYSTEM_DRAGDROPSTART       	:= 0x000E
    static SYSTEM_DRAGDROPEND         	:= 0x000F
    static SYSTEM_DIALOGSTART             	:= 0x0010
    static SYSTEM_DIALOGEND               	:= 0x0011
    static SYSTEM_SCROLLINGSTART       	:= 0x0012
    static SYSTEM_SCROLLINGEND         	:= 0x0013
    static SYSTEM_SWITCHSTART             	:= 0x0014
    static SYSTEM_SWITCHEND               	:= 0x0015
    static SYSTEM_MINIMIZESTART           	:= 0x0016
    static SYSTEM_MINIMIZEEND             	:= 0x0017
    static CONSOLE_CARET                    	:= 0x4001
    static CONSOLE_UPDATE_REGION   	:= 0x4002
    static CONSOLE_UPDATE_SIMPLE      	:= 0x4003
    static CONSOLE_UPDATE_SCROLL    	:= 0x4004
    static CONSOLE_LAYOUT                 	:= 0x4005
    static CONSOLE_START_APPLICATION	:= 0x4006
    static CONSOLE_END_APPLICATION 	:= 0x4007
    static OBJECT_CREATE                      	:= 0x8000
    static OBJECT_DESTROY                     	:= 0x8001
    static OBJECT_SHOW                        	:= 0x8002
    static OBJECT_HIDE                          	:= 0x8003
    static OBJECT_REORDER                    	:= 0x8004
    static OBJECT_FOCUS                       	:= 0x8005
    static OBJECT_SELECTION                 	:= 0x8006
    static OBJECT_SELECTIONAD            	:= 0x8007
    static OBJECT_SELECTIONREMOVE   	:= 0x8008
    static OBJECT_SELECTIONWITHIN     	:= 0x8009
    static OBJECT_STATECHANGE           	:= 0x800A
    static OBJECT_LOCATIONCHANGE   	:= 0x800B
    static OBJECT_NAMECHANGE           	:= 0x800C
    static OBJECT_DESCRIPTIONCHANGE	:= 0x800D
    static OBJECT_VALUECHANGE          	:= 0x800E
    static OBJECT_PARENTCHANGE        	:= 0x800F
    static OBJECT_HELPCHANGE            	:= 0x8010
    static OBJECT_DEFACTIONCHANGE 	:= 0x8011
    static OBJECT_ACCELERATORCHANGE	:= 0x8012
}
class VT_CONSTANTS {
    static EMPTY     		:=    0x0  		; No value
    static NULL      		:=    0x1  		; SQL-style Null
    static I2        			:=    0x2  		; 16-bit signed int
    static I4        			:=    0x3  		; 32-bit signed int
    static R4        		:=    0x4  		; 32-bit floating-point number
    static R8        		:=    0x5  		; 64-bit floating-point number
    static CY        		:=    0x6  		; Currency
    static DATE      		:=    0x7  		; Date
    static BSTR      		:=    0x8  		; COM string (Unicode string with length prefix)
    static DISPATCH  	:=    0x9  		; COM object
    static ERROR      	:=    0xA   	; Error code (32-bit integer)
    static BOOL      	:=    0xB  		; Boolean True (-1) or False (0)
    static VARIANT   	:=    0xC 		; VARIANT (must be combined with VT_ARRAY or VT_BYREF)
    static UNKNOWN :=    0xD   	; IUnknown interface pointer
    static DECIMAL   	:=    0xE  		; (not supported)
    static I1        			:=   0x10 		; 8-bit signed int
    static UI1       		:=   0x11 		; 8-bit unsigned int
    static UI2       		:=   0x12 		; 16-bit unsigned int
    static UI4       		:=   0x13 		; 32-bit unsigned int
    static I8        			:=   0x14 		; 64-bit signed int
    static UI8       		:=   0x15 		; 64-bit unsigned int
    static INT       		:=   0x16 		; Signed machine int
    static UINT      		:=   0x17 		; Unsigned machine int
    static RECORD    	:=   0x24 		; User-defined type -- NOT SUPPORTED
    static ARRAY     		:= 0x2000  	; SAFEARRAY
    static BYREF     		:= 0x4000  	; Pointer to another type of value
}
class ACC_FILTERS {
    byDefaultAction(Acc,action){
        bf := Acc.accDefaultAction = action
        return bf
    }

    byDescription(Acc,desc){
        bf := Acc.accDescription = desc
        return bf
    }

    byValue(Acc,value){
        bf := Acc.accValue = value
        return bf
    }

    byHelp(Acc,help){
        bf := Acc.accHelp = help
    }

    byState(Acc,state){
        return Acc.accState & state
    }

    byRole(Acc,role){
        bf := Acc.accRole = role
        return bf
    }

    byName(Acc,name){
        bf := Acc.accName = name
        return bf
    }

    byRegex(Acc,rx){
        info := Acc.accName . ";"
              . Acc.accHelp . ";"
              . Acc.accValue ";"
              . Acc.accDescription . ";"
              . Acc.accDefaultAction
        return RegexMatch(Haystack, rx) > 0
    }
}
class ACC_ChildProxy {
    __New(AccParent,id){
      global ACC_STATE
      this.__accParent         	:= AccParent
      this.__accChildID        	:= id
      this.accParent          		:= AccParent

      try {
        this.accDefaultAction    			:= AccParent.accDefaultAction(id)
      } catch e {
        this.accDefaultAction:=""
      }
      try {
        this.accDescription      			:= AccParent.accDescription(id)
      } catch e {
        this.accDescription:=""
      }
      try {
        this.accHelp             				:= AccParent.accHelp(id)
      } catch e {
        this.accHelp:=""
      }
      try {
        this.accHelpTopic        			:= AccParent.accHelpTopic(id)
      } catch e {
        this.accHelpTopic:=""
      }
      try {
        this.accKeyboardShortcut 		:= AccParent.accKeyboardShortcut(id)
      } catch e {
        this.accKeyboardShortcut:=""
      }
      try {
        this.accName             				:= AccParent.accName(id)
      } catch e {
        this.accName:=""
      }

      try {
        this.accRole             				:= AccParent.accRole(id)
      } catch e {
        this.accRole:=""
      }
      try {
        this.accState            				:= AccParent.accState(id)
      } catch e {
        this.accState:=""
      }
      try {
        this.accValue            				:= AccParent.accValue(id)
      } catch e {
        this.accValue:=""
      }
      try {
        this.accFocus            				:= this.accState && ACC_STATE.FOCUSED
      } catch e {
        this.accFocus:=""
      }
    }

    accDoDefaultAction(){
        return this.__accParent.accDoDefaultAction(this.__accChildID)
    }

    accHitTest(){
        return false
    }
    accLocation(ByRef left, Byref top, ByRef width, ByRef height){
        return this.__accParent.accLocation(left, top, width, height, this.__accChildID)
    }
    accNavigate(){
        return this.__accParent.accNavigate(navDir,this.__accChildID)
    }
    accSelect(flagsSelect){
        return this.__accParent.accSelect(flagsSelect,this.__accChildID)
    }
}


ACC_InitAcc(){
	;COM_Init()
	If Not	DllCall("GetModuleHandle", "str", "oleacc")
	Return	DllCall("LoadLibrary"    , "str", "oleacc")
}
ACC_Term(){
	;COM_Term()
	If   hModule :=	DllCall("GetModuleHandle", "str", "oleacc")
	Return		DllCall("FreeLibrary"    , "Uint", hModule)
}
; modification maybe by jethrow
ACC_ObjectFromEvent(hWnd, idObject, idChild, ByRef _idChild_){
	VarSetCapacity(varChild,16,0)
	DllCall("oleacc\AccessibleObjectFromEvent", "Uint", hWnd, "Uint", idObject, "Uint", idChild, "UintP", Acc, "Uint", &varChild)
	_idChild_ := NumGet(varChild,8)
	Return	Acc
}
ACC_ObjectFromEventJ(ByRef _idChild_, hWnd, idObject, idChild) {
	; modification maybe by jethrow
	ACC_InitAcc()
	if (DllCall("oleacc\AccessibleObjectFromEvent"
	          , "Ptr", hWnd
			  , "UInt", idObject
			  , "UInt", idChild
			  , "Ptr*", acc
			  , "Ptr", VarSetCapacity(varChild, 8 + 2 * A_PtrSize, 0) * 0 + &varChild) = 0) {
		_idChild_:=NumGet(varChild,8,"UInt")
		return ComObjEnwrap(9,acc,1)
	}
}
ACC_ObjectFromPointX(x="", y="", ByRef _idChild_= ""){
	VarSetCapacity(varChild,16,0)
	x<>""&&y<>"" ? pt:=x&0xFFFFFFFF|y<<32 : DllCall("GetCursorPos", "int64P", pt)
	DllCall("oleacc\AccessibleObjectFromPoint", "int64", pt, "UintP", Acc, "Uint", &varChild)
	_idChild_ := NumGet(varChild,8)
	Return	Acc
}
ACC_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "") {
	; modification maybe by jethrow
	ACC_InitAcc()
	if (DllCall("oleacc\AccessibleObjectFromPoint"
			  , "Int64", x == ""||y==""
						 ? 0 * DllCall("GetCursorPos","Int64*",pt) + pt
						 : x & 0xFFFFFFFF | y << 32
			  , "Ptr*", acc
			  , "Ptr", VarSetCapacity(varChild, 8 + 2 * A_PtrSize, 0) * 0 + &varChild) = 0) {
		_idChild_:=NumGet(varChild,8,"UInt")
		return ComObjEnwrap(9,acc,1)
	}
}
ACC_ObjectFromWindow(hWnd, idObject = -4) {
	; modification maybe by jethrow
	ACC_InitAcc()
	if (DllCall("oleacc\AccessibleObjectFromWindow"
			  , "Ptr", hWnd
			  , "UInt", idObject &= 0xFFFFFFFF
			  , "Ptr", -VarSetCapacity(IID,16)
			           + NumPut(idObject == 0xFFFFFFF0
							    ? 0x46000000000000C0
								: 0x719B3800AA000C81
								, NumPut(idObject == 0xFFFFFFF0
								? 0x0000000000020400
								: 0x11CF3C3D618736E0,IID,"Int64"),"Int64")
			  , "Ptr*", acc) = 0)
		return ComObjEnwrap(9,acc,1)
}
ACC_WindowFromObject(Acc){
	DllCall("oleacc\WindowFromAccessibleObject", "Uint", Acc, "UintP", hWnd)
	Return	hWnd
}

ACC_GetAccLocation(Acc, Child=0, byref x="", byref y="", byref w="", byref h="") {

	; from text-capture-acc.ahk

  Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), Child)
  Return  "x" (x:=NumGet(x,0,"Int")) "  "
  .  "y" (y:=NumGet(y,0,"Int")) "  "
  .  "w" (w:=NumGet(w,0,"Int")) "  "
  .  "h" (h:=NumGet(h,0,"Int"))
}
ACC_GetChild(Acc_or_Hwnd, child_path) {
   Acc := WinExist("ahk_id" Acc_or_Hwnd)? Acc_ObjectFromWindow(Acc_or_Hwnd) : Acc_or_Hwnd
   if ComObjType(Acc,"Name") = "IAccessible" {
      Loop Parse, child_path, csv
         Acc := A_LoopField="P"? Acc_Parent(Acc):Acc_Children(Acc,varChildren)[A_LoopField]
      return Acc
   }
}
ACC_GetChildren(Acc) {
    if ComObjType(Acc,"Name") != "IAccessible"
        ErrorLevel := "Invalid IAccessible Object"
    else {
        ACC_InitAcc(), cChildren:=Acc.accChildCount, Children:=[], ErrorLevel=
        if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
            Loop %cChildren%
            {
                ic:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,ic)
                ;I assume NumGet(varChildren,i-8) is ComObjType ~Sancarn
                ComType := NumGet(varChildren,ic-8)
                if (ComType = VT_CONSTANTS.DISPATCH) {
                    Children.push(Acc_Query(child))
                    ObjRelease(child)
                } else if (ComType = VT_CONSTANTS.I4) {
                    Children.push(new ACC_ChildProxy(Acc,child))
                } else {
                    ErrorLevel := "Unknown ComType: " ComType
                    Children.push(child)
                }
            }
            return Children.MaxIndex()?Children:
        } else
            ErrorLevel := "AccessibleChildren DllCall Failed"
    }
    if Acc_Error()
        throw Exception(ErrorLevel,-1)
}
ACC_GetChildrenJ(Acc) {
	; modification maybe by jethrow
	;ACC_InitAcc()
	cChildren := Acc.accChildCount
	Children:=[]

	if (DllCall("oleacc\AccessibleChildren"
	          , "Ptr", ComObjValue(Acc)
			  , "Int", 0
			  , "Int", cChildren
			  , "Ptr", VarSetCapacity(varChildren, cChildren * (8 + 2 * A_PtrSize), 0) * 0
			                                                 + &varChildren
			  , "Int*", cChildren) = 0) {

		Loop % cChildren {
			i := (A_Index - 1) * (A_PtrSize * 2 + 8) + 8
			child:=NumGet(varChildren,i)
			Children.Insert(NumGet(varChildren, i - 8) = 3
					        ? child
							: Acc_Query(child))
			ObjRelease(child)
		}
		return Children
	}
	error := Exception("", -1)
	MsgBox 262420
	     , Acc_Children Failed
		 , % "File:  " error.file "`nLine: " error.line "`n`nContinue Script?"
	IfMsgBox, No
		ExitApp
}
ACC_GetChildrenByRole(Acc, Role) {
    if ComObjType(Acc,"Name")!="IAccessible"
        ErrorLevel := "Invalid IAccessible Object"
    else {
        ACC_InitAcc(), cChildren:=Acc.accChildCount, Children:=[]
        if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
            Loop %cChildren% {
                ic:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,ic)
                if NumGet(varChildren,ic-8)=9
                    AccChild:=Acc_Query(child), ObjRelease(child), Acc_Role(AccChild)=Role?Children.Insert(AccChild):
                else
                    Acc_Role(Acc, child)=Role?Children.Insert(child):
            }
            return Children.MaxIndex()?Children:, ErrorLevel:=0
        } else
            ErrorLevel := "AccessibleChildren DllCall Failed"
    }
    if Acc_Error()
        throw Exception(ErrorLevel,-1)
}
ACC_GetChildrenByName(Acc, name, returnOne:=false){
    items:=acc_Children(Acc,varChildren)
    results := []
    for k,item in items
    {
        if item.accName = name {
            if returnOne {
                return item
            }
            results.push(item)
        }
    }
    return results
}
ACC_GetEnumIndex(Acc, idChild=0) {

	; from text-capture-acc.ahk

	  If Not idChild {
		ChildPos := acc_Location(Acc).pos
		For Each, child in acc_Children(ACC_Parent(Acc),varChildren)
		  If IsObject(child) and acc_Location(child).pos=ChildPos
			Return A_Index
	  }
	  Else {
		ChildPos := acc_Location(Acc,idChild).pos
		For Each, child in acc_Children(Acc,varChildren)
		  If Not IsObject(child) and acc_Location(Acc,child).pos=ChildPos
			Return A_Index
	  }

}
ACC_GetPath(Acc, byref hwnd="") {

	; from text-capture-acc.ahk

	  hwnd 			:= ACC_WindowFromObject(Acc)
	  WinObj 			:= ACC_ObjectFromWindow(hwnd)
	  WinObjPos 	:= ACC_Location(WinObj).pos

	  While ACC_WindowFromObject(Parent:=Acc_Parent(Acc)) = hwnd {
			t2 := ACC_GetEnumIndex(Acc) "." t2
			If acc_Location(Parent).pos = WinObjPos
				Return {Acc:Parent, Path:SubStr(t2,1,-1)}
			Acc := Parent
	  }

	  While ACC_WindowFromObject(Parent:=acc_Parent(WinObj)) = hwnd
			t1.="P.", WinObj:=Parent

Return {Acc:Acc, Path:t1 SubStr(t2,1,-1)}
}
ACC_GetRoleText(nRole) {
    nSize := DllCall("oleacc\GetRoleText"
                   , "Uint", nRole
                   , "Ptr", 0
                   , "Uint", 0)
    VarSetCapacity(sRole, (A_IsUnicode ? 2 : 1) * nSize)
    DllCall("oleacc\GetRoleText"
          , "Uint", nRole
          , "str", sRole
          , "Uint", nSize+1)
    return sRole
}
ACC_GetRootElement(){
    return acc_ObjectFromWindow(0x10010)  ;Root object window handle always appears to be 0x10010
}
ACC_GetStateText(nState) {
    nSize := DllCall("oleacc\GetStateText"
                   , "Uint", nState
                   , "Ptr", 0
                   , "Uint", 0)
    VarSetCapacity(sState, (A_IsUnicode ? 2 : 1) * nSize)
    DllCall("oleacc\GetStateText"
          , "Uint", nState
          , "str", sState
          , "Uint", nSize+1)
    return sState
}
JEE_AccGetPath(Acc, hWnd:="") {
	local
	if (hWnd = "")
		hWnd := ACC_WindowFromObject(Acc)
		, hWnd := DllCall("user32\GetParent", Ptr,hWnd, Ptr)
	vAccPath := ""
	vIsMatch := 0
	if (hWnd = -1) ;get all possible ancestors
		Loop
		{
			vIndex := JEE_AccGetEnumIndex(Acc)
			if !vIndex
				break
			vAccPath := vIndex (A_Index=1?"":".") vAccPath
			Acc := Acc.accParent
		}
	else
		Loop
		{
			vIndex := JEE_AccGetEnumIndex(Acc)
			hWnd2 := ACC_WindowFromObject(Acc)
			if !vIsMatch && (hWnd = hWnd2)
				vIsMatch := 1
			if vIsMatch && !(hWnd = hWnd2)
				break
			vAccPath := vIndex (A_Index=1?"":".") vAccPath
			if vIsMatch
				break
			Acc := Acc.accParent
		}
	return vAccPath
}
JEE_AccGetEnumIndex(oAcc, vChildID:=0) {
	local
	if !vChildID
	{
		Acc_Location(oAcc, 0) ;, vChildPos
		for _, oChild in Acc_GetChildren(Acc_Parent(oAcc))
		{
			Acc_Location(oChild, 0) ;, vPos
			if IsObject(oChild) && (vPos = vChildPos)
				return A_Index
		}
	}
	else
	{
		Acc_Location(oAcc, vChildID) ;, vChildPos
		for _, oChild in Acc_GetChildren(oAcc)
		{
			Acc_Location(oAcc, oChild) ;, vPos
			if !IsObject(oChild) && (vPos = vChildPos)
				return A_Index
		}
	}
}
; pCallback := RegisterCallback("ACC_WinEventProc")
ACC_SetWinEventHook(eventMin, eventMax, pCallback){
	Return	DllCall("SetWinEventHook", "Uint", eventMin, "Uint", eventMax, "Uint", 0, "Uint", pCallback, "Uint", 0, "Uint", 0, "Uint", 0)
}
ACC_UnhookWinEvent(hHook){
	Return	DllCall("UnhookWinEvent", "Uint", hHook)
}
ACC_WinEventProc(hHook, event, hWnd, idObject, idChild, eventThread, eventTime){
	Critical
	Acc := ACC_ObjectFromEvent(hWnd, idObject, idChild, _idChild_)
/*	Add custom codes here!
	...
*/
	;COM_Release(Acc)
}

acc_Error(p="") {
    static setting:=0
    return p=""?setting:setting:=p
}
acc_Child(Acc, idChild=0) {
    try child := Acc.accChild(idChild)
    return child ? Acc_Query(child) : ""
}
acc_ChildCount(Acc){
	If	DllCall(NumGet(NumGet(1*Acc)+32), "Uint", Acc, "UintP", cChildren)=0
	Return	cChildren
}
acc_Children(Acc, ByRef varChildren){
	VarSetCapacity(varChildren,16*(cChildren:=acc_ChildCount(Acc)),0)
	DllCall("oleacc\AccessibleChildren", "Uint", Acc, "int", 0, "int", cChildren, "Uint", &varChildren, "intP", cObtained)
	Return	cObtained
}
acc_ChildrenFilter(Acc, fCondition, value=0, returnOne=false, obj=0){

    items:=acc_Children(Acc,varChildren)
    results := []
    if !IsFunc(fCondition)
        return 0
    if obj =0
        obj:=ACC_FILTERS

    methodCallConvention = instr(fCondition.name, ".") > 0

    for k,item in items
    {
        ;fCondition(this ==> stores variables && other methods of object,item,value)
        if methodCallConvention {
            condition := fCondition.call(obj,item,value)
        } else {
            condition := fCondition.call(item,value)
        }
        if condition {
            if returnOne {
                return item
            }
            results.push(item)
        }
    }
    return results
}
acc_Get(Cmd, ChildPath:="", idChild:=0, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {

    static properties := {Action:"DefaultAction", DoAction:"DoDefaultAction", Keyboard:"KeyboardShortcut"}

    Acc :=   IsObject(WinTitle)? WinTitle : ACC_ObjectFromWindow( WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText), 0 )

    If !Instr(ComObjType(Acc, "Name"), "IAccessible") {

        return "Could not access an IAccessible Object"

    } else {

        ChildPath := StrReplace(ChildPath, "_", A_Space, All)
        AccError	:= acc_Error()
		acc_Error(true)
		cPath   	:= StrSplit(ChildPath, "." , " ")

        Loop, % cPath.MaxIndex() { ; Parse, ChildPath, ., %A_Space%

            try {

				t .= cPath[A_Index] "."

                if cPath[A_Index] is digit
                    Children:=ACC_GetChildren(Acc), mg2:=cPath[A_Index]-1 ; mimic "m2" output in else-statement
                else
                    RegExMatch(cPath[A_Index], "(\D*)(\d*)", mg), Children:=ACC_GetChildrenByRole(Acc, mg1), mg2:=(mg2?mg2:1)


				if Not Children.HasKey(mg2)
                    break
                Acc := Children[mg2]
				MsgBox, % "Path: " RTrim(t, ".") "`nmaxChildren: " Children.MaxIndex() "`nACCRole(" Acc.accRole(0)+1 "): " ACC_GetRoleText(Acc.accRole(0)+1)

            } catch {
                ErrorLevel:="Cannot access ChildPath Item #" A_Index " -> " A_LoopField, acc_Error(AccError)
                if acc_Error()
                    throw Exception("Cannot access ChildPath Item", -1, "Item #" A_Index " -> " A_LoopField)
                return
            }

		}

		If IsObject(acc)
			return acc

        acc_Error(AccError)
        StringReplace, Cmd, Cmd, %A_Space%, , All
        properties.HasKey(Cmd)? Cmd:=properties[Cmd]:
        try {
            if (Cmd = "Location")
                Acc.accLocation(ComObj(0x4003,&xg:=0), ComObj(0x4003,&yg:=0), ComObj(0x4003,&wg:=0), ComObj(0x4003,&hg:=0), idChild)
              , ret_val := "x" NumGet(xg,0,"int") " y" NumGet(yg,0,"int") " w" NumGet(wg,0,"int") " h" NumGet(hg,0,"int")
            else if (Cmd = "Object")
                ret_val := Acc
            else if Cmd in Role,State
                ret_val := Acc_%Cmd%(Acc, idChild+0)
            else if Cmd in ChildCount,Selection,Focus
                ret_val := Acc["acc" Cmd]
            else
                ret_val := Acc["acc" Cmd](idChild+0)
        } catch {
            ErrorLevel := """" Cmd """ Cmd Not Implemented"
            if Acc_Error()
                throw Exception("Cmd Not Implemented", -1, Cmd)
            return
        }
        return ret_val, ErrorLevel:=0
    }

    if acc_Error()
        throw Exception(ErrorLevel,-1)
}
acc_Location(Acc, idChild=0) { ; adapted from Sean's code
    try Acc.accLocation(ComObj(0x4003, &xl:=0)
                      , ComObj(0x4003,&yl:=0)
                      , ComObj(0x4003,&wl:=0)
                      , ComObj(0x4003,&hl:=0)
                      , idChild)
    catch
        return
    return { x:NumGet(xl,0,"int")
           , y:NumGet(yl,0,"int")
           , w:NumGet(wl,0,"int")
           , h:NumGet(hl,0,"int")
           , pos:"x" NumGet(xl,0,"int")
              . " y" NumGet(yl,0,"int")
              . " w" NumGet(wl,0,"int")
              . " h" NumGet(hl,0,"int") }
}
acc_Query(Acc) {
    ; thanks Lexikos - www.autohotkey.com/forum/viewtopic.php?t=81731&p=509530#509530
    try return ComObj(9, ComObjQuery(Acc, "{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}
acc_Parent(Acc) {
    try parent := Acc.accParent
    return parent ? Acc_Query(parent) :
}
acc_Role(Acc, idChild=0) {
    try return ComObjType(Acc,"Name") = "IAccessible"
               ? Acc_GetRoleText(Acc.accRole(idChild))
               : "invalid object"
}
acc_State(Acc, idChild = 0){
/*
	STATE_SYSTEM_NORMAL	:= 0
	STATE_SYSTEM_UNAVAILABLE:= 0x1
	STATE_SYSTEM_SELECTED	:= 0x2
	STATE_SYSTEM_FOCUSED	:= 0x4
	STATE_SYSTEM_PRESSED	:= 0x8
	STATE_SYSTEM_CHECKED	:= 0x10
	STATE_SYSTEM_MIXED	:= 0x20
	STATE_SYSTEM_READONLY	:= 0x40
	STATE_SYSTEM_HOTTRACKED	:= 0x80
	STATE_SYSTEM_DEFAULT	:= 0x100
	STATE_SYSTEM_EXPANDED	:= 0x200
	STATE_SYSTEM_COLLAPSED	:= 0x400
	STATE_SYSTEM_BUSY	:= 0x800
	STATE_SYSTEM_FLOATING	:= 0x1000
	STATE_SYSTEM_MARQUEED	:= 0x2000
	STATE_SYSTEM_ANIMATED	:= 0x4000
	STATE_SYSTEM_INVISIBLE	:= 0x8000
	STATE_SYSTEM_OFFSCREEN	:= 0x10000
	STATE_SYSTEM_SIZEABLE	:= 0x20000
	STATE_SYSTEM_MOVEABLE	:= 0x40000
	STATE_SYSTEM_SELFVOICING:= 0x80000
	STATE_SYSTEM_FOCUSABLE	:= 0x100000
	STATE_SYSTEM_SELECTABLE	:= 0x200000
	STATE_SYSTEM_LINKED	:= 0x400000
	STATE_SYSTEM_TRAVERSED	:= 0x800000
	STATE_SYSTEM_MULTISELECTABLE	:= 0x1000000
	STATE_SYSTEM_EXTSELECTABLE	:= 0x2000000
	STATE_SYSTEM_ALERT_LOW	:= 0x4000000
	STATE_SYSTEM_ALERT_MEDIUM:=0x8000000
	STATE_SYSTEM_ALERT_HIGH	:= 0x10000000
	STATE_SYSTEM_PROTECTED	:= 0x20000000
	STATE_SYSTEM_HASPOPUP	:= 0x40000000
*/
    try return ComObjType(Acc,"Name") = "IAccessible"
               ? ACC_GetStateText(Acc.accState(idChild))
               : "invalid object"
}


COM_GUID4String(ByRef CLSID, String){
	VarSetCapacity(CLSID,16,0)
	DllCall("ole32\CLSIDFromString", "Uint", &String, "Uint", &CLSID)
	Return	&CLSID
}

COM_String4GUID(pGUID){
	VarSetCapacity(String,38*2)
	DllCall("ole32\StringFromGUID2", "Uint", pGUID, "str", String, "int", 39)
	Return	String
}

/*
acc_Child_old(Acc, idChild){
	If	DllCall(NumGet(NumGet(1*Acc)+36), "Uint", Acc, "int64", 3, "int64", idChild, "UintP", AccChild)=0 && AccChild
	Return	acc_Query(AccChild)
}
acc_Query_old(Acc, bunk = ""){
	If	DllCall(NumGet(NumGet(1*Acc)+0), "Uint", Acc, "Uint", COM_GUID4String(IID_IAccessible,bunk ? "{00020404-0000-0000-C000-000000000046}" : "{618736E0-3C3D-11CF-810C-00AA00389B71}"), "UintP", pobj)=0
		DllCall(NumGet(NumGet(1*Acc)+8), "Uint", Acc), Acc:=pobj
	Return	Acc
}
acc_Help(Acc	, idChild = 0){
	If	DllCall(NumGet(NumGet(1*Acc)+60), "Uint", Acc, "int64", 3, "int64", idChild, "UintP", pHelp)=0 && pHelp
	Return	COM_Ansi4Unicode(pHelp) . SubStr(COM_SysFreeString(pHelp),1,0)
}
acc_HelpTopic(Acc, idChild = 0){
	If	DllCall(NumGet(NumGet(1*Acc)+64), "Uint", Acc, "UintP", pHelpFile, "int64", 3, "int64", idChild, "intP", idTopic)=0 && pHelpFile
	Return	COM_Ansi4Unicode(pHelpFile) . SubStr(COM_SysFreeString(pHelpFile),1,0) . "|" . idTopic
}
acc_Description(Acc, idChild = 0){
	If	DllCall(NumGet(NumGet(1*Acc)+48), "Uint", Acc, "int64", 3, "int64", idChild, "UintP", pDescription)=0 && pDescription
	Return	COM_Ansi4Unicode(pDescription) . SubStr(COM_SysFreeString(pDescription),1,0)
}
acc_DefaultAction(Acc, idChild = 0){
	If	DllCall(NumGet(NumGet(1*Acc)+80), "Uint", Acc, "int64", 3, "int64", idChild, "UintP", pDefaultAction)=0 && pDefaultAction
	Return	COM_Ansi4Unicode(pDefaultAction) . SubStr(COM_SysFreeString(pDefaultAction),1,0)
}
acc_DoDefaultAction(Acc, idChild = 0){
	Return	DllCall(NumGet(NumGet(1*Acc)+100), "Uint", Acc, "int64", 3, "int64", idChild)
}
acc_Focus(Acc){
	VarSetCapacity(var,16,0)
	If	DllCall(NumGet(NumGet(1*Acc)+72), "Uint", Acc, "Uint", &var)=0
	Return	(vtType:=NumGet(var,0,"Ushort"))=3 ? NumGet(var,8) : vtType=9 ? "+" . acc_Query(NumGet(var,8)) : ""
}
acc_HitTest(Acc, x = "", y = ""){
	VarSetCapacity(var,16,0)
	x<>""&&y<>"" ? pt:=x&0xFFFFFFFF|y<<32 : DllCall("GetCursorPos", "int64P", pt)
	If	DllCall(NumGet(NumGet(1*Acc)+96), "Uint", Acc, "int64", pt, "Uint", &var)=0
	Return	(vtType:=NumGet(var,0,"Ushort"))=3 ? NumGet(var,8) : vtType=9 ? "+" . acc_Query(NumGet(var,8)) : ""
}
acc_KeyboardShortcut(Acc, idChild = 0){
	If	DllCall(NumGet(NumGet(1*Acc)+68), "Uint", Acc, "int64", 3, "int64", idChild, "UintP", pKeyboardShortcut)=0 && pKeyboardShortcut
	Return	COM_Ansi4Unicode(pKeyboardShortcut) . SubStr(COM_SysFreeString(pKeyboardShortcut),1,0)
}
acc_Name(Acc	, idChild = 0){
	If	DllCall(NumGet(NumGet(1*Acc)+40), "Uint", Acc, "int64", 3, "int64", idChild, "UintP", pName)=0 && pName
	Return	COM_Ansi4Unicode(pName) . SubStr(COM_SysFreeString(pName),1,0)
}
acc_Navigate(Acc, idChild = 0, nDir = 7){

	;NAVDIR_UP	:= 1
	;NAVDIR_DOWN	:= 2
	;NAVDIR_LEFT	:= 3
	;NAVDIR_RIGHT	:= 4
	;NAVDIR_NEXT	:= 5
	;NAVDIR_PREVIOUS	:= 6
	;NAVDIR_FIRSTCHILD:=7
	;NAVDIR_LASTCHILD:= 8

	VarSetCapacity(var,16,0)
	If	DllCall(NumGet(NumGet(1*Acc)+92), "Uint", Acc, "int", nDir, "int64", 3, "int64", idChild, "Uint", &var)=0
	Return	(vtType:=NumGet(var,0,"Ushort"))=3 ? NumGet(var,8) : vtType=9 ? "+" . acc_Query(NumGet(var,8)) : ""
}
acc_Parent_old(Acc){
	If	DllCall(NumGet(NumGet(1*Acc)+28), "Uint", Acc, "UintP", AccParent)=0 && AccParent
	Return	acc_Query(AccParent)
}
acc_Value(Acc, idChild = 0){
	If	DllCall(NumGet(NumGet(1*Acc)+44), "Uint", Acc, "int64", 3, "int64", idChild, "UintP", pValue)=0 && pValue
	Return	COM_Ansi4Unicode(pValue) . SubStr(COM_SysFreeString(pValue),1,0)
}
acc_Role(Acc, idChild = 0){
	VarSetCapacity(var,16,0)
	If	DllCall(NumGet(NumGet(1*Acc)+52), "Uint", Acc, "int64", 3, "int64", idChild, "Uint", &var)=0
	Return	ACC_GetRoleText(NumGet(var,8))
}
acc_Select(Acc, idChild = 0, nFlags = 3){

	;SELFLAG_NONE		:= 0x0
	;SELFLAG_TAKEFOCUS	:= 0x1
	;SELFLAG_TAKESELECTION	:= 0x2
	;SELFLAG_EXTENDSELECTION	:= 0x4
	;SELFLAG_ADDSELECTION	:= 0x8
	;SELFLAG_REMOVESELECTION	:= 0x10

	Return	DllCall(NumGet(NumGet(1*Acc)+84), "Uint", Acc, "int", nFlags, "int64", 3, "int64", idChild)
}
acc_Selection(Acc){
	VarSetCapacity(var,16,0)
	If	DllCall(NumGet(NumGet(1*Acc)+76), "Uint", Acc, "Uint", &var)=0
	Return	(vtType:=NumGet(var,0,"Ushort"))=3 ? NumGet(var,8) : vtType=9 ? "+" . acc_Query(NumGet(var,8)) : vtType=13 ? " " . acc_Query(NumGet(var,8),1) : ""
}

*/

/*
LControl & LButton:: ;get information from object under cursor, 'AccViewer Basic' (cf. AccViewer.ahk)
ComObjError(False)
Acc := Acc_ObjectFromPoint(vChildId)
vAccRoleNum := Acc.accRole(vChildId)
vAccRoleNumHex := Format("0x{:X}", vAccRoleNum)
vAccStateNum := Acc.accState(vChildId)
vAccStateNumHex := Format("0x{:X}", vAccStateNum)
oRect := Acc_Location(Acc, vChildId)

vAccName := Acc.accName(vChildId)
vAccValue := Acc.accValue(vChildId)
vAccRoleText := Acc_GetRoleText(Acc.accRole(vChildId))
vAccStateText := Acc_GetStateText(Acc.accState(vChildId))
vAccStateTextAll := JEE_AccGetStateTextAll(vAccStateNum)
vAccAction := Acc.accDefaultAction(vChildId)
vAccFocus := Acc.accFocus
vAccSelection := JEE_AccSelection(Acc)
StrReplace(vAccSelection, ",",, vCount), vCount += 1
vAccSelectionCount := (vAccSelection = "") ? 0 : vCount
vAccChildCount := Acc.accChildCount
vAccLocation := Format("X{} Y{} W{} H{}", oRect.x, oRect.y, oRect.w, oRect.h)
vAccDescription := Acc.accDescription(vChildId)
vAccKeyboard := Acc.accKeyboardShortCut(vChildId)
vAccHelp := Acc.accHelp(vChildId)
vAccHelpTopic := Acc.accHelpTopic(vChildId)
hWnd := Acc_WindowFromObject(Acc)
vAccPath := "--" ;not implemented
Acc := ""
ComObjError(True)

;get window/control details
if (hWndParent := DllCall("user32\GetParent", Ptr,hWnd, Ptr))
{
	WinGetTitle, vWinTitle, % "ahk_id " hWndParent
	ControlGetText, vWinText,, % "ahk_id " hWnd
	WinGetClass, vWinClass, % "ahk_id " hWnd

	;control hWnd to ClassNN
	WinGet, vCtlList, ControlList, % "ahk_id " hWndParent
	Loop, Parse, vCtlList, `n
	{
		ControlGet, hCtl, Hwnd,, % A_LoopField, % "ahk_id " hWndParent
		if (hCtl = hWnd)
		{
			vWinClass := A_LoopField
			break
		}
	}
	ControlGetPos, vPosX, vPosY, vPosW, vPosH,, % "ahk_id " hWnd
	WinGet, vPName, ProcessName, % "ahk_id " hWndParent
	WinGet, vPID, PID, % "ahk_id " hWndParent
}
else
{
	WinGetTitle, vWinTitle, % "ahk_id " hWnd
	WinGetText, vWinText, % "ahk_id " hWnd
	WinGetClass, vWinClass, % "ahk_id " hWnd
	WinGetPos, vPosX, vPosY, vPosW, vPosH, % "ahk_id " hWnd
	WinGet, vPName, ProcessName, % "ahk_id " hWnd
	WinGet, vPID, PID, % "ahk_id " hWnd
}
hWnd := Format("0x{:X}", hWnd)
vWinPos := Format("X{} Y{} W{} H{}", vPosX, vPosY, vPosW, vPosH)

;truncate variables with long text
vList := "vWinText,vAccName,vAccValue"
Loop, Parse, vList, % ","
{
	%A_LoopField% := StrReplace(%A_LoopField%, "`r", " ")
	%A_LoopField% := StrReplace(%A_LoopField%, "`n", " ")
	if (StrLen(%A_LoopField%) > 100)
		%A_LoopField% := SubStr(%A_LoopField%, 1, 100) "..."
}

vOutput = ;continuation section
(
Name: %vAccName%
Value: %vAccValue%
Role: %vAccRoleText% (%vAccRoleNumHex%) (%vAccRoleNum%)
State: %vAccStateText% (%vAccStateNumHex%)
State (All): %vAccStateTextAll%
Action: %vAccAction%
Focused Item: %vAccFocus%
Selected Items: %vAccSelection%
Selection Count: %vAccSelectionCount%
Child Count: %vAccChildCount%

Location: %vAccLocation%
Description: %vAccDescription%
Keyboard: %vAccKeyboard%
Help: %vAccHelp%
HelpTopic: %vAccHelpTopic%

Child ID: %vChildId%
Path: %vAccPath%

WinTitle: %vWinTitle%
Text: %vWinText%
HWnd: %hWnd%
Location: %vWinPos%
Class(NN): %vWinClass%
Process: %vPName%
Proc ID: %vPID%
)
ToolTip, % vOutput
return

;==================================================

JEE_AccGetStateTextAll(vState){
	;sources: WinUser.h, oleacc.h
	;e.g. STATE_SYSTEM_SELECTED := 0x2
	static oArray := {0x1:"UNAVAILABLE"
	, 0x2:"SELECTED"
	, 0x4:"FOCUSED"
	, 0x8:"PRESSED"
	, 0x10:"CHECKED"
	, 0x20:"MIXED"
	, 0x40:"READONLY"
	, 0x80:"HOTTRACKED"
	, 0x100:"DEFAULT"
	, 0x200:"EXPANDED"
	, 0x400:"COLLAPSED"
	, 0x800:"BUSY"
	, 0x1000:"FLOATING"
	, 0x2000:"MARQUEED"
	, 0x4000:"ANIMATED"
	, 0x8000:"INVISIBLE"
	, 0x10000:"OFFSCREEN"
	, 0x20000:"SIZEABLE"
	, 0x40000:"MOVEABLE"
	, 0x80000:"SELFVOICING"
	, 0x100000:"FOCUSABLE"
	, 0x200000:"SELECTABLE"
	, 0x400000:"LINKED"
	, 0x800000:"TRAVERSED"
	, 0x1000000:"MULTISELECTABLE"
	, 0x2000000:"EXTSELECTABLE"
	, 0x4000000:"ALERT_LOW"
	, 0x8000000:"ALERT_MEDIUM"
	, 0x10000000:"ALERT_HIGH"
	, 0x20000000:"PROTECTED"
	, 0x40000000:"HASPOPUP"}
	vNum := 1
	Loop, 30
	{
		if vState & vNum
			vOutput .= oArray[vNum] " "
		vNum <<= 1 ;multiply by 2
	}
	vOutput := RTrim(vOutput)
	return Format("{:L}", vOutput)
}

;==================================================

JEE_AccSelection(Acc){
	vSel := Acc.accSelection ;if one item selected, gets index, if multiple items selected, gets indexes as object
	if IsObject(vSel)
	{
		oSel := vSel, vSel := ""
		while oSel.Next(vValue, vType)
			vSel .= (A_Index=1?"":",") vValue
		oSel := ""
	}
	return vSel
}

;==================================================
*/

acc_Hex(num){
	old := A_FormatInteger
	SetFormat, Integer, H
	num += 0
	SetFormat, Integer, %old%
	Return	num
}