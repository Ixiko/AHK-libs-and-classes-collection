;<< Error handling >>
exception(msg:="",r:="",depth:=0, legacyParameter_1:="",legacyParameter_2:=""){
	; This looks wierd, it has been changed, it was convenient to keep this format	
	throw new xlib.error(msg,r,depth,"obj") ; Might just change to throw here. (Seems so...)
}
getEnvironmentVersion(){
	; Used by core\initializeThreadpoolEnvironment
	; Used by core\setThreadpoolCallbackPriority	
	local OS := xlib.getOsVersion() ; major.minor
	if OS < 6.0			; Older than windows vista
		xlib.exception(OS . " not supported for thread pools, minimum OS is Windows Vista. ( 6.0 ) ")
	else if OS >= 6.1	; Newer or equal to win7
		return 3
	return 1			; Windows vista	
}

getOsVersion(major:=true, minor:=true, build:=false){
	/*
	Url:
		- https://msdn.microsoft.com/en-us/library/windows/desktop/ms724832(v=vs.85).aspx (Operating System Version)
	Operating system				Version number
	Windows 10						10.0*
	Windows Server 2016				10.0*
	Windows 8.1						6.3*
	Windows Server 2012 R2			6.3*
	Windows 8						6.2
	Windows Server 2012				6.2
	Windows 7						6.1
	Windows Server 2008 R2			6.1
	Windows Server 2008				6.0
	Windows Vista					6.0
	Windows Server 2003 R2			5.2
	Windows Server 2003				5.2
	Windows XP 64-Bit Edition		5.2
	Windows XP						5.1
	Windows 2000					5.0
	*/
	static OS := strSplit(A_OSVersion,".")
	return 	 	(major ? OS.1 : "")
			.	(minor ? OS.2 : "")
			.	(build ? OS.3 : "")
}

splitTypesAndArgs(typesAndArgs, byref decl, byref params){
	local
	decl := []		; function declaration
	params := []	; parameters to be passed to function
	l := typesAndArgs.length()
	if l & 1			; return type or cdecl specified
		l -= 1, ret := checkIfTypeSpecified( typesAndArgs.pop() )
	else
		ret := "int"	; default return type
	ind := 1
	loop l
		decl[ind] := typesAndArgs[a_index++]
		, params[ind] := typesAndArgs[a_index]
		, ind++
	decl.push ret
	checkIfTypeSpecified(str){
		local
		global xlib
		static del := [" ", "`t"]
		arr := strsplit(str, del)
		for k, v in arr
			try 
				if xlib.type.sizeof(v)
					return str
		return "int " str
	}
}

verifyCallback(callbackFunction){
	; currently not implemented
	return callbackFunction
}