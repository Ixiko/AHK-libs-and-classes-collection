class String extends OptParser.Option {

	__new(option1Dash, option2Dashes, optionClass, optionProperty=""
			, argumentDescription="", description="", flags=1
			, value="", initialValue="") {
		base.__new(option1Dash, option2Dashes, optionClass, optionProperty
				, argumentDescription, description, flags, value, initialValue)
		return this
	}

	getShortMatch() {
		return "^" this.option1Dash ".*$"
	}
}
