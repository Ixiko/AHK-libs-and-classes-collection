class DataBaseFactory
{
	static AvaiableTypes := ["SQLite", "MySQL", "ADO"]
	
	/*
		This static Method returns an Instance of an DataBase derived Object
	*/
	OpenDataBase(dbType, connectionString){
		if(dbType = "SQLite")
		{
			OutputDebug, Open Database of known type [%dbType%]
			SQLite_Startup()
			;//parse connection string. for now assume its a path to the requested DB
			handle := SQLite_OpenDB(connectionString)
			
			if(handle == 0)
				throw Exception("SQLite: The connection to the the given Datebase could not be etablished. Is the following SQLite connection string valid?`n`n" connectionString,-1) 
			return new DBA.DataBaseSQLLite(handle)
			
		} if(dbType = "MySQL") {
			OutputDebug, Open Database of known type [%dbType%]
			MySQL_StartUp()
			conData := MySQL_CreateConnectionData(connectionString)
			return new DBA.DataBaseMySQL(conData)
		} if(dbType = "ADO") {
			OutputDebug, Open Database of known type [%dbType%]
			return new DBA.DataBaseADO(connectionString)
		} else {
			throw Exception("The given Database Type is unknown! [" . dbType "]",-1)
		}
	}
	
	__New(){
		throw Exception("This is a static class, dont instante it!",-1)
	}
}