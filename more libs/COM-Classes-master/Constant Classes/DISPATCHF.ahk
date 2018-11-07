/*
class: DISPATCHF
an enumeration class that contains invoke flags.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/DISPATCHF)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221359)

Requirements:
	AutoHotkey - AHK v2 alpha

Remarks:
	This class is named DISPATCHF instead of DISPATCH (as the C++ constants) to avoid a conflict with the Dispatch interface class.
*/
class DISPATCHF
{
	/*
	Field: METHOD
	The member is invoked as a method. If a property has the same name, both this and the <PROPERTYGET> flag can be set.
	*/
	static METHOD := 0x1

	/*
	Field: PROPERTYGET
	The member is retrieved as a property or data member.
	*/
	static PROPERTYGET := 0x2

	/*
	Field: PROPERTYPUT
	The member is set as a property or data member.
	*/
	static PROPERTYPUT := 0x4

	/*
	Field: PROPERTYPUTREF
	The member is changed by a reference assignment, rather than a value assignment. This flag is valid only when the property accepts a reference to an object.
	*/
	static PROPERTYPUTREF := 0x8
}