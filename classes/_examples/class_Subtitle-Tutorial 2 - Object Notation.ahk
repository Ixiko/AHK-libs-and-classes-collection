#include <Subtitle>

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


Subtitle.Render("ta mère est une fleure rare que t'abreuve par ton amour", background, text).Screenshot("image2.png")

