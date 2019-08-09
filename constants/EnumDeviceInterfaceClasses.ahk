;------------------------------------------------------------------------------------------------
; Device interface classes provide a mechanism for grouping devices according to shared
; characteristics. Instead of tracking the presence in the system of an individual device,
; drivers and user applications can register to be notified of the arrival or removal of
; any device that belongs to a particular interface class.
;
; Definitions of interface classes are not provided in a single file. A device interface
; class is always defined in a header file that belongs exclusively to a particular class
; of devices.
;
; Some examples of header files.
; Ntddmou.h		: mouse device interface class
; Ntddpar.h		: parallel device interface class
; Ntddpcm.h		: PCMCIA device interface class
; Ntddstor.h	: storage device interface class
;
; The GUIDs in header files that are specific to the device interface class should be used
; to register for notification of arrival of an instance of a device interface. If a driver
; registers for notification using a setup class GUID instead of an interface class GUID,
; then it will not be notified when an interface arrives.
;------------------------------------------------------------------------------------------------

; 1394 and 61883 Devices
global EnumDeviceInterfaceClasses := {BUS1394_CLASS_GUID: "{6BDD1FC1-810F-11d0-BEC7-08002BE2092F}"
	, "GUID_61883_CLASS"                      : "{7EBEFBC0-3200-11d2-B4C2-00A0C9697D07}"

; Battery and ACPI Devices
	, GUID_DEVICE_APPLICATIONLAUNCH_BUTTON    : "{629758EE-986E-4D9E-8E47-DE27F8AB054D}"
	, GUID_DEVICE_BATTERY                     : "{72631E54-78A4-11D0-BCF7-00AA00B7B32A}"
	, GUID_DEVICE_LID                         : "{4AFA3D52-74A7-11d0-be5e-00A0C9062857}"
	, GUID_DEVICE_MEMORY                      : "{3FD0F03D-92E0-45FB-B75C-5ED8FFB01021}"
	, GUID_DEVICE_MESSAGE_INDICATOR           : "{CD48A365-FA94-4CE2-A232-A1B764E5D8B4}"
	, GUID_DEVICE_PROCESSOR                   : "{97FADB10-4E33-40AE-359C-8BEF029DBDD0}"
	, GUID_DEVICE_SYS_BUTTON                  : "{4AFA3D53-74A7-11d0-be5e-00A0C9062857}"
	, GUID_DEVICE_THERMAL_ZONE                : "{4AFA3D51-74A7-11d0-be5e-00A0C9062857}"

; Bluetooth Devices
	, GUID_BTHPORT_DEVICE_INTERFACE           : "{0850302A-B344-4fda-9BE9-90576B8D46F0}"

; Display and Image Devices
	, GUID_DEVINTERFACE_BRIGHTNESS            : "{FDE5BBA4-B3F9-46FB-BDAA-0728CE3100B4}"
	, GUID_DEVINTERFACE_DISPLAY_ADAPTER       : "{5B45201D-F2F2-4F3B-85BB-30FF1F953599}"
	, GUID_DEVINTERFACE_I2C                   : "{2564AA4F-DDDB-4495-B497-6AD4A84163D7}"
	, GUID_DEVINTERFACE_IMAGE                 : "{6BDD1FC6-810F-11D0-BEC7-08002BE2092F}"
	, GUID_DEVINTERFACE_MONITOR               : "{E6F07B5F-EE97-4a90-B076-33F57BF4EAA7}"
	, GUID_DEVINTERFACE_OPM                   : "{BF4672DE-6B4E-4BE4-A325-68A91EA49C09}"
	, GUID_DEVINTERFACE_VIDEO_OUTPUT_ARRIVAL  : "{1AD9E4F0-F88D-4360-BAB9-4C2D55E564CD}"
	, GUID_DISPLAY_DEVICE_ARRIVAL             : "{1CA05180-A699-450A-9A0C-DE4FBE3DDD89}"

; Interactive Input Devices
	, GUID_DEVINTERFACE_HID                   : "{4D1E55B2-F16F-11CF-88CB-001111000030}"
	, GUID_DEVINTERFACE_KEYBOARD              : "{884b96c3-56ef-11d1-bc8c-00a0c91405dd}"
	, GUID_DEVINTERFACE_MOUSE                 : "{378DE44C-56EF-11D1-BC8C-00A0C91405DD}"

; Modem Devices
	, GUID_DEVINTERFACE_MODEM                 : "{2C7089AA-2E0E-11D1-B114-00C04FC2AAE4}"

; Network Devices
	, GUID_DEVINTERFACE_NET                   : "{CAC88484-7515-4C03-82E6-71A87ABAC361}"

; Serial and Parallel Post Devices
	, GUID_DEVINTERFACE_COMPORT               : "{86E0D1E0-8089-11D0-9CE4-08003E301F73}"
	, GUID_DEVINTERFACE_PARALLEL              : "{97F76EF0-F883-11D0-AF1F-0000F800845C}"
	, GUID_DEVINTERFACE_PARCLASS              : "{811FC6A5-F728-11D0-A537-0000F8753ED1}"
	, GUID_DEVINTERFACE_SERENUM_BUS_ENUMERATOR: "{4D36E978-E325-11CE-BFC1-08002BE10318}"

; Storage Devices
	, GUID_DEVINTERFACE_CDCHANGER             : "{53F56312-B6BF-11D0-94F2-00A0C91EFB8B}"
	, GUID_DEVINTERFACE_CDROM                 : "{53F56308-B6BF-11D0-94F2-00A0C91EFB8B}"
	, GUID_DEVINTERFACE_DISK                  : "{53F56307-B6BF-11D0-94F2-00A0C91EFB8B}"
	, GUID_DEVINTERFACE_FLOPPY                : "{53F56311-B6BF-11D0-94F2-00A0C91EFB8B}"
	, GUID_DEVINTERFACE_MEDIUMCHANGER         : "{53F56310-B6BF-11D0-94F2-00A0C91EFB8B}"
	, GUID_DEVINTERFACE_PARTITION             : "{53F5630A-B6BF-11D0-94F2-00A0C91EFB8B}"
	, GUID_DEVINTERFACE_STORAGEPORT           : "{2ACCFE60-C130-11D2-B082-00A0C91EFB8B}"
	, GUID_DEVINTERFACE_TAPE                  : "{53F5630B-B6BF-11D0-94F2-00A0C91EFB8B}"
	, GUID_DEVINTERFACE_VOLUME                : "{53F5630D-B6BF-11D0-94F2-00A0C91EFB8B}"
	, GUID_DEVINTERFACE_WRITEONCEDISK         : "{53F5630C-B6BF-11D0-94F2-00A0C91EFB8B}"
	, GUID_IO_VOLUME_DEVICE_INTERFACE         : "{53F5630D-B6BF-11D0-94F2-00A0C91EFB8B}"
	, MOUNTDEV_MOUNTED_DEVICE_GUID            : "{53F5630D-B6BF-11D0-94F2-00A0C91EFB8B}"

; Kernel Steaming Media Devices
	, GUID_AVC_CLASS                          : "{095780C3-48A1-4570-BD95-46707F78C2DC}"
	, GUID_VIRTUAL_AVC_CLASS                  : "{616EF4D0-23CE-446D-A568-C31EB01913D0}"

; USB Devices
	, GUID_DEVINTERFACE_USB_DEVICE            : "{A5DCBF10-6530-11D2-901F-00C04FB951ED}"
	, GUID_DEVINTERFACE_USB_HOST_CONTROLLER   : "{3ABF6F2D-71C4-462A-8A92-1E6861E6AF27}"
	, GUID_DEVINTERFACE_USB_HUB               : "{F18A0E88-C30C-11D0-8815-00A0C906BED8}"

; Windows Portable Devices
	, GUID_DEVINTERFACE_WPD                   : "{6AC27878-A6FA-4155-BA85-F98F491D4F33}"
	, GUID_DEVINTERFACE_WPD_PRIVATE           : "{BA0C718F-4DED-49B7-BDD3-FABE28661211}"

; Windows SlideShow Devices
	, GUID_DEVINTERFACE_SIDESHOW              : "{152E5811-FEB9-4B00-90F4-D32947AE1681}"}
