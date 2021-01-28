;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Miscellaneous functions I use in AHK_L
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; misc
;;
;; LOG
;; Nov 30, 2012
;;  - fixed memcpy().  It was calling memcpy_s with wrong parameters.  Fixed.
;; Dec 5, 2012
;;  - added WARN() and removeCommentsAndWhitespaceFromRegEx()
;; Dec 7, 2012
;;  - added documentation.
;;  - WARN() can have it's popup disabled by setting WARN global to 1.
;;  - Using OutputDebug() function instead of internal command.  This is because
;;    though it is unlikely that the stack output will generate more than 32k of
;;    characters, it could be possible in a complex application.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include <DllCallCheck>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FAIL(msg)
;;  Reports that the code has reached a location that it should not have.
;;
;;    msg - message to report back to the developer.
;;
;;  This is sort of like an assert without the test.  The reason for no test is
;;  that if test were to be done as a function parameter, then the error string
;;  would be build regardless if the assert is true or not.  Using a
;;  shortcircuiting logical or a trinary expression stops that from happening.
;;  E.g.  The following are equivilant.
;;
;;    invalidState and FAIL("This state is invalid: '" x "', '" y "', '" z "'.)
;;  or
;;    !invalidState or FAIL("This state is invalid: '" x "', '" y "', '" z "'.)
;;  or
;;    invalidState ? FAIL("This state is invalid: '" x "', '" y "', '" z "'.):0
;;
;;  A popup will occur when FAIL() is called with the message passed, and the
;;  call stack to aid the developer in finding out what happened.  Debug output
;;  via an OutputDebug() call is also generated.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FAIL(msg)
{
	exitMsg := "ERROR: " msg "`n`n" CallStack()

	OutputDebug(exitMsg)
	MsgBox %exitMsg%
	ExitApp
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; WARN(msg)
;;  Keeps developer apprised of things that are happening in the code and where.
;;
;;    msg - message to report back to the developer.
;;
;;  This is used to tell the developer of things that have just happend, and
;;  like FAIL(), reports where it has happened, what line, and what the stack
;;  looks like.  Unlike FAIL(), the application keeps going.
;;
;;  Also, if the global WARN is set to 0, the popup is not generated, though the
;;  OutputDebug() call is still generated.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WARN = 1
WARN(msg)
{
	global WARN
	msg := "WARNING: " msg "`n`n" CallStack()

	OutputDebug(msg)
	if (WARN)
		MsgBox %msg%
	a := 1 ; to allow for setting a breakpoint
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; removeCommentsAndWhitespaceFromRegEx(regex)
;;  Attempts to reduce the size of a regex to increase it's execution speed.
;;
;;    regex - Any regex, but only those with the x option will attempt to be 
;;            modified.
;;
;;  Regular expressions allow for adding comments if the x option is used.  But
;;  it turns out that the longer the regex string becomes, the longer it takes
;;  to execute the regex.  This is not related to the regex itself, but to the
;;  string comparison to determine what internally compiled regex is to be used.
;;
;;  By removing the whitespace at the begining and end of a line, the whitespace
;;  between the options and the first non-whitespace, and the whitespace just 
;;  after the first | character on a line, it allows the regex to be smaller
;;  without changing its meaning.
;;
;;  I think this should only be a stopgap measure and that the compiled regex
;;  should be exposed to remove this problem since a longer and more complex 
;;  regex will take longer to execute, even if the regex engine is not to blame.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
removeCommentsAndWhitespaceFromRegEx(regex)
{
	if (RegExMatch(regex, "^[^x()]*x[^x()]*\)"))
	{
		static REMOVE_COMMENTS := "`am)^((?:\\.|\[[^\]*]\]|[^#])*)#.*$"
		, REMOVE_WHITESPACE := "[ \t\r\n]*((?:\\.|\[(?:\\.|[^\]])*\]|[^# \t\r\n])*)[ \t\r\n]*"
		
		;~ This is an attempt to whitespaces and comments in one RegExReplace() call.
		;~ Not sure if it can be done though, but it's just for fun. :)
		;~ , KEEP_NON_WHITESPACE := "((?:\\.|\[(?:\\.|[^\]])*\]|[^# \t\r\n])*)"
		;~ , REMOVE_COMMENTS_AND_SURROUNDING_WHITESPACE := "[ \t\r\n]*(?:#[^\r\n]*(?:\r\n?|\n\r?))[ \t\r\n]*"
		
		;~ , REMOVE_COMMENTS_AND_ALL_WHITESPACE := KEEP_NON_WHITESPACE REMOVE_COMMENTS_AND_SURROUNDING_WHITESPACE
		;~ RE_1 := RegExReplace(regex, REMOVE_COMMENTS_AND_ALL_WHITESPACE, "$1")
		;~ RegExCheck(REMOVE_COMMENTS_AND_ALL_WHITESPACE)
		;~ return RE_1
		
		RE_2 := RegExReplace(regex, REMOVE_COMMENTS, "$1")
		;~ RegExCheck(REMOVE_COMMENTS)
		RE_3 := RegExReplace(RE_2, REMOVE_WHITESPACE, "$1")
		;~ RegExCheck(REMOVE_WHITESPACE)
		return RE_3
	}
	return regex
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CallStack(skipStackLevels = 0, printLines = 1)
;;  Returns the call stack to help the programmer determine what has gone wrong.
;;
;;    skipStackLevels - used to skip levels if the programmer using this is
;;                      always calling it from several levels deep that is not
;;                      useful for debugging.
;;
;;    printLines - if non-zero, extracts the line from the file where the stack
;;                 call has occured.
;;
;;  This is primarly used for debugging purporses.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CallStack(skipStackLevels = 0, printLines = 1)
{
	stack := "Call Stack:"
	stackLevel := -2 - skipStackLevels
	oEx := Exception("", stackLevel)
	oExPrev := Exception("", stackLevel - 1)
	while % !isInteger(oEx.What)
	{
		FileReadLine, line, % oEx.file, % oEx.line
		stack .= "`n  '" oEx.file "':" oEx.line (IsNumber(oExPrev.What) ? "" : ":" oExPrev.What (IsFunc(oExPrev.What) ? "()" : "")) (printLines ? ":`n    " Trim(line) : "`n")
		oEx := Exception("", --stackLevel)
		oExPrev := Exception("", stackLevel - 1)
	}
	return stack
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; isNumber(x)
;;  Returns if x is a number or not.
;;    x - variable to determine if it is a number.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isNumber(ByRef x)
{
	if x is number
		return 1
	else
		return 0
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; isInteger(x)
;;  Returns if x is an integer or not.
;;    x - variable to determine if it is a integer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isInteger(ByRef x)
{
	if x is Integer
		return 1
	else
		return 0
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; memcpy(pDst, pSrc, size)
;;  Copys size byte from pSrc to pDst.
;;    pDst - address to copy to (destination)
;;    pSrc - address to copy from (source)
;;    size - number of bytes to copy.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
memcpy(pDst, pSrc, size)
{
	if pDst is not integer
		FAIL("memset paramater pDst is '" pDst "' and not a integer.")
	else if (pDst = 0)
		FAIL("Can't call memcpy with pDst being a NULL pointer.")
	else if pSrc is not integer
		FAIL("memset paramater pSrc is '" pSrc "' and not a integer.")
	else if (pSrc = 0)
		FAIL("Can't call memcpy with pSrc being a NULL pointer.")
	else if size is not integer
		FAIL("memset paramater size is '" size "' and not a integer.")
	;; using Ptr instead of int for size because size_t is based on the largest integer (I think)
	_(DllCall("msvcrt\memcpy_s", "UPtr", pDst, "UPtr", size, "UPtr", pSrc, "Ptr", size, "Int"), _.STATUS)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; memset(pDst, val, size)
;;  Sets the memory at pDst for size bytes to val.
;;    pDst - destination address
;;    val - value to set each byte to
;;    size - number of bytes to set the value to.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
memset(pDst, val, size)
{
	if pDst is not integer
		FAIL("memset paramater pDst is '" pDst "' and not a integer.")
	else if (pDst = 0)
		FAIL("Can't call memset on a NULL pointer.")
	else if val is not integer
		FAIL("memset paramater val is '" val "' and not a integer.")
	else if size is not integer
		FAIL("memset paramater size is '" size "' and not a integer.")

	;; using Ptr instead of int for size because size_t is based on the largest integer (I think)
	return _(DllCall("msvcrt\memset", "UPtr", pDst, "Int", val, "Ptr", size, "Ptr"), pDst)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; repeat(x, y)
;;  Returns a string consiting of x repeated y times.
;;    x - string to repeat
;;    y - how many times to repeat string x.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
repeat(x, y)
{
	loop %y%
		z .= x
	return z
}
