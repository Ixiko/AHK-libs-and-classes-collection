
; ##############################################################################################################################################################################################
; #                                                                                                                                                                                            #
; #     AHKDb version 0.1 alpha                                                                                                                                                                #
; #                                                                                                                                                                                            #
; #     Description: A database library for AutoHotkey.                                                                                                                                        #
; #     Dependencies: None.                                                                                                                                                                    #
; #                                                                                                                                                                                            #
; #     Original author: Elias                                                                                                                                                                 #
; #     Released: January 20, 2020                                                                                                                                                             #
; #     Lisence: GNU AGPLv3                                                                                                                                                                    #
; #     Encoding: UTF-8                                                                                                                                                                        #
; #     Tab length: 4 spaces                                                                                                                                                              	   #
; #                                                                                                                                                                                            #
; ##############################################################################################################################################################################################

; ##############################################################################################################################################################################################
; #                                                                                                                                                                                            #
; #     FUNCTIONS:                                                                                                                                                                             #
; #                                                                                                                                                                                            #
; ##############################################################################################################################################################################################

DatabaseAbsoluteValue( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Turn negative values (from a specified part of the database) into positive
; Example: DatabaseAbsoluteValue( "database.txt" )													; turn all negative values in database into positive values
; Example: DatabaseAbsoluteValue( "database.txt", 2 )												; turn all negative values in the second database row into positive values
; Example: DatabaseAbsoluteValue( "database.txt", , 2 )												; turn all negative values in the second database column into positive values
; Example: DatabaseAbsoluteValue( "database.txt", 1, 2 )											; turn the cell value (if negative) in the first row and second column into a positive value
; Example: DatabaseAbsoluteValue( "database.txt", , , TRUE )										; turn all negative values in database into positive values, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Abs(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Abs(A_LoopField) . "`r`n"											; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Abs(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Abs(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Abs(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Abs(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Abs(db_Cells[db_Column])										; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseAddColumn( db_DatabaseName
				 , db_Row1:=""	, db_Row2:=""	, db_Row3:=""	, db_Row4:=""	, db_Row5:=""
				 , db_Row6:=""	, db_Row7:=""	, db_Row8:=""	, db_Row9:=""	, db_Row10:=""
				 , db_Row11:=""	, db_Row12:=""	, db_Row13:=""	, db_Row14:=""	, db_Row15:=""
				 , db_Row16:=""	, db_Row17:=""	, db_Row18:=""	, db_Row19:=""	, db_Row20:=""
				 , db_Row21:=""	, db_Row22:=""	, db_Row23:=""	, db_Row24:=""	, db_Row25:=""
				 , db_Row26:=""	, db_Row27:=""	, db_Row28:=""	, db_Row29:=""	, db_Row30:=""
				 , db_Row31:=""	, db_Row32:=""	, db_Row33:=""	, db_Row34:=""	, db_Row35:=""
				 , db_Row36:=""	, db_Row37:=""	, db_Row38:=""	, db_Row39:=""	, db_Row40:=""
				 , db_Row41:=""	, db_Row42:=""	, db_Row43:=""	, db_Row44:=""	, db_Row45:=""
				 , db_Row46:=""	, db_Row47:=""	, db_Row48:=""	, db_Row49:=""	, db_Row50:="" ) { ; Add database column (to right end of database)
; Example: DatabaseAddColumn( "database.txt" )												; add a new database column (with empty cells)
; Example: DatabaseAddColumn( "database.txt", "First cell", "Second", "Third" )				; add a new database column with first three cells specified

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Save database with new column:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )						; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		db_RowOutput := A_LoopReadLine . A_Tab . db_Row%A_Index%							; prepare output row with new column
		if ( A_Index<db_NumberOfRows )														; if not the last row of database
			db_RowOutput .= "`r`n"															; add linebreak at the end of the row
		FileAppend, %db_RowOutput%															; add modified database row (with new column) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseAddition( db_DatabaseName, db_Constant, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Add constant to value in each cell (assume cells contain numbers)
; Example: DatabaseAddition( "database.txt", 10 )													; add 10 to each cell in database
; Example: DatabaseAddition( "database.txt", 3, 2 )													; add 3 to each cell of the second row
; Example: DatabaseAddition( "database.txt", 3, , 4 )												; add 3 to each cell of the fourth column
; Example: DatabaseAddition( "database.txt", 3, 5, 4 )												; add 3 to the cell on the fifth row and fourth column

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % A_LoopField+db_Constant . A_Tab									; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % A_LoopField+db_Constant . "`r`n"									; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % A_LoopField+db_Constant											; save updated cell content to output file
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= db_CellContent+db_Constant								; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := db_Cells[1]+db_Constant												; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]+db_Constant							; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := db_Cells[db_Column]+db_Constant								; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseAddNA( db_DatabaseName, db_SkipFirstRow:=FALSE ) { ; Replace empty cell content with "NA" and return number of such cases
; Example: AddedNA := DatabaseAddNA( "database.txt" )							; fill all empty cells with "NA", and present number of such cases
;          MsgBox, Number of NAs added: %AddedNA%								;
; Example: DatabaseAddNA( "database.txt", TRUE)									; fill all empty cells with "NA", but skip the first row

return DatabaseReplace( db_DatabaseName, "", "NA", , , , db_SkipFirstRow )		; fill empty cells with "NA" as specified and return number of such cases
}

DatabaseAddNumerationColumn( db_DatabaseName, db_SkipFirstRow:=FALSE ) { ; Add a new database column containing increasing integers (starting from 1)
; Example: DatabaseAddNumerationColumn( "database.txt" )									; add a new database column containing increasing integers (starting from 1)

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Save database with numeration column:
	Numeration := 1																			; initiate numeration variable
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		IfNotExist, %db_DatabaseName%														; if database output file does not exist
		{																					; {
			if ( db_SkipFirstRow==TRUE )													; if the first row shall be skipped
				FileAppend, %A_LoopReadLine%%A_Tab%											; append first database row without numeration
			else {																			; else (if the first row shall not be skipped)
				FileAppend, %A_LoopReadLine%%A_Tab%%Numeration%								; append first database row with numeration
				Numeration++																; increase numeration variable by 1
			}
			continue																		; continue loop (next iteration)
		}																					; }
		FileAppend, `r`n%A_LoopReadLine%%A_Tab%%Numeration%									; append database row with numeration
		Numeration++																		; increase numeration variable by 1
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseAddRandomColumn( db_DatabaseName, db_RandomMin:=0, db_RandomMax:=9, db_SkipFirstRow:=FALSE ) { ; Add a new database column containing (pseudo) random numbers
; Example: DatabaseAddRandomColumn( "database.txt" )										; add a database column containing random integers (from 0 to 9)
; Example: DatabaseAddRandomColumn( "database.txt", -5, 3 )									; add a database column containing random integers from -5 to 3
; Example: DatabaseAddRandomColumn( "database.txt", -5.0, 3.0 )								; add a database column containing random rational numbers from -5.0 to 3.0
; Example: DatabaseAddRandomColumn( "database.txt", , , TRUE )								; add a database column containing random integers (from 0 to 9), but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Save database with numeration column:
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		Random, db_RandomCellContent, db_RandomMin, db_RandomMax							; store a generated (pseudo) random number
		IfNotExist, %db_DatabaseName%														; if database output file does not exist
		{																					; {
			if ( db_SkipFirstRow==TRUE )													; if the first row shall be skipped
				FileAppend, %A_LoopReadLine%%A_Tab%											; append first database row without random number
			else																			; else (if the first row shall not be skipped)
				FileAppend, %A_LoopReadLine%%A_Tab%%db_RandomCellContent%					; append first database row with random number
			continue																		; continue loop (next iteration)
		}																					; }
		FileAppend, `r`n%A_LoopReadLine%%A_Tab%%db_RandomCellContent%						; append database row with random number
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseAddRow( db_DatabaseName
			  , db_Column1:=""	, db_Column2:=""	, db_Column3:=""	, db_Column4:=""	, db_Column5:=""
			  , db_Column6:=""	, db_Column7:=""	, db_Column8:=""	, db_Column9:=""	, db_Column10:=""
			  , db_Column11:=""	, db_Column12:=""	, db_Column13:=""	, db_Column14:=""	, db_Column15:=""
			  , db_Column16:=""	, db_Column17:=""	, db_Column18:=""	, db_Column19:=""	, db_Column20:=""
			  , db_Column21:=""	, db_Column22:=""	, db_Column23:=""	, db_Column24:=""	, db_Column25:=""
			  , db_Column26:=""	, db_Column27:=""	, db_Column28:=""	, db_Column29:=""	, db_Column30:=""
			  , db_Column31:=""	, db_Column32:=""	, db_Column33:=""	, db_Column34:=""	, db_Column35:=""
			  , db_Column36:=""	, db_Column37:=""	, db_Column38:=""	, db_Column39:=""	, db_Column40:=""
			  , db_Column41:=""	, db_Column42:=""	, db_Column43:=""	, db_Column44:=""	, db_Column45:=""
			  , db_Column46:=""	, db_Column47:=""	, db_Column48:=""	, db_Column49:=""	, db_Column50:="" ) { ; Add database row (to bottom of database)
; Example: DatabaseAddRow( "database.txt", "First", "Second", "Third" )					; add a new database row with first three cells specified
; Example: DatabaseAddRow( "database.txt", "", , "Third" )								; add a new database row with only third cell specified

	; Prepare new database row:
	IfExist %db_DatabaseName%															; if database exists
	{
		db_NewDatabaseRow = `r`n														; add linebreak to row output
		db_NumberOfColumns := DatabaseGetNumberOfColumns( db_DatabaseName )				; store number of database columns
	} else {																			; else (if database file does not exist)
		db_NewDatabaseRow =																; prepare empty row output
		Loop, 50																		; loop through all possible cells of row
			if ( db_Column%A_Index%!="" )												; if cell content is specified
				db_NumberOfColumns := A_Index											; store loop iteration as number of columns of databae
	}
	while A_Index<db_NumberOfColumns {													; loop (number of database columns minus 1)
		db_NewDatabaseRow .= db_Column%A_Index% . A_Tab									; add cell content followed by tab to string
	}
	db_NewDatabaseRow .= db_Column%db_NumberOfColumns%									; add last cell content without tab to string

	; Add new row to database:
	FileAppend, %db_NewDatabaseRow%, %db_DatabaseName%, UTF-8							; add new database row to file

return																					; return
}

DatabaseArcCos( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take arccos() of each cell value in specified part of database
; Example: DatabaseArcCos( "database.txt" )															; take arccos() of each value in database
; Example: DatabaseArcCos( "database.txt", 2 )														; take arccos() of each value in second row of database
; Example: DatabaseArcCos( "database.txt", , 2 )													; take arccos() of each value in second column of database
; Example: DatabaseArcCos( "database.txt", 1, 2 )													; take arccos() of cell value in the first row and second column of database
; Example: DatabaseArcCos( "database.txt", , , TRUE )												; take arccos() of each value in database, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % ACos(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % ACos(A_LoopField) . "`r`n"										; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % ACos(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= ACos(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := ACos(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . ACos(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := ACos(db_Cells[db_Column])									; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseArcSin( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take arcsin() of each cell value in specified part of database
; Example: DatabaseArcSin( "database.txt" )															; take arcsin() of each value in database
; Example: DatabaseArcSin( "database.txt", 2 )														; take arcsin() of each value in second row of database
; Example: DatabaseArcSin( "database.txt", , 2 )													; take arcsin() of each value in second column of database
; Example: DatabaseArcSin( "database.txt", 1, 2 )													; take arcsin() of cell value in the first row and second column of database
; Example: DatabaseArcSin( "database.txt", , , TRUE )												; take arcsin() of each value in database, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % ASin(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % ASin(A_LoopField) . "`r`n"										; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % ASin(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= ASin(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := ASin(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . ASin(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := ASin(db_Cells[db_Column])									; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseArcTan( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take arctan() of each cell value in specified part of database
; Example: DatabaseArcTan( "database.txt" )															; take arctan() of each value in database
; Example: DatabaseArcTan( "database.txt", 2 )														; take arctan() of each value in second row of database
; Example: DatabaseArcTan( "database.txt", , 2 )													; take arctan() of each value in second column of database
; Example: DatabaseArcTan( "database.txt", 1, 2 )													; take arctan() of cell value in the first row and second column of database
; Example: DatabaseArcTan( "database.txt", , , TRUE )												; take arctan() of each value in database, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % ATan(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % ATan(A_LoopField) . "`r`n"										; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % ATan(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= ATan(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := ATan(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . ATan(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := ATan(db_Cells[db_Column])									; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseBackup( db_DatabaseName, db_Location:="", db_BackupName:="NUMBER" ) { ; Create a backup of database by a built-in naming system (NUMBER, DATE, DATETIME or ORIGINAL)
; Example: DatabaseBackup( "database.txt" )																		; store a database backup (filename with number) in working directory
; Example: DatabaseBackup( "database.txt", , "NUMBER" )															; store a database backup (filename with number) in working directory
; Example: DatabaseBackup( "database.txt", , "DATE" )															; store a database backup (filename with date)
; Example: DatabaseBackup( "database.txt", , "DATETIME" )														; store a database backup (filename with date and time)
; Example: DatabaseBackup( "database.txt", "C:\Users\Username\Desktop\Backup", "ORIGINAL" )						; store a backup (with same name as original) in a backup folder on desktop
; Example: BackupName := DatabaseBackup( "database.txt" )														; create a backup, and present backup filename (if no problem was detected)
;          if ( BackupName==0 )																					;
;              MsgBox, Backup failed.																			;
;          else																									;
;              MsgBox, Backup named %BackupName% created.														;

	; Prepare location (folder):
	if ( db_Location=="" )																						; if no location is specified
		db_Location := A_WorkingDir																				; set location to the working directory

	; Prepare filename:
	SplitPath, db_DatabaseName, , , , db_DatabaseNameNoExtension												; get database filename without extension
	if ( db_BackupName=="NUMBER" ) {																			; if naming system based on numbering
		Loop,																									; loop
			IfNotExist, %db_DatabaseNameNoExtension%_%A_Index%.txt												; if filename is available
			{																									; {
				db_BackupFile = %db_DatabaseNameNoExtension%_%A_Index%.txt										; store filename
				break																							; break
			}																									; }
	} else if ( db_BackupName=="DATE" )																			; else if naming system based on date
		db_BackupFile = %db_DatabaseNameNoExtension%_%A_YYYY%_%A_MM%_%A_DD%.txt									; store filename
	else if ( db_BackupName=="DATETIME" )																		; else if naming system based on date and time
		db_BackupFile = %db_DatabaseNameNoExtension%_%A_YYYY%_%A_MM%_%A_DD%_%A_Hour%_%A_Min%_%A_Sec%.txt		; store filename
	else if ( db_BackupName=="ORIGINAL" )																		; else if naming backup same as original
		db_BackupFile = %db_DatabaseNameNoExtension%.txt														; store filename
	else																										; else
		return 0																								; return 0 (incorrect naming system declared)

	; Save database file:
	FileCopy, %db_DatabaseName%, %db_Location%\%db_BackupFile%, 1												; save a backup of database (overwrite if needed)

	; Return 1 if backup file is found:
	IfNotExist, %db_Location%\%db_BackupFile%																	; if database backup file is not found
		return 0																								; return 0

return db_BackupFile																							; return 1 (no problem was detected)
}

DatabaseCeiling( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Round up values from specified part of database
; Example: DatabaseCeiling( "database.txt" )														; round up all database values
; Example: DatabaseCeiling( "database.txt", 2 )														; round up all database values in the second row
; Example: DatabaseCeiling( "database.txt", , 2 )													; round up all database values in the second column
; Example: DatabaseCeiling( "database.txt", 1, 2 )													; round up the value in the first row and second column
; Example: DatabaseCeiling( "database.txt", , , TRUE )												; round up all database values, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Ceil(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Ceil(A_LoopField) . "`r`n"										; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Ceil(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Ceil(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Ceil(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Ceil(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Ceil(db_Cells[db_Column])									; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseCheck( db_DatabaseName ) { ; Check if database contain errors (rows with different number of cells, and if last row with cells end with linebreak), and return 1 if no problems found
; Example: if ( DatabaseCheck( "database.txt" ) )									; check if database contain error, and present result
;              MsgBox, No problem detected.											;
;          else																		;
;              MsgBox, Problem detected.											;

	; Ensure all rows have the same number of cells:
	db_NumberOfColumns := DatabaseGetNumberOfColumns( db_DatabaseName )				; store number of columns
	Loop, read, %db_DatabaseName%													; loop through database rows
		if !( db_NumberOfColumns==StrSplit( A_LoopReadLine, A_Tab ).MaxIndex() )	; if row does not have correct number of cells
			return 0																; return 0

	; Ensure last row with cells does not end with linebreak:
	db_DatabaseOpen := FileOpen( db_DatabaseName, "r" )								; open file (for reading)
	Loop, read, %db_DatabaseName%													; loop through database rows
		if !( A_Index==1 )															; if not the first row
			db_DatabaseOpen.ReadLine()												; read one line of database (move pointer to next row)
	db_DatabaseRow := db_DatabaseOpen.ReadLine()									; read one line of database (the last row containing cells)
	StringRight, db_EndOfRow, db_DatabaseRow, 1										; store last character of row
	if !( db_EndOfRow=="`n" )														; if row does not end with linebreak
		return 1																	; return 1
	db_DatabaseOpen.Close()															; close file

return 0																			; return 0 (the last row with cells end with a linebreak)
}

DatabaseColumnSplitDelimiter( db_DatabaseName, db_Column, db_Delimiter, db_SkipFirstRow:=FALSE ) { ; Split a column at a delimiter
; Example: DatabaseColumnSplitDelimiter( "database.txt", 4, "," )										; split the fourth column at (the first) comma (the comma is removed)
; Example: DatabaseColumnSplitDelimiter( "database.txt", 4, ",", TRUE )									; split the fourth column at (the first) comma, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )						; rename database file (and store new filename)

	; Split column:
	Loop, read, %db_TemporaryFilename%, %db_DatabaseName%												; loop through database rows
	{																									; {
		db_DatabaseRow 			:= A_LoopReadLine														; read (current) line of database
		db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)						; store position of tab before cell content on database row
		db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)							; store position of tab after cell content on database row
		db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)					; store part of database row before cell content to split
		if !( db_TabAfterCellContent==0 ) {																; if a column other than the last database column shall be splitted
			db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1					; store content of cell to splitted
											, db_TabAfterCellContent-db_TabBeforeCellContent-1)
			db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)					; store content of cell to the right of cell to split (no tab included)
		} else {																						; else (last database column shall be splitted)
			db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)				; store cell content
			db_RightPartOfRow       := 																	; store nothing in output variable for content to the right of cell content
		}
		db_SplittedCells := StrSplit( db_CellContent, db_Delimiter, , 2 )								; store splitted cell in array
		IfExist, %db_DatabaseName%																		; if output file exists
			FileAppend, `r`n																			; append linebreak
		FileAppend, %db_LeftPartOfRow%																	; append part before colummn to split
		if ( A_Index==1 AND db_SkipFirstRow==TRUE )														; if the first row, and the first row shall be skipped
			FileAppend, %db_Cellcontent%`t																; append the unsplitted cell content and a tab
		else																							; else (if the row shall be splitted)
			FileAppend, % db_SplittedCells[1] . "`t" . db_SplittedCells[2]								; append splitted cell content in two cells
		FileAppend, %db_RightPartOfRow%																	; append part after the splitted cell
	}																									; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																	; delete (temporary) file

return																									; return
}

DatabaseColumnSplitLeft( db_DatabaseName, db_Column, db_SplitPosition, db_SkipFirstRow:=FALSE ) { ; Split a column after a specified number of characters from the left
; Example: DatabaseColumnSplitLeft( "database.txt", 5, 2 )												; split the fifth column after the second character (from left)
; Example: NewColumn := DatabaseColumnSplitLeft( "database.txt", 3, 2 )									; split the third column after the second character and show new column number
;          MsgBox, The new column has column number %NewColumn%.										;
; Example: DatabaseColumnSplitLeft( "database.txt", 4, 2, TRUE )										; split the fourth column after the second character, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )						; rename database file (and store new filename)

	; Split column:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )									; store number of database rows
	Loop, read, %db_TemporaryFilename%, %db_DatabaseName%												; loop through database rows
	{																									; {
		db_DatabaseRow 			:= A_LoopReadLine														; read (current) line of database
		db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)						; store position of tab before cell content on database row
		db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)							; store position of tab after cell content on database row
		db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)					; store part of database row before cell content to split
		if !( db_TabAfterCellContent==0 ) {																; if a column other than the last database column shall be splitted
			db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1					; store content of cell to split
											, db_TabAfterCellContent-db_TabBeforeCellContent-1)
			db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)					; store content of cell to the right of cell to split
		} else {																						; else (last database column shall be splitted)
			db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)				; store cell content
			db_RightPartOfRow       := 																	; store nothing in output variable for content to the right of cell content
		}
		IfExist, %db_DatabaseName%																		; if output file exists
			FileAppend, `r`n																			; append linebreak
		FileAppend, %db_LeftPartOfRow%																	; append part to the left of column to split
		if ( A_Index==1 AND db_SkipFirstRow==TRUE )														; if first database row, and it shall be skipped
			FileAppend, %db_CellContent%`t																; output row content (with first cell of new column empty)
		else																							; else (if the row shall be splitted)
			FileAppend, % SubStr(db_CellContent, 1, db_SplitPosition) . "`t"							; append splitted columns (separated by a tab)
						. SubStr(db_CellContent, db_SplitPosition+1 )
		FileAppend, %db_RightPartOfRow%																	; output part of row to the right of splitted column
	}																									; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																	; delete (temporary) file

return % db_Column+1																					; return column number of new column (right part of splitted column)
}

DatabaseColumnSplitRight( db_DatabaseName, db_Column, db_SplitPosition, db_SkipFirstRow:=FALSE ) { ; Split a column after a specified number of characters from the right
; Example: DatabaseColumnSplitRight( "database.txt", 5, 2 )												; split the fifth column after the second character (from right)
; Example: NewColumn := DatabaseColumnSplitRight( "database.txt", 3, 2 )								; split the third column after the second character and show new column number
;          MsgBox, The new column has column number %NewColumn%.										;
; Example: DatabaseColumnSplitRight( "database.txt", 4, 2, TRUE )										; split the fourth column after the second character, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )						; rename database file (and store new filename)

	; Split column:
	Loop, read, %db_TemporaryFilename%, %db_DatabaseName%												; loop through database rows
	{																									; {
		db_DatabaseRow 			:= A_LoopReadLine														; read (current) line of database
		db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)						; store position of tab before cell content on database row
		db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)							; store position of tab after cell content on database row
		db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)					; store part of database row before cell content to split
		if !( db_TabAfterCellContent==0 ) {																; if a column other than the last database column shall be splitted
			db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1					; store content of cell to split
											, db_TabAfterCellContent-db_TabBeforeCellContent-1)
			db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)					; store content of cell to the right of cell to split
		} else {																						; else (last database column shall be splitted)
			db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)				; store cell content
			db_RightPartOfRow       := 																	; store nothing in output variable for content to the right of cell content
		}
		IfExist, %db_DatabaseName%																		; if output file exists
			FileAppend, `r`n																			; append linebreak
		FileAppend, %db_LeftPartOfRow%																	; append part to the left of column to split
		if ( A_Index==1 AND db_SkipFirstRow==TRUE )														; if first database row, and it shall be skipped
			FileAppend, %db_CellContent%`t																; output row content (with first cell of new column empty)
		else {																							; else (if the row shall be splitted)
			db_SplitPositionFromLeft := StrLen(db_CellContent)-db_SplitPosition							; store last character to store in left column
			FileAppend, % SubStr(db_CellContent, 1, db_SplitPositionFromLeft) . "`t"					; append splitted columns (separated by a tab)
						. SubStr(db_CellContent, db_SplitPositionFromLeft+1 )
		}
		FileAppend, %db_RightPartOfRow%																	; output part of row to the right of splitted column
	}																									; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																	; delete (temporary) file

return % db_Column+1																					; return column number of new column (right part of splitted column)
}

DatabaseCompare( db_DatabaseName1, db_DatabaseName2, db_Row:="", db_Column:="", db_CaseSensitive:=FALSE, db_SkipFirstRow:=FALSE) { ; Compare content of two databases (return 1 if identical)
; Example: Comparison := DatabaseCompare( "database1.txt", "database2.txt" )							; compare content of two databases (not case-sensitive) and present result
;          if (Comparison==1)																			;
;              MsgBox, Databases are identical.															;
;          else																							;
;              MsgBox, Databases are different.															;
; Example: Comparison := DatabaseCompare( "database1.txt", "database2.txt", 2 )							; compare content of the second row of two databases and store result
; Example: Comparison := DatabaseCompare( "database1.txt", "database2.txt", , 3 )						; compare content of the third row of two databases and store result
; Example: Comparison := DatabaseCompare( "database1.txt", "database2.txt", , , TRUE )					; compare content of two databases and store result (case-sensitive comparison)
; Example: Comparison := DatabaseCompare( "database1.txt", "database2.txt", , , , TRUE )				; compare content of two databases, but skip the first row, and store result

	; Set case-sensitivity setting:
	db_OriginalCaseSensitivity := A_StringCaseSense														; store original case-sensitivity setting
	if ( db_CaseSensitive==TRUE )																		; if case-sensitivity shall be turned on
		StringCaseSense, On																				; turn on case sensitivity
	else																								; else (case-sensitivity shall be turned off)
		StringCaseSense, Off																			; turn off case sensitivity

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {																; if neither row nor column is specified
		if !( DatabaseGetNumberOfRows(db_DatabaseName1)==DatabaseGetNumberOfRows(db_DatabaseName2) )	; if number of rows differ
			return 0																					; return 0
		db_DatabaseName2Open := FileOpen( db_DatabaseName2, "r" )										; open file (for reading)
		Loop, read, %db_DatabaseName1%																	; loop through database (row by row)
		{																								; {
			db_DatabaseName2Row := db_DatabaseName2Open.ReadLine()										; read one line of database
			if ( A_Index==1 AND db_SkipFirstRow==TRUE )													; if first row and first row shall be skipped
				continue																				; continue loop (next iteration) 
			db_DatabaseName2Row := StrReplace(db_DatabaseName2Row, "`r")								; remove `r from database if present (for purpose of comparison)
			db_DatabaseName2Row := StrReplace(db_DatabaseName2Row, "`n")								; remove `n from database if present (for purpose of comparison)
			IfNotEqual, A_LoopReadLine, %db_DatabaseName2Row%											; if database rows are different (note: IfNotEqual can handle case-sensitivity)
				return 0																				; return 0
		}																								; }
		db_DatabaseName2Open.Close()																	; close file
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {														; else if column is specified but row is not specified
		if !( DatabaseGetNumberOfRows(db_DatabaseName1)==DatabaseGetNumberOfRows(db_DatabaseName2) )	; if number of rows differ
			return 0																					; return 0
		db_DatabaseName2Open := FileOpen( db_DatabaseName2, "r" )										; open file (for reading)
		Loop, read, %db_DatabaseName1%																	; loop through database (row by row)
		{																								; {
			db_DatabaseName2Row := db_DatabaseName2Open.ReadLine()										; read one line of database
			if ( A_Index==1 AND db_SkipFirstRow==TRUE )													; if first row and first row shall be skipped
				continue																				; continue loop (next iteration) 
			db_DatabaseName2Row := StrReplace(db_DatabaseName2Row, "`r")								; remove `r from database if present (for purpose of comparison)
			db_DatabaseName2Row := StrReplace(db_DatabaseName2Row, "`n")								; remove `n from database if present (for purpose of comparison)
			db_DatabaseName1Cell := StrSplit(A_LoopReadLine, "`t")[db_Column]							; store cell content of database 1
			db_DatabaseName2Cell := StrSplit(db_DatabaseName2Row, "`t")[db_Column]						; store cell content of database 2
			IfNotEqual, db_DatabaseName1Cell, %db_DatabaseName2Cell%									; if database cells are different (note: IfNotEqual can handle case-sensitivity)
				return 0																				; return 0
		}																								; }
		db_DatabaseName2Open.Close()																	; close file
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {														; else if row is specified but column is not specified
		FileReadLine, db_DatabaseName1Row, %db_DatabaseName1%, db_Row									; store row of database 1
		FileReadLine, db_DatabaseName2Row, %db_DatabaseName2%, db_Row									; store row of database 2
		IfNotEqual, db_DatabaseName1Row, %db_DatabaseName2Row%											; if database rows are different (note: IfNotEqual can handle case-sensitivity)
			return 0																					; return 0
	}

	; If row and column are specified:
	else {																								; else (if both row and column are specified)
		db_DatabaseName1Cell := DatabaseGet( db_DatabaseName1, db_Row, db_Column )						; store cell content of database 1
		db_DatabaseName2Cell := DatabaseGet( db_DatabaseName2, db_Row, db_Column )						; store cell content of database 2
		IfNotEqual, db_DatabaseName1Cell, %db_DatabaseName2Cell%										; if database cells are different (note: IfNotEqual can handle case-sensitivity)
			return 0																					; return 0
	}

	; Restore case-sensitivity setting:
	StringCaseSense, %db_OriginalCaseSensitivity%														; restore case-sensitivity setting

return 1																								; return 1
}

DatabaseCompareDimensions( db_DatabaseName1, db_DatabaseName2, db_SkipRows:=FALSE, db_SkipColumns:=FALSE, db_SkipFirstRowDb1:=FALSE, db_SkipFirstRowDb2:=FALSE ) { ; Compare database dimensions
; Example: if ( DatabaseCompareDimensions( "database1.txt", "database2.txt" ) )					; compare number of rows and columns of two databases and present result
;              MsgBox, Databases have the same number of rows and columns.						;
;          else																					;
;              MsgBox, Databases do not have the same number of rows and columns.				;
; Example: Result := DatabaseCompareDimensions( "database1.txt", "database2.txt", TRUE )		; compare number of columns and store the result (1 if same number of rows, 0 otherwise)
; Example: Result := DatabaseCompareDimensions( "database1.txt", "database2.txt", , TRUE )		; compare number of rows and store the result (1 if same number of rows, 0 otherwise)
; Example: Result := DatabaseCompareDimensions( "database1.txt", "database2.txt", , , TRUE )	; compare number of rows and columns, skip first row of first database, and store the result

	; Store number of rows and columns:
	db_DatabaseName1Columns := DatabaseGetNumberOfColumns( db_DatabaseName1 )					; store number of database columns
	db_DatabaseName2Columns := DatabaseGetNumberOfColumns( db_DatabaseName2 )					; store number of database columns
	db_DatabaseName1Rows := DatabaseGetNumberOfRows( db_DatabaseName1 )							; store number of database rows
	db_DatabaseName2Rows := DatabaseGetNumberOfRows( db_DatabaseName2 )							; store number of database rows

	; Compare number of rows and columns:
	if ( db_SkipFirstRowDb1==TRUE )																; if the first row of database shall be skipped
		db_DatabaseName1Rows--																	; decrease variable for number of rows by 1
	if ( db_SkipFirstRowDb2==TRUE )																; if the first row of database shall be skipped
		db_DatabaseName2Rows--																	; decrease variable for number of rows by 1
	if !( db_DatabaseName1Columns==db_DatabaseName2Columns )									; if number of columns differ
		return 0																				; return 0 (dimensions differ)
	if !( db_DatabaseName1Rows==db_DatabaseName2Rows )											; if number of rows differ
		return 0																				; return 0 (dimensions differ)

return 1																						; return 1 (dimensions are not different)
}

DatabaseConcatenateColumns( db_DatabaseName, db_Column1, db_Column2, db_SkipFirstRow:=FALSE ) { ; Create a concatenation of two columns and return the new column number
; Example: ColumnNumber := DatabaseConcatenateColumns( "database.txt", 2, 3 )					; concatenate the second and third database column, and present new column number
;          MsgBox, The new concatenated column has column number %ColumnNumber%.				;
; Example: DatabaseConcatenateColumns( "database.txt", 2, 3, TRUE )								; concatenate the second and third database column, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )				; rename database file (and store new filename)

	; Create database file with concatenated row:
	Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
	{																							; {
		if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first row and first row shall be skipped
			FileAppend, %A_LoopReadLine%`t														; append row to output file (without concatenated cell)
			continue																			; continue loop (next iteration)
		}
		db_Column1Cell := StrSplit( A_LoopReadLine, "`t" )[db_Column1]							; store cell content
		db_Column2Cell := StrSplit( A_LoopReadLine, "`t" )[db_Column2]							; store cell content
		if !( A_Index==1 )																		; if not the first iteration
			FileAppend, `r`n																	; append linebreak to output file
		FileAppend, %A_LoopReadLine%`t%db_Column1Cell%%db_Column2Cell%							; append row to output file (with concatenated cell)
	}																							; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%															; delete (temporary) file

return DatabaseGetNumberOfColumns( db_DatabaseName )											; return column number of new (concatenated) column
}

DatabaseConcatenateRows( db_DatabaseName, db_Row1, db_Row2 ) { ; Create a concatenation of two rows and return the new row number
; Example: RowNumber := DatabaseConcatenateRows( "database.txt", 2, 3 )							; concatenate the second and third database rows, and present new row number
;          MsgBox, The new concatenated row has row number %RowNumber%.							;

	; Prepare concatenated row:
	FileReadLine, db_EntireRow1, %db_DatabaseName%, db_Row1										; store row of database
	FileReadLine, db_EntireRow2, %db_DatabaseName%, db_Row2										; store row of database
	db_Row1Array := StrSplit( db_EntireRow1, A_Tab )											; store elements of database row in array
	db_Row2Array := StrSplit( db_EntireRow2, A_Tab )											; store elements of database row in array
	db_OutputRow =																				; initiate string
	For db_Index, db_Value in db_Row1Array														; loop through elements of array
	{																							; {
		if ( db_Index==1 ) {																	; if first iteration
			db_OutputRow .= db_Value . db_Row2Array[db_Index]									; append concatenated cell content to output string
			continue																			; continue loop (next iteration)
		}
		db_OutputRow .= "`t" . db_Value . db_Row2Array[db_Index]								; append tab and concatenated cell content to output string
	}																							; }

	; Append concatenated row to database:
	FileAppend, `r`n%db_OutputRow%, %db_DatabaseName%, UTF-8									; append concatenated row to database

return DatabaseGetNumberOfRows( db_DatabaseName )												; return row number of new (concatenated) row
}

DatabaseCopy( db_DatabaseName, db_NewDatabaseName, db_Row:="", db_Column:="", db_Overwrite:=FALSE, db_SkipFirstRow:=FALSE ) { ; Save database copy as a new file (return 0 if fail)
; Example: DatabaseCopy( "database.txt", "newdatabase.txt" )										; save a copy of "database.txt" named "newdatabase.txt" (do not overwrite if file exist)
; Example: DatabaseCopy( "database.txt", "newdatabase.txt", , , TRUE )								; save a copy of "database.txt" named "newdatabase.txt" (and overwrite if necessary)
; Example: DatabaseCopy( "database.txt", "newdatabase.txt", , , , TRUE )							; save a copy of "database.txt" named "newdatabase.txt", but skip first row
; Example: DatabaseCopy( "database.txt", "newdatabase.txt", 2 )										; save a copy of the second row of "database.txt" named "newdatabase.txt"
; Example: DatabaseCopy( "database.txt", "newdatabase.txt", , 3 )									; save a copy of the third column of "database.txt" named "newdatabase.txt"

	; Return if new database filename exist and shall not be overwritten:
	IfExist, %db_NewDatabaseName%																	; if filename already exist
	{																								; {
		if ( db_Overwrite==FALSE )																	; if existing file shall not be overwritten
			return 0																				; return 0
		else																						; else (if existing file shall be overwritten)
			FileDelete, %db_NewDatabaseName%														; delete existing file
	}																								; }

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		if ( db_SkipFirstRow==FALSE )																; if first row shall not be skipped
			FileCopy, %db_DatabaseName%, %db_NewDatabaseName%										; copy entire database
		else																						; else (if first row shall be skipped)
			Loop, Read, %db_DatabaseName%, %db_NewDatabaseName%										; loop through file (row by row)
			{																						; {
				if (A_Index==1)																		; if first loop iteration
					continue																		; continue loop (next iteration)
				if !(A_Index==2)																	; if not second iteration
					FileAppend, `r`n, %db_NewDatabaseName%, UTF-8									; append a linebreak
				FileAppend, %A_LoopReadLine%, %db_NewDatabaseName%, UTF-8							; append database row
			}																						; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		Loop, read, %db_DatabaseName%, %db_NewDatabaseName%											; loop through database (row by row)
		{																							; {
			if ( db_SkipFirstRow==TRUE )															; if first row shall not be skipped
			{																						; {
				if ( A_Index==1 )																	; if first iteration
					continue																		; continue loop (next iteration) 
				if !( A_Index==2 )																	; if not second iteration
					FileAppend, `r`n, %db_NewDatabaseName%, UTF-8									; append a linebreak
			}																						; }
			else if !( A_Index==1 )																	; else if not first iteration
				FileAppend, `r`n, %db_NewDatabaseName%, UTF-8										; append a linebreak
			db_RowOutput := StrSplit(A_LoopReadLine, "`t")[db_Column]								; store column value from database
			FileAppend, %db_RowOutput%, %db_NewDatabaseName%, UTF-8									; append database row
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		FileReadLine, db_RowOutput, %db_DatabaseName%, db_Row										; store row of database
		FileAppend, %db_RowOutput%, %db_NewDatabaseName%, UTF-8										; append database row
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_RowOutput := DatabaseGet( db_DatabaseName, db_Row, db_Column )							; store cell content of database
		FileAppend, %db_RowOutput%, %db_NewDatabaseName%, UTF-8										; append database row
	}

return 1																							; return 1 (no indication of failure)
}

DatabaseCos( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take cos() of each cell value in specified part of database
; Example: DatabaseCos( "database.txt" )															; take cos() of each value in database
; Example: DatabaseCos( "database.txt", 2 )															; take cos() of each value in second row of database
; Example: DatabaseCos( "database.txt", , 2 )														; take cos() of each value in second column of database
; Example: DatabaseCos( "database.txt", 1, 2 )														; take cos() of cell value in the first row and second column of database
; Example: DatabaseCos( "database.txt", , , TRUE )													; take cos() of each value in database, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Cos(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Cos(A_LoopField) . "`r`n"											; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Cos(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Cos(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Cos(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Cos(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Cos(db_Cells[db_Column])										; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseCreate( db_DatabaseName, db_Rows, db_Columns, db_Overwrite:=FALSE, db_ContentByColumn:=FALSE
			  , db_Cell1:=""	, db_Cell2:=""	, db_Cell3:=""	, db_Cell4:=""	, db_Cell5:=""
			  , db_Cell6:=""	, db_Cell7:=""	, db_Cell8:=""	, db_Cell9:=""	, db_Cell10:=""
			  , db_Cell11:=""	, db_Cell12:=""	, db_Cell13:=""	, db_Cell14:=""	, db_Cell15:=""
			  , db_Cell16:=""	, db_Cell17:=""	, db_Cell18:=""	, db_Cell19:=""	, db_Cell20:=""
			  , db_Cell21:=""	, db_Cell22:=""	, db_Cell23:=""	, db_Cell24:=""	, db_Cell25:=""
			  , db_Cell26:=""	, db_Cell27:=""	, db_Cell28:=""	, db_Cell29:=""	, db_Cell30:=""
			  , db_Cell31:=""	, db_Cell32:=""	, db_Cell33:=""	, db_Cell34:=""	, db_Cell35:=""
			  , db_Cell36:=""	, db_Cell37:=""	, db_Cell38:=""	, db_Cell39:=""	, db_Cell40:=""
			  , db_Cell41:=""	, db_Cell42:=""	, db_Cell43:=""	, db_Cell44:=""	, db_Cell45:=""
			  , db_Cell46:=""	, db_Cell47:=""	, db_Cell48:=""	, db_Cell49:=""	, db_Cell50:="" ) { ; Create a database
; Example: DatabaseCreate( "database.txt", 20, 10 )															; create an empty (20x10) database
; Example: DatabaseCreate( "database.txt", 3, 3, , FALSE, "a", "b", "c", "d", "e", "f", "g", "h", "i" )		; create a (3x3) database with letters sorted by row
; Example: DatabaseCreate( "database.txt", 3, 3, , TRUE, "a", "b", "c", "d", "e", "f", "g", "h", "i" )		; create a (3x3) database with letters sorted by column

	; Return 0 if file already exist:
	IfExist, %db_DatabaseName%																				; if file exist
	{																										; {
		if ( db_Overwrite==FALSE )																			; if file shall not be overwritten
			return 0																						; return 0
		FileDelete, %db_DatabaseName%																		; delete file
	}																										; }

	; If cell content should be added by row:
	if ( db_ContentByColumn==FALSE ) {																		; if cell content should be added by row
		db_DatabaseOpen := FileOpen( db_DatabaseName, "w" )													; open database file (for writing)
		Loop % db_Columns*db_Rows 																			; loop through all cells of table
		{																									; {
			db_RowContent .= db_Cell%A_Index%																; add cell content to row string
			if ( Mod(A_Index, db_Columns)==0 ) {															; if end of row
				if( A_Index==db_Columns*db_Rows )															; if end of database
					db_DatabaseOpen.Write( db_RowContent )													; write row content to database
				else																						; else (if not end of database)
					db_DatabaseOpen.Write( db_RowContent . "`r`n" )											; write row content and linebreak to database
				db_RowContent := 																			; empty string for row content
			} else																							; else (if not end of row)
				db_RowContent .= A_Tab																		; add tab to row string
		}																									; }
		db_DatabaseOpen.Close()																				; close database file
	}

	; If cell content should be added by column:
	else {																									; else (if cell content should be added by column)
		db_DatabaseOpen := FileOpen( db_DatabaseName, "w" )													; open database file (for writing)
		db_CurrentRowNumber := 1																			; initiate variable for current row number
		Loop % db_Columns*db_Rows 																			; loop through all cells of table
		{																									; {
			db_CurrentCell := db_Rows*Mod(A_Index-1, db_Columns)+db_CurrentRowNumber						; calculate which cell content to add to row
			db_RowContent .= db_Cell%db_CurrentCell%														; add cell content to row string
			if ( Mod(A_Index, db_Columns)==0 ) {															; if end of row
				if( A_Index==db_Columns*db_Rows )															; if end of database
					db_DatabaseOpen.Write( db_RowContent )													; write row content to database
				else																						; else (if not end of database)
					db_DatabaseOpen.Write( db_RowContent . "`r`n" )											; write row content and linebreak to database
				db_RowContent := 																			; empty string for row content
			} else																							; else (if not end of row)
				db_RowContent .= A_Tab																		; add tab to row string
			if ( Mod(A_Index, db_Columns)==0 )																; if end of row
				db_CurrentRowNumber++																		; increase row current row number by 1
		}																									; }
		db_DatabaseOpen.Close()																				; close database file
	}

return 1																									; return 1
}

DatabaseCreateTest( db_DatabaseName, db_Type:="A1", db_Rows:=10, db_Columns:=5, db_Overwrite:=FALSE ) { ; Create a test database (available types: A1, NUMBERS, LETTERS, AIRPORTS)
; Example: DatabaseCreateTest( "database.txt" )																			; create a 10x5 test database containing letters and numbers
; Example: DatabaseCreateTest( "database.txt", , 20, 10 )																; create a 20x10 test database containing letters and numbers
; Example: DatabaseCreateTest( "database.txt", "LETTERS" )																; create a 10x5 test database containing letters (1 per cell)
; Example: DatabaseCreateTest( "database.txt", "LETTERS3", 5, 4 )														; create a 5x4 test database containing letters (3 per cell)
; Example: DatabaseCreateTest( "database.txt", "NUMBERS" )																; create a 10x5 test database containing random numbers (from 0 to 9)
; Example: DatabaseCreateTest( "database.txt", "-20NUMBERS10", 3, 4 )													; create a 3x4 test database containing random numbers (from -20 to 10)
; Example: DatabaseCreateTest( "database.txt", "AIRPORTS" )																; create an airport test database
; Example: DatabaseCreateTest( "database.txt", "AIRPORTS", , , TRUE )													; create an airport test database (overwrite if necessary)

	; Return 0 if file already exist:
	IfExist, %db_DatabaseName%																							; if file exist
	{																													; {
		if ( db_Overwrite==FALSE )																						; if file shall not be overwritten
			return 0																									; return 0
		FileDelete, %db_DatabaseName%																					; delete file
	}																													; }

	; Open database file for reading:
	db_DatabaseOpen := FileOpen( db_DatabaseName, "w" )																	; open database file (for writing)

	; If type is A1 (letters and numbers):
	if ( db_Type=="A1" )																								; if type is A1 (A1, A2, A3, ...)
		Loop, %db_Rows%																									; loop through each database row
		{																												; {
			db_Letter := Chr(65+Mod(A_Index-1, 26))																		; store letter for row (A, B, ...)
			db_RowOutput = %db_Letter%1																					; initiate string for row with letter and number 1
			Loop, % db_Columns-1																						; loop through each column of row except the first
				db_RowOutput .= A_Tab . db_Letter . Mod(A_Index+1, 10)													; store letter and number (depending on column) in each cell
			if ( A_Index<db_Rows )																						; if not the last row of database
				db_RowOutput .= "`r`n"																					; add a linebreak in end of row
			db_DatabaseOpen.Write( db_RowOutput )																		; write row to database
		}																												; }

	; If type is NUMBERS:
	else if ( InStr( db_Type, "NUMBERS" ) ) {																			; is type is NUMBERS (pseudo-random numers)
		db_RandomMin := StrSplit( db_Type, "NUMBERS" )[1]																; store smallest possible random number (if specified)
		db_RandomMax := StrSplit( db_Type, "NUMBERS" )[2]																; store largest possible random number (if specified)
		if ( db_RandomMin=="" )																							; if smallest possible random number is not specified
			db_RandomMin := 0																							; set the smallest possible random number to 0
		if ( db_RandomMax=="" )																							; if largest possible random number is not specified
			db_RandomMax := 9																							; set the largest possible random number to 9
		Loop, %db_Rows%																									; loop through each database row
		{																												; {
			Random, db_RandomNumber, db_RandomMin, db_RandomMax															; store a random number
			db_RowOutput = %db_RandomNumber%																			; initiate string for row with a random number
			Loop, % db_Columns-1																						; loop through each column of row except the first
			{																											; {
				Random, db_RandomNumber, db_RandomMin, db_RandomMax														; store a random number
				db_RowOutput .= A_Tab . db_RandomNumber																	; store random number in each cell
			}																											; }
			if ( A_Index<db_Rows )																						; if not the last row of database
				db_RowOutput .= "`r`n"																					; add a linebreak in end of row
			db_DatabaseOpen.Write( db_RowOutput )																		; write row to database
		}																												; }
	}

	; If type is LETTERS:
	else if ( SubStr( db_Type, 1, 7)=="LETTERS" ) {																		; if type is LETTERS (pseudo-random letters)
		db_NumberOfLetters := SubStr( db_Type, 8 )																		; store number of letters per cell (if specified)
		if ( db_NumberOfLetters=="" )																					; if number of letters per cell is not specified
			db_NumberOfLetters := 1																						; set number of letters per cell to 1
		Loop, %db_Rows%																									; loop through each database row
		{																												; {
			db_RowOutput = 																								; initiate string for content database row
			Loop, %db_NumberOfLetters%																					; loop once for each letter in (first) cell
			{																											; {
				Random, db_RandomNumber, 65, 90																			; store a (pseudo-)random number
				db_RowOutput .= Chr(db_RandomNumber)																	; add random letter to (first) cell
			}																											; }
			Loop, % db_Columns-1																						; loop through each column of row except the first
			{																											; {
				db_RowOutput .= A_Tab																					; add a tab to row string
				Loop, %db_NumberOfLetters%																				; loop once for each letter in cell
				{																										; {
					Random, db_RandomNumber, 65, 90																		; store a (pseudo-)random number
					db_RowOutput .= Chr(db_RandomNumber)																; add a random letter to cell
				}																										; }
			}																											; }
			if ( A_Index<db_Rows )																						; if not the last row of database
				db_RowOutput .= "`r`n"																					; add a linebreak in end of row
			db_DatabaseOpen.Write( db_RowOutput )																		; write row to database
		}																												; }
	}

	; If type is AIRPORTS:
	else if ( db_Type=="AIRPORTS" ) {																					; if type is AIRPORTS (an airport database)
		db_DatabaseOpen.Write( "IATA	NAME	CITY SERVED	OPENED	ELEVATION (m)`r`n" )								; write row to database
		db_DatabaseOpen.Write( "ATI	Artigas Airport	Artigas`, Uruguay	1973	125`r`n" )								; write row to database 
		db_DatabaseOpen.Write( "BDU	Bardufoss Airport	Bardufoss, Norway	1936	77`r`n" )							; write row to database
		db_DatabaseOpen.Write( "BRA	Barreiras Airport	Barreiras, Brazil	1940	746`r`n" )							; write row to database
		db_DatabaseOpen.Write( "CHC	Christchurch International Airport	Christchurch, New Zealand	1936	37`r`n" )	; write row to database
		db_DatabaseOpen.Write( "CPT	Cape Town International Airport	Cape Town, South Africa	1954	46`r`n" )			; write row to database
		db_DatabaseOpen.Write( "FRA	Frankfurt Airport	Frankfurt, Germany	1936	111`r`n" )							; write row to database
		db_DatabaseOpen.Write( "GRZ	Graz Airport	Graz, Austria	1914	340`r`n" )									; write row to database
		db_DatabaseOpen.Write( "HND	Haneda Airport	Tokyo, Japan	1931	6`r`n" )									; write row to database
		db_DatabaseOpen.Write( "LLW	Lilongwe International Airport	Lilongwe, Malawi	1977	1230`r`n" )				; write row to database
		db_DatabaseOpen.Write( "MNL	Ninoy Aquino International Airport	Manila, Philippines	1935	23`r`n" )			; write row to database
		db_DatabaseOpen.Write( "NAN	Nadi International Airport	Nadi, Fiji	1940	18`r`n" )							; write row to database
		db_DatabaseOpen.Write( "NBO	Jomo Kenyatta International Airport	Nairobi, Kenya	1958	1624`r`n" )				; write row to database
		db_DatabaseOpen.Write( "ORD	O'Hare International Airport	Chicago, United States	1944	204`r`n" )			; write row to database
		db_DatabaseOpen.Write( "PAC	Albrook " . Chr(34) . "Marcos A. Gelabert" . Chr(34) 
								. " International Airport	Panama City, Panama	1932	9`r`n" )						; write row to database
		db_DatabaseOpen.Write( "RES	Resistencia International Airport	Resistencia, Argentina	1965	52`r`n" )		; write row to database
		db_DatabaseOpen.Write( "SIN	Singapore Changi Airport	Changi, Singapore	1981	7`r`n" )					; write row to database
		db_DatabaseOpen.Write( "TSV	Townsville Airport	Townsville, Australia	1939	5`r`n" )						; write row to database
		db_DatabaseOpen.Write( "YEG	Edmonton International Airport	Edmonton, Canada	1960	723" )					; write row to database
		}

	; If a non-existing type is specified:
	else																												; else (an unknown database type)
		return 0																										; return 0

	; If failed to create database:
	IfNotExist, db_DatabaseName																							; if database file not found
		return 0																										; return 0

	; Close database file (for reading):
	db_DatabaseOpen.Close()																								; close database file

return 1																												; return 1 (no problem found)
}

DatabaseDelete( db_DatabaseName ) { ; Delete database (return 1 if successfully deleted, 0 otherwise)
; Example: DatabaseDelete( "database.txt" )				; delete "database.txt" (return 1 if successfully deleted, 0 otherwise)
; Example: if ( DatabaseDelete( "database.txt" ) )		; delete "database.txt" and inform whether or not successful through a message box
;               MsgBox, Database deleted.				;
;          else											;
;               MsgBox, Database not deleted.			;

	; Delete database file:
	FileDelete, %db_DatabaseName%						; delete database

	; Return 1 if database file is not found:
	IfNotExist, %db_DatabaseName%						; if database file is not found
		return 1										; return 1

return 0												; return 0 (database file appears to remain in original location)
}

DatabaseDivideColumns( db_DatabaseName, db_Column1, db_Column2, db_SkipFirstRow:=FALSE ) { ; Add new column containing one column divided by another column
; Example: DatabaseDivideColumns( "database.txt", 3, 5 )											; store column 3 divided by column 5 as a new column
; Example: DatabaseDivideColumns( "database.txt", 3, 5, TRUE )										; store column 3 divided by column 5 as a new column, but skip the first row
; Example: NewColumn := DatabaseDivideColumns( "database.txt", 3, 5 )								; store column 3 divided by column 5 as a new column, and show the new column number
;          MsgBox, The new column has column number %NewColumn%										;

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; Save database with new column:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )								; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%											; loop through each row of database
	{																								; {
		if !( db_SkipFirstRow==TRUE AND A_Index==1 )												; if not first row and first row shall be skipped
			db_RowOutput := A_LoopReadLine . A_Tab . StrSplit( A_LoopReadLine, A_Tab )[db_Column1]
													/StrSplit( A_LoopReadLine, A_Tab )[db_Column2]	; prepare output row with new column
		else																						; else
			db_RowOutput := A_LoopReadLine . A_Tab													; prepare output row with new column
		if ( A_Index<db_NumberOfRows )																; if not the last row of database
			db_RowOutput .= "`r`n"																	; add linebreak at the end of the row
		FileAppend, %db_RowOutput%																	; add modified database row (with new column) to output file
	}																								; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return DatabaseGetNumberOfColumns( db_DatabaseName )												; return column number of new database column
}

DatabaseDivision( db_DatabaseName, db_Divisor, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Divide each cell in specified part of database by a specified divisor
; Example: DatabaseDivision( "database.txt", 2 )													; divide each database cell value by 2
; Example: DatabaseDivision( "database.txt", 2, 3 )													; divide each cell value in the third row by 2
; Example: DatabaseDivision( "database.txt", 2, , 3 )												; divide each cell value in the third column by 2
; Example: DatabaseDivision( "database.txt", 2, 1, 3 )												; divide the cell in the first row and third column by 2
; Example: DatabaseDivision( "database.txt", 2, , , TRUE )											; divide each database cell value, with the first row excluded, by 2

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % A_LoopField/db_Divisor . A_Tab									; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % A_LoopField/db_Divisor . "`r`n"									; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % A_LoopField/db_Divisor											; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= db_CellContent/db_Divisor								; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := db_Cells[1]/db_Divisor													; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]/db_Divisor								; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := db_Cells[db_Column]/db_Divisor								; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseDuplicateColumn( db_DatabaseName, db_Column:="" ) { ; Create a duplicate of a database column (return column number of new column)
; Example: DatabaseDuplicateColumn( "database.txt", 3 )											; create a duplicate of the third database column
; Example: DatabaseDuplicateColumn( "database.txt" )											; create a duplicate of the last database column
; Example: NewColumn := DatabaseDuplicateColumn( "database.txt", 2 )							; duplicate the second column and present the column number of the new copy
;          MsgBox, Column %NewColumn% is now a duplicate of the second column.					;

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )				; rename database file (and store new filename)

	; Save database with new column:
	if ( db_Column=="" )																		; if column to duplicate is not specified
		db_Column := DatabaseGetNumberOfColumns( db_TemporaryFilename )							; set the last database column to be duplicated
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through each row of database
	{																							; {
		db_RowOutput := A_LoopReadLine . A_Tab . StrSplit( A_LoopReadLine, A_Tab )[db_Column]	; prepare output row with new column
		if ( A_Index<db_NumberOfRows )															; if not the last row of database
			db_RowOutput .= "`r`n"																; add linebreak at the end of the row
		FileAppend, %db_RowOutput%																; add modified database row (with new column) to output file
	}																							; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%															; delete (temporary) file

return DatabaseGetNumberOfColumns( db_DatabaseName )											; return column number of new database column
}

DatabaseDuplicateRow( db_DatabaseName, db_Row:="" ) { ; Create a duplicate of a database row (return row number of new row)
; Example: DatabaseDuplicateRow( "database.txt", 5 )									; create a duplicate of the fifth database row
; Example: DatabaseDuplicateRow( "database.txt" )										; create a duplicate of the last database row
; Example: NewRow := DatabaseDuplicateRow( "database.txt", 2 )							; duplicate the second column and present the column number of the new copy 
;          MsgBox, Row %NewRow% is now a duplicate of the second row.					;

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )		; rename database file (and store new filename)

	; Save database with new row:
	if ( db_Row=="" )																	; if row to duplicate is not specified
		db_Row := DatabaseGetNumberOfRows( db_TemporaryFilename )						; set the last database row to be duplicated
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%								; loop through each row of database
	{																					; {
		FileAppend, %A_LoopReadLine%`r`n												; append database row to output file
		if ( A_Index==db_Row )															; if database row to duplicate
			db_DuplicatedRow = %A_LoopReadLine%											; store database row to duplicate
	}																					; }
	FileAppend, %db_DuplicatedRow%, %db_DatabaseName%, UTF-8							; append database row to copy to output file

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%													; delete (temporary) file

return DatabaseGetNumberOfRows( db_DatabaseName )										; return row number of new database row
}

DatabaseExp( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take exp() of each cell value in specified part of database
; Example: DatabaseExp( "database.txt" )															; take exp() of each cell value
; Example: DatabaseExp( "database.txt", 2 )															; take exp() of each cell value in the second row
; Example: DatabaseExp( "database.txt", , 2 )														; take exp() of each cell value in the second column
; Example: DatabaseExp( "database.txt", 1, 2 )														; take exp() of the cell value in the first row and second column
; Example: DatabaseExp( "database.txt", , , TRUE )													; take exp() of each cell value, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Exp(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Exp(A_LoopField) . "`r`n"											; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Exp(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Exp(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Exp(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Exp(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Exp(db_Cells[db_Column])										; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseExportCSV( db_InputFile, db_OutputFile:="", db_Overwrite:=FALSE ) { ; Export (convert) tab-separated database to CSV-file
; Example: DatabaseExportCSV( "database.txt" )																; save tab-separated database as comma-separated (does not overwrite if file exists)
; Example: DatabaseExportCSV( "database.txt", , TRUE )														; save tab-separated database as comma-separated, and overwrites if file exists
; Example: DatabaseExportCSV( "input.txt", "output.csv" )													; convert (tab-separated) "input.txt" to (comma-separated) "output.csv"
; Example: if ( DatabaseExportCSV( "database.txt" ) )														; convert database and informs about whether or not conversion completed
;              MsgBox, Conversion completed.																;
;          else																								;
;              MsgBox, Conversion did not complete.															;

	; Create output filename if not specified:
	if ( db_OutputFile=="" ) {																				; if no output filename
		SplitPath, db_InputFile, , , , db_OutputFile														; get input filename without extension
		db_OutputFile .= ".csv"																				; add ".csv" as file extension
	}

	; Delete output file (if it exists and it is permitted):
	IfExist, %db_OutputFile%																				; if output filename exist
	{																										; {
		if ( db_Overwrite==FALSE )																			; if no permission to overwrite
			return 0																						; return 0
		FileDelete, %db_OutputFile%																			; delete file
	}																										; }

	; Convert file:
	Loop, read, %db_InputFile%, %db_OutputFile%																; loop through input file
	{																										; {
		IfExist, %db_OutputFile%																			; if file exist (i.e., if not the first row)
			FileAppend, `r`n																				; add a linebreak
		Loop, parse, A_LoopReadLine, %A_Tab%																; loop through cells on row
		{																									; {
			if ( InStr(A_LoopField, Chr(44)) OR InStr(A_LoopField, Chr(34)) )								; if cell contains comma (Chr(44)) or double quote (Chr(34))
				db_OutputField := Chr(34) . StrReplace( A_LoopField, Chr(34), Chr(34)Chr(34) ) . Chr(34)	; store cell content with quotation marks in the ends, and "" for every " in cell
			else																							; else (if cell does not contain comma or double quote)
				db_OutputField = %A_LoopField%																; store cell content in output string
			if !( A_Index==1 )																				; if no the first cell on row
				FileAppend, `,%db_OutputField%																; append comma followed by output string
			else																							; else (if first cell on row)
				FileAppend, %db_OutputField%																; append output string
		}																									; }
	}																										; }

return 1																									; return 1 (no problem detected)
}

DatabaseFind( db_DatabaseName, db_SearchTerm, db_Row:="", db_Column:="", db_Occurrence:="1", db_CaseSensitive:=FALSE, db_SkipFirstRow:=FALSE ) { ; Find a cell containing a search term
; Example: CellLocation := DatabaseFind( "database.txt", "Cell content" )			; store location (as array) of first cell containing "Cell content"
; Example: CellLocation := DatabaseFind( "database.txt", "Cell content", 10 )		; store location (as array) of first cell in row 10 containing "Cell content"
; Example: CellLocation := DatabaseFind( "database.txt", "Cell content", , 3 )		; store location (as array) of first cell in column 3 containing "Cell content"
; Example: CellLocation := DatabaseFind( "database.txt", "Cell content", 5, 7 )		; store location (5,7) (as array) if cell (5,7) contain "Cell content"
; Example: CellLocation := DatabaseFind( "database.txt", "Content", 2, , 3)			; store location of third cell containing "Content" in the second row
; Example: CellLocation := DatabaseFind( "database.txt", "Content", , , , TRUE )	; store location (as array) of first cell containing "Content" (case-sensitive search)
; Example: CellLocation := DatabaseFind( "database.txt", "Content", , , , , TRUE )	; store location (as array) of first cell containing "Content", when excluding the first row

	; Set case-sensitivity setting:
	db_OriginalCaseSensitivity := A_StringCaseSense									; store original case-sensitivity setting
	if ( db_CaseSensitive==TRUE )													; if case-sensitivity shall be turned on
		StringCaseSense, On															; turn on case sensitivity
	else																			; else (case-sensitivity shall be turned off)
		StringCaseSense, Off														; turn off case sensitivity

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {											; if neither row nor column is specified
		Loop, read, %db_DatabaseName%												; loop through database (row by row)
		{																			; {
			db_LineNumber := A_Index												; store line number
			Loop, parse, A_LoopReadLine, %A_Tab%									; loop through cells on row (cell by cell)
				if ( A_Index==1 AND db_SkipFirstRow==TRUE )							; if first row and first row shall be skipped
					continue														; continue loop from beginning (next iteration)
				else IfEqual, A_LoopField, %db_SearchTerm%							; if cell contains search term (note: IfNotEqual can handle case-sensitivity)
				{																	; {
					if !( db_Occurrence==1 ) {										; if this is not the correct occurrence
						db_Occurrence--												; decrease variable by 1
						continue													; continue loop from beginning (next iteration)
					}
					db_CellLocation := Object()										; create array
					db_CellLocation[1] := db_LineNumber								; store row number in array
					db_CellLocation[2] := A_Index									; store column number in array
					return db_CellLocation											; return array
				}																	; }
		}																			; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {									; else if column is specified but row is not specified
		Loop, read, %db_DatabaseName%												; loop through database rows
		{																			; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE )								; if first row and first row shall be skipped
				continue															; continue loop from beginning (next iteration)			
			db_CellContent := StrSplit( A_LoopReadLine, A_Tab )[db_Column]			; store cell content
			IfEqual, db_CellContent, %db_SearchTerm%								; if cell contains search term (note: IfNotEqual can handle case-sensitivity)
			{																		; {
				if !( db_Occurrence==1 ) {											; if this is not the correct occurrence
					db_Occurrence--													; decrease variable by 1
					continue														; continue loop (from start)
				}
				db_CellLocation := Object()											; create array
				db_CellLocation[1] := A_Index										; store row number in array
				db_CellLocation[2] := db_Column										; store column number in array
				return db_CellLocation												; return array
			}																		; }
		}																			; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {									; else if row is specified but column is not specified
		FileReadLine, db_DatabaseRow, %db_DatabaseName%, %db_Row%					; read row of database
		Loop, parse, db_DatabaseRow, %A_Tab%										; loop through cells on row (cell by cell)
			IfEqual, A_LoopField, %db_SearchTerm%									; if cell contains search term (note: IfNotEqual can handle case-sensitivity)
			{																		; {
				if !( db_Occurrence==1 ) {											; if this is not the correct occurrence
					db_Occurrence--													; decrease variable by 1
					continue														; continue loop (from start)
				}
				db_CellLocation := Object()											; create array
				db_CellLocation[1] := db_Row										; store row number in array
				db_CellLocation[2] := A_Index										; store column number in array
				return db_CellLocation												; return array
			}																		; }
	}

	; If both row and column are specified:
	else {																			; else (both row and column are specified)
		db_CellContent := DatabaseGet(db_DatabaseName, db_Row, db_Column)			; store cell content
		IfEqual, db_CellContent, %db_SearchTerm%									; if cell contains search term (note: IfNotEqual can handle case-sensitivity)
		{																			; {
			if !( db_Occurrence==1 )												; if this is no the correct occurrence
				return 0															; return 0 (cannot be more than one occurrence)
			db_CellLocation := Object()												; create array
			db_CellLocation[1] := db_Row											; store row number in array
			db_CellLocation[2] := db_Column											; store column number in array
			return db_CellLocation													; return array
		}																			; }
	}

	; Restore case-sensitivity setting:
	StringCaseSense, %db_OriginalCaseSensitivity%									; restore case-sensitivity setting

return 0																			; return 0 (if search term is not found)
}

DatabaseFloor( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Round down values from a specified part of the database
; Example: DatabaseFloor( "database.txt" )															; round down all database values
; Example: DatabaseFloor( "database.txt", 2 )														; round down all database values in the second row
; Example: DatabaseFloor( "database.txt", , 2 )														; round down all database values in the second column
; Example: DatabaseFloor( "database.txt", 1, 2 )													; round down the value in the first row and second column
; Example: DatabaseFloor( "database.txt", , , TRUE )												; round down all database values, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Floor(A_LoopField) . A_Tab										; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Floor(A_LoopField) . "`r`n"										; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Floor(A_LoopField)												; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Floor(db_CellContent)									; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Floor(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Floor(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Floor(db_Cells[db_Column])									; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseGet( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Get content of a cell, a row or a column
; Example: CellValue := DatabaseGet( "database.txt", 3, 2 )								; return the content of the database cell on the third row and second column
; Example: CellRowAsArray := DatabaseGet( "database.txt", 3 )							; return the third database row (as array)
; Example: CellColumnAsArray := DatabaseGet( "database.txt", , 2 )						; return the second database column (as array)
; Example: CellColumnAsArray := DatabaseGet( "database.txt", , 2, TRUE )				; return the second database column (as array) but skip the first row

	; If both row and column are specified;
	if ( !(db_Row=="") AND !(db_Column=="") ) {											; if row and column are specified
		FileReadLine, db_DatabaseRow, %db_DatabaseName%, %db_Row%						; read row
		db_Cells := StrSplit( db_DatabaseRow, A_Tab )									; split row into cells
		return % db_Cells[db_Column]													; return correct cell content
	}

	; If row but not column is specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {										; if row but not column is specified
		FileReadLine, db_DatabaseRow, %db_DatabaseName%, %db_Row%						; read row
		db_Cells := StrSplit( db_DatabaseRow, A_Tab )									; split row into cells
		return % db_Cells																; return cells (as array)
	}

	; If column but not row is specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {										; if column but not row is specified
		db_CellsToReturn := Object()													; create array to return
		Loop, read, %db_DatabaseName%													; loop through database rows
			if ( A_Index==1 AND db_SkipFirstRow==TRUE )									; if first row and first row shall be skipped
				continue																; continue loop (next iteration)
			else																		; else (if not first row and first row shall be skipped)
				db_CellsToReturn.Push( StrSplit( A_LoopReadLine, A_Tab )[db_Column] )	; store column cell in array
		return % db_CellsToReturn														; return cells of specified column
	}

return																					; return nothing (if no row nor column is specified)
}

DatabaseGetEncoding( db_DatabaseName ) { ; Return database encoding
; Example: Encoding := DatabaseGetEncoding( "database.txt" )	; show database encoding
;          MsgBox, %Encoding%									;

	; Store the database encoding:
	db_DatabaseOpen := FileOpen( db_DatabaseName, "r" )			; open database file (for writing)
	db_DatabaseEncoding := db_DatabaseOpen.Encoding()			; store database encoding
	db_DatabaseOpen.Close()										; close database file

return db_DatabaseEncoding										; return encoding
}

DatabaseGetLargest( db_DatabaseName, db_Row:="", db_Column:="", db_Order:=1, db_SkipFirstRow:=FALSE ) { ; Return the nth (db_Order) largest value from specified part of database
; Example: LargestValue := DatabaseGetLargest( "database.txt" )											; present the largest value of database (assumed to only contain values)
;          MsgBox, The largest value is: %LargestValue%													;
; Example; LargestValue := DatabaseGetLargest( "database.txt", 2 )										; store the largest value of the second row
; Example: LargestValue := DatabaseGetLargest( "database.txt", , 3 )									; store the largest value of the third column
; Example: SecondLargestValue := DatabaseGetLargest( "database.txt", , 3, 2 )							; store the second largest value of the third row
; Example: SecondLargestValue := DatabaseGetLargest( "database.txt", , , 2, TRUE )						; store the second largest value of database, when skipping the first row

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {																; if neither row nor column is specified
		db_MaxValues := Object()																		; initiate an array
		Loop, read, %db_DatabaseName%																	; loop through database (row by row)
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			Loop, parse, A_LoopReadLine, %A_Tab%														; loop through cells on row (cell by cell)
				if ( db_MaxValues.MaxIndex()=="" ) {													; if first cell
					db_MaxValues.Push( A_LoopField )													; store cell content (value) in array
					continue																			; continue loop (next iteration)
				} else if ( db_MaxValues.MaxIndex()<db_Order OR A_LoopField>db_MaxValues[db_Order] ) { 	; else if array is not filled, or cell is larger than smallest (full) array element
					if ( A_LoopField>db_MaxValues[db_Order] )											; if cell value is larger than smallest array element (of full array)
						db_MaxValues.RemoveAt( db_Order )												; remove smallest value in array
					Loop, % db_MaxValues.MaxIndex()														; loop number of values in array
						if ( A_LoopField>db_MaxValues[A_Index] ) {										; if current cell value is larger than current array element
							db_MaxValues.InsertAt( A_Index, A_LoopField )								; insert the current cell value at current position in array
							goto, db_value_added_to_list_4												; go to label
						}
					db_MaxValues.Push( A_LoopField )													; add cell content to end of array
					db_value_added_to_list_4:															; label
				}
		}																								; }
		return db_MaxValues[db_Order]																	; return value
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {														; else if column is specified but row is not specified
		db_MaxValues := Object()																		; initiate an array
		Loop, read, %db_DatabaseName%																	; loop through database rows
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			db_Cell := StrSplit( A_LoopReadLine, A_Tab )[db_Column]										; split row into cells
			if ( db_MaxValues.MaxIndex()=="" ) {														; if first cell
				db_MaxValues.Push( db_Cell )															; store cell content (value) in array
				continue																				; continue loop (next iteration)
			} else if ( db_MaxValues.MaxIndex()<db_Order OR db_Cell>db_MaxValues[db_Order] ) { 			; else if array is not filled, or cell is larger than smallest (full) array element
				if ( db_Cell>db_MaxValues[db_Order] )													; if cell value is larger than smallest array element (of full array)
					db_MaxValues.RemoveAt( db_Order )													; remove largest value in array
				Loop, % db_MaxValues.MaxIndex()															; loop number of values in array
					if ( db_Cell>db_MaxValues[A_Index] ) {												; if current cell value is larger than current array element
						db_MaxValues.InsertAt( A_Index, db_Cell )										; insert the current cell value at current position in array
						goto, db_value_added_to_list_5													; go to label
					}
				db_MaxValues.Push( db_Cell )															; add cell content to end of array
				db_value_added_to_list_5:																; label
			}
		}																								; }
		return db_MaxValues[db_Order]																	; return value
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {														; else if row is specified but column is not specified
		db_MaxValues := Object()																		; initiate an array
		FileReadLine, db_DatabaseRow, %db_DatabaseName%, %db_Row%										; read row of database
		Loop, parse, db_DatabaseRow, %A_Tab%															; loop through cells on row (cell by cell)
		{																								; {
			if ( db_MaxValues.MaxIndex()=="" ) {														; if first cell
				db_MaxValues.Push( A_LoopField )														; store cell content (value) in array
				continue																				; continue loop (next iteration)
			} else if ( db_MaxValues.MaxIndex()<db_Order OR A_LoopField>db_MaxValues[db_Order] ) { 		; else if array is not filled, or cell is larger than smallest (full) array element
				if ( A_LoopField>db_MaxValues[db_Order] )												; if cell value is larger than smallest array element (of full array)
					db_MaxValues.RemoveAt( db_Order )													; remove largest value in array
				Loop, % db_MaxValues.MaxIndex()															; loop number of values in array
					if ( A_LoopField>db_MaxValues[A_Index] ) {											; if current cell value is larger than current array element
						db_MaxValues.InsertAt( A_Index, A_LoopField )									; insert the current cell value at current position in array
						goto, db_value_added_to_list_6													; go to label
					}
				db_MaxValues.Push( A_LoopField )														; add cell content to end of array
				db_value_added_to_list_6:																; label
			}
		}																								; }
		return db_MaxValues[db_Order]																	; return value
	}
	
	; If both row and column are specified:
	else if ( db_Order==1 )																				; else (if both row and column are specified) and the largest value shall be returned
		return DatabaseGet( db_DatabaseName, db_Row, db_Column )										; return cell content

return																									; return (nothing)
}

DatabaseGetMean( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Return the mean value from specified part of database
; Example: MeanValue := DatabaseGetMean( "database.txt" )												; show the mean cell value of database
;          MsgBox, The mean cell value is: %MeanValue%													;
; Example: MeanValue := DatabaseGetMean( "database.txt", , , TRUE )										; store the mean cell value of database, when excluding the first row
; Example: MeanValue := DatabaseGetMean( "database.txt", 2 )											; store the mean cell value of the second row
; Example: MeanValue := DatabaseGetMean( "database.txt", , 3 )											; store the mean cell value of the third column
; Example: MeanValue := DatabaseGetMean( "database.txt", , 3, TRUE )									; store the mean cell value of the third column, when excluding the first row

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {																; if neither row nor column is specified
		db_SumOfValues := 0																				; initiate variable
		Loop, read, %db_DatabaseName%																	; loop through database (row by row)
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			Loop, parse, A_LoopReadLine, %A_Tab%														; loop through cells on row (cell by cell)
				db_SumOfValues += A_LoopField															; add cell value to variable
		}																								; }
		return db_SumOfValues/DatabaseGetNumberOfCells( db_DatabaseName, db_SkipFirstRow )				; return mean value
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {														; else if column is specified but row is not specified
		db_SumOfValues := 0																				; initiate variable
		Loop, read, %db_DatabaseName%																	; loop through database rows
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			db_SumOfValues += StrSplit( A_LoopReadLine, A_Tab )[db_Column]								; add cell value to variable
		}																								; }
		return db_SumOfValues/DatabaseGetNumberOfRows( db_DatabaseName, db_SkipFirstRow )				; return mean value
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {														; else if row is specified but column is not specified
		db_SumOfValues := 0																				; initiate variable
		FileReadLine, db_DatabaseRow, %db_DatabaseName%, %db_Row%										; read row of database
		Loop, parse, db_DatabaseRow, %A_Tab%															; loop through cells on row (cell by cell)
			db_SumOfValues += A_LoopField																; add cell value to variable
		return db_SumOfValues/DatabaseGetNumberOfColumns( db_DatabaseName )								; return mean value
	}

	; If both row and column are specified:
	else																								; else (if both row and column are specified)
		return DatabaseGet( db_DatabaseName, db_Row, db_Column )										; return cell content (mean value)

return																									; return (nothing)
}

DatabaseGetMedian( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Return the median value from specified part of database
; Example: Median := DatabaseGetMedian( "database.txt" )												; present median of database cell values
;          MsgBox, The median is: %Median%																;
; Example: Median := DatabaseGetMedian( "database.txt", 2 )												; store median of values in second database row
; Example: Median := DatabaseGetMedian( "database.txt", , 2 )											; store median of values in third database column
; Example: Median := DatabaseGetMedian( "database.txt", , , TRUE )										; store median of database cell values, with the first row excluded

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {																; if neither row nor column is specified
		db_Order := Ceil((DatabaseGetNumberOfCells(db_DatabaseName, db_SkipFirstRow)+1)/2)				; store the number of (largest) values to keep in array (so median can be determined)
		db_MaxValues := Object()																		; initiate an array
		Loop, read, %db_DatabaseName%																	; loop through database (row by row)
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			Loop, parse, A_LoopReadLine, %A_Tab%														; loop through cells on row (cell by cell)
				if ( db_MaxValues.MaxIndex()=="" ) {													; if first cell
					db_MaxValues.Push( A_LoopField )													; store cell content (value) in array
					continue																			; continue loop (next iteration)
				} else if ( db_MaxValues.MaxIndex()<db_Order OR A_LoopField>db_MaxValues[db_Order] ) { 	; else if array is not filled, or cell is larger than smallest (full) array element
					if ( A_LoopField>db_MaxValues[db_Order] )											; if cell value is larger than smallest array element (of full array)
						db_MaxValues.RemoveAt( db_Order )												; remove smallest value in array
					Loop, % db_MaxValues.MaxIndex()														; loop number of values in array
						if ( A_LoopField>db_MaxValues[A_Index] ) {										; if current cell value is larger than current array element
							db_MaxValues.InsertAt( A_Index, A_LoopField )								; insert the current cell value at current position in array
							goto, db_value_added_to_list_7												; go to label
						}
					db_MaxValues.Push( A_LoopField )													; add cell content to end of array
					db_value_added_to_list_7:															; label
				}
		}																								; }
		if ( Mod(DatabaseGetNumberOfCells(db_DatabaseName, db_SkipFirstRow), 2)==0 )					; if median is calculated from an even number of cells
			return (db_MaxValues[db_Order-1]+db_MaxValues[db_Order])/2									; return median
		else																							; else (median is calculated from an odd number of cells)
			return db_MaxValues[db_Order]																; return median
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {														; else if column is specified but row is not specified
		db_Order := Ceil((DatabaseGetNumberOfRows(db_DatabaseName, db_SkipFirstRow)+1)/2)				; store the number of (largest) values to keep in array (so median can be determined)
		db_MaxValues := Object()																		; initiate an array
		Loop, read, %db_DatabaseName%																	; loop through database rows
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			db_Cell := StrSplit( A_LoopReadLine, A_Tab )[db_Column]										; split row into cells
			if ( db_MaxValues.MaxIndex()=="" ) {														; if first cell
				db_MaxValues.Push( db_Cell )															; store cell content (value) in array
				continue																				; continue loop (next iteration)
			} else if ( db_MaxValues.MaxIndex()<db_Order OR db_Cell>db_MaxValues[db_Order] ) { 			; else if array is not filled, or cell is larger than smallest (full) array element
				if ( db_Cell>db_MaxValues[db_Order] )													; if cell value is larger than smallest array element (of full array)
					db_MaxValues.RemoveAt( db_Order )													; remove largest value in array
				Loop, % db_MaxValues.MaxIndex()															; loop number of values in array
					if ( db_Cell>db_MaxValues[A_Index] ) {												; if current cell value is larger than current array element
						db_MaxValues.InsertAt( A_Index, db_Cell )										; insert the current cell value at current position in array
						goto, db_value_added_to_list_8													; go to label
					}
				db_MaxValues.Push( db_Cell )															; add cell content to end of array
				db_value_added_to_list_8:																; label
			}
		}																								; }
		if ( Mod(DatabaseGetNumberOfRows(db_DatabaseName, db_SkipFirstRow), 2)==0 )						; if median is calculated from an even number of cells
			return (db_MaxValues[db_Order-1]+db_MaxValues[db_Order])/2									; return median
		else																							; else (median is calculated from an odd number of cells)
			return db_MaxValues[db_Order]																; return median
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {														; else if row is specified but column is not specified
		db_Order := Ceil((DatabaseGetNumberOfColumns(db_DatabaseName)+1)/2)								; store the number of (largest) values to keep in array (so median can be determined)
		db_MaxValues := Object()																		; initiate an array
		FileReadLine, db_DatabaseRow, %db_DatabaseName%, %db_Row%										; read row of database
		Loop, parse, db_DatabaseRow, %A_Tab%															; loop through cells on row (cell by cell)
		{																								; {
			if ( db_MaxValues.MaxIndex()=="" ) {														; if first cell
				db_MaxValues.Push( A_LoopField )														; store cell content (value) in array
				continue																				; continue loop (next iteration)
			} else if ( db_MaxValues.MaxIndex()<db_Order OR A_LoopField>db_MaxValues[db_Order] ) { 		; else if array is not filled, or cell is larger than smallest (full) array element
				if ( A_LoopField>db_MaxValues[db_Order] )												; if cell value is larger than smallest array element (of full array)
					db_MaxValues.RemoveAt( db_Order )													; remove largest value in array
				Loop, % db_MaxValues.MaxIndex()															; loop number of values in array
					if ( A_LoopField>db_MaxValues[A_Index] ) {											; if current cell value is larger than current array element
						db_MaxValues.InsertAt( A_Index, A_LoopField )									; insert the current cell value at current position in array
						goto, db_value_added_to_list_9													; go to label
					}
				db_MaxValues.Push( A_LoopField )														; add cell content to end of array
				db_value_added_to_list_9:																; label
			}
		}																								; }
		if ( Mod(DatabaseGetNumberOfColumns(db_DatabaseName), 2)==0 )									; if median is calculated from an even number of cells
			return (db_MaxValues[db_Order-1]+db_MaxValues[db_Order])/2									; return median
		else																							; else (median is calculated from an odd number of cells)
			return db_MaxValues[db_Order]																; return median
	}
	
	; If both row and column are specified:
	else																								; else (if both row and column are specified)
		return DatabaseGet( db_DatabaseName, db_Row, db_Column )										; return cell content (median)

return																									; return (nothing)
}

DatabaseGetNumberOfCells( db_DatabaseName, db_SkipFirstRow:=FALSE ) { ; Return the number of cells in database (including first row)
; Example: MsgBox, % DatabaseGetNumberOfCells( "database.txt" )												; show the number of database cells
; Example: NumberOfCells := DatabaseGetNumberOfCells( "database.txt" )										; store the number of database cells
; Example: NumberOfCells := DatabaseGetNumberOfCells( "database.txt", TRUE )								; store the number of database cells, without the first row

	; Return the number of database cells (if the first row shall not be skipped):
	if ( db_SkipFirstRow==FALSE )																			; if the first row shall be skipped
		return DatabaseGetNumberOfRows( db_DatabaseName ) * DatabaseGetNumberOfColumns( db_DatabaseName )	; return number of database rows (including the first row)

return (DatabaseGetNumberOfRows( db_DatabaseName )-1) * DatabaseGetNumberOfColumns( db_DatabaseName )		; return number of database rows (excluding the first row)
}

DatabaseGetNumberOfColumns( db_DatabaseName ) { ; Return the number of columns in database (row 1)
; Example: NumberOfColumns := DatabaseGetNumberOfColumns( "database.txt" )		; print number of columns in "database.txt"
;          MsgBox, Database has %NumberOfColumns% columns.						;

	; Divide row of database into cells:
	FileReadLine, db_DatabaseRow, %db_DatabaseName%, 1							; read row of database
	db_Cells := StrSplit( db_DatabaseRow, A_Tab )								; split row into cells and store in array

return db_Cells.Length()														; return number of cells in array (i.e., number of columns)
}

DatabaseGetNumberOfRows( db_DatabaseName, db_SkipFirstRow:=FALSE ) { ; Return the number of rows in database
; Example: NumberOfRows := DatabaseGetNumberOfRows( "database.txt" )		; print number of rows in "database.txt"
;          MsgBox, Database has %NumberOfRows% rows.						;

	; Find number of rows in database:
	db_CountRows := 0														; prepare a variable for counting rows
	Loop, Read, %db_DatabaseName%											; loop through rows of database
		db_CountRows++														; increase counting variable by 1

	; Return adjusted number of rows if the first row shall be skipped:
	if ( db_SkipFirstRow==TRUE )											; if the first row shall be skipped:
		return db_CountRows-1												; return the total number of rows subtracted by 1 

return db_CountRows															; return the number of rows
}

DatabaseGetSmallest( db_DatabaseName, db_Row:="", db_Column:="", db_Order:=1, db_SkipFirstRow:=FALSE ) { ; Return the nth ("db_Order") smallest value from specified part of database
; Example: SmallestValue := DatabaseGetSmallest( "database.txt" )										; present the smallest value of database (assumed to only contain values)
;          MsgBox, The smallest value is: %SmallestValue%												;
; Example; SmallestValue := DatabaseGetSmallest( "database.txt", 2 )									; store the smallest value of the second row
; Example: SmallestValue := DatabaseGetSmallest( "database.txt", , 3 )									; store the smallest value of the third column
; Example: SecondSmallestValue := DatabaseGetSmallest( "database.txt", , 3, 2 )							; store the second smallest value of the third row
; Example: SecondSmallestValue := DatabaseGetSmallest( "database.txt", , , 2, TRUE )					; store the second smallest value of database, when skipping the first row

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {																; if neither row nor column is specified
		db_MinValues := Object()																		; initiate an array
		Loop, read, %db_DatabaseName%																	; loop through database (row by row)
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			Loop, parse, A_LoopReadLine, %A_Tab%														; loop through cells on row (cell by cell)
				if ( db_MinValues.MaxIndex()=="" ) {													; if first cell
					db_MinValues.Push( A_LoopField )													; store cell content (value) in array
					continue																			; continue loop (next iteration)
				} else if ( db_MinValues.MaxIndex()<db_Order OR A_LoopField<db_MinValues[db_Order] ) { 	; else if array is not filled, or cell is smaller than largest (full) array element
					if ( A_LoopField<db_MinValues[db_Order] )											; if cell value is smaller than largest array element (of full array)
						db_MinValues.RemoveAt( db_Order )												; remove largest value in array
					Loop, % db_MinValues.MaxIndex()														; loop number of values in array
						if ( A_LoopField<db_MinValues[A_Index] ) {										; if current cell value is smaller than current array element
							db_MinValues.InsertAt( A_Index, A_LoopField )								; insert the current cell value at current position in array
							goto, db_value_added_to_list_1												; go to label
						}
					db_MinValues.Push( A_LoopField )													; add cell content to end of array
					db_value_added_to_list_1:															; label
				}
		}																								; }
		return db_MinValues[db_Order]																	; return value
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {														; else if column is specified but row is not specified
		db_MinValues := Object()																		; initiate an array
		Loop, read, %db_DatabaseName%																	; loop through database rows
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			db_Cell := StrSplit( A_LoopReadLine, A_Tab )[db_Column]										; split row into cells
			if ( db_MinValues.MaxIndex()=="" ) {														; if first cell
				db_MinValues.Push( db_Cell )															; store cell content (value) in array
				continue																				; continue loop (next iteration)
			} else if ( db_MinValues.MaxIndex()<db_Order OR db_Cell<db_MinValues[db_Order] ) { 			; else if array is not filled, or cell is smaller than largest (full) array element
				if ( db_Cell<db_MinValues[db_Order] )													; if cell value is smaller than largest array element (of full array)
					db_MinValues.RemoveAt( db_Order )													; remove largest value in array
				Loop, % db_MinValues.MaxIndex()															; loop number of values in array
					if ( db_Cell<db_MinValues[A_Index] ) {												; if current cell value is smaller than current array element
						db_MinValues.InsertAt( A_Index, db_Cell )										; insert the current cell value at current position in array
						goto, db_value_added_to_list_2													; go to label
					}
				db_MinValues.Push( db_Cell )															; add cell content to end of array
				db_value_added_to_list_2:																; label
			}
		}																								; }
		return db_MinValues[db_Order]																	; return value
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {														; else if row is specified but column is not specified
		db_MinValues := Object()																		; initiate an array
		FileReadLine, db_DatabaseRow, %db_DatabaseName%, %db_Row%										; read row of database
		Loop, parse, db_DatabaseRow, %A_Tab%															; loop through cells on row (cell by cell)
		{																								; {
			if ( db_MinValues.MaxIndex()=="" ) {														; if first cell
				db_MinValues.Push( A_LoopField )														; store cell content (value) in array
				continue																				; continue loop (next iteration)
			} else if ( db_MinValues.MaxIndex()<db_Order OR A_LoopField<db_MinValues[db_Order] ) { 		; else if array is not filled, or cell is smaller than largest (full) array element
				if ( A_LoopField<db_MinValues[db_Order] )												; if cell value is smaller than largest array element (of full array)
					db_MinValues.RemoveAt( db_Order )													; remove largest value in array
				Loop, % db_MinValues.MaxIndex()															; loop number of values in array
					if ( A_LoopField<db_MinValues[A_Index] ) {											; if current cell value is smaller than current array element
						db_MinValues.InsertAt( A_Index, A_LoopField )									; insert the current cell value at current position in array
						goto, db_value_added_to_list_3													; go to label
					}
				db_MinValues.Push( A_LoopField )														; add cell content to end of array
				db_value_added_to_list_3:																; label
			}
		}																								; }
		return db_MinValues[db_Order]																	; return value
	}
	
	; If both row and column are specified:
	else if ( db_Order==1 )																				; else (if both row and column are specified) and the smallest value shall be returned
		return DatabaseGet( db_DatabaseName, db_Row, db_Column )										; return cell content

return																									; return (nothing)
}

DatabaseGetSum( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Return sum of values from specified part of database
; Example: Sum := DatabaseGetSum( "database.txt" )														; show sum of (all) cell values
;          MsgBox, The sum is: %Sum%																	;
; Example: Sum := DatabaseGetSum( "database.txt", , , TRUE )											; store sum of cell values (with first row excluded)
; Example: Sum := DatabaseGetSum( "database.txt", 2 )													; store sum of values in second row
; Example: Sum := DatabaseGetSum( "database.txt", , 1 )													; store sum of values in first column

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {																; if neither row nor column is specified
		db_SumOfValues := 0																				; initiate variable
		Loop, read, %db_DatabaseName%																	; loop through database (row by row)
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			Loop, parse, A_LoopReadLine, %A_Tab%														; loop through cells on row (cell by cell)
				db_SumOfValues += A_LoopField															; add cell value to variable
		}																								; }
		return db_SumOfValues																			; return sum
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {														; else if column is specified but row is not specified
		db_SumOfValues := 0																				; initiate variable
		Loop, read, %db_DatabaseName%																	; loop through database rows
		{																								; {
			if ( db_SkipFirstRow==TRUE and A_Index==1 )													; if first row and it shall be skipped
				continue																				; continue loop (next iteration)
			db_SumOfValues += StrSplit( A_LoopReadLine, A_Tab )[db_Column]								; add cell value to variable
		}																								; }
		return db_SumOfValues																			; return sum
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {														; else if row is specified but column is not specified
		db_SumOfValues := 0																				; initiate variable
		FileReadLine, db_DatabaseRow, %db_DatabaseName%, %db_Row%										; read row of database
		Loop, parse, db_DatabaseRow, %A_Tab%															; loop through cells on row (cell by cell)
			db_SumOfValues += A_LoopField																; add cell value to variable
		return db_SumOfValues																			; return sum
	}

	; If both row and column are specified:
	else																								; else (if both row and column are specified)
		return DatabaseGet( db_DatabaseName, db_Row, db_Column )										; return cell content (sum)

return																									; return (nothing)	
}

DatabaseGetRandomCell( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Return content of a randomly selected cell
; Example: RandomCell := DatabaseGetRandomCell( "database.txt" )						; show content of a randomly selected cell
;          MsgBox, The randomly selected cell contains: %RandomCell%					;
; Example: RandomCell := DatabaseGetRandomCell( "database.txt", 2 )						; store content of a randomly selected cell from the second row
; Example: RandomCell := DatabaseGetRandomCell( "database.txt", , 3 )					; store content of a randomly selected cell from the third column
; Example: RandomCell := DatabaseGetRandomCell( "database.txt", , , TRUE )				; store content of a randomly selected cell, but skip the first row

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {												; if neither row nor column is specified
		if ( db_SkipFirstRow==TRUE )													; if the first row shall be skipped
			Random, db_RandomRow, 2, DatabaseGetNumberOfRows( db_DatabaseName )			; store randomly selected database row
		else																			; else (if the first row shall not be skipped)
			Random, db_RandomRow, 1, DatabaseGetNumberOfRows( db_DatabaseName )			; store randomly selected database row
		Random, db_RandomColumn, 1, DatabaseGetNumberOfColumns( db_DatabaseName )		; store randomly selected database column number
		return DatabaseGet( db_DatabaseName, db_RandomRow, db_RandomColumn )			; return cell
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {										; else if column is specified but row is not specified
		if ( db_SkipFirstRow==TRUE )													; if the first row shall be skipped
			Random, db_RandomRow, 2, DatabaseGetNumberOfRows( db_DatabaseName )			; store randomly selected database row
		else																			; else (if the first row shall not be skipped)
			Random, db_RandomRow, 1, DatabaseGetNumberOfRows( db_DatabaseName )			; store randomly selected database row
		return DatabaseGet( db_DatabaseName, db_RandomRow, db_Column )					; return cell
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {										; else if row is specified but column is not specified
		Random, db_RandomColumn, 1, DatabaseGetNumberOfColumns( db_DatabaseName )		; store randomly selected database column
		return DatabaseGet( db_DatabaseName, db_Row, db_RandomColumn )					; return cell
	}

	; If row and column are specified:
	else																				; else (if both row and column are specified)
		return DatabaseGet( db_DatabaseName, db_Row, db_Column )						; return cell

return																					; return
}

DatabaseGetRandomCellLocation( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Return location of a randomly selected cell
; Example: Location := DatabaseGetRandomCellLocation( "database.txt" )						; show location of a randomly selected cell
;          MsgBox, % "Location of random cell: (" . Location[1] . "," . Location[2] . ")"	;
; Example: RandomCell := DatabaseGetRandomCellLocation( "database.txt", 2 )					; store content of a randomly selected cell from the second row
; Example: RandomCell := DatabaseGetRandomCellLocation( "database.txt", , 3 )				; store content of a randomly selected cell from the third column
; Example: RandomCell := DatabaseGetRandomCellLocation( "database.txt", , , TRUE )			; store content of a randomly selected cell, but skip the first row

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {													; if neither row nor column is specified
		if ( db_SkipFirstRow==TRUE )														; if the first row shall be skipped
			Random, db_RandomRow, 2, DatabaseGetNumberOfRows( db_DatabaseName )				; store randomly selected database row
		else																				; else (if the first row shall not be skipped)
			Random, db_RandomRow, 1, DatabaseGetNumberOfRows( db_DatabaseName )				; store randomly selected database row
		Random, db_RandomColumn, 1, DatabaseGetNumberOfColumns( db_DatabaseName )			; store randomly selected database column number
		return [db_RandomRow, db_RandomColumn]												; return cell location
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {											; else if column is specified but row is not specified
		if ( db_SkipFirstRow==TRUE )														; if the first row shall be skipped
			Random, db_RandomRow, 2, DatabaseGetNumberOfRows( db_DatabaseName )				; store randomly selected database row
		else																				; else (if the first row shall not be skipped)
			Random, db_RandomRow, 1, DatabaseGetNumberOfRows( db_DatabaseName )				; store randomly selected database row
		return [db_RandomRow, db_Column]													; return cell location
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {											; else if row is specified but column is not specified
		Random, db_RandomColumn, 1, DatabaseGetNumberOfColumns( db_DatabaseName )			; store randomly selected database column
		return [db_Row, db_RandomColumn]													; return cell location
	}

	; If row and column are specified:
	else																					; else (if both row and column are specified)
		return [db_Row, db_Column]															; return cell location

return																						; return
}

DatabaseGetRandomColumn( db_DatabaseName ) { ; Return a randomly selected database column (as array)
; Example: RandomColumn := DatabaseGetRandomColumn( "database.txt" )				; present a randomly selected database column
;          For Index, Value in RandomColumn											;
;              ColumnElements .= Value . " "										;
;          MsgBox, Elements of randomly selected column: %ColumnElements%			;

	; Randomly select a column:
	Random, db_RandomColumn, 1, DatabaseGetNumberOfColumns( db_DatabaseName )	; store randomly selected database column

return DatabaseGet( db_DatabaseName, , db_RandomColumn )							; return randomly selected database column
}

DatabaseGetRandomColumnNumber( db_DatabaseName ) { ; Return a randomly selected database column number
; Example: DatabaseColumn := DatabaseGetRandomColumnNumber( "database.txt" )	; present a randomly selected database column
;          MsgBox, Randomly selected column number: %DatabaseColumn%			;

	; Randomly select a column:
	Random, db_RandomColumn, 1, DatabaseGetNumberOfColumns( db_DatabaseName )	; store randomly selected database column

return %db_RandomColumn%														; return randomly selected database column number
}

DatabaseGetRandomRow( db_DatabaseName, db_SkipFirstRow:=FALSE ) { ; Return a randomly selected database row (as array)
; Example: RandomRow := DatabaseGetRandomRow( "database.txt" )					; present a randomly selected database row
;          For Index, Value in RandomRow										;
;              RowElements .= Value . " "										;
;          MsgBox, Elements of randomly selected row: %RowElements%				;

	; Randomly select a row:
	if ( db_SkipFirstRow==TRUE )												; if first row shall be skipped
		Random, db_RandomRow, 2, DatabaseGetNumberOfRows( db_DatabaseName )		; store randomly selected database row
	else																		; else (if first row shall not be skipped)
		Random, db_RandomRow, 1, DatabaseGetNumberOfRows( db_DatabaseName )		; store randomly selected database row

return DatabaseGet( db_DatabaseName, db_RandomRow )								; return randomly selected database row
}

DatabaseGetRandomRowNumber( db_DatabaseName, db_SkipFirstRow:=FALSE ) { ; Return a randomly selected database row number
; Example: DatabaseRow := DatabaseGetRandomRowNumber( "database.txt" )			; present a randomly selected database row
;          MsgBox, Randomly selected row number: %DatabaseRow%					;

	; Randomly select a row:
	if ( db_SkipFirstRow==TRUE )												; if first row shall be skipped
		Random, db_RandomRow, 2, DatabaseGetNumberOfRows( db_DatabaseName )		; store randomly selected database row
	else																		; else (if first row shall not be skipped)
		Random, db_RandomRow, 1, DatabaseGetNumberOfRows( db_DatabaseName )		; store randomly selected database row

return %db_RandomRow%															; return randomly selected database row number
}

DatabaseImportCSV( db_InputFile, db_OutputFile:="", db_Overwrite:=FALSE ) { ; Import (convert) CSV-file to tab-separated database
; Example: DatabaseImportCSV( "database.csv" )					; convert "database.csv" to (tab-separated) "database.txt" (does not overwrite if file exists)
; Example: DatabaseImportCSV( "database.csv", , TRUE )			; convert "database.csv" to (tab-separated) "database.txt", and overwrites if file exists
; Example: DatabaseImportCSV( "input.csv", "output.txt" )		; convert "input.csv" to (tab-separated) "output.txt"
; Example: if ( DatabaseImportCSV( "database.csv" ) )			; convert database and informs about whether or not conversion completed
;              MsgBox, Conversion completed.					;
;          else													;
;              MsgBox, Conversion did not complete.				;

	; Create output filename if not specified:
	if ( db_OutputFile=="" ) {									; if no output filename
		SplitPath, db_InputFile, , , , db_OutputFile			; get input filename without extension
		db_OutputFile .= ".txt"									; add ".txt" as file extension
	}

	; Delete output file (if it exists and it is permitted):
	IfExist, %db_OutputFile%									; if output filename exist
	{															; {
		if ( db_Overwrite==FALSE )								; if no permission to overwrite
			return 0											; return 0
		FileDelete, %db_OutputFile%								; delete file
	}															; }

	; Convert file:
	Loop, read, %db_InputFile%, %db_OutputFile%					; loop through input file
	{															; {
		IfExist, %db_OutputFile%								; if file exist (i.e., if not the first row)
			FileAppend, `r`n									; append linebreak
		Loop, parse, A_LoopReadLine, CSV						; loop through cells on row
		{														; {
			if !( A_Index==1 )									; if not the first cell of the row
				FileAppend, `t%A_LoopField%						; append tab followed by cell content
			else												; else
				FileAppend, %A_LoopField%						; append cell content
		}														; }
	}															; }

return 1														; return 1 (no problem detected)
}

DatabaseInsertColumn( db_DatabaseName, db_Column
					, db_Row1:=""	, db_Row2:=""	, db_Row3:=""	, db_Row4:=""	, db_Row5:=""
					, db_Row6:=""	, db_Row7:=""	, db_Row8:=""	, db_Row9:=""	, db_Row10:=""
					, db_Row11:=""	, db_Row12:=""	, db_Row13:=""	, db_Row14:=""	, db_Row15:=""
					, db_Row16:=""	, db_Row17:=""	, db_Row18:=""	, db_Row19:=""	, db_Row20:=""
					, db_Row21:=""	, db_Row22:=""	, db_Row23:=""	, db_Row24:=""	, db_Row25:=""
					, db_Row26:=""	, db_Row27:=""	, db_Row28:=""	, db_Row29:=""	, db_Row30:=""
					, db_Row31:=""	, db_Row32:=""	, db_Row33:=""	, db_Row34:=""	, db_Row35:=""
					, db_Row36:=""	, db_Row37:=""	, db_Row38:=""	, db_Row39:=""	, db_Row40:=""
					, db_Row41:=""	, db_Row42:=""	, db_Row43:=""	, db_Row44:=""	, db_Row45:=""
					, db_Row46:=""	, db_Row47:=""	, db_Row48:=""	, db_Row49:=""	, db_Row50:="" ) { ; Insert a new database column at specified location.
; Example: DatabaseInsertColumn( "database.txt", 3)											; insert a new third database column (with empty cells)
; Example: DatabaseInsertColumn( "database.txt", 1, "First", "Second", "Third" )			; insert a new first database column (with the first three cells specified)

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Save database with new column added:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )						; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		db_TabBeforeCell := InStr( A_LoopReadLine, A_Tab, , , db_Column-1 )					; store position of tab just before new column's location
		if ( db_TabBeforeCell==0 ) 															; if new column shall be the first column of database
			db_RowOutput := db_Row%A_Index% . A_Tab . A_LoopReadLine						; store new column followed by tab and original row
		else {  																			; else (new column shall not be the first column of database)
			db_LeftPartOfRow := Substr( A_LoopReadLine, 1, db_TabBeforeCell )				; store part of row to the left of new cell's content
			db_RightPartOfRow := SubStr( A_LoopReadLine, db_TabBeforeCell )					; store part of row to the right of new cell's content
			db_RowOutput := db_LeftPartOfRow . db_Row%A_Index% . db_RightPartOfRow			; combine parts to create row with new cell included
		}
		if ( A_Index<db_NumberOfRows )														; if not the last row of database
			db_RowOutput .= "`r`n"															; add linebreak at the end of the row
		FileAppend, %db_RowOutput%															; add modified database row (with new column) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseInsertRow( db_DatabaseName, db_Row
				 , db_Column1:=""	, db_Column2:=""	, db_Column3:=""	, db_Column4:=""	, db_Column5:=""
				 , db_Column6:=""	, db_Column7:=""	, db_Column8:=""	, db_Column9:=""	, db_Column10:=""
				 , db_Column11:=""	, db_Column12:=""	, db_Column13:=""	, db_Column14:=""	, db_Column15:=""
				 , db_Column16:=""	, db_Column17:=""	, db_Column18:=""	, db_Column19:=""	, db_Column20:=""
				 , db_Column21:=""	, db_Column22:=""	, db_Column23:=""	, db_Column24:=""	, db_Column25:=""
				 , db_Column26:=""	, db_Column27:=""	, db_Column28:=""	, db_Column29:=""	, db_Column30:=""
				 , db_Column31:=""	, db_Column32:=""	, db_Column33:=""	, db_Column34:=""	, db_Column35:=""
				 , db_Column36:=""	, db_Column37:=""	, db_Column38:=""	, db_Column39:=""	, db_Column40:=""
				 , db_Column41:=""	, db_Column42:=""	, db_Column43:=""	, db_Column44:=""	, db_Column45:=""
				 , db_Column46:=""	, db_Column47:=""	, db_Column48:=""	, db_Column49:=""	, db_Column50:="" ) { ; Insert database row (and move subsequent rows down one step)
; Example: DatabaseInsertRow( "database.txt", 5, "First", "Second", "Third" )		; insert new 5th row (and move existing rows down) with the first three columns specified
; Example: DatabaseInsertRow( "database.txt", 10, , "", "Third" )					; insert new 10th row (and move existing rows down) with the third column specified

	; Prepare new database row:
	db_NumberOfColumns := DatabaseGetNumberOfColumns( db_DatabaseName )				; store number of database columns
	while A_Index<db_NumberOfColumns												; loop (number of database columns minus 1)
		db_NewDatabaseRow .= db_Column%A_Index% . A_Tab								; add cell content followed by tab to string
	db_NewDatabaseRow .= db_Column%db_NumberOfColumns% . "`r`n"						; add last cell content without tab but with linebreak to string

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )	; rename database file (and store new filename)

	; Add new row to database:
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%							; loop through each row of database
	{																				; {
		if !( A_Index==1 )															; if not the first row
			FileAppend, `r`n														; add linebreak to output file
		if ( A_Index==db_Row )														; if row where new database row shall be placed
			FileAppend, %db_NewDatabaseRow%											; add new database row to output file
		FileAppend, %A_LoopReadLine%												; add database row (from input file) to output file
	}																				; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%												; delete (temporary) file

return																				; return
}

DatabaseIsNumeric( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Return 1 if only numeric cell content, 0 otherwise
; Example: if ( DatabaseIsNumeric("database.txt")==1 )			; inform whether database is numeric or not
;              MsgBox, Database is (entirely) numeric.			;
;          else													;
;              MsgBox, Database is not (entirely) numeric.		;
; Example: DatabaseIsNumeric( "database.txt" )					; return 1 if entire database is numeric, 0 otherwise
; Example: DatabaseIsNumeric( "database.txt", 2 )				; return 1 if entire second database row is numeric, 0 otherwise
; Example: DatabaseIsNumeric( "database.txt", , 3 )				; return 1 if entire third database column is numeric, 0 otherwise
; Example: DatabaseIsNumeric( "database.txt", 2, 3 )			; return 1 if cell 2x3 is numeric, 0 otherwise
; Example: DatabaseIsNumeric( "database.txt", , , TRUE )		; return 1 if entire database when excluding the first row is numeric, 0 otherwise
; Example: DatabaseIsNumeric( "database.txt", , 2, TRUE )		; return 1 if entire second column, when excluding the first cell, is numeric, 0 otherwise

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {											; if neither row nor column is specified
		Loop, read, %db_DatabaseName%												; loop through database (row by row)
			if ( db_SkipFirstRow==TRUE AND A_Index==1 )								; if first row shall be skipped and it is the first row
				continue															; continue loop from beginning (next iteration)
			else																	; else
				Loop, parse, A_LoopReadLine, %A_Tab%								; loop through cells on row (cell by cell)
					if A_LoopField is not digit										; if cell content is not numeric
						return 0													; return 0
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {									; if column is specified but row is not specified
		Loop, read, %db_DatabaseName%												; loop through database rows
		{																			; {
			if ( db_SkipFirstRow==TRUE AND A_Index==1 )								; if first row shall be skipped and it is the first row
				continue															; continue loop from beginning (next iteration)
			else {																	; else
				db_CellContent := StrSplit( A_LoopReadLine, A_Tab )[db_Column]		; store cell content
				if db_CellContent is not digit										; if cell content is not numeric
					return 0														; return 0
			}
		}																			; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {									; if row is specified but column is not specified
		FileReadLine, db_DatabaseRow, %db_DatabaseName%, %db_Row%					; read row of database
		Loop, parse, db_DatabaseRow, %A_Tab%										; loop through cells on row (cell by cell)
			if A_LoopField is not digit												; if cell content is not numeric
				return 0															; return 0
	}

	; If both row and column are specified:
	else {																			; else
		db_CellContent := DatabaseGet(db_DatabaseName, db_Row, db_Column)			; store cell content
		if db_CellContent is not digit												; if cell content is not numeric
			return 0																; return 0
	}

return 1 																			; return 1 (only numeric cell content found)
}

DatabaseKeepIfEqual( db_DatabaseName, db_Column, db_Value, db_SkipFirstRow:=FALSE ) { ; Keep only rows with (specific) column value equal a specified value
; Example: RemovedRows := DatabaseKeepIfEqual( "database.txt", 3, 5 )							; keep rows equal to 5 (third column), and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.												;
; Example: DatabaseKeepIfEqual( "database.txt", 3, 5, TRUE )									; keep rows equal to 5 (third column), but skip the first row

return DatabaseRemoveIfNotEqual( db_DatabaseName, db_Column, db_Value, db_SkipFirstRow )		; keep correct rows and return number of removed rows
}

DatabaseKeepIfGreater( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow:=FALSE ) { ; Keep only rows with (specific) column value greater than specified
; Example: RemovedRows := DatabaseKeepIfGreater( "database.txt", 3, 5 )							; keep rows greater than 5 (third column), and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.												;
; Example: DatabaseKeepIfGreater( "database.txt", 3, 5, TRUE )									; keep rows greater than 5 (third column), but skip the first row

return DatabaseRemoveIfLessOrEqual( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow )	; keep correct rows and return number of removed rows
}

DatabaseKeepIfGreaterOrEqual( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow:=FALSE ) { ; Keep only rows with (specific) column value greater than or equal to a specified value
; Example: RemovedRows := DatabaseKeepIfGreaterOrEqual( "database.txt", 3, 5 )				; keep rows greater than or equal to 5 (third column), and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.											;
; Example: DatabaseKeepIfGreaterOrEqual( "database.txt", 3, 5, TRUE )						; keep rows greater than or equal to 5 (third column), but skip the first row

return DatabaseRemoveIfLess( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow )	; keep correct rows and return number of removed rows
}

DatabaseKeepIfLess( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow:=FALSE ) { ; Keep only rows with (specific) column value less than specified
; Example: RemovedRows := DatabaseKeepIfLess( "database.txt", 3, 5 )								; keep rows less than 5 (third column), and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.													;
; Example: DatabaseKeepIfLess( "database.txt", 3, 5, TRUE )											; keep rows less than 5 (third column), but skip the first row

return DatabaseRemoveIfGreaterOrEqual( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow )	; keep correct rows and return number of removed rows
}

DatabaseKeepIfLessOrEqual( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow:=FALSE ) { ; Keep only rows with (specific) column value less than or equal to a specified value
; Example: RemovedRows := DatabaseKeepIfLessOrEqual( "database.txt", 3, 5 )					; keep rows less than or equal to 5 (third column), and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.											;
; Example: DatabaseKeepIfLessOrEqual( "database.txt", 3, 5, TRUE )							; keep rows less than or equal to 5 (third column), but skip the first row

return DatabaseRemoveIfGreater( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow )	; keep correct rows and return number of removed rows
}

DatabaseKeepIfNotEqual( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow:=FALSE ) { ; Keep only rows with (specific) column value not equal to a specified value
; Example: RemovedRows := DatabaseKeepIfNotEqual( "database.txt", 3, 5 )					; keep rows not equal to 5 (third column), and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.											;
; Example: DatabaseKeepIfNotEqual( "database.txt", 3, 5, TRUE )								; keep rows not equal to 5 (third column), but skip the first row

return DatabaseRemoveIfEqual( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow )	; keep correct rows and return number of removed rows
}

DatabaseLog( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take log of each cell value in specified part of database
; Example: DatabaseLog( "database.txt" )															; take log of each cell value
; Example: DatabaseLog( "database.txt", 2 )															; take log of each cell value in the second row
; Example: DatabaseLog( "database.txt", , 2 )														; take log of each cell value in the second column
; Example: DatabaseLog( "database.txt", 1, 2 )														; take log of the cell value in the first row and second column
; Example: DatabaseLog( "database.txt", , , TRUE )													; take log of each cell value, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Log(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Log(A_LoopField) . "`r`n"											; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Log(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Log(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Log(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Log(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Log(db_Cells[db_Column])										; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseMatchCountRows( db_DatabaseName, db_SkipFirstRow:=FALSE
					  , db_Column1:=""	, db_Column2:=""	, db_Column3:=""	, db_Column4:=""	, db_Column5:=""
					  , db_Column6:=""	, db_Column7:=""	, db_Column8:=""	, db_Column9:=""	, db_Column10:=""
					  , db_Column11:=""	, db_Column12:=""	, db_Column13:=""	, db_Column14:=""	, db_Column15:=""
					  , db_Column16:=""	, db_Column17:=""	, db_Column18:=""	, db_Column19:=""	, db_Column20:=""
					  , db_Column21:=""	, db_Column22:=""	, db_Column23:=""	, db_Column24:=""	, db_Column25:=""
					  , db_Column26:=""	, db_Column27:=""	, db_Column28:=""	, db_Column29:=""	, db_Column30:=""
					  , db_Column31:=""	, db_Column32:=""	, db_Column33:=""	, db_Column34:=""	, db_Column35:=""
					  , db_Column36:=""	, db_Column37:=""	, db_Column38:=""	, db_Column39:=""	, db_Column40:=""
					  , db_Column41:=""	, db_Column42:=""	, db_Column43:=""	, db_Column44:=""	, db_Column45:=""
					  , db_Column46:=""	, db_Column47:=""	, db_Column48:=""	, db_Column49:=""	, db_Column50:="") { ; Return number of matching database rows (given column values)
; Example: NumberOfRows := DatabaseMatchCountRows( "database.txt", , "2", "1" )				; show number of database rows with 2 and 1 in the first two columns
;          MsgBox, Number of matching rows: %NumberOfRows%									;
; Example: NumberOfRows := DatabaseMatchCountRows( "database.txt", TRUE, "2", "1" )			; store number of database rows with 2 and 1 in the first two columns (skipping first row)
; Example: NumberOfRows := DatabaseMatchCountRows( "database.txt", , , "B2" )				; store number of database rows with B2 in the second column

	; Return number of matching rows:
	db_MatchingRowsCount := 0																; initiate variable for counting matching rows
	Loop, read, %db_DatabaseName%															; loop through database (row by row)
	{																						; {
		if ( db_SkipFirstRow==TRUE AND A_Index==1 )											; if the first row shall be skipped
			continue																		; continue loop from beginning (next iteration)
		Loop, parse, A_LoopReadLine, %A_Tab%												; loop through cells on row (cell by cell)
			if ( !(A_LoopField==db_Column%A_Index%) AND !(db_Column%A_Index%=="") )			; if element match specification, or column value is not specified through argument
				goto, db_not_a_match_4														; go to label
		db_MatchingRowsCount++																; increase variable for counting matching rows by one
		db_not_a_match_4:																	; label
	}																						; }

return db_MatchingRowsCount																	; return number of matching rows
}

DatabaseMatchGetColumn( db_DatabaseName, db_Column, db_SkipFirstRow:=FALSE
					  , db_Column1:=""	, db_Column2:=""	, db_Column3:=""	, db_Column4:=""	, db_Column5:=""
					  , db_Column6:=""	, db_Column7:=""	, db_Column8:=""	, db_Column9:=""	, db_Column10:=""
					  , db_Column11:=""	, db_Column12:=""	, db_Column13:=""	, db_Column14:=""	, db_Column15:=""
					  , db_Column16:=""	, db_Column17:=""	, db_Column18:=""	, db_Column19:=""	, db_Column20:=""
					  , db_Column21:=""	, db_Column22:=""	, db_Column23:=""	, db_Column24:=""	, db_Column25:=""
					  , db_Column26:=""	, db_Column27:=""	, db_Column28:=""	, db_Column29:=""	, db_Column30:=""
					  , db_Column31:=""	, db_Column32:=""	, db_Column33:=""	, db_Column34:=""	, db_Column35:=""
					  , db_Column36:=""	, db_Column37:=""	, db_Column38:=""	, db_Column39:=""	, db_Column40:=""
					  , db_Column41:=""	, db_Column42:=""	, db_Column43:=""	, db_Column44:=""	, db_Column45:=""
					  , db_Column46:=""	, db_Column47:=""	, db_Column48:=""	, db_Column49:=""	, db_Column50:="") { ; Find matching row and return a specified column value from that row
; Example: CellContent := DatabaseMatchGetColumn( "database.txt", 4, , , "D2", "D3" )		; show content of the 4th column of the first row with D2 in 2nd column and D3 in the third column
;          MsgBox, The matching row has the following in the second column: %CellContent%	;
; Example: ColumnValue := DatabaseMatchGetColumn( "database.txt", 4, , "D1", "D2", "D3" )	; store content of the 4th column of the first row with D1, D2 and D3 in the first columns
; Example: ColumnValue := DatabaseMatchGetColumn( "database.txt", 4, TRUE, "D1" )			; store 4th column's content of the first row with D1 in the first column (skipping the first row)

	; Return specified column value if completely matching row:
	Loop, read, %db_DatabaseName%															; loop through database (row by row)
	{																						; {
		if ( db_SkipFirstRow==TRUE AND A_Index==1 )											; if the first row shall be skipped
			continue																		; continue loop from beginning (next iteration)
		Loop, parse, A_LoopReadLine, %A_Tab%												; loop through cells on row (cell by cell)
			if ( !(A_LoopField==db_Column%A_Index%) AND !(db_Column%A_Index%=="") )			; if element match specification, or column value is not specified through argument
				goto, db_not_a_match_1														; go to label
		return DatabaseGet( db_DatabaseName, A_Index, db_Column )							; return content of specified column (for the matching row)
		db_not_a_match_1:																	; label
	}																						; }

return																						; return (no matching row)
}

DatabaseMatchGetRowNumber( db_DatabaseName, db_SkipFirstRow:=FALSE
						 , db_Column1:=""	, db_Column2:=""	, db_Column3:=""	, db_Column4:=""	, db_Column5:=""
						 , db_Column6:=""	, db_Column7:=""	, db_Column8:=""	, db_Column9:=""	, db_Column10:=""
						 , db_Column11:=""	, db_Column12:=""	, db_Column13:=""	, db_Column14:=""	, db_Column15:=""
						 , db_Column16:=""	, db_Column17:=""	, db_Column18:=""	, db_Column19:=""	, db_Column20:=""
						 , db_Column21:=""	, db_Column22:=""	, db_Column23:=""	, db_Column24:=""	, db_Column25:=""
						 , db_Column26:=""	, db_Column27:=""	, db_Column28:=""	, db_Column29:=""	, db_Column30:=""
						 , db_Column31:=""	, db_Column32:=""	, db_Column33:=""	, db_Column34:=""	, db_Column35:=""
						 , db_Column36:=""	, db_Column37:=""	, db_Column38:=""	, db_Column39:=""	, db_Column40:=""
						 , db_Column41:=""	, db_Column42:=""	, db_Column43:=""	, db_Column44:=""	, db_Column45:=""
						 , db_Column46:=""	, db_Column47:=""	, db_Column48:=""	, db_Column49:=""	, db_Column50:="") { ; Find matching row and return its row number
; Example: RowNumber := DatabaseMatchGetRowNumber( "database.txt", , "E1", "E2", "E3" )		; present row number of row with E1, E2 and E3 in the first three columns
;          MsgBox, The matching row has row number: %RowNumber%								;
; Example: RowNumber := DatabaseMatchGetRowNumber( "database.txt", , , , "D3" )				; store row number of the first row with D3 in the third column
; Example: RowNumber := DatabaseMatchGetRowNumber( "database.txt", TRUE, "D1" )				; store row number of the first row with D1 in the first column (skipping first row)

	; Return row number if completely matching row:
	Loop, read, %db_DatabaseName%															; loop through database (row by row)
	{																						; {
		if ( db_SkipFirstRow==TRUE AND A_Index==1 )											; if the first row shall be skipped
			continue																		; continue loop from beginning (next iteration)
		Loop, parse, A_LoopReadLine, %A_Tab%												; loop through cells on row (cell by cell)
			if ( !(A_LoopField==db_Column%A_Index%) AND !(db_Column%A_Index%=="") )			; if element match specification, or column value is not specified through argument
				goto, db_not_a_match_3														; go to label
		return A_Index																		; return row number (for the matching row)
		db_not_a_match_3:																	; label
	}																						; }

return 0																					; return 0 (no matching row)
}

DatabaseMatchSetColumn( db_DatabaseName, db_ColumnToSet, db_NewContent, db_SkipFirstRow:=FALSE
					  , db_Column1:=""	, db_Column2:=""	, db_Column3:=""	, db_Column4:=""	, db_Column5:=""
					  , db_Column6:=""	, db_Column7:=""	, db_Column8:=""	, db_Column9:=""	, db_Column10:=""
					  , db_Column11:=""	, db_Column12:=""	, db_Column13:=""	, db_Column14:=""	, db_Column15:=""
					  , db_Column16:=""	, db_Column17:=""	, db_Column18:=""	, db_Column19:=""	, db_Column20:=""
					  , db_Column21:=""	, db_Column22:=""	, db_Column23:=""	, db_Column24:=""	, db_Column25:=""
					  , db_Column26:=""	, db_Column27:=""	, db_Column28:=""	, db_Column29:=""	, db_Column30:=""
					  , db_Column31:=""	, db_Column32:=""	, db_Column33:=""	, db_Column34:=""	, db_Column35:=""
					  , db_Column36:=""	, db_Column37:=""	, db_Column38:=""	, db_Column39:=""	, db_Column40:=""
					  , db_Column41:=""	, db_Column42:=""	, db_Column43:=""	, db_Column44:=""	, db_Column45:=""
					  , db_Column46:=""	, db_Column47:=""	, db_Column48:=""	, db_Column49:=""	, db_Column50:="") { ; Find matching row and modify a specified column value on that row
; Example: DatabaseMatchSetColumn( "database.txt", 4, "New content", , "E1", "E2" )			; change the forth column to "New content" of a row starting with E1 and E2
; Example: Cell := DatabaseMatchSetColumn( "database.txt", 4, "New content", , "E1", "E2" )	; change the forth column to "New content" of a row starting with E1 and E2 and store cell location
; Example: DatabaseMatchSetColumn( "database.txt", 4, "New content", TRUE, "E1", "E2" )		; change the forth column to "New content" of a row starting with E1 and E2 (skipping first row)
; Example: DatabaseMatchSetColumn( "database.txt", 4, "New content", , , "E2" )				; change the forth column to "New content" of a row with E2 in the second column

	; Modify (and return location of) cell value if completely matching row:
	Loop, read, %db_DatabaseName%															; loop through database (row by row)
	{																						; {
		if ( db_SkipFirstRow==TRUE AND A_Index==1 )											; if the first row shall be skipped
			continue																		; continue loop from beginning (next iteration)
		Loop, parse, A_LoopReadLine, %A_Tab%												; loop through cells on row (cell by cell)
			if ( !(A_LoopField==db_Column%A_Index%) AND !(db_Column%A_Index%=="") )			; if element match specification, or column value is not specified through argument
				goto, db_not_a_match_2														; go to label
		db_Row := A_Index																	; store loop iteration (row number)
		break																				; break
		db_not_a_match_2:																	; label
	}																						; }

	; Return nothing or modified cell location:
	if !( db_Row>0 )																		; if row number if larger than 0 (there was a matching row)
		return																				; return nothing (no matching row)
	DatabaseModifyCell( db_DatabaseName, db_Row, db_ColumnToSet, db_NewContent )			; modify cell
	db_CellLocation := Object()																; create array
	db_CellLocation[1] := db_Row															; store row number in array
	db_CellLocation[2] := db_ColumnToSet													; store column number in array

return db_CellLocation																		; return array with location of modified cell
}

DatabaseMergeByColumns( db_Database1, db_Database2, db_DatabaseName, db_Overwrite:=FALSE ) { ; Merge two databases by columns (stack vertically)
; Example: DatabaseMergeByColumns( "database1.txt", "database2.txt", "database.txt" )			; merge two databases into "database.txt" (do not overwrite if file exists)
; Example: DatabaseMergeByColumns( "database1.txt", "database2.txt", "database.txt", TRUE )		; merge two databases into "database.txt" (and overwrite if necessary)

	; Return 0 if output file exists and shall not be overwritten:
	if ( db_Overwrite==FALSE )																	; if existing database shall not be overwritten
		IfExist, %db_DatabaseName%																; if output database exists
			return 0																			; return 0

	; Return 0 if input databases have different number of columns:
	if !( DatabaseGetNumberOfColumns(db_Database1)==DatabaseGetNumberOfColumns(db_Database2) )	; if input databases have different number of columns
		return 0																				; return 0

	; Include first (input) database in new (output) database:
	FileCopy, %db_Database1%, %db_DatabaseName%, 1												; make output database copy of first input database

	; Include second (input) database in new (output) database:
	Loop, read, %db_Database2%, %db_DatabaseName%												; loop through rows of second input database
		FileAppend, `r`n%A_LoopReadLine%														; append linebreak and row of second input database to output database

return 1																						; return 1 (no problem detected)
}

DatabaseMergeByRows( db_Database1, db_Database2, db_DatabaseName, db_Overwrite:=FALSE ) { ; Merge two databases by rows (attach horizontally)
; Example: DatabaseMergeByRows( "database1.txt", "database2.txt", "database.txt" )				; merge two databases into "database.txt" (do not overwrite if file exists)
; Example: DatabaseMergeByRows( "database1.txt", "database2.txt", "database.txt", TRUE )		; merge two databases into "database.txt" (and overwrite if necessary)

	; Return 0 if input databases have different number of rows:
	if !( DatabaseGetNumberOfRows(db_Database1)==DatabaseGetNumberOfRows(db_Database2) )		; if input databases have different number of rows
		return 0																				; return 0

	; Ensure output file can be created (return 0 otherwise):
	IfExist, %db_DatabaseName%																	; if output database exists
	{																							; {
		if ( db_Overwrite==FALSE )																; if existing database shall not be overwritten
			return 0																			; return 0
		FileDelete, %db_DatabaseName%															; delete existing output file
	}																							; }

	; Created merged database:
	db_DatabaseOpen := FileOpen( db_Database2, "r" )											; open (second database) file (for reading)
	db_NumberOfRows := DatabaseGetNumberOfRows( db_Database1 )									; store number of database rows of first database (same as second database)
	Loop, read, %db_Database1%, %db_DatabaseName%												; loop through rows of first input database
	{																							; {
		db_RowOutput := A_LoopReadLine . A_Tab . db_DatabaseOpen.ReadLine()						; prepare merged database row
		FileAppend, %db_RowOutput%																; add merged database row to output file
	}																							; }
	db_DatabaseOpen.Close()																		; close (second database) file

return 1																						; return 1 (no problem detected)
}

DatabaseModifyCell( db_DatabaseName, db_Row, db_Column, db_NewContent ) { ; Modify content of a database cell
; Example: DatabaseModifyCell( "database.txt", 2, 3, "New content" )						; modifies the content of the cell on the second row and the third column (2x3) to "New content"

	; Prepare modified database row:
	FileReadLine, db_RowToModify, %db_DatabaseName%, %db_Row%								; read database row to modify
	Loop, Parse, db_RowToModify, `t															; separate database row to modify by tabs
	{																						; {
		if !( A_Index==1 )																	; if not the first loop iteration
			db_ModifiedRow .= A_Tab															; add a tab to modified row
		if ( A_Index==db_Column )															; if the cell to modify
			db_ModifiedRow .= db_NewContent													; add new content to modified row
		else																				; else (not the cell to modify)
			db_ModifiedRow .= A_LoopField													; add already existing cell content to modified row
	}																						; }

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Update database with specified row:
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		if !( A_Index==1 )																	; if not the first row
			FileAppend, `r`n																; add linebreak to output file
		if ( A_Index==db_Row )																; if row to modify
			FileAppend, %db_ModifiedRow%													; insert modified row to output file
		else																				; else
			FileAppend, %A_LoopReadLine%													; add database row (from input file) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseModifyColumn( db_DatabaseName, db_Column, db_RemoveUnspecified:=FALSE
					, db_Row1:=""	, db_Row2:=""	, db_Row3:=""	, db_Row4:=""	, db_Row5:=""
					, db_Row6:=""	, db_Row7:=""	, db_Row8:=""	, db_Row9:=""	, db_Row10:=""
					, db_Row11:=""	, db_Row12:=""	, db_Row13:=""	, db_Row14:=""	, db_Row15:=""
					, db_Row16:=""	, db_Row17:=""	, db_Row18:=""	, db_Row19:=""	, db_Row20:=""
					, db_Row21:=""	, db_Row22:=""	, db_Row23:=""	, db_Row24:=""	, db_Row25:=""
					, db_Row26:=""	, db_Row27:=""	, db_Row28:=""	, db_Row29:=""	, db_Row30:=""
					, db_Row31:=""	, db_Row32:=""	, db_Row33:=""	, db_Row34:=""	, db_Row35:=""
					, db_Row36:=""	, db_Row37:=""	, db_Row38:=""	, db_Row39:=""	, db_Row40:=""
					, db_Row41:=""	, db_Row42:=""	, db_Row43:=""	, db_Row44:=""	, db_Row45:=""
					, db_Row46:=""	, db_Row47:=""	, db_Row48:=""	, db_Row49:=""	, db_Row50:="" ) { ; Modify content of cells in a column
; Example: DatabaseModifyColumn( "database.txt", 4, FALSE, "First", "Second", "Third" )			; set first 3 rows (and keep content of other cells on column) of the fourth database column
; Example: DatabaseModifyColumn( "database.txt", 4, TRUE, "First", "Second", "Third" )			; set first 3 rows (and remove the existing content of the rest) of the fourth database column
; Example: DatabaseModifyColumn( "database.txt", 2, , , , , "Fourth" )							; set the fourth row value of the second column (and leave existing content of other cells)

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )				; rename database file (and store new filename)

	; Save database with modified column:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through each row of database
	{																							; {
		db_TabBeforeCell := InStr( A_LoopReadLine, A_Tab, , , db_Column-1 )						; store position of tab just before column to modify
		db_TabAfterCell := InStr( A_LoopReadLine, A_Tab, , , db_Column )						; store position of tab just after column to modify
		if ( db_RemoveUnspecified==FALSE AND db_Row%A_Index%=="" )								; if existing cell content shall be kept
			db_RowOutput := A_LoopReadLine														; store original row in output variable
		else																					; else
			if ( db_TabBeforeCell==0 )															; if the first column is to be modified
				db_RowOutput := db_Row%A_Index% . SubStr( A_LoopReadLine, db_TabAfterCell )		; store new content followed by original row content in output variable
			else if ( db_TabAfterCell==0 )														; else if the last column is to be modified
				db_RowOutput := Substr( A_LoopReadLine, 1, db_TabBeforeCell ) . db_Row%A_Index%	; store the original row content followed by new content
			else {																				; else (the lat column is to be modified)
				db_LeftPartOfRow := Substr( A_LoopReadLine, 1, db_TabBeforeCell )				; store part of row to the left of new cell's content
				db_RightPartOfRow := SubStr( A_LoopReadLine, db_TabAfterCell )					; store part of row to the right of new cell's content
				db_RowOutput := db_LeftPartOfRow . db_Row%A_Index% . db_RightPartOfRow			; combine parts to create row with new cell included
			}
		if ( A_Index<db_NumberOfRows )															; if not the last row of database
			db_RowOutput .= "`r`n"																; add linebreak at the end of the row
		FileAppend, %db_RowOutput%																; add (possibly modified) database row to output file
	}																							; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%															; delete (temporary) file

return																							; return
}

DatabaseModifyRow( db_DatabaseName, db_Row, db_RemoveUnspecified:=FALSE
				 , db_Column1:=""	, db_Column2:=""	, db_Column3:=""	, db_Column4:=""	, db_Column5:=""
				 , db_Column6:=""	, db_Column7:=""	, db_Column8:=""	, db_Column9:=""	, db_Column10:=""
				 , db_Column11:=""	, db_Column12:=""	, db_Column13:=""	, db_Column14:=""	, db_Column15:=""
				 , db_Column16:=""	, db_Column17:=""	, db_Column18:=""	, db_Column19:=""	, db_Column20:=""
				 , db_Column21:=""	, db_Column22:=""	, db_Column23:=""	, db_Column24:=""	, db_Column25:=""
				 , db_Column26:=""	, db_Column27:=""	, db_Column28:=""	, db_Column29:=""	, db_Column30:=""
				 , db_Column31:=""	, db_Column32:=""	, db_Column33:=""	, db_Column34:=""	, db_Column35:=""
				 , db_Column36:=""	, db_Column37:=""	, db_Column38:=""	, db_Column39:=""	, db_Column40:=""
				 , db_Column41:=""	, db_Column42:=""	, db_Column43:=""	, db_Column44:=""	, db_Column45:=""
				 , db_Column46:=""	, db_Column47:=""	, db_Column48:=""	, db_Column49:=""	, db_Column50:="" ) { ; Modify content of cells in a row
; Example: DatabaseModifyRow( "database.txt", 4, TRUE, "First", "Second", "Third" )			; set first three columns (and empty the remaining columns) of the fourth database row
; Example: DatabaseModifyRow( "database.txt", 4, FALSE, "First", "Second", "Third" )		; set first three columns (and leave the existing content of the rest) of the fourth database row
; Example: DatabaseModifyRow( "database.txt", 2, , , , , "Fourth" )							; set the fourth column value of the second row (and leave existing content of other cells)

	; Prepare modified database row:
	db_RowToModify := DatabaseGet( db_DatabaseName, db_Row )								; store row to modify as an array
	Loop, % DatabaseGetNumberOfColumns( db_DatabaseName )									; loop through each cell of row
	{																						; {
		if ( A_Index>1 )																	; if loop iteration is larger than 1 (if not the first cell on row)
			db_NewDatabaseRow .= A_Tab														; append a tab to row output
		if ( db_Column%A_Index%=="" )														; if cell content is not specified
			if ( db_RemoveUnspecified==TRUE )												; if unspecified cell content should be removed
				db_NewDatabaseRow .= db_RowToModify											; append empty cell
			else																			; else (if unspecified cell content should not be removed)
				db_NewDatabaseRow .= db_RowToModify[A_Index]								; append already existing cell content
		else																				; else (if cell content is specified)
			db_NewDatabaseRow .= db_Column%A_Index%											; append specified cell content
	}																						; }

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Update database with specified row:
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		if !( A_Index==1 )																	; if not the first row
			FileAppend, `r`n																; add linebreak to output file
		if ( A_Index==db_Row )																; if row where specified row shall be placed
			FileAppend, %db_NewDatabaseRow%													; insert specified row to output file
		else																				; else
			FileAppend, %A_LoopReadLine%													; add database row (from input file) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseModulo( db_DatabaseName, db_Divisor, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take modulo of cell values in specified part of database
; Example: DatabaseModulo( "database.txt", 2 )														; take modulo 2 of all database cell values
; Example: DatabaseModulo( "database.txt", 2, 3 )													; take modulo 2 of all database cell values in the third row
; Example: DatabaseModulo( "database.txt", 2, , 4 )													; take modulo 2 of all database cell values in the fourth column
; Example: DatabaseModulo( "database.txt", 2, 3, 4 )												; take modulo 2 of cell value in the third row and fourth column
; Example: DatabaseModulo( "database.txt", 2, , , TRUE )											; take modulo 2 of all database cell values, except the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Mod(A_LoopField, db_Divisor) . A_Tab								; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Mod(A_LoopField, db_Divisor) . "`r`n"								; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Mod(A_LoopField, db_Divisor)										; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Mod(db_CellContent, db_Divisor)							; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Mod(db_Cells[1], db_Divisor)											; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Mod(db_Cells[A_Index+1], db_Divisor)						; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Mod(db_Cells[db_Column], db_Divisor)							; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseMoveColumn( db_DatabaseName, db_OldLocation, db_NewLocation ) { ; Move a database column to a new location (without removing any column)
; Example: DatabaseMoveColumn( "database.txt", 1, 5 )										; move the first column to the fifth column place

	; Return if old and new column positions are equal:
	if ( db_OldLocation==db_NewLocation )													; if column shall be moved to initial position
		return																				; return

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Save database with column moved:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )						; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		db_RowArray := DatabaseGet( db_TemporaryFilename, A_Index )							; store current row (cell content) as array
		if ( db_OldLocation<db_NewLocation ) {												; if column shall be moved to the right
			db_RowArray.InsertAt( db_NewLocation+1, db_RowArray[db_OldLocation] )			; copy cell content to move to desired position
			db_RowArray.RemoveAt( db_OldLocation )											; delete original cell content that has been copied
		} else {																			; else (column shall be moved to the left)
			db_RowArray.InsertAt( db_NewLocation, db_RowArray[db_OldLocation] )				; copy cell content to move to desired position
			db_RowArray.RemoveAt( db_OldLocation+1 )										; delete original cell content that has been copied
		}
		db_RowOutput = % db_RowArray[1]														; initiate output string with first element of (row) cell array
		Loop % db_RowArray.Length()-1														; loop through each but one element of (row) cell array
			db_RowOutput .= A_Tab . db_RowArray[A_Index+1]									; append a tab and an element of (row) cell array
		if ( A_Index<db_NumberOfRows )														; if not the last row of database
			db_RowOutput .= "`r`n"															; add linebreak at the end of the row
		FileAppend, %db_RowOutput%															; add modified database row (with new column) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseMoveRow( db_DatabaseName, db_OldLocation, db_NewLocation ) { ; Move a database row to a new location (without removing any row)
; Example: DatabaseMoveRow( "database.txt", 2, 5 )										; move the second database row to the fifth row

	; Return if both row positions are equal:
	if ( db_OldLocation==db_NewLocation )												; if column shall be moved to initial position
		return																			; return

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )		; rename database file (and store new filename)

	; Save database with database row moved:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store number of database rows
	db_RowOffset := 0																	; initiate offset variable
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%								; loop through each row of database
	{																					; {
		if ( A_Index==db_OldLocation AND db_OldLocation<db_NewLocation )				; if original position of row to move, and row shall be moved down
			db_RowOffset++																; increase offset by one
		else if ( A_Index==db_OldLocation+1 AND db_NewLocation<db_OldLocation )			; else if one row after original position of row to move, and row shall be moved up
			db_RowOffset++																; increase offset by one
		else if ( A_Index==db_NewLocation ) {											; else if new position for row to move
			db_RowOffset--																; decrease offset by one
			FileReadLine, db_RowOutput, %db_TemporaryFilename%, db_OldLocation			; store row to move in output string
			if ( A_Index<db_NumberOfRows )												; if not the last row of database
				db_RowOutput .= "`r`n"													; add linebreak at the end of the row
			FileAppend, %db_RowOutput%													; append row to database
			continue																	; continue loop (start from beginning with next iteration)
		}
		if ( db_RowOffset==0 )															; if offset is 0
			db_RowOutput := A_LoopReadLine												; store current row in output string
		else																			; else
			FileReadLine, db_RowOutput, %db_TemporaryFilename%, A_Index+db_RowOffset	; store correct row (given offset) in output string
		if ( A_Index<db_NumberOfRows )													; if not the last row of database
			db_RowOutput .= "`r`n"														; add linebreak at the end of the row
		FileAppend, %db_RowOutput%														; append row to database
	}																					; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%													; delete (temporary) file

return																					; return
}

DatabaseMultiplication( db_DatabaseName, db_Factor, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Multiply specified cells by specified factor (assume cells contain numbers)
; Example: DatabaseMultiplication( "database.txt", 10 )												; multiply each cell in database by 10
; Example: DatabaseMultiplication( "database.txt", 3, 2 )											; multiply each cell of the second row by 3
; Example: DatabaseMultiplication( "database.txt", 3, , 4 )											; multiply each cell of the fourth column by 3
; Example: DatabaseMultiplication( "database.txt", 3, 5, 4 )										; multiply the cell on the fifth row and fourth column by 3
; Example: DatabaseMultiplication( "database.txt", 10, , , TRUE )									; multiply each cell in database by 10, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % A_LoopField*db_Factor . A_Tab										; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % A_LoopField*db_Factor . "`r`n"									; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % A_LoopField*db_Factor												; save updated cell content to output file
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= db_CellContent*db_Factor									; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := db_Cells[1]*db_Factor													; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]*db_Factor								; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := db_Cells[db_Column]*db_Factor								; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseMultiplyColumns( db_DatabaseName, db_Column1, db_Column2, db_SkipFirstRow:=FALSE ) { ; Add new column containing one column multiplied by another column
; Example: DatabaseMultiplyColumns( "database.txt", 3, 5 )											; store column 3 multiplied by column 5 as a new column
; Example: DatabaseMultiplyColumns( "database.txt", 3, 5, TRUE )									; store column 3 multiplied by column 5 as a new column, but skip the first row
; Example: NewColumn := DatabaseMultiplyColumns( "database.txt", 3, 5 )								; store column 3 multiplied by column 5 as a new column, and show the new column number
;          MsgBox, The new column has column number %NewColumn%										;

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; Save database with new column:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )								; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%											; loop through each row of database
	{																								; {
		if !( db_SkipFirstRow==TRUE AND A_Index==1 )												; if not first row and first row shall be skipped
			db_RowOutput := A_LoopReadLine . A_Tab . StrSplit( A_LoopReadLine, A_Tab )[db_Column1]
													*StrSplit( A_LoopReadLine, A_Tab )[db_Column2]	; prepare output row with new column
		else																						; else
			db_RowOutput := A_LoopReadLine . A_Tab													; prepare output row with new column
		if ( A_Index<db_NumberOfRows )																; if not the last row of database
			db_RowOutput .= "`r`n"																	; add linebreak at the end of the row
		FileAppend, %db_RowOutput%																	; add modified database row (with new column) to output file
	}																								; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return DatabaseGetNumberOfColumns( db_DatabaseName )												; return column number of new database column
}

DatabaseNaturalLog( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take natural log of each cell value in specified part of database
; Example: DatabaseNaturalLog( "database.txt" )														; take natural log of each cell value
; Example: DatabaseNaturalLog( "database.txt", 2 )													; take natural log of each cell value in the second row
; Example: DatabaseNaturalLog( "database.txt", , 2 )												; take natural log of each cell value in the second column
; Example: DatabaseNaturalLog( "database.txt", 1, 2 )												; take natural log of the cell value in the first row and second column
; Example: DatabaseNaturalLog( "database.txt", , , TRUE )											; take natural log of each cell value, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Ln(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Ln(A_LoopField) . "`r`n"											; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Ln(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Ln(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Ln(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Ln(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Ln(db_Cells[db_Column])										; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabasePower( db_DatabaseName, db_Power, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Perform exponentiation of each cell value in specified part of database
; Example: DatabasePower( "database.txt", 2 )														; take the second power of each database cell value
; Example: DatabasePower( "database.txt", 2, 3 )													; take the second power of each cell value in the third row
; Example: DatabasePower( "database.txt", 2, , 3 )													; take the second power of each cell value in the third column
; Example: DatabasePower( "database.txt", 2, 1, 3 )													; take the second power of the cell in the first row and third column
; Example: DatabasePower( "database.txt", 2, , , TRUE )												; take the second power of each database cell value, with the first row excluded

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % A_LoopField**db_Power . A_Tab										; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % A_LoopField**db_Power . "`r`n"									; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % A_LoopField**db_Power												; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= db_CellContent**db_Power									; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := db_Cells[1]**db_Power													; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]**db_Power								; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := db_Cells[db_Column]**db_Power								; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseRecycle( db_DatabaseName ) { ; Recycle database (return 1 if successfully recycled, 0 otherwise)
; Example: DatabaseRecycle( "database.txt" )							; recycle "database.txt" (return 1 if successfully recycled, 0 otherwise)
; Example: if ( DatabaseRecycle( "database.txt" ) )						; recycle "database.txt" and inform whether or not successful through a message box
;               MsgBox, Database placed in Recycle Bin.					;
;          else															;
;               MsgBox, Database not placed in Recycle Bin.				;

	; Recycle database file:
	FileRecycle, %db_DatabaseName%										; recycle database (place in recycle bin)

	; Return 1 if file is not found:
	IfNotExist, %db_DatabaseName%										; if database file is not found
		return 1														; return 1

return 0																; return 0 (file appears to remain in original location)
}

DatabaseRemoveColumn( db_DatabaseName, db_Column:="" ) { ; Delete a database column (the last if not specified)
; Example: DatabaseRemoveColumn( "database.txt", 4 )										; delete the 4th database column
; Example: DatabaseRemoveColumn( "database.txt" )											; delete the last database column

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Save database without deleted column:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )						; store number of database rows
	if ( db_Column=="" )																	; if column for deletion is not specified
		db_Column := DatabaseGetNumberOfColumns( db_TemporaryFilename )						; set the last database column to be deleted
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		db_TabBeforeCell := InStr( A_LoopReadLine, A_Tab, , , db_Column-1 )					; store position of tab just before column to delete
		db_TabAfterCell := InStr( A_LoopReadLine, A_Tab, , , db_Column )					; store position of tab just after column to delete
		if ( db_TabAfterCell==0 )															; if the last column shall be deleted
			db_RowOutput := Substr( A_LoopReadLine, 1, db_TabBeforeCell-1 )					; store everything on row before last column
		else if ( db_TabBeforeCell==0 )														; else if the first column shall be deleted
			db_RowOutput := SubStr( A_LoopReadLine, db_TabAfterCell+1 )						; store everything after the first column
		else {																				; else (a column between other columns shall be deleted)
			db_LeftPartOfRow := Substr( A_LoopReadLine, 1, db_TabBeforeCell )				; store part of row to the left of the column to delete
			db_RightPartOfRow := SubStr( A_LoopReadLine, db_TabAfterCell+1 )				; store part of row to the right of the column to delete
			db_RowOutput = %db_LeftPartOfRow%%db_RightPartOfRow%							; combine part to the left and to the right of column to delete
		}
		if ( A_Index<db_NumberOfRows )														; if not the last row of database
			db_RowOutput .= "`r`n"															; add linebreak at the end of the row
		FileAppend, %db_RowOutput%															; add modified database row (without column to delete) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseRemoveDuplicatesByColumn( db_DatabaseName, db_Column, db_SkipFirstRow:=FALSE ) { ; Remove duplicate values in a column (deletes entire row, with only the first occurrence kept)
; Example: DatabaseRemoveDuplicatesByColumn( "database.txt", 2 )							; remove rows with non-unique column 2 values (only first occurrence kept)
; Example: DatabaseRemoveDuplicatesByColumn( "database.txt", 2, TRUE )						; remove rows with non-unique column 2 values (only first occurrence kept), but skip the first row

	; Store row numbers of duplicate rows in an array:
	db_UniqueColumnValues := Object()														; initiate an array
	db_RowsToDelete := Object()																; initiate an array
	Loop, read, %db_DatabaseName%															; loop through database rows
	{																						; {
		if ( db_SkipFirstRow==TRUE AND A_Index==1 )											; if first row shall be skipped and it is the first row
			continue																		; continue loop from beginning (next iteration)
		else if ( A_Index==1 OR (db_SkipFirstRow==TRUE AND A_Index==2) ) {					; else if the first row, or if it is the second row and the first row shall be skipped
			db_UniqueColumnValues.Push( StrSplit( A_LoopReadLine, A_Tab )[db_Column] )		; add first column value to list of unique column values
			continue																		; continue loop from beginning (next iteration)
		}
		else {																				; else
			db_CellContent := StrSplit( A_LoopReadLine, A_Tab )[db_Column]					; store cell content
			db_RowNumber := A_Index															; stor row number
			for db_Index, db_Value in db_UniqueColumnValues									; for all elements of array of unique column values
				if ( db_Value==db_CellContent ) {											; if the current column value is the same as the current element of array
					db_RowsToDelete.Push( db_RowNumber )									; add database row to list of rows to delete
					goto, db_continue_with_next_row											; go to label
				}
				db_UniqueColumnValues.Push( db_CellContent )								; add database row to list of unique rows
				db_continue_with_next_row:													; label
		}
	}																						; }

	; Return if no rows shall be deleted:
	if ( db_RowsToDelete.MaxIndex()=="" )													; if list of rows to delete is empty
		return 0																			; return 0 (number of removed database rows)

	; Store number of database rows to remove:
	db_NumberOfRowsToRemove := db_RowsToDelete.MaxIndex()									; store number of database rows to remove

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Only keep database rows with unique column values (for the specified column):
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		if ( A_Index==db_RowsToDelete[1] ) {												; if the current database row is the first in the list of rows to delete
			db_RowsToDelete.RemoveAt(1)														; remove the database row from the list of database rows to delete
			continue																		; continue loop from beginning (next iteration)
		}
		if !(A_Index==1)																	; if not the first row
			FileAppend, `r`n																; add linebreak to output file
		FileAppend, %A_LoopReadLine%														; add database row (from input file) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return db_NumberOfRowsToRemove																; return number of removed database rows
}

DatabaseRemoveDuplicates( db_DatabaseName, db_SkipFirstRow:=FALSE ) { ; Remove any row that is a complete copy (all columns are equal) of another row (keep the first)
; Example: DatabaseRemoveDuplicates( "database.txt" )										; remove each row that is a complete copy of another row (keep the first)
; Example: DatabaseRemoveDuplicates( "database.txt", TRUE )									; remove each row that is a complete copy of another row (keep the first), but skip the first row

	; Store row numbers of duplicate rows in an array:
	db_RowsToDelete := Object()																; initiate an array
	Loop, read, %db_DatabaseName%															; loop through database rows
		if ( A_Index==1 OR (db_SkipFirstRow==TRUE AND A_Index==2) )							; if first row shall be skipped and it is the first row
			continue																		; continue loop from beginning (next iteration)
		else {																				; else
			db_ComparisonRow := A_LoopReadLine												; store row content for comparison
			db_ComparisonRowNumber := A_Index												; store row number
			Loop, read, %db_DatabaseName%													; loop through database rows
			{
				if ( db_SkipFirstRow==TRUE AND A_Index==1 )									; if the first row shall be skipped, and it is the first row
					continue																; continue loop from beginning (next iteration)
				if ( db_ComparisonRow==A_LoopReadLine ) {									; if the rows are equal (there is a duplicate row)
				db_RowsToDelete.Push( db_ComparisonRowNumber )								; store row number in array for database rows to delete
				break																		; break
				}
			} until A_Index==db_ComparisonRowNumber-1										; run loop until database row is compared with the preceding row
		}

	; Return if no rows shall be deleted:
	if ( db_RowsToDelete.MaxIndex()=="" )													; if list of rows to delete is empty
		return 0																			; return 0 (number of removed rows)

	; Store number of database rows to remove:
	db_NumberOfRowsToRemove := db_RowsToDelete.MaxIndex()									; store number of database rows to remove

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Only keep unique database rows:
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		if ( A_Index==db_RowsToDelete[1] ) {												; if the current database row is the first in the list of rows to delete
			db_RowsToDelete.RemoveAt(1)														; remove the database row from the list of database rows to delete
			continue																		; continue loop from beginning (next iteration)
		}
		if !(A_Index==1)																	; if not the first row
			FileAppend, `r`n																; add linebreak to output file
		FileAppend, %A_LoopReadLine%														; add database row (from input file) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return db_NumberOfRowsToRemove																; return number of removed rows
}

DatabaseRemoveIfEqual( db_DatabaseName, db_Column, db_Value, db_SkipFirstRow:=FALSE ) { ; Remove rows with (specific) column value equal to a specified value
; Example: RemovedRows := DatabaseRemoveIfEqual( "database.txt", 3, 5 )					; remove rows with a value equal to 5 (column 3), and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.										;
; Example: DatabaseRemoveIfEqual( "database.txt", 3, 5, TRUE )							; remove rows with a value equal to 5 (column 3), but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )		; rename database file (and store new filename)

	; Save database without deleted row:
	db_NumberOfRowsRemoved := 0															; initiate variable for number of rows removed
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%								; loop through each row of database
	{																					; {
		if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {									; if first row and first row shall be skipped
			FileAppend, %A_LoopReadLine%												; add database row to output file
			db_NumberOfRowsRemoved++													; increase variable for number of removed rows by one
			continue																	; continue loop (next iteration)
		}
		if ( StrSplit( A_LoopReadLine, A_Tab )[db_Column]==db_Value ) {					; if row shall be removed
			db_NumberOfRowsRemoved++													; increase variable for number of removed rows by one
			continue																	; continue loop (next iteration)
		}
		IfExist, %db_Databasename%														; if file exist (file exist if something is written to it, i.e. if any but the first row)
			FileAppend, `r`n															; add linebreak to output file
		FileAppend, %A_LoopReadLine%													; add database row to output file
	}																					; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%													; delete (temporary) file

return db_NumberOfRowsRemoved															; return number of removed rows
}

DatabaseRemoveIfGreater( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow:=FALSE ) { ; Remove rows with (specific) column value greater than specified
; Example: RemovedRows := DatabaseRemoveIfGreater( "database.txt", 3, 5 )			; remove rows with a value greater than 5 in the third column, and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.									;
; Example: DatabaseRemoveIfGreater( "database.txt", 3, 5, TRUE )					; remove rows with a value greater than 5 in the third column, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )	; rename database file (and store new filename)

	; Save database without deleted row:
	db_NumberOfRowsRemoved := 0														; initiate variable for number of rows removed
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%							; loop through each row of database
	{																				; {
		if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {								; if first row and first row shall be skipped
			FileAppend, %A_LoopReadLine%											; add database row to output file
			db_NumberOfRowsRemoved++												; increase variable for number of removed rows by one
			continue																; continue loop (next iteration)
		}
		if ( StrSplit(A_LoopReadLine, A_Tab)[db_Column]>db_Threshold ) {			; if row shall be removed
			db_NumberOfRowsRemoved++												; increase variable for number of removed rows by one
			continue																; continue loop (next iteration)
		}
		IfExist, %db_Databasename%													; if file exist (file exist if something is written to it, i.e. if any but the first row)
			FileAppend, `r`n														; add linebreak to output file
		FileAppend, %A_LoopReadLine%												; add database row to output file
	}																				; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%												; delete (temporary) file

return db_NumberOfRowsRemoved														; return number of removed rows
}

DatabaseRemoveIfGreaterOrEqual( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow:=FALSE ) { ; Remove rows with (specific) column value greater than or equal to a specified value
; Example: RemovedRows := DatabaseRemoveIfGreaterOrEqual( "database.txt", 3, 5 )		; remove rows with a value greater than or equal to 5 (column 3), and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.										;
; Example: DatabaseRemoveIfGreaterOrEqual( "database.txt", 3, 5, TRUE )					; remove rows with a value greater than or equal to 5 (column 3), but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )		; rename database file (and store new filename)

	; Save database without deleted row:
	db_NumberOfRowsRemoved := 0															; initiate variable for number of rows removed
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%								; loop through each row of database
	{																					; {
		if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {									; if first row and first row shall be skipped
			FileAppend, %A_LoopReadLine%												; add database row to output file
			db_NumberOfRowsRemoved++													; increase variable for number of removed rows by one
			continue																	; continue loop (next iteration)
		}
		if ( StrSplit(A_LoopReadLine, A_Tab)[db_Column]>=db_Threshold ) {				; if row shall be removed
			db_NumberOfRowsRemoved++													; increase variable for number of removed rows by one
			continue																	; continue loop (next iteration)
		}
		IfExist, %db_Databasename%														; if file exist (file exist if something is written to it, i.e. if any but the first row)
			FileAppend, `r`n															; add linebreak to output file
		FileAppend, %A_LoopReadLine%													; add database row to output file
	}																					; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%													; delete (temporary) file

return db_NumberOfRowsRemoved															; return number of removed rows
}

DatabaseRemoveIfLess( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow:=FALSE ) { ; Remove rows with (specific) column value less than specified
; Example: RemovedRows := DatabaseRemoveIfLess( "database.txt", 3, 5 )				; remove rows with a value less than 5 in the third column, and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.									;
; Example: DatabaseRemoveIfLess( "database.txt", 3, 5, TRUE )						; remove rows with a value less than 5 in the third column, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )	; rename database file (and store new filename)

	; Save database without deleted row:
	db_NumberOfRowsRemoved := 0														; initiate variable for number of rows removed
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%							; loop through each row of database
	{																				; {
		if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {								; if first row and first row shall be skipped
			FileAppend, %A_LoopReadLine%											; add database row to output file
			db_NumberOfRowsRemoved++												; increase variable for number of removed rows by one
			continue																; continue loop (next iteration)
		}
		if ( StrSplit(A_LoopReadLine, A_Tab)[db_Column]<db_Threshold ) {			; if row shall be removed
			db_NumberOfRowsRemoved++												; increase variable for number of removed rows by one
			continue																; continue loop (next iteration)
		}
		IfExist, %db_Databasename%													; if file exist (file exist if something is written to it, i.e. if any but the first row)
			FileAppend, `r`n														; add linebreak to output file
		FileAppend, %A_LoopReadLine%												; add database row to output file
	}																				; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%												; delete (temporary) file

return db_NumberOfRowsRemoved														; return number of removed rows
}

DatabaseRemoveIfLessOrEqual( db_DatabaseName, db_Column, db_Threshold, db_SkipFirstRow:=FALSE ) { ; Remove rows with (specific) column value less than or equal to a specified value
; Example: RemovedRows := DatabaseRemoveIfLessOrEqual( "database.txt", 3, 5 )		; remove rows with a value less than or equal to 5 in the third column, and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.									;
; Example: DatabaseRemoveIfLessOrEqual( "database.txt", 3, 5, TRUE )				; remove rows with a value less than or equal to 5 in the third column, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )	; rename database file (and store new filename)

	; Save database without deleted row:
	db_NumberOfRowsRemoved := 0														; initiate variable for number of rows removed
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%							; loop through each row of database
	{																				; {
		if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {								; if first row and first row shall be skipped
			FileAppend, %A_LoopReadLine%											; add database row to output file
			db_NumberOfRowsRemoved++												; increase variable for number of removed rows by one
			continue																; continue loop (next iteration)
		}
		if ( StrSplit(A_LoopReadLine, A_Tab)[db_Column]<=db_Threshold ) {			; if row shall be removed
			db_NumberOfRowsRemoved++												; increase variable for number of removed rows by one
			continue																; continue loop (next iteration)
		}
		IfExist, %db_Databasename%													; if file exist (file exist if something is written to it, i.e. if any but the first row)
			FileAppend, `r`n														; add linebreak to output file
		FileAppend, %A_LoopReadLine%												; add database row to output file
	}																				; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%												; delete (temporary) file

return db_NumberOfRowsRemoved														; return number of removed rows
}

DatabaseRemoveIfNotEqual( db_DatabaseName, db_Column, db_Value, db_SkipFirstRow:=FALSE ) { ; Remove rows with not (specific) column value equal to a specified value
; Example: RemovedRows := DatabaseRemoveIfNotEqual( "database.txt", 3, 5 )				; remove rows with not a value equal to 5 (column 3), and present number of removed rows
;          MsgBox, %RemovedRows% rows were removed.										;
; Example: DatabaseRemoveIfNotEqual( "database.txt", 3, 5, TRUE )						; remove rows with not a value equal to 5 (column 3), but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )		; rename database file (and store new filename)

	; Save database without deleted row:
	db_NumberOfRowsRemoved := 0															; initiate variable for number of rows removed
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%								; loop through each row of database
	{																					; {
		if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {									; if first row and first row shall be skipped
			FileAppend, %A_LoopReadLine%												; add database row to output file
			db_NumberOfRowsRemoved++													; increase variable for number of removed rows by one
			continue																	; continue loop (next iteration)
		}
		if ( StrSplit( A_LoopReadLine, A_Tab )[db_Column]!=db_Value ) {					; if row shall be removed
			db_NumberOfRowsRemoved++													; increase variable for number of removed rows by one
			continue																	; continue loop (next iteration)
		}
		IfExist, %db_Databasename%														; if file exist (file exist if something is written to it, i.e. if any but the first row)
			FileAppend, `r`n															; add linebreak to output file
		FileAppend, %A_LoopReadLine%													; add database row to output file
	}																					; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%													; delete (temporary) file

return db_NumberOfRowsRemoved															; return number of removed rows
}

DatabaseRemoveNA( db_DatabaseName, db_CaseSensitive:=FALSE, db_SkipFirstRow:=FALSE ) { ; Empty database cells containing "NA"
; Example: RemovedNA := DatabaseRemoveNA( "database.txt" )									; empty all cells containing "NA", and present number of removals
;          MsgBox, Number of NAs removed: %RemovedNA%										;
; Example: DatabaseRemoveNA( "database.txt", TRUE )											; empty all cells containing "NA" (case-sensitive)
; Example: DatabaseRemoveNA( "database.txt", , TRUE )										; empty all cells containing "NA", but skip the first row

return DatabaseReplace( db_DatabaseName, "NA", "", db_CaseSensitive, , , db_SkipFirstRow )	; remove NAs as specified and return number of removals
}

DatabaseRemoveRow( db_DatabaseName, db_Row:="" ) { ; Delete a database row (the last if not specified)
; Example: DatabaseRemoveRow( "database.txt", 4 )											; delete the 4th database row
; Example: DatabaseRemoveRow( "database.txt" )												; delete the last database row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Save database without deleted row:
	if ( db_Row=="" )																		; if row for deletion is not specified
		db_Row := DatabaseGetNumberOfRows( db_TemporaryFilename )							; set the last database row to be deleted
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		if ( A_Index==db_Row )																; if row shall be removed
			continue																		; continue loop (next iteration)
		if ( !(A_Index==1) AND !(A_Index==2 AND db_Row==1) )								; if not the first row, and not the second row and the row to delete is the first row
			FileAppend, `r`n																; add linebreak to output file
		FileAppend, %A_LoopReadLine%														; add database row (from input file) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseReplace( db_DatabaseName, db_FindContent, db_ReplaceWith, db_CaseSensitive:=FALSE, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Replace specified cell content
; Example: Replacements := DatabaseReplace( "database.txt", "Old content", "New content" )			; replace all instances of "Old content" with "New content" and show how many replacements
;          MsgBox, Number of replacements: %Replacements%											;
; Example: DatabaseReplace( "database.txt", "Old content", "New content", TRUE )					; replace all instances of "Old content" with "New content", with case-sensitivity turned on
; Example: DatabaseReplace( "database.txt", "Old content", "New content", , 2 )						; replace all instances of "Old content" with "New content", in the second row
; Example: DatabaseReplace( "database.txt", "Old content", "New content", , , 3 )					; replace all instances of "Old content" with "New content", in the third column
; Example: DatabaseReplace( "database.txt", "Old content", "New content", , , , TRUE )				; replace all instances of "Old content" with "New content", but skip the first row

	; Set case-sensitivity setting:
	db_OriginalCaseSensitivity := A_StringCaseSense													; store original case-sensitivity setting
	if ( db_CaseSensitive==TRUE )																	; if case-sensitivity shall be turned on
		StringCaseSense, On																			; turn on case sensitivity
	else																							; else (case-sensitivity shall be turned off)
		StringCaseSense, Off																		; turn off case sensitivity

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; Initiate variable for counting replacements:
	db_NumberOfReplacements := 0																	; initiate variable for counting replacements

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first row and first row shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; output row originally in database
				continue																			; continue loop (next iteration) 
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				IfEqual, A_LoopField, %db_FindContent%												; if cell content shall be replaced (note: IfEqual can handle case-sensitivity)
				{
					FileAppend, %db_ReplaceWith%													; output replacement word
					db_NumberOfReplacements++														; increase variable for number of replacements by one
				} else																				; else (if cell does not contain word to be replaced)
					FileAppend, %A_LoopField%														; output content of cell
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, `t																	; output a tab
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, `r`n																; output a linebreak
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first row and first row shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; output row originally in database
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			IfEqual, db_CellContent, %db_FindContent%												; if cell content shall be replaced (note: IfEqual can handle case-sensitivity)
			{																						; {
				db_CellContent := db_ReplaceWith													; store replacement word in output string
				db_NumberOfReplacements++															; increase variable for number of replacements by one
			}																						; }
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_CellContent := db_Cells[1]														; store array element as variable
				IfEqual, db_CellContent, %db_FindContent%											; if cell content shall be replaced (note: IfEqual can handle case-sensitivity)
				{
					db_Output := db_ReplaceWith														; store replacement word in output string
					db_NumberOfReplacements++														; increase variable for number of replacements by one
				} else																				; else (if cell does not contain word to replace)
					db_Output := db_Cells[1]														; store cell content in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
				{																					; {
					db_CellContent := db_Cells[A_Index+1]											; store array element as variable
					IfEqual, db_CellContent, %db_FindContent%										; if cell content shall be replaced (note: IfEqual can handle case-sensitivity)
					{
						db_Output .= A_Tab . db_ReplaceWith											; add (tab and) replacement word to output string
						db_NumberOfReplacements++													; increase variable for number of replacements by one
					} else																			; else (if cell does not contain word to replace)
						db_Output .= A_Tab . db_Cells[A_Index+1]									; add (tab and) cell content to output string
				}																					; }
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_CellContent := db_Cells[db_Column]												; store array element as variable
				IfEqual, db_CellContent, %db_FindContent%											; if cell content shall be replaced (note: IfEqual can handle case-sensitivity)
				{																					; {
					db_Cells[db_Column] := db_ReplaceWith											; store replacement word in cell array
					db_NumberOfReplacements++														; increase variable for number of replacements by one
				}																					; }
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

	; Restore case-sensitivity setting:
	StringCaseSense, %db_OriginalCaseSensitivity%													; restore case-sensitivity setting

return db_NumberOfReplacements																		; return number of replacements
}

DatabaseRound( db_DatabaseName, db_DecimalPlaces:=0, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Round database cell values
; Example: DatabaseRound( "database.txt" )															; round all database cell values to integers
; Example: DatabaseRound( "database.txt", 2 )														; round all database cell values to two decimal points
; Example: DatabaseRound( "database.txt", 2, 3 )													; round all database cell values in the third row, to two decimal points
; Example: DatabaseRound( "database.txt", 2, , 4 )													; round all database cell values in the fourth column, to two decimal points
; Example: DatabaseRound( "database.txt", 2, 3, 4 )													; round the cell value in the third row and fourth column to two decimal points
; Example: DatabaseRound( "database.txt", 2, , , TRUE )												; round all database cell values, except those in the first row, to two decimal points

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Round(A_LoopField, db_DecimalPlaces) . A_Tab						; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Round(A_LoopField, db_DecimalPlaces) . "`r`n"						; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Round(A_LoopField, db_DecimalPlaces)								; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Round(db_CellContent, db_DecimalPlaces)					; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Round(db_Cells[1], db_DecimalPlaces)									; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Round(db_Cells[A_Index+1], db_DecimalPlaces)				; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Round(db_Cells[db_Column], db_DecimalPlaces)					; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseSin( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take sin() of each cell value in specified part of database
; Example: DatabaseSin( "database.txt" )															; take sin() of each value in database
; Example: DatabaseSin( "database.txt", 2 )															; take sin() of each value in second row of database
; Example: DatabaseSin( "database.txt", , 2 )														; take sin() of each value in second column of database
; Example: DatabaseSin( "database.txt", 1, 2 )														; take sin() of cell value in the first row and second column of database
; Example: DatabaseSin( "database.txt", , , TRUE )													; take sin() of each value in database, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Sin(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Sin(A_LoopField) . "`r`n"											; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Sin(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Sin(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Sin(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Sin(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Sin(db_Cells[db_Column])										; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseSortByColumn( db_DatabaseName, db_Column, db_DecreasingSort:=FALSE, db_AlphabeticSort:=FALSE, db_SkipFirstRow:=FALSE ) { ; Sort database rows by a column
; Example: DatabaseSortByColumn( "database.txt", 2 )											; sort database by the second column (increasing numeric sorting)
; Example: DatabaseSortByColumn( "database.txt", 2, TRUE )										; sort database by the second column (decreasing numeric sorting)
; Example: DatabaseSortByColumn( "database.txt", 2, , TRUE )									; sort database by the second column (increasing alphabetic sorting)
; Example: DatabaseSortByColumn( "database.txt", 2, TRUE, TRUE )								; sort database by the second column (decreasing alphabetic sorting)
; Example: DatabaseSortByColumn( "database.txt", 2, , , TRUE )									; sort database, except the first row, by the second column (increasing numeric sorting)

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )				; rename database file (and store new filename)

	; Move the first database row to output database if it shall not be sorted:
	if ( db_SkipFirstRow==TRUE ) {																; if first row shall not be sorted
		FileReadLine, db_FirstRow, %db_TemporaryFilename%, 1									; store the first row of (temporary) database
		DatabaseRemoveRow( db_TemporaryFilename, 1)												; remove the first row from (temporary) database
		FileAppend, %db_FirstRow%`r`n, %db_Databasename%, UTF-8									; adding the first row to (output) database with a linebreak
	}

	; Find order of rows by colum content:
	Loop, read, %db_TemporaryFilename%															; loop through database rows
		db_ColumnValues .= StrSplit( A_LoopReadLine, A_Tab )[db_Column] . A_Tab					; attach value of column to be storted (followed by a tab)
	if ( db_DecreasingSort==FALSE AND db_AlphabeticSort==FALSE )								; if numeric and increasing sorting
		Sort, db_ColumnValues, D`t N															; sort numerically and increasing
	else if ( db_DecreasingSort==TRUE AND db_AlphabeticSort==FALSE )							; else if numeric and decreasing sorting
		Sort, db_ColumnValues, D`t N R															; sort numerically and decreasing
	else if ( db_DecreasingSort==FALSE AND db_AlphabeticSort==TRUE )							; else if alphabetic and increasing sorting
		Sort, db_ColumnValues, D`t 																; sort alphabetically and increasing
	else																						; else (if alphabetic and decreasing sorting)
		Sort, db_ColumnValues, D`t R															; sort alphabetic and decreasing
	db_SortedColumnValues := Object()															; initiate an array (for storing sorted column content)
	Loop, parse, db_ColumnValues, %A_Tab%														; loop through column elements
		db_SortedColumnValues.Push(A_LoopField)													; store column element in array

	; Store ordered rows in output file:
	db_OccurrenceNumber := 1 																	; set variable for occurrence number to 1 (first occurrence)
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store the number of database rows (for sorting)
	Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through (temporary) database rows
	{																							; {
		db_CellPosition := DatabaseFind( db_TemporaryFilename, db_SortedColumnValues[A_Index] 	; find and store position of database row to put in (output) database
										 , , db_Column, db_OccurrenceNumber )
		FileReadLine, db_RowOutput, %db_TemporaryFilename%, db_CellPosition[1]					; read (temporary) database row that shall be saved in (output) database
		if ( A_Index<db_NumberOfRows )															; if not the last row of database
			FileAppend, % db_RowOutput . "`r`n"													; append database row and a linebreak to (output) database
		else																					; else
			FileAppend, %db_RowOutput%															; append database row (without linebreak) to (output) database
		if ( db_SortedColumnValues[A_Index]==db_SortedColumnValues[A_Index+1] )					; if the next row and the last row to be stored in database has the same column value
			db_OccurrenceNumber++																; increase variable for occurrence number by 1
		else																					; else
			db_OccurrenceNumber := 1															; set the variable for occurrence number to 1
	}																							; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%															; delete (temporary) file

return																							; return
}

DatabaseSquareRoot( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take square root of each value in specified part of database
; Example: DatabaseSquareRoot( "database.txt" )														; take square root of each value in database
; Example: DatabaseSquareRoot( "database.txt", 2 )													; take square root of each value in second row of database
; Example: DatabaseSquareRoot( "database.txt", , 2 )												; take square root of each value in second column of database
; Example: DatabaseSquareRoot( "database.txt", 1, 2 )												; take square root of cell value in first row and second column
; Example: DatabaseSquareRoot( "database.txt", , , TRUE )											; take square root of each value in database, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Sqrt(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Sqrt(A_LoopField) . "`r`n"										; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Sqrt(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Sqrt(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Sqrt(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Sqrt(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Sqrt(db_Cells[db_Column])									; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseSubString( db_DatabaseName, db_StartingPosition:=1, db_Length:="", db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Replace specified cells with substrings
; Example: DatabaseSubString( "database.txt", 2 )															; remove the first character of each database cell
; Example: DatabaseSubString( "database.txt", 2, 1 )														; keep only the second character of each database cell
; Example: DatabaseSubString( "database.txt", -0, 1 )														; keep only the last character of each database cell
; Example: DatabaseSubString( "database.txt", 2, 1, 3 )														; keep only the second character of each cell in the third database row
; Example: DatabaseSubString( "database.txt", 2, 1, , 4 )													; keep only the second character of each cell in the fourth database column
; Example: DatabaseSubString( "database.txt", 2, 1, , , TRUE )												; keep only the second character of each database cell, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )							; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {																	; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%												; loop through database (row by row)
		{																									; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {													; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n															; append the current content of the first row
				continue																					; continue loop (next iteration)
			}
			db_LineNumber      := A_Index																	; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )						; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%															; loop through cells on row (cell by cell)
			{																								; {
				if ( A_Index<db_NumberOfColumns )															; if not the last database column
					if ( db_Length=="" )																	; if number of characters to keep is not specified
						FileAppend, % SubStr(A_LoopField, db_StartingPosition) . A_Tab						; save updated cell content followed by a tab to output file
					else																					; else (number of characters to keep is specified)
						FileAppend, % SubStr(A_LoopField, db_StartingPosition, db_Length) . A_Tab			; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )													; else if not the last row
					if ( db_Length=="" )																	; if number of characters to keep is not specified
						FileAppend, % SubStr(A_LoopField, db_StartingPosition) . "`r`n"						; save updated cell content followed by a linebreak to output file
					else																					; else (number of characters to keep is specified)
						FileAppend, % SubStr(A_LoopField, db_StartingPosition, db_Length) . "`r`n"			; save updated cell content followed by a linebreak to output file
				else   																						; else (last cell of last row)
					if ( db_Length=="" )																	; if number of characters to keep is not specified
						FileAppend, % SubStr(A_LoopField, db_StartingPosition)								; save updated cell content to output file
					else																					; else (number of characters to keep is specified)
						FileAppend, % SubStr(A_LoopField, db_StartingPosition, db_Length)					; save updated cell content to output file
			}																								; }
		}																									; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {															; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )									; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%												; loop through database rows
		{																									; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {													; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n															; append the current content of the first row
				continue																					; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine														; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)						; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)							; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)					; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {																; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1					; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)					; store content of cell to the right of cell to update
			} else {																						; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)				; store cell content
				db_RightPartOfRow       := 																	; store nothing in output variable for content to the right of cell content
			}
			if ( db_Length=="" )																			; if number of characters to keep is not specified
				db_CellContent 			:= SubStr(db_CellContent, db_StartingPosition)						; update cell content as specified
			else																							; else (number of characters to keep is specified)
				db_CellContent 			:= SubStr(db_CellContent, db_StartingPosition, db_Length)			; update cell content as specified
			if ( A_Index<db_NumberOfRows )																	; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n						; save updated row and a linebreak in output file
			else																							; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%							; store updated row (but no linebreak) in output file
		}																									; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {															; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )									; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%												; loop through database rows
		{																									; {
			if ( A_Index==db_Row ) {																		; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )												; split row into cells
			if ( db_Length=="" )																			; if number of characters to keep is not specified
				db_Output := SubStr(db_Cells[1], db_StartingPosition)										; store first cell of row (with updated cell content)
			else																							; else (number of characters to keep is specified)
				db_Output := SubStr(db_Cells[1], db_StartingPosition, db_Length)							; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1																; loop through cells of row (all except the first cell)
					if ( db_Length=="" )																	; if number of characters to keep is not specified
						db_Output .= A_Tab . SubStr(db_Cells[A_Index+1], db_StartingPosition)				; store (updated) cell content
					else																					; else (number of characters to keep is specified)
						db_Output .= A_Tab . SubStr(db_Cells[A_Index+1], db_StartingPosition, db_Length)	; store (updated) cell content
			} else																							; else (not the database row to modify)
				db_Output := A_LoopReadLine																	; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )																	; if not the last row of database
				FileAppend, %db_Output%`r`n																	; save output string and linebreak to output file
			else																							; else (not the last row of database
				FileAppend, %db_Output%																		; save output string (without linebreak) to output file
		}																									; }
	}

	; If row and column are specified:
	else {																									; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )									; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%												; loop through database rows
		{																									; {
			if ( A_Index==db_Row ) {																		; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )												; split row into cells
				if ( db_Length=="" )																		; if number of characters to keep is not specified
					db_Cells[db_Column] := SubStr(db_Cells[db_Column], db_StartingPosition)					; store (updated) cell content
				else																						; else (number of characters to keep is specified)
					db_Cells[db_Column] := SubStr(db_Cells[db_Column], db_StartingPosition, db_Length)		; store (updated) cell content
				db_Output := db_Cells[1]																	; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1																; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]												; attach tab and cell content to output string
			} else																							; else (not the database row to modify)
				db_Output := A_LoopReadLine																	; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )																	; if not the last row of database
				FileAppend, %db_Output%`r`n																	; save output string and linebreak to output file
			else																							; else (not the last row of database
				FileAppend, %db_Output%																		; save output string (without linebreak) to output file
		}																									; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																		; delete (temporary) file

return																										; return
}

DatabaseSubtractColumns( db_DatabaseName, db_Column1, db_Column2, db_SkipFirstRow:=FALSE ) { ; Add new column containing one column subtracted by another column
; Example: DatabaseSubtractColumns( "database.txt", 3, 5 )											; store column 3 subtracted by column 5 as a new column
; Example: DatabaseSubtractColumns( "database.txt", 3, 5, TRUE )									; store column 3 subtracted by column 5 as a new column, but skip the first row
; Example: NewColumn := DatabaseSubtractColumns( "database.txt", 3, 5 )								; store column 3 subtracted by column 5 as a new column, and show the new column number
;          MsgBox, The new column has column number %NewColumn%										;

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; Save database with new column:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )								; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%											; loop through each row of database
	{																								; {
		if !( db_SkipFirstRow==TRUE AND A_Index==1 )												; if not first row and first row shall be skipped
			db_RowOutput := A_LoopReadLine . A_Tab . StrSplit( A_LoopReadLine, A_Tab )[db_Column1]
													-StrSplit( A_LoopReadLine, A_Tab )[db_Column2]	; prepare output row with new column
		else																						; else
			db_RowOutput := A_LoopReadLine . A_Tab													; prepare output row with new column
		if ( A_Index<db_NumberOfRows )																; if not the last row of database
			db_RowOutput .= "`r`n"																	; add linebreak at the end of the row
		FileAppend, %db_RowOutput%																	; add modified database row (with new column) to output file
	}																								; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return DatabaseGetNumberOfColumns( db_DatabaseName )												; return column number of new database column
}

DatabaseSubtraction( db_DatabaseName, db_SubtractBy, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Subtract a value from each cell in specified part of database
; Example: DatabaseSubtraction( "database.txt", 2 )													; subtract 2 from each database cell value
; Example: DatabaseSubtraction( "database.txt", 2, 3 )												; subtract 2 from each cell value in the third row
; Example: DatabaseSubtraction( "database.txt", 2, , 3 )											; subtract 2 from each cell value in the third column
; Example: DatabaseSubtraction( "database.txt", 2, 1, 3 )											; subtract 2 from the cell in the first row and third column
; Example: DatabaseSubtraction( "database.txt", 2, , , TRUE )										; subtract 2 from each database cell value, with the first row excluded

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % A_LoopField-db_SubtractBy . A_Tab									; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % A_LoopField-db_SubtractBy . "`r`n"								; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % A_LoopField-db_SubtractBy											; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= db_CellContent-db_SubtractBy								; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := db_Cells[1]-db_SubtractBy												; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]-db_SubtractBy							; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := db_Cells[db_Column]-db_SubtractBy							; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseSumColumns( db_DatabaseName, db_Column1, db_Column2, db_SkipFirstRow:=FALSE ) { ; Add new column containing the sum of two other columns
; Example: DatabaseSumColumns( "database.txt", 3, 5 )												; add a new column containing the sum of column 3 and 5
; Example: DatabaseSumColumns( "database.txt", 3, 5, TRUE )											; add a new column containing the sum of column 3 and 5, but skip the first row
; Example: NewColumn := DatabaseSumColumns( "database.txt", 3, 5 )									; add a new column containing the sum of column 3 and 5, and show the new column number
;          MsgBox, The new column has column number %NewColumn%										;

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; Save database with new column:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )								; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%											; loop through each row of database
	{																								; {
		if !( db_SkipFirstRow==TRUE AND A_Index==1 )												; if not first row and first row shall be skipped
			db_RowOutput := A_LoopReadLine . A_Tab . StrSplit( A_LoopReadLine, A_Tab )[db_Column1]
													+StrSplit( A_LoopReadLine, A_Tab )[db_Column2]	; prepare output row with new column
		else																						; else
			db_RowOutput := A_LoopReadLine . A_Tab													; prepare output row with new column
		if ( A_Index<db_NumberOfRows )																; if not the last row of database
			db_RowOutput .= "`r`n"																	; add linebreak at the end of the row
		FileAppend, %db_RowOutput%																	; add modified database row (with new column) to output file
	}																								; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return DatabaseGetNumberOfColumns( db_DatabaseName )												; return column number of new database column
}

DatabaseSwitchColumns( db_DatabaseName, db_Column1, db_Column2 ) { ; Switch the poitions of two database columns
; Example: DatabaseSwitchColumns( "database.txt", 1, 5 )									; switch the positions of column 1 and 5

	; Return if both column arguments contain the same column:
	if ( db_Column1==db_Column2 )															; if both column arguments contain the same column
		return																				; return

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )			; rename database file (and store new filename)

	; Save database with column positions switched:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )						; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%									; loop through each row of database
	{																						; {
		db_RowArray := StrSplit(A_LoopReadLine, "`t")										; store current row (cell content) as array
		if ( db_Column1<db_Column2 ) {														; if the first column is to the left of the second column
			db_RowArray.InsertAt( db_Column1+1, db_RowArray[db_Column2] )					; insert cell content in new position of array
			db_RowArray.InsertAt( db_Column2+1, db_RowArray[db_Column1] )					; insert cell content in new position of array
			db_RowArray.RemoveAt( db_Column1 )												; remove cell content of array
			db_RowArray.RemoveAt( db_Column2+1 )											; remove cell content of array
		} else {																			; else (if the second column is to the left of the first column)
			db_RowArray.InsertAt( db_Column2+1, db_RowArray[db_Column1] )					; insert cell content in new position of array
			db_RowArray.InsertAt( db_Column1+1, db_RowArray[db_Column2] )					; insert cell content in new position of array
			db_RowArray.RemoveAt( db_Column2 )												; remove cell content of array
			db_RowArray.RemoveAt( db_Column1+1 )											; remove cell content of array
		}
		db_RowOutput = % db_RowArray[1]														; initiate output string with first element of (row) cell array
		Loop % db_RowArray.Length()-1														; loop through each but one element of (row) cell array
			db_RowOutput .= A_Tab . db_RowArray[A_Index+1]									; append a tab and an element of (row) cell array
		if ( A_Index<db_NumberOfRows )														; if not the last row of database
			db_RowOutput .= "`r`n"															; add linebreak at the end of the row
		FileAppend, %db_RowOutput%															; add modified database row (with new column) to output file
	}																						; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%														; delete (temporary) file

return																						; return
}

DatabaseSwitchRows( db_DatabaseName, db_Row1, db_Row2 ) { ; Switch the positions of two database rows
; Example: DatabaseSwitchRows( "database.txt", 1, 3 )									; switch the positions of the first and third database rows

	; Return if both row positions are equal:
	if ( db_Row1==db_Row2 )																; if column shall be moved to initial position
		return																			; return

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )		; rename database file (and store new filename)

	; Save database with rows switched:
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store number of database rows
	Loop, Read, %db_TemporaryFilename%, %db_DatabaseName%								; loop through each row of database
	{																					; {
		if ( A_Index==db_Row1 )															; if it is the first row to switch
			FileReadLine, db_RowOutput, %db_TemporaryFilename%, %db_Row2%				; store the second row to switch as output
		else if ( A_Index==db_Row2 )													; if it is the second row to switch
			FileReadLine, db_RowOutput, %db_TemporaryFilename%, %db_Row1%				; store the first row to switch as output
		else																			; else
			db_RowOutput := A_LoopReadLine												; store the current row as output
		if ( A_Index<db_NumberOfRows )													; if not the last row of database
			db_RowOutput .= "`r`n"														; add linebreak at the end of the row
		FileAppend, %db_RowOutput%														; append row to database
	}																					; }

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%													; delete (temporary) file

return																					; return
}

DatabaseTan( db_DatabaseName, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Take tan() of each cell value in specified part of database
; Example: DatabaseTan( "database.txt" )															; take tan() of each value in database
; Example: DatabaseTan( "database.txt", 2 )															; take tan() of each value in second row of database
; Example: DatabaseTan( "database.txt", , 2 )														; take tan() of each value in second column of database
; Example: DatabaseTan( "database.txt", 1, 2 )														; take tan() of cell value in the first row and second column of database
; Example: DatabaseTan( "database.txt", , , TRUE )													; take tan() of each value in database, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % Tan(A_LoopField) . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % Tan(A_LoopField) . "`r`n"											; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % Tan(A_LoopField)													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			db_CellContent 				:= Tan(db_CellContent)										; update cell content as specified
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Output := Tan(db_Cells[1])														; store first cell of row (with updated cell content)
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . Tan(db_Cells[A_Index+1])									; attach tab and updated cell content
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_Cells[db_Column] := Tan(db_Cells[db_Column])										; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseTranspose( db_DatabaseName ) { ; Transpose database (turn columns into rows, and rows into columns)
; Example: DatabaseTranspose( "database.txt" )													; transpose database (turn columns into rows, and rows into columns)

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )				; rename database file (and store new filename)

	; Save transposed database:
	db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )					; store number of database columns
	db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
	db_DatabaseOpen := FileOpen( db_DatabaseName, "w" )											; open database file (for writing)
	Loop, %db_NumberOfColumns%																	; loop (as many iterations as columns)
	{																							; {
		db_Column := A_Index																	; store iteration number
		Loop, Read, %db_TemporaryFilename%														; loop through each row of database
		{																						; {
			if ( A_Index<db_NumberOfRows )														; if not the last row
				db_DatabaseOpen.Write( StrSplit( A_LoopReadLine, A_Tab )[db_Column] . A_Tab )	; write cell content followed by a tab to database
			else																				; else (the last row)
				db_DatabaseOpen.Write( StrSplit( A_LoopReadLine, A_Tab )[db_Column] )			; write cell content to database
		}																						; }
		if ( A_Index<db_NumberOfColumns )														; if not the last row of database
			db_DatabaseOpen.Write( "`r`n" )														; write linebreak to database
	}																							; }
	db_DatabaseOpen.Close()																		; close database file

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%															; delete (temporary) file

return																							; return
}

DatabaseTrimLeft( db_DatabaseName, db_Characters, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Remove a specified number of characters (from the left) from database cells
; Example: DatabaseTrimLeft( "database.txt", 2 )													; remove the first two character in each cell of database
; Example: DatabaseTrimLeft( "database.txt", 2, 3 )													; remove the first two character in each cell of the third database row
; Example: DatabaseTrimLeft( "database.txt", 2, , 3 )												; remove the first two character in each cell of the third database column
; Example: DatabaseTrimLeft( "database.txt", 2, , , TRUE )											; remove the first two character in each cell of database, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				StringTrimLeft, db_CellContent, A_LoopField, db_Characters							; store trimmed cell content
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % db_CellContent . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % db_CellContent . "`r`n"											; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % db_CellContent													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			StringTrimLeft, db_CellContent, db_CellContent, db_Characters							; store trimmed cell content
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_CellContent := db_Cells[1]														; store array element as variable
				StringTrimLeft, db_Output, db_CellContent, db_Characters							; store trimmed cell content
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
				{																					; {
					db_CellContent := db_Cells[A_Index+1]											; store array element as variable
					StringTrimLeft, db_CellContent, db_CellContent, db_Characters					; store trimmed cell content
					db_Output .= A_Tab . db_CellContent												; attach tab and updated cell content
				}																					; }
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_CellContent := db_Cells[db_Column]												; store array element as variable
				StringTrimLeft, db_CellContent, db_CellContent, db_Characters						; store trimmed cell content
				db_Cells[db_Column] := db_CellContent												; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseTrimRight( db_DatabaseName, db_Characters, db_Row:="", db_Column:="", db_SkipFirstRow:=FALSE ) { ; Remove a specified number of characters (from the right) from database cells
; Example: DatabaseTrimRight( "database.txt", 2 )													; remove the first two character in each cell of database
; Example: DatabaseTrimRight( "database.txt", 2, 3 )												; remove the first two character in each cell of the third database row
; Example: DatabaseTrimRight( "database.txt", 2, , 3 )												; remove the first two character in each cell of the third database column
; Example: DatabaseTrimRight( "database.txt", 2, , , TRUE )											; remove the first two character in each cell of database, but skip the first row

	; Rename database to unused filename:
	db_TemporaryFilename := db_RenameDatabaseToUnusedFilename( db_DatabaseName )					; rename database file (and store new filename)

	; If neither row nor column is specified:
	if ( db_Row=="" AND db_Column=="" ) {															; if neither row nor column is specified
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database (row by row)
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_LineNumber      := A_Index															; store current database row
			db_NumberOfRows    := DatabaseGetNumberOfRows( db_TemporaryFilename )					; store (total) number of database rows
			db_NumberOfColumns := DatabaseGetNumberOfColumns( db_TemporaryFilename )				; store (total) number of database columns
			Loop, parse, A_LoopReadLine, %A_Tab%													; loop through cells on row (cell by cell)
			{																						; {
				StringTrimRight, db_CellContent, A_LoopField, db_Characters							; store trimmed cell content
				if ( A_Index<db_NumberOfColumns )													; if not the last database column
					FileAppend, % db_CellContent . A_Tab											; save updated cell content followed by a tab to output file
				else if ( db_LineNumber<db_NumberOfRows )											; else if not the last row
					FileAppend, % db_CellContent . "`r`n"											; save updated cell content followed by linebreak to output file
				else   																				; else (last cell of last row)
					FileAppend, % db_CellContent													; save updated cell content to output file
			}																						; }
		}																							; }
	}

	; If column is specified but row is not specified:
	else if ( db_Row=="" AND !(db_Column=="") ) {													; else if column is specified but row is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==1 AND db_SkipFirstRow==TRUE ) {											; if first database row and it shall be skipped
				FileAppend, %A_LoopReadLine%`r`n													; append the current content of the first row
				continue																			; continue loop (next iteration)
			}
			db_DatabaseRow 			:= A_LoopReadLine												; read (current) line of database
			db_TabBeforeCellContent := InStr(db_DatabaseRow, A_Tab, , 1, db_Column-1)				; store position of tab before cell content on database row
			db_TabAfterCellContent  := InStr(db_DatabaseRow, A_Tab, , 1, db_Column)					; store position of tab after cell content on database row
			db_LeftPartOfRow        := SubStr(db_DatabaseRow, 1, db_TabBeforeCellContent)			; store part of database row before cell content to update
			if !( db_TabAfterCellContent==0 ) {														; if a column other than the last database column shall be updated
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1			; store content of cell to update
												, db_TabAfterCellContent-db_TabBeforeCellContent-1)
				db_RightPartOfRow       := SubStr(db_DatabaseRow, db_TabAfterCellContent)			; store content of cell to the right of cell to update
			} else {																				; else (last database column shall be updated)
				db_CellContent      	:= SubStr(db_DatabaseRow, db_TabBeforeCellContent+1)		; store cell content
				db_RightPartOfRow       := 															; store nothing in output variable for content to the right of cell content
			}
			StringTrimRight, db_CellContent, db_CellContent, db_Characters							; store trimmed cell content
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%`r`n				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend, %db_LeftPartOfRow%%db_CellContent%%db_RightPartOfRow%					; store updated row (but no linebreak) in output file
		}																							; }
	}

	; If row is specified but column is not specified:
	else if ( !(db_Row=="") AND db_Column=="" ) {													; else if row is specified but column is not specified
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_CellContent := db_Cells[1]														; store array element as variable
				StringTrimRight, db_Output, db_CellContent, db_Characters							; store trimmed cell content
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
				{																					; {
					db_CellContent := db_Cells[A_Index+1]											; store array element as variable
					StringTrimRight, db_CellContent, db_CellContent, db_Characters					; store trimmed cell content
					db_Output .= A_Tab . db_CellContent												; attach tab and updated cell content
				}																					; }
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; If row and column are specified:
	else {																							; else (if both row and column are specified)
		db_NumberOfRows := DatabaseGetNumberOfRows( db_TemporaryFilename )							; store number of database rows
		Loop, read, %db_TemporaryFilename%, %db_DatabaseName%										; loop through database rows
		{																							; {
			if ( A_Index==db_Row ) {																; if database row to modify
				db_Cells := StrSplit( A_LoopReadLine, A_Tab )										; split row into cells
				db_CellContent := db_Cells[db_Column]												; store array element as variable
				StringTrimRight, db_CellContent, db_CellContent, db_Characters						; store trimmed cell content
				db_Cells[db_Column] := db_CellContent												; update database cell as specified
				db_Output := db_Cells[1]															; store first cell of database row in output string
				Loop, % db_Cells.MaxIndex()-1														; loop through cells of row (all except the first cell)
					db_Output .= A_Tab . db_Cells[A_Index+1]										; attach tab and cell content to output string
			} else																					; else (not the database row to modify)
				db_Output := A_LoopReadLine															; add (unmodified) database row to output string
			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend, %db_Output%`r`n															; save output string and linebreak to output file
			else																					; else (not the last row of database
				FileAppend, %db_Output%																; save output string (without linebreak) to output file
		}																							; }
	}

	; Delete temporary database file:
	FileDelete, %db_TemporaryFilename%																; delete (temporary) file

return																								; return
}

DatabaseView( db_DatabaseName, db_UnPauseScript:=FALSE ) { ; Displays database in a graphical interface

	; Store database filesize:
	FileGetSize, db_DatabaseFileSize, %db_DatabaseName%															; get size of database in bytes
	if ( db_DatabaseFileSize > 1048576 ) { 																		; if database is larger than 1 megabyte (base 2)
		db_DatabaseFileSize := Round(db_DatabaseFileSize/1048576, 1)											; convert the filesize to mb
		db_DatabaseFileSizeUnit = mb																			; set unit to megabytes
	}
	else if ( db_DatabaseFileSize > 1024 ) { 																	; else if database is larger than 1 kilobyte (base 2)
		db_DatabaseFileSize := Round(db_DatabaseFileSize/1024, 1)												; convert the filesize to kb
		db_DatabaseFileSizeUnit = kb																			; set unit to kilobytes
	}
	else																										; else
		db_DatabaseFileSizeUnit = bytes																			; set unit to bytes

	; Store database dimensions:
	db_DatabaseNumberOfRows := DatabaseGetNumberOfRows( db_DatabaseName )										; get number of rows in database
	db_DatabaseNumberOfColumns := DatabaseGetNumberOfColumns( db_DatabaseName )									; get number of columns in database

	; Create GUI controls:
	Gui, +Resize																								; enable re-sizing of window
	Gui, Add, Text, y9 w160 h20 Disabled Center, File: %db_DatabaseName%										; add text control
	Gui, Add, Text, y9 w140 h20 Disabled, Dimensions: %db_DatabaseNumberOfRows% x %db_DatabaseNumberOfColumns%	; add text control
	Gui, Add, Text, y9 w90 h20 Disabled Right, Size: %db_DatabaseFileSize% %db_DatabaseFileSizeUnit%			; add text control
	Gui, Add, ListView, x-1 y30 NoSort, % Chr(32)																; add listview control (and one column without text)

	; Create ListView columns:
	LV_ModifyCol(1, "35 Right")																					; set width and right-alignment of first column
	Loop, % Min( db_DatabaseNumberOfColumns, 50 )																; loop through all database columns (or 50 if database has more columns)
		LV_InsertCol( (A_Index+1) , "80 Right", "Column " A_Index)												; insert a column for each database column

	; Create ListView rows:
	Loop, Read, %db_DatabaseName%																				; loop through all database rows
	{																											; {
		db_Cells := StrSplit( A_LoopReadLine, A_Tab )															; split current row into cells
		LV_Add( , A_Index																						; add up to 50 database cells to listview
			, db_Cells[1] 	, db_Cells[2] 	, db_Cells[3] 	, db_Cells[4] 	, db_Cells[5] 
			, db_Cells[6] 	, db_Cells[7] 	, db_Cells[8] 	, db_Cells[9] 	, db_Cells[10]
			, db_Cells[11]	, db_Cells[12]	, db_Cells[13]	, db_Cells[14]	, db_Cells[15]
			, db_Cells[16]	, db_Cells[17]	, db_Cells[18]	, db_Cells[19]	, db_Cells[20]
			, db_Cells[21]	, db_Cells[22]	, db_Cells[23]	, db_Cells[24]	, db_Cells[25]
			, db_Cells[26]	, db_Cells[27]	, db_Cells[28]	, db_Cells[29]	, db_Cells[30]
			, db_Cells[31]	, db_Cells[32]	, db_Cells[33]	, db_Cells[34]	, db_Cells[35]
			, db_Cells[36]	, db_Cells[37]	, db_Cells[38]	, db_Cells[39]	, db_Cells[40]
			, db_Cells[41]	, db_Cells[42]	, db_Cells[43]	, db_Cells[44]	, db_Cells[45]
			, db_Cells[46]	, db_Cells[47]	, db_Cells[48]	, db_Cells[49]	, db_Cells[50] )
	}																											; }

	; Calculate (initial) height and width of window:
	db_ViewerWidth := 60+80*db_DatabaseNumberOfColumns															; calculate width (based on number of columns)
	if ( db_ViewerWidth>A_ScreenWidth*0.85 )																	; if window width is more than 85% of screen width
		db_ViewerWidth := A_ScreenWidth*0.85																	; set window width to 85% of screen width
	db_ViewerHeight := 65+18*db_DatabaseNumberOfRows															; calculate height (based on number of rows)
	if ( db_ViewerHeight>A_ScreenHeight*0.6 )																	; if window height is more than 60% of screen height
		db_ViewerHeight := A_ScreenHeight*0.6																	; set window height to 60% of screen height

	; Show GUI:
	Gui, Show, w%db_ViewerWidth% h%db_ViewerHeight%, Database Viewer											; show gui
	if ( db_DatabaseNumberOfColumns>50 )																		; if more than 50 columns in database
		MsgBox, 262208, Too many columns, Only the first 50 columns will be displayed in the viewer.			; display notification about column limitation in viewer
	if ( db_UnPauseScript==FALSE )																				; if set to pause script
		Pause, On																								; pause script
	return																										; return

	; Adjust controls if window is resized:
	GuiSize: 																									; runs when window is resized (and upon start)
	if ( ErrorLevel = 1 ) 																						; if window is minimized
		return																									; return
	db_ListViewWidth := A_GuiWidth + 2																			; calculate listview width
	db_ListViewHeight := A_GuiHeight - 29																		; calculate listview height
	GuiControl, Move, SysListView321, W%db_ListViewWidth% H%db_ListViewHeight%									; adjust listview width and height
	if ( A_GuiWidth < 500 ) {																					; if window width is less than 500 pixels
		db_SizeTextX := A_GuiWidth + 500																		; calculate position outside window (for filesize text)
		db_DimensionTextX := A_GuiWidth + 500																	; calculate position outside window (for dimensions text)
	} else {																									; else
		db_SizeTextX := A_GuiWidth - 100																		; calculate position inside window (for filesize text)
		db_DimensionTextX := 10																					; calculate position inside window (for dimensions text)
	}
	GuiControl, Move, Static3, x%db_SizeTextX%																	; move filesize text to calculated position
	GuiControl, Move, Static2, x%db_DimensionTextX%																; move dimensions text to calculated position
	db_NameTextX := (A_GuiWidth*0.5)-80																			; calculate position for filename text
	GuiControl, Move, Static1, x%db_NameTextX%																	; move filename text to calculated position
	return																										; return

	; Close GUI:
	GuiClose:																									; runs when closing window
	Gui, Destroy																								; destroy gui
	if ( db_UnPauseScript==FALSE )																				; if set to pause script
		Pause, Off																								; resume script
	return																										; return

return 0																										; return 0 (script should never get here)
}

; ##############################################################################################################################################################################################
; #                                                                                                                                                                                            #
; #     INTERNAL FUNCTIONS:                                                                                                                                                                    #
; #                                                                                                                                                                                            #
; ##############################################################################################################################################################################################

db_RenameDatabaseToUnusedFilename( db_DatabaseName ) { ; Rename database file (to an unused filename) and return the new filename

	; Find filename not in use:
	SplitPath, db_DatabaseName, , , , db_DatabaseNameNoExtension						; get database filename without extension
	Loop,																				; loop
		IfNotExist, %db_DatabaseNameNoExtension%_temp%A_Index%.txt						; if filename is available
		{																				; {
			db_TemporaryFilename = %db_DatabaseNameNoExtension%_temp%A_Index%.txt		; store filename
			break																		; break
		}																				; }

	; Rename database file:
	FileMove, %db_DatabaseName%, %db_TemporaryFilename%									; rename database

return db_TemporaryFilename																; return temporary database filename
}

; ##############################################################################################################################################################################################
; #                                                                                                                                                                                            #
; #     END.                                                                                                                                                                                   #
; #                                                                                                                                                                                            #
; ##############################################################################################################################################################################################
