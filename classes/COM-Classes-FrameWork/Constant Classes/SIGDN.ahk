/*
class: SIGDN
an enumeration class containing flags that specify the form of an item's display name to retrieve through IShellItem::GetDisplayName and SHGetNameFromIDList.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/SIGDN)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb762544)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP SP1 / Windows Server 2003 or higher
*/
class SIGDN
{
	/*
	Field: NORMALDISPLAY
	Returns the display name relative to the desktop. In UI this name is generally ideal for display to the user.
	*/
	static NORMALDISPLAY := 0x00000000

	/*
	Field: PARENTRELATIVEPARSING
	Returns the parsing name relative to the parent folder. This name is not suitable for use in UI.
	*/
	static PARENTRELATIVEPARSING := 0x80018001

	/*
	Field: DESKTOPABSOLUTEPARSING
	Returns the parsing name relative to the desktop. This name is not suitable for use in UI.
	*/
	static DESKTOPABSOLUTEPARSING := 0x80028000

	/*
	Field: PARENTRELATIVEEDITING
	Returns the editing name relative to the parent folder. In UI this name is suitable for display to the user.
	*/
	static PARENTRELATIVEEDITING := 0x80031001

	/*
	Field: DESKTOPABSOLUTEEDITING
	Returns the editing name relative to the desktop. In UI this name is suitable for display to the user.
	*/
	static DESKTOPABSOLUTEEDITING := 0x8004c000

	/*
	Field: FILESYSPATH
	Returns the item's file system path, if it has one. Only items that report SFGAO.FILESYSTEM have a file system path. When an item does not have a file system path, a call to IShellItem::GetDisplayName on that item will fail. In UI this name is suitable for display to the user in some cases, but note that it might not be specified for all items.
	*/
	static FILESYSPATH := 0x80058000

	/*
	Field: URL
	Returns the item's URL, if it has one. Some items do not have a URL, and in those cases a call to IShellItem::GetDisplayName will fail. This name is suitable for display to the user in some cases, but note that it might not be specified for all items.
	*/
	static URL := 0x80068000

	/*
	Field: PARENTRELATIVEFORADDRESSBAR
	Returns the path relative to the parent folder in a friendly format as displayed in an address bar. This name is suitable for display to the user.
	*/
	static PARENTRELATIVEFORADDRESSBAR := 0x8007c001

	/*
	Field: PARENTRELATIVE
	Returns the path relative to the parent folder.
	*/
	static PARENTRELATIVE := 0x80080001
}