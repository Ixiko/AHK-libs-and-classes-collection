/*
class: TYPEFLAG
an enumeration class that specifies parameter flags.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TYPEFLAG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221509)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class TYPEFLAG
{
	/*
	Field: FAPPOBJECT
	A type description that describes an Application object.
	*/
	static FAPPOBJECT := 0x1

	/*
	Field: FCANCREATE
	Instances of the type can be created by ITypeInfo::CreateInstance.
	*/
	static FCANCREATE := 0x2

	/*
	Field: FLICENSED
	The type is licensed.
	*/
	static FLICENSED := 0x4

	/*
	Field: FPREDECLID
	The type is predefined. The client application should automatically create a single instance of the object that has this attribute. The name of the variable that points to the object is the same as the class name of the object.
	*/
	static FPREDECLID := 0x8

	/*
	Field: FHIDDEN
	The type should not be displayed to browsers.
	*/
	static FHIDDEN := 0x10

	/*
	Field: FCONTROL
	The type is a control from which other types will be derived, and should not be displayed to users.
	*/
	static FCONTROL := 0x20

	/*
	Field: FDUAL
	The interface supplies both IDispatch and VTBL binding.
	*/
	static FDUAL := 0x40

	/*
	Field: FNONEXTENSIBLE
	The interface cannot add members at run time.
	*/
	static FNONEXTENSIBLE := 0x80

	/*
	Field: FOLEAUTOMATION
	The types used in the interface are fully compatible with Automation, including VTBL binding support. Setting dual on an interface sets this flag in addition to <FDUAL>. Not allowed on dispinterfaces.
	*/
	static FOLEAUTOMATION := 0x100

	/*
	Field: FRESTRICTED
	Should not be accessible from macro languages. This flag is intended for system-level types or types that type browsers should not display.
	*/
	static FRESTRICTED := 0x200

	/*
	Field: FAGGREGATABLE
	The class supports aggregation.
	*/
	static FAGGREGATABLE := 0x400

	/*
	Field: FREPLACEABLE
	to be defined
	*/
	static FREPLACEABLE := 0x800

	/*
	Field: FDISPATCHABLE
	Indicates that the interface derives from IDispatch, either directly or indirectly. This flag is computed. There is no Object Description Language for the flag.
	*/
	static FDISPATCHABLE := 0x1000

	/*
	Field: FREVERSEBIND
	to be defined
	*/
	static FREVERSEBIND := 0x2000

	/*
	Field: FPROXY
	Interfaces can be marked with this flag to indicate that they will be using a proxy/stub dynamic link library. This flag specifies that the typelib proxy should not be unregistered when the typelib is unregistered.
	*/
	static FPROXY := 0x4000
}