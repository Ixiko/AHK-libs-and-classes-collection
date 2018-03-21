/*

Plugin            : LowerReplaceSpace()
Purpose           : Paste current clipboard (top most in menu) as lower case
Version           : 1.0
Last modified     : Wednesday, November 6, 2013
CL3 version       : 1.0

*/

LowerReplaceSpace(Text)	{
	 StringLower, text, text
	 StringReplace, text, text, %A_Space%, _, All
	 return text
	}
	