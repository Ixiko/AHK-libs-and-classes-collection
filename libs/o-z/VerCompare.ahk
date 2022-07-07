/*
Library: VerCompare.ahk
Author: Animan8000, original by joedf
Description: VerCompare() function for AutoHotkey v1.1 - Compare two semantic version strings similar like the function in v2 of AutoHotkey! For more information see: https://lexikos.github.io/v2/docs/commands/VerCompare.htm
Version: 1.0
GitHub: https://github.com/Animan8000/VerCompare.ahk
License: MIT
*/

VerCompare(VersionA, VersionB) {
	CheckVerA := StrSplit(VersionA,"."), CheckVerB := StrSplit(VersionB,".")
	For _index, _num in CheckVerB
		If ((CheckVerA[_index]+0) > (_num+0))
			Return 1
		Else If ((CheckVerA[_index]+0) = (_num+0))
			Return 0
		Else If ((CheckVerA[_index]+0) < (_num+0))
			Return -1
	Return 0
}
