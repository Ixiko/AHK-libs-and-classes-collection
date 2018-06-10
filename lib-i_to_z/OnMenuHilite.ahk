/*
  DISCLAIMER : Experimental code
  Show Menu tips with modeless menu / SKAN ( arian.suresh@gmail.com ) / 12-Dec-2013
  Topic:  http://ahkscript.org/boards/viewtopic.php?t=971

  Info:
  WM_MENUSELECT() creates/updates the following global variables:
  OMH_Handle   :  Handle/hMenu of the active menu.
  OMH_Flags    :  Flags to be used for testing whether the item is disabled/checked etc.
  OMH_IsPopup  :  Will be true when a submenu is being highlighted or false otherwise.
  OMH_String   :  The Menu Item string. Will contain a TAB if item uses accelerator key.
  OMH_ItemRef  :  Depends on OMH_IsPopup. It is MenuItemPos when OMH_IsPopup is 1 (true)
                                             or CommandID   when OMH_IsPopup is 0 (false).

  Reference:

  majkinetor & Mr.Chris
  http://goo.gl/P8mQhG  How to add menu tooltip or right mouse button notification
  http://goo.gl/Bc35dV  Dropped messages

------------------------------------------------------------------------------------------
*/


If IsLabel( "OnMenuHilite" )
  OnMessage( 0x11F, "WM_MENUSELECT" ), OnMessage( 0x211, "WM_ENTERMENULOOP" )


WM_ENTERMENULOOP() {
  Return True
}

WM_MENUSELECT( wParam, lParam, Msg, hWnd ) {
Global OMH_Handle, OMH_Flags, OMH_IsPopup, OMH_ItemRef, OMH_String
  VarSetCapacity( OMH_String ) < 2048 ? VarSetCapacity( OMH_String, 2048 ) : 0

  OMH_Handle  := lParam                       ; hMenu
  OMH_Flags   := wParam >> 16                 ; wParam HiWord,  Refer MSDN: goo.gl/Xs9QwU
  OMH_IsPopup := ( OMH_Flags & 0x10 = 0x10 )  ; Test 'Flags' for MF_POPUP=0x10
  OMH_ItemRef := ( wParam & 0xFFFF )          ; Extract MenuItemPos/CommandID from LoWord

  DllCall( "GetMenuString", UInt,OMH_Handle   ; MF_BYPOSITION = 0x400, MF_BYCOMMAND = 0
            , UInt,OMH_ItemRef, Str,OMH_String, UInt,1024, UInt,OMH_IsPopup ? 0x400 : 0 )

  If IsLabel( Label := "OnMenuHilite" )
   SetTimer, %Label%, -1
}