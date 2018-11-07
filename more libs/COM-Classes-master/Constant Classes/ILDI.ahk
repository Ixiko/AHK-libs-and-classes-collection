/*
class: ILDI
an enumeration class containing flags for discarding an image from an image list.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ILDI)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761409)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher

Remarks:
	- <STANDBY> and <PURGE> are mutually exclusive. <RESETACCESS> can be combined with either.
*/
class ILDI
{
	/*
	Field: PURGE
	Discard and purge. 
	*/
	static PURGE := 0x00000001
	
	/*
	Field: STANDBY
	Discard to standby list. 
	*/
	static STANDBY := 0x00000002
	
	/*
	Field: RESETACCESS
	Reset the "has been accessed" flag. 
	*/
	static RESETACCESS := 0x00000004
	
	/*
	Field: QUERYACCESS
	Ask whether access flag is set (but do not reset). 
	*/
	static QUERYACCESS := 0x00000008
}