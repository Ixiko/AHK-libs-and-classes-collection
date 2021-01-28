RegExFileSearch(fnSearchTerm,fnSearchRootFolder := "")
{
	; search files and folders using regular expressions
	; MsgBox fnSearchRootFolder: %fnSearchRootFolder%`nfnSearchTerm: %fnSearchTerm%


	; declare local, global, static variables
	Global LocalWorkFolder, TempDir, RegExFileSearchResultsHTMLTemplate


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnSearchTerm
			Throw, Exception("No search term was passed in")


		; initialise variables
		If !fnSearchRootFolder
			fnSearchRootFolder := LocalWorkFolder
		MatchingFolderNames  := ""
		MatchingFileNames    := ""
		MatchingFileContents := ""
		BodyText             := ""
		MaxFilenameLength    := 0
		MaxFilenameLength2   := 0
		MaxFoldernameLength2 := 0
		MaxFilenameLength3   := 0
		MaxFoldernameLength3 := 0
		MaxLineLength3       := 0
		RegExFileSearchResults = %TempDir%\RegExSearch_%A_Now%.html
		
		
		; set default options if not present
		; FirstOpenParen  := InStr(fnSearchTerm, "(")
		; FirstCloseParen := InStr(fnSearchTerm, ")")
		; If (FirstCloseParen > FirstOpenParen) ; no options
			; fnSearchTerm := "iS)" fnSearchTerm
		

		; create arrays of matches
		Loop, Files, %fnSearchRootFolder%\*.*, FDR
		{
			 ; folders
			If A_LoopFileAttrib contains D
			{
				If RegExMatch(A_LoopFileName,fnSearchTerm)
				{
					MatchingFolderNames .= A_LoopFileName "|" A_LoopFileFullPath "`r`n"
					MaxFilenameLength1 := StrLen(A_LoopFileName) > MaxFilenameLength1 ? StrLen(A_LoopFileName) : MaxFilenameLength1
				}
			}
				
			 ; files
			If A_LoopFileAttrib not contains D
			{
				If A_LoopFileExt in txt,sql,csv,ahk
				{
					; filenames
					If RegExMatch(A_LoopFileName,fnSearchTerm)
					{
						MatchingFileNames .= A_LoopFileName "|" A_LoopFileFullPath "|" A_LoopFileDir "`r`n"
						MaxFilenameLength2   := StrLen(A_LoopFileName    ) > MaxFilenameLength2   ? StrLen(A_LoopFileName    ) : MaxFilenameLength2
						MaxFoldernameLength2 := StrLen(A_LoopFileFullPath) > MaxFoldernameLength2 ? StrLen(A_LoopFileFullPath) : MaxFoldernameLength2
					}	

				
					; file contents
					FileRead, ThisFileContents, %A_LoopFileFullPath%
					If RegExMatch(ThisFileContents,fnSearchTerm)
					{
						Loop, Parse, ThisFileContents, `n, `r
						{
							ThisLineNum := A_Index
							ThisLine := A_LoopField
							StringReplace, ThisLine, ThisLine, %A_Tab%, %A_Space%, All
							If RegExMatch(ThisLine,fnSearchTerm)
							{
								MatchingFileContents .= A_LoopFileName "|" SubStr("00000" ThisLineNum,-4) "|" A_LoopFileFullPath "|" ThisLine "|" StrLen(A_LoopFileName) "|" A_LoopFileDir "`r`n"
								MaxFilenameLength3   := StrLen(A_LoopFileName    ) > MaxFilenameLength3   ? StrLen(A_LoopFileName    ) : MaxFilenameLength3
								MaxFoldernameLength3 := StrLen(A_LoopFileFullPath) > MaxFoldernameLength3 ? StrLen(A_LoopFileFullPath) : MaxFoldernameLength3
								MaxLineLength3       := StrLen(ThisLine          ) > MaxLineLength3       ? StrLen(ThisLine          ) : MaxLineLength3
							}							
						}
					}
				}
			}
		}
		
		
		; sort by filename
		Sort, MatchingFolderNames
		Sort, MatchingFileNames
		Sort, MatchingFileContents
		
		
		; format text
		Loop, Parse, MatchingFolderNames, `n, `r
		{
			ThisArrayLine := A_LoopField
			
			ThisFilename := ""
			ThisFileDir  := ""
			ThisFilenameLength := 0
			
			StringSplit, ThisElement, ThisArrayLine, |
			
			ThisFilename := ThisElement1
			ThisFileDir  := ThisElement2
			ThisFilenameLength := StrLen(ThisElement1)
			
			MatchingFolderNamesHTML .= "<a href=""" ThisFilepath """ title=""" ThisFilepath """>" ThisFilename "</a>" StrReplicate(" ",MaxFilenameLength1-ThisFilenameLength) "  " ThisFileDir "<br>`r`n"
		}

		Loop, Parse, MatchingFileNames, `n, `r
		{
			ThisArrayLine := A_LoopField
			
			ThisFilename := ""
			ThisFilepath := ""
			ThisFileDir  := ""
			ThisFilenameLength := 0
			
			StringSplit, ThisElement, ThisArrayLine, |
			
			ThisFilename := ThisElement1
			ThisFilepath := ThisElement2
			ThisFileDir  := ThisElement3
			ThisFilenameLength := StrLen(ThisElement1)

			MatchingFileNamesHTML .= "<a href=""" ThisFilepath """ title=""" ThisFilepath """>" ThisFilename "</a>" StrReplicate(" ",MaxFilenameLength2-ThisFilenameLength) "  " ThisFileDir "<br>`r`n"
		}

		Loop, Parse, MatchingFileContents, `n, `r
		{
			ThisArrayLine := A_LoopField

			ThisFilename       := ""
			ThisLineNum        := ""
			ThisFilepath       := ""
			ThisLine           := ""
			ThisFilenameLength := ""
			ThisFileDir        := ""
			ThisLineLength     := 0
			
			StringSplit, ThisElement, ThisArrayLine, |
			
			ThisFilename       := ThisElement1
			ThisLineNum        := ThisElement2
			ThisFilepath       := ThisElement3
			ThisLine           := Trim(ThisElement4)
			ThisFilenameLength := ThisElement5
			ThisFileDir        := ThisElement6
			
			ThisLineLength     := StrLen(ThisLine)
			ThisLine           := ReplaceHtmlDecodedChars(Trim(ThisElement4))
			ThisLine           := RegExReplace(ThisLine,fnSearchTerm,"<font color=""#9F000F""><b>$0</b></font>") ; highlight the search term in the line
			
			MatchingFileContentsHTML .= "<a href=""" ThisFilepath """ title=""" ThisFilepath """>" ThisFilename "</a>" StrReplicate(" ",MaxFilenameLength3-ThisFilenameLength) "  " ThisLineNum StrReplicate(" ",5-StrLen(ThisLineNum)) ": " ThisLine StrReplicate(" ",MaxLineLength3-ThisLineLength) "  " ThisFileDir "<br>`r`n"
			
		}
		MatchingFileContentsHTML := StrReplace(MatchingFileContentsHTML," 0000","     ")
		MatchingFileContentsHTML := StrReplace(MatchingFileContentsHTML," 000" ,"    ")
		MatchingFileContentsHTML := StrReplace(MatchingFileContentsHTML," 00"  ,"   ")
		MatchingFileContentsHTML := StrReplace(MatchingFileContentsHTML," 0"   ,"  ")
		
		
		; enclose in html tags
		PreOpenTag := "<pre><span class=""inner-pre"" style=""font-size: 11px"">"
		PreCloseTag := "</span></pre>"
		MatchingFolderNamesHTML  := PreOpenTag MatchingFolderNamesHTML  PreCloseTag
		MatchingFileNamesHTML    := PreOpenTag MatchingFileNamesHTML    PreCloseTag
		MatchingFileContentsHTML := PreOpenTag MatchingFileContentsHTML PreCloseTag
		

		; get html template
		FileRead, HTMLText, %RegExFileSearchResultsHTMLTemplate%


		; write search term to html file
		BodyText := "Search results for """ ReplaceHtmlDecodedChars(fnSearchTerm) """ in " ReplaceHtmlDecodedChars(fnSearchRootFolder) "<br><br>" ; html


		; write results to html file
		BodyText .= "<b>Matching folder names:</b>"  "<br>" MatchingFolderNamesHTML  "<br><br>"
		BodyText .= "<b>Matching file names:</b>"    "<br>" MatchingFileNamesHTML    "<br><br>"
		BodyText .= "<b>Matching file contents:</b>" "<br>" MatchingFileContentsHTML "<br><br>"
		StringReplace, BodyText, BodyText, xBodyTextx, %BodyText%
		FileAppend, %BodyText%, %RegExFileSearchResults%
		
		
		; view the results
		Run, %RegExFileSearchResults%

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
SearchTerm := "report"
SearchRootFolder := A_MyDocuments "\_nbell\_SQLScripts"
ReturnValue := RegExFileSearch(SearchTerm,SearchRootFolder)
MsgBox, RegExFileSearch`n`nReturnValue: %ReturnValue%
*/