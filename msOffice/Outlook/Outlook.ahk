Menu, Tray, Icon, shell32.dll, 157
SetKeyDelay, 0 

#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  							; Enable warnings to assist with detecting common errors.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
#SingleInstance force 			; only one instance of this script may run at a time!

global oOutlook
global ClipSaved, ClipVar
#IfWinActive ahk_exe OUTLOOK.EXE

F6::
	SaveAttachments()
return

F7::
	AddAttachments()
return

F8::
	DeleteAttachments()
return

^*::
	ShowHide()
return

^+h::
	HiddenStyle()
return

^r::
	ReplyForm()
return

^+r::
	ReplyAllForm()
return

^f::
	ForwardForm()
return

^n::
^+m::
	NewMessageForm()
return

^Space::
^+n::
	TemplateStyle("Odkryty ms")
return

#If

AddAttachments()
{
	global oOutlook, ClipSaved, ClipVar
	ClipSaved := Clipboard
	Clipboard := ""
	oOutlook := ComObjActive("Outlook.Application")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	if (VarType = "_Inspector")
	{
		myItem := myInspector.CurrentItem
		myAttachments := myItem.Attachments
		FileSelectFile, files, M3  ; M3 = Multiselect existing files.
		Loop, parse, files, `n
		{
			if (A_Index = 1)
			{
				path := A_LoopField
			}
			else if (A_Index = 2)
			{
				fullpath = %path%\%A_LoopField%
				myAttachments.Add(fullpath)
				ClipVar := % fullpath
				Clipboard := ClipVar
			}
			else
			{
				fullpath = %path%\%A_LoopField%
				myAttachments.Add(fullpath)
				ClipVar := % Clipboard . "<br>" . fullpath
				Clipboard := ClipVar
			}
		}
		ClipVar := Clipboard
		HText := myItem.HTMLBody
		AText = <HTML><BODY><font face="calibri" size="2" color="red">%ClipVar%</font></BODY></HTML>
		HText = %AText%%HText%
		myItem.HTMLBody := HText
	}
	oOutlook := ""
	Clipboard := ClipSaved
}

SaveAttachments()
{
	global oOutlook, ClipSaved, ClipVar
	ClipSaved := Clipboard
	ClipVar := ""
	Clipboard := "Deleted attachments: `"
	oOutlook := ComObjActive("Outlook.Application")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	if (VarType = "_Inspector")
	{
		myItem := myInspector.CurrentItem
		myAttachments := myItem.Attachments
		
		MsgBox, 4, ,Czy chcesz zapisać i usunąć załączniki?
		IfMsgBox No
			return	
		
		cnt := myAttachments.Count
		if (cnt < 1)
		{
			MsgBox, Brak załączników w wiadomości.
			return
		}
		i := cnt
		
		while (i > 0)
		{
			AttachmentName := myAttachments.Item(i).FileName
			path := "C:\temp1\Załączniki\"
			if !FileExist(path)
				FileCreateDir, % path
			path = %path%%AttachmentName%
				myAttachments.Item(i).SaveAsFile(path)
			i := i-1
		}
		k := 1
		while (k <= cnt)
		{
			AttachmentName := myAttachments.Item(k).FileName
			ClipVar = % Clipboard . " `" . AttachmentName
			Clipboard := ClipVar
			if (k != cnt)
			{
				ClipVar = %Clipboard%,
				Clipboard := ClipVar
			}
			k := k+1
		}
		ClipVar = % Clipboard . "<br>" . "Attachments saved in location C:\temp1\Załączniki." . "<br>"
		Clipboard := ClipVar

		ClipVar := Clipboard
		try
			myInspector.CommandBars.ExecuteMso("EditMessage")
		
		HText := myItem.HTMLBody
		AText = <HTML><BODY><font face="calibri" size="2" color="red">%ClipVar%</font></BODY></HTML>
		HText = %AText%%HText%
		myItem.HTMLBody := HText
		
		j := cnt
		while(j > 0)
		{
			myAttachments.Remove(j)
			j := j-1
		}
		myItem.Save
		myItem.Close(0)
	}
	oOutlook := ""
	Clipboard := ClipSaved
}

DeleteAttachments()
{
	global oOutlook, ClipSaved, ClipVar
	oOutlook := ComObjActive("Outlook.Application")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	ClipSaved := Clipboard
	Clipboard := ""
	ClipVar := ""
	if (VarType = "_Inspector")
	{
		myItem := myInspector.CurrentItem
		myAttachments := myItem.Attachments
		i := 1
		
		MsgBox, 4, ,Czy chcesz usunąć załączniki?
		IfMsgBox No
			return	
		
		cnt := myAttachments.Count
		
		if (cnt < 1)
		{
			MsgBox, Brak załączników w wiadomości.
			return
		}
		
		Clipboard := "Deleted attachments: `"
		
		while (i <= cnt)
		{
			AttachmentName := myAttachments.Item(i).FileName
			ClipVar = % Clipboard . " `" . AttachmentName
			Clipboard := ClipVar
			if (i != cnt)
			{
				ClipVar = %Clipboard%,
				Clipboard := ClipVar
			}
			i := i+1
		}
		
		ClipVar := Clipboard
		try
			myInspector.CommandBars.ExecuteMso("EditMessage")

		HText := myItem.HTMLBody
		AText = <HTML><BODY><font face="calibri" size="2" color="red">%ClipVar%</font></BODY></HTML>
		HText = %AText%%HText%
		myItem.HTMLBody := HText
		
		j := cnt
		while(j > 0)
		{
			myAttachments.Remove(j)
			j := j-1
		}
		myItem.Save
		myItem.Close(0)
	}
	oOutlook := ""
	Clipboard := ClipSaved
}

ShowHide()
{
	global oOutlook
	oOutlook := ComObjActive("Outlook.Application")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	
	if (VarType = "_Inspector")
	{
		try
			myInspector.CommandBars.ExecuteMso("EditMessage")
		oDoc := myInspector.WordEditor
		ShowAll := oDoc.Windows(1).View.ShowAll
		if (ShowAll = 0)
			oDoc.Windows(1).View.ShowAll := -1
		else
			oDoc.Windows(1).View.ShowAll := 0
	}
	oOutlook := ""
}

NewMessageForm()
{
	global oOutlook
	oOutlook := ComObjActive("Outlook.Application")
	myItem := oOutlook.CreateItemFromTemplate("S:\OrgDR\Praktykanci\JakubMasiak\20200220_Outlook\TQ-S437-SzablonOutlook.oft")
	myItem.Display
	MsgBox, Wiadomość wywołana została na podstawie szablonu TQ-S437-SzablonOutlook.oft
	oOutlook := ""
}

HiddenStyle()
{
	global oOutlook
	
	oOutlook := ComObjActive("Outlook.Application")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	
	if (VarType = "_Inspector")
	{
		try
				myInspector.CommandBars.ExecuteMso("EditMessage")
		oDoc := myInspector.WordEditor
		oSel := oDoc.Windows(1).Selection
		StyleVar := oSel.Style.NameLocal
		if (StyleVar != "Ukryty ms")
			TemplateStyle("Ukryty ms")
		else
			TemplateStyle("Odkryty ms")
	}
	oOutlook := ""
	return
}

TemplateStyle(StyleName)
{
	global oOutlook
	
	oOutlook := ComObjActive("Outlook.Application")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	
	if (VarType = "_Inspector")
	{
		try
		{
			try
				myInspector.CommandBars.ExecuteMso("EditMessage")
			oDoc := myInspector.WordEditor
			oSel := oDoc.Windows(1).Selection
			oSel.Style := StyleName
		}
		catch
		{
			MsgBox, 16, Próba wywołania stylu z szablonu, 
		( Join
		 Aby wywołać styl, wiadomość musi być utworzona na podstawie szablonu "TQ-S437-SzablonOutlook.oft". 
 W tym celu utwórz nową wiadomość korzystając ze skrótów klawiszowych.
		)
		}
	}
	oOutlook := ""
	return
}

ReplyForm()
{
	global oOutlook
	oOutlook := ComObjActive("Outlook.Application")
	myTemplate := oOutlook.CreateItemFromTemplate("S:\OrgDR\Praktykanci\JakubMasiak\20200220_Outlook\TQ-S437-SzablonOutlook.oft")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	if (VarType != "")
	{
		myItem := myInspector.CurrentItem.Reply
		HText := myItem.HTMLBody
		myTemplate.To := myItem.To
		myTemplate.CC := myItem.CC
		myTemplate.Subject := myItem.Subject
		myTemplate.Recipients.ResolveAll
		MsgBox, Wiadomość wywołana została na podstawie szablonu TQ-S437-SzablonOutlook.oft
		TText := myTemplate.HTMLBody
		myTemplate.Display
		myTemplate.HTMLBody := TText
		myTemplate.HTMLBody := HText
	}
	else
		Send, ^r
	oOutlook := ""
}

ReplyAllForm()
{
	global oOutlook
	oOutlook := ComObjActive("Outlook.Application")
	myTemplate := oOutlook.CreateItemFromTemplate("S:\OrgDR\Praktykanci\JakubMasiak\20200220_Outlook\TQ-S437-SzablonOutlook.oft")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	if (VarType != "")
	{
		myItem := myInspector.CurrentItem.ReplyAll
		HText := myItem.HTMLBody
		myTemplate.To := myItem.To
		myTemplate.CC := myItem.CC
		myTemplate.Subject := myItem.Subject
		myTemplate.Recipients.ResolveAll
		MsgBox, Wiadomość wywołana została na podstawie szablonu TQ-S437-SzablonOutlook.oft
		TText := myTemplate.HTMLBody
		myTemplate.Display
		myTemplate.HTMLBody := TText
		myTemplate.HTMLBody := HText
	}
	else
		Send, ^+r
	oOutlook := ""
}

ForwardForm()
{
	global oOutlook
	oOutlook := ComObjActive("Outlook.Application")
	myTemplate := oOutlook.CreateItemFromTemplate("S:\OrgDR\Praktykanci\JakubMasiak\20200220_Outlook\TQ-S437-SzablonOutlook.oft")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	if (VarType != "")
	{
		myItem := myInspector.CurrentItem.Forward
		HText := myItem.HTMLBody
		myTemplate.To := myItem.To
		myTemplate.CC := myItem.CC
		myTemplate.Subject := myItem.Subject
		myTemplate.Recipients.ResolveAll
		MsgBox, Wiadomość wywołana została na podstawie szablonu TQ-S437-SzablonOutlook.oft
		TText := myTemplate.HTMLBody
		myTemplate.Display
		myTemplate.HTMLBody := TText
		myTemplate.HTMLBody := HText
	}
	else
		Send, ^f
	oOutlook := ""
}