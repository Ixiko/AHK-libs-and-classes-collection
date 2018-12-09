/*
class: SFGAO
an enumeration class containing flags that specify attributes that can be retrieved on an item (file or folder) or set of items.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/SFGAO)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb762589)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
*/
class SFGAO
{
	/*
	Field: CANCOPY
	The specified items can be copied.
	*/
	static CANCOPY := 0x00000001

	/*
	Field: CANMOVE
	The specified items can be moved.
	*/
	static CANMOVE := 0x00000002

	/*
	Field: CANLINK
	Shortcuts can be created for the specified items.
	*/
	static CANLINK := 0x00000004

	/*
	Field: STORAGE
	The specified items can be bound to an IStorage object through IShellFolder::BindToObject. For more information about namespace manipulation capabilities, see IStorage.
	*/
	static STORAGE := 0x00000008

	/*
	Field: CANRENAME
	The specified items can be renamed. Note that this value is essentially a suggestion; not all namespace clients allow items to be renamed. However, those that do must have this attribute set.
	*/
	static CANRENAME := 0x00000010

	/*
	Field: CANDELETE
	The specified items can be deleted.
	*/
	static CANDELETE := 0x00000020

	/*
	Field: HASPROPSHEET
	The specified items have property sheets.
	*/
	static HASPROPSHEET := 0x00000040

	/*
	Field: DROPTARGET
	The specified items are drop targets.
	*/
	static DROPTARGET := 0x00000100

	/*
	Field: CAPABILITYMASK
	This flag is a mask for the capability attributes: <CANCOPY>, <CANMOVE>, <CANLINK>, <CANRENAME>, <CANDELETE>, <HASPROPSHEET>, and <DROPTARGET>. Callers normally do not use this value.
	*/
	static CAPABILITYMASK := 0x00000177

	/*
	Field: SYSTEM
	*Windows 7 and later.* The specified items are system items.
	*/
	static SYSTEM := 0x00001000

	/*
	Field: ENCRYPTED
	The specified items are encrypted and might require special presentation.
	*/
	static ENCRYPTED := 0x00002000

	/*
	Field: ISSLOW
	Accessing the item (through IStream or other storage interfaces) is expected to be a slow operation. Applications should avoid accessing items flagged with SFGAO_ISSLOW.

	Remarks:
		Opening a stream for an item is generally a slow operation at all times. SFGAO_ISSLOW indicates that it is expected to be especially slow, for example in the case of slow network connections or offline (FILE_ATTRIBUTE_OFFLINE) files. However, querying <ISSLOW> is itself a slow operation. Applications should query <ISSLOW> only on a background thread. An alternate method, such as retrieving the PKEY_FileAttributes property and testing for FILE_ATTRIBUTE_OFFLINE, could be used in place of a method call that involves <ISSLOW>.
	*/
	static ISSLOW := 0x00004000

	/*
	Field: GHOSTED
	The specified items are shown as dimmed and unavailable to the user.
	*/
	static GHOSTED := 0x00008000

	/*
	Field: LINK
	The specified items are shortcuts.
	*/
	static LINK := 0x00010000

	/*
	Field: SHARE
	The specified objects are shared.
	*/
	static SHARE := 0x00020000

	/*
	Field: READONLY
	The specified items are read-only. In the case of folders, this means that new items cannot be created in those folders. This should not be confused with the behavior specified by the FILE_ATTRIBUTE_READONLY flag retrieved by IColumnProvider::GetItemData in a SHCOLUMNDATA structure. FILE_ATTRIBUTE_READONLY has no meaning for Win32 file system folders.
	*/
	static READONLY := 0x00040000

	/*
	Field: HIDDEN
	The item is hidden and should not be displayed unless the "Show hidden files and folders" option is enabled in Folder Settings.
	*/
	static HIDDEN := 0x00080000

	/*
	Field: DISPLAYATTRMASK
	Do not use.
	*/
	static DISPLAYATTRMASK := 0x000FC000

	/*
	Field: NONENUMERATED
	The items are nonenumerated items and should be hidden. They are not returned through an enumerator such as that created by the IShellFolder::EnumObjects method.
	*/
	static NONENUMERATED := 0x00100000

	/*
	Field: NEWCONTENT
	The items contain new content, as defined by the particular application.´
	*/
	static NEWCONTENT := 0x00200000

	/*
	Field: CANMONIKER
	Not supported.
	*/
	static CANMONIKER := 0x00400000

	/*
	Field: HASSTORAGE
	Not supported.
	*/
	static HASSTORAGE := 0x00400000

	/*
	Field: STREAM
	Indicates that the item has a stream associated with it. That stream can be accessed through a call to IShellFolder::BindToObject or IShellItem::BindToHandler with IID_IStream in the interface parameter.
	*/
	static STREAM := 0x00400000

	/*
	Field: STORAGEANCESTOR
	Children of this item are accessible through IStream or IStorage. Those children are flagged with <STORAGE> or <STREAM>.
	*/
	static STORAGEANCESTOR := 0x00800000

	/*
	Field: VALIDATE
	When specified as input, <VALIDATE> instructs the folder to validate that the items contained in a folder or Shell item array exist. If one or more of those items do not exist, IShellFolder::GetAttributesOf and IShellItemArray::GetAttributes return a failure code. This flag is never returned as an [out] value.
	*/
	static VALIDATE := 0x01000000

	/*
	Field: REMOVABLE
	The specified items are on removable media or are themselves removable devices.
	*/
	static REMOVABLE := 0x02000000

	/*
	Field: COMPRESSED
	The specified items are compressed.
	*/
	static COMPRESSED := 0x04000000

	/*
	Field: BROWSABLE
	The specified items can be hosted inside a web browser or Windows Explorer frame.
	*/
	static BROWSABLE := 0x08000000

	/*
	Field: FILESYSANCESTOR
	The specified folders are either file system folders or contain at least one descendant (child, grandchild, or later) that is a file system (<FILESYSTEM>) folder.
	*/
	static FILESYSANCESTOR := 0x10000000

	/*
	Field: FOLDER
	The specified items are folders. Some items can be flagged with both <STREAM> and <FOLDER>, such as a compressed file with a .zip file name extension. Some applications might include this flag when testing for items that are both files and containers.
	*/
	static FOLDER := 0x20000000

	/*
	Field: FILESYSTEM
	The specified folders or files are part of the file system (that is, they are files, directories, or root directories). The parsed names of the items can be assumed to be valid Win32 file system paths. These paths can be either UNC or drive-letter based.
	*/
	static FILESYSTEM := 0x40000000

	/*
	Field: STORAGECAPMASK
	This flag is a mask for the storage capability attributes: <STORAGE>, <LINK>, <READONLY>, <STREAM>, <STORAGEANCESTOR>, <FILESYSANCESTOR>, <FOLDER>, and <FILESYSTEM>. Callers normally do not use this value.
	*/
	static STORAGECAPMASK := 0x70C50008

	/*
	Field: HASSUBFOLDER
	The specified folders have subfolders. The <HASSUBFOLDER> attribute is only advisory and might be returned by Shell folder implementations even if they do not contain subfolders. Note, however, that the converse - failing to return <HASSUBFOLDER> - definitively states that the folder objects do not have subfolders.
	The Shell always returns <HASSUBFOLDER> when a folder is located on a network drive.
	*/
	static HASSUBFOLDER := 0x80000000

	/*
	Field: CONTENTSMASK
	This flag is a mask for content attributes, at present only <HASSUBFOLDER>. Callers normally do not use this value.
	*/
	static CONTENTSMASK := 0x80000000

	/*
	Field: PKEYSFGAOMASK
	Mask used by the PKEY_SFGAOFlags property to determine attributes that are considered to cause slow calculations or lack context: <ISSLOW>, <READONLY>, <HASSUBFOLDER>, and <VALIDATE>. Callers normally do not use this value.
	*/
	static PKEYSFGAOMASK := 0x81044000
}