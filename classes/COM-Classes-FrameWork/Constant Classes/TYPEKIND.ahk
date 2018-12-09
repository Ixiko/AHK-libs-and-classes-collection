/*
class: TYPEKIND
an enumeration class that specifies a type.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TYPEKIND)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221643)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class TYPEKIND
{
	/*
	Field: ENUM
	A set of enumerators.
	*/
	static ENUM := 0

	/*
	Field: RECORD
	A structure with no methods.
	*/
	static RECORD := 1

	/*
	Field: MODULE
	A module that can only have static functions and data (for example, a DLL).
	*/
	static MODULE := 2

	/*
	Field: INTERFACE
	A type that has virtual and pure functions.
	*/
	static INTERFACE := 3

	/*
	Field: DISPATCH
	A set of methods and properties that are accessible through IDispatch::Invoke. By default, dual interfaces return <DISPATCH>.
	*/
	static DISPATCH := 4

	/*
	Field: COCLASS
	A set of implemented component object interfaces.
	*/
	static COCLASS := 5

	/*
	Field: ALIAS
	A type that is an alias for another type.
	*/
	static ALIAS := 6

	/*
	Field: UNION
	A union, all of whose members have an offset of zero.
	*/
	static UNION := 7

	/*
	Field: MAX
	End of enum marker.
	*/
	static MAX := 8
}