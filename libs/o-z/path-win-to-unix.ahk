; Win + AltGr + P: Translate C:\Users\ to /c/Users/
PathWinToUnix(clipVal) {

	; Replace c:\path\ with c:/path/
	path := StrReplace(clipVal, "\", "/")

	; Replace C:/ with c/
	path := "/" StrReplace(path, ":")

return RegExReplace(path, "(?<=/)(([^\\/:*?""<>|]+) (?2))(?=/)" , """$1""") 	; Quote directories with spaces in them
}
