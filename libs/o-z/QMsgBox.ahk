QMsgBoxF( title = "", msg = "", sBtns = "OK", icon = "", centered = True, modal = False )
{
  box := new QMsgBox( { "msg" 	: msg
            , "buttons" : sBtns
            , "center" 	: centered
            , "modal"	: modal
            , "title"	: title
            , "pic"		: icon } )
  return box.Show()
}

class QMsgBox
{
  __New( params )
  {
    this.SetParams( params )
    this.alive := 1
  }
  
  ;uses guis 75-85
  _GetFreeGui()
  {
    guinum := 75
    loop, 10
    {
      num := A_Index+74
      Gui, %num%:+LastFoundExist
      if !WinExist()
      {
        guinum := num
        break
      }
    }
    this.guinum := guinum
  }
  
  SetParams( params )
  {
    if !IsObject( params )
    {
      if ( params != "" )
        this.msg := params
    }
    else
    {
      for name,val in params
        if ( val != "" )
          this[ name ] := val
    }
  }
  
  Destroy()
  {
    this._ChangeModal( -1 )
    Gui,% this.guinum ":Destroy"
    this.alive := 0
  }
  
  __Delete()
  {
    return
  }
  
  ; returns defaults
  __Get( name )
  {
    return QMsgBox._defaults[ name ]
  }
  
  _ChangeModal( mode )
  {
    if !this.modal
      return
    for i,nGui in StrSplit( this.pGuis, "|", A_tab A_Space )
    {
      if ( !nGui || nGui > 99 )
        continue
      if ( i = 1 )
        Gui,% this.guinum ":" ( mode = 1 ? "+owner" : "-owner" ) nGui
      Gui,%  nGui ":" ( mode = 1 ? "+Disabled" : "-Disabled" )
    }
  }
  
  _GetPos()
  {
    if this.center
      return "center"
    else
    {
      storeDHW := A_DetectHiddenWindows
      DetectHiddenWindows, On
      ControlGetPos, bX, bY, bW, bH, Button1,% "ahk_id " this.handle
      CoordMode,Mouse,Screen
      MouseGetPos, mX, mY
      WinGetPos,,,wW,wH,% "ahk_id " this.handle
      x := round( mX - bW/2 - bX )
      x := ( x + wW ) > A_ScreenWidth ? ( A_ScreenWidth - wW ) : x < 0 ? 0 : x
      y := round( mY - bH/2 - bY )
      y := ( y + wH ) > A_ScreenHeight ? ( A_ScreenHeight - wH ) : y < 0 ? 0 : y
      DetectHiddenWindows,% storeDHW
      return "x" x " y" y
    }
  }
  
  _AddPic()
  {
    token := Gdip_Startup()
    pic := this.pic
    if !pic
      hBitmap := 0
    if IsInteger( pic )
      hBitmap := pic
    else if pic in !,?,x,i,s
    {
      IDI := pic = "!" ? 32515
        :  pic = "?" ? 32514
        :  pic = "x" ? 32513
        :  pic = "i" ? 32516
        :  pic = "s" ? 32518 : 0
      if !IDI
        return 0
      if hIcon := DllCall( "LoadImageW"
              , "Ptr", 0
              , "Uint", IDI
              , "UInt", 1
              , "UInt", 0
              , "UInt", 0
              , "Uint", 0x00008000
              ,"Ptr" )
        hBitmap := HBITMAPfromHICON( hIcon )
      else
        hBitmap := 0
    }
    else
    {
      resPath := IconGetPath( pic )
      resIdx  := IconGetIndex( pic )
      if ( resIdx = "" )
      {
        DllCall("gdiplus\GdipCreateBitmapFromFile", "wstr", resPath, "Ptr*", pBitmap )
        DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "Ptr*", hBitmap, "int", 0xffffffff )
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
      }
      else
      {
        if hIcon := IconExtract( resPath, resIdx, 0 )
          hBitmap := HBITMAPfromHICON( hIcon )
        else
          hBitmap := 0
        DllCall( "DestroyIcon", "Ptr", hIcon )
      }
    }
    if !hBitmap
      return 0
    Gui,% this.guinum ":Default"
    Gui, Add, Picture,% "hwndPicHwnd +" SS_BITMAP := 0xE
    SendMessage,% STM_SETIMAGE := 0x0172,% IMAGE_BITMAP := 0,% hBitmap,, ahk_id %PicHwnd%
    DllCall("DeleteObject", "Ptr", hBitmap )
    Gdip_Shutdown( token )
    return PicHwnd
  }
  
  Show( pGuis = "" ) 
  {
    this._GetFreeGui()
    this.pressed := ""
    Gui,% this.guinum ":Default"
    Gui,Destroy
    this.alive := 1
    options .= this.ontop ? " +AlwaysOnTop " : ""
    options .= this.nocaption ? " -Caption +Border " : ""
    options .= this.nosysmenu ? " -SysMenu " : ""
    Gui % "+LabelQMsgBox -MaximizeBox -MinimizeBox " options
    Gui, +HWNDhandle
    this.handle := handle
    this.pGuis := ( this.modal ? A_Gui "|" : "" ) . pGuis
    aBtns := StrSplit( this.buttons, "|", A_Space A_Tab )
    cnt := aBtns.MaxIndex()
    defButWid := QMsgBox.defButtonWidth
    btnsWidth := ( ( cnt * defButWid ) + ( cnt-1 )*5 )
    
    this._ChangeModal( 1 )
    
    if PicHwnd := this._AddPic()
      ControlGetPos,,,pW,pH,,ahk_id %PicHwnd%
    else
      pW := 0, pH := 0
    textBoxWidth := btnsWidth > QMsgBox.defTextWidth ? btnsWidth : QMsgBox.defTextWidth
    Gui, Add, Text,% "ym +Wrap +hwndTextHwnd +Multi x+" pW+10 " w" textBoxWidth,% this.msg
    ControlGetPos,,,,tH,,ahk_id %TextHwnd%
    ButPosY := ( tH > pH ? tH : pH ) + 15
    for i,btn in aBtns
      Gui,Add,Button,% "y" ButPosY " x" (i=1?"p":"+5") " w" defButWid " gQMsgBoxOnPress",% btn
    Gui,Show,hide autosize
    Gui, Show,% this._GetPos(),% this.title
    while this.alive
      sleep 100
      ,sleep -1
    return this.pressed
    
    QMsgBoxClose:
      this.Destroy()
      return
      
    QMsgBoxOnPress:
      this.pressed := A_GuiControl
      this.Destroy()
      return
  }
  
  static defButtonWidth := 70
  ,defTextWidth := 300
  
  static _defaults := { "title"		: "Message"
                        ,"msg" 		: "press any button to continue"
                        ,"buttons": "OK"
                        ,"ontop"	: 0 
                        ,"nocaption": 0 
                        ,"nosysmenu": 0
                        ,"modal"	: 0
                        ,"center"	: 1
                        ,"pic"		: 0 }
}