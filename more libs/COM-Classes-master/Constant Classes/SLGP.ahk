/*
class: SLGP
an enumeration class containing flags that specify the type of path information to retrieve.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/SLGP)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb774944)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows 2000 Server or higher
*/
class SLGP
{
	/*
	Field: SHORTPATH
	Retrieves the standard short (8.3 format) file name.
	*/
	static SHORTPATH := 0x1

	/*
	Field: UNCPRIORITY
	Retrieves the UNC path name of the file.
	*/
	static UNCPRIORITY := 0x2

	/*
	Field: RAWPATH
	Retrieves the raw path name. A raw path is something that might not exist and may include environment variables that need to be expanded.
	*/
	static RAWPATH := 0x4

	/*
	Field: RELATIVEPRIORITY
	*Windows Vista and later.* Although not officially documented, this might give a relative path (?).
	*/
	static RELATIVEPRIORITY := 0x8
}