#include AccLib.ahk
global dbfile:="TestDB.mdb"
global dbpassword:="268423"
nmbr:=
gid:=:

Gui,default
Gui,Add,ListView,x2 y2 w776 h405 ginf vmyl AltSubmit Grid -Multi,ID|USER NAME|PASSWORD|NAME|LAST NAME
Gui,Add,Button,x795 y33 w85 h22 gadd,Add New
Gui,Add,Button,x795 y60 w85 h22 gedt,Modify (F2)
Gui,Add,Button,x795 y87 w85 h22 gdel,Delete (Del)
Gui,Add,Button,x795 y114 w85 h22 grefresh,Refresh (F5)
Gui,Add,Button,x795 y142 w85 h49 gguiclose,Close
Gui,Show,,[trksyln] - %dbfile%

goto,refresh
~F5::
refresh:
query= 
 (
 SELECT * FROM Members ORDER BY id
 )

AccLib("SELECT * FROM Members ORDER BY id")

LV_Delete()
LV_ModifyCol(1,45)
LV_ModifyCol(2,150)
LV_ModifyCol(3,150)
LV_ModifyCol(4,150)
LV_ModifyCol(5,200)
loop,%total%  
  {
  id := % Read["id",a_index]
  username := % Read["username",A_Index]
  pw := % Read["pw",A_Index]
  name := % Read["name",A_Index]
  lastname := % Read["lastname",A_Index]
  LV_Add("",id,username,pw,name,lastname)
}
return


GuiClose:
ExitApp


inf:
if A_GuiEvent = Normal
{
  nmbr := LV_GetNext(0,"")
LV_GetText(gid, A_EventInfo,1)
}
return


del:
~DEL::
if (gid =""){
MsgBox, 4096,Error, Select one first!
return
}
LV_Delete(nmbr)
query_del =
(
DELETE From Members Where id=%gid%
)
AccLib(  query_del)
nmbr:=
gid:=
return


add:
gui,addmenu:destroy
Gui,addmenu:Add,Edit,x79 y9 w164 h21 vauname,
Gui,addmenu:Add,Edit,x79 y34 w164 h21 vapass,
Gui,addmenu:Add,Edit,x79 y59 w164 h21 vaname,
Gui,addmenu:Add,Edit,x80 y83 w164 h21 valname,
Gui,addmenu:Add,Text,x7 y11 w69 h17,User name:
Gui,addmenu:Add,Text,x8 y37 w69 h17,Password:
Gui,addmenu:Add,Text,x8 y64 w69 h17,Name:
Gui,addmenu:Add,Text,x8 y89 w69 h17,Last name:
Gui,addmenu:Add,Button,x53 y112 w71 h23 Default gaddsave,Save
Gui,addmenu:Add,Button,x138 y112 w71 h23 gaddmenuguiclose,Cancel
Gui,addmenu:Show,,Add
return

addsave:
SetTimer,addsave1,1
return
addsave1:
SetTimer,addsave1,off
gui,addmenu:submit,nohide
if(auname = "" or apass = "" or aname = "" or alname = ""){
MsgBox, 4096,Error, Fill form first!
return
}
query_add =
(
INSERT INTO Members ( username, pw, name, lastname)
VALUES ( '%auname%', '%apass%','%aname%', '%alname%' )
)
AccLib(  query_add)

get_id= 
 (
 SELECT * FROM Members Order by id desc
 )
AccLib(get_id)
  id2 := % Read["id",1]
  LV_Add("",id2,auname,apass,aname,alname)
 gui,addmenu:destroy
 return
 

edt:
~F2::
if(gid = ""){
MsgBox, 4096,Error, Select one first!
return
}
query_edit= 
 (
 SELECT * FROM Members Where id=%gid%
 )
 AccLib(  query_edit)
  id := % Read["id",1]
  username := % Read["username",1]
  pw := % Read["pw",1]
  name := % Read["name",1]
  lastname := % Read["lastname",1]

 
gui,editmenu:destroy
Gui,editmenu:Add,edit,x7 y11 w69 h17 hidden venm,%nmbr%
Gui,editmenu:Add,edit,x7 y11 w69 h17 hidden veid,%gid%
Gui,editmenu:Add,Edit,x79 y9 w164 h21 veuname,%username%
Gui,editmenu:Add,Edit,x79 y34 w164 h21 vepass,%pw%
Gui,editmenu:Add,Edit,x79 y59 w164 h21 vename,%name%
Gui,editmenu:Add,Edit,x80 y83 w164 h21 velname,%lastname%
Gui,editmenu:Add,Text,x7 y11 w69 h17,User name:
Gui,editmenu:Add,Text,x8 y37 w69 h17,Password:
Gui,editmenu:Add,Text,x8 y64 w69 h17,Name:
Gui,editmenu:Add,Text,x8 y89 w69 h17,Last name:
Gui,editmenu:Add,Button,x53 y112 w71 h23 geditsave Default,Save
Gui,editmenu:Add,Button,x138 y112 w71 h23 geditmenuguiclose,Cancel
Gui,editmenu:Show,,Edit
nmbr:=
gid:=
return



editsave:
SetTimer,editsave1,1
return
editsave1:
SetTimer,editsave1,off
gui,editmenu:submit,nohide
if(euname = "" or epass = "" or ename = "" or elname = ""){
MsgBox, 4096,Error, Fill form first!
return
}
query_esave =
(
UPDATE Members SET username='%euname%', pw='%epass%', name='%ename%', lastname='%elname%'  Where id = %eid%
)
LV_Modify(enm,"",eid,euname,epass,ename,elname)
 AccLib(  query_esave)
 gui,editmenu:destroy
 return
 
 
 
editmenuguiclose:
gui,editmenu:destroy
return
addmenuguiclose:
gui,addmenu:destroy
return