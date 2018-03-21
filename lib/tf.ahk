/*
Name          : TF: Textfile & String Library for AutoHotkey - maintained by HugoV
Version       : 3.2
Updated       : 20 February 2010
Documentation : http://www.autohotkey.net/~hugov/tf-lib.htm (needs to be updated for v3+)
AHK Forum     : http://www.autohotkey.com/forum/viewtopic.php?p=307344#307344 (Also for examples)
Credits       : http://www.autohotkey.net/~hugov/tf-lib.htm#Credits 
History       : http://www.autohotkey.net/~hugov/tf-lib.htm#History

Structure of most functions:

TF_...(Text, other parameters)
	{
     ; get the basic data we need for further processing and returning the output: 
     TF_GetData(OW, Text, FileName)
	 ; OW = 0 Copy inputfile 
	 ; OW = 1 Overwrite inputfile
	 ; OW = 2 Return variable
	 ; Text : either contents of file or the var that was passed on
	 ; FileName : Used in case OW is 0 or 1 (=file), not used for OW=2 (variable)
    
	 ; Creates a matchlist for use in Loop below
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine)

	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			{
			...
			}
		 Else 
			{
			...
			}
		}
	 ; either copy or overwrite file or return variabla
	 Return TF_ReturnOutPut(OW, OutPut, FileName, TrimTrailing, CreateNewFile) 
	 ; OW 0 or 1 = file
	 ; Output = new content of file or var to save to file or return
	 ; FileName
	 ; TrimTrailing: because of the loops used most functions will add trailing newline, this will remove it by default
	 ; CreateNewFile: To create a file that doesn't exist this parameter is needed, only used in few functions
   }

*/

TF_CountLines(Text)
	{ 
 	 TF_GetData(OW, Text, FileName)	 
 	 StringReplace, Text, Text, `n, `n, UseErrorLevel
	 Return ErrorLevel + 1
	}

TF_ReadLines(Text, StartLine = 1, EndLine = 0, Trailing = 0)
	{
	 TF_GetData(OW, Text, FileName)	 
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			OutPut .= A_LoopField "`n"
		 Else if (A_Index => EndLine)
			Break
		}
	 OW = 2 ; make sure we return variable not process file
     	 Return TF_ReturnOutPut(OW, OutPut, FileName, Trailing)
	}


TF_ReplaceInLines(Text, StartLine = 1, EndLine = 0, SearchText = "", ReplaceText = "")
	{
 	 TF_GetData(OW, Text, FileName)
	 IfNotInString, Text, %SearchText%
	 	Return ; SearchText not in TextFile so return and do nothing
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
	 	{
      	 If A_Index in %TF_MatchList%
			{
			 StringReplace, LoopField, A_LoopField, %SearchText%, %ReplaceText%, All
			 OutPut .= LoopField "`n"
			}
		 Else
			OutPut .= A_LoopField "`n"
    		}		
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_Replace(Text, SearchText, ReplaceText="")
	{
	 TF_GetData(OW, Text, FileName)
	 IfNotInString, Text, %SearchText%
	 	Return ; SearchText not in TextFile so return and do nothing
	 Loop
		{
		 StringReplace, Text, Text, %SearchText%, %ReplaceText%, All
		 if (ErrorLevel = 0) ; No more replacements needed.
			break
		}
 	 Return TF_ReturnOutPut(OW, Text, FileName, 0)
	}

TF_RegExReplaceInLines(Text, StartLine = 1, EndLine = 0, NeedleRegEx = "", Replacement = "")
	{
	 TF_GetData(OW, Text, FileName)
	 If (RegExMatch(Text, NeedleRegEx) < 1)
	 	Return ; NeedleRegEx not in file or error, do nothing
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
         	 If A_Index in %TF_MatchList%
			{
			 LoopField := RegExReplace(A_LoopField, NeedleRegEx, Replacement)
			 OutPut .= LoopField "`n"
			}
		 Else
			OutPut .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_RegExReplace(Text, NeedleRegEx = "", Replacement = "")
	{
	 TF_GetData(OW, Text, FileName)
	 If (RegExMatch(Text, NeedleRegEx) < 1)
	 	Return ; NeedleRegEx not in file or error, do nothing
	 Text := RegExReplace(Text, NeedleRegEx, Replacement)
 	 Return TF_ReturnOutPut(OW, Text, FileName, 0)
	}

TF_RemoveLines(Text, StartLine = 1, EndLine = 0)
	{
	 TF_GetData(OW, Text, FileName)
	 If (StartLine < 0) ; remove last X lines from file, endline parameter ignored
	 	{
	 	 StartLine:=TF_CountLines(Text) + StartLine + 1
	 	 EndLine=0
	 	}
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 
	 Loop, Parse, Text, `n, `r
		{
        	 If A_Index in %TF_MatchList%
        		Continue
		 Else
        		OutPut .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_RemoveBlankLines(Text, StartLine = 1, EndLine = 0)
	{
	 TF_GetData(OW, Text, FileName)
	 If (RegExMatch(Text, "[\S]+?\r?\n?") < 1)
	 	Return ; NeedleRegEx not in file or error, do nothing
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{ 
		 	 If A_Index in %TF_MatchList%
         	 	OutPut .= (RegExMatch(A_LoopField,"[\S]+?\r?\n?")) ? A_LoopField "`n" :
	         Else
        		OutPut .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_RemoveDuplicateLines(Text, StartLine = 1, Endline = 0, Consecutive = 0, CaseSensitive = false)
	{
	 TF_GetData(OW, Text, FileName)
	 If (StartLine = "")
	        StartLine = 1
	 If (Endline = 0 OR Endline = "")
	        EndLine := TF_Count(Text, "`n") + 1
	 Loop, Parse, Text, `n, `r
		{
		 If (A_Index < StartLine)
			Section1 .= A_LoopField "`n"
		 If A_Index between %StartLine% and %Endline%
			{
			 If (Consecutive = 1)
				{
				 If (A_LoopField <> PreviousLine) ; method one for consequtive duplicate lines
					 Section2 .= A_LoopField "`n"
				 PreviousLine:=A_LoopField
				} 
			 Else
				{
				 If !(InStr(SearchForSection2,"__bol__" . A_LoopField . "__eol__",CaseSensitive)) ; not found
				 	{
				 	 SearchForSection2 .= "__bol__" A_LoopField "__eol__" ; this makes it unique otherwise it could be a partial match
					 Section2 .= A_LoopField "`n"
				 	}
				}	 
			}
		 If (A_Index > EndLine)
			Section3 .= A_LoopField "`n"
		}
	 Output .= Section1 Section2 Section3
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_InsertLine(Text, StartLine = 1, Endline = 0, InsertText = "")
	{
	 TF_GetData(OW, Text, FileName)
     TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
     Loop, Parse, Text, `n, `r
		{
         	 If A_Index in %TF_MatchList%
			Output .= InsertText "`n" A_LoopField "`n"
		 Else 
			Output .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_ReplaceLine(Text, StartLine = 1, Endline = 0, ReplaceText = "")
	{
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			Output .= ReplaceText "`n" 
		 Else 
			Output .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_InsertPrefix(Text, StartLine = 1, EndLine = 0, InsertText = "")
	{
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			OutPut .= InsertText A_LoopField "`n"
		 Else
			OutPut .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_InsertSuffix(Text, StartLine = 1, EndLine = 0 , InsertText = "")
	{
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
         	 If A_Index in %TF_MatchList%
            		OutPut .= A_LoopField InsertText "`n"
         	 Else
            		OutPut .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_TrimLeft(Text, StartLine = 1, EndLine = 0, Count = 1)
	{
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			{
       		 StringTrimLeft, StrOutPut, A_LoopField, %Count%
       		 OutPut .= StrOutPut "`n"
			}
		 Else
       		OutPut .= A_LoopField "`n"
		}		
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_TrimRight(Text, StartLine = 1, EndLine = 0, Count = 1)
	{
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
       	 If A_Index in %TF_MatchList%
			{
       		 StringTrimRight, StrOutPut, A_LoopField, %Count%
       		 OutPut .= StrOutPut "`n"
			}
      	 Else
       		OutPut .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_AlignLeft(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
	{
	 Trim:=A_AutoTrim ; store trim settings
	 AutoTrim, On ; make sure AutoTrim is on
	 TF_GetData(OW, Text, FileName)
	 If (Endline = 0 OR Endline = "")
		EndLine := TF_Count(Text, "`n") + 1
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
       	 If A_Index in %TF_MatchList%
			{
			 LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace. Trims leading and trailing spaces!
	       	 SpaceNum := Columns-StrLen(LoopField)-1 
	       	 If (SpaceNum > 0) and (Padding = 1) ; requires padding + keep padding
	        	{
				 Left:=TF_SetWidth(LoopField,Columns, 0) ; align left
		         OutPut .= Left "`n"
        		}
        	 Else 
       			OutPut .= LoopField "`n"
			}
         Else
         	OutPut .= A_LoopField "`n"
		}
	 AutoTrim, %Trim%	; restore original Trim
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_AlignCenter(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
	{
	 Trim:=A_AutoTrim ; store trim settings
	 AutoTrim, On ; make sure AutoTrim is on
	 TF_GetData(OW, Text, FileName)
    	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
     	 Loop, Parse, Text, `n, `r
			{
         	 If A_Index in %TF_MatchList%
				{
				 LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace
	         	 SpaceNum := (Columns-StrLen(LoopField)-1)/2
				 If (Padding = 1) and (LoopField = "") ; skip emtpy lines, do not fill with spaces
					{
					 OutPut .= "`n"
					 Continue
					}
				 If (StrLen(LoopField) >= Columns)
					{
					 OutPut .= LoopField "`n" ; add as is 	
					 Continue
					}
                 Centered:=TF_SetWidth(LoopField,Columns, 1) ; align center using set width
				 OutPut .= Centered "`n"
				}
         	 Else
             	OutPut .= A_LoopField "`n"
		}
	 AutoTrim, %Trim%	; restore original Trim
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_AlignRight(Text, StartLine = 1, EndLine = 0, Columns = 80, Skip = 0)
	{
	 Trim:=A_AutoTrim ; store trim settings
	 AutoTrim, On ; make sure AutoTrim is on
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
     	 Loop, Parse, Text, `n, `r
			{
         	 If A_Index in %TF_MatchList%
				{
				 LoopField = %A_LoopField% ; Make use of AutoTrim, should be faster then a RegExReplace
				 If (Skip = 1) and (LoopField = "") ; skip emtpy lines, do not fill with spaces
					{
					 OutPut .= "`n"
					 Continue
					}
				 If (StrLen(LoopField) >= Columns) 
					{
					 OutPut .= LoopField "`n" ; add as is 	
					 Continue
					}
                 Right:=TF_SetWidth(LoopField,Columns, 2) ; align right using set width
				 OutPut .= Right "`n"
				}
         	 Else
				OutPut .= A_LoopField "`n"
		}
	 AutoTrim, %Trim%	; restore original Trim
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

/*
Based on:
CONCATenate text files, ftp://garbo.uwasa.fi/pc/ts/tsfltc22.zip
*/

TF_ConCat(FirstTextFile, SecondTextFile, OutputFile = "", Blanks = 0, FirstPadMargin = 0, SecondPadMargin = 0)
	{
	 If (Blanks > 0)
      	Loop, %Blanks%
			InsertBlanks .= A_Space
	 If (FirstPadMargin > 0)
		Loop, %FirstPadMargin%
			PaddingFile1 .= A_Space
	 If (SecondPadMargin > 0)
	         Loop, %SecondPadMargin%
	 PaddingFile2 .= A_Space
	 Text:=FirstTextFile		
	 	 TF_GetData(OW, Text, FileName)
	 StringSplit, Str1Lines, Text, `n, `r
	 Text:=SecondTextFile
	 	 TF_GetData(OW, Text, FileName)
	 StringSplit, Str2Lines, Text, `n, `r
	 Text= ; clear mem

; first we need to determine the file with the most lines for our loop
	 If (Str1Lines0 > Str2Lines0)
		MaxLoop:=Str1Lines0
	 Else
		MaxLoop:=Str2Lines0
	 Loop, %MaxLoop%
		{
		 Section1:=Str1Lines%A_Index%
		 Section2:=Str2Lines%A_Index%
		 OutPut .=  Section1 PaddingFile1 InsertBlanks Section2 PaddingFile2 "`n"
		 Section1= ; otherwise it will remember the last line from the shortest file or var
		 Section2=
		}
	 OW=1 ; it is probably 0 so in that case it would create _copy, so set it to 1
	 If (OutPutFile = "") ; if OutPutFile is empty return as variable
		OW=2
	 Return TF_ReturnOutPut(OW, OutPut, OutputFile, 1, 1)
   	}

TF_LineNumber(Text, Leading = 0, Restart = 0, Char = 0) ; Hugov / ribbet.1
	{
	 global t
	 TF_GetData(OW, Text, FileName)
	 Lines:=TF_Count(Text, "`n") + 1
	 Padding:=StrLen(Lines)
	 If (Leading = 0) and (Char = 0)
		Char := A_Space
         Loop, %Padding%
        	PadLines .= Char
	 Loop, Parse, Text, `n
		{
       	 If Restart = 0
       		MaxNo = %A_Index%
		 Else
			{
			 MaxNo++
			 If MaxNo > %Restart%
				MaxNo = 1
			}
		 LineNumber:= MaxNo
		 If (Leading = 1)
			{
			 LineNumber := Padlines LineNumber  ; add padding
			 StringRight, LineNumber, LineNumber, StrLen(Lines) ; remove excess padding
			}
		 If (Leading = 0)
			{
			 LineNumber := LineNumber Padlines ; add padding
			 StringLeft, LineNumber, LineNumber, StrLen(Lines) ; remove excess padding
			}         
		 OutPut .= LineNumber A_Space A_LoopField "`n"
		}
     Return TF_ReturnOutPut(OW, OutPut, FileName)
   }

; skip = 1, skip shorter lines (e.g. lines shorter startcolumn position)
TF_ColGet(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1, Skip = 0)
	{ 
	 TF_GetData(OW, Text, FileName)
	 EndColumn:=(EndColumn+1)-StartColumn
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			{
		     StringMid, Section, A_LoopField, StartColumn, EndColumn
			 If (Skip = 1) and (StrLen(A_LoopField) < StartColumn)
		        Continue
	         OutPut .= Section "`n"               
			}
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
}


/*
Based on:
COLPUT.EXE & CUT.EXE, ftp://garbo.uwasa.fi/pc/ts/tsfltc22.zip
*/
TF_ColPut(Text, Startline = 1, EndLine = 0, StartColumn = 1, InsertText = "", Skip = 0)
	{ 
	 TF_GetData(OW, Text, FileName)
	 StartColumn--
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			{
			 StringLeft, Section1, A_LoopField, StartColumn
			 StringMid, Section2, A_LoopField, StartColumn+1
			 If (Skip = 1) and (StrLen(A_LoopField) < StartColumn)
                OutPut .= Section1 Section2 "`n"
			 Else
                OutPut .= Section1 InsertText Section2 "`n"
			}
		 Else
			OutPut .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_ColCut(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1)
	{
	 StartColumn--
	 EndColumn++
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			{
			 StringLeft, Section1, A_LoopField, StartColumn
			 StringMid, Section2, A_LoopField, EndColumn
			 OutPut .= Section1 Section2 "`n"
			}
		 Else
			OutPut .= A_LoopField "`n"
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}


TF_ReverseLines(Text, StartLine = 1, EndLine = 0)
	{
	 TF_GetData(OW, Text, FileName)
	 StringSplit, Line, Text, `n, `r ; line0 is number of lines
	 If (EndLine = 0 OR EndLine = "")
		EndLine:=Line0
	 If (EndLine > Line0)
		EndLine:=Line0
	 CountDown:=EndLine+1
	 Loop, Parse, Text, `n, `r
		{
		 If (A_Index < StartLine)
			Output1 .= A_LoopField "`n" ; section1
	 	 If A_Index between %StartLine% and %Endline%
			{
			 CountDown--
			 Output2 .= Line%CountDown% "`n" section2
			}
		 If (A_Index > EndLine)
			 Output3 .= A_LoopField "`n"
		}
	 OutPut.= Output1 Output2 Output3
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}



;TF_SplitFileByLines
;example:
;TF_SplitFileByLines("TestFile.txt", "4", "sfile_", "txt", "1") ; split file every 3 lines
; InFile = 0 skip line e.g. do not include the actual line in any of the output files
; InFile = 1 include line IN current file
; InFile = 2 include line IN next file

TF_SplitFileByLines(Text, SplitAt, Prefix = "file", Extension = "txt", InFile = 1)
	{
	 LineCounter=1
	 FileCounter=1
	 Where:=SplitAt
	 Method=1 
	 ; 1 = default, splitat every X lines, 
	 ; 2 = splitat: - rotating if applicable 
	 ; 3 = splitat: specific lines comma separated
	 TF_GetData(OW, Text, FileName)
	 
	 IfInString, SplitAt, `- ; method 2
		{
		 StringSplit, Split, SplitAt, `-
		 Part=1
		 Where:=Split%Part%
		 Method=2
		} 
	 IfInString, SplitAt, `, ; method 3
		{
		 StringSplit, Split, SplitAt, `,
		 Part=1
		 Where:=Split%Part%
		 Method=3
		} 
	 Loop, Parse, Text, `n, `r
		{
		 OutPut .= A_LoopField "`n"
         	 If (LineCounter = Where)
			{
			 If (InFile = 0)
				{
				 StringReplace, CheckOutput, PreviousOutput, `n, , All
				 StringReplace, CheckOutput, CheckOutput, `r, , All
				 If (CheckOutput <> "") and (OW <> 2) ; skip empty files
				   	 TF_ReturnOutPut(1, PreviousOutput, Prefix FileCounter "." Extension, 0, 1) 
				 If (CheckOutput <> "") and (OW = 2) ; skip empty files
					 TF_SetGlobal(Prefix FileCounter,PreviousOutput)
         		 Output:=
           		}
       		 If (InFile = 1)
			{
			 StringReplace, CheckOutput, Output, `n, , All
			 StringReplace, CheckOutput, CheckOutput, `r, , All
			 If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                  		 TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1) 
			 If (CheckOutput <> "") and (OW = 2) ; skip empty files
				 TF_SetGlobal(Prefix FileCounter,Output)
			 Output:=
                	}
             	If (InFile = 2)
			{
			 OutPut := PreviousOutput
			 StringReplace, CheckOutput, Output, `n, , All
			 StringReplace, CheckOutput, CheckOutput, `r, , All
			 If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                  		 TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1) 
			 If (CheckOutput <> "") and (OW = 2) ; skip empty files
				 TF_SetGlobal(Prefix FileCounter,Output)
			 OutPut := A_LoopField "`n"
			}
	     If (Method <> 3)			
             	LineCounter=0 ; reset
             FileCounter++ ; next file
			 Part++
			 If (Method = 2) ; 2 = splitat: - rotating if applicable 
			 	{
			 	 If (Part > Split0)
			 	    {
			 	     Part=1
			 	    }
		 	 	 Where:=Split%Part%
			 	}
			 If (Method = 3) ; 3 = splitat: specific lines comma separated
			 	{
			 	 If (Part > Split0)
			 	 	Where:=Split%Split0%
			 	 Else
			 	 	Where:=Split%Part%
			 	}
			}
		 LineCounter++
		 PreviousOutput:=Output
		 PreviousLine:=A_LoopField
		}
	 StringReplace, CheckOutput, Output, `n, , All
	 StringReplace, CheckOutput, CheckOutput, `r, , All
	 If (CheckOutPut <> "") and (OW <> 2) ; skip empty files
       	 TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1) 
	 If (CheckOutput <> "") and (OW = 2) ; skip empty files
		{
		 TF_SetGlobal(Prefix FileCounter,Output)
		 TF_SetGlobal(Prefix . "0" , FileCounter)
		} 
	}

; TF_SplitFileByText("TestFile.txt", "button", "sfile_", "txt") ; split file at every line with button in it, can be regexp
; InFile = 0 skip line e.g. do not include the actual line in any of the output files
; InFile = 1 include line IN current file
; InFile = 2 include line IN next file

TF_SplitFileByText(Text, SplitAt, Prefix = "file", Extension = "txt",  InFile = 1)
	{
	 LineCounter=1
	 FileCounter=1
	 TF_GetData(OW, Text, FileName)
	 SplitPath, TextFile,, Dir
	 Loop, Parse, Text, `n, `r
		{
         	 OutPut .= A_LoopField "`n"
         	 FoundPos:=RegExMatch(A_LoopField, SplitAt)
         	 If (FoundPos > 0)
           		{
			 If (InFile = 0)
				{
				 StringReplace, CheckOutput, PreviousOutput, `n, , All
				 StringReplace, CheckOutput, CheckOutput, `r, , All
				 If (CheckOutput <> "") and (OW <> 2) ; skip empty files
				   	 TF_ReturnOutPut(1, PreviousOutput, Prefix FileCounter "." Extension, 0, 1) 
				 If (CheckOutput <> "") and (OW = 2) ; skip empty files
					 TF_SetGlobal(Prefix FileCounter,PreviousOutput)
					Output:=
           		}
       		 If (InFile = 1)
				{
				 StringReplace, CheckOutput, Output, `n, , All
				 StringReplace, CheckOutput, CheckOutput, `r, , All
				 If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                  	 TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1) 
				 If (CheckOutput <> "") and (OW = 2) ; skip empty files
					 TF_SetGlobal(Prefix FileCounter,Output)
				 Output:=
           		}
			 If (InFile = 2)
				{
				 OutPut := PreviousOutput
				 StringReplace, CheckOutput, Output, `n, , All
				 StringReplace, CheckOutput, CheckOutput, `r, , All
				 If (CheckOutput <> "") and (OW <> 2) ; skip empty files
                  	 TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1) 
				 If (CheckOutput <> "") and (OW = 2) ; skip empty files
					 TF_SetGlobal(Prefix FileCounter,Output)
				 OutPut := A_LoopField "`n"
				}
       		 LineCounter=0 ; reset
       		 FileCounter++ ; next file
			}
		 LineCounter++
		 PreviousOutput:=Output
		 PreviousLine:=A_LoopField
		}
	 StringReplace, CheckOutput, Output, `n, , All
	 StringReplace, CheckOutput, CheckOutput, `r, , All
	 If (CheckOutPut <> "") and (OW <> 2) ; skip empty files
       	 TF_ReturnOutPut(1, Output, Prefix FileCounter "." Extension, 0, 1) 
	 If (CheckOutput <> "") and (OW = 2) ; skip empty files
		{
		 TF_SetGlobal(Prefix FileCounter,Output)
		 TF_SetGlobal(Prefix . "0" , FileCounter)
		} 
	}



TF_Find(Text, StartLine = 1, EndLine = 0, SearchText = "", ReturnFirst = 1, ReturnText = 0)
	{ ; complete rewrite for 3.1
	 TF_GetData(OW, Text, FileName)
	 If (RegExMatch(Text, SearchText) < 1)
	 	Return "0" ; SearchText not in file or error, do nothing
     	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Loop, Parse, Text, `n
		{
		 If A_Index in %TF_MatchList%
		 	{
			 If (RegExMatch(A_LoopField, SearchText) > 0)
				{
				 If (ReturnText = 0)
					Lines .= A_Index "," ; line number
				 Else If (ReturnText = 1)
					Lines .= A_LoopField "`n" ; text of line 
				 Else If (ReturnText = 2)
					Lines .= A_Index ": " A_LoopField "`n" ; add line number
				 If (ReturnFirst = 1) ; only return first occurence
					Break
				}	
		 	}	
		}
	 If (Lines <> "")
		StringTrimRight, Lines, Lines, 1 ; trim trailing , or `n
	 Else
		Lines = 0 ; make sure we return 0
	 Return Lines
	}


TF_FindLines(Text, StartLine = 1, EndLine = 0, SearchText = "", CaseSensitive = false)
	{
	 Return TF_Find(Text, StartLine, EndLine, SearchText, 0)
	}

TF_Prepend(File1, File2)
	{
FileList=
(
%File1%
%File2%
)
TF_Merge(FileList,"`n", "!" . File2)
Return
	}

TF_Append(File1, File2)
	{
FileList=
(
%File2%
%File1%
)
TF_Merge(FileList,"`n", "!" . File2)
Return
	}

; You will need to create a Filelist variable, one file per line, to pass on to the function:
; FileList=
; (
; c:\file1.txt
; c:\file2.txt
; )
; use Loop (files & folders) to create one quickly if you want to merge all TXT files for example
;
; Loop, c:\*.txt
;   FileList .= A_LoopFileFullPath "`n"
;
; By default, a new line is used as a separator between two text files
; !merged.txt deletes target file before starting to merge files

TF_Merge(FileList, Separator = "`n", FileName = "merged.txt") 
	{
	 OW=0
	 Loop, Parse, FileList, `n, `r
		{
		 Append2File= ; Just make sure it is empty
		 IfExist, %A_LoopField%
			{
			 FileRead, Append2File, %A_LoopField%
			 If not ErrorLevel  ; Successfully loaded
				Output .= Append2File Separator
			}
		}
	 If (SubStr(FileName,1,1)="!") ; check if we want to delete the target file before we start
		{
		 FileName:=SubStr(FileName,2)
		 OW=1	 
		}
	 Return TF_ReturnOutPut(OW, OutPut, FileName, 0, 1)
	}

; Wrap file or specified lines, by HugoV
TF_Wrap(Text, Columns = 80, AllowBreak = 0, StartLine = 1, EndLine = 0)
	{
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 If (AllowBreak = 1)
	 	Break=
	 Else
	 	Break=[ \r?\n]
	 Loop, Parse, Text, `n, `r
	 	{
		 If A_Index in %TF_MatchList%
		 	{
			 If (StrLen(A_LoopField) > Columns)
				{
				 LoopField := A_LoopField " " ; just seems to work better by adding a space
				 OutPut .= RegExReplace(LoopField, "(.{1," . Columns . "})" . Break , "$1`n")
				}
			 Else
				OutPut .= A_LoopField "`n"
			}	
		  Else
			 OutPut .= A_LoopField "`n"
		}		
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

TF_WhiteSpace(Text, RemoveLeading = 1, RemoveTrailing = 1, StartLine = 1, EndLine = 0) {
	 TF_GetData(OW, Text, FileName)
	 TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine) ; create MatchList
	 Trim:=A_AutoTrim ; store trim settings
	 AutoTrim, On ; make sure AutoTrim is on
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			{
			 If (RemoveLeading = 1) AND (RemoveTrailing = 1)
			 	{
				 LoopField = %A_LoopField%
				 Output .= LoopField "`n"
			         Continue
			 	}
			 If (RemoveLeading = 1) AND (RemoveTrailing = 0)
			 	{
				 LoopField := A_LoopField . "."
				 LoopField = %LoopField%
				 StringTrimRight, LoopField, LoopField, 1
				 Output .=  LoopField "`n"
			         Continue
			 	}
			 If (RemoveLeading = 0) AND (RemoveTrailing = 1)
			 	{
				 LoopField := "." A_LoopField
				 LoopField = %LoopField%
				 StringTrimLeft, LoopField, LoopField, 1
				 Output .= LoopField "`n"
			         Continue
			 	}
			 If (RemoveLeading = 0) AND (RemoveTrailing = 0)
			 	{
				 Output .= A_LoopField "`n"
			         Continue
			 	}
		 	}
		 Else
		 	Output .= A_LoopField "`n"
		}
	AutoTrim, %Trim%	; restore original Trim
	Return TF_ReturnOutPut(OW, OutPut, FileName)
}

; Delete lines from file1 in file2 (using StringReplace) by HugoV
TF_Substract(File1, File2, PartialMatch = 0) {
	Text:=File1
 	 TF_GetData(OW, Text, FileName)
	Str1:=Text
	Text:=File2
 	 TF_GetData(OW, Text, FileName)
    OutPut:=Text
	 If (OW = 2)
		File1= ; free mem in case of var/text
	 OutPut .= "`n" ; just to make sure the StringReplace will work

	If (PartialMatch = 1) ; allow paRTIal match
		{
		 Loop, Parse, Str1, `n, `r
		 	StringReplace, Output, Output, %A_LoopField%, , All ; remove lines from file1 in file2
		}
	Else
		{ 
		 search:="m)^(.*)$"
		 replace=__bol__$1__eol__
		 Output:=RegExReplace(Output, search, replace)
		 StringReplace, Output, Output, `n__eol__,__eol__ , All ; strange fix but seems to be needed.
		 Loop, Parse, Str1, `n, `r
		 	StringReplace, Output, Output, __bol__%A_LoopField%__eol__, , All ; remove lines from file1 in file2
		}	
	If (PartialMatch = 0)
		{
		  StringReplace, Output, Output, __bol__, , All
		  StringReplace, Output, Output, __eol__, , All
		}
		
	; Remove all blank lines from the text in a variable:
	Loop
	{
	    StringReplace, Output, Output, `r`n`r`n, `r`n, UseErrorLevel
	    if (ErrorLevel = 0) or (ErrorLevel = 1) ; No more replacements needed.
	        break
	}	
	Return TF_ReturnOutPut(OW, OutPut, FileName, 0)
}

; Similar to "BK Replace EM" RangeReplace
TF_RangeReplace(Text, SearchTextBegin, SearchTextEnd, ReplaceText = "", CaseSensitive = "False", KeepBegin = 0, KeepEnd = 0)
	{
	 TF_GetData(OW, Text, FileName)
	 IfNotInString, Text, %SearchText%
	 	Return ; SearchTextBegin not in TextFile so return and do nothing
     	 Start = 0
     	 End = 0
     	 If (KeepBegin = 1)
     		KeepBegin:=SearchTextBegin
     	 Else
		KeepBegin=
     	 If (KeepEnd = 1)
     		KeepEnd:= SearchTextEnd
     	 Else
		KeepEnd=
         If (SearchTextBegin = "")
      		Start=1
    	 If (SearchTextEnd = "")
      		End=2
    
	 Loop, Parse, Text, `n, `r
	 	{
		 If (End = 1) ; end has been found already, replacement made simply continue to add all lines
	 		{
			 Output .= A_LoopField "`n"
        		 Continue
	 		}
		 If (Start = 0) ; start hasn't been found
		 	{
		 	 If (InStr(A_LoopField,SearchTextBegin,CaseSensitive)) ; start has been found
	 			{
		 		 Start = 1
		 		 KeepSection := SubStr(A_LoopField, 1, InStr(A_LoopField, SearchTextBegin)-1) 
		 		 EndSection := SubStr(A_LoopField, InStr(A_LoopField, SearchTextBegin)-1) 
		 		 ; check if SearchEndText is in second part of line
		 		 If (InStr(EndSection,SearchTextEnd,CaseSensitive)) ; end found
		 		 	{
		 		 	 EndSection := ReplaceText KeepEnd SubStr(EndSection, InStr(EndSection, SearchTextEnd) + StrLen(SearchTextEnd) ) "`n"
		 		 	 If (End <> 2)	
		 		 	 	End=1
		 		 	 If (End = 2)	
		 		 	 	EndSection=
		 		 	}
		 		 Else
	 		 		EndSection=
		 		 Output .= KeepSection KeepBegin EndSection
				 Continue
	 			}
		 	 Else	
		 		Output .= A_LoopField "`n" ; if not found yet simply add
	         	}
		 If (Start = 1) and (End <> 2) ; start has been found, now look for end if end isn't an empty string
			{
		 	 If (InStr(A_LoopField,SearchTextEnd,CaseSensitive)) ; end found
		 		{
			 	 End = 1
				 Output .= ReplaceText KeepEnd SubStr(A_LoopField, InStr(A_LoopField, SearchTextEnd) + StrLen(SearchTextEnd) ) "`n"
			 	}
        		}
		}   
	 If (End = 2)	
	 	Output .= ReplaceText
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}

; Create file of X lines and Y columns, fill with space or other character(s)
TF_MakeFile(Text, Lines = 1, Columns = 1, Fill = " ")
	{
	 OW=1
 	 If (Text = "") ; if OutPutFile is empty return as variable
		OW=2
	 Loop, % Columns
		Cols .= Fill
	 Loop, % Lines
		Output .= Cols "`n"
	 Return TF_ReturnOutPut(OW, OutPut, Text, 1, 1)	
	}

; Convert tabs to spaces, shorthand for TF_ReplaceInLines
TF_Tab2Spaces(Text, TabStop = 4, StartLine = 1, EndLine =0)
	{
	Loop, % TabStop
		Replace .= A_Space
	Return TF_ReplaceInLines(Text, StartLine, EndLine, A_Tab, Replace)
	}

; Convert spaces to tabs, shorthand for TF_ReplaceInLines
TF_Spaces2Tab(Text, TabStop = 4, StartLine = 1, EndLine =0)
	{
	Loop, % TabStop
		Replace .= A_Space
	Return TF_ReplaceInLines(Text, StartLine, EndLine, Replace, A_Tab)
	}

; Sort (section of) text file
TF_Sort(Text, SortOptions = "", StartLine = 1, EndLine = 0) ; use the SORT options http://www.autohotkey.com/docs/commands/Sort.htm
	{
	 TF_GetData(OW, Text, FileName)
	 If StartLine contains -,+,`, ; no sections, incremental or multiple line input
		Return
	 If (StartLine = 1) and (Endline = 0) ; process entire file
		{
		 Output:=Text
	 	 Sort, Output, %SortOptions%
	 	}
	 Else
	 	{
	 	 Output := TF_ReadLines(Text, 1, StartLine-1) ; get first section
	 	 ToSort := TF_ReadLines(Text, StartLine, EndLine) ; get section to sort
	 	 Sort, ToSort, %SortOptions%
	 	 OutPut .= ToSort
	 	 OutPut .= TF_ReadLines(Text, EndLine+1) ; append last section
	 	} 
	 Return TF_ReturnOutPut(OW, OutPut, FileName)
	}


TF_Tail(Text, Lines = 1, RemoveTrailing = 0, ReturnEmpty = 1)
  {
    TF_GetData(OW, Text, FileName)
    Neg = 0
    If (Lines < 0)
      {
        Neg=1
        Lines:= Lines * -1
      }
    If (ReturnEmpty = 0) ; remove blank lines first so we can't return any blank lines anyway
      {
       Loop, Parse, Text, `n, `r
            OutPut .= (RegExMatch(A_LoopField,"[\S]+?\r?\n?")) ? A_LoopField "`n" :
	   StringTrimRight, OutPut, OutPut, 1 ; remove trailing `n added by loop above
	   Text:=OutPut
	   OutPut=
      }
    If (Neg = 1) ; get only one line!
      { 
        Lines++
		Output:=Text
        StringGetPos, Pos, Output, `n, R%Lines% ; These next two Lines by Tuncay see
        StringTrimLeft, Output, Output, % ++Pos ; http://www.autoHotkey.com/forum/viewtopic.php?p=262375#262375
        StringGetPos, Pos, Output, `n
		StringLeft, Output, Output, % Pos
		Output .= "`n"
      }
    Else
      {
	Output:=Text
        StringGetPos, Pos, Output, `n, R%Lines% ; These next two Lines by Tuncay see
        StringTrimLeft, Output, Output, % ++Pos ; http://www.autoHotkey.com/forum/viewtopic.php?p=262375#262375
	Output .= "`n"
      }
    OW = 2 ; make sure we return variable not process file
    Return TF_ReturnOutPut(OW, OutPut, FileName, RemoveTrailing)
  }

TF_Count(String, Char)
	{
	StringReplace, String, String, %Char%,, UseErrorLevel
	Return ErrorLevel
	}

TF_Save(Text, FileName, OverWrite = 1) { ; HugoV write file
	Return TF_ReturnOutPut(OverWrite, Text, FileName, 0, 1)
	}

TF(TextFile, CreateGlobalVar = "T") { ; read contents of file in output and %output% as global var ...  http://www.autohotkey.com/forum/viewtopic.php?p=313120#313120
	 global
	 FileRead, %CreateGlobalVar%, %TextFile%
	 Return, (%CreateGlobalVar%)
	}

;----- Helper functions ----------------
	
TF_SetGlobal(var, content = "") ; helper function for TF_Split* to return array and not files, credits Tuncay :-)
	{
     global
     %var% := content
	}
	
; HugoV, helper function to determine if VAR/TEXT or FILE is passed to TF
; Update 11 January 2010 (skip filecheck if `n in Text -> can't be file)
TF_GetData(byref OW, byref Text, byref FileName) 
	{
	OW=0 ; default setting: asume it is a file and create file_copy
	IfNotInString, Text, `n ; it can be a file as the Text doesn't contact a newline character
		{
		 If (SubStr(Text,1,1)="!") ; first we check for "overwrite" 
			{
			 Text:=SubStr(Text,2)
			 OW=1 ; overwrite file (if it is a file)
			} 
		 IfNotExist, %Text% ; now we can check if the file exists, it doesn't so it is a var
		 {
		  If (OW=1) ; the variable started with a ! so we need to put it back because it is variable/text not a file
			Text:= "!" . Text
		  OW=2 ; no file, so it is a var or Text passed on directly to TF
		 }
		}
	Else ; there is a newline character in Text so it has to be a variable 
		{
		 OW=2
		}
    If (OW = 0) or (OW = 1) ; it is a file, so we have to read into var Text
		{
	 	 Text := (SubStr(Text,1,1)="!") ? (SubStr(Text,2)) : Text
		 FileName=%Text% ; Store FileName
		 FileRead, Text, %Text% ; Read file and return as var Text
		 If (ErrorLevel > 0)
			{
	 		 MsgBox, 48, TF Lib Error, % "Can not read " FileName
			 ExitApp
			}
		}
	Return
	}
	
	
; Skan
; http://www.autohotkey.com/forum/viewtopic.php?p=45880#45880
; SetWidth() : SetWidth increases a String's length by adding spaces to it and aligns it Left/Center/Right. ( Requires Space() ) 

TF_SetWidth(Text,Width,AlignText)
	{
	 If (AlignText!=0 and AlignText!=1 and AlignText!=2)
		AlignText=0
	 If AlignText=0         
		{
		 RetStr= % (Text)TF_Space(Width)
		 StringLeft, RetText, RetText, %Width%
		}
	 If AlignText=1         
		{
		 Spaces:=(Width-(StrLen(Text)))
		 RetStr= % TF_Space(Round(Spaces/2))(Text)TF_Space(Spaces-(Round(Spaces/2)))
		}
	 If AlignText=2         
		{
		 RetStr= % TF_Space(Width)(Text)
		 StringRight, RetStr, RetStr, %Width%
		}
	 Return RetStr
	}

; Skan
; http://www.autohotkey.com/forum/viewtopic.php?p=45880#45880

TF_Space(Width)
	{
	 Loop,%Width%
	 Space=% Space Chr(32)
	 Return Space
	}
	
TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0) { ; HugoV
	If (OW = 0) ; input was file, file_copy will be created, if it already exist file_copy will be overwritten
		{
		 IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
		 	{
		 	 If (CreateNewFile = 1) ; CreateNewFile used for TF_SplitFileBy* and others
				{
				 OW = 1 
		 		 Goto CreateNewFile
				}
			 Else 
				Return
			}
		 If (TrimTrailing = 1)
			 StringTrimRight, Text, Text, 1 ; remove trailing `n
		SplitPath, FileName,, Dir, Ext, Name
		 If (Dir = "") ; if Dir is empty Text & script are in same directory
			Dir := A_ScriptDir
		 IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
			FileCopy, % Dir "\" Name "_copy." Ext, % Dir "\backup\" Name "_copy.bak", 1
		 FileDelete, % Dir "\" Name "_copy." Ext
		 FileAppend, %Text%, % Dir "\" Name "_copy." Ext
		 Return Errorlevel ? False : True
		}
	 CreateNewFile:	
	 If (OW = 1) ; input was file, will be overwritten by output 
		{
		 IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
		 	{
		 	If (CreateNewFile = 0) ; CreateNewFile used for TF_SplitFileBy* and others
		 		Return
			}
		 If (TrimTrailing = 1)
			 StringTrimRight, Text, Text, 1 ; remove trailing `n
		 SplitPath, FileName,, Dir, Ext, Name
		 If (Dir = "") ; if Dir is empty Text & script are in same directory
			Dir := A_ScriptDir
		 IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
			FileCopy, % Dir "\" Name "." Ext, % Dir "\backup\" Name ".bak", 1
		 FileDelete, % Dir "\" Name "." Ext
		 FileAppend, %Text%, % Dir "\" Name "." Ext
		 Return Errorlevel ? False : True
		}
	If (OW = 2) ; input was var, return variable 
		{
		 If (TrimTrailing = 1)
			StringTrimRight, Text, Text, 1 ; remove trailing `n
		 Return Text
		}
	}


; _MakeMatchList by HugoV
; Purpose:
; Make a MatchList which is used in various functions
; Using a MatchList gives greater flexibility so you can process multiple
; sections of lines in one go avoiding repetitive fileread/append actions

_MakeMatchList(Text, Start = 1, End = 0)
	{
	ErrorList=
	 (join|
	 Error 01: Invalid StartLine parameter (non numerical character)
	 Error 02: Invalid EndLine parameter (non numerical character)
	 Error 03: Invalid StartLine parameter (only one + allowed)
	 )
	 StringSplit, ErrorMessage, ErrorList, |
	 Error = 0
	 
 	 TF_MatchList= ; just to be sure
	 If (Start = 0 or Start = "")
		Start = 1
		
	 ; some basic error checking
	 
	 ; error: only digits - and + allowed
	 If (RegExReplace(Start, "[ 0-9+\-\,]", "") <> "")
		 Error = 1
		 
	 If (RegExReplace(End, "[0-9 ]", "") <> "")
		 Error = 2

	 ; error: only one + allowed
	 If (TF_Count(Start,"+") > 1)
		 Error = 3
	 	
	 If (Error > 0 )
		{
		 MsgBox, 48, TF Lib Error, % ErrorMessage%Error%
		 ExitApp
		}
		
 	 ; Option #1
	 ; StartLine has + character indicating startline + incremental processing. 
	 ; EndLine will be used
	 ; Make TF_MatchList
 
	 IfInString, Start, `+ 
		{
		 If (End = 0 or End = "") ; determine number of lines
			End:= TF_Count(Text, "`n") + 1
		 StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
		 Loop, %Section0%
			{
			 StringSplit, SectionLines, Section%A_Index%, `+
			 LoopSection:=End + 1 - SectionLines1
			 Counter=0
	         	 TF_MatchList .= SectionLines1 ","
			 Loop, %LoopSection%
				{
				 If (A_Index >= End) ; 
					Break
				 If (Counter = (SectionLines2-1)) ; counter is smaller than the incremental value so skip
					{
					 TF_MatchList .= (SectionLines1 + A_Index) ","
					 Counter=0
					}
				 Else
					Counter++
				}
			}
		 StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing , 
		 Return TF_MatchList
		}

	 ; Option #2
	 ; StartLine has - character indicating from-to, COULD be multiple sections. 
	 ; EndLine will be ignored
	 ; Make TF_MatchList

	 IfInString, Start, `-
		{
		 StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
		 Loop, %Section0%
			{
			 StringSplit, SectionLines, Section%A_Index%, `-
			 LoopSection:=SectionLines2 + 1 - SectionLines1
			 Loop, %LoopSection%
				{
				 TF_MatchList .= (SectionLines1 - 1 + A_Index) ","
				}
			}
		 StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
		 Return TF_MatchList
		}

	 ; Option #3
	 ; StartLine has comma indicating multiple lines. 
	 ; EndLine will be ignored
	 IfInString, Start, `,
		{
		 TF_MatchList:=Start
		 Return TF_MatchList
		}

	 ; Option #4
	 ; parameters passed on as StartLine, EndLine. 
	 ; Make TF_MatchList from StartLine to EndLine

	 If (End = 0 or End = "") ; determine number of lines
			End:= TF_Count(Text, "`n") + 1
	 LoopTimes:=End-Start
	 Loop, %LoopTimes%
		{	
		 TF_MatchList .= (Start - 1 + A_Index) ","
		}
	 TF_MatchList .= End ","
	 StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
	 Return TF_MatchList
	}

/* -------------- */
