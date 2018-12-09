/*
class: VARFLAG
an enumeration class that specifies parameter flags.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/VARFLAG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221426)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class VARFLAG
{
	/*
	Field: FREADONLY
	Assignment to the variable should not be allowed.
	*/
	static FREADONLY := 0x1

	/*
	Field: FSOURCE
	The variable returns an object that is a source of events.
	*/
	static FSOURCE := 0x2

	/*
	Field: FBINDABLE
	The variable supports data binding.
	*/
	static FBINDABLE := 0x4

	/*
	Field: FREQUESTEDIT
	When set, any attempt to directly change the property results in a call to IPropertyNotifySink::OnRequestEdit. The implementation of OnRequestEdit determines if the change is accepted.
	*/
	static FREQUESTEDIT := 0x8

	/*
	Field: FDISPLAYBIND
	The variable is displayed to the user as bindable. <FBINDABLE> must also be set.
	*/
	static FDISPLAYBIND := 0x10

	/*
	Field: FDEFAULTBIND
	The variable is the single property that best represents the object. Only one variable in type information can have this attribute.
	*/
	static FDEFAULTBIND := 0x20

	/*
	Field: FHIDDEN
	The variable should not be displayed to the user in a browser, although it exists and is bindable.
	*/
	static FHIDDEN := 0x40

	/*
	Field: FRESTRICTED
	The variable should not be accessible from macro languages. This flag is intended for system-level variables or variables that you do not want type browsers to display.
	*/
	static FRESTRICTED := 0x80

	/*
	Field: FDEFAULTCOLLELEM
	Permits an optimization in which the compiler looks for a member named "xyz" on the type of abc. If such a member is found and is flagged as an accessor function for an element of the default collection, then a call is generated to that member function. Permitted on members in dispinterfaces and interfaces; not permitted on modules.
	*/
	static FDEFAULTCOLLELEM := 0x100

	/*
	Field: FUIDEFAULT
	The variable is the default display in the user interface.
	*/
	static FUIDEFAULT := 0x200

	/*
	Field: FNONBROWSABLE
	The variable appears in an object browser, but not in a properties browser.
	*/
	static FNONBROWSABLE := 0x400

	/*
	Field: FREPLACEABLE
	Tags the interface as having default behaviors.
	*/
	static FREPLACEABLE := 0x800

	/*
	Field: FIMMEDIATEBIND
	The variable is mapped as individual bindable properties.
	*/
	static FIMMEDIATEBIND := 0x1000
}