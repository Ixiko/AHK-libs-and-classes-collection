Install := { Error_NonAdministrator:	0x01
			,Error_InvalidParameters:	0x02
			,Error_NonExistantFile:		0x03
			,Error_NonExistantDir:		0x04
			,Error_Extraction:			0x05
			,Error_CopyToStdLib:	 	0x06
			,Error_CreateRepoDir:		0x07
			,Error_CreateRepoSubDir:	0x08
			,Error_CreateArchiveDir:	0x09
			,Error_ArchiveBackup:		0x0A
			,Error_DeleteStdLib:		0x0B
			,Error_DeleteStdLibSubDir:	0x0C
			,Error_DeleteRepoSubDir:	0x0D
			,Error_ToolInstallScript:	0x0E
			,Error_ToolRemoveScript:	0x0F
			,Error_AhkVersionInvalid:	0x10
			,Error_NoAction:			0x11
			,Error_RunInstaller: "ERROR"
			,Success: 0xDEAD } ;random chosen value, "Maximum" value is 0x80000000
			;see http://msdn.microsoft.com/en-us/library/system.environment.exitcode.aspx
Install_ExitCode(e) {
	global Install
	for i, code in Install
		if (e==code)
			return i
	return "Error_Unknown"
}