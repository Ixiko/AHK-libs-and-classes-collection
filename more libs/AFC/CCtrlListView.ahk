;
; GUI List View Control Wrapper Class
;

#include <CControl>

/*!
	Class: CCtrlListView
		List view control (equivalent to `Gui, Add, ListView`).
	Inherits: CControl
	@UseShortForm
*/

class CCtrlListView extends CControl
{
	static __CtrlName := "ListView"
	
	_SelectLV()
	{
		this.__Gui()._SelectLV(this)
	}
	
	/*!
		Method: AddRow(fields, options := "")
			Adds a row to the control. Equivalent to `LV_Add`.
		Parameters:
			fields - Array containing the fields to add.
			options - (Optional) Options to apply to the row. See the AutoHotkey help file for more details.
	*/
	
	AddRow(fields, options := "")
	{
		this._SelectLV()
		return LV_Add(options, fields*)
	}
	
	/*!
		Method: InsertRow(row, fields, options := "")
			Inserts a row into the control. Equivalent to `LV_Insert`.
		Parameters:
			row - Row number at which to insert the new row.
			fields - Array containing the fields to add.
			options - (Optional) Options to apply to the row. See the AutoHotkey help file for more details.
	*/
	
	InsertRow(row, fields, options := "")
	{
		this._SelectLV()
		return LV_Insert(row, options, fields*)
	}
	
	/*!
		Method: InsertCol(col [, options := "", columnTitle])
			Inserts a column into the control. Equivalent to `LV_InsertCol`.
		Parameters:
			col - Column number at which to insert the new column.
			options - (Optional) Options to apply to the row. See the AutoHotkey help file for more details.
			columnTitle - (Optional) The title of the column.
	*/
	
	InsertCol(col, p*)
	{
		this._SelectLV()
		return LV_InsertCol(col, p*)
	}
	
	/*!
		Method: ModifyRow(row, fields, options := "")
			Modifies a row. Equivalent to `LV_Modify`.
		Parameters:
			row - Row number to modify.
			fields - Array containing the fields to modify.
			options - (Optional) Options to apply to the row. See the AutoHotkey help file for more details.
	*/
	
	ModifyRow(row, fields, options := "")
	{
		this._SelectLV()
		return LV_Modify(row, options, fields*)
	}
	
	/*!
		Method: ModifyCol(colId, options, columnTitle := "")
			Modifies a row. Equivalent to `LV_ModifyCol` with at least two parameters.
		Parameters:
			colId - Column number to modify.
			options - (Optional) Options to apply to the row. See the AutoHotkey help file for more details.
			columnTitle - (Optional) The title of the column. Omit this parameter in order not to modify it.
	*/
	
	ModifyCol(colId, options, p*)
	{
		this._SelectLV()
		return LV_ModifyCol(colId, options, p*)
	}
	
	/*!
		Method: AutoSizeCol(colId := 0)
			Automatically resizes a column according to its contents. Equivalent to `LV_ModifyCol` with up to one parameter.
		Parameters:
			colId - (Optional) Column number to autosize. If omitted the method autosizes all columns.
	*/
	
	AutoSizeCol(colId := 0)
	{
		this._SelectLV()
		return colId ? LV_ModifyCol(colId) : LV_ModifyCol()
	}
	
	/*!
		Method: DeleteRow(row)
			Deletes a row. Equivalent to `LV_Delete` with one parameter.
		Parameters:
			row - The row number to delete.
	*/
	
	DeleteRow(row)
	{
		this._SelectLV()
		return LV_Delete(row)
	}
	
	/*!
		Method: Clear()
			Deletes all rows. Equivalent to `LV_Delete` with no parameters.
	*/
	
	Clear()
	{
		this._SelectLV()
		return LV_Delete()
	}
	
	/*!
		Method: DeleteCol(col)
			Deletes a column. Equivalent to `LV_DeleteCol`.
		Parameters:
			col - The column number to delete.
	*/
	
	DeleteCol(col)
	{
		this._SelectLV()
		return LV_DeleteCol(col)
	}
	
	/*!
		Method: BindImageList(oList, iconType := "")
			Binds an image list to the control. Equivalent to `LV_SetImageList`.
		Parameters:
			oList - the [image list object](CImageList.html) to bind to the control.
			iconType - (Optional) As in `LV_SetImageList`.
	*/
	
	BindImageList(oList, iconType := "")
	{
		this._SelectLV()
		ret := iconType = "" ? LV_SetImageList(oList.__Handle) : LV_SetImageList(oList.__Handle, iconType)
		this.__ImageList := oList ; Store a reference to the image list object
		return ret
	}
	
	/*!
		Method: _NewEnum()
			Enumerates all the rows in the control.
		Remarks:
			Enumerate the rows using the `for` command:
			> for position, fields in listViewObj ; "fields" will contain an array
	*/
	
	_NewEnum()
	{
		return new this.Enumerator(this)
	}
	
	; Property getters
	class __Get extends CPropImpl
	{
		/*!
			Property: RowCount [get]
				Returns the number of rows. Equivalent to `LV_GetCount()`.
		*/
		RowCount()
		{
			this._SelectLV()
			return LV_GetCount()
		}
		
		/*!
			Property: ColCount [get]
				Returns the number of columns. Equivalent to `LV_GetCount("C")`.
		*/
		ColCount()
		{
			this._SelectLV()
			return LV_GetCount("C")
		}
		
		/*!
			Property: SelCount [get]
				Returns the number of selected rows. Equivalent to `LV_GetCount("S")`.
		*/
		
		SelCount()
		{
			this._SelectLV()
			return LV_GetCount("S")
		}
		
		/*!
			Property: NextSelectedRow[row := 0] [get]
				Returns the next selected row. Equivalent to `LV_GetNext`.
			Parameters:
				row - (Optional) The starting row. If omitted or zero it defaults to the beginning of the list.
		*/
		
		NextSelectedRow(row := 0)
		{
			this._SelectLV()
			return LV_GetNext(row)
		}
		
		/*!
			Property: NextCheckedRow[row := 0] [get]
				Returns the next checked row. Equivalent to `LV_GetNext` with the `Col` option.
			Parameters:
				row - (Optional) The starting row. If omitted or zero it defaults to the beginning of the list.
		*/
		
		NextCheckedRow(row := 0)
		{
			this._SelectLV()
			return LV_GetNext(row, "Col")
		}
		
		/*!
			Property: NextFocusedRow[row := 0] [get]
				Returns the next focused row. Equivalent to `LV_GetNext` with the `F` option.
			Parameters:
				row - (Optional) The starting row. If omitted or zero it defaults to the beginning of the list.
		*/
		
		NextFocusedRow(row := 0)
		{
			this._SelectLV()
			return LV_GetNext(row, "F")
		}
		
		/*!
			Property: RowData[row] [get]
				Returns an array containing a row's fields.
			Parameters:
				row - The row to retrieve.
		*/
		
		RowData(row)
		{
			this._SelectLV()
			obj := []
			Loop, % LV_GetCount("Col")
			{
				LV_GetText(ov, row, A_Index)
				obj.Insert(ov)
			}
			return obj
		}
		
		/*!
			Property: Item[row, col] [get/set]
				This property represents a specific field's text.
			Parameters:
				row - The item's row number.
				col - The item's column number.
		*/
		
		Item(row, col)
		{
			this._SelectLV()
			if !LV_GetText(ov, row, col)
				throw Exception("LV_GetText", -1) ; Short msg since so rare.
			return ov
		}
		
		/*!
			Property: ColumnText[col] [get/set]
				This property represents a specific column's text.
			Parameters:
				col - The column number.
		*/
		
		ColumnText(col)
		{
			return this.Item[0, col]
		}
	}
	
	; Property setters
	class __Set extends CPropImpl
	{
		Item(row, col, value)
		{
			this.SelectLV()
			LV_Modify(row, "Col" col, value)
		}
		
		ColumnText(col, value)
		{
			this.SelectLV()
			LV_ModifyCol(col, "", value)
		}
	}
	
	/*!
		Method: OnDoubleClick(oCtrl, row, isRightClick)
			Called when the user double-clicks a row.
		Parameters:
			oCtrl - The control that fired the event.
			row - The row number.
			isRightClick - `true` if the user double-right-clicked the row, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnColClick(oCtrl, col)
			Called when the user clicks a column.
		Parameters:
			oCtrl - The control that fired the event.
			col - The column number.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnDrag(oCtrl, row, isEnd)
			Called when the user begins or ends dragging a row or icon.
		Parameters:
			oCtrl - The control that fired the event.
			row - The row number.
			isEnd - `true` if the user finished dragging, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive drag end events, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnEdit(oCtrl, row, isEnd)
			Called when the user begins or ends editing the first field of a row.
		Parameters:
			oCtrl - The control that fired the event.
			row - The row number.
			isEnd - `true` if the user finished dragging, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive edit start events, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnClick(oCtrl, row, isRightClick)
			Called when the user clicks a row.
		Parameters:
			oCtrl - The control that fired the event.
			row - The row number.
			isRightClick - `true` if the user right-clicked the row, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnRowActivated(oCtrl, row)
			Called when the user activates a row.
		Parameters:
			oCtrl - The control that fired the event.
			row - The row number.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnMouseOut(oCtrl)
			Called when the user moves the mouse out of the control.
		Parameters:
			oCtrl - The control that fired the event.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnKeybdFocus(oCtrl, hasFocus)
			Called when the user gives or removes keyboard focus to the control.
		Parameters:
			oCtrl - The control that fired the event.
			hasFocus - `true` if the control gained focus, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive edit start events, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnItemChange(oCtrl, row, changedProperties)
			Called when the user changes an item.
		Parameters:
			oCtrl - The control that fired the event.
			row - The row number.
			changedProperties - See `I` event's documentation on `ErrorLevel`.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnKeyPress(oCtrl, keyVK)
			Called when the user presses a key.
		Parameters:
			oCtrl - The control that fired the event.
			keyVK - The virtual key code of the key.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnMarquee(oCtrl)
			Called when the user starts drag a selection-rectangle around a group of rows or icons.
		Parameters:
			oCtrl - The control that fired the event.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnScroll(oCtrl, isBegin)
			Called when the user begins or ends scrolling the control.
		Parameters:
			oCtrl - The control that fired the event.
			isBegin - `true` if the user started scrolling, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	OnEvent(oCtrl, guiEvent, eventInfo)
	{
		if IsLabel(lbl := "__CCtrlListView_OnEvent_" guiEvent)
			goto %lbl%
		return
		
		__CCtrlListView_OnEvent_DoubleClick:
		__CCtrlListView_OnEvent_R:
		return oCtrl.OnDoubleClick.(this, oCtrl, eventInfo, !!InStr(guiEvent, "R"))
		
		__CCtrlListView_OnEvent_ColClick:
		return oCtrl.OnColClick.(this, oCtrl, eventInfo)
		
		__CCtrlListView_OnEvent_D:
		return oCtrl.OnDrag.(this, oCtrl, eventInfo, guiEvent == "d")
		
		__CCtrlListView_OnEvent_e:
		return oCtrl.OnEdit.(this, oCtrl, eventInfo, guiEvent == "e")
		
		__CCtrlListView_OnEvent_Normal:
		__CCtrlListView_OnEvent_RightClick:
		return oCtrl.OnClick.(this, oCtrl, eventInfo, !!InStr(guiEvent, "R"))
		
		__CCtrlListView_OnEvent_A:
		return oCtrl.OnRowActivated.(this, oCtrl, eventInfo)
		
		__CCtrlListView_OnEvent_C:
		return oCtrl.OnMouseOut.(this, oCtrl)
		
		__CCtrlListView_OnEvent_F:
		return oCtrl.OnKeybdFocus.(this, oCtrl, eventInfo == "F")
		
		__CCtrlListView_OnEvent_I:
		return oCtrl.OnItemChange.(this, oCtrl, eventInfo, ErrorLevel)
		
		__CCtrlListView_OnEvent_K:
		return oCtrl.OnKeyPress.(this, oCtrl, eventInfo)
		
		__CCtrlListView_OnEvent_M:
		return oCtrl.OnMarquee.(this, oCtrl)
		
		__CCtrlListView_OnEvent_S:
		return oCtrl.OnScroll.(this, oCtrl, eventInfo == "S")
	}
	
	class Enumerator
	{
		__New(obj, row := 1, top := 0)
		{
			this.o := obj
			this.i := row
			this.t := top ? top : obj.RowCount()
		}
		
		Next(ByRef k, ByRef v)
		{
			obj := this.o, i := this.i
			if (i > obj.t)
				return false
			v := obj.RowData[this.i := i++]
			return true
		}
	}
}

/*!
	End of class
*/
