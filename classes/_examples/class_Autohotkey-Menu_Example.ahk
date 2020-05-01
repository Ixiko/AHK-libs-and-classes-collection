#Persistent
#SingleInstance, Force
#KeyHistory, 0
SetBatchLines, -1
ListLines, Off
;
TITLE:="AutoHotkey _Menu Class Example"
IMAGERES:="C:\Windows\System32\imageres.dll"
;
MOVE_MENU:=New _Menu("MoveMenu","Move &Left","MoveLeft","+Break",IMAGERES,249,1)
MOVE_MENU.Icon("Move &Left",IMAGERES,284,32)
MOVE_MENU.Add("Move &Right","MoveRight")
MOVE_MENU.Icon("Move &Right",IMAGERES,285,32)

ADMIN_MENU:=New _Menu("AdminMenu","&Task Manager","TaskManager","+Break",IMAGERES,249,1)
ADMIN_MENU.Icon("&Task Manager",IMAGERES,112,32)
ADMIN_MENU.Add("&Services","Services")
ADMIN_MENU.Icon("&Services",IMAGERES,64,32)

POWER_MENU:=New _Menu("PowerMenu","&Power","PowerFunc","+Break",IMAGERES,250,1)
POWER_MENU.Icon("&Power",IMAGERES,230,32)
POWER_MENU.Add("&Restart","RestartFunc")
POWER_MENU.Icon("&Restart",IMAGERES,229,32)
POWER_MENU.Add("&Log Off","LogoffFunc")
POWER_MENU.Icon("&Log Off",IMAGERES,231,32)

TRAY_MENU:=New _Menu(,TITLE,"_Menu.DummyFunc","+Break",IMAGERES,249,1)
TRAY_MENU.NoStandard()
TRAY_MENU.Tip(TITLE)

TRAY_MENU.Icon(TITLE,IMAGERES,249,32)

TRAY_MENU.Separator()

TRAY_MENU.Add("Mo&ve Menu",":" MOVE_MENU.MenuName)
TRAY_MENU.Icon("Mo&ve Menu",IMAGERES,281,32)

TRAY_MENU.Add("Admi&n Menu",":" ADMIN_MENU.MenuName)
TRAY_MENU.Icon("Admi&n Menu",IMAGERES,74,32)

TRAY_MENU.Add("Po&wer Menu",":" POWER_MENU.MenuName)
TRAY_MENU.Icon("Po&wer Menu",IMAGERES,250,32)

TRAY_MENU.Separator()

TRAY_MENU.Add("Reloa&d","ReloadFunc")
TRAY_MENU.Icon("Reloa&d",IMAGERES,229,32)

TRAY_MENU.Add("E&xit","ExitFunc")
TRAY_MENU.Icon("E&xit",IMAGERES,236,32)

TRAY_MENU.Default("Reloa&d")

TRAY_MENU.Color("0xFFFFFF","Single")
MOVE_MENU.Color("0xEFF4FF","Single")
ADMIN_MENU.Color("0xEFF4FF","Single")

; TRAY_MENU.Rename("Mo&ve Menu","Mo&ve It Menu")
;
return
;
; ╓─────────╖
; ║ Hotkeys ║
; ╙─────────╜
!F5::
    TRAY_MENU.Show()
return
!F6::
    MOVE_MENU.Show()
return
!F7::
    ADMIN_MENU.Show()
return
; 
#Include, _Menu.aclass
; 
ExitFunc(code:=0)
{
    ExitApp,%code%
}
; 
ReloadFunc()
{
    run,%A_ScriptFullPath%,,UseErrorLevel
    ExitApp, %ErrorLevel%
}
;
MoveLeft()
{   global
    TRAY_MENU.Show(0,(A_ScreenHeight/2),"Screen")   
}
MoveRight()
{   global
    TRAY_MENU.Show(A_ScreenWidth,(A_ScreenHeight/2),"Screen")   
}
TaskManager()
{
    run,taskmgr
}
Services()
{
    run,C:\Windows\System32\services.msc
}
PowerFunc()
{
    Power()
}
RestartFunc()
{
    Power(2)
}
LogoffFunc()
{
    Power(0)
}
Power(option:=1)
{
    if option is integer
    {
        shutdown,%option%
    }
}