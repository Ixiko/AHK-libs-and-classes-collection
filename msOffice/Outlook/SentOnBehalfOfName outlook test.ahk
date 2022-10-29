#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


Xl := ComObjActive("Excel.Application")
ComObjError(false)

For sheet in Xl.Worksheets
	if InStr(Sheet.Name, "OP Investigation Report") 
		Xl.Sheets(Sheet.Name).activate

Pointer := Xl.ActiveSheet.Range("A:H").Find("Fund Code")
MsgBox % s := Xl.Range(Pointer.Offset(0, 1).address).Value


default_Text =
(

I wish to advise that a salary overpayment has occurred with your pay. 

Please refer to the attached letter for further information. Full details of the overpayment are provided in the attached letter and ‘Paid/Due/Difference’ explanation.

To advise your preferred repayment option, please complete and sign the attached Recovery Authorisation for Salary Overpayment and return to payrolldebtrecovery.asp@nt.gov.au within 10 working days from the date of this email.  

If you wish to repay at less than the scheduled 10 percent ($xxxx) please complete Section 5 of the form and return for submission to your Agency for their consideration. 

If you have any queries regarding the calculations supplied please contact Payroll Debt Recovery Services.

We apologise for any inconvenience this may cause.
)
			
			m :=	ComObjActive("Outlook.Application").CreateItem(0)
			m.Subject := "Notification of Salary Overpayment - " . Client._AGS . " | " . Client._NameLast " , " Client._NameFirst
			m.To :=	Client._Email,m.Display
			m.cc := "Test"
			m.SentOnBehalfOfName := "Payrolldebtrecovery.asp@nt.gov.au"
			m.SendUsingAccount := m.Application.Session.Accounts.Item(1)
			myInspector :=	m.GetInspector, myInspector.Activate
			wdDoc :=	myInspector.WordEditor
			wdRange :=	wdDoc.Range(0, wdDoc.Characters.Count)
			wdRange.InsertBefore("Dear " . Workbook_Class.Change_String(Client._Title,"Clean") . " " . Workbook_Class.Change_String(Client._NameLast,"Title") . "`n`r" . default_Text)
			m.Attachments.Add("C:\Users\babb\Documents\Blank.txt")
			