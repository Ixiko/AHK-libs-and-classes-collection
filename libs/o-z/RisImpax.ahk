
#include <.NetGetControl>
;~ #include <EditFunctions>
#include <Edit>
;~ DetectHiddenWindows,on


;~ SetTitleMatchMode,2
;~ clipboard:=ListControls(risopened()[2])
;~ ExitApp
;~ msgbox % risopened()[1]
;~ clipboard:=listcontrols(impaxopened()[2,1])

RisImpaxMsgProtocol(){
	global
	local k,v
	registerRisChangeMsg:=[0x1000, 0x1003]
	,registerRisChangeItem:=["ris", "risAcc", "risReport", "risOldReport"]
	,registerImpaxChangeMsg:=[0x2000,0x2001]
	,registerImpaxChangeItem:=["impax", "impaxAcc"]
	,RisImpaxChangeMsg2Item:=[]
	,RisImpaxChangeItem2Msg:=[]

	loop % registerRisChangeMsg.2-registerRisChangeMsg.1+1 {
		RisImpaxChangeMsg2Item[registerRisChangeMsg.1+A_Index-1]:=registerRisChangeItem[A_Index]
		,RisImpaxChangeItem2Msg[registerRisChangeItem[A_Index]]:=registerRisChangeMsg.1+A_Index-1
	}
	loop % registerImpaxChangeMsg.2-registerImpaxChangeMsg.1+1 {
		RisImpaxChangeMsg2Item[registerImpaxChangeMsg.1+A_Index-1]:=registerImpaxChangeItem[A_Index]
		,RisImpaxChangeItem2Msg[registerImpaxChangeItem[A_Index]]:=registerImpaxChangeMsg.1+A_Index-1
	}

}


checkRIS(byref RisState,refresh=1){
	SetTitleMatchMode,2
	winget,winList,list,放射線資訊管理系統(Radiology Information System)
	match:=0
	loop % winList
	{
		wingetclass, winClass,% "ahk_id " id:=winList%a_index%
		if instr(winClass,"WindowsForms10.Window.8.app.") && id=RisState[2] {
			match:=1
			break
		}
	}
	if (!match && refresh)
		RisState:=RisOpened()
	return match
}



/* check if RIS opened
	[0, 0]: no
	[1, HWND]: wait for login
	[2, HWND]: opened


	for multiple RIS
		1: [HWNDs]
	2: [HWNDs]
*/
;~ risopened()[1]
;~ msgbox % dllcall("IsHungAppWindow", "UInt", risopened()[2])

RisOpened(allRis=0) {
	if (A_TitleMatchMode!=2){
		oldTitleMatchMode:=A_TitleMatchMode
		SetTitleMatchMode,2
	}
	if( A_DetectHiddenWindows!="on" ){
		oldDetectHiddenWindows:=A_DetectHiddenWindows
		detectHiddenWindows,on
	}


	if(allRis=0){

		winget,winList,list,放射線資訊管理系統(Radiology Information System)
		winget,activeWin,id,A
		loop % winList
		{
			wingetclass, winClass,% "ahk_id " winList%a_index%
			if instr(winClass,"WindowsForms10.Window.8.app."){
				return array(2,winList%a_index%)

			}
		}

		winget,winList,list,RIS系統登入<<陽明資訊>>
		loop % winList
		{
			wingetclass, winClass,% "ahk_id " winList%a_index%
			if instr(winClass,"WindowsForms10.Window.8.app."){
				return array(1,winList%a_index%)

			}
		}

		return array(0,0)
	}else{


		ret:=[]
		arr1:=[], arr2:=[]
		winget,winList,list,放射線資訊管理系統(Radiology Information System) ahk_exe Menu.exe
		loop % winList
			if dllcall("IsHungAppWindow", "UInt", winList%a_index%)
				process,close,% "ahk_id " winList%a_index%
		else if(winvisible(winList%a_index%))
			arr1.insert(winList%a_index%)
		else
			arr2.insert(winList%a_index%)

		ret[2]:=[]
		for k,v in arr1
			ret[2].insert(v)
		for k,v in arr2
			ret[2].insert(v)

		ret[1]:=[]
		winget,winList,list,RIS系統登入<<陽明資訊>> ahk_exe Menu.exe
		loop % winList
			ret[1].insert(winList%a_index%)


	}

	if(oldTitleMatchMode)
		SetTitleMatchMode,% oldTitleMatchMode
	if(oldDetectHiddenWindows)
		DetectHiddenWindows,% oldDetectHiddenWindows


	return ret


}

GetControls(hwnd, controls="") {
	if !isobject(controls)
		controls:=[]

	if isobject(hwnd){
		for k,v in hwnd
			controls:=GetControls(v, controls)
		return controls
	}

	winget,classnn,ControlList,ahk_id %hwnd%
	winget,controlId,controllisthwnd,ahk_id %hwnd%
	loop,parse,classnn,`n
	{
		controls[a_index]:=[]
		controls[a_index]["ClassNN"]:=a_loopfield
	}

	loop,parse,controlId,`n
	{
		controls[a_index]["Hwnd"]:=a_loopfield
		controlgetText,txt,,ahk_id %a_loopfield%
		controls[a_index]["text"]:=txt
	}
	return controls
}

GetOtherControl(refHwnd,shift,controls,type="hwnd"){
	for k,v in controls
		if v[type]=refHwnd
			return controls[k+shift].hwnd
}

/* check if IMPAX opened
	arr[1]=0	no IMPAX
	arr[1]=1, arr[2,1]=hwnd of login window
	arr[1]=2, arr[2,1]=hwnd of image window
	arr[1]=2, arr[2,2]=hwnd of list & text window
	arr[1]=2, arr[2,3]=hwnd of list window
	arr[1]=2, arr[2,4]=which type of active IMPAX window (1:image, 2:list, 3:text)
	arr[1]=2, arr[2,5]=which configuration of IMPAX windows (1 for one window, 2 for double window)
*/
ImpaxOpened() {
	winget,ImpaxIdList,list,ahk_class WindowsForms10.Window.8.app.0.2bf8098
	winget,activeWin,id,A
	arr:=[],ind1:=ind2:=ind3:=0,a1:=a2:=a3:=0
	arr[1]:=0
	loop 5
		arr[2,a_index]:=0


	loop % ImpaxIdList
	{
		id:=ImpaxIdList%a_index%
		wingettext,text,ahk_id %id%
		if ind:=instr(text,"STUDY_NAV_TOOLBAR0"){
			ind1:=ind,a1:=a_index,arr[2,1]:=id
			;~ if((arr[2,1]:=id)=activeWin)
				;~ arr[2,4]:=1

		}
		if((instr(text,"工作清單")&&instr(text,"相關性")&&instr(text,"更新"))||(instr(text,"Worklists")&&instr(text,"Relevance")&&instr(text,"Refresh"))){
			if((instr(text,"臨床資訊")&&instr(text,"RIS 狀態")&&instr(text,"病患 HIS 代碼"))||(instr(text,"Clinical Information")&&instr(text,"RIS Status")&&instr(text,"Patient HIS Code"))){
			ind2:=instr(text,"臨床資訊")|instr(text,"Clinical Information")
				a2:=a_index,arr[2,2]:=id
				;~ if((arr[2,2]:=id)=activeWin)
					;~ arr[2,4]:=2
			}else{
				ind3:=instr(text,"工作清單")|instr(text,"Worklists")
				a3:=a_index,arr[2,3]:=id
				;~ if((arr[2,3]:=id)=activeWin)
					;~ arr[2,4]:=3

			}
		}
		wingetpos,,,,h,ahk_id %id%
		if (maxH<h)
			maxH:=h
	}

	h:=maxH
	h-=41


	if (arr[2,1]||arr[2,2]||arr[2,3]){

		arr[1]:=2
		if(arr[2,1]=(arr[2,2]|arr[2,3])){
			arr[2,5]:=1

			if ((bar:=impaxBar(arr[2,2]|arr[2,3])).h>h){
				arr[2,4]:=2
			}else if(ind1<(ind2|ind3)){
				arr[2,4]:=1
			}else {
				arr[2,4]:=3
			}


		}else{
			arr[2,5]:=2

			;~ if(arr[2,4]>1&&(impaxBar(arr[2,2]|arr[2,3]).h>h)){
				;~ arr[2,4]:=2
			;~ }else if (arr[2,4]>1&&(impaxBar(arr[2,2]|arr[2,3]).h<=h)){
				;~ arr[2,4]:=3
			;~ }else{
				;~ arr[2,4]:=1
			;~ }

			if(a1<(a2|a3)){
				arr[2,4]:=1
			}else if(impaxBar(arr[2,2]|arr[2,3]).h>h){
				arr[2,4]:=2
			}else{
				arr[2,4]:=3
			}


		}
		return arr
	}

	loop % ImpaxIdList
	{
		id:=ImpaxIdList%a_index%
		wingettext,text,ahk_id %id%
		if (instr(text,"登入") && instr(text,"密碼") && instr(text,"選項")) || (instr(text,"Login") && instr(text,"Options") && instr(text,"User ID"))
			return array(1,array(id))
	}

	return array(0,0)
}

GetControlIdByText(byref arr,RefControlText,offset=0,UseRegEx=0) {
	if !isobject(arr)||!arr.maxIndex()
		return
	k=0
	if UseRegEx
	{
		for k,v in arr
			if RegExMatch(v.text,RefControltext)
				break
	}
	else
	{
		for k,v in arr
			if v.text=RefControltext
				break
		if !k
			for k,v in arr
				if instr(v.text,RefControltext)
					break
	}

	if !offset
		i:=k
	else
	{
		i:=k+offset
		l:=arr.MaxIndex()
		while i>l
			i-=l
		while i<1
			i+=l
	}
	return (k=0 ? 0 : arr[i]["Hwnd"])

}

;~ run % GetRisPath(1)
GetRisPath(direct=0){
if(direct=0){
		if fileexist(path:=a_desktop "\放射線資訊管理系統(Radiology Information System).appref-ms")
			return path

		if fileexist(path:=a_desktop "\RIS.appref-ms")
			return path

		if fileexist(path:=A_StartMenu "\Programs\放射線資訊管理系統(Radiology Information System).appref-ms")
			return path
		if fileexist(path:=A_StartMenu "\程式集\放射線資訊管理系統(Radiology Information System).appref-ms")
			return path
		if fileexist(path:=A_StartMenu "\Programs\陽明資訊\RIS.appref-ms")
			return path
		if fileexist(path:=A_StartMenu "\程式集\陽明資訊\RIS.appref-ms")
			return path
	}

	loop,HKCU,Software\Microsoft\Windows\ShellNoRoam\MUICache
		if instr(a_loopregname,"Menu.exe") && fileexist(a_loopregname)
			return a_loopregname
	loop,HKCU,Software\Microsoft\Internet Explorer\TypedURLs
	{
		regread,v
		if instr(a,"Menu.exe") && fileexist(v)
			return v
	}
	if (a:=searchFile("Menu.exe",substr(a_windir,1,3) "Documents and Settings\" a_username "\Local Settings\Apps\2.0")).maxindex()
		return a[a.maxindex()]


	return 0

}

;~ if (a:=searchFile("Menu.exe",substr(a_windir,1,3) "Documents and Settings\" a_username "\Local Settings\Apps\2.0")).maxindex()
		;~ clipboard:= a[1]

ListControls(hwnd, obj=0, arr="") {
	if !isobject(arr)
		arr:=[]

	if isobject(hwnd){
		for k,v in hwnd
			arr:=ListControls(v, 1, arr)
		goto ListControlsReturn
	}

	str=
	arr:=GetControls(hwnd)
ListControlsReturn:
	if obj
		return arr

	for k,v in arr
		str.="""" v["Hwnd"] """,""" v["ClassNN"] """,""" v["text"] """`n"
	return str
}

/*
	return switch bar: hwnd, x,y,w,h
*/
ImpaxBar(impaxStateOrHwnd){
	if isobject(impaxStateOrHwnd)
		hwnd:=impaxStateOrHwnd[2,2] | impaxStateOrHwnd[2,3]
	else
		hwnd:=impaxStateOrHwnd

	for k,v in (impaxControls:=getcontrols(hwnd)) {
		if ((v.text="登出"||v.text="Logout") && instr(v.classNN,"WindowsForms10.BUTTON.app") && instr(impaxControls[k-2].classNN,"WindowsForms10.Window.8.app")) {
			controlgetpos,x,y,w,h,,% "ahk_id " barId:=impaxControls[k-2].hwnd
			break
		}
	}
	return {hwnd:barId, x:x, y:y, w:w, h:h}
}

/*
	ImpaxStateArr[1]=image window (in pacs monitor), ImpaxStateArr[2]=search window
	which=0, switch to search page
	which=1, switch to image page
*/
ImpaxSwitchPage(ImpaxStateArr,which=0,bar=""){
	if !bar
		bar:=ImpaxBar(ImpaxStateArr[2])
	wingetpos,winx,winy,,,% "ahk_id " ImpaxStateArr[2]
	if (which=0){
		winactivate,% "ahk_id " ImpaxStateArr[2]
		controlclick,,% "ahk_id " bar.hwnd
	} else if (which=1) {
		if(ImpaxState[1]) {
			winactivate,% "ahk_id " ImpaxStateArr[1]
		}else if !(bar.h>100) {
			mouseclick,,% winx+bar.x+bar.w/3,% winy+bar.y+10,,0
		}

	}
}

/*
	arr[1,1]=main findings
	arr[1,2]=main impression
	arr[2,1]=prior findings
	arr[2,2]=prior impression
	to be editted!!
*/
;~ msgbox % controlgettext(getRisReports(RisOpened()[2])[1,1])
getRisReports(risHwnd){
	arr:=[]
	for k,v in risControls:=getcontrols(risHwnd) {
		if (instr(v.text,"下筆") && instr(v.classNN,"WindowsForms10.BUTTON")) {
			temp:=k
			break
		}
	}
	for k,v in risControls {
		if (v.text="Exam." && instr(risControls[k+1]["classNN"],"WindowsForms10.EDIT.app")) {
			if(abs(k-temp)<18){
				arr[1]:=array(risControls[k+1]["hwnd"],risControls[k+4]["hwnd"])
			}else if (risControls[k-13,"text"]="歷史報告") || (risControls[k-12,"text"]="歷史報告") {
				arr[2]:=array(risControls[k+1]["hwnd"],risControls[k+4]["hwnd"])
			}else if (risControls[k-12,"text"]="報告版本查詢") || (risControls[k-11,"text"]="報告版本查詢") {
				arr[3]:=array(risControls[k+1]["hwnd"],risControls[k+4]["hwnd"])
			}
		}
	}
	return arr
}

getRisReportsHwnd(risHwnd){
	for k,v in risControls:=getcontrols(risHwnd) {
		if (instr(v.text,"下筆") && instr(v.classNN,"WindowsForms10.BUTTON")) {
			temp:=k
			break
		}
	}
	for k,v in risControls {
		if (v.text="Exam." && instr(risControls[k+1]["classNN"],"WindowsForms10.EDIT.app") && abs(k-temp)<13) {
			return array(risControls[k+1]["hwnd"])
			break
		}

	}
	return []

}




getTextByHwnd(id){
	controlgettext,t,,ahk_id %id%
	return t
}

;~ getChartNo(id){
	;~ for k,v in risControls:=getcontrols(id) {
		;~ if RegExMatch(v.text,"(\d|n|N|j|J)\d{6}") && instr(v.classNN,"WindowsForms10.EDIT.app") && risControls[k-1].text="???" && risControls[k+2].text="??" {
			;~ return v.text
		;~ }
	;~ }
;~ }
getImpaxChartNo(impaxStateOrHwnd=""){
	if isobject(impaxStateOrHwnd)
		hwnd:=impaxStateOrHwnd[2,1]
	else if (impaxStateOrHwnd)
		hwnd:=impaxStateOrHwnd
	else
		hwnd:=impaxopened()[2,1]

	controlgettext,chartNo,,% "ahk_id " getNetControl2(hwnd,"","patientIdLabel","","WindowsForms10.STATIC.app","","","",0)[1]

	while strlen(chartNo)<7
		chartNo:="0" chartNo

	return chartno="0000000"?"":chartNo
}
getImpaxUserId(impaxStateOrHwnd=""){
	if isobject(impaxStateOrHwnd)
		hwnd:=impaxStateOrHwnd[2,2] | impaxStateOrHwnd[2,3]
	else if (impaxStateOrHwnd)
		hwnd:=impaxStateOrHwnd
	else
		hwnd:=impaxopened()[2,1]
	controlgettext,UserId,,% "ahk_id " getNetControl2(hwnd,"","userIDLabel","","WindowsForms10.STATIC.app","","","",0)[1]

	return UserId
}

;~ msgbox % getImpaxAccNo()

getImpaxAccNo(impaxStateOrHwnd="",leftUpper=1){
	if isobject(impaxStateOrHwnd)
		hwnd:=impaxStateOrHwnd[2,1]
	else if (impaxStateOrHwnd)
		hwnd:=impaxStateOrHwnd
	else
		hwnd:=impaxopened()[2,1]

	con:=getNetControl2(hwnd,"","accessionNumberLabel","","WindowsForms10.STATIC.app","","","",0)
	controlgettext,AccNo,,% "ahk_id " selectControlByPos(con)

	return AccNo
}
;~ getTopParent(0x1C0BB2)
;~ winget,class,processname,ahk_id 1510172
;~ msgbox % class
;~ getTopParent(hwnd){
	;~ while (hwnd!=(parent:=DllCall("GetParent", "int" , hwnd))) && parent
		;~ hwnd:=parent
	;~ return hwnd
;~ }

selectControlByPos(byref controlArr,mostLeft=1,mostUpper=0,first=1){
	selected:=[],ind:=1
	selected[ind]:=controlArr[1]
	controlgetpos,cx,cy,,,,% "ahk_id " controlArr[1]

	if(mostLeft=0&&mostUpper=0)
		mostLeft:=1

	for k,v in controlArr {
		if k=1
			continue
		controlgetpos,x,y,,,,ahk_id %v%
		if (x=cx && y=cy)
			selected[++ind]:=v
		else if  (((mostLeft=1 && x<cx) || (mostLeft=-1 && x>cx)) && mostUpper=0)
			|| (((mostUpper=1 && y<cy) || (mostUpper=-1 && y>cy)) && mostLeft=0)
			|| (((mostUpper=1 && y<cy) || (mostUpper=-1 && y>cy)) && ((mostUpper=1 && y<cy) || (mostUpper=-1 && y>cy)))
			|| ((x=cx) && mostUpper=0 && y<cy)
			|| ((y=cy) && mostLeft=0 && x<cx)
			selected:=[],ind:=1,selected[1]:=v


		cx:=x,cy:=y
	}

	if(first)
		return selected[1]
	else
		return selected

}


;~ msgbox % getRisChartNo(RisOpened()[2])
;~ ExitApp
getChartNo(id){
	return getRisChartNo(id)
}
getRisChartNo(hwnd){
	;~ controlgettext,chartNo,,% "ahk_id " (ids:=getNetControl2(hwnd,"???","FID_LABEL","???","WindowsForms10.STATIC.app.0.378734a","","","",1))[2]
	;~ if chartNo=
		;~ controlgettext,chartNo,,% "ahk_id " ids[1]
	;~ while strlen(chartNo)<7
		;~ chartNo:="0" chartNo

	;~ return chartno


	for k,v in controls:=getcontrols(hwnd)
		if RegExMatch(v.text,"^\w\d{6}$") && controls[k-1].text="病歷號"
			chartNo:=v.text

	if chartNo!=
		while strlen(chartNo)<7
			chartNo:="0" chartNo

	return chartNo

	for k,v in getcontrols(hwnd)
		if instr(v.classNN,"WindowsForms10.EDIT") && acc_objectfromwindow(v.hwnd).accName="病歷號"
		{
			controlgettext,str,,% "ahk_id " v.hwnd
			return str
		}
}
getRisChartNoHwnd(hwnd){

	for k,v in controls:=getcontrols(hwnd)
		if RegExMatch(v.text,"^\w\d{6}$") && controls[k-1].text="病歷號"
			chartNo:=v.text,id:=v.hwnd

	if chartNo!=
		while strlen(chartNo)<7
			chartNo:="0" chartNo

	return id

	for k,v in getcontrols(hwnd)
		if instr(v.classNN,"WindowsForms10.EDIT") && acc_objectfromwindow(v.hwnd).accName="病歷號"
		{
			;~ controlgettext,str,,% "ahk_id " v.hwnd
			return v.hwnd
		}

}

getRisAccNo(hwnd){
	return getRisSheetNo(hwnd)
}
getRisSheetNo(hwnd){
	for k,v in controls:=getcontrols(hwnd)
		if controls[k-1].text="照會單號" && regexmatch(v.text,"T\d{10}") && instr(v.classNN,"WindowsForms10.EDIT")
		{
			;~ controlgettext,str,,% "ahk_id " v.hwnd
			return v.text
		}
}

getRisAccNoHwnd(risHwnd){
	for k,v in controls:=getcontrols(risHwnd)
		if controls[k-1].text="照會單號" && regexmatch(v.text,"T\d{10}") && instr(v.classNN,"WindowsForms10.EDIT")
		{
			;~ controlgettext,str,,% "ahk_id " v.hwnd
			return v.hwnd
		}

}


getRisHistoryId(hwnd){
	for k,v in controls:=getControls(hwnd)
		if (instr(v.classNN,"WindowsForms10.Window.8.app") && v.text="歷史報告" && instr(controls[k+3,"classNN"],"WindowsForms10.Window.8.app")){
			if (controlId:=controls[k+3,"hwnd"])
				return controlId

		}
}

/*
	getRisHistory(hwnd,byref arr="",n=""){
		if !isobject(arr)
			arr:=[]

	;~ if !controlId:=getNetControl(hwnd,controlName:="dgHisReport",accName:="DataGridView",classNN:="WindowsForms",accHelp:="")
		;~ return arr

	;~ for k,v in controls:=getControls(hwnd)
		;~ if (instr(v.classNN,"WindowsForms10.Window.8.app") && v.text="????" && instr(controls[k+3,"classNN"],"WindowsForms10.Window.8.app")){
			;~ controlId:=controls[k+3,"hwnd"]
			;~ break
		;~ }

		if !(controlId:=getRisHistoryId(hwnd)) || !(acc:=acc_objectfromwindow(controlId))
			return

		acc:=acc_objectfromwindow(controlId)

		colNo:=[]
		loop % acc_children(acc_get("Object",1,0,acc)).maxindex()-1
			colNo["" acc_get("Value","1." a_index+1,0,acc)]:=a_index+1

		loop % (n=""?(acc_children(acc).maxindex()-1):1) {
			i:=(n=""?(a_index+1):n),arr2:=[]
			arr2["ExamDate"]:="" acc_get("Value",i "." colNo["???"],0,acc)
			arr2["DrName"]:="" acc_get("Value",i "." colNo["????"],0,acc)
			arr2["ExamName"]:="" acc_get("Value",i ".4" colNo["????"],0,acc)
			arr2["SheetNo"]:="" acc_get("Value",i ".5" colNo["????"],0,acc)
			arr2["ChartNo"]:="" acc_get("Value",i ".6" colNo["????"],0,acc)
			arr2["ReportIndex"]:="" acc_get("Value",i ".7" colNo["????"],0,acc)
			arr2["Hospital"]:="" acc_get("Value",i ".8" colNo["??"],0,acc)
			arr.insert(arr2.clone())
		}
	;~ arr[0]:=acc
		return arr
	}
*/
getRisHistoryIndex(dgHisReportAcc,rowAcc){
	loop % acc_children(dgHisReportAcc).maxIndex()-1 {
		check:=true
		i:=a_index+1
		loop % acc_children(acc_get("Object",1,0,dgHisReportAcc)).maxindex()-1 {
			j:=A_Index
			check:=check & (acc_get("Value",i "." j,0,dgHisReportAcc)=acc_get("Value",j,0,rowAcc))
		}
		if (check)
			return i
	}
	return 0
}

searchFile(f,dir){
	arr:=[]
	originalWorkingDir:=A_WorkingDir
	SetWorkingDir,% dir
	loop,% f,0,1
		arr.insert(a_loopfilelongpath)
	SetWorkingDir,% originalWorkingDir
	return arr
}


searchRisChartNo(hwnd,chartNo){
	for k,v in controls:=getControls(hwnd)
		if (instr(v.text,"查詢單號") && instr(v.classNN,"WindowsForms10.STATIC")){
			controlfocus,,% "ahk_id " controls[k+1].hwnd
			controlsettext,,% chartNo,% "ahk_id " controls[k+1].hwnd
			controlsend,,{Enter},% "ahk_id " controls[k+1].hwnd
			return true
		}

	for k,v in controls
		if (instr(v.text,"病歷號") && instr(v.classNN,"WindowsForms10.STATIC") && !instr(controls[k-3].text,"照會單號")){
			controlfocus,,% "ahk_id " controls[k+1].hwnd
			controlsettext,,% chartNo,% "ahk_id " controls[k+1].hwnd
			controlsend,,{Enter},% "ahk_id " controls[k+1].hwnd
			return true
		}

	return false
}
; limit can be range: [2, 5] or [7, ] or [8]
; callback: func(rowIndex, rowAcc, cellsAcc)
parseDataGrid(hwnd,byref output="",acc=0,limit=0,sleep=0,start="",callback=""){
	if(acc=0)
		acc:=acc_ObjectFromWindow(hwnd)
		,rows:=acc_children(acc)
	else if(acc=1)
		rows:=hwnd
	rowsCount:=rows.maxIndex()
	;~ callback:=func(callback)

	if (output="")
		output:=[]
	;~ msgbox % start.1 "," 0+start.1 "," start.2
	;~ msgbox % acc_children(acc).maxindex()
	if (isobject(start) && !isobject(limit)){
		for k,v in rows {
			if(!controlexist(hwnd) && !acc_windowfromobject(acc_parent(hwnd[1]))){
				OutputDebug, % "Data grid not exist!"
				return output
			}

			cells:=acc_children(v)
			if(cells[0+start.1].accValue=start.2)
				found:=k
			else if(limit && found && k-found>limit-1)
				break

			for x,y in cells
				output[k,x]:=y.accValue

			%callback%(k, v, cells)

			if (sleep)
				sleep % sleep
		}
	}else if (!isobject(limit)){
		if (start="" || start=0)
			start:=1
		;~ for k,v in rows:=acc_children(acc) {

		loop {
			if (limit && a_index>limit)
				break

			if(!controlexist(hwnd) && !acc_windowfromobject(acc_parent(hwnd[1]))){
				OutputDebug,  % "Data grid not exist!"
				return output
			}

			if (k:=start+a_index-1)>rowsCount
				break
			;~ if (limit && k<=limit){
			for x,y in acc_children(rows[k])
				output[k,x]:=y.accValue
			;~ }
			%callback%(k, v, cells)

			if (sleep)
				sleep % sleep
		}
	}else{

		k1:=limit.1&&limit.1>=1&&limit.1<=rows.maxIndex()?limit.1:1
		if(limit.maxIndex()=1)
			k2:=k1
		else
			k2:=limit.2&&limit.2<=rows.maxindex()&&limit.2>=1?limit.2:rows.maxIndex()
		loop % abs(k2-k1)+1 {
			if(!controlexist(hwnd) && !acc_windowfromobject(acc_parent(hwnd[1]))){
				msgbox % "Data grid not exist!"
				return output
			}

			ind:=k2>=k1?a_index-1+k1:k1-a_index+1
			for x,y in acc_children(rows[k1])
				output[ind,x]:=y.accValue
			%callback%(k)
			if(sleep)
				sleep % sleep
		}

	}

	return rowsCount
}
;~ msgbox % getRisMenu()
getRisMenu(){
	global menuHwnd=0
	EnumAddress := RegisterCallback("EnumProc")
	DllCall("EnumWindows", UInt, EnumAddress, UInt, 0)
	return menuHwnd
}

EnumProc(hwnd, lParam)
{
	global menuHwnd

	if (DllCall("GetWindowLong",UInt,hwnd,Int,-20)=0x10008){
		;~ msgbox % hwnd "," acc_children(acc_objectfromwindow(hwnd))[1].accName
		;~ STYLE:=DllCall("GetWindowLong",UInt,hwnd,Int,-16)
		if ((acc:=acc_children(acc_objectfromwindow(hwnd))).maxindex()=6 && acc[1].accName="瀏覽影像"){
			menuHwnd:=hwnd
			;~ msgbox % DllCall("GetWindowLong",UInt,hwnd,Int,-16)
			return false
		}
	}

	return true  ; Tell EnumWindows() to continue until all windows have been enumerated.
}

getRisExamItems(hwnd){
	;~ arr:=[]
	;~ if !controlId:=getNetControl(hwnd,controlName:="EXAMITEM",accName:="DataGridView",classNN:="WindowsForms",accHelp:="")
		;~ return arr

	for k,v in getcontrols(hwnd) {
		;~ if instr(name:=getControlNameByHwnd(hwnd,v.hwnd),"EXAM"){
		if (instr(name:=getControlNameByHwnd(hwnd,v.hwnd),"EXAMITEM")) {
			return v.hwnd
			acc:=acc_objectFromWindow(v.hwnd)
			break
		}
	}

	;~ ExitApp

	;~ controlgetpos,x,y,w,h,,ahk_id %controlId%
	;~ winactivate,ahk_id %hwnd%
	;~ mousemove,% x,% y
	;~ mousemove,% x+w,% y+h
	;~ pause

}

/*
	arr[1]: active exams done this time
	arr[2]: all exams done this time
*/
parseRisExamItems(hwnd){
	arr:=[[],[]]

	acc:=acc_objectFromWindow(hwnd)

	if !acc
		return arr

	loop % acc_children(acc).maxindex()-1 {
		i:=a_index+1
		str:=acc_get("Value",i ".2",0,acc)
		if(str="")
			continue
		if instr(str,"※")
			arr[1].insert(RegExReplace(str,"※"))
		arr[2].insert(RegExReplace(str,"※"))
	}
	return arr
}
parseRisHistory(hwnd){
	arr:=[]

	if !acc:=acc_objectfromwindow(hwnd)
		return arr

	;~ col:=[]
	;~ for k,v in acc_children(acc_get("Object",1,0,acc))
		;~ col[k]:="" acc_get("Value","1." k+1,0,acc)


	for i,j in rows:=acc_children(acc) {
		if i=1
			continue
		for x,y in acc_children(v)
			arr[i-1,x]:=y.accValue
	}


	;~ loop % acc_children(acc).maxIndex()-1 {
		;~ i:=a_index+1
		;~ loop % k
			;~ arr[a_index,"" col[k]]:=acc_get("Value",i "." k,0,acc)
	;~ }
	return arr

}


getRisHistory(hwnd){

	;~ if !controlId:=getNetControl(hwnd,controlName:="dgHisReport",accName:="DataGridView",classNN:="WindowsForms",accHelp:="")
		;~ return arr

	for k,v in getcontrols(hwnd) {
		if (getControlNameByHwnd(hwnd,v.hwnd)="dgHisReport") {
			return v.hwnd
			break
		}
	}



}



LineBreakConvert(str){
	return regexreplace(regexreplace(str,"\r",""),"\n","`r`n")
}

getSEIM(ImpaxState=""){
	if !impaxstate
		impaxstate:=impaxOpened()
	impaxImageHwnd:=impaxState[2,1]
	SEIM:=getNetControl2(impaxImageHwnd,"","DicomImageNumbers","","WindowsForms10.STATIC.app","","","",0)
	for k,v in SEIM
		if text:=controlgettext(v)
			break
	;~ controlgettext,t,,ahk_id %impaxImageHwnd%
	;~ msgbox % t
	RegExMatch(text,"i)S:\s+(\d+)\s+I:\s+(\d+)",match)
	return [match1,match2]
}


RisExamEditInfo(RisHwnd="",RisExamHwnd=""){
	if !rishwnd && !risexamhwnd
		risHwnd:=risOpened()[2]

	if !risexamhwnd
		risexamhwnd:=getRisReports(risHwnd)[1,1]

	Edit_GetSel(risexamhwnd,start,end)

	return {id: risexamhwnd, start: start,end: end}

}

getReportHint(risHwnd){
	return ControlGetText(acc_windowfromobject(getNetAcc(risHwnd,"REPORT_HINT","WindowsForms10.STATIC")))
}

getIndication(RisHwnd,filter=1){
	indication:=getNetControl2(RisHwnd,"","REPORT_HINT","","WindowsForms10.STATIC.app","","","",0)
	if regexmatch(controlgettext(indication[1]),"Indication:([^\n\r]*)",match) {
		str:=match1
	}else{

		for k,v in getControls(RisHwnd)
			if regexmatch(v.text,"Indication:([^\n\r]*)",match) {
				str:=match1
				break
			}
	}

	str:=RegExReplace(trim(str),"[^\w\+\)]+$","")

	if(filter=1){
		str:=RegExReplace(str,"is)(.+?)(有.+)?","$1")
	}
	return trim(str)
}

getClinicalInfo(RisHwnd){
	return controlgettext(getNetControl2(risHwnd,"","txtALL","","WindowsForms10.EDIT.app","","","",0)[1])
}

getIndicationText(RisHwnd){
	clinicalHx:=getClinicalInfo(RisHwnd)
	indication:=getIndication(RisHwnd)
	if(indication="" && RegExMatch(clinicalHx,"is)\[The Others\]:([^\r\n\※]+)",match)){
		indication:=Trim(match1)
	}
	if(indication="")
		indication:="N/A"
	return indication

}



;~ a:=getSeriesList()
;~ for k,v in a
	;~ msgbox % acc_location(a.1).x
/*
	return arr:	(screen1): [hwnd of series window, hwnd of series control]
	(screen2):
*/
getSeriesList(){
	winget,impaxList,list,ahk_exe impax-client-main.exe
	SeriesList:=[]
	loop % impaxList {
		acc:=acc_objectfromwindow(id:=impaxList%a_index%)
		;~ clipboard.=id "," acc_children(acc).maxindex() "`n"
		if (acc_children(acc).maxindex()=10)
			SeriesList.insert(id)
	}

	if impaxList && !seriesList.maxIndex()
		return -1


	sysget,mon,monitor,2
	;~ sysget,mon2,monitor,3

	List:=[]
	;~ Series:=[]
	for k,v in SeriesList {
		for x,y in getControls(v)
			if (y.ClassNN="SysListView321" && y.text="List1") {
				wingetpos,x,,,,% "ahk_id " y.hwnd
				if (x<=monRight)
					List[1]:=[v,y.hwnd]
				else
					List[2]:=[v,y.hwnd]
				;~ acc:=acc_objectfromwindow(y.hwnd)
				;~ Series["" y.hwnd]:=[]
				;~ loop % acc_children(acc).maxindex()-1
					;~ Series["" y.hwnd].insert(acc_child(acc,a_index))
				break
			}
	}

	;simple sort of two screen list according to x
	;~ pos:=[]
	;~ for k,v in List {
		;~ wingetpos,x,y,,,ahk_id %v%
		;~ pos.insert(x)
	;~ }
	;~ sortedList:=[]
	;~ if pos[2]<pos[1]
		;~ sortedList:=[List[2],List[1]]
	;~ else
		;~ sortedList:=List

	return List

}

;~ a:=getSeriesName()
;~ b:=1

getSeriesName(list="",screen=1){
	if list=
		list:=getSeriesList()

	if isobject(list)
		listAcc:=acc_objectfromwindow(listHwnd:=list[screen,2])
	else
		listAcc:=acc_objectfromwindow(list)

	seriesName:=[],ch:=acc_children(listAcc),count:=ch.maxindex()
	for k,v in ch {
		if (k=count)
			break
		RegExMatch(acc_get("Name","",k,listAcc),"is)(\d+)\s*:\s*(\d+)\s*:\s*(.*)",match)
		seriesName.insert([match3,match2])
	}
	return seriesName
}


;~ a:=getViewFrame()
;~ b=1
/*
	axis:
	(1,1) (1,2)
	(2,1) (2,2)

	return arr:	screen:	hwnd of frame at (x,y)
*/
getViewFrame(ImpaxHwnd=""){
	if impaxHwnd=
		impaxHwnd:=impaxOpened()[2,1]

	if !impaxHwnd
		return

	arr:=[]
	;~ screen:=0,x:=0,y:=0,xMax:=0,yMax:=0
	for k,v in getControls(impaxHwnd)
		if RegExMatch(v.ClassNN,"AfxWnd90u\d+") && RegExMatch(v.text,"Screen_(\d+)_format_\d+_Position_(\d)_(\d)",match) {
			screen:=match1+1,x:=match2+1,y:=match3+1
			if !isobject(arr[screen])
				arr[screen]:=[]
			arr[screen,x,y]:=v.hwnd
		}

	return arr
}

;~ CoordMode,mouse,screen
;~ dragSeries(9,1,2,2)

/*
	seriesInd: 0 as cursor position
	frameX, frameY: axis of frame, one dimension axis if frameY=0
*/

dragSeries(frameX,frameY=0,seriesInd=0,screen=1,seriesList="",frame=""){
	CoordMode,mouse,screen
	if frame=
  		frame:=getViewFrame()
	if seriesList=
		seriesList:=getSeriesList()

	frameFlat:=[]
	for k,v in frame[screen]
		for m,n in v
			frameFlat.insert(n)

	if !(frameHwnd:=frame[screen,frameX,frameY]) && !(frameHwnd:=frameFlat[frameX+frameY])
		return

	listAcc:=acc_objectfromwindow(listHwnd:=seriesList[screen,2])
	listWin:=seriesList[screen,1]
	mousegetpos,mX,mY


	if(seriesInd=0){
		seriesLoc:={x:mX,y:mY,w:0,h:0}
	}else{
		seriesLoc:=acc_location(listAcc,seriesInd)
		if (!seriesLoc.x || !seriesLoc.y)
			return
	}



	if (seriesInd!=0){
		wingetpos,x,y,w,h,ahk_id %listWin%

		xMax:=0,columns:=0
		loop % (seriesNum:=acc_children(listAcc).maxindex()-1) {
			loc:=acc_location(listAcc,a_index)
			;~ if loc.x>xMax
				;~ xMax:=loc.x
			if(loc.x>xMax){
				xMax:=loc.x
			}else{
				columns:=a_index-1
				break
			}
		}

		controlsend,,{home},ahk_id %listHwnd%
		Loop % floor(seriesInd/columns)
			controlsend,,{down},ahk_id %listHwnd%
		sleep 500
		seriesLoc:=acc_location(listAcc,seriesInd)
	}


	wingetpos,fX,fY,fW,fH,% "ahk_id " frameHwnd

	;~ sysget,mon1,monitor,% screen
	;~ sysget,mon2,monitor,% screen+1
	;~ if (fX<mon2Left){
		;~ fX+=mon1Right-mon1Left
	;~ }

	mousemove,% seriesLoc.x+seriesLoc.w/2,% seriesLoc.y+seriesLoc.h/2,0
	;~ controlsend,,{lbutton down},ahk_id %listHwnd%
	send {lbutton down}
	sleep 100

	mousemove,% fX+fW/2,% fY+20,2
	;~ controlsend,,{lbutton up},ahk_id %frameHwnd%
	send {lbutton up}

	mousemove,% mX,% mY,0

}

monitorInfo(){
	sysget,monitorCount,monitorCount
	arr:=[],sorted:=[]
	loop % monitorCount {
		sysget,mon,monitor,% a_index
		arr.insert({l:monLeft,r:monRight,b:monBottom,t:monTop,w:monRight-monLeft+1,h:monBottom-monTop+1})
		k:=a_index
		while strlen(k)<3
			k:="0" k
		sorted[monLeft k]:=a_index
	}
	arr2:=[]
	for k,v in sorted
		arr2.insert(arr[v])
	return arr2
}

/*
	return [current monitor, monitor count]
*/
whichMonitor(x="",y="",byref monitorInfo=""){
	CoordMode,mouse,screen
	if (x="" || y="")
		mousegetpos,x,y
	if !IsObject(monitorInfo)
		monitorInfo:=monitorInfo()

	for k,v in monitorInfo
		if (x>=v.l&&x<=v.r&&y>=v.t&&y<=v.b)
			return [k,monitorInfo.maxIndex()]
}

;~ a:=parseDataGrid(getRisList())
;~ b=1
;~ msgbox % getRisList()
getRisList(hwnd=""){
	if !hwnd
		hwnd:=risOpened()[2]



	return getNetAcc(hwnd,"DataGridView1","WindowsForms",0,0,"","")

}

RisAddToDisplayList(risHwnd="",list=""){
	if !risHwnd
		risHwnd:=risOpened()[2]

	if !list || !isobject(list)
		list:=parseDataGrid(getRisList(risHwnd))

	str:=""
	i:=list.maxIndex()

	for k,v in list.1
		if (v="照會單號") {
			ind:=k
			break
		}

	if !ind
		return
	arr:=[]
	for k,v in list
		if (k!=1 && k!=i)
			str.="ADD_TO_DISPLAY_LIST """" " v[ind] " """" "
	,arr.insert(v[ind])

	str.="SYNC_DISPLAY """" " list[2,ind] " """""

	return arr

}
;~ impaxCyclicListDo()
impaxCyclicListDo(next=1,hwnd=""){
	if !hwnd
		hwnd:=impaxOpened()[2,1]
	controlclick,,% "ahk_id " getNetAcc(hwnd,next=1?"nextButton":"previousButton","WindowsForms10.BUTTON",0,0,"","")
}

controlexist(hwnd){
	if !hwnd
		return
	controlget,id,hwnd,,,ahk_id %hwnd%
	return id
}


RisSearchResultCount(risHwnd){
	static RisSearchResultTextHwnd
	if !controlexist(RisSearchResultTextHwnd)
		RisSearchResultTextHwnd:=getNetAcc(risHwnd,"lblSearchResult","WindowsForms10.STATIC",0,0,"","")
	text:=controlgettext(RisSearchResultTextHwnd)
	regexmatch(text,"共搜尋到\s*(\d+)\s*筆資料",match)
	return match1

}

getRisExamDate(risHwnd){
	if IsObject(risHwnd)
		risHwnd:=risHwnd[2]
	return ControlGetText(getNetControl2(risHwnd,"","EXAM_DATE_TIME","","WindowsForms10.EDIT")[1])
}

getImpaxListAcc(impaxState){
	impaxHwnd:=impaxState[2,2] | impaxState[2,3]
	return getNetAcc(impaxHwnd, "grid", "windowsForms")
}

;~ acc:=getImpaxList(impaxOpened())
;~ parseDataGrid(acc_children(acc), arr:=[], 1)

;~ ExitApp
;~ MsgBox % getRisLoginName(risOpened()[2])
;~ ExitApp
getRisTechName(risHwnd){
	return getNetAcc(risHwnd,"FID_TEXT","WindowsForms10.EDIT",0,true,"放射師","").accValue
}

getRisLoginName(risHwnd){
	WinGetTitle,title,% "ahk_id " risHwnd
	RegExMatch(title,"^([^\-])+", match)
	return match
}

setReportText(findings, impression, RisReports="", replaceFindings=false, replaceImpression=true, caretToEnd=true){
	if (RisReports="" || !IsObject(RisReports)) || !WinExist("ahk_id " RisReports[1,1])
		RisReports:=getRisReports(risOpened()[2])

	if !(replaceFindings)
		findings:=(oldReport:=Trim(ControlGetText(RisReports[1,1]))) (oldReport=""?"":"`n`n") findings
	if !(replaceImpression)
		impression:=Trim(ControlGetText(RisReports[1,2])) "`n" impression

	ControlSetText,,% findings:=Trim(RegExReplace(findings, "(?<!\r)\n", "`r`n")),% "ahk_id " RisReports[1,1]
	ControlSetText,,% impression:=Trim(RegExReplace(impression, "(?<!\r)\n", "`r`n")),% "ahk_id " RisReports[1,2]

	if(caretToEnd){
		Edit_SetSel(RisReports[1,1], len:=StrLen(findings), len)
		Edit_SetSel(RisReports[1,2], len:=StrLen(impression), len)
	}
}