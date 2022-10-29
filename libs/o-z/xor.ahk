#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
RAW =
(
6-9 z: qzzzzxzzfzzzz
2-4 s: xgmsdts
6-7 k: khqpsvk
1-3 k: knkqh
4-11 z: lwnzgzlmpvz
11-12 m: mmmmmmmmmmtz
1-10 l: lllllllllml
2-5 q: qjmzhdpmmnqpwptn
7-8 t: ttkttbtwtt
)
Total := 0
List := StrSplit(RAW,"`n")
for k, v in List {
	RegExMatch(v, "O)(?<min>\d+)-(?<max>\d+) (?<digit>\w): (?<password>\w*)",o)

	If (SubStr(o.password,o.min,1) = o.digit) ^ (SubStr(o.password,o.max,1) = o.digit)
		s .= o.password " - " Total++ "`n"
}
MsgBox, %  s
