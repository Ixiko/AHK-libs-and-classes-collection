/*
This script demonstrates the usage of ListViews and CFolderDialog
*/
gui := new ScriptLauncher()
#include %A_ScriptDir%\..\CGUI.ahk
Class ScriptLauncher Extends CGUI
{
	listView1			:= this.AddControl("ListView", "listView1", "x12 y40 w334 h217", "Files")
	button1			:= this.AddControl("Button", "button1", "x271 y12 w75 h23", "Browse")
	textBox1			:= this.AddControl("Edit", "textBox1", "x12 y14 w253 h20", "")
	statusStrip1	:= this.AddControl("StatusBar", "statusStrip1", "w356 h22", "Double-click a script to launch it!")

	__New()
	{
		this.Title := "ScriptLauncher"
		this.DestroyOnClose := true
		this.CloseOnEscape := true
		this.Show()
	}
	listView1_DoubleClick(RowNumber)
	{
		run, % this.textBox1.Text "\" this.listView1.SelectedItem[1]
	}
	button1_Click()
	{
		;Show a folder dialog to choose a directory
		FolderDialog := new CFolderDialog()
		FolderDialog.Folder := this.textBox1.Text
		if(FolderDialog.Show())
		{
			this.textBox1.Text := FolderDialog.Folder
			this.FolderChanged()
		}
	}
	textBox1_TextChanged()
	{
		this.FolderChanged()
	}
	FolderChanged()
	{
		this.ListView1.Items.Clear()
		Loop, % this.TextBox1.Text "\*.ahk", 0, 0
				this.listView1.Items.Add("", A_LoopFileName)
	}
	PostDestroy()
	{
		if(!this.Instances.MaxIndex())
			ExitApp
	}
}