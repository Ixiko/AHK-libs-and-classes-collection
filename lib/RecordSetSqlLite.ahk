;namespace DBA

/*
	Represents a result set of an SQLite Query
*/
class RecordSetSqlLite extends DBA.RecordSet
{
	_currentRow := 0 	; Row
	_colNames := 0		; Collection<ColumnNames>
	_query := 0			; int Handle to the Query
	_db	:= 0			; SQLiteDataBase
	_eof := false		; bool 
	
	
	
	__New(db, query){
		
		if(!is(db, DBA.DataBaseSQLLite)){
			throw Exception("ArgumentException: db must be a DataBaseSQLLite Object",-1)
		}
		this._db := db
		this._query := query
		
		if(query != 0){
			
			SQLite_FetchNames(this._query, names)
			this._colNames := new Collection(names)
			
			this.MoveNext() ; move to the first record
		}
	}
	
	Test(){
		return "I'm a RecordSetSqlLite instance. For sure."
	}
	
	
	/*
		Is this RecordSet valid?
	*/
	IsValid(){
		return (this._query != 0)
	}
	
	/*
		Returns an Array with all Column Names
	*/
	getColumnNames(){
		return this._colNames
	}
		
	getEOF(){
		return this._eof
	}
	
	
	MoveNext() {	
		static EOR := -1
		
		this.ErrorMsg := ""
		this.ErrorCode := 0
		this._currentRow := 0
		
		if (!this._query) {
			this.ErrorMsg := "Invalid query handle!"
			this._eof := true
			return false
		}
		rc := DllCall("SQlite3\sqlite3_step", "UInt", this._query, "Cdecl Int")

		if (rc != this._db.ReturnCode("SQLITE_ROW")) {
			if (rc = this._db.ReturnCode("SQLITE_DONE")) {
				this.ErrorMsg := "EOR"
				this.ErrorCode := rc
				this._eof := true
				return EOR
			}
			this.ErrorMessage := this._db.ErrMsg()
			this.ErrorCode := rc
			this._eof := true
			return false
		}
		rc := DllCall("SQlite3\sqlite3_data_count", UInt, this._query, "Cdecl Int")
		
		if (rc < 1) {
			this.ErrorMsg := "RecordSet is empty!"
			this.ErrorCode := this._db.ReturnCode("SQLITE_EMPTY")
			this._eof := true
			return false
		}
		 
		; fill the internal row structure
		;_currentRow := new Row()
		fields := new Collection()
		Loop, %rc% {
			ctype := DllCall("SQlite3\sqlite3_column_type", UInt, this._query, Int, A_Index - 1, "Cdecl Int")
			
			if (ctype == SQLiteDataType.SQLITE_NULL) {
				
				fields[A_Index] := DBA.DataBase.NULL ;""
				
			}else if(ctype == SQLiteDataType.SQLITE_BLOB){

				blobSize := DllCall("SQlite3\sqlite3_column_bytes", UInt, this._query, Int, A_Index -1, "Cdecl UInt")
				blobPtr := DllCall("SQlite3\sqlite3_column_blob", UInt, this._query, Int, A_Index - 1, "Cdecl Ptr")

				if ( blobPtr )
				{
					fields[A_Index] :=  MemoryBuffer.Create( blobPtr, blobSize )
				}else{
					fields[A_Index] := DBA.DataBase.NULL
				}
			} else {
				strPtr := DllCall("SQlite3\sqlite3_column_text", UInt, this._query, Int, A_Index - 1, "Cdecl UInt")
				fields[A_Index] := StrGet(strPtr, "UTF-8")
			}
		}
		this._currentRow := new DBA.Row(this.getColumnNames(), fields)
		this.CurrentRow++
		return true
	}
	
	

	Reset() {
		this.ErrorMsg := ""
		this.ErrorCode := 0
		
		if (!this._query) {
			this.ErrorMsg := "Invalid query handle!"
			return false
		}
		rc := DllCall("SQlite3\sqlite3_reset", UInt, this._query, "Cdecl Int")

		if (rc) {
			this.ErrorMsg := This._db.ErrMsg()
			this.ErrorCode := rc
			return false
		}
		this.CurrentRow := 0
		this.MoveNext()
		return true
	}

	
	Close() {
		this.ErrorMsg := ""
		this.ErrorCode := 0
		if(this._query == 0)
			return true
		
		rc := DllCall("SQlite3\sqlite3_finalize", "UInt", this._query, "Cdecl Int")

		if (rc) {
			this.ErrorMsg := this._db.ErrMsg()
			this.ErrorCode := rc
			return false
		}
		this._query := 0
		return true
	}
	

}

