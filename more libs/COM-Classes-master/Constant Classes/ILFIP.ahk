/*
class: ILFIP
an enumeration class containing flags for setting an image as "current" in an image list..

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ILFIP)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761411)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
*/
class ILFIP
{
	/*
	Field: ALWAYS
	Always get the image (can be slow).
	*/
	static ALWAYS := 0x00000000

	/*
	Field: FROMSTANDBY
	Only get if on standby.
	*/
	static FROMSTANDBY := 0x00000001
}