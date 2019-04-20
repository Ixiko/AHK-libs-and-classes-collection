/*
;===================================================================================
Listview Supplementary Library v1.0
;===================================================================================
	Functions:
	- LVG_Search()
	- LVG_Get()
	- LVG_Count_Un()
	- LVG_GetNext_Un()
	- LVG_Check()
	- LVG_Select()
	- LVG_Delete()
;===================================================================================
LVG_Search()
		Returns the...
			- Total number of the rows, that contain "Search string" and that are...
			- Row numbers of all rows (comma separated list), that contain "Search string" and that are...
			- Row number of the next row, that contains "Search string" and that's...
			
			* Selected
			* Deselected
			* Checked
			* Unchecked
			* Selected AND checked
			* Deselected AND unchecked
			* Selected AND unchecked
			* Deselected AND checked
			
		...from the user specified row/column range.
		
		Quick example:
			Say you've got a Gui with the number 23 assigned to it (Gui, 23:...), and it has a Listview
		with 150 rows. You want to get the row numbers of the selected rows from the first twenty, 
		that contain the word "Scripting" in their second column. Here's how to do it:
		
			LVG_Search(23,"Selected","List","1-20","2","Scripting") 
		
;-----------------------------------------------------------------------------------	
LVG_Get()
		Returns the...
			- Total number of rows, that are...
			- Row numbers of all rows (comma separated list), that are...
			- Row number of the next row, that's...
		
			* Selected
			* Deselected
			* Checked
			* Unchecked
			* Selected AND checked
			* Deselected AND unchecked
			* Selected AND unchecked
			* Deselected AND checked
		
		...from the user specified row range 
		
		Quick example:
			LVG_Get(1,"Unchecked","Count","1-12;23-55;89;82") 
		...will return a comma separated list, that contains the total number of those unchecked rows,
		whose row numbers are: 1-12 or 23-55 or 89 or 82.
		
;-----------------------------------------------------------------------------------
LVG_Count_Un()
		Returns the row number of the next: 
			* Unchecked
			* Deselected 
		...row.
	
		Quick example:
			LVG_GetNext_Un(1,"Deselected") 
		...will return the total number of all the deselected rows from the default Listview of GUI1.
		
;-----------------------------------------------------------------------------------
LVG_GetNext_Un()
		Returns the row number of the next: 
			* Unchecked
			* Deselected 
		...row.
	
		Quick example:
			LVG_GetNext_Un(65,"Unchecked") 
		...will return the next unchecked row from the default Listview of GUI65.
		
;-----------------------------------------------------------------------------------
LVG_Check()
		Checks/Unchecks all the rows that are...
			
			* Checked
			* Unchecked
			* Selected
			* Deselected
			
			* Reverts checks
			
		Quick example:
			LVG_Select(1,"CheckAll") 
		...will check all the unchecked rows.
		
;-----------------------------------------------------------------------------------
LVG_Select()
		Selects/Deselects all the rows that are...
			
			* Selected
			* Deselected
			* Checked
			* Unchecked
			
			* Reverts selection
			
		Quick example:
			LVG_Select(1,"Reverse") 
		...will select all the deselected rows, and deselect all the selected ones.
		
;-----------------------------------------------------------------------------------		
LVG_Delete()
		Deletes all the rows that are...
		
			* Selected
			* Deselected
			* Checked
			* Unchecked
			* Selected AND checked
			* Deselected AND unchecked
			* Selected AND unchecked
			* Deselected AND checked
			
		Quick example:
			LVG_Delete(1,"Unchecked") 
		...will delete all unchecked rows.		
;=========================================
Remarks:
	- For further info on the functions' parameters see the descriptions by each function below.
	- It's not heavily commented (or should I say not commented at all)... So, if you have questions, don't hesitate to ask 'em in the forum topic.
	- The uncheck/check-related features work only if the Listview has "Checked" specified among its options
;=========================================
About:
	- Version: 1.0 by GAHKS http://www.autohotkey.net/~gahks
	- License: Attribution-Share Alike 3.0 Unported:  http://creativecommons.org/licenses/by-sa/3.0/
	- Forum topic: http://www.autohotkey.com/forum/topic49091.html
;===================================================================================
*/






/*
;===================================================================================
Function:		
	LVG_Search(GuiNumber,"Mode","Mode2","RowstoSearchIn","ColstoSearchIn","SearchString")
	
Description:
	Searches for the string specified in "SearchString" in the specified range, if any fields of the specified row contains the string, it returns the row's number according to "Mode2".
		
		
Parameters:		
	GuiNumber:				- the number of the gui, that has the target listview as its default listview control
	Mode: 
		Selected			- will search only in selected rows
		Deselected			- will search only in deselected rows
		Checked				- etc., etc.
		Unchecked
		SelectedChecked
		DeselectedUnchecked
		SelectedUnchecked
		DeselectedChecked
	Mode2:
		Count				- returns the total number of rows
		Next				- returns the row number of the next row
		List				- returns the row numbers of all the rows
	RowToSearchIn:
		All					- will search in all the rows that meet the conditions of Mode
		Semicolon-separated list of numbers or ranges in quotation marks. Eg.: "1;2;12-35;67-87;54"
							- will search only in these rows
		StartingRowNumber	- only if Mode2 is Next
	ColstoSearchIn:
		All					- will search in all the columns
		Semicolon-separated list of numbers or ranges in quotation marks. Eg.: "1-3;5;7"
							- will search only in the fields that are in this column, and in "RowToSearchIn" row
	SearchString
		String				- will search for this string in the above specified fields


Examples:
	You'd like to obtain the row numbers for any checked AND selected rows that contain the letter "a" in their first and second column starting from row thirty-four, to row fifty, including row seventy and seventy-one, from the default listview of GUI nr. 14.
	
	LVG_Search(14,"SelectedChecked","List","34-50;70;71","1-2","a")
	...will return a comma-separated list, containing all the rows that met the above conditions.
				
	Say you'd like to do the same, with the only exceptions, that you'd like to know only the total number of rows that meet these conditions:
	
	LVG_Search(14,"SelectedChecked","Total","34-50;70;71","1-2","a")
*/
;===================================================================================
LVG_Search(Gui_nr=1,mode="Selected",mode2="Count",rows="all",cols="all",srch_str="") {
	modelist=Selected,Deselected,Checked,Unchecked,SelectedChecked
	,DeselectedUnchecked,SelectedUnchecked,DeselectedChecked
	StringSplit, modelist, modelist, `,
	Loop, %modelist0%
		if (mode=modelist%a_index%)
			mode = %a_index%
	mode2list=Count,Next,List
	StringSplit, mode2list, mode2list, `,
	Loop, %mode2list0%
		if (mode2=mode2list%a_index%)
			mode2 = %a_index%
	modelist:="",mode2list:="",c:=0,count:="",s_mode:="Checked",s_mode2:=""
	if (mode=1 || mode=2 || mode=5 || mode=6 || mode=7 || mode=8)
		s_mode:="", s_mode2:="Checked"
	Gui, %Gui_nr%:Default
	if (rows <> "all")
	{
		StringSplit, row_a, rows, `; ;Splitting row parameter into subparameters
		Loop, %row_a0%
		{
			c_row_a := a_index 
			StringSplit, row_b, row_a%a_index%, -
			if row_b0 = 2
			{
				start := row_b1
				Loop, % row_b2-row_b1+1 ;+1 so that it includes the last number too (eg. by rows=4-12 it includes 12 too)
				{
					row_c%start% := 1
					start++
				}
			}
			else if row_b0 = 1
				row_c%row_b1% := 1
		}
	}
	if (cols <> "all")
	{
		StringSplit, col_a, cols, `; ;Splitting row parameter into subparameters
		Loop, %col_a0%
		{
			c_col_a := a_index 
			StringSplit, col_b, col_a%a_index%, -
			if col_b0 = 2
			{
				start := col_b1
				Loop, % col_b2-col_b1+1 ;+1 so that it includes the last number too (eg. by rows=4-12 it includes 12 too)
				{
					col_c%start% := 1
					start++
				}
			}
			else if col_b0 = 1
				col_c%col_b1% := 1
		}
	}
	pr=0
	if mode2=2
		if (rows = "all" || row_a0 <> 1 || row_b0 <> 1)
			return "ERROR"
		else
			pr:=rows
	Loop, % LV_GetCount()
	{
		c_i := a_index
		if (!row_c%c_i% && rows <> "all" && mode2 <> 2)  
		{
			pr := c_i
			Continue
		}
		if (mode2=2)
			c_i:=rows+a_index-1
		if (((LV_GetNext(pr, s_mode) = c_i) && (mode=2 || mode=4))
		|| ((LV_GetNext(pr, s_mode) <> c_i) && (mode=1 || mode=3))
		|| (((LV_GetNext(pr, s_mode) = c_i) || (LV_GetNext(pr, s_mode2) = c_i)) && mode=6)
		|| (((LV_GetNext(pr, s_mode) <> c_i) || (LV_GetNext(pr, s_mode2) <> c_i)) && mode=5)
		|| (((LV_GetNext(pr, s_mode) = c_i) || (LV_GetNext(pr, s_mode2) <> c_i)) && mode=8)
		|| (((LV_GetNext(pr, s_mode) <> c_i) || (LV_GetNext(pr, s_mode2) = c_i)) && mode=7))
		{
			pr := c_i
			Continue
		}
		else if (((LV_GetNext(pr, s_mode) = c_i) && (mode=1 || mode=3))
		|| ((LV_GetNext(pr, s_mode) <> c_i) && (mode=2 || mode=4))
		|| ((LV_GetNext(pr, s_mode) <> c_i) && (LV_GetNext(pr, s_mode2) <> c_i) && mode=6)
		|| ((LV_GetNext(pr, s_mode) = c_i) && (LV_GetNext(pr, s_mode2) = c_i) && mode=5)
		|| ((LV_GetNext(pr, s_mode) <> c_i) && (LV_GetNext(pr, s_mode2) = c_i) && mode=8)
		|| ((LV_GetNext(pr, s_mode) = c_i) && (LV_GetNext(pr, s_mode2) <> c_i) && mode=7))
		{
			Loop, % LV_GetCount("Column")
			{
				if (!col_c%a_index% && cols <> "all")
					continue
				col_i := col_c%a_index%
				if (cols = "all")
					col_i := a_index
				LV_GetText(c_t, c_i, col_i)
				IfInString, c_t, %srch_str%
				{
					if (mode2=2)
						return c_i
					else if (mode2=1)
						count++
					else if (mode2=3)
						count .= c_i . ","	
					break
				}		
			}	
			pr := c_i
		}
	}
	if mode2=3
		StringTrimRight, count, count, 1
	return count
}
/*
;===================================================================================
Function:		
	LVG_Get(GuiNumber,"Mode","Mode2","RowstoSearchIn")
			
Description:
	Returns the row numbers of the rows/total number of rows/row number of the next row according to "Mode2", that meet(s) the conditions of "Mode"	
		
Parameters:		
	GuiNumber:				- the number of the gui, that has the target listview as its default listview control
	Mode: 
		Selected			- will return selected rows only
		Deselected			- will return deselected rows only
		Checked				- etc., etc.
		Unchecked
		SelectedChecked
		DeselectedUnchecked
		SelectedUnchecked
		DeselectedChecked
	Mode2:
		Count				- returns the total number of rows
		Next				- returns the row number of the next row that meets the conditions specified in "Mode"
		List				- returns the row numbers of all the rows
	RowsToSearchIn:
		All					- will return all the rows that meet the conditions of "Mode"
		Semicolon-separated list of numbers or ranges in quotation marks. Eg.: "1;2;12-35;67-87;54"
							- will return rows from this row range if they meet Mode conditions
		StartingRowNumber	- only if Mode2 is Next	
		
Examples:
	You'd like to obtain the row numbers for any "Unchecked" rows starting from second row to the nineth row, but including row twelve and thirteen, from the default listview of GUI nr. 1.
	LVG_Get(1,"Unchecked","List","2-9;12-13")	
	...this will return a comma-separated list, containing all the rows that met the above conditions.
				
	Say you'd like to do the same, only you'd like to know the total number of rows that meet these conditions:
	LVG_Get(1,"Unchecked","Count","2-9;12-13")
	
	And now you'd like to know only the first row from the List that meets these conditions:
	LVG_Get(1,"Unchecked","Next",2)
*/
;===================================================================================
LVG_Get(Gui_nr=1,mode="Selected",mode2="Count",rows="all") {
	modelist=Selected,Deselected,Checked,Unchecked,SelectedChecked
	,DeselectedUnchecked,SelectedUnchecked,DeselectedChecked
	StringSplit, modelist, modelist, `,
	Loop, %modelist0%
		if (mode=modelist%a_index%)
			mode = %a_index%
	mode2list=Count,Next,List
	StringSplit, mode2list, mode2list, `,
	Loop, %mode2list0%
		if (mode2=mode2list%a_index%)
			mode2 = %a_index%
	modelist:="",mode2list:="",c:=0,count:="",s_mode:="Checked",s_mode2:=""
	if (mode=1 || mode=2 || mode=5 || mode=6 || mode=7 || mode=8)
		s_mode:="", s_mode2:="Checked"
	Gui, %Gui_nr%:Default
	if (rows <> "all")
	{
		StringSplit, row_a, rows, `; ;Splitting row parameter into subparameters
		Loop, %row_a0%
		{
			c_row_a := a_index 
			StringSplit, row_b, row_a%a_index%, -
			if row_b0 = 2
			{
				start := row_b1
				Loop, % row_b2-row_b1+1 ;+1 so that it includes the last number too (eg. by rows=4-12 it includes 12 too)
				{
					row_c%start% := 1
					start++
				}
			}
			else if row_b0 = 1
				row_c%row_b1% := 1
		}
	}
	pr=0
	if mode2=2
		if (rows = "all" || row_a0 <> 1 || row_b0 <> 1)
			return "ERROR"
		else
			pr:=rows
	Loop, % LV_GetCount()
	{
		c_i := a_index
		if (!row_c%c_i% && rows <> "all" && mode2 <> 2)  
		{
			pr := c_i
			Continue
		}
		if (mode2=2)
			c_i:=rows+a_index-1
		if (((LV_GetNext(pr, s_mode) = c_i) && (mode=2 || mode=4))
		|| ((LV_GetNext(pr, s_mode) <> c_i) && (mode=1 || mode=3))
		|| (((LV_GetNext(pr, s_mode) = c_i) || (LV_GetNext(pr, s_mode2) = c_i)) && mode=6)
		|| (((LV_GetNext(pr, s_mode) <> c_i) || (LV_GetNext(pr, s_mode2) <> c_i)) && mode=5)
		|| (((LV_GetNext(pr, s_mode) = c_i) || (LV_GetNext(pr, s_mode2) <> c_i)) && mode=8)
		|| (((LV_GetNext(pr, s_mode) <> c_i) || (LV_GetNext(pr, s_mode2) = c_i)) && mode=7))
		{
			pr := c_i
			Continue
		}
		else if (((LV_GetNext(pr, s_mode) = c_i) && (mode=1 || mode=3))
		|| ((LV_GetNext(pr, s_mode) <> c_i) && (mode=2 || mode=4))
		|| ((LV_GetNext(pr, s_mode) <> c_i) && (LV_GetNext(pr, s_mode2) <> c_i) && mode=6)
		|| ((LV_GetNext(pr, s_mode) = c_i) && (LV_GetNext(pr, s_mode2) = c_i) && mode=5)
		|| ((LV_GetNext(pr, s_mode) <> c_i) && (LV_GetNext(pr, s_mode2) = c_i) && mode=8)
		|| ((LV_GetNext(pr, s_mode) = c_i) && (LV_GetNext(pr, s_mode2) <> c_i) && mode=7))
		{
			if (mode2=2)
				return c_i
			else if (mode2=1)
				count++
			else if (mode2=3)
				count .= c_i . ","
			pr := c_i
		}
	}
	if mode2=3
		StringTrimRight, count, count, 1
	return count
}
/*
;===================================================================================
Function:		
	LVG_Count_Un(GuiNumber,Mode)
		
Description:
	Returns the total number of Deselected/Unchecked rows
			
Parameters:		
	GuiNumber:				- the number of the gui, that has the target listview as its default listview control
	Mode: 
		Deselected			- will return the total number of the Deselected rows
		Unchecked			- will return the total number of the Unchecked rows
			
Examples:
	This will return the total number of the Unchecked rows:
	LVG_Count_Un(1,"Unchecked")
				
Remarks
	With LVG_Get() you can use much more sophisticated filters to pick the right row, and basically it renders this functions obsolete. 
	I left it in this library, because this is a basic function that I assume many people will want to use, who don't need the full functionality of LVG_Get.
*/
;===================================================================================
LVG_Count_Un(Gui_nr=1,mode="Unchecked") {
	if mode=Unchecked
		mode=1
	else if mode=Deselected
		mode=2
	count:=0,s_mode:="Checked"
	If mode=2
		s_mode=
	Gui, %Gui_nr%:Default
	pr := 0
	Loop, % LV_GetCount()
	{
		If (LV_GetNext(pr, s_mode) = a_index)
			pr := a_index
		Else
			count++
	}
	return count
}
/*
;===================================================================================
Function:		
	LVG_GetNext_Un(GuiNumber,"Mode",StartingRowNumber)
			
Description:
	Returns the row number of the next Deselected/Unchecked row (starting from StartingRowNumber).
			
Parameters:		
	GuiNumber:				- the number of the gui, that has the target listview as its default listview control
	Mode: 
		Deselected			- will return the row number of the next Deselected row
		Unchecked			- will return the row number of the next Unchecked row
	StartingRowNumber:		- the row number from which to start
					
Examples:
	This will return the row number of the next Deselected row after row nr. 23.
	LVG_GetNext_Un(1,"Deselected", 23)
	
Remarks
	With LVG_Get() you can use much more sophisticated filters to pick the right row, and basically it renders this functions obsolete 
	I left it in this library, because this is a basic function that I assume many people eill want to use, who don't need the full functionality of LVG_Get.
*/
;===================================================================================
LVG_GetNext_Un(Gui_nr=1,mode="Unchecked",pr=0) {
	if mode=Unchecked
		mode=1
	else if mode=Deselected
		mode=2
	count:=0,s_mode:="Checked"
	If mode=2
		s_mode=
	Gui, %Gui_nr%:Default
	Loop, % LV_GetCount()
	{
		If (LV_GetNext(pr, s_mode) = a_index)
			pr := a_index
		Else
		{
			count := a_index
			break
		}	
	}
	return count
}
/*
;===================================================================================
Function:		
	LVG_Check(GuiNumber,"Mode")	
		
Description:
	Gui action function:
	Checks/unchecks all the rows that meet the conditions of "Mode".	
		
Parameters:		
	GuiNumber:				- the number of the gui, that has the target listview as its default listview control
	Mode: 
		Reverse				- will check all unchecked rows and uncheck all checked rows
		CheckAll			- will check all unchecked rows
		UncheckAll			- will uncheck all checked rows
		CheckSelected		- will check all selected rows
		UncheckSelected		- will uncheck all selected rows
		CheckDeselected		- will check all deselected rows
		UncheckDeselected	- will uncheck all deselected rows
					
Examples:
	This will reverse-check the listview's checkboxes in GUI2:
	LVG_Check(2,"Reverse")
	This will check all the selected rows:
	LVG_Check(2,"CheckSelected")
*/
;===================================================================================
LVG_Check(Gui_nr=1,mode="Reverse") {
	modelist=Reverse,CheckAll,UncheckAll,CheckSelected
	,UncheckSelected,CheckDeselected,UncheckDeselected
	StringSplit, modelist, modelist, `,
	Loop, %modelist0%
		if (mode=modelist%a_index%)
			mode = %a_index%
	modelist:="",count:=0,count2:=0,pr:= 0,s_mode:=
	Gui, %Gui_nr%:Default
	If (mode=1||mode=2||mode=3)
		s_mode=Checked
	Loop, % LV_GetCount()
	{
		If (LV_GetNext(pr, s_mode) = a_index)
			pr:=a_index,r%a_index%:=1,count2++
		Else
			r%a_index%:= 0,count++
	}
	Loop, % LV_GetCount()
	{
		If ((r%a_index% && (mode=1 || mode=3 || mode=5)) || (!r%a_index% && mode=7))
			LV_Modify(a_index, "-Check")
		Else if ((!r%a_index% && (mode=1 || mode=2 || mode=6)) || (r%a_index% && mode=4))
			LV_Modify(a_index, "+Check")
	}		
	return count . "," . count2
}
/*
;===================================================================================
Function:		
	LVG_Select(GuiNumber,"Mode")
		
Description:
	Gui action function:
 	Same as LVG_Check() with the exception that this works with Selections.
    Reverts selection/selects all/deselects all rows that meet the conditions of "Mode".
		
Parameters:		
	GuiNumber:				- the number of the gui, that has the target listview as its default listview control
	Mode: 
		Reverse				- will select all deselected rows and deselect all selected rows (revert selection)
		SelectAll			- will select all deselected rows
		DeselectAll			- will deselect all selected rows
		SelectChecked		- will select all checked rows
		DeselectChecked		- will deselect all checked rows
		SelectUnchecked		- will select all unchecked rows
		DeselectUnchecked	- will deselect all unchecked rows				
		
Examples:
	This will revert selection:
	LVG_Select(1,"Reverse")
	
	This will select all the Unchecked rows:
	LVG_Select(1,"SelectUnchecked")	
*/
;===================================================================================
LVG_Select(Gui_nr=1,mode="Reverse") {
	modelist=Reverse,SelectAll,DeselectAll,SelectChecked
	,DeselectChecked,SelectUnchecked,DeselectUnchecked
	StringSplit, modelist, modelist, `,
	Loop, %modelist0%
		if (mode=modelist%a_index%)
			mode = %a_index%
	modelist:="",count:=0,count2:=0,pr:= 0,s_mode:="Checked"
	Gui, %Gui_nr%:Default
	If (mode=1||mode=2||mode=3)
		s_mode=
	Loop, % LV_GetCount()
	{
		If (LV_GetNext(pr, s_mode) = a_index)
			pr:=a_index,r%a_index%:=1,count2++
		Else
			r%a_index%:= 0,count++
	}
	Loop, % LV_GetCount()
	{
		If ((r%a_index% && (mode=1 || mode=3 || mode=5)) || (!r%a_index% && mode=7))
			LV_Modify(a_index, "-Select")
		Else if ((!r%a_index% && (mode=1 || mode=2 || mode=6)) || (r%a_index% && mode=4))
			LV_Modify(a_index, "+Select")
	}		
	return count . "," . count2
}
/*
;===================================================================================
Function:		
	LVG_Delete(GuiNumber,"Mode")
			
Description:
	Gui action function:
 	Same as LVG_Check() with the exception that this works with Selections.
    Reverts selection/selects all/deselects all rows that meet the conditions of "Mode".
		
Parameters:		
	GuiNumber:				- the number of the gui, that has the target listview as its default listview control
	Mode: 
		Selected			- will delete all the selected rows
		Deselected			- will delete all deselected rows
		Checked				- etc.
		Unchecked
		SelectedChecked		- will delete all selected AND checked rows (not to be mixed with selected OR checked!) 
		DeselectedUnchecked	- etc.
		SelectedUnchecked	
		DeselectedChecked
				
Examples:
	This will delete all Selected rows:
	LVG_Delete(1,"Selected")
	
	This will delete all the Selected AND Checked rows:
	LVG_Select(1,"SelectedChecked")
	
Remarks
 	Note: With the help of LVG_Get()'s or LV_Search()' Next option and LV_Delete() you can use a more sophisticated filter to delete rows!
*/
;===================================================================================
LVG_Delete(Gui_nr=1,mode="Selected") {
	modelist=Selected,Deselected,Checked,Unchecked,SelectedChecked
	,DeselectedUnchecked,SelectedUnchecked,DeselectedChecked
	StringSplit, modelist, modelist, `,
	Loop, %modelist0%
		if (mode=modelist%a_index%)
			mode = %a_index%
	modelist:="",c:=0,count:=0,s_mode:="Checked",s_mode2:=""
	If (mode=1 || mode=2 || mode=5 || mode=6 || mode=7 || mode=8)
	{
		s_mode:=""
		s_mode2:="Checked"
	}	
	Gui, %Gui_nr%:Default
	Loop, % LV_GetCount()
	{
		If (pr = LV_GetCount())
			Break
		pr=0
		Loop, % LV_GetCount()
		{
			If (((LV_GetNext(pr, s_mode) = a_index) && (mode=2 || mode=4)) || ((LV_GetNext(pr, s_mode) <> a_index) && (mode=1 || mode=3)) || ((LV_GetNext(pr, s_mode) = a_index) && (LV_GetNext(pr, s_mode2) = a_index) && mode=6) || ((LV_GetNext(pr, s_mode) <> a_index) && (mode=5)) || ((LV_GetNext(pr, s_mode) = a_index) && (LV_GetNext(pr, s_mode2) <> a_index) && mode=8) || ((LV_GetNext(pr, s_mode) <> a_index) && (LV_GetNext(pr, s_mode2) = a_index) && mode=7))
			{
				If (mode=5 || mode=6 || mode=7 || mode=8)
				{
					Loop, % LV_GetCount()
					{
						If (((LV_GetNext(pr, s_mode2) <> a_index) && (mode=5 || mode=8)) || ((LV_GetNext(pr, s_mode2) = a_index) && (mode=6 || mode=7))) 
						{
							pr := a_index
							Continue
						}	
						Else
							break
					}
				}	
				pr := a_index
				Continue
			}
			Else if (((LV_GetNext(pr, s_mode) = a_index) && (mode=1 || mode=3)) || ((LV_GetNext(pr, s_mode) <> a_index) && (mode=2 || mode=4)) || ((LV_GetNext(pr, s_mode) <> a_index) && (LV_GetNext(pr, s_mode2) <> a_index) && mode=6) || ((LV_GetNext(pr, s_mode) = a_index) && (LV_GetNext(pr, s_mode2) = a_index) && (mode=5)) || ((LV_GetNext(pr, s_mode) <> a_index) && (LV_GetNext(pr, s_mode2) = a_index) && mode=8) || ((LV_GetNext(pr, s_mode) = a_index) && (LV_GetNext(pr, s_mode2) <> a_index) && mode=7))
			{
				count++
				LV_Delete(a_index)
				break
			}
		}
	}
	return count
}