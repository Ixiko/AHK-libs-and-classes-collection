/*
class: ILR
an enumeration class containing flags specifying how a mask is applied to an image.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/LGPL-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ILR)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761425)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
*/
class ILR
{
	/*
	Field: DEFAULT
	Not used.
	*/
	static DEFAULT := 0x0000

	/*
	Field: HORIZONTAL_LEFT
	Horizontally align to left.
	*/
	static HORIZONTAL_LEFT := 0x0000

	/*
	Field: HORIZONTAL_CENTER
	Horizontally center.
	*/
	static HORIZONTAL_CENTER := 0x0001

	/*
	Field: HORIZONTAL_RIGHT
	Horizontally align to right.
	*/
	static HORIZONTAL_RIGHT := 0x0002

	/*
	Field: VERTICAL_TOP
	Vertically align to top.
	*/
	static VERTICAL_TOP := 0x0000

	/*
	Field: VERTICAL_CENTER
	Vertically align to center.
	*/
	static VERTICAL_CENTER := 0x0010

	/*
	Field: VERTICAL_BOTTOM
	Vertically align to bottom.
	*/
	static VERTICAL_BOTTOM := 0x0020

	/*
	Field: SCALE_CLIP
	Do nothing.
	*/
	static SCALE_CLIP := 0x0000

	/*
	Field: SCALE_ASPECTRATIO
	Scale.
	*/
	static SCALE_ASPECTRATIO := 0x0100
}