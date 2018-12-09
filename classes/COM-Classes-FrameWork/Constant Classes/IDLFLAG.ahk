/*
class: IDLFLAG
an enumeration class that contains parameter flags. This is a subset of the PARAMFLAG enumeration.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/IDLFLAG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/aa909796, originally intended for Windows Mobile)

Requirements:
	AutoHotkey - AHK v2 alpha
*/
class IDLFLAG
{
	/*
	Field: NONE
	Whether the parameter passes or receives information is unspecified.
	*/
	static NONE := 0

	/*
	Field: FIN
	Parameter passes information from the caller to the callee.
	*/
	static FIN := 1

	/*
	Field: FOUT
	Parameter returns information from the callee to the caller.
	*/
	static FOUT := 2

	/*
	Field: FLCID
	Parameter is the local identifier of a client application.
	*/
	static FLCID := 4

	/*
	Field: FRETVAL
	Parameter is the return value of the member.
	*/
	static FRETVAL := 8
}