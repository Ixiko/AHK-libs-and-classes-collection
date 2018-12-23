#Include %A_ScriptDir%\..\..\classes\class_gdipChart.ahk

SetBatchLines,-1

GUI,New
GUI +hwndGUI1

chart1  := new gdipChart( GUI1, "", [ 0, 0, 5, 255 ] )
streams := []
color   := [ 0xFFFF0000, 0xFF00FF00, 0xFF0000FF ]
Loop 3
{
	stream := chart1.addDataStream( createRandomData(0, 0, 1000, 255, 40), color[ A_Index ] )
	stream.setVisible()
	streams.push( stream )
}

chart1.setVisible()
SetTimer,scrollColor, 15
bColor := []
for each, stream in streams
	bColor.Push( stream.getData()[ 1, 2 ] )
startT := A_TickCount
GUI,Show, w600 h400
return

scrollColor:

frameNr :=  ( A_TickCount - startT ) / 200
if ( floor( frameNr ) != lastFrameNr )
{
	lastFrameNr := floor( frameNr )
	lastColor := bColor
	bColor  := []
	for each, stream in streams
		bColor.Push( stream.getData()[ ceil( frameNr ), 2 ] )
}
inFramePosition := frameNr - lastFrameNr
ibColor := 255
for each, color in bColor
	ibColor := ( ibColor << 8 ) | Round( bColor[ each ] * inFramePosition + lastColor[ each ] * ( 1 - inFramePosition ) )
;^Interpolates color

chart1.freezeRedraw( 1 )
chart1.setFieldRect( [ frameNr, 0, 5, 255 ] )
chart1.setColor( ibColor )
chart1.freezeRedraw( 0 )
;^ Move Field and set BackgroundColor
;enable freezeRedraw with freezeRedraw( 1 ) to disable automatic redrawing and freezeRedraw( 0 ) to draw all new changes.
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