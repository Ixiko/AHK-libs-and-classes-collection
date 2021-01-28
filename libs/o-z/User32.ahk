;
; AutoHotkey Version: 1.0.47.06
; Platform:       WinXP
; Author:         Yonken <yonken@163.com>
;
; Wrappers of Windows Apis Reside In User32.dll

; Do NOT modify following variables!

WM_USER						:= 0x0400

MK_LBUTTON 			:= 0x0001
MK_RBUTTON 			:= 0x0002
MK_SHIFT 				:= 0x0004
MK_CONTROL			:= 0x0008
MK_MBUTTON 			:= 0x0010
MK_XBUTTON1 		:= 0x0020
MK_XBUTTON2 		:= 0x0040

WM_PAINT						:= 0x000F

WM_GETICON					:= 0x007F
WM_SETICON					:= 0x0080

ICON_SMALL					:= 0
ICON_BIG						:= 1
ICON_SMALL2					:= 2

WM_MOUSEFIRST			:= 0x0200
WM_MOUSEMOVE				:= 0x0200
WM_LBUTTONDOWN			:= 0x0201
WM_LBUTTONUP				:= 0x0202
WM_LBUTTONDBLCLK		:= 0x0203
WM_RBUTTONDOWN			:= 0x0204
WM_RBUTTONUP				:= 0x0205
WM_RBUTTONDBLCLK		:= 0x0206
WM_MBUTTONDOWN		:= 0x0207
WM_MBUTTONUP				:= 0x0208
WM_MBUTTONDBLCLK		:= 0x0209
WM_MOUSEWHEEL			:= 0x020A
WM_XBUTTONDOWN			:= 0x020B
WM_XBUTTONUP				:= 0x020C
WM_XBUTTONDBLCLK		:= 0x020D
WM_MOUSELAST				:= 0x020D
WM_MOUSELAST				:= 0x020A
WM_MOUSELAST				:= 0x0209

WM_SIZING					:= 0x0214
WM_CAPTURECHANGED		:= 0x0215
WM_MOVING					:= 0x0216

TB_ENABLEBUTTON					:= WM_USER + 1
TB_CHECKBUTTON					:= WM_USER + 2
TB_PRESSBUTTON					:= WM_USER + 3
TB_HIDEBUTTON						:= WM_USER + 4
TB_INDETERMINATE					:= WM_USER + 5
TB_MARKBUTTON						:= WM_USER + 6
TB_ISBUTTONENABLED				:= WM_USER + 9
TB_ISBUTTONCHECKED				:= WM_USER + 10
TB_ISBUTTONPRESSED				:= WM_USER + 11
TB_ISBUTTONHIDDEN				:= WM_USER + 12
TB_ISBUTTONINDETERMINATE	:= WM_USER + 13
TB_ISBUTTONHIGHLIGHTED		:= WM_USER + 14
TB_SETSTATE							:= WM_USER + 17
TB_GETSTATE							:= WM_USER + 18
TB_ADDBITMAP						:= WM_USER + 19
TB_DELETEBUTTON					:= WM_USER + 22
TB_GETBUTTON						:= WM_USER + 23
TB_BUTTONCOUNT					:= WM_USER + 24
TB_COMMANDTOINDEX				:= WM_USER + 25
TB_GETBUTTONTEXTA				:= WM_USER + 45
TB_GETBUTTONTEXTW				:= WM_USER + 75
TB_GETBUTTONTEXT				:= TB_GETBUTTONTEXTA
TB_SETSTYLE							:= WM_USER + 56
TB_GETSTYLE							:= WM_USER + 57
TB_MOVEBUTTON						:= WM_USER + 82

TBSTATE_CHECKED					:= 0x01
TBSTATE_PRESSED					:= 0x02
TBSTATE_ENABLED					:= 0x04
TBSTATE_HIDDEN					:= 0x08
TBSTATE_INDETERMINATE			:= 0x10

GCL_MENUNAME						:= -8
GCL_HBRBACKGROUND				:= -10
GCL_HCURSOR							:= -12
GCL_HICON								:= -14
GCL_HMODULE							:= -16
GCL_CBWNDEXTRA					:= -18
GCL_CBCLSEXTRA					:= -20
GCL_WNDPROC						:= -24
GCL_STYLE								:= -26
GCW_ATOM							:= -32
GCL_HICONSM							:= -34

; DWORD GetWindowThreadProcessId(
; 	 HWND hWnd,
; 	 LPDWORD lpdwProcessId
; );

GetWindowThreadProcessId(hWnd, lpdwProcessId)
{
	return DllCall("GetWindowThreadProcessId", "UInt", hWnd, "UInt", lpdwProcessId)
}

; HWND FindWindow(
; 	 LPCTSTR lpClassName,
; 	 LPCTSTR lpWindowName
; );

FindWindow(lpClassName, lpWindowName)
{
	return DllCall("FindWindow"
		, lpClassName = 0 ? "UInt" : "Str", lpClassName
		, lpWindowName = 0 ? "UInt" : "Str", lpWindowName)
}

; HWND FindWindowEx(
; 	 HWND hwndParent,
; 	 HWND hwndChildAfter,
; 	 LPCTSTR lpszClass,
; 	 LPCTSTR lpszWindow
; );

FindWindowEx(hwndParent, hwndChildAfter, lpszClass, lpszWindow)
{
	return DllCall("FindWindowEx", "UInt", hwndParent, "UInt", hwndChildAfter
		, lpszClass = 0 ? "UInt" : "Str", lpszClass
		, lpszWindow = 0 ? "UInt" : "Str", lpszWindow)
}

; LRESULT SendMessage(
; 	 HWND hWnd,
; 	 UINT Msg,
; 	 WPARAM wParam,
; 	 LPARAM lParam
; );

SendMessage(hWnd, Msg, wParam, lParam)
{
	return DllCall("SendMessage", "UInt", hWnd, "UInt", Msg, "UInt", wParam, "UInt", lParam)
}

; BOOL PostMessage(
; 	 HWND hWnd,
; 	 UINT Msg,
; 	 WPARAM wParam,
; 	 LPARAM lParam
; );

PostMessage(hWnd, Msg, wParam, lParam)
{
	return DllCall("PostMessage", "UInt", hWnd, "UInt", Msg, "UInt", wParam, "UInt", lParam)
}

; HDC GetDC(
; 	 HWND hWnd // handle to window
; );

GetDC(hWnd)
{
	return DllCall("GetDC", "UInt", hWnd)
}

; HDC GetWindowDC(
; 	 HWND hWnd // handle to window
; );

GetWindowDC(hWnd)
{
	return DllCall("GetWindowDC", "UInt", hWnd)
}

; int ReleaseDC(
;   HWND hWnd,  // handle to window
;   HDC hDC     // handle to DC
; );

ReleaseDC(hWnd, hDC)
{
	return DllCall("ReleaseDC", "UInt", hWnd, "UInt", hDC)
}

; int FillRect(
;   HDC hDC,           // handle to DC
;   CONST RECT *lprc,  // rectangle
;   HBRUSH hbr         // handle to brush
; );

FillRect(hDC, lprc, hbr)
{
	return DllCall("FillRect", "UInt", hDC, "UInt", lprc, "UInt", hbr)
}

; BOOL UpdateWindow(
;   HWND hWnd   // handle to window
; );

UpdateWindow(hWnd)
{
	return DllCall("UpdateWindow", "UInt", hWnd)
}

; BOOL DrawIcon(
; 	 HDC hDC,
; 	 int X,
; 	 int Y,
; 	 HICON hIcon
; );

DrawIcon(hDC, X, Y, hIcon)
{
	return DllCall("DrawIcon", "UInt", hDC, "Int", X, "Int", Y, "UInt", hIcon)
}

; DWORD GetClassLong(
; 	 HWND hWnd,
; 	 int nIndex
; );

GetClassLong(hWnd, nIndex)
{
	return DllCall("GetClassLong", "UInt", hWnd, "Int", nIndex)
}

