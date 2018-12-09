/*
class: ILCF
an enumeration class containing image list copy flags.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ILCF)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761443)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows Server 2003 or higher
*/
class ILCF
{
	/*
	Field: MOVE
	The source image is copied to the destination image's index. This operation results in multiple instances of a given image.
	*/
	static MOVE := 0

	/*
	Field: SWAP
	The source and destination images exchange positions within the image list.
	*/
	static SWAP := 1
}