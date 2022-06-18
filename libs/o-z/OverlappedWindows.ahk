; https://www.autohotkey.com/board/topic/80470-getoverlappingwindows/

GetOverlappingWindows(HWND) {

   VarSetCapacity(RECT1, 16, 0)
   VarSetCapacity(RECT2, 16, 0)

   PtrType := A_PtrSize ? "Ptr" : "UInt" ; AHK_L : AHK_Basic
   Overlapping := ""

   DllCall("User32.dll\GetWindowRect", PtrType, HWND, PtrType, &RECT1)
   WinGet, HWIN, List

   Loop, %HWIN% {

      If (HWIN%A_Index% = HWND)
         Break

      DllCall("User32.dll\GetWindowRect", PtrType, HWIN%A_Index%, PtrType, &RECT2)
      ; http://msdn.microsoft.com/en-us/library/dd145001(VS.85).aspx
      If DllCall("User32.dll\IntersectRect", PtrType, &RECT2, PtrType, &RECT1, PtrType, &RECT2, "UInt")
         Overlapping .= (Overlapping ? "," : "") . HWIN%A_Index%

   }

   Return Overlapping
}

OverlappingWindows(HWND1, HWND2) {                                                                                   	;-- compares two windows
  ; // modified from:    http://www.autohotkey.com/community/viewtopic.php?f=2&t=86283
	VarSetCapacity(RECT1, 16, 0)
	VarSetCapacity(RECT2, 16, 0)
	PtrType := A_PtrSize ? "Ptr" : "UInt" ; AHK_L : AHK_Basic
	DllCall("User32.dll\GetWindowRect", PtrType, HWND1, PtrType, &RECT1)
	DllCall("User32.dll\GetWindowRect", PtrType, HWND2, PtrType, &RECT2)
  ; http://msdn.microsoft.com/en-us/library/dd145001(VS.85).aspx
return DllCall("User32.dll\IntersectRect", PtrType, &RECT2, PtrType, &RECT1, PtrType, &RECT2, "UInt") ? true : false
}

GetNextOverlappedWindow(HWND) {
   ;// modified from:    http://www.autohotkey.com/community/viewtopic.php?f=2&t=86283
   VarSetCapacity(RECT1, 16, 0)
   VarSetCapacity(RECT2, 16, 0)
   PtrType := A_PtrSize ? "Ptr" : "UInt" ; AHK_L : AHK_Basic
   DllCall("User32.dll\GetWindowRect", PtrType, HWND, PtrType, &RECT1)
   WinGet, HWIN, List
   Loop % HWIN {
      hNextwin := HWIN%A_Index%
      If (hNextwin = HWND)
         continue
      DllCall("User32.dll\GetWindowRect", PtrType, hNextwin, PtrType, &RECT2)
      ; http://msdn.microsoft.com/en-us/library/dd145001(VS.85).aspx
      If DllCall("User32.dll\IntersectRect", PtrType, &RECT2, PtrType, &RECT1, PtrType, &RECT2, "UInt")
         If !RegExMatch(class, "i)(tooltip)")
            return class ": " hNextwin
   }
}
