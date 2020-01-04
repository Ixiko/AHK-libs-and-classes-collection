class Option {
	option1Dash := ""
	option2Dashes := ""
	optionClass := 0
	argumentDescription := ""
	description := ""
	flags := 0
	value := ""
	defaultValue := ""

	__new(option1Dash, option2Dashes, optionClass, optionProperty
			, argumentDescription="", description="", flags=0
			, defaultValue=0, initialValue="") {
		this.option1Dash := (option1Dash != 0 ? "-" option1Dash : "")
		this.option2Dashes := (option2Dashes != ""
				? "--" option2Dashes
				: "")
		this.optionClass := optionClass
		this.optionProperty := optionProperty
		this.argumentDescription := (!(flags | OptParser.OPT_NOARG)
				&& argumentDescription = "" ? "..." : argumentDescription)
		this.description := description
		this.flags := flags
		this.defaultValue := defaultValue
		this.optionClass[this.optionProperty] := initialValue
		return this
	}

	usage() {
		if (this.flags & OptParser.OPT_HIDDEN) {
			return ""
		} else {
			return new OptParser.Line(this.optionUsage()
					, this.description).usage()
		}
	}

	optionUsage() {
		return this.option1Dash (this.option1Dash != ""
				&& this.option2Dashes != "" ? ", " : "")
				. (this.option2Dashes != ""
				&& this.flags & OptParser.OPT_NEG_USAGE
				? this.option2Dashes.replace("--", "--[no]")
				: this.option2Dashes) this.argumentUsage()
	}

	argumentUsage() {
		if (this.flags & OptParser.OPT_NOARG) {
			argUsage := ""
		} else {
			argNameInBrackets := "<" this.argumentDescription ">"
			if (this.flags & OptParser.OPT_OPTARG) {
				argUsage := "["
						. (this.option2Dashes != "" ? "=" : "")
						. argNameInBrackets "]"
			} else {
				argUsage := " " argNameInBrackets
			}
		}
		return argUsage
	}

	set(argument, optionParser) {
		if (this.defaultValue != ""
				&& (!(this.flags & OptParser.OPT_MULTIPLE)
				|| this.value = "")) {
			this.setValue(this.defaultValue)
		}
		if (this.flags & OptParser.OPT_ARGREQ
				|| this.flags & OptParser.OPT_OPTARG) {
			RegExMatch(argument
					, "iJ)^(-\w(?P<Argument>.+))|(--[\w-]+?=(?P<Argument>.+))$"
					, group)
			if (groupArgument != "") {
				this.setValue(groupArgument)
			} else if (optionParser.iPtr < optionParser.argumentList
					.maxIndex()) {
				nextArgument
						:= optionParser.argumentList[optionParser.iPtr + 1]
				if (nextArgument != ""
						&& SubStr(nextArgument, 1, 1) != "-"
						|| (this.flags & OptParser.OPT_ALLOW_SINGLE_DASH
						&& nextArgument == "-")) {
					optionParser.iPtr += 1
					this.setValue(nextArgument)
				}
			}
			if ((this.flags & OptParser.OPT_ARGREQ)
					&& this.optionClass[this.optionProperty] = "") {
				throw Exception("Missing argument '"
						. this.argumentDescription "'")
			}
		}
		optionParser.iPtr += 1
		return StrLen(this.optionClass[this.optionProperty])
	}

	setValue(value) {
		if (this.flags & OptParser.OPT_MULTIPLE) {
			if (!IsObject(this.optionClass[this.optionProperty])) {
				this.optionClass[this.optionProperty] := []
			}
			this.optionClass[this.optionProperty].Push(value)
		} else {
			this.optionClass[this.optionProperty] := value
		}
	}

	getLongMatch() {
		return "^" this.option2Dashes "(=.*)?$"
	}

	getShortMatch() {
		return "^" this.option1Dash "(=.*)?$"
	}
}
