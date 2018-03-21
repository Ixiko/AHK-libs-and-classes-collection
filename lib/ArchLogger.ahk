#Include <Base>

class ArchLogger
{
	static Logger := new _ArchLoggerFile()
	
	SetLogger(newLogger){
		ArchLogger.Logger := newLogger
	}
	
	Log(msg){
		date := A_DD "." A_MM "." A_YYYY
		time := A_Hour ":" A_Min
		
		ArchLogger.Logger.Log("# " date " ( " time " ) " msg)
	}
}

class _ArchLoggerCallBack
{
	callBack := null
	
	Log(msg){
		this.callBack.( msg )
	}
	
	__new(callBackFunction){
		this.callBack := callBackFunction
	}
}

class _ArchLoggerFile
{
	logpath := A_ScriptDir "\" A_ScriptName ".log"
	
	Log(msg){
		
		FileAppend, %msg%`n, % this.logpath
	}
}