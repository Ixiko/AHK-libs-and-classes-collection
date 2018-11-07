/*
class: LOCKTYPE
an enumeration class containing flags that  indicate the type of locking requested for the specified range of bytes. The values are used in the ILockBytes::LockRegion and IStream::LockRegion methods.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/LOCKTYPE)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/aa380048)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
*/
class LOCKTYPE
{
	/*
	Field: WRITE
	If this lock is granted, the specified range of bytes can be opened and read any number of times, but writing to the locked range is prohibited except for the owner that was granted this lock.
	*/
	static WRITE := 1

	/*
	Field: EXCLUSIVE
	If this lock is granted, writing to the specified range of bytes is prohibited except by the owner that was granted this lock.
	*/
	static EXCLUSIVE := 2

	/*
	Field: ONLYONCE
	If this lock is granted, no other <ONLYONCE> lock can be obtained on the range. Usually this lock type is an alias for some other lock type. Thus, specific implementations can have additional behavior associated with this lock type.
	*/
	static ONLYONCE := 4
}