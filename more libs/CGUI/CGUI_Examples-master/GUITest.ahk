SetBatchlines, -1
MyWindow := new CMyWindow("first") ;Create an instance of this window class
;~ MySecondWindow := new CMyWindow("second") ;Create a second instance of this window class
return

#include <CGUI>
Class CMyWindow Extends CGUI
{
	lvItems			:= this.AddControl("ListView", "lvItems", "x12 y12 w301 h155 Checked", "Field 1|Field 2")
	btnAdd				:= this.AddControl("Button", "btnAdd", "x319 y12 w75 h23", "Add")
	btnRemove		:= this.AddControl("Button", "btnRemove", "x319 y41 w75 h23", "Remove")
	chkChecked	:= this.AddControl("Radio", "chkChecked", "x13 y174 w69 h17 Disabled", "Checked")
	chkChecked2	:= this.AddControl("Radio", "chkChecked2", "x313 y174 w69 h17", "Checked")
	txtField1			:= this.AddControl("Edit", "txtField1", "x99 y174 w104 h20 Disabled", "")
	txtField2			:= this.AddControl("Edit", "txtField2", "x209 y174 w104 h20 Disabled", "")
	btnSave			:= this.AddControl("Button", "btnSave", "x319 y144 w75 h23", "Save")
	btnLoad			:= this.AddControl("Button", "btnLoad", "x319 y115 w75 h23", "Load")
	picTest			:= this.AddControl("Picture", "picTest", "x500 y500 w200 h-1", A_ScriptDir "\Res\7+-w.ico")
	prgTest			:= this.AddControl("Hotkey", "prgTest", "x300 y300 w100 h100", 50)
	comboBox		:= this.AddControl("ComboBox", "comboBox", "x100 y400", "a|b|c")
	statBar			:= this.AddControl("StatusBar", "statBar", "", "test")
	sometab			:= this.AddControl("Tab", "sometab", "x20 y200 w200 h200", "tab1|tab2|tab3")
	tree					:= this.AddControl("TreeView", "tree", "x300 y600 w100 h200 -Readonly", "")
	sysLink			:= this.AddControl("SysLink", "sysLink", "x800 y500", "For more information about AutoHotkey <A HREF=""http://www.autohotkey.com/forum"">visit the forum</A>, please.")
	__New(title)
	{
		this.Title := Title
		this.Resize := true
		this.MinSize := "500x"
	
		this.chkChecked.AddControl("Text", "test1", "x400 y700", "bla", 1)
		this.chkChecked2.AddControl("Text", "test1", "x400 y720", "bla", 1)
		this.txtField2.AddUpDown(2, 40)
		this.lvItems.IndependentSorting := true
		this.lvItems.Items.Add("", "test2", "test2") ;variadic function
		this.lvItems.Items[1].SetIcon(A_ScriptDir "\Res\7+-w.ico", 1) ;Set icon and icon number
		this.lvItems.Items.Add("", "test3", "test3") ;variadic function
		this.lvItems.Items[1].AddControl("Text", "test1", "x400 y600", "bla", 1)
		this.lvItems.Items[2].AddControl("Text", "test1", "x500 y600", "bla", 1)
		;~ GuiControl, % this.GUINum ":-Smooth", % this.prgTest.ClassNN
		;~ this.prgTest.Vertical := 1
		;~ this.lvItems.Items[1].Icon := A_ScriptDir "\Res\7+-w.ico" ;Use first icon.
		;~ this.lvItems.Items[1].IconNumber := 2 ;Use 2nd icon. Beware that doing this will result in a second icon stored in the imagelist, so do not use this if you are concerned about memory
		this.comboBox.Items.Add("d")
		this.comboBox.Tooltip := "Blup" ;combobox consists of edit + drop down button control, this will show tooltip on both
		this.comboBox.SelectedIndex := 3
		this.combobox.text := "a"
		this.combobox.items[1].AddControl("edit", "txtblup", "x200 y250", "haha", 1)
		this.lvItems.tooltip := "List"
		this.btnSave.Tooltip := "SAAAAAVEEEE"
		this.btnLoad.Tooltip := "LOOOOAAAAAD"
		this.sometab.Tabs[1].AddControl("Text", "tabtext", "", "text")
		this.sometab.Tabs[1].Controls.tabtext.Link := 1
		;~ msgbox % this.sometab.Tabs[1]._.TabNumber
		this.sometab.Tabs[1].Icon := A_AHKPath
		this.sometab.Tabs[2].Icon := A_ScriptDir "\Res\7+-w.ico"
		this.lvItems.HotTrack := 1
		this.statBar.Parts.Add("bla")
		this.statBar.Parts[1].Icon := A_AHKPath
		this.statBar.Parts[1] := {text : "blup", width : 50}
		this.statBar.Parts := [{Text : "blup", Width : 200}, {Text : "bla"}]
		this.picTest.Picture := A_AHKPath
		T1 := this.tree.Items.Add("T1")
		T11 := T1.Add("T11")
		T11.AddControl("Text", "test1", "x100 y600", "hallo11")
		T11.Icon := A_AHKPath
		T12 := T1.Add("T12")
		T12.AddControl("Text", "test1", "x100 y600", "bla")
		T12.Icon := ""
		T13 := T1.Add("T13")
		T131 := T13.Add("T131")
		T2 := this.tree.Items.Add("T2")
		T21 := T2.Add("T21")
		this.txtField2.Max := 5
		;~ for index, Item in this.Tree.Items[1]
			;~ msgbox % Item.Text
		;~ T1[3].Remove(1)
		T1[3].Text := "bluP"
		T1[3].Bold := 1
		;~ T1[3].Move(4)
		this.tree.HotTrack := 1
		;~ this.Add("ActiveX", "explorer", "x400 y400 w200 h200", "Shell.Explorer")
		;~ this.explorer._.Object.Navigate("http://www.google.de")
		;~ this.explorer.Navigate("http://www.google.de")
		;~ msgbox % this.picTest.Picture
		;~ this.statBar.Parts.Remove(1)
		;~ this.lvItems.Items[1].Checked := true
		;~ msgbox % this.lvItems.Items[1][1]
		;~ this.lvItems.Items[1].SetUnsortedIndex(1, 20, this.lvItems.hwnd)
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		;~ this.ValidateOnFocusLeave := true
		this.OnGUIMessage(0x200, "MouseMove")
		this.Menu1 := New CMenu("Main")
		this.Menu1.AddMenuItem("hallo", "hallo")
		this.Menu1[1].Text := "Test"
		this.Menu1[1].Checked := true
		this.Menu1[1].Enabled := false
		this.Menu1.AddSubMenu("sub1", "Test")
		this.Menu1[2].AddMenuItem("blup", "blup")
		sub2 := New CMenu("sub2")
		sub2.AddMenuItem("blah", "blah")
		this.Menu1.AddSubMenu("sub2", sub2)
		sub2.Icon := A_AHKPath
		this.Menu1.DeleteMenuItem(1)
		this.slider := this.AddControl("Slider", "slider", "x600 y200", 20)
		;~ this.Menu(this.Menu1) ;It seems a menu can't be used for context and menu bar at once?
		this.Show("")
		return this
	}
	Slider_SliderMoved()
	{
		MsgBox % this.Slider.Value
	}
	sometab_Click(Item)
	{
		MsgBox % item.Text
	}
	ContextMenu()
	{
		ToolTip context
		this.ShowMenu(this.Menu1)
	}
	blup()
	{
		MsgBox blup
	}
	hallo()
	{
		MsgBox hallo
	}
	blah()
	{
		MsgBox blah
	}
	ComboBox_Validate(Text)
	{
		return Round(Text)
	}
	tree_FocusEnter()
	{
		ToolTip Enter
	}
	MouseMove(Msg, wParam, lParam)
	{
		tooltip mousemove
		return 0
	}
	explorer_NavigateComplete2(pDisp, URL)
	{
		if(InStr(URL, "google"))
			this.explorer.Navigate("http://www.microsoft.com")
	}
	tabtext_Click()
	{
		;~ this.Add("Button", "dynamicbutton", "x300 y300","blup")
		;~ for index, item in this.combobox.items
			;~ msgbox % this.comboBox.Items[A_Index]
		msgbox % this.lvItems.SelectedIndex
	}
	lvItems_SelectionChanged(RowItem)
	{
		if(this.lvItems.SelectedIndices.MaxIndex() >= 1)
		{
			this.chkChecked.Enabled := true
			this.txtField1.Enabled := true
			this.txtField2.Enabled := true
			this.chkChecked.Checked := this.lvItems.Items[Row].Checked
			this.txtField1.Text := this.lvItems.Items[this.lvItems.SelectedIndices[1]][1]
			this.txtField2.Text := this.lvItems.Items[this.lvItems.SelectedIndices[1]][2]
		}
		else
		{
			this.chkChecked.Enabled := false
			this.txtField1.Enabled := false
			this.txtField2.Enabled := false
			this.chkChecked.Checked := 0
			this.txtField1.Text := ""
			this.txtField2.Text := ""
		}
	}
	lvItems_CheckedChanged(Row)
	{
		this.chkChecked.Checked := this.lvItems.Items[Row].Checked
	}
	lvItems_KeyPress(key)
	{
		if(key = 46)
			for key, index in this.lvItems.SelectedIndices
				this.lvItems.Items.DeleteRow(index)
	}
	btnAdd_Click()
	{
		this.lvItems.Items.Add("", "Test 1", "Test 2")
	}
	btnRemove_Click()
	{
		for number, index in this.lvItems.SelectedIndices
		;~ Loop % this.lvItems.SelectedIndices.MaxIndex()
			this.lvItems.Items.Delete(this.lvItems.SelectedIndices[A_Index])
	}
	btnLoad_Click()
	{
		;~ global CFileDialog
		FileDialog := new CFileDialog("Open")
		FileDialog.Filter := "Comma separated value(*.csv;*.dat)"
		if(FileDialog.Show())
		{
			File := FileOpen(FileDialog.Filename, "r")
			if(File)
			{
				string := File.Read()
				File.Close()
				Items := Array()
				Loop, Parse, string, `n
				{
					RowText := A_LoopField
					Row := Array()
					Loop, Parse, RowText, `,
						Row.Insert(A_LoopField)
					Items.Insert(Row)
				}
				this.lvItems.Items := Items
			}
		}
	}
	btnSave_Click()
	{
		;~ global CFileDialog
		FileDialog := new CFileDialog("Save")
		FileDialog.Filter := "Comma separated value(*.csv;*.dat)"
		if(FileDialog.Show())
		{
			Loop % this.lvItems.Items.Count
			{
				Row := this.lvItems.Items[A_Index]
				string .= A_Index = 1 ? "" : "`n"
				Loop % Row.Count
					string .= (A_Index = 1 ? "" : ",") Row[A_Index]
			}
			File := FileOpen(FileDialog.Filename, "w")
			File.Write(string)
			File.Close()
		}
	}
	chkChecked_CheckedChanged()
	{
		for number, Item in this.lvItems.SelectedItems
			this.lvItems.SelectedItems[Number].Checked := this.chkChecked.Checked
	}
	txtField1_TextChanged()
	{
		for number, index in this.lvItems.SelectedIndices
			this.lvItems.Items[index][1] := this.txtField1.Text
	}
	txtField2_TextChanged()
	{
		for number, index in this.lvItems.SelectedIndices
			this.lvItems.Items[index][2] := this.txtField2.Text
	}
	PostDestroy()
	{
		if(!this.Instances.MaxIndex()) ;Exit when all instances of this window are closed
			ExitApp
	}
	tree_EditingEnd(Item)
	{
		msgbox % "renamed to " Item.Text
	}
}
CMyWindow_tabText:
CMyWindow_lvItems:
CMyWindow_btnAdd:
CMyWindow_btnRemove:
CMyWindow_btnSave:
CMyWindow_btnLoad:
CMyWindow_txtField1:
CMyWindow_txtField2:
CMyWindow_chkChecked:
CMyWindow_chkChecked2:
CMyWindow_comboBox:
CMyWindow_tree:
CGUI.HandleEvent()
return
ExploreObj(Obj, NewRow="`n", Equal="  =  ", Indent="`t", Depth=12, CurIndent="") { 
    for k,v in Obj 
        ToReturn .= CurIndent . k . (IsObject(v) && depth>1 ? NewRow . ExploreObj(v, NewRow, Equal, Indent, Depth-1, CurIndent . Indent) : Equal . v) . NewRow 
    return RTrim(ToReturn, NewRow) 
}