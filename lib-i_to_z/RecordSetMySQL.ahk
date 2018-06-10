;namespace DBA

/*
	Represents a result set of an MySQL Query
*/
class RecordSetMySQL extends DBA.RecordSet
{
	_colNames := 0		; Collection<ColumnNames>
	_colCount := 0
	_query := 0			; ptr to Resultset/Query
	_db	:= 0			; ptr to DataBase
	_eof := false		; bool 
	CurrentRow := 0		; int - row number


	__New(db, requestResult){
		this._db := db
		this._query := requestResult
		
		if(this._query != 0){
			this._colNames := this.getColumnNames()
			this.MoveNext()
		}
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
		mysqlFields := MySQL_fetch_fields(this._query)
		colNames := new Collection()
		i := 0
		for each, mysqlField in mysqlFields
		{
			colNames.Add(mysqlField.Name())
			i++
		}
		this._colCount := i
		return colNames
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
		
		rowptr := MySQL_fetch_row(this._query)
		if (!rowptr){
			; // we reached eof
			this.ErrorMsg := "RecordSet is empty! (eof)"
			this.ErrorCode := 1
			this._eof := true
			return false
		}
		
		lengths := MySQL_fetch_lengths(this._query)
		datafields := new Collection()
		Loop % this._colCount
		{
			length := GetUIntAtAddress(lengths, A_Index - 1)
			fieldPointer := GetPtrAtAddress(rowptr, A_Index - 1)
			fieldValue := StrGet(fieldPointer, length, "CP0")
			datafields.Add(fieldValue)
		}
		this._currentRow := new DBA.Row(this._colNames, datafields)
		this.CurrentRow++
		return true
	}
	
	

	Reset() {
		throw Exception("Not Supported!",-1)
	}

	
	Close() {
		this.ErrorMsg := ""
		this.ErrorCode := 0
		if(this._query == 0)
			return true
		
		MySQL_free_result(this._query)
		
		this._query := 0
		return true
	}
}

