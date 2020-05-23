/*	Requires JSON.ahk

	https://autohotkey.com/boards/viewtopic.php?t=627
	https://github.com/cocobelgica/AutoHotkey-JSON
*/

GetLatestPreRelease_Version(user, repo) {
	releaseInfos := GetLatestPreRelease_Infos(user, repo)
	releaseVersion := releaseInfos.name
	return releaseVersion
}

GetLatestRelease_Version(user, repo) {
	releaseInfos := GetLatestRelease_Infos(user, repo)
	releaseVersion := releaseInfos.name
	return releaseVersion
}

GetLatestRelease_Infos(user, repo, preRelease=false) {
	Try {
		httpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		httpReq.SetTimeouts("10000", "10000", "10000", "10000")

		if (preRelease=true)
			httpReq.Open("GET", "https://api.github.com/repos/" user "/" repo "/releases?page=1", true)
		else httpReq.Open("GET", "https://api.github.com/repos/" user "/" repo "/releases/latest", true)

		httpReq.Send()
		httpReq.WaitForResponse(10)

		releasesJSON := httpReq.ResponseText
		parsedJSON := JSON.Load(releasesJSON)

		if (preRelease=true) {
			for subArr, nothing in parsedJSON {
				for key, content in parsedJSON[subArr] {
					if (key = "prerelease") && (content = true) && !(found) {
						releaseInfos := parsedJSON[subArr]
						found := true
					}
				}
			}
		}
		else releaseInfos := parsedJSON
	}

	Catch e {
		MsgBox, 16,, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file
        . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
	}

	return releaseInfos
}

GetLatestPreRelease_Infos(user, repo) {
	releaseInfos := GetLatestRelease_Infos(user, repo, 1)
	return releaseInfos
}