class WBClientSite
{
	__New(self)
	{
		ObjSetCapacity(this, "__Site", 3*A_PtrSize)
		NumPut(&self
		, NumPut(this.base._vftable("_vft_IInternetSecurityManager", "11348733")
		, NumPut(this.base._vftable("_vft_IServiceProvider", "3")
		, NumPut(this.base._vftable("_vft_IOleClientSite", "031010")
		    , this.__Ptr := ObjGetAddress(this, "__Site") ) ) ) )
	}

	_vftable(name, args)
	{
		if ( ptr := ObjGetAddress(this, name) )
			return ptr
		
		static IUnknown
		if !IUnknown
		{
			IUnknown := {
			(Join, Q C
				"QueryInterface": RegisterCallback(this._QueryInterface, "Fast")
				"AddRef":         RegisterCallback(this._AddRef, "Fast")
				"Release":        RegisterCallback(this._Release, "Fast")
			)}
		}

		sizeof_VFTABLE := (3 + StrLen(args)) * A_PtrSize
		ObjSetCapacity(this, name, sizeof_VFTABLE)
		ptr := ObjGetAddress(this, name)

		NumPut(IUnknown.QueryInterface, ptr + 0*A_PtrSize)
		NumPut(IUnknown.AddRef,         ptr + 1*A_PtrSize)
		NumPut(IUnknown.Release,        ptr + 2*A_PtrSize)

		for i, argc in StrSplit(args)
		{
			vfunc := RegisterCallback(this[SubStr(name, 6)], "Fast", argc+1, i)
			NumPut(vfunc, ptr + (3+i-1)*A_PtrSize)
		}

		return ptr
	}

	_QueryInterface(riid, ppvObject)
	{
		static IID_IUnknown := "{00000000-0000-0000-C000-000000000046}"
		     , IID_IOleClientSite := "{00000118-0000-0000-C000-000000000046}"
		     , IID_IServiceProvider := "{6d5140c1-7436-11ce-8034-00aa006009fa}"
		
		iid := WBClientSite._GUID2String(riid)
		if (iid = IID_IOleClientSite || iid = IID_IUnknown)
		{
			NumPut(this, ppvObject+0) ;// IOleClientSite
			return 0 ;// S_OK
		}
		if (iid = IID_IServiceProvider)
		{
			NumPut(this + A_PtrSize, ppvObject+0) ;// IServiceProvider
			return 0 ;// S_OK
		}
		NumPut(0, ppvObject+0)
		return 0x80004002 ;// E_NOINTERFACE
	}

	_AddRef()
	{
		return 1
	}

	_Release()
	{
		return 1
	}

	IOleClientSite(p1:="", p2:="", p3:="")
	{
		if (A_EventInfo == 3) ;// GetContainer
		{
			NumPut(0, p1+0) ;// *ppContainer := NULL
			return 0x80004002 ;// E_NOINTERFACE
		}
		return 0x80004001 ;// E_NOTIMPL
	}

	IServiceProvider(guidService, riid, ppv) ;// QueryService
	{
		static IID_IUnknown := "{00000000-0000-0000-C000-000000000046}"
		     , IID_IInternetSecurityManager := "{79eac9ee-baf9-11ce-8c82-00aa004ba90b}"
		
		if (WBClientSite._GUID2String(guidService) = IID_IInternetSecurityManager)
		{
			iid := WBClientSite._GUID2String(riid)
			if (iid = IID_IInternetSecurityManager || iid = IID_IUnknown)
			{
				NumPut(this + A_PtrSize, ppv+0) ;// IInternetSecurityManager
				return 0 ;// S_OK
			}
			NumPut(0, ppv+0)
			return 0x80004002 ;// E_NOINTERFACE
		}
		NumPut(0, ppv+0)
		return 0x80004001 ;// E_NOTIMPL
	}

	IInternetSecurityManager(p1:="", p2:="", p3:="", p4:="", p5:="", p6:="", p7:="", p8:="")
	{
		if (A_EventInfo == 5) ;// ProcessUrlAction
		{
		 	if (p2 == 0x1400) ;// dwAction = URLACTION_SCRIPT_RUN
		 	{
		 		NumPut(0x00, p3+0) ;// *pPolicy := URLPOLICY_ALLOW = 0x00
		 		return 0 ;// S_OK
		 	}
		}
		return 0x800C0011 ;// INET_E_DEFAULT_ACTION
	}

	_GUID2String(pGUID)
	{
		VarSetCapacity(string, 38*2)
		DllCall("ole32\StringFromGUID2", "ptr", pGUID, "str", string, "int", 39)
		return string
	}
}