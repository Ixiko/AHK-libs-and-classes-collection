; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=85417
; Author:
; Date:
; for:     	AHK_L

/*


*/

;***************************************************************************************************
#Include <My Altered Gdip Lib>  ;<------       Replace with your copy of GDIP
;***************************************************************************************************
;***************************************************************************************************
;~ #Include <ColorTip>  ; Already at the bottom of this script
;***************************************************************************************************
#SingleInstance, Force
#NoEnv
ListLines, Off
SetBatchLines, -1
OnExit, *ESC

pToken := Gdip_Startup()

Index := 0

Needle := {"Total":"0xFFFFFFFF","Index:":"0xFFFFFF00",Current:"0xFFFFFFFF"}
Needle2 := {Fuzzy:0xFFFF00FF,Wuzzy:0xFF00FFFF,Bear:0xFFFFFF00,Hair:0xFF00FF00}

text1 := "Fuzzy Wuzzy Was A Bear `n Fuzzy Wuzzy Had No Hair `n Fuzzy Wuzzy Wasn't fuzzy was he?"

; Color Tip 1
;****************************
Tip1 := New ColorTip(0.016000,Needle,"Segoe UI","0xFFFF0000","s36 Bold","0xFF000000",0)
;****************************
; Color Tip 2
;****************************
Tip2 := New ColorTip(0.016000,Needle,"Arial","0xFFFF0000","s16","0xFF000000",0,800,600,30,10)
;****************************
; Color Tip 3
;****************************
Tip3 := New ColorTip()
Tip3.Set("X_Position",1000)
;~ Tip3.Set("Y_Position",400)
Tip3.Y_Position := 400
Tip3.Set("BackgroundColor",0xFF222222)
;~ Tip3.BackgroundColor := "0xFFFFFF00"
Tip3.FontColor := "0xFFFFFFFF"
Tip3.Roundness := 15, Tip3.MarginX := 30, Tip3.MarginY := 15
Tip3.Set("Needle",Needle2)
Tip3.Update(Text1)
;****************************
SetTimer, Numpad1, 100
return
*ESC::
	GDIP_ShutDown(pToken)
	ExitApp

Numpad1::
	; Examples of using the "Set" method  (can also just set the keys/values)
	;***************************************************************************************************
	;***************************************************************************************************
	if(Index=25){
		Tip1.Set("FontOptions","s12")
		Tip1.Set("X_Position",100)
	}else if(Index=50){
		Tip1.Set("X_Position","")
		Tip1.Set("Y_Position",100)
	}else if(Index=100){
		Tip1.Set("Needle",{"Time":"0xFFFF00FF",Total:"0xFF0000FF"})
		Tip1.Set("Y_Position",300)
		Tip1.Set("X_Position",300)
		Tip1.Set("FontOptions","s22 Bold")
		Tip1.Set("Font","Segoe Ui")
	}else if(Index=150){
		Tip1.Set("FontColor","0xFF000000")
		Tip1.Set("BackgroundColor","0xFF00FF00")
		Tip1.Set("Roundness",10)
	}else if(Index=200){
		Tip1.Set("FontColor","0xFFFFFF00")
		Tip1.Set("BackgroundColor","0x66000000")
		Tip1.Set("Needle","")
		Tip2.Set("Roundness",20)
	}else if(Index=250){
		Tip1.Set("FontColor","0xFFFFFF00")
		Tip1.Set("BackgroundColor","0x66000000")
		Needle["Index:"]:="0xFFFF0000"
		Tip1.Set("Needle",Needle)
		Tip1.FreeMode()
	}else if(Index=350){
		Tip1.Hide()
		SetTimer, Numpad1, Off
		return
	}
	;***************************************************************************************************
	;***************************************************************************************************
	; Example of updating and displaying the tip
	Tip1.Update( "Total Time : " totalTime/1000 " `n Index: " ++Index)
	Tip2.Update( "Current Second : " A_Sec " `n Index: " Index)
	;***************************************************************************************************
	;***************************************************************************************************
	totalTime := A_TickCount - startTime
	startTime := A_TickCount
	return

Numpad2::
	ColorTip.Helper()  ;  <----  Calling the Helper Gui
	Tip3 := "" ; Deleting Tip3
	return

;********************************************************************************************************************************************************************************
;********************************************************************************************************************************************************************************
; ColorTip Class By Hellbent
; Jan 7th, 2021
; Create multi-colored tooltips
; Credits:
;********************************************************************************************************************************************************************************
;********************************************************************************************************************************************************************************
class ColorTip	{
	static WindowCount := 0
	__New(Text := "No Text Added Yet", Needle := "", Font := "Arial", FontColor := "0xFF000000", FontOptions := "s12 Bold", BackgroundColor := "0xFFF0F0F0", Roundness := 0, X_Position := "", Y_Position := "", MarginX := 5, MarginY := 5, X_Offset := 20, Y_Offset := 20, OffsetW := 1.025, OffsetH := 0.95  ){
		This.Name := "ColorTipWindow_" ++ColorTip.WindowCount
		This.Text := Text
		(Needle)?(This.Needle := Needle)
		This.Font := Font
		This.FontColor := FontColor
		This.FontOptions := FontOptions
		This.BackgroundColor := BackgroundColor
		This.Roundness := Roundness
		This.X_Position := X_Position
		This.Y_Position := Y_Position
		This.MarginX := MarginX
		This.MarginY := MarginY
		This.X_Offset := X_Offset
		This.Y_Offset := Y_Offset
		This.OffsetW := OffsetW
		This.OffsetH := OffsetH
		This._GetCharHeight()
		This._GetStringSize()
		This._GetTipSize()
		This.LastTipWidth := This.TipWidth
		This.LastTipHeight := This.TipHeight
		This._GetBackgroundSize()
		This._CreateTipWindow()
	}
	_GetCharHeight(){
		local pBitmap, G, Brush
		pBitmap := Gdip_CreateBitmap( 10,10), G := Gdip_GraphicsFromImage( pBitmap ), Gdip_SetSmoothingMode( G , 2 )
		Brush := Gdip_BrushCreateSolid( This.FontColor)
		This.CharHeight := StrSplit( Gdip_TextToGraphics( G , "Sample", This.FontOptions " c" Brush " Left NoWrap x" 0 " y" 0 , This.Font , 10000, 10000  ),"|","|"  )[4]
		Gdip_DeleteBrush( Brush ), Gdip_DeleteGraphics( G ), Gdip_DisposeImage(pBitmap)
	}
	_GetStringSize(){
		local pBitmap, G, Brush, temparr
		pBitmap := Gdip_CreateBitmap( 10,10), G := Gdip_GraphicsFromImage( pBitmap ), Gdip_SetSmoothingMode( G , 2 )
		Brush := Gdip_BrushCreateSolid( This.FontColor)
		temparr := StrSplit( Gdip_TextToGraphics( G , This.Text, This.FontOptions " c" Brush " Left NoWrap x" 0 " y" 0 , This.Font , 10000, 10000  ),"|","|"  )
		Gdip_DeleteBrush( Brush ), Gdip_DeleteGraphics( G ), Gdip_DisposeImage(pBitmap)
		This.StringWidth := temparr[3]
		This.StringHeight := temparr[4]
	}
	_GetTipSize(){
		This.TipWidth := (This.StringWidth * This.OffsetW) + (This.MarginX * 2 )
		This.TipHeight := (This.StringHeight * This.OffsetH) + (This.MarginY * 2 )
	}
	_GetBackgroundSize(){
		This.BackgroundWidth := (This.StringWidth * This.OffsetW) + (This.MarginX * 2 - 1 ) * 0.96
		This.BackgroundHeight := (This.StringHeight * This.OffsetH) + (This.MarginY * 2 - 1 ) ;* 0.96
	}
	_CreateTipBitmapDefault(){
		local position := 0, Y := 0, G, Brush
		This.TipBitmap := Gdip_CreateBitmap( This.TipWidth, This.TipHeight), G := Gdip_GraphicsFromImage( This.TipBitmap ), Gdip_SetSmoothingMode( G , 2 )
		Brush := Gdip_BrushCreateSolid( This.BackgroundColor )
		Gdip_FillRoundedRectangle(G, Brush, 0, 0, This.BackgroundWidth, This.BackgroundHeight, This.Roundness)
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( This.FontColor )
		Gdip_TextToGraphics( G , This.Text , This.FontOptions " c" Brush " Left NoWrap x" This.MarginX " y" This.MarginY , This.Font , This.StringWidth, This.StringHeight  )
		Gdip_DeleteBrush( Brush ), Gdip_DeleteGraphics( G )
	}
	_CreateTipBitmapNeedle(){
		local position := This.MarginX, Y := This.MarginY, G, Brush, Arr
		This.TipBitmap := Gdip_CreateBitmap( This.TipWidth, This.TipHeight), G := Gdip_GraphicsFromImage( This.TipBitmap ), Gdip_SetSmoothingMode( G , 2 )
		Brush := Gdip_BrushCreateSolid( This.BackgroundColor )
		Gdip_FillRoundedRectangle(G, Brush, 0, 0, This.BackgroundWidth, This.BackgroundHeight, This.Roundness)
		Gdip_DeleteBrush( Brush )
		Arr := StrSplit(This.Text," ")
		Loop, % Arr.Length(){
			if(Arr[A_Index]="`n")
				Arr[A_Index] := "", Y += This.CharHeight // 1.2, Position:=This.MarginX
			Brush := Gdip_BrushCreateSolid( (This.Needle.HasKey(Arr[A_Index]))?(This.Needle[Arr[A_Index]]):(This.FontColor) )
			Position += StrSplit( Gdip_TextToGraphics( G , Arr[A_Index] , This.FontOptions " c" Brush " Left NoWrap x" Position " y" Y , This.Font , 1000, 1000  ),"|","|"  )[3]
			Gdip_DeleteBrush( Brush )
		}
		Gdip_DeleteGraphics( G )
	}
	_DestroyTipWindow(){
		Gui, % This.Name " :Destroy"
		SelectObject( This.hdc , This.obm )
		DeleteObject( This.hbm )
		DeleteDC( This.hdc )
		Gdip_DeleteGraphics( This.G )
	}
	FreeMode(){
		This.X_Position := ""
		This.Y_Position := ""
	}
	_CreateTipWindow(){
		This._DestroyTipWindow()
		Gui , % This.Name ": New" , % " +E0x80000 +LastFound -Caption +ToolWindow -DPIScale +AlwaysOnTop"
		This.Hwnd := WinExist()
		This.hbm := CreateDIBSection( This.TipWidth , This.TipHeight )
		This.hdc := CreateCompatibleDC()
		This.obm := SelectObject( This.hdc , This.hbm )
		This.G := Gdip_GraphicsFromHDC( This.hdc )
		Gdip_SetSmoothingMode( This.G , 2 )
	}
	Set(key,value){
		This[key] := value
		This._routine()
	}
	_routine(){
		This._GetCharHeight()
		This._GetStringSize()
		This._GetTipSize()
		This._GetBackgroundSize()
		if(This.LastTipWidth!=This.TipWidth||This.LastTipHeight!=This.TipHeight)
			This._CreateTipWindow()
		This.LastTipWidth := This.TipWidth
		This.LastTipHeight := This.TipHeight
		Gdip_DisposeImage(This.TipBitmap)
		if(!This.Needle)
			This._CreateTipBitmapDefault()
		else
			This._CreateTipBitmapNeedle()
	}
	Update(Text:=""){
		local x, y
		if(!This.Font)
			return 0
		(text != ""&&text!=This.LastText)?(This.Text := Text,This.LastText:=This.Text, This._routine())
		CoordMode, Mouse, Screen
		MouseGetPos, x, y
		Gdip_GraphicsClear( This.G )
		Gui , % This.Name ":Show", % "w" This.TipWidth " h" This.TipHeight " NA"
		Gdip_DrawImage(This.G, This.TipBitmap, 0, 0, This.TipWidth, This.TipHeight)
		if(!This.X_Position&&!This.Y_Position)
			UpdateLayeredWindow( This.hwnd , This.hdc , x+20, y+20)
		else if(!This.X_Position&&This.Y_Position)
			UpdateLayeredWindow( This.hwnd , This.hdc , x+20, This.Y_Position)
		else if(This.X_Position&&!This.Y_Position)
			UpdateLayeredWindow( This.hwnd , This.hdc , This.X_Position, y+20)
		else
			UpdateLayeredWindow( This.hwnd , This.hdc , This.X_Position, This.Y_Position)
	}
	Hide(){
		Gui , % This.Name ":Hide"
	}
	__Delete(){
		This._DestroyTipWindow()
	}
	Helper(){
		local keylist := "Text||Needle|Font|FontColor|FontOptions|BackgroundColor|Roundness|X_Position|Y_Position|MarginX|MarginY|X_Offset|Y_Offset|OffsetW|OffsetH"
		, methodlist := "New ColorTip( args )||Set( key , value )|Update( New Text *Optional* )|FreeMode()|Hide()"
		prototype =
		(Join
			MyColorTip := New ColorTip(Text := "No Text Added Yet", Needle := "", Font := "Arial", FontColor := "0xFF000000", FontOptions := "s12", BackgroundColor := "0xFFF0F0F0", Roundness := 0, X_Position := "", Y_Position := "", MarginX := 5, MarginY := 5, X_Offset := 20, Y_Offset := 20, OffsetW := 1.025, OffsetH := 0.95  )
		)
		Gui, HBColorTipsHelperHB: New, +AlwaysOnTop
		Gui, HBColorTipsHelperHB: Default
		Gui,Color,222428
		Gui,Font, s10 Bold, Segoe UI
		Gui,Add,Text,cAqua xm ym , Keys List
		Gui,Add,DDL,xm  r15,% KeyList
		Gui,Add,Text,cAqua xm  , Methods
		Gui,Add,DDL,xm w300 r15,% methodlist
		Gui,Add,Text,cAqua xm  y+30,How To Create a Tip
		Gui,Add,Text,cYellow xm  , NameOfTip := New ColorTip(args)
		Gui,Add,Text,cAqua xm  y+30,How To Delete a Tip
		Gui,Add,Text,cRed xm  , NameOfTip := ""
		Gui,Add,Text,cAqua xm  y+30, New ColorTip Prototype
		Gui,Font,
		Gui,Font, s10, Segoe UI
		Gui,Add,Edit,cWhite xm w300 r1 ReadOnly, % prototype
		Gui,Add,Text,cTeal xm  y+30, ColorTips By Hellbent
		Gui, Show, NA,HB ColorTip Helper
		prototype := ""
	}
}