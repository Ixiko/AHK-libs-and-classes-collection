ITL_InterfaceConstructor(this, instance)
{
	local interfacePtr
	if (!instance)
	{
		throw Exception("An instance of abstract type " this.base.__class " must not be created without supplying a valid instance pointer.", -1)
	}
	interfacePtr := ComObjQuery(instance, this.base[ITL.Properties.TYPE_GUID])
	if (!interfacePtr)
	{
		throw Exception(ITL_FormatException("Failed to create an instance of interface """ this.base[ITL.Properties.TYPE_NAME] """."
										, "The interface is not supported by the given class instance."
										, ErrorLevel, ""
										, !interfacePtr, "Invalid pointer returned by ComObjQuery() : " interfacePtr)*)
	}
	this[ITL.Properties.INSTANCE_POINTER] := interfacePtr
}