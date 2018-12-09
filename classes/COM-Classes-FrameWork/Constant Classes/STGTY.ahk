/*
class: STGTY
an enumeration class containing flags used in the type member of the STATSTG structure to indicate the type of the storage element. A storage element is a storage object, a stream object, or a byte-array object (LOCKBYTES).

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/STGTY)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/aa380348)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
*/
class STGTY
{
	/*
	Field: STORAGE
	Indicates that the storage element is a storage object.
	*/
	static STORAGE := 1

	/*
	Field: STREAM
	Indicates that the storage element is a stream object.
	*/
	static STREAM := 2

	/*
	Field: LOCKBYTES
	Indicates that the storage element is a byte-array object.
	*/
	static LOCKBYTES := 3

	/*
	Field: PROPERTY
	Indicates that the storage element is a property storage object.
	*/
	static PROPERTY := 4
}