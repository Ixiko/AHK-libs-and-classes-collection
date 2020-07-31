#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include WSOConsts.ahk
; This file was translated from VBScript
; You can also just use the numeric constants from it 
; if you're so inclined, and don't want another #Include

;This is a clone of:
;
;WindowSystemObject (WSO) example
;by Veretennikov A. B. 2004

; The line below doesn't really need to be global
; unless you use the original 'Wso.About() method
; in the HelpAbout() function
global wso := ComObjCreate("Scripting.WindowSystemObject")

global Form := Wso.CreateForm()
Form.ClientWidth := 500
Form.ClientHeight := 300
Form.CenterControl()
Form.Text := "WSO Edit in AHK"
Form.OnCloseQuery := Func("FormCloseQuery")

global Edit := Form.CreateEdit()
Edit.Align := Wso.Translate("AL_CLIENT")
Edit.HideSelection := false
Edit.MultiLine := true
Edit.ScrollBars := Wso.Translate("SS_BOTH")

global Menu := Form.CreateMenuBar(0,0,0,0)
Menu.Align := Wso.Translate("AL_TOP")

global FileMenu := Menu.Menu.Add("File")
FileMenu.Add("Open","CTRL+O").OnExecute := Func("FileOpen")
FileMenu.Add("Save as ...","CTRL+S").OnExecute := Func("FileSaveAs")
FileMenu.NewLine()
FileMenu.Add("Exit","ESC").OnExecute := Func("CloseFormHandler")

global EditMenu := Menu.Menu.Add("Edit")
UndoMenuItem := EditMenu.Add("Undo")
UndoMenuItem.OnExecute := Func("EditUndo")
UndoMenuItem.OnUpdate := Func("EditUndoUpdate")

EditMenu.NewLine()

CutMenuItem := EditMenu.Add("Cut")
CutMenuItem.OnExecute := Func("EditCut")
CutMenuItem.OnUpdate := Func("EditCutCopyUpdate")

CopyMenuItem := EditMenu.Add("Copy")
CopyMenuItem.OnExecute := Func("EditCopy")
CopyMenuItem.OnUpdate := Func("EditCutCopyUpdate")

PasteMenuItem := EditMenu.Add("Paste")
PasteMenuItem.OnExecute := Func("EditPaste")
PasteMenuItem.OnUpdate := Func("EditPasteUpdate")

EditMenu.NewLine()
EditMenu.Add("Select All").OnExecute := Func("EditSelectAll")

global FormatMenu := Menu.Menu.Add("Format")
global WordWrapMenuItem := FormatMenu.Add("Word Wrap")
WordWrapMenuItem.CheckBox := true
WordWrapMenuItem.OnExecute := Func("WordWrapExecute")
WordWrapMenuItem.OnUpdate := Func("WordWrapUpdate")

FormatMenu.NewLine()
FormatMenu.Add("Font").OnExecute := Func("FormatFont")

global HelpMenu = Menu.Menu.Add("Help")
HelpMenu.Add("About","F1").OnExecute := Func("HelpAbout")

Form.CreateStatusBar()

EditUndoUpdate(this) {
	this.Enabled := Edit.CanUndo
}

EditUndo(this) {
	Edit.Undo()
}

EditCopy(this) {
	Edit.Copy()
}

EditCut(this) {
	Edit.Cut()
}

EditCutCopyUpdate(this) {
	this.Enabled := Edit.SelEnd<>Edit.SelStart
}

EditPaste(this) {
	Edit.Paste()
}

EditPasteUpdate(this) {
	Enabled = Edit.CanPaste
}

EditSelectAll(this) {
	Edit.SelectAll()
}

FileOpen(this) {
	st := Form.OpenDialog("","Text Files (*.txt)|*.txt")
	If (st != "") {
		global fs := ComObjCreate("Scripting.FileSystemObject")
		global file := fs.OpenTextFile(st,1,false)
		Edit.Clear()
		Edit.Text := file.ReadAll()
	}
}

FileSaveAs(this) {
	st := Form.SaveDialog("","Text Files (*.txt)|*.txt")
	If (st != "") {
		global fs := ComObjCreate("Scripting.FileSystemObject")
		global file := fs.CreateTextFile(st,true)
		file.Write(Edit.Text)
	}
}

WordWrapUpdate(this) {
	; Pure trial-and-error discovered this works
	WordWrapMenuItem.Checked := Edit.WordWrap
}

WordWrapExecute(this) {
	; Also pure trial-and-error
	Edit.WordWrap := WordWrapMenuItem.Checked
}

FormatFont(this) {
	Edit.Font := Form.FontDialog(Edit.Font)
}

Form.Show()

Wso.Run()

HelpAbout(this) {
	;If you leave this commented, wso doesn't need to be global
	;Wso.About()
	Msgbox WSO Edit in AHK`r`nUsing WindowSystemObject`r`nby A. Veretennikov (http://www.veretennikov.org/)`r`nСпасибо тебе друг!`r`n(translation of provided demo in VBScript)
	
}

FormCloseQuery(this,ResultPtr) {
	ResultPtr.Put(Form.MessageBox("Do you really want to quit this program?","",Wso.Translate("MB_OKCANCEL")) = Wso.Translate("IDOK"))
}

StartupDir() {
	StartupDir := A_ScriptDir
}

CloseFormHandler(this) {
	Form.Close()
}


/* Utility function for debugging (from docs)
si(d) {
VarType := ComObjType(d)
IName   := ComObjType(d, "Name")
IID     := ComObjType(d, "IID")
CName   := ComObjType(d, "Class")  ; Requires [v1.1.26+]
CLSID   := ComObjType(d, "CLSID")  ; Requires [v1.1.26+]
MsgBox % "Variant type:`t" VarType
	. "`nInterface name:`t" IName "`nInterface ID:`t" IID
	. "`nClass name:`t" CName "`nClass ID (CLSID):`t" CLSID
}
*/



