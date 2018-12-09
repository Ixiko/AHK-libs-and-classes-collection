/*
class: IMPLTYPEFLAG
an enumeration class that specifies implementation type flags.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/IMPLTYPEFLAG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221065)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class IMPLTYPEFLAG
{
	/*
	Field: FDEFAULT
	The interface or dispinterface presents the default for the source or sink.
	*/
	static FDEFAULT := 0x1

	/*
	Field: FSOURCE
	This member of a coclass is called rather than implemented.
	*/
	static FSOURCE := 0x2

	/*
	Field: FRESTRICTED
	The member should not be displayed or programmable by users.
	*/
	static FRESTRICTED := 0x4

	/*
	Field: FDEFAULTVTABLE
	Sinks receive events through the VTBL.
	*/
	static FDEFAULTVTABLE := 0x8
}