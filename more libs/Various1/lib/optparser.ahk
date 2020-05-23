class OptParser {

	requires() {
		return [Object, String]
	}

	/*
	 *	Constants: Parser & Option flags.
	 *		OPT_ARGREQ - Argument required.
	 *		OPT_ARG - Same as OPT_ARGREQ. For compatibilty issues
	 *		OPT_OPTARG - Optional argument.
	 *		OPT_NOARG - No argument allowed.
	 *		OPT_HIDDEN - Don't print argument in usage.
	 *		OPT_MULTIPLE - Collect arguments in a list.
	 *      OPT_NEG - Allow 'no-' prefix to invert options.
	 *      OPT_NEG_USAGE - Display as 'no'-option in usage.
	 *      PARSER_ALLOW_DASHED_ARGS - Allow dashes in arguments
	 */
	static OPT_ARG	     := 1
	static OPT_ARGREQ	 := 1
	static OPT_OPTARG	 := 2
	static OPT_NOARG	 := 4
	static OPT_HIDDEN	 := 8
	static OPT_MULTIPLE  := 16
	static OPT_NEG       := 32
	static OPT_NEG_USAGE := 64
	static OPT_ALLOW_SINGLE_DASH := 128

	static PARSER_ALLOW_DASHED_ARGS := 1

	static rcPathGlobal := A_AppDataCommon
	static rcPathUser := A_AppData
	static rcPathProject := A_WorkingDir

	envVarName := ""
	useEnvVar := true
	rcFileName := ""
	usageText := []
	optionList := []
	argumentList := []
	iPtr := 0
	exitOnDie := false
	hasCounter := false

	#Include %A_LineFile%\..\modules\optparser
	#Include Group.ahk
	#Include Line.ahk
	#Include Option.ahk
	#Include Boolean.ahk
	#Include String.ahk
	#Include Callback.ahk
	#Include RcFile.ahk
	#Include Counter.ahk
	#Include Generic.ahk

	__new(usageText, flags=0, envVarName="", rcFileName="") {
		if (IsObject(usageText)) {
			this.usageText := usageText
		} else {
			this.usageText := [usageText]
		}
		this.flags := flags
		this.envVarName := envVarName
		this.rcFileName := rcFileName
		return this
	}

	add(option) {
		if (Object.instanceOf(option, "OptParser.Counter")) {
			if (this.hasCounter) {
				this.die("Only one counter option per option parser allowed."	; NOTEST: 'die' method will never return
						, 3)													; NOTEST
			} else {
				this.hasCounter := true
			}
		}
		this.optionList.insert(option)
	}

	usage() {
		usageText := ""
		for i, usageOfParser in this.usageText {
			usageText .= (i = 1 ? "usage: " : "   or: ") usageOfParser "`n"
		}
		usageText .= "`n"
		for i, alternativeUsageOfParser in this.optionList {
			usageText .= ((usage := alternativeUsageOfParser.usage()) = ""
					? ""
					: usage "`n")
		}
		return usageText "`n"
	}

	die(message, exitCode=0) {
		if (!this.exitOnDie) {
			throw Exception(message, exitCode)
		} else {																; NOTEST: Not testable via TestCase class
			exitapp exitCode													; NOTEST
		}
	}

	parse(argumentList) {
		if (!IsObject(argumentList)) {
			throw Exception("The given argument is not an array")
		}
		cleanedArgumentList := this.handleEnvNoEnvOptions(argumentList)
		rcArgumentList := (this.useEnvVar == true
				? this.handleRcFiles(cleanedArgumentList)
				: cleanedArgumentList)
		envArgumentList := this.handleEnvironmentVariable(rcArgumentList)
		expandedArgumentList := this.expandBundeledOptions(envArgumentList)
		this.argumentList := expandedArgumentList
		this.parseArguments()
		return this.determineRemainigArguments()
	}

	handleRcFiles(inputArgumentList) {
		globalArgumentList := this.handleRcFile(inputArgumentList
				, OptParser.rcPathGlobal "\" this.rcFileName)
		userArgumentList := this.handleRcFile(globalArgumentList
				, OptParser.rcPathUser "\" this.rcFileName)
		projectArgumentList := this.handleRcFile(userArgumentList
				, OptParser.rcPathProject "\" this.rcFileName)
		return projectArgumentList
	}

	handleRcFile(argumentList, rcFile) {
		argsFromRcFile := this.processRcFile(rcFile)
		if (argsFromRcFile.maxIndex() != "") {
			argumentList.insertAt(1, argsFromRcFile*)
		}
		return argumentList
	}

	processRcFile(filePath) {
		argumentList := []
		fileAttributes := FileExist(filePath)
		if (fileAttributes && !InStr(fileAttributes, "D")) {
			try {
				rcFile := FileOpen(filePath, "r `n")
				while (not rcFile.atEOF) {
					line := rcFile.readLine()
					if (!RegExMatch(line, "^\s*(#.*)?$")) {
						args := StrSplit(line, [A_Space, A_Tab], "`r`n")
						argumentList.push(args*)
					}
				}
			} finally {
				if (rcFile) {
					rcFile.close()
				}
			}
		}
		return argumentList
	}

	handleEnvironmentVariable(argumentList) {
		if (this.envVarName) {
			envVarName := this.envVarName
			EnvGet optionsInEnvVar, %envVarName%
			if (this.useEnvVar && optionsInEnvVar) {
				argumentList.insertAt(1, optionsInEnvVar.toArray()*)
			}
		}
		return argumentList
	}

	expandBundeledOptions(argumentList) {
		alteredArgumentList := []
		while (A_Index <= argumentList.maxIndex()) {
			argument := argumentList[A_Index]
			try {
				if (RegExMatch(argument, "^-(?P<Arguments>[\w\W]+)"
						, bundled)) {
					alteredArgumentList
							:= this.processBundeledOptions(bundledArguments
							, alteredArgumentList, argument)
				} else {
					alteredArgumentList.insert(argument)
				}
			} catch argumentThatCantBeBundeled {
				alteredArgumentList.insert(argumentThatCantBeBundeled)
			}
		}
		return alteredArgumentList
	}

	parseArguments() {
		this.iPtr := this.argumentList.minIndex()
		validArgument := 0
		while (validArgument != -1
				&& this.iPtr <= this.argumentList.maxIndex()) {
			argumentToParse := this.argumentList[this.iPtr]
			if (this.optionList.maxIndex() = "") {
				validArgument := -1
			} else {
				validArgument
						:= this.testIfValidLongOrShortOption(argumentToParse)
				if (!validArgument) {
					this.die("Invalid argument: " argumentToParse)				; NOTEST: 'die' method will never return
				}
			}
		}
	}

	determineRemainigArguments() {
		remainingArguments := []
		while (this.iPtr != "" && this.iPtr <= this.argumentList.maxIndex()) {
			argument := this.argumentList[this.iPtr++]
			if (!(this.flags & OptParser.PARSER_ALLOW_DASHED_ARGS)
					&& SubStr(argument, 1, 1) = "-") {
				this.die("A remainig argument starts with a dash: "				; NOTEST: 'die' method will never return
						. argument, 4)											; NOTEST
			}
			remainingArguments.push(argument)
		}
		return remainingArguments
	}

	handleEnvNoEnvOptions(argumentList) {
		i := argumentList.minIndex()
		while (i <= argumentList.maxIndex()) {
			if (RegExMatch(argumentList[i], "--no-?env")) {
				argumentList.removeAt(i)
				this.useEnvVar := false
				continue
			} else if (argumentList[i] == "--env") {
				argumentList.removeAt(i)
				this.useEnvVar := true
				continue
			}
			i++
		}
		return argumentList
	}

	processBundeledOptions(bundledArguments, alteredArgumentList, argument) {
		loop % StrLen(bundledArguments) {
			option := SubStr(bundledArguments, A_Index, 1)
			if (!this.isBundlingOfThisOptionPossible(option)) {
				throw argument
			}
			alteredArgumentList.insert("-" option)
		}
		return alteredArgumentList
	}

	isBundlingOfThisOptionPossible(option) {
		p := this.optionList.minIndex()
		while (p <= this.optionList.maxIndex()) {
			if (SubStr(this.optionList[p].option1Dash, 0) == option) {
				if (this.optionList[p].flags & OptParser.OPT_ARGREQ) {
					return false
				} else {
					return true
				}
			}
			p++
		}
		return false
	}

	testIfValidLongOrShortOption(argumentToParse) {
		validOption := 0
		while (!validOption && A_Index <= this.optionList.maxIndex()) {
			option := this.optionList[A_Index]
			if (Object.instanceOf(option, "OptParser.Group")) {
				continue
			} else if (argumentToParse == "--"
					|| SubStr(argumentToParse, 1, 1) != "-") {
				if (argumentToParse == "--") {
					this.iPtr += 1
				}
				validOption := -1
			} else if ((option.option2Dashes != "" && RegExMatch(argumentToParse
					, option.getLongMatch()))
					|| (option.option1Dash != "" && RegExMatch(argumentToParse
					, option.getShortMatch()))) {
				option.set(argumentToParse, this)
				validOption := 1
			}
		}
		return validOption
	}
}
