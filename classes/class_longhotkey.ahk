class LongHotkey
{
	;	;	;	; 	; 	;	;	;	;
	; Author: Helgef
	; Date: 2016-10-21
	; Instructions:
	;

	; Class variables
	static instanceArray:=Object()										; Holds references to all objects derived from this class.
	static allHotkeys:=Object()											; Holds all registred hotkeys.
	static doNothingFunc:=ObjBindMethod(LongHotkey,"doNothing")			; All hotkeys are bound to this function.
	static globalContextFunc:=""										; Global context function, set via setGlobalContext()
	static allSuspended:=0												; Used for pseudo-suspending all hotkeys.
	static PriorLhk:=""													; Stores the long hotkey that was completed prior to the most recent completed lhk.
	static mostRecentLhk:=""											; Stores the most recent lhk.
	static TimeOfPriorLongHotkey:=""									; Stores the A_TickCount for the PriorLongHotkey.
	static TimeOfMostRecentLongHotkey:=""								; Stores the A_TickCount for the most recently completed LongHotkey.
	static hasFirstUps:=0												; Keeps track of whether any lhk has specified FirstUp option.
	static LatestFirstUp:=""											; For the first up option.
	; Instance variables
	hits:=0																; Tracks the progress of the long hotkey.
	contextFunc:=""														; Specified through setContext() method, to make the long hotkey context sensitive.
	suspended:=0														; Set by suspend() method, for pseudo-suspending hotkey.
	FirstUpAllowed:=1													; Used when enableFirstUp(true) has been called, to determine if upFunc should be called.
	upFunc:=""															; See comment on FirstUpAllowed.
	TimeOfThisLongHotkey:=""											; Stores the time of  the last completion for this lhk.

	;
	; Callable instance methods
	;

	setContext(function:="",params*)	{

		; Provide a function with an optional number of parameters to act as context function.
		; This function should return true if the hotkey should be considered as in context, else false.
		; Call setContext() without passing any parameters to remove context.
		if IsFunc(function)
			this.contextFunc:=Func(function).Bind(params*)
		else if (function="")
			this.contextFunc:=""
		return
	}

	suspend(bool:=1)	{

		; Pseudo-supend this hotkey. The registred hotkeys will remain, but the evaluation will terminate quick and no triggering is possible.
		; Call with bool:=1 or do not pass a parameter at all, to invoke suspension.
		; Call with bool:=0 to cancel suspension.
		; Call with bool:=-1 to toggle suspension.
		; Returns the current suspension state, ie., 1 for being suspended, 0 for not suspended.
		return this.suspended:=bool=-1?!this.suspended:bool
	}

	setFunction(function,params*)	{

		; Specify the name of the function that will be called when the long hotkey is completed, along with any number of parameters.
		; Can be a label.
		; If 'function' is not a function nor label, it is considered to be a string to send, it will be passed to LongHotkey.send()
		; By default a reference to this hotkey is pushed into the params* array.
		if	RegExMatch(function,"@$")															; Mark the function name with an @ (at) at the end to omit the reference to this instance in the params* array.	Eg, "myFunc@"
			function:=SubStr(function,1,-1)
		else
			params.push(this)

		if IsFunc(function)
			this.function:=Func(function).Bind(params*)											; Function to call when sequence is completed, with params.
		else if IsLabel(function)
			this.function:=function																; Label to call when sequence is completed.
		else if (function!="")
			this.function:=ObjBindMethod(LongHotkey,"Send",function)							; The parameter 'function' was not function nor label, send it as string instead.
		else
			this.function:=""
	}

	enableFirstUp(enable:=1)	{

		; Enable the first key in the long hotkey to trigger its normal press event on its release, in the case when no other keys in the long hotkey was pressed.
		; Call this function with parameter 0 to disable this behaviour.
		if enable
		{
			LongHotkey.hasFirstUps:=this.upFunc?LongHotkey.hasFirstUps:++LongHotkey.hasFirstUps ; Only increment hasFirstUps counter if upFunc doesn't exist.
			_downKey:=RegExReplace(this.keyList[1].down,"(?:\*|)(\w+)","{$1}") ; Encloses key name in "{ }"
			this.upFunc:=ObjBindMethod(LongHotkey,"SendFirstUp",_downKey)
		}
		else if (this.UpFunc!="")	; This check is to avoid decrement LongHotkey.hasFirstUps unless it has an upFunc
		{
			this.upFunc:=""
			LongHotkey.hasFirstUps--
		}
		return
	}

	ThisLongHotkey()	{

		; Similar to A_ThisHotkey.
		; Call this method on the reference passed to the success function, to get back the string that defined the hotkey.
		; Eg, A_ThisLongHotkey:=lh.ThisLongHotkey(), where lh is the last parameter of the success function, eg, f(x1,...,xn,lh)
		return this.keys
	}

	TimeSinceThisLongHotkey()	{
		; Similar to A_TimeSinceThisHotkey.
		; Returns the time (in ms) since this lhk was triggered.
		; If the long hotkey has never been triggered, this method returns -1.
		return this.TimeOfThisLongHotkey?A_TickCount-this.TimeOfThisLongHotkey:-1
	}

	getKeyList()	{
		; Similar to the ThisLongHotkey() method, but here an array is returned. Note that modifers doesn't get their own spots in the array, eg,
		; keys:="^ & a & b ! & c" transforms to keyList:=[^a, ^b, ^!c]
		; This description is not correct any more                  																		< - - NOTE
		return this.keyList
	}

	unregister()	{
		; Unregister this long hotkey. To free the object, do lh:="" afterwards, if you wish. Here, lh is an instance of the class LongHotkey.
		; To reregister, use reregister() method (not if lh:="" was done, obviously).
		_clonedList:=this.keyList.clone()
		LongHotkey.instanceArray.delete(this.instanceNumber)
		Hotkey, If, LongHotkey.Press()
		For _k, _key in _clonedList  ; For each key(.down) in this long hotkey, check if it is registred in any of the other hotkeys, if it is, do not unregister it, else, do.
		{
			_deleteThis:=1
			For _l, _lh in LongHotkey.instanceArray						; Search for the key in another long hotkey, if it is found, do not delete it.
			{
				For _m, _dndKey in _lh.keyList
				{
					if (_key.down=_dndKey.down)
					{
						_deleteThis:=0 ; do not delete key.
						break,2
					}
				}
			}
			if _deleteThis
			{
				Hotkey, % _key.down, Off									; Turn off the hotkey, and remove it from the allHotkeys list.
				LongHotkey.allHotkeys.delete(_key.down)
			}
		}
		this.keyList:=_clonedList									    ; The clone lives.
		this.registred:=0												; This long hotkey is not registred any more.
		Hotkey, If
		return
	}

	reregister()	{
		; Reregister a long hotkey, return 1 on success, 0 otherwise.
		if this.registred
			return 0
		For _k, _key in this.keyList 										; If we get here, this is the clone.
			LongHotkey.RegisterHotkey(_key.down)
		this.instanceNumber:=LongHotkey.instanceArray.push(this)
		this.registred:=1
		return 1
	}

	;
	;	Callable class methods
	;

	suspendAll(bool:=1)	{
		; Pseudo-supend all long hotkeys.
		; The registred hotkeys will remain, but the evaluation will terminate quick and no triggering is possible.
		; To truly suspend, use the built in Supend command.
		; Call with bool:=1 or do not pass a parameter at all, to invoke suspension.
		; Call with bool:=0 to cancel suspension.
		; Call with bool:=-1 to toggle suspension.
		; Returns the current suspension state, ie., 1 for all is suspended, 0 for not suspended
		return LongHotkey.allSuspended:=bool=-1?!LongHotkey.allSuspended:bool
	}

	setGlobalContext(function:="",params*)	{
		; Provide a function with an optional number of parameters to act as global context function.
		; If this function is set and returns 0 no hotkey is active.
		; This function should return true if the hotkey should be considered as in context, else false.
		; Call with setGlobalContext() without any parameters to remove context.
		if IsFunc(function)
			LongHotkey.globalContextFunc:=Func(function).Bind(params*)
		else if (function="")
			LongHotkey.globalContextFunc:=""
		return
	}

	unregisterAll(onOff:="Off")	{
		; Unregisters all hotkeys.
		; Do not pass a parameter
		Hotkey, If, LongHotkey.Press()
		For _key in LongHotkey.allHotkeys
			Hotkey, % _key, % onOff
		Hotkey, If,
		return
	}

	reregisterAll()	{
		; Reregisters all hotkeys.
		return LongHotkey.unregisterAll("On")
	}

	MostRecentLongHotkey(ref:=0)	{
		; This is returns the most recently completed long hotkey.
		; Call with ref:=0 or without any parameter, to get the key string that defined the hotkey that triggered most recently, eg,
		; "a & b & c".
		; Call with ref:=1 to recieve a reference to the most recent long hotkey instead.
		return !ref?LongHotkey.MostRecentLhk.keys:LongHotkey.MostRecentLhk
	}

	TimeSinceMostRecentLongHotkey()	{
		; Returns the time since (in ms.) the the most recently lhk was triggered.
		; If no long hotkey has been triggered, this method returns -1.
		return LongHotkey.TimeOfMostRecentLongHotkey?A_TickCount-LongHotkey.TimeOfMostRecentLongHotkey:-1
	}

	PriorLongHotkey(ref:=0)	{
		; Similar to A_PriorHotkey.
		; Call with ref:=0 or without any parameter, to get the key string that defined the hotkey that triggered prior to the most recent one, eg,
		; "a & b & c".
		; Call with ref:=1 to recieve a reference to the prior long hotkey instead.
		; returns blank if no PriorLongHotkey exists.
		return !ref?LongHotkey.Priorlhk.keys:LongHotkey.Priorlhk
	}

	TimeSincePriorLongHotkey()	{
		; Similar to A_TimeSincePriorHotkey
		; Returns the time since (in ms.) the prior lhk was last triggered. That is, time since the lhk prior to the most recent one was triggered.
		; If there is no prior long hotkey, this method returns -1.
		return LongHotkey.TimeOfPriorLongHotkey?A_TickCount-LongHotkey.TimeOfPriorLongHotkey:-1
	}
	;
	; End callable methods.
	;

	__New(keys,function,params*) 	{
		this.instanceNumber:=LongHotkey.instanceArray.Push(this)
		this.length:=this.processKeys(keys)							; Creates a "keyList" for this instance, and returns the appropriate length.
		this.registred:=1											; Indicates that the hotkeys are registred.
		this.keys:=keys
		this.setFunction(function,params*)
	}

	processKeys(str)	{
		; Pre-process routine, runs once per new long hotkey.
		; Converts the key string (str) to an array, keyList[n]:={down:modifier key_n, up: "*key_n up", tilde:true/false}
		; Eg, "^ & ~a & b & ! & c" -> 	keyList[1]:={down: "^a",  up: "*a up", tilde: 1}
		;								keyList[2]:={down: "^b",  up: "*b up", tilde: 0}
		;								keyList[3]:={down: "^!c", up: "*c up", tilde: 0}
		; Also makes a slightly redunant array: keyUpList[keyList[n].up]:=n. It is used in the Release() function, to quickly determine which part of the hotkey sequnce was released.
		;

		this.keyList:=Object()
		this.keyUpList:=Object()
		_modifiers:=""
		; Adjust key string (str) to fit pre-process routine
		str:=RegExReplace(str,"\s","") 									; Remove spaces.
		; Transfrom modifiers given by name to symbol styled modifier, eg, "LCtrl" --> "<^"
		_ModifierList := { LControl:"<^",LCtrl:"<^",RControl:">^",RCtrl:">^",Ctrl:"^",Control:"^"
						,LAlt:"<!",RAlt:">!",Alt:"!"
						,LShift:"<+",RShift:">+",Shift:"+"
						,LWin:"<#",RWin:">#",Win:"#"					; "Win" is not a supported key, but it works here.
						,AltGr:"<^>!"}

		; prepend @0 to last key if it is a modifier. Cheap way to make modifiers work as last key.
		if _ModifierList.HasKey(RegExReplace(str,".*&(.*)","$1"))
			str:=RegExReplace(str,"(.*&)","$1@0")
		For _name, _symbol in _ModifierList
			str:=RegExReplace(str,"i)\b" _name "\b", _symbol)			; Swap names for symbols.
		; Parse 1, tilde ~
		_ctr:=0															; For correct indexing of tilde ~.
		Loop, Parse, str,&
		{
			if RegExMatch(A_LoopField,"[\^!#+]+")
				continue
			_ctr++
			this.keyList[_ctr]:={}										; Create an empty "sub-object" at index _ctr, this will have three key-value pairs: down,up,tilde.
			if RegExMatch(A_LoopField,"~")
				this.keyList[_ctr].tilde:=1								; If key has tilde, 0 should be returned from Press(), then the key is not suppressed.
			else
				this.keyList[_ctr].tilde:=0								; Keys without tilde, should be suppressed.
		}
		str:=RegExReplace(str,"~","") 									; Remove all ~
		; Parse 2, set up key list and register hotkeys.
		_ctr:=0															; For correct indexing.
		Loop, Parse, str,&
		{
			if RegExMatch(A_LoopField,"[\^!#+]+") && !InStr(A_LoopField, "@0")						; Check if modifers. @0 is to allow last key as modifier.
			{
				_modifiers:=LongHotkey.sortModifiers(_modifiers A_LoopField)
				continue
			}
			_ctr++
			_key:=RegExReplace(A_LoopField,"@0")				; This is a cheap way to make modifiers work as last key
			LongHotkey.RegisterHotkey(_modifiers _key)			; Register this hotkey, i.e, modifier+key.
			this.keyList[_ctr].down:=_modifiers _key 			; Down events will trigger Press()
			this.keyList[_ctr].up:=(InStr(_key,"*")?"":"*") _key " up" 	; Using this format for the up event is due to that there seemed to be problems with modifiers. That is good english.
			; Test
			this.keyUpList[this.keyList[_ctr].up]:=_ctr					; This is slightly redundant, but it should improve performance.
			LongHotkey.allHotkeys[_modifiers _key]:=""			; This is used for un/re-registerAll().
		}
		return _ctr
	}

	sortModifiers(unsorted)	{
		; Helper function for process keys. Sorts modifiers, to aviod, eg, ^!b and !^b, this enables user to instanciate
		; long hotkeys like, "ctrl & a & alt & b" and "alt & a & ctrl & b", simultaneously.
		_ModifierList := [{"<^>!":4},{"<^":2},{">^":2},{"<!":2},{">!":2},{"<+":2}
						 ,{">+":2},{"<#":2},{">#":2},{"+":1},{"^":1},{"!":1},{"#":1}]
		_sorted:=""
		For _k, _mod in _ModifierList				; This is 13 iterations.
			For _symbol, _len in _mod				; This loop is one iteration.
				if (_p:=InStr(unsorted,_symbol))
					_sorted.=SubStr(unsorted,_p,_len), unsorted:=StrReplace(unsorted,_symbol,"")

		return _sorted
	}

	;;
	;;	Hotkey evaluation methods.
	;;

	Press()	{
		Critical,1000
		if (LongHotkey.allSuspended || (LongHotkey.LatestFirstUp!="" && ((LongHotkey.LatestFirstUp:="") || 1)))	; If pseudo-suspended, return 0 immediately, or if first up is needed to be suppressed.
			return 0
		if (LongHotkey.globalContextFunc!="" && !LongHotkey.globalContextFunc.Call())			; Global context check
			return 0
		_upEventRegistred:=0																	; To aviod registring the up event more than once
		_oneHit:=0, _tilde:=0																	; These values will togheter determine if the output should be suppressed or not, it is an unfortunate solution, w.r.t. maintainabillity. Hopefully it works and need not be changed.
		_priority:=0, _dp:=0	; In case a lot of hotkeys are triggered at the same time, or any other reason, one can set dp:=1 to make sure the timers for the success functions is set with decreaseing priority, hence they will not interupt eachother, but execute in the order their settimer is created. If you want the timers not to be interupted by other timers and such, set priority to a high enough value.
		For _k, _lh in LongHotkey.instanceArray
		{
			if (_lh.hits=0 && (_lh.suspended || (_lh.contextFunc!="" && !_lh.contextFunc.Call()))) 	; Check if suspended, and check context only when first key is pressed.
				continue
			if (_lh.hits>0 && _lh.keyList[_lh.hits].down=A_ThisHotkey)							; Key is same as last, suppress and continue.
			{
				_oneHit:=1
				_tilde+=_lh.keyList[_lh.hits].tilde
				continue
			}
			if (_lh.keyList[_lh.hits+1].down=A_ThisHotkey)										; Check if advanced.
			{
				_oneHit:=1
				_lh.hits+=1																		; Update hit count.
				_tilde+=_lh.keyList[_lh.hits].tilde
				if (_lh.hits=_lh.length)														; Hotkey completed.
				{
					_timerFunction:=_lh.function												; Set up function call.
					SetTimer, % _timerFunction,-1,% _priority - _dp								; priority and dp is explaind a few lines up.
					_lh.hits-=1																	; Decrement the hit count to enable auto-repeat of the hotkey-
					_lh.FirstUpAllowed:=0														; No "first up" if hotkey completed.
					; Manage TimeSince, and PriorLongHotkey stuff.
					_lh.TimeOfThisLongHotkey:=A_TickCount
					LongHotkey.PriorLhk:=LongHotkey.mostRecentLhk								; Manage prior long hotkey.
					LongHotkey.mostRecentLhk:=_lh
					LongHotkey.TimeOfPriorLongHotkey:=LongHotkey.TimeOfMostRecentLongHotkey		; Time stamps.
					LongHotkey.TimeOfMostRecentLongHotkey:=A_TickCount
					continue 																	; No need to bind up-event for last key.
				}
				if !_upEventRegistred
				{
					_doNothingFunc:=LongHotkey.doNothingFunc									; Hotkey has advanced, but not compeleted.
					Hotkey, If, LongHotkey.Release()											; Bind up-event.
					Hotkey, % _lh.keyList[_lh.hits].up, % _doNothingFunc, On
					Hotkey, If,
					_upEventRegistred:=1
				}
			}
		}
		return _oneHit*(_tilde=0) ;+_completedOne) ; If there is no hit, no suppress, if there is a tilde but no hotkey completed, no suppress, if there is a completed hotkey, suppress, regardless of tilde precence.
	}

	Release()	{
		; Every time a key is released, all long hotkeys are set to zero hits.
		Critical, On
		Hotkey, If, LongHotkey.Release()			; Unbind this up-event.
		Hotkey, % A_ThisHotkey, Off
		Hotkey, If
		; Determine if this up event should reset or decrease the hit count for any long hotkey. Also, manages the "first_up" option
		_oneTimerSet:=0												; For first up option
		if LongHotkey.hasFirstUps									; Do this check to avoid calling noMultiHits() unless necessary.
			_noMultiHits:=LongHotkey.noMultiHits() 					; For first up option

		For _k, _lh in LongHotkey.instanceArray
		{
			if (_lh.hits=0)
				continue
			if (_noMultiHits && !_oneTimerSet && _lh.upFunc!="" && _lh.hits=1 && _lh.FirstUpAllowed && _lh.keyList[1].up=A_ThisHotkey)
			{
				_timerFunction:=_lh.upFunc
				SetTimer,% _timerFunction,-1
				_oneTimerSet:=1										; Only send one time, in case more than one hotkey has this as first key.
				LongHotkey.LatestFirstUp:=_lh.keyList[1].down		; This is needed to disable Press() when the first up is triggered.
			}
			; Determine new hit count for this long hotkey.
			_n:=_lh.keyUpList[A_ThisHotkey]
			if (_n!="" && _n<=_lh.hits)
				_lh.hits:=_n-1
			_lh.FirstUpAllowed:=_lh.hits?_lh.FirstUpAllowed:1
		}
		return 0
	}

	noMultiHits()	{
		; Helper function for FirstUp option, called from Release()
		For _k, _lh in LongHotkey.instanceArray
			if !_lh.FirstUpAllowed
				return 0
		return 1
	}

	RegisterHotkey(key)	{
		; Register key to function doNothing(), under context LongHotkey.Press()
		_doNothingFunc:=LongHotkey.doNothingFunc
		Hotkey, If, LongHotkey.Press()
		if !LongHotkey.allHotkeys.HasKey(key)	; Make sure key not already registred.
		{
			Hotkey,% key,% _doNothingFunc, On
			LongHotkey.allHotkeys[key]:=""
		}
		Hotkey, If
		return
	}

	doNothing(){
		return		; All hotkeys are bound to this, serves two purposes:
	}				; 1. The hotkey command require a function/label, 2. calling this function will suppress the "usual" output of the hotkey, when needed.

	SendFirstUp(key)	{
		; Function to send first key in case enableFirstUp(1) has been called
		SendLevel,1 ; If there is problems with the first up function, try to increase/remove this.
		Send, % key
		return
	}

	Send(str)	{
		; Mostly for testing, but works if wanted.
		SendInput, % str
		return
	}

	; For the hotkey command.
	#If LongHotkey.Press()
	#If LongHotkey.Release()
	#If
}
