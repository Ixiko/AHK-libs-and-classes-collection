gui := new CSharpGuiConverter()
#include <CGUI>
#include <Regex>
Class CSharpGuiConverter Extends CGUI
{
	label1			:= this.AddControl("Text", "label1", "x12 y15 w53 h13", "Input File:")
	txtInput 		:= this.AddControl("Edit", "txtInput", "x71 y14 w274 h20", "")
	btnInput		:= this.AddControl("Button", "btnInput", "x351 y12 w36 h23", "...")
	label2			:= this.AddControl("Text", "label2", "x12 y41 w61 h13", "Output File:")
	txtOutput		:= this.AddControl("Edit", "txtOutput", "x71 y40 w274 h20", "")
	btnOutput	:= this.AddControl("Button", "btnOutput", "x351 y38 w36 h23", "...")
	btnConvert	:= this.AddControl("Button", "btnConvert", "x15 y66 w120 h23", "Convert")
	btnRun		:= this.AddControl("Button", "btnRun", "x141 y66 w120 h23", "Run Converted File")
	btnEdit			:= this.AddControl("Button", "btnEdit", "x267 y66 w120 h23", "Edit Converted File")
	__New()
	{
		IniRead, in, %A_ScriptName%.ini,Settings, In, %A_Space%
		IniRead, out, %A_ScriptName%.ini,Settings, Out, %A_Space%
		
		this.txtInput.Text := in
		this.txtOutput.Text := out
		
		this.btnConvert.Enabled := FileExist(in) && strlen(out) > 1		
		this.btnRun.Enabled := 0			
		this.btnEdit.Enabled := 0
		
		this.height := 116
		this.Title := "C# GUI Converter"
		this.Width := 401
		this.DestroyOnClose := true
		this.Show()		
	}
	btnInput_Click()
	{
		;~ global CFileDialog
		FileDialog := new CFileDialog("Open")
		FileDialog.Filter := "*.cs"
		Text := this.txtInput.Text
		SplitPath, Text, Filename, FileDir
		if(FileDir)
			FileDialog.InitialDirectory := FileDir
		if(Filename)
			FileDialog.Filename := Filename
		if(FileDialog.Show())
			this.txtInput.Text := FileDialog.Filename
	}
	btnOutput_Click()
	{
		;~ global CFileDialog
		FileDialog := new CFileDialog("Save")
		FileDialog.Filter := "*.ahk"
		Text := this.txtInput.Text
		SplitPath, Text, Filename, FileDir
		if(FileDir)
			FileDialog.InitialDirectory := FileDir
		if(Filename)
			FileDialog.Filename := Filename
		if(FileDialog.Show())
			this.txtOutput.Text := FileDialog.Filename
	}
	btnConvert_Click()
	{
		if(InStr(FileExist(this.txtInput.Text), "D") && InStr(FileExist(this.txtOutput.Text), "D"))
		{
			Loop, % this.txtInput.Text "\*.cs", 0, 0
			{
				if(InStr(A_LoopFileName, ".Designer.cs"))
				{
					;~ MsgBox % "convert " A_LoopFileLongPath " -> " this.txtOutput.Text "\" SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 11) ".ahk"
					this.Convert(A_LoopFileLongPath, this.txtOutput.Text "\" SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 12) ".ahk")
				}
			}
		}
		else
		{
			this.Convert(this.txtInput.Text, this.txtOutput.Text)
			this.ConvertedFile := this.txtOutput.Text
			this.btnRun.Enable()
			this.btnEdit.Enable()
		}
	}
	btnRun_Click()
	{
		run % this.ConvertedFile
	}
	btnEdit_Click()
	{
		run % "*Edit " this.ConvertedFile
	}
	txtInput_TextChanged()
	{
		if(FileExist(this.txtInput.Text) && this.txtOutput.Text)
			this.btnConvert.Enable()
		else
			this.btnConvert.Disable()
	}
	txtOutput_TextChanged()
	{
		if(FileExist(this.txtInput.Text) && this.txtOutput.Text)
			this.btnConvert.Enable()
		else
			this.btnConvert.Disable()
	}
	PreClose()
	{
		IniWrite, % this.txtInput.Text, %A_ScriptName%.ini, Settings, In
		IniWrite, % this.txtOutput.Text, %A_ScriptName%.ini, Settings, Out
		ExitApp
	}
	ReadTabs(ByRef InputFile, Controls, TabPages)
	{
		;Collect TabPage variables and create TabPages array for each tab control
		Loop, Parse, InputFile, `n, %A_Space%%A_Tab%
		{
			if(InStr(A_LoopField, "private System.Windows.Forms."))
			{
				CSharptype := Regex.MatchSimple(A_LoopField, "type", "\.Forms\.(?P<type>.*?) (?P<name>.*?)\;")
				name := Regex.MatchSimple(A_LoopField, "name", "\.Forms\.(?P<type>.*?) (?P<name>.*?)\;")
				if(CSharptype && name)
				{
					if(CSharpType = "TabControl")
						Controls[Name].TabPages := {}
					else if(CSharpType = "TabPage")
						TabPages[Name] := {}
				}
			}
		}
		;Scan for tab pages and associate controls with tab control tabs
		;Find tabpage->tab control relationship
		Loop, Parse, InputFile, `n, %A_Space%%A_Tab%
		{
			if(InStr(A_LoopField, ".Controls.Add("))
			{
				TabControl := Regex.MatchSimple(A_LoopField, "Name", "this\.(?P<Name>.*?)\.Controls\.Add\(")
				if(Controls[TabControl].Type = "Tab")
				{
					TabPage := {Name : Regex.MatchSimple(A_LoopField, "Control", "\(this\.(?P<Control>.*?)\);")}  ;this.tabPage1.Controls.Add(this.label2);
					Controls[TabControl].TabPages.Insert(TabPage)
				}
			}
			;~ this.tabPage2.Controls.Add(this.txtTags);
		}
		;Find tabpage text
		Loop, Parse, InputFile, `n, %A_Space%%A_Tab%
		{
			if(InStr(A_LoopField, ".Text = """)) ;this.tabPage1.Text = "General";
			{
				TabPage := Regex.MatchSimple(A_LoopField, "Name", "this\.(?P<Name>.*?)\.Text = ")
				for name, control in Controls
					for index, tabpage2 in control.TabPages
					if(TabPage2.Name = TabPage)
					{
						TabPage2.Text := Regex.MatchSimple(A_LoopField, "Text", " = ""(?P<Text>.*?)"";")
						break 2
					}
			}
		}
		
		;Find control->tabpage relationship
		Loop, Parse, InputFile, `n, %A_Space%%A_Tab%
		{
			if(InStr(A_LoopField, ".Controls.Add(")) ;this.tabPage1.Controls.Add(this.label2);
			{
				TabPage := Regex.MatchSimple(A_LoopField, "Name", "this\.(?P<Name>.*?)\.Controls\.Add\(")
				if(IsObject(TabPages[TabPage]))
				{
					SubControl := Regex.MatchSimple(A_LoopField, "Control", "\(this\.(?P<Control>.*?)\);")  
					for Name, Control in Controls
						if(IsObject(Control.TabPages))
							for index, TabPage2 in Control.TabPages
								if(TabPage2.Name = TabPage)
								{
									Controls[SubControl].TabControl := Control									
									Controls[SubControl].Tab := index
									break 2
								}					
				}
			}
			;~ this.tabPage2.Controls.Add(this.txtTags);
		}
	}
	ReadGroupBoxes(ByRef InputFile, Controls)
	{
		for name, control in Controls
			if(control.Type = "GroupBox")
				control.Controls := {}
		Loop, Parse, InputFile, `n, %A_Space%%A_Tab%
		{
			if(InStr(A_LoopField, ".Controls.Add("))
			{
				GroupBoxControl := Regex.MatchSimple(A_LoopField, "Name", "this\.(?P<Name>.*?)\.Controls\.Add\(")
				if(Controls[GroupBoxControl].Type = "GroupBox")
				{
					SubControl := Regex.MatchSimple(A_LoopField, "Control", "\(this\.(?P<Control>.*?)\);") ;this.tabPage1.Controls.Add(this.label2);
					Controls[GroupBoxControl].Controls.Insert(SubControl)
					Controls[SubControl].GroupBox := 1
					Controls[SubControl].AccessString := "this." GroupBoxControl ".Controls." Controls[SubControl].Name
				}
			}
		}
	}
	Convert(InPath, OutPath)
	{
		;~ global Regex
		FileRead, InputFile, % "*t " InPath
		start := InStr(InputFile, "partial class ") + StrLen("partial class ")
		Class := SubStr(InputFile, start, InStr(InputFile, "`n", 0, start) - start)
		Controls := [] ;array storing control definitions
		Window := {Events : {}} ;Object storing window properties
		StartString := "private System.Windows.Forms."
		EndString := ";"
		;Get a list of controls
		Loop, Parse, InputFile, `n, %A_Space%%A_Tab%
		{
			line := A_LoopField
			if(InStr(line, "private System.Windows.Forms."))
			{
				CSharptype := Regex.MatchSimple(line, "type", "\.Forms\.(?P<type>.*?) (?P<name>.*?)\;")
				name := Regex.MatchSimple(line, "name", "\.Forms\.(?P<type>.*?) (?P<name>.*?)\;")
				if(CSharptype && name)
				{
					SupportedControls := { TextBox : "Edit", Label : "Text", Button : "Button", CheckBox : "CheckBox", PictureBox : "Picture", ListView : "ListView", ComboBox : "ComboBox", ListBox : "ListBox", TreeView : "TreeView", GroupBox : "GroupBox", RadioButton : "Radio", TabControl : "Tab", LinkLabel : "SysLink", StatusStrip : "StatusBar", NumericUpDown : "Edit"}
					type := SupportedControls[CSharptype]
					if(type)
					{
						Control := {Type : Type, Name : name, Events : {}}
						if(CSharpType = "NumericUpDown")
						{
							Control.UpDown := true
							Control.Min := 0
							Control.Max := 100
						}
						Controls[Control.Name] := Control
					}
				}
			}
		}
		;Parse all control and gui properties
		Loop, Parse, InputFile, `n, %A_Space%%A_Tab%
		{
			line := A_LoopField
			if(InStr(line, "// ") && !InStr(line, "///") && strlen(line) > 4) ;Start of control section is marked by //
			{
				found := false
				for Name, Control in Controls
				{
					if(line = "// " Control.Name) ;Start of new control section
					{
						CurrentControl := Control
						found := true
						break
					}
				}
				if(!found)
					CurrentControl := ""
				if(!found && strLen(line) > 5 && !InStr(line, "///"))
				{
					if(!found && InStr(line, "// " Class))
					{
						CurrentControl := "Window"
					}
				}
			}
			if(CurrentControl = "Window")
			{
				if(InStr(line, " =")) ;window property assignments
				{
					if(InStr(line, "this.ClientSize"))
					{
						Width := Regex.MatchSimple(line, "width", "\.Size\((?P<width>\d+),.*?(?P<height>\d+)")
						Height := Regex.MatchSimple(line, "height", "\.Size\((?P<width>\d+),.*?(?P<height>\d+)")
						if(width)
							Window.Width := width
						if(height)
							Window.height := height
					}
					else if(InStr(line, "this.MaximizeBox"))
						Window.MaximizeBox := InStr(line, "true")
					else if(InStr(line, "this.MinimizeBox"))
						Window.MinimizeBox := InStr(line, "true")
					else if(InStr(line, "this.TopMost"))
						Window.AlwaysOnTop := InStr(line, "true")
					else if(InStr(line, "this.Enabled"))
						Window.Enabled := InStr(line, "true")
					else if(InStr(line, "this.Autosize"))
						Window.AutoSize := InStr(line, "true")
					else if(InStr(line, "FormBorderStyle."))
					{
						if(InStr(line, "ToolWindow;"))
							Window.ToolWindow := 1
						if(InStr(line, "Sizable"))
							Window.Resize := 1
					}
					else if(InStr(line, "this.Text"))
						Window.Title := Regex.MatchSimple(line, "text", """(?P<text>.*)""")
				}
				else if(InStr(line, "EventHandler(")) ;GUIs have different event handler classes
				{
					if(InStr(line, "this.DragDrop"))
						Window.Events.Insert("DropFiles()")
					else if(InStr(line, "this.FormClosing"))
						Window.Events.Insert("PreClose()")
					else if(InStr(line, "this.FormClosed"))
						Window.Events.Insert("PostDestroy()")
				}
			}
			else if(IsObject(CurrentControl)) ;Process control property assignments
			{
				Handled := false
				if(InStr(line, " =")) ;control property assignments
				{
					Handled := true
					if(InStr(line, "this." CurrentControl.Name ".Size")) ;Some basic ones first
					{
						Width := Regex.MatchSimple(line, "width", "\.Size\((?P<width>\d+),.*?(?P<height>\d+)")
						Height := Regex.MatchSimple(line, "height", "\.Size\((?P<width>\d+),.*?(?P<height>\d+)")
						if(width)
							CurrentControl.Width := width
						if(height && CurrentControl.Type != "ComboBox") ;ComboBox/DropDownList use it to limit their drop down list
							CurrentControl.height := height
					}
					else if(InStr(line, "this." CurrentControl.Name ".Location"))
					{
						x := Regex.MatchSimple(line, "x", "\.Point\((?P<x>\d+),.*?(?P<y>\d+)")
						y := Regex.MatchSimple(line, "y", "\.Point\((?P<x>\d+),.*?(?P<y>\d+)")
						if(x)
							CurrentControl.x := x
						if(x)
							CurrentControl.y := y
					}
					else if(InStr(line, "this." CurrentControl.Name ".Text"))
					{
						CurrentControl.Text := Regex.MatchSimple(line, "text", """(?P<text>.*)""")
						;Convert SysLink control text to URL if it is one.
						if(CurrentControl.Type = "SysLink" && RegexMatch(Trim(CurrentControl.Text, " "), "(?:(?:ht|f)tps?://|www\.).+\..+") > 0)
							CurrentControl.Text := "<A HREF=""""" CurrentControl.Text """"">" CurrentControl.Text "</A>"
					}
					else if(InStr(line, "this." CurrentControl.Name ".Enabled"))
						CurrentControl.Enabled := (InStr(line, "true") || InStr(line, "1;"))
					else if(InStr(line, "this." CurrentControl.Name ".Visible"))
						CurrentControl.Visible := (InStr(line, "true") || InStr(line, "1;"))
					else if(InStr(line, "this." CurrentControl.Name ".TextAlign"))
					{
						if(InStr(line, "Left"))
							CurrentControl.Left := 1
						else if(InStr(line, "Right"))
							CurrentControl.Right := 1
					}
					else if(InStr(line, "new System.EventHandler") && InStr(line, "_Enter);"))
						CurrentControl.Events.Insert("_FocusReceived()")
					else if(InStr(line, "new System.EventHandler") && InStr(line, "_Leave);"))
						CurrentControl.Events.Insert("_FocusLost()")
					else
						handled := false
				}
				if(!handled && IsFunc(this[CurrentControl.Type])) ;Process special properties depending on type
					Handled := this[CurrentControl.Type](CurrentControl, line)
			}
		}
		TabPages := {}
		this.ReadTabs(InputFile, Controls, TabPages)
		this.ReadGroupBoxes(InputFile, Controls)
		
		;Now that all info is available, write the file
		OutputFile := "gui := new " Class "()`n#include <CGUI>`nClass " Class " Extends CGUI`n{`n"
		for Name, Control in Controls ;Write static control definitions
		{
			if(!Control.HasKey("TabControl") && Control.Type != "Tab" && !Control.HasKey("GroupBox") && !Control.HasKey("UpDown")) ;Must not add subcontrols of groupboxes and UpDown Controls here
			{
				Options := (Control.HasKey("x") ? "x" Control.x " " : "" ) (Control.HasKey("y") ? "y" Control.y " " : "" ) (Control.HasKey("width") ? "w" Control.width " " : "" ) (Control.HasKey("height") ? "h" Control.height : "" )
				OutputFile .= "`t" Control.Name " := this.AddControl(""" Control.Type """, """ Control.Name """, """ Options """, """ Control.Text """)`n"
			}
		}
		
		/*
		Tab Class
		*/
		for Name, Control in Controls
		{
			if(Control.Type = "Tab")
			{
				for index, TabPage in Control.TabPages
					Text .= A_Index = 1 ? TabPage.Text : "|" TabPage.Text
				Options := (Control.HasKey("x") ? "x" Control.x " " : "" ) (Control.HasKey("y") ? "y" Control.y " " : "" ) (Control.HasKey("width") ? "w" Control.width " " : "" ) (Control.HasKey("height") ? "h" Control.height : "" )
				OutputFile .= "`tClass " Control.Name "`n`t{`n`t`tstatic Type := ""Tab""`n`t`tstatic Options := """ Options """`n`t`tstatic Text := """ Text """`n`t`t__New(GUI)`n`t`t{`n"
				
				for Name2, Control2 in Controls
					if(Control2.TabControl = Control && !Control2.GroupBox)
					{
						Control2.x := Control2.x + 22
						Control2.y := Control2.y + 36
						this.WriteControl(OutputFile, Control2, "this.Tabs[" Control2.Tab "].AddControl", "this.Tabs[" Control2.Tab "].Controls." Control2.Name, 3)
						;~ Options := (Control2.HasKey("x") ? "x" Control2.x + 22 " " : "" ) (Control2.HasKey("y") ? "y" Control2.y + 36 " " : "" ) (Control2.HasKey("width") ? "w" Control2.width " " : "" ) (Control2.HasKey("height") ? "h" Control2.height : "" )
						;~ OutputFile .= "`t`t`tthis.Tabs[" Control2.Tab "].AddControl(""" Control2.Type """, """ Control2.Name """, """ Options """, """ Control2.Text """)`n"						
						if(Control2.Type = "GroupBox")
							this.WriteGroupBox(OutputFile, Controls, Control2, "this.Tabs[" Control2.Tab "].Controls." Control2.Name ".AddControl", "this.Tabs[" Control2.Tab "].Controls." Control2.Name ".Controls", 3)
					}
				OutputFile .= "`t`t}`n`t}`n`t`n"
			}
		}
		/*
		//Tab Class
		*/
		
		OutputFile .= "`t__New()`n`t{`n"
		for Name, Control in Controls
			if(Control.Type = "GroupBox" && !Control.HasKey(TabControl))
				this.WriteGroupBox(OutputFile, Controls, Control, "this." Control.Name ".AddControl", "this." Control.Name, 2)
			else if(!Control.HasKey("TabControl") && Control.HasKey("UpDown"))
				this.WriteControl(OutputFile, Control, "this." Control.Name " := this.AddControl", "this." Control.Name, 2) 
		
		for, Name, Control in Controls
		{
			for Property, Value in Control
				if Property not in x,y,width,height,name,type,Text,Events,Tab,TabControl,TabPages,GroupBox,Controls,UpDown,Min,Max,AccessString
				{
					AccessString := Control.HasKey("AccessString") ? Control.AccessString : "this." Control.Name "."
					if Value is Number
						OutputFile .= "`t`t" AccessString "." Property " := " Value "`n"
					else if(Value = "true" || Value = "false")
						OutputFile .= "`t`t" AccessString "." Property " := " Value "`n"
					else
						OutputFile .= "`t`t" AccessString "." Property " := """ Value """`n"
				}
		}
		for WindowProperty, Value in Window
		{
			if WindowProperty not in width,height,Events
			{
				if Value is Number
					OutputFile .= "`t`tthis." WindowProperty " := " Value "`n"
				else if(Value = "true" || Value = "false")
					OutputFile .= "`t`tthis." WindowProperty " := " Value "`n"
				else
					OutputFile .= "`t`tthis." WindowProperty " := """ Value """`n"
			}
		}
		OutputFile .= "`t`tthis.Show()`n"		
		OutputFile .= "`t}"
		for EventIndex, GUIEvent in Window.Events
			OutputFile .= "`n`t" GUIEvent "`n`t{`n`t`t`n`t}"
		for Name, Control in Controls
		{
			for index2, Event in Control.Events
			{
				OutputFile .= "`n`t" Control.Name Event "`n`t{`n`t`t`n`t}"
				AnyEvents := true
			}
		}
		OutputFile .= "`n}"
		FileDelete, % OutPath
		FileAppend, % OutputFile, % OutPath
	}
	WriteControl(ByRef OutputFile, Control, PreText, AccessText, IndentLevel)
	{
		if(!PreText)
			PreText := "this." ControlName " := this.AddControl"
		Options := (Control.HasKey("x") ? "x" Control.x " " : "" ) (Control.HasKey("y") ? "y" Control.y " " : "" ) (Control.HasKey("width") ? "w" Control.width " " : "" ) (Control.HasKey("height") ? "h" Control.height : "" )
		Loop % IndentLevel
			OutputFile .= "`t"
		OutputFile .= PreText "(""" Control.Type """, """ Control.Name """, """ Options """, """ Control.Text """)`n"
		if(Control.UpDown)
		{	
			Loop % IndentLevel
				OutputFile .= "`t"
			OutputFile .= AccessText ".AddUpDown(" Control.Min ", " Control.Max ")`n"
		}
	}
	WriteGroupBox(ByRef OutputFile, Controls, GroupBoxControl, PreText, AccessText, IndentLevel)
	{
		for index, ControlName in GroupBoxControl.Controls
		{
			Control := Controls[ControlName]
			if(!PreText)
				PreText := "this." ControlName " := this." GroupBoxControl.Name ".AddControl"			
			AccessText .= ".Controls." ControlName
			Control.X := Control.X + GroupBoxControl.X
			Control.Y := Control.Y + GroupBoxControl.Y
			this.WriteControl(OutputFile, Control, PreText, AccessText, IndentLevel)
			;~ Options := (Control.HasKey("x") ? "x" Control.x " " : "" ) (Control.HasKey("y") ? "y" Control.y " " : "" ) (Control.HasKey("width") ? "w" Control.width " " : "" ) (Control.HasKey("height") ? "h" Control.height : "" )
			;~ Loop % IndentLevel
				;~ OutputFile .= "`t"
			;~ OutputFile .= PreText "(""" Control.Type """, """ Control.Name """, """ Options """, """ Control.Text """)`n"
		}
	}
	Text(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_Click);"))
				CurrentControl.Events.Insert("_Click()")
			else if(InStr(line, "_DoubleClick);"))
				CurrentControl.Events.Insert("_DoubleClick()")
		}
	}
	Button(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_Click);"))
				CurrentControl.Events.Insert("_Click()")
		}
	}
	Edit(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_TextChanged);"))
				CurrentControl.Events.Insert("_TextChanged()")
		}
		else if(InStr(line, "this." CurrentControl.Name ".MultiLine"))
			CurrentControl.Multi := (InStr(line, "true") || InStr(line, "1;"))
		else if(InStr(line, "this." CurrentControl.Name ".UseSystemPasswordChar"))
			CurrentControl.Password := (InStr(line, "true") || InStr(line, "1;"))
	}
	Checkbox(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_CheckedChanged);"))
				CurrentControl.Events.Insert("_CheckedChanged()")
		}
		else if(InStr(line, "this." CurrentControl.Name ".Checked"))
			CurrentControl.Checked := (InStr(line, "true") || InStr(line, "1;"))
	}
	Radio(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_CheckedChanged);"))
				CurrentControl.Events.Insert("_CheckedChanged()")
		}
		else if(InStr(line, "this." CurrentControl.Name ".Checked"))
			CurrentControl.Checked := (InStr(line, "true") || InStr(line, "1;"))
	}
	ComboBox(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_SelectedIndexChanged);"))
				CurrentControl.Events.Insert("_SelectionChanged()")
		}
		else if(InStr(line, "this." CurrentControl.Name ".DropDownStyle") && InStr(line, "DropDownList"))
			CurrentControl.type := "DropDownList"
	}
	DropDownList(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_SelectedIndexChanged);"))
				CurrentControl.Events.Insert("_SelectionChanged()")
		}
	}
	ListBox(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_SelectedIndexChanged);"))
				CurrentControl.Events.Insert("_SelectionChanged()")
		}
	}
	ListView(CurrentControl, line)
	{
		if(InStr(line, "EventHandler("))
		{
			if(InStr(line, "_ItemSelectionChanged);") || InStr(line, "_SelectedIndexChanged")) ;Make sure only one of those events is transformed
			{
				for key, Value in CurrentControl.Events
					if(Value = "_SelectionChanged(Row)")
						return
				CurrentControl.Events.Insert("_SelectionChanged(Row)")
			}
			else if(InStr(line, "_ItemCheckedChanged);"))
				CurrentControl.Events.Insert("_CheckedChanged(Row)")
			else if(InStr(line, "_MouseClick);"))
				CurrentControl.Events.Insert("_Click(RowNumber)")
			else if(InStr(line, "_MouseDoubleClick);"))
				CurrentControl.Events.Insert("_DoubleClick(RowNumber)")
			else if(InStr(line, "_ColumnClick);"))
				CurrentControl.Events.Insert("_ColumnClick(ColumnNumber)")
			else if(InStr(line, "_BeforeLabelEdit);"))
				CurrentControl.Events.Insert("_EditingStart(RowNumber)")
			else if(InStr(line, "_AfterLabelEdit);"))
				CurrentControl.Events.Insert("_EditingEnd(RowNumber)")
			else if(InStr(line, "_ItemActivate);"))
				CurrentControl.Events.Insert("_ItemActivate(RowNumber)")
			else if(InStr(line, "_KeyPress);"))
				CurrentControl.Events.Insert("_KeyPress(Key)")
			else if(InStr(line, "_MouseLeave);"))
				CurrentControl.Events.Insert("_MouseLeave()")
		}
	}
	TreeView(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_MouseClick);"))
				CurrentControl.Events.Insert("_Click(Item)")
			else if(InStr(line, "_MouseDoubleClick);"))
				CurrentControl.Events.Insert("_DoubleClick(Item)")
			else if(InStr(line, "_BeforeLabelEdit);"))
				CurrentControl.Events.Insert("_EditingStart(Item)")
			else if(InStr(line, "_AfterLabelEdit);"))
				CurrentControl.Events.Insert("_EditingEnd(Item)")
			else if(InStr(line, "_ItemActivate);"))
				CurrentControl.Events.Insert("_KeyPress(Key)")
			else if(InStr(line, "_MouseLeave);"))
				CurrentControl.Events.Insert("_MouseLeave()")
			else if(InStr(line, "_AfterSelect);"))
				CurrentControl.Events.Insert("_ItemSelected(Item)")
			else if(InStr(line, "_AfterExpand);"))
				CurrentControl.Events.Insert("_ItemExpanded(Item)")
			else if(InStr(line, "_AfterCollapse);"))
				CurrentControl.Events.Insert("_ItemCollapsed(Item)")
		}
		else if(InStr(line, "this." CurrentControl.Name ".Checkboxes"))
			CurrentControl.Checked := 1
		else if(InStr(line, "this." CurrentControl.Name ".HotTracking"))
			CurrentControl.HotTrack := 1
		else if(InStr(line, "this." CurrentControl.Name ".FullRowSelect"))
			CurrentControl.FullRowSelect := 1
		else if(InStr(line, "this." CurrentControl.Name ".LabelEdit"))
			CurrentControl.ReadOnly := 0
	}
	
	Picture(CurrentControl, line)
	{
		if(InStr(line, "new System.EventHandler"))
		{
			if(InStr(line, "_Click);"))
				CurrentControl.Events.Insert("_Click()")
			else if(InStr(line, "_DoubleClick);"))
				CurrentControl.Events.Insert("_DoubleClick()")
		}
	}
	SysLink(CurrentControl, line)
	{
		if(InStr(line, "new System.Windows.Forms.LinkLabelLinkClickedEventHandler"))
			CurrentControl.Events.Insert("_Click(URL)")
	}
}
CSharpGuiConverter_btnInput:
CSharpGuiConverter_btnOutput:
CSharpGuiConverter_btnConvert:
CSharpGuiConverter_btnRun:
CSharpGuiConverter_btnEdit:
CSharpGuiConverter_txtInput:
CSharpGuiConverter_txtOutput:
CGUI.HandleEvent()
return