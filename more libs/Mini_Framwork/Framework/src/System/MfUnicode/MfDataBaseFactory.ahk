; namespace MfUcd

class MfDataBaseFactory
{
	static AvaiableTypes := ["SQLite"]
	
	/*
		This static Method returns an Instance of an DataBase derived Object
	*/
	OpenDataBase(dbType, connectionString){
		if(dbType = "SQLite")
		{
			;~ OutputDebug, Open Database of known type [%dbType%]
			MfUcd.SQLite_Startup()
			;//parse connection string. for now assume its a path to the requested DB
			handle := MfUcd.SQLite_OpenDB(connectionString)
			
			if(handle == 0)
			{
				ex := new MfException(MfEnvironment.Instance.GetResourceStringBySection("Exception_Database_Connection"
					, "DATA"), "SQLite", MfEnvironment.Instance.NewLine, connectionString) 
				ex.Source := A_ThisFunc
				ex.File := A_LineFile
				ex.Line := A_LineNumber
				throw ex
			}
			return new MfUcd.DataBaseSQLLite(handle)
			
		} else {
			ex := new  MfException(MfEnvironment.Instance.GetResourceStringBySection("Exception_Db_Unknow_Db_Type","DATA", dbType))
			
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
	}
	
	__New(){
		throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Static_Class", "MfUcd.MfDataBaseFactory"))
	}
}