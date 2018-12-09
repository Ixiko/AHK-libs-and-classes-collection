/*
class: PersistFile
wraps the *IPersistFile* interface and enables an object to be loaded from or saved to a disk file, rather than a storage object or stream.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PersistFile)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms687223)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows XP / Windows Server 2003 or higher
	Base classes - _CCF_Error_Handler_, Unknown, Persist
	Helper classes - STGM
*/
class PersistFile extends Persist
{
	/*
	Field: IID
	This is IID_IPersistFile. It is required to create an instance.
	*/
	static IID := "{0000010b-0000-0000-C000-000000000046}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: IsDirty
	Determines whether an object has changed since it was last saved to its current file.

	Returns:
		BOOL changed - true if the object changed, false otherwise
	*/
	IsDirty()
	{
		return this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr))
	}

	/*
	Method: Load
	Opens the specified file and initializes an object from the file contents.

	Parameters:
		STR path - The absolute path of the file to be opened.
		UINT flags - The access mode to be used when opening the file. Possible values are taken from the STGM enumeration. The method can treat this value as a suggestion, adding more restrictive permissions if necessary. You may use the fields of the STGM class for convenience.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Load(path, flags)
	{
		return this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "str", path, "uint", flags))
	}

	/*
	Method: Save
	Saves a copy of the object to the specified file.

	Parameters:
		STR path - The absolute path of the file to which the object should be saved. If path is NULL, the object should save its data to the current file, if there is one.
		BOOL remember - Indicates whether the path parameter is to be used as the current working file. If TRUE, path becomes the current file and the object should clear its dirty flag after the save. If FALSE, this save operation is a Save A Copy As ... operation. In this case, the current file is unchanged and the object should not clear its dirty flag. If path is NULL, the implementation should ignore the remember flag.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Save(path, remember)
	{
		return this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "str", path, "uint", remember))
	}

	/*
	Method: SaveCompleted
	Notifies the object that it can write to its file. It does this by notifying the object that it can revert from NoScribble mode (in which it must not write to its file), to Normal mode (in which it can). The component enters NoScribble mode when it receives an IPersistFile::Save call.

	Parameters:
		STR path - The absolute path of the file where the object was saved previously.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SaveCompleted(path)
	{
		return this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "str", path))
	}

	/*
	Method: GetCurFile
	Retrieves the current name of the file associated with the object. If there is no current working file, this method retrieves the default save prompt for the object.

	Returns:
		STR path - The path for the current file or the default file name prompt (such as *.txt). If an error occurs, this is set to NULL.
	*/
	GetCurFile()
	{
		local path
		this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "ptr", this.ptr, "ptr*", path))
		return StrGet(path)
	}
}
