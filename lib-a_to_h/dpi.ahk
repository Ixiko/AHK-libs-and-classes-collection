/*
Name             : DPI
Purpose          : Return scaling factor or calculate position/values for AHK controls (font size, position (x y), width, height)
Version          : 0.31
Source           : https://github.com/hi5/dpi
AutoHotkey Forum : https://autohotkey.com/boards/viewtopic.php?f=6&t=37913
License          : see license.txt (GPL 2.0)
Documentation    : See readme.md @ https://github.com/hi5/dpi

History:

* v0.31: refactored "process" code, just one line now
* v0.3: - Replaced super global variable ###dpiset with static variable within dpi() to set dpi
        - Removed r parameter, always use Round()
        - No longer scales the Rows option and others that should be skipped (h-1, *w0, hwnd etc)
* v0.2: public release
* v0.1: first draft

*/

DPI(in="",setdpi=1)
	{
	 static dpi:=1
	 if (setdpi <> 1)
		dpi:=setdpi
	 RegRead, AppliedDPI, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI
	 ; If the AppliedDPI key is not found the default settings are used.
	 ; 96 is the default value.
	 if (ErrorLevel=1) OR (AppliedDPI=96)
		AppliedDPI:=96
	 if (dpi <> 1)
		AppliedDPI:=dpi
	 factor:=AppliedDPI/96
	 if !in
		Return factor

	 Loop, parse, in, %A_Space%%A_Tab%
		{
		 option:=A_LoopField
		 if RegExMatch(option,"i)(w0|h0|h-1|xp|yp|xs|ys|xm|ym)$") or RegExMatch(option,"i)(icon|hwnd)") ; these need to be bypassed
			out .= option A_Space
		 else if RegExMatch(option,"i)^\*{0,1}(x|xp|y|yp|w|h|s)[-+]{0,1}\K(\d+)",number) ; should be processed
			out .= StrReplace(option,number,Round(number*factor)) A_Space
		 else ; the rest can be bypassed as well (variable names etc)
			out .= option A_Space
		}
	 Return Trim(out)
	}
