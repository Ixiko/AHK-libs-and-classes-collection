/*
class: CustomDestinationList
wraps the *ICustomDestinationList* interface and exposes methods that allow an application to provide a custom Jump List, including destinations and tasks, for display in the taskbar.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/CustomDestinationList)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd378402)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7 / Windows Server 2008 R2 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Constant classes - KDC
	Other classes - CCFramework, ObjectArray, ShellLink, ShellItem
*/
class CustomDestinationList extends Unknown
{
	/*
	Field: CLSID
	This is CLSID_DestinationList. It is required to create an instance.
	*/
	static CLSID := "{77f10cf0-3db5-4966-b520-b7c54fd35ed6}"

	/*
	Field: IID
	This is IID_ICustomDestinationList. It is required to create an instance.
	*/
	static IID := "{6332debf-87b5-4670-90c0-5e57b408a49e}"

	/*
	Method: SetAppID
	Specifies a unique Application User Model ID (AppUserModelID) for the application whose taskbar button will hold the custom Jump List built through the methods of this interface. This method is optional.

	Parameters:
		STR id -  the AppUserModelID of the process or application whose taskbar representation receives the Jump List.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetAppID(id)
	{
		return this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "str", id))
	}

	/*
	Method: BeginList
	Initiates a building session for a custom Jump List.

	Parameters:
		[opt] byRef UINT slots - receives the current user setting for the Number of recent items to display in Jump Lists option in the Taskbar and Start Menu Properties window. The default value is 10. This is the maximum number of destinations that will be shown, and it is a total of all destinations, regardless of category. More destinations can be added, but they will not be shown in the UI. This number does not include separators and section headers as long as the total number of separators and headers does not exceed four.
		[opt] IID removedType - an IID for the interface to use to represent the list of removed items, either as raw pointer or GUID string. Defaults to IID_IObjectArray.
		[opt] byRef IUnknown removedItems - receives a raw interface pointer to a list of the type specified in the <removedType> parameter, which represents a collection of IShellItem and IShellLink objects that represent the removed items.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		The list interface retrieved in the removedItems parameter represents the same list of removed destinations that is retrieved through <GetRemovedDestinations>. When a new Jump List is being generated, applications must first process any removed destinations. Tracking data for any item in the removed list must be cleared. If an application attempts to include an item through <AppendCategory> that is present in this removed destinations list, the <AppendCategory> call fails.
	*/
	BeginList(byRef slots := "", removedType := "{92CA9DCD-5622-4bba-A805-5E9F541BD8C9}", byRef removedItems := "")
	{
		local mem

		if !CCFramework.isInteger(removedType)
			VarSetCapacity(mem, 16, 00), removedType := CCFramework.String2GUID(removedType, &mem)

		return this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "uint*", slots, "ptr", removedType, "ptr*", removedItems))
	}

	/*
	Method: AppendCategory
	Defines a custom category and the destinations that it contains, for inclusion in a custom Jump List.

	Parameters:
		STR name - a string that contains the display name of the custom category. This string is shown in the category's header in the Jump List. The string can directly hold the display name or it can be an indirect string representation, such as "@shell32.dll,-1324", to use a stored string. An indirect string enables the category header to be displayed in the user's selected language.
		ObjectArray items - an IObjectArray that represents one or more IShellItem objects that represent the destinations in the category. Some destinations in the list might also be represented by IShellLink objects, although less often. This can either be a raw interface pointer or a class instance.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		- Each custom category must have a unique name. Duplicate category names will cause presentation issues in the Jump List.
		- Any IShellLink used here must declare an argument list through SetArguments. Adding an IShellLink object with no arguments to a custom category is not supported since a user cannot pin or unpin this type of item from a Jump List, nor can they be added or removed.
	*/
	AppendCategory(name, items)
	{
		if IsObject(items)
			items := items.ptr
		return this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "str", name, "ptr", items))
	}

	/*
	Method: AppendKnownCategory
	Specifies that the *Frequent* or *Recent* category should be included in a custom Jump List.

	Parameters:
		UINT category - the category to add. You may use the fields of the KDC class for convenience.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	AppendKnownCategory(category)
	{
		return this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "uint", category))
	}

	/*
	Method: AddUserTasks
	Specifies items to include in the Tasks category of a custom Jump List.

	Parameters:
		ObjectArray tasks - an IObjectArray that represents one or more IShellLink (or, more rarely, IShellItem) objects that represent the tasks. This can either be a raw interface pointer or a class instance.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		- Any IShellLink used here must declare an argument list through SetArguments. Adding an IShellLink object with no arguments to a custom category is not supported. A user cannot pin or unpin this type of item from a Jump List, nor can they be added or removed.
		- Tasks should apply to the application as a whole; they are not meant to be specific to an individual window or document. For those more granular contextual tasks, an application can supply them through a thumbnail toolbar.
	*/
	AddUserTasks(tasks)
	{
		if IsObject(tasks)
			tasks := tasks.ptr
		return this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "ptr", tasks))
	}

	/*
	Method: CommitList
	Declares that the Jump List initiated by a call to <BeginList> is complete and ready for display.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	CommitList()
	{
		return this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "ptr", this.ptr))
	}

	/*
	Method: GetRemovedDestinations
	Retrieves the current list of destinations that have been removed by the user from the existing Jump List that this custom Jump List is meant to replace.

	Parameters:
		[opt] IID type - an IID for the interface to use to represent the list of removed items, either as raw pointer or GUID string. Defaults to IID_IObjectArray.

	Returns:
		IUnknown list - a raw interface pointer to a list of the type given with the <type> parameter.
	*/
	GetRemovedDestinations(type := "{92CA9DCD-5622-4bba-A805-5E9F541BD8C9}")
	{
		local mem, out

		if !CCFramework.isInteger(type)
			VarSetCapacity(mem, 16, 00), type := CCFramework.String2GUID(type, &mem)

		this._Error(DllCall(NumGet(this.vt+09*A_PtrSize), "ptr", this.ptr, "ptr", type, "ptr*", out))
		return out
	}

	/*
	Method: DeleteList
	Deletes a custom Jump List for a specified application.

	Parameters:
		STR id - the AppUserModelID of the process whose taskbar button representation displays the custom Jump List.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		There are several instances where this method should be called, including:
			- When the application is uninstalled.
			- When the user clears history from within the application.
			- When the user disables destination tracking in the application's Settings or Options pages.
	*/
	DeleteList(id)
	{
		return this._Error(DllCall(NumGet(this.vt+10*A_PtrSize), "ptr", this.ptr, "str", id))
	}

	/*
	Method: AbortList
	Discontinues a Jump List building session initiated by <BeginList> without committing any changes.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	AbortList()
	{
		return this._Error(DllCall(NumGet(this.vt+11*A_PtrSize), "ptr", this.ptr))
	}
}