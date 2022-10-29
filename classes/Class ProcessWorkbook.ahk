#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Workbook := {}
Global Xl, Workbook, CheckListArray

		CheckListArray :=   {"TIMEOUTCHECK":"|<>*48$91.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzsDzsDw7kDUDz00TllztnznzTzLzjjjnyztwzszjz9zrrrzzDxzTwDrzizvvvzzbwzbybvzrTxxxzznyTnzNxznbyyyzzvzDxzgyzvvzzTzztzbyzrDTxwzzjzz1znzTvrjwyTzrzzwTtzjxtryzjzvzzzbwzryyPz03zxzzznyTvzTBzDxzyzzzxzDtzjmzjyzzTzzyzbwzrwTbzDzjzzyTvyTvyDnzrzrzvzDwyTxzbvzvzvzwSDzCTs7nkDUT07zUTzkTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
						    ,"MAINMENUCHECK":"|<>*45$41.zzzzzzzzzzzzzztzw7znznznbzbzDzDbzbyTyzjzDsztzDzDnznyTyTbzbyzwSDzDxzwwzyTvzttzwzrznnztzjzbbznzTzDDzbwzySTzDtzwwTzTnztwzyTDzXtzyQzzDlzy3zyTnzzzztzbzzzznzbzzzzDzjzzzyTzzzzzzz"							
					        ,"SEPARATEDCHECK":"|<>*106$78.zzzzzzzbzzzzzzzzzzzzbzzzzzzDzzzzzDzzzyTzDkD1zzDUy1yTyDwzrzyDwTnzDyTyzbzyTwTnzDwTyTDzyTwDnzbwzzDDzwzxDnzbwzziTzwzxbnzXszzYzztzxbnznszzkzztzxnnznszztzznzxtnzntzztzznzxtnzntzztzzbzxwnznszztzzbzxwnznszztzzDzxyHznszztzzDzxz3znwzztzzDzxz3zXwzztzyTzxzXzbwTy0DyTzkDXzbyTzzzwzzzzzzDyDzzzwzzzzzzDzDzzzzzzzzzyTzjzzzzzzzzzyTzzzzzzzzzzzzzU"
							,"CASUALCHECK":"|<>*106$101.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs7w2TzzzzzzzzzzzzzDXkzzzzzzzzzzzzzySTlzzzzzzzzzzzzzwxznzzzzzzzzzzzzztnzby1zy0DVsDy1zznbzzlszswTnyTlszzbTzzztzbwzbwzztzzCzzzzvzDtzDtzzvzyRzzzzrzDzyTnzzrzwvzzzzjz0Twzbzzjztrzzy0TzyTtzDy0TznbzzlwzzyTnyTlwzzbDzzDxzzyTbwzDxzzDDySTvzTwzDtyTvzyTTtwzbyTnzTXwzbzwzD7swDwTDyS7swDztz0zw33v0zy13w33k0Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
							,"TEMPCHECK":"|<>*47$101.zzzzzzwzzzzzzzzzzzzzzzztzzzzzzzzzzbzzzzzbzzzzDzzzzzDkT1zzDUy1yTzzzzwztzjzwztzjyTzzzztzvyTztzlzTwzzzzzXzntzzrzVyzwzzzzzDznrzzDzHxztzzzzyTzrDzyTynvzlzzzzszzYzztzxbrznzzzznzzXzznzvbjzbzzzzbzzbzzDzrjTzDzzzzDzzTzyTzjCzyTzzzyTzyzztzzTBzwzzzzwzzxzznzyyPztzzzztzzvzzDzxyLznzzzzlzzrzyTzvyDzbzzXznzzjzxzzrwTyDzy3zbzzTznzzjwzwzzw7z7zU3zjzw3tztzzwTzDzzzyTzzzzzbzzzzyTzzzwzzzzzzDzzzzyTzzzzzzzzzwzzzzzyzzzzzzzzzztzzzzzzzzzzzzzzzzzzzzzz"
							,"COFCHECK":"|<>*107$101.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzUHzUTs01zzzzzzzzwS7wSTwznzzzzzzzznyDnyTtzbzzzzzzzzjyT7yTnzDzzzzzzzyTwyTwzbyTzzzzzzzwzzwzwzDzzzzzzzzzvzznztyQzzzzzzzzzbzzbznwtzzzU0DzzzDzzDzbs3zzz00TzzyTzyTzDnbzzzzzzzzyzzwzyTbDzzzzzzzzwzzxzwzDzzzzzzzzztzztznyTzzzzzzzzztzntzbwzzzzzzzzzzvzDnyTtzzzzzzzzzztszltznzzzzzzzzzzs7zs7y0Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
							,"NTGPASSCHECK":"|<>*107$101.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzUy1s03zUHzzzzzzzzszbnnrwy7zzzzzzzzlzDbbjnzDzzzzzzzzVyTDDTjyTzzzzzzzzHwySSyTzzzzzzzzzyntwwxwzzzzzzzzzzxbnztzvzzzzzzzzzzvbbznzbzzzzU0DzzzrbDzbzDzzzz00TzzzjCTzDyTUDzzzzzzzzTAzyTyzwzzzzzzzzyyNzwzwztzzzzzzzzxyHztztznzzzzzzzzvy7znznzbzzzzzzzzrwDzbznzDzzzzzzzzjwTzDzlyTzzzzzzzw3szU3zs3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
							,"SPR":"|<>*108$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzkC1w1zk0TUy1bzrzdztyTszbjzDyHznyTlzDTyTwrzbyzVySyQzvbzDwzHwwstzbDyTvynttlnzDTwzbxbnndbyyTtwTvbbaHDtwzk3zrbDAqznxzbbzjCTPhzU1zDbzTAyr/yTvyTbyyNxC7xznwzbxyHsQDnzbtzjvy7lwTbzjnzDrwDXszTzDbzTjwT7ls7kA1yA3szzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"}



ActiveWorkbook := New ProcessWorkbook()
ActiveWorkbook.GetPayDetails()

Return

Class ProcessWorkbook {

	__New() {
	Xl := ComObjActive("Excel.Application")
	ComObjError(false)
	Xl.Sheets("OP Investigation Report").activate	
	Xl.ActiveSheet.Unprotect
	}

	GetPayDetails() {
		WinActivate, Mochasoft - mainframe.nt.gov.au
		sleep 150
		winactivate, Mochasoft
		sleep 150
		sendinput, {F4}
		if (MainfraimToText.GetWindowState() = "TIMEOUTCHECK")
		{
			sendinput, {enter} 
			sleep 150
			sendinput, {enter}
			sleep 150
			sendinput, {enter}
			sleep 150
		}
		if (MainfraimToText.GetWindowState() = "MAINMENUCHECK")
		{
			sendinput, Pay{enter}{F8}
			sleep 150
			run, Calc
			InputBox, Percentage, RCY.COM Percentage, Please Enter Ten Percent of the Gross Salary., , 200, 150
			if ErrorLevel
				MsgBox, CANCEL was pressed.
			WinClose, Calc
			Workbook.Percentage := Percentage
		}
		else
		{
			MsgBox % "Open PIPS to Main Menu, then hit Okay."
						sendinput, Pay{enter}{F8}
			sleep 150
			run, Calc
			InputBox, Percentage, RCY.COM Percentage, Please Enter Ten Percent of the Gross Salary., , 200, 150
			if ErrorLevel
				MsgBox, CANCEL was pressed.
			WinClose, Calc
			Workbook.Percentage := Percentage
		}
	}


	Complete() 
	{

	SetCellValue("AGS",Active_AGS,0,1)
	SetCellValue("TAX",Workbook.TaxAmount,1,0)
	SetCellValue("Nett Diff",Workbook.NettAmount,1,0)
	SetCellValue("Net Pay Diff",Workbook.NettAmount,1,0) 
	SetCellValue("Gross Diff",Workbook.GrossAmount,1,0) 
	SetCellValue("Gross Diff", Workbook.SalarySacAmountGross,1,3) 
	SetCellValue("Salary Sacrifice Contribution",Workbook.SalarySacAmount,1,0)
	SetCellValue("Fund Code",Workbook.SuperAmount,1,1)
	SetCellValue("Deductions", Workbook.DeductionsAmount, 1, 0)
	
	if (Workbook.GrossAmount != "")
		SetCellValue("Gross",Workbook.GrossAmount,1,0)
	
	SetCellValue("Fund Name", array_[1], 0, 1)
	SetCellValue("Fund Address", array_[2], 0, 1)
	SetCellValue("Fund Name", array_[3], 2, 1)
	SetCellValue("Fund Code", Workbook.SuperFund, 0, 1)
	SetCellValue("Fund Code", "Previous Financial Year Super:", 0, 5)
	SetCellValue("Fund Code", Workbook.CantRecovreSuper, 1, 5)
	
	SetCellValue("Member Number", Workbook.SuperRef, 0, 1)
	SetCellValue("Member DOB", Workbook.Date_of_birth, 0, 1)
	SetCellValue("FBT Date", FBT_Date(), 0, 1)
	SetCellValue("Cost Code",Workbook.CostCode,0,1)
	SetCellValue("Existing overpayment on EPOD:", Workbook.ExistingOverpaymentAmount,0,1)
	
	Xl.Sheets("Recovery Authorisation").activate
	SetCellValue("Cost Code",Workbook.CostCode,0,1)
	Xl.Sheets("PFES Recovery Authorisation").activate
	SetCellValue("Cost Code",Workbook.CostCode,0,1)
	Xl.Sheets("OP Investigation Report").activate
	
	if (GetCellValue("Is Employee on Leave Without Pay?", 0, 1) = "Yes")
	{
		Xl.Sheets("OP Letter").Select(True)
		Xl.Sheets("PAWA OP Letter").Select(False)
		Xl.Sheets("Recovery Authorisation").Select(False)
		Xl.Sheets("PFES OP Letter").Select(False)
		Xl.Sheets("PAWA Recovery Authorisation").Select(False)
		Xl.Sheets("PFES Recovery Authorisation").Select(False)
		Xl.ActiveWindow.SelectedSheets.Visible := False 
		
		Xl.Sheets("OP Investigation Report").Visible := True
		Xl.Sheets("OP Investigation Report").activate
		Xl.Sheets("OP Investigation Report").Visible := True
	}
	if (GetCellValue("Is Employee on Leave Without Pay?", 0, 1) = "No")
	{
		Xl.Sheets("LWOP OP Letter").Select(True)
		Xl.Sheets("PFES LWOP OP Letter").Select(False)
		
		Xl.ActiveWindow.SelectedSheets.Visible := False 
		Xl.Sheets("OP Investigation Report").Visible := True
		Xl.Sheets("OP Investigation Report").activate
		Xl.Sheets("OP Investigation Report").Visible := True
	}
	
	if (GetCellValue("Overpayment Investigation Report", -1, 0) = "Previous Financial Year")
	{
		SetCellValue("Fund Name", array_[1] . " - N/A - Previous Financial Year", 0, 1)	
		Xl.Sheets("Checklist").activate
		
		SetCellValue("Overpayment Document placed in Future Action", "Pay Cycle: " Workbook.Pay_Cycle, 0, 1)
		Merge_and_Center("C19", "D19", "N/A - Previous Financial Year")
		Merge_and_Center("C33", "D33", "N/A - Previous Financial Year")
		Xl.Sheets("OP Investigation Report").activate
	}
	
	if (GetCellValue("Overpayment Investigation Report", -1, 0) = "Current Financial Year")
	{
		Xl.Sheets("Checklist").activate
		SetCellValue("Overpayment Document placed in Future Action", "Pay Cycle: " Workbook.Pay_Cycle, 0, 1)
		
		Merge_and_Center("C26", "D26", "N/A - Current Financial Year")
		Merge_and_Center("C18", "D18", "N/A - Current Financial Year")
		Xl.Sheets("OP Investigation Report").activate
	}
	
	if ((SubStr(GetCellValue("Pay Centre", 0, 1), 1,3), 0, 1) != "673")
	{
		Xl.Sheets("PAWA OP Letter").Select(True)
		Xl.Sheets("PAWA Recovery Authorisation").Select(False)
		Xl.Sheets("PFES OP Letter").Select(False)
		Xl.Sheets("PFES LWOP OP Letter").Select(False)
		Xl.Sheets("PAWA Recovery Authorisation").Select(False)
		Xl.Sheets("PFES Recovery Authorisation").Select(False)
		Xl.ActiveWindow.SelectedSheets.Visible := False 
		Xl.Sheets("OP Investigation Report").Visible := True
		Xl.Sheets("OP Investigation Report").activate
		Xl.Sheets("OP Investigation Report").Visible := True
	}	
	
	if ((SubStr(GetCellValue("Pay Centre", 0, 1), 1,3), 0, 1) = "673")
	{
		Xl.Sheets("PAWA OP Letter").Select(True)
		Xl.Sheets("PAWA Recovery Authorisation").Select(False)
		Xl.Sheets("OP Letter").Select(False)
		Xl.Sheets("Recovery Authorisation").Select(False)
		Xl.Sheets("PAWA Recovery Authorisation").Select(False)
		Xl.ActiveWindow.SelectedSheets.Visible := False 
		Xl.Sheets("OP Investigation Report").Visible := True
		Xl.Sheets("OP Investigation Report").activate
		Xl.Sheets("OP Investigation Report").Visible := True
	}	
	
	
	Selected_Cells := "H51" . ":" . "J51"
	Xl.ActiveSheet.Range(Selected_Cells).select
	Xl.Selection.Font.Bold := (True)
	Xl.Selection.HorizontalAlignment:=-4108
	Xl.Selection.VerticalAlignment:=-4107
	Xl.Selection.WrapText := (False)
	Xl.Selection.Orientation := (0)
	Xl.Selection.AddIndent := (False)
	Xl.Selection.ShrinkToFit := (False)
	Xl.Selection.ReadingOrder.XlContext
	Xl.Selection.MergeCells := (False)
	Xl.Selection.Font.Bold := (True)
	Xl.Selection.Merge
	
	
	Selected_Cells := "H52" . ":" . "J52"
	Xl.ActiveSheet.Range(Selected_Cells).select
	Xl.Selection.Font.Bold := (True)
	Xl.Selection.HorizontalAlignment:=-4108
	Xl.Selection.VerticalAlignment:=-4107
	Xl.Selection.WrapText := (False)
	Xl.Selection.Orientation := (0)
	Xl.Selection.AddIndent := (False)
	Xl.Selection.ShrinkToFit := (False)
	Xl.Selection.ReadingOrder.XlContext
	Xl.Selection.MergeCells := (False)
	Xl.Selection.Font.Bold := (True)
	Xl.Selection.Merge
	Xl.Selection.NumberFormat:= ("$#,##0.00")
	
	;Overpayment Investigation Report
	Workbook_AGS := SubStr(GetCellValue("AGS", 0, 1), 1 , 8)
	Workbook.PayCentre := GetCellValue("Pay Centre", 0, 1)
	Workbook.FBT := GetCellValue("FBT Date", 0, 1)
	Workbook.Date_Detected := GetCellValue("Date Overpayment Detected", 0, 1)
	Workbook.Date_Commenced := GetCellValue("Date O/P commenced", 1, 0)
	Workbook.Date_Ceased := GetCellValue("Date O/P ceased", 1, 0)
	Workbook.TotalAmount := GetCellValue("Total overpayment to be recovered", 1, 0)
	Workbook.TotalAmount := RegExReplace(Workbook.TotalAmount, "[^0-9.]")
	Workbook.Reason := GetCellValue("Reason for Overpayment (This description will be shown on the letter to the employee)", 1, 0) . ". (" . Workbook.Date_Commenced . " to " . Workbook.Date_Ceased . ")  $" . Workbook.TotalAmount	
	; ePOD Reporting
	Workbook.Error_Source := GetCellValue("Error Source", 1, 0)
	Workbook.Error_Type := GetCellValue("Error Type", 1, 0)
	Workbook.Error_Cause := GetCellValue("Error Cause", 1, 0)
	Workbook.Location := GetCellValue("Location", 1, 0)
	
	;Cumulative Totals and Recover Overpaid Tax
	Workbook.RPMENT := Float(GetCellValue("RPM.ENT", 0, 2)) 
	Workbook.TAXPYM := Float(GetCellValue("TAX.PYM", 0, 2)) 
	Workbook.RDRENT := Float(GetCellValue("RDR.ENT", 0, 2)) 
	Workbook.RCYCOM := Float(GetCellValue("RCY.COM", -1, 3))
	Workbook.Percentage := Float(GetCellValue("10% of gross salary", 0, 1),2) 
	Workbook.Paydate := Pay_hash(Workbook.Pay_Cycle, "Pay_Cycle")
	
	;Finalise and Fix Up stuff in the workbook
	Xl.Sheets("Checklist").activate
	SetCellValue("Overpayment Document placed in Future Action", "Pay Cycle: " Workbook.Pay_Cycle, 0, 1)
	FormatTime, Time,, dd/MM/yyyy
	SetCellValue("Overpayment workbook (Blue Sections)", "Bryn Abbott | " time, 0, 1)
	
	Array := StrSplit(Workbook.Date_Detected, "/")
	DetectedDate := Array.3 . Array.2 . Array.1
	FormatTime, TimeString,, shortDate
	ProcessedDateString := TimeString
	Array := StrSplit(ProcessedDateString, "/")
	ProcessedDate := Array.3 . Array.2 . Array.1
	datefrom := DetectedDate
	distance := dateto := ProcessedDate
	distance -= datefrom, days
	Workbook.Distance := distance
	
	SetCellValue("Overpayment workbook (Blue Sections)", "Days Since Discovery:", 0, 4)
	SetCellValue("Overpayment workbook (Blue Sections)", Workbook.Distance, 1, 4)
	
	Xl.Sheets("OP Investigation Report").activate
	Xl.Range("C19:F19").CheckSpelling
	}
}



Class MainfraimToText
{
	__New(ServiceNo)
	{
		Stage := 1
		WinGet IDVar,ID, ahk_exe tn3270.exe  
		This.ServiceNo := ServiceNo
		This.ID:=IDVar  
		WinActivate % "ahk_id "This.ID  
		sendinput,{F4}
	}

	Activate()  
	{ 
		WinActivate % "ahk_id "This.ID  
		Return This.ID
	}   

	GetWindowState()
	{
		This.Activate() 
		if FindText(1502-150000, 121-150000, 1502+150000, 121+150000, 0, 0, CheckListArray["MAINMENUCHECK"])
			Return This.WindowState:="MAINMENUCHECK"
		else if FindText(1538-150000, 154-150000, 1538+150000, 154+150000, 0, 0, CheckListArray["TIMEOUTCHECK"]) 
			Return This.WindowState:="TIMEOUTCHECK"
		else if FindText(2492-150000, 715-150000, 2492+150000, 715+150000, 0, 0, CheckListArray["SEPARATEDCHECK"])
			Return This.WindowState:="SEPARATEDCHECK"
		else if FindText(1510-150000, 184-150000, 1510+150000, 184+150000, 0, 0, CheckListArray["CASUALCHECK"])
			Return This.WindowState:="CASUALCHECK"
		else if FindText(1750-150000, 550-150000, 1750+150000, 550+150000, 0, 0, CheckListArray["TEMPCHECK"])
		 	Return This.WindowState:="TEMPCHECK"
		else if FindText(2493-150000, 153-150000, 2493+150000, 153+150000, 0, 0, CheckListArray["COFCHECK"])
			Return This.WindowState:="COFCHECK"
		else if FindText(1494-150000, 87-150000, 1494+150000, 87+150000, 0, 0, CheckListArray["SPR"])
			Return This.WindowState:="SPR"
		else if FindText(2493-150000, 153-150000, 2493+150000, 153+150000, 0, 0, CheckListArray["NTGPASSCHECK"])
			Return This.WindowState:="NTGPASSCHECK"
		else
			Return This.WindowState:="ERROR"
	}
		
	Navigate()
	{
		if (This.GetWindowState() = "TIMEOUTCHECK") 
			{
				This.Sleep(100)
				sendinput,{enter}
				This.Sleep(100)
				sendinput,{enter}
				This.Sleep(100)
				sendinput,{enter}
				This.Sleep(200)
			}

		if (This.GetWindowState() = "MAINMENUCHECK") 
			{
				This.Sleep(100)
				sendinput, 1.2.1
				This.Sleep(100)
				sendinput,{enter}
				This.Sleep(100)
				sendinput % this.ServiceNo 
				This.Sleep(100)
				sendinput, {enter}
				This.Sleep(200)
			}

		if (This.GetWindowState() = "SEPARATEDCHECK") 
			{
				This.Sleep(100)
				sendinput, {enter}
				This.Sleep(200)
			}
	}

	GatherPersonDetails()
	{
		if (This.GetWindowState() = "CasualCheck") 
		{	
			Array := This.MainframeToTextArray()
			Sleep 2000
			Workbook.Surname := substr(Array[6],22,23)
			Workbook.Given_names := substr(Array[7],30,45)
			Workbook.Date_of_birth := substr(Array[12],30,11)
			Workbook.Pay_centre := substr(Array[18],30,3)
			Workbook.Courtesy_Title := substr(Array[9],30,4)
		}
		else if (This.GetWindowState() = "TempCheck") 
		{
			Array := This.MainframeToTextArray()
			Sleep 2000
			Workbook.Surname := substr(Array[6],22,23)
			Workbook.Given_names := substr(Array[7],22,45)
			Workbook.Date_of_birth := substr(Array[10],22,11)
			Workbook.Pay_centre := substr(Array[12],22,4)
			Workbook.Courtesy_Title := substr(Array[9],22,11)
		}	
		
		while (Workbook.Surname = "") or (Workbook.Date_of_birth = "")
			This.GatherPersonDetails()

		Stage := 2
		sendinput, {F4}
		sendinput, {TAB}1.2.3
		sendinput, {Enter}{F8}
	}

	GatherAddresses()
	{
		This.Navigate()
		Array := This.MainframeToTextArray()

		if (substr(Array[3],37,9) = "Addresses" and substr(Array[16],66,5) != "Other")
		{
			Workbook.Street_1 := substr(Array[12],18,21)
			Workbook.Street_2 := substr(Array[13],18,21) 
			Workbook.Street_3 := substr(Array[14],18,21) 
			Workbook.City := substr(Array[15],18,21) 
			Workbook.State := substr(Array[15],46,3) 
			Workbook.PostCode := substr(Array[16],18,4) 
			Workbook.Phone := substr(Array[10],18,20) 
			Workbook.Email := substr(Array[11],18,50)
			Workbook.WorkEmail := substr(Array[22],18,50) 
		}

		if (substr(Array[3],37,9) = "Addresses" and substr(Array[16],66,5) = "Other")
		{
			Workbook.Phone := substr(Array[10],18,20) 
			if (Workbook.Phone = "")
				Workbook.Phone := substr(Array[10],61,20) 
			Workbook.Email := substr(Array[11],18,50) 
			Workbook.WorkEmail := substr(Array[22],18,50) 
			sendinput, {Enter}
			This.Sleep(1000)
			Array := This.MainframeToTextArray()
			Workbook.Street_1 := substr(Array[12],28,24) 
			Workbook.Street_2 := substr(Array[13],28,24) 
			Workbook.Street_3 := substr(Array[14],28,24) 
			Workbook.City := substr(Array[15],28,17) 
			Workbook.State := substr(Array[15],56,3) 
			Workbook.PostCode := substr(Array[16],28,4) 
		}

		Stage := 3
		sendinput, {F4}
		sendinput, {TAB}1.2.7
		sendinput, {Enter}{F8}
	}
	
	GatherSuperannuation()
	{
		Array := ""
		This.Navigate()
		Sleep 2000
		Array := This.MainframeToTextArray()
		Sleep 2000
		
		this.Activate()
		if (substr(Array[2],3,7) = "(1.2.7)")
		{
			Loop 6
				{
					Test := (InStr(substr(Array[10+A_Index],3,4), "A") ? A_Index : Return)
						if (Test = "")
							Break
						else
							Row := Test
				}

			sendinput, %Row% {enter}
			this.Sleep(1000)
		}

		Array := This.MainframeToTextArray()

		if (substr(Array[3],29,52) = "    Superannuation          - Choice   (Enquiry)    ")
			{
				this.Sleep(100)
				Workbook.SuperRef := StrReplace(SubStr(Array[11], 55 , 20), "_") 
				Workbook.SuperFund	:= SubStr(Array[11], 23 , 7) 
			}
		else
			{
				Workbook.SuperRef := "Other - N/A"
				Workbook.SuperFund	:= "Other - N/A"
			}
		Stage := "Done"
	}

	GatherCostCode()
	{
		ServiceNo := this.ServiceNo
		winactivate, ePOD
		This.sleep(200)
		WinGet, hWnd, ID, ePOD
		oAcc := Acc_Get("Object", "4.4.4", 0, "ahk_id " hWnd) 
		ControlHwnd := Acc_WindowFromObject(oAcc)
		This.sleep(200)
		ControlFocus,, ahk_id %ControlHwnd%
		This.sleep(200)
		ControlGetFocus, ControlName, ahk_id %ControlHwnd%
		This.sleep(200)
		dllcall("keybd_event", int, 0x25, int, 0x14B, int, 0, int, 0)
		This.sleep(200)
		send, {AppsKey}{Down}{Down}{Enter}
		This.sleep(200)
		Send, %ServiceNo%{ENTER}
		This.sleep(200)
		oAcc := Acc_Get("Object", "4.1.4.1.4.16.4", vChildID, "ahk_id " hWnd)
		Workbook.CostCode := oAcc.accValue(vChildID)
	}

	MainframeToTextArray()
	{
		This.Sleep(100)	
		winactivate, Mochasoft
		This.Sleep(100)
		sendinput, {Alt}ES
		This.Sleep(500)
		sendinput, ^c
		This.Sleep(100)
		This.Sleep(300)
		This.Array := StrSplit(Clipboard, "`n")
		This.Sleep(200)
		Return This.Array
	}

	Sleep(Duration)
	{
		Sleep % Duration
	}

}