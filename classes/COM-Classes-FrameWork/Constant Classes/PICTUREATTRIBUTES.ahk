/*
class: PICTUREATTRIBUTES
an enumeration class specifying attributes of a picture object as returned through IPicture::get_Attributes.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PICTUREATTRIBUTES)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms680123)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
*/
class PICTUREATTRIBUTES
{
	/*
	Field: SCALABLE
	The picture object is scalable, such that it can be redrawn with a different size than was used to create the picture originally. Metafile-based pictures are considered scalable; icon and bitmap pictures, while they can be scaled, do not express this attribute because both involve bitmap stretching instead of true scaling.
	*/
	static SCALABLE := 0x1

	/*
	Field: TRANSPARENT
	The picture object contains an image that has transparent areas, such that drawing the picture will not necessarily fill in all the spaces in the rectangle it occupies. Metafile and icon pictures have this attribute; bitmap pictures do not.
	*/
	static TRANSPARENT := 0x2
}