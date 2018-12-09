; zero-based
class ITL_StructureArray
{
	__New(type, count)
	{
		this[ITL.Properties.ARRAY_ELEMTYPEOBJ] := type
		, this[ITL.Properties.ARRAY_ELEMCOUNT] := count
		, this[ITL.Properties.ARRAY_MEMBUFFER] := ITL_Mem_Allocate(count * type.GetSize())
		, this[ITL.Properties.ARRAY_ELEMSIZE] := type.GetSize()
		, this[ITL.Properties.ARRAY_INSTANCEOBJ] := []
	}

	__Get(property)
	{
		local buffer, size, index, struct, type
		if (property != "base" && !ITL.Properties.IsInternalProperty(property))
		{
			count := this[ITL.Properties.ARRAY_ELEMCOUNT]
			if (property == "")
			{
				buffer := this[ITL.Properties.ARRAY_MEMBUFFER], size := this[ITL.Properties.ARRAY_ELEMSIZE]
				for index, struct in this
				{
					ITL_Mem_Copy(struct[ITL.Properties.INSTANCE_POINTER], buffer + index * size, size)
				}
				return buffer
			}

			else if property is not integer
			{
				throw Exception(ITL_FormatException("Failed to retrieve an array element."
												, """" property """ is not a valid array index."
												, ErrorLevel)*)
			}
			else if (property < 0 || property >= count)
			{
				throw Exception(ITL_FormatException("Failed to retrieve an array element."
												, """" property """ is out of range."
												, ErrorLevel)*)
			}

			struct := this[ITL.Properties.ARRAY_INSTANCEOBJ][property]
			if (!IsObject(struct))
			{
				type := this[ITL.Properties.ARRAY_ELEMTYPEOBJ]
				, this[ITL.Properties.ARRAY_INSTANCEOBJ][property] := struct := new type()
			}
			return struct
		}
	}

	__Set(property, value)
	{
		local count := this[ITL.Properties.ARRAY_ELEMCOUNT]
		if (property != "base" && !ITL.Properties.IsInternalProperty(property))
		{
			if property is not integer
			{
				throw Exception(ITL_FormatException("Failed to set an array element."
												, """" property """ is not a valid array index."
												, ErrorLevel)*)
			}
			else if (property < 0 || property >= count)
			{
				throw Exception(ITL_FormatException("Failed to set an array element."
												, """" property """ is out of range."
												, ErrorLevel)*)
			}

			if value is integer
			{
				value := new this[ITL.Properties.ARRAY_ELEMTYPEOBJ](value, true)
			}
			this[ITL.Properties.ARRAY_INSTANCEOBJ][property] := value
		}
	}

	_NewEnum()
	{
		return ObjNewEnum(this[ITL.Properties.ARRAY_INSTANCEOBJ])
	}

	NewEnum()
	{
		return this._NewEnum()
	}

	SetCapacity(newCount)
	{
		local newBuffer := ITL_Mem_Allocate(newCount * this[ITL.Properties.ARRAY_ELEMSIZE])
		, oldBuffer := this[ITL.Properties.ARRAY_MEMBUFFER]
		, oldCount := this[ITL.Properties.ARRAY_ELEMCOUNT]

		ITL_Mem_Copy(oldBuffer, newBuffer, oldCount), ITL_Mem_Release(oldBuffer)
		this[ITL.Properties.ARRAY_MEMBUFFER] := newBuffer, this[ITL.Properties.ARRAY_ELEMCOUNT] := newCount

		if (newCount < oldCount)
		{
			this[ITL.Properties.ARRAY_INSTANCEOBJ].Remove(newCount - 1, oldCount - 1)
		}
	}
}