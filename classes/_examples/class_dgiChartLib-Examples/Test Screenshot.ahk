#Include %A_ScriptDir%\..\..\classes\class_gdipChart.ahk

/*
Original Example by Helgef - but it really does look beautiful
*/

SetBatchLines,-1

GUI,New
GUI +hwndGUI1

chart := new gdipChart( GUI1, "", [ -3.3, -1.1, 6.6, 2.2 ] )
data:=[[-3.140000,-0.001593],[-2.878333,-0.260229],[-2.616667,-0.501149],[-2.355000,-0.707951],[-2.093333,-0.866556],[-1.831667,-0.966166],[-1.570000,-1.000000],[-1.308333,-0.965754],[-1.046667,-0.865760],[-0.785000,-0.706825],[-0.523333,-0.499770],[-0.261667,-0.258691],[-0.000000,-0.000000],[0.261667,0.258691],[0.523333,0.499770],[0.785000,0.706825],[1.046667,0.865760],[1.308333,0.965754],[1.570000,1.000000],[1.831667,0.966166],[2.093333,0.866556],[2.355000,0.707951],[2.616667,0.501149],[2.878333,0.260229],[3.140000,0.001593]]
stream := chart.addDataStream( data, 0xFF00FF00 )
chart.getAxes().setAttached( 1 )
chart.getGrid().setFieldSize( [ 3.14, 1 ] )
stream.setVisible()
chart.setVisible()
GUI,Show, w600 h400
chart.flushToFile( "Screenshots/Screenshot.png" )
return

GUIClose:
ExitApp