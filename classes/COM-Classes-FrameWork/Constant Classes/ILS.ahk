/*
class: ILS
an enumeration class containing flags passed to IImageList::Draw in the fState member of IMAGELISTDRAWPARAMS.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ILS)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb775231)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows Server 2003 or higher
*/
class ILS
{
	/*
	Field: NORMAL
	The image state is not modified.
	*/
	static NORMAL := 0x00000000

	/*
	Field: GLOW
	Not supported.
	*/
	static GLOW := 0x00000001

	/*
	Field: SHADOW
	Not supported.
	*/
	static SHADOW := 0x00000002

	/*
	Field: SATURATE
	Reduces the color saturation of the icon to grayscale. This only affects 32bpp images.
	*/
	static SATURATE := 0x00000004

	/*
	Field: ALPHA
	Alpha blends the icon. Alpha blending controls the transparency level of an icon, according to the value of its alpha channel. The value of the alpha channel is indicated by the frame member in the IMAGELISTDRAWPARAMS method. The alpha channel can be from 0 to 255, with 0 being completely transparent, and 255 being completely opaque.
	*/
	static ALPHA := 0x00000008
}