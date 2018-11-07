/*
class: RECO
an enumeration class specifying a RichEdit clipboard operation.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/RECO)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb774341)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
*/
class RECO
{
	/*
	Field: COPY
	Copy to the clipboard.
	*/
	static COPY := 0x02

	/*
	Field: CUT
	Cut to the clipboard.
	*/
	static CUT := 0x03

	/*
	Field: DRAG
	Drag operation (drag-and-drop).
	*/
	static DRAG := 0x04

	/*
	Field: DROP
	Drop operation (drag-and-drop).
	*/
	static DROP := 0x01

	/*
	Field: PASTE
	Paste from the clipboard.
	*/
	static PASTE := 0x00
}