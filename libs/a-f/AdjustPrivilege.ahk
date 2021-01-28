/*
    Habilita o deshabilita un privilegio al proceso de llamada.
    Parámetros:
        Privilege: Un valor que identifica al privilegio. Este parámetro debe ser uno de los siguientes valores (algunos pueden no estar disponibles):
            SeAssignPrimaryTokenPrivilege   = 3
            SeAuditPrivilege                = 21
            SeBackupPrivilege               = 17
            SeChangeNotifyPrivilege         = 23
            SeCreateGlobalPrivilege         = 30
            SeCreatePagefilePrivilege       = 15
            SeCreatePermanentPrivilege      = 16
            SeCreateSymbolicLinkPrivilege   = 35
            SeCreateTokenPrivilege          = 2
            SeDebugPrivilege                = 20
            SeEnableDelegationPrivilege     = 27
            SeImpersonatePrivilege          = 29
            SeIncreaseBasePriorityPrivilege = 14
            SeIncreaseQuotaPrivilege        = 5
            SeIncreaseWorkingSetPrivilege   = 33
            SeLoadDriverPrivilege           = 10
            SeLockMemoryPrivilege           = 4
            SeMachineAccountPrivilege       = 6
            SeManageVolumePrivilege         = 28
            SeProfileSingleProcessPrivilege = 13
            SeRelabelPrivilege              = 32
            SeRemoteShutdownPrivilege       = 24
            SeRestorePrivilege              = 18
            SeSecurityPrivilege             = 8
            SeShutdownPrivilege             = 19
            SeSyncAgentPrivilege            = 26
            SeSystemEnvironmentPrivilege    = 22
            SeSystemProfilePrivilege        = 11
            SeSystemtimePrivilege           = 12
            SeTakeOwnershipPrivilege        = 9
            SeTcbPrivilege                  = 7
            SeTimeZonePrivilege             = 34
            SeTrustedCredManAccessPrivilege = 31
            SeUndockPrivilege               = 25
            SeUnsolicitedInputPrivilege     = 0
        Enable   : Si este parámetro es 1 se habilita, si es 0 se deshabilita.
*/
AdjustPrivilege(Privilege, Enable := TRUE)
{
    Local t
    Return !DllCall('Ntdll.dll\RtlAdjustPrivilege', 'UInt', Privilege, 'UChar', Enable, 'UChar', FALSE, 'IntP', t)
}
