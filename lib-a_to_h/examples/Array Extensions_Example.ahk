; Autoexecute
#NoEnv
#SingleInstance force

#Include C:\Program Files\AutoHotkey\lib\Array Extensions.ahk

none := []
hege := ["Cecilie", "Lone"]
stale := ["Emil", "Tobias", "Linus"]
kai := ["Robin", "Tobias", "Walter"]
Num := [5,3,7,9,1,13,999,-4]

children := hege.Concat(stale, kai)
MsgBox, 0, Concat Arrays Building Children, % "Children =`n" children.Join("`n")

MsgBox, 0, IndexOf Tobias, % children.IndexOf("Tobias")

MsgBox, 0, IndexOf Tobias with Start = 5, % children.IndexOf("Tobias", 5)

MsgBox, 0, LastIndexOf Tobias, % children.LastIndexOf("Tobias")

MsgBox, 0, LastIndexOf Tobias with Start = 5, % children.LastIndexOf("Tobias", 5)

MsgBox, 0, LastIndexOf Tobias with Start = 5, % children.LastIndexOf("Tobias", 5)

MsgBox, 0, Length of Children, % children.Length()

MsgBox, 0, Pop an Element, % children.Pop()

MsgBox, 0, Array After Pop, % children.Join("`n")

MsgBox, 0, Push Micheal, % children.Push("Micheal").Join("`n")

MsgBox, 0, Shift an Element, % children.Shift()

MsgBox, 0, Array After Shift, % children.Join("`n")

MsgBox, 0, Unshift George, % children.Unshift("George").Join("`n")

MsgBox, 0, Slice Out Indexes 2 - 4, % children.Slice(2, 4).Join("`n")

MsgBox, 0, Splice - 2 Elements Removed at Index 3
, % children.Splice(3, 2, "Sally", "Amy").Join("`n")

MsgBox, 0, Splice - Sally`, Amy Added at Index 3
, % children.Join("`n")

MsgBox, 0, Sort Children, % children.Sort().Join("`n")

MsgBox, 0, Numerical Sort, % Num.Sort("N").Join("`n")

MsgBox, 0, Reverse Children, % children.Reverse().Join("`n")

return