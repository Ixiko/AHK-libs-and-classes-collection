VerticalTextAlign(ByRef fnSqlText) {
	; aligns text vertically on spaces
	; MsgBox fnSqlText: %fnSqlText%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success

		; validate parameters
		If !fnSqlText
			Throw, Exception("fnSqlText was empty")

		; initialise variables
		BatchLines := A_BatchLines

		; set this thread for max speed
		SetBatchLines, -1

		; remove trailing CR LF characters
		StringRight, TrailingLF, fnSqlText, 2
		If (TrailingLF = "`r`n")
			StringTrimRight, fnSqlText, fnSqlText, 2

		; find first space position of each line, and max value for all lines
		MaxFirstSpace := 0
		Loop, Parse, fnSqlText, `n, `r ; parse line by line
		{
			ThisLine := A_LoopField

			; add placeholders for case statements
			If RegExMatch(ThisLine,"CASE.*WHEN.*THEN.*END")
			{
				FirstCasePosn := InStr(ThisLine,"CASE")
				LastEndPosn   := InStr(ThisLine,"END")
				StringL := SubStr(ThisLine,1,FirstCasePosn-1)
				StringM := SubStr(ThisLine,FirstCasePosn,(LastEndPosn+3)-FirstCasePosn)
				StringR := SubStr(ThisLine,LastEndPosn+3)
				ThisLine := StringL StrReplace(StringM,A_Space,"§") StringR ; add placeholders for spaces
			}

			StringReplace, ThisLine, ThisLine, % "'" A_Space A_Space "'", % "'¢¢'", All ; replace quoted double space (temp workaround)
			ThisLine := RegExReplace(ThisLine,"[ \t]+"," ") ; remove multiple white space
			ThisFirstSpace := InStr(ThisLine,A_Space,,,1) ; find position of first space
			ThisFirstSpace := ThisFirstSpace ? ThisFirstSpace : StrLen(ThisLine)+1 ; if no spaces in string, first character after end of string
			MaxFirstSpace := ThisFirstSpace > MaxFirstSpace ? ThisFirstSpace : MaxFirstSpace ; get max position of first space
			StringReplace, ThisLine, ThisLine, % "'¢¢'", % "'" A_Space A_Space "'", All ; restore quoted double space (temp workaround)
			LineCount := A_Index ; count number of loops
			LineOriginal%A_Index% := ThisLine
			FirstSpace%A_Index% := ThisFirstSpace
		}


		; space the lines appropriately
		Loop, %LineCount%
		{
			ThisFirstSpace := FirstSpace%A_Index%

			SpacesForReplace := StrReplicate(A_Space,MaxFirstSpace-ThisFirstSpace+1)

			StringReplace, ThisLineSpaced, LineOriginal%A_Index%, %A_Space%, %SpacesForReplace%, 0 ; replace the first space with enough to make the same as max spaces
			StringReplace, ThisLineSpaced, ThisLineSpaced, §, %A_Space%, All ; replace placeholders

			; align NULLs against NOT NULLs
			StringReplace, ThisLineSpaced, ThisLineSpaced, datetime, datextime, all ; workaround because RegEx does not seem to like the string "datetime"
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( (big|small|tiny)?int             )(\s+)?(NULL)", "$1$3    $4") ; bigint,int,smallint,tinyint
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( (var)?binary                     )(\s+)?(NULL)", "$1$3    $4") ; binary,varbinary
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( bit                              )(\s+)?(NULL)", "$1$2    $3") ; bit
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( n?(var)?char([(](\d*|max)[)])?   )(\s+)?(NULL)", "$1$5    $6") ; char,nchar,nvarchar,varchar
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( date                             )(\s+)?(NULL)", "$1$2    $3") ; date
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( time                             )(\s+)?(NULL)", "$1$2    $3") ; time
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( timestamp                        )(\s+)?(NULL)", "$1$2    $3") ; timestamp
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( smalldatextime                   )(\s+)?(NULL)", "$1$2    $3") ; smalldatetime
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( datextime(2|offset)?([(]\d*[)])? )(\s+)?(NULL)", "$1$4    $5") ; datetime,datetime2,datetimeoffset
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( geo(graph|metr)y                 )(\s+)?(NULL)", "$1$3    $4") ; geography,geometry
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( (small)?money                    )(\s+)?(NULL)", "$1$3    $4") ; money,smallmoney
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( n?text                           )(\s+)?(NULL)", "$1$2    $3") ; text,ntext
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( decimal([(]\d*[,]\d*[)])?        )(\s+)?(NULL)", "$1$3    $4") ; decimal
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( float([(]\d*[,]\d*[)])?          )(\s+)?(NULL)", "$1$3    $4") ; float
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( numeric([(]\d*[,]\d*[)])?        )(\s+)?(NULL)", "$1$3    $4") ; numeric
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( real([(]\d*[,]\d*[)])?           )(\s+)?(NULL)", "$1$3    $4") ; real
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( hierarchyid                      )(\s+)?(NULL)", "$1$2    $3") ; hierarchyid
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( image                            )(\s+)?(NULL)", "$1$2    $3") ; image
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( sql_variant                      )(\s+)?(NULL)", "$1$2    $3") ; sql_variant
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( sysname                          )(\s+)?(NULL)", "$1$2    $3") ; sysname
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( uniqueidentifier                 )(\s+)?(NULL)", "$1$2    $3") ; uniqueidentifier
			ThisLineSpaced := RegExReplace(ThisLineSpaced, "xiS)^( xml                              )(\s+)?(NULL)", "$1$2    $3") ; xml
			StringReplace, ThisLineSpaced, ThisLineSpaced, datextime, datetime, all ; workaround

			StringReplace, ThisLineSpaced, ThisLineSpaced, +, {+}, All
			StringReplace, ThisLineSpaced, ThisLineSpaced, #, {#}, All

			LineSpaced%A_Index% := ThisLineSpaced
		}


		; send the lines back to the application
		Send % "{Del}{Up " LineCount-1 "}"
		Loop, %LineCount%
		{
			Send % LineSpaced%A_Index%
			Sleep 10
			Send {Down}{End}
			Sleep 10
		}
		; Send {Shift down} ; because of a sticky shift
		; Send {Shift up} ; because of a sticky shift

	}
	Catch, ThrownValue
	{
		; capture error values
		ErrorMessage := ThrownValue.Message, ErrorWhat := ThrownValue.What, ErrorExtra := ThrownValue.Extra, ErrorFile := ThrownValue.File, ErrorLine := ThrownValue.Line
		RethrowMessage := "Error at line " ErrorLine " of " ErrorWhat (ErrorMessage ? ": `n`n" ErrorMessage : "") (ErrorExtra ? "`n" ErrorExtra : "") ; (ErrorFile ? "`n`n" ErrorFile  : "")


		; set return value
		ReturnValue := !ReturnValue


		; take action on the error
		; InfoTip(RethrowMessage,,,3,A_ThisFunc,1,10000)
		; MsgBox, 8500, %ApplicationName%, %RethrowMessage%`n`nOpen containing file?`n`n%ErrorFile%
		; IfMsgBox, Yes
			; Run, Edit %ErrorFile%


		; rethrow error to caller
		; Throw, RethrowMessage
	}
	Finally
	{
		SetBatchLines, %BatchLines%
	}

	; return
	Return ReturnValue
}


/* ; testing
SqlText =
(
configuration_id AS configuration_id
[name]        AS name
[value] AS value
minimum AS minimum
maximum AS maximum
value_in_use AS value_in_use
)
ReturnValue := VerticalTextAlign(SqlText)
MsgBox, VerticalTextAlign`n`nReturnValue: %ReturnValue%
*/