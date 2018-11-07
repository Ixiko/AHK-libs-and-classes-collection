/*
class: CF
an enumeration class defining system clipboard formats.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/CF)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ff729168)
	- *more information* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms649013)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
*/
class CF
{
	/*
	Field: BITMAP
	A handle to a bitmap (HBITMAP).
	*/
	static BITMAP := 2

	/*
	Field: DIB
	A memory object containing a BITMAPINFO structure followed by the bitmap bits.
	*/
	static DIB := 8

	/*
	Field: DIBV5
	A memory object containing a BITMAPV5HEADER structure followed by the bitmap color space information and the bitmap bits.
	*/
	static DIBV5 := 17

	/*
	Field: DIF
	Software Arts' Data Interchange Format.
	*/
	static DIF := 5

	/*
	Field: DSPBITMAP
	Bitmap display format associated with a private format.
	*/
	static DSPBITMAP := 0x0082

	/*
	Field: DSPENHMETAFILE
	Enhanced metafile display format associated with a private format.
	*/
	static DSPENHMETAFILE := 0x008E

	/*
	Field: DSPMETAFILEPICT
	Metafile-picture display format associated with a private format.
	*/
	static DSPMETAFILEPICT := 0x0083

	/*
	Field: DSPTEXT
	Text display format associated with a private format.
	*/
	static DSPTEXT := 0x0081

	/*
	Field: ENHMETAFILE
	A handle to an enhanced metafile (HENHMETAFILE).
	*/
	static ENHMETAFILE := 14

	/*
	Field: GDIOBJFIRST
	Start of a range of integer values for application-defined GDI object clipboard formats. The end of the range is <GDIOBJLAST>.
	*/
	static GDIOBJFIRST := 0x0300

	/*
	Field: GDIOBJLAST
	See <GDIOBJFIRST>.
	*/
	static GDIOBJLAST := 0x03FF

	/*
	Field: HDROP
	A handle to type HDROP that identifies a list of files. An application can retrieve information about the files by passing the handle to the DragQueryFile function.
	*/
	static HDROP := 15

	/*
	Field: LOCALE
	The data is a handle to the locale identifier associated with text in the clipboard. When you close the clipboard, if it contains <TEXT> data but no <LOCALE> data, the system automatically sets the <LOCALE> format to the current input language. You can use the <LOCALE> format to associate a different locale with the clipboard text.
	An application that pastes text from the clipboard can retrieve this format to determine which character set was used to generate the text.
	Note that the clipboard does not support plain text in multiple character sets. To achieve this, use a formatted text data type such as RTF instead.
	The system uses the code page associated with <LOCALE> to implicitly convert from <TEXT> to <UNICODETEXT>. Therefore, the correct code page table is used for the conversion.
	*/
	static LOCALE := 16

	/*
	Field: METAFILEPICT
	Handle to a metafile picture format as defined by the METAFILEPICT structure.
	*/
	static METAFILEPICT := 3

	/*
	Field: OEMTEXT
	Text format containing characters in the OEM character set. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
	*/
	static OEMTEXT := 7

	/*
	Field: OWNERDISPLAY
	Owner-display format. The clipboard owner must display and update the clipboard viewer window, and receive the WM_ASKCBFORMATNAME, WM_HSCROLLCLIPBOARD, WM_PAINTCLIPBOARD, WM_SIZECLIPBOARD, and WM_VSCROLLCLIPBOARD messages.
	*/
	static OWNERDISPLAY := 0x0080

	/*
	Field: PALETTE
	Handle to a color palette. Whenever an application places data in the clipboard that depends on or assumes a color palette, it should place the palette on the clipboard as well.
	If the clipboard contains data in the <PALETTE> (logical color palette) format, the application should use the SelectPalette and RealizePalette functions to realize (compare) any other data in the clipboard against that logical palette.
	When displaying clipboard data, the clipboard always uses as its current palette any object on the clipboard that is in the <PALETTE> format.
	*/
	static PALETTE := 9

	/*
	Field: PENDATA
	Data for the pen extensions to the Microsoft Windows for Pen Computing.
	*/
	static PENDATA := 10

	/*
	Field: PRIVATEFIRST
	Start of a range of integer values for private clipboard formats. The range ends with <PRIVATELAST>. Handles associated with private clipboard formats are not freed automatically; the clipboard owner must free such handles, typically in response to the WM_DESTROYCLIPBOARD message.
	*/
	static PRIVATEFIRST := 0x0200

	/*
	Field: PRIVATELAST
	See <PRIVATEFIRST>.
	*/
	static PRIVATELAST := 0x02FF

	/*
	Field: RIFF
	Represents audio data more complex than can be represented in a <WAVE> standard wave format.
	*/
	static RIFF := 11

	/*
	Field: SYLK
	Microsoft Symbolic Link (SYLK) format.
	*/
	static SYLK := 4

	/*
	Field: TEXT
	Text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data. Use this format for ANSI text.
	*/
	static TEXT := 1

	/*
	Field: TIFF
	Tagged-image file format.
	*/
	static TIFF := 6

	/*
	Field: UNICODETEXT
	Unicode text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
	*/
	static UNICODETEXT := 13

	/*
	Field: WAVE
	Represents audio data in one of the standard wave formats, such as 11 kHz or 22 kHz PCM.
	*/
	static WAVE := 12

	/*
	Field: MAX
	*/
	static MAX := 18

	/*
	Field: HTML
	The format for HTML data. This is not a constant as the other members but generated by a call to RegisterClipboardFormat().

	Remarks:
		For more information on this format visit <http://msdn.microsoft.com/en-us/library/windows/desktop/ms649015>
	*/
	static HTML := DllCall("RegisterClipoardFormat", "str", "HTML Format")
}