#noenv
#include AHKWebDriver.ahk

wd := new WDSession()
if(wd.rc.isError){
    msgbox % "Error:" wd.rc.value.error " " wd.rc.value.message
    ExitApp
}
wd.url("https://autohotkey.com")
wd.debug()
; next force error
wd.url("ixbxm.com")
wd.debug()
wd.delete