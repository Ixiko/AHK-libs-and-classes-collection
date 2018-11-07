/*
class: STREAM_SEEK
an enumeration class specifying the origin from which to calculate the new seek-pointer location.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/STREAM_SEEK)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/aa380359)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
*/
class STREAM_SEEK
{
	/*
	Field: SET
	The new seek pointer is an offset relative to the beginning of the stream. In this case, the dlibMove parameter is the new seek position relative to the beginning of the stream.
	*/
	static SET := 0

	/*
	Field: CUR
	The new seek pointer is an offset relative to the current seek pointer location. In this case, the dlibMove parameter is the signed displacement from the current seek position.
	*/
	static CUR := 1

	/*
	Field: END
	The new seek pointer is an offset relative to the end of the stream. In this case, the dlibMove parameter is the new seek position relative to the end of the stream.
	*/
	static END := 2
}