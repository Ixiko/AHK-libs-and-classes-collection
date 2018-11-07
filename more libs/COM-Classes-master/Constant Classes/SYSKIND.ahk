/*
class: SYSKIND
an enumeration class that identifies a target operating system platform.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/SYSKIND)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221272)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class SYSKIND
{
	/*
	Field: WIN16
	The target operating system for the type library is 16-bit Windows. By default, data members are packed.
	*/
	static WIN16 := 0

	/*
	Field: WIN32
	The target operating system for the type library is 32-bit Windows. By default, data members are naturally aligned (for example, 2-byte integers are aligned on even-byte boundaries; 4-byte integers are aligned on quad-word boundaries, and so on).
	*/
	static WIN32 := 1

	/*
	Field: MAC
	The target operating system for the type library is Apple Macintosh. By default, all data members are aligned on even-byte boundaries.
	*/
	static MAC := 2

	/*
	Field: WIN64
	The target operating system for the type library is 64-bit Windows.
	*/
	static WIN64 := 3
}