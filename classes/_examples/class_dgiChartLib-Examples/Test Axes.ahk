#Include %A_ScriptDir%\..\..\classes\class_gdipChart.ahk

SetBatchLines,-1

GUI,New
GUI +hwndGUI1
chart1 := new gdipChart( GUI1, "", [ -127, -127, 255, 255 ] )

stream := chart1.addDataStream( createRandomData( -160, -160, 355, 355, 20, 10 ), 0xFF00FF00 )

stream.setVisible()
chart1.getAxes().setAttached( 1 ) 
chart1.getAxes().setColor( 0xFFFF0000 )
chart1.setVisible()
Start := A_TickCount
SetTimer,Rotate,15
GoSub,Rotate
GUI,Show, w600 h600
return

Rotate:
frame := ( A_TickCount - Start ) / 300
chart1.setFieldRect( [ -127 + sin( frame ) * 40 , -127 + cos( frame ) * 40, 255, 255 ] )
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