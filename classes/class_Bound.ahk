Class Bound {

	Class Func { ; cf. https://github.com/Lexikos/xHotkey.ahk/blob/master/xHotkey_test.ahk

		__New(_fn, _args*) {

			if not (_v:=Bound.Func._isCallableObject(_fn))
				throw ErrorLevel:=1
			else this.fn := (_v < 1) ? _fn.bind(_args*) : ObjBindMethod(_fn, _args.removeAt(1), _args*)

		}
		__Call(_callee) {
			if (StrReplace(_callee, "call", "") = "") {
				_fn := this.fn
			return %_fn%()
			}
		}
		_isCallableObject(ByRef _callback) {
			if (IsFunc(_callback)) {
				((_callback.minParams = "") && _callback:=Func(_callback))
			return -1
			} else if (IsObject(_callback)) ; _callback.base.hasKey("__Call")
				return 1
			else return 0
		}

			Class Iterator {

				__New(_fn, _args*) {
				this.callableObject := new Bound.Func(_fn, _args*)
				}

					setPeriod(_period) {
					if (_f:=this.callableObject)
						SetTimer, % _f, % _period
					}
					delete() {
					if not (_f:=this.callableObject)
						return
							SetTimer, % _f, Off
							SetTimer, % _f, Delete
					return this.callableObject := ""
					}

			}

	}

}