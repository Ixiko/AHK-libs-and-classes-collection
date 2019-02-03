;Uses a combined list & array Groups index,for ease of use & efficiency,respectively.
;https://www.autohotkey.com/boards/viewtopic.php?t=60272
;====================================================================================================

GroupAdd(groupName,groupMembers*){
	Global A_Groups,A_GroupsArr
	( !InStr(A_Groups, groupName ",") ? (A_Groups .= A_Groups ? "`n" groupName "," : groupName ",") : "" )	;initialise group if it doesn't exist...
	For i,groupMember in groupMembers
		( !InStr(A_Groups, groupMember) ? (A_Groups := StrReplace(A_Groups, groupName ",", groupName "," groupMember ",")) : )	;append to or create new group...
	A_Groups := RegExReplace(RegExReplace(A_Groups, "(^|\R)\K\s+"), "\R+\R", "`r`n")	;clean up groups to remove any possible blank lines
	,ArrayFromList(A_GroupsArr,A_Groups)	;rebuild group as array for most efficient cycling through groups...
}

GroupDelete(groupName, groupMember:=""){
	Global A_Groups,A_GroupsArr
	For i,group in StrSplit(A_Groups,"`n")
		( groupMember && group && InStr(A_Groups,groupMember) && groupName = StrSplit(group,",")[1] ? (A_Groups:=StrReplace(A_Groups,group,StrReplace(group,groupMember ","))) : !groupMember && groupName = StrSplit(group,",")[1] ? (A_Groups:=StrReplace(A_Groups,group))  )	;remove group member from group & update group in A_Groups
	A_Groups := RegExReplace(RegExReplace(A_Groups, "(^|\R)\K\s+"), "\R+\R", "`r`n")	;clean up groups to remove any possible blank lines
	,ArrayFromList(A_GroupsArr,A_Groups)	;rebuild group as array for most efficient cycling through groups...
}

ArrayFromList(ByRef larray, ByRef list, listDelim := "`n", lineDelim:=","){
	larray := []
	Loop, Parse, list, % listDelim
		larray.Push(StrSplit(A_LoopField,lineDelim))
}

;Function's below are subject to a performance overhead & hence use A_GroupsArr...as they are repeatedly called...
GroupActive(groupName){
	Global A_GroupsArr
	For i,group in A_GroupsArr
		If (group.1 = groupName)
			For iG,groupMember in group
				If (iG > 1 && groupMember && (firstMatchId := WinActive(groupMember)))
					Return group.1 "," firstMatchId
}

GroupTranspose(groupName){	;makes this custom group,a 'real' group,some use cases....
	Global A_GroupsArr
	For i,group in A_GroupsArr
		If (group.1 = groupName)
			For iG,groupMember in group
				If (iG > 1 && groupMember)
					GroupAdd, % group.1, % groupMember
	Return groupName
}

IsInGroup(groupName, groupMember){
	Global A_Groups
	Loop, Parse, A_Groups, `n
		If (StrSplit(A_LoopField,",")[1] = groupName && InStr(A_LoopField,groupMember))
			Return True
}

;====================================================================================================