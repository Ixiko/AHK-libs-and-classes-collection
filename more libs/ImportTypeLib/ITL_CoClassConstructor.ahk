ITL_CoClassConstructor(this, iid = 0)
{
	static IMPLTYPEFLAG_FDEFAULT := 1
	local info, typeAttr := 0, hr, iid_mem, instance := 0, typeName

	info := this.base[ITL.Properties.TYPE_TYPEINFO]
	typeName := this.base[ITL.Properties.TYPE_NAME]

	hr := DllCall(NumGet(NumGet(info+0), 03*A_PtrSize, "Ptr"), "Ptr", info, "Ptr*", typeAttr, "Int") ; ITypeInfo::GetTypeAttr()
	if (ITL_FAILED(hr) || !typeAttr)
	{
		throw Exception(ITL_FormatException("Failed to create an instance of the class """ typeName """."
										, "ITypeInfo::GetTypeAttr() failed."
										, ErrorLevel, hr
										, !typeAttr, "Invalid TYPEATTR pointer: " typeAttr)*)
	}

	if (!iid)
	{
		iid := this.base[ITL.Properties.TYPE_DEFAULTINTERFACE] ; get coclass default interface
		if (!iid) ; there's no default interface
		{
			throw Exception(ITL_FormatException("Failed to create an instance of the class """ typeName """."
											, "An IID must be specified to create an instance of this class."
											, ErrorLevel)*)
		}
	}

	hr := ITL_GUID_FromString(iid, iid_mem)
	if (ITL_FAILED(hr))
	{
		throw Exception(ITL_FormatException("Failed to create an instance of the class """ typeName """."
										, "The IID """ iid """ could not be converted."
										, ErrorLevel, hr)*)
	}
	iid := &iid_mem

	hr := DllCall(NumGet(NumGet(info+0), 16*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", 0, "Ptr", iid, "Ptr*", instance, "Int") ; ITypeInfo::CreateInstance()
	if (ITL_FAILED(hr) || !instance)
	{
		throw Exception(ITL_FormatException("Failed to create an instance of the class """ typeName """."
										, "ITypeInfo::CreateInstance() failed."
										, ErrorLevel, hr
										, !instance, "Invalid instance pointer: " instance)*)
	}

	return instance
}