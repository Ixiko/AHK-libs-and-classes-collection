#Include %A_ScriptDir%\..\..\classes\class_gdipChart.ahk

SetBatchLines,-1
CoordMode,Mouse,Client

GUI,New
GUI +hwndGUI1
chart1 := new gdipChart( GUI1, "", [ -128, -128, 256, 256 ] )
stream := chart1.addDataStream( createRandomData( -128, -128 ), 0xFF00FF00 )
chart1.getAxes().setAttached( 0 )

stream.setVisible()
chart1.setVisible()
Start := A_TickCount
SetTimer,Move,15
GoSub,Move
GUI,Show, w600 h400
return

Move:
MouseGetPos, x, y, hWND
if ( hWND + 0 = GUI1 + 0 && isObject( origin := chart1.getPointPixelToField( [ x, y ], 1, 0, 0 ) ) ) 
{
	chart1.setFreezeRedraw( 1 )
	chart1.getAxes().setVisible()
	chart1.getAxes().setOrigin( origin )
	chart1.setFreezeRedraw( 0 )
}
else
	chart1.getAxes().setVisible( 0 )
return

GUIClose:
ExitApp


createRandomData( x := 0, y := 0, w := 256, h := 256, variance := 5, steps := 1 )
{
	data := []
	dSteps := 1 / steps
	x *= dSteps
	y *= dSteps
	w *= dSteps
	h *= dSteps
	variance *= dSteps
	Random,val,% y,% y + h
	Loop % ( w-x )
	{
		Random,val,% ( val - variance < y ) ? y : val - variance  ,% ( val + variance > ( y + h ) ) ? ( y + h ) : val + variance
		data[ A_Index ] := [ ( x + A_Index - 1 ) * steps, val * steps ]
	}
	return data
}