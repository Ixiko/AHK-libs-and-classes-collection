GetEnvironmentVariables()
{
	; Creates a set of variables to match Windows environment variables
	; MsgBox params: %params%


	; declare local, global, static variables
	Global


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters


		; initialise variables


		; create a list of environment variables
		EnvVarList =
		( LTrim Comment Join,
			ALLUSERSPROFILE
			APPDATA
			COMMONPROGRAMFILES
			COMMONPROGRAMFILES(X86)
			COMMONPROGRAMW6432
			COMPUTERNAME
			; COMSPEC
			FP_NO_HOST_CHECK
			HOMEDRIVE
			HOMEPATH
			LOCALAPPDATA
			LOGONSERVER
			NUMBER_OF_PROCESSORS
			OS
			PATH
			PATHEXT
			PCBRAND
			PLATFORM
			PROCESSOR_ARCHITECTURE
			PROCESSOR_IDENTIFIER
			PROCESSOR_LEVEL
			PROCESSOR_REVISION
			PROGRAMDATA
			; PROGRAMFILES
			PROGRAMFILES(X86)
			PROGRAMW6432
			PROMPT
			PSMODULEPATH
			PUBLIC
			SESSIONNAME
			SYSTEMDRIVE
			SYSTEMROOT
			TEMP
			TMP
			USERDOMAIN
			USERNAME
			USERPROFILE
			VS110COMNTOOLS
			VS120COMNTOOLS
			WINDIR
		)
		
		Loop, Parse, EnvVarList, CSV
		{
			; create without parentheses
			EnvVarValue := A_LoopField
			EnvVarName := StrReplace(StrReplace(A_LoopField,"(",""),")","")
			EnvGet, %EnvVarName%, %EnvVarValue%
			
			; also create a version without underscores
			EnvVarName := StrReplace(EnvVarName,"_","")
			EnvGet, %EnvVarName%, %EnvVarValue%
		}

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing

#NoEnv

AllUsersProfile        := ""
AppData                := ""
CommonProgramFiles     := ""
CommonProgramFilesx86  := ""
CommonProgramW6432     := ""
ComputerName           := ""
Fp_No_Host_Check       := ""
FpNoHostCheck          := ""
HomeDrive              := ""
HomePath               := ""
LocalAppData           := ""
LogonServer            := ""
Number_Of_Processors   := ""
NumberOfProcessors     := ""
OS                     := ""
Path                   := ""
PathExt                := ""
PcBrand                := ""
Platform               := ""
Processor_Architecture := ""
Processor_Identifier   := ""
Processor_Level        := ""
Processor_Revision     := ""
ProgramData            := ""
ProgramFilesx86        := ""
ProgramW6432           := ""
Prompt                 := ""
PsModulePath           := ""
Public                 := ""
SessionName            := ""
SystemDrive            := ""
SystemRoot             := ""
Temp                   := ""
Tmp                    := ""
UserDomain             := ""
UserName               := ""
UserProfile            := ""
VS110ComnTools         := ""
VS120ComnTools         := ""
WinDir                 := ""

GetEnvironmentVariables()

MsgBox
, AllUsersProfile        : %ALLUSERSPROFILE%`n
, AppData                : %APPDATA%`n
, CommonProgramFiles     : %CommonProgramFiles%`n
, CommonProgramFiles(x86): %CommonProgramFilesx86%`n
, CommonProgramW6432     : %CommonProgramW6432%`n
, ComputerName           : %COMPUTERNAME%`n
, ComSpec                : %ComSpec%`n
, Fp_No_Host_Check       : %FP_NO_HOST_CHECK%`n
, FpNoHostCheck          : %FP_NO_HOST_CHECK%`n
, HomeDrive              : %HOMEDRIVE%`n
, HomePath               : %HOMEPATH%`n
, LocalAppData           : %LOCALAPPDATA%`n
, LogonServer            : %LOGONSERVER%`n
, Number_Of_Processors   : %NUMBER_OF_PROCESSORS%`n
, NumberOfProcessors     : %NUMBER_OF_PROCESSORS%`n
, OS                     : %OS%`n
, Path                   : %Path%`n
, PathExt                : %PATHEXT%`n
, PcBrand                : %PCBRAND%`n
, Platform               : %Platform%`n
, Processor_Architecture : %PROCESSOR_ARCHITECTURE%`n
, Processor_Identifier   : %PROCESSOR_IDENTIFIER%`n
, Processor_Level        : %PROCESSOR_LEVEL%`n
, Processor_Revision     : %PROCESSOR_REVISION%`n
, ProgramData            : %ProgramData%`n
, ProgramFiles           : %ProgramFiles%`n
, ProgramFiles(x86)      : %ProgramFilesx86%`n
, ProgramW6432           : %ProgramW6432%`n
, Prompt                 : %PROMPT%`n
, PsModulePath           : %PSModulePath%`n
, Public                 : %PUBLIC%`n
, SessionName            : %SESSIONNAME%`n
, SystemDrive            : %SystemDrive%`n
, SystemRoot             : %SystemRoot%`n
, Temp                   : %TEMP%`n
, Tmp                    : %TMP%`n
, UserDomain             : %USERDOMAIN%`n
, UserName               : %USERNAME%`n
, UserProfile            : %USERPROFILE%`n
, VS110ComnTools         : %VS110COMNTOOLS%`n
, VS120ComnTools         : %VS120COMNTOOLS%`n
, WinDir                 : %windir%`n

*/