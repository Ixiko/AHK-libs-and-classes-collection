/*
License: Commercial Attribution 3.0
	http://objectlistview.sourceforge.net/cs/index.html

	Credits:
		ObjectListView

	TODO:
		For edit settings GUI, in addition to providing a separate GUI to edit everything,
			see about inserting a final row which has an "Settings" button.
		Add buttons and other cool images, just like it is displayed on the website in the license,.
		Shrink column to fit screen
		WindowSpy++ to use CFlyout_ListBox instead of TreeView
*/

class CFlyout_New
{
	m_sRowID := "Row"
	m_sChildID := "Child"
	m_asColHeaders := ""
	m_vXML := ""

	__New(asColHeaders="", asParms*)
	{
		global

		if (asColHeaders)
			this.m_asColHeaders := asColHeaders

		; Load settings from FlyoutConfig.xml
		this.LoadDefaultSettings()

		; Override default settings by parsing function parms.
		this.ParseParms(asParms)

		this.m_vCLRObj := this.GetCSLib()
		this.m_vForm := this.m_vCLRObj.GetForm()

		; Set up form from aParms. Unrecognized parms will simply be ignored.
		asParms.Insert("RowID=" this.m_sRowID)
		asParms.Insert("ChildID=" this.m_sChildID)
		if (this.m_iMaxRows)
			asParms.Insert("MaxRows=" this.m_iMaxRows)

		this.m_vForm.Init(this.m_sType, st_glue(asParms, "|"))

		; Compile the helper class. This could be pre-compiled.
		FileRead c#, lib\EventHelper.cs
		vHelperAsm := CLR_CompileC#(c#)
		vHelper := vHelperAsm.CreateInstance("EventHelper")

		; Add an event handler for the "OnEvent" event.  Use "" to pass the
		; address as a string, since IDispatch doesn't support 64-bit integers.
		vHelper.AddHandler(this.m_vForm.m_vView, "m_hOnClick", "" RegisterCallback("OnClick",,, this.m_vForm.Handle))
		vHelper.AddHandler(this.m_vForm.m_vView, "m_hOnDblClick", "" RegisterCallback("OnDblClick",,, this.m_vForm.Handle))
		vHelper.AddHandler(this.m_vForm.m_vView, "m_hOnKeyDown", "" RegisterCallback("OnKeyDown",,, this.m_vForm.Handle))
		vHelper.AddHandler(this.m_vForm.m_vView, "m_hOnFormClosing", "" RegisterCallback("OnFormClosing",,, this.m_vForm.Handle))

		if (this.m_bExitOnEsc)
		{
			Hotkey, IfWinActive, % "ahk_id" this.m_vForm.Handle
				Hotkey, Esc, CFlyout_New_GUIEscape
		}
		else
		{
			Hotkey, IfWinActive, % "ahk_id" this.m_vForm.Handle
				Hotkey, Esc, CFlyout_New_GUIMinimize
		}

		CFlyout_New.FromHwnd[this.m_vForm.Handle] := &this ; for OnMessage handlers.

		if (this.m_bStartExpanded)
			this.m_vForm.Expand()

		; Automatically resize the columns AFTER expansion.
		this.m_vForm.AutoResizeColumns()

		if (this.m_bShowOnCreate)
			this.m_vForm.Show()

		return this

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;
		CFlyout_New_GUIEscape:
		{
			Object(CFlyout_New.FromHwnd[WinExist("A")]).__Delete()
			return
		}
		;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;
		CFlyout_New_GUIMinimize:
		{
			Object(CFlyout_New.FromHwnd[WinExist("A")]).Hide()
			return
		}
		;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	}

	__Delete()
	{
		;this.m_vCLRObj.Unload() ; free dll.
		CLR_StopDomain(this.m_vAppDomain) ; free dll.
		this.m_vForm := ; free obj.
		this.m_vCLRObj := ; free obj.
		this :=

		return
	}

	__Get(sGet)
	{
		if (sGet = "m_hFlyout")
			return this.m_vForm.Handle
		if (sGet = "m_sCurSel")
			return this.m_vForm.getSelText()

		return
	}

	; Wrapper for OnMessage. All window messages that need monitoring should be sent through this function instead of directly sent to native OnMessage
		; 1.Msgs is a comma-delimited list of Window Messages. All messages are initially directed towards CFlyout_OnMessage.
	; Class-specific functionality, such as WM_LBUTTONDOWN messages, are handled in this function.
		; 2.sCallback is the function name of a callback for CFlyout_OnMessage. sCallback must be a function that takes two parameters: a CFlyout object and a msg.
	OnMessage(msgs, sCallback="")
	{
		static WM_LBUTTONDOWN:=513, WM_KEYDOWN:=256

		Loop, Parse, msgs, `,
		{
			if (A_LoopField = "Copy")
			{
				; TODO: OLV should naturally allow this.
				;~ Hotkey, IfWinActive, % "ahk_id" this.m_hFlyout
					;~ Hotkey, ^C, CFlyout_New_OnCopy
			}
			;~ else OnMessage(A_LoopField, "CFlyout_New_OnMessage")

			if (%A_LoopField% == WM_LBUTTONDOWN)
				this.m_bHandleClick := false
		}

		;~ if (this.m_bHandleClick)
			;~ OnMessage(WM_LBUTTONDOWN, "CFlyout_New_OnMessage")

		this.m_sCallbackFunc := sCallback
		return
	}

	Clear()
	{
		this.m_vXML := 0
		this.m_vForm.Clear()

		return
	}

	getText(iAt) ; iAt is 1-based.
	{
		return this.m_vForm.getText(iAt-1)
	}

	Setup_AddRow(avData)
	{
		if (!IsObject(this.m_vLVItems))
		{
			this.m_vLVItems := ComObjCreate("Scripting.Dictionary")

			for iCol, sCol in this.m_asColHeaders
			{
				if (!sCol)
					continue
				this.m_vLVItems.Add(sCol, ComObjCreate("Scripting.Dictionary"))
			}
		}

		for iRow, avRowData in avData
		{
			for iCol, sCell in avRowData
			{
				sCol := this.m_asColHeaders[iCol]
				vSubItems := this.m_vLVItems.item(sCol)

				vSubItems.Add(vSubItems.Count, sCell)
			}
		}

		return
	}

	Setup_AddRoot(vRowData)
	{
		if (!IsObject(this.m_vXML)) {
			this.m_vXML := ComObjCreate("MSXML2.DOMDocument.6.0")
			this.m_vXML.async := false
			this.m_vXML.loadXML("<Root>`r`n</Root>")
		}

		return this.SetRowForNode(vRowData) ; return new parent node.
	}

	Setup_AddChild(vParentNode, vChildData)
	{
		return this.SetChildForNode(vParentNode, vChildData) ; return new child node.
	}

	Setup_Create()
	{
		if (this.m_sType == "ListView") {
			this.m_vForm.LoadFromList(this.m_vLVItems)
		}
		else {
			if (!IsObject(this.m_vXML)) {
				; TODO: Msgbox error.
				return false
			}

			this.m_vForm.CreateFromXML(this.m_vXML)
		}

		if (this.m_bStartExpanded)
			this.m_vForm.Expand()

		; Automatically resize the columns AFTER expansion.
		this.m_vForm.AutoResizeColumns()

		if (this.m_bShowOnCreate)
			this.m_vForm.Show()

		return true
	}

	CreateFromObject(vRoot)
	{
		; Create XML
		this.m_vXML := ComObjCreate("MSXML2.DOMDocument.6.0")
		this.m_vXML.async := false
		this.m_vXML.loadXML("<Root>`r`n</Root>")

		vColSet := new EasyIni()
		for sRow, avRowData in vRoot
		{
			vColSet.Task := sRow
			vColSet.Internal_Func := ""

			this.SetRowForNode(vColSet)

			vParentNode := this.m_vXML.getElementsByTagName(this.m_sRowID).Item(A_Index-1)
			this.SetChildForNode(vParentNode, avRowData, this.m_asColHeaders)
		}

		return this.m_vXML
	}

	Show()
	{
		WinShow, % "ahk_id" this.m_vForm.Handle
		WinSet, Top,, % "ahk_id" this.m_vForm.Handle
		WinActivate, % "ahk_id" this.m_vForm.Handle

		this.m_bIsHidden := false
		return
	}

	Hide()
	{
		; If we don't minimize and then hide, then an imprint of the form is left over the desktop.
		WinMinimize, % "ahk_id" this.m_vForm.Handle
		WinHide, % "ahk_id" this.m_vForm.Handle

		this.m_bIsHidden := true
		return
	}

	ExpandAll()
	{
		this.m_vForm.Expand()
	}

	GetCSLib()
	{
		sDir := A_AhkPath
		iEndPos := InStr(sDir, "\Autohotkey.exe")-1
		sDir := SubStr(sDir, 1, iEndPos)
		sBaseDir := sDir "\lib"
		sPathToLib := sDir "\lib\CFlyout.dll"

		csCode =
	(
		using System;
		using System.Collections.Generic;
		using System.Linq;
		using System.Reflection;
		using System.Windows.Forms;

		class Library
		{
			AppDomain g_vDom;

			public Form GetForm()
			{
				AppDomain.CurrentDomain.AssemblyResolve += (sender, args) =>
				{

					// Change this to wherever the additional dependencies are located    
					var dllPath = @"%sBaseDir%";

					//var assemblyPath = System.IO.Path.Combine(dllPath, args.Name.Split(',').First() + ".dll");
					//MessageBox.Show(dllPath);
					var assemblyPath = System.IO.Path.Combine(dllPath, args.Name.Split(',')[0] + ".dll");
					//MessageBox.Show(assemblyPath);

					if (!System.IO.File.Exists(assemblyPath))
						throw new ReflectionTypeLoadException(new[] { args.GetType() },
							new[] { new System.IO.FileNotFoundException(assemblyPath) });

					return Assembly.LoadFrom(assemblyPath);
				};

				Assembly assembly = Assembly.LoadFile(@"%sPathToLib%");
				Type type = assembly.GetType("CFlyout.Form1");
				object obj = Activator.CreateInstance(type);

				Form form = obj as Form;
				return form;
			}

			public Form OldGetForm()
			{
				var domaininfo = new AppDomainSetup();
				domaininfo.ApplicationBase = @"%sPathToLib%";
				//Create evidence for the new appdomain from evidence of the current application domain
				System.Security.Policy.Evidence adEvidence = AppDomain.CurrentDomain.Evidence;
				g_vDom = AppDomain.CreateDomain("some", adEvidence, domaininfo);
				AssemblyName assemblyName = new AssemblyName();
				assemblyName.CodeBase = @"%sPathToLib%";

				try
				{
					Assembly assembly = g_vDom.Load(assemblyName);
					Type type = assembly.GetType("CFlyout.Form1");
					object obj = Activator.CreateInstance(type);
					Form form = obj as Form;

					return form;
				}
				catch (Exception vEx)
				{
					MessageBox.Show(vEx.Message);
					return null;
				}
			}

			public void Unload()
			{
				AppDomain.Unload(g_vDom);
			}
		}
	)

		CLR_StartDomain(pApp, sPathToLib)
		this.m_vAppDomain := pApp

		vAsm := CLR_CompileC#(csCode, "System.dll | System.Management.dll "
		. " | System.Windows.Forms.dll | System.Reflection.dll"
		. " | System.Linq.dll | System.Collections.dll")
		vCSLib := CLR_CreateObject(vAsm, "Library")

		return vCSLib
	}

	SetRowForNode(vRowData)
	{
		vNode := this.m_vXML.createElement(this.m_sRowID)

		bAddColHeaders := this.m_asColHeaders.MaxIndex() > 0
		for col, sRow in vRowData
		{
			;~ Msgbox % st_concat("`n", col, sRow)
			vNode.setAttribute(col, sRow)
			this.m_vXML.getElementsByTagName("Root").Item("0").appendChild(vNode)

			if (bAddColHeaders)
				this.m_asColHeaders.Insert(col)
		}

		return vNode
	}

	SetChildForNode(vParentNode, avData)
	{
		vChild :=

		for key, val in avData
		{
			;~ Msgbox % st_concat("`n", A_ThisFunc "()", key, val, avData, key.1, val.1, IsObject(key), IsObject(val))

			if (IsObject(key)) ; if the key is an object, then we have children.
			{
				;~ Msgbox % st_concat("`n", "Encountered object", key, val)
				vChildNode := this.PopulateChild(vParentNode, key)
				vChild := this.SetChildForNode(vChildNode, val)
			}
			else ; key is a number and val is row data
				vChild := this.PopulateChild(vParentNode, val)
		}

		return vChild
	}

	PopulateChild(vParentNode, vRowData)
	{
		; Create child.
		vChildNode := this.m_vXML.createElement(this.m_sChildID)

		;~ Msgbox % st_concat("`n", A_ThisFunc "()", IsObject(vRowData), vRowData)
		; Populate child attributes.
		for iRow, sRow in vRowData ; for every child node, the key will be a row of data.
		{
			vChildNode.setAttribute(this.m_asColHeaders[iRow], sRow)
			;~ Msgbox % st_concat("`n", A_ThisFunc "(in for loop)", iRow, sRow)
		}

		; Add child to parent.
		vParentNode.appendChild(vChildNode)

		return vChildNode
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: CenterWndOnOwner
			Purpose:
		Parameters
			hWnd: Window to center.
			hOwner=0: Owner of hWnd with which to center hWnd upon. If 0 or WinGetPos fails,
				window is centered on primary monitor.
	*/
	CenterWndOnOwner(hWnd, hOwner=0)
	{
		WinGetPos,,, iW, iH, ahk_id %hWnd%

		WinGetPos, iOwnerX, iOwnerY, iOwnerW, iOwnerH, ahk_id %hOwner%
		if (iOwnerX == A_Blank)
		{
			iOwnerX := 0
			iOwnerY := 0
			iOwnerW := A_ScreenWidth
			iOwnerH := A_ScreenHeight
		}

		iXPct := (100 - ((iW * 100) / (iOwnerW)))*0.5
		iYPct := (100 - ((iH * 100) / (iOwnerH)))*0.5

		iX := Round((iXPct / 100) * iOwnerW + iOwnerX)
		iY := Round((iYPct / 100) * iOwnerH + iOwnerY)

		WinMove, ahk_id %hWnd%, , iX, iY

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: ParseParms
			Purpose: Parse parms in aParms and set appropriate member variables
		Parameters
			aParms
	*/
	ParseParms(aParms)
	{
		static s_asKeysMap := {X: "iX", Left: "iX", Y: "iY", Top: "iY", Right: "iW", W: "iW", R: "iMaxRows"
		, AnchorAt: "iAnchorAt", AutoSizeW: "bAutoSizeW", ConserveWidth: "bConserveWidth"
		, FollowMouse: "bFollowMouse", DrawBelowAnchor: "bDrawBelowAnchor", ShowOnCreate: "bShowOnCreate"
		, ExitOnEsc: "bExitOnEsc", ReadOnly: "bReadOnly", ShowInTaskbar: "bShowInTaskbar"
		, AlwaysOnTop: "bAlwaysOnTop", Parent: "hParent", Background: "sBackground"
		, Font: "sFont", Highlight: "sHighlightColor", Separator: "sSeparator", ShowBorder: "bShowBorder"
		, StartExpanded: "bStartExpanded", RowID: "sRowID", ChildID: "sChildID"
		, Debug: "bDebug", ImageTrans: "iImageTrans", Type: "sType", UseGroups: "bUseGroups"}

		for iParm, sParm in aParms
		{
			sParm := Trim(sParm) ; Spaces can mess things up.

			iPosOfEquals := InStr(sParm, "=")
			sKey := SubStr(sParm, 1, iPosOfEquals-1)
			sVal := SubStr(sParm, iPosOfEquals+1)

			; Build string list of errors.
			bValidKey := true
			if (!s_asKeysMap.HasKey(sKey))
			{
				bValidKey := false
				sErrors .= (sErrors ? "`n" : "") "Invalid key:`t" sKey "=" sVal
			}

			if (sKey = "Font")
			{
				; Add keys first or else weird crashes can happen.
				this.m_sFont := this.m_sFontColor := ""

				; Format is native GUI format: Consolas, s16 c0xFF
				iCommaPos := InStr(sVal, ",")
				if (iCommaPos)
				{
					sFontOpts := SubStr(sVal, iCommaPos+1)
					StringSplit, aFontOpts, sFontOpts, %A_Space%
					; Find font color c0xFF.
					Loop %aFontOpts0%
					{
						sFontOpt := Trim(aFontOpts%A_Index%) ; Spaces seriously mess things up.
						if (SubStr(sFontOpt, 1, 1) = "c")
						{
							this.m_sFontColor := sFontOpt
							; Now set m_sFont.
							StringReplace, sNewFont, sVal, %sFontOpt%
							this.m_sFont := sNewFont
							break
						}
					}
					; If no font color was specified, m_sFont is simply the val
					if (!this.m_sFont)
						this.m_sFont := sVal
				}
			}
			else if (sKey = "Highlight")
			{
				; Add keys first or else weird crashes can happen.
				this.m_sHighlightTrans := this.m_sHighlightColor :=

				; Format is t200 c0x0
				iCommaPos := InStr(sVal, ",")
				sOpts := SubStr(sVal, iCommaPos+1)
				StringSplit, aOpts, sOpts, %A_Space%
				; Find font color c0xFF.
				Loop %aOpts0%
				{
					sOpt := Trim(aOpts%A_Index%) ; Spaces seriously mess things up.
					sSubKey := SubStr(sOpt, 1, 1)
					sSubVal := SubStr(sOpt, 2)

					if (sSubKey = "t")
						this.m_sHighlightTrans := sSubVal
					else if (sSubKey = "c")
						this.m_sHighlightColor := sSubVal
				}
			}
			else
			{
				sClassKey := s_asKeysMap[sKey]

				; Is this a bool?
				if (SubStr(sClassKey, 1, 1) = "b")
					sVal := (sVal == true || sVal = "true")

				; Dynamically set key/val pair!
				this["m_" sClassKey] := sVal
				
			}
		}

		; Display list of errors for non-compiled scripts.
		if (sErrors && !A_IsCompiled)
			Msgbox 8256,, %sErrors%

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Loads settings for flyout from Flyout_Config.ini. If any options are not specified,
	; the default options specified in GetDefaultConfigIni will be used. If any unknown keys are in the inis, they are simply ignored.
	; You can override default settings in __New
	LoadDefaultSettings()
	{
		vDefaultConfigIni := class_EasyIni("", this.GetDefaultConfigIni())
		this.m_vConfigIni := class_EasyIni(A_WorkingDir "\Flyout_config.ini")
		; Merge allows new sections/keys to be added without any compatibility issues
		; Invalid keys/sections will be removed since bRemoveNonMatching (by default) is set to true
		this.m_vConfigIni.Merge(vDefaultConfigIni)
		this.m_vConfigIni.Save() ; So the old ini gets the new data.

		for key, val in this.m_vConfigIni.Flyout
		{
			if (InStr(val, "Expr:"))
				val := DynaExpr_EvalToVar(SubStr(val, InStr(val, "Expr:") + 5))

			if (key = "X")
				this.m_iX := val
			else if (key = "Y")
				this.m_iY := val
			else if (key = "W")
				this.m_iW := val
			else if (key = "AutoSizeW")
				this.m_bAutoSizeW := (val == true || val = "true")
			;~ else if (key = "H")
				;~ this.m_iH := val
			else if (key = "MaxRows")
				this.m_iMaxRows := val
			else if (key = "AnchorAt")
				this.m_iAnchorAt := val
			else if (key = "DrawBelowAnchor")
				this.m_bDrawBelowAnchor := (val == true || val = "true")
			else if (key = "Background")
				this.m_sBackground := val
			else if (key = "ReadOnly")
				this.m_bReadOnly := (val == true || val = "true")
			else if (key = "ShowInTaskbar")
				this.m_bShowInTaskbar := (val == true || val = "true")
			else if (key = "ShowOnCreate")
				this.m_bShowOnCreate := (val == true || val = "true")
			else if (key = "ExitOnEsc")
				this.m_bExitOnEsc := (val == true || val = "true")
			else if (key = "AlwaysOnTop")
				this.m_bAlwaysOnTop := (val == true || val = "true")
			else if (key = "Font")
			{
				; This is probably only an issue for me, but it's nice to fix it for me.
				StringReplace, val, val, c000000,, All
				this.m_sFont := val
			}
			else if (key = "FontColor")
				this.m_sFontColor := "c" val
			else if (key = "HighlightColor")
				this.m_sHighlightColor := val
			else if (key = "HighlightTrans")
				this.m_sHighlightTrans := val
			else if (key = "ShowBorder")
				this.m_bShowBorder := (val == true || val = "true")
			; else Errors here cause a crash. It's weird, and I think it has to do with DynaExpr.
			; but is erroring even a good idea? What if it's just a deprecated key?
			; For now, let's just ignore it.
		}

		return true
	}

	; Member Variables

	; public:
		; [Flyout] in Flyout_config.ini. All may also be set from __New
		m_iX :=
		m_iY :=
		m_iW :=
		m_iMaxRows :=
		m_iAnchorAt :=
		m_bDrawBelowAnchor :=
		m_bReadOnly :=
		m_bShowInTaskbar :=
		m_bAlwaysOnTop :=

		m_sBackground :=

		; Font Dlg
		m_sFont :=
		m_sFontColor :=
		m_sHighlightColor :=
		m_sHighlightTrans :=
		; End Flyout_config.ini section.

	; private:
		m_vConfigIni := {}

		m_bFollowMouse := false ; Set to true when m_iX and m_iY are less than -32768
		static m_iMouseOffset := 16 ; Static pixel offset used to separate mouse pointer from Flyout when m_bFollowMouse is true

		m_sSeparator := ; The idea is to fill a completely empty line a specified separator such as "-"
		m_sSeparatorLine :=

		m_bIsHidden := ; True when Hide() is called. False when Show() is called.

		; Handles
		m_hFlyout := ; Handle to main GUI
		m_hListBox :=
		m_hFont := ; Handle to logical font for Text control
		m_hParent := ; Handle to parent assigned from hParent in __New

		; Control IDs
		m_vLB :=
		m_vSelector :=

		m_iFlyoutNum := ; Needed to multiple CFlyouts
		m_asItems := [] ; Formatted for Text control display purposes

		; OnMessage callback
		m_sCallbackFunc := ; Function name for optional OnMessage callbacks
		m_bHandleClick := true ; Internally handle clicks by moving selection.
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Message handler for all messages specified through CFlyout.OnMessage.
;;;;;;;;;;;;;; Class-specific functionality, such as WM_LBUTTONDOWN messages, are handled in this function.
CFlyout_New_OnMessage(wParam, lParam, msg, hWnd)
{
	Critical

	; hWnd isn't always the flyout, so we can't use that.
	; A_GUIControl is reliably the ListBox from the Flyout,
	; so getting the parent of that will give us the correct flyout.
	GUIControlGet, hGUICtrl, hWnd, %A_GUIControl%
	hFlyout := DllCall("GetParent", uint, hGUICtrl)
	vFlyout := Object(CFlyout_New.FromHwnd[hFlyout])

	if (this.m_bHandleClick && msg == WM_LBUTTONDOWN:=513)
	{
		CoordMode, Mouse, Relative
		MouseGetPos,, iClickY
		vFlyout.Click(iClickY)
	}

	if (IsFunc(vFlyout.m_sCallbackFunc))
		bRet := Func(vFlyout.m_sCallbackFunc).(vFlyout, msg)

	vFlyout :=
	return bRet
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OnFormClosing(aParms)
{
	; Give callback a chance to act upon the closing message,
	; such as prompting to exit. If the callback returns false,
	; then don't exit.
	; It's also very important because the caller is responsible for deleting any global CFlyout,
	; otherwise the class destructor is never triggered.
	if (!StdCBProc(A_EventInfo, WM_CLOSE:=16))
		return

	return
}

OnClick(pprm)
{
	prm := ComObject(0x200C, pprm)
	return StdCBProc(A_EventInfo, WM_LBUTTONDOWN:=513)
}

OnDblClick(pprm)
{
	prm := ComObject(0x200C, pprm)
	return StdCBProc(A_EventInfo, WM_LBUTTONDBLCLK:=515)
}

OnKeyDown(pprm)
{
	prm := ComObject(0x200C, pprm)
	iKey := prm[1].KeyCode
	return StdCBProc(A_EventInfo, iKey)
}

StdCBProc(iEventInfo, iMsg)
{
	vFlyout := Object(CFlyout_New.FromHwnd[iEventInfo])
	if (IsFunc(vFlyout.m_sCallbackFunc))
		bRet := Func(vFlyout.m_sCallbackFunc).(vFlyout, iMsg)

	vFlyout :=
	return bRet
}