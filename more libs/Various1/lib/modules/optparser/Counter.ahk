class Counter {

	static flags := OptParser.OPT_NOARG
	optionClass := 0
	description := ""
	option1Dash := "-"

	__new(optionClass, optionProperty="", description=""
			, initialValue=1) {
		this.optionClass := optionClass
		this.optionProperty := optionProperty
		this.description := description
		this.optionClass[this.optionProperty] := initialValue

		return this
	}

	set(argumentDescription, op) {
		value := argumentDescription.SubStr(2)
		this.optionClass[this.optionProperty] := value
		op.iPtr += 1
		return value
	}

	getShortMatch() {
		return "^-[0-9]+$"
	}
}
