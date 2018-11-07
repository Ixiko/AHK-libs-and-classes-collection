/*
class: REO
an enumeration class containing flags that specify what information should be placed in a REOBJECT structure.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/REO)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb787946) (part I)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb774345) (part II)
	- not all fields are documented on msdn.

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
*/
class REO
{
	/*
	group: interface information
	Flags to specify which interfaces should be returned in the REOBJECT structure.

	Field: GETOBJ_NO_INTERFACES
	Get no interfaces.
	*/
	static GETOBJ_NO_INTERFACES := 0x00000000

	/*
	Field: GETOBJ_POLEOBJ
	Get object interface.
	*/
	static GETOBJ_POLEOBJ := 0x00000001

	/*
	Field: GETOBJ_PSTG
	Get storage interface.
	*/
	static GETOBJ_PSTG := 0x00000002

	/*
	Field: GETOBJ_POLESITE
	Get site interface.
	*/
	static GETOBJ_POLESITE := 0x00000004

	/*
	Field: GETOBJ_ALL_INTERFACES
	Get all interfaces.
	*/
	static GETOBJ_ALL_INTERFACES := 0x00000007

	/*
	group: selection & caret

	Field: CP_SELECTION
	Place object at selection
	*/
	static CP_SELECTION := -1

	/*
	Field: IOB_SELECTION
	*/
	static IOB_SELECTION := -1

	/*
	Field: IOB_USE_CP
	Use character position to specify object instead of index
	*/
	static IOB_USE_CP := -2

	/*
	group: object flags

	Field: NULL
	No flags.
	*/
	static NULL := 0x00000000

	/*
	Field: READWRITEMASK
	Mask out read-only bits
	*/
	static READWRITEMASK := 0x0000003F

	/*
	Field: DONTNEEDPALETTE
	Object is rendered before the creation and realization of a half-tone palette. Applies to 32-bit platforms only.
	*/
	static DONTNEEDPALETTE := 0x00000020

	/*
	Field: BLANK
	Object is new. This value gives the object an opportunity to save nothing and be deleted from the control automatically.
	*/
	BLANK := 0x00000010

	/*
	Field: DYNAMICSIZE
	Object always determines its extents and may change despite the modify flag being turned off.
	*/
	DYNAMICSIZE := 0x00000008

	/*
	Field: INVERTEDSELECT
	Object is to be drawn entirely inverted when selected; the default is to be drawn with a border.
	*/
	INVERTEDSELECT := 0x00000004

	/*
	Field: BELOWBASELINE
	Object sits below the baseline of the surrounding text; the default is to sit on the baseline.
	*/
	static BELOWBASELINE := 0x00000002

	/*
	Field: RESIZABLE
	Object may be resized.
	*/
	static RESIZABLE := 0x00000001

	/*
	Field: LINK
	Object is a link. This flag can be read but not set.
	*/
	static LINK := 0x80000000

	/*
	Field: STATIC
	Object is a static object. This flag can be read but not set.
	*/
	static STATIC := 0x40000000

	/*
	Field: SELECTED
	Object is currently selected in the rich edit control. This flag can be read but not set.
	*/
	static SELECTED := 0x08000000

	/*
	Field: OPEN
	Object is currently open in its server. This flag can be read but not set.
	*/
	static OPEN := 0x04000000

	/*
	Field: INPLACEACTIVE
	Object is currently inplace active. This flag can be read but not set.
	*/
	static INPLACEACTIVE := 0x02000000

	/*
	Field: HILITED
	Object is currently highlighted to indicate selection. Occurs when focus is in the control and <SELECTED> is set. This flag can be read but not set.
	*/
	static HILITED := 0x01000000

	/*
	Field: LINKAVAILABLE
	Object is a link and is believed to be available. This flag can be read but not set.
	*/
	static LINKAVAILABLE := 0x00800000

	/*
	Field: GETMETAFILE
	The rich edit control retrieved the metafile from the object to correctly determine the object's extents. This flag can be read but not set.
	*/
	static GETMETAFILE := 0x00400000
}