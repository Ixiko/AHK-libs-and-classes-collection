; Title:   	Pressing an element on a web page
; Link:   	autohotkey.com/boards/viewtopic.php?f=76&t=87021&hilit=acc+click
; Author:   ? teadrinker + AHKStudent
; Date:     17.02.2021
; for:     	AHK_L

/*
; @teadrinker 's chromejs method is perfect for this, here is a sample, run the script, come back to this page
; and hit w (warning: it will click on logo and navigate you away from this page)

   SetBatchLines, -1
   js =
   (
      javascript:
      document.getElementsByClassName("site_logo")[0].click();
   )
   Return

w::
   RunJsFromChromeAddressBar(js)
Return

*/

RunJsFromChromeAddressBar(js, exe := "chrome.exe") {
   static WM_GETOBJECT := 0x3D
        , ROLE_SYSTEM_TEXT := 0x2A
        , STATE_SYSTEM_FOCUSABLE := 0x100000
        , SELFLAG_TAKEFOCUS := 0x1
        , AccAddrBar
   if !AccAddrBar {
      window := "ahk_class Chrome_WidgetWin_1 ahk_exe " . exe
      SendMessage, WM_GETOBJECT, 0, 1, Chrome_RenderWidgetHostHWND1, % window
      AccChrome := AccObjectFromWindow( WinExist(window) )
      AccAddrBar := AccSearchElement(AccChrome, {Role: ROLE_SYSTEM_TEXT, State: STATE_SYSTEM_FOCUSABLE})
   }
   AccAddrBar.accValue(0) := "javascript:" . js
   AccAddrBar.accSelect(SELFLAG_TAKEFOCUS, 0)
   ControlSend,, {Enter}, % window, Chrome Legacy Window
}

AccSearchElement(parentElement, params) {
   found := true
   for k, v in params {
      try {
         if (k = "ChildCount")
            (parentElement.accChildCount != v && found := false)
         else if (k = "State")
            (!(parentElement.accState(0) & v) && found := false)
         else
            (parentElement["acc" . k](0) != v && found := false)
      }
      catch
         found := false
   } until !found
   if found
      Return parentElement

   for k, v in AccChildren(parentElement)
      if obj := SearchElement(v, params)
         Return obj
}

AccObjectFromWindow(hWnd, idObject = 0) {
   static IID_IDispatch   := "{00020400-0000-0000-C000-000000000046}"
        , IID_IAccessible := "{618736E0-3C3D-11CF-810C-00AA00389B71}"
        , OBJID_NATIVEOM  := 0xFFFFFFF0, VT_DISPATCH := 9, F_OWNVALUE := 1
        , h := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")

   VarSetCapacity(IID, 16), idObject &= 0xFFFFFFFF
   DllCall("ole32\CLSIDFromString", "Str", idObject = OBJID_NATIVEOM ? IID_IDispatch : IID_IAccessible, "Ptr", &IID)
   if DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject, "Ptr", &IID, "PtrP", pAcc) = 0
      Return ComObject(VT_DISPATCH, pAcc, F_OWNVALUE)
}

AccChildren(Acc) {
   static VT_DISPATCH := 9
   Loop 1  {
      if ComObjType(Acc, "Name") != "IAccessible"  {
         error := "Invalid IAccessible Object"
         break
      }
      try cChildren := Acc.accChildCount
      catch
         Return ""
      Children := []
      VarSetCapacity(varChildren, cChildren*(8 + A_PtrSize*2), 0)
      res := DllCall("oleacc\AccessibleChildren", "Ptr", ComObjValue(Acc), "Int", 0
                                                , "Int", cChildren, "Ptr", &varChildren, "IntP", cChildren)
      if (res != 0) {
         error := "AccessibleChildren DllCall Failed"
         break
      }
      Loop % cChildren  {
         i := (A_Index - 1)*(A_PtrSize*2 + 8)
         child := NumGet(varChildren, i + 8)
         Children.Push( (b := NumGet(varChildren, i) = VT_DISPATCH) ? AccQuery(child) : child )
         ( b && ObjRelease(child) )
      }
   }
   if error
      ErrorLevel := error
   else
      Return Children.MaxIndex() ? Children : ""
}

AccQuery(Acc) {
   static IAccessible := "{618736e0-3c3d-11cf-810c-00aa00389b71}", VT_DISPATCH := 9, F_OWNVALUE := 1
   try Return ComObject(VT_DISPATCH, ComObjQuery(Acc, IAccessible), F_OWNVALUE)
}