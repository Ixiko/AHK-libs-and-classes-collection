UpdateCheck(force=false, prompt=false, preRelease=false) {
	global ProgramValues, SPACEBAR_WAIT
	iniFile := ProgramValues.Ini_File

	autoupdate := INI.Get(iniFile, "SETTINGS", "Auto_Update")
	lastUpdateCheck := INI.Get(iniFile, "PROGRAM", "Last_Update_Check")
	if (force) ; Fake the last update check, so it's higher than 35mins
		lastUpdateCheck := 1994042612310000

	timeDif := A_Now
	timeDif -= lastUpdateCheck, Minutes

	if !(timeDif > 35) ; Hasn't been longer than 35mins since last check, cancel to avoid spamming GitHub API
		Return

	if FileExist(ProgramValues.Updater_File)
		FileDelete,% ProgramValues.Updater_File

	Ini.Set(iniFile, "PROGRAM", "Last_Update_Check", A_Now)

	if (preRelease)
		releaseInfos := GetLatestPreRelease_Infos(ProgramValues.Github_User, ProgramValues.Github_Repo)
	else
		releaseInfos := GetLatestRelease_Infos(ProgramValues.Github_User, ProgramValues.Github_Repo)
	onlineVer := releaseInfos.name
	onlineDownload := releaseInfos.assets.1.browser_download_url

	if (prompt) {
		if (!onlineVer || !onlineDownload) {
			SplashTextOn(ProgramValues.Name " - Updating Error", "There was an issue when retrieving the latest release from GitHub API"
			.											"`nIf this keeps on happening, please try updating manually."
			.											"`nYou can find the GitHub repository link in the Settings menu.", 1, 1)
		}
		else if (onlineVer && onlineDownload) && (onlineVer != ProgramValues.Version) {
			if (autoupdate) {
				FileDownload(ProgramValues.Updater_Link, ProgramValues.Updater_File)
				Run_Updater(onlineDownload)
			}
			Else
				ShowUpdatePrompt(onlineVer, onlineDownload)
			Return
		}
	}

	Return {Version:onlineVer, Download:onlineDownload}
}

ShowUpdatePrompt(ver, dl) {
	global ProgramValues

	MsgBox, 4100, Update detected (v%ver%),% "Current version:" A_Tab ProgramValues.Version
	.										 "`nOnline version: " A_Tab ver
	.										 "`n"
	.										 "`nWould you like to update now?"
	.										 "`nThe entire updating process is automated."
	IfMsgBox, Yes
	{
		success := Download(ProgramValues.Updater_Link, ProgramValues.Updater_File)
		if (success)
			Run_Updater(dl)
	}
}

Run_Updater(downloadLink) {
	global ProgramValues
	iniFile := ProgramValues.Ini_File

	updaterLink 		:= ProgramValues.Updater_Link

	INI.Set(iniFile, "PROGRAM", "LastUpdate", A_Now)
	Run,% ProgramValues.Updater_File 
	. " /Name=""" ProgramValues.Name  """"
	. " /File_Name=""" A_ScriptDir "\" ProgramValues.Name ".exe" """"
	. " /Local_Folder=""" ProgramValues.Local_Folder """"
	. " /Ini_File=""" ProgramValues.Ini_File """"
	. " /NewVersion_Link=""" downloadLink """"
	ExitApp
}