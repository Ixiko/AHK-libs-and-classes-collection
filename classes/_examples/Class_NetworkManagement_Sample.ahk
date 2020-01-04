; GLOBAL SETTINGS ===============================================================================================================

#NoEnv
#SingleInstance Force
SetBatchLines -1


; SCRIPT ========================================================================================================================


NetUserEnum := NetworkManagement.NetUserEnum("192.168.0.1")
for k, v in NetUserEnum
    MsgBox % "Name:`t`t"      v.Name        "`n"
           . "Password:`t`t"  v.Password    "`n"
           . "PasswordAge:`t" v.PasswordAge "`n"
           . "Privilege:`t`t" v.Privilege   "`n"
           . "HomeDir:`t`t"   v.HomeDir     "`n"
           . "Comment:`t"     v.Comment     "`n"
           . "Flags:`t`t"     v.Flags       "`n"
           . "ScriptPath:`t"  v.ScriptPath


; =======================================================================================


NetUserGetGroups := NetworkManagement.NetUserGetGroups(A_UserName, "192.168.0.1")
for k, v in NetUserGetGroups
    MsgBox % v


; =======================================================================================


NetUserGetLocalGroups := NetworkManagement.NetUserGetLocalGroups(A_UserName, "EXAMPLE\", "192.168.0.1")
for k, v in NetUserGetLocalGroups
    MsgBox % v


; =======================================================================================


NetWkstaGetInfo := NetworkManagement.NetWkstaGetInfo("192.168.0.1")
MsgBox % "Platform_ID:`t"  NetWkstaGetInfo.Platform_ID  "`n"
       . "ComputerName:`t" NetWkstaGetInfo.ComputerName "`n"
       . "LanGroup:`t`t"   NetWkstaGetInfo.LanGroup     "`n"
       . "VerMajor:`t`t"   NetWkstaGetInfo.VerMajor     "`n"
       . "VerMinor:`t`t"   NetWkstaGetInfo.VerMinor     "`n"
       . "LanRoot:`t`t"    NetWkstaGetInfo.LanRoot      "`n"
       . "LoggedOnUser:`t" NetWkstaGetInfo.LoggedOnUser


; =======================================================================================


NetWkstaTransportEnum := NetworkManagement.NetWkstaTransportEnum("192.168.0.1")
MsgBox % "QualityOfService:`t"   NetWkstaTransportEnum.QualityOfService "`n"
       . "NumberOfVcs:`t"        NetWkstaTransportEnum.NumberOfVcs      "`n"
       . "TransportName:`t`t"    NetWkstaTransportEnum.TransportName    "`n"
       . "TransportAddress:`t`t" NetWkstaTransportEnum.TransportAddress "`n"
       . "WanIsh:`t`t"           NetWkstaTransportEnum.WanIsh


; =======================================================================================


NetWkstaUserEnum := NetworkManagement.NetWkstaUserEnum("192.168.0.1")
for k, v in NetWkstaUserEnum
    MsgBox % "UserName:`t"     v.UserName     "`n"
           . "LogonDomain:`t"  v.LogonDomain  "`n"
           . "OtherDomains:`t" v.OtherDomains "`n"
           . "LogonServer:`t"  v.LogonServer


; =======================================================================================


NetWkstaUserGetInfo := NetworkManagement.NetWkstaUserGetInfo()
MsgBox % "UserName:`t"     NetWkstaUserGetInfo.UserName     "`n"
       . "LogonDomain:`t"  NetWkstaUserGetInfo.LogonDomain  "`n"
       . "OtherDomains:`t" NetWkstaUserGetInfo.OtherDomains "`n"
       . "LogonServer:`t"  NetWkstaUserGetInfo.LogonServer



; EXIT ==========================================================================================================================

ExitApp


; INCLUDES ======================================================================================================================

#include %A_ScriptDir%\..\class_NetworkManagement.ahk


; ===============================================================================================================================