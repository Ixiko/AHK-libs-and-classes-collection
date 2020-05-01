FindInstalled(SortResults:="Down") {			; returns a list with all installed programs

	; param SortResults can be Up, Down or nothing

	installed := ""

	REGPATH =SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
	Loop, HKEY_LOCAL_MACHINE, %REGPATH%, 1, 1
	{
		If A_LoopRegName = DisplayName
		{
			RegRead, value
			installed .= value "|"
		}
	}

	REGPATH =SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
	Loop, HKEY_LOCAL_MACHINE, %REGPATH%, 1, 1
	{
		If A_LoopRegName = DisplayName
		{
			RegRead, value
			installed .= value "|"
		}
	}

	installed := RTrim(installed, "|")

	If RegExMatch(SortResults, "\s*Down\s*")
		Sort, installed, D| U
	else If RegExMatch(SortResults, "\s*Up\s*")
		Sort, installed, D| R U

return installed
}




