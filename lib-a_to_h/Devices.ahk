


EjectDevice(RootPathName, Retract := FALSE) {
    
    /*                                  DESCRIPTION
    
             Eject the specified device. It can be a CD / DVD drive or a removable device (USB).
            Parameters:
            RootPathName: The root directory of the unit.
            Retract: If it is TRUE the CD / DVD drive closes (by default it opens).
            Return:
            -2 = The device could not be ejected.
            -1 = The device is invalid.
            0 = The device has been successfully ejected.
            2 = ERROR_FILE_NOT_FOUND. The dispisitivo does not exist.
            32 = ERROR_SHARING_VIOLATION. The device can not be ejected because another application prevents it.
            X = Another error code.
    */
       
    Local DriveType, Device, Size, R, STORAGE_DEVICE_NUMBER, BytesReturned, DeviceNumber, PNPDeviceID, hModule, VetoType, hDevInst, hParentDevInst, nVT, Obj
    
    RootPathName := SubStr(RootPathName, 1, 1) . ':'
    DriveType    := DllCall('Kernel32.dll\GetDriveTypeW', 'Str', RootPathName . '\')
    
    If (DriveType == 5)
    {
        DriveEject(RootPathName, Retract)
        Return (ErrorLevel ? -1 : 0)
    }

    If (DriveType != 2)
        Return (-1)

    If (!(Device := FileOpen('\\.\' . RootPathName, 'rw')))
        Return (A_LastError)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa363216(v=vs.85).aspx
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb968800(v=vs.85).aspx
    Size   := VarSetcapacity(STORAGE_DEVICE_NUMBER, 4 * 3, 0)
    R      := DllCall('Kernel32.dll\DeviceIoControl', 'Ptr'  , Device.__Handle        ;hDevice
                                                    , 'UInt' , 0x2D1080               ;dwIoControlCode --> IOCTL_STORAGE_GET_DEVICE_NUMBER
                                                    , 'Ptr'  , 0                      ;lpInBuffer
                                                    , 'UInt' , 0                      ;nInBufferSize
                                                    , 'UPtr' , &STORAGE_DEVICE_NUMBER ;lpOutBuffer
                                                    , 'UInt' , Size                   ;nOutBufferSize
                                                    , 'UIntP', BytesReturned          ;lpBytesReturned
                                                    , 'Ptr'  , 0)                     ;lpOverlapped
    Device := ''

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb968801(v=vs.85).aspx
    If (NumGet(&STORAGE_DEVICE_NUMBER, 'UInt') != 7) ;DeviceType --> FILE_DEVICE_DISK
        Return (-1)

    DeviceNumber := NumGet(&STORAGE_DEVICE_NUMBER + 4, 'UInt')
    PNPDeviceID  := ''

    ; https://msdn.microsoft.com/en-us/library/aa394132(v=vs.85).aspx
    For Obj in ComObjGet('winmgmts:').ExecQuery('Select * from Win32_DiskDrive')
    {
        If (Obj.DeviceID == '\\.\PHYSICALDRIVE' . DeviceNumber && Obj.InterfaceType == 'USB')
        {
            PNPDeviceID := Obj.PNPDeviceID
            Break
        }
    }

    If (PNPDeviceID == '')
        Return (-1)

    hModule := DllCall('Kernel32.dll\LoadLibraryW', 'Str', 'SetupAPI.dll', 'Ptr')

    ; https://msdn.microsoft.com/en-us/library/windows/hardware/ff538742(v=vs.85).aspx
    DllCall('SetupAPI.dll\CM_Locate_DevNodeW', 'PtrP', hDevInst, 'UPtr', &PNPDeviceID, 'UInt', 0)

    ; https://msdn.microsoft.com/en-us/library/windows/hardware/ff538610(v=vs.85).aspx
    DllCall('SetupAPI.dll\CM_Get_Parent', 'PtrP', hParentDevInst, 'Ptr', hDevInst, 'UInt', 0, 'Cdecl')

    ; https://msdn.microsoft.com/en-us/library/windows/hardware/ff539806(v=vs.85).aspx
    VetoType := 1
    While (hParentDevInst && VetoType && A_Index < 4)
        DllCall('SetupAPI.dll\CM_Request_Device_EjectW', 'Ptr', hParentDevInst, 'PtrP', VetoType, 'Ptr', 0, 'UInt', 0, 'UInt', 0)

    DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hModule)

    Return (nVT ? -2 : 0)
} ;http://ahkscript.org/boards/viewtopic.php?f=6&t=4491

EnumDiskDrives() {
    
    /*                                  DESCRIPTION
    
                List all the disks and their partitions.
                    Return:
                        Returns an object, the key is the number that identifies the disk, and the value is an array with the letter of the partition.
            
    */
    
    /*                                  EXAMPLE(s)
    
                 For Disk, Partitions in EnumDiskDrives ()
                 {
                     Str. = Disk. 'n'
                     For Each, Partition in Partitions
                         Str. = '`T'. Partition. 'n'
                     Str. = '`N'
                 }
                 MsgBox (Str)

    */
        
    Local n, Disk
        , List := {}

    For Obj in ComObjGet('winmgmts:\\.\root\CIMV2').ExecQuery('SELECT * FROM Win32_LogicalDiskToPartition')
    {
        Disk := SubStr(Obj.Antecedent, n:=InStr(Obj.Antecedent, 'Disk #')+6, InStr(Obj.Antecedent, ',')-n)
        If (!List.HasKey(Disk))
            List[Disk] := []
        List[Disk][StrReplace(SubStr(Obj.Antecedent, n:=InStr(Obj.Antecedent, 'Partition #')+11, 3), '"')] := SubStr(Obj.Dependent, n:=InStr(Obj.Dependent, '="')+2, InStr(Obj.Dependent, ':"')-n)
    }

    Return (List)
} ;https://autohotkey.com/board/topic/89345-physical-hard-drive-information/

