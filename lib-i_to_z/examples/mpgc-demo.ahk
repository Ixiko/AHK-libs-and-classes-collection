#NoEnv
#SingleInstance Force

#include mpgc.ahk

init_mpgc()
update_mpgc()
MsgBox % "Color: " . mpgc(10, 10)
MsgBox % "Color: " . mpgc(11, 11)
update_mpgc()
MsgBox % "Color: " . mpgc(10, 10)
MsgBox % "Color: " . mpgc(11, 11)
end_mpgc()
