; AutoHotkey wrapper for Windows native Zip feature
; https://github.com/cocobelgica/AutoHotkey-ZipFile

/* ZipFile
 *     Wrapper for Windows shell ZIP function
 * AHK Version: Requires v1.1+ OR v2.0-a049+
 * License: WTFPL (http://www.wtfpl.net/)
 * Usage:
 *     See each method's inline documentation for usage
 * Remarks:
 *     Caller can insantiate the class vie the 'new' operator OR call the
 *     ZipFile() function(function definition is below the class definition)
 */
class ZipFile
{
	/* Function: __New
	 * Instantiates an object that represents a zip archive. 
	 * Syntax:
	 *     zip := new ZipFile( file )
	 * Parameter(s):
	 *     file    [in] - The zip archive . If 'file' does not exist, an empty
	 *                    zip archive is created.
	 */
	__New(file) {
		static set := Func( A_AhkVersion < "2" ? "ObjInsert" : "ObjRawSet" )
		
		%set%(this, "_", {}) ;// dummy object, bypass __Set
		fso := ComObjCreate("Scripting.FileSystemObject")
		this._.__path := file := fso.GetAbsolutePathName(file)
		;// create empty zip file if it doesn't exist
		if !FileExist(file) {
			header1 := "PK" . Chr(5) . Chr(6)
			, VarSetCapacity(header2, 18, 0)
			, archive := FileOpen(file, "w")
			, archive.Write(header1)
			, archive.RawWrite(header2, 18)
			, archive.Close()
		}
	}
	/* Function: pack
	 * Adds the specified file(s) to the archive
	 * Syntax:
	 *     zip.pack([ fspec, del ])
	 * Parameter(s):
	 *     fpsec   [in] - The file(s) to zip, accepts wildcards. If omitted,
	 *                    all the file(s) in the current directory will be
	 *                    included.
	 *     del     [in] - If true, the file(s) will be deleted after zipping.
	 */
	pack(fspec:="*.*", del:=false) {
		fso := ComObjCreate("Scripting.FileSystemObject")
		, psh := ComObjCreate("Shell.Application")
		, fspec := fso.GetAbsolutePathName(fspec)
		, dest := psh.NameSpace(this._.__path)
		, items := psh.NameSpace(fso.GetParentFolderName(fspec)).Items()
		;// .Filter(): http://goo.gl/HsUW5W
		, items.Filter(0x00020|0x00040|0x00080 ;// http://goo.gl/A2nfTt
		             , fso.GetFileName(fspec))

		if (tmp := dest.Items().Count) {
			tmp := fso.CreateFolder(A_Temp . "\" . fso.GetTempName())
			, _dest := dest
			, dest := psh.NameSpace(tmp.Path) ;// .Path -> http://goo.gl/aHMt2J
		}
		count := items.Count
		dest[del ? "MoveHere" : "CopyHere"](items, 4|16)
		while (dest.Items().Count != count)
			Sleep 15
		if tmp {
			_dest.MoveHere(dest.Items(), 4|16)
			while (dest.Items().Count != 0)
				Sleep 15
			tmp.Delete(true) ;// http://goo.gl/b5p7DT
		}
	}
	/* Function: unpack
	 * Extracts file(s) to the current or specified directory.
	 * Syntax:
	 *     zip.unpack([ fspec, dest ])
	 * Parameter(s):
	 *     fpsec   [in] - The file(s) to extract, accepts wildcards. If
	 *                    omitted, all the files in the archive will be
	 *                    extracted.
	 *     dest    [in] - The directory to extract to. A_WorkingDir if omitted.
	 */
	unpack(fspec:="*.*", dest:="") {
		fso := ComObjCreate("Scripting.FileSystemObject")
		, psh := ComObjCreate("Shell.Application")
		, dest := psh.NameSpace(fso.GetAbsolutePathName(dest))
		, items := psh.NameSpace(this._.__path).Items()
		, items.Filter(0x00020|0x00040|0x00080, fspec)

		if (tmp := dest.Items().Count) {
			tmp := fso.CreateFolder(A_Temp . "\" . fso.GetTempName())
			, _dest := dest
			, dest := psh.NameSpace(tmp.Path) 
		}
		count := items.Count
		dest.CopyHere(items, 4|16)
		while (dest.Items().Count != count)
			Sleep 15
		if tmp {
			_dest.MoveHere(dest.Items(), 4|16)
			while (dest.Items().Count != 0)
				Sleep 15
			tmp.Delete(true)
		}
	}
	/* Function: delete
	 * Removes the specified item(s) from the archive
	 * Syntax:
	 *     zip.delete([ fspec ])
	 * Parameter(s):
	 *     fspec   [in] - File(s) to be deleted from the archive, accepts
	 *                    wildcard pattern. All files, if omitted.
	 */
	delete(fspec:="*.*") {
		fso := ComObjCreate("Scripting.FileSystemObject")
		, psh := ComObjCreate("Shell.Application")
		, items := psh.NameSpace(this._.__path).Items()
		, items.Filter(0x00020|0x00040|0x00080, fspec)
		, count := items.Count
		, tmp := fso.CreateFolder(A_Temp . "\" . fso.GetTempName())
		, trash := psh.NameSpace(tmp.Path)
		, trash.MoveHere(items, 4|16)
		while (trash.Items().Count != count)
			Sleep 15
		tmp.Delete(true)
	}
	/* Function: items
	 * Returns an array containing an item object for each member of the archive.
	 * Syntax:
	 *     zip.items([ filter ])
	 * Parameter(s):
	 *     filter  [in] - Only item(s) that match the wildcard pattern will
	 *                    be included. Defaults to all types(*.*).
	 */
	items(filter:="*.*") {
		static push := Func( A_AhkVersion < "2" ? "ObjInsert" : "ObjPush" )
		
		fso := ComObjCreate("Scripting.FileSystemObject")
		, psh := ComObjCreate("Shell.Application")
		, list := []
		, items := psh.NameSpace(this._.__path).Items()
		, items.Filter(0x00020|0x00040|0x00080, filter)
		for item in items
			member := {
			(Join Q C
				"base": {"__Class": "ZipFile.Member", "__Get": this.base.__Get},
				"_": [&this, item.Path]
			)}
			, %push%(list, member)
		return list
	}
	/* Function: item_info
	 * Retrieves details about an item in the archive.
	 * Syntax:
	 *     zip.item_info(item [, info ])
	 * Parameter(s):
	 *     item    [in] - Name/relative path of the item for which to retrieve
	 *                    the information.
	 *     info    [in] - One the following: [name, size, type, date, path].
	 *                    Defaults to 'name' if omitted.
	 */
	item_info(item, info:="name") {
		psh := ComObjCreate("Shell.Application")
		, pzip := psh.NameSpace(this._.__path)
		, item := pzip.ParseName(item)
		;// Name
		if (info = "name") {
			fso := ComObjCreate("Scripting.FileSystemObject")
			return fso.GetFileName(item.Path)
		} 
		;// Size, type, date
		else if (i:={"size":"Size", "type":"Type", "date":"ModifyDate"}[info])
			return item[i]
		;// Relative path
		else if (info = "path")
			return SubStr(item.Path, StrLen(this._.__path)+2)
	}
	;// PRIVATE -> for internal use
	__Get(k, p*) {
		;// Bypass 'base' and '__Class'
		if (k = "base" || k = "__Class")
			goto __zf_get
		;// Applies to each item object created by ZipFile.items()
		if (this.__Class == "ZipFile.Member") {
			zip := Object(this._[1])
			return zip.item_info(SubStr(this._[2], StrLen(zip._.__path)+2), k)
		}
		;// Full path of the zip archive
		else if (k = "path" || k = "__path") {
			return this._.__path
		}
		;// Name of the zip archive w/o path
		else if (k = "name") {
			fso := ComObjCreate("Scripting.FileSystemObject")
			return fso.GetFileName(this._.__path)
		}
		;// Private members
		else if this._.HasKey(k) {
			return this._[k]
		}

		__zf_get:
	}

	__Set(k, v, p*) {
		;// Bypass 'base' and '__Class'
		if (k != "base" && k != "__Class")
			return false ;// Make any property read-only
	}

	_NewEnum() {
		return {"enum":this.items()._NewEnum(), "base":{"Next":this.base.Next}}
	}

	Next(ByRef k, ByRef v:="") {
		if (r := this.enum.Next(k, v))
			k := v, v := ""
		return r
	}
}

ZipFile(file) {
	return new ZipFile(file)
}

