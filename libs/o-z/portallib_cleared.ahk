#include <httprequest>
#include <Hex2Bin>
#include <Crypt_AES>
#include <binaryIO>
#include <json>

portalUrl:="http://portal.ntuh.gov.tw"

#(byref pwb,id){
	return pwb.document.getElementById(id)
}

$(byref dom,id){
	return dom.getElementById(id)
}

/*
function as getElementById(identifier).value
return false if no id match
return "" if value=""

future rewrite: <(\w+)((?:\s+\w+(?:\s*=\s*(?:(?:"[^"]*")|(?:'[^']*')|[^>\s]+))?)*)\s*(\/?)>
*/
get(byref html,identifier,from="id",get="value"){
	dom:=ComObjCreate("HtmlFile")
	
	dom.write(regexreplace(html,"is)(<\/html>).*$","$1"))
		if(from="id"){
			return dom.getElementById(identifier)[get]
		}else if (from="name"){
			return dom.all[identifier][get]
		}
	
}

getText(byref html){
	html:=RegExReplace(html,"[\n\r\t]+","")
	
	html:=regexreplace(html,"\s{2,}<"," <")
	html:=regexreplace(html,">\s{2,}","> ")
	html:=regexreplace(html,">\s+<","><")
	
	html:=RegExReplace(html,"is)<script[^>]*>.*?<\s*\/\s*script\s*>","")

	html:=regexreplace(html,"<[^<>]+>","")
	html:=regexreplace(html,"i)&nbsp;"," ")
	return html
}

getHtmlById(byref html,id,outer=false){
	RegExMatch(html,"is)<([^>\s]+)[^>]*\sid=(?:(?:""" id """)|(?:'" id "')|(?:" id "))[^>]*>(.*?)<\s*\/\s*\1\s*>",match)
	return outer ? match : match2
}

getTextById(byref html,id,trim=true){
	return trim ? trim(s:=getText(getHtmlById(html,id))) : s
}

getHtmlByTagName(byref html,tagName,outer=false){
	arr:=[]
	i:=0
	while i:=regexmatch(html,"is)<" tagName "(?:\s[^>]*)?>(.*?)<\s*\/\s*" tagName "\s*>",match,i+1)
		outer ? arr.insert(match) : arr.insert(match1)
	return arr
}

getTextByTagName(byref html,tagName,trim=true){
	arr:=getHtmlByTagName(html,tagName)
	arr2:=[]
	for k,v in arr
		trim ? arr2.insert(trim(s:=getText(v))) : arr2.insert(s)
	return arr2
}

getUserName(userId,sid){
	if !checkSid(sid)
		return
	global portalUrl
	
	httprequest(url:="http://ihisaw.ntuh.gov.tw/WebApplication/InPatient/Ward/OpenWard.aspx?SESSION=" sid,html:="",header:="")
	
	RegExMatch(header,"ASP.NET_SessionId=(\w+)",match)
	
	
	header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */*`nReferer: http://ihisaw.ntuh.gov.tw/WebApplication/InPatient/Ward/OpenWard.aspx?SESSION=" sid "`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; GTB7.4; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: ihisaw.ntuh.gov.tw`nConnection: Close`nPragma: no-cache`nCookie: " match
	
	post:="scrollLeft=&scrollTop=&__EVENTTARGET=&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=" encodeurl(get(html,"__VIEWSTATE")) "&__EVENTVALIDATION=" encodeurl(get(html,"__EVENTVALIDATION")) "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24DropListHosp=T0&NTUHWeb1%24QueryInPatientPersonAccountControl1%24DropListWard=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24SearchDayRangeTextBox=4&NTUHWeb1%24QueryInPatientPersonAccountControl1%24PersonIDInput=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24AccountIDSEInput=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24tbxChartNoInput=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24PatientBasicInfoQueryByName1%24ctl00=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24OperationRoomInput=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24OPDateInput%24YearInput=" a_yyyy "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24OPDateInput%24MonthInput" 0+a_mm "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24OPDateInput%24DayInput" 0+a_dd "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24IDInputTextBox=" getUserId(sid) "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24DateTextBoxYearMonthDayInputUI1%24YearInput=" a_yyyy "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24DateTextBoxYearMonthDayInputUI1%24MonthInput" 0+a_mm "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24DateTextBoxYearMonthDayInputUI1%24DayInput" 0+a_dd "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24DateTextBoxYearMonthDayInputUI2%24YearInput=" a_yyyy "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24DateTextBoxYearMonthDayInputUI2%24MonthInput" 0+a_mm "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24DateTextBoxYearMonthDayInputUI2%24DayInput" 0+a_dd "&NTUHWeb1%24QueryInPatientPersonAccountControl1%24CheckBoxShowDrMainColumn=on&NTUHWeb1%24QueryInPatientPersonAccountControl1%24ShowIntraReportCheck=on&NTUHWeb1%24QueryInPatientPersonAccountControl1%24QueryPersonIDByChartNo1%24ChartNoTextBox=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24QueryPersonIDByChartNo1%24LNameInput=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24QueryPersonIDByChartNo1%24FNameInput=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24QueryPersonIDByChartNo1%24BirthDayInput=&NTUHWeb1%24QueryInPatientPersonAccountControl1%24HiddenFieldIntraReport=&NTUHWeb1%24Group=BySelectPrint&NTUHWeb1%24ConditionLevelDropList=%23&NTUHWeb1%24DateExecuteSwitchDate%24YearInput=" a_yyyy "&NTUHWeb1%24DateExecuteSwitchDate%24MonthInput" 0+a_mm "&NTUHWeb1%24DateExecuteSwitchDate%24DayInput" 0+a_dd "&NTUHWeb1%24OriginalUserID=&NTUHWeb1%24TransferUserID=&NTUHWeb1%24QueryDrIDInfoByDrName1%24EmpNoQueryInput=" userId "&NTUHWeb1%24QueryDrIDInfoByDrName1%24QueryByID=ID%E6%9F%A5%E5%A7%93%E5%90%8D&NTUHWeb1%24DateTextBoxYearMonthDayInputDrugGiven%24YearInput=" a_yyyy "&NTUHWeb1%24DateTextBoxYearMonthDayInputDrugGiven%24MonthInput" 0+a_mm "&NTUHWeb1%24DateTextBoxYearMonthDayInputDrugGiven%24DayInput" 0+a_dd "&NTUHWeb1%24PrintStartDate%24YearInput=1500&NTUHWeb1%24PrintStartDate%24MonthInput=1&NTUHWeb1%24PrintStartDate%24DayInput=1&NTUHWeb1%24PrintEndDate%24YearInput=" a_yyyy "&NTUHWeb1%24PrintEndDate%24MonthInput" 0+a_mm "&NTUHWeb1%24PrintEndDate%24DayInput" 0+a_dd
	 
	httprequest(url,post,header,"charset: utf-8")
	
	
	
	regexmatch(getTextById(post,"NTUHWeb1_QueryDrIDInfoByDrName1_EmpNoLabel"),"姓名：([^\s　]+)",match)
	return match1
	
	
}

getUserId(sid){
	if !checkSid(sid)
		return
	global portalUrl
	httprequest(portalUrl "/General/Redirect.aspx?SESSION=" sid,page)
	RegExMatch(page,"Portal_UserID=([^\']+)\'",match)
	return match1
}

/*
check if sid valid for portal
return 1 if valid 
return 0 if invalid
*/

checkSid(sid){
	global portalUrl
	if !RegExMatch(sid,"i)^[A-Z\d]+$")
		return 0
	httprequest(portalUrl "/General/Redirect.aspx?SESSION=" sid,page)
	return instr(page,sid) ? 1 : 0
}

/*
return valid sid
*/
renewSid(sid,loginId,loginPw){
	if checkSid(sid)
		return sid
	else
		return login(loginId,loginPw)
}

login(loginId,loginPw,HospitalCode=0){
	global portalUrl
	
	httprequest(url:=portalUrl "/General/Login.aspx",html:="")
	inputs:=[]
	inputs[s:="__VIEWSTATE"]:="" get(html,s)
	inputs[s:="__EVENTVALIDATION"]:="" get(html,s)
	inputs["txtUserID"]:="" loginId
	inputs["txtPass"]:="" md5(loginpw)
	inputs["ddlHospital"]:="T" hospitalCode
	inputs["rdblQuickMenu"]:="H"
	str=
	for k,v in inputs
	  str.= encodeurl(k) "=" encodeurl(v) "&"
	
	post:=str "imgBtnSubmitNew.x=0&imgBtnSubmitNew.y=0"
	header:="Accept: image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*`nReferer: http://portal/General/Login.aspx`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; .NET4.0C; .NET4.0E)`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: portal`nConnection: Close`nPragma: no-cache"
	
	httprequest(url,post,header,"charset: utf-8`n+NO_COOKIES")
	RegExMatch(post,"i)SESSION=([A-Z\d]+)",match)
	global portalAspId:=RegExReplace(header,"s).+ASP\.NET_SessionId=([^;]+);.+","$1")
	return match1 ? match1 : ""
}

logout(sid,portalAspId){
	global portalUrl
	
	httprequest(url:="http://portal.ntuh.gov.tw/General/Redirect.aspx?SESSION=" sid,html:="")
	
	header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */*`nReferer: http://portal.ntuh.gov.tw/General/Redirect.aspx?SESSION=" sid "`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; GTB7.4; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: portal.ntuh.gov.tw`nConnection: Close`nPragma: no-cache`nCookie: _CK_NTUHPortal=HospitalCode=T0&HospitalCodeIndex=0&UserID=" getUserId(sid) "&SessionKey=" sid "&LoginPosCode=H&LoginPosCodeIndex=0; ASP.NET_SessionId=" portalAspId
	
	post:="__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=" encodeurl(get(html,"__VIEWSTATE")) "&__EVENTVALIDATION=" encodeurl(get(html,"__EVENTVALIDATION")) "&ibtnLogOut.x=63&ibtnLogOut.y=22"
	
	httprequest(url,post,header,"charset: utf-8")
	
	
}

patientBasicInfo(chartNo,sid,byref html=""){
	if !checkSid(sid)
		return []
	
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	
	if !regexmatch(chartNo,"(n|N|\d)\d{6}")
		return
	
	if(html=""){
		httprequest(url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/PatientMedicalRecordListQuery.aspx?QueryBySelf=N&SESSION=" sid,html:="")
		inputs:=[]
		inputs[s:="__VIEWSTATE"]:="" get(html,s)
		inputs[s:="__EVENTVALIDATION"]:="" get(html,s)
		inputs["NTUHWeb1$PatientBasicInfoQueryByIDAndName1$ctl01"]:="" chartNo
		inputs["NTUHWeb1$PatientBasicInfoQueryByIDAndName1$ctl09"]:="查詢"
		post=
		for k,v in inputs
			post.= encodeurl(k) "=" encodeurl(v) "&"
		header:="Accept: image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*`nReferer: " url "`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; .NET4.0C; .NET4.0E)`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: ihisaw.ntuh.gov.tw`nConnection: Close`nPragma: no-cache"
		
		httprequest(url,post,header,"charset: utf-8`n+NO_COOKIES")
	}else {
		post:=html
	}
	;~ clipboard:=post
	ptInfo:=[]
	RegExMatch(post,"<[^>]+\sid=""NTUHWeb1_PatAccountListRecord1_PatBasicDescription""[^>]*>([^\(]+)\(([^\,])\,(\d+)\/(\d+)\/(\d+)\,([^\)]+)\)",match)
	ptInfo.name:=match1
	ptInfo.gender:=match2
	ptInfo.birthYear:=match3
	ptInfo.birthMonth:=match4
	ptInfo.birthDay:=match5
	ptInfo.age:=match6
	ptInfo.personId:=get(post,"NTUHWeb1_PatAccountListRecord1_personidHidden")
	
	if (instr(post,"住院中")||instr(post,"已住院登記")||(trim(txt:=getTextById(post,"NTUHWeb1_PatAccountListRecord1_GridViewInPatRecord_ctl02_InLabelStatusName"))&&(!instr(txt,"已出院"))))
		ptInfo.ward:=getTextById(post,"NTUHWeb1_PatAccountListRecord1_GridViewInPatRecord_ctl02_InLabelWardName") " " getTextById(post,"NTUHWeb1_PatAccountListRecord1_GridViewInPatRecord_ctl02_InLabelRoomName") "-" getTextById(post,"NTUHWeb1_PatAccountListRecord1_GridViewInPatRecord_ctl02_InLabelBedName")
	else if s:=getTextById(post,"NTUHWeb1_PatAccountListRecord1_GridViewEmergencyContent_ctl02_LabelEmerTempBedID")
		ptInfo.ward:="ER " s
	else if (trim(txt:=getTextById(post,"NTUHWeb1_PatAccountListRecord1_GridViewEmergencyContent_ctl02_LabelEmerStatusName"))&&txt!="已離部")
		ptInfo.ward:="ER"
	else
		ptInfo.ward:="OPD"
	return ptInfo
}

patientLabDataRecent(personId,sid){
	if !checkSid(sid)
		return
	
	url:= "http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/ReportResultQuery.aspx?SESSION=" sid "&PatClass=I&PersonID=" personId "&Hosp=T0&DefaultQuery=EMRContent"
	
	httprequest(url,data,header,"charset: utf-8`n+NO_COOKIES")
	arr:=new patientLabDataRecent(getHtmlById(data,"TablePatientLabResult"))
	return arr
}

class patientLabDataRecent {
	__New(html){
		i:=0,arr:=[]
		while i:=RegExMatch(html,"is)<td>([^<]*)<\/td>",match,i+1) {
			if a_index<10
				continue
			
			if mod(a_index,3)=1
				item:=match1
			else if mod(a_index,3)=2
				value:=match1
			else {
				date:=match1
				arr[item,"" date]:=value
			}
		}
		this.lab:=arr
	}
	
	getValue(labName){
		value:=[]
		for k,v in this.lab {
			if (isobject(labName)) {
				for m,n in labName
					if(k=n)
						for x,y in v
							value.insert(array(x,y))
			}else if(k=labName)
				for x,y in v
					value.insert(array(x,y))
		}
		return value
	}
	
}

/* ;~ old site is closed on 2012/10/1 
patientLabDataRecent(chartno,sid){
	global portalUrl
	if !checkSid(sid)
		return 
	url:= portalUrl "/DigReport/CheckUser_report.asp?SESSION=" sid "&myurl=DigReport/Lab/NewQuery.asp?chartno=" chartNo
	header:="Accept: image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)`nAccept-Encoding: gzip, deflate`nConnection: Close`nHost: portal`nCookie: chartno=; _CK_NTUHPortal=HospitalCode=T0&HospitalCodeIndex=0&UserID=100860&SessionKey=520520A662C445E3B0D89688209F77A8&LoginPosCode=H&LoginPosCodeIndex=0; ASP.NET_SessionId=rbwu4emb3j4m4555ss1pxm45; ASPSESSIONIDCCRABSBD=ILBHPDCBCOCOMBHAGDFJOBGM"
	
	httprequest(url,data,header,"charset: utf-8`n+NO_COOKIES")
	return data
}
*/
/* ;~ old site is closed on 2012/10/1 
patientLabDataAll(chartno,sid){
	global portalUrl
	
	if !checkSid(sid)
		return
	
	patientLabDataRecent(chartno,sid)
	
	url:=portalUrl "/DigReport/Lab/NewQuery_notsure.asp"
	header:="Accept: image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*`nReferer: http://portal/DigReport/Lab/NewQuery.asp?chartno=" chartno "`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)`nAccept-Encoding: gzip, deflate`nHost: portal`nConnection: Close`nCookie: chartno=; _CK_NTUHPortal=HospitalCode=T0&HospitalCodeIndex=0&UserID=100860&SessionKey=520520A662C445E3B0D89688209F77A8&LoginPosCode=H&LoginPosCodeIndex=0; ASP.NET_SessionId=rbwu4emb3j4m4555ss1pxm45; ASPSESSIONIDCCRABSBD=ILBHPDCBCOCOMBHAGDFJOBGM"
	
	httprequest(url,data:="",header,"charset: utf-8`n+NO_COOKIES")
	return lab:=new parseLabData(data)
	
}
*/
/*
return 0: time out
return 1
*/
waitLoaded(byref pwb,judge="",waitSeconds=30,firstDelay=200){
	sleep % firstDelay
	if !isobject(judge) {
		while pwb.busy {
			if (a_index>waitSeconds*10)
				return 0
			sleep 100
		}
		return 1
	}else{
		while !judge.(pwb) {
			if (a_index>waitSeconds*10)
				return 0
			sleep 100
		}
		return 1
	}
}

IEGet2(Name="",matchMode="1") {     ;Retrieve pointer to existing IE window/tab

		Name := ( Name="New Tab - Windows Internet Explorer" ) ? "about:Tabs" : RegExReplace( Name, " - (Windows|Microsoft) Internet Explorer" )
		
		if(matchMode="1"){
			For Pwb in ComObjCreate( "Shell.Application" ).Windows
				If ( RegExMatch(Pwb.LocationName,"^" Name) && InStr( Pwb.FullName, "iexplore.exe" ))
					Return Pwb
		}else if(matchMode="2"){
			For Pwb in ComObjCreate( "Shell.Application" ).Windows
				If ( instr(Pwb.LocationName,Name) && InStr( Pwb.FullName, "iexplore.exe" ))
					Return Pwb
		}else if(matchMode="3"){
			For Pwb in ComObjCreate( "Shell.Application" ).Windows
				If ( Pwb.LocationName=Name) && InStr( Pwb.FullName, "iexplore.exe" )
					Return Pwb
		}else if(matchMode="RegEx"){
			For Pwb in ComObjCreate( "Shell.Application" ).Windows
			If ( RegExMatch(Pwb.LocationName,Name) && InStr( Pwb.FullName, "iexplore.exe" ))
				Return Pwb
	}
	
	return ""
} 

/*
return array with key=(innerText), value=(id)
*/
labOrderList(byref pwb,divId="NTUHWeb1_OrderSearch1_pnlSearchOrders"){
	arr:=[]
	if instr(pwb.document.getElementById(divId).innerText,"查無醫令")
		return arr
	tr:=pwb.document.getElementById(divId).getElementsByTagName("a")
	
	loop % tr.length
		if RegExMatch(tr[a_index-1].id,"NTUHWeb1_OrderSearch1_dlsOrders_ctl\d+_lbnName")
			arr[tr[a_index-1].innerText]:=tr[a_index-1].id
	
	return arr
}

/*
return array with key=(academic name), value=(business name)
*/
medOrderList(pwb,divId="NTUHWeb1_MedicationDrugSearchBox_pnlControl"){
	arr:=[]
	
	
	
	tr:=pwb.document.getElementById(divId).rows
	
	loop % tr.length-1 {
		name:=tr[a_index].cells[1].innerText
		arr[name,"id"]:=tr[a_index].getElementsByTagName("input")[0].id
		arr[name,"bName"]:=tr[a_index].cells[2].innerText
	}
	
	return arr
}

class parseLabDataRegex
{
	__New(html){
		if !html
			return ""
		labTable:=getHtmlByTagName(html,"table")[2]
		labTableRows:=getHtmlByTagName(labTable,"tr")
		lab:=[]
		loop % labTableRows.maxIndex()
		{
			i:=a_index
			labTableRowText:=getText(labTableRows[i])
			if(i=1){
				RegExMatch(labTableRowText,"病歷號:(\w{7})\s+姓名:([^\n]+)(?:先生|小姐)\s+生日:\s民國\s([^\s]+)",match)
				if !match1
					break
				lab.chartNo:="" match1
				lab.name:="" match2
				lab.birthDate:="" match3
				continue
			}
			if (!labTableRowText)
				continue
			if(regexmatch(labTableRowText,"登記\s([^\s]+)\s+([^\s]+)\s+([^\n]+\s+)([^\s]+)\s+No:([^\s]+)\s+(?:詳細資料\s+)?報告\s([^\s]+)\s+([^\s]+)",match)){
				labNo:=match5
				lab[labNo]:=[]
				lab[labNo].registerDate:="" match1
				lab[labNo].registerTime:="" match2
				lab[labNo].sample:="" trim(match3)
				lab[labNo].examRoom:="" match4
				lab[labNo].reportDate:="" match6
				lab[labNo].reportTime:="" match7
				continue
			}
			
			if(instr(labTableRowText,"檢查項目")){
				labNameCol:=labValueCol:=labUnitCol:=labRangeCol:=labInfoCol:=""
				loop % getHtmlByTagName(labTableRows[i],"td").maxIndex() 
				{
					labTableCellText:=getText(getHtmlByTagName(labTableRows[i],"td")[a_index])
					if instr(labTableCellText,"檢查項目")
						labNameCol:=a_index
					else if instr(labTableCellText,"數值")
						labValueCol:=a_index
					else if instr(labTableCellText,"單位")
						labUnitCol:=a_index
					else if instr(labTableCellText,"標準值")
						labRangeCol:=a_index
					else if instr(labTableCellText,"說明")
						labInfoCol:=a_index
				}
				continue
			}
			
			if !labNameCol || !labNo
				continue
			else
			{
				labTableCells:=getHtmlByTagName(labTableRows[i],"td")
				labName:=trim(getText(labTableCells[labNameCol]))
				lab[labNo][labName]:=[]
				if labValueCol
					lab[labNo][labName].value:="" trim(getText(labTableCells[labValueCol]))
				if labUnitCol
					lab[labNo][labName].unit:="" trim(getText(labTableCells[labUnitCol]))
				if labRangeCol
					lab[labNo][labName].range:="" trim(getText(labTableCells[labRangeCol]))
				if labInfoCol
					lab[labNo][labName].info:="" trim(getText(labTableCells[labInfoCol]))
			}
		}
		
		labHxTable:=getHtmlByTagName(html,"table")[3]
		labHxTableRows:=getHtmlByTagName(labHxTable,"tr")
		labHx:=[]
		loop % labHxTableRows.maxIndex()-1
		{
			labHxTableRow:=labHxTableRows[a_index+1]
			labHx[a_index]:=[]
			labHx[a_index].account:="" getText(getHtmlByTagName(labHxTableRow,"td")[2])
			labHx[a_index].ptFrom:="" getText(getHtmlByTagName(labHxTableRow,"td")[3])
			labHx[a_index].earliest:="" getText(getHtmlByTagName(labHxTableRow,"td")[4])
			labHx[a_index].last:="" getText(getHtmlByTagName(labHxTableRow,"td")[5])
			labHx[a_index].newest:="" getText(getHtmlByTagName(labHxTableRow,"td")[6])
			RegExMatch(getHtmlByTagName(labHxTableRow,"td")[2],"href=""([^""]+)""",match)
			labHx[a_index].link:="" match1
			
		}
		
		lab.insert("labHx",labHx)
		this.lab:=lab	
	}
	
	
	/* result:
	(index)
		1
			register date and time in format of 100.01.01 00:00
		2
			value
	*/
	getValue(labName,sample="BLOOD"){
		StringUpper,sample,sample
		result:=[]
		for k,v in this.lab
		{
			if k is not number
				continue
			
			if !(v.sample=sample)
				continue
			
			
			for i,j in v
			{
				if !isobject(j)
					continue
				
				if(i=labName)
					result.insert(array("" v.registerDate " " v.registerTime,"" j.value))
			}
		}
		
		return result
	}
}

/* structure:
name: patient name
chartNo: patient chart no.
birthDate: patient birthday in format of 74.01.01
(labNo): 7 digits of number
	examRoom
	registerDate
	registerTime
	reportDate
	reportTime
	(labName)
		value
		unit
		range
		info
labHx	
	(index)
		account
		earliest
		last
		link
		newest
		ptFrom
		
future rewrite: use regex to parse
*/
class parseLabData
{
	__New(html){
		if !html
			return ""
		doc := ComObjCreate("{25336920-03F9-11CF-8FD0-00AA00686F13}")
		doc.write(html)
		labTable:=doc.getElementsByTagName("table")[1]
		labTableRows:=labTable.rows
		lab:=[]
		loop % labTableRows.length
		{
			i:=a_index-1
			labTableRowText:=labTableRows[i].innerText
			if(!i){
				RegExMatch(labTableRowText,"病歷號:(\w{7})\s+姓名:([^\n]+)(?:先生|小姐)\s+生日:\s民國\s([^\s]+)",match)
				if !match1
					break
				lab.chartNo:="" match1
				lab.name:="" match2
				lab.birthDate:="" match3
				continue
			}
			if (!labTableRowText)
				continue
			if(regexmatch(labTableRowText,"登記\s([^\s]+)\s+([^\s]+)\s+([^\n]+\s+)([^\s]+)\s+No:([^\s]+)\s+(?:詳細資料\s+)?報告\s([^\s]+)\s+([^\s]+)",match)){
				labNo:=match5
				lab[labNo]:=[]
				lab[labNo].registerDate:="" match1
				lab[labNo].registerTime:="" match2
				lab[labNo].sample:="" trim(match3)
				lab[labNo].examRoom:="" match4
				lab[labNo].reportDate:="" match6
				lab[labNo].reportTime:="" match7
				continue
			}
			
			if(instr(labTableRowText,"檢查項目")){
				labNameCol:=labValueCol:=labUnitCol:=labRangeCol:=labInfoCol:=""
				loop % labTableRows[i].cells.length 
				{
					labTableCellText:=labTableRows[i].cells[a_index-1].innerText
					if instr(labTableCellText,"檢查項目")
						labNameCol:=a_index-1
					else if instr(labTableCellText,"數值")
						labValueCol:=a_index-1
					else if instr(labTableCellText,"單位")
						labUnitCol:=a_index-1
					else if instr(labTableCellText,"標準值")
						labRangeCol:=a_index-1
					else if instr(labTableCellText,"說明")
						labInfoCol:=a_index-1
				}
				continue
			}
			
			if !labNameCol || !labNo
				continue
			else
			{
				labTableCells:=labTableRows[i].cells
				labName:=trim(labTableCells[labNameCol].innerText)
				lab[labNo][labName]:=[]
				if labValueCol
					lab[labNo][labName].value:="" trim(labTableCells[labValueCol].innerText)
				if labUnitCol
					lab[labNo][labName].unit:="" trim(labTableCells[labUnitCol].innerText)
				if labRangeCol
					lab[labNo][labName].range:="" trim(labTableCells[labRangeCol].innerText)
				if labInfoCol
					lab[labNo][labName].info:="" trim(labTableCells[labInfoCol].innerText)
			}
		}
		
		labHxTable:=doc.getElementsByTagName("table")[2]
		labHxTableRows:=labHxTable.rows
		labHx:=[]
		loop % labHxTableRows.length-1
		{
			labHxTableRow:=labHxTableRows[a_index]
			labHx[a_index]:=[]
			labHx[a_index].account:="" labHxTableRow.cells[1].innerText
			labHx[a_index].ptFrom:="" labHxTableRow.cells[2].innerText
			labHx[a_index].earliest:="" labHxTableRow.cells[3].innerText
			labHx[a_index].last:="" labHxTableRow.cells[4].innerText
			labHx[a_index].newest:="" labHxTableRow.cells[5].innerText
			labHx[a_index].link:="" labHxTableRow.cells[1].getElementsByTagName("a")[0].href
			
		}
		
		lab.insert("labHx",labHx)
		this.lab:=lab
		
	}
	
	/* result:
	(index)
		1
			register date and time in format of 100.01.01 00:00
		2
			value
	*/
	getValue(labName,sample="BLOOD"){
		StringUpper,sample,sample
		result:=[]
		for k,v in this.lab
		{
			if k is not number
				continue
			
			if !(v.sample=sample)
				continue
			
			
			for i,j in v
			{
				if !isobject(j)
					continue
				
				if(i=labName)
					result.insert(array("" v.registerDate " " v.registerTime,"" j.value))
			}
		}
		
		return result
	}
	
}

MD5( V ) { ; www.autohotkey.com/forum/viewtopic.php?p=376840#376840
 VarSetCapacity( MD5_CTX,104,0 ), DllCall( "advapi32\MD5Init", UInt,&MD5_CTX )
 DllCall( "advapi32\MD5Update", UInt,&MD5_CTX, A_IsUnicode ? "AStr" : "Str",V
 , UInt,StrLen(V) ), DllCall( "advapi32\MD5Final", UInt,&MD5_CTX )
 Loop % StrLen( Hex:="123456789ABCDEF0" )
  N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
stringlower,MD5,md5
return md5
}

EncodeURL( p_data, p_reserved=true, p_encode=true ) {
   old_FormatInteger := A_FormatInteger
   SetFormat, Integer, hex

   unsafe = 
      ( Join LTrim
         25000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20
         22233C3E5B5C5D5E607B7C7D7F808182838485868788898A8B8C8D8E8F9091929394
         95969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6
         B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8
         D9DADBDCDDDEDF7EE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9
         FAFBFCFDFEFF
      )
      
   if ( p_reserved )
      unsafe = %unsafe%24262B2C2F3A3B3D3F40
   
   if ( p_encode )
      loop, % StrLen( unsafe )//2
      {
         StringMid, token, unsafe, A_Index*2-1, 2
         StringReplace, p_data, p_data, % Chr( "0x" token ), `%%token%, all 
      }
   else
      loop, % StrLen( unsafe )//2
      {
         StringMid, token, unsafe, A_Index*2-1, 2
         StringReplace, p_data, p_data, `%%token%, % Chr( "0x" token ), all
      }
      
   SetFormat, Integer, %old_FormatInteger%

   return, p_data
}

DecodeURL( p_data ) {
   return, EncodeURL( p_data, true, false )
}

getLab4New(chartNo,sid,days=10){
	global lab4portalAspId
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MedicalReportContent.aspx?PatClass=I&WardCode=03C1&ChartNo=" chartNo "&HospitalCode=T0&Seed=" a_now "&IntervalDay=-" days-1 "&SESSION=" sid
	
	header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/xaml+xml, application/vnd.ms-xpsdocument, application/x-ms-xbap, application/x-ms-application, */*`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; BTRS105843; SIMBAR={170CCC21-65EC-11E2-B538-FEB49644ABDD}; GTB7.5; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nAccept-Encoding: gzip, deflate`nConnection: Close`nHost: ihisaw.ntuh.gov.tw`nCookie: CK_MedicalReportOpen_PatientQueryCookie=SelectPatListTypeCookieIPatList=&SelectPatListTypeCookieEPatList=&SelectPatListTypeCookieOPatList=&SelectPatListTypeCookieLabPatList=&SelectPatListTypeCookieSpeList=&SelectPatListTypeCookie=IPatList;"
	
	httprequest(url,post:="",header,"charset: utf-8")
	RegExMatch(header,"is).+ASP.NET_SessionId=(\w{24}).+",match)
	lab4portalAspId:=match1
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MedicalReportContent.aspx?PatClass=I&WardCode=03C1&ChartNo=" chartNo "&HospitalCode=T0&Seed=" a_now "&IntervalDay=-" days-1 "&SESSION=" sid
	
	
	header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/xaml+xml, application/vnd.ms-xpsdocument, application/x-ms-xbap, application/x-ms-application, */*`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; BTRS105843; SIMBAR={170CCC21-65EC-11E2-B538-FEB49644ABDD}; GTB7.5; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nAccept-Encoding: gzip, deflate`nConnection: Close`nHost: ihisaw.ntuh.gov.tw`nCookie: CK_MedicalReportOpen_PatientQueryCookie=SelectPatListTypeCookieIPatList=&SelectPatListTypeCookieEPatList=&SelectPatListTypeCookieOPatList=&SelectPatListTypeCookieLabPatList=&SelectPatListTypeCookieSpeList=; ASP.NET_SessionId=" lab4portalAspId
	
	httprequest(url,post:="",header,"charset: utf-8")
	
	dom:=ComObjCreate("HtmlFile")
	dom.write(post)
	return parseLab4New(dom)
}

parseLab4New(byref dom){
	arr:=[]
	loop % (spans:=$(dom,"lReportTab_lsvReportBody_ctrl0_ctl00_LabDetailedSheetControl1_SpanSort").parentNode.childNodes).length-1 {
		specimen:=[]
		span:=spans[a_index]
		
		RegExMatch(text:=span.firstChild.innerText,"isO)([^:\d]+?):(.+?)\s([^:\d]+?):(\d+?)\s(.+)\s([^:\d]+?):(.+?)\s([^:\d]+?):(.+?)\s([^:\d]+?):(.+?)$",match)
		specimen["Info","" trim(match.1)]:=trim(match.2)
		specimen["Info","" trim(match.3)]:=trim(match.4)
		specimen["Info","SpecimenName"]:=trim(match.5)
		specimen["Info","" trim(match.6)]:=trim(match.7)
		specimen["Info","" trim(match.8)]:=trim(match.9)
		specimen["Info","" trim(match.10)]:=trim(match.11)
		
		table:=span.getElementsByTagName("TABLE")[0]
		titles:=[]
		loop % (tds:=table.rows[0].childNodes).length
			titles.insert(trim(tds[a_index-1].innerText))
		loop % (trs:=table.childNodes[1].childNodes).length {
			item:=[],i:=a_index
			for k,v in titles
				item["" v]:="" trim(regexreplace(trs[i-1].childNodes[k-1].innerText,"歷$"))
			specimen.insert(item.clone())
		}
		arr.insert(specimen.clone())
	}
	return arr
}

findLab4New(byref lab,itemName,specimenName="BLOOD"){
	arr:=[],itemNameText:="檢驗項目",sort:=[],foundCount:=0
	for i,specimen in lab
		for k,item in specimen {
			if (k="Info" || !(item[itemNameText]=itemName))
				continue
			
			if (time:=regexreplace(specimen["info","採檢"],"\D")) {
			}else if (time:=regexreplace(specimen["info","登入"],"\D")) {
			}else 
				time:=regexreplace(specimen["info","最後報告"],"\D")
			
			sort[time]:=(++foundCount)
			found:=item.clone()
			for m,n in specimen.Info
				found["" m]:="" n
			arr.insert(found.clone())
		}
	
	sortedArr:=[]
	for k,v in sort
		sortedArr[foundCount+1-a_index]:=arr[v].clone()
	return sortedArr
}

searchLab4(chartNo,sid){
	if !checksid(sid)
		return
	
	;~ global portalUrl
	httprequest(url:="http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MedicalReportContent.aspx?SESSION=" sid,html:="")
	inputs:=[]
	inputs["__LASTFOCUS"]:=""
	inputs["__EVENTTARGET"]:=""
	inputs["__EVENTARGUMENT"]:=""
	inputs[s:="__VIEWSTATE"]:="" get(html,s)
	inputs["__VIEWSTATEENCRYPTED"]:=""
	inputs[s:="__PREVIOUSPAGE"]:="" get(html,s)
	inputs[s:="__EVENTVALIDATION"]:="" get(html,s)
	inputs["hdfDelayedAction"]:=""
	inputs["hdfAction"]:=""
	inputs["hdfSplitted"]:="false"
	inputs["hdfSelectPatientList"]:=""
	inputs["hdfPatientInfoStaus"]:=""
	inputs["CleanCookie"]:="false"
	inputs["HeaderTemplate1$hdfSelectedFilter"]:=""
	inputs["HeaderTemplate1$hdfIsFilterSetModified"]:="False"
	inputs["sltexample4"]:="LabReport"
	inputs["sltexample4"]:="XrayTextReport"
	inputs["sltexample4"]:="UltraSonicReport"
	inputs["sltexample4"]:="ECGReport"
	inputs["sltexample4"]:="CECGReport"
	inputs["sltexample4"]:="TreadmillReport"
	inputs["sltexample4"]:="ABPMReport"
	inputs["sltexample4"]:="LungFunctionReport"
	inputs["sltexample4"]:="ExerciseLungReport"
	inputs["sltexample4"]:="GEEndoScopeReport"
	inputs["sltexample4"]:="EchocardiogramExternalReport"
	inputs["sltexample4"]:="EchocardiogramReport"
	inputs["sltexample4"]:="HolterReport"
	inputs["sltexample4"]:="HealthyCenterReport"
	inputs["sltexample4"]:="PathologyReport"
	inputs["sltexample4"]:="PapTestReport"
	inputs["sltexample4"]:="SLP"
	inputs["sltexample4"]:="UBTReport"
	inputs["sltexample4"]:="UltraSoundReport"
	inputs["sltexample4"]:="EEGReport"
	inputs["sltexample4"]:="ConductionReport"
	inputs["sltexample4"]:="EvokeReport"
	inputs["sltexample4"]:="RTNoteReport"
	inputs["sltexample4"]:="GeneticReport"
	inputs["sltexample4"]:="ChromosomesReport"
	inputs["sltexample4"]:="PEDEEGReport"
	inputs["sltexample4"]:="PEDHEARTSONOReport"
	inputs["sltexample4"]:="01400-4-601266"
	inputs["sltexample4"]:="01400-4-601197"
	inputs["sltexample4"]:="01400-4-601267"
	inputs["sltexample4"]:="01400-4-601431"
	inputs["multiselect_sltReportFilter"]:="LabReport"
	inputs["multiselect_sltReportFilter"]:="XrayTextReport"
	inputs["multiselect_sltReportFilter"]:="UltraSonicReport"
	inputs["multiselect_sltReportFilter"]:="ECGReport"
	inputs["multiselect_sltReportFilter"]:="CECGReport"
	inputs["multiselect_sltReportFilter"]:="TreadmillReport"
	inputs["multiselect_sltReportFilter"]:="ABPMReport"
	inputs["multiselect_sltReportFilter"]:="LungFunctionReport"
	inputs["multiselect_sltReportFilter"]:="ExerciseLungReport"
	inputs["multiselect_sltReportFilter"]:="GEEndoScopeReport"
	inputs["multiselect_sltReportFilter"]:="EchocardiogramExternalReport"
	inputs["multiselect_sltReportFilter"]:="EchocardiogramReport"
	inputs["multiselect_sltReportFilter"]:="HolterReport"
	inputs["multiselect_sltReportFilter"]:="HealthyCenterReport"
	inputs["multiselect_sltReportFilter"]:="PathologyReport"
	inputs["multiselect_sltReportFilter"]:="PapTestReport"
	inputs["multiselect_sltReportFilter"]:="SLP"
	inputs["multiselect_sltReportFilter"]:="UBTReport"
	inputs["multiselect_sltReportFilter"]:="UltraSoundReport"
	inputs["multiselect_sltReportFilter"]:="EEGReport"
	inputs["multiselect_sltReportFilter"]:="ConductionReport"
	inputs["multiselect_sltReportFilter"]:="EvokeReport"
	inputs["multiselect_sltReportFilter"]:="RTNoteReport"
	inputs["multiselect_sltReportFilter"]:="GeneticReport"
	inputs["multiselect_sltReportFilter"]:="ChromosomesReport"
	inputs["multiselect_sltReportFilter"]:="PEDEEGReport"
	inputs["multiselect_sltReportFilter"]:="PEDHEARTSONOReport"
	inputs["multiselect_sltReportFilter"]:="01400-4-601266"
	inputs["multiselect_sltReportFilter"]:="01400-4-601197"
	inputs["multiselect_sltReportFilter"]:="01400-4-601267"
	inputs["multiselect_sltReportFilter"]:="01400-4-601431"
	inputs["q"]:=""
	inputs["HeaderTemplate1$txbIDInput"]:="" chartNo
	inputs["HeaderTemplate1$TextBoxWatermarkExtender1_ClientState"]:=""
	inputs["HeaderTemplate1$btnQueryAction"]:="查詢"
	inputs["PatientListTemplate1$rblPatList"]:="IPatList"
	inputs["PatientListTemplate1$ddlBedHosp"]:="T0"
	inputs["PatientListTemplate1$ddlWard"]:=""
	
	post=
	for k,v in inputs
	  post.= encodeurl(k) "=" encodeurl(v) "&"
	
	header:="Accept: image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*`nReferer: http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MedicalReportContent.aspx?`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: ihisaw.ntuh.gov.tw`nConnection: Close`nPragma: no-cache`nCookie: InPatientWardDefaultQuery=T0|04B2|00|; WardListColumnSelect" getUserId(sid) "=DR; Page_Session_InPatientPatientListSessionKey=Pat0=09B_13_02_%u5b98%u68ee%u679d%7cT0_I_V200162702_12T03777608&Pat1=09B_15_01_%u5b98%u68ee%u679d%7cT0_I_V200162702_12T01536867; NTUHPage_MenuSettingCookie=%u5831%u544a%u67e5%u8a62=Y; WardListColumnSelect006584=DR; H102172945_allergyExpire=N; K201534052_allergyExpire=N; B100586598_allergyExpire=N; A121394302_allergyExpire=N; A101438778_allergyExpire=N; A101605911_allergyExpire=N; WardListColumnSelect007382=DR; P101086669_allergyExpire=N; A102053680_allergyExpire=N; D120348318_allergyExpire=N; V200162702_allergyExpire=N; CK_MedicalReportOpen_PatientQueryCookie=SelectPatListTypeCookieIPatList=T0&SelectPatListTypeCookieEPatList=T0&SelectPatListTypeCookieOPatList=T0&SelectUnitOrderTypeCookieE=0&SelectPatListTypeCookieSpeList=T0; ASP.NET_SessionId=nu1hnlzfevbjw4bc2a5t11qd"
	
	httprequest(url,post,header,"charset: utf-8")
	return header "`n`n" post
}

LabIn10Days(chartNo,sid,personId=""){
	if !checksid(sid)
		return
	
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	
	if !personId
		personId:=patientBasicInfo(chartNo,sid).personId
	
	seed:=a_now
	
	header:="Accept: image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*`nReferer: http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/SimpleShowiframePage.aspx?SESSION=" sid "&PersonID=" personId "&Seed=" seed "`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)`nAccept-Encoding: gzip, deflate`nHost: portal.ntuh.gov.tw`nConnection: Close`nCookie: _CK_NTUHPortal=HospitalCode=T0&HospitalCodeIndex=0&UserID=" getUserId(sid) "&SessionKey=" sid "&LoginPosCode=H&LoginPosCodeIndex=0"
	
	httprequest("http://portal.ntuh.gov.tw/new_digreport/Lab/NewQuery.asp?result_latest=Y&chartno=" chartNo,post:="",header,"charset: utf-8")
	lab:=new patientLabIn10Days(post)
	return lab
}

class patientLabIn10Days {
	__New(html){
		i:=0,arr:=[],labNo:=""
		dom:=ComObjCreate("HtmlFile")
		dom.write(html)
		
		
		loop % (tables:=dom.getElementsByTagName("TABLE")).length {
			v:=tables[a_index-1]
			
			if RegExMatch(v.innerText,"[^\s]+\s+([^\n]+)\s+No:(\d+)\s+\(\s+(\d+).(\d+).(\d+)\s+(\d+:\d+)[^\(]+\((\d+).(\d+).(\d+)\s+(\d+:\d+)",match){
				labNo:=match2
				arr["" labNo,"sample"]:="" trim(match1)
				arr["" labNo,"regDate"]:=(match3+1911) match4 match5
				arr["" labNo,"regTime"]:="" match6
				arr["" labNo,"reportDate"]:=(match7+1911) match8 match9
				arr["" labNo,"reportTime"]:="" match10
				
				continue
			}
			
			if !labNo
				continue

			if(v.getElementsByTagName("TABLE").length)
				continue
			
			
			loop % (tr:=v.rows).length {
				if(a_index=1)
					continue
				
				
				if (td:=tr[a_index-1].cells).length<6
					continue
				
				labName:="" trim(td[1].innerText)
				arr["" labNo,"" labName,"value"]:="" trim(td[2].innerText)
				arr["" labNo,"" labName,"unit"]:="" trim(td[3].innerText)
				arr["" labNo,"" labName,"range"]:="" trim(td[4].innerText)
				arr["" labNo,"" labName,"condition"]:="" trim(td[5].innerText)
				
			}
			labNo:=""
			
		}
		
		this.lab:=arr
	}
	
	getValue(byref labName,sample="BLOOD"){
		result:=[]
		StringUpper,sample,sample
		
		for k,v in this.lab {
			if (!isobject(v) || v.sample!=sample)
				continue
			if (isobject(labName))
				for m,n in labName
					if(isobject(v[n]))
						result[v.reportDate]:=v[n]
			else if (isobject(v[labName]))
				result[v.reportDate]:=v[labName]
			
		}
		return result
	}
	
}

StrPutVar(string, ByRef var, encoding) {
    ; Ensure capacity.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut returns char count, but VarSetCapacity needs bytes.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; Copy or convert the string.
    return StrPut(string, &var, encoding),VarSetCapacity(var,-1)
}

patientBasicInfoTree(chartNo,sid,function="",personId=""){
	if !function
		return
	if !checkSid(sid)
		return
	
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	
	if !personId
		personId:=patientBasicInfo(chartNo,sid).personId
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/SimpleShowiframePage.aspx?SESSION=" sid "&PersonID=" personId "&Seed=" a_now
	header:="Accept: */*`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)`nAccept-Encoding: gzip, deflate`nConnection: Close`nHost: ihisaw.ntuh.gov.tw`nPragma: no-cache"
	httprequest(url,page:="",header,"charset: utf-8`n+NO_COOKIES")
	RegExMatch(page,"i)http:[^']+?SimpleInfoShowUsingPlaceHolder[^']+?Func=" function "&[^']+?Seed=\d+",match)
	return (match?RegExReplace(match,"&amp;","&"):"")


}

patientBasicInfoWeb(chartNo,sid,personId="",medicalPrivacy="C5"){
	if !checkSid(sid)
		return
	
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	
	if !personId
		personId:=patientBasicInfo(chartNo,sid).personId
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/SimpleShowiframePage.aspx?SESSION=" sid "&PersonID=" personId "&Seed=" a_now
	header2:=header:="Accept: */*`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)`nAccept-Encoding: gzip, deflate`nConnection: Close`nHost: ihisaw.ntuh.gov.tw`nPragma: no-cache"
	httprequest(url,page:="",header,"charset: utf-8`n+NO_COOKIES")
	
	if(instr(page,"確認非醫療業務執行期間開檔申請")){
		RegExMatch(page,"<form[^>]+action=""[^>]+ReturnPath=(\w+)[^>]+>",match)
		url2:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/MedicalManagementAuthor.aspx?SESSION=" sid "&PersonID=" personId "&ReturnPath=" match1
		header2:="Accept: */*`nAccept-Language: zh-tw`nReferer: " url2 "`nx-microsoftajax: Delta=true`nContent-Type: application/x-www-form-urlencoded; charset=utf-8`nCache-Control: no-cache`nAccept-Encoding: gzip, deflate`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)`nHost: ihisaw.ntuh.gov.tw`nConnection: Close`nPragma: no-cache"
		post2:="ScriptManager1=UpdatePanelContent%7CConfirmButton&__EVENTTARGET=&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=" encodeurl(get(page,"__VIEWSTATE")) "&__EVENTVALIDATION=" encodeurl(get(page,"__EVENTVALIDATION")) "&SelectCodeValue=" medicalPrivacy "&RBList=" medicalPrivacy "&OtherReason=&__ASYNCPOST=true&ConfirmButton=%E7%A2%BA%E8%AA%8D%E7%94%B3%E8%AB%8B%E9%96%8B%E6%AA%94"
		httprequest(url2,post2,header2,"charset: utf-8`n+NO_COOKIES")
		;~ regexmatch(post2,"pageRedirect\|\|([^\|]+)\|",match)
		;~ httprequest(match1,page:="",header2,"charset: utf-8`n+NO_COOKIES")
		
		url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/SimpleShowiframePage.aspx?SESSION=" sid "&PersonID=" personId "&Seed=" a_now
		header2:=header:="Accept: */*`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)`nAccept-Encoding: gzip, deflate`nConnection: Close`nHost: ihisaw.ntuh.gov.tw`nPragma: no-cache"
		httprequest(url,page:="",header,"charset: utf-8`n+NO_COOKIES")

		
		
	}


	return page
}

patientBasicInfoWebTree(html,recursing="",returnClass=1){
	;~ if !IsObject(html) {
		;~ dom:=ComObjCreate("HtmlFile")
		;~ ,dom.write(html)
		;~ ,page:=dom
	;~ }else{
		;~ page:=html.clone()
	;~ }
	
	if(!recursing){
		static dom:=ComObjCreate("HtmlFile")
		dom.write(html)
		,page:=dom.getElementById("TreeViewItemn0Nodes")
	}else{
		page:=dom.getElementById(recursing)
	}
	
	arr:=[]
	Loop % (children:=page.childNodes).length {
		v:=children[A_Index-1]
		if(v.tagName="table"){
			node:=[],a:=v.getElementsByTagName("a"),a:=a[a.length-1]
			node.innerText:=Trim(a.innerText)
			node.id:=a.id
			node.href:="" a.href
			if(v.nextSibling.tagName!="div"){
				arr.Insert(node)
			}
		}else if(v.tagName="div"){
			
			node.childNodes:=patientBasicInfoWebTree(html, v.id)
			arr.Insert(node)
		}
	}
	if (returnClass && !recursing){
		return new patientBasicInfoWebTree(arr)
	}else
		return arr
	
}

class patientBasicInfoWebTree {
	__New(ByRef arr){
		this.arr:=arr
	}
	
	getNodeByNames(params*){
		thisNode:=this.arr
		for k,v in params {
			found:=0
			for m,n in thisNode {
				if (n.innerText=v){
					thisNode:=n.childNodes, found:=1
					break
				}
			}
			if(!found)
				return []
		}
		
		return new patientBasicInfoWebTree(thisNode)
	}
}

patientBriefMedicalRecord(chartNo,sid,personId=""){
	if !checkSid(sid)
		return
	
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	
	if !personId
		personId:=patientBasicInfo(chartNo,sid).personId
	
	url:=patientBasicInfoTree(chartNo,sid,"PatientBriefMedicalRecord",personId)
	httprequest(url,page:="",header:="","charset: utf-8`n+NO_COOKIES")
	arr:=[]
	RegExMatch(page,"體重:([.\d]+)",match)
	arr["BW"]:="" (match1?"" match1:"")
	RegExMatch(page,"身高:([.\d]+)",match)
	arr["BH"]:="" (match1?"" match1:"")
	
	return arr
	
	
}

patientBWBH(chartNo,sid,personId=""){
	if !checkSid(sid)
		return
	
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	
	if !personId
		personId:=patientBasicInfo(chartNo,sid).personId
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/PatientBasicExaminationInfo.aspx?SESSION=" sid "&PersonID=" personId "&Hosp=T0&PatClass=E"
	httprequest(url,page:="",header:="","charset: utf-8`n+NO_COOKIES")
	arr:=[]
	arr["BH"]:="" regexreplace(getTextById(page,"TextBoxInputArea_ctl00_Label1"),"i)上次記錄 : ([\d.]+|nil|NA)","$1")
	arr["BW"]:="" regexreplace(getTextById(page,"TextBoxInputArea_ctl01_Label1"),"i)上次記錄 : ([\d.]+|nil|NA)","$1")
	arr["UpdateDate"]:="" RegExReplace(getTextById(page,"ErrorMessage"),"is).+?([\d\/]+).*?","$1")
	return arr
}

patientLabHistory(chartNo,sid,personId=""){
	if !checkSid(sid)
		return
	
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	
	if !personId
		personId:=patientBasicInfo(chartNo,sid).personId
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/SimpleInfoShowUsingPlaceHolder.aspx?SESSION=" sid "&PersonID=" personId "&Func=LabResultHistory&Seed=" a_now
	httprequest(url,page:="",header:="","charset: utf-8`n+NO_COOKIES")
	
	return o:=new patientLabHistory(page)
	
	
}

fill0(str,n=2,fill="0"){
	while strlen(str)<n
		str:=fill str
	
	return str
}

parseRisPatientMainPage(html){
	arr:=[]
	
	html:=RegExReplace(html,"is)<input type=""hidden"" name=""__VIEWSTATE"" id=""__VIEWSTATE"" value="".+?"" \/>")
	
	dom:=comobjcreate("HtmlFile")
	dom.write(html)
	
	arr["OrderName"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_OrderNameLabel").innerText
	arr["CreatePersonName"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_lblCreateName").innerText
	arr["AccountNo"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_lblAccountNo").innerText
	arr["SheetNo"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_RequestSheetLabel").innerText
	arr["OrderStatus"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_OrderStatusLabel").innerText
	arr["ConfirmPersonName"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_LabelConfirmEmp").innerText
	arr["OrderTime"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_lblCreateDateTime").title
	arr["RegisterTime"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_RegisterTimeLabel").title
	arr["LoginTime"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_LoginDateTimeLabel").title
	arr["NotPerformReason"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_NotPerformReasonList").value
	arr["SpecialInstruction"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_SpecialInstructionLabel").innerText
	arr["ExecuteDr"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_ExecuteDrListLabel").innerText
	arr["CCC"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_lblExecuteCCC").innerText
	arr["ReportDr"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_ReportDrListLabel").innerText
	arr["Technician"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_TechnicianList").innerText
	arr["Machine"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_ExecuteMachineList").innerText
	arr["ExecuteRecord"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_ExcuteRecordInfo").innerText
	arr["ReportTime"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_txbReportDateTime").value
	arr["ShouldPayAmount"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_lblShouldPayAmount").innerText
	arr["PaidAmount"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_lblPaidAmount").innerText
	arr["NeedToPayAmount"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_lblNeedToPayAmount").innerText
	arr["LastPaidDate"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_lblLastPaidDate").innerText
	arr["LastPaidDate"]:=$(html,"NTUHWeb1_OrderScheduleInfo1_lblLastPaidDate").innerText
	
	loop % (tr:=$(html,"NTUHWeb1_AppendCreateOrders1_grvTreOrders").rows).length {
		arr["CreateOrders",a_index,"class"]:=(td:=tr[a_index+1].cells)[2].innerText
		arr["CreateOrders",a_index,"code"]:=td[3].innerText
		arr["CreateOrders",a_index,"name"]:=td[4].innerText
		arr["CreateOrders",a_index,"amount"]:=td[5].innerText
		arr["CreateOrders",a_index,"ifEmergent"]:=td[6].innerText
		arr["CreateOrders",a_index,"accountType"]:=td[7].innerText
		arr["CreateOrders",a_index,"executeTime"]:=td[8].innerText
	}
	
	return arr
	
	
}

getAccountIdFromAccNo(sid, AccNo){
	global __VIEWSTATE,__EVENTVALIDATION,portalAspId
	
	
	url:="http://hisaw.ntuh.gov.tw/WebApplication/Radiology/RISPatientRegistration.aspx?SESSION=" sid
	
	if (__VIEWSTATE="" || __EVENTVALIDATION="" || portalAspId=""){
		httprequest(url, post:="",header:="", "charset: utf-8")
		RegExMatch(header,"i)(?<=ASP.NET_SessionId=)\w+",portalAspId)
		renewPortalState(post)
	}
	
	
	StartDate:=substr(a_now,1,4) "/" substr(a_now,5,2) "/" substr(a_now,7,2)

	header=
	(LTrim
	Accept: */*
	Accept-Language: zh-tw
	Referer: %url%
	Host: hisaw.ntuh.gov.tw
	Cookie: 3=1; CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=&IsShowChartNo=Y&IsShowBarCode=N; ASP.NET_SessionId=%portalAspId%; JSESSIONID=null
	Connection: Keep-Alive
	x-microsoftajax: Delta=true
	Content-Type: application/x-www-form-urlencoded; charset=utf-8
	Cache-Control: no-cache
	Accept-Encoding: gzip, deflate
	User-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322; .NET4.0C; .NET4.0E)
	Pragma: no-cache
	)
	post:="NTUHWeb1%24ScriptManager1=NTUHWeb1%24uPnlQuery%7CNTUHWeb1%24btnQueryByPatient&scrollLeft=&scrollTop=&__LASTFOCUS=&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=" encodeurl(__VIEWSTATE) "&__VIEWSTATEGENERATOR=377EE134&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&NTUHWeb1%24ddlOrderType=X&NTUHWeb1%24ddlUnitList=BDE1&NTUHWeb1%24ddlStatisticGroupCode=MRI&NTUHWeb1%24ddlShiftType=&NTUHWeb1%24ddlPatClass=&NTUHWeb1%24txbQueryStartDate=" encodeurl(StartDate) "&NTUHWeb1%24ddlQueryDays=1&NTUHWeb1%24txbRequestSheetNo=" AccNo "&NTUHWeb1%24txbPersonID=&NTUHWeb1%24txbAccountNo=&NTUHWeb1%24txbChartNo=&NTUHWeb1%24ddlStatisticGroupCodeFilter=&NTUHWeb1%24cbxIsShowChartNo=on&__ASYNCPOST=true&NTUHWeb1%24btnQueryByPatient=%E7%97%85%E4%BA%BA%E6%9F%A5%E8%A9%A2"
	;~ clipboard:=post
	httprequest(url, post, header1:=header, "charset: utf-8")
	if !instr(post,AccNo)
		return -1
	
	
	renewPortalState(post)
	post:="NTUHWeb1%24ScriptManager1=NTUHWeb1%24uPnlOrders%7CNTUHWeb1%24grvPatientOrderList%24ctl02%24lbnSelect&scrollLeft=&scrollTop=&NTUHWeb1%24ddlOrderType=X&NTUHWeb1%24ddlUnitList=BDE1&NTUHWeb1%24ddlStatisticGroupCode=MRI&NTUHWeb1%24ddlShiftType=&NTUHWeb1%24ddlPatClass=&NTUHWeb1%24txbQueryStartDate=" encodeurl(StartDate) "&NTUHWeb1%24ddlQueryDays=1&NTUHWeb1%24txbRequestSheetNo=" AccNo "&NTUHWeb1%24txbPersonID=&NTUHWeb1%24txbAccountNo=&NTUHWeb1%24txbChartNo=&NTUHWeb1%24ddlStatisticGroupCodeFilter=&NTUHWeb1%24cbxIsShowChartNo=on&NTUHWeb1%24txbExecuteDate=" encodeurl(StartDate) " " substr(a_now,9,2) "%3A" substr(a_now,11,2) "&NTUHWeb1%24ddlNotPerformReasonList=&NTUHWeb1%24ddlFunctionType=&NTUHWeb1%24ddlFunctionType2=&__LASTFOCUS=&__EVENTTARGET=NTUHWeb1%24grvPatientOrderList%24ctl02%24lbnSelect&__EVENTARGUMENT=&__VIEWSTATE=" encodeurl(__VIEWSTATE) "&__EVENTVALIDATION="  encodeurl(__EVENTVALIDATION) "&__AjaxControlToolkitCalendarCssLoaded=&__ASYNCPOST=true&"
	httprequest(url,post,header1:=header,"charset: utf-8")
	
	if !instr(post,"pageRedirect")
		return -1
	
	url:="http://hisaw.ntuh.gov.tw/WebApplication/Radiology/PatientMainPage.aspx?SESSION=" sid
	
	httprequest(url,post:="",header,"charset: utf-8")
	
	if !instr(post,AccNo)
		return -1
	
	dom:=comobjcreate("HtmlFile")
	dom.write(post)
	
	return dom.getElementById("NTUHWeb1_OrderScheduleInfo1_lblAccountNo").innerText
}

renewPortalState(post){
	global __VIEWSTATE,__EVENTVALIDATION
	if !VIEWSTATE:=get(post,"__VIEWSTATE")
		regexmatch(post,"i)(?<=__VIEWSTATE\|)[^\|]+",VIEWSTATE)
	if (VIEWSTATE!="")
		__VIEWSTATE:=VIEWSTATE
		
	if !EVENTVALIDATION:=get(post,"__EVENTVALIDATION")
		regexmatch(post,"i)(?<=__EVENTVALIDATION\|)[^\|]+",EVENTVALIDATION)
	if (EVENTVALIDATION!="")
		__EVENTVALIDATION:=EVENTVALIDATION
	
}

getRisPatientMainPage(sid,which="",ChartNo="",UnitList="X",StartDate="",ShiftType="",PatClass="",QueryDays=1,SheetNo="",PersonID="",AccountNo=""){
	global __VIEWSTATE,__EVENTVALIDATION,portalAspId
	if portalAspId=
		portalAspId=3aq1hx55dvooyqyzlp0nod22
	
	if which=
		which:="02"
	else
		which:=fill0(which+1)
	
	if (StartDate="")
		StartDate:=substr(a_now,1,4) "/" substr(a_now,5,2) "/" substr(a_now,7,2)

	
	
	url:="http://hisaw.ntuh.gov.tw/WebApplication/Radiology/RISPatientRegistration.aspx?SESSION=" sid
	
	if (__VIEWSTATE="" || __EVENTVALIDATION=""){
		header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/xaml+xml, application/vnd.ms-xpsdocument, application/x-ms-xbap, application/x-ms-application, */*`nReferer: http://hisaw.ntuh.gov.tw/WebApplication/Radiology/Default.aspx?SESSION=" sid "`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nAccept-Encoding: gzip, deflate`nHost: hisaw.ntuh.gov.tw`nConnection: Keep-Alive`nCookie: 3=1; ASP.NET_SessionId=" portalAspId "; JSESSIONID=null; CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=&IsShowChartNo=Y"

		httprequest(url,post:="",header,"charset: utf-8")
		
		__VIEWSTATE:=get(post,"__VIEWSTATE")
		__EVENTVALIDATION:=get(post,"__EVENTVALIDATION")
	}

	header:="Accept: */*`nAccept-Language: zh-tw`nReferer: http://hisaw.ntuh.gov.tw/WebApplication/Radiology/RISPatientRegistration.aspx?SESSION=" sid "`nx-microsoftajax: Delta=true`nContent-Type: application/x-www-form-urlencoded; charset=utf-8`nCache-Control: no-cache`nAccept-Encoding: gzip, deflate`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nHost: hisaw.ntuh.gov.tw`nConnection: Keep-Alive`nPragma: no-cache`nCookie: 3=1; ASP.NET_SessionId=" portalAspId "; JSESSIONID=null; CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=&IsShowChartNo=Y"
	
	post:="NTUHWeb1%24ScriptManager1=NTUHWeb1%24uPnlOrders%7CNTUHWeb1%24grvPatientOrderList%24ctl" which "%24lbnSelect&scrollLeft=0&scrollTop=99&__LASTFOCUS=&__EVENTTARGET=NTUHWeb1%24grvPatientOrderList%24ctl" which "%24lbnSelect&__EVENTARGUMENT=&__VIEWSTATE=" encodeurl(__VIEWSTATE) "&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&NTUHWeb1%24ddlOrderType=X&NTUHWeb1%24ddlUnitList=CHCT&NTUHWeb1%24ddlStatisticGroupCode=MRI&NTUHWeb1%24ddlShiftType=&NTUHWeb1%24ddlPatClass=&NTUHWeb1%24txbQueryStartDate=" encodeurl(StartDate) "&NTUHWeb1%24ddlQueryDays=1&NTUHWeb1%24txbRequestSheetNo=&NTUHWeb1%24txbPersonID=&NTUHWeb1%24txbAccountNo=&NTUHWeb1%24txbChartNo=&NTUHWeb1%24ddlStatisticGroupCodeFilter=&NTUHWeb1%24cbxIsShowChartNo=on&NTUHWeb1%24txbExecuteDate=" encodeurl(StartDate) " " substr(a_now,9,2) "%3A" substr(a_now,11,2) "&NTUHWeb1%24ddlNotPerformReasonList=&NTUHWeb1%24ddlFunctionType=&NTUHWeb1%24grvPatientOrderList%24ctl" which "%24cbxSelect=on&NTUHWeb1%24ddlFunctionType2=&__ASYNCPOST=true&"
	
	httprequest(url,post,header,"charset: utf-8")
	
	
	
	url:="http://hisaw.ntuh.gov.tw/WebApplication/Radiology/PatientMainPage.aspx?SESSION=" sid
	
	header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/xaml+xml, application/vnd.ms-xpsdocument, application/x-ms-xbap, application/x-ms-application, */*`nReferer: http://hisaw.ntuh.gov.tw/WebApplication/Radiology/RISPatientRegistration.aspx?SESSION=" sid "`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nAccept-Encoding: gzip, deflate`nHost: hisaw.ntuh.gov.tw`nConnection: Keep-Alive`nCookie: 3=1; ASP.NET_SessionId=" portalAspId "; JSESSIONID=null; CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=&IsShowChartNo=Y"
	
	httprequest(url,post:="",header,"charset: utf-8")
	
	return post
	
}

class parseRisSchedule{

	__New(html){
		arr:=[]
		dom:=comobjcreate("HtmlFile")
		dom.write(html)
		
		table:=$(dom,"NTUHWeb1_grvPatientOrderList")
		loop % table.rows.length-1 {
			row:=table.rows[a_index]
			exam:=[]
			exam.Date:=trim(row.cells[2].firstChild.title)
			exam.Shift:=trim(row.cells[3].innerText)
			exam.ExamOrder:=trim(row.cells[4].innerText)
			exam.ChartNo:=trim(row.cells[5].innerText)
			exam.Name:=trim(row.cells[6].innerText)
			exam.IdBirth:=trim(row.cells[6].firstChild.title)
			exam.Gender:=trim(row.cells[7].innerText)
			exam.Dept:=trim(row.cells[8].innerText)
			exam.Dept1:=trim(row.cells[8].firstChild.title)
			exam.BillType:=trim(row.cells[9].innerText)
			exam.OrderName:=trim(row.cells[10].innerText)
			exam.SheetNo:=trim(row.cells[10].firstChild.title)
			exam.Status:=trim(row.cells[11].innerText)
			exam.AccountStatus:=trim(row.cells[12].innerText)
			exam.ArriveTime:=trim(row.cells[13].innerText)
			exam.Emergent:=trim(row.cells[14].innerText)
			exam.Portable:=trim(row.cells[15].innerText)
			arr.insert(exam.clone())
		}
			
		this.schedule:=arr
	}
	
	filter(byref exam,filterName,filterValue,fitType=0){
		if instr(exam.Status,"刪除")
			return 0
		if(fitType=1)
			return exam[filterName]=trim(filterValue)?1:0
		else if(fitType=0 || fitType="")
			return instr(exam[filterName],trim(filterValue))?1:0
		else if(fitType=2)
			return regexmatch(exam[filterName],trim(filterValue))?1:0
	}
	
	query(param){
		arr:=[]
		
		for k,v in this.schedule {
			match:=true
			for x,y in param
				if !(match:=match && this.filter(v,y.1,y.2,y.3))
					break
			if match
				arr.insert(v.clone())
		}
		return arr
	}
	
}

getRisSchedule(sid,ChartNo="",UnitList="CTE1",StartDate="",ShiftType="",PatClass="",QueryDays=1,SheetNo="",PersonID="",AccountNo=""){
	global __VIEWSTATE,__EVENTVALIDATION,portalAspId
	
	;~ if portalAspId=
		;~ portalAspId=3aq1hx55dvooyqyzlp0nod22
		
	loop % 7-strlen(chartNo)
		chartNo:="0" chartNo
	
	url:="http://hisaw.ntuh.gov.tw/WebApplication/Radiology/RISPatientRegistration.aspx?SESSION=" sid
	
	
	if (__VIEWSTATE="" || __EVENTVALIDATION="" || !portalAspId){
		;~ header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/xaml+xml, application/vnd.ms-xpsdocument, application/x-ms-xbap, application/x-ms-application, */*`nReferer: http://hisaw.ntuh.gov.tw/WebApplication/Radiology/Default.aspx?SESSION=" sid "`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nAccept-Encoding: gzip, deflate`nHost: hisaw.ntuh.gov.tw`nConnection: Keep-Alive`nCookie: 3=1; ASP.NET_SessionId=" portalAspId "; JSESSIONID=null; CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=&IsShowChartNo=Y"

		httprequest(url,post:="",header,"charset: utf-8")
		portalAspId:=RegExReplace(header,"s).+ASP\.NET_SessionId=([^;]+);.+","$1")
		__VIEWSTATE:=get(post,"__VIEWSTATE")
		__EVENTVALIDATION:=get(post,"__EVENTVALIDATION")
	}
	
	
	
	header:="Accept: */*`nAccept-Language: zh-tw`nReferer: http://hisaw.ntuh.gov.tw/WebApplication/Radiology/RISPatientRegistration.aspx?SESSION=" sid "`nx-microsoftajax: Delta=true`nContent-Type: application/x-www-form-urlencoded; charset=utf-8`nCache-Control: no-cache`nAccept-Encoding: gzip, deflate`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nHost: hisaw.ntuh.gov.tw`nConnection: Keep-Alive`nPragma: no-cache`nCookie: 3=1; ASP.NET_SessionId=" portalAspId "; JSESSIONID=null; CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=&IsShowChartNo=Y"
	
	if (StartDate="")
		formattime,StartDate,% a_now,yyyy/MM/dd
		;~ StartDate:=substr(a_now,1,4) "/" substr(a_now,5,2) "/" substr(a_now,7,2)
	
	queryType:="NTUHWeb1$uPnlQuery"
	
	if chartNo!=
		queryType.="|NTUHWeb1$btnQueryByPatient"
	if UnitList!=X
		queryType.="|NTUHWeb1$ddlUnitList"
	
	formattime,now,% a_now,yyyy/MM/dd hh:mm
	
	;~ post:="NTUHWeb1%24ScriptManager1=" queryType "&scrollLeft=&scrollTop=&__LASTFOCUS=&__EVENTTARGET=&__EVENTARGUMENT=&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&NTUHWeb1%24ddlOrderType=X&NTUHWeb1%24ddlUnitList=" encodeurl(UnitList) "&NTUHWeb1%24ddlStatisticGroupCode=MRI&NTUHWeb1%24ddlShiftType=" encodeurl(ShiftType) "&NTUHWeb1%24ddlPatClass=" encodeurl(PatClass) "&NTUHWeb1%24txbQueryStartDate=" encodeurl(StartDate) "&NTUHWeb1%24ddlQueryDays=" encodeurl(QueryDays) "&NTUHWeb1%24txbRequestSheetNo=" encodeurl(SheetNo) "&NTUHWeb1%24txbPersonID=" encodeurl(PersonID) "&NTUHWeb1%24txbAccountNo=" encodeurl(AccountNo) "&NTUHWeb1%24txbChartNo=" encodeurl(ChartNo) "&NTUHWeb1%24ddlStatisticGroupCodeFilter=&NTUHWeb1%24cbxIsShowChartNo=on&__ASYNCPOST=true&NTUHWeb1%24cbxIsShowChartNo=on&NTUHWeb1%24ddlFunctionType=&NTUHWeb1%24ddlFunctionType2=&NTUHWeb1%24ddlNotPerformReasonList=&NTUHWeb1%24txbExecuteDate=" encodeurl(now) "&__AjaxControlToolkitCalendarCssLoaded="
	post:="NTUHWeb1%24ScriptManager1=" encodeurl(queryType) "&scrollLeft=&scrollTop=&__LASTFOCUS=&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=" encodeurl(__VIEWSTATE) "&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&NTUHWeb1%24ddlOrderType=X&NTUHWeb1%24ddlUnitList=" encodeurl(UnitList) "&NTUHWeb1%24ddlStatisticGroupCode=MRI&NTUHWeb1%24ddlShiftType=" encodeurl(ShiftType) "&NTUHWeb1%24ddlPatClass=" encodeurl(PatClass) "&NTUHWeb1%24txbQueryStartDate=" encodeurl(StartDate) "&NTUHWeb1%24ddlQueryDays=" encodeurl(QueryDays) "&NTUHWeb1%24txbRequestSheetNo=" encodeurl(SheetNo) "&NTUHWeb1%24txbPersonID=" encodeurl(PersonID) "&NTUHWeb1%24txbAccountNo=" encodeurl(AccountNo) "&NTUHWeb1%24txbChartNo=" encodeurl(ChartNo) "&NTUHWeb1%24ddlStatisticGroupCodeFilter=&NTUHWeb1%24cbxIsShowChartNo=on&__ASYNCPOST=true"

	if chartNo!=
		post.="&NTUHWeb1%24btnQueryByPatient=%E6%8E%92%E7%A8%8B%E6%9F%A5%E8%A9%A2"

	httprequest(url,post,header,"charset: utf-8")
	return post
}

class patientLabHistory {
	__New(html){
		arr:=[]
		,ComObjError(false)
		,dom:=ComObjCreate("HtmlFile")
		,dom.write(html)
		
		loop % (tr:=dom.getElementById("TableLabHistoryNote").rows).length {
			if (td:=tr[a_index-1].cells).length <=1
				continue
			labName:=td[1].innerText
			
			ind=0
			loop % (i:=td[2].cells).length {
				if(ind:=!ind){
					RegExMatch(i[a_index-1].innerText,"is)(.+)\s([^\s]+?)$",match)
					,labValue:=match1
					,labUnit:=match2
				}else{
					labDate:=i[a_index-1].innerText
					if !isobject(arr["" labName,"" labDate]) 
						arr["" labName,"" labDate]:=[]
					arr["" labName,"" labDate].insert(array("" labValue,"" labUnit))
				}
			}	
			
		}
		
		
		this.lab:=arr
	}
	
	getValue(labName){
		result:=[]
		if(!isobject(this.lab[labName]))
			return result
		
		for k,v in this.lab[labName] 
			result[k]:=v
		return result
	}
	
}

getPathoAspId(sid){
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/MedicalReportQuery/PathExam.aspx?SESSION=" sid
	
	header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */*`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; GTB7.4; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nAccept-Encoding: gzip, deflate`nConnection: Keep-Alive`nHost: ihisaw.ntuh.gov.tw`nCookie: NTUHPage_MenuSettingCookie=%u5831%u544a%u7d22%u5f15%u7cfb%u7d71=Y&%u5831%u544a%u67e5%u8a62=Y"
	
		
	httprequest(url,post:="",header)
	
	RegExMatch(header,"ASP.NET_SessionId=(\w{24})",match)
	
	return match1
}

getPatho(sid,chartNo){
	global pathoportalAspId
	
	if !pathoportalAspId
		pathoportalAspId:=getPathoAspId(sid)
		
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/MedicalReportQuery/PathExam.aspx"
	
	header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */*`nReferer: " url "?`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; GTB7.4; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: ihisaw.ntuh.gov.tw`nConnection: Close`nPragma: no-cache`nCookie: NTUHPage_MenuSettingCookie=%u5831%u544a%u7d22%u5f15%u7cfb%u7d71=Y&%u5831%u544a%u67e5%u8a62=Y; ASP.NET_SessionId=" pathoportalAspId ";"
	
	httprequest(url "?SESSION=" sid,html:="",h:=header)
	
	
	post:="__EVENTTARGET=&__EVENTARGUMENT=&ctl07_ExpandState=eununnunnnnununnunnunnnnnununnunnn&ctl07_SelectedNode=&ctl07_PopulateLog=&__VIEWSTATE=" encodeurl(get(html,"__VIEWSTATE")) "&__EVENTVALIDATION=" encodeurl(get(html,"__EVENTVALIDATION")) "&QueryByChartNo1%24txbPatChar=" chartNo "&QueryByChartNo1%24btnPerIDPatChar=%E6%9F%A5%E8%A9%A2"
	
	httprequest(url,post,header,"charset: utf-8")
	
	dom:=ComObjCreate("HtmlFile")
	dom.write(post)
	arr:=[]
	
	loop % (rows:=dom.getElementById("PathExam_Control1_GridViewPathExamno").rows).length
	{
		if a_index=1
			continue
		cells:=rows[i:=a_index-1].cells
		arr[i,"Name"]:=trim(cells[0].innerText)
		arr[i,"PathoNo"]:=trim(cells[1].innerText)
		arr[i,"Department"]:=trim(cells[2].innerText)
		arr[i,"Ward"]:=trim(cells[3].innerText)
		arr[i,"Specimen"]:=trim(cells[4].innerText)
		arr[i,"getDate"]:="" trim(convertTaiwanDateToWestern(cells[5].innerText))
		arr[i,"reportDate"]:="" trim(convertTaiwanDateToWestern(cells[6].innerText))
		arr[i,"linkId"]:=trim(cells[7].firstChild.id)
		
	}
	
	return arr
	
}

getPatho2(chartNo){
	url:="http://converws.ntuh.gov.tw/WebApplication/PathologyReportWS/PathologyReportWS.asmx"

	header:="SOAPAction: ""http://PathologyReportWS.ntuh.gov.tw/GetPathReportListByChartNo""`nHost: converws.ntuh.gov.tw`nContent-Type: text/xml; charset=utf-8"

	post=
	(
	<?xml version="1.0" encoding="utf-8"?>
	<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
	  <soap:Body>
		<GetPathReportListByChartNo xmlns="http://PathologyReportWS.ntuh.gov.tw/">
		  <chartNo>%chartNo%</chartNo>
		</GetPathReportListByChartNo>
	  </soap:Body>
	</soap:Envelope>
	)

	httprequest(url,post,header,"charset: utf-8")
	
	i:=0,arr:=[]
	while (i:=regexmatch(post,"is)<Table.+?<PATHCODE>(.+?)</PATHCODE><CHARTNO>" chartNo "</CHARTNO><SPECIMENGETDATE>(.+?)</SPECIMENGETDATE><REPORTDATETIME>(.+?)</REPORTDATETIME><ORGSOURCE>(.+?)</ORGSOURCE><CHECKREPORT>(.+?)</CHECKREPORT></Table>",match,i+1)) {
		arr[a_index,"" "pathCode"]:="" match1
		arr[a_index,"" "getDate"]:="" dateTimeParse1(match2).str
		arr[a_index,"" "reportDate"]:="" dateTimeParse1(match3).str
		arr[a_index,"" "resource"]:="" match4
		arr[a_index,"" "report"]:="" match5
	}
	return arr
}

getLabValue(byref Lab2Arr,ItemName,SpecimenName="BLOOD"){
	arr:=[],sort:=[],newArr:=[],foundCount:=0

		if(isobject(ItemName)){
			for k,v in Lab2Arr
				for m,n in ItemName
					if (v.ItemName=n && v.SpecimenName=SpecimenName) {
						arr.insert(v.clone())
						
						if ((time:=regexreplace(v.LogDateTime,"\D"))&&floor(substr(time,1,1))>1){
						}else
							time:=regexreplace(v.ReleaseDateTime,"\D")
						
						sort["" time (++foundCount)]:=(foundCount)
						
					}
						
		}else {
			for k,v in Lab2Arr
				if (v.ItemName=ItemName && v.SpecimenName=SpecimenName) {
					arr.insert(v.clone())
					if ((time:=regexreplace(v.LogDateTime,"\D"))&&floor(substr(time,1,1))>1){
					}else
						time:=regexreplace(v.ReleaseDateTime,"\D")
					
					sort["" time (++foundCount)]:=(foundCount)
					
				
				}
		}
	
	for k,v in sort
		newArr[foundCount+1-a_index]:=arr[v].clone()
	
	
	return newArr
}

getLab2(chartNo,sid="",startDays=14,endDays=0,startTime="",endTime=""){
	global ptInfo,birthday,userId
	url:="http://converws.ntuh.gov.tw/WebApplication/MedicalReportWS/MedicalReportSelectedLabItemReportWS.asmx"

	header:="SOAPAction: ""http://tempuri.org/QueryLabReportWithNormalRange""`nHost: converws.ntuh.gov.tw`nContent-Type: text/xml; charset=utf-8"
	
	while(strlen(chartNo)<7)
		chartNo:="0" chartNo
	
	;~ if !ptInfo
		;~ ptInfo:=patientBasicInfo(chartNo,sid)
	;~ if !birthDay
		;~ birthDay:=ptInfo.birthYear "-" ptInfo.birthMonth "-" ptInfo.birthDay "T00:00:00"
	;~ if !userId
		;~ userId:=getUserId(sid)
	
	if (startTime=""){
		date:=a_now
		date+=-%startDays%,d
		FormatTime,startTime,% date,yyyy-MM-ddTHH:mm:ss
	}
	
	if (endTime=""){
		date:=a_now
		date+=-%endDays%,d
		FormatTime,endTime,% date,yyyy-MM-ddTHH:mm:ss
	}
	
	post=
	(
	<?xml version="1.0" encoding="utf-8"?>
	<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
	  <soap:Body>
		<QueryLabReportWithNormalRange xmlns="http://tempuri.org/">
		  <chartNo>%chartNo%</chartNo>
		  <birthday>1900-01-01T00:00:00</birthday>
		  <loginEmpNo>007382</loginEmpNo>
		  <startTime>%startTime%</startTime>
		  <endTime>%endTime%</endTime>
		</QueryLabReportWithNormalRange>
	  </soap:Body>
	</soap:Envelope>
	)

	httprequest(url,post,header,"charset: utf-8")
	;~ clipboard:=post
	
	
	itemName:=["SybaseAcc","PortalAcc","DeptCode","Value","itemCode","LoginNo","ItemName","UnitName","ItemNameShort","OrderCode","ACMGroupName","OrderSeqNo","SpecimenName","SpecimenCode","LogDate","LogDateTime","ReleaseDateTime","Description","ViewCondition","OperatorDefineRange","RangeResult","MaxValue","MinValue","PatientClassCode"]
	
	i:=0,arr:=[]
	while i:=RegExMatch(post,"is)<LabItem>(.+?)</LabItem>",m,i+1) {
		j:=a_index
		for k,v in itemName {
			RegExMatch(m1,"<" v ">(.+?)</" v ">",match)
			StringReplace,match1,match1,&gt;,>
			StringReplace,match1,match1,&lt;,<
			StringReplace,match1,match1,&nbsp;,%a_space%
			StringReplace,match1,match1,&quot;,"
			StringReplace,match1,match1,&amp;,&
			arr[j,v]:=match1
		}
	}
	
	
	return arr
	
	/*
	
	*/
	
	
	
	/* response-------------------------------------------
	<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <QueryLabReportWithNormalRangeResponse xmlns="http://tempurf.org/">
      <QueryLabReportWithNormalRangeResult>
        <_LabItemList>
          <LabItem>
            <ChartNo>string</ChartNo>
            <SybaseAcc>string</SybaseAcc>
            <PortalAcc>string</PortalAcc>
            <DeptCode>string</DeptCode>
            <Value>string</Value>
            <itemCode>string</itemCode>
            <LoginNo>string</LoginNo>
            <ItemName>string</ItemName>
            <UnitName>string</UnitName>
            <ItemNameShort>string</ItemNameShort>
            <OrderCode>string</OrderCode>
            <ACMGroupName>string</ACMGroupName>
            <OrderSeqNo>string</OrderSeqNo>
            <SpecimenName>string</SpecimenName>
            <SpecimenCode>string</SpecimenCode>
            <LogDate>string</LogDate>
            <LogDateTime>dateTime</LogDateTime>
            <ReleaseDateTime>dateTime</ReleaseDateTime>
            <Description>string</Description>
            <ViewCondition>string</ViewCondition>
            <OperatorDefineRange>string</OperatorDefineRange>
            <RangeResult>Normal or Over or Below or Unknown</RangeResult>
            <MaxValue>string</MaxValue>
            <MinValue>string</MinValue>
            <PatientClassCode>string</PatientClassCode>
          </LabItem>
          <LabItem>
            <ChartNo>string</ChartNo>
            <SybaseAcc>string</SybaseAcc>
            <PortalAcc>string</PortalAcc>
            <DeptCode>string</DeptCode>
            <Value>string</Value>
            <itemCode>string</itemCode>
            <LoginNo>string</LoginNo>
            <ItemName>string</ItemName>
            <UnitName>string</UnitName>
            <ItemNameShort>string</ItemNameShort>
            <OrderCode>string</OrderCode>
            <ACMGroupName>string</ACMGroupName>
            <OrderSeqNo>string</OrderSeqNo>
            <SpecimenName>string</SpecimenName>
            <SpecimenCode>string</SpecimenCode>
            <LogDate>string</LogDate>
            <LogDateTime>dateTime</LogDateTime>
            <ReleaseDateTime>dateTime</ReleaseDateTime>
            <Description>string</Description>
            <ViewCondition>string</ViewCondition>
            <OperatorDefineRange>string</OperatorDefineRange>
            <RangeResult>Normal or Over or Below or Unknown</RangeResult>
            <MaxValue>string</MaxValue>
            <MinValue>string</MinValue>
            <PatientClassCode>string</PatientClassCode>
          </LabItem>
        </_LabItemList>
        <ChartNo>string</ChartNo>
        <StartTime>dateTime</StartTime>
        <EndTime>dateTime</EndTime>
      </QueryLabReportWithNormalRangeResult>
      <errMsg>string</errMsg>
    </QueryLabReportWithNormalRangeResponse>
  </soap:Body>
</soap:Envelope>
	*/
}

dateTimeParse1(str,delim="-"){
	arr:=[]
	RegExMatch(str,"(\d{4})" delim "(\d{2})" delim "(\d{2})T(\d{2}):(\d{2}):(\d{2})((?:\+|-)(?:\d{2}):(?:\d{2}))",match)
	arr.year:=match1
	arr.month:=match2
	arr.day:=match3
	arr.hour:=match4
	arr.minute:=match5
	arr.second:=match6
	arr.zone:=match7
	arr.dateStr:=match1 fill0(match2) fill0(match3)
	arr.timeStr:=fill0(match4) fill0(match5) fill0(match6)
	arr.str:=arr.dateStr arr.timeStr
	return arr
}

convertTaiwanDateToWestern(tw,delim="/"){
	RegExMatch(tw,"(\d+)\" delim "(\d+)\" delim "(\d+)",match)
	return (match1<200?(1911+match1):match1) fill0(match2) fill0(match3)
}

portalMessage(sid,phoneNos,msg,msgType=3){
	global portalAspId
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/CriticalVentilator/MessageSend.aspx?SESSION=" sid
	
	if (msgType=2)
		category:="rdbUnNormal"
	else if (msgType=1)
		category:="rdbCritical"
	else
		category:="rdbNormal"
	
	
	
	httprequest(url,html:="")
	
	header:="Accept: image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*`nReferer: " url "`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; Sleipnir/2.9.14)`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: ihisaw.ntuh.gov.tw`nConnection: Keep-Alive`nPragma: no-cache"
	
	str:="`nCookie: 3=1; ASP.NET_SessionId=" portalAspId "; JSESSIONID=null;"
	
	post:="scrollLeft=&scrollTop=&__EVENTTARGET=NTUHWeb1%24btnSendSMSAndEmail&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=" encodeurl(get(html,"__VIEWSTATE")) "&__EVENTVALIDATION=" encodeurl(get(html,"__EVENTVALIDATION")) "&NTUHWeb1%24PersonIDInput=&NTUHWeb1%24txbwardno=&NTUHWeb1%24QueryInputByDr=&NTUHWeb1%24PHSSendSeqNo=&NTUHWeb1%24PHSTelNo=" phoneNos "&NTUHWeb1%24txbEmail=&NTUHWeb1%24MessageContent=" encodeurl(msg) "&NTUHWeb1%24Category=" category "&NTUHWeb1%24txbSearchID=100860&NTUHWeb1%24txbStartDate=2013%2F4%2F29&NTUHWeb1%24txbEndDate=2013%2F5%2F2"
	
	httprequest(url,post,header str,"charset: utf-8")
	
	;~ clipboard:=header "`n`n" post
	
	return RegExMatch(post,"is)<script>alert.+?簡訊發送完成\\n")?true:false
	
}

getOpHistory(sid,chartNo,personId=""){
	if(personId=""){
		personId:=patientBasicInfo(chartNo,sid).personId
	}
	httprequest("http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/SimpleInfoShowUsingPlaceHolder.aspx?SESSION=" sid "&PersonID=" personId "&Func=OPNoteList&Seed=" a_now,html:="")
	
	dom:=ComObjCreate("HtmlFile")
	dom.write(html)
	arr:=[]
	
	loop {
		if((t:=getTextById(html,"TreeViewItemt" a_index-1))="")
			break
		RegExMatch(t,"is)(.+)_(\d+)\/(\d+)\/(\d+)",match)
		arr["" match2 match3 match4]:=match1
	}
	
	return arr
}

getLab4(sid,chartNo){
	global portalAspId
	
	httprequest(url:="http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MedicalReportOpen.aspx?SESSION=" sid,html:="",header:="Cookie: ASP.NET_SessionId=" portalAspId)
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MedicalReportOpen.aspx"
	header:="Cookie: NTUHPage_MenuSettingCookie=%u5831%u544a%u7d22%u5f15%u7cfb%u7d71=Y; ASP.NET_SessionId=" portalAspId
	
	
}

htmlEscapeBack(str){
	static escapeCode:="&euro;,&nbsp;,&quot;,&amp;,&lt;,&gt;,&iexcl;,&cent;,&pound;,&curren;,&yen;,&brvbar;,&sect;,&uml;,&copy;,&ordf;,&not;,&reg;,&macr;,&deg;,&plusmn;,&sup2;,&sup3;,&acute;,&micro;,&para;,&middot;,&cedil;,&sup1;,&ordm;,&raquo;,&frac14;,&frac12;,&frac34;,&iquest;,&Agrave;,&Aacute;,&Acirc;,&Atilde;,&Auml;,&Aring;,&AElig;,&Ccedil;,&Egrave;,&Eacute;,&Ecirc;,&Euml;,&Igrave;,&Iacute;,&Icirc;,&Iuml;,&ETH;,&Ntilde;,&Ograve;,&Oacute;,&Ocirc;,&Otilde;,&Ouml;,&times;,&Oslash;,&Ugrave;,&Uacute;,&Ucirc;,&Uuml;,&Yacute;,&THORN;,&szlig;,&agrave;,&aacute;,&acirc;,&atilde;,&auml;,&aring;,&aelig;,&ccedil;,&egrave;,&eacute;,&ecirc;,&euml;,&igrave;,&iacute;,&icirc;,&iuml;,&eth;,&ntilde;,&ograve;,&oacute;,&ocirc;,&otilde;,&ouml;,&divide;,&oslash;,&ugrave;,&uacute;,&ucirc;,&uuml;,&yacute;,&thorn;"
	static characters:="€ ""&<>¡¢£¤¥¦§¨©ª¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþ"
	
	i:=0
	s:=str
	while RegExMatch(s,"&([\w\d#]+?);",m,i+1) {
		if RegExMatch(m,"#(\d+)",n) {
			s:=RegExReplace(s,m,chr(n1))
		}else {
			loop,parse,escapeCode,`,
				if(a_loopfield=m) {
					s:=RegExReplace(s,m,substr(characters,a_index,1))
					break
				}
		}
	}
	
	
	return s
	
}

OpdHxArrToCSV(byref arr,chartNo){
	
	
	csv:=""
	csv.="""病歷號"",""性別"",""生日年"",""生日月"",""生日日"",""姓名"",""門診日期"",""診斷"",""處方"",""醫令"",""年齡"",""帳號"",""院區"",""部門"",""主治醫師"",""Subjective"",""Objective"",""未來影像檢查排程"",""未來其他檢查排程"",""未來門診預約""`n"
	
	for k,v in arr {
		
		csv.=OpdHxToCSV(v,chartNo)
		
	}
	
	return csv
	
}

escapeQuote(str){
	return trim(RegExReplace(str,"""",""""""))
}

OpdHxToCSV(html,chartNo){
	v:=parseOpdHx(html)
	csv:=""
	
	csv.= """" escapeQuote(chartNo) ""","
	csv.= """" escapeQuote(v.gender) ""","
	RegExMatch(v.birthDay,"(\d+)\/(\d+)\/(\d+)",match)
	csv.= """" escapeQuote(match1) ""","
	csv.= """" escapeQuote(match2) ""","
	csv.= """" escapeQuote(match3) ""","
	csv.= """" escapeQuote(v.name) ""","
	csv.= """" escapeQuote(v.OpdDate) ""","
	
	str:=""
	for x,y in v.diagnosis
		str.= y.1 "," y.2 "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","
	
	str:=""
	for x,y in v.drug
		str.= y.name " | " y.dose " | " y.frequency " | " y.duration " | " y.totalAmount " | " y.ifChronic " | " y.orderDate " | " y.specialOrder "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","	
	
	str:=""
	for x,y in v.order
		str.= y "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","		
	
	
	csv.= """" escapeQuote(v.age) ""","
	csv.= """" escapeQuote(v.account) ""","
	csv.= """" escapeQuote(v.hospital) ""","
	csv.= """" escapeQuote(v.department) ""","
	csv.= """" escapeQuote(v.VS) ""","
	csv.= """" escapeQuote(v.subjective) ""","
	csv.= """" escapeQuote(v.objective) ""","
	
	str:=""
	for x,y in v.imageSchedule
		str.= y.date " | " y.timeShift " | " y.examRoom " | " y.number " | " y.orderName "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","	
	
	str:=""
	for x,y in v.examSchedule
		str.= y.date " | " y.timeShift " | " y.examRoom " | " y.number " | " y.orderName "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","	
	
	str:=""
	for x,y in v.FutureSchedule
		str.= y.date " | " y.timeShift " | " y.department " | " y.OpdNo " | " y.number " | " y.VS "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) """`n"	
	
	return csv
}

parseOpdHx(byref html){
	arr:=[]
	
	dom:=ComObjCreate("HtmlFile")
	dom.write(html)
	
	str:=$(dom,"TablePatientBasic").rows[1].innerText
	regexmatch(str,regex:="is)([^\s]+)\s+?\((\w),\s+?(\w+),\s+?([^)]+)\)",match)
	arr.name:=match1
	arr.gender:=match2
	arr.age:=match3
	arr.birthDay:=match4
	
	str:=$(dom,"TablePatientBasic").rows[2].innerText
	regexmatch(str,regex:="is)([^\s]+)\s+?([^\s]+)\s+?([^\s]+)\s+?主治醫師：([^\s]+)\s+?看診日期：([\d\/]+)",match)
	arr.account:=match1
	arr.hospital:=match2
	arr.department:=match3
	arr.VS:=match4
	arr.OpdDate:=match5
	
	arr.subjective:=htmlEscapeBack($(dom,"TableSubjectContent").rows[1].innerText)
	arr.objective:=htmlEscapeBack($(dom,"TableObjectContent").rows[1].innerText)
	
	dx:=[]
	loop % $(dom,"TableDiagnosis").rows.length {
		RegExMatch($(dom,"TableDiagnosis").rows[a_index-1].innerText,"is)([^,]+),\s+?(.+)",match)
		dx.insert(array("" match1, "" htmlEscapeBack(match2)))
	}
	arr.diagnosis:=dx
	
	if $(dom,"TablePlanningContent").rows[1].getElementsByTagName("TABLE").length=0
		arr.plan:=$(dom,"TablePlanningContent").rows[1].innerText
	
	drug:=[]
	loop % (tr:=$(dom,"TableDrugData").rows).length-2 {
		d:=[],td:=tr[a_index+1].cells
		if ((name:=htmlEscapeBack(td[0].innerText))="") || td.length<8 {
			drug[drug.maxIndex(),"specialOrder"]:="" tr[a_index+1].innerText
			continue
		}
		d.name:="" name
		d.dose:="" td[1].innerText
		d.frequency:="" td[2].innerText
		d.duration:="" td[3].innerText
		d.totalAmount:="" td[4].innerText
		d.ifChronic:="" td[5].innerText
		d.orderDate:="" td[6].innerText
		drug.insert(d.clone())
	}
	arr.drug:=drug
	
	order:=[]
	loop % (tr:=$(dom,"TableOrderInfo").rows).length-1 {
		contents:=RegExReplace(tr[a_index].cells[0].innerHTML,"is)<br\s*(\/)?>","ω")
		loop,parse,contents,ω
		{
			;~ ifDC:=""
			;~ if regexmatch(a_loopfield,"is)<span\s+?style=""?text-decoration\:\s*?line\-through""?[^>]*?>(.+)<\/span>",match)
				;~ ifDC:="(DC!)",a_loopfield:=decodeurl(match1)
			if ((txt:=trim(htmlEscapeBack(regexreplace(a_loopfield,"is)<span[^>]+?line-through[^>]+?>.+?<\/span>"))))!="")
				order.insert(RegExReplace(txt,",$"))
		}
	}
	arr.order:=order
	
	
	imageSchedule:=[]
	loop % (tr:=dom.getElementById("TableImageSchedule").rows).length-2 {
		i:=[],td:=tr[a_index+1].cells
		if(instr(tr.innerText,"未來一般檢查排程")||instr(tr.innerText,"日期"))
			continue
		i.date:=td[0].innerText
		i.timeShift:=td[1].innerText
		i.examRoom:=htmlEscapeBack(td[2].innerText)
		i.number:=td[3].innerText
		i.orderName:=htmlEscapeBack(td[4].innerText)
		imageSchedule.insert(i.clone())
	}
	arr.imageSchedule:=imageSchedule
	
	if ((table:=dom.getElementById("TableImageSchedule").nextSibling).tagName="TABLE"&&instr(table.innerText,"未來一般檢查排程")) {
		examSchedule:=[]
		loop % (tr:=table.rows).length-2 {
			e:=[],td:=tr[a_index+1].cells
			e.date:=td[0].innerText
			e.timeShift:=td[1].innerText
			e.examRoom:=htmlEscapeBack(td[2].innerText)
			e.number:=td[3].innerText
			e.orderName:=htmlEscapeBack(td[4].innerText)
			examSchedule.insert(e.clone())
		}
		arr.examSchedule:=examSchedule
	}
	
	
	
	FutureSchedule:=[]
	loop % (tr:=$(dom,"TableFutureSchedule").rows).length-2 {
		f:=[],td:=tr[a_index+1].cells
		f.date:=td[0].innerText
		f.timeShift:=td[1].innerText
		f.department:=htmlEscapeBack(td[2].innerText)
		f.OpdNo:=td[3].innerText
		f.number:=td[4].innerText
		f.VS:=td[5].innerText
		FutureSchedule.insert(f.clone())
	}
	arr.FutureSchedule:=FutureSchedule
	
	return arr
}

parseOldOpdHx(byref html){
	arr:=[]
	
	dom:=ComObjCreate("HtmlFile")
	dom.write(html)
	loop % (elm:=dom.body.childNodes).length {
		title:=trim((tr:=elm[a_index-1].firstChild.childNodes)[0].innerText)
		if(title="基本資料"){
			RegExMatch(tr[1].innerText,"([^\s]+)\s*?\((\w),([\d\/]+)\)\s*?\(電話\)([^\s]*?)\s*?\(手機\)([^\s]*?)\s*?\(住址\)([^\n]*)",match)
			arr.name:=match1
			arr.gender:=match2
			arr.birthDay:=match3
			arr.phone:=match4
			arr.cellPhone:=match5
			arr.address:=match6
		}else if(title="帳號資料"){
			RegExMatch(tr[1].innerText,"台大醫院([^\s]+) 科部：([^\s]+) 主治醫師：([^\s]+) 看診時間：([\d\/]+)",match)
			arr.hospital:=match1
			arr.department:=match2
			arr.VS:=match3
			arr.OpdDate:=match4
		}else if(title="病歷內容"){
			arr.chart:=htmlEscapeBack(tr[1].innerText)
		}else if(title="診斷內容"){
			dx:=[],text:=tr[1].innerText
			StringReplace,text,text,`,(,¢
			temp:=""
			loop,parse,text,¢
			{
				if(RegExMatch(a_loopfield,"^\w)")){
					if(temp)
						dx.insert(htmlEscapeBack(temp)),temp:=A_LoopField
				}else{
					temp.=a_loopfield
				}
			}
			dx.insert(RegExReplace(htmlEscapeBack(temp),",\s?$"))
			arr.diagnosis:=dx
		}else if(title="處方內容"){
			drug:=[]
			loop % tr.length-2 {
				d:=[]
				name:=(td:=tr[a_index+1].childNodes)[0].innerText
				d.route:=td[1].innerText
				d.dose:=td[2].innerText
				d.frequency:=td[3].innerText
				d.duration:=td[4].innerText
				d.totalAmount:=td[5].innerText
				d.ifChronic:=td[6].innerText
				d.specialOrder:=htmlEscapeBack(td[7].innerText)
				drug["" name]:=d
			}
			arr.drug:=drug
		}else if(title="醫令內容"){
			order:=[]
			loop % tr.length-1 {
				order.insert(htmlEscapeBack(tr[a_index].innerText))
			}
			arr.order:=order
		}
		
	}
	return arr
	
}

OldOpdHxToCSV(byref html,chartNo){
	v:=parseOldOpdHx(html)
	csv:=""
	
	csv.= """" escapeQuote(chartNo) ""","
	csv.= """" escapeQuote(v.gender) ""","
	RegExMatch(v.birthDay,"(\d+)\/(\d+)\/(\d+)",match)
	csv.= """" escapeQuote(match1) ""","
	csv.= """" escapeQuote(match2) ""","
	csv.= """" escapeQuote(match3) ""","
	csv.= """" escapeQuote(v.name) ""","
	csv.= """" escapeQuote(v.OpdDate) ""","
	
	;;
	str:=""
	for x,y in v.diagnosis
		str.= y "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","
	
	str:=""
	for x,y in v.drug
		str.= x " | " y.dose " | " y.frequency " | " y.duration " | " y.totalAmount " | " y.ifChronic " |  | " y.route " | " y.specialOrder "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","	
	
	str:=""
	for x,y in v.order
		str.= y "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","		
	
	
	csv.= """" escapeQuote(v.age) ""","
	csv.= """" escapeQuote(v.account) ""","  ;;;
	csv.= """" escapeQuote(v.hospital) ""","
	csv.= """" escapeQuote(v.department) ""","
	csv.= """" escapeQuote(v.VS) ""","
	;~ csv.= """" escapeQuote(v.subjective) ""","  ;;;
	csv.= """" escapeQuote(v.chart) ""","  ;;;
	csv.= """" escapeQuote(v.objective) ""","  ;;;
	
	return csv ","""","""",""""`n"
	
	str:=""
	for x,y in v.imageSchedule
		str.= y.date " | " y.timeShift " | " y.examRoom " | " y.number " | " y.orderName "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","	
	
	str:=""
	for x,y in v.examSchedule
		str.= y.date " | " y.timeShift " | " y.examRoom " | " y.number " | " y.orderName "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) ""","	
	
	str:=""
	for x,y in v.FutureSchedule
		str.= y.date " | " y.timeShift " | " y.department " | " y.OpdNo " | " y.number " | " y.VS "`n"
	csv.= """" escapeQuote(regexreplace(str,"\n?$")) """`n"	
	
	
}

/* 
params:
startYear
startMonth
startDay
endYear
endMonth
endDate
DeptCode
userId
ward
hospital
patientId
*/
consultInfo(sid,queryBy="",byref params="",html="",parse=1){
	if (params="")
		params:=[]
	if (queryBy="")
		queryBy:="NTUHWeb1$QueryNotifyContent"
	
	if queryBy=Dept
		queryBy=NTUHWeb1$ButtonQueryByDept
	
	
	
	global __VIEWSTATE,__EVENTVALIDATION,portalAspId,__VIEWSTATEGENERATOR
	
	if (__VIEWSTATE="" || __EVENTVALIDATION="" || portalAspId="" || __VIEWSTATEGENERATOR="")
		httprequest(url:="http://ihisaw.ntuh.gov.tw/WebApplication/InPatient/Ward/QueryNotifyRecordByDr.aspx?SESSION=" sid,html:="",header:="","charset: utf-8")	
		,RegExMatch(header,"i)ASP\.NET_SessionId=\w{24}",portalAspId)
	
	header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/msword, application/xaml+xml, application/vnd.ms-xpsdocument, application/x-ms-xbap, application/x-ms-application, */*`nReferer: " url "`nAccept-Language: zh-tw`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: ihisaw.ntuh.gov.tw`nPragma: no-cache`nCookie: " portalAspId 
	
	
	endDate:=startDate:=a_now
	if(!params.endYear)
		params.endYear:=substr(endDate,1,4)
	if(!params.endMonth)
		params.endMonth:=substr(endDate,5,2)*1
	if(!params.endDay)
		params.endDay:=substr(endDate,7,2)*1
	
	startDate+=-3,D
	if(!params.startYear)
		params.startYear:=substr(startDate,1,4)
	if(!params.startMonth)
		params.startMonth:=substr(startDate,5,2)*1
	if(!params.startDay)
		params.startDay:=substr(startDate,7,2)*1
	
	
	if (queryBy="NTUHWeb1$ButtonQueryByDept"){
		post:="scrollLeft=0&scrollTop=0&__EVENTTARGET=" encodeurl("NTUHWeb1$NotDepartSelectionObj$ddlDeptCode") "&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=" encodeurl(__VIEWSTATE:=get(html,"__VIEWSTATE")) "&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION:=get(html,"__EVENTVALIDATION")) "&NTUHWeb1%24DateTextBoxYearMonthDayStart%24YearInput=" params.startYear "&NTUHWeb1%24DateTextBoxYearMonthDayStart%24MonthInput=" params.startMonth "&NTUHWeb1%24DateTextBoxYearMonthDayStart%24DayInput=" params.startDay "&NTUHWeb1%24DateTextBoxYearMonthDayEnd%24YearInput=" params.endYear "&NTUHWeb1%24DateTextBoxYearMonthDayEnd%24MonthInput=" params.endMonth "&NTUHWeb1%24DateTextBoxYearMonthDayEnd%24DayInput=" params.endDay "&NTUHWeb1%24NotDepartSelectionObj%24ddlHospitalCode=" ((hospital:=params.hospital)?hospital:"T0") "&NTUHWeb1%24NotDepartSelectionObj%24ddlDeptCode=" params.DeptCode "&NTUHWeb1%24DropDownListPatClass=&NTUHWeb1%24PersonIDInput=" ((id:=params.userId)?id:getUserid(sid)) "&NTUHWeb1%24DropDownListWardCode=" params.ward "&NTUHWeb1%24txbChartNo=" params.chartNo "&NTUHWeb1%24txbPatientPID=" params.patientId "&NTUHWeb1%24QueryDrIDInfoByDrName1%24EmpNoQueryInput=&NTUHWeb1%24HiddenFieldHospitalCode=T0&NTUHWeb1%24NotDepartSelectionObj%24ddlSubDept=&__VIEWSTATEGENERATOR=" encodeurl(__VIEWSTATEGENERATOR:=get(html,"__VIEWSTATEGENERATOR"))
    	httprequest(url,html:=post,header1:=header,"charset: utf-8")

	}
	
	
	post:="scrollLeft=0&scrollTop=0&__EVENTTARGET=" encodeurl(queryBy) "&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=" encodeurl(__VIEWSTATE:=get(html,"__VIEWSTATE")) "&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION:=get(html,"__EVENTVALIDATION")) "&NTUHWeb1%24DateTextBoxYearMonthDayStart%24YearInput=" params.startYear "&NTUHWeb1%24DateTextBoxYearMonthDayStart%24MonthInput=" params.startMonth "&NTUHWeb1%24DateTextBoxYearMonthDayStart%24DayInput=" params.startDay "&NTUHWeb1%24DateTextBoxYearMonthDayEnd%24YearInput=" params.endYear "&NTUHWeb1%24DateTextBoxYearMonthDayEnd%24MonthInput=" params.endMonth "&NTUHWeb1%24DateTextBoxYearMonthDayEnd%24DayInput=" params.endDay "&NTUHWeb1%24NotDepartSelectionObj%24ddlHospitalCode=" ((hospital:=params.hospital)?hospital:"T0") "&NTUHWeb1%24NotDepartSelectionObj%24ddlDeptCode=" params.DeptCode "&NTUHWeb1%24DropDownListPatClass=&NTUHWeb1%24PersonIDInput=" ((id:=params.userId)?id:getUserid(sid)) "&NTUHWeb1%24DropDownListWardCode=" params.ward "&NTUHWeb1%24txbChartNo=" params.chartNo "&NTUHWeb1%24txbPatientPID=" params.patientId "&NTUHWeb1%24QueryDrIDInfoByDrName1%24EmpNoQueryInput=&NTUHWeb1%24HiddenFieldHospitalCode=T0&NTUHWeb1%24NotDepartSelectionObj%24ddlSubDept=&__VIEWSTATEGENERATOR=" encodeurl(__VIEWSTATEGENERATOR:=get(html,"__VIEWSTATEGENERATOR"))
	
	httprequest(url,post,header,"charset: utf-8")
	
	if !parse
		return post
	
	dom:=ComObjCreate("HtmlFile")
	dom.write(post)
	arr:=[]
	
	if !(table:=$(dom,"NTUHWeb1_NotifyDrRecord"))
		return arr
	
	vsName:=getUserName(params.userId,sid)
	
	loop % (tr:=table.rows).length-1 {
		if(instr(tr[a_index].innerHTML,"line-through"))
			continue
		
		vs:="" trim((td:=tr[a_index].cells)[9].innerText)
		R:="" trim(td[10].innerText)
		replyBy:="" trim(td[11].innerText)
		GCA:="" trim(td[12].innerText)
		if(params.userId && vsName!=vs && vsName!=R && vsName!=replyBy && vsName!=GCA)
			continue
		if !(time:=trim(RegExReplace(td[4].firstChild.title,"[\/\s:]")))
			continue
		
		row:=[]
		RegExMatch(td[1].firstChild.title,"is)T0-(.+)分機:(.+)",match)
		row.department:="" (d:=RegExReplace(match1,"\s"))?d:td[1].innerText
		row.departmentPhone:="" trim(match2)
		row.chartNo:="" trim(td[2].innerText)
		row.notifyId:="" td[2].firstChild.title
		row.account:="" trim(td[3].firstChild.title)
		RegExMatch(td[3].innerText,"is)([^\(]+)\((\w),([^\)]+)\)",match)
		row.name:=match1,row.gender:=match2,row.age:=match3
		row.time:=time
		row.type:="" trim(td[5].innerText)
		row.type2:=td[5].firstChild.title
		row.consulter:="" trim(td[6].innerText)
		RegExMatch(td[6].firstChild.title,"\d+",match)
		row.consulterPhone:=match
		row.purpose:=td[7].firstChild.title
		row.consulted:="" trim(td[8].innerText)
		row.VS:=vs
		RegExMatch(td[9].firstChild.title,"\d+",match)
		row.Rphone:=match
		row.R:=R
		RegExMatch(td[10].firstChild.title,"\d+",match)
		row.Rphone:=match
		row.replyBy:=replyBy
		row.GCA:=GCA
		row.status:="" trim(td[13].innerText)
		row.leftTime:="" trim(td[14].innerText)
		
		arr.insert(row.clone())
	}
	
	return arr
}

getConsult(sid,accountIDSE,notifyIDSE,PatClass){
	seed2:=(substr(a_now,9,2)<12?"上午":"下午") " " substr(a_now,11,2) ":" substr(a_now,13,2) ":" substr(a_now,15,2)
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/InPatient/Ward/NotifyOtherDoctor.aspx?SESSION=" sid "&AccountIDSE=" accountIDSE "&NotifyIDSE=" notifyIDSE  "&Reply=Y&Seed=" seed2
	
	httprequest(url,html:="",header:="","charset: utf-8`n+NO_COOKIES")
	return html
	
}

replyConsult(sid,accountIDSE,notifyIDSE,PatClass,replyContent,diagnosis,suggestion,byref params=""){
	
	seed1:=(substr(a_now,9,2)<12?"%ufffdU%ufffd%ufffd":"%ufffdU%ufffd%ufffd") "+" substr(a_now,11,2) "%3a" substr(a_now,13,2) "%3a" substr(a_now,15,2)
	seed2:=(substr(a_now,9,2)<12?"上午":"下午") " " substr(a_now,11,2) ":" substr(a_now,13,2) ":" substr(a_now,15,2)
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/InPatient/Ward/NotifyOtherDoctor.aspx?SESSION=" sid "&AccountIDSE=" accountIDSE "&NotifyIDSE=" notifyIDSE  "&Reply=Y&Seed=" seed1
	
	referer:="http://ihisaw.ntuh.gov.tw/WebApplication/InPatient/Ward/NotifyOtherDoctor.aspx?SESSION=" sid "&AccountIDSE=" accountIDSE "&NotifyIDSE=" notifyIDSE  "&Reply=Y&Seed=" seed2
	
	
	html:=getConsult(sid,accountIDSE,notifyIDSE,PatClass)
	
	
	
	dom:=ComObjCreate("HtmlFile")
	dom.write(html)
	
	
	
	header:="Accept: image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*`nReferer: " referer "`nAccept-Language: zh-TW`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: ihisaw.ntuh.gov.tw`nConnection: Close`nPragma: no-cache"
	
	post:="scrollLeft=0&scrollTop=0&__EVENTTARGET=NTUHWeb1%24btnRecordFisrtAnalysisTime&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=" encodeurl($(dom,"__VIEWSTATE").value) "&__EVENTVALIDATION=" encodeurl($(dom,"__EVENTVALIDATION").value) "&NTUHWeb1%24TextboxMainPurpose=" regexreplace(encodeurl($(dom,"NTUHWeb1_TextboxMainPurpose").value),"%20","+") "&NTUHWeb1%24TextboxDescription=" regexreplace(encodeurl($(dom,"NTUHWeb1_TextboxDescription").value),"%20","+") "&NTUHWeb1%24TextboxReplyContent=" regexreplace(encodeurl(replyContent),"%20","+") "&NTUHWeb1%24TextboxDiagnosis=" regexreplace(encodeurl(diagnosis),"%20","+") "&NTUHWeb1%24TextboxSuggestion=" regexreplace(encodeurl(suggestion),"%20","+") "&NTUHWeb1%24atxbGCAEmpNo%24txbContent=" (params.VS?params.VS:$(dom,"NTUHWeb1_atxbGCAEmpNo_txbContent").value) "&NTUHWeb1%24TextboxCostCenterInput=" (params.costCenter?params.costCenter:$(dom,"NTUHWeb1_TextboxCostCenterInput").value) "&hiddenInputToUpdateATBuffer_CommonToolkitScripts=1&__VIEWSTATEGENERATOR=" encodeurl($(dom,"__VIEWSTATEGENERATOR").value)
	
	httprequest(url,post,header,"charset: utf-8`n+NO_COOKIES")
	
	return 1
	;~ return !!(instr(post,"<script>alert(""成功產生照會醫令") || instr(post,"<script>alert(""\n初次評估完成"");"))
	
		
	
}

askForPortalIdPw(opt=0){
	global loginId,loginPw,sid
	priorSid:=Sid
	
	if fileexist("portal.ini")
		path:="portal.ini"
	else if fileexist((dir:=regexreplace(a_scriptdir,"[/\\][^/\\]+$")) "\portal.ini")
		path:=dir "\portal.ini"
	
	AES_pw:="scsnakePortalLib"
	if(!opt){
		enc_dec:=""
		if(loginId=""&&loginPw=""&&fileexist(path)){
			iniread,loginId,% path,login,loginId
			iniread,loginPw,% path,login,loginPw
			Hex_Bin(enc_dec,loginPw)
			size:=Crypt_AES(&enc_dec, floor(strlen(loginPw)/2), AES_pw, 256, 0)
			loginPw:=substr(substr(enc_dec,1,size),1,size-16)
		}
		priorPw:=loginPw
		priorId:=loginId
	}else{
		priorPw:=loginPw
		priorId:=loginId
		loginId:="",loginPw:=""
	}
	
	while !checkSid(sid:=Login(loginId,loginPw)) {
		if (a_index>50) {
			msgbox % Can not login Portal !!
			exitapp
		}
		
		loop {
			inputbox,loginId,Portal login ID,,,300,150,,,,,% (loginId="ERROR")?"":loginId
			if (errorlevel && !opt)
				exitapp
			else if (errorlevel) {
				loginId:=priorId,loginPw:=priorPw,Sid:=priorSid
				return
			}
		} until loginId!=""
		
		loop {
			inputbox,loginPw,Portal login password,,Hide,300,150
			if (errorlevel && !opt)
				exitapp
			else if (errorlevel){
				loginId:=priorId,loginPw:=priorPw,Sid:=priorSid
				return
			}
		} until loginPw!=""
		sleep 200
	}
	
	enc_dec:=loginPw "0123456789abcdef"
	size:=Crypt_AES(&enc_dec, strlen(enc_dec), AES_pw, 256, 1)
	encloginPw:=Bin_Hex(enc_dec,size,32,"")
	
	if !fileexist(path)
		path:="portal.ini"
	
	if(opt||priorId!=loginId||priorPw!=loginPw){
		iniwrite,% loginId,% path,login,loginId
		iniwrite,% encloginPw,% path,login,loginPw
	}
}

getOptionByText(byref el,str){
	if(el.tagName="select"){
		loop % el.options.length {
			if instr(el.options[a_index-1].innerText,str)
				return object("index",a_index-1,"value",el.options[a_index-1].value)
		}
	}
}

queryDigiSign(sid,id){
	global __VIEWSTATE,__EVENTVALIDATION,portalAspId
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/DigitalSignature/DSQuery.aspx?SESSION=" sid
	if (!__VIEWSTATE || !__EVENTVALIDATION || !portalAspId) {
		header:="Host: ihisaw.ntuh.gov.tw`nUser-Agent: Mozilla/5.0 (Windows NT 5.1; rv:29.0) Gecko/20100101 Firefox/29.0`nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8`nAccept-Language: en-US,en;q=0.5`nAccept-Encoding: gzip, deflate`nConnection: keep-alive"
		
		httprequest(url,html:="",header,"charset: utf-8")
		portalAspId:=RegExReplace(header,"s).+ASP\.NET_SessionId=([^;]+);.+","$1")
		__VIEWSTATE:=get(html,"__VIEWSTATE")
		__EVENTVALIDATION:=get(html,"__EVENTVALIDATION")
	}
	
	while strlen(id)<6
		id:="0" id
	
	formattime,date,% a_now,yyyy/MM/dd
	
	header:="Host: ihisaw.ntuh.gov.tw`nUser-Agent: Mozilla/5.0 (Windows NT 5.1; rv:29.0) Gecko/20100101 Firefox/29.0`nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8`nAccept-Language: en-US,en;q=0.5`nAccept-Encoding: gzip, deflate`nReferer: http://ihisaw.ntuh.gov.tw/WebApplication/DigitalSignature/DSQuery.aspx?SESSION=" sid "`nConnection: close`nCookie: 5=1; ASP.NET_SessionId=" portalAspId "; JSESSIONID=null"
	
	post:="scrollLeft=0&scrollTop=0&__EVENTTARGET=NTUHWeb1%24txbEmpNO&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=" encodeurl(__VIEWSTATE) "&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&NTUHWeb1%24txbEmpNO=" id "&NTUHWeb1%24txbPinCode=&NTUHWeb1%24txtSDateChar=" encodeurl(date) "&NTUHWeb1%24txtSDateChar_MaskedEditExtender_ClientState=&NTUHWeb1%24txtEDateChar=" encodeurl(date) "&NTUHWeb1%24txtEDateChar_MaskedEditExtender_ClientState="
	
	httprequest(url,post,header,"charset: utf-8")
	
	return post
	
}

queryDigiSignN(sid,id){
	global __VIEWSTATE,__EVENTVALIDATION,portalAspId,loginId
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/DigitalSignature/DrugGivenDS.aspx?SESSION=" sid
	if (!__VIEWSTATE || !__EVENTVALIDATION || !portalAspId) {
		header:="Host: ihisaw.ntuh.gov.tw`nUser-Agent: Mozilla/5.0 (Windows NT 5.1; rv:29.0) Gecko/20100101 Firefox/29.0`nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8`nAccept-Language: en-US,en;q=0.5`nAccept-Encoding: gzip, deflate`nConnection: keep-alive"
		
		httprequest(url,html:="",header,"charset: utf-8")
		portalAspId:=RegExReplace(header,"s).+ASP\.NET_SessionId=([^;]+);.+","$1")
		__VIEWSTATE:=get(html,"__VIEWSTATE")
		__EVENTVALIDATION:=get(html,"__EVENTVALIDATION")
	}
	
	while strlen(id)<6
		id:="0" id
	
	formattime,date,% a_now,yyyy/MM/dd
	
	header:="Host: ihisaw.ntuh.gov.tw`nUser-Agent: Mozilla/5.0 (Windows NT 5.1; rv:29.0) Gecko/20100101 Firefox/29.0`nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8`nAccept-Language: en-US,en;q=0.5`nAccept-Encoding: gzip, deflate`nReferer: http://ihisaw.ntuh.gov.tw/WebApplication/DigitalSignature/DrugGivenDS.aspx?SESSION=" sid "`nConnection: close`nCookie: 5=1; ASP.NET_SessionId=" portalAspId "; JSESSIONID=null"
	
	d:=A_Now
	d+=-6,days
	
	post:="NTUHWeb1%24ScriptManager1=NTUHWeb1%24UpdatePanel1%7CNTUHWeb1%24BtnGetEmgPatientListByDoctor&scrollLeft=0&scrollTop=0&hiddenHl7Reg=http%3A%2F%2Fihiswsvc.ntuh.gov.tw%2FHL7Central_IIS%2FCentral.asmx-" sid "-" loginId "-" A_IPAddress1 "-DigitalSignature%2FDrugGivenDS&NTUHWeb1%24txbEmpNO=" id "&NTUHWeb1%24txtSDateChar=" substr(d,1,4) "%2F" substr(d,5,2) "%2F" substr(d,7,2) "&NTUHWeb1%24txtSDateChar_MaskedEditExtender_ClientState=&NTUHWeb1%24txtEDateChar=" a_yyyy "%2F" a_MM "%2F" a_dd "&NTUHWeb1%24txtEDateChar_MaskedEditExtender_ClientState=&NTUHWeb1%24txbPinCode=&NTUHWeb1%24hiddenPin=undefind&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=" encodeurl(__VIEWSTATE) "&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&__AjaxControlToolkitCalendarCssLoaded=&hiddenRecord=000000-" loginId "-T0&__ASYNCPOST=true&NTUHWeb1%24BtnGetEmgPatientListByDoctor=%E6%9F%A5%E8%A9%A2"
	
	httprequest(url,post,header,"charset: utf-8")
	
	return post
	
}

EMRViewerMobile(sid,chartNo){
	global __VIEWSTATE,__EVENTVALIDATION,portalAspId,reportpageguid
	
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	
	if !(__VIEWSTATE && __EVENTVALIDATION && reportpageguid){
		url:="http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MedicalReportOpen.aspx?SESSION=" sid
		header:="Host: ihisaw.ntuh.gov.tw`nConnection: Keep-Alive"		
		httprequest(url,post:="",header,"charset: utf-8")
		
		RegExMatch(post,"reportpageguid=([\w\-]+)",match)
		reportpageguid:=match1
		__VIEWSTATE:=get(post,"__VIEWSTATE")
		__EVENTVALIDATION:=get(post,"__EVENTVALIDATION")
	}
	
	;~ url:="http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MobileMasterPage.aspx?reportpageguid=" reportpageguid
	;~ header:="Host: ihisaw.ntuh.gov.tw`nConnection: Keep-Alive"
	;~ httprequest(url,post:="",header,"charset: utf-8")
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MobileMasterPage.aspx?reportpageguid="reportpageguid
	header:="Referer: http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MobileMasterPage.aspx?reportpageguid=" reportpageguid "`nHost: ihisaw.ntuh.gov.tw`nConnection: Keep-Alive`nPragma: no-cache"
	post:="__LASTFOCUS=&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=" encodeurl(__VIEWSTATE) "&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&txbIDInput=" chartNo "&btnQueryAction=%E6%9F%A5%E8%A9%A2"
	httprequest(url,post,header,"charset: utf-8")
	
	RegExMatch(post,"reportpageguid=([\w\-]+)",match)
	reportpageguid:=match1
	__VIEWSTATE:=get(post,"__VIEWSTATE")
	__EVENTVALIDATION:=get(post,"__EVENTVALIDATION")
	
	
	return new EMRViewerMobile(post)
}

EMRgetRadExams(EMRViewerMobile){
	radExams:=[]
	sorting:=[],i:=0
	for k,v in EMRViewerMobile.EMR
		if instr(v.title,"影核醫") {
			for x,y in v
				if x is number
				{
					regexmatch(y.param,"([^_]+)_([^_]+)_([^_]+)",match)
					radExams.insert({ExamName: RegExReplace(y["報告類別"],"i) \(V\d+\)$","") 
						,ExamDate: y["檢查日期"] ;yyyy/mm/dd
						,Hospital: match1 ;T0
						,AccessNo: match3
						,ReportDate: y["報告日期"]}) ;yyyymmdd
					sorting[RegExReplace(y["檢查日期"],"\D","") match3]:=++i
				}
		}
	sorted:=[]
	for k,v in sorting
		sorted.insert(radExams[v])
	return sorted
}

class EMRViewerMobile {
	__New(html){
		dom:=ComObjCreate("HtmlFile")
		dom.write(html)
		
		ret:=[]
		
		loop % $(dom,"MobileMenu").childNodes.length
		{	
			arr:=[]
			group:=$(dom,"MobileMenu").childNodes[a_index-1]
			arr["title"]:=group.firstChild.firstChild.nodeValue
			col:=[]
			loop % group.childNodes[1].firstChild.firstChild.childNodes.length
				col.insert(trim(group.childNodes[1].firstChild.firstChild.childNodes[a_index-1].innerText))
			
			loop % group.childNodes[1].childNodes[1].childNodes.length {
				i:=a_index
				item:=[]
				item["param"]:=trim(group.childNodes[1].childNodes[1].childNodes[i-1].param)
				loop % group.childNodes[1].childNodes[1].childNodes[i-1].childNodes.length {
					j:=a_index
					if (col[j]="開報告"){
						regexmatch(group.childNodes[1].childNodes[1].childNodes[i-1].childNodes[j-1].firstChild.href,"WebForm_PostBackOptions\(""([^""]+)",match)
						item["" col[j]]:="" trim(match1)
					}else{
						item["" col[j]]:="" trim(group.childNodes[1].childNodes[1].childNodes[i-1].childNodes[j-1].innerText)
					}
				}
				arr.insert(item.clone())
			}
			ret.insert(arr.clone())
		}
		this.EMR:=ret	
		
		RegExMatch(html,"reportpageguid=([\w\-]+)",match)
		this.reportpageguid:=match1
		this.__VIEWSTATE:=get(html,"__VIEWSTATE")
		this.__EVENTVALIDATION:=get(html,"__EVENTVALIDATION")
		
		this.chartNo:=get(html,"txbIDInput")
	}
	
	getReport(reportNameSubStr,examDate,titleSubStr="影核醫",Number=0,reportDate=""){
		if (reportNameSubStr="" || titleSubStr="")
			return []
		
		arr:=[],arr2:=[]
		
		if isobject(reportNameSubStr) {
			for k,v in this.EMR {
				if instr(v.title,titleSubStr) {
					for x,y in v {
						if x is not number
							continue
						if reportNameSubStr.(y["報告類別"]) && instr(RegExReplace(y["檢查日期"],"\D",""),RegExReplace(examDate,"\D","")){ 
							arr2.insert(y["開報告"])
							if (reportDate="" || instr(RegExReplace(y["報告日期"],"\D",""),RegExReplace(reportDate,"\D","")))
								arr.insert(y["開報告"])
						}
					}
					break
				}
			}
		}else{
			for k,v in this.EMR {
				if instr(v.title,titleSubStr) {
					for x,y in v {
						if x is not number
							continue
						if instr(y["報告類別"],reportNameSubStr) && instr(RegExReplace(y["檢查日期"],"\D",""),RegExReplace(examDate,"\D","")){
							arr2.insert(y["開報告"])
							if (reportDate="" || instr(RegExReplace(y["報告日期"],"\D",""),RegExReplace(reportDate,"\D","")))
								arr.insert(y["開報告"])
						}
					}
					break
				}
			}
		}
		
		if !arr.maxIndex()
			arr:=arr2.clone()
		
		if !arr.maxIndex()
			return 0
		arr2:=[]
		
		for k,v in arr {
			if (number>0&&a_index>number)
				break
			arr2.insert(this.getReportByLink(v))
		}
		return arr2
	}
	
	getReportByLink(linkId){
		url:="http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MobileMasterPage.aspx?reportpageguid=" this.reportpageguid
		header:="Referer: http://ihisaw.ntuh.gov.tw/WebApplication/ElectronicMedicalReportViewer/MobileMasterPage.aspx?reportpageguid=" this.reportpageguid "`nHost: ihisaw.ntuh.gov.tw`nConnection: Keep-Alive`nPragma: no-cache"
		post:="__LASTFOCUS=&__EVENTTARGET=" encodeUrl(linkId) "&__EVENTARGUMENT=&__VIEWSTATE=" encodeurl(this.__VIEWSTATE) "&__EVENTVALIDATION=" encodeurl(this.__EVENTVALIDATION) "&ddlPatChartNo=" encodeUrl(this.chartNo) "&txbIDInput=" encodeUrl(this.chartNo) "&txtEndDate=&txtStartDate="
		httprequest(url,post,header,"charset: utf-8")
		
		url:=RegExReplace(get(post,"Reportifrm","id","src"),"&amp;","&")
		httprequest(url,post:="",header:="","charset: utf-8")
		
		return post
	}
	
	radReportText(html){
		dom:=ComObjCreate("HtmlFile")
		dom.write(html)
		
		table1:=$(dom,"rReportTab_lsvReportBody_ctrl0_ctl00_tblDisplay").previousSibling.childNodes[5].firstChild
		table2:=$(dom,"rReportTab_lsvReportBody_ctrl0_ctl00_tblDisplay")
		str:=""
		
		loop % table1.firstChild.childNodes.length {
			i:=a_index
			loop % table1.firstChild.childNodes[i-1].childNodes.length {
				j:=a_index
				str.=trim(table1.firstChild.childNodes[i-1].childNodes[j-1].innerText) " "
			}
			str.="`n"
		}
		loop % table2.firstChild.childNodes.length {
			i:=a_index
			loop % table2.firstChild.childNodes[i-1].childNodes.length {
				j:=a_index
				if(table2.firstChild.childNodes[i-1].childNodes[j-1].getElementsByTagName("textarea").length>0)
					str.=trim(table2.firstChild.childNodes[i-1].childNodes[j-1].firstChild.firstChild.innerText) " "
				else
					str.=trim(table2.firstChild.childNodes[i-1].childNodes[j-1].innerText) " "
			}
			str.="`n"
		}
		
		return str
		
	}
	
	
}

/*
arr[1]
	醫令
	報告醫師
	影像時間 (format=2015/10/19 17:29)
	醫令碼
	報告時間
arr[2]	report
arr[3]	impression
*/
parseRisReport2Yr(html){
	dom:=ComObjCreate("HtmlFile")
	dom.write(html)
	
	table:=$(dom,"TableRISReport")
	
	arr:=[]
	loop % table.rows.length-1 {
		row:=table.rows[a_index]
		text:=row.innerText
		if regexmatch(text,"is)^醫令: (.+?) 報告醫師: (.+?) 影像時間: (.+?) \(([^\)]+)\) 發報告時間: (.+?)",match)
			tmp:=[],tmp.insert([trim(match1), trim(match2), trim(match3), trim(match4), trim(match5)])
		else if regexmatch(text,"is)^報告內容: (.+)",match) || regexmatch(text,"is)^Impression: (.+)",match)
			tmp.insert(trim(match1))
		else if regexmatch(text,"^症狀: ",match)
			arr.insert(tmp)
	}
	return arr
}

RisReport2Yr(sid,chartNo){
	if !checksid(sid){
		return -1
	}
	
	if RegExMatch(chartNo,"i)\w\d{9}"){
		personId:=chartNo
	}else {
		while strlen(chartNo)<7
			chartNo:="0" chartNo
		personId:=patientBasicInfo(chartNo,sid).personId
	}
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/SimpleInfoShowUsingPlaceHolder.aspx?SESSION=" sid "&Func=RISReport&AccountIDSE=&PersonID=" personid "&Hosp=&WinPup=True&Seed=" a_hour a_min a_sec
	header:="Referer: http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/SimpleShowiframePage.aspx?SESSION=" sid "&PersonID=" personid "&Seed=" a_now "`nHost: ihisaw.ntuh.gov.tw"
	httprequest(url,post:="",header,"charset: utf-8")
		
	return post
	
}

AppendAspInfo(post,html){
	global __VIEWSTATE,__EVENTVALIDATION
	post:=RegExReplace(post,"i)&?(__VIEWSTATE|__EVENTVALIDATION)=[^&]+","")
	post:=RegExReplace(post,"i)(__VIEWSTATE|__EVENTVALIDATION)=[^&]+&?","")
	
	if (post!="")
		post.="&"
	if (__VIEWSTATE="")
		__VIEWSTATE:=get(html,"__VIEWSTATE")
	if (__EVENTVALIDATION="")
		__EVENTVALIDATION:=get(html,"__EVENTVALIDATION")
	
	return post "__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&__VIEWSTATE=" encodeurl(__VIEWSTATE)
}

ExtractHeaderCookie(responseHeader){
	i:=0,match:=str:=""
	while i:=regexmatch(responseHeader,"i)Set-Cookie: ([^\n]+)",match,i+strlen(match)+1)
		str.=match1
	
	return str:=RegExReplace(str,"(path=\/|HttpOnly|expires=[^;]+);?","")
}

queryInjectionRecords(sid,chartno){
	global __VIEWSTATE,__EVENTVALIDATION,portalAspId
	url:="http://hisaw.ntuh.gov.tw/WebApplication/InspectionReport/ReportOfCase.aspx?SESSION=" sid
	if (!__VIEWSTATE || !__EVENTVALIDATION || !portalAspId) {
		header:="Host: hisaw.ntuh.gov.tw`nUser-Agent: Mozilla/5.0 (Windows NT 5.1; rv:29.0) Gecko/20100101 Firefox/29.0`nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8`nAccept-Language: en-US,en;q=0.5`nAccept-Encoding: gzip, deflate`nConnection: keep-alive`nCookie: CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=IsShowChartNo=Y; CK_Clinics_OrderSearch=IsShowOrderCode=N;"
		httprequest(url,html:="",header,"charset: utf-8")
		portalAspId:=RegExReplace(header,"s)^.+ASP\.NET_SessionId=([^;]+);.+$","$1")
		__VIEWSTATE:=get(html,"__VIEWSTATE")
		__EVENTVALIDATION:=get(html,"__EVENTVALIDATION")
	}
	header:="Host: hisaw.ntuh.gov.tw`nUser-Agent: Mozilla/5.0 (Windows NT 5.1; rv:29.0) Gecko/20100101 Firefox/29.0`nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8`nAccept-Language: en-US,en;q=0.5`nAccept-Encoding: gzip, deflate`nConnection: keep-alive`nCookie: CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=IsShowChartNo=Y; CK_Clinics_OrderSearch=IsShowOrderCode=N;ASP.NET_SessionId=" portalAspId ";"
	httprequest(url,html:="",header,"charset: utf-8")
	ToolkitScriptManager1_HiddenField:=RegExReplace(html,"is)^.+\/WebApplication\/InspectionReport\/ReportOfCase\.aspx\?_TSM_HiddenField_=ToolkitScriptManager1_HiddenField&amp;_TSM_CombinedScripts_=([^""]+).+$","$1")
	ucQueryHandler_QueryTab_ClientState:=RegExReplace(get(html,"ucQueryHandler_QueryTab_ClientState"),"i)&quot;","""")
	__VIEWSTATE:=get(html,"__VIEWSTATE")
	__EVENTVALIDATION:=get(html,"__EVENTVALIDATION")
	while strlen(chartno)<6
		chartno:="0" chartno
	formattime,startDate,% a_now,yyyy/M/d
	header:="Host: hisaw.ntuh.gov.tw`nUser-Agent: Mozilla/5.0 (Windows NT 5.1; rv:29.0) Gecko/20100101 Firefox/29.0`nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8`nAccept-Language: en-US,en;q=0.5`nAccept-Encoding: gzip, deflate`nReferer: http://hisaw.ntuh.gov.tw/WebApplication/InspectionReport/ReportOfCase.aspx?`nConnection: keep-alive`nCookie: ASP.NET_SessionId=" portalAspId "; CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=&IsShowChartNo=Y; CK_Clinics_OrderSearch=IsShowOrderCode=N;"
	post:="ToolkitScriptManager1_HiddenField=" ToolkitScriptManager1_HiddenField "&__EVENTTARGET=&__EVENTARGUMENT=&__LASTFOCUS=&ucQueryHandler_QueryTab_ClientState=" encodeurl("{""ActiveTabIndex"":1,""TabEnabledState"":[true,true],""TabWasLoadedOnceState"":[true,false]}") "&__VIEWSTATE=" encodeurl(__VIEWSTATE) "&__SCROLLPOSITIONX=0&__SCROLLPOSITIONY=0&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&ucQueryHandler%24ddlSystem=17&ucQueryHandler%24QueryTab%24QueryFromScheduling%24ddlOrder=CHMRX&ucQueryHandler%24QueryTab%24QueryFromScheduling%24txbDateStart=" encodeurl(startDate) "&ucQueryHandler%24QueryTab%24QueryFromScheduling%24ddlShiftType=&ucQueryHandler%24QueryTab%24QueryFromScheduling%24txbQueryPat=&ucQueryHandler%24QueryTab%24QueryFromScheduling%24TextBoxWatermarkExtender2_ClientState=&ucQueryHandler%24QueryTab%24QueryForFilledCase%24txbChartNoOrPersonId=" encodeurl(chartNo) "&ucQueryHandler%24QueryTab%24QueryForFilledCase%24TextBoxWatermarkExtender1_ClientState=&ucQueryHandler%24QueryTab%24QueryForFilledCase%24txbStartDate=" encodeurl(startDate) "&ucQueryHandler%24QueryTab%24QueryForFilledCase%24txbEndDate=" encodeurl(startDate) "&ucQueryHandler%24QueryTab%24QueryForFilledCase%24btnQueryFilled=%E6%9F%A5%E8%A9%A2&isMenuVisible=true"
	httprequest("http://hisaw.ntuh.gov.tw/WebApplication/InspectionReport/ReportOfCase.aspx",post,header,"charset: utf-8")
	return new FoundInjectionRecords(post)
}

class FoundInjectionRecords {
	__New(post){
		dom:=ComObjCreate("HtmlFile")
		dom.write(post)
		this.ToolkitScriptManager1_HiddenField:=RegExReplace(post,"is)^.+\/WebApplication\/InspectionReport\/ReportOfCase\.aspx\?_TSM_HiddenField_=ToolkitScriptManager1_HiddenField&amp;_TSM_CombinedScripts_=([^""]+).+$","$1")
		this.ucQueryHandler_QueryTab_ClientState:=RegExReplace(get(post,"ucQueryHandler_QueryTab_ClientState"),"i)&quot;","""")
		arr:=[]
		table:=$(dom,"UpdatePanel1").childNodes[2]
		loop % table.rows.length-1 {
			v:=table.rows[a_index]
			pt:=[]
			pt.ChartNo:=trim(v.cells[1].innerText)
			pt.Name:=trim(v.cells[2].innerText)
			pt.Gender:=trim(v.cells[3].innerText)
			pt.Age:=trim(v.cells[4].innerText)
			pt.Status:=trim(v.cells[5].innerText)
			pt.Date:=trim(v.cells[6].innerText)
			pt.PostBack:=RegExReplace(v.cells[2].firstChild.href,"is)^.+(lvQuery\$ctrl\d+\$lbtName).+$","$1")
			arr.insert(pt.clone())
		}
		this.results:=arr
	}
	getLink(n="",chartNo="",date="",postback:=""){
		global sid,portalAspId,__VIEWSTATE,__EVENTVALIDATION
		if(n!=""){
			return this.getLink("","","",this.results[n].PostBack)
		}else{
			arr:=[]
			for k,v in this.results {
				if (instr(v.chartNo,chartNo) && instr(RegExReplace(v.date,"\D",""),substr(RegExReplace(date,"\D",""),1,8))){
					formattime,startDate,% a_now,yyyy/M/d
					header:="Accept: */*`nAccept-Language: zh-tw`nReferer: http://hisaw.ntuh.gov.tw/WebApplication/InspectionReport/ReportOfCase.aspx`nx-requested-with: XMLHttpRequest`nx-microsoftajax: Delta=true`nContent-Type: application/x-www-form-urlencoded; charset=utf-8`nCache-Control: no-cache`nAccept-Encoding: gzip, deflate`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET4.0C; .NET4.0E)`nHost: hisaw.ntuh.gov.tw`nConnection: Keep-Alive`nPragma: no-cache`nCookie: ASP.NET_SessionId=" portalAspId "; CK_Radiology_RISPatientRegistration=X_StatisticGroupCodeCookie=&IsShowChartNo=Y; CK_Clinics_OrderSearch=IsShowOrderCode=N; "
					post:="ToolkitScriptManager1=" encodeurl("UpdatePanel1|" (postback=""?v.PostBack:postback)) "&ToolkitScriptManager1_HiddenField=" this.func1(RegExReplace(this.ToolkitScriptManager1_HiddenField,"\+","%20")) "&__EVENTTARGET=" encodeurl(postback=""?v.PostBack:postback) "&__EVENTARGUMENT=&__LASTFOCUS=&ucQueryHandler_QueryTab_ClientState=" encodeurl("{""ActiveTabIndex"":1,""TabEnabledState"":[true,true],""TabWasLoadedOnceState"":[true,true]}") "&__VIEWSTATE=" encodeurl(__VIEWSTATE) "&__SCROLLPOSITIONX=0&__SCROLLPOSITIONY=0&__EVENTVALIDATION=" encodeurl(__EVENTVALIDATION) "&ucQueryHandler%24ddlSystem=17&ucQueryHandler%24QueryTab%24QueryFromScheduling%24ddlOrder=CHMRX&ucQueryHandler%24QueryTab%24QueryFromScheduling%24txbDateStart=" encodeurl(startDate) "&ucQueryHandler%24QueryTab%24QueryFromScheduling%24ddlShiftType=&ucQueryHandler%24QueryTab%24QueryFromScheduling%24txbQueryPat=&ucQueryHandler%24QueryTab%24QueryFromScheduling%24TextBoxWatermarkExtender2_ClientState=&ucQueryHandler%24QueryTab%24QueryForFilledCase%24txbChartNoOrPersonId=" v.chartNo "&ucQueryHandler%24QueryTab%24QueryForFilledCase%24TextBoxWatermarkExtender1_ClientState=&ucQueryHandler%24QueryTab%24QueryForFilledCase%24txbStartDate=" encodeurl(startDate) "&ucQueryHandler%24QueryTab%24QueryForFilledCase%24txbEndDate=" encodeurl(startDate) "&isMenuVisible=true&__ASYNCPOST=true"
					;~ clipboard:=header "`n`n" post
					httprequest("http://hisaw.ntuh.gov.tw/WebApplication/InspectionReport/ReportOfCase.aspx",post,header,"charset: utf-8")
					arr.insert(RegExReplace(clipboard:=post,"is)^.+(http:\/\/hisaw\.ntuh\.gov\.tw\/WebApplication\/InspectionReport\/ReportSheet\.aspx\?SESSION=" sid "[^\\]+).+$","$1"))
					if (PostBack!="")
						break
				}
			}
			return arr
		}
	}
	StringUpper(str){
		StringUpper,str,str
		return str
	}
	func1(str){
		str:=RegExReplace(str,"(\%\d)b","$1B")
		str:=RegExReplace(str,"(\%\d)a","$1A")
		str:=RegExReplace(str,"(\%\d)d","$1D")
		str:=RegExReplace(str,"(\%\d)c","$1C")
		str:=RegExReplace(str,"(\%\d)e","$1E")
		str:=RegExReplace(str,"(\%\d)f","$1F")
		return str
	}
}

/*
POST http://hiswsvc.ntuh.gov.tw/HL7Central_IIS/Central.asmx HTTP/1.1
User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; MS Web Services Client Protocol 2.0.50727.3053)
Content-Type: text/xml; charset=utf-8
SOAPAction: "http://localhost/HL7Central/HL7Port"
Host: hiswsvc.ntuh.gov.tw
Content-Length: 763
Expect: 100-continue

<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><HL7Port xmlns="http://localhost/HL7Central/"><HL7Input>&lt;QBP_Z10&gt;&lt;MSH&gt;&lt;MSH.3&gt;&lt;HD.1&gt;WebPageID&lt;/HD.1&gt;&lt;/MSH.3&gt;&lt;MSH.7&gt;&lt;TS.1&gt;20151023084922.2880&lt;/TS.1&gt;&lt;/MSH.7&gt;&lt;MSH.9&gt;&lt;MSG.2&gt;Z01&lt;/MSG.2&gt;&lt;/MSH.9&gt;&lt;/MSH&gt;&lt;PV1&gt;&lt;PV1.2&gt;I&lt;/PV1.2&gt;&lt;PV1.3&gt;&lt;PL.11&gt;&lt;HD.1&gt;T0&lt;/HD.1&gt;&lt;/PL.11&gt;&lt;/PV1.3&gt;&lt;PV1.19&gt;&lt;CX.1&gt;15T01440976&lt;/CX.1&gt;&lt;/PV1.19&gt;&lt;/PV1&gt;&lt;/QBP_Z10&gt;</HL7Input></HL7Port></soap:Body></soap:Envelope>


<QBP_Z10><MSH><MSH.3><HD.1>WebPageID</HD.1></MSH.3><MSH.7><TS.1>20151023084922.2880</TS.1></MSH.7><MSH.9><MSG.2>Z01</MSG.2></MSH.9></MSH><PV1><PV1.2>I</PV1.2><PV1.3><PL.11><HD.1>T0</HD.1></PL.11></PV1.3><PV1.19><CX.1>15T01440976</CX.1></PV1.19></PV1></QBP_Z10>



response:
HTTP/1.1 200 OK
Date: Fri, 23 Oct 2015 00:49:20 GMT
Server: Microsoft-IIS/6.0
X-Powered-By: ASP.NET
X-AspNet-Version: 2.0.50727
Cache-Control: private, max-age=0
Content-Type: text/xml; charset=utf-8
Content-Length: 11269

<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><HL7PortResponse xmlns="http://localhost/HL7Central/"><HL7PortResult>&lt;BAR_Z01&gt;&lt;PID&gt;&lt;PID.3&gt;&lt;CX.1&gt;A102151725&lt;/CX.1&gt;&lt;/PID.3&gt;&lt;/PID&gt;&lt;BAR_Z01.VISIT&gt;&lt;PV1&gt;&lt;PV1.2&gt;I&lt;/PV1.2&gt;&lt;PV1.3&gt;&lt;PL.11&gt;&lt;HD.1&gt;T0&lt;/HD.1&gt;&lt;HD.2&gt;EMER&lt;/HD.2&gt;&lt;HD.3&gt;NA&lt;/HD.3&gt;&lt;/PL.11&gt;&lt;/PV1.3&gt;&lt;PV1.19&gt;&lt;CX.1&gt;15T01440976&lt;/CX.1&gt;&lt;/PV1.19&gt;&lt;/PV1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;M&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;486&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Pneumonia&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;694.9&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Bullous dermatosis&lt;/ZDG1.4&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;692.9&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Eczema, chronic&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02,16&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;698.9&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Pruritus&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;879.8&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Wound&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;04&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;707.0&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Pressure sore&lt;/ZDG1.4&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;332.0&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Parkinsonism (F02.3)&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;331.4&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Hydrocephalus&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;300.4&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Mixed depression and anxiety&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;333.0&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Multiple system atrophy (MSA)&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;437.0&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Cerebral atherosclerosis&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;01,02,22&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;564.0&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Constipation&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;401.9&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Hypertension&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;V70.0&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Health examination&lt;/ZDG1.4&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;600.0&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Hypertrophy (benign) of prostate&lt;/ZDG1.4&gt;&lt;ZDG1.5&gt;02,14&lt;/ZDG1.5&gt;&lt;ZDG1.6&gt;103667&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.29.39&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;103667&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;103667&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.16.29.39&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151020151140.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;/BAR_Z01.VISIT&gt;&lt;/BAR_Z01&gt;</HL7PortResult></HL7PortResponse></soap:Body></soap:Envelope>


<BAR_Z01><PID><PID.3><CX.1>A102151725</CX.1></PID.3></PID><BAR_Z01.VISIT><PV1><PV1.2>I</PV1.2><PV1.3><PL.11><HD.1>T0</HD.1><HD.2>EMER</HD.2><HD.3>NA</HD.3></PL.11></PV1.3><PV1.19><CX.1>15T01440976</CX.1></PV1.19></PV1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>M</ZDG1.2><ZDG1.3>486</ZDG1.3><ZDG1.4>Pneumonia</ZDG1.4><ZDG1.5>02</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>694.9</ZDG1.3><ZDG1.4>Bullous dermatosis</ZDG1.4><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>692.9</ZDG1.3><ZDG1.4>Eczema, chronic</ZDG1.4><ZDG1.5>02,16</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>698.9</ZDG1.3><ZDG1.4>Pruritus</ZDG1.4><ZDG1.5>02</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>879.8</ZDG1.3><ZDG1.4>Wound</ZDG1.4><ZDG1.5>04</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>707.0</ZDG1.3><ZDG1.4>Pressure sore</ZDG1.4><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>332.0</ZDG1.3><ZDG1.4>Parkinsonism (F02.3)</ZDG1.4><ZDG1.5>02</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>331.4</ZDG1.3><ZDG1.4>Hydrocephalus</ZDG1.4><ZDG1.5>02</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>300.4</ZDG1.3><ZDG1.4>Mixed depression and anxiety</ZDG1.4><ZDG1.5>02</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>333.0</ZDG1.3><ZDG1.4>Multiple system atrophy (MSA)</ZDG1.4><ZDG1.5>02</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>437.0</ZDG1.3><ZDG1.4>Cerebral atherosclerosis</ZDG1.4><ZDG1.5>01,02,22</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>564.0</ZDG1.3><ZDG1.4>Constipation</ZDG1.4><ZDG1.5>02</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>401.9</ZDG1.3><ZDG1.4>Hypertension</ZDG1.4><ZDG1.5>02</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>V70.0</ZDG1.3><ZDG1.4>Health examination</ZDG1.4><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1><ZDG1><ZDG1.1>I</ZDG1.1><ZDG1.2>O</ZDG1.2><ZDG1.3>600.0</ZDG1.3><ZDG1.4>Hypertrophy (benign) of prostate</ZDG1.4><ZDG1.5>02,14</ZDG1.5><ZDG1.6>103667</ZDG1.6><ZDG1.7><TS.1>20151020151140.0000</TS.1></ZDG1.7><ZDG1.8>172.16.29.39</ZDG1.8><ZDG1.9>103667</ZDG1.9><ZDG1.10><TS.1>20151020151140.0000</TS.1></ZDG1.10><ZDG1.11>Y</ZDG1.11><ZDG1.13>103667</ZDG1.13><ZDG1.14>172.16.29.39</ZDG1.14><ZDG1.15><TS.1>20151020151140.0000</TS.1></ZDG1.15><ZDG1.16>I</ZDG1.16><ZDG1.17>N</ZDG1.17></ZDG1></BAR_Z01.VISIT></BAR_Z01>
*/
PacsWebInfo(byref output,AccNo,chartNo="",loginId="",loginPw="",count="1500"){
	;~ url:="http://pacsmobile.ntuh.gov.tw/?user=" loginId "&password=" loginPw "&tab=Display&PatientID=" chartNo "&AccessionNumber=" AccNo "&theme=epr"
	;~ header=
	;~ ( ltrim
	;~ Referer: http://pacswide.ntuh.gov.tw:8080/kQuery.php
	;~ Host: pacsmobile.ntuh.gov.tw
	;~ )
	;~ httprequest(url,post,header)
	;~ clipboard:=header "`n`n" post
	;~ exitapp
	
	url:="http://pacsmobile.ntuh.gov.tw/wado/?v=2.0.SU3.3&requestType=STUDY&contentType=text/javascript&maxResults=250&PatientID=" chartNo "&AccessionNumber=" AccNo "&ae=local&IssuerOfPatientID=&groupByIssuer=*&language=zh_TW&user=" loginId "&password=" loginPw 
	header=
	( Ltrim
	Referer: http://pacsmobile.ntuh.gov.tw/?&tab=Display&PatientID=%chartNo%&AccessionNumber=%AccNo%&theme=epr
	Host: pacsmobile.ntuh.gov.tw
	)
	httprequest(url,post:="",header)
	;~ clipboard:=post
	regexmatch(post,"(?<=studyUID=)[^&]+",studyUID)
	;~ regexmatch(post,"(?<=Count=)[^&]+",count)
	;~ count:=2
	regexmatch(post,"(?<=""ver"":"")[^""]+",ver)
	
	url:="http://pacsmobile.ntuh.gov.tw/wado/?v=2.0.SU3.3&requestType=IMAGE&contentType=text/javascript&regroup=*&studyUID=" (studyUid) "&Position=0&Count=" 1 "&ver=" ver "&ae=local&language=zh_TW&user=" loginId "&password=" loginPw 
	header=
	( Ltrim
	Referer: http://pacsmobile.ntuh.gov.tw/?&tab=Display&PatientID=%chartNo%&AccessionNumber=%AccNo%&theme=epr
	Host: pacsmobile.ntuh.gov.tw
	)
	httprequest(url,post,header)
	
	
	json:=json_from(post)
	if(!isobject(output))
		output:=[]
	
	output.studyUID:=json.children.1.children.1.studyUID
	output.url:=PacsWebUrlTrans(json.children.1.children.1.url)
	
	header=
	( Ltrim
	Referer: http://pacsmobile.ntuh.gov.tw/?&tab=Display&PatientID=%chartNo%&AccessionNumber=%AccNo%&theme=epr
	Host: pacsmobile.ntuh.gov.tw
	)
	
	ind:=0
	for k,v in json.children.1.children.1.children {
		if (v.seriesUID="")
			continue
		++ind
		output[ind]:=[]
		output[ind,"seriesUID"]:=v.seriesUID
		output[ind,"url"]:=PacsWebUrlTrans(v.url)
		
		url:="http://pacsmobile.ntuh.gov.tw/wado/?v=2.0.SU3.3&" regexreplace(substr(v.url,2),"i)&url=true&regroup=true","") "&user=" loginId "&password=" loginPw "&contentType=text/javascript&regroup=*&ver=" ver
		;~ url:=regexreplace(url,"i)&url=true&regroup=true","") 
		httprequest(url,post:="",header1:=header)
		
		json2:=json_from(post)
		
		ind2:=0
		
		for x,y in json2.children.1.children.1.children {
			if (y.seriesUID=v.seriesUID){
				ind3:=x
				break
			}
		}
		
		for x,y in json2.children.1.children.1.children[ind3].children {
			if(y.objectUID="")
				continue
			++ind2
			output[ind,ind2,"objectUID"]:=y.objectUID
			output[ind,ind2,"url"]:=PacsWebUrlTrans(y.url)
		}
	}
	return output
	
}

PacsWebInfoFlatten(byref result){
	output:=[]
	for k,v in result
		if isobject(v)
			for x,y in v
				if isobject(y) && y.hasKey("ObjectUID")
					output.insert(y)
	return output
}

PacsWebUrlTrans(url){
	regexmatch(url,"is)(?<=studyUID=)[\d\.]+",studyUID)
	regexmatch(url,"is)(?<=seriesUID=)[\d\.]+",seriesUID)
	regexmatch(url,"is)(?<=objectUID=)[\d\.]+",objectUID)
	return "http://pacsmobile.ntuh.gov.tw/wado/?v=2.0.SU3.3&requestType=XERO" (studyUID?"&studyUID=" studyUID:"") (seriesUID?"&seriesUID=" seriesUID:"") (objectUID?"&objectUID=" objectUID:"") "&language=zh_TW&ae=local"
}

PacsWebUrl(AccNo,chartNo="",loginId="",loginPw=""){
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	return "http://pacsmobile.ntuh.gov.tw/?user=" loginId "&password=" loginPw "&tab=Display&PatientID=" chartNo "&AccessionNumber=" AccNo "&theme=epr"
}

WebTemp(accNo,chartNo,loginId,loginPw){
	global JSESSIONID,JSESSIONSSO
	candidates1:="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-_"
	candidates2:="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	JSESSIONID:=JSESSIONSSO:=""
	loop 24 {
		random,rand,1,% strlen(candidates1)
		JSESSIONID.=substr(candidates1,rand,1)
	}
	loop 32 {
		random,rand,1,% strlen(candidates2)
		JSESSIONSSO.=substr(candidates2,rand,1)
	}
	
	url:="http://pacsmobile.ntuh.gov.tw/?user=" loginId "&password=" loginpw "&tab=Display&PatientID=" chartNo "&AccessionNumber=" AccNo "&theme=epr"
	header=
	(
	Referer: http://pacswide.ntuh.gov.tw:8080/kQuery.php
	Host: pacsmobile.ntuh.gov.tw
	Cookie: JSESSIONID=%JSESSIONID%; JSESSIONIDSSO=%JSESSIONIDSSO%; xero-viewport-size=1024/643
	)
	httprequest(url,post:="",header)
	
}

PacsWebDownloadJpeg2(url,AccNo,chartNo,fileName="",folder="",PicWidth="",loginId="",loginPw="",retry=3,fileSize=100,first=1){
	
	;~ global JSESSIONID,JSESSIONSSO
	
	;~ if(!JSESSIONID || !JSESSIONSSO)
		;~ PacsWebTemp(AccNo,chartNo,loginId,loginPw)

	
	
	if(first=1){
		;~ url:=PacsWebUrl(AccNo,chartNo,loginId,loginPw)
		;~ header:="Host: pacsmobile.ntuh.gov.tw`nReferer: http://pacswide.ntuh.gov.tw:8080/kQuery.php"
		;~ httprequest(url,post:="",header)
		
		
		while strlen(chartNo)<7
			chartNo:="0" chartNo
		
		if !instr(url,"user=")
			url.="&user=" loginId
		if !instr(url,"password=")
			url.="&password=" loginPw
		
		if (!instr(url,"rows="))
			url.="&rows=" (PicWidth?PicWidth:a_screenwidth)
		else if PicWidth
			url:=RegExReplace(url,"(?<=rows=)[^&]+",PicWidth)
	}
	
	;~ url:="http://pacsmobile.ntuh.gov.tw/wado/?v=2.0.SU3.3&requestType=XERO&studyUID=1.2.124.113532.80.22187.2757.20130629.230919.702675561&seriesUID=1.2.840.113619.2.80.667156916.17002.1372519080.40.4.1&language=zh_TW&objectUID=1.2.840.113619.2.80.667156916.17002.1372519083.55&ae=local&user=100860&password=31416"
	header=
	( LTRIM
	Referer: http://pacsmobile.ntuh.gov.tw/?&tab=Display&PatientID=%chartNo%&AccessionNumber=%AccNo%&theme=epr
	Host: pacsmobile.ntuh.gov.tw
	)
	httprequest(url,post:="",header,"charset: utf-8`nbinary")
	;~ msgbox % post
	;~ clipboard:=header
	
	
	
	if (folder="")
		folder:=A_ScriptDir
	if (filename="")
		filename:=AccNo " " chartNo " 1.jpeg"
	
	regexmatch(header,"(?<=Content-Length: )\d+",len)
	filedelete,% folder "\" filename
	if !InStr(FileExist(folder), "D")
		FileCreateDir,% folder
	if (len>fileSize)
		bytes:=BinWrite(folder "\" filename,post,len)
	
	if(bytes>100){
		return 0
	}else if (--retry<1){
		return -1
	}else
		return PacsWebDownloadJpeg2(url,AccNo,chartNo,fileName,folder,PicWidth,loginid,loginpw,retry,fileSize,0)
}

PacsWebDownloadJpeg(AccNo,chartNo="",fileName="",folder="",PicWidth="",loginid="",loginpw="",retry=3,fileSize=100){
	static tried

	++tried
	
	if (chartNo!="")
		while strlen(chartNo)<7
			chartNo:="0" chartNo
	
	url:=PacsWebUrl(AccNo,chartNo,loginId,loginPw)
	header:="Host: pacsmobile.ntuh.gov.tw`nReferer: http://pacswide.ntuh.gov.tw:8080/kQuery.php"
	httprequest(url,post:="",header)

	regexmatch(post,"i)wado\/\?v=[^\ \""]+",match)
	StringReplace,match,match,&amp;,&,all
	
	url:="http://pacsmobile.ntuh.gov.tw/" match
	url:=RegExReplace(url,"\d+$",picWidth?picWidth:a_screenwidth)
	header:="Referer: http://pacsmobile.ntuh.gov.tw/?&tab=Display&PatientID=" chartNo "&AccessionNumber=" AccNo "&theme=epr`nHost: pacsmobile.ntuh.gov.tw"
	httprequest(url,post:="",header1:=header,"charset: utf-8`nbinary")
	
	
	if (folder="")
		folder:=A_ScriptDir
	if (filename="")
		filename:=AccNo " " chartNo " 1.jpeg"
	
	regexmatch(header1,"(?<=Content-Length: )\d+",len)
	
	filedelete,% folder "\" filename
	bytes:=BinWrite(folder "\" filename,post,len)
	
	if(bytes>100)
		return 0
	else if (tried>=retry)
		return tried
	else
		return PacsWebDownloadJpeg(AccNo,chartNo,fileName,folder,PicWidth,loginid,loginpw,retry,fileSize)
	
}

PacsWebLogin(loginid,loginpw){
	global pacsWebPhpid
	
	if (pacsWebPhpId=""){
		httprequest("http://pacswide.ntuh.gov.tw:8080/",post:="",header:="","charset: utf-8")
		RegExMatch(header,"i)PHPSESSID=(\w+)",match)
		pacsWebPhpId:=match1
	}
	
	url:="http://pacswide.ntuh.gov.tw:8080/auth_ntuh.php"
	header:="Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */*`nReferer: http://pacswide.ntuh.gov.tw:8080/`nAccept-Language: zh-tw`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322; .NET4.0C; .NET4.0E)`nContent-Type: application/x-www-form-urlencoded`nAccept-Encoding: gzip, deflate`nHost: pacswide.ntuh.gov.tw:8080`nConnection: Keep-Alive`nPragma: no-cache`nCookie: PHPSESSID=" pacsWebPhpId
	post:="account=" loginId "&pwd=" loginPw "&signIn=%E7%99%BB%E5%85%A5"
	
	httprequest(url,post,header,"charset: utf-8")
	
	if instr(post,"﻿﻿<script language='javascript'>location.replace('kQuery.php')</script>")
		return 1
	else
		return 0
}

PacsWebQuery(chartNo,hospital="1",pageLimit=3){
	global pacsWebPhpId
	
	while strlen(chartNo)<7
		chartNo:="0" chartNo
	
	
	url:="http://pacsweb.ntuh.gov.tw/gXWL.php"
	header:="x-requested-with: XMLHttpRequest`nAccept-Language: zh-tw`nReferer: http://pacswide.ntuh.gov.tw:8080/kQuery.php`nAccept: text/html, */*; q=0.01`nContent-Type: application/x-www-form-urlencoded; charset=UTF-8`nAccept-Encoding: gzip, deflate`nUser-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322; .NET4.0C; .NET4.0E)`nHost: pacswide.ntuh.gov.tw:8080`nConnection: Keep-Alive`nPragma: no-cache`nCookie: PHPSESSID=" pacsWebPhpId
	
	;~ post:="qMethod=pt_id&hosp_id=hosp_id_01&user_hosp=01&pt_id=" chartNo "&fetchDbFlag=Y&qDirect=+&emgFlag=T"
	hospitalCode:=""
	loop,parse,hospital,`,
		hospitalCode.="hosp_id_0" a_loopfield "%2C"
	hospitalCode:=substr(hospitalCode,1,-3)
	if (hospitalCode="")
		hospitalCode:="hosp_id_01"
	post:="qMethod=pt_id&hosp_id=" hospitalCode "&user_hosp=01&pt_id=" chartNo "&fetchDbFlag=Y&qDirect=+&emgFlag=F"
	
	httprequest(url,post,headerSent:=header,"charset: utf-8")
	
	regexmatch(post,"第(\d)頁 / 共(\d)頁",match)
	
	result:=[]
	PacsWebResult(post,result)
	loop % match2-1 {
		if (pageLimit && a_index>pageLimit)
			break
		
		httprequest(url,post:="qMethod=pt_id&hosp_id=" hospitalCode "&user_hosp=01&pt_id=" chartNo "&fetchDbFlag=N&qDirect=next&emgFlag=F",headerSent:=header,"charset: utf-8")
		PacsWebResult(post,result)
	}
	
	return result
}

PacsWebResult(html,byref arr){
	dom:=ComObjCreate("HtmlFile")
	
	dom.write(html)
	
	table:=$(dom,"ptWL_table")
	loop % table.rows.length-1 {
		row:=table.rows[a_index]
		tmp:=[]
		tmp["Hospital"]:=trim(row.cells[2].innerText)
		tmp["Name"]:=trim(row.cells[3].innerText)
		tmp["Gender"]:=trim(row.cells[4].innerText)
		tmp["Age"]:=trim(row.cells[5].innerText)
		tmp["Birthday"]:=trim(row.cells[6].innerText)
		tmp["ChartNo"]:=trim(row.cells[7].innerText)
		tmp["Modality"]:=trim(row.cells[8].innerText)
		tmp["ExamDate"]:=trim(row.cells[9].innerText) ;2015/11/11 19:21:54
		tmp["AccessNo"]:=trim(row.cells[10].innerText)
		tmp["ExamName"]:=trim(row.cells[11].innerText)
		arr.insert(tmp)
	}
	
	return arr
	
}

/*POST http://hiswsvc.ntuh.gov.tw/HL7Central_IIS/Central.asmx HTTP/1.1
User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; MS Web Services Client Protocol 2.0.50727.3623)
Content-Type: text/xml; charset=utf-8
SOAPAction: "http://localhost/HL7Central/HL7Port"
Host: hiswsvc.ntuh.gov.tw
Content-Length: 763
Expect: 100-continue

<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><HL7Port xmlns="http://localhost/HL7Central/"><HL7Input>&lt;QBP_Z10&gt;&lt;MSH&gt;&lt;MSH.3&gt;&lt;HD.1&gt;WebPageID&lt;/HD.1&gt;&lt;/MSH.3&gt;&lt;MSH.7&gt;&lt;TS.1&gt;20151115114124.7158&lt;/TS.1&gt;&lt;/MSH.7&gt;&lt;MSH.9&gt;&lt;MSG.2&gt;Z01&lt;/MSG.2&gt;&lt;/MSH.9&gt;&lt;/MSH&gt;&lt;PV1&gt;&lt;PV1.2&gt;I&lt;/PV1.2&gt;&lt;PV1.3&gt;&lt;PL.11&gt;&lt;HD.1&gt;T0&lt;/HD.1&gt;&lt;/PL.11&gt;&lt;/PV1.3&gt;&lt;PV1.19&gt;&lt;CX.1&gt;15T08814901&lt;/CX.1&gt;&lt;/PV1.19&gt;&lt;/PV1&gt;&lt;/QBP_Z10&gt;</HL7Input></HL7Port></soap:Body></soap:Envelope>
*/
/*
HTTP/1.1 200 OK
Date: Sun, 15 Nov 2015 03:41:23 GMT
Server: Microsoft-IIS/6.0
X-Powered-By: ASP.NET
X-AspNet-Version: 2.0.50727
Cache-Control: private, max-age=0
Content-Type: text/xml; charset=utf-8
Content-Length: 2112

<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><HL7PortResponse xmlns="http://localhost/HL7Central/"><HL7PortResult>&lt;BAR_Z01&gt;&lt;PID&gt;&lt;PID.3&gt;&lt;CX.1&gt;A221317101&lt;/CX.1&gt;&lt;/PID.3&gt;&lt;/PID&gt;&lt;BAR_Z01.VISIT&gt;&lt;PV1&gt;&lt;PV1.2&gt;I&lt;/PV1.2&gt;&lt;PV1.3&gt;&lt;PL.11&gt;&lt;HD.1&gt;T0&lt;/HD.1&gt;&lt;HD.2&gt;SURG&lt;/HD.2&gt;&lt;HD.3&gt;NA&lt;/HD.3&gt;&lt;/PL.11&gt;&lt;/PV1.3&gt;&lt;PV1.19&gt;&lt;CX.1&gt;15T08814901&lt;/CX.1&gt;&lt;/PV1.19&gt;&lt;/PV1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;U&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;M&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;512.8&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Pneumothorax&lt;/ZDG1.4&gt;&lt;ZDG1.6&gt;100898&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20150903155518.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.16.22.30&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;100898&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20150903155518.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;100898&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.18.17.25&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151024095801.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;ZDG1&gt;&lt;ZDG1.1&gt;I&lt;/ZDG1.1&gt;&lt;ZDG1.2&gt;O&lt;/ZDG1.2&gt;&lt;ZDG1.3&gt;599.0&lt;/ZDG1.3&gt;&lt;ZDG1.4&gt;Urinary tract infection&lt;/ZDG1.4&gt;&lt;ZDG1.6&gt;100898&lt;/ZDG1.6&gt;&lt;ZDG1.7&gt;&lt;TS.1&gt;20151024095801.0000&lt;/TS.1&gt;&lt;/ZDG1.7&gt;&lt;ZDG1.8&gt;172.18.17.25&lt;/ZDG1.8&gt;&lt;ZDG1.9&gt;100898&lt;/ZDG1.9&gt;&lt;ZDG1.10&gt;&lt;TS.1&gt;20151024095801.0000&lt;/TS.1&gt;&lt;/ZDG1.10&gt;&lt;ZDG1.11&gt;Y&lt;/ZDG1.11&gt;&lt;ZDG1.13&gt;100898&lt;/ZDG1.13&gt;&lt;ZDG1.14&gt;172.18.17.25&lt;/ZDG1.14&gt;&lt;ZDG1.15&gt;&lt;TS.1&gt;20151024095801.0000&lt;/TS.1&gt;&lt;/ZDG1.15&gt;&lt;ZDG1.16&gt;I&lt;/ZDG1.16&gt;&lt;ZDG1.17&gt;N&lt;/ZDG1.17&gt;&lt;/ZDG1&gt;&lt;/BAR_Z01.VISIT&gt;&lt;/BAR_Z01&gt;</HL7PortResult></HL7PortResponse></soap:Body></soap:Envelope>
*/

getRisPatientDx(PatientAccNo,hospital="T0",patientType="I"){
	;~ random,rand,1,1000
	;~ while strlen(rand)<4
		;~ rand.="0" rand
	
	url:="http://hiswsvc.ntuh.gov.tw/HL7Central_IIS/Central.asmx"
	header:="User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; MS Web Services Client Protocol 2.0.50727.3623)`nContent-Type: text/xml; charset=utf-8`nSOAPAction: ""http://localhost/HL7Central/HL7Port""`nHost: hiswsvc.ntuh.gov.tw`nExpect: 100-continue"
	post:="<?xml version=""1.0"" encoding=""utf-8""?><soap:Envelope xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema""><soap:Body><HL7Port xmlns=""http://localhost/HL7Central/""><HL7Input>&lt;QBP_Z10&gt;&lt;MSH&gt;&lt;MSH.3&gt;&lt;HD.1&gt;WebPageID&lt;/HD.1&gt;&lt;/MSH.3&gt;&lt;MSH.7&gt;&lt;TS.1&gt;" a_now ".0001"  "&lt;/TS.1&gt;&lt;/MSH.7&gt;&lt;MSH.9&gt;&lt;MSG.2&gt;Z01&lt;/MSG.2&gt;&lt;/MSH.9&gt;&lt;/MSH&gt;&lt;PV1&gt;&lt;PV1.2&gt;" patientType "&lt;/PV1.2&gt;&lt;PV1.3&gt;&lt;PL.11&gt;&lt;HD.1&gt;" hospital "&lt;/HD.1&gt;&lt;/PL.11&gt;&lt;/PV1.3&gt;&lt;PV1.19&gt;&lt;CX.1&gt;" PatientAccNo "&lt;/CX.1&gt;&lt;/PV1.19&gt;&lt;/PV1&gt;&lt;/QBP_Z10&gt;</HL7Input></HL7Port></soap:Body></soap:Envelope>"
	
	httprequest(url,post,header,"charset: utf-8")
	
	regexmatch(post,"is)<HL7PortResult>(.*)<\/HL7PortResult>",match)
	StringReplace,match1,match1,&lt;,<,all
	StringReplace,match1,match1,&gt;,>,all
	return match1
	
}

getPacsHx(sid,patientIdorChartNo){
	if(patientIdorChartNo="")
		return
	while strlen(patientIdorChartNo)<7
		patientIdorChartNo:="0" patientIdorChartNo
	
	personId:=strlen(patientIdorChartNo)<10?patientBasicInfo(patientIdorChartNo,sid).personId:patientIdorChartNo
	
	url:="http://ihisaw.ntuh.gov.tw/WebApplication/OtherIndependentProj/PatientBasicInfoEdit/PACSImageShowList.aspx?SESSION=" sid "&PersonID=" personId
	httprequest(url, post:="", header:="", "charset: utf-8")
	
	dom:=ComObjCreate("HtmlFile")
	dom.write(post)
	arr:=[]
	rows:=$(dom,"BloodCallRecordDataGrid").rows
	
	;全選  病歷號 單號 檢查日 檢查名稱 儀器 狀態 
	loop % rows.length-1 {
		cells:=rows[a_index].cells
		arr[a_index]:=[]
		arr[a_index,"ChartNo"]:=trim(cells[1].innerText)
		arr[a_index,"AccessNo"]:=trim(cells[2].innerText)
		arr[a_index,"ExamDate"]:=trim(cells[3].innerText) ;20151019
		arr[a_index,"ExamName"]:=trim(cells[4].innerText)
		arr[a_index,"Modality"]:=trim(cells[5].innerText)
		arr[a_index,"Status"]:=trim(cells[6].innerText) ;已確認 
	}
	
	return arr
}
