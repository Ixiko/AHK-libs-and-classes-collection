class ITL
{
	static __New := Func("ITL_AbstractClassConstructor")

	#include ITL_WrapperBaseClass.ahk
	#Include ITL_ConstantMemberWrapperBaseClass.ahk

	#include ITL_CoClassWrapper.ahk
	#include ITL_InterfaceWrapper.ahk
	#include ITL_EnumWrapper.ahk
	#include ITL_StructureWrapper.ahk
	#include ITL_ModuleWrapper.ahk

	#include ITL_TypeLibWrapper.ahk

	#include ITL_StructureArray.ahk
	#include Properties.ahk
}