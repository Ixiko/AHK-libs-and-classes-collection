#include IDropTarget\IDropTarget.ahk

class menu_drop {
	; User methods:
	; call subscribe(myMenu, callbacks), for the callbacks parameter see IDropTarget's static new() method.
	; call unsubscribe(myMenu) to release the IDropTarget instance and stop callbacks.
	static subscribe(menu, callbacks) {
		local
		global IDropTarget
		this.SetMenuInfo menu 				; do this first to detect invalid input.
		IDT := IDropTarget.new(callbacks)
		this.handle_map[menu.handle] := IDT
		objaddref &menu	; The menu should be alive until unsubscribed.
		static WM_MENUGETOBJECT := 0x124
	
		if !this.onmsg_count ; turn on message monitoring if appropriate
			onmessage WM_MENUGETOBJECT, this.msgFn
		++this.onmsg_count
	}
	static unsubscribe(menu) {
		static WM_MENUGETOBJECT := 0x124
		; This should probably call SetMenuInfo again, but omitted for now.
		if !this.handle_map.has(menu.handle)
			throw exception('Invalid parameter #1', -1, 'menu')
		
		--this.onmsg_count
		if !this.onmsg_count ; turn off message monitoring if appropriate
			onmessage WM_MENUGETOBJECT, this.msgFn, 0
		this.handle_map.delete menu.handle
		if this.pos_map.has(menu.handle) ; need not be present, eg if the menu never recived a drop
			this.pos_map.delete menu.handle
		objrelease &menu
	}
	
	; Internal methods and properties.
	
	; Message monitor function for WM_MENUGETOBJECT:
	static pos_map := map() ; set in GetObject to indicate which menu item the cursor is hovering (zero-based).
	static GetObject(wParam, lParam, msg, hWnd) { 
	
		; return values:
		static MNGO_NOERROR := 0x00000001 ;An interface pointer was returned in the pvObj member of MENUGETOBJECTINFO
		static MNGO_NOINTERFACE := 0x00000000 ; The interface is not supported.
		local
		critical
		; tagMENUGETOBJECTINFO
		; flags := numget(lParam, 0, 'uint')
		; pos := numget(lParam, 4, 'uint')
		hMenu := numget(lParam, 8, 'ptr')
		; riid := numget(lParam, 8 + a_ptrsize, 'ptr')
		; pvObj := numget(lParam, 8 + a_ptrsize*2, 'ptr')

		if (this.handle_map.has(hMenu)) {
			idt := this.handle_map[hMenu]
			this.pos_map[hMenu] := numget(lParam, 4, 'uint')
			numput 'ptr', idt.ptr, lParam, 8+a_ptrsize*2 ; pvObj
			return MNGO_NOERROR
		}
		return MNGO_NOINTERFACE
	}
	static handle_map := map() 	; maps handles to IDropTarget instances
	static onmsg_count := 0		; reference count for turning on and off OnMessage
	static __new(){
		; Subclasses should override this method if they do not want to store their own msgFn.
		this.msgFn := objbindmethod(this, 'GetObject') ; The message monitor function. For WM_MENUGETOBJECT
	}
	static SetMenuInfo(m){
		local
		static sizeof_menuInfo := a_ptrsize == 8 ? 40 : 28
		/*
		typedef struct tagMENUINFO {
			DWORD     cbSize;
			DWORD     fMask;
			DWORD     dwStyle;
			UINT      cyMax;
			HBRUSH    hbrBack;
			DWORD     dwContextHelpID;
			ULONG_PTR dwMenuData;
		} MENUINFO, *LPMENUINFO;
		*/
		menuInfo := BufferAlloc(sizeof_menuInfo, 0)
		numput(	'uint', sizeof_menuInfo,		
				'uint', 0x10,						; values taken from kczx3, thanks
				'uint', 0x20000000 | 0x40000000, 	; MNS_DRAGDROP and MNS_MODELESS, the latter is required
				menuInfo) 
		if !dllcall('SetMenuInfo', 'Ptr', m.handle, 'Ptr', menuInfo, 'int')
			throw exception(a_thisfunc . ' failed',, a_lasterror)

	}
	static new(*){
		throw exception('Invalid usage')
	}
}