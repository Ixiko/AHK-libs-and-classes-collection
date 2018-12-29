;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  TOKEnizer/LEXer class library (TOKELEX)
;;  Copyright (C) 2012 Adrian Hawryluk
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include <misc>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TOKEnizer/LEXer class library (TOKELEX)
;;
;; INTRODUCTION:
;;
;;  This class library combines the speed of my original tokenizer I used in my 
;;  C interface library and the flexibility of the lexer in my Lexer class.  It
;;  does not buffer on lines, and it does not have a preparser.  But what it 
;;  does have is speed.
;;
;;  In tokenizer mode, this goes about 1.8 times the speed of the Lexer class.
;;  In lexer mode, it goes about 1.3 times that baseline speed.  This is still
;;  not as fast as my original tokenizer (about 2.3 times the baseline).  The
;;  reason for this is still unclear as I am using very similar code.  I'm 
;;  guessing that it has something to do with the newing of the object, and 
;;  possibly the overhead of a function call or two.
;;
;;  The test is run off of the execution of the following:
;;
;;      c.typedef___("int LONG")
;;      c.typedef___("
;;      (
;;          struct _RECT {
;;            LONG left;
;;            LONG top;
;;            LONG right;
;;            LONG bottom;
;;          } RECT, *PRECT;
;;      )")
;;
;;  Tokens are differentiated by a SINGLE regular expression.  This RegEx will
;;  state what is a valid token.  When in Lexer mode, do not allow a token of
;;  an empty string.  This is invalid and will result in a token id being some
;;  random valid value.  A empty token is generally a bad idea anyway.
;;
;; Modes:
;;
;;  Tokenizer mode is just breaking up a string or file in to an array of 
;;  strings.
;;
;;  Lexer mode breaks it up in to objects that have three members, tokenId, flag
;;  and string.  The string is the token captured, the tokenId is the capture
;;  group number, and the flag is the name specified prefixed with the string
;;  "is".  If no name is specified, then it is just the tokenId number.
;;
;; Holding on to tokens:
;;
;;  Like the Lexer class, if you are to backtrack you need to keep the tokens
;;  available as they may disappear if the next set of tokens are retreived
;;  causing the previous tokens to become stale.
;;
;;    holdTokens(pos)
;;     - holds on to currently cached tokens.  Pos will be used if you call
;;       holdTokensRevert().  This can be called many times but for each time
;;       a holdTokensRelease() must be called or excess token buildup may reduce
;;       performance.
;;
;;    holdTokensRelease()
;;     - release the last hold on the cached tokens.
;;
;;    holdTokensRevert()
;;     - returns the last pos passed to holdTokens().
;;
;; BASIC USAGE:
;;
;;  First, create your RegEx.  I would recommend using some of the following 
;;  options:
;;  `a - use all types of newline sequences, this includes \n, \r, \r\n and 
;;       others.  Using this will allow for character class \R to match all of 
;;       these types (but you can't use \R within [], it'll be treated as an
;;       uppercase R) and assertion $ if you are using the multiline option.
;;   m - Allows for using ^ and $ assertions matching newline sequences instead
;;       of just the begining and end of the string.
;;   S - Allows the dot '.' to match a character that is part of a newline 
;;       sequence.
;;   x - Ignores all whitespace that is not escaped with a preceeding backslash
;;       unless it is within [].  Also, will ignore characters # to the end of
;;       the line unless the # is within []. I HIGHLY RECOMMEND THIS OPTION as
;;       it makes for far more readable regular expressions.
;;
;;  Next, create a series of regular expressions that are seperated by a vertical
;;  bar '|'.  Each one will represents a token match and is tested in order from 
;;  left to right, top to bottom (if you write you RegEx on multiple lines).  If 
;;  you are using tokenizer mode I would recommend surrounding each RegEx match 
;;  for a token with a '(?:' and ')'.  If you are using lexer mode, you MUST 
;;  surround each RegEx match for a token with '(' and ')'.  Having just one
;;  capture group will flip the tokenizer into lexer mode, but not having a 
;;  capture group for each type of token will result in undefined behaviour.
;;  E.g.:
;;
;;   TOKENIZER_RE := "mSx)
;;   (
;;       (?:\r\n?|\n) # Newline
;;     | (?:[ \t]+) # whitespace (NOTE: one or more not zero or more)
;;     | (?::=|[=+\-]) # operators
;;     | (?:\d+) # numbers
;;     | (?:[a-zA-Z][a-z]*) # words
;;   )"
;;
;;  or
;;
;;   LEXER_RE := "mSx)
;;   (
;;       (\r\n?|\n) # Newline
;;     | ([ \t]+) # whitespace (NOTE: one or more not zero or more)
;;     | (:=|[=+\-]) # operators
;;     | (\d+) # numbers
;;     | ([a-zA-Z][a-z]*) # words
;;   )"
;;
;;  So these will match newlines of the Unix or Windows type, whitespaces (tabs
;;  and spaces), operators (colon followed by an equal sign, an equal sign, a 
;;  plus or a minus), numbers (one or more digits in succession), or words 
;;  (stating with a upper or lowercase letter followed by zero or more lowercase
;;  letters).  If a token is found in the string or file stream that doesn't conform
;;  a failure results which is reported and then terminates the application (this
;;  will change in the future).
;;
;;  From here, you register the lexer or tokenizer:
;;
;;   tokelex.Register("my tokenizer", TOKENIZER_RE)
;;
;;  or
;;
;;   tokelex.Register("my lexer", LEXER_RE, { newlineId: 1, whitespaceId: 2 } )
;;
;;  Now you can use the tokenizer or lexer on a string or a file:
;;
;;   mytokenizer := new tokelex("my tokenizer").string("this will tokenize 123")
;;   tokenizeFile := new tokelex("my tokenizer").openFile("fileToTokenize.txt")
;;
;;  or
;;
;;   mylexer := new tokelex("my lexer").string("this will lexify :=")
;;   lexifyFile := new tokelex("my lexer").openFile("fileToLexify.txt")
;;
;;  Unlike the Lexer class, this doesn't keep track of your position, this is 
;;  to reduce function call overhead.  So the first token is at position 1, the
;;  second at 2 and so on.  So keep your position in a variable and increment
;;  or decrement as needed.  If you must decrement, you should call the 
;;  holdTokens() member function or you may hit a stale token.
;;
;;  Your parsing loop should look something like this:
;;
;;   pos := 1
;;   while (pos <= myLexer.MaxIndex() or myLexer.tokenAvailable(pos))
;;   {
;;     msg .= "token = '" myLexer[pos].string 
;;         .  "', tokenId = " myLexer[pos++].tokenId "`n"
;;   }
;;   MsgBox % msg
;;
;;  or
;;
;;   pos := 1
;;   while (pos <= myTokenizer.MaxIndex() or myTokenizer.tokenAvailable(pos))
;;   {
;;     msg .= "token = '" myTokenizer[pos++].string "'`n"
;;   }
;;   MsgBox % msg
;;
;;  The "pos <= myLexer.MaxIndex() or" section is for perfomance reasons. If you
;;  are lazy, you could leave it out at a performance cost.
;;
;;  By default, horizontal whitespace and new lines are dropped.  You can in
;;  fact drop one or the other or collapse the horizontal whitespace or keep
;;  them all by oring the following flags for the optional parameter when 
;;  newing the tokelex:
;;
;;    tokelex.COLLAPSE_H_WHITESPACE
;;      - collapses the horizontal whitespace to the empty string ("")
;;
;;    tokelex.KEEP_H_WHITESPACE
;;      - keeps the horizontal whitespace unchanged
;;
;;    tokelex.KEEP_NEWLINE
;;      - keeps the newline unchanged
;;
;;  Having both tokelex.COLLAPSE_H_WHITESPACE and tokelex.KEEP_H_WHITESPACE
;;  is equivilant to just having tokelex.COLLAPSE_H_WHITESPACE.
;; 
;; ADVANCED USAGE:
;;
;;  You may have noticed that on registring the lexer there were additional
;;  parameters passed.  These tell the lexer what pattern group is considered a 
;;  whitespace and what pattern group is a new line.  This is important as won't
;;  drop whitespaces or newlines if you don't specify these.  Here are the 
;;  following values that can be passed to the additionalParams parameter of the
;;  Register() function:
;;
;;   whitespaceId: (int)
;;    - token id that is considered a horizontal whitespace.  Ignored in
;;      tokenizer mode.
;;
;;   newlineId: (int)
;;    - token id that is considered a newline.  Ignored in tokenizer mode
;;
;;   groupToTokenId: (int->int)
;;    - maps group id to a token id.  Token ids are unique so you cannot map two
;;      group ids to a single token id.  You can give them the same id name 
;;      though.  Ignored in tokenizer mode.
;;
;;   idNames: (int->int/string)
;;    - maps a token id to an id name.  If it is not a number, it will append
;;      "is" in front of name.  These are used for flags.  Ignored in
;;      tokenizer mode.
;;
;;   remapTokenString: (string->anything)
;;    - remaps any token string to anything.  This can be a string or an 
;;      object and is used in both tokenizer and lexer modes.
;;
;; Group to Token Id:
;;  If you want the 4th group to be id 1 and the 2nd group to be id 3, you 
;;  would register like this:
;;
;;    tokelex.Register("my lexer", LEXER_RE, { newlineId: 1
;;       , whitespaceId: 2, groupToTokenId: { 4: 1, 2: 3 } } )
;;
;;  Any non specified groups will be tacked on to the end.  In other words the
;;  mappings would be like:  1->2, 2->3, 3->4 and 4->1 and would be equivilant
;;  to:
;;
;;    tokelex.Register("my lexer", LEXER_RE, { newlineId: 1
;;       , whitespaceId: 2, groupToTokenId: [2, 3, 4, 1] } )
;;
;; Id Names:
;;  Flags can be used to question if a token is a paticular type in a faster
;;  way then comparing the token id to a constant.  I.e.:
;;
;;    tokelex.Register("my lexer", LEXER_RE, { newlineId: 1
;;       , whitespaceId: 2, idNames: [ "newline", "whitespace", "operator"
;;       , "word" ] } )
;;
;;  you could state:
;;
;;    myLexer[pos].isWhitespace
;;
;;  to ask if the token is a whitespace instead of
;;
;;    myLexer[pos].tokenId == 2 ; NOTE: this is still valid
;;
;;  This also make for more readable code and doesn't rely on external 
;;  constants.  An alternate method is
;;
;;    myLexer[pos, "isWhitespace"]
;;
;;  which is slightly faster.  Any token ids that are not given
;;  an id name will have a flag that is the id number.  I.e. passing 
;;  { 3: "operator" } would mean you could query if it is a whitespce by doing:
;;
;;    myLexer[pos].2
;;
;;  or
;;
;;    myLexer[pos, 2]
;;
;;  where again the latter is slightly faster.  myLexer[pos, "isOperator"] 
;;  would also still valid for quering if the token is an operator.
;;
;; Remapping Token Strings:
;;  Remapping a token string is useful to map a string like "`r`n" to "`n"
;;  or "struct" to { isStruct: 1 }.  This would be accomplished like this:
;;
;;    tokelex.Register("my lexer", LEXER_RE, { newlineId: 1
;;       , whitespaceId: 2, remapTokenString: { "`r`n": "`n"
;;         , struct: { isStruct: 1 } } )
;;
;;  or
;;
;;    tokelex.Register("my tokenizer", LEXER_RE, { newlineId: 1
;;       , whitespaceId: 2, remapTokenString: { "`r`n": "`n"
;;         , struct: { isStruct: 1 } } )
;;
;;  Remapping strings to objects in a tokenizer doesn't seem to increase
;;  parsing speed, but doesn't seem to impair it either.  Using flags for the
;;  lexer does help in perfomance for the parser.
;;
;;  If a remapped string results in an object that has contains an element
;;  named expand, then that element is treated as an array of tokens and is 
;;  inserted into the token stream.
;;
;; ADDITIONAL SPEED:
;;
;;  Due to how AHK works, the longer the RegEx, the slower it is to execute 
;;  RegExMatch()/RegExReplace() functions, even if most of the RegEx is 
;;  comments.  To minimize this, use removeCommentsAndWhitespaceFromRegEx().
;;
;;  That's it for now.  ENJOY!!
;;
;;
;;
;;  Adrian Hawryluk
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

class tokelex
{
	static DROP_WHITESPACE := 0
	, KEEP_NEWLINE := 1
	, KEEP_H_WHITESPACE := 2
	, COLLAPSE_H_WHITESPACE := 4
	, lexers := {} ; holds the registered lexers
	, RS := chr(8) ; record seperator character
	, FS := chr(7) ; field seperator character
	;, RS := chr(30) ; chr(8)
	;, FS := chr(31) ; chr(7)

	; idNames is an array of strings that state what the "is" flag should be called for each group.
	;         "is" will be prepended to each flag name.  Ids that do not have a corrisponding name
	;         will be marked simply as their number.
	; groupToTokenId is an array of numbers indicating what capture groups will appear first.  Any 
	;         remaining capture groups will be tacked on the end in acending order.
	; remapTokenString is an associative array of what to map a token with a string the same as it's name
	;         to.  I.e. { if: { isIf: 1, string: "if" }, then: { isThen: 1, string: "then" } }
	; whitespaceId is the group number for whitespaces
	; newlinId is the group number for newlines
	Register(lexerName, tokenRE, additionalParams := 0)
	{
pcre_callout = RegExDebug
		static FS := tokelex.FS
		idNames := additionalParams.idNames
		
		lexerInfo := {}
		lexerInfo.collapsedWhitespaceToken := { (additionalParams.whitespaceId): 1, tokenId: additionalParams.whitespaceId, value: "" }
		lexerInfo.newlineToken := { (additionalParams.newlineId): 1, tokenId: additionalParams.newlineId, value: "\n" }
		lexerInfo.remapTokenString := additionalParams.remapTokenString

		; Build a RegEx to convert a string into a series of records with fields relating to which token it belongs to
		COUNT_GROUPS_RE := "\((?!\?)([^()]++|\((?-1)\))*\)"
		COUNT_GROUPS_RE := "As)(?:\\.|\[(?:\\.|[^\]])*\]|\([?*]|[^(])*+\(" ;(?Chere)"
		x := RegExReplace(tokenRE, COUNT_GROUPS_RE, "", count)
		RegExCheck(COUNT_GROUPS_RE)
		
		tokenIdsAvailable := {}
		tokensDeltWith := {}
		loop %count%
			tokenIdsAvailable.Insert(A_Index, A_Index)
		
		for index, value in additionalParams.groupToTokenId
		{
			replacement .= FS "${" value "}"
			, tokensDeltWith.Insert(value, 1)
		}
		
		idFlagNames := {}
		loop %count%
		{
			if (tokensDeltWith[A_Index])
			{ ; delibretly left blank
			}
			else
			{
				replacement .= FS "${" tokenIdsAvailable.Remove(tokenIdsAvailable.MinIndex(), "") "}"
			}
			
			if (idNames.haskey(A_Index))
				idFlagNames.Insert(A_Index, "is" idNames[A_Index])
			else
				idFlagNames.Insert(A_Index, A_Index)
		}

		lexerInfo.count := count
		lexerInfo.idFlagNames := idFlagNames
		lexerInfo.lexEnum := count ? 8 : 0
		lexerInfo.replacement := replacement tokelex.RS
		lexerInfo.tokenRE := tokenRE
		tokelex.lexers[lexerName] := lexerInfo
	}
	
	__New(lexerName, keepWhiteSpace=0)
	{
		local lexerInfo := tokelex.lexers[lexerName]
		if (lexer)
		{ ;do nothing
		}
		else
			FAIL("Lexer '" lexerName "' not registered.")

		this.lexerInfo := lexerInfo
		this.keepWhiteSpace := keepWhiteSpace
		this.tokenRE := lexerInfo.tokenRE
		this.holdTokensPositionStack := []
		this.queuedToken := ""
		this.maxTokenFound := 0
		this.file := 0
		this.chunkSize := 1

		; This is actually good as I can have different implementations of tokenizers limited to a string_helper() function,
		; such as those that box them into objects with flags and or enums indicating what type of token it is.
		; That'll be for later		
		static stringFNs := { (                                             tokelex.DROP_WHITESPACE): tokelex.string_dropWhitespace
			, (                                                                tokelex.KEEP_NEWLINE): tokelex.string_dropHWhitespaceAndKeepNewLine
			, (                                    tokelex.KEEP_H_WHITESPACE                       ): tokelex.string_keepHWhitespaceAndDropNewLine
			, (                                    tokelex.KEEP_H_WHITESPACE | tokelex.KEEP_NEWLINE): tokelex.string_keepWhitespace
			, (    tokelex.COLLAPSE_H_WHITESPACE                                                   ): tokelex.string_collapseHWhitespaceAndDropNewLine
			, (    tokelex.COLLAPSE_H_WHITESPACE | tokelex.KEEP_H_WHITESPACE                       ): tokelex.string_collapseHWhitespaceAndDropNewLine
			, (    tokelex.COLLAPSE_H_WHITESPACE                             | tokelex.KEEP_NEWLINE): tokelex.string_collapseHWhitespaceAndKeepNewLine
			, (    tokelex.COLLAPSE_H_WHITESPACE | tokelex.KEEP_H_WHITESPACE | tokelex.KEEP_NEWLINE): tokelex.string_collapseHWhitespaceAndKeepNewLine
            , (8 |                                                          tokelex.DROP_WHITESPACE): tokelex.string_dropWhitespaceLexEnum
			, (8 |                                                             tokelex.KEEP_NEWLINE): tokelex.string_dropHWhitespaceAndKeepNewLineLexEnum
			, (8 |                                 tokelex.KEEP_H_WHITESPACE                       ): tokelex.string_keepHWhitespaceAndDropNewLineLexEnum
			, (8 |                                 tokelex.KEEP_H_WHITESPACE | tokelex.KEEP_NEWLINE): tokelex.string_keepWhitespaceLexEnum
			, (8 | tokelex.COLLAPSE_H_WHITESPACE                                                   ): tokelex.string_collapseHWhitespaceAndDropNewLineLexEnum
			, (8 | tokelex.COLLAPSE_H_WHITESPACE | tokelex.KEEP_H_WHITESPACE                       ): tokelex.string_collapseHWhitespaceAndDropNewLineLexEnum
			, (8 | tokelex.COLLAPSE_H_WHITESPACE                             | tokelex.KEEP_NEWLINE): tokelex.string_collapseHWhitespaceAndKeepNewLineLexEnum
			, (8 | tokelex.COLLAPSE_H_WHITESPACE | tokelex.KEEP_H_WHITESPACE | tokelex.KEEP_NEWLINE): tokelex.string_collapseHWhitespaceAndKeepNewLineLexEnum }
		if (this.string_helper := stringFNs[keepWhiteSpace | lexerInfo.lexEnum])
			return this
		else
			FAIL("keepWhiteSpace value is '" keepWhiteSpace "' which is invalid.")
	}

	; call overhead is about 10usec
	invalidTokenCheck(byref string)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		;string := FS "z" RS FS "wxyqz" RS "x" FS FS FS "y" FS FS FS
		static VALID_TOKEN_RE :=  "(?:[" FS "]([^" RS "]*)" RS ")" ; Match on a record that don't match an invalid token. $1 = token
		, VALID_TOKENS_RE := "(?:[" FS "][^" RS "]*" RS ")*" ; Remove 0 or more records that don't match an invalid token
		, INVALID_TOKEN_RE := "(?:([^" FS "]+)" FS "+([^" FS RS "]*)" FS "*" RS "?).*$" ; Match a record that does have an invalid token followed by whatever. $1 = invalid token, $2 is following token that it was up against
		, RE := "s)^" VALID_TOKENS_RE INVALID_TOKEN_RE
;		, INVALID_TOKEN_RE := "(?:([^" FS "]+)" FS "+([^" FS RS "]*)" FS "*" RS ").*$" ; Match a record that does have an invalid token followed by whatever. Invalid token must not be last token as it may be incomplete.  $1 = invalid token, $2 is following token that it was up against
;		, RE := "s)^(?:" INVALID_TOKEN_RE "|[^" RS "]*" RS "?)"
		
		if (substr(string, 1, 1) != FS or RegExMatch(string, RS "[^" FS "][^" RS "]*" RS))
		{
			Error := RegExReplace(string, RE, "Found invalid token '$1$2' ('$1', '$2').", count)
			;RegExCheck(RE)
			FAIL(Error)
		}
	}
	
	string_dropWhitespace(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		, replacement := FS "$0" RS 
		local remapTokenString := this.lexerInfo.remapTokenString

		string := substr(RegExReplace(string, this.lexerInfo.tokenRE, replacement), 1, -1) ; insert a RS after every token except the last one

		tokelex.invalidTokenCheck(string)
		
		loop, parse, string, %RS%, %FS%
		{
			if (InStr("`r`n`r", queuedToken := A_LoopField) or Trim(A_LoopField) == "")
				lastTokenDropped := 1 ; drop whitespace
			else
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert(A_LoopField)
			}
		}
		this.queuedToken := queuedToken
		return this
	}
	
	string_collapseHWhitespaceAndKeepNewLine(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		, replacement := FS "$0" RS 
		local remapTokenString := this.lexerInfo.remapTokenString

		string := substr(RegExReplace(string, this.lexerInfo.tokenRE, replacement), 1, -1) ; insert a RS after every token except the last one

		tokelex.invalidTokenCheck(string)
		
		loop, parse, string, %RS%, %FS%
		{
			if (Trim(queuedToken := A_LoopField) == "")
				remapTokenString.haskey("") ? (remapTokenString[""].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[""].expand*) : this.Insert(remapTokenString[""])) : this.Insert(A_LoopField) ; collapse whitespace
			else
				remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert(A_LoopField)
		}
		this.queuedToken := queuedToken
		lastTokenDropped := 0
		return this
	}
	
	string_collapseHWhitespaceAndDropNewLine(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		, replacement := FS "$0" RS 
		local remapTokenString := this.lexerInfo.remapTokenString

		string := substr(RegExReplace(string, this.lexerInfo.tokenRE, replacement), 1, -1) ; insert a RS after every token except the last one

		tokelex.invalidTokenCheck(string)
		
		loop, parse, string, %RS%, %FS%
		{
			if (Trim(queuedToken := A_LoopField) == "")
			{
				lastTokenDropped := 0
				, remapTokenString.haskey("") ? (remapTokenString[""].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[""].expand*) : this.Insert(remapTokenString[""])) : this.Insert(A_LoopField) ; collapse whitespace
			}
			else if (InStr("`r`n`r", A_LoopField))
			{ ; drop newline
				lastTokenDropped := 1
			}
			else
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert(A_LoopField)
			}
		}
		this.queuedToken := queuedToken
		return this
	}

	string_keepWhitespace(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		, replacement := FS "$0" RS 
		local remapTokenString := this.lexerInfo.remapTokenString

		string := substr(RegExReplace(string, this.lexerInfo.tokenRE, replacement), 1, -1) ; insert a RS after every token except the last one

		tokelex.invalidTokenCheck(string)
		
		loop, parse, string, %RS%, %FS%
		{
			remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert(A_LoopField)
		}
		this.queuedToken := queuedToken
		lastTokenDropped := 0
		return this
	}

	string_keepHWhitespaceAndDropNewLine(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		, replacement := FS "$0" RS 
		local remapTokenString := this.lexerInfo.remapTokenString

		string := substr(RegExReplace(string, this.lexerInfo.tokenRE, replacement), 1, -1) ; insert a RS after every token except the last one

		tokelex.invalidTokenCheck(string)
		
		loop, parse, string, %RS%, %FS%
		{
			if (InStr("`r`n`r", queuedToken := A_LoopField))
			{ ; drop newline
				lastTokenDropped := 1
			}
			else
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert(A_LoopField)
			}
		}
		this.queuedToken := queuedToken
		return this
	}
	
	string_dropHWhitespaceAndKeepNewLine(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		, replacement := FS "$0" RS 
		local remapTokenString := this.lexerInfo.remapTokenString

		string := RegExReplace(string, this.lexerInfo.tokenRE, replacement)
		A_IsUnicode 
			? NumPut(0, &string, 2*strlen(string)-2, "short") 
			: NumPut(0, &string, strlen(string)-1, "char") ; insert a RS after every token except the last one
		;VarSetCapacity(string, -1)

		tokelex.invalidTokenCheck(string)
		
		loop, parse, string, %RS%, %FS%
		{
			if (Trim(queuedToken := A_LoopField) == "")
			{ ; drop horizontal whitespace
				lastTokenDropped := 1
			}
			else
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert(A_LoopField)
			}
		}
		this.queuedToken := queuedToken
		return this
	}
	
	string_dropWhitespaceLexEnum(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		
		local lexerInfo := this.lexerInfo
		, NlEnum := lexerInfo.newlineToken.tokenId
		, WsEnum := lexerInfo.collapsedWhitespaceToken.tokenId
		, idFlagNames := lexerInfo.idFlagNames
		, count := lexerInfo.count
		, queuedToken := 0
		, index := 0
		, remapTokenString := lexerInfo.remapTokenString
		
		string := substr(RegExReplace(string, lexerInfo.tokenRE, lexerInfo.replacement), 1, -1) ; insert a RS after every token except the last one

		loop, parse, string, %RS%
		{
			loop, parse, A_LoopField, %FS% ; parse loop faster then RegExMatch call by about 36us
				if (A_LoopField != "")
				{
					queuedToken := A_LoopField
					, index := A_Index - 1
					break
				}
				
			if (index == NlEnum or index == WsEnum)
			{
				; drop whitespace
				lastTokenDropped := 1
			}
			else if (index)
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert( { ( idFlagNames[index] ): 1, tokenId: index, string: queuedToken } )
			}
			else
				FAIL("Invalid token '" RegExReplace(string, FS) "'.  Failing prefix '" stringToken "'.")
		}

		this.queuedToken := queuedToken
		return this
	}

	string_collapseHWhitespaceAndKeepNewLineLexEnum(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		
		local lexerInfo := this.lexerInfo
		, NlEnum := lexerInfo.newlineToken.tokenId
		, WsEnum := lexerInfo.collapsedWhitespaceToken.tokenId
		, idFlagNames := lexerInfo.idFlagNames
		, count := lexerInfo.count
		, queuedToken := 0
		, index := 0
		, remapTokenString := lexerInfo.remapTokenString
		
		string := substr(RegExReplace(string, lexerInfo.tokenRE, lexerInfo.replacement), 1, -1) ; insert a RS after every token except the last one

		loop, parse, string, %RS%
		{
			loop, parse, A_LoopField, %FS% ; parse loop faster then RegExMatch call by about 36us
				if (A_LoopField != "")
				{
					queuedToken := A_LoopField
					, index := A_Index - 1
					break
				}
				
			if (index == WsEnum)
			{
				; collapse horizontal whitespace
				this.Insert(lexerInfo.collapsedWhitespaceToken)
				, lastTokenDropped := 1
			}
			else if (index)
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert( { ( idFlagNames[index] ): 1, tokenId: index, string: queuedToken } )
			}
			else
				FAIL("Invalid token '" RegExReplace(string, FS) "'.  Failing prefix '" stringToken "'.")
		}

		this.queuedToken := queuedToken
		return this
	}
	
	string_collapseHWhitespaceAndDropNewLineLexEnum(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		
		local lexerInfo := this.lexerInfo
		, NlEnum := lexerInfo.newlineToken.tokenId
		, WsEnum := lexerInfo.collapsedWhitespaceToken.tokenId
		, idFlagNames := lexerInfo.idFlagNames
		, count := lexerInfo.count
		, queuedToken := 0
		, index := 0
		, remapTokenString := lexerInfo.remapTokenString
		
		string := substr(RegExReplace(string, lexerInfo.tokenRE, lexerInfo.replacement), 1, -1) ; insert a RS after every token except the last one

		loop, parse, string, %RS%
		{
			loop, parse, A_LoopField, %FS% ; parse loop faster then RegExMatch call by about 36us
				if (A_LoopField != "")
				{
					queuedToken := A_LoopField
					, index := A_Index - 1
					break
				}
				
			if (index == NlEnum)
			{
				; drop newline
				lastTokenDropped := 1
			}
			else if (index == WsEnum)
			{
				; collapse horizontal whitespace
				lastTokenDropped := 0
				, this.Insert(lexerInfo.collapsedWhitespaceToken)
			}
			else if (index)
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert( { ( idFlagNames[index] ): 1, tokenId: index, string: queuedToken } )
			}
			else
				FAIL("Invalid token '" RegExReplace(string, FS) "'.  Failing prefix '" stringToken "'.")
		}

		this.queuedToken := queuedToken
		return this
	}

	string_keepWhitespaceLexEnum(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		
		local lexerInfo := this.lexerInfo
		, NlEnum := lexerInfo.newlineToken.tokenId
		, WsEnum := lexerInfo.collapsedWhitespaceToken.tokenId
		, idFlagNames := lexerInfo.idFlagNames
		, count := lexerInfo.count
		, queuedToken := 0
		, index := 0
		, remapTokenString := lexerInfo.remapTokenString
		
		string := substr(RegExReplace(string, lexerInfo.tokenRE, lexerInfo.replacement), 1, -1) ; insert a RS after every token except the last one

		loop, parse, string, %RS%
		{
			loop, parse, A_LoopField, %FS% ; parse loop faster then RegExMatch call by about 36us
				if (A_LoopField != "")
				{
					queuedToken := A_LoopField
					, index := A_Index - 1
					break
				}
				
			else if (index)
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert( { ( idFlagNames[index] ): 1, tokenId: index, string: queuedToken } )
			}
			else
				FAIL("Invalid token '" RegExReplace(string, FS) "'.  Failing prefix '" stringToken "'.")
		}

		this.queuedToken := queuedToken
		return this
	}

	string_keepHWhitespaceAndDropNewLineLexEnum(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		
		local lexerInfo := this.lexerInfo
		, NlEnum := lexerInfo.newlineToken.tokenId
		, WsEnum := lexerInfo.collapsedWhitespaceToken.tokenId
		, idFlagNames := lexerInfo.idFlagNames
		, count := lexerInfo.count
		, queuedToken := 0
		, index := 0
		, remapTokenString := lexerInfo.remapTokenString
		
		string := substr(RegExReplace(string, lexerInfo.tokenRE, lexerInfo.replacement), 1, -1) ; insert a RS after every token except the last one

		loop, parse, string, %RS%
		{
			loop, parse, A_LoopField, %FS% ; parse loop faster then RegExMatch call by about 36us
				if (A_LoopField != "")
				{
					queuedToken := A_LoopField
					, index := A_Index - 1
					break
				}
				
			if (index == NlEnum)
			{
				; drop horizontal newline
				lastTokenDropped := 1
			}
			else if (index)
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert( { ( idFlagNames[index] ): 1, tokenId: index, string: queuedToken } )
			}
			else
				FAIL("Invalid token '" RegExReplace(string, FS) "'.  Failing prefix '" stringToken "'.")
		}

		this.queuedToken := queuedToken
		return this
	}
	
	string_dropHWhitespaceAndKeepNewLineLexEnum(string, ByRef lastTokenDropped = 0)
	{
		static RS := tokelex.RS
		, FS := tokelex.FS
		
		local lexerInfo := this.lexerInfo
		, NlEnum := lexerInfo.newlineToken.tokenId
		, WsEnum := lexerInfo.collapsedWhitespaceToken.tokenId
		, idFlagNames := lexerInfo.idFlagNames
		, count := lexerInfo.count
		, queuedToken := 0
		, index := 0
		, remapTokenString := lexerInfo.remapTokenString
		
		string := substr(RegExReplace(string, lexerInfo.tokenRE, lexerInfo.replacement), 1, -1) ; insert a RS after every token except the last one

		loop, parse, string, %RS%
		{
			loop, parse, A_LoopField, %FS% ; parse loop faster then RegExMatch call by about 36us
				if (A_LoopField != "")
				{
					queuedToken := A_LoopField
					, index := A_Index - 1
					break
				}
				
			if (index == NlEnum)
			{
				lastTokenDropped := 0
				, this.Insert(lexerInfo.newlineToken)
			}
			else if (index == WsEnum)
			{
				; drop horizontal whitespace
				lastTokenDropped := 1
			}
			else if (index)
			{
				lastTokenDropped := 0
				, remapTokenString.haskey(queuedToken) ? (remapTokenString[queuedToken].expand ? this.Insert(this.MaxIndex()?this.MaxIndex()+1:1, remapTokenString[queuedToken].expand*) : this.Insert(remapTokenString[queuedToken])) : this.Insert( { ( idFlagNames[index] ): 1, tokenId: index, string: queuedToken } )
			}
			else
				FAIL("Invalid token '" RegExReplace(string, FS) "'.  Failing prefix '" stringToken "'.")
		}

		this.queuedToken := queuedToken
		return this
	}
	
	string(string)
	{
		if (string != "")
			this.string_helper(string)
		this.maxTokenFound := 1
		this.queuedToken := ""
		this.__Get := tokelex.__Get_FromString
		return this
	}
	
	openFile(filename, chunkSize=4096)
	{
		this.file := FileOpen(filename, "r")
		this.chunkSize := chunkSize
		this.__Get := tokelex.__Get_FromFile
		return this
	}

	;;::::::::::::::::::::::::::::::::::::::::::::
	;; HAVE TO DEAL WITH MULTILINE TOKENS
	;;::::::::::::::::::::::::::::::::::::::::::::
	__Get_FromString(index, appendToTokenList=0, failOnNoMoreTokens=1)
	{
		;; nothing more to get
		if index is number
			if (index < this.MinIndex())
				FAIL("Token " index " is stale.")
			else if (index > (maxIndex := this.MaxIndex()) and failOnNoMoreTokens )
				FAIL("Request to get token " index " failed as there are only " (maxIndex is number ? maxIndex : 0) " tokens available!")
			else
				return 0
		else
			FAIL("Unrecognised member '" index "' requested from tokelex. object.")
	}
	
	__Get_FromFile(index, appendToTokenList=0, failOnNoMoreTokens=1)
	{
		if index is number
		{
			if (index < this.MinIndex())
				FAIL("Token " index " is stale.")

			appendToTokenList := appendToTokenList or this.holdTokensPositionStack.MaxIndex()
;OutputDebug % "== LOOP START =="
			loop 
			{
				; read in from file.  If less characters are read in then requested, then check to see if at eof
				; to allow for special files.
				maxTokenFound := strlen(string := (this.file ? this.file.Read(this.chunkSize) : "")) < this.chunkSize ;? this.file.AtEOF : 0
;OutputDebug % "Read in: '" string "'."

				; prepend any queuedToken token
				if ("" != this.queuedToken)
					string := this.queuedToken string
				else if ("" == string)
				{
					maxIndex := this.MaxIndex()
					break
				}
				
;OutputDebug % "Processing: '" string "'."
				;continue := 0
				
				if (appendToTokenList)
				{
					; do nothing
				}
				else
				{
					; replace tokens
					this.Remove(this.MinIndex(), oldMax := this.MaxIndex())
					oldMax := oldMax ? oldMax : 0
					ObjInsert(this, oldMax, 0)
				}
				
				this.string_helper(string, lastTokenDropped)
				
				if (maxTokenFound)
				{
					this.maxTokenFound := 1
					this.queuedToken := ""
					
					if (index > (maxIndex := this.MaxIndex()) and failOnNoMoreTokens )
						FAIL("Request to get token " index " failed as there are only " (maxIndex is number ? maxIndex : 0) " tokens available!")
					
					if (this.file)
					{
						this.file.Close()
						this.file := 0
					}
				}
				else
				{
					; this must check if the queued token would have already have been dropped and if so not to drop it.
					if (lastTokenDropped)
					{
						; do nothing
					}
					else
					{
						x := hex_dump(this.GetAddress("queuedToken"), 4)
						this.Remove() ; remove the last token as it may be incomplete
					}
					maxIndex := this.MaxIndex()
				}

;OutputDebug % "State: " object_elementList(this, "this") "."
;OutputDebug % "Continue: " continue
;if (continue)
;	continue
				appendToTokenList := 1
			} until index <= maxIndex or maxTokenFound
			
			this.Remove(oldMax, "")
			
;OutputDebug % "== LOOP FIN =="
			if (index <= maxIndex)
				return this[index]
			else if (failOnNoMoreTokens)
				FAIL("Token '" index "' is not available.  Maximum token read in is '" maxIndex "'.")
			else
				return 0 ; should only occur if failOnNoMoreTokens is false
		}
		else
			FAIL("Unrecognised member '" index "' requested from tokelex. object.")
	}
	
	; NOTE: To reduce call and computational overhead, check to see if (pos <= this.MaxIndex() or this.tokenAvailable(pos))
	tokenAvailable(pos)
	{
		return pos <= this.MaxIndex()
			? this.MinIndex() <= pos
			: this.maxTokenFound
				? 0
				: (1, this[pos, 0, 0]) ? pos <= this.MaxIndex() : FAIL("Will never get here.")

		; original code
		if (pos <= this.MaxIndex())
			return 1
		else if (this.maxTokenFound)
			return 0
		else
		{
			this[pos, 0, 0]
			if (pos <= this.MaxIndex())
				return 1
			else
				return 0
		}
	}

	; This is a stack of token positions that are being held.  This is for
	; the case where the parse partially matches, but then fails later,
	; allowing to go back and try a different parse.
	;
	; If this contains any elements, then the token cache will not be cleared, but appended to when getting the next set of tokens.
	;holdTokensPositionStack := []
	
	; About to test a parse with possibility of failure.
	; Push a token position to the token position stack so can backtrack on failure.
	holdTokens(pos)
	{
		this.holdTokensPositionStack.Insert(pos)
	}
	
	; Parse was successful, don't need to backtrack to last held position.
	; Pops off the last held token position.
	holdTokensRelease()
	{
		if ((maxIndex := (holdTokensPositionStack := this.holdTokensPositionStack).MaxIndex()) == "")
			FAIL("Token release called without a matching hold.")
		holdTokensPositionStack.Remove()
	}
	
	; Parse was unsuccessful, backtrack and try again by
	; reverting to last held position, but do not clear that position
	holdTokensRevert()
	{
		if ((maxIndex := (holdTokensPositionStack := this.holdTokensPositionStack).MaxIndex()) == "")
			FAIL("Token revert called without a matching hold.")
		return holdTokensPositionStack[maxIndex]
	}

	test()
	{
		; DO NOT ANCHOR THE RegEx to the begining of the string or it will not be able to capture
		; the failure token properly.
		TOKENIZER_RE_ := "SxmP`a)
		(
				(?:[lL](?!"")|[a-km-zA-KM-Z_])[a-zA-Z_0-9]* # WORD
			|	[ \t]+ # WHITESPACE
			|	(?:==?|\+[+=]?|-[-=]?|&[&=]?|\|[|=]?|\*=?|/(?![/*])=?|\^=?|!=?|<=?|>=?|`%=?|\.(?![0-9])|\#\#?|[(){}\[\],?:;]) # OPERATORS
			|	(?:\\$(?:\r\n?|\n\r?)?) # QUOTED NEWLINE
			|	(?://.*$) # COMMENT LINE
			|	(?:/\*(?:\r\n?|\n\r?|.)*?\*/) # COMMENT BLOCK
		#	|	(?:/\*(?:\r\n?|\n\r?|.)*$) # COMMENT BLOCK INCOMPLETE
			|	(?:[lL]?""(?:\\""|.)*?"") # STRING LITERAL
			| 	(?: # some parts here are duplicated to prevent backtracking.
					0(?:
						(?:
							\.[0-9]* # float/double
							(?:[Ee][+-]?[0-9]+)? # possible exponential notaion
							[Ff]?  # possible float suffix
						`)
						| (?:
							[0-7]+ # octal dec and hex
							| [xX][0-9a-fA-F]+ # hex
							| # just zero
						`)[Uu]?[Ll]? # possible U or L suffix
					`)
					| [1-9][0-9]*  # int or
						(?:
							\.[0-9]* # float/double
							(?:[Ee][+-]?[0-9]+)? # possible exponential notaion
							[Ff]?  # possible float suffix
							| [Uu]?[Ll]? # possible  U or L suffix
						`)
					|
						\.[0-9]* # float/double
						(?:[Ee][+-]?[0-9]+)? # possible exponential notaion
						[Ff]?  # possible float suffix
				`)\b # end on a word boundry
					 # NUMERIC LITERAL
			|	(?:'(?:\\'|.)+') # CHARACTER LITERAL
			|	(?:\r\n?|\n\r?) # NEW LINE
		)"
		, TOKENIZER_RE := removeCommentsAndWhitespaceFromRegEx(TOKENIZER_RE_)
		, string := "0fu "
		, RS := chr(8)
		, FS := chr(7)
		, replacement := FS "$0" RS 

		; TODO: Ensure that failed tokens are found
		t := new tokelex.(TOKENIZER_RE_, tokelex.KEEP_NEWLINE).openFile("linestream-test.txt",2)
		;t := new tokelex.(TOKENIZER_RE_, tokelex.KEEP_NEWLINE).string(string)
		p := 1
		while(t.tokenAvailable(p))
			msg .= "[" A_Index "] = '" RegExReplace(RegExReplace(RegExReplace(t[p++], "\n", "``n"), "\t", "``t"), "\r", "``r") "'`n"

		OutputDebug % msg
		MsgBox % msg
	}
}
