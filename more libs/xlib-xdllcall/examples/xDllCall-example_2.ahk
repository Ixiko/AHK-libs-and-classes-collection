#include ..\xdllcall.ahk

aWinWait(cb,
	lpszClass := '',
	lpszWindow := '',
	timeout := -1,
	hWndParent := 0,
	hWndChildAfter := 0) {
	; Description:
	; 	async wait for window with class lpszClass and title lpszWindow.
	; params:
	;	cb, callback function
	;	timeout, max time in ms to wait, maximum wait time is 0xffffffff.
	;	Other parameters, see:
	;		- https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-findwindowexw (FindWindowExW function)
	;
	static bin, FindWindow, _sleep
	static sleep_time := 30	; how often to check if window exist, ms
	local
	global xlib
	
	if !FindWindow {
		FindWindow := xlib.ui.getFnPtrFromLib('User32.dll', 'FindWindowExW')
		_sleep := xlib.ui.getFnPtrFromLib('Kernel32.dll', 'Sleep')
	}
	
	if lpszClass == '' 
		lpszClass := 0, class_type := 'ptr'
	else
		class_type := 'str'
	
	if lpszWindow == '' 
		lpszWindow := 0, window_type := 'ptr'
	else
		window_type := 'str'
		
	xDllCall cb, bin, 'ptr', FindWindow, 'ptr', _sleep, 'ptr', hWndParent, 'ptr', hWndChildAfter, class_type, lpszClass, window_type, lpszWindow, 'uint', timeout, 'uint', sleep_time, 'ptr'
	init(){
		static flProtect:=0x40, flAllocationType:=0x1000 ; PAGE_EXECUTE_READWRITE ; MEM_COMMIT	
		static _ := init()
		raw32:=[1474660693,3968029526,611683100,1166799753,608471324,407210764,136594569,2299807115,2332304452,76091461,139853604,2232478851,1976011200,607422736,1342985727,4076984457,1931494713,4100296137,1583085705,2428722527]
		raw64:=[1430345281,1465209921,2202555222,3029016812,38948,3431549184,1305839944,2303575433,1291028942,2284096651,1275068416,2149876875,1275068416,2303521417,3573498345,1220576584,292931465,3590320521,4076984457,2418312249,1929379840,4169746638,549749576,1566531163,1564564545,2428722753,2425393296,2425393296]
		bin:=DllCall("Kernel32.dll\VirtualAlloc", "Uptr",0, "Ptr", (raw:=A_PtrSize==4?raw32:raw64).length()*4, "Uint", flAllocationType, "Uint", flProtect, "Ptr")
		for k, i in raw
			NumPut(i,bin+(k-1)*4,"Int")
	}
}

; Example,
cb := (r)=> msgbox( r[0] )
aWinWait cb, 'Notepad',, 3000					; waits 3 seconds for window with class Notepad to exist.
aWinWait cb, 'AutoHotkeyGUI', 'MyGui', 3000		; waits 3 seconds for window with class AutoHotkeyGUI and title MyGui to exist.

msgbox 'Press "F1" to run notepad.`nPress "F2" to open a gui.'

F1::run 'notepad.exe'
F2::guicreate(,'MyGui').show('w400 h200')
esc::exitapp







/*
//	c source: 
//	gcc -Os
// HWND FindWindowExW(
//   HWND    hWndParent,
//   HWND    hWndChildAfter,
//   LPCWSTR lpszClass,
//   LPCWSTR lpszWindow
// );

#include <windef.h>


typedef HWND WINAPI (*FindWindow)(HWND,HWND,LPCWSTR,LPCWSTR);
typedef int WINAPI (*sleep)(unsigned int);
HWND winWait(
	FindWindow fw,
	sleep _sleep,
	HWND    hWndParent,
	HWND    hWndChildAfter,
	LPCWSTR lpszClass,
	LPCWSTR lpszWindow,
	unsigned int timeout,
	unsigned int sleep_time){
	
	HWND found;
	unsigned int time_waited = 0;

	do {
		if (found = fw (hWndParent, hWndChildAfter, lpszClass, lpszWindow))
			break;
		_sleep (sleep_time);
		time_waited += sleep_time;
		
	} while (time_waited <= timeout);
	
	return found;
}


*/