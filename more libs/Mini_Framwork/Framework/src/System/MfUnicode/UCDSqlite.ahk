; Namespace MfUcd
Class UCDSqlite extends MfResourceSingletonBase
{
	static _instance := "" ; Static var to contain the singleton instance
	m_conn		:= Null
	m_Db		:= Null
	m_SQL		:= Null
	__New() 
	{
		SqliteDllPrefix := (A_PtrSize == 8) ? "\x64" : ""
		SqliteDllPath := MfString.Format("{0}{1}\sqlite3.dll", MfEnvironment.Instance.ResourceFolder, SqliteDllPrefix)
		if (!FileExist(SqliteDllPath)) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("IO.FileNotFound"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		this.m_conn := MfString.Format("{0}\ucd.db", MfEnvironment.Instance.ResourceFolder)
		if (!FileExist(this.m_conn)) {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("IO.FileNotFound"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		; init sqlite to use sqlite3.dll from resource folder
		MfUcd.SQLite_DLLPath(SqliteDllPath)
		
	}
;{ 	Properties
	
	Db[]
	{
		get {
			if (MfNull.IsNull(this.m_Db)) {
				this.m_Db := MfUcd.MfDataBaseFactory.OpenDataBase("SQLite", this.m_conn)
			}
			return this.m_Db
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
	GetUnicodeGeneralCategory(iChar) {
		if (!Mfunc.IsNumeric(iChar)) {
			return Null
		}
		WasFormat := A_FormatInteger
		SetFormat, IntegerFast, D
		cCode := iChar + 0 ; convert to dec if needed
		SetFormat,IntegerFast, %WasFormat%
		_value := Null

		this.m_SQL := MfString.Format( "SELECT {0}, {1} FROM {2} WHERE {0} = {3};"
			, this.QuoteIdentifier("cp")
			, this.QuoteIdentifier("gc")
			, this.QuoteIdentifier("repertoire")
			, iChar)
		try {
			rs := this.RunSQL(this.m_SQL)
			; rs is already on the first record by default
			;~ rs.MoveNext()
			_value := rs.CurrentRow.Column["gc"]
		} catch e {
			ex := new MfException(MfString.Format(MfEnvironment.Instance.GetResourceString("Exception_Error"), A_ThisFunc), e)
			ex.Source	:= A_ThisFunc
			ex.File		:= A_LineFile
			ex.Line		:= A_LineNumber
			throw ex
		} 
		return _value
			
	}
	
	; If the character has the property value Numeric_Type=Digit, then the Numeric_Value of that
	; digit is represented with an integer value (limited to the range 0..9) in fields 7 and 8, and field 6 is null.
	;
	; http://www.unicode.org/reports/tr44/#Numeric_Type
	; http://www.unicode.org/Public/3.0-Update/UnicodeData-3.0.0.html
	; Field 6: Decimal digit value	(De)
	; Field 7: Digit value			(Di)
	; Field 8: Numeric value		(Nu)
	GetDigitValue(iChar) {
		; http://www.fileformat.info/info/unicode/category/Nd/list.htm
		retval := -1
		if (!Mfunc.IsNumeric(iChar)) {
			return retval
		}
		try {
			_row := this._GetNV(iChar)
			; Nd = DecimalDigitNumber
			; De=Decimal
			_nt := _row.Column["nt"]
			_gc := _row.Column["gc"]
			if (((_gc = "Nd") || (_gc = "Nl") || (_gc = "No")) && ((_nt = "De") || (_nt = "Di")) ) {
				_value := _row.Column["nv"]
				if ((Mfunc.IsInteger(_value) = true) && (_value >= 0) && (_value <=9)) {
					retval := _value
				}
			}
		} catch e {
			ex := new MfException(MfString.Format(MfEnvironment.Instance.GetResourceString("Exception_Error"), A_ThisFunc), e)
			ex.Source	:= A_ThisFunc
			ex.File		:= A_LineFile
			ex.Line		:= A_LineNumber
			throw ex
		} 
		return retval
	}
	
	; If the character has the property value Numeric_Type=Decimal, 
	; then the Numeric_Value of that digit is represented with an integer
	; value (limited to the range 0..9) in fields 6, 7, and 8.
	;
	; http://www.unicode.org/reports/tr44/#Numeric_Type
	; http://www.unicode.org/Public/3.0-Update/UnicodeData-3.0.0.html
	; Field 6: Decimal digit value	(De)
	; Field 7: Digit value			(Di)
	; Field 8: Numeric value		(Nu)
	GetDecimalDigitValue(iChar) {
		retval := -1
		if (!Mfunc.IsNumeric(iChar)) {
			return retval
		}
		try {
			_row := this._GetNV(iChar)
			; Nd = DecimalDigitNumber
			; De=Decimal
			_nt := _row.Column["nt"]
			_gc := _row.Column["gc"]
			;~ if ((_row.Column["gc"] = "Nd") && ((_nt = "De") || (_nt = "Di") || (_nt = "Nu"))) {
			if ((_gc = "Nd") && (_nt = "De")) {
				_value := _row.Column["nv"]
				if ((Mfunc.IsInteger(_value) = true) && (_value >= 0) && (_value <=9)) {
					retval := _value
				}
			}
		} catch e {
			ex := new MfException(MfString.Format(MfEnvironment.Instance.GetResourceString("Exception_Error"), A_ThisFunc), e)
			ex.Source	:= A_ThisFunc
			ex.File		:= A_LineFile
			ex.Line		:= A_LineNumber
			throw ex
		} 
		return retval
	}
	; Get value from database for nv.
	; Returns Row containing Column as key and field as value
	
	GetNumericValue(iChar) {
		retval := -1
		if (!Mfunc.IsNumeric(iChar)) {
			return retval
		}
		try {
			_row := this._GetNV(iChar)
			_gc := _row.Column["gc"]
			if ((_gc = "Nd") || (_gc = "No") || (_gc = "Nl")) {
				_nt := _row.Column["nt"]
				if ((_nt = "De") || (_nt = "Di")) {
					_value := _row.Column["nv"]
					if ((Mfunc.IsInteger(_value) = true) && (_value >= 0) && (_value <=9)) {
						retval := _value
					}
				} else if (_nt = "Nu") {
					_value := _row.Column["nv"]
								
					if (RegExMatch(_value, "^\s*-?\d+\s*$")) {
						; whole number found. Just in case clean it up
						retval := Trim(_value)
					} else {
						try {
							retval :=this.FractionToDec(_value)
						} catch e {
							retval := -1
						}
					}
				}
			}
				
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.Source	:= A_ThisFunc
			ex.File		:= A_LineFile
			ex.Line		:= A_LineNumber
			throw ex
		}
		return retval
	}
	_GetNV(iChar) {
		; http://www.fileformat.info/info/unicode/category/Nd/list.htm
		if (!Mfunc.IsNumeric(iChar)) {
			return Null
		}
		WasFormat := A_FormatInteger
		SetFormat, IntegerFast, D
		cCode := iChar + 0 ; convert to dec if needed
		cCode .= "" ; Necessary due to the "fast" mode.
		SetFormat,IntegerFast, %WasFormat%
		_row := Null
		; SELECT `cp`,`gc`, `nt`, `nv` FROM `repertoire` WHERE `cp`=57;
		this.m_SQL := MfString.Format( "SELECT {0}, {1}, {2}, {3} FROM {4} WHERE {0} = {5};"
			, this.QuoteIdentifier("cp")
			, this.QuoteIdentifier("gc")
			, this.QuoteIdentifier("nt")
			, this.QuoteIdentifier("nv")
			, this.QuoteIdentifier("repertoire")
			, iChar)
		try {
			rs := this.RunSQL(this.m_SQL)
			; rs is already on the first record by default
			;~ rs.MoveNext()
			_row := rs.CurrentRow ; .Column["nv"]
		} catch e {
			ex := new MfException(MfString.Format(MfEnvironment.Instance.GetResourceString("Exception_Error"), A_ThisFunc), e)
			ex.Source	:= A_ThisFunc
			ex.File		:= A_LineFile
			ex.Line		:= A_LineNumber
			throw ex
		} 
		return _row
	}
;{ 	FractionToDec
/*
	Function: FractionToDec(strF)
		FractionToDec() Converts a fraction string into a decimal
	Parameters:
		strF - The string containing the fraction to convert
	Remarks:
		This function allows whitespace to be in the *strF*
	Returns:
		Returns a decimal value representing the converted fraction
	Throws:
		Throws Exception if invalid fraction
*/
	FractionToDec(strF) {
		If (!RegExMatch(strF,"S)^\s*(-?\d+)\s*/\s*(-?\d+)\s*$", Field)) {
			ex := new MfException(MfEnvironment.Instance.GetResourceStringBySection("Exception_Invalid_Fraction","DATA", strF))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
        If (Field2 = 0) {
			ex := new MfException(MfEnvironment.Instance.GetResourceStringBySection("Exception_Invalid_Denominator","DATA", Field2))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
        _Numerator := Field1
        _Denominator := Field2
		return _Numerator / _Denominator
	}
; 	End:FractionToDec ;}
;{ GetInstance
    /*!
        Method: GetInstance()
            GetInstance() Gets the instance of the Singleton for MfEnvironment  
            Overrides [MfSingletonBase.GetInstance](MfSingletonBase.GetInstance.html) method.
        Returns:
            Returns Singleton instance for the MfEnvironment class.
    */
    GetInstance() { ; Overrides base
        if (MfNull.IsNull(MfUcd.UCDSqlite._instance)) {
            MfUcd.UCDSqlite._instance := new MfUcd.UCDSqlite()
        }
        return MfUcd.UCDSqlite._instance
    }
; End:GetInstance ;}
;{ 	DestroyInstance()
    /*!
        Method: DestroyInstance()
            DestroyInstance() Set current instance of cm[MfEnvironment](MfEnvironment.html) singleton class to null.  
            Overrides [MfResourceSingletonBase](MfResourceSingletonBase.html) Method.
        Remarks:
            `DestroyInstance()` is an abstract method and must be implemeted in derived class.
        Example:
            > static _instance := Null ; set up class global var to hold instance of myClass.
            > 
            > GetInstance() { ; overrides from MfSingletonBase
            > 	if (MfNull.IsNull(myClass._instance)) {
            > 		myClass._instance = new myClass()
            > 	}
            > 	return myClass._instance
            > }
            > 
            > DestroyInstance() { ; overrides from MfSingletonBase
            > 	myClass._instance := "" ; releases myClass._instance to free memory
            > }
        Throws:
            Throws [MfNotImplementedException](MfNotImplementedException.html) if not implemented in derived class.
    */
	DestroyInstance() {
		this.m_Db := Null
	}
; End:DestroyInstance() ;}
;{ 	Is()				- Overrides - MfSingletonBase
	/*!
		Method: Is(ObjType)
			Is() Gets if current *instance* of *object* is of the same type.  
			Overrides [MfSingletonBase.Is()](MfSingletonBase.is.html)
		Parameters:
			ObjType - The object to compare this *instance* type with
				Type can be an *instance* of [MfType](MfType.html) or an object derived from
				[MfSingletonBase](MfSingletonBase.html) or an *instance* of 
				or a string containing the name of the object
				type such as "MfObject"
		Remarks:
			If a string is used as the Type case is ignored so "mfobject" is the same as "MfObject"
		Returns:
			Returns **true** if current *object* *instance* is of the same type as the Type Paramater
			otherwise **false**
	*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "UCDSqlite") {
			return true
		} 
		if (typeName = "MfUcd.UCDSqlite") {
			return true
		}
		return base.Is(typeName)
	}
;	End:Is() ;}

	QuoteIdentifier(identifier) {
		; ` characters are actually valid. Technically everthing but a literal null U+0000.
		; Everything else is fair game: http://dev.mysql.com/doc/refman/5.0/en/identifiers.html
		StringReplace, identifier, identifier, ``, ````, All
		return "``" identifier "``"
	}
	
	RunSQL(SQL){
		rs := Null
		try {
			rs := this.Db.OpenRecordSet(SQL)
		} catch e {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceStringBySection("NotSupportedException_DbConnection_ORS"
				,"DATA"), e)
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		return rs
	}
}