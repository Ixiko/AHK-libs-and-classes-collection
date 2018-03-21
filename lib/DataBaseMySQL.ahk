;namespace DBA

/*
	Represents a Connection to a SQLite Database
*/
class DataBaseMySQL extends DBA.DataBase
{
	_handleDB := 0
	_connectionData := []
	
	__New(connectionData){
		if(!IsObject(connectionData))
			throw Exception("Expected connectionData Array!")
		this._connectionData := connectionData
		
		this.Connect()
	}
	
	/*
		(Re) Connects to the db with the given creditals
	*/
	Connect(){
		connectionData := this._connectionData
		
		if(!connectionData.Port){
		  dbHandle := MySQL_Connect(connectionData.Server, connectionData.Uid, connectionData.Pwd, connectionData.Database)
		} else {
		  dbHandle := MySQL_Connect(connectionData.Server, connectionData.Uid, connectionData.Pwd, connectionData.Database, connectionData.Port)
		}
		this._handleDB := dbHandle
	}
	
	Close(){
		/*
		ToDo!
		*/
	}
	
	IsValid(){
		return (this._handleDB != 0)
	}
	
	GetLastError(){
		return MySQL_GetLastErrorNo(this._handleDB)
	}
	
	GetLastErrorMsg(){
		return MySQL_GetLastErrorMsg(this._handleDB)
	}
	
	SetTimeout(timeout = 1000){
		/* 
		todo 
		*/
	}
	
	
   ErrMsg() {
		return DllCall("libmySQL.dll\mysql_error", "UInt", this._handleDB, "AStr")
   }

   ErrCode() {
		return DllCall("libmySQL.dll\mysql_errno", "UInt", this._handleDB) ; "Cdecl UInt"
   }

   Changes() {
      /*
		ToDo
	  */
   }
	
	
	/*
		Querys the DB and returns a RecordSet
	*/
	OpenRecordSet(sql, editable = false){
		
		result := MySQL_Query(this._handleDB, sql)
		
		if (result != 0) {
			errCode := this.ErrCode()
			if(errCode == 2003 || errCode == 2006 || errCode == 0){ ;// we've lost the connection
				;// try reconnect
				this.Connect()
				result := MySQL_Query(this._handleDB, sql)
				if (result != 0)
					throw new Exception(BuildMySQLErrorStr(this._handleDB, "Query failed because of lost connection. Reconnect failed too." errCode, sql), -1)
			} else {
				throw new Exception(BuildMySQLErrorStr(this._handleDB, "Query Failed Error " errCode, sql), -1)
			}
		}
		
		requestResult := MySQL_Use_Result(this._handleDB)
		if(!requestResult)
			return false
		
		return new DBA.RecordSetMySQL(this._handleDB, requestResult)
	}
	
	/*
		Querys the DB and returns a ResultTable or true/false
	*/
	Query(sql){
		return this._GetTableObj(sql)
	}

	EscapeString(str){
		return Mysql_escape_string(str)
	}
	
	QuoteIdentifier(identifier) {
		; ` characters are actually valid. Technically everthing but a literal null U+0000.
		; Everything else is fair game: http://dev.mysql.com/doc/refman/5.0/en/identifiers.html
		StringReplace, identifier, identifier, ``, ````, All
		return "``" identifier "``"
	}
	
	BeginTransaction(){
		this.Query("START TRANSACTION;")
	}
	
	EndTransaction(){
		this.Query("COMMIT;")
	}
	
	Rollback(){
		this.Query("ROLLBACK;") 
	}
	
	InsertMany(records, tableName){
		
		if(!is(records, Collection) || records.IsEmpty())
			return false
		
		sql := "INSERT INTO " tableName "`n"
		colString := ""
		
		for column, value in records.First()
		{
			colstring .= this.QuoteIdentifier(column) ","
		}
		StringTrimRight, colstring, colstring, 1
		sql .= "(" colstring ")`nVALUES`n"
		
		for each, record in records
		{
			valString := ""
			for column, value in record
			{
				valString .=  this.ToSqlLiteral(value) ","
			}
			StringTrimRight, valString, valString, 1
			sql .= "(" valString "),`n"
		}
		StringTrimRight, colstring, colstring, 1
		sql := Trim(sql," `t`r`n,") ";"
		
		;FileAppend,`n---------`n%sql%`n, dba_sql.log
		return this.Query(sql)
	}
	

	Insert(record, tableName){
		records := new Collection()
		records.Add(record)
		return this.InsertMany(records, tableName)
	}
	
	Update(fields, constraints, tableName, safe = True) {
		if (safe) ;limitation: information_schema doesn't work with temp tables
			for k, row in this.Query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_KEY = 'PRI' AND TABLE_NAME = " this.ToSqlLiteral(tableName)).Rows
				if (!constraints.HasKey(row[1]))
					return -1 ; error handling....
		
		WHERE := ""
		for col, val in constraints
			WHERE .= ", " this.QuoteIdentifier(col) " = " this.ToSqlLiteral(val)
		WHERE := SubStr(WHERE, 3)
		
		SET := ""
		for col, val in fields
			SET .= "AND " this.QuoteIdentifier(col) " = " this.EscapeString(val)
		SET := SubStr(SET, 5)
		
		query := "UPDATE " this.QuoteIdentifier(tableName) " SET " SET " WHERE " WHERE
		return db.Query(query)
	}
	
	_GetTableObj(sql, maxResult = -1) {
	
		result := MySQL_Query(this._handleDB, sql)
		
		/*
		* Instant reconnect attempt
		*/
		if (result != 0) {
			errCode := this.ErrCode()
			if(errCode == 2003 || errCode == 2006 || errCode == 0){ ;// we've lost the connection
				;// try reconnect
				this.Connect()
				result := MySQL_Query(this._handleDB, sql)
				if (result != 0)
					throw new Exception(BuildMySQLErrorStr(this._handleDB, "Query failed because of lost connection. Reconnect failed too." errCode, sql), -1)
			} else {
				throw new Exception(BuildMySQLErrorStr(this._handleDB, "Query Failed Error " errCode, sql), -1)
			}
		}
		

		requestResult := MySql_Store_Result(this._handleDB)

		if (!requestResult) ; the query was a non {SELECT, SHOW, DESCRIBE, EXPLAIN or CHECK TABLE} statement which doesn't yield any resultset
			return
		
		mysqlFields := MySQL_fetch_fields(requestResult)
		colNames := new Collection()
		columnCount := 0
		for each, mysqlField in mysqlFields
		{
			colNames.Add(mysqlField.Name())
			columnCount++
		}
		
		rowptr := 0
		myRows := new Collection()
		while((rowptr := MySQL_fetch_row(requestResult)))
		{
			rowIndex := A_Index
			datafields := new Collection()
			
			lengths := MySQL_fetch_lengths(requestResult)
			Loop, % columnCount
			{
				length := GetUIntAtAddress(lengths, A_Index - 1)
				fieldPointer := GetPtrAtAddress(rowptr, A_Index - 1)
				if (fieldPointer != 0) ; "NULL values in the row are indicated by NULL pointers." See http://dev.mysql.com/doc/refman/5.0/en/mysql-fetch-row.html
					fieldValue := StrGet(fieldPointer, length, "CP0")
				else
					fieldValue := "" ; Should use DBA.DataBase.NULL from database-types branch?
				datafields.Add(fieldValue)
			}
			myRows.Add(new DBA.Row(colNames, datafields))
		}
		MySQL_free_result(requestResult)
		
		tbl := new DBA.Table(myRows, colNames)
		return tbl
	}
}
