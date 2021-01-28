ExtractTableData( FilePath, HeadingsArray, Delimiter, SaveDir )
{
	static htmObj

	if !IsObject( htmObj )
		htmObj := ComObjCreate( "HTMLfile" )
	else
		htmObj.Close()

	tablesArray			:= {}
	tablesDataArray		:= {}

	FileRead, HTML, % FilePath
	htmObj.Write( HTML )
	tablesCollection 	:= htmObj.getElementsByTagName( "table" )
	tablesCount 		:= tablesCollection.length

	For Each, Value in HeadingsArray
	{
		tableNumber 	:= 0
		HeadingName 	:= Each
		HeadingNumbers	:= Value.1
		RowNumbers 		:= Value.2

		loop % tablesCount
		{
			tableObj := tablesCollection[ a_index-1 ]


			if InStr( tableObj.innerText, HeadingName )
			{

				tableNumber++
				tableBodyObj 	 			:= tableObj.getElementsByTagName( "tbody" )
				tableColumnHeadingObj		:= tableBodyObj[ 0 ].firstChild.getElementsByTagName( "th" )
				tableRowObj 	 			:= tableBodyObj[ 0 ].getElementsByTagName( "tr" )

				tableCaption 				:= tableBodyObj[ 0 ].previousSibling.innerText

				tableColumnHeadingCount 	:= tableColumnHeadingObj.length
				tableDataRowCount 	 		:= tableRowObj.length-1 ; table data rows minus the heading row

				loop % tableColumnHeadingCount
				{
					tableColumnHeadingValue := tableColumnHeadingObj[ a_index-1 ].innerText
					columnNumber 			:= a_index-1

					if ( tableColumnHeadingValue ~= "^" HeadingName )
					{
						loop % tableDataRowCount
						{
							tableDataObj 		:= tableRowObj[ a_index ].getElementsByTagName( "td" ) 
							tableData 			:= tableDataObj[ columnNumber ].innerText

							tablesArray[ RegExReplace( Trim( tableColumnHeadingValue ), "\W", "_" ), tableNumber, a_index ] := { tableData: tableData, tableCaption : tableCaption }
						}
					}
				}
			}
		}

		HeadingName := RegExReplace( HeadingName, "\W", "_" )

		if !( HeadingNumbers.length() || IsObject( HeadingNumbers ) || RowNumbers.length() || IsObject( RowNumbers ) )
		{
			tableCaption 	 := tablesArray[ HeadingName ][ HeadingNumbers ][ RowNumbers ].tableCaption
			tableArrayValue  := tablesArray[ HeadingName ][ HeadingNumbers ][ RowNumbers ].tableData
			tablesDataString .= ( tableArrayValue != "" ? tableCaption " ~ " HeadingName ": " tableArrayValue Delimiter : "" )
		}
		else if ( HeadingNumbers.length() || IsObject( HeadingNumbers ) ) && !(  RowNumbers.length() || IsObject( RowNumbers ) )
 		{
			For i in HeadingNumbers
			{
				tableCaption  	 := tablesArray[ HeadingName ][ i ][ RowNumbers ].tableCaption				
				tableArrayValue  := tablesArray[ HeadingName ][ i ][ RowNumbers ].tableData
				tablesDataString .= ( tableArrayValue != "" ? tableCaption " ~ " HeadingName ": " tableArrayValue Delimiter : "" )	
			}
		} 	
		else if !( HeadingNumbers.length() || IsObject( HeadingNumbers ) ) && (  RowNumbers.length() || IsObject( RowNumbers ) )
		{
			For i in RowNumbers
			{
				tableCaption  	 := tablesArray[ HeadingName ][ HeadingNumbers ][ i ].tableCaption			
				tableArrayValue  := tablesArray[ HeadingName ][ HeadingNumbers ][ i ].tableData
				tablesDataString .= ( tableArrayValue != "" ? tableCaption " ~ " HeadingName ": " tableArrayValue Delimiter : "" )
			}
		}
		else if ( HeadingNumbers.length() || IsObject( HeadingNumbers ) ) && (  RowNumbers.length() || IsObject( RowNumbers ) )
		{
			For h in HeadingNumbers
			{
				For r in RowNumbers
				{
					tableCaption  	 := tablesArray[ HeadingName ][ h ][ r ].tableCaption				
					tableArrayValue  := tablesArray[ HeadingName ][ h ][ r ].tableData
					tablesDataString .= ( tableArrayValue != "" ? tableCaption " ~ " HeadingName ": " tableArrayValue Delimiter : "" )
				}
			}
		}
	}

	SplitPath, % FilePath, FileNameExt,,, FileName

	if !StrLen( tablesDataString )
	{
		Msgbox 0x10, Whoops!, % "No Table Data Found in: " FileNameExt
		return true
	}
	else 
	{
		SaveFile := SaveDir "\" FileName ".txt"
		if FileExist( SaveFile )
		{
			FileDelete % SaveFile
		}

		FileAppend, % Trim( tablesDataString, Delimiter ), % SaveFile
		TrayTip,, % "Table Data Written To: " FileName ".txt"
	}

	return tablesDataString
}