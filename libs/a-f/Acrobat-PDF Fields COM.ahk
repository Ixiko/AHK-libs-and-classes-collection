F12::
	AFormAut := ComObjCreate("AFormAut.App")
	for Field in AFormAut.Fields
	{
		fNum := A_Index - 1
		fName := Field.Name
		fValue := Field.Value
		MsgBox % "Field Number = " fNum "`nField Name = " fName "`nField Value = " fValue
	}
	AFormAut.Fields("Your Name").Value := "Fanatic Guru"
return

F11::
	App := ComObjCreate("AcroExch.App")
	AVDoc := App.GetActiveDoc()
	PDDoc := AVDoc.GetPDDoc()
	JSO	:= PDDoc.GetJSObject
	Loop % JSO.NumFields
	{
		fNum := A_Index - 1
		fName := JSO.GetNthFieldName(fNum)
		fValue := JSO.GetField(fName).Value
		MsgBox % "Field Number = " fNum "`nField Name = " fName "`nField Value = " fValue
	}
	JSO.GetField("Your Name").Value := "Fanatic Guru"
return