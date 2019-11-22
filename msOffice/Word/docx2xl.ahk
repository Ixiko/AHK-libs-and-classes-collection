#NoTrayIcon
#SingleInstance, force 
IniRead()
oWord := ComObjActive("Word.Application") 

Progress, CT%header_color% CW%background% B1 Y0 ZH0 CTFF0000, Navigate to relevant folder and press F1 to remove copy docx' to active Excel sheet (ESC to cancel)

; Progress, show CT%header_color% CW%background% fm20 WS700 c00 x0 w300 h125 zy60 zh0 B0, , %text%,, %header% 
Esc::ExitApp
F1::
folder := Explorer_GetPath()
Loop, %folder%\*.*
	fileCount := A_Index
Loop, %folder%\*.*
{
	if A_Index > %fileCount% 
		ExitApp
	oWord.Documents.Open(A_LoopFileFullPath)
	sentences2XL()
	oWord.ActiveDocument.Close 
}
ExitApp



sentences2XL(){
	oWord := ComObjActive("Word.Application")
	xl := ComObjActive("Excel.Application") 
	refColumns := Object(1,"A",2,"B",3,"C",4,"D",5,"E",6,"F",7,"G",8,"H",9,"I",10,"J",11,"K",12,"L",13,"M",14,"N",15,"O",16,"P",17,"Q",18,"R",19,"S",20,"T",21,"U",22,"V",23,"W",24,"X",25,"Y",26,"Z",27,"AA",28,"AB",29,"AC",30,"AD",31,"AE",32,"AF",33,"AG",34,"AH",35,"AI",36,"AJ",37,"AK",38,"AL",39,"AM",40,"AN",41,"AO",42,"AP",43,"AQ",44,"AR",45,"AS",46,"AT",47,"AU",48,"AV",49,"AW",50,"AX",51,"AY",52,"AZ",53,"BA",54,"BB",55,"BC",56,"BD",57,"BE",58,"BF",59,"BG",60,"BH",61,"BI",62,"BJ",63,"BK",64,"BL",65,"BM",66,"BN",67,"BO",68,"BP",69,"BQ",70,"BR",71,"BS",72,"BT",73,"BU",74,"BV",75,"BW",76,"BX",77,"BY",78,"BZ",79,"CA",80,"CB",81,"CC",82,"CD",83,"CE",84,"CF",85,"CG",86,"CH",87,"CI",88,"CJ",89,"CK",90,"CL",91,"CM",92,"CN",93,"CO",94,"CP",95,"CQ",96,"CR",97,"CS",98,"CT",99,"CU",100,"CV",101,"CW",102,"CX",103,"CY",104,"CZ")

	row := xl.ActiveSheet.UsedRange.Rows.Count + 1

	xl.ActiveSheet.Range("A" . row).Value := oWord.ActiveDocument.Name
	loop % oWord.ActiveDocument.Sentences.Count
	{
		oWord.ActiveDocument.Sentences(A_Index).Copy 
		splashNotify(Clipboard, , "bottom")
		col := A_Index + 1 
		xl.Range(refColumns[col] . row).Value := Clipboard 
	}	
}
