#NoEnv

/*
String = MsgBox `% "Hello, World! ""123"" 456" . Hello . World! . "`nTest: " . 123 * 456
MsgBox % CodeReplace(String,"S)!","Exclamation")
MsgBox % CodeReplace(String,"S)123","OneTwoThree")
MsgBox % LiteralReplace(String,"S)!","Exclamation")
MsgBox % LiteralReplace(String,"S)123","OneTwoThree")
*/

StringCodeReplace(String,RegularExpression,Replacement = "",ByRef OutputCount = "")
{
 FoundPos := 1, FoundPos1 := 1
 While, (FoundPos := RegExMatch(String,"S)""(?:[^""]|"""")*""",Match,FoundPos))
  String1 .= RegExReplace(SubStr(String,FoundPos1,FoundPos - FoundPos1),RegularExpression,Replacement) . Match, FoundPos += StrLen(Match), FoundPos1 := FoundPos, OutputCount := A_Index
 Return, String1 . RegExReplace(SubStr(String,FoundPos1),RegularExpression,Replacement)
}

StringLiteralReplace(String,RegularExpression,Replacement = "",ByRef OutputCount = "")
{
 FoundPos := 1, FoundPos1 := 1
 While, (FoundPos := RegExMatch(String,"S)""(?:[^""]|"""")*""",Match,FoundPos))
  String1 .= SubStr(String,FoundPos1,FoundPos - FoundPos1) . RegExReplace(Match,RegularExpression,Replacement), FoundPos += StrLen(Match), FoundPos1 := FoundPos, OutputCount := A_Index
 Return, String1 . SubStr(String,FoundPos1)
}