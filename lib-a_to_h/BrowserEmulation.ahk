/* Function: BrowserEmulation
 *     FEATURE_BROWSER_EMULATION -> http://goo.gl/V01Frx
 * Requirements:
 *     AutoHotkey v1.1.17.01+ OR v2.0-a057
 * Syntax:
 *     BrowserEmulation( [ version ] )
 * Parameter(s):
 *     version  [in, opt] - IE version(7+). Integer between 7 - 11, value can be
 *                          negative. If omitted, current setting is returned.
 *                          If 'version' is the word "edge", installed IE version
 *                          is used. See table below for possible values:
 * Parameter "version" values table:
 * (values that are negative ignore !DOCTYPE directives, see http://goo.gl/V01Frx)
 *     7:  7000               ; 0x1B58           - IE7 Standards mode.
 *     8:  8000,  -8:  8888   ; 0x1F40  | 0x22B8 - IE8 mode, IE8 Standards mode
 *     9:  9000,  -9:  9999   ; 0x2328  | 0x270F - IE9 mode, IE9 Standards mode
 *     10: 10000, -10: 10001  ; 0x02710 | 0x2711 - IE10 Standards mode
 *     11: 11000, -11: 11001  ; 0x2AF8  | 0x2AF9 - IE11 edge mode
 * Remarks:
 *     This function modifes the registry.
 */
BrowserEmulation(version:="*") ;// FEATURE_BROWSER_EMULATION -> http://goo.gl/V01Frx
{
	static fbe := Format( ;// registry path
	(LTrim Join, Q
		"HKCU\Software\{1}Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\{2}"
		A_Is64bitOS ? "Wow6432Node\" : ""
		A_IsCompiled ? A_ScriptName : StrGet(DllCall("Shlwapi\PathFindFileName", "Str", A_AhkPath))
	))
	static WshShell := ComObjCreate("WScript.Shell"), prev := "*"
	if (prev == "*") ;// init
		try prev := WshShell.RegRead(fbe)
		catch ;// value does not exist
			prev := ""
	;// __Get()
	if (version == "*")
	{
		try value := WshShell.RegRead(fbe)
		catch ;// value does not exist
			value := "" ;// throw Exception()??
		finally
			return value
	}
	;// __Set()
	if version
	{
		if (version = "edge") ;// use version of IE installed
			version := Round(WshShell.RegRead("HKLM\SOFTWARE\Microsoft\Internet Explorer\svcVersion")) ;// static var??
		static val := { 7:7000, 8:8000, -8:8888, 9:9000, -9:9999, 10:10000, -10:10001, 11:11000, -11:11001 }
		if !(version := val[version + 0])
			throw Exception("Failed to resolve value.")
		try WshShell.RegWrite(fbe, version, "REG_DWORD")
	}
	else
		try (prev != "") ? WshShell.RegWrite(fbe, prev, "REG_DWORD") : WshShell.RegDelete(fbe)
	catch error
		throw error
	finally
		return BrowserEmulation() ;// OR return the value itself
}