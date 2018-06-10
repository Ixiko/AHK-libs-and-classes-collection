CheckForUpdates(installed_version, byRef latestVersion, url)
{
	URLDownloadToFile, %url%, %A_Temp%\version_checker_temp_file.ini
	if !ErrorLevel 
	{	
		IniRead, latestVersion, %A_Temp%\version_checker_temp_file.ini, info, currentVersion, %installed_version%
		IniRead, zipURL, %A_Temp%\version_checker_temp_file.ini, info, zipURL, 0
		FileDelete %A_Temp%\version_checker_temp_file.ini
		If (latestVersion > installed_version && zipURL)
			Return zipURL ; update exist
	}
	latestVersion := installed_version ; incase there was an error
	FileDelete %A_Temp%\version_checker_temp_file.ini
	Return 0 ; no update or error
}


/*
	Reads an ini file with the following keys

[info]
currentVersion=2.95
zipURL=http://www.xyz.com/file.zip

*/