; Created by Frankie Bagnardi
; Forum topic:
; Licenced under the MIT license: http://www.opensource.org/licenses/mit-license.php
class RegEx
{
	Needle := "."
	EMAIL := "i)(?:\b|^)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}(?:\b|$)"
	EMAIL2 := "[a-z0-9!#$%&'*+/=?^_``{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_``" 
	. "{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|"
	. "net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\b"
	
	__New(N) {
		this.Needle := N
	}
	
	; All matches are stored in a 2-dimentional object
	; The format is MyMatches[Match_Number, Group_Name]
	; In many cases Group_Name is a number
	; When using a named group, e.g., (?P<MyGroupName>pattern), the result
	; will be stored in MyGroupName also
	Match(H, N=-1) {
		If N is number
			If (N = -1)
				N := this.Needle ; Set default
		Matches := {}
		Groups := this.GetGroups(N)
		Pos := 1, Match_ := ""
		While ( Pos := RegExMatch(H, N, Match_, Pos + StrLen(Match_)) )
		{
			MatchIndex := A_Index
			for key, subpat in Groups
			{
				This_Match := Match_%subpat%
				OutputDebug Matches[%MatchIndex%, %subpat%] := %This_Match%`n%key%
				Matches[MatchIndex, key] := This_Match
				subpat_int := subpat+0
				If subpat_int is not Integer
					Matches[MatchIndex, subpat] := This_Match
			}
		}
		return Matches
	}
	
	; MatchCall is a callout function
	; It calls function F each time your needle matches
	;	F can be a string like "MyFuncName", or an object reference, e.g., Class.MyFuncName
	;	Do not include the parenthesis and parameters. C.F not C.F(Param)
	; Each subpattern is sent as a parameter
	MatchCall(H, F, N=-1) {
		If N is number
			If (N = -1)
				N := this.Needle ; Set default
		If !IsFunc(F)
			return
		If !IsObject(F)
			F := Func(F) ; Make it an object
		G := this.GetGroups(N)
		Pos := 1, M_ := ""
		While ( Pos := RegExMatch(H, N, M_, Pos + StrLen(M_)) ) {
			for key, subpat in G
				P_%key% := M_%Subpat%
			F.(M_, P_1, P_2, P_3, P_4, P_5, P_6, P_7, P_8, P_9, P_10, P_11, P_12, P_13, P_14, P_15)
		}
	}
	
	; This is essencially a one line RegExMatch, as apposed to a command
	; Subpat refers to the numbered or named subpatern to be returned
	;	For example, 1 or MyNamedPattern
	;	Ommit this parameter or use "" to return the entire match
	; To capture multiple matches use Match()
	MatchSimple(H, Subpat="", N=-1) {
		If N is number
			If (N = -1)
				N := this.Needle ; Set default
		RegExMatch(H, N, M)
		return M%Subpat%
	}
	
	; Returns true if any mach is found
	; false otherwise
	Test(H, N=-1) {
		If N is number
			If (N = -1)
				N := this.Needle ; Set default
		Return !!RegExMatch(H, N)
	}
	
	; Return all pattern group in the needle
	; Unnamed subpatterns and named subpatterns will found
	; Results will be returned in an array
	GetGroups(N) {
		Groups := [] ; Array to be returned
		Pos := 0
		While ( Pos := RegExMatch(N, "\(\?P<(?P<NamedMatch>.*?)>.*?\)|\(.*?\)", Group_, Pos + 1) )
		{
			If Group_NamedMatch
				Groups.Insert(Group_NamedMatch)
			else
				Groups.Insert(A_Index)
		}
		return Groups
	}
}