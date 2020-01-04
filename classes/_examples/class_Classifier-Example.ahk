#NoEnv
#include %A_ScriptDir%\..\class_Classifier.ahk

c := new Classifier

c.Train("Nobody owns the water.","good")
c.Train("the quick rabbit jumps fences","good")
c.Train("buy pharmaceuticals now","bad")
c.Train("make quick money at the online casino","bad")
c.Train("the quick brown fox jumps","good")

Item := "quick rabbit"

Result := "Category`tProbability`n"
For Index, Entry In c.Classify(Item)
    Result .= Entry.Category . "`t" . Entry.Probability . "`n"
MsgBox, %Result%
ExitApp