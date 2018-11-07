/*
class: DISPID
an enumeration class containing special values for DISPID variables. They are used to identify methods, properties, and arguments.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/DISPID)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221242)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class DISPID
{
	/*
	Field: COLLECT
	The *Collect* property. You use this property if the method you are calling through Invoke is an accessor function.
	*/
	static COLLECT := -8

	/*
	Field: CONSTRUCTOR
	The C++ constructor function for the object.
	*/
	static CONSTRUCTOR := -6

	/*
	Field: DESTRUCTOR
	The C++ destructor function for the object.
	*/
	static DESTRUCTOR := -7

	/*
	Field: EVALUATE
	The Evaluate method. This method is implicitly invoked when the ActiveX client encloses the arguments in square brackets. For example, the following two lines are equivalent:
>	x.[A1:C1].value = 10
>	x.Evaluate("A1:C1").value = 10
	*/
	static EVALUATE := -5

	/*
	Field: NEWENUM
	The _NewEnum property. This special, restricted property is required for collection objects. It returns an enumerator object that supports IEnumVARIANT, and should have the restricted attribute specified.
	*/
	static NEWENUM := -4

	/*
	Field: PROPERTYPUT
	The parameter that receives the value of an assignment in a PROPERTYPUT.
	*/
	static PROPERTYPUT := -3

	/*
	Field: UNKNOWN
	The value returned by IDispatch::GetIDsOfNames to indicate that a member or parameter name was not found.
	*/
	static UNKNOWN := -1

	/*
	Field: VALUE
	The default member for the object. This property or method is invoked when an ActiveX client specifies the object name without a property or method.
	*/
	static VALUE := 0
}