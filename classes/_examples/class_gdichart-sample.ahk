#NoEnv
#include %A_ScriptDir%\..\class_gdichart.ahk

;~ 0x2e880c	绿
;~ 0x234fcb	橙
;~ 0xdd5403	蓝

Gui, +hwndgid +AlwaysOnTop +ToolWindow ;+E0x20
Gui, Color, ffffff
Gui, Add, Pic, w460 h290 Section Border 0xE hwndpic1
Gui, Add, Pic, x+10 yp w560 h290 Border 0xE hwndpic3
Gui, Add, Pic, w460 h230 xs Border 0xE hwndpic2
Gui, Add, Pic, x+10 yp w560 h230 Border 0xE hwndpic4


; #########################sample1 start##########################
data1:=Object()
data1["chart"]:="line"
data1["maxindex"]:=0
data1["xmax"]:=0
data1["ymax"]:=0

str=
(Join`s
50,100
120,240
150,70
200,450
220,400
240,510
270,400
300,280
320,350
400,110
)
Loop, Parse, str,%A_Space%
{
	RegExMatch(A_LoopField,"(\d+),(\d+)",match)
	data1["x",A_Index]:=match1+0
	data1["y",A_Index]:=match2+0
	data1["maxindex"]++
}

chart1:=new gdichart(pic1)

chart1.Grid(4,4)
chart1.drawData(data1,0xfffa5c7e)
chart1.show()
; #########################sample1 end############################



; #########################sample2 start##########################
data2_a:=Object()
data2_a["chart"]:="line"
data2_a["maxindex"]:=0
data2_a["xmax"]:=0
data2_a["ymax"]:=0
Loop, 20
{
	data2_a["x",A_Index]:=A_Index*50+roll(0,30)
	data2_a["y",A_Index]:=(roll(50,500)*0.5+(data2_a["y",A_Index-1]>0?data2_a["y",A_Index-1]:0)*0.3+(data2_a["y",A_Index-2]>0?data2_a["y",A_Index-2]:0)*0.2)
	data2_a["maxindex"]++
}

data2_b:=Object()
data2_b["chart"]:="line"
data2_b["maxindex"]:=0
data2_b["xmax"]:=0
data2_b["ymax"]:=0
Loop, 20
{
	data2_b["x",A_Index]:=A_Index*50+roll(0,30)
	data2_b["y",A_Index]:=(roll(50,500)*0.5+(data2_b["y",A_Index-1]>0?data2_b["y",A_Index-1]:0)*0.3+(data2_b["y",A_Index-2]>0?data2_b["y",A_Index-2]:0)*0.2)
	data2_b["maxindex"]++
}

chart2:=new gdichart(pic2)

chart2.Grid(10,10)
chart2.drawData(data2_a,0xffdd5403)
chart2.drawData(data2_b,0xff234fcb)
chart2.show()
; #########################sample2 end############################



; #########################sample3 start##########################
data3:=Object()
data3["chart"]:="bar"
data3["maxindex"]:=0
data3["xmax"]:=10
data3["ymax"]:=500

Loop, 10
{
data3["x",A_Index]:=A_Index
data3["y1",A_Index]:=roll(50,500)
data3["y2",A_Index]:=roll(50,500)
data3["y3",A_Index]:=roll(50,500)
data3["maxindex"]++
}

chart3:=new gdichart(pic3)
chart3.Grid(10,5)
chart3.drawData(data3,"0xfffa5c7e|0xff234fcb|0xffdd5403")
chart3.show()
; #########################sample3 end############################




; #########################sample4 start##########################
data4:=Object()
data4["chart"]:="line"
data4["maxindex"]:=0
data4["xmax"]:=0
data4["ymax"]:=0
Loop, 100
{
	data4["x",A_Index]:=A_Index*15+roll(0,5)
	data4["y",A_Index]:=(roll(50,500)*0.25+roll(50,500)*0.25+roll(50,500)*0.25+roll(50,500)*0.25)
	data4["maxindex"]++
}

chart4:=new gdichart(pic4)
chart4.Grid(15,10)
chart4.drawData(data4,0xff234fcb)
chart4.drawLabel()
chart4.show()
; #########################sample4 end############################

Gui, Show,
Return



F5::
GuiClose:
ExitApp

roll(min=0,max=100)
{
	Random, var, min, max
	Return, var
}
