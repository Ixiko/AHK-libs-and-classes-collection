;PopUpMenuFix.ahk
;include this file and use the static class included,  
;Fixes the Default Menu Item not working hitting enter on a menu in using Menu,MyMenu,Show
;  Where the Default Menu should be triggered
;
;PopUpMenuFix, Singleton Static Class to wrap the functionality
;   ShowPopUp(MenuName as String, X as optional coord, Y as optional Coord) 
;        The function theat replaces  Menu,,Show
;           ;Menu,MyMenu,Show
;           PopUpMenuFix.ShowPopUp("MyMenu")
;
; Credit Goes To teadrinker (https://autohotkey.com/boards/memberlist.php?mode=viewprofile&u=62433)
; Based on his code submitted in this Topic (https://autohotkey.com/boards/viewtopic.php?f=5&t=36903)
;  
; Conversion to Singleton Static Class: icuurd12b42 (https://autohotkey.com/boards/memberlist.php?mode=viewprofile&u=71341)
; Topic: https://autohotkey.com/boards/viewtopic.php?f=6&t=36947
;
;see example use below.


;uncomment below to test on it's own, proper setup demonstracted here
/*
MsgBox , PopUpMenuFix Version 1, Hit F10
; 1) Make a menu, with a Default
Loop 4
{
   Menu, MyMenu, Add, Item %A_Index%, handling
}   
;set default it item 4
Menu, MyMenu, Default, Item 3
;Add a Quit menu
Menu, MyMenu, Add, Quit, OnQuit

return

; 2) Show the menu by "Name" using the helper function, Enter should return the default when in the menu
;;;;;;$F10::
PopUpMenuFix.ShowPopUp("MyMenu")
*/ 
;uncomment above to test on it's own, proper setup demonstracted here
Class PopUpMenuFix
{
    static m_MenuInfo :=
    static m_hHookKeybd :=
    ;the show menu
    ShowPopUp(strMenuName, X:=-100000, Y:=-100000)
    {
        
        PopUpMenuFix._SetHook()
        PopUpMenuFix.m_MenuInfo.hMenu := MenuGetHandle(strMenuName)
        if(X=-100000 and Y = -100000)        {
            Menu, %strMenuName%, Show
        }
        else if(X=-100000)
        {
            Menu, %strMenuName%, Show, , %Y%
        }
        else if(Y=-100000)
        {
            Menu, %strMenuName%, Show, %X%
        }
        else
        {
            Menu, %strMenuName%, Show, %X%, %Y%
        }
        PopUpMenuFix.m_MenuInfo.hMenu := ""
        PopUpMenuFix._ReleaseHook()
    }
    ;the supporting Show Menu functions
    _SetHook()
    {
        
        PopUpMenuFix.m_MenuInfo := {}
        
        ObjPtr := Object(PopUpMenuFix.m_MenuInfo)
        PopUpMenuFix.m_hHookKeybd := DllCall("SetWindowsHookEx"
        , Int, WH_KEYBOARD_LL := 13
        , Ptr, RegisterCallback("PopUpMenuFix_LowLevelKeyboardProc", "", 3, ObjPtr)
        , Ptr, DllCall("GetModuleHandle", UInt, 0, Ptr)
        , UInt, 0, Ptr)
        ObjRelease(ObjPtr)
    }
    _ReleaseHook()
    {
        
        DllCall("UnhookWindowsHookEx", Ptr, PopUpMenuFix.m_hHookKeybd)
    }
    LowLevelKeyboardProc(nCode, wParam, lParam)
    {
        
        PopUpMenuFix_LowLevelKeyboardProc(nCode, wParam, lParam)
    }
}


;the calbacks
PopUpMenuFix_LowLevelKeyboardProc(nCode, wParam, lParam)
{
   static PID := DllCall("GetCurrentProcessId"), LLKHF_INJECTED := 0x10, SC_ENTER := 0x1C
   
   msg   := wParam   
   flags := NumGet(lParam + 8, "UInt")
   ext   := flags & 1
   sc    := NumGet(lParam + 4, "UInt") | ext << 8
   INJECTED := (flags & LLKHF_INJECTED) >> 4
   MenuInfo := Object(A_EventInfo)
   
   if ( sc = SC_ENTER && !INJECTED && !(msg & 1) && (hwnd := WinExist("ahk_class #32768 ahk_pid " . PID)) && hMenu := MenuInfo.hMenu )  {
      timerId := DllCall("SetTimer", Ptr, 0, Ptr, 0, UInt, 10, Ptr, RegisterCallback("PopUpMenuFix_SendKeys", "", 0, A_EventInfo), Ptr)
      MenuInfo.hWnd := hwnd, MenuInfo.TimerID := timerId
      Return 1
   }
   Return DllCall("CallNextHookEx", Ptr, 0, Int, nCode, Ptr, wParam, Ptr, lParam)
}


PopUpMenuFix_SendKeys()  {
   static SC_ENTER := 0x1C, VK_ENTER := 0xD, KEYEVENTF_KEYUP := 2
        , MF_BYPOSITION := 0x400, MF_HILITE := 0x80, MIIM_ID := 0x2
        , WM_CANCELMODE := 0x1F, WM_COMMAND := 0x111
   DefaultItem :=-1     
   MenuInfo := Object(A_EventInfo)
   DllCall("KillTimer", Ptr, 0, Ptr, MenuInfo.timerID)
   hMenu := MenuInfo.hMenu
   
   Loop % DllCall("GetMenuItemCount", Ptr, hMenu)  {
      state := DllCall("GetMenuState", Ptr, hMenu, UInt, A_Index - 1, UInt, MF_BYPOSITION)
      if (state & MF_HILITE)  {
         DefaultItem := 0
         break
      }
   }
   if (DefaultItem = 0)
      DllCall("keybd_event", UChar, VK_ENTER, UChar, SC_ENTER, UInt, 0, Ptr, 0)
   if (DefaultItem != 0)  {
      DefaultItem := DllCall("GetMenuDefaultItem", Ptr, hMenu, UInt, true, UInt, 0)
      if (DefaultItem != -1)  {
         VarSetCapacity(MENUITEMINFO, size := 4*4 + A_PtrSize*8, 0)
         NumPut(size, MENUITEMINFO)
         NumPut(MIIM_ID, MENUITEMINFO, 4)
         DllCall("GetMenuItemInfo", Ptr, hMenu, UInt, DefaultItem, UInt, true, Ptr, &MENUITEMINFO)
         MenuID := NumGet(MENUITEMINFO, 16, "UInt")
         DllCall("PostMessage", Ptr, A_ScriptHwnd, UInt, WM_CANCELMODE, Ptr, 0, Ptr, 0)
         DllCall("PostMessage", Ptr, A_ScriptHwnd, UInt, WM_COMMAND, Ptr, MenuID, Ptr, 0)
      }
   }
}