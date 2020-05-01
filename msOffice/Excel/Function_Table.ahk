/*  ; Credits   
	Created by AHK_User
	Date: 2020-02-09
	Lets run functions with parameters of script in excel,  usefull to quickly exicute functions trough data in Excel
*/
#SingleInstance, Force

²::
Function_Table()
return

Function_Table(){
	
	ArrayRC := {}
	ArrayRC := SelToArrayRC(0) ; Copies the selection to an array
	Columns := ArrayRC["Columns"]
	Rows := ArrayRC["Rows"]
	
	oExcel := Excel_Get(Wintitle) ; Connect to Excel, to be able the add values in excel
	oWorkBook := oExcel.ActiveWorkbook
	oWorkSheet := oWorkBook.activesheet
	ActiveCellAddress := oExcel.ActiveCell.address
	oActiveCell := oWorkSheet.Range(ActiveCellAddress)
	
	Loop, %Rows%
	{
		Row := A_Index
		Function_Ahk := ArrayRC[Row,1]
		
		if !IsFunc(Function_Ahk){
			MsgBox, Error,  %Function_Ahk% is not a function.
			return
		}
		
		params:={}
		loop,  % Columns-1
		{
			; Counting the passed parameters for error detection, empty parameters will be skipped
			if (ArrayRC[Row,A_index+1] !=""){
				NumberPar := A_index
				params[A_index]:= ArrayRC[Row,A_index+1]
			}
		}
		
		fn := Func(Function_Ahk)
		if (fn.MinParams > NumberPar or NumberPar > fn.MaxParams){
			;~ ; Checking if the amount of parameters is correct
			oWorkSheet.Range(ActiveCellAddress).Offset(Row-1,Columns+1).Value := "ERROR: Wrong number of parameters"
			Continue
		}
		
		Result := %Function_Ahk%(params*)
		if ErrorLevel{
			; ErrorLevel does not seem to work? for example when using to few parameters
			Result := "Error"
		}
		oWorkSheet.Range(ActiveCellAddress).Offset(Row-1,Columns+1).Value := Result
		
	}
	
	oWorkbook := ""
	return
}

SelToArrayRC(Header = true) { ;Create 2D array from the excel selection
	ArrayRC := {}
	Clipboard_1 := Clipboard()
	RegExReplace(Clipboard_1,"m)\n", "",CountLines)
	If (Countlines = "0"){
		Return false
	}
	WinGet, Active_Process, ProcessName, A
	if (Active_Process = "Explorer.exe"){
		sort, Clipboard_1 ; sorts clipboard in numeric order
	}
	
	Clipboard_1 = %Clipboard_1%
	if (Active_Process = "Excel.exe"){
		Send {Esc} ; hides that clipboard is used
	}
	
	;StringReplace, Clipboard_1, Clipboard_1, `r`n, `r`n, UseErrorLevel
	StrReplace(Clipboard_1, "`r`n", "`r`n", Number_rn)
	if (Active_Process = "Explorer.exe"){
		ArrayRC.Rows := Number_rn+1 ; explorer will count 1 file to little
	} 
	Else{
		ArrayRC.Rows := Number_rn
	}
	StrReplace(Clipboard_1, A_Tab, A_Tab, Number_tab)
	;StringReplace, Clipboard_1, Clipboard_1, %A_Tab%, %A_Tab%, UseErrorLevel
	ArrayRC.Columns := (Number_tab/ArrayRC.Rows) + 1
	
	if (Header = false){
		Loop, Parse, Clipboard_1, `n, `r
		{  	
			row := A_Index
			Loop, Parse, A_LoopField, %A_Tab%
			{	
				ArrayRC[row,A_Index] := A_LoopField
			}
		}
	}
	else{
		Loop, Parse, Clipboard_1, `n, `r
		{  	
			row := A_Index - 1
			if (Row = 0){
				Loop, Parse, A_LoopField, %A_Tab%
				{	Header_%A_Index% := A_LoopField
					ArrayRC[row,A_Index] := A_LoopField
				}
				continue
			}
			Loop, Parse, A_LoopField, %A_Tab%
			{	ArrayRC[row,Header_%A_Index%] := A_LoopField
				ArrayRC[row,A_Index] := A_LoopField
			}
		}
	}
	return ArrayRC
}

Clipboard(SecondsToWait = "3") { ; Copies selection to result without deleting the current content
	if WinActive("ahk_exe Excel.exe"){
		WinGetTitle, WinTitle, A
		XL := Excel_Get(WinTitle)
		Clipboard_01 := XLS_Clipboard(XL)
		return Clipboard_01
	}
	ClipboardSaved := ClipboardAll ; Save the entire clipboard to a variable of your choice.
	Clipboard =  ; Empty the clipboard.
	SendInput, ^c
	ClipWait, %SecondsToWait%	; Wait for the clipboard to contain text.
	Clipboard_1 := Clipboard
	Clipboard := ClipboardSaved ; Restore the original clipboard.
	ClipboardSaved = ; Free the memory in case the clipboard was very large.
	return Clipboard_1
}

XLS_Clipboard(Xl := ""){ ; Clipboard for Excel
	if (Xl =""){
		Try{
			Try Xl := ComObjActive("Excel.Application") ;handle
			catch{
				Try Xl := ComObjActive("Excel.Application") ;handle
			}
		}
		catch{
			MsgBox, Error, Could not find Excel.`nThread will exit.
			Exit
		}
	}
	
	Try For Cell in xl.range(XL.Selection.Address) 
	{	if (A_Index = 1){
		Column_1 := cell.column(),Clip := cell.text
		continue
	}
	if (Column_1 = cell.column()){
		Clip .= "`r`n" cell.text
		continue
	}
	Clip .= "`t" cell.text
}
catch {
	return false
}
Return Clip "`r`n"
}

Excel_Get(WinTitle="ahk_class XLMAIN") {	; by Sean and Jethrow, minor modification by Learning one
	ControlGet, hwnd, hwnd, , Excel71, %WinTitle%
	if !hwnd
		return
	Window := Acc_ObjectFromWindow(hwnd, -16)
	Loop
		try
			oExcel := Window.Application
	catch
		ControlSend, Excel71, {esc}, %WinTitle%
	Until !!oExcel
	return oExcel
}

MsgBox(Text="", Title:= ""){
	MsgBox, , %Title%, %Text%
}

Add(Var1, Var2){
	return Var1+Var2
}