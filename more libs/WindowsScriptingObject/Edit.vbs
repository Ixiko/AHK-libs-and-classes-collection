'WindowSystemObject (WSO) example
'Copyright (C) Veretennikov A. B. 2004

Set Wso = WScript.CreateObject("Scripting.WindowSystemObject")

Set Form = Wso.CreateForm()
Form.ClientWidth = 500
Form.ClientHeight = 300
Form.CenterControl()
Form.Text = "Text Editor"
Form.OnCloseQuery = GetRef("FormCloseQuery")

Set Edit = Form.CreateEdit()
Edit.Align = Wso.Translate("AL_CLIENT")
Edit.HideSelection = false
Edit.MultiLine = true
Edit.ScrollBars = Wso.Translate("SS_BOTH")

Set Menu = Form.CreateMenuBar(0,0,0,0)
Menu.Align = Wso.Translate("AL_TOP")

Set FileMenu = Menu.Menu.Add("File")
FileMenu.Add("Open","CTRL+O").OnExecute = GetRef("FileOpen")
FileMenu.Add("Save as ...","CTRL+S").OnExecute = GetRef("FileSaveAs")
FileMenu.NewLine()
FileMenu.Add("Exit","ESC").OnExecute = GetRef("CloseFormHandler")

Set EditMenu = Menu.Menu.Add("Edit")
Set UndoMenuItem = EditMenu.Add("Undo")
UndoMenuItem.OnExecute = GetRef("EditUndo")
UndoMenuItem.OnUpdate = GetRef("EditUndoUpdate")

EditMenu.NewLine()

Set CutMenuItem = EditMenu.Add("Cut")
CutMenuItem.OnExecute = GetRef("EditCut")
CutMenuItem.OnUpdate = GetRef("EditCutCopyUpdate")

Set CopyMenuItem = EditMenu.Add("Copy")
CopyMenuItem.OnExecute = GetRef("EditCopy")
CopyMenuItem.OnUpdate = GetRef("EditCutCopyUpdate")

Set PasteMenuItem = EditMenu.Add("Paste")
PasteMenuItem.OnExecute = GetRef("EditPaste")
PasteMenuItem.OnUpdate = GetRef("EditPasteUpdate")

EditMenu.NewLine()
EditMenu.Add("Select All").OnExecute = GetRef("EditSelectAll")

Set FormatMenu = Menu.Menu.Add("Format")
Set WordWrapMenuItem = FormatMenu.Add("Word Wrap")
WordWrapMenuItem.CheckBox = true
WordWrapMenuItem.OnExecute = GetRef("WordWrapExecute")
WordWrapMenuItem.OnUpdate = GetRef("WordWrapUpdate")

FormatMenu.NewLine()
FormatMenu.Add("Font").OnExecute = GetRef("FormatFont")

Set HelpMenu = Menu.Menu.Add("Help")
HelpMenu.Add("About","F1").OnExecute = GetRef("HelpAbout")

Form.CreateStatusBar()

Sub EditUndoUpdate(Sender)
	Sender.Enabled = Edit.CanUndo
End Sub

Sub EditUndo(Sender)
	Edit.Undo()
End Sub

Sub EditCopy(Sender)
	Edit.Copy()
End Sub

Sub EditCut(Sender)
	Edit.Cut()
End Sub

Sub EditCutCopyUpdate(Sender)
	Sender.Enabled = Edit.SelEnd<>Edit.SelStart
End Sub

Sub EditPaste(Sender)
	Edit.Paste()
End Sub

Sub EditPasteUpdate(Sender)
	Sender.Enabled = Edit.CanPaste
End Sub

Sub EditSelectAll(Sender)
	Edit.SelectAll()
End Sub

Sub FileOpen(Sender)
	st = Form.OpenDialog("","Text Files (*.txt)|*.txt")
	If st<>"" Then
		Set fs = CreateObject("Scripting.FileSystemObject")
		Set file = fs.OpenTextFile(st,1,false)
		Edit.Clear()
		On Error Resume Next
		Edit.Text = file.ReadAll()
	End If
End Sub

Sub FileSaveAs(Sender)
	st = Form.SaveDialog("","Text Files (*.txt)|*.txt")
	If st<>"" Then
		Set fs = CreateObject("Scripting.FileSystemObject")
		Set file = fs.CreateTextFile(st,true)
		file.Write(Edit.Text)
	End If
End Sub

Sub WordWrapUpdate(Sender)
	Sender.Checked = Edit.WordWrap
End Sub

Sub WordWrapExecute(Sender)
	Edit.WordWrap = Sender.Checked
End Sub

Sub FormatFont(Sender)
	Edit.Font = Form.FontDialog(Edit.Font)
End Sub

Form.Show()

Wso.Run()

Sub HelpAbout(Sender)
	Wso.About()
End Sub

Sub FormCloseQuery(Sender,ResultPtr)
	ResultPtr.Put(Sender.Form.MessageBox("Do you really want to quit this program?","",Wso.Translate("MB_OKCANCEL")) = Wso.Translate("IDOK"))
End Sub

Function StartupDir()
	Dim s
	s = WScript.ScriptFullName
	s = Left(s,InStrRev(s,"\"))
	StartupDir = s
End Function

Sub CloseFormHandler(Sender)
	Sender.Form.Close()
End Sub
