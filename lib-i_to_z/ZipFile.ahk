
/* Class: ZipFile
 *     Wrapper for Windows shell ZIP function
 * Version:
 *     1.2.00.02 [updated 03/20/2015]
 * License:
 *     WTFPL [http://www.wtfpl.net/]
 * Requirements:
 *     Latest version of AutoHotkey v1.1+ OR v2.0-a
 * Installation:
 *     Use '#Include ZipFile.ahk' or copy into a function library folder and
 *     then use '#Include <ZipFile>'
 * Links:
 *     GitHub      - http://goo.gl/Ur0wg5
 *     Forum topic - http://goo.gl/rx6cNm
 */

class ZipFile
{
	/* Constructor: __New
	 *     Instantiates an object that represents a ZIP file
	 * Syntax:
	 *     oZip := new ZipFile( zip )
	 * Parameter(s):
	 *     oZip      [retval] - a ZipFile instance
	 *     zip           [in] - path to the ZIP file. An empty ZIP file is
	 *                          created if 'zip' does not exist.
	 */
	__New(zip)
	{
		static fso := ComObjCreate("Scripting.FileSystemObject")
		this.Path := fso.GetAbsolutePathName(zip)

		if !FileExist(zip)
		{
			static header ; magic number(empty ZIP file)
			if !VarSetCapacity(header)
				VarSetCapacity(header, 22, 0), NumPut(0x06054b50, header, 0, "UInt") ; 'PK' Chr(5) Chr(6)

			if !fzip := FileOpen(this.Path, "w")
				throw Exception("Failed to create ZIP file.", -1, this.Path)

			fzip.RawWrite(header, 22), fzip := "" ; close
		}
		; Check if valid ZIP file ??
	}
	/* Method: Pack
	 *     Add the specified files/folders into the ZIP file
	 * Syntax:
	 *     oZip.Pack( [ FilePattern := "*.*", del := false ] )
	 * Parameter(s):
	 *     FilePattern  [in, opt] - file pattern specifying the files to pack
	 *     del          [in, opt] - if 'true', the file(s) will be deleted after
	 *                              zipping.
	 */

	 /* Method: Unpack
	 *     Extract the item(s) into the specified directory
	 * Syntax:
	 *     oZip.Unpack( [ FilePattern := "*.*", dest := "" ] )
	 * Parameter(s):
	 *     FilePattern  [in, opt] - file pattern specifying the files to unpack.
	 *                              Path is relative to A_WorkingDir
	 *     dest         [in, opt] - the directory to extract to, A_WorkingDir if
	 *                              omitted.
	 */
	__Call(name, args*)
	{
		if (name = "Pack") || (name = "Unpack")
			return this._PackOrUnpack(name, args*)
	}

	_PackOrUnpack(action:="Pack", fspec:="*.*", arg:="")
	{
		static fso := ComObjCreate("Scripting.FileSystemObject") ; http://goo.gl/kNQeh4
		static sApp := ComObjCreate("Shell.Application") ; http://goo.gl/HDE4zG
		static AbsPath := ObjBindMethod(fso, "GetAbsolutePathName")

		IsPack := action = "Pack"
		ZipPath := this.Path

		; When Pack()-ing, to avoid the 'a zip file cannot include itself' error
		; which occurs if the filter happens to include the ZIP file itself, we
		; temporarily move the ZIP file to a temporary location, pack the item(s)
		; into it, then restore the ZIP file back to its original location.
		if IsPack && ( %AbsPath%(fspec . "\..") = %AbsPath%(ZipPath . "\..") ) ; check if parent folder is the same
		{
			TmpFolder := new ZipFile.TempFolder(ZipPath . "\..")
			FileMove %ZipPath%, % TmpFolder.Path
			ZipPath := TmpFolder.Path . "\" . fso.GetFileName(ZipPath) ; update the ZIP path
		}

		dest := sApp.NameSpace(IsPack ? ZipPath : %AbsPath%(arg))

		; Destination is not empty, this causes a problem when checking if the
		; MoveHere/CopyHere routine has completed, so we create a temporary dump
		; location, Pack() or Unpack() into it, then move the item(s) back to the
		; actual destination.
		if dest.Items().Count
		{
			TmpDest := new ZipFile.TempFolder(dest.Self.Path, IsPack)
			dest := sApp.NameSpace(TmpDest.Path) ; update Folder object
		}

		items := sApp.NameSpace(IsPack ? %AbsPath%(fspec . "\..") : ZipPath).Items()
		; SHCONTF_FOLDERS|SHCONTF_NONFOLDERS|SHCONTF_INCLUDEHIDDEN - http://goo.gl/A2nfTt
		items.Filter(0x00020|0x00040|0x00080, fspec) ; .Filter(): http://goo.gl/HsUW5W
		count := items.Count
		; Pack OR Unpack
		dest[IsPack && arg ? "MoveHere" : "CopyHere"](items, 4|16)
		while (dest.Items().Count != count)
			Sleep 10

		TmpDest := "", TmpFolder := "" ; restore temporarily relocated files
	}

	__Get(key:="", args*)
	{
		if !key ; Folder object [http://goo.gl/STuHFG]
			return ComObjCreate("Shell.Application").NameSpace(this.Path)
	}
	/* Property: Item
	 *     Returns an object that represents an item in the ZIP file.
	 * Syntax:
	 *     oItem := oZip.Item[ [ NameOrIndex := 1 ] ]
	 * Parameter(s):
	 *     oItem          [retval] - a FolderItem[http://goo.gl/wDYdbh] object
	 *     NameOrIndex   [in, opt] - the name(file or folder name) or one-based
	 *                               index of the particular item to retrieve.
	 */
	Item[NameOrIndex:=1] { ; FolderItem object [http://goo.gl/wDYdbh]
		get {
			if (ObjGetCapacity([NameOrIndex], 1) != "") ; string (name)
				return this[].ParseName(NameOrIndex)
			items := this[].Items()
			if (NameOrIndex > 0) && (NameOrIndex <= items.Count)
				return items.Item(NameOrIndex - 1) ; zero-based
		}
	}
	/* Property: Items
	 *     Returns a collection object that represents items in the ZIP file.
	 * Syntax:
	 *     oItem := oZip.Items[ [ filter ] ]
	 * Parameter(s):
	 *     oItem          [retval] - a FolderItems[http://goo.gl/3klMkj] object
	 *     filter        [in, opt] - a file pattern(name or wildcard) specifying
	 *                               the items to include. If omitted, all the
	 *                               items in the ZIP file are included.
	 */
	Items[filter:=""] { ; FolderItems object [http://goo.gl/3klMkj]
		get {
			items := this[].Items()
			if (filter != "")
				items.Filter(0x00020|0x00040|0x00080, filter)
			return items
		}
	}
	/* Class: ZipFile.TempFolder
	 *     Private helper class to manage creation/deletion of temporary folder(s)
	 *     and restoration of its contents(if any).
	 * Remarks:
	 *     This class is for private use. Documentation is for maintenance
	 *     purposes only.
	 */
	class TempFolder
	{
		/* Constructor: __New
		 *     Instantiates an object that represents a temporary folder
		 * Parameter(s):
		 *     RestoreTo   [in, opt] - the directory where to restore the contents
		 *                             of the temp folder prior its deletion.
		 *     shell       [in, opt] - if 'true', the Shell method(s) will be used
		 *                             when restoring the folder's contents.
		 */
		__New(RestoreTo:="", shell:=false)
		{
			fso := ComObjCreate("Scripting.FileSystemObject")
			this.Path := A_Temp . "\ZIPFILE_" . fso.GetTempName()
			this.Folder := fso.CreateFolder(this.Path)
			this.RestoreTo := fso.GetAbsolutePathName(RestoreTo)
			this.UseShell := shell
		}
		/* Deconstructor: __Delete
		 *     Called automatically when a ZipFile.TempFolder instance is released
		 * Remarks:
		 *     If the temp folder is not empty, its contents will be restored
		 *     into the directory specified when the TempFolder object is created.
		 */
		__Delete()
		{
			dest := this.RestoreTo
			if this.UseShell && sApp := ComObjCreate("Shell.Application")
			{
				src := sApp.NameSpace(this.Path)
				dest := sApp.NameSpace(dest)
				dest.MoveHere(src.Items(), 4|16)
				while (src.Items().Count != 0)
					Sleep 10
			}
			else fso := ComObjCreate("Scripting.FileSystemObject")
				try fso.MoveFile(this.Path . "\*", dest), fso.MoveFolder(this.Path . "\*", dest)

			this.Folder.Delete(true) ; http://goo.gl/b5p7DT
		}
	}
}