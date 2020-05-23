;***************************************************************************************************
;***************************************************************************************************
#Include %A_ScriptDir%\..\..\lib-a_to_h\GDIP_All.ahk
;***************************************************************************************************
;***************************************************************************************************
#Include %A_ScriptDir%\..\class_LayeredWindow.ahk
;***************************************************************************************************
;***************************************************************************************************
#SingleInstance,Force
SetBatchLines -1
OnExit,GuiClose

Window := New LayeredWindow( x := "" , y := "", w := 300 , h := 100 , window := 1 , title := "Test Window" , smoothing := 4 , options := "+AlwaysOnTop" , autoShow := 1 , GdipStart := 1 , { x: 0 , y: 0 , w: 300 , h: 42 } , BackgroundColor := "0xFF222529" )


return
GuiClose:
GuiContextMenu:
*ESC::
	Window.DeleteWindow( 1 )
	ExitApp

;________________________________________________________________________________________________________
;________________________________________________________________________________________________________
;        <><><><><>   Testing   <><><><><>
;________________________________________________________________________________________________________
;________________________________________________________________________________________________________
numpad1:: ;Test painting the background and clearing the graphics
	Window.PaintBackground( "0xFF3377ff" , 1 )
	sleep, 500
	Window.ClearWindow( 1 )
	sleep, 500
	Window.PaintBackground( "0xFFff0000" , 1 )
	return

Numpad2:: ;Test moving the window and drawing a bitmap to the graphics
	Window.ShowWindow( 1 , { x: 200 , y: 200 , w: Window.W , h: Window.H } )
	sleep, 500
	Window.PaintBackground( "0xFF222529" , 1 )
	Window.Draw( HB_BITMAP_MAKER() , { X: 75 , Y: 2 , W: 150 , H: 40 } , , 1 )
	return

Numpad3:: ;Test deleting the layered window	, shuting down gdip , and creating a new window
	Window.DeleteWindow( 1 )
	Window := ""
	sleep, 1000
	Window := New LayeredWindow( x := "" , y := "", w := 300 , h := 100 , window := 1 , title := "New Test Window" , smoothing := 4 , options := "+AlwaysOnTop" , autoShow := 1 , GdipStart := 1 , { x: 0 , y: 0 , w: 300 , h: 42 } , BackgroundColor := "0xFF222529" )
	Window.ShowWindow( 1 , { x: 700 , y: 200 , w: Window.W , h: Window.H } )
	sleep, 500
	Window.Draw( HB_BITMAP_MAKER() , { X: 75 , Y: 2 , W: 150 , H: 40 } , , 1 )
	return
;***********************************************************************************************************************************************************************
;***********************************************************************************************************************************************************************
HB_BITMAP_MAKER(){ ;Create Test Bitmap
	;Bitmap Created Using: HB Bitmap Maker
	pBitmap:=Gdip_CreateBitmap( 150 , 40 )
	 G := Gdip_GraphicsFromImage( pBitmap )
	Gdip_SetSmoothingMode( G , 2 )
	Brush := Gdip_BrushCreateSolid( "0xFF272928" )
	Gdip_FillRectangle( G , Brush , 0 , 0 , 150 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 7 , 21 , 2 , 23 , "0xFF52C2DA" , "0xFF111111" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 1 , 1 , 148 , 37 , 18 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF343933" )
	Gdip_FillRoundedRectangle( G , Brush , 6 , 4 , 138 , 31 , 14 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF272928" )
	Gdip_FillRectangle( G , Brush , 30 , 1 , 90 , 10 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF272928" )
	Gdip_FillRectangle( G , Brush , 30 , 28 , 90 , 10 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF232B32" )
	Gdip_FillRoundedRectangle( G , Brush , 9 , 6 , 132 , 27 , 10 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrush( 71 , 20 , 70 , 20 , "0xFF24404C" , "0xFF3E8191" , 2 )
	Gdip_FillRoundedRectangle( G , Brush , 11 , 8 , 128 , 23 , 10 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF0FBBE1" )
	Gdip_FillRectangle( G , Brush , 20 , 9 , 110 , 1 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF0FBBE1" )
	Gdip_FillRectangle( G , Brush , 30 , 5 , 90 , 1 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF0FBBE1" )
	Gdip_FillRectangle( G , Brush , 30 , 34 , 90 , 1 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF0FBBE1" )
	Gdip_FillRectangle( G , Brush , 20 , 30 , 110 , 1 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF111111" )
	Gdip_TextToGraphics( G , "Hellbent" , "s16 Center vCenter c" Brush " x0 y1" , "Arial Black" , 150 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF111111" )
	Gdip_TextToGraphics( G , "Hellbent" , "s16 Center vCenter c" Brush " x0 y1" , "Arial Black" , 150 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF111111" )
	Gdip_TextToGraphics( G , "Hellbent" , "s16 Center vCenter c" Brush " x1 y2" , "Arial Black" , 150 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE7FEFF" )
	Gdip_TextToGraphics( G , "Hellbent" , "s16 Center vCenter c" Brush " x0 y1" , "Arial Black" , 150 , 40 )
	Gdip_DeleteBrush( Brush )
	Gdip_DeleteGraphics( G )
	return pBitmap
}