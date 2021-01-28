Class _FunctorEx extends eAutocomplete._FunctorEx._Proxy {
	call(_args*) {
		return base.call(_args*)
	}
	Class _Functor {
		static instances := {}
		__Call(_newEnum, _args*) {
			local
			if (IsObject(_newEnum)) {
				if (!_args.count())
					throw Exception("Invalid call.")
				__class := StrSplit(this.__Class, ".").pop()
				if not (_newEnum.hasKey(__class) || _newEnum.base.hasKey(__class))
					throw Exception("Invalid call.")
			return this.call(_args*)
			}
		}
	}
	Class _Proxy extends eAutocomplete._FunctorEx._Functor {
		test(_root, _maxParams, _k, _arg, _args*) {
			local _instances, __Class, _count, _inst, _arg_, _args_
			_instances := _root.instances, __class := StrSplit(this.__Class, ".").pop()
			if not (_instances.hasKey(__Class))
				_instances[__class] := {}
			_instances := _instances[__class], _count := _args.count()
			if not (_instances.hasKey(_k)) {
				if (_count = _maxParams - 2)
					_instances[_k] := {}
				else throw Exception("Invalid call.")
			} else if (_count <= _maxParams - 2) {
				if (!_count && (_arg = "")) {
					_instances[_k] := ""
					return "", _instances.delete(_k)
				} else if (_count = _maxParams - 3) {
					return _instances[_k, _arg]
				} else if not (_count = _maxParams - 2)
					throw Exception("Invalid call.")
			} else throw Exception("Invalid call.")
			_arg_ := _arg, _args_ := _args.clone()
			_instances := _instances[_k]
			_args_.insertAt(1, _arg_)
			Loop % _count {
				(IsObject(_instances[_arg_:=_args_.removeAt(1)]) || _instances[_arg_]:={})
				if (--_count)
					_instances := _instances[_arg_]
			}
			_instances[_arg_] := ""
		return _instances[_arg_] := new this(_k, _arg, _args*)
		}
		call(_k, _arg, _args*) {
			local base, _obj, _depth, _classPath, _className, _root
			_obj := this, _depth := 0
			while(_obj.base.__Class) {
				++_depth, _obj := _obj.base
			}
			_classPath := StrSplit(_obj.__Class, ".")
			_className := _classPath.removeAt(1)
			_root := %_className%[_classPath*]
			_obj := this
			while(_obj.base.base.base.base.__Class) {
				_obj := _obj.base
			}
			return this.test(_root, Func(_obj.__Class . ".__New").maxParams - 1, _k, _arg, _args*)
		}
	}
}