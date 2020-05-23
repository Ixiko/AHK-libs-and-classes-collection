# GUIClass
Basic Usage:
Download the Zip file from Github.
```autohotkey
#Include Includes\GUIClass.ahk
MainWin:=New GUIClass(1,{MarginX:2,MarginY:2,Background:0,Color:"0xAAAAAA"}) ;Instantiate the class
MainWin.Add("Edit,vMyEdit gMyEdit w500 h500,Default Text,wh") ;Add a Control to the GUI with the Name of MyEdit
MainWin.Show("My Window Name") ;Show the Window with the name of "My Window Name"
return
MyEdit(){
  global MainWin
  All:=MainWin[] ;Get all of the values from the Controls
  ToolTip,% All.MyEdit ;Display the value for MyEdit
}
1Escape(){
  ExitApp ;This Function will be called when the user press Escape with the Window Focused
}
1Close(){
  ExitApp ;This Function will be called when the user presses the X to close the Window
}
```
The file GUIClass.ahk has a more in depth example.
