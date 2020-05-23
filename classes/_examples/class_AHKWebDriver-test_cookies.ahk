#noenv
#include %A_ScriptDir%\..\class_AHKWebDriver.ahk
#include %A_ScriptDir%\..\class_JSON.ahk

wd := new WDSession()
if(wd.rc.isError){
    msgbox % "Error:" wd.rc.error " " wd.rc.message
    ExitApp
}
wd.url("https://autohotkey.com")
listCookies := wd.getAllCookies()
msgbox % wd.rc.raw "`n`n list: " listCookies[1].name
cookie := wd.getCookie("_gid")
msgbox % wd.rc.raw "`n`nget: " cookie.value
wd.cookie("test","xxxxxxxxxx","/")
msgbox % wd.rc.raw "`n`nnew:" wd.rc.isError
wd.getCookie("test")
msgbox % wd.rc.raw "`n`ngetCookie: " cookie.value
cookie := wd.delCookie("test")
msgbox % wd.rc.raw "`n`ndel: " cookie.value
cookie := wd.getCookie("test")
msgbox % wd.rc.raw "`n`ndel: " cookie.value
wd.delAllCookies()
msgbox % wd.rc.raw "`n`nnew:" wd.rc.isError
listCookies := wd.getAllCookies()
msgbox % wd.rc.raw "`n`n list: " listCookies[1].name
wd.delete()
