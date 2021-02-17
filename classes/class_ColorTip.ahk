; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=85417
; Author:
; Date:
; for:     	AHK_L

/*


*/


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