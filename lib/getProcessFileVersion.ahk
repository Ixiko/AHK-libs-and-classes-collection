getProcessFileVersion(process)
{
	process, exist, %process%
	If (!pid := ErrorLevel)
		return 0
	; msdn states ComObjGet( "winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2" )
	; Could have also used the process name ie -  ("Select * from Win32_Process where Name= '" process "'" )
	for Item in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId="  pid)
	{
		; There should (can) only be one SC2, but let it iterate what it finds anyway
		aInfo := fileGetVersionInfo(Item.ExecutablePath)
		if aInfo.FileVersion
			return aInfo.FileVersion
	}	
	return 0
}

/*
Win32_Process class
http://msdn.microsoft.com/en-us/library/aa394372.aspx

[Provider("CIMWin32")]class Win32_Process : CIM_Process
{
  string   Caption;
  string   CommandLine;
  string   CreationClassName;
  datetime CreationDate;
  string   CSCreationClassName;
  string   CSName;
  string   Description;
  string   ExecutablePath;
  uint16   ExecutionState;
  string   Handle;
  uint32   HandleCount;
  datetime InstallDate;
  uint64   KernelModeTime;
  uint32   MaximumWorkingSetSize;
  uint32   MinimumWorkingSetSize;
  string   Name;
  string   OSCreationClassName;
  string   OSName;
  uint64   OtherOperationCount;
  uint64   OtherTransferCount;
  uint32   PageFaults;
  uint32   PageFileUsage;
  uint32   ParentProcessId;
  uint32   PeakPageFileUsage;
  uint64   PeakVirtualSize;
  uint32   PeakWorkingSetSize;
  uint32   Priority = NULL;
  uint64   PrivatePageCount;
  uint32   ProcessId;
  uint32   QuotaNonPagedPoolUsage;
  uint32   QuotaPagedPoolUsage;
  uint32   QuotaPeakNonPagedPoolUsage;
  uint32   QuotaPeakPagedPoolUsage;
  uint64   ReadOperationCount;
  uint64   ReadTransferCount;
  uint32   SessionId;
  string   Status;
  datetime TerminationDate;
  uint32   ThreadCount;
  uint64   UserModeTime;
  uint64   VirtualSize;
  string   WindowsVersion;
  uint64   WorkingSetSize;
  uint64   WriteOperationCount;
  uint64   WriteTransferCount;
};

*/