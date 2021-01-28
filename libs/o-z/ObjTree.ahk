#include *i <LV>
;~ #include <_Struct>

ObjTree(ByRef obj,Title="ObjTree",Options="+ReadOnly +Resize,GuiShow=w640 h480",ishwnd=-1){
	; Version 1.0.1.0
	static
	; TREEOBJ will hold all running windows and some information about them
	static TREEOBJ:={},parents:={},ReadOnly:={},ReadOnlyLevel:={},objects:={},newObj:={},hwnd:={},EditItem:={},EditKey:={},EditObject:={},TT:={},Changed:={}
				,LV_SortArrow:="LV_SortArrow",ToolTipText,EditValue,G,WM_NOTIFY:=0x4e
	
	; OnMessage WM_NOTIFY structure
	static HDR:=new _Struct("HWND hwndFrom,UINT_PTR idFrom,UINT code,LPTSTR pszText,int cchTextMax,HANDLE hItem,LPARAM lParam") ;NMTVGETINFOTIP
	static TVN_FIRST := 0xfffffe70,TVN_GETINFOTIP := TVN_FIRST - 14 - (A_IsUnicode?0:1),MenuExist:=0
	local Font:="",GuiShow:="",GuiOptions:="",TREEHWND:="",EDITHWND:="",_EditKey:="",DefaultGui:="",FocusedControl:="",Height:="",Width:="",k:="",v:="",Item:="",NewKey:=""
				,option:="",option1:="",option2:="",pos:="",thisHwnd:="",toRemove:="",object:="",TV_Child:="",TV_Item:="",TV_Text:="",TVC:="",TVP:="",LV_CurrRow:="",opt:=""
	If (ishwnd!=-1&&!IsObject(ishwnd)){
		/*
			ObjTree is also used to Monitor messages for TreeView: ObjeTree(obj=wParam,Title=lParam,Options=msg,ishwnd=hwnd)
			when ishwnd is a handle, this routine is taken
		*/
		
		; Using _Struct class we can assign new pointer to our structure
		; This way the structure is available a lot faster and less CPU is used
		HDR[]:=Title
		
		; Check if this message is relevant for our windows
		If (HDR.code!=TVN_GETINFOTIP || !TREEOBJ["_" HDR.hwndFrom])
			Return 
		
		; Set Default Gui
		Gui,% (G:=TREEOBJ["_" HDR.hwndFrom]) ":Default"
		
		; Set Default TreeView
		Gui,TreeView, ObjTreeTreeView%G%
		
		; HDR.Item contains the relevant TV_ID
		TV_GetText(TV_Text,TV_Item:=HDR.hItem)
		
		; Check if this GUI uses a ToolTip object that contains the information in same structure as the TreeView
		If ToolTipText:=TT[G] { ; Gui has own ToolTip object
			
			; following will resolve the item in ToolTip object
			object:=[TV_Text]
			While TV_Item:=TV_GetParent(TV_Item){
				TV_GetText(k,TV_Item)
				object.Insert(k)
			}

			; Resolve our item/value in ToolTip object
			While object.MaxIndex(){
				ToolTipText:=ToolTipText[object.Remove()]
			}
			; Item is not an object and is not empty, display value in ToolTip
			If (ToolTipText!="")
				Return HDR.pszText[""]:=&ToolTipText
		}
		
		; Gui has no ToolTip object or item could not be resolved
		; Get the value of item and display in ToolTip
		object:=parents[G,HDR.hItem]
		
		; Check if Item is an object and if so, display first 20 keys (first 50 chars) and values (first 100 chars)
		If (Parents[G,object]!=HDR.hItem){
			for key,v in object
				If ((IsObject(key)?(Chr(177) " " (&key)):key)=TV_Text){
					If !IsObject(v)
						Return ToolTipText:=v,HDR.pszText[""]:=&ToolTipText
					else If IsFunc(object)
						ToolTipText:="[Func]`t`t" object.Name "`nBuildIn:`t`t" object.IsBuiltIn "`nVariadic:`t" object.IsVariadic "`nMinParams:`t" object.MinParams "`nMaxParams:`t" object.MaxParams
					else
					for key,v in v
					{
						ToolTipText.=(ToolTipText?"`n":"") SubStr(key,1,50) (StrLen(key)>50?"...":"") " = " (IsObject(v)?"[Obj] ":SubStr(v,1,100) (StrLen(v)>100?"...":""))
						If (A_Index>20){
							ToolTipText.="`n...s"
							break
						}
					}
					Return HDR.pszText[""]:=&ToolTipText
				}
				for key,v in Parents[G,HDR.hItem]
				{
					ToolTipText.=(ToolTipText?"`n":"") SubStr(key,1,50) (StrLen(key)>50?"...":"") " = " (IsObject(v)?"[Obj] ":SubStr(v,1,100) (StrLen(v)>100?"...":""))
					If (A_Index>20){
						ToolTipText.="`n...s"
						break
					}
				}
				Return HDR.pszText[""]:=&ToolTipText
		} else { ; Item is an object, display
			ToolTipText:=""
			If IsFunc(object)
				ToolTipText:="[Func]`t`t" object.Name "`nBuildIn:`t`t" object.IsBuiltIn "`nVariadic:`t" object.IsVariadic "`nMinParams:`t" object.MinParams "`nMaxParams:`t" object.MaxParams
			else
				for key,v in object
				{
					ToolTipText.=(ToolTipText?"`n":"") SubStr(key,1,50) (StrLen(key)>50?"...":"") " = " (IsObject(v)?"[Obj] ":SubStr(v,1,100) (StrLen(v)>100?"...":""))
					If (A_Index>20){
						ToolTipText.="`n...s"
						break
					}
				}
			HDR.pszText[""]:= &ToolTipText
		}
		Return
	}
	; Function was not called by Message to the window
	; Create a new ObjTree window
	
	
	; Get the hwnd of default GUI to restore it later
	Gui,+HwndDefaultGui
	
	;find free gui starting at 30
	Loop % (G := 30) { 
	 Gui %G%:+LastFoundExist
	 If !WinExist() ;gui is free
		break
	 G++
	}
	
	; Custom ToolTip object
	; It needs to have same keys/object structure as main object
	; You can leave out keys, then their value will be show
	If IsObject(ishwnd) 
		TT[G]:=ishwnd
	else TT[G]:=""
	
	; Apply properties and Gui options
	If (Options="")
		Options:="+AlwaysOnTop +Resize,GuiShow=w640 h480"
	If RegExMatch(Options,"i)^\s*([-\+]?ReadOnly)(\d+)?\s*$",option)
		Options:="+AlwaysOnTop +Resize,GuiShow=w640 h480",ReadOnly[G]:=option1,ReadOnlyLevel[G]:=option2
	else ReadOnly[G]:="+ReadOnly"
	Loop, Parse, Options, `,, %A_Space%
	{
	 opt := Trim(SubStr(A_LoopField,1,InStr(A_LoopField,"=")-1))
	 If RegExMatch(A_LoopField,"i)([-\+]?ReadOnly)(\d+)?",option)
		ReadOnly[G]:=option1,ReadOnlyLevel[G]:=option2
	 If (InStr("Font,GuiShow,NoWait",opt))
		%opt% := SubStr(A_LoopField,InStr(A_LoopField,"=") + 1,StrLen(A_LoopField))  
	 else GuiOptions:=RegExReplace(A_LoopField,"i)[-\+]?ReadOnly\s?")
	}
	
	; Set new default Gui
	Gui,%G%:Default
	
	; Set font
	if Font
		Gui, Font, % SubStr(Font,1,Pos := InStr(Font,":") - 1), % SubStr(Font,Pos + 2,StrLen(Font)) 
	
	; Get Gui size
	RegExMatch(GuiShow,"\b[w]([0-9]+\b).*\b[h]([0-9]+\b)",size)
	
	; Get hwnd of new window
	Gui,+HwndthisHwnd
	
	; Hwnd will be required later so save it
	hWnd[G]:=thisHwnd
	
	; Apply Gui options and create Gui
	Gui,%GuiOptions% +LastFound +LabelObjTree__
	Gui,Add,Button, x0 y0 NoTab Hidden Default gObjTree_ButtonOK,Show/Expand Object
	Gui,Add,TreeView,% "xs w" (size1*0.3) " h" size2 " ys AltSubmit gObjTree_TreeView +0x800 hwndTREEHWND " ReadOnly[G] " vObjTreeTreeView" G
	Gui,Add,ListView,% "x+1 w" (size1*0.7) " h" (size2*0.5) " ys AltSubmit Checked " ReadOnly[G] " gObjTree_ListView hwndLISTHWND" G " vObjTreeListView" G,[IsObj] Key/Address|Value/Address
	Gui,Add,Edit,% "y+1 w" (size1*0.7) " h" (size2*0.5) " -wrap +HScroll gObjTree_Edit HWNDEDITHWND " ReadOnly[G]
	GuiControl,Disable,Edit1
	TREEOBJ["_" (TREEHWND+0)] := G
	Attach(TREEHWND,"w1/2 h")
	Attach(LISTHWND%G%,"w1/2 h1/2 x1/2 y0")
	Attach(EDITHWND,"w1/2 h1/2 x1/2 y1/2")
	
	; parents will hold TV_Item <> Object relation
	parents[G]:={}
	
	; Convert object to TreeView
	; Also create a clone for our object
	; Changes can be optionally saved when ObjTree is closed when -ReadOnly is used
	If (ReadOnly[G]="-ReadOnly")
		newObj[G]:=ObjTree_Clone(Objects[G]:=obj),parents[G,newObj[G]]:=0,ObjTree_Add(newObj[G],0,parents,G)
	else parents[G,obj]:=0,ObjTree_Add(Objects[G]:=obj,0,parents,G)
	
	; Create Menus to be used for all ObjTree windows (ReadOnly windows have separate Menu)
	if !MenuExist {
		Menu,ObjTree,Add,&Expand,ObjTree_ExpandSelection
		Menu,ObjTree,Add,&Collapse,ObjTree_CollapseSelection
		Menu,ObjTree,Add
		Menu,ObjTree,Add,E&xpand All,ObjTree_ExpandAll
		Menu,ObjTree,Add,C&ollapse All,ObjTree_CollapseAll
		Menu,ObjTree,Add
		Menu,ObjTree,Add,&Insert,ObjTree_Insert
		Menu,ObjTree,Add,I&nsertChild,ObjTree_InsertChild
		Menu,ObjTree,Add
		Menu,ObjTree,Add,&Delete,ObjTree_Delete
		
		Menu,ObjTreeReadOnly,Add,&Expand,ObjTree_ExpandSelection
		Menu,ObjTreeReadOnly,Add,&Collapse,ObjTree_CollapseSelection
		Menu,ObjTreeReadOnly,Add
		Menu,ObjTreeReadOnly,Add,E&xpand All,ObjTree_ExpandAll
		Menu,ObjTreeReadOnly,Add,C&ollapse All,ObjTree_CollapseAll
		
		MenuExist:=1
	}
	
	; Register to Launch this function OnMessage
	OnMessage(WM_NOTIFY,"ObjTree")
	
	; Show our Gui
	Gui,Show,%GuiShow%,%Title%
	
	; Restore Default Gui
	If DefaultGui
		Gui, %DefaultGui%:Default
	
	; Return hwnd of new ObjTree window
	Return thisHwnd
	
	; Backup current Gui number and display Menu
	ObjTree__ContextMenu:
		G:=A_Gui
		If (ReadOnly[G]!="-ReadOnly")
			Menu,ObjTreeReadOnly,Show
		else Menu,ObjTree,Show
	Return
	
	; Insert new Item, launched by Menu
	ObjTree_Insert:
		If A_Gui
			G:=A_Gui
		If (ReadOnly[G]!="-ReadOnly")
			return
		Changed[G]:=1
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		TV_Item:=TV_GetSelection()
		Loop % ReadOnlyLevel[G]
			If !(TV_Item:=TV_GetParent(TV_Item))
				Return
		EditItem[G]:=TV_GetParent(TV_Child:=TV_GetSelection())
		,EditObject[G]:=!EditItem[G]?newObj[G]:parents[G,EditItem[G]]
		,EditObject[G].Insert("")
		,Parents[G,EditItem[G]:=TV_Add(EditObject[G].MaxIndex(),EditItem[G],"Sort")]:=EditObject[G]
		,TV_Modify(EditItem[G],"Select")
		,TV_GetText(TV_Text,TV_Item)
	return
	
	; Insert new Child item, launched by Menu
	ObjTree_InsertChild:
		If A_Gui
			G:=A_Gui
		If (ReadOnly[G]!="-ReadOnly")
			return
		Changed[G]:=1
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		TV_Item:=TV_GetSelection()
		Loop % ReadOnlyLevel[G]
			If !(TV_Item:=TV_GetParent(TV_Item))
				Return
		EditItem[G]:=TV_GetParent(TV_Child:=TV_GetSelection())
		EditObject[G]:=!EditItem[G]?newObj[G]:parents[G,EditItem[G]]
		TV_GetText(_EditKey,TV_Child)
		If IsObject(EditObject[G,EditKey[G]:=_EditKey]){
			_EditKey:=EditObject[G,EditKey[G]].MaxIndex()+1
			EditObject[G,EditKey[G]].Insert(NewKey:=_EditKey?_EditKey:1,"") ;,ObjTree_Add(EditObject[G,EditKey[G]],TV_Child,parents[G])
			,Parents[G,EditItem[G]:=TV_Add(EditObject[G,EditKey[G]].MaxIndex(),TV_Child,"Sort")]:=EditObject[G,EditKey[G]]
			,ObjTree_LoadList(EditObject[G,EditKey[G]],"",G)
		} else 
			EditObject[G,EditKey[G]]:=NewKey:={1:""},parents[G,TV_Child]:=NewKey,parents[G,NewKey]:=TV_Child
			,ObjTree_Add(NewKey,TV_Child,parents,G)
		TV_Modify(TV_Child,"Expand")
		DllCall("InvalidateRect", "ptr", hwnd[G], "ptr", 0, "int", true)
	return
	
	; Delete Item, launched by Menu
	ObjTree_Delete:
		If A_Gui
			G:=A_Gui
		If (ReadOnly[G]!="-ReadOnly")
			return
		Changed[G]:=1
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		TV_Item:=TV_GetSelection()
		Loop % ReadOnlyLevel[G]
			If !(TV_Item:=TV_GetParent(TV_Item))
				Return
		EditObject[G]:=!TV_GetParent(TV_GetSelection())?newObj[G]:parents[G,TV_GetParent(TV_GetSelection())]
		TV_GetText(_EditKey,TV_Item:=TV_GetSelection())
		ObjRemove(EditObject[G],EditKey[G]:=_EditKey)
		for key in EditObject[G]
		{
			EditKey[G]:=key
			break
		}
		ObjTree_TVReload(EditObject[G],TV_Item,EditKey[G],parents,G)
		Return
	return
	
	; Close ObjTree Window
	ObjTree__Close:
		If A_Gui
			G:=A_Gui
		Gui,%G%:+OwnDialogs
		If (ReadOnly[G]="-ReadOnly" && Changed[G]){
			MsgBox,3,Save Changes,Would you like to save changes?
			IfMsgBox Cancel
				Return
			IfMsgBox Yes
			{
				toRemove:={}
				for key in Objects[G]
					toRemove[k]:=key
				for key in toRemove
					Objects[G].Remove(key)
				for key,v in newObj[G]
					Objects[G,key]:=v
			}
		}
		Gui,%G%:Destroy
		newObj[G]:="",Objects[G]:="",parents[G]:="",hwnd[G]:="",TREEOBJ[G]:="",Readonly[G]:="",ReadOnlyLevel[G]:=""
	Return
	
	; Edit control event, update value in ListView and clone of our object
	ObjTree_Edit:
		If A_Gui
			G:=A_Gui
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		If (ReadOnly[G]!="-ReadOnly"||!(EditItem[G]:=LV_GetNext(0)))
			Return
		TV_Item:=TV_GetSelection()
		Loop % ReadOnlyLevel[G]-1
			If !(TV_Item:=TV_GetParent(TV_Item)){
				LV_GetText(_EditKey,EditItem[G],2)
				ControlSetText,Edit1,% EditKey[G]:=_EditKey,% "ahk_id " hwnd[G]
				Return
			}
		EditObject[G]:=!TV_GetParent(TV_GetSelection())?newObj[G]:parents[G,TV_GetParent(TV_GetSelection())]
		LV_GetText(_EditKey,EditItem[G])
		If IsObject(EditObject[G,EditKey[G]:=_EditKey]){
			GuiControl,,Edit1
			GuiControl,Disable,Edit1
			Return
		}
		ControlGetText,EditValue,Edit1,% "ahk_id " hwnd[G]
		LV_Modify(EditItem[G],"",EditKey[G],EditValue)
		EditObject[G,EditKey[G]]:=EditValue
		Changed[G]:=1
	Return
	
	; TreeView events handling
	ObjTree_TreeView:
		If A_Gui
			G:=A_Gui
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		If (ReadOnly[G]="-ReadOnly"){
			If (A_GuiEvent=="E"||(A_GuiEvent="k"&&A_EventInfo=113)){
				If (A_GuiEvent="k")
					EditItem[G]:=TV_GetSelection()
				else EditItem[G]:=A_EventInfo
				EditObject[G]:=!TV_GetParent(EditItem[G])?newObj[G]:parents[G,TV_GetParent(EditItem[G])]
				TV_GetText(_EditKey,EditItem[G])
				EditKey[G]:=_EditKey
				Return
			} else if (EditItem[G]&&A_GuiEvent=="e"){
				TV_Item:=TV_GetSelection()
				Loop % ReadOnlyLevel[G]
					If !(TV_Item:=TV_GetParent(TV_Item))
						Return, TV_Modify(EditItem[G],"Sort",EditKey[G])
				TV_GetText(NewKey,EditItem[G])
				If (NewKey=EditKey[G])
					Return
				else if EditObject[G].HasKey(NewKey){
					Gui,%G%: +OwnDialogs
					MsgBox,4,Existing Item,The new item already exist.`nDo you want to replace it with this item?
					IfMsgBox No 
						Return TV_Modify(EditItem[G],"",EditKey[G])
					Changed[G]:=1
					EditObject[G,NewKey]:=EditObject[G,EditKey[G]],ObjRemove(EditObject[G],EditKey[G])
					return ObjTree_TVReload(EditObject[G],EditItem[G],NewKey,parents,G)
				} else {
					Changed[G]:=1
					EditObject[G,NewKey]:=EditObject[G,EditKey[G]],ObjRemove(EditObject[G],EditKey[G])
					return ObjTree_TVReload(EditObject[G],EditItem[G],NewKey,parents,G)
				}
			} else	If (A_GuiEvent="k"){ ;Key Press
				If A_EventInfo not in 45,46
					Return
				TV_Item:=TV_GetSelection()
				Loop % ReadOnlyLevel[G]
					If !(TV_Item:=TV_GetParent(TV_Item))
						Return
				If (A_EventInfo=45){ ;Insert + Shift && Insert
					Changed[G]:=1
					EditItem[G]:=TV_GetParent(TV_Child:=TV_GetSelection())
					EditObject[G]:=!EditItem[G]?newObj[G]:parents[G,EditItem[G]]
					If (GetKeyState("Shift","P")&&!ReadOnlyLevel[G])
						EditObject[G].Insert(EditKey[G]:={1:""})
						,parents[G,EditItem[G]:=TV_Add(EditObject[G].MaxIndex(),EditItem[G],"Sort")]:=EditKey[G],parents[G,EditKey[G]]:=EditItem[G]
						,ObjTree_Add(EditKey[G],EditItem[G],parents,G)
					else if (GetKeyState("CTRL","P")&&!ReadOnlyLevel[G]){
						TV_GetText(_EditKey,TV_Child)
						If IsObject(EditObject[G,EditKey[G]:=_EditKey]){
							_EditKey:=EditObject[G,EditKey[G]].MaxIndex()+1
							EditObject[G,EditKey[G]].Insert(_EditKey?_EditKey:1,"")
							,Parents[G,EditItem[G]:=TV_Add(EditObject[G,EditKey[G]].MaxIndex(),TV_Child,"Sort")]:=EditObject[G,EditKey[G]]
							,ObjTree_LoadList(EditObject[G,EditKey[G]],"",G)
						} else 
							EditObject[G,EditKey[G]]:=NewKey:={1:""},parents[G,TV_Child]:=NewKey,parents[G,NewKey]:=TV_Child
							,ObjTree_Add(NewKey,TV_Child,parents,G),TV_Modify(TV_Child,"Expand")
					} else 
						EditObject[G].Insert("")
						,parents[G,EditItem[G]:=TV_Add(EditObject[G].MaxIndex(),EditItem[G],"Sort")]:=EditObject[G]
				} else if (A_EventInfo=46) { ;Delete
					Changed[G]:=1
					EditObject[G]:=!TV_GetParent(TV_GetSelection())?newObj[G]:parents[G,TV_GetParent(TV_GetSelection())]
					TV_GetText(_EditKey,TV_Item:=TV_GetSelection())
					ObjRemove(EditObject[G],EditKey[G]:=_EditKey)
					for key in EditObject[G]
					{
						EditKey[G]:=key
						break
					}
					return ObjTree_TVReload(EditObject[G],TV_Item,EditKey[G],parents,G)
				}
				EditKey[G]:="",EditObject[G]:="",EditItem[G]:=""
				GuiControl, +Redraw, ObjTreeTreeView
				DllCall("InvalidateRect", "ptr", hwnd[G], "ptr", 0, "int", true)
				Return
			}
		} else if A_GuiEvent in k,E,e
			Return
		if (A_EventInfo=0)
			Return
		If (A_GuiEvent="-"){
			TV_Modify(A_EventInfo,"-Expand")
			Return
		}
		TV_GetText(TV_Text,A_EventInfo)
		TV_Modify(A_EventInfo,"Select")
		If parents[G].HasKey(A_EventInfo)
			ObjTree_LoadList(parents[G,A_EventInfo],TV_Text,G)
		else
			ObjTree_LoadList(parents[G,TV_GetParent(A_EventInfo)],TV_Text,G)
	Return
	
	; ListView events handling
	ObjTree_ListView:
		If A_Gui
			G:=A_Gui
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		If (ReadOnly[G]="-ReadOnly"){
			If (A_GuiEvent=="E"){
				LV_GetText(_EditKey,A_EventInfo),EditKey[G]:=_EditKey,EditItem[G]:=TV_GetSelection()
				EditObject[G]:=!TV_GetParent(EditItem[G])?newObj[G]:parents[G,TV_GetParent(TV_GetSelection())]
			} else If (A_GuiEvent=="e"){
				TV_Item:=TV_GetSelection()
				Loop % ReadOnlyLevel[G]
					If !(TV_Item:=TV_GetParent(TV_Item)){
						LV_Modify(A_EventInfo,"",EditKey[G])
						Return
					}
				LV_GetText(NewKey,A_EventInfo)
				If (NewKey=EditKey[G])
					Return
				else if EditObject[G].HasKey(NewKey) {
					Gui,%G%: +OwnDialogs
					MsgBox,4,Existing Item,The new item already exist.`nDo you want to replace it with this item?
					IfMsgBox No
					{
						LV_Modify(A_EventInfo,"",EditKey[G])
						Return
					}
					Changed[G]:=1
					EditObject[G,NewKey]:=EditObject[G,EditKey[G]],ObjRemove(EditObject[G],EditKey[G])
					return ObjTree_TVReload(EditObject[G],EditItem[G],NewKey,parents,G)
				} else {
					Changed[G]:=1
					EditObject[G,NewKey]:=EditObject[G,EditKey[G]],ObjRemove(EditObject[G],EditKey[G])
					ObjTree_TVReload(EditObject[G],EditItem[G],NewKey,parents,G)
					return
				}
			}
		}
		If (A_GuiEvent = "ColClick"){
			Return ,IsFunc(LV_SortArrow)?LV_SortArrow.(LISTHWND%G%, A_EventInfo):""
		} else if (A_GuiEvent="k" && A_EventInfo=8){
			If TV_GetParent(TV_GetSelection())
				TV_Modify(TV_GetParent(TV_GetSelection()))
			Gui,+LastFound
			ControlFocus,ObjTreeListView%G%
			return
		} else if (A_GuiEvent="Normal"){
			GuiControl,,Edit1
			GuiControl,Disable,Edit1
			TV_Item:=TV_GetSelection()
			If !(TV_Child:=TV_GetChild(TV_Item))
				TV_Item:=TV_GetParent(TV_Item),TV_Child:=TV_GetChild(TV_Item)
			If (!TV_GetNext(TV_Child) && TV_GetChild(TV_Child) && TV_GetText(TVP,TV_Child) && TV_GetText(TVC,TV_GetParent(TV_Child)) && TVC=TVP)
				If TV_GetParent(TV_Child)
					TV_Child:=TV_GetParent(0)
				else
					TV_Child:=TV_GetNext()
			If !TV_Child
				TV_Child:=TV_GetSelection()
			LV_GetText(LV_Item,A_EventInfo,1)
			While (TV_GetText(TV_Item,TV_Child) && TV_Item!=LV_Item)
				TV_Child:=TV_GetNext(TV_Child)
			If !TV_Child
				Return
			; If (parents[G,parents[G,TV_Child]]!=TV_Child)
				; If !(TV_Child:=parents[G,parents[G,TV_Child]])
					; TV_Child:=TV_GetNext()
			If (TV_GetSelection()!=TV_Child)
				TV_Modify(TV_Child,"Select Expand")
			for key,v in parents[G,TV_Child]
				If (key=LV_Item || (Chr(177) " " (&key))=LV_Item){
					GuiControl,,Edit1,% parents[G,TV_Child,key]
					GuiControl,Enable,Edit1
					Break
				}
			Return
		} else if (A_GuiEvent!="DoubleClick" && !(A_GuiEvent="I" && ErrorLevel="C"))
			Return
	
	; Hidden Default Button
	; Used when Enter is pressed but also used by TreeView and ListView
	ObjTree_ButtonOK:
		If A_Gui
			G:=A_Gui
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		If (A_ThisLabel="ObjTree_ButtonOK"){
			GuiControlGet, FocusedControl, FocusV
			if (FocusedControl = "ObjTreeListView" G){
				Item:=LV_GetNext(0)
			} else if (FocusedControl = "ObjTreeTreeView" G){
				TV_Modify(TV_GetSelection(),"Expand")
				Return 
			}
			If !Item
				Return
		} else Item:=A_EventInfo
		TV_Item:=TV_GetSelection()
		If !(TV_Child:=TV_GetChild(TV_Item))
			TV_Item:=TV_GetParent(TV_Item),TV_Child:=TV_GetChild(TV_Item)
		If (!TV_GetNext(TV_Child) && TV_GetChild(TV_Child) && TV_GetText(TVP,TV_Child) && TV_GetText(TVC,TV_GetParent(TV_Child)) && TVC=TVP)
			If TV_GetParent(TV_Child)
				TV_Child:=TV_GetParent(0)
			else
				TV_Child:=TV_GetNext()
		If !TV_Child
			TV_Child:=TV_GetSelection()
		LV_GetText(LV_Item,Item,1)
		While (TV_GetText(TV_Item,TV_Child) && TV_Item!=LV_Item)
			TV_Child:=TV_GetNext(TV_Child)
		If (A_GuiEvent="I" && ErrorLevel="C")
			LV_Modify(Item,(parents[G,parents[G,TV_Child]]=TV_Child?"":"-")"Check")
		else if (TV_Child)
			TV_Modify(TV_Child,"Select Expand")
	Return
	
	ObjTree_ExpandAll:
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		ObjTree_Expand(TV_GetNext())
	Return
	ObjTree_ExpandSelection:
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		ObjTree_Expand(TV_GetSelection(),1)
	Return
	ObjTree_CollapseAll:
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		ObjTree_Expand(TV_GetNext(),0,1)
		TV_Modify(TV_GetNext())
	Return
	ObjTree_CollapseSelection:
		Gui,%G%:Default
		Gui,TreeView, ObjTreeTreeView%G%
		Gui,ListView, ObjTreeListView%G%
		ObjTree_Expand(TV_GetSelection(),1,1)
	Return
}
ObjTree_Expand(TV_Item,OnlyOneItem=0,Collapse=0){
	Loop {
		If !TV_GetChild(TV_Item)
			TV_Modify(TV_GetParent(TV_Item),(Collapse?"-":"") "Expand")
		else TV_Modify(TV_Item,(Collapse?"-":"") "Expand")
		If (TV_Child:=TV_GetChild(TV_Item))
			ObjTree_Expand(TV_Child,0,Collapse)
	} Until (OnlyOneItem || (!TV_Item:=TV_GetNext(TV_Item)))
}
ObjTree_Add(obj,parent,ByRef p,G){
	k:="",v:=""
	for k,v in obj
	{
		If (IsObject(v) && !p[G].Haskey(v))
			p[G,v]:=TV_Add(IsObject(k)?Chr(177) " " (&k):k,parent,"Sort"),p[G,p[G,v]]:=v
			,ObjTree_Add(v,p[G,v],p,G)
		else
			p[G,lastParent:=TV_Add(IsObject(k)?Chr(177) " " (&k):k,parent,"Sort")]:=IsObject(v)?v:obj
		If (IsObject(k) && !p[G].HasKey(v))
			p[G,k]:=TV_Add(Chr(177) " " (&k),IsObject(v)?p[G,v]:lastParent,"Sort"),p[G,p[G,k]]:=k
			,ObjTree_Add(k,p[G,k],p,G)
	}
}
ObjTree_Clone(obj,e=0){
	k:="",v:=""
	If !e
		e:={(obj):clone:=obj._Clone()}
	else If !e.HasKey(obj)
		e[obj]:=clone:=obj._Clone()
	for k,v in obj
	{
		If IsObject(v){
      If (IsObject(n:=k) && !e.HasKey(n))
         n:=ObjTree_Clone(k,e)
			else if e.HasKey(n)
				n:=e[n]
			If !e.HasKey(v){
				e[v]:=clone[n]:=IsFunc(v)?v:ObjTree_Clone(v,e)
			} else clone[n]:=e[v]
		} else If IsObject(k) {
			If !e.HasKey(k){
				clone[n:=ObjTree_Clone(k,e)]:=e[k]:=clone[n],ObjRemove(clone,k)
			} else clone[e[k]]:=v,ObjRemove(clone,k)
		}
	}
	Return clone
}
ObjTree_TVReload(ByRef obj,TV_Item,Key,ByRef parents,G){ ; Version 1.0.1.0 http://www.autohotkey.com/forum/viewtopic.php?t=69756
	Gui,%G%:Default
	Gui,TreeView, ObjTreeTreeView%G%
	If !(TV_Child:=TV_GetParent(TV_Item))
		TV_Delete(),parents[G]:={}
	else {
		While % TV_GetChild(TV_Child)
			TV_Delete(TV_GetChild(TV_Child))
	}
	ObjTree_Add(obj,TV_Child,parents,G)
	ObjTree_LoadList(obj,Key,G)
	GuiControl, +Redraw, ObjTreeTreeView
	TV_Child:=TV_GetChild(TV_Child)
	While (TV_GetText(TV_Item,TV_Child) && TV_Item!=Key){
		TV_Child:=TV_GetNext(TV_Child)
	}
	TV_Modify(TV_Child,"Select") ;select item
	DllCall("InvalidateRect", "ptr", hwnd[G], "ptr", 0, "int", true)
}
ObjTree_LoadList(obj,text,G){
	LV_CurrRow:=""
	Gui,%G%:Default
	Gui,ListView, ObjTreeListView%G%
	select:=!TV_GetChild(TV_GetSelection())
	LV_Delete()
	GuiControl,,Edit1,
	GuiControl,Disable,Edit1
	for k,v in obj
	{
		LV_Add(((IsObject(v)||IsObject(k))?"Check":"") (select&&text=(IsObject(k)?(Chr(177) " " (&k)):k)?(" Select",LV_CurrRow:=A_Index):"")
					,IsObject(k)?(Chr(177) " " (&k)):k,IsFunc(v)?"[" (v.IsBuiltIn?"BuildIn ":"") (v.IsVariadic?"Variadic ":"") "Func] " v.Name:IsObject(v)?(Chr(177) " " (&v)):v)
		If (LV_CurrRow=A_Index){
			LV_Modify(LV_CurrRow,"Vis Select") ;make sure selcted row it is visible
			GuiControl,Enable,Edit1
			GuiControl,,Edit1,%v%
		}
	}
	Loop 2
		LV_ModifyCol(A_Index,"AutoHdr") ;autofit contents
}