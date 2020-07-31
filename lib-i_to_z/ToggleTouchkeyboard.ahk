; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

ToggleTouchKeyboard()

ToggleTouchKeyboard() {
   static CLSID_UIHostNoLaunch := "{4CE576FA-83DC-4F88-951C-9D0782B4E376}"
        , IID_ITipInvocation   := "{37C994E7-432B-4834-A2F7-DCE1F13B834B}"
   Process, Exist, TabTip.exe
   if !ErrorLevel
      Run, TabTip.exe
   else {
      pTip := ComObjCreate(CLSID_UIHostNoLaunch, IID_ITipInvocation)
      ; ITipInvocation —> Toggle
      DllCall(NumGet(NumGet(pTip+0) + A_PtrSize*3), Ptr, pTip, Ptr, DllCall("GetDesktopWindow", Ptr))
      ObjRelease(pTip)
   }
}