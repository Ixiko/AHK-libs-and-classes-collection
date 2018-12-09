class ITL_StructureWrapper extends ITL.ITL_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		static GUID_NULL := "{00000000-0000-0000-0000-000000000000}", IID_ICreateTypeInfo := "{00020405-0000-0000-C000-000000000046}"
		local Base, hr := 0x00, rcinfo := 0, guid:= 0, createInfo, guid, typeName

		if (this != ITL.ITL_StructureWrapper)
		{
			Base.__New(typeInfo, lib)
			, typeName := this[ITL.Properties.TYPE_NAME]

			; If there's no GUID specified, this would cause GetRecordInfoFromTypeInfo() to fail
			; So we're trying to add a random-generated GUID just to keep it satisfied.
			if (lib.GetGUID(typeInfo, false, true) == GUID_NULL)
			{
				createInfo := ComObjQuery(typeInfo, IID_ICreateTypeInfo) ; query for the ICreateTypeInfo interface which can be used to modify the type
				if (!createInfo)
				{
					throw Exception(ITL_FormatException("Failed to create a wrapper for """ typeName """."
													, "QueryInterface() for ICreateTypeInfo failed."
													, ErrorLevel, ""
													, !createInfo, "Invalid ICreateTypeInfo pointer returned by ComObjQuery() : " createInfo)*)
				}

				hr := ITL_GUID_Create(guid) ; dynamically create a new GUID
				if (ITL_FAILED(hr))
				{
					throw Exception(ITL_FormatException("Failed to create a wrapper for """ typeName """."
													, "Creation of a GUID failed."
													, ErrorLevel, hr)*)
				}

				hr := DllCall(NumGet(NumGet(createInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", createInfo, "Ptr", &guid, "Int") ; ICreateTypeInfo::SetGuid() - assign a GUID for the type
				if (ITL_FAILED(hr))
				{
					throw Exception(ITL_FormatException("Failed to create a wrapper for """ typeName """."
													, "ICreateTypeInfo::SetGuid() failed."
													, ErrorLevel, hr)*)
				}
			}

			hr := DllCall("OleAut32\GetRecordInfoFromTypeInfo", "Ptr", typeInfo, "Ptr*", rcinfo, "Int") ; retrieve an IRecordInfo instance for a type
			if (ITL_FAILED(hr) || !rcinfo)
			{
				throw Exception(ITL_FormatException("Failed to create a wrapper for """ typeName """."
												, "GetRecordInfoFromTypeInfo() failed."
												, ErrorLevel, hr
												, !rcinfo, "Invalid IRecordInfo pointer: " rcinfo)*)
			}
			this[ITL.Properties.TYPE_RECORDINFO] := rcinfo

			ObjInsert(this, "__New", Func("ITL_StructureConstructor"))
		}
	}

	__Delete()
	{
		local hr, ptr, rcinfo
		if (ptr := this[ITL.Properties.INSTANCE_POINTER])
		{
			rcinfo := this.base[ITL.Properties.TYPE_RECORDINFO]
			hr := DllCall(NumGet(NumGet(rcinfo+0), 18*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptr, "Int") ; IRecordInfo::RecordDestroy()
			if (ITL_FAILED(hr))
			{
				throw Exception(ITL_FormatException("Failed to release structure of type """ this.base[ITL.Properties.TYPE_NAME] """."
												, "IRecordInfo::RecordDestroy() failed."
												, ErrorLevel, hr)*)
			}
		}
		else
		{
			rcinfo := this[ITL.Properties.TYPE_RECORDINFO]
			ObjRelease(rcinfo)
		}
	}

	__Get(field)
	{
		static sizeof_VARIANT := 8 + 2 * A_PtrSize
		local hr, ptr, variant := 0, rcinfo

		if (field != "base" && !ITL.Properties.IsInternalProperty(field)) ; ignore base and internal properties (handled by ITL_WrapperBaseClass)
		{
			ptr := this[ITL.Properties.INSTANCE_POINTER]
			if (ptr)
			{
				rcinfo := this.base[ITL.Properties.TYPE_RECORDINFO]

				if (VarSetCapacity(variant, sizeof_VARIANT, 00) != sizeof_VARIANT)
				{
					throw Exception(ITL_FormatException("Out of memory.", "Memory allocation for VARIANT failed.", ErrorLevel)*)
				}

				hr := DllCall(NumGet(NumGet(rcinfo+0), 10*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptr, "Str", field, "Ptr", &variant, "Int") ; IRecordInfo::GetField()
				if (ITL_FAILED(hr))
				{
					throw Exception(ITL_FormatException("Failed to retrieve a structure field."
													, "IRecordInfo::GetField() failed for field """ field """ on type """ this.base[ITL.Properties.TYPE_NAME] """."
													, ErrorLevel, hr)*)
				}

				return ITL_VARIANT_GetValue(&variant)
			}
			else if field is integer
			{
				if (field > 0)
				{
					return new ITL.ITL_StructureArray(this, field)
				}
			}
		}
	}

	__Set(field, value)
	{
		static INVOKE_PROPERTYPUT := 4
		local hr, ptr, variant := 0, rcinfo

		if (field != "base" && !ITL.Properties.IsInternalProperty(field)) ; ignore base and internal properties (handled by ITL_WrapperBaseClass)
		{
			ptr := this[ITL.Properties.INSTANCE_POINTER]
			, rcinfo := this.base[ITL.Properties.TYPE_RECORDINFO]

			ITL_VARIANT_Create(value, variant)
			hr := DllCall(NumGet(NumGet(rcinfo+0), 12*A_PtrSize, "Ptr"), "Ptr", rcinfo, "UInt", INVOKE_PROPERTYPUT, "Ptr", ptr, "Str", field, "Ptr", &variant, "Int") ; IRecordInfo::PutField()
			if (ITL_FAILED(hr))
			{
				throw Exception(ITL_FormatException("Failed to set a structure field."
												, "IRecordInfo::PutField() failed for field """ field """ on type """ this.base[ITL.Properties.TYPE_NAME] """."
												, ErrorLevel, hr)*)
			}

			return value
		}
	}

	_NewEnum()
	{
		local hr, info, rcinfo, attr := 0, obj, names_array, varCount := -1, name := ""

		obj := {} ; create a storage object
		rcinfo := this.base[ITL.Properties.TYPE_RECORDINFO]

		; call GetFieldNames() with a NULL array pointer -> retrieve the total field count through "varCount"
		hr := DllCall(NumGet(NumGet(rcinfo+0), 14 * A_PtrSize, "Ptr"), "Ptr", rcinfo, "UInt*", varCount, "Ptr", 0, "Int") ; IRecordInfo::GetFieldNames()
		if (ITL_FAILED(hr) || varCount == -1)
		{
			throw Exception(ITL_FormatException("Failed to enumerate structure members of type """ this.base[ITL.Properties.TYPE_NAME] """."
											, "IRecordInfo::GetFieldNames() failed."
											, ErrorLevel, hr
											, varCount != -1, "Invalid member count: " varCount)*)
		}

		VarSetCapacity(names_array, varCount * A_PtrSize, 00) ; allocate name array memory
		; call it again, this time supplying a valid array pointer
		hr := DllCall(NumGet(NumGet(rcinfo+0), 14 * A_PtrSize, "Ptr"), "Ptr", rcinfo, "UInt*", varCount, "Ptr", &names_array, "Int") ; IRecordInfo::GetFieldNames()
		if (ITL_FAILED(hr))
		{
			throw Exception(ITL_FormatException("Failed to enumerate structure members of type """ this.base[ITL.Properties.TYPE_NAME] """."
											, "IRecordInfo::GetFieldNames() failed."
											, ErrorLevel, hr)*)
		}

		Loop %varCount%
		{
			name := StrGet(NumGet(names_array, (A_Index - 1) * A_PtrSize, "Ptr"))
			obj.Insert(name, this[name])
		}

		return ObjNewEnum(obj)
	}

	NewEnum()
	{
		return this._NewEnum()
	}

	_Clone()
	{
		local hr, rcinfo := this.base[ITL.Properties.TYPE_RECORDINFO], ptrNew := 0, ptrOld := this[ITL.Properties.INSTANCE_POINTER], newObj

		newObj := new this.base()
		ptrNew := newObj[ITL.Properties.INSTANCE_POINTER]

		hr := DllCall(NumGet(NumGet(rcinfo+0), 05*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptrOld, "Ptr", ptrNew, "Int") ; IRecordInfo::RecordCopy()
		if (ITL_FAILED(hr))
		{
			throw Exception(ITL_FormatException("Failed to clone a structure instance."
											, "IRecordInfo::RecordCopy() failed."
											, ErrorLevel, hr)*)
		}

		return newObj
	}

	Clone()
	{
		return this._Clone()
	}

	GetSize()
	{
		local hr, size := -1, type, rcinfo

		type := this
		if (this[ITL.Properties.INSTANCE_POINTER])
			type := this.base
		
		rcinfo := type[ITL.Properties.TYPE_RECORDINFO]
			

		hr := DllCall(Numget(NumGet(rcinfo+0), 08*A_PtrSize, "Ptr"), "Ptr", rcinfo, "UInt*", size, "Int") ; IRecordInfo::GetSize()
		if (ITL_FAILED(hr) || size == -1)
		{
			throw Exception(ITL_FormatException("Failed to retrieve structure size for """ type[ITL.Properties.TYPE_NAME] """."
											, "IRecordInfo::GetSize() failed."
											, ErrorLevel, hr)*)
		}

		return size
	}

	Clear()
	{
		local hr, rcinfo := this.base[ITL.Properties.TYPE_RECORDINFO], ptr := this[ITL.Properties.INSTANCE_POINTER]
		hr := DllCall(NumGet(NumGet(rcinfo+0), 04*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptr, "Int") ; IRecordInfo::RecordClear()
		if (ITL_Failed(hr))
		{
			throw Exception(ITL_FormatException("Failed to clear a structure instance."
											, "IRecordInfo::RecordClear() failed."
											, ErrorLevel, hr)*)
		}
		hr := DllCall(NumGet(NumGet(rcinfo+0), 03*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptr, "Int") ; IRecordInfo::RecordInit()
		if (ITL_Failed(hr))
		{
			throw Exception(ITL_FormatException("Failed to clear a structure instance."
											, "RecordInit::RecordClear() failed."
											, ErrorLevel, hr)*)
		}
	}
}