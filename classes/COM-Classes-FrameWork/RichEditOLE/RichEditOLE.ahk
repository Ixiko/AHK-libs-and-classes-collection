/*
class: RichEditOLE
wraps the *IRichEditOLE* interface and exposes the COM functionality of a rich edit control.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/RichEditOLE)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb774306)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Constant classes - REO, DVASPECT, CF
	Structure classes - REOBJECT, CHARRANGE
	Other classes - CCFramework

Remarks:
	- To create an instance of this class, call the (static) FromHWND() method.
	- The standard implementation returned by FromHWND() also implements ITextDocument. You can call QueryInterface() on the return value and supply its IID ("{8CC497C0-A1DF-11ce-8098-00AA0047BE5D}").
		Use ComObjEnwrap() to retrieve a dispatch object which can be used from your script.
		Also note there's an undocumented ITextDocument2 interface ("{01c25500-4268-11d1-883a-3c8b00c10000}"). Search "TOM.h" on google to get the header with its definition.
*/
class RichEditOLE extends Unknown
{
	/*
	Field: IID
	This is IID_IRichEditOLE. It is required to create an instance.
	*/
	static IID := "{00020D00-0000-0000-C000-000000000046}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: FromHWND
	creates a new instance of the class from the given HWND of a RichEdit control.

	Parameters:
		HWND ctrl - the HWND to the RichEdit control

	Returns:
		RichEditOLE instance - the new instance
	*/
	FromHWND(ctrl)
	{
		static EM_GETOLEINTERFACE := 0x43C
		local ptr
		DllCall("SendMessage", "uptr", ctrl, "uint", EM_GETOLEINTERFACE, "uint", 0, "ptr*", ptr)
		return new RichEditOLE(ptr)
	}

	/*
	Method: GetClientSite
	Retrieves an IOleClientSite interface to be used when creating a new object. All objects inserted into a rich edit control must use client site interfaces returned by this function. A client site may be used with exactly one object.

	Returns:
		OleClientSite client - the IOleClientSite, either as class instance (if available) or as pointer
	*/
	GetClientSite()
	{
		local client
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "ptr*", client))
		return IsObject(OleClientSite) ? new OleClientSite(client) : client
	}

	/*
	Method: GetObjectCount
	returns the number of objects currently contained in a rich edit control.

	Returns:
		INT count - the object count
	*/
	GetObjectCount()
	{
		this._Error(0)
		return DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr)
	}

	/*
	Method: GetLinkCount
	returns the number of objects in a rich edit control that are links.

	Returns:
		INT count - the number of objects in a rich edit control that are links
	*/
	GetLinkCount()
	{
		this._Error(0)
		return DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr)
	}

	/*
	Method: GetObject
	Retrieves information, stored in a REOBJECT structure, about an object in a rich edit control.

	Parameters:
		INT index - the object's zero-based index. If this parameter is REO.IOB_USE_CP, information about the object at the character position specified by the REOBJECT structure is returned.
		UINT flags - Operation flags that specify which interfaces to return in the structure. This can be a combination of the *interface information flags* in the REO enumeration class.

	Returns:
		REOBJECT object - the retrieved object
	*/
	GetObject(index, flags)
	{
		static reo_size := REOBJECT.GetRequiredSize()
		local obj := CCFramework.AllocateMemory(reo_size)
		this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "int", index, "ptr", obj, "uint", flags))
		return REOBJECT.FromStructPtr(obj)
	}

	/*
	Method: InsertObject
	inserts an object into a rich edit control.

	Parameters:
		REOBJECT obj - the object to isert, either as raw memory pointer or as REOBJECT class instance.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		If the cp member of the REOBJECT structure is REO.CP_SELECTION, the selection is replaced with the specified object.
	*/
	InsertObject(obj)
	{
		return this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "ptr", IsObject(obj) ? obj.ToStructPtr() : obj))
	}

	/*
	Method: ConvertObject
	converts an object to a new type. This call reloads the object but does not force an update; the caller must do this.

	Parameters:
		INT index - Index of the object to convert. If this parameter is REO.IOB_SELECTION, the selected object is to be converted.
		GUID clsid - Class identifier of the class to which the object is converted (as a CLSID string or raw pointer).
		STR type - User-visible type name of the class to which the object is converted.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	ConvertObject(index, clsid, type)
	{
		local mem
		if !CCFramework.isInteger(clsid)
			VarSetCapacity(mem, 16, 00), clsid := CCFramework.String2GUID(clsid, &mem)
		return this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "ptr", this.ptr, "int", index, "ptr", clsid, "str", type))
	}

	/*
	Method: ActivateAs
	handles Activate As behavior by unloading all objects of the old class, telling OLE to treat those objects as objects of the new class, and reloading the objects. If objects cannot be reloaded, they are deleted.

	Parameters:
		GUID old - Class identifier of the old class (as a CLSID string or raw pointer).
		GUID new - Class identifier of the new class (as a CLSID string or raw pointer).

	Returns:
		BOOL success - true on success, false otherwise
	*/
	ActivateAs(old, new)
	{
		local mem1, mem2
		if !CCFramework.isInteger(old)
			VarSetCapacity(mem1, 16, 00), old := CCFramework.String2GUID(old, &mem1)
		if !CCFramework.isInteger(new)
			VarSetCapacity(mem2, 16, 00), new := CCFramework.String2GUID(new, &mem2)
		return this._Error(DllCall(NumGet(this.vt+09*A_PtrSize), "ptr", this.ptr, "ptr", old, "ptr", new))
	}

	/*
	Method: SetHostNames
	sets the host names to be given to objects as they are inserted to a rich edit control. The host names are used in the user interface of servers to describe the container context of opened objects.

	Parameters:
		STR app - name of the container application.
		STR obj - name of the container document or object.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetHostNames(app, obj)
	{
		return this._Error(DllCall(NumGet(this.vt+10*A_PtrSize), "ptr", this.ptr, "str", app, "str", obj))
	}

	/*
	Method: SetLinkAvailable
	sets the value of the link-available bit in the object's flags. The link-available bit defaults to TRUE. It should be set to FALSE if any errors occur on the link which would indicate problems connecting to the linked object or application. When those problems are repaired, the bit should be set to TRUE again.

	Parameters:
		INT index - Index of object whose bit is to be set. If this parameter is REO.IOB_SELECTION, the bit on the selected object is to be set.
		BOOL value - Value used in the set operation. The value can be TRUE or FALSE.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetLinkAvailable(index, value)
	{
		return this._Error(DllCall(NumGet(this.vt+11*A_PtrSize), "ptr", this.ptr, "int", index, "uint", value))
	}

	/*
	Method: SetDvaspect
	sets the aspect that a rich edit control uses to draw an object. This call does not change the drawing information cached in the object; this must be done by the caller. The call does cause the object to be redrawn.

	Parameters:
		INT index - Index of the object whose aspect is to be set. If this parameter is REO.IOB_SELECTION, the aspect of the selected object is to be set.
		UINT aspect - Aspect to use when drawing. You may use the fields of the DVASPECT class for convenience.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetDvaspect(index, aspect)
	{
		return this._Error(DllCall(NumGet(this.vt+12*A_PtrSize), "ptr", this.ptr, "int", index, "uint", aspect))
	}

	/*
	Method: HandsOffStorage
	tells a rich edit control to release its reference to the storage interface associated with the specified object. This call does not call the object's IRichEditOle::HandsOffStorage method; the caller must do that.

	Parameters:
		INT index - the index of the object whose storage is to be released. If this parameter is REO.IOB_SELECTION, the storage of the selected object is to be released.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	HandsOffStorage(index)
	{
		return this._Error(DllCall(NumGet(this.vt+13*A_PtrSize), "ptr", this.ptr, "int", index))
	}

	/*
	Method: SaveCompleted
	tells a rich edit control that the most recent save operation has been completed and that it should hold onto a different storage for the object.

	Parameters:
		INT index - Index of the object whose storage is being specified. If this parameter is REO.IOB_SELECTION, the selected object is used.
		Storage stg - New storage for the object. If the storage is not NULL, the rich edit control releases any storage it is currently holding for the object and uses this new storage instead. This may be passed as raw pointer or class instance.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SaveCompleted(index, stg)
	{
		return this._Error(DllCall(NumGet(this.vt+14*A_PtrSize), "Ptr", this.ptr, "Int", index, "Ptr", IsObject(stg) ? stg.ptr : stg))
	}

	/*
	Method: InPlaceDeactivate
	tells a rich edit control to deactivate the currently active in-place object, if any.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		If there is no active in-place object, the method succeeds.
	*/
	InPlaceDeactivate()
	{
		return this._Error(DllCall(NumGet(this.vt+15*A_PtrSize), "Ptr", this.ptr))
	}

	/*
	Method: ContextSensitiveHelp
	tells a rich edit control that it should transition into or out of context-sensitive help mode. A rich edit control calls the <ContextSensitiveHelp> method of any in-place object which is currently active if a state change is occurring.

	Parameters:
		BOOL enter - Indicator of whether the control is entering context-sensitive help mode (TRUE) or leaving it (FALSE).

	Returns:
		BOOL success - true on success, false otherwise
	*/
	ContextSensitiveHelp(enter)
	{
		return this._Error(DllCall(NumGet(this.vt+16*A_PtrSize), "Ptr", this.ptr, "UInt", enter))
	}

	/*
	Method: GetClipboardData
	retrieves a clipboard object for a range in an edit control.

	Parameters:
		CHARRANGE range - structure specifying the range for which to create the clipboard object. This may be a class instance or a raw memory pointer.
		UINT reco - The clipboard operation flag. You may use the fields of the RECO class for convenience.

	Returns:
		DataObject obj - the IDataObject interface of the clipboard object representing the range specified, either as class instance (if available) or raw interface pointer.
	*/
	GetClipboardData(range, reco)
	{
		local obj
		this._Error(DllCall(NumGet(this.vt+17*A_PtrSize), "Ptr", this.ptr, "Ptr", IsObject(range) ? range.ToStructPtr() : range, "UInt", reco, "Ptr*", obj))
		return IsObject(DataObject) ? new DataObject(obj) : obj
	}

	/*
	Method: ImportDataObject
	imports a clipboard object into a rich edit control, replacing the current selection.

	Parameters:
		DataObject obj - IDataObject interface for the clipboard object to import, either as class instance or raw interface pointer.
		UINT cf - Clipboard format to use. A value of zero will use the best available format. You may use the fields of the CF class for convenience.
		[opt] UPTR hMetaPict - Handle to a metafile containing the icon view of an object. The handle is used only if the DVASPECT.ICON display aspect is required by a Paste Special operation.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	ImportDataObject(obj, cf, hMetaPict := 0)
	{
		return this._Error(DllCall(NumGet(this.vt+18*A_PtrSize), "Ptr", this.ptr, "Ptr", IsObject(obj) ? obj.ptr : obj, "UInt", cf, "Ptr", hMetaPict))
	}
}