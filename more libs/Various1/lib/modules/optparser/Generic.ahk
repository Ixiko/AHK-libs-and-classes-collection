class Generic {

	flags := OptParser.OPT_NOARG | OptParser.OPT_HIDDEN
	optionsClass := 0
	regularExpression := ""
	option2Dashes := "--"
	value := ""

	__new(regularExpression, optionClass, optionProperty="", flags=0) {
		this.optionsClass := optionClass
		this.optionProperty := optionProperty
		this.regularExpression := regularExpression
		this.flags := this.flags | flags
		return this
	}

	set(genericOption, op) {
		genericOptionWithoutDashes := genericOption.SubStr(3)
		op.iPtr += 1
		this.setValue(genericOptionWithoutDashes)
		return StrLen(this.optionsClass[this.optionProperty])
	}

	setValue(value) {
		value := RegExReplace(value, "i)^no-?", "!", "", 1)
		if (this.flags & OptParser.OPT_MULTIPLE) {
			if (!IsObject(this.optionsClass[this.optionProperty])) {
				this.optionsClass[this.optionProperty] := []
			}
			this.optionsClass[this.optionProperty].Push(value)
		} else {
			this.optionsClass[this.optionProperty] := value
		}
	}

	getLongMatch() {
		RegExMatch(this.regularExpression, "^([imsxADJUXPSC]+\))?(.*)", $)
		return $1 "^--" (this.flags & OptParser.OPT_NEG ? "(no-?)?" : "")
				. $2 "$"
	}
}
