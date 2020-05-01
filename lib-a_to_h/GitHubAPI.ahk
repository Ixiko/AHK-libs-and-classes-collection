/*	Requires: JSON.ahk, EasyFuncs.ahk, cURL.ahk, curl.exe

	https://autohotkey.com/boards/viewtopic.php?t=627
	https://github.com/cocobelgica/AutoHotkey-JSON
*/

GitHubAPI_GetLatestRelease(user, repo) {
    rel := GitHubAPI_GetReleases(user, repo, "releases_only", latestOnly:=True)
    return rel
}
GitHubAPI_GetLatestPrerelease(user, repo) {
    rel := GitHubAPI_GetReleases(user, repo, "prereleases_only", latestOnly:=True)
    return rel
}
GitHubAPI_GetRecentReleases(user, repo) {
    rel := GitHubAPI_GetReleases(user, repo, "all", latestOnly:=False)
    return rel
}


GitHubAPI_GetReleases(user, repo, which="releases_only", latestOnly=False, pageIndex=1) {

    if !IsIn(which, "releases_only,prereleases_only,all,both") {
        MsgBox % A_ThisFunc ": Invalid usage for param ""which"" with value """ which ""
        return
    }

    url := "https://api.github.com/repos/" . user . "/" . repo . "/releases"
    url .= (which="releases_only" && latestOnly)?("/latest") : ("?page=" pageIndex)
    errorMsg := "Failed to check for updates. Please check manually on GitHub."
    . "`nA link to the GitHub repo can be found in the Settings."

	postData		:= ""
	reqHeaders		:= []
	reqHeaders.Push("Content-Type: text/html; charset=UTF-8")
	options			:= ""
	html 			:= cURL_Download(url, ioData := postData, reqHeaders, options, true, false, false, errorMsg)
    ; FileRead, html,% A_ScriptDir "\releasejson.txt"
    
	if GitHubAPI_IsRateLimitExceeded(html, reqHeaders)
		Return

	parsedJSON  	:= JSON.Load(html)

    if (which="releases_only" && latestOnly) {
        relInfos := parsedJSON
    }
    else {
        relArr := {}
        for index, nothing in parsedJSON {
            if (breakLoop = True)
                Break

            isPreRelease := parsedJSON[index].prerelease

            if (which="prereleases_only" && latestOnly && isPreRelease)
                relInfos := parsedJSON[index], breakLoop := True
            else if (which="prereleases_only" && !latestOnly && isPreRelease)
                relArr[index] := parsedJSON[index]
            else if (which="releases_only" && !latestOnly && !isPreRelease)
                relArr[index] := parsedJSON[index]
            else if (which="all" || which="both")
                relArr[index] := parsedJSON[index]
        }

        if (!relInfos && parsedJSON && latestOnly) { ; check for next page
            GitHubAPI_GetReleases(user, repo, which, True, pageIndex+1)
        }
    }
    
    if (latestOnly)
        return relInfos
    else
        return relARr
}

GitHubAPI_IsRateLimitExceeded(html, headers) {
    if RegExMatch(html, "iO)message.*API rate limit exceeded for (\d+\.\d+\.\d+\.\d+)?", htmlPat) {
        userIP := htmlPat.1
        RegExMatch(headers, "iO)X-RateLimit-Reset.*:\s(\d+)?", headersPat), epochTime := headersPat.1
        AutoTrimStr(userIP, epochTime)

        ; Timezone diff calc
        userTZ := A_Now
        utcTZ := A_NowUTC
        Envsub, userTZ, %utcTZ%, M
        TZDiff := Round(userTZ/60, 2)
        ; Epoch time calc
        epochUTC := 1970
        epochUTC += epochTime, Seconds
        EnvAdd, epochUTC, TZDiff, H
        FormatTime, epochReset, %epochUTC%, HH:mm:ss

        err := ""
        . "GitHub API rate limit exceeded!"
        . "`n`nThe API rate limit has been exceeded for your IP (" userIP ")."
        . "`nReset your IP or wait until the rate refreshes at " epochReset " (every hour)."
        . "`n`nThe application will not be able to check for updates until then."

        MsgBox(4096, "GitHub API Error", err)
        return True
    }
    else
        return False
}
