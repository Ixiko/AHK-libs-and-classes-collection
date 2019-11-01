; <AutoHotkey L>

#include %A_ScriptDir%\..\class_ALD.ahk
conn := new ALD.Connection("https://ahk4.net/user/maulesel/api")

item_list := conn.getItemList()
for each, item in item_list
{
	items .= "  - {" . item.id . "} " . item.name . " ( " . item.version . " )`n"
}
MsgBox Uploaded items:`n`n%items%

user_list := conn.getUserList()
for each, user in user_list
{
	users .= "  - " . user . "`n"
}
MsgBox Registered users:`n`n%users%

list := ""
for field, value in conn.getUser("maul.esel")
{
	list .= "  -  " field " = " value . "`n"
}
MsgBox maul.esel`n`n%list%

list := ""
for field, value in conn.getItemById("FDBA89C73EC0476AFDE6F792FF4EC588")
{
	list .= "  -  " field " = " value . "`n"
}
MsgBox Item:`n`n%list%

list := ""
for field, value in conn.getItem("TheTestPack", "4.0.2.1 b")
{
	list .= "  -  " field " = " value . "`n"
}
MsgBox Item:`n`n%list%


FileSelectFile package
if ErrorLevel
   ExitApp

InputBox user, Enter user name..., Enter your ALD user name below:
if ErrorLevel
	ExitApp

InputBox pw, Enter password..., Enter your ALD user password below:, HIDE
if ErrorLevel
	ExitApp

MsgBox % conn.uploadItem(package, user, pw)