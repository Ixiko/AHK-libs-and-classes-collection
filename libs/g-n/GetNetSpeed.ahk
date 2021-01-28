GetNetSpeed() {

    local MIB_IF_ROW2, IfIndex
    
    ; Create interface structure and use the default network device.
    VarSetCapacity(MIB_IF_ROW2, 1368, 0)
    DllCall("iphlpapi\GetBestInterface", "Ptr", 0, "Ptr*", IfIndex)
    NumPut(IfIndex, &MIB_IF_ROW2+8, "UInt")
    NumPut(&MIB_IF_ROW2+1256, &MIB_IF_ROW2+1352), NumPut(&MIB_IF_ROW2+1320, &MIB_IF_ROW2+1360) ; InUcastOctets/OutUcastOctets


    ; Get/Refresh structure data.
    DllCall("iphlpapi\GetIfEntry2", "Ptr", &MIB_IF_ROW2)
    
    ; Return a array holding the speed for bytes In/Out
    return {1: NumGet(NumGet(&MIB_IF_ROW2+1352), "Int64"), 2: NumGet(NumGet(&MIB_IF_ROW2+1360), "Int64")}
}
