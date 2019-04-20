CSV_(){
return true
if (p="QBO"){
for each,v in ["TRNTYPE","DTPOSTED","DTUSER","DTAVAIL","TRNMT","FITID","CORRECTFITID","CORRECTACTION","SRVRTID","CHECKNUM","REFNUM","SIC","PAYEEID","NAME"]{
if isobject(k)
if k[v]
ret.="<" v ">" k[v]
else if O:=m(k, v ">?([[:print:]]*)")
ret.="<" v ">" O.1
}return ret
}
}

CSV_Cut(file="E:\AH\icmg_.txt",endfile="E:\AH\tst.txt",TransLimit=10000,startD=2010101){
; SetFormat, Float, 0.2
Transnum:=0,pos:=1,delete(endfile),P:=splitpath(file),endP:=splitpath(endfile),txt:=r(sr(read(file),","),"`r`n","`n")
while RegExmatch(txt,"sm)LAST STATEMENT \.{2,} \d\d\/\d\d\/\d\d (?P<lastbal>[\d]{0,15}\.\d\d)(?P<in>[^ ])?",m) {
RegExmatch(txt,"sm)" m "(?P<Trans>..+?)BALANCE THIS STATEMENT \.{2,} (?P<Date>\d\d\/\d\d\/\d\d) (?P<end_Bal>[\,\d]+\.\d\d)(?P<min>[^ ])?..+?(?P<etc>TOTAL CREDITS..+?TOTAL DEBITS..+?)[-=\*]",_)
lastbal:=min mlastbal,_end_Bal:=_min _end_Bal,txt:=sr(txt,_)
; o:=RegExMatch(_trans,"sm)\d{0,15}\.\d\d\K[^ ]",D)
_trans:=r(_trans,"m)([[:alpha:]])[-]" D,"$1")
r(_trans,"sm).*(\d{0,15}\.\d\d)([^ ]).*","$2$1 ")
T(a)
o:=RegExMatch(_trans,"sm)\.\d\d \d\d\/\d\d\/\d\d [\d]+\.\d\d[^ ]",ma)

t(neg:=r(_trans,"sm).*?([a-zA-Z][\w\d- #]+ \n?)(\d{0,10}\.\d\d) (\d\d\/\d\d\/\d\d) ([\d]+\.\d\d)([^ ]).*","$1$2 $3 $5$4"))

RegExMatch(neg,"sm)(?P<NAME>[a-zA-Z][\w\d- #]+) \n?(?P<TRNAMT>[\,\d]{0,10}\.\d\d) (?P<DTPOSTED>\d\d\/\d\d\/\d\d)(?P<bal>[^.]*[.]\d\d)(?P<min>[^ ])?",MA)
msg(isneg(mabal))
if (date:=r(_Date,"([\d][\d])/([\d][\d])/([\d][\d])","20$3$1$2"))<startd
continue
info.=Idate:=r(_Date,"([\d][\d])/([\d][\d])/([\d][\d])","20$3-$1-$2") " (" lastbal ") - (" _end_bal ")`n" _etc "`n"
while (transnum!=TransLimit) and pos:=RegExMatch(_trans,"sm)(?P<NAME>[a-zA-Z][\w\d- #]+) \n?(?P<TRNAMT>[\,\d]{0,10}\.\d\d) (?P<DTPOSTED>\d\d\/\d\d\/\d\d) (?P<bal>[\d-]+\.\d\d)(?P<min>[^ ])?",T_,pos+=T_.l){
(lastbal>(T_bal:=T_min T_bal)?(T_TRNAMT:="-" T_TRNAMT,T_TRNTYPE:="DEBIT"):T_TRNTYPE:="CREDIT"),lastbal:=T_bal
Checknum:=instr(T_name,"CHECK # ")?"<CHECKNUM>" r(T_name,"[^0-9]*","") "`n":""
toApp.="<STMTTRN>`n<TRNTYPE>" T_TRNTYPE "`n<DTPOSTED>" r(T_DTPOSTED,"([\d][\d])/([\d][\d])/([\d][\d])","20$3$1$2") "`n<TRNAMT>" T_TRNAMT FITID:="`n<FITID>" Now() "0" ++Transnum "`n" Checknum "<NAME>" substr(T_NAME,1,31) "`n</STMTTRN>`n"
}T_:="",pos:=1 ; toapp.=trans(T_trans,lastbal,T_endT_Bal,endfile,TransLimit)

}
RegExMatch(toapp,"sm)^..*<FITID>\d+0(?P<num>[\d]+)",fit)
HD:=read("E:\AH\QBO\HD.qbo") "`n"
FT:=read("E:\AH\QBO\FT.qbo")
FT:=r(FT,"<BALAMT>\K(.*)",_end_bal)
FT:=r(FT,"<DTASOF>\K(.*)",Date)
append(info,"info.txt")
endfile:=endp.dir "\" endp.nno " - " Transnum " Trans - " _end_Bal "." endp.ext
append(ltrim(HD "`n" toapp FT,"`r`n"),endfile)
}
billpay(CSVTOCONVERT="E:\Downloads\csv.csv",NEWCSV="E:\Downloads\csv.qbo"){
Tags:=["TRNTYPE","DTPOSTED","DTUSER","DTAVAIL","TRNAMT","FITID","CORRECTFITID","CORRECTACTION","SRVRTID","CHECKNUM","REFNUM","SIC","PAYEEID","NAME","NAME"]
; CSVTOCONVERT=E:\Downloads\csv.csv
; NEWCSV=E:\Downloads\csv.qbo
FileDELETE, %NEWCSV%
FileReadLine, H, %CSVTOCONVERT%, 1
H:=regexreplace(H,"TotalPayment")
H:=regexreplace(H,"Payment Type","<CHECKNUM>") ; Payment
H:=RegExReplace(H,"<?Amount>?","<TRNAMT>")
H:=RegExReplace(H,"<?Category>?","<MEMO>")
H:=regexreplace(H,"<?To>?","<NAME>")
Loop, Parse, H, CSV
Col%A_index%:=A_LoopField
FileRead, V, %CSVTOCONVERT%
regexmatch(v,".*",m),v:=sr(v,m)
V:=regexreplace(V,"\$?([\d]+)`,?([\d])","$1$2") ; $ and , from Amount if exist
V:=trim(V," `t`r`n"),i:=5432100000
Loop, Parse, V,`n
{
a.="<STMTTRN>`n"
if instr(A_LoopField,"Check#")
a.="<TRNTYPE>CHECK`n"
else,if instr(A_LoopField,"""-")
a.="<TRNTYPE>DEBIT`n"
else, ; if instr(A_LoopField,"""-")
a.="<TRNTYPE>CREDIT`n"
if d:=R(A_LoopField,".*([\d]{2})\/([\d]{2})\/([\d]{4}).*","$3$1$2")
a.="<DTPOSTED>" d "`n"
    Loop, Parse, A_LoopField, CSV
    {
    if !(A_LoopField AND Col%A_index%)
    continue
    if (Col%A_index% ="<TRNAMT>")
    a.="<FITID>" i++ "`n" ; O[Col%A_index%]:=A_LoopField
    else,a.= Col%A_index%  A_LoopField "`n"
    }
a.="</STMTTRN> `n`n"
}v:=a,V:=R(V,"<?(DeliveryOn|MEMO|Status|TotalPayment)>?.+?\R") ;
V:=sr(V,"Check#"),v:=r(v,"<CHECKNUM>PMT\R+")
t(append(v,newcsv))
}




;== OLD
new_csv(file="E:\AH\icmg_.txt",endfile="E:\AH\tst.txt",TransLimit=10000,startD=20150101){
Transnum:=0
SetFormat, Float, 0.2
delete(endfile)
P:=splitpath(file),endP:=splitpath(endfile)
txt:=r(sr(read(file),","),"`r`n","`n")
; append(r(txt,"sm)([\d]{0,15}\.\d\d)([^ ]{2})","$2$1 "),"E:\AH\minus.txt")
loop {
if !RegExmatch(txt,"sm)LAST STATEMENT \.{2,} \d\d\/\d\d\/\d\d (?P<lastbal>[\d]{0,15}\.\d\d)(?P<in>[^ ])?",m)
break
lastbal:=(min?"-":"")mlastbal
RegExmatch(txt,"sm)" m "(?P<Trans>..+?)BALANCE THIS STATEMENT \.{2,} (?P<Date>\d\d\/\d\d\/\d\d) (?P<end_Bal>[\,\d]+\.\d\d)(?P<min>[^ ])?..+?(?P<etc>TOTAL CREDITS..+?TOTAL DEBITS..+?)[-=\*]",_)
_end_Bal:=(_min?"-":"")_end_Bal,txt:=sr(txt,_),_trans:=r(_trans,"sm)(\d{0,15}\.\d\d)([^ ])","$2$1 ")
_Date:=r(_Date,"([\d][\d])/([\d][\d])/([\d][\d])","20$3$1$2")
if (_date<startd)
continue
info.="E:\AH\" sr(_Date,"/","-") " (" lastbal ") - (" _end_bal ")`n" _etc "`n"
ninfo.="`n"_trans "`n" lastbal "`n" _end_bal

;==================================
loop {
if (!RegExMatch(_trans,"sm)(?P<NAME>[a-zA-Z][\w\d- #]+) \n?(?P<TRNAMT>[\,\d]{0,10}\.\d\d) (?P<DTPOSTED>\d\d\/\d\d\/\d\d) (?P<bal>[\d]+\.\d\d)(?P<min>[^ ])?",T_)) OR (transnum==TransLimit)
break
name:="<PAYEEID>",T_bal:=(T_min?"-":"")T_bal,name:="<NAME>"
if (lastbal>T_bal)
T_TRNAMT:="-" T_TRNAMT,T_TRNTYPE:="DEBIT"
else,T_TRNTYPE:="CREDIT",name:="<NAME>"
T_DTPOSTED:=r(T_DTPOSTED,"([\d][\d])/([\d][\d])/([\d][\d])","20$3$1$2"),rem:=strreplace(rem,T_)
lastbal:=T_bal,FITID:="`n<FITID>" a_now "000" Transnum "`n"
if instr(T_name,"CHECK # ")
name:="<NAME>",Checknum:="<CHECKNUM>" r(T_name,"[^0-9]*","") "`n"
else,Checknum:=""
if instr(T_name,"CHECK # ")
continue
Transnum++,toApp.="<STMTTRN>`n<TRNTYPE>" T_TRNTYPE "`n<DTPOSTED>" T_DTPOSTED "`n<TRNAMT>" T_TRNAMT FITID Checknum name substr(T_NAME,1,31) "`n</STMTTRN>`n"
}
; toapp.=trans(_trans,lastbal,_end_Bal,endfile,TransLimit) ==================================

}
RegExMatch(toapp,"sm)^..*<FITID>\d+000(?P<num>[\d]+)",fit)
HD:=read("E:\AH\QBO\HD.qbo") "`n"
FT:=read("E:\AH\QBO\FT.qbo")
FT:=r(FT,"<BALAMT>\K(.*)",_end_bal)
_Date:=r(_Date,"([\d][\d])\/([\d][\d])\/([\d][\d])","20$3$1$2")
FT:=r(FT,"<DTASOF>\K(.*)",_Date)
append(info ninfo,"info.txt")
endfile:=endp.dir "\" endp.nno "(" fitnum " Trans)(" _end_Bal ")." endp.ext
append(HD "`n" toapp FT,endfile)
}
