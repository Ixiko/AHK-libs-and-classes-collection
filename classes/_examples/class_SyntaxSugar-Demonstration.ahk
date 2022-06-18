; Demonstration:
#Include <SyntaxSugar>


String = Dates X20170523120123 Y20050423220133 Z20070523120123
Regex = Ogi)(?<Name>x|Y|z)(?<Number>\d+)  ; Uses the global flag g to get all matches from the string.
Matches := String.Match(Regex)

; Show the array of matches in a message box:
Matches.Msgbox()

; Format the dates in the string and return the new string:
Result := String
    .Replace( Regex, Func("ReplaceFunc") )
    .Msgbox()

; Show all matches from the years 2005, 2006, and 2007:
For Index, Match in Matches
	If Match.Number.Contains("2005,2006,2007")
		Msgbox % "Date " Match.Name " was long ago (" Match.Number.Substr(1, 4) ")."

ReplaceFunc(Match, CurrentMatches, String){
	FormatTime, TimeString, % Match.Number, dddd MMMM d, yyyy hh:mm:ss tt
	Return "`n" Match.Name ": [" TimeString "]"
}

