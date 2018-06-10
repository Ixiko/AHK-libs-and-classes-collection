; ===============================================================================================================================
; The network management functions provide the ability to manage user accounts and network resources.
;
; EXPERIMENTAL - USE AT YOUR OWN RISK - TESTED WITH WIN10 64BIT
; ===============================================================================================================================

class NetworkManagement
{

    static hNETAPI32 := DllCall("LoadLibrary", "str", "netapi32.dll", "ptr")
    static MAX_PREFERRED_LENGTH := -1


    ; ===========================================================================================================================
    ; Function .................:  NetUserEnum
    ; Minimum supported client .:  Windows 2000 Professional
    ; Minimum supported server .:  Windows 2000 Server
    ; Links ....................:  https://msdn.microsoft.com/en-us/library/aa370652(v=vs.85).aspx
    ; ===========================================================================================================================
    NetUserEnum(ServerName := "127.0.0.1")
    {
        static USER_INFO_1                      := 1
        static FILTER_NORMAL_ACCOUNT            := 0x0002
        static FILTER_WORKSTATION_TRUST_ACCOUNT := 0x0010
        static USER_PRIV                        := { 0: "GUEST", 1: "USER", 2: "ADMIN" }

        if (NET_API_STATUS := DllCall("netapi32\NetUserEnum", "wstr",  ServerName
                                                            , "uint",  USER_INFO_1
                                                            , "uint",  FILTER_NORMAL_ACCOUNT
                                                            , "ptr*",  buf
                                                            , "uint",  this.MAX_PREFERRED_LENGTH
                                                            , "uint*", EntriesRead
                                                            , "uint*", TotalEntries
                                                            , "uint*", 0
                                                            , "uint")  != 0)
            throw Exception("NetUserEnum failed: " NET_API_STATUS, -1), this.NetApiBufferFree(buf)

        addr := buf, USER_INFO := []
        loop % EntriesRead
        {
            USER_INFO[A_Index, "Name"]        := StrGet(NumGet(addr + (A_PtrSize * 0), "uptr"), "utf-16")
            USER_INFO[A_Index, "Password"]    := StrGet(NumGet(addr + (A_PtrSize * 1), "uptr"), "utf-16")
            USER_INFO[A_Index, "PasswordAge"] := NumGet(addr + (A_PtrSize * 2), "uint")
            USER_INFO[A_Index, "Privilege"]   := USER_PRIV[NumGet(addr + (A_PtrSize * 2) + 4, "uint")]
            USER_INFO[A_Index, "HomeDir"]     := StrGet(NumGet(addr + (A_PtrSize * 3), "uptr"), "utf-16")
            USER_INFO[A_Index, "Comment"]     := StrGet(NumGet(addr + (A_PtrSize * 4), "uptr"), "utf-16")
            USER_INFO[A_Index, "Flags"]       := NumGet(addr + (A_PtrSize * 5), "uint")
            USER_INFO[A_Index, "ScriptPath"]  := StrGet(NumGet(addr + (A_PtrSize * 6), "uptr"), "utf-16")
            addr += 8 + A_PtrSize * 6
        }

        return USER_INFO, this.NetApiBufferFree(buf)
    }


    ; ===========================================================================================================================
    ; Function .................:  NetUserGetGroups
    ; Minimum supported client .:  Windows 2000 Professional
    ; Minimum supported server .:  Windows 2000 Server
    ; Links ....................:  https://msdn.microsoft.com/en-us/library/aa370653(v=vs.85).aspx
    ; ===========================================================================================================================
    NetUserGetGroups(UserName, ServerName := "127.0.0.1")
    {
        static GROUP_USERS_INFO_0 := 0

        if (NET_API_STATUS := DllCall("netapi32\NetUserGetGroups", "wstr",  ServerName
                                                                 , "wstr",  UserName
                                                                 , "uint",  GROUP_USERS_INFO_0
                                                                 , "ptr*",  buf
                                                                 , "uint",  this.MAX_PREFERRED_LENGTH
                                                                 , "uint*", EntriesRead
                                                                 , "uint*", TotalEntries
                                                                 , "uint")  != 0)
            throw Exception("NetUserGetGroups failed: " NET_API_STATUS, -1), this.NetApiBufferFree(buf)

        addr := buf, GROUP_USERS_INFO := []
        loop % EntriesRead
        {
            GROUP_USERS_INFO.Push(StrGet(NumGet(addr + (A_PtrSize * 0), "uptr"), "utf-16"))
            addr += A_PtrSize
        }

        return GROUP_USERS_INFO, this.NetApiBufferFree(buf)
    }


    ; ===========================================================================================================================
    ; Function .................:  NetUserGetLocalGroups
    ; Minimum supported client .:  Windows 2000 Professional
    ; Minimum supported server .:  Windows 2000 Server
    ; Links ....................:  https://msdn.microsoft.com/en-us/library/aa370655(v=vs.85).aspx
    ; ===========================================================================================================================
    NetUserGetLocalGroups(UserName, Domain := "", ServerName := "127.0.0.1")
    {
        static LOCALGROUP_USERS_INFO_0 := 0
        static LG_INCLUDE_INDIRECT     := 0x0001

        if (NET_API_STATUS := DllCall("netapi32\NetUserGetLocalGroups", "wstr",  ServerName
                                                                      , "wstr",  Domain . UserName
                                                                      , "uint",  LOCALGROUP_USERS_INFO_0
                                                                      , "uint",  LG_INCLUDE_INDIRECT
                                                                      , "ptr*",  buf
                                                                      , "uint",  this.MAX_PREFERRED_LENGTH
                                                                      , "uint*", EntriesRead
                                                                      , "uint*", TotalEntries
                                                                      , "uint")  != 0)
            throw Exception("NetUserGetLocalGroups failed: " NET_API_STATUS, -1), this.NetApiBufferFree(buf)

        addr := buf, LOCALGROUP_USERS_INFO := []
        loop % EntriesRead
        {
            LOCALGROUP_USERS_INFO.Push(StrGet(NumGet(addr + (A_PtrSize * 0), "uptr"), "utf-16"))
            addr += A_PtrSize
        }

        return LOCALGROUP_USERS_INFO, this.NetApiBufferFree(buf)
    }


    ; ===========================================================================================================================
    ; Function .................:  NetWkstaGetInfo
    ; Minimum supported client .:  Windows 2000 Professional
    ; Minimum supported server .:  Windows 2000 Server
    ; Links ....................:  https://msdn.microsoft.com/en-us/library/aa370663(v=vs.85).aspx
    ; ===========================================================================================================================
    NetWkstaGetInfo(ServerName := "127.0.0.1")
    {
        static WKSTA_INFO_102 := 102
        static PLATFORM_ID    := { 300: "DOS", 400: "OS2", 500: "NT", 600: "OSF", 700: "VMS" }

        if (NET_API_STATUS := DllCall("netapi32\NetWkstaGetInfo", "wstr", ServerName
                                                                , "uint", WKSTA_INFO_102
                                                                , "ptr*", buf
                                                                , "uint") != 0)
            throw Exception("NetWkstaGetInfo failed: " NET_API_STATUS, -1), this.NetApiBufferFree(buf)

        WKSTA_INFO := {}
        WKSTA_INFO.Platform_ID  := PLATFORM_ID[NumGet(buf + 0, "uint")]
        WKSTA_INFO.ComputerName := StrGet(NumGet(buf + (A_PtrSize * 1), "uptr"), "utf-16")
        WKSTA_INFO.LanGroup     := StrGet(NumGet(buf + (A_PtrSize * 2), "uptr"), "utf-16")
        WKSTA_INFO.VerMajor     := NumGet(buf + (A_PtrSize * 3), "uint")
        WKSTA_INFO.VerMinor     := NumGet(buf + (A_PtrSize * 3) + 4, "uint")
        WKSTA_INFO.LanRoot      := StrGet(NumGet(buf + (A_PtrSize * 4), "uptr"), "utf-16")
        WKSTA_INFO.LoggedOnUser := NumGet(buf + (A_PtrSize * 5), "uint")

        return WKSTA_INFO, this.NetApiBufferFree(buf)
    }


    ; ===========================================================================================================================
    ; Function .................:  NetWkstaTransportEnum
    ; Minimum supported client .:  Windows 2000 Professional
    ; Minimum supported server .:  Windows 2000 Server
    ; Links ....................:  https://msdn.microsoft.com/en-us/library/aa370668(v=vs.85).aspx
    ; ===========================================================================================================================
    NetWkstaTransportEnum(ServerName := "127.0.0.1")
    {
        static WKSTA_TRANSPORT_INFO_0 := 0

        if (NET_API_STATUS := DllCall("netapi32\NetWkstaTransportEnum", "wstr",  ServerName
                                                                      , "uint",  WKSTA_TRANSPORT_INFO_0
                                                                      , "ptr*",  buf
                                                                      , "uint",  this.MAX_PREFERRED_LENGTH
                                                                      , "uint*", EntriesRead
                                                                      , "uint*", TotalEntries
                                                                      , "uint*", 0
                                                                      , "uint")  != 0)
            throw Exception("NetWkstaTransportEnum failed: " NET_API_STATUS, -1), this.NetApiBufferFree(buf)

        addr := buf, WKSTA_TRANSPORT_INFO := []
        loop % EntriesRead
        {
            WKSTA_TRANSPORT_INFO[A_Index, "QualityOfService"] := NumGet(addr + 0, "uint")
            WKSTA_TRANSPORT_INFO[A_Index, "NumberOfVcs"]      := NumGet(addr + 4, "uint")
            WKSTA_TRANSPORT_INFO[A_Index, "TransportName"]    := StrGet(NumGet(addr + (A_PtrSize * 2), "uptr"), "utf-16")
            WKSTA_TRANSPORT_INFO[A_Index, "TransportAddress"] := StrGet(NumGet(addr + (A_PtrSize * 3), "uptr"), "utf-16")
            WKSTA_TRANSPORT_INFO[A_Index, "WanIsh"]           := NumGet(addr + (A_PtrSize * 4), "int")
            addr += 8 + A_PtrSize * 3
        }

        return WKSTA_TRANSPORT_INFO, this.NetApiBufferFree(buf)
    }


    ; ===========================================================================================================================
    ; Function .................:  NetWkstaUserEnum
    ; Minimum supported client .:  Windows 2000 Professional
    ; Minimum supported server .:  Windows 2000 Server
    ; Links ....................:  https://msdn.microsoft.com/en-us/library/aa370669(v=vs.85).aspx
    ; ===========================================================================================================================
    NetWkstaUserEnum(ServerName := "127.0.0.1")
    {
        static WKSTA_USER_INFO_1    := 1

        if (NET_API_STATUS := DllCall("netapi32\NetWkstaUserEnum", "wstr",  ServerName
                                                                 , "uint",  WKSTA_USER_INFO_1
                                                                 , "ptr*",  buf
                                                                 , "uint",  this.MAX_PREFERRED_LENGTH
                                                                 , "uint*", EntriesRead
                                                                 , "uint*", TotalEntries
                                                                 , "uint*", 0
                                                                 , "uint")  != 0)
            throw Exception("NetWkstaUserEnum failed: " NET_API_STATUS, -1), this.NetApiBufferFree(buf)

        addr := buf, WKSTA_USER_INFO := []
        loop % EntriesRead
        {
            WKSTA_USER_INFO[A_Index, "UserName"]     := StrGet(NumGet(addr + (A_PtrSize * 0), "uptr"), "utf-16")
            WKSTA_USER_INFO[A_Index, "LogonDomain"]  := StrGet(NumGet(addr + (A_PtrSize * 1), "uptr"), "utf-16")
            WKSTA_USER_INFO[A_Index, "OtherDomains"] := StrGet(NumGet(addr + (A_PtrSize * 2), "uptr"), "utf-16")
            WKSTA_USER_INFO[A_Index, "LogonServer"]  := StrGet(NumGet(addr + (A_PtrSize * 3), "uptr"), "utf-16")
            addr += A_PtrSize * 4
        }

        return WKSTA_USER_INFO, this.NetApiBufferFree(buf)
    }


    ; ===========================================================================================================================
    ; Function .................:  NetWkstaUserGetInfo
    ; Minimum supported client .:  Windows 2000 Professional
    ; Minimum supported server .:  Windows 2000 Server
    ; Links ....................:  https://msdn.microsoft.com/en-us/library/aa370670(v=vs.85).aspx
    ; ===========================================================================================================================
    NetWkstaUserGetInfo()
    {
        static WKSTA_USER_INFO_1 := 1

        if (NET_API_STATUS := DllCall("netapi32\NetWkstaUserGetInfo", "ptr",  0
                                                                    , "uint", WKSTA_USER_INFO_1
                                                                    , "ptr*", buf
                                                                    , "uint") != 0)
            throw Exception("NetWkstaUserGetInfo failed: " NET_API_STATUS, -1), this.NetApiBufferFree(buf)

        WKSTA_USER_INFO              := {}
        WKSTA_USER_INFO.UserName     := StrGet(NumGet(buf + (A_PtrSize * 0), "uptr"), "utf-16")
        WKSTA_USER_INFO.LogonDomain  := StrGet(NumGet(buf + (A_PtrSize * 1), "uptr"), "utf-16")
        WKSTA_USER_INFO.OtherDomains := StrGet(NumGet(buf + (A_PtrSize * 2), "uptr"), "utf-16")
        WKSTA_USER_INFO.LogonServer  := StrGet(NumGet(buf + (A_PtrSize * 3), "uptr"), "utf-16")

        return WKSTA_USER_INFO, this.NetApiBufferFree(buf)
    }


    ; ===========================================================================================================================
    ; Function .................:  NetApiBufferFree
    ; Minimum supported client .:  Windows 2000 Professional
    ; Minimum supported server .:  Windows 2000 Server
    ; Links ....................:  https://msdn.microsoft.com/en-us/library/aa370304(v=vs.85).aspx
    ; ===========================================================================================================================
    NetApiBufferFree(buffer)
    {
        if (NET_API_STATUS := DllCall("netapi32\NetApiBufferFree", "ptr", buf, "uint") != 0)
            throw Exception("NetApiBufferFree failed: " NET_API_STATUS, -1)
        return true
    }
}

; ===============================================================================================================================