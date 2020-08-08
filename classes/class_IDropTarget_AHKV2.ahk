class IDropTarget {
	
	static instances := map()
	static new(callbacks) {
		; Callbacks, an object with any ownprops callaback pairs:
		; DragEnter :	(Data, grfKeyState, pt, pdwEffect) => { ... }
		; DragOver 	:	(grfKeyState, pt, pdwEffect) => { ... }
		; DragLeave	:	() => { ... }
		; Drop		:	(Data, grfKeyState, pt, pdwEffect) => { ... }
		; where Data is an object with ownprops:
		; CF_TEXT 	: an array of text dropped
		; CF_HDROP	: an array of files (paths) dropped
		; Data only has the property if they contain data, so check, eg, data.hasownprop('CF_TEXT') to see if
		; any text is being / has been dropped.
		; For the other params see IDropTarget docs on MSDN. In particular handle pdwEffect to set the correct cursor to indicate if the drop is handled.
		; The functions should return the HRESULT suitable for the corresponding IDropTarget methods.
		local
		global object
		cls := this ; for convenience, free var
		if !(callbacks is object)
			throw exception('Invalid parameter #1', -1, '"Callbacks" must be an Object.')
		IDT := BufferAlloc(a_ptrsize * 8, 0) ; the memory object which will hold the "binary instance", free var
		
		this := base.new() 		; The AHK object which will hold the reference to IDT
		pthis := &this			; Free var
		
		; Ptr property:
		this.defineprop 'ptr', {
			get : (this) => IDT.ptr
			; set throws
		}	
		
		; Interface methods, closures. In each method 'self' will hold the value of IDT.ptr.
		; IUnknown methods:
		QueryInterface(self, riid, ppvObject) => 0
		AddRef(self) =>  objaddref(pthis)	; increment the reference count for the AHK instance, as long as it is alive, the "binary instance" will be too.
		Release(self) => objrelease(pthis)	; decrement -- '' --
		; IDropTarget methods:
		DragEnter(p) {
			critical
			adr_to_arr(p, true)
			self := p[1], pDataObj := p[2], grfKeyState := p[3], pt := p[4], pdwEffect := p[5]
			grfKeyState &= 0xffffffff
			if pdwEffect == 0
				return 0x80000003 ; E_INVALID param
			data := cls.getData(pDataObj)
			return callCallback(a_thisfunc, data, grfKeyState, pt, pdwEffect)
		}
		DragOver(p) {
			critical
			adr_to_arr(p, false)
			self := p[1], grfKeyState:=p[2], pt := p[3], pdwEffect := p[4]
			if pdwEffect == 0
				return 0x80000003 ; E_INVALID param
			grfKeyState &= 0xffffffff
			return callCallback(a_thisfunc, grfKeyState, pt, pdwEffect)
		}
		DragLeave(self) {
			critical
			return callCallback(a_thisfunc)
		}
		Drop(p) {
			critical
			adr_to_arr(p, true)
			self := p[1], pDataObj := p[2], grfKeyState := p[3], pt := p[4], pdwEffect := p[5]
			if pdwEffect == 0
				return 0x80000003 ; E_INVALID param
			data := cls.getData(pDataObj)
			grfKeyState &= 0xffffffff
			return callCallback(a_thisfunc, data, grfKeyState, pt, pdwEffect)
		}
		adr_to_arr(byref p, has_data){
			; work around callbackcreate( variadic(p*) => expr,, paramcount > 0) not working.
			local
			a := []
			a.push numget(p, 0, 'ptr') 		; self
			o := has_data ? a_ptrsize : 0
			if has_data
				a.push numget(p, a_ptrsize*1, 'ptr') 	; data
			a.push numget(p, o + a_ptrsize*1, 'uint')	; grfKeyState
			a.push numget(p, o + a_ptrsize*2, 'int64')	; pt
			a.push numget(p, o + a_ptrsize*2+8, 'ptr')	; pdwEffect
			p := a
		}
		; Assemble the vTable:
		vtbl_pos := numput('ptr', IDT.ptr + a_ptrsize, IDT) ; vtbl address
		fn_count := 0
		; Note, DragEnter, DragOver and Drop really are 6 params because the pt param is a 64 bit value and counts as two variables, only relevant for 32-bit builds.
		for cbcp in [  ; callbackcreate params
			['QueryInterface',, 3],
			['AddRef',, 1],
			['Release',, 1],
			['DragEnter', '&', 6],	
			['DragOver', '&', 6],
			['DragLeave',, 1],
			['Drop', '&', 6]
		]
			; Write the methods to the vtbl
			vtbl_pos := numput('ptr', callbackcreate(cbcp*), vtbl_pos), fn_count++
			
		this.defineprop 'fn_count', {
			get : (this) => fn_count
			; set throws
		}
		return this
		
		; Help functions:
		callCallback(fn, p*) {
			; Calls a callback function if defined.
			if callbacks.hasownprop(fn)
				return %(callbacks.%fn%)%(p*)
			return 0
		}
	}
	; Clean up function:
	__delete() {
		vt := this.ptr + a_ptrsize ; vtbl
		; free all methods
		loop this.fn_count
			callbackfree numget(vt + (a_index-1) * a_ptrsize)
	}
	
	static getData(pDataObj) {
		; This function is used by IDropTarget methods, which recieves the pDataObj parameter,
		; to call IDataObject::GetData to get the data being dropped. The data is visible before the actual drop, and
		; a callback can determin if it accepts it or not and set the pdwEffect parameter appropriately.
		
		/*
		typedef struct tagFORMATETC {
			CLIPFORMAT     cfFormat;
			DVTARGETDEVICE *ptd;
			DWORD          dwAspect;
			LONG           lindex;
			DWORD          tymed;
		} FORMATETC, *LPFORMATETC;
		*/
		; cfFormat	:=	numget(rgelt, 0, 'short')
		; ptd		:=	numget(rgelt, a_ptrsize, 'ptr')
		; dwAspect	:=	numget(rgelt, a_ptrsize*2, 'uint')
		; lindex 	:=	numget(rgelt, a_ptrsize*2+4, 'int')
		; tymed 	:= 	numget(rgelt, a_ptrsize*2+8, 'uint')
		
		local
		
		data := {} 		; Will hold any data to be returned
		
		; Clipboard formats:
		static CF_TEXT        	:= 1
		static CF_BITMAP      	:= 2
		static CF_METAFILEPICT	:= 3
		static CF_SYLK        	:= 4
		static CF_DIF         	:= 5
		static CF_TIFF        	:= 6
		static CF_OEMTEXT     	:= 7
		static CF_DIB         	:= 8
		static CF_PALETTE     	:= 9
		static CF_PENDATA     	:= 10
		static CF_RIFF        	:= 11
		static CF_WAVE        	:= 12
		static CF_UNICODETEXT 	:= 13
		static CF_ENHMETAFILE 	:= 14
		static CF_HDROP       	:= 15
		static CF_LOCALE      	:= 16
		
		; enum tagTYMED
		;{
			static TYMED_HGLOBAL	:= 1
			static TYMED_FILE		:= 2
			static TYMED_ISTREAM	:= 4
			static TYMED_ISTORAGE	:= 8
			static TYMED_GDI		:= 16
			static TYMED_MFPICT		:= 32
			static TYMED_ENHMF		:= 64
			static TYMED_NULL		:= 0
		;} TYMED;
		
		static sizeof_FORMATETC := (a_ptrsize == 8 ? 32 : 20)
		pformatetc := bufferalloc(sizeof_FORMATETC)
		
		tymed_in := TYMED_HGLOBAL ; Currently the only one supported.
		
		for cfFormat in [CF_TEXT, CF_HDROP] {
			numput 'short', cfFormat, pformatetc, 0							; cfFormat
			numput 'ptr', 0, pformatetc, a_ptrsize							; ptd
			numput 'uint', 1, pformatetc, a_ptrsize * 2						; dwAspect
			numput 'uint', -1, pformatetc, a_ptrsize * 2 + 4				; lindex
			numput 'uint', tymed_in, pformatetc, a_ptrsize * 2 + 8			; tymed
			
			; HRESULT QueryGetData( FORMATETC *pformatetc);
			; Call IDataObject::QueryGetData to see if pDataObj accepts this clipboard format/TYMED combination
			HR := comcall(5, pDataObj, 'ptr', pformatetc)  ; IDataObject::QueryGetData
			if HR == 0 { ; S_OK, pDataObj accepts this, so get it
				pmedium := bufferalloc(a_ptrsize*3, 0)
				; Call GetData:
				comcall 3, pDataObj, 'ptr', pformatetc, 'ptr', pmedium ; IDataObject::GetData
				; Get tymed for verification:
				; This should probably not be needed but done for peace of mind.
				tymed_out := numget(pmedium, 'uint')
				if tymed_in !== tymed_out
					throw exception(a_thisfunc . ' failed',, 'tymed mismatch')
				
				; Handle this clipboard format:
				try {
					switch cfFormat {
						case CF_TEXT: 	this.getAnsiText(data, pmedium)
						case CF_HDROP: 	this.getWpath(data, pmedium)
						default: throw exception('Implementation error',, 'Unhandled clipboard format')
					}
				} catch e {
					throw e
				} finally {
					this.releaseMedium pmedium
				}
			}
		}
		return data
		
	}
	
	; Help functions:
	static getAnsiText(data, med) {
		; Handles CF_TEXT, TYMED_HGLOBAL
		local
		hGlobal := numget(med, a_ptrsize)
		if !pstr := this.GlobalLock(hGlobal)
			throw exception(a_thisfunc . ' failed',, 'GlobalLock')
		try {
			if !data.hasownprop('CF_TEXT')
				data.CF_TEXT := []
			data.CF_TEXT.push strget(pstr, 'cp0')
		} catch e {
			throw e
		} finally {
			this.GlobalUnlock hGlobal
		}
	}
	static getWpath(data, pmedium) {
		; Handles CF_HDROP, TYMED_HGLOBAL
		local
		hGlobal := numget(pmedium, a_ptrsize)
		if !hDrop := this.GlobalLock(hGlobal)
			throw exception(a_thisfunc . ' failed',, 'GlobalLock')
		; Get file count:
		try {
			count := this.DragQueryFile(hDrop, 0xffffffff)
			if !count
				return ; this is probably not possible, maybe out of mem.
			if !data.hasownprop('CF_HDROP')
				data.CF_HDROP := []
			loop count {
				strout := ''
				if this.DragQueryFile(hDrop, a_index - 1, strout)
					data.CF_HDROP.push strout
			}
		} catch e {
			throw e
		} finally {
			this.GlobalUnlock hGlobal
		}
	}
	
	; General help functions:
	static ReleaseMedium(med){
		if !numget(med, a_ptrsize * 2) ; punkForRelease == 0
			this.ReleaseStgMedium med
	}
	static ReleaseStgMedium(LPSTGMEDIUM) {
		/*
		void ReleaseStgMedium(
			IN LPSTGMEDIUM
		);
		*/
		dllcall 'Ole32.dll\ReleaseStgMedium', 'ptr', LPSTGMEDIUM
	}
	static GlobalLock(hMem) {
		return dllcall('Kernel32.dll\GlobalLock', 'ptr', hMem, 'ptr')
	}
	static GlobalUnlock(hMem) {
		return dllcall('Kernel32.dll\GlobalUnlock', 'ptr', hMem, 'int')
	}
	static DragQueryFile(hDrop, iFile, byref filename := '') {
		/*
		UINT DragQueryFileW(
			HDROP  hDrop,
			UINT   iFile,
			LPWSTR lpszFile,
			UINT   cch
		);
		*/
		; Note: For dllcall, if omitting the trailing W, the ansi version is called.
		local
		if iFile == 0xffffffff  ; requesting file count
			return dllcall('Shell32.dll\DragQueryFileW', 'ptr', hDrop, 'uint', iFile, 'ptr', 0, 'uint', 0, 'uint')
		if !isbyref(filename)
			throw exception('Invalid parameter #3', -1, 'filename')
		cch := dllcall('Shell32.dll\DragQueryFileW', 'ptr', hDrop, 'uint', iFile, 'ptr', 0, 'uint', 0, 'uint') ; request buffer size in characters
		cch += 1 ; for the null terminator
		lpszFile := bufferalloc(cch * 2)
		; get the string:
		r := dllcall('Shell32.dll\DragQueryFileW', 'ptr', hDrop, 'uint', iFile, 'ptr', lpszFile, 'uint', cch, 'uint') 
		if !r
			throw exception(a_thisfunc . ' failed', -1)
		filename := strget(lpszFile, 'UTF-16')
		return r ; char count (not including zero terminator.)
	}
} ; end IDropTarget