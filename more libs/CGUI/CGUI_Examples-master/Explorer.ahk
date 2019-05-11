gui := new Explorer()
#include <CGUI>
Class Explorer Extends CGUI
{
	ExplorerLeft := this.AddControl("ActiveX", "ExplorerLeft", "x187 y38 w358 h475", "Shell.Explorer")
	ExplorerRight := this.AddControl("ActiveX", "ExplorerRight", "x551 y38 w352 h475", "Shell.Explorer")
	statusbar := this.AddControl("StatusBar", "statusbar", "w917 h22", "statusStrip1")
	editAddress := this.AddControl("Edit", "editAddress", "x187 y12 w716 h20", "")
	treeFiles := this.AddControl("TreeView", "treeFiles", "x12 y12 w165 h502", "")
	__New()
	{
		this.Title := "Explorer"
		this.Show()
		this.ExplorerLeft.AddressBar := true
		this.ExplorerLeft.Navigate("C:\")
		this.ExplorerRight.Navigate("C:\")
		DriveGet,list,List
		Loop, Parse, list
			this.AddFolderToTree(this.treeFiles.SelectedItem, A_LoopField ":")
	}
	AddFolderToTree(Parent, name, level = 0)
	{
		node := Parent.Add(name)
		Path := this.BuildPath(Node)
		node.SetIcon(ExtractAssociatedIcon(0, Path))
		if(level = 0)
		{
			Loop, %Path%\*, 2, 0 ;This recursion is pretty slow but it is required to find out if there are subfolders. This is just a demo project showing off this library, so I don't really care...Explorer namespace extensions provide information if there are subfolders, but accessing those goes too far here.
				this.AddFolderToTree(node, A_LoopFileName, 1)
		}
	}
	treeFiles_ItemSelected()
	{
		this.GetActiveView().Navigate(Path := this.BuildPath(this.treeFiles.SelectedItem))
		this.SetAddress(Path)
		for index, node in this.TreeFiles.SelectedItem
			this.TreeFiles.SelectedItem.Remove(node)
		Loop, %Path%\*, 2, 0
			this.AddFolderToTree(this.treeFiles.SelectedItem, A_LoopFileName)
			;~ this.treeFiles.SelectedItem.Add(A_LoopFileName)
	}
	BuildPath(TreeNode)
	{
		while(TreeNode.ID)
		{
			Path := TreeNode.Text "\" Path
			TreeNode := TreeNode.Parent
		}
		return Path
	}
	GetActiveView()
	{
		return this.LastFocus = "SysListView322" ? this.ExplorerRight : this.ExplorerLeft
	}
	OnKeyDown()
	{
		if(A_ThisHotkey = "Enter" && this.ActiveControl.name = "editAddress" && FileExist(this.editAddress.Text))
		{
			this.GetActiveView().Navigate(this.editAddress.Text)
		}
	}
	FocusChange()
	{
		ControlGetFocus, Class, A
		this.StatusBar.Parts[1].Text := "Active: " Class
		if(InStr(Class, "SysListView32"))
		this.LastFocus := Class
	}
	ExplorerLeft_NavigateComplete2(pDisp, URL, Params*)
	{
		ControlGetFocus, Value, % "ahk_id " this.hwnd
		if(Value = "SysListView321")
			this.SetAddress(URL)
	}
	
	ExplorerRight_NavigateComplete2(pDisp, URL, Params*)
	{
		ControlGetFocus, Value, % "ahk_id " this.hwnd
		if(Value = "SysListView322")
			this.SetAddress(URL)
	}
	SetAddress(URL)
	{
		this.editAddress.Text := URL
	}
	PreClose()
	{
		ExitApp
	}
}

#If WinActive("Explorer ahk_class AutoHotkeyGUI")
Enter::
RerouteHotkey()
return

RerouteHotkey()
{
	hwnd := WinExist("A")
	for name, GUI in CGUI.GUIList
		if(GUI.hwnd = hwnd)
			GUI.OnKeyDown()
}
ExtractAssociatedIcon(hInst, lpIconPath, ByRef lpiIcon = 0)
{
	return DllCall("Shell32\ExtractAssociatedIcon", "Ptr", hInst, "Str", lpIconPath, "UShortP", lpiIcon, "Ptr")
 }