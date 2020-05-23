Class GUIClass{
	static Table:=[],ShowList:=[]
	__Get(x*){
		if(x.1)
			return this.Var[x.1]
		return this.Add()
	}__New(Win:=1,Info:=""){
		static Defaults:={Color:0,Size:10,MarginX:5,MarginY:5}
		for a,b in Defaults
			if(Info[a]="")
				Info[a]:=b
		SetWinDelay,-1
		Gui,%Win%:Destroy
		Gui,%Win%:+HWNDHWND -DPIScale
		Gui,%Win%:Margin,%MarginX%,%MarginY%
		Gui,%Win%:Font,% "s" Info.Size " c" Info.Color,Courier New
		if(Info.Background!="")
			Gui,%Win%:Color,% Info.Background,% Info.Background
		this.MarginX:=Info.MarginX,this.MarginY:=Info.MarginY,this.All:=[],this.GUI:=[],this.HWND:=HWND,this.Con:=[],this.ID:="ahk_id" HWND,this.Win:=Win,GUIClass.Table[Win]:=this,this.Var:=[],this.LookUp:=[],this.ActiveX:=[],this.StoredLV:=[],this.Background:=Info.Background,this.Color:=Info.Color
		for a,b in {Border:A_OSVersion~="^10"?3:0,Caption:DllCall("GetSystemMetrics",Int,4,Int)}
			this[a]:=b
		Gui,%Win%:+LabelGUIClass.
		Gui,%Win%:Default
		return this
	}Add(Info*){
		static
		if(Info.1=""||Info.1.Get){
			Var:=[],Get:=Info.1.Get!=""?{(Info.1.Get):this.Var[Info.1.Get]}:this.Var
			Gui,% this.Win ":Submit",Nohide
			Try
				for a,b in Get{
					if(b.Type="s")
						Var[a]:=b.sc.GetUNI()
					else if(b.Type="ListView"){
						Var[a]:=[],this.Default(a)
						while(Next:=LV_GetNext(Next)){
							Obj:=Var[a,Next]:=[]
							Loop,% LV_GetCount("Columns")
								LV_GetText(Text,Next,A_Index),Obj.Push(Text)
						}
					}else if(b.Type="TreeView"){
						Var[a]:=[],this.Default(a),TV:=TV_GetSelection()
						while(Next:=TV_GetNext(Next,(this.All[a].Full?"F":"C")))
							Var[a].Push({TV:Next,Checked:(TV_Get(Next,"Checked")?1:0),Expand:(TV_Get(Next,"Expand")?1:0),Bold:(TV_Get(Next,"Bold")?1:0)}),Found:=Found?Found:TV=Next
						if(!Found)
							Var[a].Push({TV:TV,Checked:0,Expand:(TV_Get(TV,"Expand")?1:0),Bold:(TV_Get(TV,"Bold")?1:0)})
					}else
						Var[a]:=%a%
				}return Var,Found:=""
		}for a,b in Info{
			i:=StrSplit(b,",")
			if(i.1="ComboBox")
				WinGet,ControlList,ControlList,% this.ID
			if(i.1="s")
				Pos:=RegExReplace(i.2,"OU)\s*\b(v.+)\b"),sc:=New s(1,{Pos:Pos}),HWND:=sc.sc
			else
				Gui,% this.Win ":Add",% i.1,% i.2 " HWNDHWND",% i.3
			if(RegExMatch(i.2,"OU)\bg(.*)\b",Label))
				Label:=Label.1
			if(RegExMatch(i.2,"OU)\bv(.*)\b",Var))
				this.Var[Var.1]:={HWND:HWND,Type:i.1,sc:sc}
			this.Con[HWND]:=[],Name:=Var.1?Var.1:Label,this.Con[HWND,"Name"]:=Name,Name:=Var.1?Var.1:Label?Label:"Control" A_TickCount A_MSec
			if(i.4!="")
				this.Con[HWND,"Pos"]:=i.4,this.Resize:=1
			this.All[Name]:={HWND:HWND,Name:Name,Label:Label,Type:i.1,ID:"ahk_id" HWND,sc:sc},sc:=""
			if(i.1="ComboBox"){
				WinGet,ControlList2,ControlList,% this.ID
				Obj:=StrSplit(ControlList2,"`n"),LeftOver:=[]
				for a,b in Obj
					LeftOver[b]:=1
				for a,b in Obj2:=StrSplit(ControlList,"`n")
					LeftOver.Delete(b)
				for a in LeftOver{
					if(!InStr(a,"ComboBox")){
						ControlGet,Married,HWND,,%a%,% this.ID
						this.LookUp[Name]:={HWND:HWND,Married:Married,ID:"ahk_id" Married+0,Name:Name,Type:"Edit"}
			}}}if(!this.LookUp[Name]&&Name)
				this.LookUp[Name]:={HWND:HWND,ID:"ahk_id" HWND,Name:Name,Label:Label,Type:i.1}
			if(i.1="ActiveX")
				VV:=Var.1,this.ActiveX[Name]:=%VV%
			Name:=""
	}}Close(a:=""){
		this:=GUIClass.Table[A_Gui],(Func:=Func("SavePos"))?Func.Call(this.Win,this.WinPos()):this.SavePos(),(Func:=Func(A_Gui "Close"))?Func.Call():""
	}ContextMenu(x*){
		this:=GUIClass.Table[A_Gui],x.1:=this.GetName(x.1),(Function:=Func(A_Gui "ContextMenu"))?Function.Call(x*)
	}Default(Control){
		Gui,% this.Win ":Default"
		Obj:=this.LookUp[Control]
		if(Obj.Type~="TreeView|ListView")
			Gui,% this.Win ":" Obj.Type,% Obj.HWND
	}DisableAll(){
		for a,b in this.All{
			if(b.Label)
				GuiControl,1:+g,% b.HWND
			GuiControl,1:-Redraw,% b.HWND
		}
	}DropFiles(Info*){
		this:=GUIClass.Table[A_Gui],Info.2:=this.GetName(Info.2),(Fun:=Func("DropFiles"))?Fun.Call(Info*)
	}EnableAll(){
		for a,b in this.All{
			if(b.Label)
				GuiControl,% this.Win ":+g" b.Label,% b.HWND
			GuiControl,% this.Win ":+Redraw",% b.HWND
	}}Escape(){
		KeyWait,Escape,U
		this:=GUIClass.Table[A_Gui],(Func:=Func("SavePos"))?Func.Call(this.Win,this.WinPos()):this.SavePos(),(Esc:=Func(A_Gui "Escape"))?Esc.Call()
		return 
	}Exit(){
		Exit:
		(Save:=Func("SavePos"))?Save.Call(this.Win,this.WinPos(this.HWND)):this.SavePos()
		ExitApp
		return
	}Focus(Control){
		this.Default(Control)
		ControlFocus,,% this.LookUp[Control].ID
	}Full(Control,Enable:=1){
		this.All[Control].Full:=Enable
	}Get(Val){
		return this.Add({Get:Val})
	}GetFocus(){
		ControlGetFocus,Focus,% this.ID
		ControlGet,HWND,HWND,,%Focus%,% this.ID
		return this.Con[HWND].Name
	}GetName(HWND){
		return this.Con[HWND].Name
	}GetPos(){
		Detect:=A_DetectHiddenWindows
		DetectHiddenWindows,On
		Gui,% this.Win ":Show",AutoSize Hide
		WinGet,CL,ControlListHWND,% this.ID
		Pos:=This.Winpos(),WW:=Pos.W,WH:=Pos.H,Flip:={X:"WW",Y:"WH"}
		for Index,HWND In StrSplit(CL,"`n"){
			Obj:=this.GUI[HWND]:=[]
			ControlGetPos,x,y,w,h,,ahk_id%hwnd%
			for c,d in StrSplit(this.Con[HWND].Pos)
				d~="w|h"?(obj[d]:=%d%-w%d%):d~="x|y"?(Obj[d]:=%d%-(d="y"?WH+this.Caption+this.Border:WW+this.Border))
		}DetectHiddenWindows,%Detect%
	}GetTV(Control){
		this.Default(Control)
		return TV_GetSelection()
	}LoadPos(){
		IniRead,Pos,Settings.ini,% this.Win,Text,0
		IniRead,Max,Settings.ini,% this.Win,Max,0
		return {Pos:(Pos?Pos:0),Max:Max}
	}SavePos(){
		Pos:=this.WinPos()
		if(Pos.Max=0){
			IniWrite,% Pos.Text,Settings.ini,% this.Win,Text
			IniDelete,Settings.ini,% this.Win,Max
		}else if(Pos.Max=1)
			IniWrite,1,Settings.ini,% this.Win,Max
	}SetText(Control,Text:=""){
		this.Default(Control)
		if((sc:=this.Var[Control].sc).sc)
			Len:=VarSetCapacity(tt,StrPut(Text,"UTF-8")-1),StrPut(Text,&tt,Len,"UTF-8"),sc.2181(0,&tt)
		else
			GuiControl,% this.Win ":",% this.Lookup[Control].HWND,%Text%
	}SetLV(Info){
		this.Default(Info.Control)
		if(Info.Headers){
			Loop,% LV_GetCount("Columns"){
				LV_GetText(Text,0,A_Index)
				if(Text!=Info.Headers[A_Index]){
					LV_Delete(),this.StoredLV[Info.Control]:=[]
					while(LV_GetCount("Columns"))
						LV_DeleteCol(1)
					for a,b in Info.Headers
						LV_InsertCol(A_Index,"",b)
		}}}if(Info.Clear)
			LV_Delete(),this.StoredLV[Info.Control]:=[]
		if(!this.StoredLV[Info.Control])
			this.StoredLV[Info.Control]:=[]
		for a,b in Info.Data
			LV_Add(Info.Options,b*),this.StoredLV[Info.Control].Push(b)
		if(Info.AutoHDR){
			if(Info.AutoHDR=1)
				Loop,% LV_GetCount("Columns")
					LV_ModifyCol(A_Index,"AutoHDR")
			else
				for a,b in Info.AutoHDR
					LV_ModifyCol(b,"AutoHDR")
		}
	}SetTV(Info){
		this.Default(Info.Control),(Info.Clear)?TV_Delete():"",(Info.Delete)?TV_Delete(Info.Delete):"",(Info.Text)?(TV:=TV_Add(Info.Text,(Info.Parent=1?TV_GetSelection():Info.Parent),Info.Options)):"",(Info.Text&&Info.Options&&Info.TV)?TV_Modify(Info.TV,Info.Options,Info.Text):""
		return TV
	}Show(name){
		this.GetPos(),Pos:=this.Resize=1?"":"AutoSize",this.name:=name
		if(this.Resize=1)
			Gui,% this.Win ":+Resize"
		GUIClass.ShowList.Push(this)
		this.ShowWindow()
	}ShowWindow(){
		while(this:=GUIClass.Showlist.Pop()){
			if(Show:=Func("Show"))
				Pos:=Show.Call(this.Win)
			else
				Pos:=this.LoadPos()
			Gui,% this.Win ":Show",Hide
			Pos1:=this.WinPos(),MinW:=Pos1.W,MinH:=Pos1.H
			Gui,% this.Win ":Show",% Pos.Pos,% this.Name
			if(this.Resize!=1)
				Gui,% this.Win ":Show",AutoSize
			if(Pos.Max)
				WinMaximize,% this.ID
			Gui,% this.Win ":+MinSize" MinW "x" MinH
			WinActivate,% this.id
		}
	}Size(){
		this:=IsObject(this)?this:GUIClass.Table[A_Gui],pos:=this.Winpos()
		for a,b in this.GUI
			for c,d in b
				GuiControl,% this.Win ":" (this.All[this.Con[a].Name].Type="ActiveX"?"Move":"MoveDraw"),%a%,% c (c~="y|h"?pos.h:pos.w)+d
	}WinPos(HWND:=0){
		VarSetCapacity(Rect,16),DllCall("GetClientRect",Ptr,(HWND?HWND:this.HWND),Ptr,&Rect)
		WinGetPos,X,Y,,,% (HWND?"ahk_id" HWND:this.AhkID)
		W:=NumGet(Rect,8,Int),H:=NumGet(Rect,12,Int),Text:=(X!=""&&Y!=""&&W!=""&&H!="")?"X" X " Y" Y " W" W " H" H:""
		WinGet,Max,MinMax,% this.ID
		return {X:X,Y:Y,W:W,H:H,Text:Text,Max:Max}
	}
}