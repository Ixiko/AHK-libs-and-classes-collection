/**

	Requires:

 * Lib: JSON.ahk
 *     JSON lib for AutoHotkey.
 * Version:
 *     v2.1.3 [updated 04/18/2016 (MM/DD/YYYY)]
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Requirements:
 *     Latest version of AutoHotkey (v1.1+ or v2.0-a+)
 * Installation:
 *     Use #Include JSON.ahk or copy into a function library folder and then
 *     use #Include <JSON>
 * Links:
 *     GitHub:     - https://github.com/cocobelgica/AutoHotkey-JSON
 *     Forum Topic - http://goo.gl/r0zI8t
 *     Email:      - cocobelgica <at> gmail <dot> com
 */

UrlDownloadToJson(input) {
	file := A_Temp "\_" A_ScriptName A_ScriptHwnd A_Now A_TickCount ".json"
	UrlDownloadToFile, % input, % file
	FileRead, input, % file
	FileDelete, % file
	return JSON.Dump(JSON.Load(input),, 2)
}