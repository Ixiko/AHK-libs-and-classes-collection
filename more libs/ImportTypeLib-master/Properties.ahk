class Properties
{
	static INSTANCE_POINTER			:= "internal://type-instance"
	static INSTANCE_ENUMERATOR		:= "internal://instance-enumerator"

	static TYPE_TYPEINFO			:= "internal://typeinfo-instance"
	static TYPE_NAME				:= "internal://typeinfo-name"
	static TYPE_GUID				:= "internal://type-guid"
	static TYPE_RECORDINFO			:= "internal://rcinfo-instance"
	static TYPE_ENUMERATOR			:= "internal://enumerator-object"
	static TYPE_DEFAULTINTERFACE	:= "internal://default-iid"
	static TYPE_TYPELIBOBJ			:= "internal://typelib-object"

	static ARRAY_ELEMCOUNT			:= "internal://instance-count"
	static ARRAY_MEMBUFFER			:= "internal://memory-buffer"
	static ARRAY_ELEMTYPEOBJ		:= "internal://type-obj"
	static ARRAY_ELEMSIZE			:= "internal://instance-size"
	static ARRAY_INSTANCEOBJ		:= "internal://instance-array"

	static LIB_TYPELIB				:= "internal://typelib-instance"
	static LIB_NAME					:= "internal://typelib-name"
	static LIB_GUID					:= "internal://typelib-guid"

	IsInternalProperty(property)
	{
		return RegExMatch(property, "^internal://")
	}
}