;-- randomjoke with :  activeX / urldownloadtoVar / StrX
;-- AHK_L
;--------------------------------------------------
modified=20131226
filename1=RandomJoke_%modified%

setworkingdir,%a_scriptdir%
Filename1   =01100_2901333561637848669504.html

fx=http://www.kbv.de/tools/ebm/html/%Filename1%
f2=%a_scriptdir%\testjoke2.htm

Gui,2: Color, 000000

w1=755
h1=380

w2=775
h2=440

Gui,2:Add,ActiveX, x10 y10 w%w1% h%h1% vWB1, Shell.Explorer
;Gui,2:Add,ActiveX, x10 y10 w%w1% h%h1% vWB1 ,Mozilla.Browser
;Gui,2:Add,ActiveX, x10 y10 w%w1% h%h1% vWB1 ,Chrome.Browser
;Gui,2:Add,ActiveX, x10 y10 w%w1% h%h1% vWB1 ,Maxthon.Browser

hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")         ;Create the Object

Gui,2: Show,x0 y0 w%w2% h%h5%,%filename1%

WB1.Navigate(F3)

return
;-----------------------------------------------------

2Guiclose:
exitapp
;-----

mh1:
Gui,2:submit,nohide

ComObjError(false)
hObject.Open("GET",fx)                    ;Open communication
hObject.Send()                            ;Send the "get" request
aac:=hObject.ResponseText                 ;Set the  "aac" variable to the response
pars1= <p class=


;T  := StrX( aac, %pars1% ,1,0, "</p><p class",1,0 )
FileAppend, %aac%, %f2%
F3:="file:///" RegExReplace(F2,"\\","/")
WB1.Navigate(F3)
t=
aac=
filedelete,%f2%
Return
;-----------------


;--- Function StrX by user SKAN --------------------------
;--- http://www.autohotkey.com/forum/viewtopic.php?t=51354
StrX( H,  BS="",BO=0,BT=1,   ES="",EO=0,ET=1,  ByRef N="" ) { ;    | by Skan | 19-Nov-2009
Return SubStr(H,P:=(((Z:=StrLen(ES))+(X:=StrLen(H))+StrLen(BS)-Z-X)?((T:=InStr(H,BS,0,((BO
 <0)?(1):(BO))))?(T+BT):(X+1)):(1)),(N:=P+((Z)?((T:=InStr(H,ES,0,((EO)?(P+1):(0))))?(T-P+Z
 +(0-ET)):(X+P)):(X)))-P) ; v1.0-196c 21-Nov-2009 www.autohotkey.com/forum/topic51354.html
}
;===========================================================================================
