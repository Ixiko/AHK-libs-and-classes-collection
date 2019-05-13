#include %A_ScriptDir%\hXfromHBITMAP.ahk
#include %A_ScriptDir%\LoadPictureType.ahk

transCol:=0xC0FFEE
hBitmap := LoadPicture("hX.bmp")
hIcon := new hIconFromhBitmap(hBitmap,transCol)

gui := guiCreate()
gui.addText(,"Input bitmap:")
gui.addPic(,"hBitmap:" hBitmap)
gui.addText(,"Output icon:")
gui.addPic(,"hIcon:" hIcon)
gui.addText(,"Font: wingdings. Symbol: 7")
gui.show()
