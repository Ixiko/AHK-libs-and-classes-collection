#include ..\Lib\String.ahk

str := "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

MsgBox("First character: " str[1])
MsgBox("Substring for characters 2-7: " str[2,7])
MsgBox("Substring starting from character 10: " str[10,0])

MsgBox("Reversed: " str.Reverse())
MsgBox("Word wrapped: `n" str.WordWrap())
MsgBox("Concatenate: " "; ".Concat("First", "second", 123))