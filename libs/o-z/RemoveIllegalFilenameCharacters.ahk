RemoveIllegalFilenameCharacters(fnText)
{
	; remove disallowed windows filename characters from a string
	; MsgBox fnText: %fnText%
	
	StringReplace, fnText, fnText, \,, All
	StringReplace, fnText, fnText, /,, All
	StringReplace, fnText, fnText, :,, All
	StringReplace, fnText, fnText, *,, All
	StringReplace, fnText, fnText, ?,, All
	StringReplace, fnText, fnText, ",, All
	StringReplace, fnText, fnText, <,, All
	StringReplace, fnText, fnText, >,, All
	StringReplace, fnText, fnText, |,, All
	
	Return fnText	
}


/* ; testing
Text := "Hello < my Dear! ""I am "" /\:*?""<>|what's up?"
ReturnValue := RemoveIllegalFilenameCharacters(Text)
MsgBox, RemoveIllegalFilenameCharacters`n`nReturnValue: %ReturnValue%
*/