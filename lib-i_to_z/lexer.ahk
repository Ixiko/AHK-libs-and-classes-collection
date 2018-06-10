;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Lexer class
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

#include <lineReader>
#include <misc>
#include <ClassCheck>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LEXER CLASS:
;
;  This is a abstract class for a lexer.  It is abstract since there are
;  required functions that are missing from this class that need to be 
;  added by the extending (derriving from) this class. You cannot use this 
;  class on its own and will fail upon attempting on calling one of these
;  functions.
;
;  The extending class is required to implement the following functions:
;
;    1. tokenizer(lineReader, tokens, gettingLineContinuation)
;
;    2. someTokensAreNotIgnored([byref] tokens)
;
;    3. preparser([byref] tokens)
;
;  tokenizer()
;
;    The tokenizer() breaks up a line that it retreives from the linereader
;    class instance into an array of tokens that it then adds to the token 
;    array passed to it.
;
;    If gettingLineContinuation is non-zero, this tells the function
;    that the line is incomplete on its own and that it needs more to be 
;    completed.  Simply forward this value to lineReader.GetLine() like so:
;
;      if (lineReader.GetLine(startPos, endPos, gettingLineContinuation))
;
;    See lineReaderString class for more details
;
;    Successful extraction of any tokens from the lineReader should result
;    in the return of a 1.  Note that the successful extraction of 0 tokens
;    may occur in the case when the line is empty (endPos = startPos-1).
;
;    If the lineReader.GetLine() call fails (returns 0) then some end of stream
;    token may be added to the end of the tokens array, but a return of 0 from 
;    the tokenizer() function must occur.
;
;    Multiline tokens are possible to lex by determining that the character
;    sequence has been found without the end sequence.  You can then read in the
;    rest of the contents of the token by calling tokenizer_readMultiLineToken()
;    or drop its contents by calling tokenizer_dropMultiLineToken().
;
;  someTokensAreNotIgnored()
;
;    If a call to this function returns 0, then the next line of tokens are
;    read in since there is nothing for the parser to do, otherwise the 
;    generated tokes are released to the parser.
;
;    By having tokens parameter as a byref, you can remove all ignored tokens
;    immediately by setting it to [] if needed.
;
;  preparser()
;
;    This preparses the line of tokens prior to calling someTokensAreNotIgnored()
;    and prior to setting/appending these new tokens into the current
;    token list used by the parser.
;
;    If a call to this function returns 0 then another line of tokens are added
;    to the current set.  Returning 1 states that the line is complete and that
;    it can be passed on to the parser.
;
;    Although the tokenizer() could find the end of the line, the preparser is
;    called once a line has been tokenized() so if you are adding an end of line
;    token, it may be advantagious performance wise to add it here rather then 
;    use another regex in the tokenizer().
;
;    By having tokens parameter as a byref, you can remove all ignored tokens
;    immediately by setting it to [] if needed.
;
; USAGE:
;
;  Using the lexer is fairly simple, you instantiate a lineReader and pass it
;  to a new instance of a lexer.  You then extract the tokens using the get
;  functions and can mark a position to redo a search path later if it is
;  discovered that a grammer match has failed and an alternate exists, allowing
;  it to process LL(k) grammers.
;
;  The lexer does not enforce the type or the structure of each token of the
;  tokens list by design allowing the programmer to optimise as they see fit.
;  The original design was that of a more traditional lexer where each token
;  was given numeric designation (an enumeration), but I realised that this
;  could be a perfomance issue in a scripting language, so I was very happy
;  when I found a way to seperate token representation from implementation of 
;  this lexer.  However, the enum system is left in case there becomes some 
;  reason to use it.  I personally use a flag system which can be seen in use
;  in the c.lexer implmentation.
;
; Using the Enums
;
;  The extending class defines the static variables tnames and tenums and 
;  assigns to them lexer.addTokenNames("lexerToken1", ..., "lexerTokenN")
;  and <extendingClassName>.generateEnums() respectivly.
;
;  What this does is create an enum list of token names that start with
;  END_OF_STREAM(enum value of 0) and INCOMPLETE_TOKEN(1), followed by
;  the token names that were specified.  To go back from an enum value to
;  what the token's name is, use the tenums static varible.
;
; Extracting a Token
;
;  Use the get functions.  If l is the lexer object, the commands would be
;  l.getInc(), l.incGet(), l.getDec(), l.decGet(), l.getPrev(), l.getNext(),
;  l.get() and l[x], where x is any integer representing an offset from the
;  current token represented by l.t_pos.  Manually chaning l.t_pos can be
;  done, but a value less than 1 indicates a stale token (token has been 
;  dropped from the token cache).  If the token cache does not have the token 
;  as pointed at by l.t_pos and it is a positive value, then calling a get 
;  function will result in an attempt to get that token by reading in as many 
;  lines as it takes or until it reaches the end of the lineReader stream which
;  would cause an error.
;
;  The first four get functions will change the l.t_pos pointer.  l.getInc()
;  and l.getDec() gets the tokens and then moves the l.t_pos pointer.  
;  l.incGet() and l.decGet() moves the l.t_pos pointer and then gets the token.
;
;  The last four get functions do not move the l.t_pos pointer.
;
;  Tokens in the token cache can become stale when reading in the next line
;  unless a hold function is used or when using l[x] which never drops stale
;  tokens.  Use l[x] sparingly or you may reduce perfomance and increase
;  memory usage.
;
; Hold functions
;
;  To be able to backtrack and test another potential grammer match, the hold
;  functions can be used to hold off removing tokens when reading in the next
;  line.  Again, if l is the lexer object, the function calls would be
;  l.holdTokens(), l.holdTokensRelease() and  l.holdTokensRevert().
;
;  l.holdTokens() holds all tokens currently in the cache and remembers
;  the current token position so that it can be returned to using 
;  l.holdTokensRevert().  If a successful gramatic parse occurs use the 
;  l.holdTokensRelease() function.
;
;  For every l.holdTokens() there should be a l.holdTokensRelease() or the 
;  application report an error due to an invalid gramatic parse.  Not
;  releasing a hold position could result in reduced performance and an
;  increase in memory usage.
;
; Detect end of token stream
;
;  The member function hasMoreTokens() ensures that the token cache is updated
;  (like the get functions) as well, it will return a 1 if there are more 
;  tokens are available.  It will return 0 if there is not.
;
; END - ENJOY!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

class lexer extends CheckCallNameExists
{
	static tnames := lexer.addTokenNames("INCOMPLETE_TOKEN")
	static tenums := lexer.generateEnums()

	addTokenNames(tokenNames*)
	{
		if ((minIndex := (tnames := this.tnames.Clone()).MinIndex()) == "")
			tnames := { 0: "END_OF_STREAM" }
		else if (minIndex == 1)
			tnames.insert(0, "END_OF_STREAM")
		
		tnames.insert(tnames.MaxIndex()+1, tokenNames*)
		return tnames
	}
	
	generateEnums()
	{
		tenums := {}
		for tenum, tname in this.tnames
			tenums[tname] := tenum
		return tenums
	}

	tokens := [] ; token cache
	t_pos := 1 ; current index used for tokens. t_pos > t_max will require that the cache be refilled.
	; stack indicating tokens in use state that these tokens are not to be removed when caching more tokens.
	t_max := 0 ; slight optimisation of tokens.MaxIndex()
	; if you parse something that is included from within currentParseFrom, then push currentParseFrom here.  When done pop it off and put it in currentParseFrom
	defines := [] ; defines
	currentParseFrom := 0 ; this is to be a lineReader object
	; set to the last parsed token from within the tokenizer().  
	; This allows seperation between the data representation of the token stream and the lexer.
	; All the lexer knows about the representation is that it is an array, but not what each element in the array holds.
	incompleteToken := 0
	
	__New(lineReader)
	{
		this.currentParseFrom := lineReader
	}
	
	incGet()
	{
		if (this.t_pos >= this.t_max)
			this.cacheMoreTokens()
		return this.tokens[++this.t_pos]
	}
	
	getInc()
	{
		if (this.t_pos > this.t_max)
			this.cacheMoreTokens()
		return this.tokens[this.t_pos++]
	}
	
	decGet()
	{
		if (this.t_pos <= 1)
			FAIL("Trying to retreive stale token in cache store.")
		return this.tokens[--this.t_pos]
	}
	
	getDec()
	{
		if (this.t_pos <= 1)
			FAIL("Trying to move token pointer to stale cache location.")
		return this.t_pos--
	}

	__Get(offset)
	{
		getAtIndex := this.t_pos
		if (1 <= getAtIndex)
		{
			while (getAtIndex > this.t_max)
			{
				this.cacheMoreTokens(1, 1) ; make sure to hold on to currently cached tokens or current t_pos will become wrong
			}
			return this.tokens[getAtIndex]
		}
		FAIL("Trying to retreive stale token in cache store.")
	}
	
	get()
	{
		if (this.t_pos > this.t_max)
			this.cacheMoreTokens()
		return this.tokens[this.t_pos]
	}
	
	getPrev()
	{
		if (this.t_pos <= 1)
			FAIL("Trying to retreive stale token in cache store.")
		return this.tokens[this.t_pos-1]
	}
	
	getNext()
	{
		if (this.t_pos >= this.t_max)
			this.cacheMoreTokens(1, 1) ; make sure to hold on to currently cached tokens or current t_pos will become wrong
		return this.tokens[this.t_pos+1]
	}
	
	hasMoreTokens()
	{
		result := 1
		; loop while the token at t_pos is not available and there are more tokens available
		while this.t_pos > this.t_max and result := this.cacheMoreTokens(0)
		{
		} 
		return result
	}

	; This is a stack of token positions that are being held.  This is for
	; the case where the parse partially matches, but then fails later,
	; allowing to go back and try a different parse.
	;
	; If this contains any elements, then the token cache will not be cleared, but appended to when getting the next set of tokens.
	holdTokensPositionStack := []
	
	; About to test a parse with possibility of failure.
	; Push a token position to the token position stack so can backtrack on failure.
	holdTokens()
	{
		this.holdTokensPositionStack.Insert(this.t_pos)
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
		this.t_pos := holdTokensPositionStack[maxIndex]
	}
	
	; Finishes reading in a block comment token and drops the content
	tokenizer_dropMultiLineToken(lineReader, tokens, ByRef startPos, ByRef endPos, byref match, TOKEN_END_RE)
	{
		while ((readLine := lineReader.GetLine(startPos, endPos, 1)) and !RegExMatch(lineReader.buffer, TOKEN_END_RE, match, startPos))
		{
		}
		if (readLine)
			return 1
		else
			FAIL("Didn't find end of multiline token matching RegEx '" TOKEN_END_RE "' from " this.currentParseFrom.diagnositicInfo())
	}
	
	; Finishes reading in a block comment token and returns the content
	tokenizer_readMultiLineToken(lineReader, tokens, ByRef startPos, ByRef endPos, byref match, TOKEN_END_RE)
	{
		while ((readLine := lineReader.GetLine(startPos, endPos, 1)) and !RegExMatch(lineReader.buffer, TOKEN_END_RE, match, startPos))
		{
			result .= substr(lineReader.buffer, startPos, endPos-startPos+1) "`n"
		}
		if (readLine)
			return result match
		else
			FAIL("Didn't find end of multiline token matching RegEx '" TOKEN_END_RE "' from " this.currentParseFrom.diagnositicInfo())
	}
	
	; If failOnFailure and there are no more tokens to get, then FAIL() , else return 0
	; If holdTokens then hold tokens even if holdTokensPositionStack is empty
	cacheMoreTokens(failOnFailure = 1, holdTokens = 0)
	{
		tokens := []
		ppDoesNotNeedMore := 1
		success := 1
		Loop
		{
			; generate tokens for current line
			if (this.tokenizer(this.currentParseFrom, tokens, !ppDoesNotNeedMore))
			{ ; intentionally blank
			}
			else if (ppDoesNotNeedMore)
				if (failOnFailure)
					FAIL("Ran out of tokens while reading from " this.currentParseFrom.diagnositicInfo())
				else
					return 0
			else
				FAIL("Preprocessor required more tokens but stream has terminated unexpectedly while reading from " this.currentParseFrom.diagnositicInfo())
	
			; OPTIMIZATION: Embedded preparser here to save extra processing if more tokens were needed.  
			;               Also removes the need to put tokens somewhere to be preprocessed before appending to/replacing current tokens
			; preparser returns true when it doesn't need to read in any additional lines
			; if no tokens left due to preparser removing them all, continue from the start of loop
		} Until (ppDoesNotNeedMore := this.preparser(tokens)) and this.someTokensAreNotIgnored(tokens)

		; remove stale tokens from this.tokens if no tokens held, append otherwise.
		; Also adjust t_max.
		if (holdTokens or this.holdTokensPositionStack.MaxIndex())
		{
			; append tokens to current list
			this.tokens.Insert(this.t_max + 1, tokens*)
			this.t_max += tokens.MaxIndex()
		}
		else
		{
			; replace tokens
			this.tokens := tokens
			this.t_max := tokens.MaxIndex()
			; since replacing tokens, t_pos gets reset to begining
			this.t_pos := 1
		}
		return 1
	}
}