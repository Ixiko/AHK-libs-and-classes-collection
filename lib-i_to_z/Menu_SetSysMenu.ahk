;**********************************************************************************************
;**********************************************************************************************
/*  Menu_SetSysMenu.ahk - Library
     __ __ __ __ __ __ __ _ __
    / /_ / /__/ /_____ _ / / / /____ _/ /_ / /________________(_)___ / /_ ____ _______
   / __ \/ __/ __/ __ \(_) // // __ '/ __ \/ //_/ ___/ ___/ __/ / __ \/ __// __ \/ __/ _ \
  / / / / /_/ /_/ /_/ / / // // /_/ / / / / ,< (__ ) /__/ / / / /_/ / /__/ /_/ / / / / // /
 /_/ /__/\__/\__/ .___(_) // / \__,_/_/ /_/_/|_/____/\___/_/ /_/ .___/\__ (_)____/_/ \__ /
              /_/ /_///_/ /_/ (___/
              
  Script : System Menu : Add custom and/or remove standard items
  Author : SKAN ( arian.suresh@gmail.com ), Created: 19-Dec-2013
  Topic : http://ahkscript.org/boards/viewtopic.php?p=7630#p7630
  Modified by: tmplinshi
  
*/

/*  Example
      ;
      The
      Gui, +HwndHGUI ; Handle for the specified interface
      The
      SysMenuItems := "
      (LTrim Comments
      ----------------------------- ; Delimiter in the menu
      Window Top, 2015, gui_AlwaysOnTop, Checked1
      ; Format ---> Menu Name, Menu ID, Click on the label or function of the menu execution, check (can be Checked1 or Checked0)
      )"
      The
      Menu_SetSysMenu( HGUI, SysMenuItems, "Reset" )
*/
;**********************************************************************************************
;**********************************************************************************************

Menu_SetSysMenu(p*) {
  SystemMenu.Menu_SetSysMenu(p*)
}

Class SystemMenu {

  Static _ := OnMessage( 0x112, "SystemMenu.WM_SYSCOMMAND" )
  Static menu_func := {}

  WM_SYSCOMMAND( lParam, Msg, hWnd ) { ; WM_SYSCOMMAND() goo.gl/kDL6uM

    hSysMenu := SystemMenu.Menu_SetSysMenu( hWnd ) ; Get a Handle to SYSMENU

    wParam := this
    If SystemMenu.menu_func[wParam].checked
      SystemMenu.Menu_CheckItem( hSysMenu, wParam, False, -1 ) ; Toggle Checkmark
    If SystemMenu.menu_func.HasKey(wParam)
      SetTimer, % SystemMenu.menu_func[wParam].fn, -1
  }


  Menu_CheckItem( hMenu, ItemRef=0, ByPos=1, CheckState=1 ) {
  Static MF_BYCOMMAND := 0, MF_BYPOSITION := 0x400, MF_CHECKED := 0x8, MF_UNCHECKED := 0

    Flag := ByPos ? MF_BYPOSITION : MF_BYCOMMAND,
    ItemRef := ItemRef - ( ByPos ? 1 : 0 )
   
    Flag |= ( !CheckState ) ? MF_UNCHECKED ; GetMenuState() goo.gl/SjVKK8
         : (CheckState > 0) ? MF_CHECKED
         : ( DllCall( "GetMenuState", UInt, hMenu, UInt, ItemRef, UInt, Flag ) & MF_CHECKED
                                                               MF_UNCHECKED : MF_CHECKED )

  Return DllCall( "CheckMenuItem", UInt, hMenu, UInt, ItemRef, UInt, Flag ) ; goo.gl/L4FlQy
  }


  Menu_GetState( hMenu, ItemRef=0, ByPos=1, MF=0x8 ) {
  Static MF_BYCOMMAND := 0, MF_BYPOSITION := 0x400, MF_POPUP := 0x10

    Flag := ByPos ? MF_BYPOSITION : MF_BYCOMMAND
    ItemRef := ItemRef - ( ByPos ? 1 : 0 )

    R := DllCall( "GetMenuState", UInt,hMenu, UInt, ItemRef, UInt,Flag ) ; goo.gl/PdRLR9

  Return (MF=MF_POPUP ? (R&16 ? R>>8: 0) : MF>0 ? (R & MF = MF) : R )
  }


  Menu_SetSysMenu( hWnd, AddItems="", Options="" ) {
  Static MF_MENUBARBREAK := 0x20, MF_SEPARATOR := 0x800, MF_STRING := 0 ; goo.gl/ggTuwF
  Static SWP_Flag := 0x33 ; SWP_DRAWFRAME|SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE goo.gl/sah2Dm

    InStr( Options, "Reset" ) ? DllCall( "GetSystemMenu", UInt,hWnd, UInt,True )

    hMenu := DllCall( "GetSystemMenu", UInt,hWnd, UInt,0 ); GetSystemMenu() goo.gl/cfW40p
                                                             
    InStr( Options, "-Close" ) ? DllCall( "RemoveMenu", UInt,hMenu, UInt,0xF060, UInt,0 )
    InStr( Options, "-Move" ) ? DllCall( "RemoveMenu", UInt,hMenu, UInt,0xF010, UInt,0 )
                                                             ; RemoveMenu() goo.gl/KzP0Yg
    Loop, Parse, AddItems,`n, `r`t%A_Space%
    {
      Item := A_LoopField, F1 := "", F2 := 0
      F3 := "", F4 := ""

      Loop, Parse, Item, CSV, %A_Space%`t
        F%A_Index% := A_LoopField
                                                              
      DllCall( "AppendMenu", UInt, hMenu ; AppendMenu() goo.gl/ggTuwF
                           , UInt, !F2 ? MF_SEPARATOR : F2>>16 ? MF_MENUBARBREAK : MF_STRING
                           , UInt, F2 & 0xFFFF
                           , UInt, F2 ? &F1 : F2 )

      If RegExMatch(F4, "i)Checked\K\d", CheckState) {
        this.Menu_CheckItem( hMenu, F2, False, CheckState )
        This.menu_func[F2, "Checked"] := True
      }
      This.menu_func[F2, "fn"] := F3
    }

    If InStr( Options, "Redraw" ) ; SetWindowPos() goo.gl/sah2Dm
      DllCall( "SetWindowPos", UInt,hWnd, Int,0, Int,0, Int,0, Int,0, Int,0, UInt,SWP_Flag )

  Return hMenu, DllCall( "SetLastError", UInt, DllCall( "GetMenuItemCount", UInt, hMenu )
  }
}