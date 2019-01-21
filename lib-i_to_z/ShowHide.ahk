/*
Modified by: Edison Hua
Original Author: rbrtryn


Script Function:
Show/Hide hidden folders, files and extensions in Windows XP and Windows 7

All of these system settings are found in the Windows Registry at:
Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced

The specific values are:
    Hidden              Show hidden files?      ( 2 = no , 1 = yes )
    HideFileExt         Show file extensions?   ( 1 = no , 0 = yes )
    ShowSuperHidden     Show system files?      ( 0 = no , 1 = yes )

In order to show protected system files Windows requires that both
the ShowSuperHidden and the hidden settings be set to yes, i.e. both set to 1
*/




ToggleHiddenFiles(){
    `(GetRegValue( "Hidden" ) = 1 ) ? SetRegValue( "Hidden" , 2 ) : SetRegValue( "Hidden" , 1 )
    UpdateWindows()
}


ToggleSystemFiles(){
    GetRegValue( "ShowSuperHidden" ) ? SetRegValue( "ShowSuperHidden" , 0 ) : SetRegValue( "ShowSuperHidden" , 1 )
    UpdateWindows()
}


ToggleFileExt(){
    GetRegValue( "HideFileExt" ) ? SetRegValue( "HideFileExt" , 0 ) : SetRegValue( "HideFileExt" , 1 )
    UpdateWindows()
}


GetRegValue( ValueName )
{
    SubKey := "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    RegRead Value , HKCU , %SubKey% , %ValueName%
    Return Value
}

SetRegValue( ValueName , Value )
{
    SubKey := "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    RegWrite REG_DWORD , HKCU , %SubKey% , %ValueName% , %Value%
}

UpdateWindows()
{
    Code := ( InStr( "WIN_7,WIN_VISTA" , A_OSVERSION ) ) ? 41504 : 28931
    SetTitleMatchMode RegEx
    WinGet WindowList , List , ahk_class ExploreWClass|CabinetWClass|Progman
    Loop %WindowList%
        PostMessage 0x111 , %Code% ,  ,  , % "ahk_id" WindowList%A_Index%
    SetTitleMatchMode 1
}