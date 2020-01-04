class Boolean extends OptParser.Option {
	value := true

	__new(option1Dash, option2Dashes, optionClass=0, optionProperty=""
			, description="", flags=0, initValue=false) {
		base.__new(option1Dash, option2Dashes, optionClass, optionProperty
				, "", description, flags | OptParser.OPT_NOARG, true
				, initValue)
		return this
	}

	set(argument, op) {
		if (RegExMatch(argument, "--(no-?)?(\w+)", $)) {
			base.set("--" $2, op)
			if ($1 != "") {
				this.optionClass[this.optionProperty]
						:= !this.optionClass[this.optionProperty]
			}
			return StrLen(this.optionClass[this.optionProperty])
		} else {
			return base.set(argument, op)
		}
	}

	getLongMatch() {
		return "^--" (this.flags & OptParser.OPT_NEG ? "(no-?)?" : "")
				. SubStr(this.option2Dashes, 3) "(=.*)?$"
	}
}
