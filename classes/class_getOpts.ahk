; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=64611
; Author:
; Date:
; for:     	AHK_L

/*


*/

/*      DESCRIPTION

        Intended to simplify checks of command line options passed to ahk
		scripts. Will treat a string array in a getOpt-similar manner and
		store options and values as key-value pairs.

		―――――――――――
		:1, Options
		―――――――――――

		-------------------------------
		:1.1, Regular opions and values
		-------------------------------
		Entries starting with "--" are interpreted as options, every
		consecutive non-option is treated as value to the nearest preceeding
		option. In
		  ["--myOpt", "1", "two", "III"]
		"myOpt" is the option, other entries are the option's values.
		(For checking option occurrence and retrieving options' values,
		refrer to :4, Methods)
		Multiple occurrences are possible. In a command line like
		  ["--rot", "X", "90", "--shr", "Z", "1.5", "--rot", "Y", "90"]
		"X", "90", and "Y", "90" are the values associated with the "rot"
		option. It is possible to retrieve options, which were passed with
		the second (1st, 4th, n-th , ...) call of an option, see
		:1.4, Option count.
		Empty values are ignored by default. In
		  ["--opt", "", ""]
		"opt" is treated as not having any values associated with it. (To
		change this, refer to :4.1, storeKV() or :3.1, Constructor)

		----------------------
		:1.2, The empty option
		----------------------
		Special option. If a value has no option to associate with, it is
		treated as a value for the empty option. In a command line like
		  ["1", "2", "3"]
		all the entries are values of the empty option. In this case, it
		is an implicit reference of the empty option. The "--" entry
		(option flag without any other chars) is the explicit reference.
		The command line above is treated in the same
		way as
		  ["--", "1", "2", "3"]
		In a command line like
		  ["1", "--opt", "two", "--", "3"]
		"1" and "3" are the values of the empty option. First reference of
		"--" is implicit, the second is explicit.
		(For retrieving the empty option's values, refer to :4.7 or :4.8 in
		Methods)

		--------------------
		:1.3, Single options
		--------------------
		In a sh command like "rm -rf /", each char between "-" and space is
		an option for itself, and executing "rm -r -f /" has the same effect
		(kids, do not try this at home, it is here just for the sake of
		example).
		getOpt treats command line entries starting with "-" (the single
		option flag) in a similar way	―― they are expanded 'by char'. A
		command line like
		  ["-opt"]
		is treated the same way as
		  ["--o", "--p", "--t"]
		Single char single options are treated as regular options, so
		  ["-opt"]
		is also the same as
		  ["-o", "-p", "-t"]
		Values following a single option are associated with the empty
		option (as it is unclear, to which of the characters they belong),
		as in
		  ["-opt", "42", "42"]
		with an implicit reference of the empty option. The single option
		flag by itself is an explicit reference, just like the regular
		option flag ("--"), so
		  ["-opt", "42", "42"]
		is the same as
		  ["-opt", "-", "42", "42"] or
		  ["-opt", "--", "42", "42"] or
		  ["-o", "-p", "-t", "--", "42", "42"]
		Multiple occurrences are possible, so in
		  ["-optop"]
		the "o" and "p" options are referenced twice and are not ignored the
		second time (see :1.4, Option count)
		To pass a value, you have to refer to an opton regularly, as in
		  ["-op", "--t", "42", "42"]
		this time, "42", "42" are values of the "t" option, and not of the
		empty option.

		------------------
		:1.4, Option count
		------------------
		There are two option counters.
		A global one to assign consecutive numbers to all options, so in
		getOpt.storeKV(["-option", "--nother opt"])
		getOpt.optNr(1) will return "o"
		getOpt.optNr(2) will return "p"
		 ...
		getOpt.optNr(5) will return "o"
		getOpt.optNr(7) will return "nother opt"
		Stored in the "optCallTotal" field.
		An occurrence count for each option to track the number of
		calls for this option. In a command line like
		cmdLine
		  := ["--rot", "X", "90", "--shr", "Z", "1.5", "--rot", "Y", "90"]
		getOpt.storeKV(cmdLine)
		getOpt.valOfOptStr("rot", 1, 2)
		will return "Y", the first val on second call of "rot".
		Stored in the "optCallCount" field, k-v-map, keys are the option
		names.

		―――――――――――
		:2, Numbers
		―――――――――――
		... are strings, which the autohotkey interpreter would treat in a
		numeric way (decimal integers, floats, e-notation floats and
		hexadecimal intgers).
		Such strings are treated as values by default. So, in a
		command line like  ["-42"], the "-42" string is treated as a value
		to the empty option, and not as a single option. Numbers with "--"
		prepended are treated as options, so
		["---1", "minus one"]
		is the option "-1" with the value "minus one". Same goes for all
		kinds of number strings.
		One detail to no te: hexadecimal keys are automatically converted to
		decimals, so in ["--0xA", "val"] "val" is associated with the "10"
		key.
		It is not possible to pass numbers as single options, i. e. to treat
		["-42"] as ["-4", "-2"].

		―――――――――――――――――
		:3, Instantiation
		―――――――――――――――――
		In the majority of cases you will deal with A_Args and only one
		getOpt object. So, no instantiation is needed and the key-vals are
		stored to the getOpt prototype directly. Thus, getOpt.storeKV() will
		store strings from A_Args to getOpt and
		getOpt.valOfOptNr(1) will return the first val of the first option
		in A_Args, etc.
		Also, to handle several command lines, but one at a time, you will
		only need the one getOpt object. So,
		getOpt.storeKV(cmdLine1)
		... handle cmdLine1 ...
		getOpt.storeKV(cmdLine2)
		... handle cmdLine2 ...
		will work fine (well, at least it is supposed to)
		To deal with different command lines in parallel, you will need
		different getOpt objects. So,
		getOptObj1 := new getOpt(cmdLine1)
		getOptObj1.storeKV()
		getOptObj2 := new getOpt(cmdLine2)
		getOptObj2.storeKV()
		getOptObj1.valOfOptNr(1) will return the first val of the first
		option in cmdLine1
		getOptObj2.valOfOptNr(2) will return the first val of the second
		option in cmdLine2, etc.

		-----------------
		:3.1, Constructor
		-----------------
		Will take the same args as storeKV().
		After constructing an getOpt object, you will have to call its
		storeKV() method to actually store the key-vals. (see :4.1,
		storeKV())

		―――――――――――
		:4, Methods
		―――――――――――

		------------------------------------------
		:4.1, storeKV(cmdLine, empty vals setting)
		------------------------------------------
		will associalte options with their values and store as k-v pairs.

		1st argument:
		String array. The command line to store.
		If no cmdLine is explicitly passed (which is the same as passing "")
		, will interpret A_Args.
		If the object, on which storeKV() is called, already has a cmdLine
		assigned (passed on construction, or the storeKV() method has been
		already called on this object), and no cmdLine is explicitly given,
		will interpret the object's cmdLine. The object's cmdLine is stored
		in the "args" field.

		2nd argument:
		getOpt.ALLOW_EMPTY_VALS and getOpt.IGNORE_EMPTY_VALS are the
		possible values (false and true, respectively).
		getOpt.IGNORE_EMPTY_VALS is the default setting.

		Examples:
		getOpt.storeKV() will interpret A_Args.
		getOpt.storeKV(["one", "two", "three"]) will interpret
		["one", "two", "three"].
		getOpt.storeKV() will interpret ["one", "two", "three"] again.
		getOpt.args := ""
		getOpt.storeKV()
		will interpret A_Args again.
		go1 := new getOpt(["one", "two", "three"])
		go1.storeKV()
		will interpret ["one", "two", "three"].
		go1.args := ""
		go1.storeKV()
		will interpret A_Args.

		-----------------------
		:4.2, hasOptStr(optStr)
		-----------------------
		Whether the string optStr has been passed as option.

		Return val: boolean

		Examples:
		getOpt.storeKV(["--myopt", "myVal", "myVal"])
		getOpt.hasOptStr("myOpt")
		will return true.
		getOpt.hasOptStr("someOtherOpt") will return false.
		getOpt.storeKV(["-abcd"])
		getOpt.hasOptStr("a"), ..., getOpt.hasOptStr("d")
		will return true.
		getOpt.storeKV(["vals", "vals", "everywhere"])
		getOpt.hasOptStr("") will return true, as the empty option has
		been (implicitly) called.

		---------------------
		:4.3, hasOptNr(optNr)
		---------------------
		Whether optNr-th option has been passed.

		Return val: boolean

		Examples:
		getOpt.storeKV(["--anOpt", "val", "--notherOpt"])
		getOpt.hasOptNr(1), getOpt.hasOptNr(2)
		will return true.
		getOpt.hasOptNr(3) will return false.
		getOpt.storeKV(["-abcd", "val"])
		getOpt.hasOptNr(1), ..., getOpt.hasOptNr(4)
		will return true.
		getOpt.hasOptNr(5) will return true (the empty option is the
		fifth option passed, as single options don't take values, so "val"
		is assigned to the empty option).
		getOpt.storeKV(["vals", "vals", "everywhere"])
		getOpt.hasOptNr(1)
		will return true, as the empty option is the first option called.

		------------------
		:4.4, optNr(count)
		------------------
		Returns the count-th option of cmdLine, or "", if no count-th
		option was on cmdLine.

		Return val: string
		The "" return value is ambiguous, it either means 'no count-th
		option' or 'count-th option is the empty option'. Check existence
		with hasOptNr(optNr)

		Examples:
		getOpt.storeKV(["--anOpt", "--notherOpt"])
		getOpt.optNr(1), will return "anOpt"
		getOpt.optNr(2), will return "notherOpt"
		getOpt.optNr(3), will return ""
		getOpt.storeKV(["vals", "vals", "everywhere"])
		getOpt.optNr(1),
		will return "", the empty option in this case.

		-----------------------------------------
		:4.5, optStrHasVal(optStr, valNr, callNr)
		-----------------------------------------
		Whether valNr-th value has been passed on callNr-th call of option
		optStr. 1 is the default for valNr and callNr.

		1st argument:
		String. The option to query. "" denotes the empty option.

		2nd argument:
		Positive integer or special value. 1 is default val.
		getOpt.ALL or getOpt.ALL_FLAT are special args that can be passed
		to determine, if vals were passed with callNr-th call of optStr at
		all.

		3rd argument:
		Positive integer or special value. 1 is default val.
		getOpt.ALL or getOpt.ALL_FLAT are special args that can be passed to
		determine, if vals were passed with any call of optStr at all. The
		second argument is ignored in this case.

		return val: boolean or "".
		Will return "", if optStr is not an option. Check existence
		with hasOptStr(optStr).

		Examples:
		cmdLine := ["--r", "I", "II", "--a", "1", "2", "--r", "III", "IV"]
		getOpt.storeKV(cmdLine)
		getOpt.optStrHasVal("r") ( same as getOpt.optStrHasVal("r",1,1) )
		will return true (first val passed on first call of "r" is "I").
		getOpt.optStrHasVal("r", 3) will return false (no third val on first
		call of "r")
		getOpt.optStrHasVal("r", 2, 2) will return true (second val on
		second call of "r" is "IV").
		getOpt.optStrHasVal("r", getOpt.ALL, 2) will return true ("III",
		"IV" are the vals on second call of "r")
		getOpt.optStrHasVal("r", getOpt.ALL, 3) will return false (no third
		call of "r")
		getOpt.optStrHasVal("someOpt", getOpt.ALL) will return "" (no
		"someOpt" on cmdLine)
		getOpt.optStrHasVal("r", , getOpt.ALL) will return true ("I", "II",
		"III", "IV" are the vals passed with "r". Same as
		getOpt.optStrHasVal("r", "", getOpt.ALL)
		getOpt.optStrHasVal("r", 42, getOpt.ALL)

		-------------------------------------
		:4.6, optNrHasVal(optCount, valCount)
		-------------------------------------
		Whether valCount-th value has been passed with the optCount-th
		option.

		1st arg: positive integer

		2nd arg: positive integer or special value. 1 is default.
		getOpt.ALL or getOpt.ALL_FLAT are special args that can be passed to
		determine, if vals were passed with optCount-th option at all.

		Return val: boolean or ""
		Will return "", if no optCount-th option has been passed. Check
		existence with :4.3, hasOptNr().

		Examples:
		cmdLine := ["--r", "I", "II", "--a", "1", "2", "--r", "III", "IV"]
		getOpt.storeKV(cmdLine)
		getOpt.optStrHasVal(1)
		will return true (first val passed with first option is "I"). Same
		as getOpt.optStrHasVal(1, 1).
		getOpt.optStrHasVal(2, 2) will return true (second val passed with
		second option is "2").
		getOpt.optStrHasVal(3, 3) will return false (no third val passed
		with third option, "r" in this case).
		getOpt.optStrHasVal(3, getOpt.ALL) will return true ("III", "IV" are
		the vals passed with 3rd option).
		getOpt.optStrHasVal(4, getOpt.ALL) will return "" (no 4th option
		passed).

		------------------------------------
		:4.7, valOfOptNr(optCount, valCount)
		------------------------------------
		returns values of optCount-th option

		1st arg: the option number (refer to :option count)

		2nr arg: number of value to retun, return, or special value. 1 is
		default.
		getOpt.ALL and getOpt.ALL_FLAT are special args that can be passed
		to return a list of all values of the optCount-th option. Will
		return "", if no optCount-th option was passed.

		return val:
		string or list of strings.
		The "" return value is unambiguous, it either means 'no valCount-th
		option was passed with optCount-th' value, or 'no optCount-th value
		was passed', or 'valCount-th option happens to be "" '. Check option
		existence with hasOptNr() and value existence with optNrHasVal().

		examples:
		getOpt.storeKV(["--anOpt", "val", "--notherOpt"])
		valOfOptNr(1)
		will return "val". Same as valOfOptNr(1, 1).
		valOfOptNr(1, 2) will return "" (no second val passed with the first
		option).
		valOfOptNr(2) will return "" (no vals were passed with the second
		option "notherGetOpt" in this case").
		valOfOptNr(3) will return "" (no third option was passed).
		cmdLine := ["--anOpt", "", "--notherOpt"]
		getOpt.storeKV(cmdLine, getOpt.ALLOW_EMPTY_VALS)
		valOfOptNr(1)
		will return "" (first option of the first value happens to be "").
		getOpt.storeKV(["--anOpt", "val", "--notherOpt"])
		valOfOptNr(1, getOpt.ALL)
		will return ["val"] ( Same as valOfOptNr(1, getOpt.ALL_FLAT) )
		valOfOptNr(2, getOpt.ALL)
		will return "".

		----------------------------------------
		:4.8, valOfOptStr(optStr, argNr, callNr)
		----------------------------------------
		returns values associated with optStr, or "".

		1st arg: the option string ("" to retrieve vals of the empty option)

		2nd arg: number of val to return or special argument. 1 is
		default.
		getOpt.ALL and getOpt.ALL_FLAT are special args that can be
		passed to return a list of all values passed on the callNr-th
		call of optStr.

		3rd arg: call number of opt (see :call count) or special arg. 1
		is default.
		getOpt.ALL is a special arg that can be passed to return a list
		of value lists, indexed by call number
		getOpt.ALL_FLAT is a special arg that can be passed to return a
		normal flat list of all vals.
		The second argument is ignored if getOpt.ALL or getOpt.ALL_FLAT
		is passed as third argument.

		return val: string or nested list of strings.

		examples:
		cmdLine := ["--r", "I", "II", "--a", "1", "2", "--r", "III", "IV"]
		getOpt.storeKV(cmdLine)
		valOfOptStr("a")
		will return "1". Same as valOfOptStr("a", 1, 1).
		valOfOptStr("a", 3) will return "" (no 3rd val on first call of
		"a").
		valOfOptStr("a", 1, 2) will return "" (no 2nd call of "a").
		valOfOptStr("r", getOpt.ALL, 2) will return ["III", "IV"] ( Same as
		valOfOptStr("r", getOpt.ALL_FLAT, 2) )
		valOfOptStr("r", "", getOpt.ALL)  will return
		[["I", II], ["III", "IV"]].
		valOfOptStr("r", "", getOpt.ALL_FLAT) will return
		["I", "II", "III", "IV"].

*/

  class getOpt {
    static RGX_POS_MODE := "P)"
    static OPT_RGX := "^-"
    static SHORT_OPT_RGX := "^-($|[^-])"
    static LONG_OPT_RGX := "^--"
    static DEC_RGX := "((\d+\.?\d*)|(\.\d+))" ; Nonngegative decimal
    static DEXP_RGX := "([eE]-?\d+)" ; Decimal exponent
    static HEXINT_RGX := "(0[xX][0-9A-Fa-f]+)" ; Nonnegative hexadecimal
    ; integer ([:xdigit:] doesn't work in AHK)
    ; Regex for the interpreter number format (i. e. for strings which
    ; the autohotkey interpreter would treat as 'numbers':
    static NUM_RGX :=
      (, LTrim join`s
      "^-?(" getOpt.HEXINT_RGX "|" getOpt.DEC_RGX getOpt.DEXP_RGX "?)$"
      )

    static ALL := "a"
    static ALL_FLAT := "af"
    static IGNORE_EMPTY_VALS := true
    static ALLOW_EMPTY_VALS := false

    args := ""
    idx := ""

    ignoreEmptyVals := ""

    opts := ""
    optByNr := ""
    valsLstByNr := ""

    optCallCount := ""
    optCallTotal := ""

    lastIsDone := ""
    lastIsDoneIdx := ""

    lastNumMatch := ""
    lastNumMatchIdx := ""

    isNum() {  ; As number check is sometimes called twice on same args,
    ; make the isNum() "remember" the last value and return it, if
    ; called again with the same input
      if (this.lastNumMatchIdx = this.idx)
        return this.lastNumMatch
      this.lastNumMatchIdx := this.idx
      this.lastNumMatch :=
      (, LTrim join`s
        regexmatch(
          this.args[this.idx],
          getOpt.RGX_POS_MODE getOpt.NUM_RGX)
      )
      return this.lastNumMatch
    }

    isOpt() {
      return,
      (, LTrim join`s
          regexMatch(
            this.args[this.idx],
            getOpt.RGX_POS_MODE getOpt.OPT_RGX)
        and
          not this.isNum()
      )
    }

    isLongOpt() {
      return regexMatch(  this.args[this.idx]
                        , getOpt.RGX_POS_MODE getOpt.LONG_OPT_RGX  )
    }

    isShortOpt() {
      return,
      (, LTrim join`s
          regexMatch(
            this.args[this.idx],
            getOpt.RGX_POS_MODE getOpt.SHORT_OPT_RGX)
        and
          not this.isNum()
      )
    }

    getFlatVals(optStr) {
      result := []
      for k1 in this.opts[optStr]
        for k2, v2 in this.opts[optStr, k1]
          result.push(v2)
      return result
    }

    optNrHasVal(optCount, valCount := 1) {
      if (not this.hasOptNr(optCount))
        return
      if (valCount = getOpt.ALL or valCount = getOpt.ALL_FLAT)
        return (this.valsLstByNr.hasKey(optCount)) ; Wheter vals were
        ; passed with optCount-th option
      return (this.valsLstByNr[optCount].length() >= valCount)
    }

    optStrHasVal(optStr, valNr := 1, callNr := 1) {
    ; Whether there are values associated with the option optStr at the
    ; given position.
    ; The false return value is ambiguous ―― it either means that there
    ; is no valNr-th value on callNr-th call, or that optStr is not an
    ; option. Check optStr with hasOption(optStr).
      if (not this.hasOption(optStr))
        return
      if (callNr = getOpt.ALL or callNr = getOpt.ALL_FLAT)
        return (this.opts[optStr] = "") ; Whether there are values
                                        ; associated with optStr at all
      if (valNr = getOpt.ALL or valNr = getOpt.ALL_FLAT)
        return (this.opts[optStr].hasKey(callNr)) ; Whether there are
        ; values on callNr-th call of optStr
      return (this.opts[optStr, callNr].length() >= valNr)
    }

    hasOptNr(optNr) {
      return (this.optByNr.length() >= optNr)
    }

    hasOptStr(optStr) {
      return this.opts.hasKey(optStr)
    }

    optNr(count) {
      return this.optByNr[count]
    }

    valOfOptNr(optCount, valCount := 1) {
    ; optCount is not option's position within this.args, but the option
    ; count. So, values of the first option passed (not necessarily at
    ; position 1 of this.args) are retrieved with valOfOptNr(1, ...),
    ; etc.
    ; The "" return value is ambiguous, it means either that the queried
    ; value does not exist, (i. e. valCount is out of range) or that
    ; valOfOptNr(num) happens to be the empty value. Check option and
    ; value existence with hasOptNr(...) and optNrHasVal(...)
      if (valCount = getOpt.ALL or valCount = getOpt.ALL_FLAT)
        return this.valsLstByNr[optCount]
      return this.valsLstByNr[optCount, valCount]
    }

    valOfOptStr(optStr, argNr := 1, callNr := 1) {
    ; The "" return value is ambiguous, it means either that the queried
    ; option or value does not exist, or that the queried option is "".
    ; Check option and value for existence with hasOptStr(optStr) and
    ; optStrHasVal(...)
      if (not this.opts.hasKey(optStr))
        return
      if (callNr = getOpt.ALL) ; List of value lists by call number
        return this.opts[optStr]
      if (callNr = getOpt.ALL_FLAT) ; Flat list of all vals in all calls
        return this.getFlatVals(optStr)
      if (argNr = this.ALL or argNr = this.ALL_FLAT) ; List of all vals
      ; in callNr-th call
        return this.opts[optStr, callNr]
      return this.opts[optStr, callNr, argNr] ; argNr-th val of
                                              ; callNr-th call
    }

    isDone() { ; As isDone() check is sometimes called twice on same
    ; args, make isDone() "remember" the last value and return it, if
    ; called again with the same input
      if (this.lastIsDoneIdx = this.idx)
        return this.lastIsDone
      this.lastIsDoneIdx := this.idx
      this.lastIsDone := (this.idx > this.args.length())
      return this.lastIsDone
    }

    enlistVals() {
      result := []
      while (not (this.isDone() or this.isOpt())) {
        if (this.args[this.idx] or not this.ignoreEmptyVals)
          result.push(this.args[this.idx])
        this.idx++
      }
      if (result.length())
        return result
      ; return null otherwise
    }

    attachList(opt, list) { ; Assuming that list is not empty. List
    ; is either null or has at least length 1 (as returned by
    ; this.enlistVals() )
      if (this.optCallCount.hasKey(opt))
        this.optCallCount[opt]++
      else
        this.optCallCount[opt] := 1
      this.optCallTotal++
      this.optByNr[this.optCallTotal] := opt
      if (list) {
        if (not this.opts[opt]) ; this.opts[opt] is either null or the
        ; opts string is not a key in opts. Either the opt string was
        ; not passed as option, or passed without any arguments.
          this.opts[opt] := []
        this.opts[opt, this.optCallCount[opt]] := list
        this.valsLstByNr[this.optCallTotal] := list
      }
      else ; Don't attach an empty list. Generate, however, an option
      ; with the value null, if necessary
        if (not this.opts.hasKey(opt))
          this.opts[opt] := ""
    }

    doShortOpt() {
      if (this.isDone() or (not this.isShortOpt()))
        return
      optChars := substr(this.args[this.idx], 2)
      loop % strLen(optChars) {
        curOptChar := substr(optChars, A_Index, 1)
        this.attachList(curOptChar, "")
      }
      this.idx++
      curValsLst := this.enlistVals()
      if (curValsLst or not optChars) ; not optChars: short option is
      ; "-", an explicit call of the empty option, so increase the
      ; corresponding optCallCount even if there are no vals (i. e.
      ; curValsLst is null)
        this.attachList("", curValsLst)
    }

    doLongOpt() {
      if (this.isDone() or (not this.isLongOpt()))
        return
      curOpt := substr(this.args[this.idx], 3)
      this.idx++
      curValsLst := this.enlistVals()
      this.attachList(curOpt, curValsLst)
    }

    storeKV(argsPrm := "", ignoreEmptyVals := true) {
      this.init(argsPrm, ignoreEmptyVals)
      curValsLst := this.enlistVals()
      if (curValsLst)
        this.attachList("", curValsLst)
      if (this.isDone())
        return
      loop {
        this.doShortOpt()
        if (this.isDone())
          break
        this.doLongOpt()
      }
      until (this.isDone())
    }

    init(argsPrm, ignoreEmptyVals) {
      if (not isObject(argsPrm)) {
        if (not this.args)
          this.args := A_Args
      }
      else
        this.args := argsPrm
      if (ignoreEmptyVals = "") {
        if (this.ignoreEmptyVals = "")
          this.ignoreEmptyVals := true
      }
      else
        this.ignoreEmptyVals := ignoreEmptyVals
      this.idx := 1
      this.opts := []
      this.optByNr := []
      this.valsLstByNr := []
      this.optCallCount := []
      this.optCallTotal := 0
    }

    __New(argsPrm := "", ignoreEmptyVals := true) {
      this.init(argsPrm, ignoreEmptyVals)
    }
  }

;;#include %a_scriptDir%\objTreeView.ahk ; For debugging. The objects
  ; for storing opts and values have further levels and the method
  ; objTreeView() is handy for looking at the whole structure.