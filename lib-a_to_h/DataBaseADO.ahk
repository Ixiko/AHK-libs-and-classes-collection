;namespace DBA

/*
	Represents a Connection to a ADO Database
*/
class DataBaseADO extends DBA.DataBase
{
	_connection := null
	_connectionData := ""
	
	__New(connectionString){
		this._connectionData := connectionString
		this.Connect()
	}
	
	/*
		(Re) Connects to the db with the given creditals
	*/
	Connect(){
		if(IsObject(this._connection))
		{
			this.Close()
		}
		this._connection := ComObjCreate("ADODB.connection")
		
		;connection.Open connectionstring,userID,password,options
		this._connection.Open(this._connectionData)
	}
	
	Close(){
		if(this.IsConnected())
		{
			this._connection.Close()
			this._connection := null
		}
	}
	
	/*
	* Is this connection open?
	*/
	IsConnected(){
		static ObjectStateEnum_adStateClosed := 0
		
		if(IsObject(this._connection))
		{
			return  (this._connection.State != ObjectStateEnum_adStateClosed)
		}
		return false
	}
	
	IsValid(){
		return IsObject(this._connection)
	}
	
	GetLastError(){
		; todo
	}
	
	GetLastErrorMsg(){

		errMsg := ""
		for objErr in this._connection.Errors
		{
			errMsg .= objErr.Number " " objErr.Description " Source:" objErr.Source "`n"
		}
		
		return errMsg
	}
	
	SetTimeout(timeout = 1000){
		if(this.IsValid())
			this._connection.ConnectionTimeout := (timeout / 1000)
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
		return new DBA.RecordSetADO(sql, this._connection, editable)
	}
	
	/*
		Querys the DB and returns a ResultTable or true/false
	*/
	Query(sql){
		ret := false
		if(this.IsValid())
		{
			;Execute( commandtext,ra,options)
			affectedRows := 0
			rs := this._connection.Execute(sql, affectedRows)
			if(IsObject(rs) && rs.State != ADO.ObjectStateEnum.adStateClosed)
			{
				ret := this.FetchADORecordSet(rs)
				rs.Close()
			}else{
				ret := affectedRows
			}
		}
		return ret
	}	
	
	EscapeString(str){
		return Mysql_escape_string(str)
	}
	
	
	BeginTransaction(){
	  if(this.IsValid())
		this._connection.BeginTrans()
	}
	
	EndTransaction(){
	  if(this.IsValid())
		this._connection.CommitTrans()
	}
	
	Rollback(){
	  if(this.IsValid())
		this._connection.RollbackTrans()
	}
	
	FetchADORecordSet(adoRS){
		tbl := null
		if(IsObject(adoRS) && !adoRS.EOF)
		{
			columnNames := new Collection()
			myRows := new Collection()


			for field in adoRS.Fields
				columnNames.add(field.Name)
		
			fetchedArray := adoRS.GetRows() ; returns a COM-SafeArray Wrapper
			colSize := fetchedArray.MaxIndex(1) + 1
			rowSize := fetchedArray.MaxIndex(2) + 1
			
			loop, % rowSize
			{
				i := A_index - 1
				datafields := new Collection()
				loop, % colSize
				{
					j := A_index - 1
					datafields.add(fetchedArray[j,i])
				}
				myRows.Add(new DBA.Row(columnNames, datafields))
			}
			
			tbl := new DBA.Table(myRows, columnNames)
		}
		return tbl
	}
	
	InsertMany(records, tableName){
		
		;objRecordset.Open source,actconn,cursortyp,locktyp,opt
	
		rs := ComObjCreate("ADODB.Recordset")
		/* batch 
		rs.Open(tableName, this._connection, ADO.CursorType.adOpenKeyset, ADO.LockType.adLockBatchOptimistic, ADO.CommandType.adCmdTable)

		for each, record in records
		{
			rs.AddNew()
			
			for column, value in record
			{
				rs.Fields[column].Value := value
			}
		}
		rs.UpdateBatch()
		*/
		
		rs.Open(tableName, this._connection, ADO.CursorType.adOpenKeyset, ADO.LockType.adLockOptimistic, ADO.CommandType.adCmdTable)

		for each, record in records
		{
			rs.AddNew()
			
			for column, value in record
			{
				rs.Fields[column].Value := value
			}
			rs.Update()
		}

		rs.Close()
	}
	
	Insert(record, tableName){
		records := new Collection()
		records.Add(record)
		return this.InsertMany(records, tableName)
	}

}
