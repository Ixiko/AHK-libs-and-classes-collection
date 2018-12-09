/*
class: SICHINT
an enumeration class used to determine how to compare two Shell items. IShellItem::Compare uses this.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/SICHINT)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb762543)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows Server 2003 or higher
*/
class SICHINT
{
	/*
	Field: DISPLAY
	This relates to the iOrder parameter of the IShellItem::Compare interface and indicates that the comparison is based on the display in a folder view.
	*/
	static DISPLAY := 0x00000000

	/*
	Field: ALLFIELDS
	Exact comparison of two instances of a Shell item.
	*/
	static ALLFIELDS := 0x80000000

	/*
	Field: CANONICAL
	This relates to the iOrder parameter of the IShellItem::Compare interface and indicates that the comparison is based on a canonical name.
	*/
	static CANONICAL := 0x10000000

	/*
	Field: TEST_FILESYSPATH_IF_NOT_EQUAL
	*Windows 7 and later.* If the Shell items are not the same, test the file system paths.
	*/
	static TEST_FILESYSPATH_IF_NOT_EQUAL := 0x20000000
}