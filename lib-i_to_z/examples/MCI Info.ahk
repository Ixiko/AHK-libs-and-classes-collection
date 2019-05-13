#NoEnv
#SingleInstance Force
ListLines Off

gui -MinimizeBox
gui Margin,0,0
gui Add
    ,Button
    ,w300 h70 vDevices1 gDevices1
   ,MCI Devices`n(Windows NT4+)

if (A_OSType="WIN32_WINDOWS")
    GUIControl Disable,Devices1

gui Add
   ,Button
   ,wp hp gDevices2
   ,MCI Devices (via MCI)

gui Add
   ,Button
   ,wp hp vExt1 gExt1
   ,MCI File Extensions`n(Windows NT4+)

if (A_OSType="WIN32_WINDOWS")
    GUIControl Disable,Ext1

gui Add
   ,Button
   ,wp hp vExt2 gExt2
   ,MCI File Extensions`n(Windows 95/98/ME)

if (A_OSType="WIN32_NT")
    GUIControl Disable,Ext2

gui Show,,MCI Info
return


GUIEscape:
GUIClose:
ExitApp


Devices1:
$List1:=""
Loop HKEY_LOCAL_MACHINE,SOFTWARE\Microsoft\Windows NT\CurrentVersion\MCI
    {
    RegRead RegValue
    if StrLen($List1)=0
        $List1:=A_LoopRegName . "  (" . RegValue . ")"
     else
        $List1.="`n" . A_LoopRegName . "  (" . RegValue . ")"
    }

Sort $List1,D`n

$List2:=""
Loop HKEY_LOCAL_MACHINE,SOFTWARE\Microsoft\Windows NT\CurrentVersion\MCI32
    {
    RegRead RegValue
    if StrLen($List2)=0
        $List2:=A_LoopRegName . "  (" . RegValue . ")"
     else
        $List2.="`n" . A_LoopRegName . "  (" . RegValue . ")"
    }

Sort $List2,D`n

gui +OwnDialogs
MsgBox 0,MCI Devices,
   (ltrim join
    16-bit devices:
    `n---------------
    `n%$List1%
    `n`n`n
    32-bit devices:
    `n---------------
    `n%$List2%
   )

return


Devices2:
$List:=""
MCI_SendString("sysinfo all quantity",TotalDevices)
Loop %TotalDevices%
    {
    MCI_SendString("sysinfo all name " . A_Index,DeviceName)
    if StrLen($List)=0
        $List:=DeviceName
     else
        $List.="`n" . DeviceName
    }

Sort $List,D`n

gui +OwnDialogs
MsgBox 0,MCI Devices,%$List%
return


Ext1:
$List:=""
Loop HKEY_LOCAL_MACHINE,SOFTWARE\Microsoft\Windows NT\CurrentVersion\MCI Extensions
    {
    RegRead RegValue
    if StrLen($List)=0
        $List:=A_LoopRegName . "`t(" . RegValue . ")"
     else
        $List.="`n" . A_LoopRegName . "`t(" . RegValue . ")"
    }

Sort $List,D`n

gui +OwnDialogs
MsgBox 0,MCI File Extensions,%$List%
return


Ext2:
$List:=""
$Section:=""
FileRead $WinINI,%A_WinDir%\win.ini
Loop Parse,$WinINI,`n,`r
    {
    l_LoopField=%A_LoopField%  ;-- AutoTrim

    ;-- Skip blank and comment
    if l_LoopField is Space
        Continue

    if SubStr(l_LoopField,1,1)=";"
        Continue

    ;-- Section
     if SubStr(l_LoopField,1,1)="["
    and SubStr(l_LoopField,StrLen(l_LoopField))="]"
        {
        Section:=SubStr(l_LoopField,2,StrLen(l_LoopField)-2)
        Continue
        }

    if (Section="MCI Extensions")
        {
        Key:=""
        Value:=""
        Loop parse,A_LoopField,=
            if (A_Index=1)
                Key:=A_LoopField
             else
                Value:=A_LoopField

        if StrLen($List)=0
            $List:=Key . "`t(" . Value . ")"
         else
            $List.="`n" . Key . "`t(" . Value . ")"
        }
    }
    
Sort $List,D`n

gui +OwnDialogs
MsgBox 0,MCI File Extensions,%$List%
return


#include MCI.ahk
