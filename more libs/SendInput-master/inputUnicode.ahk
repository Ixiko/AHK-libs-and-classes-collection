class SendInputW {
	; Requires SendInput.ahk
	; About SendInput,
	; Url:
	;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms646310(v=vs.85).aspx (SendInput function)
	;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms646271(v=vs.85).aspx (KEYBDINPUT structure)
	; Input parameters:
	;	- str, a string to send via windows function SendInput() with unicode flag, see links above for more info.
	;	- sendOnlyDown, set to true to only send key  down  events,  charachters
	;        are  generally  printed on the down event. Behaviour vary between
	;        different target windows, set to false to  send  down  followed  by  up
	;        event. For example, notepad prints two subsequent equal key down events, eg, aa,
	;		 while notepad++ doesn't print the second a. If the target windows accepts
	;		 only down events, it uses half the memory and is faster. (experimental, set to false by default)
	; Methods:
	;	Send(str:="",sendOnlyDown:=false) See example usage
	;		
	; Example usage:
	;	Method 1)	 Pre-process and keep a reference,  a string is  pre-processed  and  a
	;				SendInput  object  is saved with all events written in memory 
	;				ready to send with just one call to windows SendInput()
	;
	;	- Pro: 	  Faster when the actuall send is invoked.
	;	- Con: 	  Non-dynamic, uses more memory.
	;	
	;	Code:
	;		siw:= new SendInputW(str)	; keep a reference, eg, siw
	;		siw.send()					; Invoke the send, no input parameters.
	;
	;	Method 2) 	Process and send, a string is processed and send directly when
	; 				processing is done. No reference is saved.
	;
	;	- Pro: Occupies no memory after send is done, dynamic.
	;	- Con: Slower.
	;
	;	Code:
	;		SendInputW.Send(str)		; Process str and send. Used memory is freed.
	;
	;	Notes on speed difference between methods. It is not very large.
	;	Notes on memory: Each key event requires 40 bytes on AHK64bit and 28 bytes on AHK32bit.
	;	Example memory usage: sendOnlyDown:=false, string length: 1000 chars, AHK64Bit: 1000*2*40=80kb, AHK32Bit: 1000*2*28=56kb
	;	
	__new(str,sendOnlyDown:=false){
		local inputArray
		inputArray:=this.process(str,sendOnlyDown)	; Pre-process the str
		this.si:= new SendInput(inputArray)						; Create a SendInput object. The input array is written to memory and discarded.
	}
	send(str:="",sendOnlyDown:=false){
		if (str!="")
			return new SendInputW(str,sendOnlyDown).send()	; Send method 2) 
		return this.si.send()								; Send method 1)
	}
	process(str,sod){
		static KEYEVENTF_KEYUP:=2
		static KEYEVENTF_UNICODE:=4
		local iArr,n,k,char
		iArr:=[]						; The array of input structures which will be passed to SendInput(.ahk)
		n:=sod?1:2						; Loop 1 if send only down
		for k, char in StrSplit(str)	; Each charachter is one down (and one up) event.
			loop, % n
				iArr.Push({type:"ki",vk:0,sc:ord(char),dwFlags:KEYEVENTF_UNICODE|(A_Index-1)*KEYEVENTF_KEYUP,time:0,dwExtraInfo:0})	; See SendInput.ahk for details on InputArray
		return iArr
	}
} 