; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Enables or disables a privilege in the current process.
    Parameters:
        Privilege:
            0      SeUnsolicitedInputPrivilege 
            2      SeCreateTokenPrivilege    
            3      SeAssignPrimaryTokenPrivilege  
            4      SeLockMemoryPrivilege  
            5      SeIncreaseQuotaPrivilege      
            6      SeMachineAccountPrivilege     
            7      SeTcbPrivilege    
            8      SeSecurityPrivilege            
            9      SeTakeOwnershipPrivilege  
            10     SeLoadDriverPrivilege    
            11     SeSystemProfilePrivilege       
            12     SeSystemtimePrivilege  
            13     SeProfileSingleProcessPrivilege
            14     SeIncreaseBasePriorityPrivilege
            21     SeAuditPrivilege               
            17     SeBackupPrivilege              
            23     SeChangeNotifyPrivilege        
            30     SeCreateGlobalPrivilege        
            15     SeCreatePagefilePrivilege      
            16     SeCreatePermanentPrivilege     
            18     SeRestorePrivilege 
            19     SeShutdownPrivilege 
            35     SeCreateSymbolicLinkPrivilege  
            20     SeDebugPrivilege    
            22     SeSystemEnvironmentPrivilege        
            24     SeRemoteShutdownPrivilege    
            25     SeUndockPrivilege   
            26     SeSyncAgentPrivilege    
            27     SeEnableDelegationPrivilege    
            28     SeManageVolumePrivilege     
            29     SeImpersonatePrivilege 
            31     SeTrustedCredManAccessPrivilege    
            32     SeRelabelPrivilege       
            33     SeIncreaseWorkingSetPrivilege  
            34     SeTimeZonePrivilege   
        Enable:
            FALSE    Disable the specified privilege.
            TRUE     Enable the specified privilege.
        IsThreadPrivilege:
            FALSE    Open current process.
            TRUE     Open current thread.
    Return value:
        If the function succeeds, the return value is non-zero.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
*/
AdjustPrivilege(Privilege, Enable := TRUE, IsThreadPrivilege := FALSE)
{
    A_LastError := DllCall("Ntdll.dll\RtlAdjustPrivilege",   "UInt", Privilege            ; ULONG.
                                                         ,  "UChar", !!Enable             ; BOOLEAN.
                                                         ,  "UChar", !!IsThreadPrivilege  ; BOOLEAN.
                                                         , "UCharP", 0                    ; PBOOLEAN.
                                                         ,   "UInt")
    ; The last parameter is supposed to return the previous value, but it doesn't work.

    return A_LastError == 0 ? TRUE : FALSE
} ; https://source.winehq.org/WineAPI/RtlAdjustPrivilege.html