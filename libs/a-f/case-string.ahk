; Title:   	(3) Determine casing with numbers and/or symbols
; Link:     	autohotkey.com/boards/viewtopic.php?f=76&t=86881
; Author:	mikeyww
; Date:   	2021-02-13
; for:     	AHK_L

/*

   Is it possible to determine casing (capitalization) modes in a string that includes numbers or symbols? Essentially, I want to be able to test strings for "all-caps", and test for "all-lower-case",
   in strings that may include numbers and/or symbols. Is this possible?

	For k, v in ["A98B", "A45b", "a45b", "0x89Af(Hex)"]
	MsgBox, 0, case, % k ". " v  ": " case(v)


*/


case(string) {
 string := RegExReplace(string, "[^\pL]"), case := "Mixed"
 If string is upper
  case = Upper
 If string is lower
  case = Lower

Return case
}