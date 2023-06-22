/*
	Name: String.ahk
	Version 0.14 (23.03.2023)
	Created: 27.08.22
	Author: Descolada
	Credit:
	tidbit		--- Author of "String Things - Common String & Array Functions", from which
					I copied/based a lot of methods
	Contributors: Axlefublr, neogna2
	Contributors to "String Things": AfterLemon, Bon, Lexikos, MasterFocus, Rseding91, Verdlin

	Description:
	A compilation of useful string methods. Also lets strings be treated as objects.

	These methods cannot be used as stand-alone. To do that, you must add another argument
	'string' to the function and replace all occurrences of 'this' with 'string'.
	.-==========================================================================-.
	| Properties                                                                 |
	|============================================================================|
	| String.Length                                                              |
	|       .IsDigit                                                             |
	|       .IsXDigit                                                            |
	|       .IsAlpha                                                             |
	|       .IsUpper                                                             |
	|       .IsLower                                                             |
	|       .IsAlnum                                                             |
	|       .IsSpace                                                             |
	|       .IsTime                                                              |
	|============================================================================|
	| Methods                                                                    |
	|============================================================================|
	| Native functions as methods:                                               |
	| String.ToUpper()                                                           |
	|       .ToLower()                                                           |
	|       .ToTitle()                                                           |
	|       .Split([Delimiters, OmitChars, MaxParts])                            |
	|       .Replace(Needle [, ReplaceText, CaseSense, &OutputVarCount, Limit])  |
	|       .Trim([OmitChars])                                                   |
	|       .LTrim([OmitChars])                                                  |
	|       .RTrim([OmitChars])                                                  |
	|       .Compare(comparison [, CaseSense])                                   |
	|       .Sort([, Options, Function])                                         |
	|       .Format([Values...])                                                 |
	|       .Find(Needle [, CaseSense, StartingPos, Occurrence])                 |
	|       .SplitPath() => returns object {FileName, Dir, Ext, NameNoExt, Drive}|                                                       |
	|		.RegExMatch(needleRegex, &match?, startingPos?)                      |
	|       .RegExMatchAll(needleRegex, startingPos?)                            |
	|		.RegExReplace(needle, replacement?, &count?, limit?, startingPos?)   |
	|                                                                            |
	| String[n] => gets nth character                                            |
	| String[i,j] => substring from i to j                                       |
	| for [index,] char in String => loops over the characters in String         |
	| String.Length                                                              |
	| String.Count(searchFor)                                                    |
	| String.Insert(insert, into [, pos])                                        |
	| String.Delete(string [, start, length])                                    |
	| String.Overwrite(overwrite, into [, pos])                                  |
	| String.Repeat(count)                                                       |
	| Delimeter.Concat(words*)                                                   |
	|                                                                            |
	| String.LineWrap([column:=56, indentChar:=""])                              |
	| String.WordWrap([column:=56, indentChar:=""])                              |
	| String.ReadLine(line [, delim:="`n", exclude:="`r"])                       |
	| String.DeleteLine(line [, delim:="`n", exclude:="`r"])                     |
	| String.InsertLine(insert, into, line [, delim:="`n", exclude:="`r"])       |
	|                                                                            |
	| String.Reverse()                                                           |
	| String.Contains(needle1 [, needle2, needle3...])                           |
	| String.RemoveDuplicates([delim:="`n"])                                     |
	| String.LPad(count)                                                         |
	| String.RPad(count)                                                         |
	|                                                                            |
	| String.Center([fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width])  |
	| String.Right([fill:=" ", delim:="`n", exclude:="`r"])                      |
	'-==========================================================================-'
*/
Class String2 {
	static __New() {
		; Add String2 methods and properties into String object
		__ObjDefineProp := Object.Prototype.DefineProp
		for __String2_Prop in String2.OwnProps()
			if SubStr(__String2_Prop, 1, 2) != "__"
				__ObjDefineProp(String.Prototype, __String2_Prop, String2.GetOwnPropDesc(__String2_Prop))
		__ObjDefineProp(String.Prototype, "__Item", {get:(args*)=>String2.__Item[args*]})
		__ObjDefineProp(String.Prototype, "__Enum", {call:String2.__Enum})
	}

	static __Item[args*] {
		get {
			if args.length = 2
				return SubStr(args[1], args[2], 1)
			else {
				len := StrLen(args[1])
				if args[2] < 0
					args[2] := len+args[2]+1
				if args[3] < 0
					args[3] := len+args[3]+1
				if args[3] >= args[2]
					return SubStr(args[1], args[2], args[3]-args[2]+1)
				else
					return SubStr(args[1], args[3], args[2]-args[3]+1).Reverse()
			}
		}
	}

	static __Enum(varCount) {
		pos := 0, len := StrLen(this)
		EnumElements(&char) {
			char := StrGet(StrPtr(this) + 2*pos, 1)
			return ++pos <= len
		}
		
		EnumIndexAndElements(&index, &char) {
			char := StrGet(StrPtr(this) + 2*pos, 1), index := ++pos
			return pos <= len
		}

		return varCount = 1 ? EnumElements : EnumIndexAndElements
	}
	; Native functions implemented as methods for the String object
	static Length    	  => StrLen(this)
	static WLength        => (RegExReplace(this, "s).", "", &i), i)
	static ULength        => StrLen(RegExReplace(this, "s)((?>\P{M}(\p{M}|\x{200D}))+\P{M})|\X", "_"))
	static IsDigit		  => IsDigit(this)
	static IsXDigit		  => IsXDigit(this)
	static IsAlpha		  => IsAlpha(this)
	static IsUpper		  => IsUpper(this)
	static IsLower		  => IsLower(this)
	static IsAlnum		  => IsAlnum(this)
	static IsSpace		  => IsSpace(this)
	static IsTime		  => IsTime(this)
	static ToUpper()      => StrUpper(this)
	static ToLower()      => StrLower(this)
	static ToTitle()      => StrTitle(this)
	static Split(args*)   => StrSplit(this, args*)
	static Replace(args*) => StrReplace(this, args*)
	static Trim(args*)    => Trim(this, args*)
	static LTrim(args*)   => LTrim(this, args*)
	static RTrim(args*)   => RTrim(this, args*)
	static Compare(args*) => StrCompare(this, args*)
	static Sort(args*)    => Sort(this, args*)
	static Format(args*)  => Format(this, args*)
	static Find(args*)    => InStr(this, args*)
	static SplitPath() 	  => (SplitPath(this, &a1, &a2, &a3, &a4, &a5), {FileName: a1, Dir: a2, Ext: a3, NameNoExt: a4, Drive: a5})
	/**
	 * Returns the match object
	 * @param needleRegex *String* What pattern to match
	 * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
	 * @returns {Object}
	 */
	static RegExMatch(needleRegex, &match?, startingPos?) => (RegExMatch(this, needleRegex, &match, startingPos?), match)
	/**
	* Returns all RegExMatch results in an array: [RegExMatchInfo1, RegExMatchInfo2, ...]
	* @param needleRegEx *String* The RegEx pattern to search for.
	* @param startingPosition *Integer* If StartingPos is omitted, it defaults to 1 (the beginning of haystack).
	* @returns {Array}
	*/
	static RegExMatchAll(needleRegEx, startingPosition := 1) {
		out := []
		While startingPosition := RegExMatch(this, needleRegEx, &outputVar, startingPosition)
			out.Push(outputVar), startingPosition += outputVar[0] ? StrLen(outputVar[0]) : 1
		return out
	}
	 /**
	  * Uses regex to perform a replacement, returns the changed string
	  * @param needleRegex *String* What pattern to match.
	  * 	This can also be a Array of needles (and replacement a corresponding array of replacement values), 
	  * 	in which case all of the pairs will be searched for and replaced with the corresponding replacement. 
	  * 	replacement should be left empty, outputVarCount will be set to the total number of replacements, limit is the maximum
	  * 	number of replacements for each needle-replacement pair.
	  * @param replacement *String* What to replace that match into
	  * @param outputVarCount *VarRef* Specify a variable with a `&` before it to assign it to the amount of replacements that have occured
	  * @param limit *Integer* The maximum amount of replacements that can happen. Unlimited by default
	  * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
	  * @returns {String} The changed string
	  */
	static RegExReplace(needleRegex, replacement?, &outputVarCount?, limit?, startingPos?) {
		if IsObject(needleRegex) {
			out := this, count := 0
			for i, needle in needleRegex {
				out := RegExReplace(out, needle, IsSet(replacement) ? replacement[i] : unset, &count, limit?, startingPos?)
				if IsSet(outputVarCount)
					outputVarCount += count
			}
			return out
		}
		return RegExReplace(this, needleRegex, replacement?, &outputVarCount?, limit?, startingPos?)
	}
	/**
	 * Add character(s) to left side of the input string.
	 * example: "aaa".LPad("+", 5)
	 * output: +++++aaa
	 * @param padding Text you want to add
	 * @param count How many times do you want to repeat adding to the left side.
	 * @returns {String}
	 */
	static LPad(padding, count:=1) {
		str := this
		if (count>0) {
			Loop count
				str := padding str
		}
		return str
	}

	/**
	 * Add character(s) to right side of the input string.
	 * example: "aaa".RPad("+", 5)
	 * output: aaa+++++
	 * @param padding Text you want to add
	 * @param count How many times do you want to repeat adding to the left side.
	 * @returns {String}
	 */
	static RPad(padding, count:=1) {
		str := this
		if (count>0) {
			Loop count
				str := str padding
		}
		return str
	}

	/**
	 * Count the number of occurrences of needle in the string
	 * input: "12234".Count("2")
	 * output: 2
	 * @param needle Text to search for
	 * @param caseSensitive
	 * @returns {Integer}
	 */
	static Count(needle, caseSensitive:=False) {
		StrReplace(this, needle,, caseSensitive, &count)
		return count
	}

	/**
	 * Duplicate the string 'count' times.
	 * input: "abc".Repeat(3)
	 * output: "abcabcabc"
	 * @param count *Integer*
	 * @returns {String}
	 */
	static Repeat(count) => StrReplace(Format("{:" count "}",""), " ", this)

	/**
	 * Reverse the string.
	 * @returns {String}
	 */
	static Reverse() {
		DllCall("msvcrt\_wcsrev", "str", str := this, "CDecl str")
		return str
	}
	static WReverse() {
		str := this, out := "", m := ""
		While str && (m := Chr(Ord(str))) && (out := m . out)
			str := SubStr(str,StrLen(m)+1)
		return out
	}

	/**
	 * Insert the string inside 'insert' into position 'pos'
	 * input: "abc".Insert("d", 2)
	 * output: "adbc"
	 * @param insert The text to insert
	 * @param pos *Integer*
	 * @returns {String}
	 */
	static Insert(insert, pos:=1) {
		Length := StrLen(this)
		((pos > 0)
			? pos2 := pos - 1
			: (pos = 0
				? (pos2 := StrLen(this), Length := 0)
				: pos2 := pos
				)
		)
		output := SubStr(this, 1, pos2) . insert . SubStr(this, pos, Length)
		if (StrLen(output) > StrLen(this) + StrLen(insert))
			((Abs(pos) <= StrLen(this)/2)
				? (output := SubStr(output, 1, pos2 - 1)
					. SubStr(output, pos + 1, StrLen(this))
				)
				: (output := SubStr(output, 1, pos2 - StrLen(insert) - 2)
					. SubStr(output, pos - StrLen(insert), StrLen(this))
				)
			)
		return output
	}

	/**
	 * Replace part of the string with the string in 'overwrite' starting from position 'pos'
	 * input: "aaabbbccc".Overwrite("zzz", 4)
	 * output: "aaazzzccc"
	 * @param overwrite Text to insert.
	 * @param pos The position where to begin overwriting. 0 may be used to overwrite at the very end, -1 will offset 1 from the end, and so on.
	 * @returns {String}
	 */
	static Overwrite(overwrite, pos:=1) {
		if (Abs(pos) > StrLen(this))
			return ""
		else if (pos>0)
			return SubStr(this, 1, pos-1) . overwrite . SubStr(this, pos+StrLen(overwrite))
		else if (pos<0)
			return SubStr(this, 1, pos) . overwrite . SubStr(this " ",(Abs(pos) > StrLen(overwrite) ? pos+StrLen(overwrite) : 0), Abs(pos+StrLen(overwrite)))
		else if (pos=0)
			return this . overwrite
	}

	/**
	 * Delete a range of characters from the specified string.
	 * input: "aaabbbccc".Delete(4, 3)
	 * output: "aaaccc"
	 * @param start The position where to start deleting.
	 * @param length How many characters to delete.
	 * @returns {String}
	 */
	static Delete(start:=1, length:=1) {
		if (Abs(start) > StrLen(this))
			return ""
		if (start>0)
			return SubStr(this, 1, start-1) . SubStr(this, start + length)
		else if (start<=0)
			return SubStr(this " ", 1, start-1) SubStr(this " ", ((start<0) ? start-1+length : 0), -1)
	}

	/**
	 * Wrap the string so each line is never more than a specified length.
	 * input: "Apples are a round fruit, usually red".LineWrap(20, "---")
	 * output: "Apples are a round f
	 *          ---ruit, usually red"
	 * @param column Specify a maximum length per line
	 * @param indentChar Choose a character to indent the following lines with
	 * @returns {String}
	 */
	static LineWrap(column:=56, indentChar:="") {
		CharLength := StrLen(indentChar)
		, columnSpan := column - CharLength
		, Ptr := A_PtrSize ? "Ptr" : "UInt"
		, UnicodeModifier := 2
		, VarSetStrCapacity(&out, (finalLength := (StrLen(this) + (Ceil(StrLen(this) / columnSpan) * (column + CharLength + 1))))*2)
		, A := StrPtr(out)

		Loop parse, this, "`n", "`r" {
			if ((FieldLength := StrLen(ALoopField := A_LoopField)) > column) {
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", column * UnicodeModifier)
				, A += column * UnicodeModifier
				, NumPut("UShort", 10, A)
				, A += UnicodeModifier
				, Pos := column

				While (Pos < FieldLength) {
					if CharLength
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(indentChar), "UInt", CharLength * UnicodeModifier)
						, A += CharLength * UnicodeModifier

					if (Pos + columnSpan > FieldLength)
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", (FieldLength - Pos) * UnicodeModifier)
						, A += (FieldLength - Pos) * UnicodeModifier
						, Pos += FieldLength - Pos
					else
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", columnSpan * UnicodeModifier)
						, A += columnSpan * UnicodeModifier
						, Pos += columnSpan

					NumPut("UShort", 10, A)
					, A += UnicodeModifier
				}
			} else
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", FieldLength * UnicodeModifier)
				, A += FieldLength * UnicodeModifier
				, NumPut("UShort", 10, A)
				, A += UnicodeModifier
		}
		NumPut("UShort", 0, A)
		VarSetStrCapacity(&out, -1)
		return SubStr(out,1, -1)
	}

	/**
	 * Wrap the string so each line is never more than a specified length.
	 * Unlike LineWrap(), this method takes into account words separated by a space.
	 * input: "Apples are a round fruit, usually red.".WordWrap(20, "---")
	 * output: "Apples are a round
	 *          ---fruit, usually
	 *          ---red."
	 * @param column Specify a maximum length per line
	 * @param indentChar Choose a character to indent the following lines with
	 * @returns {String}
	 */
	static WordWrap(column:=56, indentChar:="") {
		if !IsInteger(column)
			throw TypeError("WordWrap: argument 'column' must be an integer", -1)
		out := ""
		indentLength := StrLen(indentChar)

		Loop parse, this, "`n", "`r" {
			if (StrLen(A_LoopField) > column) {
				pos := 1
				Loop parse, A_LoopField, " "
					if (pos + (LoopLength := StrLen(A_LoopField)) <= column)
						out .= (A_Index = 1 ? "" : " ") A_LoopField
						, pos += LoopLength + 1
					else
						pos := LoopLength + 1 + indentLength
						, out .= "`n" indentChar A_LoopField

				out .= "`n"
			} else
				out .= A_LoopField "`n"
		}
		return SubStr(out, 1, -1)
	}

	/**
	* Insert a line of text at the specified line number.
	* The line you specify is pushed down 1 and your text is inserted at its
	* position. A "line" can be determined by the delimiter parameter. Not
	* necessarily just a `r or `n. But perhaps you want a | as your "line".
	* input: "aaa|ccc|ddd".InsertLine("bbb", 2, "|")
	* output: "aaa|bbb|ccc|ddd"
	* @param insert Text you want to insert.
	* @param line What line number to insert at. Use a 0 or negative to start inserting from the end.
	* @param delim The character which defines a "line".
	* @param exclude The text you want to ignore when defining a line.
	* @returns {String}
	 */
	static InsertLine(insert, line, delim:="`n", exclude:="`r") {
		if StrLen(delim) != 1
			throw ValueError("InsertLine: Delimiter can only be a single character", -1)
		into := this, new := ""
		count := into.Count(delim)+1

		; Create any lines that don't exist yet, if the Line is less than the total line count.
		if (line<0 && Abs(line)>count) {
			Loop Abs(line)-count
				into := delim into
			line:=1
		}
		if (line == 0)
			line:=Count+1
		if (line<0)
			line:=count+line+1
		; Create any lines that don't exist yet. Otherwise the Insert doesn't work.
		if (count<line)
			Loop line-count
				into.=delim

		Loop parse, into, delim, exclude
			new.=((a_index==line) ? insert . delim . A_LoopField . delim : A_LoopField . delim)

		return SubStr(new, 1, -(line > count ? 2 : 1))
	}

	/**
	 * Delete a line of text at the specified line number.
	 * The line you specify is deleted and all lines below it are shifted up.
	 * A "line" can be determined by the delimiter parameter. Not necessarily
	 * just a `r or `n. But perhaps you want a | as your "line".
	 * input: "aaa|bbb|777|ccc".DeleteLine(3, "|")
	 * output: "aaa|bbb|ccc"
	 * @param string Text you want to delete the line from.
	 * @param line What line to delete. You may use -1 for the last line and a negative an offset from the last. -2 would be the second to the last.
	 * @param delim The character which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static DeleteLine(line, delim:="`n", exclude:="`r") {
		if StrLen(delim) != 1
			throw ValueError("DeleteLine: Delimiter can only be a single character", -1)
		new := ""
		; checks to see if we are trying to delete a non-existing line.
		count:=this.Count(delim)+1
		if (abs(line)>Count)
			throw ValueError("DeleteLine: the line number cannot be greater than the number of lines", -1)
		if (line<0)
			line:=count+line+1
		else if (line=0)
			throw ValueError("DeleteLine: line number cannot be 0", -1)

		Loop parse, this, delim, exclude {
			if (a_index==line) {
				Continue
			} else
				(new .= A_LoopField . delim)
		}

		return SubStr(new,1,-1)
	}

	/**
	 * Read the content of the specified line in a string. A "line" can be
	 * determined by the delimiter parameter. Not necessarily just a `r or `n.
	 * But perhaps you want a | as your "line".
	 * input: "aaa|bbb|ccc|ddd|eee|fff".ReadLine(4, "|")
	 * output: "ddd"
	 * @param line What line to read*. "L" = The last line. "R" = A random line. Otherwise specify a number to get that line. You may specify a negative number to get the line starting from the end. -1 is the same as "L", the last. -2 would be the second to the last, and so on.
	 * @param delim The character which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static ReadLine(line, delim:="`n", exclude:="`r") {
		out := "", count:=this.Count(delim)+1

		if (line="R")
			line := Random(1, count)
		else if (line="L")
			line := count
		else if abs(line)>Count
			throw ValueError("ReadLine: the line number cannot be greater than the number of lines", -1)
		else if (line<0)
			line:=count+line+1
		else if (line=0)
			throw ValueError("ReadLine: line number cannot be 0", -1)

		Loop parse, this, delim, exclude {
			if A_Index = line
				return A_LoopField
		}
		throw Error("ReadLine: something went wrong, the line was not found", -1)
	}

	/**
	 * Replace all consecutive occurrences of 'delim' with only one occurrence.
	 * input: "aaa|bbb|||ccc||ddd".RemoveDuplicates("|")
	 * output: "aaa|bbb|ccc|ddd"
	 * @param delim *String*
	 */
	static RemoveDuplicates(delim:="`n") => RegExReplace(this, "(\Q" delim "\E)+", "$1")

	/**
	 * Checks whether the string contains any of the needles provided.
	 * input: "aaa|bbb|ccc|ddd".Contains("eee", "aaa")
	 * output: 1 (although the string doesn't contain "eee", it DOES contain "aaa")
	 * @param needles
	 * @returns {Boolean}
	 */
	static Contains(needles*) {
		for needle in needles
			if InStr(this, needle)
				return 1
		return 0
	}

	/**
	 * Centers a block of text to the longest item in the string.
	 * example: "aaa`na`naaaaaaaa".Center()
	 * output: "aaa
	 *           a
	 *       aaaaaaaa"
	 * @param text The text you would like to center.
	 * @param fill A single character to use as the padding to center text.
	 * @param symFill 0: Just fill in the left half. 1: Fill in both sides.
	 * @param delim The character which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @param width Can be specified to add extra padding to the sides
	 * @returns {String}
	 */
	static Center(fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width?) {
		fill:=SubStr(fill,1,1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField)>longest)
				longest := StrLen(A_LoopField)
		if IsSet(width)
			longest := Max(longest, width)
		Loop parse this, delim, exclude 
		{
			filled:="", len := StrLen(A_LoopField)
			Loop (longest-len)//2
				filled.=fill
			new .= filled A_LoopField ((symFill=1) ? filled (2*StrLen(filled)+len = longest ? "" : fill) : "") "`n"
		}
		return RTrim(new,"`r`n")
	}

	/**
	 * Align a block of text to the right side.
	 * input: "aaa`na`naaaaaaaa".Right()
	 * output: "     aaa
	 *                 a
	 *          aaaaaaaa"
	 * @param fill A single character to use as to push the text to the right.
	 * @param delim The character which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static Right(fill:=" ", delim:="`n", exclude:="`r") {
		fill:=SubStr(fill,1,1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField)>longest)
				longest:=StrLen(A_LoopField)
		Loop parse, this, delim, exclude {
			filled:=""
			Loop Abs(longest-StrLen(A_LoopField))
				filled.=fill
			new.= filled A_LoopField "`n"
		}
		return RTrim(new,"`r`n")
	}

	/**
	 * Join a list of strings together to form a string separated by delimiter this was called with.
	 * input: "|".Concat("111", "222", "333", "abc")
	 * output: "111|222|333|abc"
	 * @param words A list of strings separated by a comma.
	 * @returns {String}
	 */
	static Concat(words*) {
		delim := this, s := ""
		for v in words
			s .= v . delim
		return SubStr(s,1,-StrLen(this))
	}
}