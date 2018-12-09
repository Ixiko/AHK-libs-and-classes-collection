/*
class: ILIF
an enumeration class containing constants on image quality

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ILIF)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761486)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows Server 2008 or higher
*/
class ILIF
{
	/*
	Field: ALPHA
	Indicates that the item in the imagelist has an alpha channel.
	*/
	static ALPHA := 0x00000001

	/*
	Field: LOWQUALITY
	*Windows Vista and later.* Indicates that the item in the imagelist was generated via a StretchBlt function, consequently image quality may have degraded.
	*/
	static LOWQUALITY := 0x00000002
}