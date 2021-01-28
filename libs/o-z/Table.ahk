/*
####################################################################################################
####################################################################################################
######                                                                                        ######
######                      Function Library for 9/10 Table Manipulation                      ######
######                                                                                        ######
####################################################################################################
####################################################################################################

	AutoHotkey Version:    1.0.48.05
	Language:              English
	Encoding:              ANSI
	Created On:            2010/11/15
	Author:                [VxE]
	Lib Version:           0.27
	Available @:           http://www.autohotkey.com/forum/viewtopic.php?t=66290
	VersionInfo:           http://dl.dropbox.com/u/13873642/mufl_table.txt

	These functions require a specific table format to function properly. A table must use a single
	newline character to separate table rows from each other and from the table header. Each table
	row must contain exactly the same number of tab characters as the table header. Any table that
	does not conform to these restrictions is unlikely to work correctly with these functions.

	Referencing Conventions:

	When referencing columns or cells, functions in this library use the name of the column of
	interest. To override this behavior and force the functions to reference columns or cells by
	their ordinal position ( 1 = the first / leftmost ), precede the parameter's value with a
	single tab character. Similarly, when referencing rows, functions in this library use the
	contents of the first column of the row. To override this and use the row's ordinal position
	instead ( 1 = the row just after the header ), precede the parameter's value with a single tab.
	All comparisons are string-based* so be careful about using numeric row identifiers.
	(*) NOTE: the following functions will perform non-string comparisons if comparing non-string
	data: Table_GetRowIndex, Table_Between

	Function List:

	Table_Aggregate    - Returns table metadata, typicaly derived from a single table column.
	Table_Append       - Appends rows, columns, or both to a table. Also manipulates table columns.
	Table_Between      - A simple QUERY. Removes table rows that don't satisfy an inequality.
	Table_ColToList    - Extracts a single column from the table in the form of a delimited list.
	Table_Decode       - Replaces character entities for tabs and newlines with the actual characters.
	Table_Deintersect  - Returns the input table with rows that match the criteria removed.
	Table_Encode       - Replaces tabs and newlines with character entities (similar to html entities).
	Table_FromCSV      - Converts a CSV table to a 9/10 table (literal tabs and newlines are encoded).
	Table_FromHTML     - Converts an HTML table into a 9/10 table
	Table_FromINI      - Converts the text of an INI file into a 2-column table (Section/Key,Value).
	Table_FromListview - Returns a table with the contents of the default gui's active listview.
	Table_FromLvHwnd   - Returns a table with the contents of the listview and its header.
	Table_FromXMLNode  - Converts an XML node array into a 9/10 table (not a lossless conversion).
	Table_FormatTime   - Converts the values in the indicated column using the FormatTime command.
	Table_GetCell      - Returns the value of one cell in the table.
	Table_GetColName   - Returns the name of the table column at the given position.
	Table_GetRowIndex  - Returns a row's ordinal position in the table.
	Table_Header       - Returns the table's header. (The counterpart, 'Table_Decapitate', was removed)
	Table_Intersect    - Returns the input table with rows that don't match the criteria removed.
	Table_Invert       - Inverts the table so that the first column becomes the new header.
	Table_Join         - Adds columns from one table to another, arranging rows to match.
	Table_Len          - Returns the number of rows in the table.
	Table_RemCols      - Removes table columns, either by name or index.
	Table_RemRows      - Removes table rows, either by id or by index.
	Table_Reverse      - Reverses the row order of the table.
	Table_RotateL      - Rotates a table 90 degrees to the left.
	Table_SetCell      - Replaces the contents of one cell in the table and returns the modified table.
	Table_SpacePad     - Converts a 9/10 table into a space-padded table.
	Table_Sort         - Sorts the table based on the contents of one column and some user options.
	Table_SubTable     - Removes some rows from the table.
	Table_ToCSV        - Converts a table to CSV format. Tab and newline character entities are decoded.
	Table_ToListview   - Modifies the current listview using the given table.
	Table_ToLvHWND     - Modifies a listview using the given table.
	Table_Transpose    - Flips a table along its main diagonal.
	Table_Update       - Updates certain cells in a table using data from another table.
	Table_UpdateAppend - Updates a table, then appends rows that didn't have a match in the table.
	Table_Width        - Returns the number of columns in the table.
*/
; [0721]
Table_Aggregate( Table, Column="`t1", Op="sum", GroupBy="", Round="" ) { ; -------------------------
; Returns metadata derived from the table. 'Op' determines the aggregate data operation. Valid
; values for 'Op' include 'Sum', 'Min', 'Max', 'Med', 'Avg', 'Span', 'Count', and 'Dev'.
; If 'GroupBy' is not blank, the operation is resolved for each unique value in the column specified
; in 'GroupBy' and the results are returned in a 2-column table with the left column having the
; group column name and the right column having the name of the data column. E.g: if the table
; has 3 columns (A B C) then Table_Aggregate( Table, "B", "Sum", "C" ) will yield a table with the
; header "C B" where the values in 'C' are unique and the values in 'B' are the sums for each group.

	If Op NOT IN sum,min,max,med,avg,span,count,dev
		Return "" ; error: invalid operation

	oel := ErrorLevel, Groups := "`n", tagz := "0", Round |= 0
	If Round IS NOT INTEGER
		Round := ""

	Loop, Parse, Table, `n, `r ; extract the relevant column values and maybe the groups too
		If ( A_Index = 1 ) ; Handle the header
		{
			VarSetCapacity( Table, 0 )
			StringReplace, header, A_LoopField, % "`t", % "`t", UseErrorLevel
			ColCount := ErrorLevel, header := "`t" header "`t"
			If Asc( Column ) != 9
			{
				StringLeft, Column, header, InStr( header, "`t" Column "`t" )
				StringReplace, Column, Column, % "`t", % "`t", UseErrorLevel
				Column := ErrorLevel - 1
			}
			Else Column := Round( SubStr( Column, 2 ) ) - 1
			If ( Column < 0 ) || ( ColCount < Column )
				Return "", ErrorLevel := oel ; Error: invalid column specified
		
			If ( GroupBy != "" ) && Asc( GroupBy ) != 9
			{
				StringLeft, GroupBy, header, InStr( header, "`t" GroupBy "`t" )
				StringReplace, GroupBy, GroupBy, % "`t", % "`t", UseErrorLevel
				GroupBy := ErrorLevel - 1 <= ColCount ? ErrorLevel - 1 : 0 - 1
			}
			Else GroupBy := Round( SubStr( GroupBy, 2 ) ) - 1
			; don't error if 'groupBy' is invalid... treat it as blank
		}
		Else ; handle the body
		{
			Table := A_Index - 1 ; keep count how many values we have
			If ( Column = 0 )
				StringLeft, vxe, A_LoopField, InStr( A_LoopField . "`t", "`t" ) - 1
			Else If ( Column = ColCount )
				StringTrimLeft, vxe, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
			Else
			{
				StringGetPos, pos, A_LoopField, % "`t", L%Column%
				StringTrimLeft, vxe, A_LoopField, pos + 1
				StringLeft, vxe, vxe, InStr( vxe, "`t" ) - 1
			}
			Table_Aggregate_Value_%Table% := vxe ; keep the value in a pseudo-array member
			If ( GroupBy < 0 ) ; If the user doesn't want groups, use a single group internally
				Table_Aggregate_Group_%Table% := ""
			Else ; otherwise, the user wants groups, keep the group value
			{
				If ( GroupBy = 0 )
					StringLeft, Acu, A_LoopField, InStr( A_LoopField . "`t", "`t" ) - 1
				Else If ( GroupBy = ColCount )
					StringTrimLeft, Acu, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
				Else
				{
					StringGetPos, pos, A_LoopField, % "`t", L%GroupBy%
					StringTrimLeft, Acu, A_LoopField, pos + 1
					StringLeft, Acu, Acu, InStr( Acu, "`t" ) - 1
				}
				Table_Aggregate_Group_%Table% := Acu
			}
		}

	; Instead of bothering with the user's selected operation now, just calculate all of
	; them (except deviation and median) since some operations require others. E.g: 'span' is the
	; max minus the min and 'dev' requires the avg to be known.
	Loop %Table% ; for each datum in the table...
	{
		If !( pos := InStr( Groups, "`n" Table_Aggregate_Group_%A_Index% "`n" ) )
		{ ; zomg! we haven't seen this group item before!. So set most of the aggs to the item val
			tagz := "" tagz + 1
			Groups .= Table_Aggregate_Group_%A_Index% . "`n", Table_Aggregate_Count_%tagz% := 1
			Table_Aggregate_Med_%tagz% := Table_Aggregate_Sum_%tagz% := Table_Aggregate_Min_%tagz% := Table_Aggregate_Max_%tagz% := Table_Aggregate_Avg_%tagz% := Table_Aggregate_Value_%A_Index%
			Continue
		}
		StringLeft, Acu, Groups, pos
		StringReplace, Acu, Acu, `n, `n, UseErrorLevel
		Acu := ErrorLevel
		Table_Aggregate_Count_%Acu% += 1, Table_Aggregate_Sum_%Acu% += Table_Aggregate_Value_%A_Index%
		Table_Aggregate_Avg_%Acu% := Table_Aggregate_Avg_%Acu% * ( 1 - 1 / Table_Aggregate_Count_%Acu% ) + Table_Aggregate_Value_%A_Index% * ( 1 / Count%Acu% )
		If ( Table_Aggregate_Value_%A_Index% < Table_Aggregate_Min_%Acu% )
			Table_Aggregate_Min_%Acu% := Table_Aggregate_Value_%A_Index%
		If ( Table_Aggregate_Value_%A_Index% > Table_Aggregate_Max_%Acu% )
			Table_Aggregate_Max_%Acu% := Table_Aggregate_Value_%A_Index%
		If ( Op = "med" ) ; only do the median thing if that's the operation
			Table_Aggregate_Med_%Acu% .= "`n" . Table_Aggregate_Value_%A_Index%
	}

	If ( GroupBy < 0 ) ; Don't bother with any groups, just return the value
	{
		If Op IN sum,min,max,avg,count
			vxe := Table_Aggregate_%Op%_%tagz%
		Else If ( Op = "span")
			vxe := Table_Aggregate_Max_%tagz% - Table_Aggregate_min_%tagz%
		Else If ( Op = "med" )
		{
			If ( Table_Aggregate_Count_%tagz% = 1 )
				vxe := Table_Aggregate_Max_%tagz%
			Else If ( Table_Aggregate_Count_%tagz% = 2 )
				vxe := Table_Aggregate_Max_%tagz% / 2 + Table_Aggregate_Min_%tagz% / 2
			Else
			{ ; the median is calculated by sorting the list, then if the list size is odd,
			; returning the middle item. But if the size is even, the average of the two middle
			; values is the median.
				Sort, Table_Aggregate_Med_%tagz%, N
				vxe := Table_Aggregate_Count_%tagz% - 1 & 1, Acu := ( Table_Aggregate_Count_%tagz% - 1 >> 1 )
				StringGetPos, pos, Table_Aggregate_Med_%tagz%, `n, L%Acu%
				StringTrimLeft, Table_Aggregate_Med_%tagz%, Table_Aggregate_Med_%tagz%, pos + 1
				StringGetPos, pos, Table_Aggregate_Med_%tagz%, `n
				StringMid, Acu, Table_Aggregate_Med_%tagz%, pos + 2, InStr( Table_Aggregate_Med_%tagz%, "`n", 0, pos + 2 ) - pos - 2
				StringLeft, Table_Aggregate_Med_%tagz%, Table_Aggregate_Med_%tagz%, pos
				vxe := ( vxe ? Table_Aggregate_Med_%tagz% / 2 + Acu / 2 : Table_Aggregate_Med_%tagz% )
			}
		}
		Else If ( Op = "dev" ) ; standard deviation requires another traversal of the data
		{
			Loop, %Table%
				If ( A_Index = 1 )
					vxe := ( Table_Aggregate_Avg_%tagz% - Table_Aggregate_Value_%A_Index% ) * ( Table_Aggregate_Avg_%tagz% - Table_Aggregate_Value_%A_Index% )
				Else vxe := vxe * ( 1 - 1 / A_Index ) + ( ( Table_Aggregate_Avg_%tagz% - Table_Aggregate_Value_%A_Index% )
						* ( Table_Aggregate_Avg_%tagz% - Table_Aggregate_Value_%A_Index% ) ) * ( 1 / A_Index )
			vxe := SQRT( vxe )
		}
		Return ( round = "" ? vxe : Round( vxe, Round ) ), ErrorLevel := oel
	}
	; Handle the 'GroupBy' part
	Groups := SubStr( Groups, 2, -1 )
	Loop, Parse, Groups, `n
	{
		If ( A_Index = 1 )
		{
			Column += 1, GroupBy += 1
			StringGetPos, pos, header, % "`t", L%GroupBy%
			StringTrimLeft, vxe, header, pos + 1
			StringLeft, Groups, vxe, InStr( vxe, "`t" )
			StringGetPos, pos, header, % "`t", L%Column%
			StringTrimLeft, vxe, header, pos + 1
			Groups .= SubStr( vxe, 1, InStr( vxe, "`t" ) - 1 )
		}
		Groups .= "`n" . A_LoopField . "`t"
		If Op IN sum,min,max,avg,count
			vxe := Table_Aggregate_%Op%_%A_Index%
		Else If ( Op = "span" )
			vxe := Table_Aggregate_Max_%A_Index% - Table_Aggregate_Min_%A_Index%
		Else If ( Op = "med" )
		{
			If ( Table_Aggregate_Count_%A_Index% = 1 )
				vxe := Table_Aggregate_Max_%A_Index%
			Else If ( Table_Aggregate_Count_%A_Index% = 2 )
				vxe := Table_Aggregate_Max_%A_Index% / 2 + Table_Aggregate_Min_%A_Index% / 2
			Else
			{
				Sort, Table_Aggregate_Med_%A_Index%, N
				vxe := Table_Aggregate_Count_%A_Index% - 1 & 1, Acu := ( Table_Aggregate_Count_%A_Index% - 1 >> 1 )
				StringGetPos, pos, Table_Aggregate_Med_%A_Index%, `n, L%Acu%
				StringTrimLeft, Table_Aggregate_Med_%A_Index%, Table_Aggregate_Med_%A_Index%, pos + 1
				StringGetPos, pos, Table_Aggregate_Med_%A_Index%, `n
				StringMid, Acu, Table_Aggregate_Med_%A_Index%, pos + 2
					, InStr( Table_Aggregate_Med_%A_Index%, "`n", 0, pos + 2 ) - pos - 2
				StringLeft, Table_Aggregate_Med_%A_Index%, Table_Aggregate_Med_%A_Index%, pos
				vxe := vxe ? Table_Aggregate_Med_%A_Index% / 2 + Acu / 2 : Table_Aggregate_Med_%A_Index%
			}
		}
		Else If ( Op = "dev" ) ; standard deviation requires another traversal of the data
		{
			Acu := Table_Aggregate_Avg_%A_Index%
			Loop, Parse, Table_Aggregate_Med_%A_Index%, `n
				If ( A_Index = 1 )
					vxe := ( Acu - A_LoopField ) * ( Acu - A_LoopField )
				Else vxe := vxe * ( 1 - 1 / A_Index ) + ( ( Acu - A_LoopField )
						* ( Acu - A_LoopField ) ) * ( 1 / A_Index )
			vxe := SQRT( vxe )
		}
		Groups .= Round = "" ? vxe : Round( vxe, Round )
	}
	Return Groups, ErrorLevel := oel
} ; Table_Aggregate( Table, Column="`t1", Op="sum", GroupBy="", Round="" ) -------------------------

Table_Append( TableA, TableB, Mode=0 ) { ; ---------------------------------------------------------
; Appends TableB to TableA, optionally adding columns to TableA. Mode determines whether columns
; are added and how rows are added. The following table details the supported values of Mode:
; Mode = 0  -> Rows from TableB are added to TableA, no columns are changed in TableA
; Mode = 1  -> Rows from TableB are added to TableA, columns in TableB are added to TableA's right
;              side IF TableA doesn't already have that column.
; Mode = 2  -> Columns in TableB are added to TableA's right side IF TableA doesn't already have
;              that column, no rows are added to TableA.
; NOTE: Rows appended are re-arranged so that the column data matches up with TableA's columns.
	Table_Append_Cell_0x1 := Table_Append_Cell_1 := ""
	oel := ErrorLevel, Mode |= 0
	TableA .= "`n"
	StringGetPos, pos, TableA, `n
	StringLeft, HeaderA, TableA, pos
	StringTrimRight, HeaderA, HeaderA, SubStr( HeaderA, 0 ) = "`r"
	StringTrimRight, TableA, TableA, 1

	TableB .= "`n"
	StringGetPos, pos, TableB, `n
	StringLeft, HeaderB, TableB, pos
	StringTrimRight, HeaderB, HeaderB, SubStr( HeaderB, 0 ) = "`r"
	StringTrimLeft, TableB, TableB, pos
	StringTrimRight, TableB, TableB, 1

	If ( HeaderA != HeaderB ) ; Headers are NOT identical... so check the columns
	{
		HeaderA := "`t" HeaderA "`t"

		; See if we need to add any columns to TableA
		If ( Mode = 1 || Mode = 2 )
			Loop, Parse, HeaderB, % "`t"
				IfNotInString, HeaderA, % "`t" A_LoopField "`t"
				{
					HeaderA .= "`n" A_LoopField "`t"
					TableA .= "`n"
					StringReplace, TableA, TableA, `n, % "`t`n", A
					StringReplace, TableA, TableA, % "`t`n", % "`t" A_LoopField "`n"
					StringTrimRight, TableA, TableA, 1
				}

		If ( Mode = 0 || Mode = 1 ) ; Add rows to TableA
		{
			; Generate a column arrangement map based on the headers
			StringReplace, HeaderA, HeaderA, `n,, A
			StringTrimRight, HeaderA, HeaderA, 1
			StringTrimLeft, HeaderA, HeaderA, 1
			StringTrimLeft, TableB, TableB, 1
			HeaderB := "`t" HeaderB "`t"
			Table_Append_Cell_0x1 := 0
			Loop, Parse, HeaderA, % "`t", `r
			{
				StringGetPos, pos, HeaderB, % "`t" A_LoopField "`t"
				If ( ErrorLevel := !ErrorLevel )
				{
					Table_Append_Cell_0x1 := 1
					StringReplace, HeaderB, HeaderB, % "`t" A_LoopField "`t", % "`t`t"
					StringLeft, Table_Append_Cell_1, HeaderB, pos + 1
					StringReplace, Table_Append_Cell_1, Table_Append_Cell_1, % "`t", % "`t", UseErrorLevel
				}
				If ( A_Index = 1 )
					HeaderA := ErrorLevel
				Else HeaderA .= "`n" ErrorLevel
			}
			If ( Table_Append_Cell_0x1 != 0 )
			{
				Table_Append_Cell_1 := ""
				Loop, Parse, TableB, `n, `r
				{
					Loop, Parse, A_LoopField, % "`t"
						Table_Append_Cell_%A_Index% := A_LoopField
					Loop, Parse, HeaderA, `n
					{
						TableA .= ( A_Index = 1 ? "`n" : "`t" )
						If ( A_LoopField )
						{
							TableA .= Table_Append_Cell_%A_LoopField%
							Table_Append_Cell_%A_LoopField% := ""
						}
					}
				}
			}
		}
	}
	Else If ( Mode = 0 || Mode = 1 ) ; identical headers, no need to futz around with columns.
			TableA .= TableB
	Return TableA, ErrorLevel := oel
} ; Table_Append( TableA, TableB, Mode=0 ) ---------------------------------------------------------

Table_Between( Table, Column, GreaterThan, LessThan="" ) { ; ---------------------------------------
; Returns Table, with any rows in which the 'Column' cell exceeds the indicated bounds removed. In
; other words, it returns the table rows that have a value between 'GreaterThan', and 'LessThan'.
; To invert the operation (return rows that are NOT between the two values), use a value for
; 'GreaterThan' that is greater than the value of 'LessThan'.
; To invert the equality portion of a check, preceed the intended value with a single tab character.
; To perform a simple inequality check, leave the other value blank (e.g: set 'GreaterThan' to ""
; for the function to remove rows with a value greater than the value in 'LessThan' ).
; Example: get rows where 4 <= Cost <= 5 :  Table_Between( Items, "Cost", 4, 5 )
; Example: get rows where 0 <= Cost :  Table_Between( Items, "Cost", "0" )
; Example: get rows where Cost <= 0 OR Cost > 100 :  Table_Between( Items, "Cost", 100, "`t0" )
; Example: get rows where Cost <= 0 :  Table_Between( Items, "Cost", "", "0" )
	StringTrimLeft, GreaterThan, GreaterThan, gt := 1 = InStr( GreaterThan, "`t" )
	StringTrimLeft, LessThan, LessThan, lt := 1 = InStr( LessThan, "`t" )
	StringLen, gz, GreaterThan
	StringLen, lz, LessThan
	oel := ErrorLevel, nix := gz && lz && LessThan < GreaterThan
	Loop, Parse, Table, `n, `r ; Parse the table by newlines, removing carriage returns.
		If ( A_Index = 1 ) ; first line is the header, so find the matchcol
		{
			StringReplace, Table, A_LoopField, % "`t", % "`t", UseErrorLevel
			ColCount := ErrorLevel
			If Asc( Column ) != 9 ; column by name
			{
				pos := "`t" A_LoopField
				StringLeft, Column, pos, InStr( pos "`t", "`t" Column "`t" )
				StringReplace, Column, Column, % "`t", % "`t", UseErrorLevel
				Column := ErrorLevel - 1
			}
			Else Column := Round( SubStr( Column, 2 ) ) - 1 ; column by index
			If ( Column < 0 || ColCount < Column )
				Return A_LoopField, ErrorLevel := oel ; column not found, so return empty table
		}
		Else ; lines other than the first contain row data
		{
			If !Column ; the first cell
				StringLeft, cell, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
			Else If ( Column = ColCount ) ; the last cell
				StringTrimLeft, cell, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
			Else ; cell is somewhere in the middle
			{
				StringGetPos, pos, A_LoopField, % "`t", L%Column%
				StringTrimLeft, cell, A_LoopField, pos + 1
				StringLeft, cell, cell, InStr( cell, "`t" ) - 1
			}
			; nested ternary operators FTW ! I'm pretty sure the ternaries here are faster than
			; the boolean-only equivalent due to fewer variable dereferences.
			If ( nix ? ( ( lz && ( lt ? ( cell <= LessThan ) : ( cell < LessThan ) ) )
				|| ( gz && ( gt ? ( GreaterThan <= cell ) : ( GreaterThan < cell ) ) ) )
			: ( ( !gz || ( gt ? ( GreaterThan < cell ) : ( GreaterThan <= cell ) ) )
				&& ( !lz || ( lt ? ( cell < LessThan ) : ( cell <= LessThan ) ) ) ) )

					Table .= "`n" A_LoopField
		}
	Return Table, ErrorLevel := oel ; return the OK rows
} ; Table_Between( Table, Column, GreaterThan, LessThan="" ) ---------------------------------------

Table_ColToList( Table, Column="`t1", Delimiters="`n" ) { ; ----------------------------------------
; Extracts a single column from the table and formats it with the specified delimiters.
; If 'Delimiters' begins with the word 'multi', then the character immediately following the 'i' is
; used to parse the delimiters list, and they are used to delimit the cells in order. For example,
; if 'Delimiters' contained "multi,.,.,|", and the table had 9 rows then the resulting list would
; look like this: "<data1>.<data2>.<data3>|<data4>.<data5>.<data6>|<data7>.<data8>.<data9>"

	oel := ErrorLevel
	Loop, Parse, Table, `n, `r
		If ( A_Index = 1 ) ; look in the header for the indicated column
		{
			StringReplace, Table, A_LoopField, % "`t", % "`t", UseErrorLevel
			ColCount := ErrorLevel, Table := ""
			If Asc( Column ) != 9 ; column by name
			{
				pos := "`t" A_LoopField
				StringLeft, Column, pos, InStr( pos "`t", "`t" Column "`t" )
				StringReplace, Column, Column, % "`t", % "`t", UseErrorLevel
				Column := ErrorLevel - 1
			}
			Else Column := Round( SubStr( Column, 2 ) ) - 1 ; column by index
			If ( Column < 0 || ColCount < Column )
				Return "", ErrorLevel := oel ; column not found, so return nothing
			If InStr( Delimiters, "multi" ) = 1 ; check for multi-delimiter
				Loop, Parse, Delimiters, % SubStr( Delimiters, 6, 1 )
					DelCount := A_Index - 1, d%DelCount% := A_LoopField
			Else DelCount := A_Index, d%DelCount% := Delimiters
			Delimiters := 0 ; initialize the delimiter cycle
		}
		Else
		{
			If !( Column )
				StringLeft, pos, A_LoopField, InStr( A_LoopField . "`t", "`t" ) - 1
			Else If ( Column = ColCount )
				StringTrimLeft, pos, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
			Else
			{
				StringGetPos, pos, A_LoopField, % "`t", L%Column%
				StringTrimLeft, pos, A_LoopField, pos + 1
				StringLeft, pos, pos, InStr( pos, "`t" ) - 1
			}
			If !( Delimiters ) ; this only happens for the first row
				Table := pos
			Else Table .= d%Delimiters% . pos
			Delimiters := 1 + Mod( Delimiters, DelCount ) ; for single-delimiter, it's always '1'
		}
	Return Table, ErrorLevel := oel
} ; Table_ColToList( Table, Column="`t1", Delimiters="`n" ) ----------------------------------------

Table_Decode( String ) { ; -------------------------------------------------------------------------
; Returns the string with the following entities decoded into their ascii characters: &#10`;  &#09`;
; NOTE: It is the user's responsibility to manage character escaping when using table-functions
	oel := ErrorLevel
	StringReplace, String, String, &#10`;, `n, a
	StringReplace, String, String, &#9`;, % "`t", a
	StringReplace, String, String, &#09`;, % "`t", a
	Return String, ErrorLevel := oel
} ; Table_Decode( String ) -------------------------------------------------------------------------

Table_Deintersect( TableA, TableB, MatchColA="", MatchColB="" ) { ; --------------------------------
; Returns TableA, with any row with a value that matches a value in TableB's match column removed.
; If MatchColB is blank, it is treated as the same column NAME as MatchColA. If MatchColA is blank,
; it is considered to be the NAME of TableB's first column (this makes it easier to deintersect a
; table using a simple list of values). If the value of 'TableB' is a positive integer, the returned
; table will contain only the rows with a MatchColA value that has fewer than that many instances
; in the same column above it. For example, Table_Deintersect( MyTable, "1", "`t1" ) will remove any
; row whose first member is a repeat of a previous row's first member. In other words, it removes
; duplicates. Similarly Table_Deintersect( MyTable, "2", "`t1" ) will allow up to 2 rows to have the
; same first member, but any subsequent rows with the same value in their first member are removed.
; When this mode is used, the default value for 'MatchColA' is TableA's first column.

	oel := ErrorLevel
	If TableB IS INTEGER
		MatchColB := "`n"
	Else
	{
		TableB .= "`n"
		StringGetPos, pos, TableB, `n
		StringLeft, HeaderB, TableB, pos
		StringTrimRight, HeaderB, HeaderB, pos = InStr( HeaderB, "`r", 0, 0 )
	}
	StringLen, len, TableA
	Loop, Parse, TableA, `n, `r
		If ( A_Index = 1 ) ; figure out what kind of deintersection we're doing here
		{
			StringReplace, ColCount, A_LoopField, % "`t", % "`t", UseErrorLevel
			ColCount := ErrorLevel
			If ( MatchColA = "" )
				If ( MatchColB != "`n" ) ; MatchColA defaults to TableB's 1st col
					StringLeft, MatchColA, HeaderB, InStr( HeaderB "`t", "`t" ) - 1
				Else StringLeft, MatchColA, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1

			If Asc( MatchColA ) != 9 ; column by name
			{
				vxe := "`t" A_LoopField
				StringLeft, MatchColA, vxe, InStr( vxe "`t", "`t" MatchColA "`t" )
				StringReplace, MatchColA, MatchColA, % "`t", % "`t", UseErrorLevel
				MatchColA := ErrorLevel - 1
			}
			Else MatchColA := Round( SubStr( MatchColA, 2 ) ) - 1 ; column by index

			If ( MatchColA < 0 || ColCount < MatchColA )
				Return TableA, ErrorLevel := oel ; column not found, so return the table

			If ( MatchColB = "`n" )
				MatchColB := 0 - TableB, VarSetCapacity( TableB, len / ColCount << !!A_IsUnicode, 0 )
			Else
			{
				If ( MatchColB = "" ) ; if MatchColB is blank, use MatchColA's name as MatchColB
				{
					If !( MatchColA )
						StringLeft, MatchColB, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
					Else If ( MatchColA = ColCount )
						StringTrimLeft, MatchColB, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
					Else
					{
						StringGetPos, pos, A_LoopField, % "`t", L%MatchColA%
						StringTrimLeft, MatchColB, A_LoopField, pos + 1
						StringLeft, MatchColB, MatchColB, InStr( MatchColB, "`t" ) - 1
					}
				}

				If Asc( MatchColB ) != 9 ; column by name
				{
					vxe := "`t" HeaderB
					StringLeft, MatchColB, vxe, InStr( vxe "`t", "`t" MatchColB "`t" )
					StringReplace, MatchColB, MatchColB, % "`t", % "`t", UseErrorLevel
					MatchColB := ErrorLevel - 1
				}
				Else MatchColB := Round( SubStr( MatchColB, 2 ) ) - 1 ; column by index

				StringReplace, HeaderB, HeaderB, % "`t", % "`t", UseErrorLevel
				If ( MatchColB < 0 || ErrorLevel < MatchColB )
					Return TableA, ErrorLevel := oel ; column not found, so return the table

				Loop, Parse, TableB, `n, `r ; reduce TableB to just its match col (in list form)
					If ( A_Index = 1 )
					{
						StringReplace, TableB, A_LoopField, % "`t", % "`t", UseErrorLevel
						ColCountB := ErrorLevel
						TableB := "`n"
					}
					Else
					{
						If !( MatchColB )
							StringLeft, vxe, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
						Else If ( MatchColB = ColCountB )
							StringTrimLeft, vxe, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
						Else
						{
							StringGetPos, pos, A_LoopField, % "`t", L%MatchColB%
							StringTrimLeft, vxe, A_LoopField, pos + 1
							StringLeft, vxe, vxe, InStr( vxe, "`t" ) - 1
						}
						TableB .= vxe "`n"
					}
				StringTrimRight, TableB, TableB, 1
			}
			; for a multiples deintersection, the matchlist is generated as the table is parsed.
			TableA := A_LoopField ; column found OK
		}
		Else If ( A_LoopField = "" )
			Continue
		Else If ( MatchColB < 0 ) ; multiples deintersection
		{
			If !( MatchColA )
				StringLeft, vxe, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
			Else If ( MatchColA = ColCount )
				StringTrimLeft, vxe, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
			Else
			{
				StringGetPos, pos, A_LoopField, % "`t", L%MatchColA%
				StringTrimLeft, vxe, A_LoopField, pos + 1
				StringLeft, vxe, vxe, InStr( vxe, "`t" ) - 1
			}
			StringReplace, TableB, TableB, `n%vxe%`n, `n%vxe%`n, UseErrorLevel
			If ( ErrorLevel + MatchColB < 0 ) ; previous count minus the allowed count
			{
				TableA .= "`n" A_LoopField
				TableB .= "`n" vxe "`n"
			}
		}
		Else ; normal deintersection
		{
			If !( MatchColA )
				StringLeft, pos, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
			Else If ( MatchColA = ColCount )
				StringTrimLeft, pos, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
			Else
			{
				StringGetPos, pos, A_LoopField, % "`t", L%MatchColA%
				StringTrimLeft, pos, A_LoopField, pos + 1
				StringLeft, pos, pos, InStr( pos, "`t" ) - 1
			}
			IfNotInString, TableB, `n%pos%`n
				TableA .= "`n" A_LoopField
		}
	Return TableA, ErrorLevel := oel
} ; Table_Deintersect( TableA, TableB, MatchColA="", MatchColB="" ) --------------------------------

Table_Encode( String ) { ; -------------------------------------------------------------------------
; Return the string with all newlines and tabs converted into html-entities &#1&#48;;  &#&#48;9;
; This is the only way to validly insert text which may contain these characters into a 9/10 table.
; NOTE: It is the user's responsibility to manage character escaping when using table-functions
	oel := ErrorLevel
	StringReplace, String, String, `n, &#10`;, A
	StringReplace, String, String, % "`t", &#09`;, A
	Return String, ErrorLevel := oel
} ; Table_Encode( String ) -------------------------------------------------------------------------

Table_FormatTime( Table, Format="", Columns="`t" ) { ; ---------------------------------------------
; Returns a table where any instance of a 14-digit date string in one of the indicated columns is
; converted to 'Format' using FormatTime. If 'Columns' is a single tab character, this function will
; autodetect 14-digit cell values in the table and convert any that it finds.
; NOTE: multiple columns can be converted by separating the column identifiers with newlines.
; NOTE: This function is intended to prep a table for insertion into a listview with Table_ToListview

	oel := ErrorLevel
	Loop, Parse, Table, `n, `r ; parse the table
		If ( A_Index = 1 ) ; handle the header
		{
			StringReplace, vxe, A_LoopField, % "`t", % "`t", UseErrorLevel
			ColCount := ErrorLevel, vxe := "`t" vxe "`t"
			If !( auto := Columns = "`t" )
				Loop, Parse, Columns, `n, `r
				{
					If ( A_Index = 1 )
						Columns := "`t"
					If Asc( A_LoopField ) != 9
					{
						StringLeft, pos, vxe, InStr( vxe, "`t" A_LoopField "`t" )
						StringReplace, pos, pos, % "`t", % "`t", UseErrorLevel
						Columns .= ErrorLevel "`t"
					}
					Else If ( 0 < ( pos := Round( SubStr( A_LoopField, 2 ) ) ) )
							&& ( pos <= ColCount )
						Columns .= pos "`t"
				}
			If !auto && Columns = "`t"
				Return Table, ErrorLevel := oel ; none of the specified columns were found...
			Table := A_LoopField
		}
		Else Loop, Parse, A_LoopField, % "`t"
			{
				vxe := A_LoopField
				If ( auto )
				{
					If vxe IS TIME
						FormatTime, vxe, %vxe%, %Format%
				}
				Else If InStr( Columns, "`t" A_Index "`t" ) && ( vxe != "" )
					FormatTime, vxe, %vxe%, %Format%
				Table .= ( A_Index = 1 ? "`n" : "`t" ) vxe
			}
	Return Table, ErrorLevel := oel
} ; Table_FormatTime( Table, Format="", Columns="`t" ) ---------------------------------------------

Table_FromCSV( CSV_Table ) { ; ---------------------------------------------------------------------
; Converts a CSV table into a 9/10 table. Literal tabs and newlines are encoded as &#09`; and &#10`;
	oel := ErrorLevel
	StringReplace, CSV_Table, CSV_Table, % "`t", &#09`;, A
	Loop, Parse, CSV_Table, " ; look for literal newlines that need to be escaped
		If !( A_Index & 1 ) ; inside quotes
		{
			StringReplace, vxe, A_LoopField, `n, &#10`;, A
			CSV_Table .= """" vxe
		}
		Else If ( A_Index = 1 )
			CSV_Table := A_LoopField
		Else CSV_Table .= """" A_LoopField

	Loop, Parse, CSV_Table, `n, `r ; parse by non-literal newlines
		If ( A_Index = 1 )
			Loop, Parse, A_LoopField, CSV
				CSV_Table := ( A_Index = 1 ? "" : CSV_Table "`t" ) A_LoopField
		Else If ( A_LoopField != "" )
			Loop, Parse, A_LoopField, CSV
				CSV_Table .= ( A_Index = 1 ? "`n" : "`t" ) A_LoopField
	Return CSV_Table, ErrorLevel := oel
} ; Table_FromCSV( CSV_Table ) ---------------------------------------------------------------------

Table_FromHTML( HTML, StartChar=1 ) { ; ------------------------------------------------------------
; Converts an HTML table (inside <Table></Table> tags) into a 9/10 table. Nested tables remain
; unconverted. Literal linebreaks (that means linebreaks in the HTML code) are removed and any <br>
; tags are left unchanged.
; NOTE: 'StartChar' can be used to determine which table to convert if the HTML contains more than one
; NOTE: Literal tabs are converted into '&#09`;' in the returned table.
; NOTE: Cell spanning is handled by replicating the cell's contents into each of the spanned cells.
; NOTE: The table's first row becomes the header of the retuned table. To supply a different header,
; simply append this function's return value to it, separated by a newline character.
; NOTE: <thead> and <tfoot> sections are NOT respected by this function.

	oel := ErrorLevel
	StringGetPos, pos, HTML, <table,, StartChar - 1
	If ( ErrorLevel )
		Return ""
	StringTrimLeft, HTML, HTML, pos
	StringReplace, HTML, HTML, `r,, A
	nest := row := col := i := j := w := 0
	spans := "`t"
	Loop, Parse, HTML, <
		If ( A_Index != 1 )
		{
			Loop, Parse, A_LoopField, >, % " `t`r`n"
				If ( A_Index = 1 )
					StringReplace, tag, A_LoopField, `n,, A
				Else StringReplace, tex, A_LoopField, `n,, A

			
			If !( nest += ( InStr( tag " ", "table " ) = 1 ) - ( InStr( tag " ", "/table " ) = 1 ) )
				Break ; we've found the close-tag for the top table
			Else If ( nest != 1 ) ; we're still inside a nested table
				HTML .= "<" tag ">" tex
			Else If InStr( tag " ", "tr " ) = 1 ; it's a new row
				row += ( col := 1 )
			Else If InStr( tag " ", "/tr " ) = 1
				w := w < ( Table_FromHTML_Row_%row% := col ) ? col : w
			Else If InStr( tag " ", "td " ) = 1 || InStr( tag " ", "th " ) = 1 ; it's a new cell
			{
				RegexMatch( tag " colspan=1", "\hcolspan=""?\K\d+", colspan )
				RegexMatch( tag " rowspan=1", "\hrowspan=""?\K\d+", rowspan )
				If !( colspan )
					colspan := w - col
				HTML := tex
			}
			Else If ( InStr( tag " ", "/td " ) = 1 || InStr( tag " ", "/th " ) = 1 ) && ( tag != lasttag ) ; end of cell
			{
				Loop, % rowspan
					Loop, % colspan + !( B_Index := A_Index )
					{
						Loop
							IfInString, spans, % "`t" ( row - 1 + B_Index ) " " ( col - 1 + A_Index ) "`t"
								col += 1
							Else Break
						j := col - 1 + A_Index
						If ( row < ( i := row - 1 + B_Index ) )
							spans .= i " " j "`t"
						StringReplace, Table_FromHTML_Cell_%i%_%j%, HTML, % "`t", % "&#09;", A
					}
				col += colspan
			}
			Else HTML .= "<" tag ">" tex
			lasttag := tag
		}
	; Now we have all of the html table cells in a pseudo array, so we'll assemble them into a table
	Loop, %row%
		Loop % w + !( row := A_Index )
			If ( row = 1 ) && ( A_Index = 1 )
				HTML := Table_FromHTML_Cell_%row%_%A_Index%
			Else If ( A_Index > Table_FromHTML_Row_%row% )
				HTML .= "`t"
			Else HTML .= ( A_Index = 1 ? "`n" : "`t" ) Table_FromHTML_Cell_%row%_%A_Index%

	; Lastly, decode the 5 main HTML entities
	StringReplace, HTML, HTML, &quot;, ", A
	StringReplace, HTML, HTML, &apos;, ', A
	StringReplace, HTML, HTML, &lt;, <, A
	StringReplace, HTML, HTML, &gt;, >, A
	StringReplace, HTML, HTML, &amp;, &, A

	Return HTML, ErrorLevel := oel
} ; Table_FromHTML( HTML, StartChar=1 ) ------------------------------------------------------------

Table_FromINI( INI_File_Text, cd1="/" ) { ; --------------------------------------------------------
; Given text in ini format, this function creates a table such that the rightmost column holds the
; key values and the other column(s) hold the section name and keyname (separated by 'cd1'). By
; setting 'cd1' to a single tab (`t), the output table will have 3 columns (Section,Key,Value). By
; setting 'cd1' to a forward slash (default), the output table's first column will hold both the
; section name and keyname, with a slash between them (allowing simpler lookup operations).
	oel := ErrorLevel, block_comment := 0, section := "Format Error: No Section Name"
	Loop, Parse, INI_File_Text, `n
	{
		If ( A_Index = 1 )
			INI_File_Text := "Section" cd1 "Key`tValue"
		line := A_LoopField
		StringLeft, line, line, InStr( line " `;", " `;" ) - 1
		StringLeft, line, line, InStr( line "`t;", "`t;" ) - 1
		If !( block_comment := ( block_comment | ( line = "/*" ) ) & ( line != "*/" ) )
			Loop, Parse, line, `n, % "`r `t"
				If SubStr( A_LoopField, 1, 1 ) = "[" && SubStr( A_LoopField, 0 ) = "]"
					StringMid, section, A_LoopField, 2, StrLen( A_LoopField ) - 2
				Else IfInString, A_LoopField, =
				{
					StringReplace, line, A_LoopField, =, `n ; replace the first '=' sign
					Loop, Parse, line, `n, % "`r `t"
						If ( A_Index = 1 )
							INI_File_Text .= "`n" section cd1 A_LoopField "`t"
						Else
						{
							StringReplace, line, A_LoopField, % "`t", &#09`;, A
							StringReplace, line, line, ```;, `;, A
							INI_File_Text .= line
						}
				}
	}
	Return INI_File_Text, ErrorLevel := oel
} ; Table_FromINI( INI_File_Text, cd1="/" ) -------------------------------------------------------

Table_FromListview( scf="" ) { ; -------------------------------------------------------------------
; Returns a 9/10 table representing the default gui's current listview. To obtain a table from a
; different listview, use ControlGet with the 'List' option.
; If 'scf' is blank, the entire listview is considered. If 'scf' contains one or more of the letters
; 'sScCfF', the output is modified: the letters stand for 'select', 'check' and 'focus', and
; the capital letters add columns with the corresponding name to the right side of the table. So, if
; 'scf' contained 'sF', the returned table would contain only the listview rows that were selected,
; and a column named 'focused' would be added to the right side of the table and any row that was
; both selected AND focused would have the text 'focused' appear in that column.
; NOTE: multiple lowercase options are joined using 'AND' logic.

	Static sv_s := "`tSelect", sv_c := "`tCheck", sv_f := "`tFocus", svl := "sScCfF" ; these are CONST
	oel := ErrorLevel

	Loop, Parse, svl ; look for options in the parameter
		frow := Chr( 96 + A_Index ), _%frow% := !InStr( scf, A_LoopField, 1 )

	ColCount := LV_GetCount( "Column" )
	VarSetCapacity( Table, 16 * ColCount * LV_GetCount() << !!A_IsUnicode, 0 ) ; guesstimate size

	Loop, % ColCount ; build the table header
		If LV_GetText( scf, 0, A_Index )
			Table .= scf "`t"

	StringTrimRight, Table, Table, 1
	Table .= ( _b ? "" : sv_s ) ( _d ? "" : sv_c ) ( _f ? "" : sv_f )
	frow := LV_GetNext( 0, "F" ) ; look up the focused row's index

	Loop, % LV_GetCount() ; loop through each row in the listview looking for eligible rows 
		If ( _e || A_Index = frow )
		&& ( _c || A_Index = LV_GetNext( A_Index - 1, "C" ) )
		&& ( _a || A_Index = LV_GetNext( A_Index - 1 ) )
		{
			row := A_Index
			Loop, %ColCount%
				If LV_GetText( scf, row, A_Index )
				{
					StringReplace, scf, scf, `n, &#10;, A
					StringReplace, scf, scf, % "`t", &#09;, A
					Table .= ( A_Index = 1 ? "`n" : "`t" ) scf
				}
			Table .= ( _b ? "" : ( row = LV_GetNext( row - 1 ) ? sv_s : "`t" ) )
				. ( _d ? "" : ( row = LV_GetNext( row - 1, "C" ) ? sv_c : "`t" ) )
				. ( _f ? "" : ( row = frow ? sv_f : "`t" ) )
		}
	Return Table, ErrorLevel := oel
} ; Table_FromListview( scf="" ) -------------------------------------------------------------------

Table_FromLvHWND( hwnd, What_Rows="all" ) { ; -----------------------------------------------------------------
; Extracts text from a listview (identified by its HWND) and returns it in table format. 'What_Rows' may be
; "header", "all", blank, "selected", "focused", "checked", or a list of row indices.
; Blank and "All" are synonymous and the result will be all of the listview's text (default option).
; "Seleced", "Focused", and "Checked" yield a table with those rows (abbreviations are OK).
; "Header" yields no row text. Row indices less than 1 are considered an offset from the last listview row.

	Static u, w_a, ptr, psz, pid, lisz, DW := "UInt", bfsz = 8100, WM_ENABLE = 9, WM_SETREDRAW = 11
, PROCESS_VM_OPERATION 	= 8
, PROCESS_VM_READ 		= 16
, PROCESS_VM_WRITE 		= 32
, PROCESS_QUERY_INFORMATION = 1024

, LVM_GETITEMCOUNT		= 0x1004
, LVM_GETNEXTITEM		= 0x100C
, LVM_GETITEMSTATE		= 0x102C
, LVM_GETITEMTEXT
, LVM_GETHEADER 		= 0x101F
, LVM_GETITEM			= 0x104B

, HDM_GETITEMCOUNT 		= 0x1200
, HDM_GETITEM

, PAGE_READWRITE 		= 4
, MEM_COMMIT 			= 0x1000
, MEM_RESERVE 			= 0x2000
, MEM_RELEASE 			= 0x8000

	oel := ErrorLevel

; Initialize static vars. send % fhex( 0x1000 + 44 )
	If !psz
	{
		u := A_IsUnicode = 1
		w_a := u ? "W" : "A"
		ptr := A_PtrSize = "" ? DW : "Ptr"
		psz := A_PtrSize = "" ? 4 : A_PtrSize
		Process, Exist
		pid := ErrorLevel
		lisz := psz * 3 + 12 * 4
		HDM_GETITEM := u ? 0x120B : 0x1203
		LVM_GETITEMTEXT := u ? 0x1073 : 0x102D
	}
	VarSetCapacity( bufr, bfsz + 1 << u, 0 )

; Check the class name of the control. If it's not a listview, fail.
; Get the handle to listview's header and get the PID of its owner process
	If !DllCall( "GetClassName" w_a, Ptr, hwnd, "Str", bufr, DW, bfsz ) || ( bufr != "SysListView32" )
	|| !( hdrh := DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETHEADER, Ptr, 0, Ptr, 0 ) )
	|| !DllCall( "GetWindowThreadProcessId", Ptr, hwnd, DW "*", pos := 0 )
		Return "", ErrorLevel := oel ; Fail: it doesn't have a header or we can't get its owner PID

; Do some prep for both modes and determine which rows to get.
	rowc := pmem := 0
	If ( lvic := DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETITEMCOUNT, Ptr, 0, Ptr, 0 ) )
	{
		VarSetCapacity( rose, lvic << 2, 0 )
		StringLower, What_Rows, What_Rows
		If ( hdrc := InStr( "fs", SubStr( What_Rows "x", 1, 1 ) ) )
		{
			Loop
				If ( pmem := 1 + DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETNEXTITEM, Ptr, pmem - 1, Ptr, hdrc, "Int" ) )
					NumPut( pmem - 1, rose, 4 * ( rowc++ ), DW )
				Else Break
		}
		Else If InStr( What_Rows, "c" ) = 1
		{
			Loop % lvic
				If DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETITEMSTATE, Ptr, A_Index - 1, Ptr, 0xF000, DW ) != 0x1000
					NumPut( A_Index - 1, rose, 4 * ( rowc++ ), DW )
		}
		Else If InStr( What_Rows, "a" ) = 1
		{
			Loop % rowc := lvic
				NumPut( A_Index - 1, rose, A_Index - 1 << 2, DW )
		}
		Else If InStr( What_Rows, "h" ) != 1
		{
			Loop, Parse, What_Rows, % "`t`n`r !""#$%&'()*+,/:;<=>?@[\]^_`{|}~"
				If A_LoopField IS NUMBER
					If ( 0 < ( pmem := A_LoopField | 0 ) || 0 < ( pmem += lvic ) ) && ( pmem <= lvic )
						NumPut( pmem - 1, rose, 4 * ( rowc++ ), DW )
		}
	}

	hdrc := DllCall( "SendMessage", Ptr, hdrh, DW, HDM_GETITEMCOUNT, Ptr, 0, Ptr, 0 )
	VarSetCapacity( hdtx, hdrc << 4 + u, 0 ) ; guesstimate 15 chars per column
	VarSetCapacity( bdtx, hdrc * rowc << 5 + u, 0 ) ; guesstimate 31 chars per listview cell

; If the listview is owned by this very script, use our own memory to grab listview stuff
	If ( pos = pid )
	{
; Prep the HDITEM struct ( Mask = HDI_TEXT, pszText = &bufr, cchTextMax = bfsz )
		VarSetCapacity( mitm, lisz, 0 )
		NumPut( 2, mitm, 0, DW )
		NumPut( &bufr, mitm, 8, Ptr )
		NumPut( bfsz, mitm, 8 + 2 * psz, DW )

; Get the header
		Loop % hdrc
			If DllCall( "SendMessage", Ptr, hdrh, DW, HDM_GETITEM, Ptr, A_Index - 1, Ptr, &mitm )
				VarSetCapacity( bufr, -1 ), hdtx .= bufr "`t"

; Now grab the listview text for each row saved in 'rose'
		NumPut( &bufr, mitm, 16 + psz, Ptr )
		NumPut( bfsz, mitm, 16 + 2 * psz, DW )
		Loop % rowc
		{
			NumPut( pos := NumGet( rose, A_Index - 1 << 2, DW ), mitm, 4, DW )
			Loop % hdrc
			{
				NumPut( A_Index - 1, mitm, 8, DW )
				DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETITEMTEXT, Ptr, pos, Ptr, &mitm )
				VarSetCapacity( bufr, -1 ), bdtx .= ( A_Index = 1 ? "`n" : "`t" ) bufr
			}
		}
	}
; The princess is in another castle.... the listview is owned by another process, so use shared memory.
	Else
	{
		lvic := PROCESS_QUERY_INFORMATION | PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE
; Try to open the process to which the listview belongs so we can allocate shared memory for getting the header text.
		If !proc := DllCall( "OpenProcess", DW, lvic, DW, 0, DW, pos )
			Return "", ErrorLevel := oel ; Fail

; Try to allocate shared memory. The local buffer size (8100) is meant to keep the remote buffer's size below 8K
		If !pmem := DllCall( "VirtualAllocEx", ptr, proc, ptr, 0, DW, ( bfsz + 1 << u ) + lisz, DW, MEM_RESERVE | MEM_COMMIT, DW, PAGE_READWRITE )
			Return "", DllCall( "CloseHandle", ptr, proc ), ErrorLevel := oel ; Fail

; Check whether the target process is 64 bit (or if the computer is even capable of telling the difference)
		If ( lvic := DllCall( "GetProcAddress", Ptr, DllCall( "GetModuleHandle", Str, "Kernel32" ), Str, "IsWow64Process" ) )
			DllCall( "IsWow64Process", Ptr, proc, DW "*", lvic )
		lvic := lvic ? 8 : 4
		bdtx := lvic = 4 ? DW : "Int64"

; Initialize the HDITEM structure in the remote memory space.
		DllCall( "WriteProcessMemory", ptr, proc, ptr, pmem, DW "*", 2, DW, 4, ptr, 0 )
		DllCall( "WriteProcessMemory", ptr, proc, ptr, pmem + 8 + lvic * 2, DW "*", bfsz, DW, 4, ptr, 0 )

; Grab the header text.
		Loop % hdrc
		{
			DllCall( "WriteProcessMemory", ptr, proc, ptr, pmem + 8, bdtx "*", pmem + lisz, DW, lvic, ptr, 0 )
			DllCall( "SendMessage", Ptr, hdrh, DW, HDM_GETITEM, Ptr, A_Index - 1, Ptr, pmem )
			DllCall( "ReadProcessMemory", ptr, proc, ptr, pmem + 8, ptr "*", pos, DW, lvic, ptr, 0 )
			DllCall( "ReadProcessMemory", ptr, proc, ptr, pos, ptr, &bufr, DW, bfsz << u, ptr, 0 )
			VarSetCapacity( bufr, -1 ), hdtx .= bufr "`t"
		}

; Grab the listview's row's text
		DllCall( "WriteProcessMemory", ptr, proc, ptr, pmem + 16 + 2 * lvic, DW "*", bfsz, DW, 4, Ptr, 0 )
		DllCall( "WriteProcessMemory", ptr, proc, ptr, pmem + 16 + lvic, bdtx "*", pmem + lisz, DW, lvic, Ptr, 0 )
		Loop % rowc
		{
			pos := NumGet( rose, A_Index - 1 << 2, DW )
			DllCall( "WriteProcessMemory", ptr, proc, ptr, pmem + 4, DW "*", pos, DW, 4, Ptr, 0 )
			Loop % hdrc
			{
				DllCall( "WriteProcessMemory", ptr, proc, ptr, pmem + 8, DW "*", A_Index - 1, DW, 4, Ptr, 0 )
				DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETITEMTEXT, Ptr, pos, Ptr, pmem )
				DllCall( "ReadProcessMemory", ptr, proc, ptr, pmem + lisz, ptr, &bufr, DW, bfsz << u, ptr, 0 )
				VarSetCapacity( bufr, -1 ), bdtx .= ( A_Index = 1 ? "`n" : "`t" ) bufr
			}
		}

; Clean up the shared memory and close the process handle.
		DllCall( "VirtualFreeEx", ptr, proc, ptr, pmem, DW, 0, DW, MEM_RELEASE )
		DllCall( "CloseHandle", ptr, proc )
	}
	Return SubStr( hdtx, 1, -1 ) . bdtx, ErrorLevel := oel
} ; Table_FromLvHwnd( hwnd, option="" ) -----------------------------------------------------------------------

Table_FromXMLNode( XML, RowNode ) { ; --------------------------------------------------------------
; Lossy conversion of an XML stream to a 9/10 table. 'RowNode' should be the name of the container
; node for the desired row-equivalent data (each child node of 'RowNode' contains one table cell of
; data). Typically, 'RowNode' is the name of a recurring node in the XML stream, so that each
; occurrence is converted into one table row. The output table columns are named for the child nodes
; of 'RowNode'. Columns are added to the output table in the order that they are encountered, so if
; the second 'RowNode' has subnodes that aren't in the first, they will appear as table columns to
; the right of the previous columns, not mixed in with the other columns. If this is unsatisfactory,
; you can rearrange the columns using Table_Append or sort them with combined calls to Table_Invert
; and Table_Sort.
; NOTE: this function does NOT respect the absolute nest level of each 'RowNode', nor does it allow
; a node path to be specified as 'RowNode'. Hopefully, nobody using this function is dealing with
; XML that uses the same node name at several levels of nesting.

	oel := ErrorLevel, i := pos := 0
	StringTrimLeft, RowNode, RowNode, Asc( RowNode ) = 47
	; Remove comments without regex... my tests showed that if there are fewer than 3 comments in
	; the XML, the non-regex loop is faster than the regex. Since this function is not intended to
	; be used on heavily-commented XML, I decided not use regex. Also, the rest of this lib has no
	; regex. Regex fanboiz can use this instead: XML := RegexReplace( XML, "s)<!--(?:.*?-->|.*)" )
	Loop
	{
		StringGetPos, pos, XML, <!--,, pos
		If ( ErrorLevel )
			Break
		StringGetPos, SubNode, XML, -->,, pos
		If ( ErrorLevel )
		{
			StringLen, SubNode, XML
			SubNode -= 3
		}
		StringTrimLeft, SubNode, XML, SubNode + 3
		StringLeft, XML, XML, pos
		XML .= SubNode
	}
	; Parse the XML by lessthan signs, then parse each substring by the (one) greaterthan sign
	Loop, Parse, XML, <
		If ( A_Index = 1 )
			XML := Header := "`t"
		Else Loop, Parse, A_LoopField, >, % "`t`r`n "
			If ( A_Index = 1 )
				StringLeft, Node, A_LoopField, InStr( A_LoopField " ", " " ) - 1
			Else If !( i )
				i := ( Node = RowNode )
			Else If ( i = 1 )
					If ( Node = "/" RowNode )
					{
						; Append the collected data to the table
						i := 0
						StringReplace, Header, Header, % "`t", % "`t", UseErrorLevel
						Loop, % ErrorLevel - 1
						{
							StringReplace, Table_FromXML_Cell_%A_Index%, Table_FromXML_Cell_%A_Index%, % "`n", &#10`;, A
							StringReplace, Table_FromXML_Cell_%A_Index%, Table_FromXML_Cell_%A_Index%, % "`n", &#09`;, A
							XML .= ( A_Index = 1 ? "`n" : "`t" ) Table_FromXML_Cell_%A_Index%
							Table_FromXML_Cell_%A_Index% := ""
						}
					}
					Else ; it's a child of the rownode
					{
						StringLeft, SubNode, Node, 1
						If SubStr( Node, 0 ) = "/" || SubNode = "!" || SubNode = "?"
							Continue
						SubNode := Node
						StringGetPos, pos, Header, % "`t" Node "`t"
						If ( ErrorLevel )
						{
							Header .= Node "`t"
							StringTrimRight, pos, Header, 1
							StringReplace, XML, XML, % "`n", % "`t`n", A
							XML .= "`t"
						}
						Else StringLeft, pos, Header, pos + 1
						StringReplace, pos, pos, % "`t", % "`t", UseErrorLevel
						pos := ErrorLevel
						Table_FromXML_Cell_%pos% := A_LoopField
						i := 2
					}
			Else If ( Node = "/" SubNode ) ; it's the ending tag of a child of the rownode
				i := 1
			Else Table_FromXML_Cell_%pos% .= "<" Node ">" A_LoopField ; append the XML

	StringGetPos, pos, XML, % "`n"
	StringTrimLeft, XML, XML, pos
	StringTrimLeft, Header, Header, 1
	StringTrimRight, Header, Header, 1
	StringReplace, XML, XML, &lt`;, <, A
	StringReplace, XML, XML, &gt`;, >, A
	StringReplace, XML, XML, &apos`;, ', A
	StringReplace, XML, XML, &quot`;, ", A
	StringReplace, XML, XML, &amp`;, &, A
	Return Header XML, ErrorLevel := oel
} ; Table_FromXMLNode( XML, RowNode ) --------------------------------------------------------------

Table_GetCell( Table, RowID, Columns="`t1", byref a="", byref b="" ; -------------------------------
, byref c="", byref d="", byref e="", byref f="", byref g="", byref h="", byref i="", byref j=""
, byref k="", byref l="", byref m="", byref n="", byref o="", byref p="", byref q="", byref r=""
, byref s="", byref t="", byref u="", byref v="", byref w="", byref x="", byref y="", byref z="" ) {
; Returns the contents of a single cell in a table. However, if 'Columns' contains one or more
; newline characters, the return value is the number of cells that have their values put into output
; variables. For example, if a script were to call the following function:
; Table_GetCell( Items, "Cherry", "Quantity`nPrice`nShipping`nZip Code", qty, price, ship, zip )
; the returned value would be '3' (the number of columns in 'Columns' that are actually IN the
; 'Items' table) and the variables 'qty', 'price' and 'ship' would be filled with the contents of
; the cells in the matching columns for the table row with 'Cherry Bomb' in its first column.
; If RowID contains a newline character, it is interpereted as separating the desired ID column from
; the ID value, so 'Sku`n123456789' as the RowID would indicate the table row with '123456789' in
; the 'Sku' column, whether or not that column is the leftmost one in the table.

	oel := ErrorLevel, Table .= "`n"
	StringReplace, Table, Table, `r`n, `n, A
	StringGetPos, hdpos, Table, `n
	StringLeft, header, Table, hdpos

	StringReplace, header, header, % "`t", % "`t", UseErrorLevel
	ColCount := ErrorLevel
	StringReplace, Table, Table, `n, `n, UseErrorLevel
	RowCount := ErrorLevel - 1
	header := "`t" header "`t"

	If ( Columns = "`tAll" )
	{
		StringReplace, Columns, header, % "`t", `n, A
		StringTrimLeft, Columns, Columns, 1
	}

	StringTrimLeft, RowID, RowID, InStr( RowID, "`n`t" )
	StringGetPos, pos, RowID, `n
	If ( ErrorLevel ) ; it's a simple row identifier
		If Asc( RowID ) = 9 ; row by index
		{
			RowID := Round( SubStr( RowID, 2 ) )
			If ( RowID <= 0 || RowCount < RowID )
				Return "", ErrorLevel := oel ; Error: row index doesn't exist in this table.
			StringGetPos, pos, Table, `n, L%RowID%
		}
		Else ; row by first column text
		{
			StringGetPos, pos, Table, % "`n" RowID ( Colcount ? "`t" : "`n" )
			If ( ErrorLevel )
				Return "", ErrorLevel := oel ; Error: row not found
		}
	Else ; it's a complex row identifier
	{
		StringLen, len, Table
		StringLeft, RowCol, RowID, pos
		StringTrimLeft, RowID, RowID, pos + 1
		If Asc( RowCol ) != 9 ; column by name
		{
			StringLeft, RowCol, header, InStr( header, "`t" RowCol "`t" )
			StringReplace, RowCol, RowCol, % "`t", % "`t", UseErrorLevel
			RowCol := ErrorLevel - 1
		}
		Else RowCol := Round( SubStr( RowCol, 2 ) ) - 1 ; column by index
		If ( RowCol < 0 ) || ( ColCount < RowCol )
			Return "", ErrorLevel := oel ; Error: invalid rowid column

		pos := hdpos
		If !( RowCol ) ; look for a rowID in the first column
			StringGetPos, pos, Table, % "`n" RowID ( ColCount ? "`t" : "`n" ),, pos
		Else If ( RowCol = ColCount ) ; look for a rowID in the last column
		{
			StringGetPos, pos, Table, % "`t" RowID "`n",, pos
			StringGetPos, pos, Table, `n, R, len - pos - 1
		}
		Else Loop ; we'll have to look for the matching value and then check its column
			{
				StringGetPos, ext, Table, % "`t" RowID "`t",, pos
				If ( ErrorLevel )
					Break
				StringGetPos, pos, Table, `n, R, len - ext - 1
				StringMid, row, Table, pos + 1, 1 + ext - pos
				StringReplace, row, row, % "`t", % "`t", UseErrorLevel
				If ( 0 = ErrorLevel -= RowCol )
					Break
				pos := ext + 1
			}
		If ( ErrorLevel )
			Return "", ErrorLevel := oel ; Error: the target row couldn't be found
	}

	StringTrimLeft, Table, Table, pos + 1 ; isolate the target row
	StringGetPos, pos, Table, `n
	StringLeft, Table, Table, pos
	Table .= "`t"

	IfInString, Columns, `n
	{ ; The user wants multiple cell values put into the output parameters
		ext := 0
		Loop, Parse, Columns, `n, `r
		{
			If ( "{" = hdpos := Chr( 96 + A_Index ) )
				Break
			If Asc( A_LoopField ) != 9 ; column by name
			{
				StringLeft, Columns, header, InStr( header, "`t" A_LoopField "`t" )
				StringReplace, Columns, Columns, % "`t", % "`t", UseErrorLevel
				ErrorLevel -= 1
			}
			Else ErrorLevel := Round( SubStr( A_LoopField, 2 ) ) - 1

			If ( ErrorLevel < 0 || ColCount < ErrorLevel )
				Continue ; error: column not found ( just skip this column )
			If ( ErrorLevel )
			{
				StringGetPos, pos, Table, % "`t", L%ErrorLevel%
				StringTrimLeft, Columns, Table, pos + 1
			}
			Else Columns := Table
			StringLeft, %hdpos%, Columns, InStr( Columns "`t", "`t" ) - 1
			ext++				
		}
		Return ext, ErrorLevel := oel
	}
	Else ; the user just wants one value returned by this function
	{
		If Asc( Columns ) != 9 ; column by name
		{
			StringLeft, Columns, header, InStr( header, "`t" Columns "`t" )
			StringReplace, Columns, Columns, % "`t", % "`t", UseErrorLevel
			Columns := ErrorLevel - 1
		}
		Else Columns := Round( SubStr( Columns, 2 ) ) - 1
		If ( Columns < 0 || ColCount < Columns )
			Return "", ErrorLevel := oel ; error: columns not found
		If ( Columns )
		{
			StringGetPos, pos, Table, % "`t", L%Columns%
			StringTrimLeft, Table, Table, pos + 1
		}
		StringGetPos, pos, Table, % "`t"
		StringLeft, Table, Table, pos
		Return Table, ErrorLevel := oel
	}
} ; Table_GetCell( Table, RowID, Columns="`t1", byref a-z="" ) -------------------------------------

Table_GetColName( Table, Col=1 ) { ; ---------------------------------------------------------------
; Returns the column name (header cell) at the index indicated in 'Col'. If 'Col' is less than 1, it
; is interpereted as an offset from the rightmost column name.
	oel := ErrorLevel, Table .= "`n", Col |= 0
	StringGetPos, pos, Table, `n
	StringLeft, Table, Table, pos
	StringTrimRight, Table, Table, pos = InStr( Table, "`r" )
	Table := "`t" Table "`t"
	StringReplace, Table, Table, % "`t", % "`t", UseErrorLevel
	ColCount := ErrorLevel - 1
	Col += ColCount * ( Col < 1 )
	If ( Col < 1 || ColCount < Col )
		Return "", ErrorLevel := oel ; invalid index
	StringGetPos, ColCount, Table, % "`t", L%Col%
	StringTrimLeft, Table, Table, ColCount + 1
	Return SubStr( Table, 1, InStr( Table, "`t" ) - 1 ), ErrorLevel := oel
} ; Table_GetColName( Table, Col=1 ) ---------------------------------------------------------------

Table_GetRowIndex( Table, Value, Column="`t1" ) { ; ------------------------------------------------
; Returns the ordinal position of the topmost row that has a cell with a value matching 'Value' in
; the column indicated by 'Column'. If no such row is found, this function returns zero.
; NOTE: Unlike most other table functions, this function CAN match numeric values across formats.
	oel := ErrorLevel
	Loop, Parse, Table, `n, `r
		If ( A_Index = 1 )
		{
			Table := ""
			StringReplace, Table, A_LoopField, % "`t", % "`t", UseErrorLevel
			ColCount := ErrorLevel, Table := "`t" Table "`t"
			If Asc( Column ) != 9 ; column by name
			{
				StringLeft, Table, Table, InStr( Table, "`t" Column "`t" )
				StringReplace, Table, Table, % "`t", % "`t", UseErrorLevel
				Column := ErrorLevel - 1
			}
			Else Column := Floor( SubStr( Column, 2 ) ) - 1 ; column by index
			If ( Column < 0 || ColCount < Column )
				Return 0, ErrorLevel := oel ; error: column not found
		}
		Else ; look through the table's rows for a cell value match
		{
			If !( Column )
				StringLeft, Table, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
			Else If ( Column = Colcount )
				StringTrimLeft, Table, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
			Else
			{
				StringGetPos, pos, A_LoopField, % "`t", L%Column%
				StringTrimLeft, Table, A_LoopField, pos + 1
				StringLeft, Table, Table, InStr( Table "`t", "`t" ) - 1
			}
			If ( Value = Table )
				Return A_Index - 1, ErrorLevel := oel
		}
	Return 0, ErrorLevel := oel
} ; Table_GetRowIndex( Table, RowID, Column="`t1" ) ------------------------------------------------

Table_Header( Table ) { ; --------------------------------------------------------------------------
; Returns the header of the input table.
	oel := ErrorLevel, Table .= "`n"
	StringGetPos, pos, Table, `n
	StringLeft, Table, Table, pos
	StringTrimRight, Table, Table, SubStr( Table, 0 ) = "`r"
	Return Table, ErrorLevel := oel
} ; Table_Header( Table ) --------------------------------------------------------------------------

Table_Intersect( TableA, TableB, MatchColA="", MatchColB="" ) { ; ----------------------------------
; Returns TableA, with any row with a value that does not match a value in TableB's match column
; removed. If MatchColB is blank, it is treated as the same column NAME as MatchColA. If MatchColA
; is blank, it is considered to be the NAME of TableB's first column (this makes it easier to
; intersect a table using a simple list of values). If the value of 'TableB' is a positive integer,
; rows will be removed from TableA if the value in MatchColA does not match the value in a row
; previously removed. In other words, it removes rows that are not duplicates of previous rows. The
; integer value specified indicates the number of removed values needed to prevent a row from being
; removed, so '2' means that the first two instances are removed, but not any subsequent ones.

	If TableB IS INTEGER
		MatchColB := "`n"
	Else
	{
		TableB .= "`n"
		StringGetPos, pos, TableB, `n
		StringLeft, HeaderB, TableB, pos
		StringTrimRight, HeaderB, HeaderB, pos = InStr( HeaderB, "`r", 0, 0 )
	}
	StringLen, len, TableA
	Loop, Parse, TableA, `n, `r
		If ( A_Index = 1 ) ; figure out what kind of deintersection we're doing here
		{
			TableA := A_LoopField
			StringReplace, ColCount, A_LoopField, % "`t", % "`t", UseErrorLevel
			ColCount := ErrorLevel
			If ( MatchColA = "" )
				If ( MatchColB != "`n" ) ; MatchColA defaults to TableB's 1st col
					StringLeft, MatchColA, HeaderB, InStr( HeaderB "`t", "`t" ) - 1
				Else StringLeft, MatchColA, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1

			If Asc( MatchColA ) != 9 ; column by name
			{
				vxe := "`t" A_LoopField
				StringLeft, MatchColA, vxe, InStr( vxe "`t", "`t" MatchColA "`t" )
				StringReplace, MatchColA, MatchColA, % "`t", % "`t", UseErrorLevel
				MatchColA := ErrorLevel - 1
			}
			Else MatchColA := Round( SubStr( MatchColA, 2 ) ) - 1 ; column by index

			If ( MatchColA < 0 || ColCount < MatchColA )
				Return A_LoopField, ErrorLevel := oel ; column not found, so return the header

			If ( MatchColB = "`n" ) ; it's a multiples intersection
				MatchColB := 0 - TableB, VarSetCapacity( TableB, len / ColCount << !!A_IsUnicode, 0 )
			Else
			{
				If ( MatchColB = "" ) ; if MatchColB is blank, use MatchColA's name as MatchColB
				{
					If !( MatchColA )
						StringLeft, MatchColB, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
					Else If ( MatchColA = ColCount )
						StringTrimLeft, MatchColB, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
					Else
					{
						StringGetPos, pos, A_LoopField, % "`t", L%MatchColA%
						StringTrimLeft, MatchColB, A_LoopField, pos + 1
						StringLeft, MatchColB, MatchColB, InStr( MatchColB, "`t" ) - 1
					}
				}

				If Asc( MatchColB ) != 9 ; column by name
				{
					vxe := "`t" HeaderB
					StringLeft, MatchColB, vxe, InStr( vxe "`t", "`t" MatchColB "`t" )
					StringReplace, MatchColB, MatchColB, % "`t", % "`t", UseErrorLevel
					MatchColB := ErrorLevel - 1
				}
				Else MatchColB := Round( SubStr( MatchColB, 2 ) ) - 1 ; column by index

				StringReplace, HeaderB, HeaderB, % "`t", % "`t", UseErrorLevel
				If ( MatchColB < 0 || ErrorLevel < MatchColB )
					Return A_LoopField, ErrorLevel := oel ; column not found, so return the header

				Loop, Parse, TableB, `n, `r ; reduce TableB to just its match col (in list form)
					If ( A_Index = 1 )
						TableB := "`n"
					Else
					{
						If !( MatchColB )
							StringLeft, vxe, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
						Else If ( MatchColB = ColCount )
							StringTrimLeft, vxe, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
						Else
						{
							StringGetPos, pos, A_LoopField, % "`t", L%MatchColB%
							StringTrimLeft, vxe, A_LoopField, pos + 1
							StringLeft, vxe, vxe, InStr( vxe, "`t" ) - 1
						}
						TableB .= vxe "`n"
					}
				StringTrimRight, TableB, TableB, 1
			}
			; for a multiples deintersection, the matchlist is generated as the table is parsed.
		}
		Else If ( A_LoopField = "" )
			Continue
		Else If ( MatchColB < 0 ) ; multiples deintersection
		{
			If !( MatchColA )
				StringLeft, vxe, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
			Else If ( MatchColA = ColCount )
				StringTrimLeft, vxe, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
			Else
			{
				StringGetPos, pos, A_LoopField, % "`t", L%MatchColA%
				StringTrimLeft, vxe, A_LoopField, pos + 1
				StringLeft, vxe, vxe, InStr( vxe, "`t" ) - 1
			}
			StringReplace, TableB, TableB, `n%vxe%`n, `n%vxe%`n, UseErrorLevel
			If ( 0 <= ErrorLevel + MatchColB ) ; previous count minus the allowed count
			{
				TableA .= "`n" A_LoopField
				TableB .= "`n" vxe "`n"
			}
		}
		Else ; normal deintersection
		{
			If !( MatchColA )
				StringLeft, pos, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
			Else If ( MatchColA = ColCount )
				StringTrimLeft, pos, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
			Else
			{
				StringGetPos, pos, A_LoopField, % "`t", L%MatchColA%
				StringTrimLeft, pos, A_LoopField, pos + 1
				StringLeft, pos, pos, InStr( pos, "`t" ) - 1
			}
			IfInString, TableB, `n%pos%`n
				TableA .= "`n" A_LoopField
		}
	Return TableA, ErrorLevel := oel
} ; Table_Intersect( TableA, TableB, MatchColA="", MatchColB="" ) ----------------------------------

Table_Invert( Table ) { ; --------------------------------------------------------------------------
; Inverts a table so that the first cell of each row becomes a column header and each column header
; becomes the text in the first cell of a row. Conceptually, the name of the first column is at
; coordinates (1,1), therefore, its position will not be changed by this function.
; Inverts a table so that the first cell of each row becomes a column header and each column header
; becomes the text in the first cell of a row. Conceptually, the name of the first column is at
; coordinates (1,1), therefore, its position will not be changed by this function.
	B_Index := C_Index := Table_Invert_Cell_1_1 := Table_Invert_Cell_0x1_0x1 := 1

	Loop, Parse, Table, `n, `r
		If ( 1 == B_Index := A_Index )
			Loop, Parse, A_LoopField, % "`t"
				Table_Invert_Cell_%B_Index%_%A_Index% := A_LoopField, C_Index := A_Index
		Else Loop, Parse, A_LoopField, % "`t"
				Table_Invert_Cell_%B_Index%_%A_Index% := A_LoopField

	Loop, % C_Index
		Loop % !( C_Index := A_Index ) + B_Index
			If ( C_Index = 1 && A_Index = 1 )
				Table := Table_Invert_Cell_%A_Index%_%C_Index%
			Else Table .= ( A_Index = 1 ? "`n" : "`t" ) . Table_Invert_Cell_%A_Index%_%C_Index%

	Return Table
} ; Table_Invert( Table ) --------------------------------------------------------------------------

Table_Join( TableA, TableB, JoinType="Left", MatchColA="", MatchColB="" ) { ; ----------------------
; Appends columns from TableB to the right of TableA. JoinType must be one of the following:
;  Left, Right, Inner, Outer, Left 1:1, Right 1:1, Inner 1:1, Outer 1:1
; Left joins have every row in the left table (TableA) represented at least once in the output table.
; Right joins are like left joins, only for TableB (the right table).
; Inner joins omit (ignore) rows that don't have a match between the input tables.
; Outer joins are the least restrictive, every row in both tables is represented in the output table.
; The '1:1' modifier prevents a row in the key table from being duplicated because two or more rows
; in the other table have a matching 'MatchCol' value. Only the first match will be considered.
; NOTE: If TableB is the word 'Self', this function performs a self-join on TableA. 'MatchColB' may
; be a prefix given to columns added this way. For a self-join, 'Left' and 'Right' instead mean 'Up'
; and 'Down', and effect which rows are cosidered when matching. A row is never considered a match
; for itself. If 'Right' is specified, a row will only match on rows ABOVE it ('Left' = rows BELOW).
; For self-joins, 'Inner' and 'Outer' are converted into 'Left', though the '1:1' modifier remains.
; NOTE: the return table's column order is always as though TableB's matchcol was cut out, and then
; TableB's columns were placed on the right side of TableA.
	Table := ""
	oel := ErrorLevel
	StringReplace, JoinType, JoinType, 1:1
	one2one := !ErrorLevel
	StringLower, JoinType, JoinType
	HeaderA := "left,right,inner,outer"
	Loop, Parse, HeaderA, `,
		IfInString, JoinType, %A_LoopField%
			JoinType := A_LoopField
	If JoinType NOT IN %HeaderA%
		Return "" ; error: invalid jointype. Return blank

	; Get TableA's header
	TableA .= "`n"
	StringGetPos, pos, TableA, `n
	StringLeft, HeaderA, TableA, pos
	StringTrimRight, HeaderA, HeaderA, SubStr( HeaderA, 0 ) = "`r"
	StringTrimRight, TableA, TableA, 1

	If ( MatchColA = "" )
		StringLeft, MatchColA, HeaderA, InStr( HeaderA "`t", "`t" ) - 1

	; Determine TableA's MatchCol
	HeaderA := "`t" HeaderA "`t"
	StringReplace, HeaderA, HeaderA, % "`t", % "`t", UseErrorLevel
	ColCountA := ErrorLevel - 2
	If Asc( MatchColA ) != 9
	{
		StringLeft, MatchColA, HeaderA, InStr( HeaderA, "`t" MatchColA "`t" )
		StringReplace, MatchColA, MatchColA, % "`t", % "`t", UseErrorLevel
		MatchColA := ErrorLevel
	}
	Else MatchColA := Round( SubStr( MatchColA, 2 ) )
	If ( MatchColA < 1 || ColCountA + 1 < MatchColA )
		Return "", ErrorLevel := oel ; Error: MatchColA not found

	StringTrimLeft, TableA, TableA, pos + 1

	; Get the column name of TableA's MatchCol

	StringGetPos, ColName, HeaderA, % "`t", L%MatchColA%
	StringTrimLeft, ColName, HeaderA, ColName + 1
	StringLeft, ColName, ColName, InStr( ColName "`t", "`t" ) - 1

	; If we're doing a self-join, copy TableA into TableB and tweak TableB's header with the
	; prefix in 'MatchColB'.
	If ( Self_Join := TableB = "Self" )
	{
		StringReplace, HeaderB, HeaderA, % "`t", % "`t" MatchColB, UseErrorLevel
		ColCountB := ErrorLevel - 2
		StringTrimRight, HeaderB, HeaderB, StrLen( MatchColB )
		TableB := TableA
		MatchColB .= ColName
	}
	Else ; it's not a self-join, so get TableB's header
	{
		TableB .= "`n"
		StringGetPos, pos, TableB, `n
		StringLeft, HeaderB, TableB, pos
		StringTrimRight, HeaderB, HeaderB, SubStr( HeaderB, 0 ) = "`r"
		StringTrimRight, TableB, TableB, 1
		StringGetPos, pos, TableB, `n
		StringTrimLeft, TableB, TableB, pos + 1
		StringReplace, HeaderB, HeaderB, % "`t", % "`t", UseErrorLevel
		ColCountB := ErrorLevel
		HeaderB := "`t" HeaderB "`t"
		If ( MatchColB = "" )
			MatchColB := ColName
	}

	; Determine TableB's MatchCol
	If Asc( MatchColB ) != 9
	{
		StringLeft, MatchColB, HeaderB, InStr( HeaderB, "`t" MatchColB "`t" )
		StringReplace, MatchColB, MatchColB, % "`t", % "`t", UseErrorLevel
		MatchColB := ErrorLevel
	}
	Else MatchColB := Round( SubStr( MatchColB, 2 ) )

	If ( MatchColB < 1 || ColCountB + 1 < MatchColB )
		Return "", ErrorLevel := oel ; Error: MatchColB not found

	; Get the name of TableB's MatchCol (so we can remove it from the final table's header).

	StringGetPos, ColName, HeaderB, % "`t", L%MatchColB%
	StringTrimLeft, ColName, HeaderB, ColName + 1
	StringLeft, ColName, ColName, InStr( ColName "`t", "`t" ) - 1

	StringLen, cell, TableA
	StringLen, pos, TableB
	VarSetCapacity( Table, cell + pos, 0 ) ; guesstimate the final table's size
	StringReplace, Table, HeaderB, % "`t" ColName "`t", % "`t"
	Table := SubStr( HeaderA, 2 ) SubStr( Table, 2, -1 )
	MatchColA -= 1
	MatchColB -= 1

	; Prefill the null rows (groups of tab characters) even if we're doing an inner join
	NullRowB := "`t"
	Loop, % Ceil( Ln( ColCountB ) / Ln( 2 ) )
		NullRowB .= NullRowB
	StringLeft, NullRowB, NullRowB, ColCountB ; NullrowB contains tabs. NullrowA is imaginary.

	; Split TableA into a pseudo-array WITH its matchcol. Turn 'TableA' into a lookup list with
	; the matchcol values in it.
	Loop, Parse, TableA, `n, `r
	{
		Table_Join_RowA_%A_Index% := A_LoopField "`t"
		If !( MatchColA )
			StringLeft, cell, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
		Else
		{
			StringGetPos, pos, A_LoopField, % "`t", L%MatchColA%
			StringTrimLeft, cell, A_LoopField, pos + 1
			StringLeft, cell, cell, InStr( cell "`t", "`t" ) - 1
		}
		If ( 1 = ( RowCountA := A_Index ) )
			TableA := "`n" cell "`n"
		Else TableA .= cell "`n"
	}

	; Split TableB into a pseudo-array WITHOUT its matchcol. Turn 'TableB' into a lookup list with
	; the matchcol values in it.
	Loop, Parse, TableB, `n, `r
	{
		If !( MatchColB )
		{
			pos := InStr( A_LoopField "`t", "`t" )
			StringLeft, cell, A_LoopField, pos - 1
			StringTrimLeft, Table_Join_RowB_%A_Index%, A_LoopField, pos
		}
		Else
		{
			StringGetPos, pos, A_LoopField, % "`t", L%MatchColB%
			StringLeft, Table_Join_RowB_%A_Index%, A_LoopField, pos
			StringTrimLeft, cell, A_LoopField, pos + 1
			Table_Join_RowB_%A_Index% .= SubStr( cell, pos := InStr( cell "`t", "`t" ) )
			StringLeft, cell, cell, pos - 1
		}
		If ( 1 = ( RowCountB := A_Index ) )
			TableB := "`n" cell "`n"
		Else TableB .= cell "`n"
	}

	; Now decide which join operation to execute
	If ( JoinType = "inner" )
	{
		; The result rows of an inner join are in the same order as TableA.
		StringTrimRight, TableA, TableA, 1
		StringTrimLeft, TableA, TableA, 1
		Loop, Parse, TableA, `n
		{
			ThisRow := A_Index
			Loop % RowCountB
			{
				StringGetPos, pos, TableB, `n%A_LoopField%`n,, % A_Index = 1 ? 0 : pos + 1
				If ( ErrorLevel )
					Break
				StringLeft, HeaderA, TableB, pos + 1
				StringReplace, HeaderA, HeaderA, `n, `n, UseErrorLevel
				If ( Self_Join && ErrorLevel = ThisRow )
					Continue
				Table .= "`n" Table_Join_RowA_%ThisRow% Table_Join_RowB_%ErrorLevel%
				If ( one2one )
				{
					StringReplace, TableB, TableB, `n%A_LoopField%`n, `n`n
					Break
				}
			}
		}
	}
	Else If ( JoinType = "outer" )
	{
		; The result rows of an outer join are in the same order as TableA but also assuming that
		; the 'null' row is at the bottom of TableA
		HeaderB := "`n`n"
		StringTrimRight, TableA, TableA, 1
		StringTrimLeft, TableA, TableA, 1
		Loop, Parse, TableA, `n
		{
			MatchColB := 0
			ThisRow := A_Index
			Loop % RowCountB
			{
				StringGetPos, pos, TableB, `n%A_LoopField%`n,, % A_Index = 1 ? 0 : pos + 1
				If ( ErrorLevel )
				{
					If !( MatchColB ) ; if this row has no match at all, give it a null match
						Table .= "`n" Table_Join_RowA_%ThisRow% NullRowB
					HeaderB .= A_LoopField "`n"
					Break
				}
				StringLeft, HeaderA, TableB, pos + 1
				StringReplace, HeaderA, HeaderA, `n, `n, UseErrorLevel
				If ( Self_Join && ErrorLevel = ThisRow )
					Continue
				Table .= "`n" Table_Join_RowA_%ThisRow% Table_Join_RowB_%ErrorLevel%
				MatchColB := 1
				If ( one2one )
				{
					StringReplace, TableA, TableA, `n%A_LoopField%`n, `n`n
					StringReplace, TableB, TableB, `n%A_LoopField%`n, `n`n
					Break
				}
			}
		}
		; At this point, TableB contains the row ids that didn't match in TableA, so append each
		; of them to the table with NullRowA in front
		StringTrimRight, TableB, TableB, 1
		StringTrimLeft, TableB, TableB, 1
		Loop, Parse, TableB, `n
			IfNotInString, HeaderB, % "`n" A_LoopField "`n"
				{
					; re-add the identity value under MatchColA and join the B-Row to NullRowA
					Table .= "`n"
					Loop, % ColCountA + 1
						Table .= ( A_Index = MatchColA + 1 ) ? A_LoopField "`t" : "`t"
					Table .= Table_Join_RowB_%A_Index%
				}
	}
	Else If ( JoinType = "left" )
	{
		; Join each row in TableA to each matching row in TableB. Each row in TableA that doesn't
		; match at least one row in TableB is joined to NullRowB
		StringTrimRight, TableA, TableA, 1
		StringTrimLeft, TableA, TableA, 1
		Loop, Parse, TableA, `n
		{
			MatchColB := 0
			ThisRow := A_Index
			Loop % RowCountB
			{
				StringGetPos, pos, TableB, `n%A_LoopField%`n,, % A_Index = 1 ? 0 : pos + 1
				If ( ErrorLevel )
				{
					If !( MatchColB )
						Table .= "`n" Table_Join_RowA_%ThisRow% NullRowB
					Break
				}
				StringLeft, HeaderA, TableB, pos + 1
				StringReplace, HeaderA, HeaderA, `n, `n, UseErrorLevel
				If ( Self_Join && ErrorLevel <= ThisRow )
					Continue
				MatchColB := 1
				Table .= "`n" Table_Join_RowA_%ThisRow% Table_Join_RowB_%ErrorLevel%
				If ( one2one )
				{
					StringReplace, TableB, TableB, `n%A_LoopField%`n, `n`n
					Break
				}
			}
		}
	}
	Else If ( JoinType = "right" )
	{
		; Join each row in TableB to each matching row in TableA. Each row in TableB that doesn't
		; match at least one row in TableA is joined to NullRowA
		StringTrimRight, TableB, TableB, 1
		StringTrimLeft, TableB, TableB, 1
		Loop, Parse, TableB, `n
		{
			MatchColB := 0
			ThisRow := A_Index
			Loop % RowCountA
			{
				StringGetPos, pos, TableA, `n%A_LoopField%`n,, % A_Index = 1 ? 0 : pos + 1
				If ( ErrorLevel )
				{
					If !( MatchColB ) ; no matches at all, so join this row to NullRowA
					{
						Table .= "`n"
						Loop, % ColCountA + 1
							Table .= ( A_Index = MatchColA + 1 ) ? A_LoopField "`t" : "`t"
						Table .= Table_Join_RowB_%A_Index%
					}
					Break
				}
				StringLeft, HeaderA, TableA, pos + 1
				StringReplace, HeaderA, HeaderA, `n, `n, UseErrorLevel
				If ( Self_Join && ThisRow <= ErrorLevel )
					Continue
				Table .= "`n" Table_Join_RowA_%ErrorLevel% Table_Join_RowB_%ThisRow%
				MatchColB := 1
				If ( one2one )
				{
					StringReplace, TableA, TableA, `n%A_LoopField%`n, `n`n
					Break
				}
			}
		}
	}
	Return Table, ErrorLevel := oel
} ; Table_Join( TableA, TableB, JoinType="Left", MatchColA="", MatchColB="" ) ----------------------

Table_Len( Table ) { ; -----------------------------------------------------------------------------
; Returns the number of rows in the table, which is the number of newline characters in the table.
; The validity of the table is NOT checked by this function because this function is supposed to be
; as fast as possible.
	oel := ErrorLevel
	StringReplace, Table, Table, `n, `n, UseErrorLevel
	Return 0 + ErrorLevel, ErrorLevel := oel
} ; Table_Len( Table ) -----------------------------------------------------------------------------

Table_RemCols( Table, Columns ) { ; ----------------------------------------------------------------
; Removes table columns. Columns may be specified either by name or by a single tab and their index.
; Multiple columns can be removed by separating the column ids with a newline character.
	oel := ErrorLevel
	Loop, Parse, Table, `n, `r
		If ( A_Index = 1 )
		{
			Header := "`t" A_LoopField "`t"
			Columns := "`n" Columns
			Loop, Parse, Columns, `n, `r
				If ( A_Index = 1 )
					Columns := "`n"
				Else If Asc( A_LoopField ) = 9
					Columns .= 0 | Abs( SubStr( A_LoopField, 2 ) ) "`n"
				Else If ( pos := InStr( Header, "`t" A_LoopField "`t" ) )
				{
					StringLeft, pos, Header, pos
					StringReplace, pos, pos, % "`t", % "`t", UseErrorLevel
					Columns .= ErrorLevel "`n"
				}
			If ( Columns = "`n" )
				Return Table, ErrorLevel := oel ; no matching columns

			StringLen, pos, Header
			Loop, Parse, A_LoopField, % "`t"
				IfNotInString, Columns, `n%A_Index%`n
					Header .= A_LoopField "`t"
			StringTrimLeft, Header, Header, pos
			StringTrimRight, Table, Header, 1
		}
		Else
		{
			Table .= "`n"
			Loop, Parse, A_LoopField, % "`t"
				IfNotInString, Columns, `n%A_Index%`n
					Table .= A_LoopField "`t"
			StringTrimRight, Table, Table, 1
		}
	Return Table, ErrorLevel := oel
} ; Table_RemCols( Table, Columns ) ----------------------------------------------------------------

Table_RemRows( Table, RowIds, MatchCol="`t1" ) { ; -------------------------------------------------
; Returns Table, with any row whose 'MatchCol' value matches a value in RowIds removed from the table.
; Note: RowIds should be a newline-delimited list of row identifiers, which are either the contents
; of the MatchCol cell or a tab followed by an integer indicating the row's index.

	oel := ErrorLevel, Table .= "`n"
	StringGetPos, pos, Table, `n
	StringLeft, Header, Table, pos
	StringTrimRight, Header, Header, SubStr( Header, 0 ) = "`r"
	StringTrimRight, Table, Table, 1
	StringReplace, Header, Header, % "`t", % "`t", UseErrorLevel
	ColCount := ErrorLevel
	If Asc( MatchCol ) != 9
	{
		pos := "`t" Header "`t"
		StringLeft, MatchCol, pos, InStr( pos, "`t" MatchCol "`t" )
		StringReplace, MatchCol, MatchCol, % "`t", % "`t", UseErrorLevel
		MatchCol := ErrorLevel - 1
	}
	Else MatchCol := Round( SubStr( MatchCol, 2 ) ) - 1

	Header := "`n"
	RowIds := "`n" RowIds
	Loop, Parse, RowIds, `n, `r
		If ( A_Index = 1 )
			RowIds := "`n"
		Else If Asc( A_LoopField ) = 9 ; it's a row number
			Header .= Abs( SubStr( A_LoopField, 2 ) ) + 1 "`n"
		Else RowIds .= A_LoopField "`n"

	If !( MatchCol )
		Loop, Parse, Table, `n, `r
			If ( A_Index = 1 )
				Table := A_LoopField
			Else IfNotInString, Header, `n%A_Index%`n
			{
				StringLeft, Cell, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
				IfNotInString, RowIds, `n%Cell%`n
					Table .= "`n" A_LoopField
			}
	Else If ( MatchCol = ColCount )
		Loop, Parse, Table, `n, `r
			If ( A_Index = 1 )
				Table := A_LoopField
			Else IfNotInString, Header, `n%A_Index%`n
			{
				StringTrimLeft, Cell, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
				IfNotInString, RowIds, `n%Cell%`n
					Table .= "`n" A_LoopField
			}
	Else Loop, Parse, Table, `n, `r
			If ( A_Index = 1 )
				Table := A_LoopField
			Else IfNotInString, Header, `n%A_Index%`n
			{
				StringGetPos, pos, A_LoopField, % "`t", L%MatchCol%
				StringTrimLeft, cell, A_LoopField, pos + 1
				StringLeft, cell, cell, InStr( cell, "`t" ) - 1
				IfNotInString, RowIds, `n%Cell%`n
					Table .= "`n" A_LoopField
			}
	Return Table, ErrorLevel := oel
} ; Table_RemRows( Table, RowIds, MatchCol="`t1" ) -------------------------------------------------

Table_RenameCol( Table, Column_Names="" ) {
; 'Column_Names' must be a 2-column table with the match on the left and the replacement on the right.
; Returns 'Table' with each matching column name replaced with the associated replacement.

	Column_Names := "`n" Column_Names "`n"
	StringLeft, hedr, Table, -1 + pot := InStr( Table "`n", "`n" )
	Loop, Parse, hedr, % "`t", `r
		If ( pos := InStr( Column_Names, "`n" A_LoopField "`t" ) )
		{
			pos := pos + 2 + StrLen( A_LoopField )
			hedr .= "`t" SubStr( Column_Names, pos, InStr( Column_Names, "`n", 0, pos ) - pos )
		}
		Else hedr .= "`t" A_LoopField
	Return SubStr( hedr, pot + 1 ) SubStr( Table, pot )
}

Table_Reverse( Table ) { ; -------------------------------------------------------------------------
; Reverses the row order of the table (EXCLUDING the header). Uses MoveMemory for speed with large tables.
	oel := ErrorLevel, ptr := A_PtrSize = "" ? "UInt" : "Ptr", u := 1 = A_IsUnicode
	StringReplace, Table, Table, `r`n, `n, A
	StringLen, length, Table
	Loop, Parse, Table, `n
		If ( A_Index = 1 )
			VarSetCapacity( Table, 1 + u + ( length <<= u ), 0 ), Table .= A_LoopField
		Else len := StrLen( vxe := "`n" A_LoopField ) << u
			, DllCall( "RtlMoveMemory", ptr, &Table + ( length -= len ), ptr, &vxe, "UInt", len )
	Return Table, VarSetCapacity( Table, -1 ), ErrorLevel := oel
} ; Table_Reverse( Table ) -------------------------------------------------------------------------

Table_RotateL( Table ) { ; ------------------------------------------------------------------------------------
; Rotates a table 90 degrees to the left, including the header.
	Loop, Parse, Table, `n, `r
		If ( 1 = B_Index := A_Index )
			Loop, Parse, A_LoopField, % "`t"
				Table_RotateL__Cell_%B_Index%_%A_Index% := A_LoopField, C_Index := A_Index + 1
		Else
			Loop, Parse, A_LoopField, % "`t"
				Table_RotateL__Cell_%B_Index%_%A_Index% := A_LoopField

	Loop, % pos := C_Index - 1
		Loop, % B_Index + 0 * ( C_Index -= 1 )
			If ( A_Index = 1 && C_Index = pos )
				Table := Table_RotateL__Cell_%A_Index%_%C_Index%
			Else
				Table .= ( A_Index = 1 ? "`n" : "`t" ) Table_RotateL__Cell_%A_Index%_%C_Index%
	Return Table
} ; Table_RotateL( Table ) ------------------------------------------------------------------------------------

Table_SetCell( Table, RowID, Column, value ) { ; ---------------------------------------------------
; Replaces the contents of a single cell in the table. If RowID contains a single newline character,
; it is interpereted to separate the column in which the desired rowid's value lies, and the rowid
; value itself. In other words, Table_SetCell( Toys, "Sku`n1234567890", "Price", "5.99" ) would
; set the 'Price' column for the topmost row that contains '1234567890' in the 'Sku' column. By
; default, the 'RowID' value is compared against values in the first column of the table.
; This function has a special mode when the row is identified by index and the table's row count
; is exactly 1 less than the specified index. In this case, the table gains a new row, with every
; cell empty except the one for 'Column', which receives the contents of 'value'.
; NOTE: if this function encounters an error, it will simply return the table unaltered EXCEPT for
; the transformation of CRLFs into LFs. Errors include non-matching criteria, or bad parameters.

	oel := ErrorLevel, Table .= "`n"
	Loop 1 ; This allows 'Break' to jump to the cleanup section... like a GoTo, only sneakier
	{
		StringReplace, Table, Table, `r`n, `n, A ; convert CRLF into LF
		StringGetPos, hdpos, Table, `n
		StringLeft, header, Table, hdpos ; get the table header (we added a newline to the table)
		StringReplace, header, header, % "`t", % "`t", UseErrorLevel
		ColCount := ErrorLevel
		StringReplace, Table, Table, `n, `n, UseErrorLevel
		RowCount := ErrorLevel

		header := "`t" header "`t"
		If Asc( Column ) != 9 ; column by name
		{
			StringLeft, Column, header, InStr( header, "`t" Column "`t" )
			StringReplace, Column, Column, % "`t", % "`t", UseErrorLevel
			Column := ErrorLevel - 1
		}
		Else Column := Round( SubStr( Column, 2 ) ) - 1 ; column by index
		If ( Column < 0 ) || ( ColCount < Column )
			Break ; Error: invalid column specified

		StringTrimLeft, RowID, RowID, InStr( RowID, "`n`t" ) ; simplify contradictory rowID
		StringGetPos, pos, RowID, `n ; look for the ID column's ID
		If ( ErrorLevel ) ; the row is indicated in the simple manner
			If Asc( RowID ) = 9 ; the row is indicated by index
			{
				RowID := Round( SubStr( RowID, 2 ) )
				If ( RowID <= 0 || RowCount < RowID ) ; the row isn't in the table
					Break
				Else If ( RowID = RowCount ) ; the rowid is exactly 1 more than the table's rowcount
				{
					Loop % ColCount + 1
						Table .= ( A_Index = Column + 1 ? value : "" ) ( A_Index = ColCount + 1 ? "`n" : "`t" )
					Break ; adding a new row with one cell is pretty straightforward, so we're done
				}
				StringGetPos, pos, Table, `n, L%RowID%
			}
			Else ; the row is indicated by the contents of its first cell
				StringGetPos, pos, Table, % "`n" RowID ( ColCount ? "`t" : "`n" ),, pos
		Else ; the row is indicated by column name and value
		{
			StringLen, len, Table
			StringLeft, RowCol, RowID, pos
			StringTrimLeft, RowID, RowID, pos + 1
			If Asc( RowCol ) != 9 ; column by name
			{
				StringLeft, RowCol, header, InStr( header, "`t" RowCol "`t" )
				StringReplace, RowCol, RowCol, % "`t", % "`t", UseErrorLevel
				RowCol := ErrorLevel - 1
			}
			Else RowCol := Round( SubStr( RowCol, 2 ) ) - 1 ; column by index
			If ( RowCol < 0 ) || ( ColCount < RowCol )
				Break ; Error: invalid rowidcol specified

			pos := hdpos
			If !( RowCol ) ; look for a rowID in the first column
				StringGetPos, pos, Table, % "`n" RowID ( ColCount ? "`t" : "`n" ),, pos
			Else If ( RowCol = ColCount ) ; look for a rowID in the last column
			{
				StringGetPos, pos, Table, % "`t" RowID "`n",, pos
				StringGetPos, pos, Table, `n, R, len - pos - 1
			}
			Else Loop ; we'll have to look for the matching value and then check its column
				{
					StringGetPos, ext, Table, % "`t" RowID "`t",, pos
					If ( ErrorLevel )
						Break
					StringGetPos, pos, Table, `n, R, len - ext - 1
					StringMid, header, Table, pos + 1, 1 + ext - pos
					StringReplace, header, header, % "`t", % "`t", UseErrorLevel
					If ( 0 = ErrorLevel -= RowCol )
						Break
					pos := ext + 1
				}
		}

		; At this point, 'pos' holds the location of the newline at the beginning of the target
		; row, unless ErrorLevel is nonzero, in which case the row could not be found
		If ( ErrorLevel )
			Break ; Error: Row not found

		If ( Column ) ; update a cell other than the first in the row
			StringGetPos, pos, Table, % "`t", L%Column%, pos
		StringGetPos, ext, Table, % ( Column = ColCount ? "`n" : "`t" ),, pos + 1

		; Now, pos and ext hold the positions of the leading delimiter and trailing delimiter
		; for the target cell, so, to insert the new value, we'll cut the table at each location
		; and rejoin the ends around the new cell's value.

		StringTrimLeft, header, Table, ext
		StringLeft, Table, Table, pos + 1
		Table .= value header
	}
	StringTrimRight, Table, Table, 1 ; chop the trailing newline ( the one we put there )
	Return Table, ErrorLevel := oel
} ; Table_SetCell( Table, RowID, Column, value ) ---------------------------------------------------

Table_Sort( Table, Column="`t1", Sort_Options="" ) { ; ---------------------------------------------
; Sorts the table based on the value in the indicated column. The sort options are the same as for
; the sort command, with the exception of the 'D' (delimiter) option for obvious reasons.
	oel := ErrorLevel
	Loop, Parse, Table, `n, `r
		If ( A_Index = 1 ) ; handle the header
		{
			StringReplace, Header, A_LoopField, % "`t", % "`t", UseErrorLevel
			ColCount := ErrorLevel, vxe := "`t" Header "`t"
			If Asc( Column ) != 9 ; column by name
			{
				StringLeft, vxe, vxe, InStr( vxe, "`t" Column "`t" )
				StringReplace, vxe, vxe, % "`t", % "`t", UseErrorLevel
				Column := ErrorLevel - 1
			}
			Else Column := Floor( SubStr( Column, 2 ) ) - 1 ; column by index
			If ( Column < 0 || ColCount < Column )
				Return Table, ErrorLevel := oel ; error: column not found
		}
		Else ; split the rows into a pseudo-array and use the table parameter to hold the list of
		{ ; actionable cell values (the column we're about to sort).
			If !( Column )
				StringLeft, vxe, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1
			Else If ( Column = Colcount )
				StringTrimLeft, vxe, A_LoopField, InStr( A_LoopField, "`t", 0, 0 )
			Else
			{
				StringGetPos, pos, A_LoopField, % "`t", L%Column%
				StringTrimLeft, vxe, A_LoopField, pos + 1
				StringLeft, vxe, vxe, InStr( vxe "`t", "`t" ) - 1
			}
			Table_Sort_Row_%A_Index% := A_LoopField
			If ( A_Index = 2 )
				Table := vxe
			Else Table .= "`n" vxe
		}
	LookupList := "`n`n`n" Table "`n"
	Sort, Table, %Sort_Options% D`n ; the final 'D`n' should override any previous 'D?' option
	Loop, Parse, Table, `n ; the sorted table also contains the row indices belonging to the vxes
	{
		If ( A_Index = 1 )
			Table := Header
		StringGetPos, pos, LookupList, % "`n" A_LoopField "`n"
		StringLeft, Header, LookupList, pos
		StringReplace, LookupList, LookupList, % "`n" A_LoopField "`n", `n`n
		StringReplace, Header, Header, `n, `n, UseErrorLevel
		Table .= "`n" Table_Sort_Row_%ErrorLevel% ; rebuild the table
	}
	Return Table, ErrorLevel := oel
} ; Table_Sort( Table, Column="`t1", Sort_Options="" ) ---------------------------------------------

Table_SpacePad( Table, MinPadCount=3, PadChar=" " ) { ; --------------------------------------------
; Converts a 9/10 table into a padded text block by appending enough 'padchar' to each cell's value
; to make the next cell's value be the same distance from the start of the row as every other cell
; in that column. In other words, it lines up the column using the character count for each cell.
; 'MinPadCount' is the number of pad characters to append to the longest cell in each column.
; If 'MinPadCount' is preceeded by a tab character, it becomes the ABSOLUTE column width, and cell
; contents will be truncated to 1 character shorter than the numeric portion of 'MinPadCount'.
; Specify a negative 'MinPadCount' to right-justify each cell's contents (padding goes on the left).
; NOTE: this function will NEVER pad the rightmost column ON THE RIGHT.
	StringLeft, PadChar, PadChar, 1
	If !( PadAsc := Asc( PadChar ) )
		Return "" ; Error: empty pad character
	oel := ErrorLevel
	StringLeft, ColCount, Table, InStr( Table . "`n", "`n" )
	StringReplace, ColCount, ColCount, % "`t", % "`t", UseErrorLevel
	ColCount := ErrorLevel + 1
	If Asc( MinPadCount ) = 9 ; Fixed width
	{
		MinPadCount := 0 | SubStr( MinPadCount, 2 )
		Adj := 1, RJust := MinPadCount < 1, MinPadCount := Abs( MinPadCount )
		Loop % ColCount
			Table_SpacePad_MaxLen_%A_Index% := MinPadCount
	}
	Else ; content-sensitive width
	{
		Loop % ColCount
			Table_SpacePad_MaxLen_%A_Index% := 0
		Adj := 0, RJust := MinPadCount < 1, MinPadCount := Abs( 0 | MinPadCount )
		Loop, Parse, Table, `n, `r
			Loop, Parse, A_LoopField, % "`t"
				If ( Table_SpacePad_MaxLen_%A_Index% < StrLen( A_LoopField ) + MinPadCount )
					Table_SpacePad_MaxLen_%A_Index% := StrLen( A_LoopField ) + MinPadCount * ( !RJust || A_Index <> 1 )
		Loop % ColCount - 1 ; find the widest column's width. That determines the size of the padding base
			If ( MinPadCount < Table_SpacePad_MaxLen_%A_Index% )
				MinPadCount := Table_SpacePad_MaxLen_%A_Index%
	}
; Update: don't cache the padding base, rebuild it every time.
	Padding := Chr( PadAsc ) ; Build the padding base by doubling it until length >= MaxPadCount
	Loop, % Ceil( Ln( MinPadCount ) / Ln( 2 ) )
		Padding .= Padding

	Loop, Parse, Table, `n, `r
	{ 
		PadAsc := A_Index
		Loop, Parse, A_LoopField, % "`t"
		{
			StringLeft, Cell, A_LoopField, % Table_SpacePad_MaxLen_%A_Index% - Adj
			If ( RJust )
				Cell := SubStr( Padding . Cell, 1 - Table_SpacePad_MaxLen_%A_Index% )
			Else If ( A_Index != ColCount )
				Cell := SubStr( Cell . Padding, 1, Table_SpacePad_MaxLen_%A_Index% )

			If ( A_Index != 1 )
				Table .= Cell
			Else	If ( PadAsc != 1 )
				Table .= "`n" Cell
			Else Table := Cell
		}
	}
	Return Table, ErrorLevel := oel
} ; Table_SpacePad( Table, MinPadCount=3, PadChar=" " ) --------------------------------------------

Table_SubTable( Table, TopRowId="`t1", NumberOfRows=0 ) { ; ----------------------------------------
; Returns a table with the same header as the input table, but containing only 'NumberOfRows' rows.
; 'TopRowId' should contain the value of the first cell of the first row that you want in the
; returned table ( as usual, the row's index can be used instead if it is preceded by a tab ).
; NOTE: If 'NumberOfRows' is less than 1, it indicates the number of rows to OMIT from the bottom of
; of the table. Also, if TopRowId is an index less than 1, it is considered an offset from the last
; row in the table. E.g: "Table_SubTable( Table, "`t-1", 1 )" returns a table containing only the
; second-to-last row of the input table and "Table_SubTable( Table, "`t2", -1 )" returns a table
; missing its first and last rows.
	oel := ErrorLevel, Table .= "`n"
	StringReplace, Table, Table, `r`n, `n, A ; Convert CRLF to LF
	StringGetPos, pos, Table, `n
	StringLeft, Header, Table, pos
	ColCount := !InStr( Header, "`t" )
	StringReplace, Table, Table, `n, `n, UseErrorLevel
	RowCount := ErrorLevel - 1
	If Asc( TopRowId ) = 9 ; row by index
	{
		TopRowId := Round( SubStr( TopRowId, 2 ) )
		If ( TopRowId < 1 )
			TopRowId += RowCount
		StringGetPos, pos, Table, `n, L%TopRowId%
	}
	Else StringGetPos, pos, Table, % "`n" TopRowId ( ColCount ? "`n" : "`t" ) ; row by 1st cell

	If ( NumberOfRows < 1 )
		NumberOfRows += RowCount - TopRowId
	If ( ErrorLevel || NumberOfRows < 1 || RowCount < TopRowId)
		Return Header, ErrorLevel := oel ; error: table row not found

	StringTrimLeft, Table, Table, pos
	StringGetPos, pos, Table, `n, L%NumberOfRows%, 1
	If !( ErrorLevel )
		StringLeft, Table, Table, pos + 1
	StringTrimRight, Table, Table, 1
	Return Header Table, ErrorLevel := oel
} ; Table_SubTable( Table, TopRowId="`t1", NumberOfRows=0 ) ----------------------------------------

Table_ToCSV( 9_10_Table ) { ; ----------------------------------------------------------------------
; Converts a 9/10 table to CSV format.
; NOTE: A cell's contents will be wrapped in quotes if it contains a comma, quote, or newline
	oel := ErrorLevel
	StringLen, vxe, 9_10_Table
	Loop, Parse, 9_10_Table, `n, `r
		Loop, Parse, A_LoopField, % "`t"
		{
			If ( vxe )
				VarSetCapacity( 9_10_Table, vxe + 0, vxe := 0 )
			Else 9_10_Table .= A_Index = 1 ? "`n" : ","

			cell := A_LoopField
			StringReplace, cell, cell, &#10`;, `n, A
			StringReplace, cell, cell, &#09`;, % "`t", A
			StringReplace, cell, cell, % """", "", A ; double-up quotes
			If !( ErrorLevel ) || InStr( cell, "," ) || InStr( cell, "`n" )
				9_10_Table .= """" cell """"
			Else 9_10_Table .= cell
		}
	Return 9_10_Table, ErrorLevel := oel
} ; Table_ToCSV( 9_10_Table ) ----------------------------------------------------------------------

Table_ToListview( Table, Mode=7, MatchCol="`t1" ) { ; ----------------------------------------------
; Modifies the current listview using the specified table. NOTE: operations that use a matching row
; use string comparisons for the match, not numeric comparisons, even if the members are numbers.
; Mode can be one of the following:
;   0 - No table rows are added or changed. ( e.g: to set up a listview's columns, use 0+32+64+128 )
;   1 - Overwrites the listview's row data with the table's contents.
;   2 - Overwrites the listview's row data but preserves selected rows. *
;   3 - Overwrites the listview's row data but preserves checked rows. *
;   4 - Overwrites the listview's row data but preserves selected AND checked rows. *
;   5 - Updates the listview with the table's contents, matching on 'MatchCol'. *
;   6 - Appends the table's contents to the listview.
;   7 - Updates the listview where matching rows can be found and appends the remaining rows. *
; Any of the following options can be applied by adding the number to mode.
;   8 - Reserved for future use.
;  16 - Prevent rows from being appended if an existing row has the same value in 'MatchCol'. *
;  32 - Append columns from the table to the listview if the column isn't already in the listview.
;  64 - Remove columns from the listview if the table does not contain that column.
; 128 - Use the table's first row as column options (see 'LV_ModifyCol()' in the AHK manual).
; 256*X - Force the 'X'th listview column to be used as the match column.
; (*) NOTE: When using a match column, the listview's header must contain a column with the same
; NAME as the table's match column, unless the 256*X modifier is used in the mode.
; If the function encounters a problem, the return value is blank, otherwise, this function's return
; value is the number of listview rows effected.
; NOTE: When loading a table into a listview, it is recommended to turn off the listview's redraw
; using 'GuiControl, -Redraw' prior to loading the table and turn it back on afterwards. This is
; particularly advisable if the table contains more than 100 cells, since each cell is copied into
; the listview individually.
; NOTE: It is also advisable to disable the listview header while inserting data to prevent
; user-interaction from interfering with the process. Use 'GuiControl, +NoSort,...' for this.
; NOTE: Update for version 0.17: if the table has the column 'LV Row Options' (NOT case sensitive),
; the contents of that column are used as the row options for each row ADDED OR UPDATED.

	; Bake the mode
	optcol := !( Mode & 128 )
	remcol := !( Mode & 64 )
	addcol := !( Mode & 32 )
	nodupe := !( Mode & 16 )
	lvMatchCol := Mode >> 8
	Mode &= 7
	rowcount := 0
	cell_0 := cell_0x0 := ""
	oel := ErrorLevel
	; Initialize match lists (even if they won't get used)
	psl := pcl := dpl := "`n"

	Loop, Parse, Table, `n, `r ; Get the table's header
		If ( A_Index = 1 )
		{
			StringReplace, Header, A_LoopField, % "`t", % "`t", UseErrorLevel
			ColCount := ErrorLevel, Header := "`t" Header "`t"
			If Asc( MatchCol ) != 9
			{
				StringLeft, MatchCol, Header, InStr( Header, "`t" MatchCol "`t" )
				StringReplace, MatchCol, MatchCol, % "`t", % "`t", UseErrorLevel
				MatchCol := ErrorLevel - 1
			}
			Else MatchCol := Round( SubStr( MatchCol, 2 ) ) - 1
			If ( MatchCol < 0 ) || ( ColCount < MatchCol )
				Return "", ErrorLevel := oel ; Error: invalid column specified

			StringGetPos, pos, A_LoopField, % "`t", L%MatchCol%
			StringTrimLeft, Column, A_LoopField, pos + 1
			StringLeft, Column, Column, InStr( Column "`t", "`t" ) - 1

			; Get the listview's header and determine the listview's match column
			lvHeader := "`t"
			Loop % lvhlen := LV_GetCount( "Column" )
				If LV_GetText( vxe, 0, A_Index )
				{
					lvHeader .= vxe "`t"
					If !( lvMatchCol ) && ( vxe = Column )
						lvMatchCol := A_Index
				}

			If ( lvMatchCol < 1 || lvhlen < lvMatchCol )
			&& ( !nodupe || Mode = 2 || Mode = 3 || Mode = 4 || Mode = 5 || Mode = 7 )
				Return "", ErrorLevel := oel ; Error: listview matchcol not found.

			; Do we have to preserve selections?
			If !( ps := ( Mode != 2 && Mode != 4 ) )
				Loop
					If !ps := LV_GetNext( ps )
						Break
					Else If LV_GetText( vxe, ps, lvMatchCol )
						psl .= vxe "`n"

			; Do we have to preserve checkmarks?
			If !( pc := ( Mode != 3 && Mode != 4 ) )
				Loop
					If !pc := LV_GetNext( pc, "C" )
						Break
					Else If LV_GetText( vxe, pc, lvMatchCol )
						pcl .= vxe "`n"

			; If we're doing a full overwrite, delete all the rows before fussing with columns
			If ( Mode = 1 || Mode = 2 || Mode = 3 || Mode = 4 )
				LV_Delete() ; Delete all rows
			Else Loop % LV_GetCount() ; otherwise, get a full list of matchcol values
				If LV_GetText( vxe, A_Index, lvMatchCol )
					dpl .= vxe "`n"

			; See if we have to remove listview columns
			If !( remcol )
			{
				vxe := ""
				Loop, Parse, lvHeader, % "`t"
					If ( A_LoopField != "" ) && !InStr( Header, "`t" A_LoopField "`t" )
						vxe .= ( A_Index - 1 ) "`n"
				StringTrimRight, vxe, vxe, 1
				Sort, vxe, R N
				Loop, Parse, vxe, `n
					If LV_DeleteCol( A_LoopField ) && ( remcol -= 1 )
						StringReplace, lvHeader, lvHeader, % "`t" . A_LoopField . "`t", % "`t"
			}

			; See if we have to add columns to the listview.
			If !( addcol ) ; Columns added here have a default width of 9 * length.
				Loop, Parse, A_LoopField, % "`t"
					If !InStr( lvHeader, "`t" A_LoopField "`t" )
					&& LV_InsertCol( 255, 9 * StrLen( A_LoopField ), A_LoopField )
					&& ( addcol -= 1 )
						lvHeader .= A_LoopField . "`t"

			; Generate the column index mapping to match the table columns with the listview columns
			Loop, Parse, A_LoopField, % "`t"
			{
				Table_ToListview_ColumnMap_%A_Index% := 0 - ( A_LoopField = "LV Row Options" )
				StringGetPos, vxe, lvHeader, % "`t" A_LoopField "`t"
				If ( 0 != Table_ToListview_ColumnMap_%A_Index% || ErrorLevel )
					Continue
				StringLeft, vxe, lvHeader, vxe + 1
				StringReplace, vxe, vxe, % "`t", % "`t", UseErrorLevel
				Table_ToListview_ColumnMap_%A_Index% := ErrorLevel
			}
			MatchCol += 1
		}
		Else If !( optcol ) && ( A_Index = 2 ) ; see if row 1 contains column options
		{
			Loop, Parse, A_LoopField, % "`t"
				If ( Table_ToListview_ColumnMap_%A_Index% )
					LV_ModifyCol( Table_ToListview_ColumnMap_%A_Index%, A_LoopField )
			optcol := 1
		}
		Else If !( Mode )
			Return 0
		Else ; Now start handling table rows
		{
			Loop, % ColCount + 1
				Table_ToListview_Cell_%A_Index% := ""

			; Split the table row into cells
			Loop, Parse, A_LoopField, % "`t"
				Table_ToListview_Cell_%A_Index% := A_LoopField

			; try to find an existing row to update in the listview
			If ( Mode = 5 || Mode = 7 ) && ( row := InStr( dpl, "`n" Table_ToListview_Cell_%MatchCol% "`n" ) )
			{
				StringLeft, vxe, dpl, row
				StringReplace, vxe, vxe, `n, `n, UseErrorLevel
				row := ErrorLevel
			} ; otherwise, add a row ( checking for duplicates if they're not allowed )
			Else If ( Mode != 5 ) && ( nodupe || !InStr( dpl, "`n" Table_ToListview_Cell_%MatchCol% "`n" ) )
				row := LV_Add( ( !ps && InStr( psl, "`n" Table_ToListview_Cell_%MatchCol% "`n" ) ? "+Select " : "" )
					. ( !pc && InStr( pcl, "`n" Table_ToListview_Cell_%MatchCol% "`n" ) ? "+Check " : "" ) )
			Else Continue ; we couldn't find or add a listview row, so skip this row

			Loop, % ColCount + 1 ; load the table cell text into the listview according to the map
				If ( 0 < Table_ToListview_ColumnMap_%A_Index% )
					LV_Modify( row, "Col" Table_ToListview_ColumnMap_%A_Index%, Table_ToListview_Cell_%A_Index% )
				Else If ( -1 = Table_ToListview_ColumnMap_%A_Index% )
					LV_Modify( row, Table_ToListview_Cell_%A_Index% )
			dpl .= Table_ToListview_Cell_%MatchCol% "`n"
			rowcount += 1 ; increment count of modified rows
		}
	Return rowcount, ErrorLevel := oel
} ; Table_ToListview( Table, Mode=7, MatchCol="`t1" ) ----------------------------------------------

Table_ToLvHWND( HWND, Table, MODE=9, matchcol="`t1" ) { ; -----------------------------------------------------
/* Similar to Table_ToListview, this function modifies a listview (whose handle is passed as 'HWND') based on
   the input table. This function can ONLY work on listviews inside the script's own guis.
MODE: basic behavior, lowest 3 bits:
  0 = The listview's rows are not changed directly (adding or removing columns will change parts of each row).
  1 = Add table rows to the listview
  2 = Update listview rows that match at least one row in the table. *
  3 = Update listview rows where matches are found, otherwise add table rows to the listview *
  4 = Overwrite the entire listview without preserving selected or checked rows
  5 = Overwrite the entire listview, preserving selected rows *
  6 = Overwrite the entire listview, preserving checked rows *
  7 = Overwrite the entire listview, preserving selected and checked rows *
MODE: bits 4 to 8
     +8 = The table contains one or more columns named '_::icon::' ('_' is the name of the intended column). **
    +16 = Prevent rows from being added if a row already in the listview has a matching value *
    +32 = Add table columns to the listview if necessary
    +64 = Delete columns from the listview if they don't appear in the table
   +128 = Reserved.
MODE: bits 9 to 16
 +256*X = Force the 'X'th listview column to be used as the match column.

(*) - the matching is performed using one column in the table (indicated by the 'matchcol' parameter) and one
	column in the listview (by default, the one with the same name as the table's matchcol, 1 otherwise).
	An equal value in both columns represents a matching row.
(**) - For a listview to display icons, it MUST have an image list (see the AHK manual). For columns other than
	the first to display icons, the listview MUST have the extended style LVS_EX_SUBITEMIMAGES (+E0x2).
*/

	Static iuc, w_a, psz, ptr, pid, bufs := 8191, DW := "UInt", WM_ENABLE = 9, WM_SETREDRAW = 11
, LVM_GETITEMCOUNT		= 0x1004
, LVM_SETITEM			= 0x1006
, LVM_INSERTITEM
, LVM_DELETEALLITEMS	= 0x1009
, LVM_INSERTCOLUMN
, LVM_DELETECOLUMN		= 0x101C
, LVM_SETCOLUMNWIDTH	= 0x101E
, LVM_GETHEADER		= 0x101F
, LVM_SETITEMSTATE		= 0x102B
, LVM_GETITEMSTATE		= 0x102C
, LVM_SETITEMTEXT
, LVM_SETITEMCOUNT		= 0x102F
, LVM_GETITEMTEXT
, HDM_GETITEMCOUNT		= 0x1200
, HDM_GETITEM

	oel := ErrorLevel

; Initialize statics
	If !psz
	{
		iuc := A_IsUnicode = 1
		w_a := iuc ? "W" : "A"
		psz := A_PtrSize = "" ? 4 : A_PtrSize
		ptr := A_PtrSize = "" ? DW : "Ptr"
		Process, Exist
		pid := ErrorLevel
		HDM_GETITEM 		:= iuc ? 0x120B : 0x1203
		LVM_GETITEMTEXT 	:= iuc ? 0x1073 : 0x102D
		LVM_INSERTCOLUMN 	:= iuc ? 0x1061 : 0x101B
		LVM_INSERTITEM 	:= iuc ? 0x104D : 0x1007
		LVM_SETITEMTEXT 	:= iuc ? 0x1074 : 0x102E
	}

; Verify that the HWND points to a listview control AND it has a header AND it is owned by this script.
	VarSetCapacity( item, 128 << iuc, 0 )
	If !DllCall( "GetClassName" w_a, ptr, hwnd, "Str", item, DW, 127 ) || ( item != "SysListView32" )
	|| !DllCall( "GetWindowThreadProcessId", ptr, hwnd, DW "*", pos := 0 ) || ( pos != pid )
	|| !( hdrh := DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETHEADER, Ptr, 0, Ptr, 0 ) )
		Return "", ErrorLevel := oel

	listview_width := DllCall( "SendMessage", Ptr, hdrh, DW, HDM_GETITEMCOUNT, Ptr, 0, Ptr, 0 )
	Winget, listview_style, Style, AHK_ID %hwnd%
	If StrLen( Table ) < 256
		listview_style &= ~0x10000000
;	listview_style := DllCall( "GetWindowLong", Ptr, hdrh, DW, -16 )

; decode the mode
	state_mask := ( mode & 5 = 5 ? 0xF000 : 0 ) | ( mode & 6 = 6 ? 2 : 0 )
	do_overwrite := 3 < mode & 7
	do_addrows := do_overwrite || mode & 1
	do_update := mode & 6 = 2
	do_icons := 0 < mode & 8
	do_unique := 0 < mode & 16
	do_addcols := 0 < mode & 32
	do_delcols := 0 < mode & 64 ? listview_width : 0
	mode := ( mode >> 8 ) & 255

	StringReplace, Table, Table, `r`n, `n, A
	Loop, Parse, Table, `n
		If ( A_Index = 1 ) ; The start of the big main parsing loop
		{
; Prep the HDITEM struct and the buffer we'll use for the header's text
	VarSetCapacity( bufr, bufs + 1 << iuc, 0 )
	NumPut( 2, item, 0, DW )
	NumPut( &bufr, item, 8, Ptr )
	NumPut( bufs, item, 8 + 2 * psz, DW )

; Get the header control's handle, number of columns, and header items text.
	VarSetCapacity( header_text, listview_width << 4 + iuc, 0 )
	header_text := "`t"
	Loop % listview_width
	{
		DllCall( "SendMessage", Ptr, hdrh, DW, HDM_GETITEM, Ptr, A_Index - 1, Ptr, &item )
		VarSetCapacity( bufr, -1 ), header_text .= bufr "`t"
	}

; Map table columns to their listivew counterparts and find the matchcols.
	StringReplace, bufr, A_LoopField, % "`t", % "`t", UseErrorLevel
	table_width := ErrorLevel + 1
	VarSetCapacity( cmap, listview_width + table_width << 2, 0 )
	Loop, Parse, A_LoopField, % "`t"
	{
		If ( A_LoopField = matchcol )
			matchcol := "`t" A_Index

		pos := do_icons && SubStr( A_LoopField, -7 ) = "::icon::"
		StringTrimRight, bufr, A_LoopField, 8 * pos
		If ( bufr := InStr( header_text, "`t" bufr "`t" ) )
		{
			StringLeft, bufr, header_text, bufr + 0
			StringReplace, bufr, bufr, % "`t", % "`t", UseErrorLevel
			NumPut( ErrorLevel, cmap, ( A_Index - 1 << 2 ) + pos, "UChar" )
			NumPut( A_Index, cmap, ( ErrorLevel - 1 << 2 ) + 2, "UShort" )
		}
	}
	matchcol := Round( SubStr( matchcol, Asc( matchcol ) = 9 ? 2 : 1 ) ) - 1
	mode := mode ? mode : NumGet( cmap, matchcol << 2, "UChar" )

; If we need to preserve or update anything, make a list of all listview items' matchvals and their states.
	If ( 0 < state_mask || do_update || do_unique )
		If ( mode )
		{
			VarSetCapacity( bufr, bufs + 1 << iuc, 0 )
			NumPut( mode - 1, item, 8, DW ) ; iSubItem
			NumPut( &bufr, item, 16 + psz, Ptr ) ; pszText
			NumPut( bufs, item, 16 + psz * 2, DW ) ; cchTextMax
			pos := DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETITEMCOUNT, Ptr, 0, Ptr, 0 )
			VarSetCapacity( matchcol_values, pos << 4 + iuc, 0 )
			matchcol_values := "`n"
			If ( state_mask )
			{
				VarSetCapacity( mcrs, pos << 1, 0 )
				Loop % pos
				{
					NumPut( DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETITEMSTATE, Ptr, A_Index - 1, Ptr, state_mask ), mcrs, A_Index - 1 << 1, "UShort" )
					DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETITEMTEXT, Ptr, A_Index - 1, Ptr, &item )
					VarSetCapacity( bufr, -1 ), matchcol_values .= bufr "`n"
				}
			}
			Else
				Loop % pos
				{
					DllCall( "SendMessage", Ptr, hwnd, DW, LVM_GETITEMTEXT, Ptr, A_Index - 1, Ptr, &item )
					VarSetCapacity( bufr, -1 ), matchcol_values .= bufr "`n"
				}
			do_unique := do_unique ? pos : 0
		}
		Else Return "", ErrorLevel := oel ; Error: invlid matchcol. operation requires matchcol.

; Here we want to freeze the listview to reduce the risk of misalignment.

	If !( listview_style & 0x08000000 )
		DllCall( "SendMessage", Ptr, hwnd, DW, WM_ENABLE, Ptr, 0, Ptr, 0 )
	If ( listview_style & 0x10000000 )
		DllCall( "SendMessage", Ptr, hwnd, DW, WM_SETREDRAW, Ptr, 0, Ptr, 0 )

	If ( do_overwrite )
		DllCall( "SendMessage", Ptr, hwnd, DW, LVM_DELETEALLITEMS, Ptr, 0, Ptr, 0 )

; Take care of any listview column deletions by walking backwards through the match list.
	Loop % do_delcols
		If !NumGet( cmap, ( --do_delcols << 2 ) + 2, "UShort" )
		{
			StringGetPos, pos, header_text, % "`t", % "L" do_delcols + 1
			header_text := SubStr( header_text, 1, pos + 1 ) SubStr( header_text, 1 + InStr( header_text, "`t", 0, pos + 2 ) )
			DllCall( "SendMessage", Ptr, hwnd, DW, LVM_DELETECOLUMN, Ptr, do_delcols, Ptr, 0 )
			listview_width -= 1
		}

; Add columns by traversing the header row. Where a table column does not have a listview match, add it.
	If ( do_addcols )
	{
		NumPut( 4, item, 0, DW ) ; mask: LVCF_TEXT = 4
		mode := -1
		do_addcols := listview_width
		Loop, Parse, A_LoopField, % "`t"
			If !NumGet( cmap, A_Index - 1 << 2, "UShort" ) && ( !do_icons || SubStr( A_LoopField, -7 ) != "::icon::" )
			{
				NumPut( &Table + ( ++mode << iuc ), item, 12, ptr )
				mode += StrLen( A_LoopField )
				NumPut( 0, Table, mode << iuc, "UChar" )
				header_text .= A_LoopField "`t"
				DllCall( "SendMessage", Ptr, hwnd, DW, LVM_INSERTCOLUMN, Ptr, ++listview_width + 1, Ptr, &item )
			}
			Else table_offset += 1 + StrLen( A_LoopField )

		Loop % listview_width - do_addcols ; provide a little width for new columns
			DllCall( "SendMessage", Ptr, hwnd, DW, LVM_SETCOLUMNWIDTH, Ptr, do_addcols + A_Index - 1, Ptr, -2 )
	}

	If !( do_addrows || do_update )
		Break

; re-generate the column index map
	VarSetCapacity( cmap, listview_width + table_width << 2, 0 )
	Loop, Parse, A_LoopField, % "`t"
	{
		pos := do_icons && SubStr( A_LoopField, -7 ) = "::icon::"
		StringTrimRight, bufr, A_LoopField, 8 * pos
		If ( bufr := InStr( header_text, "`t" bufr "`t" ) )
		{
			StringLeft, bufr, header_text, bufr + 0
			StringReplace, bufr, bufr, % "`t", % "`t", UseErrorLevel
			NumPut( ErrorLevel, cmap, ( A_Index - 1 << 2 ) + pos, "UChar" )
			NumPut( A_Index, cmap, ( ErrorLevel - 1 << 2 ) + 2, "UShort" )
		}
	}

	StringLen, mode, A_LoopField
	NumPut( 0, item, 12, DW ) ; State
	NumPut( 0xF002, item, 16, DW ) ; StateMask

		}
		Else ; belongs to "If ( A_Index = 1 )" at the top of the bog main parsing loop
		{

	If ( pos := state_mask || do_update || do_unique )
	{
; If we're using some of the listview's previous data, look for the matching row index.
		If ( 0 < matchcol )
		{
			StringGetPos, pos, A_LoopField, % "`t", % "L" matchcol
			StringMid, bufr, A_LoopField, pos + 2, InStr( A_LoopField "`t", "`t", 0, pos + 2 ) - pos - 2
		}
		Else StringLeft, bufr, A_LoopField, InStr( A_LoopField "`t", "`t" ) - 1

		pos := InStr( matchcol_values, "`n" bufr "`n" )

		If ( do_unique )
			matchcol_values .= bufr "`n"

		If ( pos )
		{
			StringLeft, bufr, matchcol_values, pos
			StringReplace, bufr, bufr, % "`n", % "`n", UseErrorLevel
			pos := ErrorLevel
		}
	}

	If !( do_update && pos ) && do_addrows && !( do_unique && pos && !( do_overwrite && do_unique < pos ) )
	{
; Add a new row to the listview, making its first item blank.
		NumPut( 1, item, 0, DW )
		NumPut( 2147483647, item, 4, DW ) ; iItem
		NumPut( 0, item, 8, DW ) ; iSubItem
		NumPut( &item + 120, item, 16 + psz, Ptr )
		If ( state_mask && pos )
		{
			NumPut( NumGet( mcrs, pos - 1 << 1, "UShort" ), item, 12, DW )
			pos := 1 + DllCall( "SendMessage", Ptr, hwnd, DW, LVM_INSERTITEM, Ptr, 0, Ptr, &item )
			DllCall( "SendMessage", Ptr, hwnd, DW, LVM_SETITEMSTATE, Ptr, pos - 1, Ptr, &item )
		}
		Else
			pos := 1 + DllCall( "SendMessage", Ptr, hwnd, DW, LVM_INSERTITEM, Ptr, 0, Ptr, &item )
	}
	NumPut( pos - 1, item, 4, DW ) ; iItem


	If !pos ; skip this table row because there is no matching listview row.
	{
		mode += 1 + StrLen( A_LoopField )
	}
	Else If ( A_LoopField = "" ) ; this row is blank
	{
		mode += 1
		NumPut( NumGet( cmap, 0, "UChar" ) - 1, item, 8, DW )
		NumPut( &item + 120, item, 16 + psz, Ptr )
		DllCall( "SendMessage", Ptr, hwnd, DW, LVM_SETITEMTEXT, Ptr, do_delcols - 1, Ptr, &item )
	}
	Else
		Loop, Parse, A_LoopField, % "`t"
			If ( 255 < do_addcols := NumGet( cmap, A_Index - 1 << 2, "UShort" ) ) ; it's an icon column
			{
				mode += 1 + StrLen( A_LoopField )
				NumPut( 2, item, 0, DW )
				NumPut( do_addcols - 256 >> 8, item, 8, DW )
				NumPut( Round( A_LoopField ) - 1, item, 20 + psz * 2, DW )
				DllCall( "SendMessage", Ptr, hwnd, DW, LVM_SETITEM, Ptr, 0, Ptr, &item )
			}
			Else If ( do_addcols ) ; it's a text column
			{
				NumPut( do_addcols - 1, item, 8, DW ) ; iSubItem
				mode += 1
				NumPut( &Table + ( mode << iuc ), item, 16 + psz, Ptr )
				mode += StrLen( A_LoopField )
				NumPut( 0, Table, mode << iuc, "UChar" )
				DllCall( "SendMessage", Ptr, hwnd, DW, LVM_SETITEMTEXT, Ptr, pos - 1, Ptr, &item )
			}
			Else
				mode += 1 + StrLen( A_LoopField )
		} ; The end of the 'else' of the big parsing loop

	If !( listview_style & 0x08000000 )
		DllCall( "SendMessage", Ptr, hwnd, DW, WM_ENABLE, Ptr, 1, Ptr, 0 )
	If ( listview_style & 0x10000000 )
		DllCall( "SendMessage", Ptr, hwnd, DW, WM_SETREDRAW, Ptr, 1, Ptr, 0 )
		, DllCall( "InvalidateRect", Ptr, hwnd, Ptr, 0, DW, 0 )
	Return mode, ErrorLevel := oel
} ; Table_ToLvHWND( HWND, Table, MODE=9, matchcol="`t1" ) -----------------------------------------------------

Table_Transpose( Table ) { ; ----------------------------------------------------------------------------------
; Flips a table along its main diagonal. The leftmost column header remains in the same position.
; For those who wonder what the difference between "invert" and "transpose" is, there is no difference.
; Tables are NOT matrices. A table defines an algebraic function for relationships between related data.
; In other words, each data item in a table can be referenced by it's row and column. Inverting the table
; means swapping the identifying row and column for every item in the table. For example, if "c" were any one
; cell in a table, the table defines a function "c = T(a,b)" where a and b are within the table's bounds.
; The INVERSE of this function is then "c = T(b,a)", hence 'invert'ing the table.
	Loop, Parse, Table, `n, `r
		If ( 1 = B_Index := A_Index )
			Loop, Parse, A_LoopField, % "`t"
				Table_RotateL__Cell_%B_Index%_%A_Index% := A_LoopField, C_Index := A_Index
		Else
			Loop, Parse, A_LoopField, % "`t"
				Table_RotateL__Cell_%B_Index%_%A_Index% := A_LoopField
	Loop, % C_Index
		Loop, % B_Index + 0 * ( C_Index := A_Index )
			If ( A_Index = 1 && C_Index = 1 )
				Table := Table_RotateL__Cell_%A_Index%_%C_Index%
			Else
				Table .= ( A_Index = 1 ? "`n" : "`t" ) Table_RotateL__Cell_%A_Index%_%C_Index%
	Return Table
} ; Table_Transpose( Table ) ----------------------------------------------------------------------------------

Table_Update( TableA, TableB, MatchColA="`t1", MatchColB="" ) { ; ----------------------------------
; For each row in TableA that has a value in 'MatchColA's column that matches a value in TableB's
; 'MatchColB's column, the cell values in that row in TableB are copied into the cells of the row
; in TableA that have matcing column names.
; NOTE: If two or more rows in TableB have the same match value, then EVERY row in TableA that
; matches that value will be updated with the data in the TOPMOST MATCHING ROW from TableB.

	oel := ErrorLevel, ColMatches := ""
	Loop, Parse, TableA, `n, `r
		If ( A_Index = 1 )
		{ ; handle the table headers for all matching columns
			HeaderA := A_LoopField
			Loop, Parse, TableB, `n, `r
				If !( BLen := A_Index - 1 )
				{
					TableB := "`t" A_LoopField "`t"
					isx := Asc( MatchColA ) = 9
					Loop, Parse, HeaderA, % "`t"
					{
						If ( AWid := A_Index ) && ( isx != "" )
						&& ( isx ? ( SubStr( MatchColA, 2 ) = A_Index ) : ( MatchColA = A_LoopField ) )
							MatchColA := A_Index, isx := ""
						If ( pos := InStr( TableB, "`t" A_LoopField "`t" ) )
						{
							StringLeft, pos, TableB, pos
							StringReplace, pos, pos, % "`t", % "`t", UseErrorLevel
							ColMatches .= ErrorLevel "`n" A_Index "`n"
						}
					}
					If ( isx != "" )
						Return TableA, ErrorLevel := oel ; Error: MatchColA not found
					If ( MatchColB = "" ) ; default to MatchColA's name
						{
							MatchColB := "`t" HeaderA
							StringGetPos, pos, MatchColB, % "`t", L%MatchColA%
							StringTrimLeft, MatchColB, MatchColB, pos + 1
							StringLeft, MatchColB, MatchColB, InStr( MatchColB "`t", "`t" ) - 1
						}
					If Asc( MatchColB ) != 9
					{
						StringLeft, MatchColB, TableB, InStr( TableB, "`t" MatchColB "`t" )
						StringReplace, MatchColB, MatchColB, % "`t", % "`t", UseErrorLevel
						MatchColB := ErrorLevel
					}
					Else MatchColB := Round( SubStr( MatchColB, 2 ) )
					StringReplace, TableB, TableB, % "`t", % "`t", UseErrorLevel
					If ( MatchColB < 1 || ErrorLevel - 1 < MatchColB )
						Return TableA, ErrorLevel := oel ; Error: MatchColB not found
					TableB := "`n"
				}
				Else Loop, Parse, A_LoopField, % "`t"
					{
						Table_Update_Cell_%BLen%_%A_Index% := A_LoopField
						If ( A_Index = MatchColB )
							TableB .= A_LoopField "`n"
					}
			TableA := A_LoopField
		}
		Else
		{
			Loop, Parse, A_LoopField, % "`t"
				Table_Update_Cell_%A_Index% := A_LoopField

			StringGetPos, pos, TableB, % "`n" Table_Update_Cell_%MatchColA% "`n"
			If !( ErrorLevel )
			{
				StringLeft, HeaderA, TableB, pos + 1
				StringReplace, HeaderA, HeaderA, `n, `n, UseErrorLevel
				pos := ErrorLevel
				StringReplace, BMatches, BMatches, % "`n" pos "`n", `n
				Loop, Parse, ColMatches, `n
					If ( A_Index & 1 )
						isx := A_LoopField
					Else	If ( A_LoopField != MatchColA ) && ( isx != MatchColB )
						Table_Update_Cell_%A_LoopField% := Table_Update_Cell_%pos%_%isx%
			}

			Loop %AWid%
			{
				TableA .= ( A_Index = 1 ? "`n" : "`t" ) Table_Update_Cell_%A_Index%
				Table_Update_Cell_%A_Index% := ""
			}
		}
	Return TableA, ErrorLevel := oel
} ; Table_Update( TableA, TableB, MatchColA="`t1", MatchColB="" ) ----------------------------------

Table_UpdateAppend( TableA, TableB, MatchColA="`t1", MatchColB="" ) { ; ----------------------------
; For each row in TableA that has a value in 'MatchColA's column that matches a value in TableB's
; 'MatchColB's column, the cell values in that row in TableB are copied into the cells of the row
; in TableA that have matcing column names. Rows in TableB that don't have a match in TableA are
; appended to TableA and rows in TableA that don't have a match are left unchanged. The output
; table's header is the same as TableA's header.
; NOTE: If two or more rows in TableB have the same match value, then EVERY row in TableA that
; matches that value will be updated with the data in the TOPMOST MATCHING ROW from TableB.

	oel := ErrorLevel, BMatches := "`n", ColMatches := "", isx := Asc( MatchColA ) = 9
	Loop, Parse, TableA, `n, `r
		If ( A_Index = 1 )
		{ ; handle the table headers for all matching columns
			HeaderA := A_LoopField
			Loop, Parse, TableB, `n, `r
				If !( BLen := A_Index - 1 )
				{
					TableB := "`t" A_LoopField "`t"
					Loop, Parse, HeaderA, % "`t"
					{
						If ( AWid := A_Index ) && ( isx != "" )
						&& ( isx ? ( SubStr( MatchColA, 2 ) = A_Index ) : ( MatchColA = A_LoopField ) )
							MatchColA := A_Index, isx := ""
						If ( pos := InStr( TableB, "`t" A_LoopField "`t" ) )
						{
							StringLeft, pos, TableB, pos
							StringReplace, pos, pos, % "`t", % "`t", UseErrorLevel
							ColMatches .= ErrorLevel "`n" A_Index "`n"
						}
					}
					If ( MatchColB = "" ) ; default to MatchColA's name
						{
							MatchColB := "`t" HeaderA
							StringGetPos, pos, MatchColB, % "`t", L%MatchColA%
							StringTrimLeft, MatchColB, MatchColB, pos + 1
							StringLeft, MatchColB, MatchColB, InStr( MatchColB "`t", "`t" ) - 1
						}
					If Asc( MatchColB ) != 9
					{
						StringLeft, MatchColB, TableB, InStr( TableB, "`t" MatchColB "`t" )
						StringReplace, MatchColB, MatchColB, % "`t", % "`t", UseErrorLevel
						MatchColB := ErrorLevel
					}
					Else MatchColB := Round( SubStr( MatchColB, 2 ) )
					StringReplace, TableB, TableB, % "`t", % "`t", UseErrorLevel
					If ( MatchColB < 1 || ErrorLevel - 1 < MatchColB )
						Return TableA, ErrorLevel := oel ; Error: MatchColB not found
					TableB := "`n"
				}
				Else Loop, Parse, A_LoopField, % "`t"
					{
						Table_UpdateAppend_Cell_%BLen%_%A_Index% := A_LoopField
						If ( A_Index = MatchColB )
							TableB .= A_LoopField "`n", BMatches .= BLen "`n"
					}
			If ( isx != "" )
				Return TableA, ErrorLevel := oel ; Error: MatchColA not found
			TableA := A_LoopField
		}
		Else
		{
			Loop, Parse, A_LoopField, % "`t"
				Table_UpdateAppend_Cell_%A_Index% := A_LoopField

			StringGetPos, pos, TableB, % "`n" Table_UpdateAppend_Cell_%MatchColA% "`n"
			If !( ErrorLevel )
			{
				StringLeft, HeaderA, TableB, pos + 1
				StringReplace, HeaderA, HeaderA, `n, `n, UseErrorLevel
				pos := ErrorLevel
				StringReplace, BMatches, BMatches, % "`n" pos "`n", `n
				Loop, Parse, ColMatches, `n
					If ( A_Index & 1 )
						isx := A_LoopField
					Else	If ( A_LoopField != MatchColA ) && ( isx != MatchColB )
						Table_UpdateAppend_Cell_%A_LoopField% := Table_UpdateAppend_Cell_%pos%_%isx%
			}

			Loop %AWid%
			{
				TableA .= ( A_Index = 1 ? "`n" : "`t" ) Table_UpdateAppend_Cell_%A_Index%
				Table_UpdateAppend_Cell_%A_Index% := ""
			}
		}
		StringTrimLeft, BMatches, BMatches, 1
		StringTrimRight, BMatches, BMatches, 1
		Loop, Parse, BMatches, `n
		{
			pos := A_LoopField
			Loop, Parse, ColMatches, `n
				If ( A_Index & 1 )
					isx := A_LoopField
				Else	Table_UpdateAppend_Cell_%A_LoopField% := Table_UpdateAppend_Cell_%pos%_%isx%
			Loop %AWid%
				TableA .= ( A_Index = 1 ? "`n" : "`t" ) Table_UpdateAppend_Cell_%A_Index%
		}
	Return TableA, ErrorLevel := oel
} ; Table_UpdateAppend( TableA, TableB, MatchColA="`t1", MatchColB="" ) ----------------------------

Table_Width( Table ) { ; ---------------------------------------------------------------------------
; Returns the number of columns in the table, which is the number of tab characters in the header
; plus one. If 'Table' is blank, or the first character is a newline, this function returns zero.
	oel := ErrorLevel, Table .= "`n"
	StringGetPos, pos, Table, `n
	StringLeft, Table, Table, pos
	If ( Table = "" || Table = "`r" )
		Return 0
	StringReplace, Table, Table, % "`t", % "`t", UseErrorLevel
	Return ErrorLevel + 1, ErrorLevel := oel
} ; Table_Width( Table ) ---------------------------------------------------------------------------