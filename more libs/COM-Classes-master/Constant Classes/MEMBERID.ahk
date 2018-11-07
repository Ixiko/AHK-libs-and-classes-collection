/*
class: MEMBERID
an enumeration class containing special values for MEMBERID variables. They are used to identify the member in a type description.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/MEMBERID)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221103)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - DISPID
*/
class MEMBERID extends DISPID
{
	/*
	Field: NIL
	Same as DISPID.UNKNOWN.
	*/
	static NIL := DISPID.UNKNOWN
}