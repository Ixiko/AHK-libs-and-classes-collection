/*
class: PSC
an enumeration class containing flags that specify the state of a property.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PSC)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb762531)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
*/
class PSC
{
	/*
	Field: NORMAL
	The property has not been altered.
	*/
	static NORMAL := 0x0000

	/*
	Field: NOTINSOURCE
	The requested property does not exist for the file or stream on which the property handler was initialized.
	*/
	static NOTINSOURCE := 0x0001

	/*
	Field: DIRTY
	The property has been altered but has not yet been committed to the file or stream.
	*/
	static DIRTY := 0x0002
}