SingleRecordSQL(table,array,upsertkey := "",upsertdiscardkeys := "",noWrap := "",upsertValidation := ""){
	/*
		[table]						a string containing the name of the table to insert into. If working with multiple databases prepend the schema name here as you normally would.
		[array]						the array of data you want to insert. The function will safely ignore nested arrays; pass those in seperate calls.
		[upsertkey]		[optional]	pass a string or numeric array with column name *values* that reflects the ON CONFLICT(key)
		[upsertdiscardkeys]	[optional]	pass a comma-delimited string of column names, or a numeric array with column name *values* to ignore on an upsert.
		[noWrap]			[optional]	pass a comma-delimited string of column names, or a numeric array with column name *values* to not automatically wrap; most often used with subqueries.
		[validation]		[optional]	pass the exact string you would place after the WHERE clause in the UPSERT; there is no automatic escaping here!
		_								*KNOWN LIMITATION*	keynames with commas are not currently discarded or checked as upsert key; probably shouldn't use commas in your column names anyways
		
	*/
	If (upsertkey != "") {	;only process upserts if there's an upsertkey
		outup := "ON CONFLICT(" sqlGlue(upsertkey,1) ") DO UPDATE SET`n"
		for k, v in array
			if !IsObject(v)	;do not go into a nested array.
			{
				If !IfIn(sqlQuote(k),sqlGlue(upsertdiscardkeys))	;does not currently handle key names with commas
				&& !IfIn(k,sqlGlue(upsertkey,-1))			;does not currently handle key names with commas
					outup .= (final := a_tab sqlQuote(k,1) "=" "excluded." sqlQuote(k,1)) ",`n" ;"`t`t-- " sqlQuote(v) "`n"
			}
	}
	values := SubStr(values, 2)

	return Format("INSERT OR IGNORE INTO {}({}) `nVALUES({})"
		, sqlQuote(table,1)
		, sqlGlue(array,1,1)
		, sqlGlue(array,,,,noWrap)) "`n"
	.	(upsertkey=""?"":"`n" RTrim(outup,"`n,") "`n"	;conditionally pass the upsert language
	.	(upsertvalidation=""?"":"`nWHERE " Trim(upsertvalidation) "`n")) 	;conditionally pass the valudation check
	.	";`n"
}
	

sqlQuote(value,wrap := 0) { ;escapes the strings and corrects NULL values
	/*
		Defaults based on SQLite
		'keyword'		A keyword in single quotes is a string literal.
		"keyword"		A keyword in double-quotes is an identifier.
		[keyword]		A keyword enclosed in square brackets is an identifier. This is not standard SQL. 
		_				This quoting mechanism is used by MS Access and SQL Server and is included in SQLite for compatibility.
		`keyword`		A keyword enclosed in grave accents (ASCII code 96) is an identifier. 
		_				This is not standard SQL. This quoting mechanism is used by MySQL and is included in SQLite for compatibility.
	*/
	
	static w := {-1:"",0:"'",1:"""",2:"[",3:"``"}
	return (value != "")? w[wrap] StrReplace(value, "'", wrap!=-1?"''":"'") (wrap!=2?w[wrap]:"]")
		: "NULL"
}

sqlGlue(array,wrap := 0,RetCols := 0,delim := ",",noEsc := "")
{
	/*
		Generates an escaped fragment of SQL for use as a list of columns or values
		wrap accepts 0-3 as in sqlQuote (and -1)
		RetCols returns key names instead of key values if true
		noEsc is used to return unaltered values of specified passed keys
	*/
	if IsObject(noEsc)	;Glue the noEsc values just once instead of each iteration in the loop below
		noEsc := sqlGlue(noEsc,-1)
	
	for k,v in array
		If !IsObject(v)
			new.=sqlQuote((RetCols=0?v:k),IfIn(k,noEsc)=""?wrap:-1) delim
	
	return (IsObject(array)=1?trim(new, delim):array)	;return the newly built string if 'array' is an object, or pass the unaltered string
}
;SingleRecordSQL(ByRef table,ByRef array,ByRef upsertkey := "",ByRef upsertdiscardkeys := "",ByRef noWrap := "",ByRef upsertvalidation := ""){
	;/*
		;[table]						a string containing the name of the table to insert into. If working with multiple databases prepend the schema name here as you normally would.
		;[array]						the array of data you want to insert. The function will safely ignore nested arrays; pass those in seperate calls.
		;[upsertkey]		[optional]	pass a string or numeric array with column name *values* that reflects the ON CONFLICT(key)
		;[upsertdiscardkeys]	[optional]	pass a comma-delimited string of column names, or a numeric array with column name *values* to ignore on an upsert.
		;[noWrap]			[optional]	pass a comma-delimited string of column names, or a numeric array with column name *values* to not automatically wrap; most often used with subqueries.
		;[validation]		[optional]	pass the exact string you would place after the WHERE clause in the UPSERT; there is no automatic wrapping here!
		;_								*KNOWN LIMITATION*	keynames with commas are not currently discarded or checked as upsert key; probably shouldn't use commas in your column names anyways
		
	;*/
	;/*	old
		;If (upsertkey != "") {	;only process upserts if there's an upsertkey
			;outup := "ON CONFLICT(" sqlGlue(upsertkey,1) ") DO UPDATE SET`n"
			;for k, v in array
				;if !IsObject(v)	;do not go into a nested array.
				;{
					;If !IfIn(sqlQuote(k),sqlGlue(upsertdiscardkeys))	;does not currently handle key names with commas
				;&& !IfIn(k,sqlGlue(upsertkey,-1))			;does not currently handle key names with commas
						;outup .= (final := a_tab sqlQuote(k,1) "=" "excluded." sqlQuote(k,1)) ",`n" ;"`t`t-- " sqlQuote(v) "`n"
				;}
		;}
	;*/
	;MsgBox % st_printArr(array)
	;_upsertdiscardkeys := sqlGlue(upsertdiscardkeys)
	;,_upsertkey := sqlGlue(upsertkey,-1)
	;for k, v in array
		;if !IsObject(v)    ;do not go into a nested array.
		;{
			;If !IfIn(sqlQuote(k),_upsertdiscardkeys)    ;does not currently handle key names with commas
                ;&& !IfIn(k,_upsertkey)            ;does not currently handle key names with commas
                    ;outup .= (final := a_tab sqlQuote(k,1) "=" "excluded." sqlQuote(k,1)) ",`n" ;"`t`t-- " sqlQuote(v) "`n"
		;}
	;values := SubStr(values, 2)
	
	
	;msgbox % 
	;return Format("INSERT OR IGNORE INTO {}({}) `nVALUES({})"
		;, sqlQuote(table,1)
		;, sqlGlue(array,1,1)
		;, sqlGlue(array,,,,noWrap)) "`n"
	;.	(upsertkey=""?"":"`n" RTrim(outup,"`n,") "`n"	;conditionally pass the upsert language
	;.	(upsertvalidation=""?"":"`nWHERE " Trim(upsertvalidation) "`n")) 	;conditionally pass the valudation check
	;.	";`n"
;}


;sqlQuote(ByRef value,ByRef wrap := 0) { ;escapes the strings and corrects NULL values
	;/*
		;Defaults based on SQLite
		;'keyword'		A keyword in single quotes is a string literal.
		;"keyword"		A keyword in double-quotes is an identifier.
		;[keyword]		A keyword enclosed in square brackets is an identifier. This is not standard SQL. 
		;_				This quoting mechanism is used by MS Access and SQL Server and is included in SQLite for compatibility.
		;`keyword`		A keyword enclosed in grave accents (ASCII code 96) is an identifier. 
		;_				This is not standard SQL. This quoting mechanism is used by MySQL and is included in SQLite for compatibility.
	;*/
	
	;static w := {-1:"",0:"'",1:"""",2:"[",3:"``"}
	;return (value != "")? w[wrap] StrReplace(value, "'", wrap!=-1?"''":"'") (wrap!=2?w[wrap]:"]")
		;: "NULL"
;}

;sqlGlue(ByRef array,ByRef wrap := 0,ByRef RetCols := 0,ByRef delim := ",",ByRef noEsc := "")
;{
	;/*
		;Generates an escaped fragment of SQL for use as a list of columns or values
		;wrap accepts 0-3 as in sqlQuote (and -1)
		;RetCols returns key names instead of key values if true
		;noEsc is used to return unaltered values of specified passed keys
	;*/
	;if IsObject(noEsc)	;Glue the noEsc values just once instead of each iteration in the loop below
		;noEsc := sqlGlue(noEsc,-1)
	
	;for k,v in array
		;If !IsObject(v)
			;new.=instr(RetCols=0?v:k,"'")?sqlQuote((RetCols=0?v:k),IfIn(k,noEsc)=""?wrap:-1) delim:delim
	
	;return (IsObject(array)=1?trim(new, delim):array)	;return the newly built string if 'array' is an object, or pass the unaltered string
;}



/*
	SingleRecordSQL(table,arr,upsertkey := "",upsertdiscardkeys := "",NoQuote := "")
	{
		static preSQL := {}
		preSQL[1] := arr
		return getSql(table,preSQL,upsertkey,upsertdiscardkeys,NoQuote)
	}
	
	getSql(table, records, upsertkey := "", upsertdiscardkeys := "", NoQuote := "")
	{
; Get a list of all keys
;msgbox % st_printarr(records)
		outup := "ON CONFLICT(" upsertkey ") DO UPDATE SET`n"
		keys := {}
		for i, record in records	
			for k, v in record
				if !IsObject(v)
				{
					keys[k] := 1
					If (upsertkey != "")
				&& !IfIn(k,upsertdiscardkeys)
						outup .= sqlQuote(k) "=" (!IfIn(k,NoQuote)? sqlQuote(v):v) ",`n"
				}
;msgbox % st_printArr(records)
; Convert key names into SQL
		for k in keys
			cols .= "," sqlQuote(k)
		cols := SubStr(cols, 2)
		
; Convert records into SQL
		for i, record in records
		{
			fields := ""
			for k in keys ; Loop over 'keys' not 'record' to ensure consistent column order
				fields .= "," (record.HasKey(k) ? (!IfIn(k,NoQuote)? sqlQuote(record[k]):record[k]) : "NULL")
			values .= ",`n(" SubStr(fields, 2) ")"
		}
		values := SubStr(values, 2)
		
		return Format("INSERT OR IGNORE INTO {} ({}) VALUES {}", sqlQuote(table), cols, values) 
	.	(upsertkey=""?"":"`n" RTrim(outup,"`n,")) ;conditionally pass the upsert language
	.	";`n"
	}
	
*/
