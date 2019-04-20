#Include %A_ScriptDir%\..\..\classes\class_gdipChart.ahk

SetBatchLines,-1

GUI,New
GUI +hwndGUI1
GUI,Show, w600 h400

chart1 := new gdipChart( GUI1, "", [ 0, 0, 256, 256 ] )

stream := chart1.addDataStream( createRandomData(), 0xFF00FF00 )

stream.setVisible()
chart1.setVisible()
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