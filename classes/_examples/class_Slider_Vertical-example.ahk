;~ Class_Slider_Vertical.ahk  by Keylo
;~ Based on tmplinshi Horizontal Slidder- https://www.autohotkey.com/boards/viewtopic.php?t=80476
;~ __________________________________________________________________________________________
/*--------------------------------------------------------------------
Availlable 64encoded sliders:
**********************************************
Create_Yellow_Slider_png(NewHandle := False)
Create_White_Slider_2_png(NewHandle := False)
Create_White_Slider_png(NewHandle := False)
Create_Silver_Slider_png(NewHandle := False)
Create_Red_Slider_png(NewHandle := False)
Create_Black_Flat_Slider_png(NewHandle := False)
Create_Black_and_Blue_Slider_jpg(NewHandle := False)
Create_Grey_Slider_jpg(NewHandle := False)
Create_GoldSlider_jpg(NewHandle := False)
Create_sliderthumb_png(NewHandle := False)
************************************************
_______________________________
Optional - you can also load your own picture using:
ex : hBitmap := LoadPicture("GoldSlider.JPG")

To retrieve the slider position use: MsgBox, % slider.pos
To set the slider position use : slider.pos := 50
_______________________________________

*/--------------------------------------------------------------------
#Include %A_ScriptDir%\..\class_Slider_Vertical.ahk

Gui, 4:Color, 0x282D41
gui, 4:add, edit, vValue ,
hBitmap := Create_Silver_Slider_png(NewHandle := False)
hBitmap2 := Create_Red_Slider_png(NewHandle := False)
hBitmap3 := Create_GoldSlider_jpg(NewHandle := False)
hBitmap4 := Create_White_Slider_2_png(NewHandle := False)

;~ slider := new Slider_Vertical("Range0-100 x44 y60 w8 h244 BackGround0x454C5F c0x2666B5", 20, hBitmap , ShowTooltip := true, SliderWidth := 24, SliderHeight := 54, Label := "play", Gui := "4")
slider := new Slider_Vertical("Range0-100 x10 y60 w8 h44 BackGround0x454C5F c0x2666B5", 20, hBitmap , ShowTooltip := true, SliderWidth := 14, SliderHeight := 22, Label := "Count", Gui := "4")

slider2 := new Slider_Vertical("Range0-100 x54 y60 w8 h144 BackGround0x454C5F c0x2666B5", 50, hBitmap3, ShowTooltip := true, SliderWidth := 24, SliderHeight := 54, Label := "", Gui := "4")

slider2 := new Slider_Vertical("Range0-100 x144 y60 w8 h144 BackGround0x454C5F c0x2666B5", 50, hBitmap2, ShowTooltip := true, SliderWidth := 24, SliderHeight := 54, Label := "", Gui := "4")

slider2 := new Slider_Vertical("Range0-100 x184 y60 w8 h144 BackGround0x454C5F c0x2666B5", 50, hBitmap4, ShowTooltip := true, SliderWidth := 24, SliderHeight := 54, Label := "", Gui := "4")

Gui, 4:Show,  w300 h400

Return

Count:
ct++
TrayTip,,%ct%
return


4GuiClose:
ExitApp