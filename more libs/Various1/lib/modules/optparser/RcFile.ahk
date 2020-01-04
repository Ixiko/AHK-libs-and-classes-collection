class RcFile extends OptParser.Option {

	__new(option1Dash, option2Dashes, optionClass, optionProperty=""
			, argumentDescription="", description="", flags=1
			, value="", initialValue="") {
		base.__new(option1Dash, option2Dashes, optionClass, optionProperty
				, argumentDescription, description, flags, value, initialValue)
		return this
	}

	set(argument, optionParser) {
		result := base.set(argument, optionParser)
		if (optionParser.useEnvVar) {
			argsFromRcFile := optionParser
					.processRcFile(this.optionClass[this.optionProperty])
			optionParser.argumentList.insertAt(optionParser.iPtr
					, argsFromRcFile*)
		}
		return result
	}
}
