/*
class: ILGOS
an enumeration class containing flags for retrieving an image's size.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ILGOS)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761415)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
*/
class ILGOS
{
	/*
	Field: ALWAYS
	Always get the original size (can be slow).
	*/
	static ALWAYS := 0x00000000
	
	/*
	Field: FROMSTANDBY
	Only get if present or on standby.
	*/
	static FROMSTANDBY := 0x00000001
}