Array2INI(iniArray,Saveto)
{
	for Sec, Seclines in iniArray
		for k, v in Seclines
			IniWrite, % v, % Saveto, % Sec, % k
}

INI2Array(iniFile)
{
	iniarray := []
	for i, Sec in GetINISections(iniFile)
	{	
		IniRead, SecLines, % iniFile, % Sec
		for k, line in StrSplit(SecLines, "`n")
		{
			IniRead, Val , % iniFile, % Sec, % Key := substr(line, 1, instr(line,"=")-1)
			iniarray[Sec,Key] := Val
		}
	}
	return iniarray
}

GetINISections(iniFile)
{
	IniRead, SectionNames, % iniFile
	return StrSplit(SectionNames, "`n")
}

CleanINI(iniFile)
{
	iniarray := INI2Array(iniFile)
	FileDelete, % iniFile
	while FileExist(iniFile)
		sleep, 100
	Array2INI(iniArray,iniFile)
}
