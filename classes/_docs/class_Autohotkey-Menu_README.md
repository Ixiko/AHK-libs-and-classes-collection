# AutoHotkey _Menu Class

<div style="padding: 0;">
<img src="./images/AutoHotkey-Class.png" width="186" /><br>
<img src="./images/AutoHotkey-Scripting.png" width="218" /><br>
<img src="./images/AutoHotkey-Coding.png" width="203" /><br>
<img src="./images/AutoHotkey-Programming.png" width="257" /><br>
<img src="./images/AutoHotkey-Is-The-Best.png" width="237" /><br>
</div>

Create objects of system tray/context menus in the AutoHotkey scripting language&#46;

This is a full-featured class that has methods to do anything the Menu commands can already do, but it creates objects of information to make working with the menus cleaner &amp; more organzied&#46;

## Motivation

I create lots of menus in Windows based on context &amp; in my guis&#39; &amp; I wanted to make this to help organize my menus. I&#39;m a fan of OOP/objects as it helps me keep things clean; especially in this language&#46;

## Skill Level

Intermediate - Advanced

This is for experienced AutoHotkey programmers who already know how AHK menus work. I have provided an example menu script &amp; the class file is documented with enough information that an eperienced programmer should be able to use this well&#46;

More information can be found in the example menu file &amp; the class file is fully commented&#46;

## Files

The <span style="color: red;">.aclass</span> &amp; <span style="color: red;">.ahk</span> are the same file &amp; only one is needed as per your preference. I use aclass to help me differentiate my function files from my class files&#46;

[Release Page](https://github.com/Lateralus138/AutoHotkey-Menu-Class/releases)

[_Menu Class - ACLASS](_Menu.aclass)

[_Menu Class - AHK](_Menu.ahk)

[_Menu_Example File - AHK](_Menu_Example.ahk)

## Example Menu

This [file](_Menu_Example.ahk) is found at the root of this repository&#46;

<pre style="white-space: pre-wrap;">
<code>
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
</code>
</pre>
