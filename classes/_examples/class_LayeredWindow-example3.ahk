#SingleInstance, Force
SetBatchLines, -1
#NoEnv
ListLines, Off
OnExit, GuiClose
pToken := GDIP_STARTUP()
global pbm := New PlayerBitmaps()
FlappyGame._CreateStartWindow()
global HS := []
IfNotExist, %A_ScriptDir%\HS.txt
	HS[1] := {Score: 0 , Name: "None"} , HS[2] := {Score: 0 , Name: "None"} , HS[3] := {Score: 0 , Name: "None"}
IfExist, %A_ScriptDir%\HS.txt
{
	FileRead,temp,%A_ScriptDir%\HS.txt
	tpa := StrSplit(temp,"`n")
	HS[1] := {Score: tpa[1] , Name: tpa[2]} , HS[2] := {Score: tpa[3] , Name: tpa[4]} , HS[3] := {Score: tpa[5] , Name: tpa[6]} , tpa := ""

}

return
GuiClose:
GuiContextMenu:
*ESC::
	ExitApp
class FlappyGame	{
	_CreateStartWindow(){
		( This.StartWindow ) ? ( This.StartWindow.DeleteWindow() )
		This.Player := 2
		This.LastNum := 0
		This.CW := 1
		This.LW := 1
		This.StartWindow := New LayeredWindow( x := "" , y := "", w := 500 , h := 300 , window := 1 , title := "HB Flappy Bird" , smoothing := 2 , options := "+AlwaysOnTop" , autoShow := 1 , 0 , { x: 89 , y: 12 , w: 322 , h: 34 } )
		This.StartWindowTL := New LayeredWindow( x := "" , y := "", w := 500 , h := 300 , window := 2 , title := "HB Flappy Bird" , smoothing := 2 , options := "+Parent1 +E0x20" , autoShow := 1 , 0 )
		This.StartWindow.Draw( StartWindow() , { x: 0 , Y: 0 , W: 500 , H: 300 } , , 1 )
		This._AddStartControls()
		This._AddStartWindowTimer()
	}
	_CreateHighScoresWindow(pp:=""){
		local ctrl , StartWindow_Timer
		MouseGetPos,,,,ctrl,2
		if( ctrl = StartHighScores ){
			This.CW := 2
			StartWindow_Timer := This.StartWindow_Timer
			SetTimer, %StartWindow_Timer% , Delete
			This.StartWindow.DeleteWindow()
			This.StartWindowTL.DeleteWindow()
			This.HSWindow := New LayeredWindow( x := "" , y := "", w := 500 , h := 300 , window := 3 , title := "HB Flappy Bird" , smoothing := 4 , options := "+AlwaysOnTop" , autoShow := 1 , 0 , { x: 89 , y: 12 , w: 322 , h: 34 } )
			This.HSWindow.Draw( ScoresWindow( 0 , HS[1].Score , HS[2].Score , HS[3].Score , HS[1].Name , HS[2].Name , HS[3].Name ) , { x: 0 , Y: 0 , W: 500 , H: 300 } , , 1  )
			This._AddScoresControls()
			This._AddScoresWindowTimer()
		}

	}
	_CreateMainGameWindow1(){
		local ctrl , StartWindow_Timer , ph
		MouseGetPos,,,,ctrl,2
		if(ctrl=StartStartGame){
			This.CW := 3
			StartWindow_Timer := This.StartWindow_Timer
			SetTimer, %StartWindow_Timer% , Delete
			This.StartWindow.DeleteWindow()
			This.StartWindowTL.DeleteWindow()
			This.MainGameWindow1 := New LayeredWindow( x := "" , y := "", w := 500 , h := 600 , window := 4 , title := "HB Flappy Bird" , smoothing := 2 , options := "+AlwaysOnTop" , autoShow := 1 , 0 , { x: 89 , y: 12 , w: 322 , h: 34 } )
			This.MainGameWindow1.Draw( MainWin() ,  { x: 0 , Y: 0 , W: 500 , H: 600 } , , 1 )
			This._AddMainWindow1Control()

			This.MainGameWindow2 := New LayeredWindow( x := 17 , y := 52 , w := 466 , h := 531 , window := 5 , title := "HB Flappy Bird" , smoothing := 2 , options := "+Parent4" , autoShow := 1 , 0 )
			This.MainGameWindow3 := New LayeredWindow( x := 0 , y := 0 , w := 466 , h := 531 , window := 6 , title := "HB Flappy Bird" , smoothing := 2 , options := "+Parent5" , autoShow := 1 , 0 )


			pw := 60 , px := 10
			This.Pipe := []
			Loop 10	{
				This.Pipe[A_Index] := New Pipes(ran(1,11))
				This.MainGameWindow2.Draw( This.Pipe[A_Index].Bitmap ,  { x: px , Y: 0 , W: pw , H: 600 } , , 1 )
				px += pw + 5
			}
			This.Pipe[11] := New Pipes(ran(1,11))
			This.MainGameWindow3.Draw( This.Pipe[11].Bitmap ,  { x: 33 , Y: 0 , W: pw , H: 600 } , , 1 )
			This.Pipe[12] := New Pipes(1)
			This.MainGameWindow3.Draw( This.Pipe[12].Bitmap ,  { x: 333 , Y: 0 , W: pw , H: 600 } , , 1 )
		}
	}
	_AddStartControls(){
		local bd
		Gui, 1: Add , Text , x466 y13 w20 h20 hwndStartWindowCloseButton gGuiClose
		Gui, 1: Add , Text , x70 y105 w60 h60 hwndStartSelectPlayer1
		Gui, 1: Add , Text , x220 y105 w60 h60 hwndStartSelectPlayer2
		Gui, 1: Add , Text , x370 y105 w60 h60 hwndStartSelectPlayer3
		Gui, 1: Add , Text , x120 y190 w260 h30 hwndStartHighScores
		Gui, 1: Add , Text , x120 y235 w260 h30 hwndStartStartGame ;gGuiClose
		bd := This._SetPlayer.Bind( This )
		loop 3
			GuiControl, 1: +G , % StartSelectPlayer%A_Index% , % bd
		bd := This._CreateHighScoresWindow.Bind( This , StartHighScores )
		GuiControl, 1: +G , % StartHighScores , % bd
		bd := This._CreateMainGameWindow1.Bind(This)
		GuiControl, 1: +G , % StartStartGame , % bd

	}
	_AddScoresControls(){
		local bd
		Gui, 3: Add , Text , x466 y13 w20 h20 hwndScoresWindowCloseButton gGuiClose
		Gui, 3: Add , Text , x120 y245 w260 h30 hwndScoresWindowBackButton
		bd := This._ExitScoresWindow.Bind( This , ScoresWindowBackButton )
		GuiControl, 3: +G , % ScoresWindowBackButton , % bd
	}
	_AddMainWindow1Control(){
		;~ local bd
		Gui, 4: Add , Text , x464 y16 w20 h20 hwndMainWindow1CloseButton gGuiClose
	}
	_AddStartWindowTimer(){
		local StartWindow_Timer
		if( !This.StartWindow_Timer )
			This.StartWindow_Timer := StartWindow_Timer :=  ObjBindMethod( This , "_StartWindowEvents" )
		else
			StartWindow_Timer := This.StartWindow_Timer
		SetTimer, %StartWindow_Timer% , 30
	}
	_AddScoresWindowTimer(){
		local ScoresWindowTimer
		if(!This.ScoresWindowTimer)
			This.ScoresWindowTimer := ScoresWindowTimer := ObjBindMethod( This , "_ScoreWindowEvents")
		else
			ScoresWindowTimer := This.ScoresWindowTimer
		SetTimer, %ScoresWindowTimer% , 30
	}
	_StartWindowEvents(){
		local ctrl
		static isActive := 0 , LastCtrl , frameDelay := 1 , frame := 1 , change := 0
		MouseGetPos,,,,ctrl,2
		if( !isActive ){
			( ctrl = StartWindowCloseButton ) ? ( isActive := 1 , LastCtrl := StartWindowCloseButton , This.LastNum := 1 , change := 1 )
			: ( ctrl = This.StartWindow.MoveHwnd ) ? ( isActive := 1 , LastCtrl := This.StartWindow.MoveHwnd , This.LastNum := 7 , change := 1 )
			: ( ctrl = StartSelectPlayer1 ) ? ( isActive := 1 , LastCtrl := StartSelectPlayer1 , This.LastNum := 2 , change := 1 )
			: ( ctrl = StartSelectPlayer2 ) ? ( isActive := 1 , LastCtrl := StartSelectPlayer2 , This.LastNum := 3 , change := 1 )
			: ( ctrl = StartSelectPlayer3 ) ? ( isActive := 1 , LastCtrl := StartSelectPlayer3 , This.LastNum := 4 , change := 1 )
			: ( ctrl = StartHighScores ) ? ( isActive := 1 , LastCtrl := StartHighScores , This.LastNum := 5 , change := 1 )
			: ( ctrl = StartStartGame ) ? ( isActive := 1 , LastCtrl := StartStartGame , This.LastNum := 6 , change := 1 )
		}else if( isActive && ctrl != LastCtrl ){
			isActive := 0 , LastCtrl := "" , This.LastNum := 0 , change := 1
		}
		if( change ){
			change := 0
			This.StartWindow.ClearWindow()
			This.StartWindow.Draw( StartWindow( This.LastNum , This.Player ) , { x: 0 , Y: 0 , W: 500 , H:300 } , 1 , 1)
		}
		This.StartWindowTL.ClearWindow()
		( ++FrameDelay = 3 ) ? ( ( ++Frame = 9 ) ? ( FrameDelay := 1 , Frame := 1 ) : ( FrameDelay := 0 ) )
		This.StartWindowTL.Draw( pbm.Players[ 1 , Frame ].Bitmap , { X: 75 , Y: 115 , W: 50 , H: 51 } , 0  )
		This.StartWindowTL.Draw( pbm.Players[ 2 , Frame ].Bitmap , { X: 225 , Y: 115 , W: 50 , H: 51 } , 0  )
		This.StartWindowTL.Draw( pbm.Players[ 3 , Frame ].Bitmap , { X: 375 , Y: 115 , W: 50 , H: 51 } , 1  )
	}
	_ScoreWindowEvents(){
		local ctrl
		static isActive := 0 , LastCtrl ,  change := 0
		MouseGetPos,,,,ctrl,2
		if(!isActive){
			(ctrl=ScoresWindowCloseButton)?( isActive := 1 , LastCtrl := ScoresWindowCloseButton , This.LastNum := 8 , change := 1 )
			: (ctrl=ScoresWindowBackButton)?( isActive := 1 , LastCtrl := ScoresWindowBackButton , This.LastNum := 9 , change := 1 )
			: ( ctrl = This.HSWindow.MoveHwnd ) ? ( isActive := 1 , LastCtrl := This.HSWindow.MoveHwnd , This.LastNum := 10 , change := 1 )
		}else if( isActive && ctrl != LastCtrl ){
			isActive := 0 , LastCtrl := "" , This.LastNum := 0 , change := 1
		}
		if( change ){
			change := 0
			This.HSWindow.ClearWindow()
			This.HSWindow.Draw( ScoresWindow( This.LastNum ) , { x: 0 , Y: 0 , W: 500 , H:300 } , 1 , 1)
		}
	}
	_SetPlayer(){
		local ctrl
		MouseGetPos,,,,ctrl,2
		(ctrl=StartSelectPlayer1)?( This.Player := 1 ):(ctrl=StartSelectPlayer2)?( This.Player := 2 ):(ctrl=StartSelectPlayer3)?( This.Player := 3 )
		This.StartWindow.ClearWindow()
		This.StartWindow.Draw( StartWindow(This.LastNum , This.Player ) , {x:0,Y:0,W:500,H:300} , 1 , 1)
	}
	_ExitScoresWindow(){
		if(This.LW =1){
			ScoresWindowTimer := This.ScoresWindowTimer
			SetTimer, %ScoresWindowTimer% , Off
			This.HSWindow.DeleteWindow()
			This._CreateStartWindow()
		}
	}
}
;***********************************************************************************************************************************************************************
;*************************************************		 Generate The player bitmaps		****************************************************************************
;***********************************************************************************************************************************************************************
class PlayerBitmaps	{
	__New(){
		This._CreateMasters()
	}
	_CreateMasters(){
		This.B64 := {}
		This.B64.BlueBirdFrames := "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"
		This.B64.BatFrames := "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"
		This.B64.YellowDemonFrames := "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"
		This.MasterBitmap := []
		for k , v in This.B64
			This.MasterBitmap[ A_Index ] := This._Create_Sheets( v )
		This._MapSplit()
	}
	_MapSplit(){
		local posx , Index := 1
		This.Players := []
		Loop, % This.MasterBitmap.Length()	{
			posx := 0
			Loop, 8	{
				This.Players[ Index , A_Index ] := {}
				This.Players[ Index , A_Index ].Bitmap := Gdip_CreateBitmap( 50 , 51 )
				This.Players[ Index , A_Index ].G := Gdip_GraphicsFromImage( This.Players[ Index , A_Index ].Bitmap )
				Gdip_SetSmoothingMode( This.Players[ Index , A_Index ].G , 2 )
				Gdip_DrawImage( This.Players[ Index , A_Index ].G , This.MasterBitmap[ Index ] , 0 , 0 , 50 , 51 , posx , 0 , 50 , 51 )
				posx += 50
			}
			Index++
		}
	}
	_Create_Sheets( B65 ){
		local ptr , uptr , pBitmap
		VarSetCapacity(B64, strlen( B65 ) << !!A_IsUnicode)
		B64 := B65
		If !DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr := A_PtrSize ? "Ptr" : "UInt" , &B64, "UInt", 0, "UInt", 0x01, Ptr, 0, "UIntP", DecLen, Ptr, 0, Ptr, 0)
		   Return False
		VarSetCapacity(Dec, DecLen, 0)
		If !DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &B64, "UInt", 0, "UInt", 0x01, Ptr, &Dec, "UIntP", DecLen, Ptr, 0, Ptr, 0)
		   Return False
		DllCall("Kernel32.dll\RtlMoveMemory", Ptr, pData := DllCall("Kernel32.dll\GlobalLock", Ptr, hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2,  UPtr := A_PtrSize ? "UPtr" : "UInt" , DecLen, UPtr), UPtr) , Ptr, &Dec, UPtr, DecLen)
		DllCall("Kernel32.dll\GlobalUnlock", Ptr, hData)
		DllCall("Ole32.dll\CreateStreamOnHGlobal", Ptr, hData, "Int", True, Ptr "P", pStream)
		DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  Ptr, pStream, Ptr "P", pBitmap)
		return pBitmap
	}
}
;***********************************************************************************************************************************************************
;*******************************************		 Class Pipes		 ***********************************************************************************
;***********************************************************************************************************************************************************
class pipes	{
	__New( level := 1 ){
		This.X := 0
		This.W := 100
		This.Space := [180,170,160,150,140,130,120,110,100,90,80]
		This.Gap := This.Space[ level ]
		This.BLimit := 460 ;the ground of the screen
		This.GapStart := Ran( 30 , 460 - This.Gap - 30 )
		This.YTop := This.GapStart - 600
		This.YBottom := This.GapStart + This.Gap

		This.PBH := This.BLimit - This.YBottom
		;~ ToolTip, % This.PBH

		This.Bitmap := This._CreatePipesBM()

	}
	_CreatePipesBM(){
		pBitmap := Gdip_CreateBitmap( 100 , 600 )
		G := Gdip_GraphicsFromImage( pBitmap )
		Gdip_DrawImage( G , This.TPipesBM := This._CreateTPipesBM() , 0 , This.YTop , 100 , 600 )
		Gdip_DisposeImage( This.TPipesBM ) , This.TPipesBM := ""
		Gdip_DrawImage( G , This.BPipesBM := This._CreateBPipesBM() , 0 , This.YBottom , 100 , This.PBH )
		Gdip_DisposeImage( This.BPipesBM ) , This.BPipesBM := ""
		Gdip_DeleteGraphics( G )
		return pBitmap
	}
	_CreateTPipesBM(){
		;Bitmap Created Using: HB Bitmap Maker
		pBitmap:=Gdip_CreateBitmap( 100 , 500 )
		G := Gdip_GraphicsFromImage( pBitmap )
		Gdip_SetSmoothingMode( G , 3 )
		Brush := Gdip_BrushCreateSolid( "0xFF005A03" )
		Gdip_FillRectangle( G , Brush , 10 , -1 , 80 , 502 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01A612" )
		Gdip_FillRectangle( G , Brush , 14 , -1 , 72 , 500 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF015C06" )
		Gdip_FillRectangle( G , Brush , 0 , 460 , 102 , 40 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01A612" )
		Gdip_FillRectangle( G , Brush , 4 , 464 , 91 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
		Gdip_FillRectangle( G , Brush , 14 , 0 , 15 , 460 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
		Gdip_FillRectangle( G , Brush , 33 , 0 , 3 , 460 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
		Gdip_FillRectangle( G , Brush , 4 , 464 , 15 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
		Gdip_FillRectangle( G , Brush , 23 , 464 , 3 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
		Gdip_FillRectangle( G , Brush , 72 , 0 , 5 , 460 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
		Gdip_FillRectangle( G , Brush , 54 , 0 , 11 , 460 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
		Gdip_FillRectangle( G , Brush , 79 , 464 , 5 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
		Gdip_FillRectangle( G , Brush , 60 , 464 , 12 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_CreateLineBrushFromRect( 13 , 0 , 77 , 457 , "0x4400A713" , "0x66000000" , 1 , 1 )
		Gdip_FillRectangle( G , Brush , 10 , -1 , 80 , 461 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_CreateLineBrushFromRect( 2 , 461 , 94 , 34 , "0x33007713" , "0x66000000" , 1 , 1 )
		Gdip_FillRectangle( G , Brush , 0 , 460 , 102 , 40 )
		Gdip_DeleteBrush( Brush )
		Gdip_DeleteGraphics( G )
		return pBitmap
	}
	_CreateBPipesBM(){
		;Bitmap Created Using: HB Bitmap Maker
		pBitmap:=Gdip_CreateBitmap( 100 , This.PBH )
		G := Gdip_GraphicsFromImage( pBitmap )
		Gdip_SetSmoothingMode( G , 3 )
		Brush := Gdip_BrushCreateSolid( "0xFF005B04" )
		Gdip_FillRectangle( G , Brush , -1 , -1 , 102 , 40 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF00A713" )
		Gdip_FillRectangle( G , Brush , 4 , 4 , 91 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF005B04" )
		Gdip_FillRectangle( G , Brush , 10 , 38 , 80 , 470 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01A612" )
		Gdip_FillRectangle( G , Brush , 14 , 42 , 72 , 470 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
		Gdip_FillRectangle( G , Brush , 3 , 4 , 14 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
		Gdip_FillRectangle( G , Brush , 14 , 42 , 14 , 462 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
		Gdip_FillRectangle( G , Brush , 21 , 4 , 3 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
		Gdip_FillRectangle( G , Brush , 31 , 42 , 3 , 472 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
		Gdip_FillRectangle( G , Brush , 79 , 4 , 5 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
		Gdip_FillRectangle( G , Brush , 73 , 42 , 5 , 472 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
		Gdip_FillRectangle( G , Brush , 61 , 4 , 12 , 32 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
		Gdip_FillRectangle( G , Brush , 56 , 42 , 12 , 492 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_CreateLineBrushFromRect( -1 , -1 , 99 , 40 , "0x4400A713" , "0x44222222" , 1 , 1 )
		Gdip_FillRectangle( G , Brush , -1 , -1 , 102 , 40 )
		Gdip_DeleteBrush( Brush )
		Brush := Gdip_CreateLineBrushFromRect( 9 , 35 , 80 , 465 , "0x4400A713" , "0x66000000" , 1 , 1 )
		Gdip_FillRectangle( G , Brush , 10 , 43 , 80 , 470 )
		Gdip_DeleteBrush( Brush )

		Brush := Gdip_BrushCreateSolid( "0xFF005B04" )
		Gdip_FillRectangle( G , Brush , 10 , This.PBH - 3 , 80 , 10 )
		Gdip_DeleteBrush( Brush )

		Gdip_DeleteGraphics( G )
		return pBitmap
	}
}
ran(min,max){
	Random,Out,min,max
	return out
}
;*************************************************************************************************************************************************
;**************************************************			Start Window      ********************************************************************
;*************************************************************************************************************************************************
StartWindow( num := 0 , sel := 2 ){
	;Bitmap Created Using: HB Bitmap Maker
	pBitmap:=Gdip_CreateBitmap( 500 , 300 )
	G := Gdip_GraphicsFromImage( pBitmap )
	Gdip_SetSmoothingMode( G , 2 )
	Brush := Gdip_CreateLineBrushFromRect( 1 , -1 , 487 , 291 , "0xaaF0F0F0" , "0xaa050A00" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 8 , 8 , 484 , 284 , 15 )
	Gdip_DeleteBrush( Brush )
	;~ Brush := Gdip_CreateLineBrushFromRect( 1 , -1 , 487 , 291 , "0xFF444444" , "0xFF152304" , 1 , 1 )
	Brush := Gdip_CreateLineBrushFromRect( 1 , -1 , 487 , 291 , "0xFF000000" , "0xFF152304" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 10 , 10 , 480 , 280 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 1 , -1 , 487 , 291 , "0x3300ff00" , "0x88000000" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 10 , 10 , 480 , 280 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xff050A00" )
	Gdip_FillRoundedRectangle( G , Brush , 19 , 49 , 462 , 232 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 21 , 53 , 457 , 223 , "0x66333333" , "0xff60B021" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 20 , 50 , 460 , 230 , 15 )
	Gdip_DeleteBrush( Brush )
	;Move window
	if(num=7)
		Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , 393 , 48 , "0xFFFFFFFF" , "0xFF000000" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , 393 , 48 , "0xFFF000B9" , "0xFF000000" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 89 , 12 , 322 , 34 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF050A00" )
	Gdip_FillRoundedRectangle( G , Brush , 90 , 13 , 320 , 32 , 5 )
	Gdip_DeleteBrush( Brush )
	if(num=7)
		Brush := Gdip_CreateLineBrush( 124 , 18 , 171 , 65 , "0xFF70C6CE" , "0xFF050A00" , 1 )
	else
		Brush := Gdip_CreateLineBrush( 124 , 18 , 171 , 65 , "0xFF05D917" , "0xFF050A00" , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 92 , 15 , 316 , 28 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , "AHK FLAPPY BIRD" , "s24 Center vCenter Bold c" Brush " x91 y14" , "Segoe Ui" , 316 , 28 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF050A00" )
	Gdip_TextToGraphics( G , "AHK FLAPPY BIRD" , "s24 Center vCenter Bold c" Brush " x93 y16" , "Segoe Ui" , 316 , 28 )
	Gdip_DeleteBrush( Brush )
	if(num=7)
		Brush := Gdip_CreateLineBrushFromRect( 149 , 19 , 204 , 17 , "0xFF22ff22" , "0xFF222222" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 149 , 19 , 204 , 17 , "0xFFF000B9" , "0xFF222222" , 1 , 1 )
	Gdip_TextToGraphics( G , "AHK FLAPPY BIRD" , "s24 Center vCenter Bold c" Brush " x92 y15" , "Segoe Ui" , 316 , 28 )
	Gdip_DeleteBrush( Brush )
	;close
	if(num=1)
		Brush := Gdip_BrushCreateSolid( "0xFFffffff" )
	else
		Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_FillEllipse( G , Brush , 466 , 13 , 20 , 20 )
	Gdip_DeleteBrush( Brush )
	if(num=1)
		Brush := Gdip_CreateLineBrushFromRect( 465 , 15 , 22 , 18 , "0xFFFF0303" , "0xFF000000" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 465 , 15 , 22 , 18 , "0xFFB4091D" , "0xFF000000" , 1 , 1 )
	Gdip_FillEllipse( G , Brush , 467 , 14 , 18 , 18 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "X" , "s12 Center vCenter Bold c" Brush " x466 y13" , "Segoe ui" , 20 , 20 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFaaaaaa" )
	Gdip_TextToGraphics( G , "X" , "s12 Center vCenter Bold c" Brush " x467 y14" , "Segoe ui" , 20 , 20 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF050A00" )
	Gdip_FillRoundedRectangle( G , Brush , 40 , 100 , 420 , 71 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrush( 0 , 0 , 100 , 100 , "0xFF95E455" , "0xFF5DAC18" , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 42 , 102 , 416 , 67 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Player Selection" , "s24 Center vCenter Bold c" Brush " x8 y48" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Player Selection" , "s24 Center vCenter Bold c" Brush " x12 y48" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Player Selection" , "s24 Center vCenter Bold c" Brush " x12 y52" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Player Selection" , "s24 Center vCenter Bold c" Brush " x8 y52" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF3F3F3" )
	Gdip_TextToGraphics( G , "Player Selection" , "s24 Center vCenter Bold c" Brush " x10 y50" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	;player position 1 outer
	if(sel=1)
		Brush := Gdip_BrushCreateSolid( "0xFFF000B9" )
	else
		Brush := Gdip_BrushCreateSolid( "0xFF111111" )
	Gdip_FillEllipse( G , Brush , 68 , 103 , 64 , 64 )
	Gdip_DeleteBrush( Brush )
	;player position 1
	if(num=2)
		Brush := Gdip_CreateLineBrushFromRect( 70 , 108 , 53 , 55 , "0xFFE3086C" , "0xFF222222" , 1 , 1 )
	else
	Brush := Gdip_CreateLineBrushFromRect( 70 , 108 , 53 , 55 , "0xFF70C6CE" , "0xFF222222" , 1 , 1 )
	Gdip_FillEllipse( G , Brush , 71 , 106 , 58 , 58 )
	Gdip_DeleteBrush( Brush )
	;player position 2 outer
	if(sel=2)
		Brush := Gdip_BrushCreateSolid( "0xFFF000B9" )
	else
		Brush := Gdip_BrushCreateSolid( "0xFF111111" )
	Gdip_FillEllipse( G , Brush , 218 , 103 , 64 , 64 )
	Gdip_DeleteBrush( Brush )
	;player position 2
	if(num=3)
		Brush := Gdip_CreateLineBrushFromRect( 70 , 108 , 53 , 55 , "0xFFE3086C" , "0xFF222222" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 70 , 108 , 53 , 55 , "0xFF70C6CE" , "0xFF222222" , 1 , 1 )
	Gdip_FillEllipse( G , Brush , 221 , 106 , 58 , 58 )
	Gdip_DeleteBrush( Brush )
	;player position 3 outer
	if(sel=3)
		Brush := Gdip_BrushCreateSolid( "0xFFF000B9" )
	else
		Brush := Gdip_BrushCreateSolid( "0xFF111111" )
	Gdip_FillEllipse( G , Brush , 368 , 103 , 64 , 64 )
	Gdip_DeleteBrush( Brush )
	;player position 3
	if(num=4)
		Brush := Gdip_CreateLineBrushFromRect( 70 , 108 , 53 , 55 , "0xFFE3086C" , "0xFF222222" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 70 , 108 , 53 , 55 , "0xFF70C6CE" , "0xFF222222" , 1 , 1 )
	Gdip_FillEllipse( G , Brush , 371 , 106 , 58 , 58 )
	Gdip_DeleteBrush( Brush )
	;high scores
	Brush := Gdip_BrushCreateSolid( "0xFF111111" )
	Gdip_FillRoundedRectangle( G , Brush , 120 , 190 , 260 , 30 , 10 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_FillRoundedRectangle( G , Brush , 121 , 191 , 258 , 28 , 10 )
	Gdip_DeleteBrush( Brush )
	if(num=5)
		Brush := Gdip_CreateLineBrushFromRect( 122 , 191 , 257 , 28 , "0xFF4CBBC4" , "0xFF000000" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 122 , 191 , 257 , 28 , "0xFFE60654" , "0xFF000000" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 122 , 192 , 256 , 26 , 10 )
	Gdip_DeleteBrush( Brush )
	;start
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_FillRoundedRectangle( G , Brush , 120 , 235 , 260 , 30 , 10 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_FillRoundedRectangle( G , Brush , 121 , 236 , 258 , 28 , 10 )
	Gdip_DeleteBrush( Brush )
	if(num=6)
		Brush := Gdip_CreateLineBrushFromRect( 121 , 238 , 256 , 25 , "0xFF4CBBC4" , "0xFF000000" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 121 , 238 , 256 , 25 , "0xFFE60654" , "0xFF000000" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 122 , 237 , 256 , 26 , 10 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "HIGH SCORES" , "s16 Center vCenter Bold c" Brush " x121 y191" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "HIGH SCORES" , "s16 Center vCenter Bold c" Brush " x123 y191" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "HIGH SCORES" , "s16 Center vCenter Bold c" Brush " x123 y193" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "HIGH SCORES" , "s16 Center vCenter Bold c" Brush " x121 y193" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , "HIGH SCORES" , "s16 Center vCenter Bold c" Brush " x122 y192" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Start" , "s16 Center vCenter Bold c" Brush " x121 y236" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Start" , "s16 Center vCenter Bold c" Brush " x123 y236" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Start" , "s16 Center vCenter Bold c" Brush " x123 y238" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Start" , "s16 Center vCenter Bold c" Brush " x121 y238" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , "Start" , "s16 Center vCenter Bold c" Brush " x122 y237" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Gdip_DeleteGraphics( G )
	return pBitmap
}
;*************************************************************************************************************************************************
;**************************************************		High Scores Window      ******************************************************************
;*************************************************************************************************************************************************
ScoresWindow(num:=0 , score1 := "" , score2 := "" , Score3 := "" , Name1 := "" , Name2 := "" , Name3 := "" ){
	;Bitmap Created Using: HB Bitmap Maker
	static s1 , s2 , s3 , n1 , n2 , n3
	(Score1 != "")?(s1:=Score1,s2:=Score2,s3:=Score3,n1:=Name1,n2:=Name2,n3:=Name3)
	pBitmap:=Gdip_CreateBitmap( 500 , 300 )
	G := Gdip_GraphicsFromImage( pBitmap )
	Gdip_SetSmoothingMode( G , 2 )
	Brush := Gdip_CreateLineBrushFromRect( 1 , -1 , 487 , 291 , "0xaaF0F0F0" , "0xaa050A00" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 8 , 8 , 484 , 284 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 1 , -1 , 487 , 291 , "0xFF444444" , "0xFF152304" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 10 , 10 , 480 , 280 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 1 , -1 , 487 , 291 , "0x33F0F0F0" , "0x88000000" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 10 , 10 , 480 , 280 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xff050A00" )
	Gdip_FillRoundedRectangle( G , Brush , 19 , 49 , 462 , 232 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 21 , 53 , 457 , 223 , "0x66333333" , "0xff60B021" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 20 , 50 , 460 , 230 , 15 )
	Gdip_DeleteBrush( Brush )
	;Move window
	if(num=10)
		Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , 393 , 48 , "0xFFFFFFFF" , "0xFF000000" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , 393 , 48 , "0xFFF000B9" , "0xFF000000" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 89 , 12 , 322 , 34 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF050A00" )
	Gdip_FillRoundedRectangle( G , Brush , 90 , 13 , 320 , 32 , 5 )
	Gdip_DeleteBrush( Brush )
	if(num=10)
		Brush := Gdip_CreateLineBrush( 124 , 18 , 171 , 65 , "0xFF70C6CE" , "0xFF050A00" , 1 )
	else
		Brush := Gdip_CreateLineBrush( 124 , 18 , 171 , 65 , "0xFF05D917" , "0xFF050A00" , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 92 , 15 , 316 , 28 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , "AHK FLAPPY BIRD" , "s24 Center vCenter Bold c" Brush " x91 y14" , "Segoe Ui" , 316 , 28 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF050A00" )
	Gdip_TextToGraphics( G , "AHK FLAPPY BIRD" , "s24 Center vCenter Bold c" Brush " x93 y16" , "Segoe Ui" , 316 , 28 )
	Gdip_DeleteBrush( Brush )
	if(num=10)
		Brush := Gdip_CreateLineBrushFromRect( 149 , 19 , 204 , 17 , "0xFF22ff22" , "0xFF222222" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 149 , 19 , 204 , 17 , "0xFFF000B9" , "0xFF222222" , 1 , 1 )
	Gdip_TextToGraphics( G , "AHK FLAPPY BIRD" , "s24 Center vCenter Bold c" Brush " x92 y15" , "Segoe Ui" , 316 , 28 )
	Gdip_DeleteBrush( Brush )
	;close
	if(num=8)
		Brush := Gdip_BrushCreateSolid( "0xFFFFFFFF" )
	else
		Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_FillEllipse( G , Brush , 466 , 13 , 20 , 20 )
	Gdip_DeleteBrush( Brush )
	if(num=8)
		Brush := Gdip_CreateLineBrushFromRect( 465 , 15 , 22 , 18 , "0xFFFF0303" , "0xFF000000" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 465 , 15 , 22 , 18 , "0xFFB4091D" , "0xFF000000" , 1 , 1 )
	Gdip_FillEllipse( G , Brush , 467 , 14 , 18 , 18 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "X" , "s12 Center vCenter Bold c" Brush " x466 y13" , "Segoe ui" , 20 , 20 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFaaaaaa" )
	Gdip_TextToGraphics( G , "X" , "s12 Center vCenter Bold c" Brush " x467 y14" , "Segoe ui" , 20 , 20 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF050A00" )
	Gdip_FillRoundedRectangle( G , Brush , 80 , 90 , 380 , 151 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrush( 0 , 0 , 100 , 100 , "0xFF95E455" , "0xFF5DAC18" , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 82 , 92 , 376 , 147 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_FillRoundedRectangle( G , Brush , 30 , 90 , 40 , 151 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrush( 0 , 0 , 100 , 100 , "0xFF95E455" , "0xFF5DAC18" , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 32 , 92 , 36 , 147 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "High Scores" , "s24 Center vCenter Bold c" Brush " x8 y43" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "High Scores" , "s24 Center vCenter Bold c" Brush " x12 y43" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "High Scores" , "s24 Center vCenter Bold c" Brush " x12 y47" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "High Scores" , "s24 Center vCenter Bold c" Brush " x8 y47" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF3F3F3" )
	Gdip_TextToGraphics( G , "High Scores" , "s24 Center vCenter Bold c" Brush " x10 y45" , "Segoe ui" , 500 , 50 )
	Gdip_DeleteBrush( Brush )
	;Back
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_FillRoundedRectangle( G , Brush , 120 , 245 , 260 , 30 , 10 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_FillRoundedRectangle( G , Brush , 121 , 246 , 258 , 28 , 10 )
	Gdip_DeleteBrush( Brush )
	if(num=9)
		Brush := Gdip_CreateLineBrushFromRect( 124 , 246 , 252 , 25 , "0xFF4CBBC4" , "0xFF000000" , 1 , 1 )
	else
		Brush := Gdip_CreateLineBrushFromRect( 124 , 246 , 252 , 25 , "0xFFE60654" , "0xFF000000" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 122 , 247 , 256 , 26 , 10 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Back" , "s16 Center vCenter Bold c" Brush " x121 y246" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Back" , "s16 Center vCenter Bold c" Brush " x123 y246" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Back" , "s16 Center vCenter Bold c" Brush " x123 y248" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "Back" , "s16 Center vCenter Bold c" Brush " x121 y248" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , "Back" , "s16 Center vCenter Bold c" Brush " x122 y247" , "Segoe ui" , 256 , 26 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , "1" , "s20 Center vCenter Bold c" Brush " x29 y99" , "Segoe ui" , 40 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "1" , "s20 Center vCenter Bold c" Brush " x31 y101" , "Segoe ui" , 40 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE60654" )
	Gdip_TextToGraphics( G , "1" , "s20 Center vCenter Bold c" Brush " x30 y100" , "Segoe ui" , 40 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , "2" , "s20 Center vCenter Bold c" Brush " x29 y139" , "Segoe ui" , 40 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "2" , "s20 Center vCenter Bold c" Brush " x31 y141" , "Segoe ui" , 40 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE60654" )
	Gdip_TextToGraphics( G , "2" , "s20 Center vCenter Bold c" Brush " x30 y140" , "Segoe ui" , 40 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , "3" , "s20 Center vCenter Bold c" Brush " x29 y179" , "Segoe ui" , 40 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "3" , "s20 Center vCenter Bold c" Brush " x31 y181" , "Segoe ui" , 40 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE60654" )
	Gdip_TextToGraphics( G , "3" , "s20 Center vCenter Bold c" Brush " x30 y180" , "Segoe ui" , 40 , 40 )
	Gdip_DeleteBrush( Brush )
	;name 1
	Brush := Gdip_BrushCreateSolid( "0x003399FF" )
	Gdip_FillRectangle( G , Brush , 100 , 100 , 250 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , n1 , "s20 vCenter Bold c" Brush " x99 y99" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , n1 , "s20 vCenter Bold c" Brush " x101 y101" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE60654" )
	Gdip_TextToGraphics( G , n1 , "s20 vCenter Bold c" Brush " x100 y100" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	;name 2
	Brush := Gdip_BrushCreateSolid( "0x003399FF" )
	Gdip_FillRectangle( G , Brush , 100 , 140 , 250 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , n2 , "s20 vCenter Bold c" Brush " x99 y139" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , n2 , "s20 vCenter Bold c" Brush " x101 y141" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE60654" )
	Gdip_TextToGraphics( G , n2 , "s20 vCenter Bold c" Brush " x100 y140" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	;name 3
	Brush := Gdip_BrushCreateSolid( "0x003399FF" )
	Gdip_FillRectangle( G , Brush , 100 , 180 , 250 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , n3 , "s20 vCenter Bold c" Brush " x99 y179" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , n3 , "s20 vCenter Bold c" Brush " x101 y181" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE60654" )
	Gdip_TextToGraphics( G , n3 , "s20 vCenter Bold c" Brush " x100 y180" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	;score 1
	Brush := Gdip_BrushCreateSolid( "0x003399FF" )
	Gdip_FillRectangle( G , Brush , 350 , 100 , 100 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , s1 , "s20 vCenter Bold c" Brush " x349 y99" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , s1 , "s20 vCenter Bold c" Brush " x351 y101" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE60654" )
	Gdip_TextToGraphics( G , s1 , "s20 vCenter Bold c" Brush " x350 y100" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	;score 2
	Brush := Gdip_BrushCreateSolid( "0x003399FF" )
	Gdip_FillRectangle( G , Brush , 350 , 140 , 100 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , s2 , "s20 vCenter Bold c" Brush " x349 y139" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , s2 , "s20 vCenter Bold c" Brush " x351 y141" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE60654" )
	Gdip_TextToGraphics( G , s2 , "s20 vCenter Bold c" Brush " x350 y140" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	;score 3
	Brush := Gdip_BrushCreateSolid( "0x003399FF" )
	Gdip_FillRectangle( G , Brush , 350 , 180 , 100 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , s3 , "s20 vCenter Bold c" Brush " x349 y179" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , s3 , "s20 vCenter Bold c" Brush " x351 y181" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFE60654" )
	Gdip_TextToGraphics( G , s3 , "s20 vCenter Bold c" Brush " x350 y180" , "Segoe ui" , 180 , 40 )
	Gdip_DeleteBrush( Brush )
	Gdip_DeleteGraphics( G )
	return pBitmap
}


MainWin(){
	;Bitmap Created Using: HB Bitmap Maker
	pBitmap:=Gdip_CreateBitmap( 500 , 600 )
	G := Gdip_GraphicsFromImage( pBitmap )
	Gdip_SetSmoothingMode( G , 2 )
	Brush := Gdip_CreateLineBrushFromRect( 3 , 4 , 491 , 587 , "0x55F0F0F0" , "0x55111111" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 7 , 7 , 486 , 586 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrush( 6 , 5 , 440 , 424 , "0xFF004444" , "0xFF111111" , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 10 , 10 , 480 , 580 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrush( 6 , 5 , 440 , 424 , "0x77023001" , "0x770A1202" , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 10 , 10 , 480 , 580 , 15 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 15 , 48 , 468 , 535 , "0x55F0F0F0" , "0xFF000000" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 15 , 50 , 470 , 535 , 0 )
	Gdip_DeleteBrush( Brush )
	;inner
	Brush := Gdip_CreateLineBrushFromRect( 483 , 583 , -485 , -606 , "0xFF018291" , "0xFF222222" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 17 , 52 , 466 , 531 , 0 )
	Gdip_DeleteBrush( Brush )
	;move
	Brush := Gdip_CreateLineBrushFromRect( 88 , 15 , 320 , 32 , "0xFFF000B9" , "0xFF000000" , 1 , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 90 , 14 , 320 , 32 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrush( 123 , 16 , 177 , 64 , "0xFF05D917" , "0xFF050A00" , 1 )
	Gdip_FillRoundedRectangle( G , Brush , 91 , 15 , 318 , 30 , 5 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFF0F0F0" )
	Gdip_TextToGraphics( G , "AHK FLAPPY BIRD" , "s24 Center vCenter Bold c" Brush " x91 y15" , "Segoe ui" , 318 , 30 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF050A00" )
	Gdip_TextToGraphics( G , "AHK FLAPPY BIRD" , "s24 Center vCenter Bold c" Brush " x93 y17" , "Segoe ui" , 318 , 30 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrush( 149 , 19 , 204 , 17 , "0xFFF000B9" , "0xFF222222" , 1 )
	Gdip_TextToGraphics( G , "AHK FLAPPY BIRD" , "s24 Center vCenter Bold c" Brush " x92 y16" , "Segoe ui" , 318 , 30 )
	Gdip_DeleteBrush( Brush )
	;close
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_FillEllipse( G , Brush , 464 , 15 , 20 , 20 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 464 , 16 , 20 , 18 , "0xFFB4091D" , "0xFF000000" , 1 , 1 )
	Gdip_FillEllipse( G , Brush , 465 , 16 , 18 , 18 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF000000" )
	Gdip_TextToGraphics( G , "X" , "s12 Center vCenter Bold c" Brush " x465 y16" , "Segoe ui" , 18 , 18 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFFAAAAAA" )
	Gdip_TextToGraphics( G , "X" , "s12 Center vCenter Bold c" Brush " x466 y17" , "Segoe ui" , 18 , 18 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , 100 , 100 , "0xFFD7D290" , "0xFF222222" , 1 , 1 )
	Gdip_FillRectangle( G , Brush , 17 , 513 , 466 , 70 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF222222" )
	Gdip_FillRectangle( G , Brush , 17 , 490 , 466 , 30 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 18 , 490 , 465 , 35 , "0xFF00A700" , "0xFF111111" , 1 , 1 )
	Gdip_FillRectangle( G , Brush , 18 , 491 , 464 , 28 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 17 , 50 , 466 , 533 , "0x55F0F0F0" , "0xFF000000" , 1 , 1 )
	Pen := Gdip_CreatePenFromBrush( Brush , 2 )
	Gdip_DeleteBrush( Brush )
	Gdip_DrawRectangle( G , Pen , 17 , 50 , 466 , 533 )
	Gdip_DeletePen( Pen )
	Gdip_DeleteGraphics( G )
	return pBitmap
}

TPipes(){
	;Bitmap Created Using: HB Bitmap Maker
	pBitmap:=Gdip_CreateBitmap( 100 , 500 )
	G := Gdip_GraphicsFromImage( pBitmap )
	Gdip_SetSmoothingMode( G , 3 )
	Brush := Gdip_BrushCreateSolid( "0xFF005A03" )
	Gdip_FillRectangle( G , Brush , 10 , -1 , 80 , 502 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01A612" )
	Gdip_FillRectangle( G , Brush , 14 , -1 , 72 , 500 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF015C06" )
	Gdip_FillRectangle( G , Brush , 0 , 460 , 102 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01A612" )
	Gdip_FillRectangle( G , Brush , 4 , 464 , 91 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
	Gdip_FillRectangle( G , Brush , 14 , 0 , 15 , 460 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
	Gdip_FillRectangle( G , Brush , 33 , 0 , 3 , 460 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
	Gdip_FillRectangle( G , Brush , 4 , 464 , 15 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
	Gdip_FillRectangle( G , Brush , 23 , 464 , 3 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
	Gdip_FillRectangle( G , Brush , 72 , 0 , 5 , 460 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
	Gdip_FillRectangle( G , Brush , 54 , 0 , 11 , 460 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
	Gdip_FillRectangle( G , Brush , 79 , 464 , 5 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
	Gdip_FillRectangle( G , Brush , 60 , 464 , 12 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 13 , 0 , 77 , 457 , "0x4400A713" , "0x66000000" , 1 , 1 )
	Gdip_FillRectangle( G , Brush , 10 , -1 , 80 , 461 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 2 , 461 , 94 , 34 , "0x33007713" , "0x66000000" , 1 , 1 )
	Gdip_FillRectangle( G , Brush , 0 , 460 , 102 , 40 )
	Gdip_DeleteBrush( Brush )
	Gdip_DeleteGraphics( G )
	return pBitmap
}

BPipes(h:=500){
	;Bitmap Created Using: HB Bitmap Maker
	pBitmap:=Gdip_CreateBitmap( 100 , h )
	G := Gdip_GraphicsFromImage( pBitmap )
	Gdip_SetSmoothingMode( G , 3 )
	Brush := Gdip_BrushCreateSolid( "0xFF005B04" )
	Gdip_FillRectangle( G , Brush , -1 , -1 , 102 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF00A713" )
	Gdip_FillRectangle( G , Brush , 4 , 4 , 91 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF005B04" )
	Gdip_FillRectangle( G , Brush , 10 , 38 , 80 , 470 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01A612" )
	Gdip_FillRectangle( G , Brush , 14 , 42 , 72 , 470 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
	Gdip_FillRectangle( G , Brush , 3 , 4 , 14 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
	Gdip_FillRectangle( G , Brush , 14 , 42 , 14 , 462 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
	Gdip_FillRectangle( G , Brush , 21 , 4 , 3 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF007D0D" )
	Gdip_FillRectangle( G , Brush , 31 , 42 , 3 , 472 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
	Gdip_FillRectangle( G , Brush , 79 , 4 , 5 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
	Gdip_FillRectangle( G , Brush , 73 , 42 , 5 , 472 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
	Gdip_FillRectangle( G , Brush , 61 , 4 , 12 , 32 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_BrushCreateSolid( "0xFF01D217" )
	Gdip_FillRectangle( G , Brush , 56 , 42 , 12 , 492 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( -1 , -1 , 99 , 40 , "0x4400A713" , "0x44222222" , 1 , 1 )
	Gdip_FillRectangle( G , Brush , -1 , -1 , 102 , 40 )
	Gdip_DeleteBrush( Brush )
	Brush := Gdip_CreateLineBrushFromRect( 9 , 35 , 80 , 465 , "0x4400A713" , "0x66000000" , 1 , 1 )
	Gdip_FillRectangle( G , Brush , 10 , 43 , 80 , 470 )
	Gdip_DeleteBrush( Brush )

	Brush := Gdip_BrushCreateSolid( "0xFF005B04" )
	Gdip_FillRectangle( G , Brush , 10 , h-3 , 80 , 10 )
	Gdip_DeleteBrush( Brush )

	Gdip_DeleteGraphics( G )
	return pBitmap
}