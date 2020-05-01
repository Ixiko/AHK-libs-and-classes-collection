;***************************************************************************************************
; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=17535&p=308449&hilit=GUI+add+position#p308449
;***************************************************************************************************
;***************************************************************************************************
; #Include <My Altered Gdip Lib>  ;<------       Replace with your copy of GDIP
;#Include Gdip.ahk
;***************************************************************************************************
;***************************************************************************************************
;***************************************************************************************************
#SingleInstance,Force
OnExit GuiClose
pToken := Gdip_Startup()

AddWindow()

Return

	
AddWindow(){
	static WinName:=0
	WinName++
	Obj:="Border" WinName
	Gui % WinName ":New",+AlwaysOnTop -DPIScale
	Gui % WinName ":Color",666666
	Gui % WinName ":Margin",0,0
	Gui % WinName ":Font",cwhite s10 Bold ,Segoe UI
	Gui % WinName ":Add",Picture,xm ym BackgroundTrans 0xE hwndhwnd,
	HB_BITMAP_MAKER(%OBJ% := {w:650, h:950, Hwnd:hwnd})
	
	; Gui % WinName ":Add",Text,% "x30 ym w" %OBJ%.W-60 " h" %OBJ%.H " Center BackgroundTrans 0x200", Your Text Here
	
	Gui % WinName ":Font", cwhite s12 Normal
	Gui % WinName ":Add",Text, % "x30 y30 Left", Information
	; The Editfield
	Gui % WinName ":Font", cBlue s14 Bold
	; Gui % WinName ":Edit", % "x30 y32 w200 h24 center vTestField1"

	
	
	Gui % WinName ":Show",% "w" %OBJ%.W " h" %OBJ%.H
	%OBJ%:=""
}

Ran(Min,Max){
	Random,Out,Min,Max
	return Out
}

HB_BITMAP_MAKER(Obj){
	;Bitmap Created Using: HB Bitmap Maker
	pBitmap:=Gdip_CreateBitmap( Obj.W , Obj.H ) 
	G := Gdip_GraphicsFromImage( pBitmap )
	Gdip_SetSmoothingMode( G , 2 )
	Pen := Gdip_CreatePen( "0xFF000000" , 10 )
	Gdip_DrawRoundedRectangle( G , Pen , 10 , 10 , Obj.W-20 , Obj.H-20 , 20 )
	Gdip_DeletePen( Pen )
	Pen := Gdip_CreatePen( "0xFF000000" , 12 )
	Gdip_DrawRoundedRectangle( G , Pen , 20 , 21 , Obj.W-41 , Obj.H-42 , 10 )
	Gdip_DeletePen( Pen )
	Pen := Gdip_CreatePen( "0xFFFFDD00" , 10 )
	Gdip_DrawRoundedRectangle( G , Pen , 12 , 12 , Obj.W-24 , Obj.H-24 , 20 )
	Gdip_DeletePen( Pen )
	Pen := Gdip_CreatePen( "0xFF333333" , 10 )
	Gdip_DrawRoundedRectangle( G , Pen , 19 , 20 , Obj.W-39 , Obj.H-40 , 12 )
	Gdip_DeletePen( Pen )
	Pen := Gdip_CreatePen( "0xFFFFAA00" , 8 )
	Gdip_DrawRoundedRectangle( G , Pen , 20 , 21 , Obj.W-41 , Obj.H-42 , 10 )
	Gdip_DeletePen( Pen )
	Gdip_DeleteGraphics( G )
	Obj.Bitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
	Gdip_DisposeImage(pBitmap)
	SetImage(Obj.Hwnd,Obj.Bitmap)
	DeleteObject(Obj.Bitmap)
}

GuiClose:
GuiContextMenu:
*ESC::
	Gdip_Shutdown(pToken)
	ExitApp