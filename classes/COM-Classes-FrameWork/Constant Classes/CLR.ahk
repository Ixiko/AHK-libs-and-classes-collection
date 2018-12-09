/*
class: CLR
an enumeration class containing special values for COLORREF variables.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/CLR)
	- *msdn* (for example http://msdn.microsoft.com/en-us/library/windows/desktop/bb761395, or in other places else where it's used).

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows Server 2000 or higher
*/
class CLR
{
	/*
	Field: DEFAULT
	Default color. The exact meaning depends on the place where this is used.
	*/
	static DEFAULT := 0xFF000000

	/*
	Field: NONE
	No color. The exact meaning depends on the place where this is used.
	*/
	static NONE := 0xFFFFFFFF
}