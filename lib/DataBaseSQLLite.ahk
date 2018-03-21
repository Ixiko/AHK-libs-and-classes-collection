; namespace DBA

class SQLite
{
	GetVersion(){
		return SQLite_LibVersion()
	}
	
	SQLiteExe(dbFile, commands, ByRef output){
		return SQLite_SQLiteExe(dbFile, commands, output)
	}
	
	__New(){
		throw Exception("This is a static Class. Don't create Instances from it!",-1)
	}
}

/*
	Represents a Connection to a SQLite Database
*/
class DataBaseSQLLite extends DBA.DataBase
{
	_handleDB := 0
	
	__New(handleDB){
		this._handleDB := handleDB
		if(!this.IsValid())
		{
			throw Exception("Can not create a DataBaseSQLLite instance, because the connection handle is not valid!")
		}
		ArchLogger.Log("New DataBaseSQLLite: Handle @" handleDB)
	}
	
	
	Close(){
		;ArchLogger.Log("DataBaseSQLLite: Close DB Handle @" handleDB)
		return SQLite_CloseDB(this._handleDB)
	}
	
	IsValid(){
		return (this._handleDB != 0)
	}
	
	GetLastError(){
		code := 0
		SQLite_ErrCode(this._handleDB, code)
		return code
	}
	
	GetLastErrorMsg(){
		msg := ""
		SQLite_ErrMsg(this._handleDB, msg)
		return msg
	}
	
	SetTimeout(timeout = 1000){
		return SQLite_SetTimeout(this._handleDB, timeout)
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
			rs := new DBA.RecordSetSqlLite(this, SQlite_Query(this._handleDB, sql))
			;myliters := new DBA.RecordSetSqlLite
			;myrs := new DBA.RecordSet
			
			;MsgBox % "DBA.RecordSetSqlLite params:`t" rs.TestRecordSet()
			;MsgBox % "DBA.RecordSetSqlLite:`t"myliters.TestRecordSet()
			;MsgBox % "DBA.RecordSet:`t" myrs.TestRecordSet()
			
			return rs
		}else
			throw Exception("NotSupportedException: There is no valid DB Connection, OpenRecordSet requires a valid connection.",-1)
	}
	
	/*
		Querys the DB and returns a ResultTable or true/false
	*/
	Query(sql){
		
		ret := null
		
			if (RegExMatch(sql, "i)^\s*SELECT\s")){ ; check if this is a selection query
				
				try
				{
					ret := this._GetTableObj(sql)
				} catch e
					throw Exception("Select Query failed.`n`n" sql "`n`nChild Exception:`n" e.What "`n" e.Message "`n" e.File "@" e.Line, -1)
			} else {
				 
				try
				{
					ret := SQLite_Exec(this._handleDB, sql)
				} catch e
					throw Exception("Non Selection Query failed.`n`n" sql "`n`nChild Exception:`n" e.What " `n" e.Message, -1)
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
	
	InsertMany(records, tableName){
		if(!is(records, Collection) || records.IsEmpty())
			return false
		
		colString := ""
		valString := ""
		columns := {}
		
		for column, value in records.First()
		{
			colString .= "," this.QuoteIdentifier(column)
			valString .= ",?"
			columns[column] := A_Index
		}
		sql := "INSERT INTO " this.QuoteIdentifier(tableName) "`n(" SubStr(colstring, 2) ")`nVALUES`n(" SubStr(valString, 2) ")" 
		
		
		types := []
		for i,row in this._GetTableObj("PRAGMA table_info(" this.QuoteIdentifier(tableName) ")").Rows
		{
			if (columns.HasKey(row.name)){
				;MsgBox,0,Error,  % "row name found: " row.name "`nTypes: " row.type  ; #DEBUG
				types[columns[row.name]] := row.types
			}
		}
		
		
		this.BeginTransaction()
		
		query := SQLite_Query(this._handleDB, sql) ;prepare the query
		if ErrorLevel
			msgbox % errorlevel
		
		try
		{
			for i, record in records
			{
				for col, val in record
				{
					if (!columns.HasKey(col))
						throw Exception("Irregular params: Column not found: [" col "] in`nTable Columns:" this.printKeys(columns))
					fieldType := "auto"
					if(types.HasKey(columns[col]))
						fieldType := types[columns[col]]
					
					ret := SQLite_bind(query, columns[col], val, fieldType)
					;MsgBox % " bind returned " ret
				}
				SQLite_Step(query)
				SQLite_Reset(query)
			}
		}
		catch e
		{
			this.Rollback()
			throw Exception("InsertMany failed.`n`nChild Exception:`n" e.What " `n" e.Message, -1)
		}
		SQLite_QueryFinalize(query)
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
	
	Insert(record, tableName){
		col := new Collection()
		col.Add(record)
		return this.InsertMany(col, tableName)
	}
	
	/*
		deprecated
	*/
	_GetTableObj(sql, maxResult = -1) {
		
		err := 0, rc := 0, GetRows := 0
		i := 0
		rows := cols := 0
		names := new Collection()
		dbh := this._handleDB

		SQLite_LastError(" ")

		if(!_SQLite_CheckDB(dbh)) {
			SQLite_LastError("ERROR: Invalid database handle " . dbh)
			ErrorLevel := _SQLite_ReturnCode("SQLITE_ERROR")
			return False
		}

		if (maxResult < -1)
			maxResult := -1
		mytable := ""
		Err := 0
		
		_SQLite_StrToUTF8(SQL, UTF8)
		RC := DllCall("SQlite3\sqlite3_get_table", "Ptr", dbh, "Ptr", &UTF8, "Ptr*", mytable
				   , "Ptr*", rows, "Ptr*", cols, "Ptr*", err, "Cdecl Int")
				   
		If (ErrorLevel) {
		  SQLite_LastError("ERROR: DLLCall sqlite3_get_table failed!")
		  Return False
		}
		If (rc) {
		  SQLite_LastError(StrGet(err, "UTF-8"))
		  DllCall("SQLite3\sqlite3_free", "Ptr", err, "cdecl")
		  ErrorLevel := rc
		  return false
		}

		

	   if (maxResult = 0) {
		  DllCall("SQLite3\sqlite3_free_table", "Ptr", mytable, "Cdecl")   
		  If (ErrorLevel) {
			 SQLite_LastError("ERROR: DLLCall sqlite3_close failed!")
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
		  names.Add(StrGet(NumGet(mytable+0, Offset), "UTF-8"))
		  Offset += A_PtrSize
	   }

		myRows := new Collection()
		Loop, %GetRows% {
			i := A_Index
			fields := new Collection()
			Loop, % Cols 
			{
				fields.Add(StrGet(NumGet(mytable+0, Offset), "UTF-8"))
				Offset += A_PtrSize
			}
			myRows.Add(new DBA.Row(Names, fields))
		}
		tbl := new DBA.Table(myRows, Names)
		
		; Free Results Memory
		DllCall("SQLite3\sqlite3_free_table", "Ptr", mytable, "Cdecl")   
		if (ErrorLevel) {
			SQLite_LastError("ERROR: DLLCall sqlite3_close failed!")
			return false
		}
		return tbl
	}
	

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
