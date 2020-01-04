class Callback extends OptParser.Option {

	pFunc := 0

	__new(option1Dash, option2Dashes, optionClass, optionProperty
			, functionName, argumentDescription="", description=""
			, flags=1) {
		base.__new(option1Dash, option2Dashes, optionClass, optionProperty
				, argumentDescription, description, flags, "", "")
		if (!IsFunc(functionName)) {
			throw Exception("Function not found: " functionName)
		}
		this.pFunc := Func(functionName)
		return this
	}

	set(argument, op) {
		no_opt := ""
		if (RegExMatch(argument, "--(no-?)?(\w+)", $)) {
			res := base.set("--" $2, op)
			no_opt := $1
		} else {
			res := base.set(argument, op)
		}
		value := this.pFunc.(this.optionClass[this.optionProperty]
				, no_opt)
		this.optionClass[this.optionProperty] := value
		return StrLen(value)
	}

	getLongMatch() {
		return "^--" (this.flags & OptParser.OPT_NEG ? "(no-?)?" : "")
				. SubStr(this.option2Dashes, 3) "(=.*)?$"
	}
}
