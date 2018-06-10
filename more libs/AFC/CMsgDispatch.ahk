;
; Cooperative message dispatch OnMessage() wrapper
;

#include <CWindow>

/*!
	Class: CMsgDispatch
		Windows message dispatcher class. OOP analogue of `OnMessage()`.
		
		The message handler is active as long as the object exists.
		When it is destroyed, the message handler is unregistered.
	@UseShortForm
*/

class CMsgDispatch
{
	static __Table := []
	static __MsgRefCount := []
	
	/*!
		Constructor: (win, msg, handler)
			Creates a message dispatcher.
		Parameters:
			win - The [window](CWindow.html) in which to listen.
			msg - The message number to listen to.
			handler - [Event handler](EventHandlers.html) to be called when messages are received.
	*/
	
	__New(obj, msg, handler)
	{
		hwnd := obj.__Handle
		CMsgDispatch.__Table[hwnd, msg] := &this
		this.__ObjPtr := &obj
		this.__Win := hwnd
		this.__Msg := msg
		this.OnEvent := handler
		if not ++ CMsgDispatch.__MsgRefCount[msg]
		{
			CMsgDispatch.__MsgRefCount[msg] := 1
			OnMessage(msg, "__CMsgDispatchProc")
		}
	}
	
	__Delete()
	{
		CMsgDispatch.__Table[this.__Win].Remove(msg := this.__Msg, "")
		if not -- CMsgDispatch.__MsgRefCount[msg]
		{
			CMsgDispatch.__MsgRefCount.Remove(msg, "")
			OnMessage(msg, "")
		}
	}
	
	_(wParam, lParam, msg)
	{
		return this.OnEvent.(Object(this.__ObjPtr), wParam, lParam, msg, __CWindow_GetGui(), __CWindow_GetGuiControl())
	}
}

/*!
	End of class
*/

__CMsgDispatchProc(wParam, lParam, msg, hWnd)
{
	return Object(CMsgDispatch.__Table[hWnd, msg])._(wParam, lParam, msg)
}
