ReplaceIllegalFilenameCharacters(fnText)
{
	; replace disallowed windows filename characters in a string with an underscore
	; MsgBox fnText: %fnText%
	
	StringReplace, fnText, fnText, \,_, All
	StringReplace, fnText, fnText, /,_, All
	StringReplace, fnText, fnText, :,_, All
	StringReplace, fnText, fnText, *,_, All
	StringReplace, fnText, fnText, ?,_, All
	StringReplace, fnText, fnText, ",_, All
	StringReplace, fnText, fnText, <,_, All
	StringReplace, fnText, fnText, >,_, All
	StringReplace, fnText, fnText, |,_, All
	
	Return fnText	
}


/* ; testing
Text := "Hello < my Dear! ""I am "" /\:*?""<>|what's up?"
ReturnValue := ReplaceIllegalFilenameCharacters(Text)
MsgBox, ReplaceIllegalFilenameCharacters`n`nReturnValue: %ReturnValue%
*/