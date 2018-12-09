/*
class: REGKIND
an enumeration class that controls how a type library is registered.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/REGKIND)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221159)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class REGKIND
{
	/*
	Field: DEFAULT
	Use default register behavior.
	*/
	static DEFAULT := 0

	/*
	Field: REGISTER
	Register this type library.
	*/
	static REGISTER := 1

	/*
	Field: NONE
	Do not register this type library.
	*/
	static NONE := 2
}