/*
    Recupera el identificador único local (LUID) utilizado en un sistema especificado para representar localmente el nombre de privilegio especificado.
    Parámetros:
        SystemName   : El nombre del sistema en el que se recupera el nombre del privilegio. Si se especifica una cadena vacía, la función intenta encontrar el nombre del privilegio en el sistema local.
        PrivilegeName: El nombre del privilegio.
    Return:
        0      = Hubo un error al intentar recuperar el identificador.
        [luid] = Si tuvo éxito devuelve el identificador.
    Privilegios:
        https://msdn.microsoft.com/en-us/library/bb530716.aspx
    Ejemplo:
        MsgBox(LookupPrivilegeValue(, 'SeSecurityPrivilege'))
        Loop Parse, 'SeAssignPrimaryTokenPrivilege|SeAuditPrivilege|SeBackupPrivilege|SeChangeNotifyPrivilege|SeCreateGlobalPrivilege|SeCreatePagefilePrivilege|SeCreatePermanentPrivilege|SeCreateSymbolicLinkPrivilege|SeCreateTokenPrivilege|SeDebugPrivilege|SeEnableDelegationPrivilege|SeImpersonatePrivilege|SeIncreaseBasePriorityPrivilege|SeIncreaseQuotaPrivilege|SeIncreaseWorkingSetPrivilege|SeLoadDriverPrivilege|SeLockMemoryPrivilege|SeMachineAccountPrivilege|SeManageVolumePrivilege|SeProfileSingleProcessPrivilege|SeRelabelPrivilege|SeRemoteShutdownPrivilege|SeRestorePrivilege|SeSecurityPrivilege|SeShutdownPrivilege|SeSyncAgentPrivilege|SeSystemEnvironmentPrivilege|SeSystemProfilePrivilege|SeSystemtimePrivilege|SeTakeOwnershipPrivilege|SeTcbPrivilege|SeTimeZonePrivilege|SeTrustedCredManAccessPrivilege|SeUndockPrivilege|SeUnsolicitedInputPrivilege', '|'
            List .= A_LoopField . ' = ' . LookupPrivilegeValue(, A_LoopField) . '`n'
        Clipboard := List
*/
LookupPrivilegeValue(SystemName := 0, PrivilegeName := 0)
{
    Local Luid
    SystemName := SystemName == 0 || SystemName == '' ? '' : SystemName . ''

    DllCall('Advapi32.dll\LookupPrivilegeValueW', 'UPtr', &SystemName, 'UPtr', &PrivilegeName, 'Int64P', Luid)
    Return (Luid)
} ;https://msdn.microsoft.com/en-us/library/aa379180(v=vs.85).aspx
