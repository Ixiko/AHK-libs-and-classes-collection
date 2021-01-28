; Link:
; Author:
; Date:
; for:     	AHK_L

/*

for k, v in wmi_hdd(){
    MsgBox % "Drive:`t`t" v.Driveletter "`nLabel:`t`t" v.VolumeLabel "`nModell:`t`t" v.Model "`nInterface:`t`t" v.InterfaceType  "`nSer.Nr. hdd:`t" v.SerialNumber "`nSer.Nr. Vol.:`t" v.VolumeSerialNumber  "`nHardwareID:`t" v.PNPDeviceID
}

*/



wmi_hdd() {
	;nach https://www.autohotkey.com/boards/viewtopic.php?p=141182&sid=50826a0ab47fd6c1936a3e7cca89d8b0#p141182
	;und https://www.mbsplugins.de/archive/2012-02-24/Detecting_drive_letter_for_an_
	;Win32_DiskDrive und Win32_LogicalDisk werden über den Laufwerksbuchstaben verbunden
	;So kann bei USB-Festplatten die Hardware-ID über den Laufwerksbuchstaben gefunden werden.
    static HDD := []
    for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_DiskDrive") {  ; WHERE InterfaceType='USB' or InterfaceType='SCSI' or InterfaceType='IDE'") {
        HDD[A_Index, "DeviceID"]      := objItem.DeviceID
		devID := objItem.DeviceID
        HDD[A_Index, "Model"]         := objItem.Model
        HDD[A_Index, "SerialNumber"]  := trim(objItem.SerialNumber)
		HDD[A_Index, "PNPDeviceID"]  := objItem.PNPDeviceID          ;Hardware-ID
		HDD[A_Index, "InterfaceType"]  := objItem.InterfaceType
		;...

		i:=A_Index

		for objItem in ComObjGet("winmgmts:").ExecQuery("Associators of {Win32_DiskDrive.DeviceID='" . devID . "'} where AssocClass=Win32_DiskDriveToDiskPartition") {
			HDD[i, "Name"]  := objItem.DeviceID
			devPart:=  objItem.DeviceID

		    for objItem in ComObjGet("winmgmts:").ExecQuery("Associators of {Win32_DiskPartition.DeviceID='" . devPart . "'} where AssocClass=Win32_LogicalDiskToPartition") {
				HDD[i, "DriveLetter"]  := objItem.DeviceID
				devDl:=objItem.DeviceID
				for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_LogicalDisk WHERE Name='" . devDl . "'") {
					HDD[i, "VolumeLabel"]  := objItem.VolumeName
					HDD[i, "VolumeSerialNumber"]  := objItem.VolumeSerialNumber
					;....
				}
			}
		}

	}
	return hdd
}

