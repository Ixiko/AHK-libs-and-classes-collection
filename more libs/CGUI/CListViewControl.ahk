/*
Class: CListViewControl
A ListView control. Additionally to its features present in AHK it can use sorting-independent indexing for synchronizing its fields with an array.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CListViewControl Extends CControl
{
	static registration := CGUI.RegisterControl("ListView", CListViewControl)

	EditingStart := new EventHandler()
	DoubleClick := new EventHandler()
	DoubleRightClick := new EventHandler()
	EditingEnd := new EventHandler()
	Click := new EventHandler()
	RightClick := new EventHandler()
	ItemActivate := new EventHandler()
	KeyPress := new EventHandler()
	ColumnClick := new EventHandler()
	FocusReceived := new EventHandler()
	ScrollingStart := new EventHandler()
	MouseLeave := new EventHandler()
	FocusLost := new EventHandler()
	Marquee := new EventHandler()
	ScrollingEnd := new EventHandler()
	ItemChecked := new EventHandler()
	ItemUnChecked := new EventHandler()
	SelectionChanged := new EventHandler()
	CheckedChanged := new EventHandler()
	FocusedChanged := new EventHandler()
	
	__New(Name, ByRef Options, Text, GUINum)
	{
		if(!InStr(Options, "AltSubmit")) ;Automagically add AltSubmit
			Options .= " AltSubmit"
			
		base.__New(Name, Options, Text, GUINum)
		this._.Insert("ControlStyles", {ReadOnly : -0x200, Header : -0x4000, NoSortHdr : 0x8000, AlwaysShowSelection : 0x8, Multi : -0x4, Sort : 0x10, SortDescending : 0x20})
		this._.Insert("ControlExStyles", {Checked : 0x4, FullRowSelect : 0x20, Grid : 0x1, AllowHeaderReordering : 0x10, HotTrack : 0x8})
		this._.Insert("Events", ["DoubleClick", "DoubleRightClick", "ColumnClick", "EditingEnd", "Click", "RightClick", "ItemActivate", "EditingStart", "KeyPress", "FocusReceived", "FocusLost", "Marquee", "ScrollingStart", "ScrollingEnd", "ItemSelected", "ItemDeselected", "ItemFocused", "ItemDefocused", "ItemChecked", "ItemUnChecked", "SelectionChanged", "CheckedChanged", "FocusedChanged"])
		;~ this._.Insert("Messages", {0x004E : "Notify"}) ;This control uses WM_NOTIFY with NM_SETFOCUS and NM_KILLFOCUS
		this.IndependentSorting := false ;Set to skip redundant __Get calls
		this.Type := "ListView"
	}
	
	PostCreate()
	{
		Base.PostCreate()
		this._.Insert("ImageListManager", new this.CImageListManager(this.GUINum, this.hwnd))
		this._.Insert("Items", new this.CItems(this.GUINum, this.hwnd))
	}
	/*
	Function: ModifyCol
	Modifies a column. All parameters are optional, see AHK help on LV_ModifyCol for details.
	
	Parameters:
		ColumnNumber - The number of the column to modify, one-based
		Options - The new width. See AHK documentation.
		ColumnTitle - The new column title.
	*/
	ModifyCol(Params*)
	{
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		if(!CGUI_Assert(!(Params.MaxIndex() > 3), "ModifyCol: This function accepts no more than 3 parameters."))
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_ModifyCol(Params*)
	}
	/*
	Function: InsertCol
	Inserts a column. See AHK help on LV_InsertCol for details.
	
	Parameters:
		ColumnNumber - The position of the new column
		Options - The new width. See AHK documentation.
		ColumnTitle - The new column title.
	*/
	InsertCol(Params*)
	{
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		if(!CGUI_Assert(!(Params.MaxIndex() > 3), "InsertCol: This function accepts no more than 3 parameters."))
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_InsertCol(Params*)
	}
	/*
	Function: DeleteCol
	Deletes a column. See AHK help on LV_DeleteCol for details.
	*/
	DeleteCol(ColumnNumber)
	{
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_DeleteCol(ColumnNumber)
	}
	/*
	Property: Items
	An array of all ListView rows. See <CListViewControl.CItems>.
	
	Property: SelectedItem
	Contains the (first) selected row.
	
	Property: SelectedItems
	Contains all selected rows.
	
	Property: SelectedIndex
	Contains the index of the (first) selected row.
	
	Property: SelectedIndices
	Contains all indices of the selected rows.
	
	Property: CheckedItem
	Contains the (first) checked row.
	
	Property: CheckedItems
	Contains all checked rows.
	
	Property: CheckedIndex
	Contains the index of the (first) checked row.
	
	Property: CheckedIndices
	Contains all indices of the checked rows.
	
	Property: FocusedItem
	Contains the focused row.
	
	Property: FocusedIndex
	Contains the index of the focused row.
	
	Property: List
	Set to true to use the List view mode.
	
	Property: Report
	Set to true to use the Report view mode.
	
	Property: Icon
	Set to true to use the Icon view mode.
	
	Property: IconSmall
	Set to true to use the IconSmall view mode.
	
	Property: Tile
	Set to true to use the Tile view mode.
	
	Property: LargeIcons
	True if this control should display large icons. Only used in List and Report view modes.
	
	Property: IndependentSorting
	This setting is off by default. In this case, indexing the rows behaves like AHK ListViews usually do.
	If it is enabled however, the row indexing will be independent of the current sorting.
	That means that the first row can actually be displayed as the second, third,... or last row on the GUI.
	This feature is very useful if you need to synchronize an array with the data in the ListView
	because the index of the array can then be directly mapped to the ListView row index.
	This would not be possible if this option was off and the ListView gets sorted differently.
	*/
	__Get(Name, Params*)
	{
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Items")
				Value := this._.Items
			else if(Name = "SelectedIndices" || Name = "SelectedItems" || Name = "CheckedIndices" || Name = "CheckedItems")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := []
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1, InStr(Name, "Checked") ? "Checked" : "") = A_Index)
					{
						Index := (this.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_Index, this.hwnd) : A_Index)
						Value.Insert(InStr(Name, "Indices") ? Index : this._.Items[Index]) ;new this.CItems.CRow(this.CItems.GetSortedIndex(A_Index, this.hwnd), this.GUINum, this.Name))
					}
			}
			else if(Name = "SelectedIndex" || Name = "SelectedItem" || Name = "CheckedIndex" || Name = "CheckedItem")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1, InStr(Name, "Checked") ? "Checked" : "") = A_Index)
					{
						Index := (this.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_Index, this.hwnd) : A_Index)
						Value := InStr(Name, "Index") ? Index : this._.Items[Index] ;new this.CItems.CRow(this.CItems.GetSortedIndex(A_Index, this.hwnd), this.GUINum, this.Name))
						break
					}
			}
			else if(Name = "FocusedItem" || Name = "FocusedIndex")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := LV_GetNext(0, "Focused")
				if(this.IndependentSorting)
					Value := this.CItems.CRow.GetUnsortedIndex(Value, this.hwnd)
				if(Name = "FocusedItem")
					Value := this._.Items[Value] ;new this.CItems.CRow(Value, this.GUINum, this.Name)
			}
			else if(Name = "PreviouslySelectedItem")
				Value := this._.PreviouslySelectedItem
			else if(Name = "List" || Name = "Report" || Name = "Icon" || Name = "IconSmall" || Name = "Tile")
				Value := this._[Name]
			else if(Name = "LargeIcons")
				Value := this._.ImageListManager.LargeIcons
			Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Params*)
	{
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			;Fix completely weird __Set behavior. If one tries to assign a value to a sub item, it doesn't call __Get for each sub item but __Set with the subitems as parameters.
			Value := Params.Remove()
			if(Params.MaxIndex())
			{
				Params.Insert(1, Name)
				Name :=  Params.Remove()
				return (this[Params*])[Name] := Value
			}
			if(Name = "SelectedIndices" || Name = "CheckedIndices" || Name = "SelectedItems" || Name = "CheckedItems")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				if(InStr(Name, "Items"))
				{
					Indices := Array()
					for index, item in Value
						Indices.Insert(item._.RowNumber)
				}
				else
				{
					Indices := Value
					if(!IsObject(Value))
					{
						Indices := Array()
						Loop, Parse, Value,|
							if A_LoopField is Integer
								Indices.Insert(A_LoopField)
					}
				}
				LV_Modify(0, InStr(Name, "Selected") ? "-Select" : "-Check")
				Loop % Indices.MaxIndex()
					if(Indices[A_Index] > 0)
						LV_Modify(this.IndependentSorting ? this.CItems.CRow.GetSortedIndex(Indices[A_Index], this.hwnd) : Indices[A_Index], InStr(Name, "Selected") ? "Select" : "Check")
				if(InStr(Name, "Selected"))
				{
					if(LV_GetCount("Selected") = 1)
					{
						this._.PreviouslySelectedItem := this.Items[this._.SelectedIndex]
						this._.SelectedIndex := this.SelectedIndex
						this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
					}
					else
					{
						this.ProcessSubControlState(this._.PreviouslySelectedItem, "")
						this._.PreviouslySelectedItem := ""
						this._.SelectedIndex := ""
					}
				}
			}
			else if(Name = "SelectedIndex" || Name = "CheckedIndex" || Name = "SelectedItem" || Name = "CheckedItem")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				if(InStr(Name, "Item"))
					Value := Value._.RowNumber
				LV_Modify(0, InStr(Name, "Selected") ? "-Select" : "-Check")
				if(Value > 0)
				{
					LV_Modify(this.IndependentSorting ? this.CItems.CRow.GetSortedIndex(Value, this.hwnd) : Value, InStr(Name, "Selected") ? "Select" : "Check")
					if(InStr(Name, "Selected"))
					{
						if(LV_GetCount("Selected") = 1)
						{
							this._.PreviouslySelectedItem := this.Items[this._.SelectedIndex]
							this._.SelectedIndex := this.SelectedIndex
							this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
						}
						else
						{
							this.ProcessSubControlState(this._.PreviouslySelectedItem, "")
							this._.PreviouslySelectedItem := ""
							this._.SelectedIndex := ""
						}
					}
				}
			}
			else if(Name = "FocusedIndex" || Name = "FocusedItem")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				if(InStr(Name, "Item"))
					Value := Value._.RowNumber
				LV_Modify(this.IndependentSorting ? this.CItems.CRow.GetSortedIndex(Value, this.hwnd) : Value, "Focused")
			}
			else if(Name = "Items" && IsObject(Value) && IsObject(this._.Items) && Params.MaxIndex() > 0)
			{
				Items := this._.Items
				Items[Params*] := Value
			}
			else if(Name = "Items")
				Value := 0
			else if((Properties := {List : "List", Report : "Report", IconSmall : "IconSmall", Icon : "Icon", Tile : "Tile"})[Name])
			{
				for k, v in Properties
					this._[k] := false
				this._[Name] := true
				;Other views use the "large" image list anyway where appropriate.
				if(Name != "Report")
					this.LargeIcons := false
				GuiControl, % this.GUINum ":+" Name, this.hwnd
			}
			else if(Name = "Redraw")
				GuiControl, % this.GUINum ":" (Value = true ? "+" : "-") "Redraw" , this.hwnd
			else if(Name = "LargeIcons")
				this._.ImageListManager.LargeIcons := Value = 1
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
	}
	
	/*
	Class: CListViewControl.CItems
	An array of all ListView rows.
	*/
	Class CItems
	{
		__New(GUINum, hwnd)
		{
			ObjInsert(this, "_", {})
			this._.GUINum := GUINum
			this._.hwnd := hwnd
		}
		_NewEnum()
		{
			return new CEnumerator(this)
		}
		/*
		Function: MaxIndex
		Returns the number of rows.
		*/
		MaxIndex()
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Gui, % this._.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			return LV_GetCount()
		}
		/*
		Function: Add
		Adds a row.
		
		Parameters:
			Options - Options for the new row. See AHK documentation on LV_Add().
			Fields - Any additional parameters are used as cell text.
			
		Returns: The added <CRow> item
		*/
		Add(Options, Fields*)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Gui, % this._.GUINum ":Default"
			Gui, ListView, % Control.hwnd
			SortedIndex := LV_Add(Options, Fields*)
			UnsortedIndex := (UnsortedIndex := this._.MaxIndex() + 1) ? UnsortedIndex : 1
			Row := new this.CRow(SortedIndex, UnsortedIndex, this._.GUINum, this._.hwnd)
			this._.Insert(UnsortedIndex, Row)
			if(InStr(Options, "Select"))
			{
				if(LV_GetCount("Selected") = 1)
				{
					Control._.PreviouslySelectedItem := Control.Items[Control._.SelectedIndex]
					Control._.SelectedIndex := Control.SelectedIndex
					Control.ProcessSubControlState(Control._.PreviouslySelectedItem, Control.SelectedItem)
				}
				else
				{
					Control.ProcessSubControlState(Control._.PreviouslySelectedItem, "")
					Control._.PreviouslySelectedItem := ""
					Control._.SelectedIndex := ""
				}
			}
			return Row
		}
		/*
		Function: Insert
		Inserts a row.
		
		Parameters:
			RowNumber - Index before which the row is inserted.
			Options - Options for the new row. See AHK documentation on LV_Add().
			Fields - Any additional parameters are used as cell text.
		*/
		Insert(RowNumber, Options, Fields*)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			SortedIndex := Control.IndependentSorting ? this.CRow.GetSortedIndex(RowNumber, Control.hwnd) : RowNumber ;If independent sorting is off, the RowNumber parameter of this function is interpreted as sorted index
			if(SortedIndex = -1 || SortedIndex > LV_GetCount())
				SortedIndex := LV_GetCount() + 1
			
			UnsortedIndex := this.CRow.GetUnsortedIndex(SortedIndex, Control.hwnd)
			
			;move all unsorted indices >= the insertion point up by one to make place for the insertion
			Loop % LV_GetCount() - UnsortedIndex + 1
			{
				index := LV_GetCount() - A_Index + 1 ;loop backwards
				sIndex := this.CRow.GetSortedIndex(index, Control.hwnd) - 1
				this.CRow.SetUnsortedIndex(sIndex, index + 1, Control.hwnd)
				this._[index + 1] := this._[index] ;Fix up the internally stored indices
				this._[index + 1]._.RowNumber := index + 1
			}
			
			SortedIndex := LV_Insert(SortedIndex, Options, Fields*)
			this._.Insert(UnsortedIndex, new this.CRow(SortedIndex, UnsortedIndex, this._.GUINum, Control.hwnd))
			if(InStr(Options, "Select"))
			{
				if(LV_GetCount("Selected") = 1)
				{
					Control._.PreviouslySelectedItem := Control.Items[Control._.SelectedIndex]
					Control._.SelectedIndex := Control.SelectedIndex
					Control.ProcessSubControlState(Control._.PreviouslySelectedItem, Control.SelectedItem)
				}
				else
				{
					Control.ProcessSubControlState(Control._.PreviouslySelectedItem, "")
					Control._.PreviouslySelectedItem := ""
					Control._.SelectedIndex := ""
				}
			}
		}
		
		/*
		Function: Modify
		Modifies a row.
		
		Parameters:
			RowNumberOrItem - Index of the row or the item which should be modified.
			Options - Options for the modified row. See AHK documentation on LV_Modify().
			Fields - Any additional parameters are used as cell text.
		*/
		Modify(RowNumberOrItem, Options, Fields*)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			if(!IsObject(RowNumberOrItem))
				RowNumberOrItem := Control.Items[RowNumberOrItem]
			if(IsObject(RowNumberOrItem))
				RowNumberOrItem.Modify(Options, Fields*)
		}
		
		/*
		Function: Clear
		Clears the ListView by deleting all rows.
		*/
		Clear()
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			LV_Delete()
			Loop % Control.Items._.MaxIndex()
				Control.Items._.Remove(A_Index, "")
			Control._.PreviouslySelectedItem := Control.Items[Control._.SelectedIndex]
			Control.ProcessSubControlState(Control._.PreviouslySelectedItem, "")
			Control._.SelectedIndex := ""
		}
		/*
		Function: Delete
		Deletes a row.
		
		Parameters:
			RowNumberOrItem - Index of the row which should be deleted or a <CRow> object.
		*/
		Delete(RowNumberOrItem)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			if(IsObject(RowNumberOrItem))
				RowNumberOrItem := RowNumberOrItem._.RowNumber
			WasSelected := Control.Items[RowNumberOrItem].Selected
			SortedIndex := Control.IndependentSorting ? this.CRow.GetSortedIndex(RowNumberOrItem, Control.hwnd) : RowNumberOrItem ;If independent sorting is off, the RowNumber parameter of this function is interpreted as sorted index
			UnsortedIndex := Control.IndependentSorting ? RowNumberOrItem : this.CRow.GetUnsortedIndex(SortedIndex, Control.hwnd)
			;Decrease the unsorted indices after the deletion index by one
			Loop % LV_GetCount() - UnsortedIndex
			{
				this.CRow.SetUnsortedIndex(this.CRow.GetSortedIndex(UnsortedIndex + A_Index, Control.hwnd), UnsortedIndex + A_Index - 1, Control.hwnd)
				this._[UnsortedIndex + A_Index - 1] := this._[UnsortedIndex + A_Index] ;Fix up the internally stored indices
				this._.Remove(UnsortedIndex + A_Index)
				this._[UnsortedIndex + A_Index - 1]._.RowNumber := UnsortedIndex + A_Index - 1
			}
			result := LV_Delete(SortedIndex)
			
			if(WasSelected)
			{
				if(LV_GetCount("Selected") = 1)
				{
					Control._.PreviouslySelectedItem := Control.Items[Control._.SelectedIndex]
					Control._.SelectedIndex := Control.SelectedIndex
					Control.ProcessSubControlState(Control._.PreviouslySelectedItem, Control.SelectedItem)
				}
				else
				{
					Control.ProcessSubControlState(Control._.PreviouslySelectedItem, "")
					Control._.PreviouslySelectedItem := ""
					Control._.SelectedIndex := ""
				}
			}
		}
		/*
		Property: 1,2,3,4,...
		Rows can be accessed by their index, e.g. this.ListView.Items[1][2] accesses the text of the first row and second column.
		
		Property: Count
		The number of rows.
		*/
		__Get(Name)
		{
			if(Name != "_")
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI.Controls[this._.hwnd]
				if Name is Integer
				{
					if(Name > 0 && Name <= this.Count)
						return this._[Control.IndependentSorting ? Name : this.CRow.GetUnsortedIndex(Name, Control.hwnd)]
				}
				else if(Name = "Count")
					return this.MaxIndex()
			}
		}
		__Set(Name, Params*)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			;Fix completely weird __Set behavior. If one tries to assign a value to a sub item, it doesn't call __Get for each sub item but __Set with the subitems as parameters.
			Value := Params.Remove()
			if(Params.MaxIndex())
			{
				Params.Insert(1, Name)
				Name := Params.Remove()
				return (this[Params*])[Name] := Value
			}
			if Name is Integer
			{
				if(!Params.MaxIndex()) ;Setting a row directly is not allowed
					return
				else ;Set a column or other row property
				{
					return (this[Name])[Params*] := Value
				}
			}
		}
		
		/*
		Class: CListViewControl.CItems.CRow
		A single row of a ListView control.
		CRow uses the unsorted row numbers internally, but it can switch to sorted row numbers depending on the setting of the ListView.
		*/
		Class CRow
		{
			__New(SortedIndex, UnsortedIndex, GUINum, hwnd)
			{
				this.Insert("_", {})
				this._.RowNumber := UnsortedIndex
				this._.GUINum := GUINum
				this._.hwnd := hwnd
				GUI := CGUI.GUIList[GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI.Controls[hwnd]
				;Store the real unsorted index in the custom property lParam field of the list view item so it can be reidentified later
				this.SetUnsortedIndex(SortedIndex, UnsortedIndex, Control.hwnd)
				this.SetIcon("")
				this._.Insert("Controls", {})
			}
			/*
			Function: AddControl
			Adds a control to this item that will be visible/enabled only when this item is selected. The parameters correspond to the Add() function of CGUI.
			
			Parameters:
				Type - The type of the control.
				Name - The name of the control.
				Options - Options used for creating the control.
				Text - The text of the control.
				UseEnabledState - If true, the control will be enabled/disabled instead of visible/hidden.
			*/
			AddControl(type, Name, Options, Text, UseEnabledState = 0)
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(!this.Selected)
					Options .= UseEnabledState ? " Disabled" : " Hidden"
				Control := GUI.AddControl(type, Name, Options, Text, this._.Controls, this)
				Control._.UseEnabledState := UseEnabledState
				Control.hParentControl := this._.hwnd
				return Control
			}
			;Sets the unsorted index of a list item (in its custom data field)
			/*
			typedef struct {
			  UINT   mask; 4
			  int    iItem; 4
			  int    iSubItem; 4
			  UINT   state; 4
			  UINT   stateMask; 4 (+4 padding)
			  LPTSTR pszText; 4-8
			  int    cchTextMax; 4
			  int    iImage; 4
			  LPARAM lParam; 4-8
			#if (_WIN32_IE >= 0x0300)
			  int    iIndent; 4
			#endif
			#if (_WIN32_WINNT >= 0x0501)
			  int    iGroupId; 4
			  UINT   cColumns; 4
			  UINT   puColumns; 4
			#endif
			#if (_WIN32_WINNT >= 0x0600)
			  int    piColFmt; 4
			  int    iGroup; 4
			#endif
			} LVITEM, *LPLVITEM;
			*/
			SetUnsortedIndex(SortedIndex, UnsortedIndex, hwnd)
			{
				static LVM_SETITEM := (A_IsUnicode ? 0x1000 + 76 : 0x1000 + 6)
				VarSetCapacity(LVITEM, 12*4 + 3 * A_PtrSize, 0)
				NumPut(0x4, LVITEM, 0, "UInt") ; LVIF_PARAM := 0x4
				NumPut(SortedIndex - 1, LVITEM, 4, "Int")   ; iItem
				NumPut(UnsortedIndex, LVITEM, 6*4 + 2*A_PtrSize, "PTR")
				return DllCall("SendMessage", "PTR", hwnd, "UInt", LVM_SETITEM, "PTR", 0, "PTR", &LVITEM, "PTR")
			}
			;Returns the sorted index (by which AHK usually accesses listviews) by searching for a custom index that is independent of sorting
			/*
			typedef struct tagLVFINDINFO {
			  UINT    flags; 4 (+4 padding)
			  LPCTSTR psz; 4-8
			  LPARAM  lParam; 4- 8
			  POINT   pt; 8
			  UINT    vkDirection; 4 (+4 padding)
			} LVFINDINFO, *LPFINDINFO;
			*/
			GetSortedIndex(UnsortedIndex, hwnd)
			{
				static LVM_FINDITEM := (A_IsUnicode ? 0x1000 + 83 : 0x1000 + 13)
				;Create the LVFINDINFO structure
				VarSetCapacity(LVFINDINFO, 2*4 + 4 * A_PtrSize, 0)
				NumPut(0x1, LVFINDINFO, 0, "UInt") ; LVFI_PARAM := 0x1
				NumPut(UnsortedIndex, LVFINDINFO, 2* A_PtrSize, "PTR")
				return DllCall("SendMessage", "PTR", hwnd, "uint", LVM_FINDITEM, "PTR", -1, "PTR", &LVFINDINFO, "PTR") + 1
			}
			;Gets the unsorted index of a list item from its custom data field
			GetUnsortedIndex(SortedIndex, hwnd)
			{
				static LVM_GETITEM := (A_IsUnicode ? 0x1000 + 75 : 0x1000 + 5)
				VarSetCapacity(LVITEM, 12*4 + 3 * A_PtrSize, 0)
				NumPut(0x4, LVITEM, 0, "UInt") ; LVIF_PARAM := 0x4
				NumPut(SortedIndex - 1, LVITEM, 4, "Int")   ; iItem
				DllCall("SendMessage", "PTR", hwnd, "UInt", LVM_GETITEM, "PTR", 0, "PTR", &LVITEM, "PTR")
				return NumGet(LVITEM, 6*4 + 2*A_PtrSize, "PTR")
			}
			_NewEnum()
			{
				return new CEnumerator(this)
			}
			/*
			Function: MaxIndex
			Returns the number of columns.
			*/
			MaxIndex()
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI.Controls[this._.hwnd]
				Gui, % Control.GUINum ":Default"
				Gui, ListView, % Control.ClassNN
				Return LV_GetCount("Column")
			}
			/*
			Function: SetIcon
			Sets the icon of a ListView row
			
			Parameters:
				Filename - The filename of the file containing the icon or a hBitmap.
				IconNumberOrTransparencyColor - The icon number or the transparency color if the used file has no transparency support.
			*/
			SetIcon(Filename, IconNumberOrTransparencyColor = 1)
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI.Controls[this._.hwnd]
				Control._.ImageListManager.SetIcon(this.GetSortedIndex(this._.RowNumber, Control.hwnd), Filename, IconNumberOrTransparencyColor)
				this._.Icon := Filename
				this._.IconNumber := IconNumberOrTransparencyColor
			}
			/*
			Function: Modify
			Modifies a row.
			
			Parameters:
				Options - Options for the modified row. See AHK documentation on LV_Modify().
				Fields - Any additional parameters are used as cell text.
			*/
			Modify(Options, Fields*)
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI.Controls[this._.hwnd]
				Gui, % Control.GUINum ":Default"
				Gui, ListView, % Control.ClassNN
				SortedIndex := Control.IndependentSorting ? this.GetSortedIndex(this._.RowNumber, Control.hwnd) : this._.RowNumber ;If independent sorting is off, the RowNumber parameter of this function is interpreted as sorted index
				LV_Modify(SortedIndex, Options, Fields*)
				if(InStr(Options, "Select"))
				{
					if(LV_GetCount("Selected") = 1)
					{
						Control._.PreviouslySelectedItem := Control.Items[Control._.SelectedIndex]
						Control._.SelectedIndex := Control.SelectedIndex
						Control.ProcessSubControlState(Control._.PreviouslySelectedItem, Control.SelectedItem)
					}
					else
					{
						Control.ProcessSubControlState(Control._.PreviouslySelectedItem, "")
						Control._.PreviouslySelectedItem := ""
						Control._.SelectedIndex := ""
					}
				}
			}
			/*
			Property: 1,2,3,4,...
			Columns can be accessed by their index, e.g. this.ListView.Items[1][2] accesses the text of the first row and second column.
			
			Property: Text
			The text of the first column of this row.
			
			Property: Index
			The index of this row. It obeys the setting of IndependentSorting.
			
			Property: Count
			The number of columns.
			
			Property: Checked
			True if the row is checked.
			
			Property: Selected
			True if the row is selected.
			
			Property: Focused
			True if the row is foucsed.
			
			Property: Icon
			The filename of the file containing the icon for the current row.
			
			Property: IconNumber
			The number of the icon in a multi-icon file.
			*/
			__Get(Name)
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(!GUI.IsDestroyed)
				{
					Control := GUI.Controls[this._.hwnd]
					if Name is Integer
					{
						if(Name > 0 && Name <= this.Count) ;Setting default listview is already done by this.Count __Get
						{
							LV_GetText(value, this.GetSortedIndex(this._.RowNumber, Control.hwnd), Name)
							return value
						}
					}
					else if(Name = "Text")
						return this[1]
					else if(Name = "Index")
						return Control.IndependentSorting ? this._.RowNumber : this.GetSortedIndex(this._.RowNumber, Control.hwnd)
					else if(Name = "Count")
					{
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.ClassNN
						Return LV_GetCount("Column")
					}
					else if Name in Checked,Focused,Selected
					{
						Value := {Checked : "Checked", Focused : "Focused", Selected : ""}[Name]
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.ClassNN
						return this.GetUnsortedIndex(LV_GetNext(this.GetSortedIndex(this._.RowNumber, Control.hwnd) - 1, Value), Control.hwnd) = this._.RowNumber
					}
					else if(Name = "Icon" || Name = "IconNumber")
						return this._[Name]
					else if(Name = "Controls")
						return this._.Controls
				}
			}
			__Set(Name, Params*)
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(!GUI.IsDestroyed)
				{
					;Fix completely weird __Set behavior. If one tries to assign a value to a sub item, it doesn't call __Get for each sub item but __Set with the subitems as parameters.
					Value := Params.Remove()
					if(Params.MaxIndex())
					{
						Params.Insert(1, Name)
						Name := Params.Remove()
						return (this[Params*])[Name] := Value
					}
					Control := GUI.Controls[this._.hwnd]
					if Name is Integer
					{
						if(Name <= this.Count) ;Setting default listview is already done by this.Count __Get
							LV_Modify(this.GetSortedIndex(this._.RowNumber, Control.hwnd), "Col" Name, Value)
						return Value
					}
					else if(Name = "Text")
					{
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.hwnd
						LV_Modify(this.GetSortedIndex(this._.RowNumber, Control.hwnd), "Col" 1, Value)
						return Value
					}
					else if((Key := {Checked : "Check", Focused : "Focus", Selected : "Select"}).HasKey(Name))
					{
						Key := Key[Name]
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.hwnd
						LV_Modify(this.GetSortedIndex(this._.RowNumber, Control.hwnd), (Value = 0 ? "-" : "") Key)
						if(Name = "Selected")
						{
							if(LV_GetCount("Selected") = 1)
							{
								Control._.PreviouslySelectedItem := Control.Items[Control._.SelectedIndex]
								Control._.SelectedIndex := Control.SelectedIndex
								Control.ProcessSubControlState(Control._.PreviouslySelectedItem, Control.SelectedItem)
							}
							else
							{
								Control.ProcessSubControlState(Control._.PreviouslySelectedItem, "")
								Control._.PreviouslySelectedItem := ""
								Control._.SelectedIndex := ""
							}
						}
						return Value
					}
					else if(Name = "Icon")
					{
						this.SetIcon(Value, this._.HasKey("IconNumber") ? this._.IconNumber : 1)
						return Value
					}
					else if(Name = "IconNumber")
					{
						this._.IconNumber := Value
						if(this._.Icon)
							this.SetIcon(this._.Icon, Value)
						return Value
					}
				}
			}
		}
	}
	
	/*
	Event: Introduction
	There are currently 3 methods to handle control events:
	
	1)	Use an event handler. Simply use control.EventName.Handler := "HandlingFunction"
		Instead of "HandlingFunction" it is also possible to pass a function reference or a Delegate: control.EventName.Handler := new Delegate(Object, "HandlingFunction")
		If this method is used, the first parameter will contain the control object that sent this event.
		
	2)	Create a function with this naming scheme in your window class: ControlName_EventName(params)
	
	3)	Instead of using ControlName_EventName() you may also call <CControl.RegisterEvent> on a control instance to register a different event function name.
		This method is deprecated since event handlers are more flexible.
		
	The parameters depend on the event and there may not be params at all in some cases.
	
	Event: Click(RowItem)
	Invoked when the user clicked on the control.
	
	Event: DoubleClick(RowItem)
	Invoked when the user double-clicked on the control.
	
	Event: RightClick(RowItem)
	Invoked when the user right-clicked on the control.
	
	Event: DoubleRightClick(RowItem)
	Invoked when the user double-right-clicked on the control.
	
	Event: ColumnClick(ColumnIndex)
	Invoked when the user clicked on a column header.
	
	Event: EditingStart(RowItem)
	Invoked when the user started editing the first cell of a row.
	
	Event: EditingEnd(RowItem)
	Invoked when the user finished editing a cell.
	
	Event: ItemActivate(RowItem)
	Invoked when a row was activated.
	
	Event: KeyPress(KeyCode)
	Invoked when the user pressed a key while the control had focus.
	
	Event: MouseLeave()
	Invoked when the mouse leaves the control boundaries.
	
	Event: FocusReceived()
	Invoked when the control receives the focus.
	
	Event: FocusLost()
	Invoked when the control loses the focus.
	
	Event: Marquee()
	Invoked when the mouse gets moved over the control.
	
	Event: ScrollingStart()
	Invoked when the user starts scrolling the control.
	
	Event: ScrollingEnd()
	Invoked when the user ends scrolling the control.
	
	Event: SelectionChanged(RowItem)
	Invoked when the selected item(s) has/have changed.
	
	Event: ItemFocused(RowItem)
	Invoked when a row gets focused.
	
	Event: ItemDefocused(RowItem)
	Invoked when a row loses the focus.
	
	Event: FocusedChanged(RowItem)
	Invoked when the row focus has changed.
	
	Event: ItemChecked(RowItem)
	Invoked when the user checks a row.
	
	Event: ItemUnchecked(RowItem)
	Invoked when the user unchecks a row.
	
	Event: CheckedChanged(RowItem)
	Invoked when the checked row(s) has/have changed.
	*/
	HandleEvent(Event)
	{
		Row := this.Items[this.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(Event.EventInfo, this.hwnd) : Event.EventInfo]
		if(Event.GUIEvent == "E")
			this.CallEvent("EditingStart", Row)
		else if(EventName := {DoubleClick : "DoubleClick", R : "DoubleRightClick",e : "EditingEnd", Normal : "Click", RightClick : "RightClick",  A : "ItemActivate"}[Event.GUIEvent])
			this.CallEvent(EventName, Row)
		else if(EventName := {K : "KeyPress", ColClick : "ColumnClick"}[Event.GUIEvent])
			this.CallEvent(EventName, Event.EventInfo)
		else if(Event.GUIEvent == "F")
			this.CallEvent("FocusReceived")
		else if(Event.GUIEvent == "S")
			this.CallEvent("ScrollingStart")
		else if(EventName :=  {C : "MouseLeave", f : "FocusLost", M : "Marquee", s : "ScrollingEnd"}[Event.GUIEvent])
			this.CallEvent(EventName)
		else if(Event.GUIEvent = "I")
		{
			if(InStr(Event.Errorlevel, "S")) ;Process sub control state
			{
				if(LV_GetCount("Selected") = 1)
				{
					this._.PreviouslySelectedItem := this.Items[this._.SelectedIndex]
					this._.SelectedIndex := this.SelectedIndex
					this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
				}
				else
				{
					this.ProcessSubControlState(this._.PreviouslySelectedItem, "")
					this._.PreviouslySelectedItem := ""
					this._.SelectedIndex := ""
				}
			}
			Mapping := {Ca : "ItemChecked", cb : "ItemUnChecked"} ;Case insensitivity strikes back!
			for EventIndex, Function in Mapping
				if(InStr(Event.Errorlevel, SubStr(EventIndex, 1, 1), true))
				{
					this.CallEvent(Function, Row)
					break
				}
			;This is handled in CGUI for all controls at the moment.
			;~ if(Event.ErrorLevel = "f")
			;~ {
				;~ CGUI.PushEvent("CGUI_FocusChange", this.GUINum)
				;~ if(Event.ErrorLevel == "F")
					;~ this.CallEvent("FocusReceived")
				;~ else if(Event.ErrorLevel == "f")
				;~ {
					;~ this.CallEvent("FocusLost")
					;~ if(CGUI.GUIList[this.GUINum].ValidateOnFocusLeave && this.IsValidatableControlType())
						;~ this.Validate()
				;~ }
			;~ }
			;ErrorLevel may contain multiple characters
			if(InStr(Event.ErrorLevel, "S"))
				this.CallEvent("SelectionChanged", Row)
			if(InStr(Event.ErrorLevel, "C"))
				this.CallEvent("CheckedChanged", Row)
			if(InStr(Event.ErrorLevel, "F"))
				this.CallEvent("FocusedChanged", Row)
		}
	}
}