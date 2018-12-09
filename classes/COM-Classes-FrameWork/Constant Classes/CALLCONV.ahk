/*
class: CALLCONV
an enumeration class that identifies the calling convention used by a member function described in a METHODDATA structure.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/CALLCONV)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221058)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class CALLCONV
{
	/*
	Field: FASTCALL
	*/
	static FASTCALL := 0

	/*
	Field: CDECL
	*/
	static CDECL := 1

	/*
	Field: MSCPASCAL
	*/
	static MSCPASCAL := 2

	/*
	Field: PASCAL
	Same as <MSCPASCAL>.
	*/
	static PASCAL := 2

	/*
	Field: MACPASCAL
	*/
	static MACPASCAL := 3

	/*
	Field: STDCALL
	*/
	static STDCALL := 4

	/*
	Field: FPFASTCALL
	*/
	static FPFASTCALL := 5

	/*
	Field: SYSCALL
	*/
	static SYSCALL := 6

	/*
	Field: MPWCDECL
	*/
	static MPWCDECL := 7

	/*
	Field: MPWPASCAL
	*/
	static MPWPASCAL := 8

	/*
	Field: MAX
	*/
	static MAX := 9
}