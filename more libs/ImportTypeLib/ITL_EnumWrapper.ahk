class ITL_EnumWrapper extends ITL.ITL_ConstantMemberWrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local Base

		if (this != ITL.ITL_EnumWrapper)
		{
			Base.__New(typeInfo, lib)
			ObjInsert(this, "__New", Func("ITL_AbstractClassConstructor"))
		}
	}
}