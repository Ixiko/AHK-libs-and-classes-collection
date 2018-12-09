/*
class: STGMOVE
an enumeration class containing values that indicate whether a storage element is to be moved or copied.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/STGMOVE)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/aa380336)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
*/
class STGMOVE
{
	/*
	Field: MOVE
	Indicates that the method should move the data from the source to the destination.
	*/
	static MOVE := 0

	/*
	Field: COPY
	Indicates that the method should copy the data from the source to the destination.
	A copy is the same as a move except that the source element is not removed after copying the element to the destination. Copying an element on top of itself is undefined.
	*/
	static COPY := 1

	/*
	Field: SHALLOWCOPY
	Not implemented.
	*/
	static SHALLOWCOPY := 2
}