/*
class: PARAMFLAG
an enumeration class that specifies parameter flags.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PARAMFLAG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221019)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class PARAMFLAG
{
	/*
	Field: NONE
	Whether the parameter passes or receives information is unspecified. IDispatch interfaces can use this flag.
	*/
	static NONE := 0

	/*
	Field: FIN
	Parameter passes information from the caller to the callee.
	*/
	static FIN := 0x1

	/*
	Field: FOUT
	Parameter returns information from the callee to the caller.
	*/
	static FOUT := 0x2

	/*
	Field: FLCID
	Parameter is the LCID of a client application.
	*/
	static FLCID := 0x4

	/*
	Field: FRETVAL
	Parameter is the return value of the member.
	*/
	static FRETVAL := 0x8

	/*
	Field: FOPT
	Parameter is optional. The pPARAMDescEx field contains a pointer to a VARIANT describing the default value for this parameter, if the <FOPT> and <FHASDEFAULT> bit of wParamFlags is set.
	*/
	static FOPT := 0x10

	/*
	Field: FHASDEFAULT
	Parameter has default behaviors defined. The pPARAMDescEx field contains a pointer to a VARIANT that describes the default value for this parameter, if the <FOPT> and <FHASDEFAULT> bit of wParamFlags is set. 
	*/
	static FHASDEFAULT := 0x20

	/*
	Field: FHASCUSTDATA
	to be defined
	*/
	static FHASCUSTDATA := 0x40
}