/*
class: FUNCKIND
an enumeration class that specifies a function's type.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/FUNCKIND)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221679)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class FUNCKIND
{
	/*
	Field: VIRTUAL
	The function is accessed the same as <PUREVIRTUAL>, except the function has an implementation.
	*/
	static VIRTUAL := 0

	/*
	Field: PUREVIRTUAL
	The function is accessed through the virtual function table (VTBL), and takes an implicit "this" pointer.
	*/
	static PUREVIRTUAL := 1

	/*
	Field: NONVIRTUAL
	The function is accessed by static address and takes an implicit this pointer.
	*/
	static NONVIRTUAL := 2

	/*
	Field: STATIC
	The function is accessed by static address and does not take an implicit "this" pointer.
	*/
	static STATIC := 3

	/*
	Field: DISPATCH
	The function can be accessed only through IDispatch.
	*/
	static DISPATCH := 4
}