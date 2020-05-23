; namespace MfUcd

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
;{ class Row
class Row extends MfObject
{
	m_Dic := Null
	__New(args*)
	{
		base.__New()
		this.m_Dic := new MfDictionary()
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 1) { ; message
			this._initDic(args[1])
		} else if (pCount = 2) { ; message, inner exception or message, param name
			this._intiColumnsFields(args[1] , args[2])
		} else if (pCount > 2) {
			msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload")
			ex := new MfNotSupportedException(MfString.Format(msg, A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			throw ex
		}
	}
	
	;	Creates a New Row.
	;	columns	:	Collection of the Columnames
	;	fields:	Collection of the Fields (Data)
	_intiColumnsFields(columns, fields) {
	
		if (!MfObject.IsObjInstance(columns, MfCollectionBase)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType","columns", "MfCollectionBase"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		if (!MfObject.IsObjInstance(fields, MfCollectionBase)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType","fields", "MfCollectionBase"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		if (columns.Count <> fields.Count) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Count_Not_Equal","columns","fields"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		
	
		_count := columns.Count		
		Loop, %_count%
		{
			_index := A_Index -1
			this.m_Dic.Add(columns.Item[_index], fields.Item[_index])
		}
	}
	
	_initDic(dicColFields) {
	
		if (!MfObject.IsObjInstance(dicColFields, MfDictionaryBase)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", "MfDictionaryBase"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		
		for k, v in dicColFields
		{
			this.m_Dic.Add(k,v)
		}
	}
	
;{ 	Properties
	Count[]
	{
		get {
			return this.m_Dic.Count
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
	
	Column[columnName]
	{
		get {
			if (!this.m_Dic.Contains(columnName)) {
				return Null
			}
			ret := this.m_Dic.Item[columnName]
			if (MfNull.IsNull(ret)) {
				return Null
			}
			return ret
		}
		set {
			this.m_Dic.Item[columnName] := (MfNull.IsNull(value) = true) ? MfIsNull.Null : value
			return value
		}
	}
	
	HasColumn(columnName)
	{
		return this.m_Dic.Contains(columnName)
	}
; 	End:Properties ;}
	
	ToString(){
		
		str := MfString.Empty
		_count := 0
		for k, v in this.m_Dic
		{
			_count ++
			str .= v
			if (_count < this.m_Dic.Count) {
				str .= ","
			}
		}
		return str
	}
		
	
	ContainsIndex(index){
		return ((index > 0) && (index <= this._fields.Count))
	}
	
	
	
	internalDictionary[]
	{
		get {
			return this.m_Dic
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
    __NewEnum() {
        return new MfUcd.Row.Enumerator(this)
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
		if (typeName = "Row") {
			return true
		}
        if (typeName = "MfUcd.Row") {
			return true
		} 
		return base.Is(typeName)
	}
; 	End:Is() ;}
;{ 		_NewEnum
	_NewEnum() {
        return new MfUcd.Row.Enumerator(this)
    }
; 		End:_NewEnum ;}
;{ 		class Enumerator
    class Enumerator
	{
		m_Parent := Null
		m_KeyEnum := Null
		m_index := 0
		m_count := 0
        __new(ParentClass) {
            
            this.m_Parent := ParentClass
			this.m_KeyEnum := this.m_Parent.internalDictionary.Keys
			if (this.m_KeyEnum) {
				this.m_count := this.m_KeyEnum.Count
			}
        }
        
       Next(ByRef key, ByRef value)
	   {
		
			if (this.m_index < this.m_count) {
				key := this.m_KeyEnum.Item[this.m_index]
				value := this.m_Parent.Column[key]
			}
			this.m_index++
			if (this.m_index > (this.m_count)) {
				return 0
			} else {
				return true
			}
        }
		
		
    }
; 		End:class Enumerator ;}
}
; End:class Row ;}

/*
	row := table[index]
*/

class Table extends MfObject
{
;{ 	Constructor
	/*
		Creates a New Table.
		rows:	Collection of the Rows (Data)
		columns	:	Collection of the Columnames
	*/
	__New(rows, columns){
		base.__New()
		if (!MfObject.IsObjInstance(rows, MfCollectionBase)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", "MfCollectionBase"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		if (!MfObject.IsObjInstance(columns, MfEnumerableBase)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", "MfCollectionBase"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
				
		this.m_Rows := rows
		this.m_Columns := columns
	}
; 	End:Constructor ;}

;{ Properties
	m_Rows		:= new MfCollection()
	Rows[]
	{
		get {
			return this.m_Rows
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
	
	m_Columns		:= new MfCollection()
	Columns[]
	{
		get {
			return this.m_Columns
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}

; End:Properties ;}
;{ 	Is()
	/*
		Function: Is(ObjType)
			Is() Gets if current *instance* of Table
			is of the same type.  
			Overrides MfObject
		Parameters:
			ObjType - The *object* to compare this *instance* of
				Table with Type can be an *instance* of Table or an *object* derived from Table
		Remarks:
			If a string is used as the Type case is ignored so "mfobject" is the same as "MfObject"
		Returns:
			Returns **true** if **Type** Parameter is of the same type as current
			Row *instance* or any of its base types otherwise **false**
	*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "Table") {
			return true
		}
        if (typeName = "MfUcd.Table") {
			return true
		} 
		return base.Is(typeName)
	}
; 	End:Is() ;}
	Count(){
		return this.Rows.Count
	}
	
	ToString(){
		colstr := this.Columns.ToString()
		StringReplace, colstr, colstr, `n, |
		return "(" this.Rows.Count() ")" . colstr
	}

    __NewEnum() {
        return ObjNewEnum(this.rows)
    }
}

class DataBase extends MfObject
{
	static NULL := Object()
	static TRUE := Object()
	static FALSE := Object()
	
	__New()
	{
		base.__New()
	}
	__delete() {
		this.Close()
	}
	
	IsValid(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
		
	}
	
	Query(sql){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
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
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	ToSqlLiteral(value) {
		if (IsObject(value)) {
			if (value == MfUcd.DataBase.NULL)
				return "NULL"
			if (value == MfUcd.DataBase.TRUE)
				return "TRUE"
			if (value == MfUcd.DataBase.FALSE)
				return "FALSE"
		}
		return "'" this.EscapeString(value) "'"
	}
	
	EscapeString(string){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	QuoteIdentifier(identifier){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	BeginTransaction(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	EndTransaction(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	Rollback(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	Insert(record, tableName){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	InsertMany(records, tableName){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	Update(fields, constraints, tableName, safe = True){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	Close(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
;{ 	Is()
	/*
		Function: Is(ObjType)
			Is() Gets if current *instance* of DataBase
			is of the same type.  
			Overrides MfObject
		Parameters:
			ObjType - The *object* to compare this *instance* of
				DataBase with Type can be an *instance* of DataBase or an *object* derived from DataBase
		Remarks:
			If a string is used as the Type case is ignored so "mfobject" is the same as "MfObject"
		Returns:
			Returns **true** if **Type** Parameter is of the same type as current
			DataBase *instance* or any of its base types otherwise **false**
	*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "DataBase") {
			return true
		}
        if (typeName = "MfUcd.DataBase") {
			return true
		} 
		return base.Is(typeName)
	}
; 	End:Is() ;}
}

class RecordSet extends MfObject
{
	__New()
	{
		base.__New()
	}
	_currentRow := null 	; Row
;{ 	Properties
	CurrentRow[]
	{
		get {
			return this._currentRow
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:Properties ;}
	__delete() {
		this.Close()
	}
	
	TestRecordSet(){
		return "I'm a RecordSet, for sure."
	}
	
	AddNew(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	MoveNext(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	Delete(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	Update(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	Close(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	getEOF(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	IsValid(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	getColumnNames(){
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	
	getCurrentRow(){
		return this._currentRow
	}
	
;{ 	Is()
	/*
		Function: Is(ObjType)
			Is() Gets if current *instance* of RecordSet
			is of the same type.  
			Overrides MfObject
		Parameters:
			ObjType - The *object* to compare this *instance* of
				DataBase with Type can be an *instance* of RecordSet or an *object* derived from RecordSet
		Remarks:
			If a string is used as the Type case is ignored so "mfobject" is the same as "MfObject"
		Returns:
			Returns **true** if **Type** Parameter is of the same type as current
			RecordSet *instance* or any of its base types otherwise **false**
	*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "RecordSet") {
			return true
		}
        if (typeName = "MfUcd.RecordSet") {
			return true
		} 
		return base.Is(typeName)
	}
; 	End:Is() ;}
}