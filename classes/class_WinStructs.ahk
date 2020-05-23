/*
WinStructs - A class to hold Window Structure Definitions

STYLE GUIDE
===========
ALWAYS Put a link to the MSDN page for the STRUCT
ALWAYS Use the same name as the Struct.
ALWAYS Use the EXACT same name for properties. If it has a lower-case prefix, keep it.
	The reasons for this are two-fold.
	1)  The immediately obvious thing to do is to strip the lower case prefixes, however in some cases this would not be possible.
		eg: KBDLLHOOKSTRUCT has vkCode and scanCode - you could not have two properties called "Code".
	2)	Consistency. Seeing as we cannot achieve consistency by stripping lower case prefixes, the next best solution is to keep them exactly as on MSDN.
		Some properties on MSDN have prefixes, some do not. MSDN may not be consistent, be WinStructs is (With MSDN).


ToDo
====
* Some way of bundling defines with struct definition?

*/

Class WinStructs {
	; Define locations - used to check validity of Structures by looking up the actual size from the specified windows header file.
	; Set to 1 for default header file of "Windows.h"
	; Set to -1 to not check (un-named sub-structs etc)
	static Defines := { KBDLLHOOKSTRUCT: 1
		, POINT: 1
		, MSLLHOOKSTRUCT: 1
		, RAWINPUTDEVICELIST: 1
		, RID_DEVICE_INFO_MOUSE: 1
		, RID_DEVICE_INFO_KEYBOARD: 1
		, RID_DEVICE_INFO_HID: 1
		, RID_DEVICE_INFO: 1
		, HIDP_CAPS: ["Hidusage.h", "Hidpi.h"]
		, RAWINPUTDEVICE: 1
		, HIDP_BUTTON_CAPS_Range: -1
		, HIDP_BUTTON_CAPS_NotRange: -1
		, HIDP_BUTTON_CAPS: ["Hidusage.h", "Hidpi.h"]
		, HIDP_VALUE_CAPS_Range: -1
		, HIDP_VALUE_CAPS_NotRange: -1
		, HIDP_VALUE_CAPS: ["Hidusage.h", "Hidpi.h"]
		, RAWMOUSE: 1
		, RAWKEYBOARD: 1
		, RAWHID: 1
		, RAWINPUTHEADER: 1
		, RAWINPUT: 1
		, STARTUPINFO: 1 }
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645568%28v=vs.85%29.aspx
	static RAWINPUTDEVICELIST := "
	(
		HANDLE hDevice;	// A handle to the raw input device.
		DWORD dwType;		// The type of device. This can be one of the following values
						// RIM_TYPEHID 			2 - The device is an HID that is not a keyboard and not a mouse
						// RIM_TYPEKEYBOARD 	1 - The device is a keyboard.
						// RIM_TYPEMOUSE 		0 - The device is a mouse.
	)"

	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645589(v=vs.85).aspx
	static RID_DEVICE_INFO_MOUSE := "
	(
		DWORD dwId;
		DWORD dwNumberOfButtons;
		DWORD dwSampleRate;
		BOOL fHasHorizontalWheel;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645587(v=vs.85).aspx
	static RID_DEVICE_INFO_KEYBOARD := "
	(
		DWORD dwType;
		DWORD dwSubType;
		DWORD dwKeyboardMode;
		DWORD dwNumberOfFunctionKeys;
		DWORD dwNumberOfIndicators;
		DWORD dwNumberOfKeysTotal;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645584%28v=vs.85%29.aspx
	static RID_DEVICE_INFO_HID := "
	(
		DWORD dwVendorId;
		DWORD dwProductId;
		DWORD dwVersionNumber;
		USHORT usUsagePage;
		USHORT usUsage;
	)"

	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645581%28v=vs.85%29.aspx
	static RID_DEVICE_INFO := "
	(
		DWORD cbSize;
		DWORD dwType;
		{
			WinStructs.RID_DEVICE_INFO_MOUSE mouse;
			WinStructs.RID_DEVICE_INFO_KEYBOARD keyboard;
			WinStructs.RID_DEVICE_INFO_HID hid;
		}
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/hardware/ff539697(v=vs.85).aspx
	static HIDP_CAPS := "
	(
		USHORT Usage;
		USHORT UsagePage;
		USHORT InputReportByteLength;
		USHORT OutputReportByteLength;
		USHORT FeatureReportByteLength;
		USHORT Reserved[17];
		USHORT NumberLinkCollectionNodes;
		USHORT NumberInputButtonCaps;
		USHORT NumberInputValueCaps;
		USHORT NumberInputDataIndices;
		USHORT NumberOutputButtonCaps;
		USHORT NumberOutputValueCaps;
		USHORT NumberOutputDataIndices;
		USHORT NumberFeatureButtonCaps;
		USHORT NumberFeatureValueCaps;
		USHORT NumberFeatureDataIndices;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645565(v=vs.85).aspx
	static RAWINPUTDEVICE := "
	(
		USHORT usUsagePage;
		USHORT usUsage;
		DWORD  dwFlags;
		HWND   hwndTarget;
	)"
	
	; https://msdn.microsoft.com/en-gb/library/windows/hardware/ff539693(v=vs.85).aspx
	static HIDP_BUTTON_CAPS_Range := "
	(
		USHORT  UsageMin;
		USHORT  UsageMax;
		USHORT StringMin;
		USHORT StringMax;
		USHORT DesignatorMin;
		USHORT DesignatorMax;
		USHORT DataIndexMin;
		USHORT DataIndexMax;
	)"
	
	static HIDP_BUTTON_CAPS_NotRange := "
	(
		USHORT  Usage;
		USHORT  Reserved1;
		USHORT StringIndex;
		USHORT Reserved2;
		USHORT DesignatorIndex;
		USHORT Reserved3;
		USHORT DataIndex;
		USHORT Reserved4;
	)"
	
	static HIDP_BUTTON_CAPS := "
	(
		USHORT  UsagePage;
		UCHAR   ReportID;
		BOOLEAN IsAlias;
		USHORT  BitField;
		USHORT  LinkCollection;
		USHORT  LinkUsage;
		USHORT  LinkUsagePage;
		BOOLEAN IsRange;
		BOOLEAN IsStringRange;
		BOOLEAN IsDesignatorRange;
		BOOLEAN IsAbsolute;
		ULONG   Reserved[10];
		{
			WinStructs.HIDP_BUTTON_CAPS_Range Range;
			WinStructs.HIDP_BUTTON_CAPS_NotRange NotRange;
		};
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/hardware/ff539832(v=vs.85).aspx
	static HIDP_VALUE_CAPS_Range := "
	(
		USAGE  UsageMin;
		USAGE  UsageMax;
		USHORT StringMin;
		USHORT StringMax;
		USHORT DesignatorMin;
		USHORT DesignatorMax;
		USHORT DataIndexMin;
		USHORT DataIndexMax;
	)"

	static HIDP_VALUE_CAPS_NotRange := "
	(
		USAGE  Usage;
		USAGE  Reserved1;
		USHORT StringIndex;
		USHORT Reserved2;
		USHORT DesignatorIndex;
		USHORT Reserved3;
		USHORT DataIndex;
		USHORT Reserved4;
	)"

	static HIDP_VALUE_CAPS := "
	(
		USAGE   UsagePage;
		UCHAR   ReportID;
		BOOLEAN IsAlias;
		USHORT  BitField;
		USHORT  LinkCollection;
		USAGE   LinkUsage;
		USAGE   LinkUsagePage;
		BOOLEAN IsRange;
		BOOLEAN IsStringRange;
		BOOLEAN IsDesignatorRange;
		BOOLEAN IsAbsolute;
		BOOLEAN HasNull;
		UCHAR   Reserved;
		USHORT  BitSize;
		USHORT  ReportCount;
		USHORT  Reserved2[5];
		ULONG   UnitsExp;
		ULONG   Units;
		LONG    LogicalMin;
		LONG    LogicalMax;
		LONG    PhysicalMin;
		LONG    PhysicalMax;
		{
			WinStructs.HIDP_VALUE_CAPS_Range Range;
			WinStructs.HIDP_VALUE_CAPS_NotRange NotRange;
		};
	)"

	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645578(v=vs.85).aspx
	static RAWMOUSE := "
	(
		USHORT usFlags;
		{
			ULONG  ulButtons;
			{
				USHORT usButtonFlags;
				USHORT usButtonData;
			};
		};
		ULONG  ulRawButtons;
		LONG   lLastX;
		LONG   lLastY;
		ULONG  ulExtraInformation;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645575(v=vs.85).aspx
	static RAWKEYBOARD := "
	(
		USHORT MakeCode;
		USHORT Flags;
		USHORT Reserved;
		USHORT VKey;
		UINT   Message;
		ULONG  ExtraInformation;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645549(v=vs.85).aspx
	static RAWHID := "
	(
		DWORD dwSizeHid;
		DWORD dwCount;
		BYTE  bRawData[1];
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645571(v=vs.85).aspx
	static RAWINPUTHEADER := "
	(
		DWORD  dwType;
		DWORD  dwSize;
		HANDLE hDevice;
		WPARAM wParam;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645562(v=vs.85).aspx
	static RAWINPUT := "
	(
		WinStructs.RAWINPUTHEADER header;
		{
			WinStructs.RAWMOUSE    mouse;
			WinStructs.RAWKEYBOARD keyboard;
			WinStructs.RAWHID      hid;
		}
		BYTE buffer[49]; // buffer as the structure might differe for devices. ToDo: check on x64
	)"

	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644967(v=vs.85).aspx
	static KBDLLHOOKSTRUCT := "
	(
		DWORD     vkCode;
		DWORD     scanCode;
		DWORD     flags;
		DWORD     time;
		ULONG_PTR dwExtraInfo;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644970(v=vs.85).aspx
	static MSLLHOOKSTRUCT := "
	(
		WinStructs.POINT     pt;
		{
		DWORD     mouseData;
			struct {
				WORD mouseData_low;
				WORD mouseData_high;
			};
		};
		DWORD     flags;
		DWORD     time;
		ULONG_PTR dwExtraInfo;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/dd162805(v=vs.85).aspx
	static POINT := "
	(
		LONG x;
		LONG y;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/dd162897(v=vs.85).aspx
	static RECT := "
	(
		LONG left;
		LONG top;
		LONG right;
		LONG bottom;
	)"
	
	; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787537(v=vs.85).aspx
	static SCROLLINFO := "
	(
		UINT cbSize;
		UINT fMask;
		int  nMin;
		int  nMax;
		UINT nPage;
		int  nPos;
		int  nTrackPos;
	)"
	
	; https://msdn.microsoft.com/en-us/library/ms686331(v=vs.85).aspx
	static STARTUPINFO := "
	(
		DWORD cb;
		LPSTR lpReserved;
		LPTSTR lpDesktop;
	 	LPTSTR lpTitle;
		DWORD  dwX;
		DWORD  dwY;
		DWORD  dwXSize;
		DWORD  dwYSize;
		DWORD  dwXCountChars;
		DWORD  dwYCountChars;
		DWORD  dwFillAttribute;
		DWORD  dwFlags;
		WORD   wShowWindow;
		WORD   cbReserved2;
		LPBYTE lpReserved2;
		HANDLE hStdInput;
		HANDLE hStdOutput;
		HANDLE hStdError;
	)"
}
