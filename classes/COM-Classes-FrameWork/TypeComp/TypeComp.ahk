/*
class: TypeComp
wraps the *ITypeComp* interface and provides a fast way to access information that compilers need when binding to and instantiating structures and interfaces. Binding is the process of mapping names to types and type members.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TypeComp)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221247)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, Unknown
	Constant classes - DESCKIND, INVOKEKIND
	Structure classes - FUNCDESC, VARDESC
	Other classes - CCFramework, TypeInfo
*/
class TypeComp extends Unknown
{
	/*
	Field: IID
	This is IID_ITypeComp. It is required to create an instance.
	*/
	static IID := "{00020403-0000-0000-C000-000000000046}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: Bind
	Maps a name to a member of a type, or binds global variables and functions contained in a type library.

	Parameters:
		STR name - The name to be bound.
		[opt] UINT hash - The hash value for the name computed by LHashValOfNameSys. If ommitted, this is automatically done for you.
		[opt] SHORT flags - One or more of the flags defined in the INVOKEKIND enumeration class. Specifies whether the name was referenced as a method or a property. When binding to a variable, specify the flag INVOKE.PROPERTYGET. Specify zero (default) to bind to any type of member.
		[opt] byRef TypeInfo info - if a FUNCDESC or VARDESC is returned via "outValue", then this receives the type description that contains the item to which it is bound.
		[opt] byRef UINT kind - Indicates whether the name bound to is a VARDESC, FUNCDESC, or TYPECOMP. This is one of the fields in the DESCKIND enum class. If there was no match, DESCKIND.NONE.
		[opt] byRef VAR outValue - receives the bound-to VARDESC, FUNCDESC, or ITypeComp interface. If the corresponding class is available, it is used to wrap this value.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		If a VARDESC or FUNCDESC is returned via "outValue", the caller is responsible for deleting it with the returned type description ("info") by calling ITypeInfo::ReleaseFuncDesc or ITypeInfo::ReleaseVarDesc on it.
	*/
	Bind(name, hash := 0, flags := 0, byRef info := "", byRef kind := 0, byRef outValue := 0)
	{
		local bool
		if (!hash)
			hash := DllCall("OleAut32\LHashValOfName", "UInt", 0, "Str", name)
		bool := this._Error(DllCall(NumGet(this.vt, 03*A_PtrSize, "Ptr"), "Ptr", this.ptr, "Str", name, "UInt", hash, "Short", flags, "Ptr*", info, "UInt*", kind, "Ptr*", outValue, "Int"))
		if (info && IsObject(TypeInfo))
			info := new TypeInfo(info)
		if (kind == 1 && IsObject(FUNCDESC))
			outValue := FUNCDESC.FromStructPtr(outValue, false)
		if ((kind == 2 || kind == 4) && IsObject(VARDESC))
			outValue := VARDESC.FromStructPtr(outValue, false)
		if (kind == 3)
			outValue := new TypeComp(outValue)
		return bool
	}

	/*
	Method: BindType
	Binds to the type descriptions contained within a type library.

	Parameters:
		STR name - The name to be bound.
		[opt] UINT hash - The hash value for the name computed by LHashValOfNameSys. If ommitted, this is automatically done for you.
		[opt] byRef TypeInfo info - receives an ITypeInfo of the type to which the name was bound.
		[opt] byRef TypeComp comp - receives an ITypeComp variable.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	BindType(name, hash := 0, byRef info := 0, byRef comp := 0)
	{
		local bool
		if (!hash)
			hash := DllCall("OleAut32\LHashValOfName", "UInt", 0, "Str", name)
		bool := this._Error(DllCall(NumGet(this.vt, 04*A_PtrSize, "Ptr"), "Ptr", this.ptr, "Str", name, "UInt", hash, "Ptr*", info, "Ptr*", comp, "Int"))
		if (info && IsObject(TypeInfo))
			info := new TypeInfo(info)
		if (comp)
			comp := new TypeComp(comp)
		return bool
	}
}