/*
class: FILE_ATTRIBUTE
an enumeration class containing flags indicating file attributes. File attributes are metadata values stored by the file system on disk and are used by the system and are available to developers via various file I/O APIs.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/FILE_ATTRIBUTE)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/gg258117)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows Server 2003 or higher
*/
class FILE_ATTRIBUTE
{
	/*
	Field: ARCHIVE
	A file or directory that is an archive file or directory. Applications typically use this attribute to mark files for backup or removal.
	*/
	static ARCHIVE := 0x20

	/*
	Field: COMPRESSED
	A file or directory that is compressed. For a file, all of the data in the file is compressed. For a directory, compression is the default for newly created files and subdirectories.
	*/
	static COMPRESSED := 0x800

	/*
	Field: DEVICE
	This value is reserved for system use.
	*/
	static DEVICE := 0x40

	/*
	Field: DIRECTORY
	The handle that identifies a directory.
	*/
	static DIRECTORY := 0x10

	/*
	Field: ENCRYPTED
	A file or directory that is encrypted. For a file, all data streams in the file are encrypted. For a directory, encryption is the default for newly created files and subdirectories.
	*/
	static ENCRYPTED := 0x4000

	/*
	Field: HIDDEN
	The file or directory is hidden. It is not included in an ordinary directory listing.
	*/
	static HIDDEN := 0x2

	/*
	Field: NORMAL
	A file that does not have other attributes set. This attribute is valid only when used alone.
	*/
	static NORMAL := 0x80

	/*
	Field: NOT_CONTENT_INDEXED
	The file or directory is not to be indexed by the content indexing service.
	*/
	static NOT_CONTENT_INDEXED := 0x2000

	/*
	Field: OFFLINE
	The data of a file is not available immediately. This attribute indicates that the file data is physically moved to offline storage. This attribute is used by Remote Storage, which is the hierarchical storage management software. Applications should not arbitrarily change this attribute.
	*/
	static OFFLINE := 0x1000

	/*
	Field: READONLY
	A file that is read-only. Applications can read the file, but cannot write to it or delete it. This attribute is not honored on directories.
	*/
	static READONLY := 0x1

	/*
	Field: REPARSE_POINT
	A file or directory that has an associated reparse point, or a file that is a symbolic link.
	*/
	static REPARSE_POINT := 0x400

	/*
	Field: SPARSE_FILE
	A file that is a sparse file.
	*/
	static SPARSE_FILE := 0x200

	/*
	Field: SYSTEM
	A file or directory that the operating system uses a part of, or uses exclusively.
	*/
	static SYSTEM := 0x4

	/*
	Field: TEMPORARY
	A file that is being used for temporary storage. File systems avoid writing data back to mass storage if sufficient cache memory is available, because typically, an application deletes a temporary file after the handle is closed. In that scenario, the system can entirely avoid writing the data. Otherwise, the data is written after the handle is closed.
	*/
	static TEMPORARY := 0x100

	/*
	Field: VIRTUAL
	This value is reserved for system use.
	*/
	static VIRTUAL := 0x10000
}