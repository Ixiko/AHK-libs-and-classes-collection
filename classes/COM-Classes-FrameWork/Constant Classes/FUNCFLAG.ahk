/*
class: FUNCFLAG
an enumeration class that specifies function flags.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/FUNCFLAG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221143)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class FUNCFLAG
{
	/*
	Field: FRESTRICTED
	The function should not be accessible from macro languages. This flag is intended for system-level functions or functions that type browsers should not display.
	*/
	static FRESTRICTED := 0x1

	/*
	Field: FSOURCE
	The function returns an object that is a source of events.
	*/
	static FSOURCE := 0x2

	/*
	Field: FBINDABLE
	The function that supports data binding.
	*/
	static FBINDABLE := 0x4

	/*
	Field: FREQUESTEDIT
	When set, any call to a method that sets the property results first in a call to IPropertyNotifySink::OnRequestEdit. The implementation of OnRequestEdit determines if the call is allowed to set the property.
	*/
	static FREQUESTEDIT := 0x8

	/*
	Field: FDISPLAYBIND
	The function that is displayed to the user as bindable. FUNC_FBINDABLE must also be set.
	*/
	static FDISPLAYBIND := 0x10

	/*
	Field: FDEFAULTBIND
	The function that best presents the object. Only one function in a type information can have this attribute.
	*/
	static FDEFAULTBIND := 0x20

	/*
	Field: FHIDDEN
	The function should not be displayed to the user, although it exists and is bindable.
	*/
	static FHIDDEN := 0x40

	/*
	Field: FUSESGETLASTERROR
	The function supports GetLastError. If an error occurs during the function, the caller can call GetLastError to retrieve the error code.
	*/
	static FUSESGETLASTERROR := 0x80

	/*
	Field: FDEFAULTCOLLELEM
	Permits an optimization in which the compiler looks for a member named xyz on the type of abc. If such a member is found and is flagged as an accessor function for an element of the default collection, then a call is generated to that member function. Permitted on members in dispinterfaces and interfaces; not permitted on modules. For more information, refer to defaultcollelem in Type Libraries and the Object Description Language.
	*/
	static FDEFAULTCOLLELEM := 0x100

	/*
	Field: FUIDEFAULT
	The type information member is the default member for display in the user interface.
	*/
	static FUIDEFAULT := 0x200

	/*
	Field: FNONBROWSABLE
	The property appears in an object browser, but not in a properties browser
	*/
	static FNONBROWSABLE := 0x400

	/*
	Field: FREPLACEABLE
	Tags the interface as having default behaviors.
	*/
	static FREPLACEABLE := 0x800

	/*
	Field: FIMMEDIATEBIND
	Mapped as individual bindable properties.
	*/
	static FIMMEDIATEBIND := 0x1000
}