#include A_ScriptDir\..\..\class_Subtitle.ahk
#include A_ScriptDir\..\..\..\libs\g-n\Gdip_All.ahk

text := {}
text.font := "Gill Sans MT Condensed"
text.size := "6vh"
text.outline := {}
text.outline.stroke := "1 px"
text.outline.color := "Black"
text.outline.glow := "5px"
text.outline.tint := "FE4759"
text.color := "White"


background := {}
background.color := "Transparent"
background.x := "center"
background.y := "40vh"


Subtitle.Render("your wife is a rare flower that you water with your love", background, text).Screenshot("image2.png")

