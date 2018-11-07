/*
class: VARKIND
an enumeration class that specifies a variable's type.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/VARKIND)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221381)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class VARKIND
{
	/*
	Field: PERINSTANCE
	The variable is a field or member of the type. It exists at a fixed offset within each instance of the type.
	*/
	static PERINSTANCE := 0

	/*
	Field: STATIC
	There is only one instance of the variable.
	*/
	static STATIC := 1

	/*
	Field: CONST
	describes a symbolic constant. There is no memory associated with it.
	*/
	static CONST := 2

	/*
	Field: DISPATCH
	The variable can only be accessed through IDispatch::Invoke.
	*/
	static DISPATCH := 3
}