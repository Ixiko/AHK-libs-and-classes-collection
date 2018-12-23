#Include %A_ScriptDir%\..\..\classes\class_gdipChart.ahk

SetBatchLines,-1

GUI,New
GUI +hwndGUI1

chart1 := new gdipChart( GUI1, "", [ 0, 0, 16, 256 ] )


stream := chart1.addDataStream( createRandomData( 0,  0, 1000, 256), 0xFF00FF00 )
startT := A_TickCount

stream.setVisible()
chart1.setVisible()
GUI,Show, w600 h400
SetTimer,scroll,15
return

GUIClose:
ExitApp

scroll:
chart1.setFieldRect( [ ( A_TickCount - startT ) / 150,0 ,16, 256 ] )
return

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