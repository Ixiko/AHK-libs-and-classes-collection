/*
class: ILC
an enumeration class containing image list creation flags.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ILC)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb775232)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows Server 2003 or higher
*/
class ILC
{
	/*
	Field: MASK
	Use a mask. The image list contains two bitmaps, one of which is a monochrome bitmap used as a mask. If this value is not included, the image list contains only one bitmap.
	*/
	static MASK := 0x00000001

	/*
	Field: COLOR
	Use the default behavior if none of the other ILC.COLORx flags is specified. Typically, the default is <COLOR4>, but for older display drivers, the default is <COLORDDB>.
	*/
	static COLOR := 0x00000000

	/*
	Field: COLORDDB
	Use a device-dependent bitmap.
	*/
	static COLORDDB := 0x000000FE

	/*
	Field: COLOR4
	Use a 4-bit (16-color) device-independent bitmap (DIB) section as the bitmap for the image list.
	*/
	static COLOR4 := 0x00000004

	/*
	Field: COLOR8
	Use an 8-bit DIB section. The colors used for the color table are the same colors as the halftone palette.
	*/
	static COLOR8 := 0x00000008

	/*
	Field: COLOR16
	Use a 16-bit (32/64k-color) DIB section.
	*/
	static COLOR16 := 0x00000010

	/*
	Field: COLOR24
	Use a 24-bit DIB section.
	*/
	static COLOR24 := 0x00000018

	/*
	Field: COLOR32
	Use a 32-bit DIB section.
	*/
	static COLOR32 := 0x00000020

	/*
	Field: PALETTE
	Not implemented.
	*/
	static PALETTE := 0x00000800

	/*
	Field: MIRROR
	Mirror the icons contained, if the process is mirrored.
	*/
	static MIRROR := 0x00002000

	/*
	Field: PERITEMMIRROR
	Causes the mirroring code to mirror each item when inserting a set of images, versus the whole strip.
	*/
	static PERITEMMIRROR := 0x00008000

	/*
	Field: ORIGINALSIZE
	*Windows Vista and later.* Imagelist should accept smaller than set images and apply original size based on image added. 
	*/
	static ORIGINALSIZE := 0x00010000

	/*
	Field: HIGHQUALITYSCALE
	*Windows Vista and later.* Reserved. 
	*/
	static HIGHQUALITYSCALE := 0x00020000
}