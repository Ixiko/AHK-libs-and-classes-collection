cSendInputW(byref str, doHook:=true,init:=false){
	; Send string str, via SendInput(), using unicode flag.
	; Optionally blocking hooks. default on. Set doHook:=false to disable.
	; Change
	; Url:
	;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366887(v=vs.85).aspx 	(VirtualAlloc function)
	;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366786(v=vs.85).aspx 	(Memory Protection Constants)
	local k, i, raw, dll, hookProc, o
	static flProtect:=0x40, flAllocationType:=0x1000 ; PAGE_EXECUTE_READWRITE ; MEM_COMMIT	
	static INPUT_KEYBOARD:=1, KEYEVENTF_KEYUP:=0x2, KEYEVENTF_UNICODE:=0x4
	static raw32:= A_IsUnicode 	? 	[1398167381,2333928579,2335974468,2335712340,2336498812,2335188044,3510641780,265304552,1468908103,6065414,2428514814,2520205,19707663,1714995843,264792713,2197892279,2305163968,3627672682,1150019190,3229955108,3280154229,612141314,608487172,7176,605849856,2198623999,3280538860,2300363907,1600019416,1989002077,666668288,0,203703495,0,136594631,0,2332214147,604292870,13,69485705,2198099711,3314094316,69500041,3341032585,470295620,4278190080,3968011350,2311293196,1459561516,82608904,3296974985,1600019228,2425406301,2425393296,2425393296,2425393296]
								:	[1398167381,2333928579,2335974468,2335712340,2336498812,3510641780,265304552,1418445383,3375444004,4261436557,2416330637,2520205,2200614415,3263365825,952140545,3362294118,4285183503,3832056166,3832793913,874792075,745914501,2298659715,3338937468,470295620,2298478592,1459561500,216826636,3296969609,1540917532,3277676382,649366928,0,203703495,0,136594631,0,2332214147,604292870,13,69485705,2198099711,3314094316,69500041,3341032585,470295620,4278190080,3968011350,2311293196,1459561516,82608904,3296974985,1600019228,3029189469,38,666668288,0,2428747825,2425393296,2425393296,2425393296]
	static raw64:=[1398167381,686588744,612141896,1955285112,3510726692,3241756137,3360100165,172461388,2370027569,1727924572,8658703,0,213323588,3229829377,2303026768,256159816,1208028343,1711456387,3628632389,3765683001,477483653,407276360,1090669453,10424,4203300864,683967304,1566531163,2430664520,1170813253,2336800817,899350,1459552256,38505736,1103464776,10424,4203300864,2300073727,3918088387,2299549439,3296938200,1600019240,2425406301,2425393296,2425393296]
	static sizeOfINPUT:=A_PtrSize=4 ? 28 : 40
	static MAXLEN:= 10000
	static INPUT
	static lib
	static bin:=cSendInputW("","",true)
	if init {
		bin:=DllCall("Kernel32.dll\VirtualAlloc", "Uptr",0, "Ptr", (raw:=A_PtrSize==4?raw32:raw64).length()*4, "Uint", flAllocationType, "Uint", flProtect, "Ptr")
		for k, i in raw
			NumPut(i,bin+(k-1)*4,"Int")
		raw32:="",raw64:=""
		dll:=DllCall("Kernel32.dll\LoadLibrary", "Str", "User32.dll", "Ptr")
		VarSetCapacity(lib,4*A_PtrSize,0)
		hookProc:=DllCall("Kernel32.dll\VirtualAlloc", "Uptr",0, "Ptr", 4, "Uint", flAllocationType, "Uint", flProtect, "Ptr")	; Pointer to hookProc
		NumPut(12828721, hookProc+0, 0, "Int")	; The hookProc
		; Fill in the fnLib, see struct in c code
		NumPut(hookProc, lib, 0, "Ptr")
		NumPut(DllCall("Kernel32.dll\GetProcAddress", "Ptr", dll, "AStr", "SetWindowsHookEx" . (A_IsUnicode ? "W" : "A"), "Ptr"), lib, A_PtrSize, "Ptr")
		NumPut(DllCall("Kernel32.dll\GetProcAddress", "Ptr", dll, "AStr", "UnhookWindowsHookEx", "Ptr"), lib, 2*A_PtrSize, "Ptr")
		NumPut(DllCall("Kernel32.dll\GetProcAddress", "Ptr", dll, "AStr", "SendInput", "Ptr"), lib, 3*A_PtrSize, "Ptr")
		DllCall("FreeLibrary", "Ptr", dll)
		; Allocate memory for INPUT array.
		VarSetCapacity(INPUT, sizeOfINPUT*MAXLEN,0)
		; Setup INPUT array.
		Loop, % MAXLEN {
			o:=sizeOfINPUT*(A_Index-1)
			NumPut(INPUT_KEYBOARD,													INPUT, o, "Uint"), 		o+=A_PtrSize+4				; type
			NumPut(KEYEVENTF_UNICODE |(mod(A_Index-1,2) ? KEYEVENTF_KEYUP : 0),		INPUT, o, "Uint"), 									; dwFlags.
		} 
		 
		return bin
	}
	return DllCall(bin, "Ptr", &str, "Int", doHook, "Uint", strlen(str), "Uint", MAXLEN, "Ptr", &lib, "Ptr", &INPUT, "Uint")
}
; c source code, compiled with gcc, (-Ofast, iirc) 
; For ansi, unsigned char* is used instead of unsigned short*
/*
#include <windows.h>

typedef HHOOK WINAPI (*_SetWindowsHookEx)(int,HOOKPROC,HINSTANCE,DWORD);
typedef BOOL WINAPI (*_UnhookWindowsHookEx)(HHOOK);
typedef UINT WINAPI (*_SendInput)(UINT,LPINPUT,int);

typedef struct fnLib {
	HOOKPROC llkbproc;
	_SetWindowsHookEx hook;
	_UnhookWindowsHookEx unhook;
	_SendInput	send;
} *pFnLib;

unsigned int sihook (unsigned short* str, int doHook, unsigned int n, unsigned int MAXLEN, pFnLib lib, INPUT* in){
    int i;
	int j=0;
	HHOOK h;
	MAXLEN>>=1;
	n = (n>MAXLEN) ? MAXLEN : n;
	for (i=0; i<=(n-1)*2; i=i+2){
		in[i].ki.wScan = str[j];
		in[i+1].ki.wScan = str[j++];
	}
	if (doHook){
		h=(*(lib->hook))(WH_KEYBOARD_LL,lib->llkbproc,NULL,0);
	}
	unsigned int r=(*(lib->send))(n*2,in,sizeof(INPUT));
	if (doHook){
		(*(lib->unhook))(h);
	}
	return r;
}

int f(){ //hookProc
	return 0;
}
*/