; namespace MfUcd

class SQLite
{
	GetVersion(){
		return MfUcd.SQLite_LibVersion()
	}
	
	SQLiteExe(dbFile, commands, ByRef output){
		return MfUcd.SQLite_SQLiteExe(dbFile, commands, output)
	}
	
	__New(){
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Static_Class", "MfUcd.SqLite"))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
}

/*
	Represents a Connection to a SQLite Database
*/
class DataBaseSQLLite extends MfUcd.DataBase
{
	_handleDB := 0
	
	__New(handleDB){
		this._handleDB := handleDB
		if(!this.IsValid())
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Create_Invalid_Handle","DATA"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
	}
	
	
	Close(){
		return MfUcd.SQLite_CloseDB(this._handleDB)
	}
	
	IsValid(){
		return (this._handleDB != 0)
	}
	
	GetLastError(){
		code := 0
		MfUcd.SQLite_ErrCode(this._handleDB, code)
		return code
	}
	
	GetLastErrorMsg(){
		msg := ""
		MfUcd.SQLite_ErrMsg(this._handleDB, msg)
		return msg
	}
	
	SetTimeout(timeout = 1000){
		return MfUcd.SQLite_SetTimeout(this._handleDB, timeout)
	}
	
	
   ErrMsg() {
      if (RC := DllCall("SQLite3\sqlite3_errmsg", "UInt", this._handleDB, "Cdecl UInt"))
         return StrGet(RC, "UTF-8")
      return ""
   }

   ErrCode() {
      return DllCall("SQLite3\sqlite3_errcode", "UInt", this._handleDB, "Cdecl UInt")
   }

   Changes() {
      return DllCall("SQLite3\sqlite3_changes", "UInt", this._handleDB, "Cdecl UInt")
   }
	
	
	/*
		Querys the DB and returns a RecordSet
	*/
	OpenRecordSet(sql, editable = false){
		
		if( this.IsValid() )
		{
			rs := new MfUcd.MfRecordSetSqlLite(this, MfUcd.SQlite_Query(this._handleDB, sql))
			return rs
		}else
			ex := new MfException(MfEnvironment.Instance.GetResourceStringBySection("NotSupportedException_DbConnection_ORS","DATA"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
	}
	
	/*
		Querys the DB and returns a ResultTable or true/false
	*/
	Query(sql)
	{
		ret := null
		if (RegExMatch(sql, "i)^\s*SELECT\s")) { ; check if this is a selection query
			try {
				ret := this._GetTableObj(sql)
			} catch e {
				ex := new MfException(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Select","DATA"
					, MfEnvironment.Instance.NewLine, sql), e)
				ex.Source := A_ThisFunc
				ex.File := A_LineFile
				ex.Line := A_LineNumber
				throw ex
			}
		} else {
			try {
				ret := MfUcd.SQLite_Exec(this._handleDB, sql)
			} catch e {
				ex := new MfException(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Non_Select_Query","DATA"
					, MfEnvironment.Instance.NewLine, sql))
				ex.Source := A_ThisFunc
				ex.File := A_LineFile
				ex.Line := A_LineNumber
				throw ex
			}
		}
		return ret
	}
	
	EscapeString(str){
		StringReplace, str, str, ', '', All ; replace all single quotes with double single-quotes. pascal escape'
		return str
	}
	
	QuoteIdentifier(identifier) {
		; ` characters are actually valid. Technically everthing but a literal null U+0000.
		; Everything else is fair game: http://dev.mysql.com/doc/refman/5.0/en/identifiers.html
		StringReplace, identifier, identifier, ``, ````, All
		return "``" identifier "``"
	}
	
	
	BeginTransaction(){
		this.Query("BEGIN TRANSACTION;")
	}
	
	EndTransaction(){
		this.Query("COMMIT TRANSACTION;")
	}
	
	Rollback(){
		this.Query("ROLLBACK TRANSACTION;")
	}
	
/*
	Function: InsertMany(records, tableName)
		InsertMany() Inserts one or more rows into a table
	Parameters:
		records - A Collections of Rows objects to insert. This must be a class derived from [MfCollectionBase](MfCollectionBase.html)
		tableName - The name of the table to insert the rows into. Can be string or instance of [MfString](MfString.html)
	Remarks:
		The records parameter must be a collecton of [MfDictionaryBase](MfDictionaryBase.html) based items.
	Returns:
		Returns *true* if successful insert otherwise *false*
*/	
	InsertMany(records, tableName){
		
		if (!MfObject.IsObjInstance(records, "MfCollectionBase") || (records.Count = 0))
		{
			return false
		}
		_tableName := MfString.GetValue(tableName)
		colString := ""
		valString := ""
		columns := {}
	
		; get the columns from the first row
		_row := records.Item[0]
		for k, v in _row
		{
			colString .= "," this.QuoteIdentifier(k)
			valString .= ",?"
			columns[k] := A_Index
		}
		
		sql := "INSERT INTO " this.QuoteIdentifier(_tableName) "`n(" SubStr(colstring, 2) ")`nVALUES`n(" SubStr(valString, 2) ")" 
		
		
		types := []
		for i,row in this._GetTableObj("PRAGMA table_info(" this.QuoteIdentifier(_tableName) ")").Rows
		{
			; name is the column name
			; row is a MfCollectionBase
			cKey := row.Column["name"]
			if (columns.HasKey(cKey)) {
				if (row.HasColumn("types")) {
					types[columns[cKey]] := row.Column["types"]
				}
			}
		}
		
		
		this.BeginTransaction()
		
		query := MfUcd.SQLite_Query(this._handleDB, sql) ;prepare the query
		if ErrorLevel
			msgbox % errorlevel
		
		try
		{
			for i, record in records
			{
				for col, val in record
				{
					if (!columns.HasKey(col))
					{
						ex := new MfException(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Col_Not_Found_Irr"
							,"DATA", col,MfEnvironment.Instance.NewLine, this.printKeys(columns)))
						ex.Source := A_ThisFunc
						ex.File := A_LineFile
						ex.Line := A_LineNumber
						throw ex
					}
					fieldType := "auto"
					if(types.HasKey(columns[col]))
						fieldType := types[columns[col]]
					
					ret := MfUcd.SQLite_bind(query, columns[col], val, fieldType)
					;MsgBox % " bind returned " ret
				}
				MfUcd.SQLite_Step(query)
				MfUcd.SQLite_Reset(query)
			}
		}
		catch e
		{
			this.Rollback()
			ex := new MfException(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Insert_Many_Fail","DATA"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		MfUcd.SQLite_QueryFinalize(query)
		this.EndTransaction()
		return True
	}
	
	printKeys(arr){
		str := ""
		for key, val in arr
		{
			str .= key ","
		}
		return str
	}
/*!
	Method: Insert((row, tableName)
		Insert() Inserts a single row into the table
	Parameters:
		row - The row data to insert into tabel. Can be instance of MfUcd.Row or instance of MfDictionaryBase
		tableName - The name of the table to insert the row into. Can be string or instance of [MfString](MfString.html)
	Remarks:
		some remaarks here
	Returns:
		Returns *true* if the insert was a success otherwise *false*.
*/
	Insert(row, tableName){
		col := new MfCollection()
		validType := false
		if (MfObject.IsObjInstance(row, "MfUcd.Row")) {
			validType := true
			col.Add(row)
		}
		if (MfObject.IsObjInstance(row, "MfDictionaryBase")) {
			validType := true
			_Row := new MfUcd.Row(row)
			col.Add(_Row)
		}
		if (validType := true) {
			return this.InsertMany(col, tableName)
		} else {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"
				, A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		
	}
	
	/*
		deprecated
	*/
	_GetTableObj(sql, maxResult = -1) {
		
		err := 0, rc := 0, GetRows := 0
		i := 0
		rows := cols := 0
		names := new MfCollection()
		dbh := this._handleDB

		MfUcd.SQLite_LastError(" ")

		if(!MfUcd._SQLite_CheckDB(dbh)) {
			MfUcd.SQLite_LastError(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Invalid_Handle","DATA", dbh))
			ErrorLevel := MfUcd._SQLite_ReturnCode("SQLITE_ERROR")
			return False
		}

		if (maxResult < -1)
			maxResult := -1
		mytable := ""
		Err := 0
		
		MfUcd._SQLite_StrToUTF8(SQL, UTF8)
		RC := DllCall("SQlite3\sqlite3_get_table", "Ptr", dbh, "Ptr", &UTF8, "Ptr*", mytable
				   , "Ptr*", rows, "Ptr*", cols, "Ptr*", err, "Cdecl Int")
				   
		If (ErrorLevel) {
		  MfUcd.SQLite_LastError(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Dll_Get_Table","DATA"))
		  Return False
		}
		If (rc) {
		  MfUcd.SQLite_LastError(StrGet(err, "UTF-8"))
		  DllCall("SQLite3\sqlite3_free", "Ptr", err, "cdecl")
		  ErrorLevel := rc
		  return false
		}

		

	   if (maxResult = 0) {
		  DllCall("SQLite3\sqlite3_free_table", "Ptr", mytable, "Cdecl")   
		  If (ErrorLevel) {
			 MfUcd.SQLite_LastError(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Dll_Close","DATA"))
			 Return False
		  }
		  Return True
	   }
	   
	   if (maxResult = 1)
		  GetRows := 0
	   else if (maxResult > 1) && (maxResult < rows)
		  GetRows := MaxResult
	   else
		  GetRows := rows
	   Offset := 0
	   
	   Loop, % cols
	   {
		  names.Add(MfNull.GetObjOrNull(StrGet(NumGet(mytable+0, Offset), "UTF-8")))
		  Offset += A_PtrSize
	   }

		myRows := new MfCollection()
		Loop, %GetRows% {
			i := A_Index
			fields := new MfCollection()
			Loop, % Cols 
			{
				fields.Add(MfNull.GetObjOrNull(StrGet(NumGet(mytable+0, Offset), "UTF-8")))
				Offset += A_PtrSize
			}
			myRows.Add(new MfUcd.Row(Names, fields))
		}
		tbl := new MfUcd.Table(myRows, Names)
		
		; Free Results Memory
		DllCall("SQLite3\sqlite3_free_table", "Ptr", mytable, "Cdecl")   
		if (ErrorLevel) {
			MfUcd.SQLite_LastError(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Dll_Close","DATA"))
			return false
		}
		return tbl
	}
;{ 	Is()
	/*
		Function: Is(ObjType)
			Is() Gets if current *instance* of Row
			is of the same type.  
			Overrides MfObject
		Parameters:
			ObjType - The *object* to compare this *instance* of
				Row with Type can be an *instance* of Row or an *object* derived from Row
		Remarks:
			If a string is used as the Type case is ignored so "mfobject" is the same as "MfObject"
		Returns:
			Returns **true** if **Type** Parameter is of the same type as current
			Row *instance* or any of its base types otherwise **false**
	*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "DataBaseSQLLite") {
			return true
		}
        if (typeName = "MfUcd.DataBaseSQLLite") {
			return true
		} 
		return base.Is(typeName)
	}
; 	End:Is() ;}

   ReturnCode(RC) {
      static RCODE := {SQLITE_OK: 0          ; Successful result
                     , SQLITE_ERROR: 1       ; SQL error or missing database
                     , SQLITE_INTERNAL: 2    ; NOT USED. Internal logic error in SQLite
                     , SQLITE_PERM: 3        ; Access permission denied
                     , SQLITE_ABORT: 4       ; Callback routine requested an abort
                     , SQLITE_BUSY: 5        ; The database file is locked
                     , SQLITE_LOCKED: 6      ; A table in the database is locked
                     , SQLITE_NOMEM: 7       ; A malloc() failed
                     , SQLITE_READONLY: 8    ; Attempt to write a readonly database
                     , SQLITE_INTERRUPT: 9   ; Operation terminated by sqlite3_interrupt()
                     , SQLITE_IOERR: 10      ; Some kind of disk I/O error occurred
                     , SQLITE_CORRUPT: 11    ; The database disk image is malformed
                     , SQLITE_NOTFOUND: 12   ; NOT USED. Table or record not found
                     , SQLITE_FULL: 13       ; Insertion failed because database is full
                     , SQLITE_CANTOPEN: 14   ; Unable to open the database file
                     , SQLITE_PROTOCOL: 15   ; NOT USED. Database lock protocol error
                     , SQLITE_EMPTY: 16      ; Database is empty
                     , SQLITE_SCHEMA: 17     ; The database schema changed
                     , SQLITE_TOOBIG: 18     ; String or BLOB exceeds size limit
                     , SQLITE_CONSTRAINT: 19 ; Abort due to constraint violation
                     , SQLITE_MISMATCH: 20   ; Data type mismatch
                     , SQLITE_MISUSE: 21     ; Library used incorrectly
                     , SQLITE_NOLFS: 22      ; Uses OS features not supported on host
                     , SQLITE_AUTH: 23       ; Authorization denied
                     , SQLITE_FORMAT: 24     ; Auxiliary database format error
                     , SQLITE_RANGE: 25      ; 2nd parameter to sqlite3_bind out of range
                     , SQLITE_NOTADB: 26     ; File opened that is not a database file
                     , SQLITE_ROW: 100       ; sqlite3_step() has another row ready
                     , SQLITE_DONE: 101}     ; sqlite3_step() has finished executing
      return RCODE.HasKey(RC) ? RCODE[RC] : ""
   }	
}
