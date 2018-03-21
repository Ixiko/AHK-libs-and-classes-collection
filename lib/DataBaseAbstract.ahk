; namespace DBA

/*
#####################################################################################
	Abstract Database Classes
	Base for all concrete implementations for the supported DataBases.
#####################################################################################
*/

/*
	data := Row[index]
	data := Row["ColumnName"]
*/

class Row
{
	_columns := 0
	_fields := new Collection()
	
	Count(){
		return this._fields.Count()
	}
	
	ToString(){
		return this._fields.ToString()
	}
	
	__Get(param){
		
		if(IsObject(param)){
			throw Exception("Expected Index or Column Name!", -1)
		}
		
		if(!IsObjectMember(this, param)){
			if param is Integer
			{
				; // assume that an indexed access is desired
				; // return the corresponding ROW
				if(this.ContainsIndex(param))
					return this._fields[param]
			} else {
				; // assume that an columnname access is desired
				; // find index
				
				index := 0
				for i, col in this._columns
				{
					if(col = param){
						index := i
						break
					}
				}
				if(this.ContainsIndex(index)){
					return this._fields[index]
				}
			}
		}
	}
	
	ContainsIndex(index){
		return ((index > 0) && (index <= this._fields.Count()))
	}
	
	
	;	Creates a New Row.
	;	columns	:	Collection of the Columnames
	;	fields:	Collection of the Fields (Data)
	__New(columns, fields){

		if(!is(columns, "Collection")){
			throw Exception("columns must be a Collection Object",-1)
		}
		
		if(!is(fields, "Collection")){
			throw Exception("fields must be a Collection Object",-1)
		}
		
		
		this._fields := fields
		this._columns := columns
	}
    
    __NewEnum() {
        return new DBA.Row.Enumerator(this)
    }
    
    class Enumerator {
        __new(row) {
            this.columnEnum := ObjNewEnum(row.columns)
            this.fieldEnum := ObjNewEnum(row.fields)
        }
        
        next(ByRef key, ByRef val) {
            return this.columnEnum.next("", key)
                && this.fieldEnum.next("",val)
        }
    }
}


/*
	row := table[index]
*/

class Table
{
	Rows := new Collection()
	Columns := new Collection()
	
	Count(){
		return this.Rows.Count()
	}
	
	ToString(){
		colstr := this.Columns.ToString()
		StringReplace, colstr, colstr, `n, |
		return "(" this.Rows.Count() ")" . colstr
	}
	
	__Get(param){
		
		if(IsObject(param)){
			throw Exception("Expected non-Object Index!",-1)
		}
		if(!IsObjectMember(this, param)){
			if param is Integer
			{
				; // assume that an indexed access is desired
				; // return the corresponding ROW
				if((param > 0) && (param < this.Rows.Count()) )
					return this.Rows[param]
			}
		}
	}
	
	/*
		Creates a New Table.
		rows:	Collection of the Rows (Data)
		columns	:	Collection of the Columnames
	*/
	__New(rows, columns){

		if(!is(rows, "Collection")){
			throw Exception("rows must be a Collection Object",-1)
		}
		
		if(!is(columns, "Collection")){
			throw Exception("rows must be a Collection Object",-1)
		}
		
		this.Rows := rows
		this.Columns := columns
	}
    
    __NewEnum() {
        return ObjNewEnum(this.rows)
    }
}

class DataBase
{
	static NULL := Object()
	static TRUE := Object()
	static FALSE := Object()
	
	__delete() {
		this.Close()
	}
	
	IsValid(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	Query(sql){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	QueryValue(sQry){
		rs := this.OpenRecordSet(sQry)
		value := rs[1]
		rs.Close()
		return value
	}
	
	QueryRow(sQry){
		rs := this.OpenRecordSet(sQry)
		myrow := rs.getCurrentRow()
		rs.Close()
		return myrow
	}
	
	OpenRecordSet(sql, editable = false){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	ToSqlLiteral(value) {
		if (IsObject(value)) {
			if (value == DBA.DataBase.NULL)
				return "NULL"
			if (value == DBA.DataBase.TRUE)
				return "TRUE"
			if (value == DBA.DataBase.FALSE)
				return "FALSE"
		}
		return "'" this.EscapeString(value) "'"
	}
	
	EscapeString(string){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	QuoteIdentifier(identifier){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	BeginTransaction(){
		throw Exceptions.MustOverride( this.__Class "." A_ThisFunc)
	}
	
	EndTransaction(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	Rollback(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	Insert(record, tableName){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	InsertMany(records, tableName){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	Update(fields, constraints, tableName, safe = True){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	Close(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
}

class RecordSet
{
	_currentRow := null 	; Row
	
	__delete() {
		this.Close()
	}
	
	TestRecordSet(){
		return "I'm a RecordSet, for sure."
	}
	
	AddNew(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	MoveNext(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	Delete(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	Update(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	Close(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	getEOF(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	IsValid(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	getColumnNames(){
		throw Exceptions.MustOverride(this.__Class "." A_ThisFunc)
	}
	
	getCurrentRow(){
		return this._currentRow
	}
	
	__Get(param){
		
		if(IsObject(param)){
			throw Exception("Expected Index or Column Name!",-1)
		}

		if(param = "EOF")
			return this.getEOF()


		if(!IsObjectMember(this, param) && param != "_currentRow"){

			if(!is(this._currentRow, DBA.Row))
				return ""
				
			;// assume memberaccess are the column names/indexes
			return this._currentRow[param]
		}
	}
}