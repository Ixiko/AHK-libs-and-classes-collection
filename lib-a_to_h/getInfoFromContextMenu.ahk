; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

;AHK v1.1 x64/x32 compatible update by jeeswg of:
;Get Info from Context Menu - Scripts and Functions - AutoHotkey Community
;https://autohotkey.com/board/topic/19754-get-info-from-context-menu/

;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         micha
;
; Script Function:
;	Demonstrates how to retrieve infos from a context/ popup menu
;

/*
  This is the struct we are using.

  typedef struct tagMENUITEMINFO {
  UINT    cbSize;
  UINT    fMask;
  UINT    fType;
  UINT    fState;
  UINT    wID;
  HMENU   hSubMenu;
  HBITMAP hbmpChecked;
  HBITMAP hbmpUnchecked;
  ULONG_PTR dwItemData;
  LPTSTR  dwTypeData;
  UINT    cch;
  HBITMAP hbmpItem;
} MENUITEMINFO, *LPMENUITEMINFO;

*/

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
#Persistent
SetTimer, Demo, 500
return

Demo:
;constants
  MFS_ENABLED = 0
  MFS_CHECKED = 8
  MFS_DEFAULT = 0x1000
  MFS_DISABLED = 2
  MFS_GRAYED = 1
  MFS_HILITE = 0x80
  ;MFS_UNCHECKED = 0
  ;MFS_UNHILITE = 0

  ;Get mouse position and handle to wnd under the mouse cursor
  MouseGetPos, MouseScreenX, MouseScreenY, MouseWindowUID, MouseControlID
  WinGet,ControlHwnd, ID,ahk_id %MouseWindowUID%
  ;Get count of menu items
  ContextMenCnt := GetContextMenuCount(ControlHwnd)
  if ContextMenCnt < 1
  {
   Tooltip,
   return
  }
  TooltipText =
  ;Read info for each menu item
  loop, %ContextMenCnt%
  {
   IsEnabled := GetContextMenuState(ControlHwnd, a_index-1)
   {
    CurrentText =
    if IsEnabled = 0
     CurrentText = %CurrentText% Enabled
    if (IsEnabled & MFS_CHECKED)
       CurrentText = %CurrentText% Checked
    if (IsEnabled & MFS_DEFAULT)
       CurrentText = %CurrentText% Default
    if (IsEnabled & MFS_DISABLED)
       CurrentText = %CurrentText% Disabled
    if (IsEnabled & MFS_GRAYED)
       CurrentText = %CurrentText% Grayed
    if (IsEnabled & MFS_HILITE)
       CurrentText = %CurrentText% Highlight
    TooltipText = %TooltipText%%a_index%:%CurrentText%`n
   }
  }
  TextText =
  loop, %ContextMenCnt%
  {
    StrSize := GetContextMenuText(ControlHwnd, a_index-1)
    nID := GetContextMenuID(ControlHwnd, a_index-1)
    TextText = %TextText%%a_index%:%StrSize%-ID=%nID%`n
  }
  CoordMode, Tooltip, Screen
  Tooltip, %TooltipText%---`n%TextText%, 0, 0
return

/***************************************************************
 * returns the count of menu items
 ***************************************************************
*/
GetContextMenuCount(hWnd)
{
  WinGetClass, WindowClass, ahk_id %hWnd%
  ;All popups should have the window class #32768
  if WindowClass <> #32768
  {
   return 0
  }
  ;Retrieve menu handle from window
  SendMessage, 0x01E1, , , , ahk_id %hWnd%
  ;Errorlevel is set by SendMessage. It contains the handle to the menu
  hMenu := errorlevel
  menuitemcount:=DllCall("GetMenuItemCount", Ptr,hMenu)
  Return, menuitemcount
}

/***************************************************************
 * returns the state of a menu entry
 ***************************************************************
*/
GetContextMenuState(hWnd, Position)
{
  WinGetClass, WindowClass, ahk_id %hWnd%
  if WindowClass <> #32768
  {
   return -1
  }
  SendMessage, 0x01E1, , , , ahk_id %hWnd%
  ;Errorlevel is set by SendMessage. It contains the handle to the menu
  hMenu := errorlevel

  ;We need to allocate a struct
  VarSetCapacity(MenuItemInfo, 60, 0)
  ;Set Size of Struct to the first member
  NumPut(A_PtrSize=8?80:48, MenuItemInfo, 0, "UInt")
  ;Get only Flags from dllcall GetMenuItemInfo MIIM_TYPE = 1
  NumPut(1, MenuItemInfo, 4, "UInt")

  ;GetMenuItemInfo: Handle to Menu, Index of Position, 0=Menu identifier / 1=Index
  InfoRes := DllCall("user32.dll\GetMenuItemInfo", Ptr,hMenu, UInt,Position, Int,1, Ptr,&MenuItemInfo)

  InfoResError := errorlevel
  LastErrorRes := DllCall("GetLastError", UInt)
  if InfoResError <> 0
     return -1
  if LastErrorRes != 0
     return -1

  ;Get Flag from struct
  GetMenuItemInfoRes := NumGet(MenuItemInfo, 12, "UInt")
  /*
  IsEnabled = 1
  if GetMenuItemInfoRes > 0
     IsEnabled = 0
  return IsEnabled
  */
  return GetMenuItemInfoRes
}

/***************************************************************
 * returns the ID of a menu entry
 ***************************************************************
*/
GetContextMenuID(hWnd, Position)
{
  WinGetClass, WindowClass, ahk_id %hWnd%
  if WindowClass <> #32768
  {
   return -1
  }
  SendMessage, 0x01E1, , , , ahk_id %hWnd%
  ;Errorlevel is set by SendMessage. It contains the handle to the menu
  hMenu := errorlevel

  ;UINT GetMenuItemID(          HMENU hMenu,    int nPos);
  InfoRes := DllCall("user32.dll\GetMenuItemID", Ptr,hMenu, Int,Position, UInt)

  InfoResError := errorlevel
  LastErrorRes := DllCall("GetLastError", UInt)
  if InfoResError <> 0
     return -1
  if LastErrorRes != 0
     return -1

  return InfoRes
}

/***************************************************************
 * returns the text of a menu entry (standard windows context menus only!!!)
 ***************************************************************
*/
GetContextMenuText(hWnd, Position)
{
  WinGetClass, WindowClass, ahk_id %hWnd%
  if WindowClass <> #32768
  {
   return -1
  }
  SendMessage, 0x01E1, , , , ahk_id %hWnd%
  ;Errorlevel is set by SendMessage. It contains the handle to the menu
  hMenu := errorlevel

  ;We need to allocate a struct
  VarSetCapacity(MenuItemInfo, 200, 0)
  ;Set Size of Struct (48) to the first member
  NumPut(A_PtrSize=8?80:48, MenuItemInfo, 0, "UInt")
  ;Retrieve string MIIM_STRING = 0x40 = 64 (/ MIIM_TYPE = 0x10 = 16)
  NumPut(64, MenuItemInfo, 4, "UInt")
  ;Set type - Get only size of string we need to allocate
  ;NumPut(0, MenuItemInfo, 8, "UInt")
  ;GetMenuItemInfo: Handle to Menu, Index of Position, 0=Menu identifier / 1=Index
  InfoRes := DllCall("user32.dll\GetMenuItemInfo", Ptr,hMenu, UInt,Position, Int,1, Ptr,&MenuItemInfo)
  if InfoRes = 0
     return -1

  InfoResError := errorlevel
  LastErrorRes := DllCall("GetLastError", UInt)
  if InfoResError <> 0
     return -1
  if LastErrorRes <> 0
     return -1

  ;Get size of string from struct
  GetMenuItemInfoRes := NumGet(MenuItemInfo, A_PtrSize=8?64:40, "UInt")
  ;If menu is empty return
  If GetMenuItemInfoRes = 0
     return "{Empty String}"

  ;+1 should be enough, we'll use 2
  GetMenuItemInfoRes += 2
  ;Set capacity of string that will be filled by windows
  VarSetCapacity(PopupText, GetMenuItemInfoRes, 0)
  ;Set Size plus 0 terminator + security ;-)
  NumPut(GetMenuItemInfoRes, MenuItemInfo, A_PtrSize=8?64:40, "UInt")
  NumPut(&PopupText, MenuItemInfo, A_PtrSize=8?56:36, "Ptr")

  InfoRes := DllCall("user32.dll\GetMenuItemInfo", Ptr,hMenu, UInt,Position, Int,1, Ptr,&MenuItemInfo)
  if InfoRes = 0
     return -1

  InfoResError := errorlevel
  LastErrorRes := DllCall("GetLastError", UInt)
  if InfoResError <> 0
     return -1
  if LastErrorRes <> 0
     return -1

  return PopupText
}

;PrintScreen::reload
