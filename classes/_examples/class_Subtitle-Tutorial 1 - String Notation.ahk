#include %A_ScriptDir%\..\class_Subtitle.ahk

a := new Subtitle()
a.Render("While I stood in the heavy, never-ending rain, I forgot how to smile...", "x:center y:83% c:Off", "s:52.7 f:(Garamond) color:White outline:(stroke:1 glow:4 tint:Black) dropShadow:(blur:5px color:White opacity:0.5 size:15)")
a.Screenshot("MyFile.png")
return