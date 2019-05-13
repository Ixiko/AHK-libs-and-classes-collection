;namespace MfUcd

/*
	Represents a result set of an SQLite Query
*/
class MfRecordSetSqlLite extends MfUcd.RecordSet
{
	_currentIndex := 0 	; Row
	_colNames := 0		; Collection<ColumnNames>
	_query := 0			; int Handle to the Query
	_db	:= 0			; SQLiteDataBase
	_eof := false		; bool 

	CurrentIndex[]
	{
		get {
			return this._currentIndex
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
	EOF[]
	{
		get {
			return this._eof
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
	__New(db, query){
		base.__New()
		if (MfType.TypeOf(db) != "MfUcd.DataBaseSQLLite") {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType"
				,"db","MfUcd.DataBaseSQLLite"), "MfUcd.DataBaseSQLLite")
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		
		this._db := db
		this._query := query
		
		if(query != 0){
			
			MfUcd.SQLite_FetchNames(this._query, names)
			this._colNames := new MfCollection()
			for k, v in names
			{
				this._colNames.Add(v)
			}
			
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
		this._currentRow := Null
		fields := Null
		
		if (!this._query) {
			this.ErrorMsg := MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Invalid_Handle_Query","DATA")
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
			this.ErrorMsg := MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Recordset_Empty","DATA")
			this.ErrorCode := this._db.ReturnCode("SQLITE_EMPTY")
			this._eof := true
			return false
		}
		 
		; fill the internal row structure
		;_currentRow := new Row()
		fields := new MfCollection()
		Loop, %rc% {
			_index := A_Index -1
			ctype := DllCall("SQlite3\sqlite3_column_type", UInt, this._query, Int, _index, "Cdecl Int")
			
			if (ctype == MfUcd.SQLiteDataType.SQLITE_NULL) {
				
				fields.Add(MfUcd.DataBase.NULL) ;""
				
			} else if(ctype == MfUcd.SQLiteDataType.SQLITE_BLOB) {

				blobSize := DllCall("SQlite3\sqlite3_column_bytes", UInt, this._query, Int, _index, "Cdecl UInt")
				blobPtr := DllCall("SQlite3\sqlite3_column_blob", UInt, this._query, Int, _index, "Cdecl Ptr")

				if ( blobPtr )
				{
					fields.Add(MfUcd.MfMemoryBuffer.Create( blobPtr, blobSize ))
				}else{
					fields.Add(MfUcd.DataBase.NULL)
				}
			} else {
				strPtr := DllCall("SQlite3\sqlite3_column_text", UInt, this._query, Int, _index, "Cdecl UInt")
				fields.Add(StrGet(strPtr, "UTF-8"))
			}
		} 
		
		this._currentRow := new MfUcd.Row(this.getColumnNames(), fields)
		this._currentIndex++
		return true
	}
	
	

	Reset() {
		this.ErrorMsg := ""
		this.ErrorCode := 0
		
		if (!this._query) {
			this.ErrorMsg := MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Invalid_Handle_Query","DATA")
			return false
		}
		rc := DllCall("SQlite3\sqlite3_reset", UInt, this._query, "Cdecl Int")

		if (rc) {
			this.ErrorMsg := This._db.ErrMsg()
			this.ErrorCode := rc
			return false
		}
		this._currentIndex := 0
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

