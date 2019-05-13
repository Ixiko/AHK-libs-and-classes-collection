		### Sub-commands  
		**(Blank)**: Leave Sub-command blank to retrieve the control's contents. All control types are self-explanatory
		except the following:  
		
		[Picture](http://ahkscript.org/docs/commands/GuiControls.htm#Picture){_blank}: Retrieves the picture's file
		name as it was originally specified when the control was created.
		This name does not change even if a new picture file name is specified.
		
		[Edit](http://ahkscript.org/docs/commands/GuiControls.htm#Edit){_blank}: Retrieves the contents but any line breaks
		in the text will be represented as plain linefeeds (\`n) rather than the traditional CR+LF (\`r\`n) used by non-GUI
		commands such as [ControlGetText](http://ahkscript.org/docs/commands/GuiControls.htm#Edit){_blank}
		and [ControlSetText](http://ahkscript.org/docs/commands/ControlSetText.htm){_blank}.
		
		[Hotkey](http://ahkscript.org/docs/commands/GuiControls.htm#Hotkey){_blank}: Retrieves a blank value if there is
		no hotkey in the control. Otherwise it retrieves the modifiers and key name. Examples: `^!C`, `^Home, +^NumpadHome`.
		
		[Checkbox](http://ahkscript.org/docs/commands/GuiControls.htm#Checkbox){_blank}
		/[Radio](http://ahkscript.org/docs/commands/GuiControls.htm#Radio){_blank}:
		Retrieves 1 if the control is checked, 0 if it is unchecked, or -1 if it has a gray checkmark. To retrieve the
		control's text/caption instead, specify the word Text for Param4. Note: Unlike the
		[Gui Submit](http://ahkscript.org/docs/commands/Gui.htm#Submit){_blank} command, radio buttons are always
		retrieved individually, regardless of whether they are in a radio group.
		
		[UpDown](http://ahkscript.org/docs/commands/GuiControls.htm#UpDown){_blank}/
		[Slider](http://ahkscript.org/docs/commands/GuiControls.htm#Slider){_blank}/
		[Progress](http://ahkscript.org/docs/commands/GuiControls.htm#Progress){_blank}: Retrieves the control's current position.
		
		[Tab](http://ahkscript.org/docs/commands/GuiControls.htm#Tab){_blank}/
		[DropDownList](http://ahkscript.org/docs/commands/GuiControls.htm#DropDownList){_blank}/
		[ComboBox](http://ahkscript.org/docs/commands/GuiControls.htm#ComboBox){_blank}/
		[ListBox](http://ahkscript.org/docs/commands/GuiControls.htm#ListBox){_blank}: Retrieves the text of the currently
		selected item/tab \(or its position if the control has the [AltSubmit](http://ahkscript.org/docs/commands/Gui.htm#AltSubmit){_blank}
		property\). For a ComboBox, if there is no selected item, the text in the control's edit field is retrieved instead. For a
		[multi-select ListBox](http://ahkscript.org/docs/commands/GuiControls.htm#ListBoxMulti){}, the output uses the window's
		[current delimiter](http://ahkscript.org/docs/commands/Gui.htm#Delimiter){}.
		
		[ListView](http://ahkscript.org/docs/commands/ListView.htm){_blank} and
		[TreeView](http://ahkscript.org/docs/commands/TreeView.htm){_blank}: These are not supported when Sub-command is blank.
		Instead, use the built-in [ListView functions](http://ahkscript.org/docs/commands/ListView.htm#BuiltIn){_blank} and
		[TreeView functions](http://ahkscript.org/docs/commands/TreeView.htm#BuiltIn){_blank}
		
		[StatusBar](http://ahkscript.org/docs/commands/GuiControls.htm#StatusBar){_blank}: Retrieves only the first part's text.
		
		[ActiveX:](http://ahkscript.org/docs/commands/GuiControls.htm#ActiveX){} Retrieves a new wrapper object for the
		control's ActiveX component.
		
		**Note**: To unconditionally retrieve any control's text/caption rather than its contents, specify the word Text for *Param4*.
		
		**GuiControlGet, OutputVar, Pos**: Retrieves the position and size of the control. The position is relative to the GUI
		window's client area, which is the area not including title bar, menu bar, and borders. The information is stored in
		four variables whose names all start with OutputVar. For example:
		> MyEdit := Mfunc.GuiControlGet("Pos", "MyEdit")
		> MsgBox The X coordinate is %MyEditX%. The Y coordinate is %MyEditY%. The width is %MyEditW%. The height is %MyEditH%.
		Within a [function](http://ahkscript.org/docs/Functions.htm){_blank}, to create a set of variables that is global
		instead of local, [declare](http://ahkscript.org/docs/Functions.htm#Global){_blank} OutputVar as a global variable
		prior to using this command (the converse is true for
		[assume-global](http://ahkscript.org/docs/Functions.htm#AssumeGlobal){_blank} functions).
		
		**GuiControlGet, OutputVar, Focus**: Retrieves the control identifier (ClassNN) for the control that currently has
		keyboard focus. Since the specified GUI window must be [active](http://ahkscript.org/docs/commands/WinActivate.htm){_blank}
		for one of its controls to have focus, OutputVar will be made blank if it is not active. Example usage:
		`focused_control := Mfunc.GuiControlGet("focus")`.
		
		**GuiControlGet, OutputVar, FocusV** *"v1.0.43.06+"*: Same as Focus (above) except that it retrieves the name of the
		focused control's [associated](http://ahkscript.org/docs/commands/Gui.htm#Events){_blank} variable. If that control
		lacks an associated [variable](http://ahkscript.org/docs/commands/Gui.htm#Events){_blank}, the first 63 characters
		of the control's text/caption is retrieved instead (this is most often used to avoid giving each button a variable name).
		
		**GuiControlGet, OutputVar, Enabled**: Retrieves 1 if the control is enabled or 0 if it is disabled.
		
		**GuiControlGet, OutputVar, Visible**: Retrieves 1 if the control is visible or 0 if it is hidden.
		
		**GuiControlGet, OutputVar, Hwnd** [v1.0.46.16+]: Retrieves the window handle (HWND) of the control. A control's HWND
		is often used with [PostMessage](http://ahkscript.org/docs/commands/PostMessage.htm){_blank},
		[SendMessage](http://ahkscript.org/docs/commands/PostMessage.htm){_blank}, and
		[DllCall](http://ahkscript.org/docs/commands/DllCall.htm){_blank}. Note:
		[HwndOutputVar](http://ahkscript.org/docs/commands/Gui.htm#HwndOutputVar){_blank} is usually a more
		concise way to get the HWND.
		
		GuiControlGet, OutputVar, Name *"v1.1.03+"*: Retrieves the name of the control's
		[associated variable](http://ahkscript.org/docs/commands/Gui.htm#Events){_blank} if it has one,
		otherwise return value is made blank.
		
		### Remarks  
		Wrapper for [AutoHotkey Docs - GuiControlGet](http://ahkscript.org/docs/commands/GuiControlGet.htm){_blank}.  
		Static method.
		
		To operate upon a window other than the default (see below), include its name or number followed by a
		colon in front of the sub-command as in these examples:  
		> MyEdit := Mfunc.GuiControlGet("MyGui:")
		> MyEdit := Mfunc.GuiControlGet("MyGui:Pos")
		> Outputvar := Mfunc.GuiControlGet("MyGui:Focus")
		This is required even if ControlID is a control's associated variable or HWND.  
		A GUI [thread](http://ahkscript.org/docs/misc/Threads.htm){_blank} is defined as any thread launched as a result of
		a GUI action. GUI actions include selecting an item from a GUI window's menu bar, or triggering one of its
		[g-labels](http://ahkscript.org/docs/commands/Gui.htm#label){_blank} (such as by pressing a button).
		
		The [default window name](http://ahkscript.org/docs/commands/Gui.htm#DefaultWin){_blank} for a GUI thread is
		that of the window that launched the thread. Non-GUI threads use 1 as their default.
		
		Any and/or all parameter for this function can be instance of [MfString](MfString.html) or var containing string.
		
		See Also:[AutoHotkey Docs - GuiControlGet](http://ahkscript.org/docs/commands/GuiControlGet.htm){_blank}.
		
		### Throws
		Throws [MfException](MfException.html) if [Autohotkey - FileRemoveDir](http://ahkscript.org/docs/commands/FileRemoveDir.htm){_blank}
		throw any errors with [InnerException](MfException.InnerException.html) set to the
		[Autohotkey - FileRemoveDir](http://ahkscript.org/docs/commands/FileRemoveDir.htm){_blank} error message.  
		Throws [MfException](MfException.html) any other general error occurs.	