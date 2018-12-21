class Dual {
	;;; Settings.
	; They are described in detail in the readme. Remember to mirror the defaults there.

	settings := {delay: 70, timeout: 300, doublePress: 200, specificDelays: false}


	;;; Public methods.
	; They are described in the readme. Remember to mirror the function headers there.

	; Note that a "key" might mean a combination of many keys, however it is often referred to as if
	; it was only one key, to simplify things. Sometimes, though, a key is referred to as a set of
	; subKeys. Keys taken as parameters in the `combine()`, `comboKey()` and `modifier()` methods
	; can either be a single key as a string (`"LShift"`) or an array of keys (`["LShift",
	; "LCtrl"]`). (See the `Dual.subKeySet() utility.`)

	__New(settings=false) {
		Dual.override(this.settings, settings)
	}

	combine(downKey, upKey, settings=false, combinators=false) {
		currentKey := A_ThisHotkey
		lastKey := A_PriorHotkey
		keys := this.getKeysFor(currentKey, downKey, upKey, settings, combinators)

		; A single `=` means case insensitive comparison. `-1` means the last two characters.
		keyState := (SubStr(currentKey, -1) = "UP") ? "keyup" : "keydown"
		this[keyState](keys, currentKey, lastKey)
	}

	comboKey(remappingKey=false, combinators=false) {
		; Allow `comboKey(combinators)`.
		if (not combinators and IsObject(remappingKey)) {
			combinators := remappingKey
			remappingKey := false
		}

		this.combo(Dual.cleanKey(A_ThisHotkey))

		key := remappingKey ? remappingKey : A_ThisHotkey
		Dual.sendSubKeySet(key, combinators)
	}

	; `justReleasedDownKeyTimeDown` is not documented in the readme, since it is only used internally.
	combo(currentKey, justReleasedDownKeyTimeDown=-1) {
		shorterTimeDownKeys := []
		for originalKey, keys in this.keys {
			upKey := keys.upKey
			downKey := keys.downKey
			if (downKey.isDown) {
				downKeyTimeDown := downKey.timeDown()
				withinDelay := (downKeyTimeDown < keys.getDelay(currentKey))
				if (downKeyTimeDown < justReleasedDownKeyTimeDown) {
					; Let's say you've combined f with shift and d with control. You press down f,
					; and then d, as to use a shift-control shortcut. However, you change your mind:
					; You want to to use just a control shortcut. So you release f. Even if the
					; timout has not passed, we do not want the upKey of f to be sent now, causing
					; control-f in effect (you still hold down d). That would be weird: It's like
					; you've pressed the shortcut backwards, f+control, and it still works! So if
					; there is at least one other dual-role key that has been down for a shorter
					; period of time than a just released dual-role key, return `false` to indicate
					; that the upKey of the just released dual-role key shouldn't be sent.
					if (not withinDelay) {
						return false
						; However, notice the `not withinDelay` check above. When you released f
						; above, what if the delay of d hasn't passed yet? That means that you
						; likely wanted to type fd, and typed that very quickly. You pressed down f,
						; and before even releasing f you pressed d, which means that f was released
						; while d was down. That usually means either control+f, or, if the delay
						; hasn't passed, df. Therefore, in that case, we should _not_ return
						; `false`. We _want_ the upKey of the just released dual-role to be sent.
					}
					; Instead, we collect the keys of the dual-role key that has been down for a
					; shorter period of time than the just released dual-role key (d in the above
					; example). These will be returned later on, so that they can be sent _after_
					; the upKey of the just released dual-role key (f in the above example), which
					; finally sends fd as we wanted.
					shorterTimeDownKeys.Insert(keys)
				} else if (withinDelay) {
					keys.abortDualRole()
				} else {
					downKey.down(true) ; Force it down, no matter what.
					downKey.combo := true
				}
			}
		}
		return shorterTimeDownKeys
	}

	modifier(remappingKey=false) {
		key := remappingKey ? remappingKey : A_ThisHotkey
		this.combine(key, key, {delay: 0, timeout: 0, doublePress: -1, specificDelays: false})
	}

	allModifiers := ["LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"]
	reset() {
		this.keys := {}
		for index, modifier in this.allModifiers {
			SendInput {%modifier% up}
		}
	}

	SendInput(string) {
		this.SendAny(string, "input")
	}
	SendEvent(string) {
		this.SendAny(string, "event")
	}
	SendPlay(string) {
		this.SendAny(string, "play")
	}
	SendRaw(string) {
		this.SendAny(string, "raw")
	}
	Send(string) {
		this.SendAny(string, "")
	}


	;;; Private.

	SendAny(string, mode="") {
		blind := (InStr(string, "{Blind}") == 1) ; Case insensitive. Perfect!
		temporarilyReleasedKeys := []
		if (not blind) {
			for originalKey, keys in this.keys {
				downKey := keys.downKey
				if (downKey.isDown) {
					downKey.up(true) ; Only send the key strokes; Don't reset times and such-like.
					temporarilyReleasedKeys.Insert(downKey)
				}
			}
		}

		if (mode == "input") {
			SendInput % string
		} else if (mode == "event") {
			SendEvent % string
		} else if (mode == "play") {
			SendPlay % string
		} else if (mode == "raw") {
			SendRaw % string
		} else {
			Send % string
		}

		for index, downKey in temporarilyReleasedKeys {
			downKey.down()
		}
	}

	keys := {}
	getKeysFor(currentKey, downKey, upKey, settings, combinators) {
		cleanKey := Dual.cleanKey(currentKey)
		if (this.keys[cleanKey]) {
			keys := this.keys[cleanKey]
		} else {
			keys := new Dual.KeyPair(downKey, upKey, this.settings, settings, combinators)
			this.keys[cleanKey] := keys
		}
		return keys
	}

	class KeyPair {
		__New(downKey, upKey, defaults, settings, combinators) {
			this.downKey := new Dual.Key(downKey)
			this.upKey   := new Dual.Key(upKey, combinators)
			Dual.override(defaults, settings, {onto: this})

			if (settings.specificDelays.extend) {
				this.specificDelays.Remove("extend")
				for keySet, delay in defaults.specificDelays {
					if (not ObjHasKey(this.specificDelays, keySet)) {
						this.specificDelays[keySet] := delay
					}
				}
			}

			this._specificDelays := []
			for keySet, delay in this.specificDelays {
				this._specificDelays.Insert({keySet: StrSplit(keySet, " "), delay: delay})
			}
		}

		getDelay(key) {
			for index, specificDelay in this._specificDelays {
				if (Dual.contains(specificDelay.keySet, key)) {
					return specificDelay.delay
				}
			}
			return this.delay
		}

		; Releases a dual-role key that is held down, and sends its upKey, so that it behaves as if
		; it was a normal key. In other words, its dual nature is aborted.
		abortDualRole() {
			downKey := this.downKey
			upKey   := this.upKey
			downKey.up()
			upKey.send()
			upKey.alreadySend := true
		}
	}

	class Key {
		__New(key, combinators=false) {
			this.key := Dual.subKeySet(key)
			this.combinators := combinators
		}

		isDown := false
		subKeysDown := {}
		down(sendActualKeyStrokes=true) {
			if (this.isDown == false) { ; Don't update any of this on OS simulated repeats.
				this.isDown := true
				this._timeDown := A_TickCount
			}

			; In order to support modifiers that do something when released, such as the alt and
			; Windows keys, it is possible to skip the for loop below, which sends the actual key
			; strokes.
			if (not sendActualKeyStrokes) {
				return
			}

			for index, key in this.key { ; (*)
				; Let's say you've made j also a shift key. Pressing j would then cause the
				; following: shift down, shift up, j down+up. Now let's say you hold down one of the
				; regular shift keys and then press j. That should result in a J, right? Yes, but it
				; doesn't, since the j-press also sent a shift up. So if an identical subKey is
				; already pressed, don't send it. That will also prevent the `up()` method from
				; sending it up.
				;
				; Remember that the OS repeats keys held down. So if a subKey is already marked as
				; down, we must send it again. Likewise, we must check every time if an identical
				; subKey is already pressed. The first time one might have been, but the second it
				; might not: The user can release it while holding the dual-role key.
				if (this.subKeysDown[key] or not GetKeyState(key)) {
					this.subKeysDown[key] := true
					Dual.sendInternal(key " down")
				}
			}
		}

		up(sendOnly=false) {
			if (not sendOnly) {
				this.isDown := false
				this._timeDown := false
				this._lastUpTime := A_TickCount
			}
			for index, key in this.key { ; (*)
				; Only send the subKey up if it was down. It might not have been sent down, due to
				; that another identical key was already down by then. Or, `up()` might already have
				; been called.
				if (this.subKeysDown[key]) {
					Dual.sendInternal(key " up")
				}
			}
			this.subKeysDown := {}
		}

		send() {
			this._lastUpTime := A_TickCount
			; `combinators` (if any) are only taken into account in this method, not in `down()` and
			; `up()`, to keep things simple. It doesn't make sense to use combinators for the
			; downKey, so it does not have `this.combinators`. In reality, only the downKey uses the
			; `down()` and `up()` methods, and only the upKey uses the `send()` method. YAGNI for
			; now.
			Dual.sendSubKeySet(this.key, this.combinators) ; (*)
		}

		; (*) The `down()`, `up()` and `send()` (via `Dual.sendSubKeySet()`) methods send input in a
		; loop, since a key might be a combination of keys, as mentioned before.

		_timeDown := false
		timeDown() {
			return Dual.timeSince(this._timeDown)
		}

		_lastUpTime := false
		timeSinceLastUp() {
			return Dual.timeSince(this._lastUpTime)
		}
	}

	keydown(keys, currentKey, lastKey) {
		downKey := keys.downKey
		upKey   := keys.upKey

		timeSinceLastUp := upKey.timeSinceLastUp()
		if (timeSinceLastUp != false
			and keys.doublePress != -1
			and timeSinceLastUp <= keys.doublePress ; (*1)
			and Dual.cleanKey(lastKey) == Dual.cleanKey(currentKey)) { ; (*2)
			upKey.repeatMode  := true
			upKey.alreadySend := true
		}
		; (*) The first line checks if a second press was quick enough to be a double-press.
		; However, another key might have been pressed in between, such as when writing "bob" (if b
		; is a dual-role key). The second line tries to work around that. It is not perfect though.
		; As usual, it only works with the comboKeys.

		if (upKey.repeatMode) {
			upKey.send()
			return
		}

		; Only send the actual key strokes if the timeout has passed, in order to support modifiers
		; that do something when released, such as the alt and Windows keys. The comboKeys will
		; force the downKey down, if they are combined before the timeout has passed.
		downKey.down(keys.timeout != -1 and downKey.timeDown() >= keys.timeout)
	}

	keyup(keys, currentKey, lastKey) {
		downKey := keys.downKey
		upKey   := keys.upKey

		downKeyTimeDown := downKey.timeDown() ; `downKey.up()` below resets it; better do it before!

		downKey.up()

		; Determine if the upKey should be sent.
		if (not downKey.combo
			and (downKeyTimeDown < keys.timeout or keys.timeout == -1)
			and not upKey.alreadySend) {
			; Dual-role keys are automatically comboKeys.
			shorterTimeDownKeys := this.combo(Dual.cleanKey(currentKey), downKeyTimeDown)
			; At this point, the upKey should be sent, mostly. However, there is one exception,
			; explained in `combo()`.
			if (shorterTimeDownKeys != false) { ; The exception referred to above.
				upKey.send()
				; The call of `combo()` above might call `abortDualRole()` for some other dual-role
				; keys, before the upKey was sent in the line above. However, sometimes that needs
				; to been done _after_ the upKey was sent. See `combo()` for an explaination.
				for index, keys in shorterTimeDownKeys {
					keys.abortDualRole()
				}
			}
		}

		downKey.combo     := false
		upKey.alreadySend := false
		upKey.repeatMode  := false
	}


	;;; Utilities
	; Call via `Dual.<method>()`, not `this.<method>()`, for consistency.

	; Cleans keys coming from `A_ThisHotkey`, which might look like `*j UP`.
	cleanKey(key) {
		; Allow single `#`, `!`, `^` etc.
		if (StrLen(key) == 1) {
			return key
		} else {
			return RegExReplace(key, "i)^[#!^+<>*~$]+| up$", "")
		}
	}

	static sentKeys := false
	sendInternal(string) {
		if (Dual.sentKeys) {
			Dual.sentKeys.Insert(string)
		} else {
			SendInput {Blind}{%string%}
		}
	}

	override(master, extension, options=false) {
		if (options.onto) {
			overrided := options.onto
			for key, value in master {
				overrided[key] := value
			}
		} else {
			overrided := master
		}
		for key, value in extension {
			if (not ObjHasKey(master, key)) {
				throw new Exception("Unrecognized key: " . key)
			}
			overrided[key] := value
		}
	}

	timeSince(time) {
		if (time == false) {
			return false
		} else {
			return A_TickCount - time
		}
	}

	subKeySet(key) {
		; A key might mean a combination of many keys. Therefore, `key` is an array. However, mostly
		; a single key will be used so a bare string is also accepted.
		if (not IsObject(key)) {
			key := [key]
		}

		; Support subKeys coming from `A_ThisHotkey`.
		for index, subKey in key {
			key[index] := Dual.cleanKey(subKey)
		}

		return key
	}

	sendSubKeySet(key, combinators=false) {
		for combinator, resultingKey in combinators {
			if (GetKeyState(combinator)) {
				key := resultingKey
				break
			}
		}

		key := Dual.subKeySet(key)

		for index, subKey in key {
			Dual.sendInternal(subKey)
		}
	}

	contains(array, searchItem) {
		for index, item in array {
			if (searchItem == item) {
				return true
			}
		}
		return false
	}
}
