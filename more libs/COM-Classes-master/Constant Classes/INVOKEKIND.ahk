/*
class: INVOKEKIND
an enumeration class that specifies the way a function is invoked.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/INVOKEKIND)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221691)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class INVOKEKIND
{
	/*
	Field: FUNC
	The member is called using a normal function invocation syntax.
	*/
	static FUNC := 1

	/*
	Field: PROPERTYGET
	The function is invoked using a normal property-access syntax.
	*/
	static PROPERTYGET := 2

	/*
	Field: PROPERTYPUT
	The function is invoked using a property value assignment syntax. Syntactically, a typical programming language might present changing a property in the same way as assignment. For example:
>	object.property := value
	*/
	static PROPERTYPUT := 4

	/*
	Field: PROPERTYPUTREF
	The function is invoked using a property reference assignment syntax.
	*/
	static PROPERTYPUTREF := 8
}