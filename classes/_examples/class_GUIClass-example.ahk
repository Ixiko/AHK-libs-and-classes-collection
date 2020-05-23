#SingleInstance,Force
TVKeep:={1:[],2:[]}
global DefaultTVText:="Press F2 To Clear"
MainWin:=New GUIClass(2,{MarginX:2,MarginY:2})
MakeWin(MainWin)
MainWin:=New GUIClass(1,{MarginX:2,MarginY:2,Background:0,Color:"0xAAAAAA"})
MakeWin(MainWin)
/*
	The Add Method works the same way as any Gui command without Gui,Add,
	Normally the first Text control would look like{
		Gui,Add,Text,w500,Press F1 or resize the window to make something happen
	}it gets changed to{
		Text,w500,Press F1 or resize the window to make something happen
	}
*/
Count:=36
OnExit,1Close
MakeWin(MainWin){
	global TVKeep
	Ver:=FixIE(12)
	/*
		Having either a v or g value will be the "Name" of the Control but if you have both it will default to the v Name
	*/
	MainWin.Add("Text,w500 vMyStatic1"
			 ,"Edit,w500 h200 vMyEdit1 gReport,This would be default if I wasn't changing it below,h"
			 ,"Edit,x+m w200 h200 vMyEdit2 gReport,This control will have focus by default thanks to MainWin.Focus(),h"
			 ,"TreeView,x+m w300 h200 vMyTreeView Checked gReport AltSubmit,,wh"
			 ,"ActiveX,vwb x+m w200 h200,mshtml,x"
			 ,"Hotkey,xm vMyHotkey gReport,,y"
			 ,"ComboBox,x+m vMyCombobox gReport,Items|Go|Here,y"
			 ,"DDL,x+m vMyDDL gReport,DDL|Items|Go|Here,y"
			 ,"DateTime,x+m vMyDateTime gReport,yyyy-MM-dd HH:mm:ss tt,y"
			 ,"ListView,xm w500 r4 vMyListView1 gReport AltSubmit,Column 1|Column 2,yw"
			 ,"ListView,x+m w" 500+MainWin.MarginX " r4 vMyListView2 gReport AltSubmit,Column 1|Column 2,yx"
			 ,"Text,xm,&All Values: (Press Alt+A to get to the Edit below),y"
			 ,"Edit,xm w" 772+MainWin.MarginX*2 " h300 vOutput,,wy"
			 ,"MonthCal,x+m vMyMonthCal gReport,,xy"
			 ,"Radio,gReport vRadio1,First Radio,xy"
			 ,"Radio,gReport vRadio2,Second Radio,xy"
			 ,"Checkbox,gReport vMyCheckBox,My CheckBox,xy"
			 ,"ListBox,gReport vMyListBox +Multi,My|List|Box,xy"
			 ,"Slider,gReport vMySlider AltSubmit,,xy"
			 ,"StatusBar")
	FixIE(Ver)
	;~ MainWin.Full("MyTreeView")	;Add if you want the full tree reported rather than just Selected and/or Checked
	MainWin.Show("My Window")		;Show the Window with the Title of "My Window"
	MainWin.Focus("MyEdit2")			;Set the Focus to "MyEdit2"
	MainWin.SetLV({Control:"MyListView1",AutoHDR:[1],Data:[["Row 1","Text"],["Row 2 A Slightly wider row","More Text"]]})	;Add 2 Rows into the Left ListView
	MainWin.SetLV({Control:"MyListView2",Data:[["Text","Here"]]})	;Add 2 Rows into the Left ListView
	MainWin.SetText("MyEdit1","This is MyEdit1")																;Change the Text of "MyEdit1"
	MainWin.SetText("MyStatic1","Press F1, F2, F3, F4, Drop Files, Select Items or resize the window to make something happen")	;Change the Text of "MyStatic1"
	TVKeep[MainWin.Win].Push(MainWin.SetTV({Text:DefaultTVText,Options:"Select Vis Focus"}))
	wb:=MainWin.ActiveX.wb
	wb.Navigate("about:" (MainWin.Background=0?"<Body Style='Background-Color:black;Color:Grey'>":"") "IE Window")
	while(wb.ReadyState!=4)
		Sleep,10
}
return
/*
	The G-Label that I gave most of the controls above reports here
*/
Report(){
	MainWin:=GUIClass.Table[A_Gui]	;Gets the MainWin Object from the Class Table
	All:=MainWin[]					;Gets all values from the window
	for a,b in All{				;for loop through all the values
		if(b="")
			Continue
		Try
			if(a!="Output"&&((!IsObject(b)&&b)||(IsObject(b)&&b.Count())))
				Msg.=a ":`n"(IsObject(b)?Obj2String(b):b) "`r`n"
	}
	MainWin.SetText("Output","This will be an object with all of the values from the controls you gave a v value to:`r`n" Trim(Msg,"`r`n"))	;Display the values within the Output Control
}
/*
	Required if you want to save the position data of the Window somewhere other than Settings.ini
	You need to save at least the Pos.Text value or you can store Pos.X, Pos.Y...etc separately if you need to
	SavePos(Win,Pos){
		Win will be the Name of the Window
		Pos will be an Object{
			Pos.X:=<X Position>
			Pos.Y:=<Y Position>
			Pos.W:=<Width>
			Pos.H:=<Height>
			Pos.Text:=X<X> Y<Y> W<W> H<H>
		}
	}
	Save the data however you like, either XML, INI, Database...etc
*/
SavePos(Win,Pos){
	if(Pos.Max=0){
		IniWrite,% Pos.Text,Settings.ini,%Win%,Text
		IniDelete,Settings.ini,%Win%,Max
	}else if(Pos.Max=1)
		IniWrite,1,Settings.ini,%Win%,Max
}
/*
	Required if you use SavePos()
	Show(Win){
		Win will be the name of the Window
		
		You need to return an Object
		Pos:="x" <X> " y" <Y> " w" <W> " h" <H>
		Max:=<Maximized State as either a 0 or 1>
		return {Pos:Pos,Max:Max}
	}
*/
Show(Win){
	IniRead,Pos,Settings.ini,%Win%,Text,0
	Pos:=Pos?Pos:(Win=1?"X0":"X" A_ScreenWidth/2)
	IniRead,Max,Settings.ini,%Win%,Max,0
	return {Pos:(Pos?Pos:0),Max:Max}
}
/*
	<Name Of The GUI>ContextMenu()
	Required if you want to monitor the Right Click of most Controls or the GUI Window
*/
1ContextMenu(Control,EventInfo,IsRightClick,X,Y){
	t(Control,EventInfo,IsRightClick,X,Y)
	Sleep,2000
	t()
}
/*
	<Name Of The GUI>Close()
	Fires when someone hits the X of a Window
*/
1Close(){
	global
	1Close:
	MainWin.Exit() ;Exits the script and saves the position of the Window
	return
}
/*
	<Name Of The GUI>Escape()
	Fires when someone hits Escape with the GUI Focused
*/
1Escape(){
	global
	m("You pressed escape on the Dark Themed Window")
	MainWin.Exit()
	ExitApp
}
2Escape(){
	m("You pressed Escape on the Light Themed Window")
	ExitApp
}
/*
	Required if you want to monitor the Dropped Files
	DropFiles(Files,Control){
		Files{
			Array of Files that were Dropped
		}
		Control:=The name of the Control that the files were Dropped into (Optional)
	}
*/
DropFiles(Files,Control){
	global MainWin
	m(Control,Files)
}
F1::
Count++
for a,MainWin in GUIClass.Table{
	MainWin.SetText("MyEdit1",A_TickCount)
	MainWin.SetText("MyEdit2",A_TickCount)
	MainWin.DisableAll()
	MainWin.SetLV({Control:"MyListView1",Clear:1,AutoHDR:1,Data:[["MyListView1",A_TickCount]]})
	Add:=""
	while(StrLen(Add)<Count){
		for a,b in StrSplit("This will Auto-Widen and won't clear "){
			Add.=b
		}Until StrLen(Add)>=Count
	}
	MainWin.SetLV({Control:"MyListView2",AutoHDR:1,Headers:["Changed","Header"],Data:[[Add,A_TickCount]]})
	Random,Random,1,% TV_GetCount()
	TVKeep[MainWin.Win].Push(MainWin.SetTV({Text:A_TickCount,Options:"Select Vis Focus",Parent:TVKeep[MainWin.Win,Random]}))
	MainWin.EnableAll()
}
return
F2::
for a,MainWin IN GUIClass.Table{
	TVKeep[MainWin.Win]:=[]
	MainWin.DisableAll()
	TVKeep[MainWin.Win].Push(MainWin.SetTV({Control:"MyTreeView",Clear:1,Text:DefaultTVText}))
	MainWin.SetLV({Control:"MyListView1",Clear:1})
	MainWin.SetLV({Control:"MyListView2",Clear:1,Headers:["Column 1","Column 2"],AutoHDR:1})
	Count:=37
	MainWin.SetText("MyEdit1","This is MyEdit1")
	MainWin.SetText("MyEdit2","This is MyEdit2")
	TV:=0
	MainWin.EnableAll()
}
return
F3::
for a,b in ["http://www.google.com","https://www.autohotkey.com/assets/images/ahk-logo-no-text241x78-180.png"]{
	wb:=GUIClass.Table[a].ActiveX.wb
	wb.Navigate(b)
	while(wb.ReadyState!=4)
		Sleep,10
	wb.Document.Body.Style.OverFlow:="Auto"
}
return
F4::
m(MainWin.StoredLV.MyListView2,"",MainWin.Get("MyEdit1"))
return
m(x*){
	for a,b in x
		Msg.=IsObject(b)?Obj2String(b):b "`n"
	MsgBox,%Msg%
}
t(x*){
	for a,b in x
		Msg.=IsObject(b)?Obj2String(b):b "`n"
	ToolTip,%Msg%
}
Obj2String(Obj,FullPath:=1,BottomBlank:=0){
	static String,Blank
	if(FullPath=1)
		String:=FullPath:=Blank:=""
	if(IsObject(Obj)){
		for a,b in Obj{
			if(IsObject(b)&&b.OuterHtml)
				String.=FullPath "." a " = " b.OuterHtml
			else if(IsObject(b)&&!b.XML)
				Obj2String(b,FullPath "." a,BottomBlank)
			else{
				if(BottomBlank=0)
					String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
				else if(b!="")
					String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
				else
					Blank.=FullPath "." a " =`n"
			}
	}}
	return String Blank
}
FixIE(Version=0){
	static Key:="Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION",Versions:={7:7000,8:8888,9:9999,10:10001,11:11001} ;Thanks GeekDude
	Version:=Versions[Version]?Versions[Version]:Version
	if(A_IsCompiled)
		ExeName:=A_ScriptName
	else
		SplitPath,A_AhkPath,ExeName
	RegRead,PreviousValue,HKCU,%Key%,%ExeName%
	if(!Version)
		RegDelete,HKCU,%Key%,%ExeName%
	else
		RegWrite,REG_DWORD,HKCU,%Key%,%ExeName%,%Version%
	return PreviousValue
}
#Include Includes\Class GUIClass.ahk