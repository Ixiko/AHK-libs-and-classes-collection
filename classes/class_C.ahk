;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  C interface library
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

#include <lexer>
#include <tokelex>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C interface library
;;
;;  This is a alpha test to create a c type interface.  This is going to move on 
;;  to a full c interface module.
;;
;; USAGE
;;  Declare your types:
;;
;;    c.typedef("<type> <altName0> [, <altName1> [...] , ;]")
;;
;;    c.struct("
;;      (
;;        <name> {
;;          [<type0> <name0a> [, <name0b> [...] ] [,];]
;;          [<type1> <name1a> [, <name1b> [...] ] [,];]
;;         }[;]
;;       )")
;;
;;    c.union("
;;      (
;;        <name> {
;;          [<type0> <name0a> [, <name0b> [...] ] [,];]
;;          [<type1> <name1a> [, <name1b> [...] ] [,];]
;;         }[;]
;;       )")
;;
;;  NOTE that all whitespaces, including carrage returns and line feeds are
;;  ignored, except to seperate words.  This uses an almost fully functioning
;;  C parser.  What it lacks are the ability to read function pointers and 
;;  functions.  It even has a limited preprocessor, where you can define 
;;  macros that take no parameters.
;;
;;    c.define("<name> <replacement string is till end of line>")
;;
;;  In the case of defines, all whitespaces are colapsed to a single space,
;;  except for new lines.  That is where the macro ends.
;;
;;  Once a type is defined, you bring an instance of it into being by using
;;  the command:
;;
;;    new c.object("<name>")
;;
;;  which returns the new object.
;;
;;  Getting/setting array elements can be done by using:
;;
;;    var.<elementNumber>
;;    var.<elementNumber> := <new value>
;;  or (this has been disabled, may reenable later)
;;    var[<elementNumber>].
;;    var[<elementNumber>] := <new value>
;;
;;  Getting/setting structure or union members is done by using
;;
;;    var.<memberName> := <new value>
;;    var.<memberName> := assignedValue.
;;
;;  I've disabled the retreival of the hidden __Class member.  If you want to
;;  get the type of the object, i.e. the hidden __Class member, use 
;;  object_getBase() function instead.  From that you can get the __Class member,
;;  or just directly compare with the class name.  E.g.
;;
;;    class x
;;    {
;;    }
;;    xx := new x()
;;    if (object_getBase(xx) == x)
;;      MsgBox xx is of class x type
;;
;; To Be Done:
;;  1. Anonymous types need to be made so that an array need not be declared
;;     as a type.  Also may help in migrating others who use only anonymous
;;     types in their code previously.
;;  2. Accept and ignore comments. *DONE* with new parser
;;  3. Allow for specifying the minimum size of a type so that types which
;;     are just headers, can be created.
;;  4. Function pointers need to be understood.
;;  5. Being able to parse general C header file.
;; TESTING -----------------------------------------------------------------
;;  Would be nice to make some regression testing.  However, in any case, I 
;;  still need to test the following:
;;    1. Anonymous structs/unions *done*
;;    2. Assign object x to object y of same and different type
;;    3. Str type
;;
;;  Full regression testing would include:
;;    1. testing of setting elemnts and getting of the same elements.
;;    2. memory layout being correct for different stucture layouts.
;;    
;; INTERNALS ---------------------------------------------------------------
;;  class c
;;  {
;;     types := {} ; associative array of all structs, unions and typedefs
;;     defines := {} ; associative array of all define macros
;;  }
;;
;;  The c.types is a associative array of types objects, keyed by their name.
;;    1. A base type is defined by a tuple (name, size)
;;    2. A typedef is defined by a tuple (name, type)
;;    3. A union is defined by an array of tuples (name, type)
;;    4. A struct is defined by an array of triples (name, type, offset)
;;
;;  In addition to the tuples and triples, there may also exist:
;;    1. an arraySize specifying how many elements are there.
;;    2. an indirectionCount specifying if the type is a pointer
;;
;;  A define is defined by an associative array of strings (replacementString) 
;;
;;  name coming off of any type member or off of c.types will be the
;;    name of the type.
;;  name coming off the array defining a struct or union membefs will be the 
;;    name of the member variable.
;;  name coming off of anything else will be the name of the typedef.
;;
;; PERFORMANCE
;;  This is kinda slow at the moment (~16000us for member access), at around 3 
;;  times slower then HotKeyIt's _Struct class (~5300us for member access), so
;;  has a lot of room for improvment.
;;
;;  Such improvements include:
;;    1. Asking if an object has a member using .hasKey() is actually slower
;;       then getting the value of the variable directly.  So need to switch
;;       from asking if a member exists to just getting the variable where
;;       possible and have a debug and a release mode for when such tests are
;;       not practical.
;;    2. Using caching of frequently used data such as size and simplerType.
;;    3. Remove use of extra object indirection to get to c.object's members.
;;       I used an object member " " to stop any name clashing with possible C
;;       identifiers, but I can do the same by prepending a " " before each
;;       name.
;;    4. Unrolling function calls
;;
;;     - Have cached the type of c object which helps by about 2000us bringing
;;       it down to about 14300us.
;;     - Swapping check between array and struct in get and set functions does
;;       about the same as caching the c object type.
;;     - Doing a direct test instead of a test through a member function call
;;       saves about 1000us.
;;     - In type[" simplestType"] function, doing direct tests instad of 
;;       through helper member functions saved about 2500us
;;     - Now at around 11560us to access member.
;;     - Caching simpler type drops access to 9360us
;;     - Without getSimplerType() function overhead, this drops to 7500us
;;     - Caching size of type doesn't seem to do anything for simple types.
;;       Most likly will be faster for more complex types (nested) which will
;;       rarely occur for most windows stuff.
;;     - Currently at 7180-7500us
;;     - Unrolled c.type[" isBaseType"] dropping access to 6540us.
;;     - Unrolled c._retrive() dropping access to 4980-5300us. This is BETTER
;;       THAN _STRUCT!!
;;     - At some point I removed the test to see if key = "__Class" since I
;;       started using object_getBase() to compare against instead of doing
;;       a string compare against the class name.  With the extra compare,
;;       this has a get member time equivilant to that of _Struct class.
;;     - At some point I removed the extra object " " from the c.object and
;;       put its elements in the c.object directly prepending a space infront
;;       of them.  IIRC, this didn't seem to increase the speed as I would have
;;       hoped.
;;     - Now Set time is around 7800us, with _Struct's set time at 5150-5300us.
;;       Lets push this a little.
;;     - Unrolling _assign() dropped speed to 6860-7180us.
;;     - Removing debug statments dropped it to 6540-6860us.
;;     - Removing address checks drops it around 6240-6560us.
;;     - Rearranging things from the unrolling of _assign() drops it down to
;;       5940us.
;;     - Removing check to see if array method is used (a[1]) instead of member
;;       method (a.1) speeds up to 5620us
;;     - Current speed of _Struct get/set is 5150-5300us/5140-5310us.
;;       Current speed of CStruct get/set is 4980-5320us/5920-6240us.
;;     - Removing the objects BASETYPE, TYPEDEForMEMBER, STRUCT, UNION, COMPLEX
;;       and replacing ctype and ctype_ with just a flag for each allows for
;;       only retreival and test of the recreived value instead of retreaval and
;;       test to see if the retreived value is one of the objects.
;;     - These are min-max out of 8 tests:
;;         Current speed of _Struct get/set is 5300-5460us/5300-5460us.
;;         Current speed of CStruct get/set is 4380-4980us/5310-5620us.
;;     - Removed optimised code to switch back to debug code. i.e. removed 
;;       function unrolling.
;;     - a.b.c is slower than a[b,c].  Increases speed by about 320us/360-620us.
;;     - switching from linear search to dict increases performance from
;;       5920-6240us/7180us to 4680-5000us/5600-6240us.  Get already better than
;;       _Struct.  Will scream when functions are unrolled.
;;
;; LOG -------------------------------------------------------------------------
;;   Nov 30, 2012
;;     - Allow for creating base c types e.g. int, float, etc.
;;     - The setting and getting of base type objects can be done by using
;;       .Get() and .Set(value) member functions for c.object's.
;;     - Fixed ambiguity allowing the assignment of a c.object's initial value
;;       from the constructor, in case the c.object is a base numeric type.
;;
;;       New syntax is:
;;         x := new c.object("int", C.ASSIGN_VALUE, 6)
;;         y := new c.object("int", C.ASSIGN_ADDRESS, address)
;;
;;       Complex and array types can still be initialised using the old syntax:
;;         c.struct("mystruct { int a, b, c; }")
;;         x := new c.object("mystruct", {a: 1, b: 2, c: 3})
;;
;;     - Can now iterate over members of a struct/union or over the elements 
;;       of an array using the "for index, [key] in object" syntax.
;;
;;     - Added more checks to give programmer more information as to what went
;;       wrong.
;;
;;     - Can now jump between Release and Debug code using c.use("ReleaseCode")
;;       or c.use("DebugCode").  Relase doesn't have as many checks as it
;;       assumes its internal data structues are valid and not being changed
;;       by external infulances.  It also has optimised code to speed things up.
;;       Such optimisations are function unrolling, and removal of c.ndebug 
;;       statements.
;;
;;     - Removed internal _repeat() function and now using external repeat()
;;       function in misc.ahk
;;
;;     - Increased lookup for structs/unions by using the object's intrnal
;;       dictionary capability.  Had to prepend a space to all variables used
;;       inside of type to make sure they wouldn't be accedentily used by
;;       a programmer accessing a C member.  This is now entirly not case
;;       sensitive.
;;
;;     - Bug found where when setting an element in an array, it wasn't getting
;;       the simpler type.  Not sure how it got past the test, but fixed now.
;;
;;     - Now accepts:
;;         typedef struct <sname> { /* stuff */ } <tname1>, <tname2>...
;;       NOTE: Comments are not accepted.
;;
;;     - Pointer size bug caused size to be miscalculated.  Fixed.
;;
;;     - Unions and structs have been tested as well as their anonymous 
;;       equivilants.
;;
;;     - C.ASSIGN_VALUE was being assigned to operation as a string instead of
;;       a value.  Fixed.
;;
;;     - Using type.description() function to describe in more detail a type
;;       instead of having this copy code differently everywhere.
;;
;;     - Element list had some bugs where it wasn't using the simpler type when
;;       it should have.  Fixed.
;;
;;     - Changed c.newName() so that it would have a different counter for
;;       structs and unions.
;;
;;     - Union wasn't workign proprely since offset wasn't specified and code
;;       relied on it.  Didn't test unions so didn't see this till now.  Just
;;       set it to 0.  Faster processing if I don't to a check.
;;
;;  Dec 16, 2012
;;     - Implemented full lexer.  Currently side by side with original half
;;       assed lexer.  Will phase out the HA lexer after running some additioal
;;       performance tests.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include <DllCallCheck>
#Include <misc>
#include <ClassCheck>

;; Using class as a namespace.  Not ideal, but sufficiant.
;; Because of this, it has no member variables, just static ones.
;; Don't bother creating a new c object.  Do create a new c.object.
class c extends checkCallNameExists
{
	defineType(command)
	{
	}

	typedef__(command)
	{
		lexer_ := new c.lexer(new stringLineReader(command))
		c.typedef_parser__(lexer_)
	}
	
	typedef(command)
	{
		tokens := c.preprocess_macroReplace(c.tokenizer(command, c.operators, c.whitespace))
		position := 1
		c.typedef_parser(tokens, position)
	}

	typedef___(command)
	{
		tokens := c.preprocess_macroReplace___(new tokelex("c tokenizer", tokelex.KEEP_NEWLINE).string(command))
		position := 1
		c.typedef_parser___(tokens, position)
	}

	typedef____(command)
	{
		tokens := c.preprocess_macroReplace____(new tokelex("c lexer", tokelex.KEEP_NEWLINE).string(command))
		position := 1
		c.typedef_parser____(tokens, position)
	}

	struct(command)
	{
		tokens := c.preprocess_macroReplace(c.tokenizer(command, c.operators, c.whitespace))
		name := tokens[1]
		if (name == "{")
			FAIL("Cannot directly create an anonymous structure.")
		position := 2
		c.struct_parser(name, tokens, position)
	}

	struct___(command)
	{
		tokens := c.preprocess_macroReplace___(new tokelex("c tokenizer", tokelex.KEEP_NEWLINE).string(command))
		name := tokens[1]
		if (name == "{")
			FAIL("Cannot directly create an anonymous structure.")
		position := 2
		c.struct_parser___(name, tokens, position)
	}

	struct____(command)
	{
		tokens := c.preprocess_macroReplace____(new tokelex("c lexer", tokelex.KEEP_NEWLINE).string(command))
		name := tokens[1].string
		if (name == "{")
			FAIL("Cannot directly create an anonymous structure.")
		position := 2
		c.struct_parser____(name, tokens, position)
	}

	struct__(command)
	{
		lexer_ := new c.lexer(new stringLineReader(command))
		name := lexer_.get().value
		if (name == "{")
			FAIL("Cannot directly create an anonymous structure.")
		lexer_.t_pos := 2
		c.struct_parser__(name, lexer_)
	}
	
	union(command)
	{
		tokens := c.preprocess_macroReplace(c.tokenizer(command, c.operators, c.whitespace))
		name := tokens[1]
		if (name == "{")
			FAIL("Cannot directly create an anonymous union.")
		position := 2
		c.union_parser(name, tokens, position)
	}

	union___(command)
	{
		tokens := c.preprocess_macroReplace___(new tokelex("c tokenizer", tokelex.KEEP_NEWLINE).string(command))
		name := tokens[1]
		if (name == "{")
			FAIL("Cannot directly create an anonymous union.")
		position := 2
		c.union_parser___(name, tokens, position)
	}

	union____(command)
	{
		tokens := c.preprocess_macroReplace____(new tokelex("c lexer", tokelex.KEEP_NEWLINE).string(command))
		name := tokens[1].string
		if (name == "{")
			FAIL("Cannot directly create an anonymous union.")
		position := 2
		c.union_parser____(name, tokens, position)
	}

	union__(command)
	{
		lexer_ := new c.lexer(new stringLineReader(command))
		name := lexer_.get().value
		if (name == "{")
			FAIL("Cannot directly create an anonymous union.")
		lexer_.t_pos := 2
		c.union_parser__(name, lexer_)
	}

	;; add a define to the set of defines
	define(command)
	{
		tokens := c.preprocess_macroReplace(c.tokenizer(command, c.operatorsWithLF, c.whitespaceSansLF))
		position := 1
		while position <= tokens.MaxIndex() and tokens[position] != "`n"
		{
			token := tokens[position++]
			if(token != "`n")
			{
				name := token
				replace := []
				while position <= tokens.MaxIndex() and tokens[position] != "`n"
				{
					replace.Insert(tokens[position++])
				}
				c.defines[name] := replace
			}
		}
	}

	;; add a define to the set of defines
	define___(command)
	{
		tokens := c.preprocess_macroReplace___(new tokelex("c tokenizer", tokelex.KEEP_WHITESPACE | tokelex.COLLAPSE_H_WHITESPACE).string(command))
		position := 1
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position)) and !instr("`r`n", substr(tokens[position], 1, 1))
		{
			token := tokens[position++]
			if (!instr("`r`n", substr(token, 1, 1)))
			{
				name := token
				replace := []
				while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position)) and !instr("`r`n", substr(tokens[position], 1, 1))
				{
					replace.Insert(tokens[position++])
				}
				c.defines[name] := replace
			}
		}
	}

	;; add a define to the set of defines
	define____(command)
	{
		tokens := c.preprocess_macroReplace____(new tokelex("c lexer", tokelex.KEEP_WHITESPACE | tokelex.COLLAPSE_H_WHITESPACE).string(command))
		position := 1
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position)) and !tokens[position, 11]
		{
			token := tokens[position++]
			if(!token[11])
			{ ; do nothing
			}
			else
			{
				name := token
				replace := []
				while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position)) and !tokens[position, 11]
				{
					replace.Insert(tokens[position++])
				}
				c.defines[name] := replace
			}
		}
	}

	;; add a define to the set of defines
	define__(command)
	{
		lexer_ := new c.lexer(new stringLineReader("#define " command))
		while (lexer_.hasMoreTokens())
		{
			++lexer_.t_pos
		}
	}
	
	static TOKENIZER_RE_ := "SxmP`a)
	(
			(?:(?:[lL](?!"")|[a-km-zA-KM-Z_])[a-zA-Z_0-9]*) # WORD
		|	(?:[ \t]+) # WHITESPACE
		|	(?:==?|\+[+=]?|-[-=]?|&[&=]?|\|[|=]?|\*=?|/(?![/*])=?|\^=?|!=?|<=?|>=?|`%=?|\.(?![0-9])|\#\#?|[(){}\[\],?:;]) # OPERATORS
		|	(?:\\$(?:\r\n?|\n\r?)?) # QUOTED NEWLINE
		|	(?://.*$) # COMMENT LINE
		|	(?:/\*(?:\r\n?|\n\r?|.)*?\*/) # COMMENT BLOCK
		|	(?:/\*(?:\r\n?|\n\r?|.)*$) # COMMENT BLOCK INCOMPLETE
		|	(?:[lL]?""(?:\\""|\\(?:\r\n?|\n\r?)|.)*?"") # STRING LITERAL
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
	, TOKENIZER_RE := (removeCommentsAndWhitespaceFromRegEx(c.TOKENIZER_RE_), tokelex.Register("c tokenizer", removeCommentsAndWhitespaceFromRegEx(c.TOKENIZER_RE_), { whitespaceId: 2, newlineId: 11 
		, remapTokenString: { "`r": "`n", "`r`n": "`n" } } ))
	static LEXER_RE_ := "SxmP`a)
	(
			((?:[lL](?!"")|[a-km-zA-KM-Z_])[a-zA-Z_0-9]*) # WORD
		|	([ \t]+) # WHITESPACE
		|	(==?|\+[+=]?|-[-=]?|&[&=]?|\|[|=]?|\*=?|/(?![/*])=?|\^=?|!=?|<=?|>=?|`%=?|\.(?![0-9])|\#\#?|[(){}\[\],?:;]) # OPERATORS
		|	(\\$(?:\r\n?|\n\r?)?) # QUOTED NEWLINE
		|	(//.*$) # COMMENT LINE
		|	(/\*(?:\r\n?|\n\r?|.)*?\*/) # COMMENT BLOCK
		|	(/\*(?:\r\n?|\n\r?|.)*$) # COMMENT BLOCK INCOMPLETE
		|	([lL]?""(?:\\""|\\(?:\r\n?|\n\r?)|.)*?"") # STRING LITERAL
		| 	( # some parts here are duplicated to prevent backtracking.
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
		|	('(?:\\'|.)+') # CHARACTER LITERAL
		|	(\r\n?|\n\r?) # NEW LINE
	)"
	, LEXER_RE := (removeCommentsAndWhitespaceFromRegEx(c.LEXER_RE_), tokelex.Register("c lexer", removeCommentsAndWhitespaceFromRegEx(c.LEXER_RE_), { whitespaceId: 2, newlineId: 11
		, remapTokenString: { struct: { isStruct: 1 }
			, union: { isUnion: 1 }
			, "{": { isOpenBrace: 1 } 
			, "}": { isCloseBrace: 1 }
			, "[": { isOpenBracket: 1 }
			, "]": { isCloseBracket: 1 }
			, "*": { isAstrix: 1 }
			, ",": { isComma: 1, isCommaOrSemicolon: 1 }
			, ";": { isSemicolon: 1, isCommaOrSemicolon: 1 }
			, "`r" : { isNewline: 1 }
			, "`r`n" : { isNewline: 1 }
			, "`n" : { isNewline: 1 }
			, typedef: { isTypedef: 1 } } } ))

	sizeof(typeNameOrObject)
	{
		if (object_getBaseAddress(typeNameOrObject) = &c.object)
			return typeNameOrObject[" size"]
		else if (IsObject(type := c.types[typeNameOrObject]))
			return type[" size"]
		else if (IsFunc(typeNameOrObject))
			FAIL("Can only call c.sizeof() on an already defined type or an allocated c.object.  Was passed a Func object pointing at '" typeNameOrObject[" name"] "'.")
		else if (IsObject(typeNameOrObject))
			FAIL("Can only call c.sizeof() on an already defined type or an allocated c.object.  Was passed an object of class '" object_getBase(typeNameOrObject).__Class "'.")
		else
			FAIL("Unknown type name '" typeNameOrObject "'.")
	}
	
	static ALLOCATE := 0
	, ASSIGN_ADDRESS := 1
	, ASSIGN_VALUE := 2
	, MIN_ALLOC := 3 ; TBD: for later to allow allocating extra space for those structs that end in an array of 0 elements.

	static parseType__ := c.parseType___DebugCode

	;; C Object that is passed around
	class object extends checkCallNameExists
	{
		static __Get := c.object.__Get_DebugCode
			, __Set := c.object.__Set_DebugCode
			, Get := c.object.Get_DebugCode
			, Set := c.object.Set_DebugCode

		; If a pointer is passed, then point at that instead of allocating new space.
		__New(typeName, operation = 0, byref value = 0)
		{
			if(!c.types.hasKey(typeName))
				FAIL("Type name '" typeName "' is not a defined c type.")
			this.init(c.types[typeName], operation, value)
		}
		
		init(type, operation, byref value)
		{
			sizeofType := type[" size"]
			ObjInsert(this, " type", type) ? 0 : FAIL("Out of memory")
			ObjInsert(this, " size", type[" size"]) ? 0 : FAIL("Out of memory")

			if (IsObject(operation))
			{
				value := operation
				operation := C.ASSIGN_VALUE
			}
			if (operation = C.ASSIGN_ADDRESS)
				if value is Integer
						ObjInsert(this, " address", value) ? 0 : FAIL("Out of memory")
					else
						FAIL("Address must be an integer, not '" value "'.")
			else
			{
				if ("" == ObjSetCapacity(this, " binary", sizeofType))
					FAIL("Didn't set the capacity of element binary")
				address := ObjGetAddress(this, " binary")
				ObjInsert(this, " address", address) ? 0 : FAIL("Out of memory")
				
				memset(address, 0, sizeofType) ; setting elements of object to zero
				if (operation = C.ASSIGN_VALUE)
					this._assign(type, address, value)
			}
		}
		
		IsOwner()
		{
			return this.hasKey(" binary")
		}
		
		_retrive(type, address)
		{
			c.ndebug ? 0 : c.debug("_retrive(" object_elementList(type, "type") ", " hex(address, 8) ")")
			type := type[" simplestType"]
			if (type[" isBaseType"])
				if (type[" name"] = "Str")
					return StrGet(NumGet(address+0))
				else
					return NumGet(address+0, 0, type[" name"])
			else
				return c.object._tmp(type, address)
		}

		Get_DebugCode()
		{
			type := this[" type"]
			if (type[" simplestType", " isBaseType"])
				return c.object._retrive(type, this[" address"])
			else
				FAIL("No reason to Get() from a non-base type.")
		}

		Get_ReleaseCode()
		{
			; excluding test to see if this is a base typed element.  Assumed this has been tested for in Debug mode previously.
			type := this[" type", " simplestType"]
			if (type[" name"] = "Str")
				return StrGet(NumGet(this[" address"])+0)
			else
				return NumGet(this[" address"]+0, 0, type[" name"])
		}
		
		__Get_DebugCode(key="", p*)
		{
			if (p.MaxIndex())
				return this[key][p.1]

			address := this[" address"]
			
			c.ndebug ? 0 : c.debug("GET: " hex(address, 8))
			
			if (key == "")
				return address
			
			type := this[" type", " simplestType"]

			if (type[" isComplex"])
				if (IsObject(elementType := type[key]))
				{
					return c.object._retrive(elementType, address + elementType[" offset"])
				}
				else
					FAIL("Attempt to access member <value> which doesn't exist for type '" type.description() "'." object_elementList(key, "value", OBJECT_SHOW.DEFAULT, "`n  "))
			else if (type[" arraySize"])
				if key is integer
					if (0 < key and key <= type[" arraySize"])
					{
						return  c.object._retrive(type[" type"], address + (key-1) * type[" type", " size"])
					}
					else
						FAIL("Attempt to access element " key " when array has " type[" arraySize"] " elements.")
				else
					FAIL("Attempt to access element <value> when the C language doesn't have associative arrays." object_elementList(key, "value", OBJECT_SHOW.DEFAULT, "`n  "))
			else ;; should be a base type from here out
			{
				c.object._retrive(type, address)
			}
		}

		__Get_ReleaseCode(key="", p*)
		{
			if (p.MaxIndex())
				return this[key][p.1]

			address := this[" address"]
			
			;c.ndebug ? 0 : c.debug("GET: " hex(address, 8))
			
			if (key == "")
				return address
			
			type := this[" type", " simplestType"]

			if (type[" isComplex"])
				if (IsObject(elementType := type[key]))
				{
					;return c.object._retrive(elementType, address + elementType[" offset"])
					;_retrive(type, address)
					{
						;	c.ndebug ? 0 : c.debug("_retrive(" object_elementList(type, "type") ", " hex(address, 8) ")")
						;type := elementType
						;address := address + elementType[" offset"]
						type := elementType[" simplestType"]
						return (type[" isBaseType"])
							? (type[" name"] = "Str")
								? StrGet(NumGet(address + elementType[" offset"]))
								: NumGet(address + elementType[" offset"], 0, type[" name"])
							: { " type": type, " address": address + elementType[" offset"], base: c.object }

						if (type[" isBaseType"])
							if (type[" name"] = "Str")
								return StrGet(NumGet(address + elementType[" offset"]))
							else
								return NumGet(address + elementType[" offset"], 0, type[" name"])
						else
							return { " type": type, " address": address + elementType[" offset"], base: c.object }
					}
				}
				else
					FAIL("Attempt to access member <value> which doesn't exist for type '" type.description() "'." object_elementList(key, "value", OBJECT_SHOW.DEFAULT, "`n  "))
			else if (type[" arraySize"])
				if key is integer
					if (0 < key and key <= type[" arraySize"])
					{
						;return  c.object._retrive(type[" type"], address + (key-1) * type[" type", " size"])
						;_retrive(type, address)
						{
						;	c.ndebug ? 0 : c.debug("_retrive(" object_elementList(type, "type") ", " hex(address, 8) ")")
							;type := type[" type"]
							type := type[" type", " simplestType"]
							
							return (type[" isBaseType"])
								? (type[" name"] = "Str")
									? StrGet(address + (key-1) * type[" size"])
									: NumGet(address + (key-1) * type[" size"], 0, type[" name"])
								: { " type": type, " address": address + (key-1) * type[" size"], base: c.object }
							
							
							if (type[" isBaseType"])
								if (type[" name"] = "Str")
									return StrGet(address + (key-1) * type[" size"])
								else
									return NumGet(address + (key-1) * type[" size"], 0, type[" name"])
							else
								return { " type": type, " address": address + (key-1) * type[" size"], base: c.object }
							
						}
					}
					else
						FAIL("Attempt to access element " key " when array has " type[" arraySize"] " elements.")
				else
					FAIL("Attempt to access element <value> when the C language doesn't have associative arrays." object_elementList(key, "value", OBJECT_SHOW.DEFAULT, "`n  "))
			else ;; should be a base type from here out
			{
				;c.object._retrive(type, address)
				;_retrive(type, address)
				{
				;	c.ndebug ? 0 : c.debug("_retrive(" object_elementList(type, "type") ", " hex(address, 8) ")")
					type := type[" simplestType"]
					return (type[" isBaseType"])
						? (type[" name"] = "Str")
							? StrGet(NumGet(address+0))
							: NumGet(address+0, 0, type[" name"])
						: { " type": type, " address": address, base: c.object }

					if (type[" isBaseType"])
						if (type[" name"] = "Str")
							return StrGet(NumGet(address+0))
						else
							return NumGet(address+0, 0, type[" name"])
					else
						return c.object._tmp(type, address)
				}
			}
		}

		_assign(_type_, address, value)
		{
			c.ndebug ? 0 : c.debug("_assign (" object_elementList(_type_, "type") ", " hex(address, 8) ", " (object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  ")) ")")
			if address is not integer
				FAIL("Address must be an integer, found '" address "' instead.")
			if (0 == address)
				FAIL("Cannot assign anything through a NULL pointer")
			_type := _type_
			_type_ := _type_[" simplestType"]
			if (_type_[" isBaseType"])
				if (_type_[" name"] = "Str")
					if (IsObject(value))
						FAIL("Attempt to put non number <value> into a number field '" _type.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
					else 
						return StrPut(value, NumGet(address+0))
				else if value is number
					return NumPut(value, address+0, 0, _type_[" name"])
				else
					FAIL("Attempt to put non number <value> into a number field '" _type.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
			else if (IsObject(value))
				if (object_getBaseAddress(value) == &c.object)
					if (_type_ == value[" type", " simplestType"])
					{
						srcAddress := value[" address"]
						if (srcAddress != 0)
							memcpy(address, srcAddress, _type_[" size"])
						else
							FAIL("Attempt to copy from NULL address.")
					}
					else
						FAIL("Cannot copy data from type " value[" type", " simplestType"].description() " to type " _type_[" type"].description() " as they are different types.")
				else
				{
					tmp := c.object._tmp(_type_, address)
					for key, val in value
						tmp[key] := val
				}
			else
				FAIL("Cannot assign <value> to object of type '" _type.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
			return this
		}

		Set_DebugCode(value)
		{
			return c.object._assign(this[" type"], this[" address"], value)
		}

		Set_ReleaseCode(value)
		{
			;_assign(_type_, address, value)
			{
			;	c.ndebug ? 0 : c.debug("_assign (" object_elementList(_type_, "type") ", " hex(address, 8) ", " (object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  ")) ")")
			;	if address is not integer
			;		FAIL("Address must be an integer, found '" address "' instead.")
				if (0 == address := this[" address"])
					FAIL("Cannot assign anything through a NULL pointer")
				_type_ := this[" type", " simplestType"]
				if (_type_[" isBaseType"])
					if (_type_[" name"] = "Str")
						if (IsObject(value))
							FAIL("Attempt to put non number <value> into a number field '" this[" type"].description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
						else 
							return StrPut(value, NumGet(address+0))
					else if value is number
						return NumPut(value, address+0, 0, _type_[" name"])
					else
						FAIL("Attempt to put non number <value> into a number field '" this[" type"].description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
				else if (IsObject(value))
					if (object_getBaseAddress(value) == &c.object)
						if (_type_ == value[" type", " simplestType"])
						{
							srcAddress := value[" address"]
							if (srcAddress != 0)
								memcpy(address, srcAddress, _type_[" size"])
							else
								FAIL("Attempt to copy from NULL address.")
						}
						else
							FAIL("Cannot copy data from type " value[" type", " simplestType"].description() " to type " _type_[" type"].description() " as they are different types.")
					else
					{
						;tmp := c.object._tmp(_type_, address)
						tmp := { " type": _type_, " address": address, base: c.object }
						for key, val in value
							tmp[key] := val
					}
				else
					FAIL("Cannot assign <value> to object of type '" this[" type"].description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
				return this
			}
		}

		__Set_DebugCode(key, value, values*)
		{
			if (values.MaxIndex()) ; Handle "a.b[c] := d" as "a.b.c := d"
				return this[key][value] := values.1
			c.ndebug ? 0 : c.debug("SET: " hex(address, 8) " := " value)
			if (key == "") ; set address
			{
				if value is integer
				{
					this.Remove(" binary")
					return this[" address"] := value
				}
				else
					FAIL("An address must be a integer, not '" value "'.")
			}
			else
			{
				type := this[" type", " simplestType"]
				if (0 == address := this[" address"])
					FAIL("Cannot assign anything through a NULL pointer")
				if (type[" isComplex"])
					if (IsObject(elementType := type[key]))
						return c.object._assign(elementType, address + elementType[" offset"], value)
					else
						FAIL("Attempt to access member <value> which doesn't exist for type '" type.description() "'." object_elementList(key, "value", OBJECT_SHOW.DEFAULT, "`n  "))
				else if (type[" arraySize"])
					if key is integer
						if (0 < key and key <= type[" arraySize"])
							return c.object._assign(type[" type"], address + (key-1) * type[" type", " size"], value)
						else
							FAIL("Attempt to write to element " key " when array has " type[" arraySize"] " elements.")
					else
						FAIL("Attempt to access element <value> when the C language doesn't have associative arrays." object_elementList(key, "value", OBJECT_SHOW.DEFAULT, "`n  "))
				else ;; should be a base type from here out
					return c.object._assign(type, address, value)
			}
		}

		__Set_ReleaseCode(key, value, values*)
		{
			if (values.MaxIndex()) ; Handle "a.b[c] := d" as "a.b.c := d"
				return this[key][value] := values.1
;			c.ndebug ? 0 : c.debug("SET: " hex(address, 8) " := " value)
			if (key == "") ; set address
			{
				if value is integer
				{
					this.Remove(" binary")
					return this[" address"] := value
				}
				else
					FAIL("An address must be a integer, not '" value "'.")
			}
			else
			{
				type := this[" type", " simplestType"]
				if (0 == address := this[" address"])
					FAIL("Cannot assign anything through a NULL pointer")
				
				if (type[" isComplex"])
					if (IsObject(elementType := type[key]))
					{
						;return c.object._assign(elementType, address + elementType[" offset"], value)
						;_assign(_type_, address, value)
						{
							;c.ndebug ? 0 : c.debug("_assign (" object_elementList(_type_, "type") ", " hex(address, 8) ", " (object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  ")) ")")
							;if address is not integer
							;	FAIL("Address must be an integer, found '" address "' instead.")
							;if (0 == address)
							;	FAIL("Cannot assign anything through a NULL pointer")
							
							;; NEW VERSION ;;
							_type_ := elementType[" simplestType"]
							if (_type_[" isBaseType"])
								if (_type_[" name"] = "Str")
									if (IsObject(value))
										FAIL("Attempt to put non number <value> into a number field '" elementType.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
									else 
										return StrPut(value, NumGet(address + elementType[" offset"]))
								else if value is number
									return NumPut(value, address + elementType[" offset"], 0, _type_[" name"])
								else
									FAIL("Attempt to put non number <value> into a number field '" elementType.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
							else if (IsObject(value))
								if (object_getBaseAddress(value) == &c.object)
									if (_type_ == value[" type", " simplestType"])
									{
										if (0 != srcAddress := value[" address"])
										{
											tmp := { " type": _type_, " address": dstAddress := address + elementType[" offset"], base: c.object }
											memcpy(dstAddress, srcAddress, _type_[" size"])
											return tmp
										}
										else
											FAIL("Attempt to copy from NULL address.")
									}
									else
										FAIL("Cannot copy data from type " value[" type", " simplestType"].description() " to type " _type_[" type"].description() " as they are different types.")
								else
								{
									;tmp := c.object._tmp(_type_, address + elementType[" offset"])
									tmp := { " type": _type_, " address": address + elementType[" offset"], base: c.object }
									for key, val in value
										tmp[key] := val
									return tmp
								}
							else
								FAIL("Cannot assign <value> to object of type '" elementType.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
							return this

							;; OLD VERSION ;;
							_type_ := elementType[" simplestType"]
							if (_type_[" isBaseType"])
								if (_type_[" name"] = "Str")
									if (IsObject(value))
										FAIL("Attempt to put non number <value> into a number field '" elementType.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
									else 
										return StrPut(value, NumGet(address + elementType[" offset"]))
								else if value is number
									return NumPut(value, address + elementType[" offset"], 0, _type_[" name"])
								else
									FAIL("Attempt to put non number <value> into a number field '" elementType.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
							else if (IsObject(value))
								if (object_getBaseAddress(value) == &c.object)
									if (_type_ == value[" type", " simplestType"])
									{
										srcAddress := value[" address"]
										if (srcAddress != 0)
											memcpy(address + elementType[" offset"], srcAddress, _type_[" size"])
										else
											FAIL("Attempt to copy from NULL address.")
									}
									else
										FAIL("Cannot copy data from type " value[" type", " simplestType"].description() " to type " _type_[" type"].description() " as they are different types.")
								else
								{
									;tmp := c.object._tmp(_type_, address + elementType[" offset"])
									tmp := { " type": _type_, " address": address + elementType[" offset"], base: c.object }
									for key, val in value
										tmp[key] := val
								}
							else
								FAIL("Cannot assign <value> to object of type '" elementType.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
							return this
}
					}
					else
						FAIL("Attempt to access member <value> which doesn't exist for type '" type.description() "'." object_elementList(key, "value", OBJECT_SHOW.DEFAULT, "`n  "))
				else if (type[" arraySize"])
					if key is integer
						if (0 < key and key <= type[" arraySize"])
						{
							;return c.object._assign(type[" type"], address + (key-1) * type[" type", " size"], value)
							;_assign(_type_, address, value)
							{
							;	c.ndebug ? 0 : c.debug("_assign (" object_elementList(_type_, "type") ", " hex(address, 8) ", " (object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  ")) ")")
							;	if address is not integer
							;		FAIL("Address must be an integer, found '" address "' instead.")
							;	if (0 == address)
							;		FAIL("Cannot assign anything through a NULL pointer")
								_type_ := type[" type", " simplestType"]
								if (_type_[" isBaseType"])
									if (_type_[" name"] = "Str")
										if (IsObject(value))
											FAIL("Attempt to put non number <value> into a number field '" type.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
										else 
											return StrPut(value, NumGet(address + (key-1) * type[" type", " size"]))
									else if value is number
										return NumPut(value, address + (key-1) * type[" type", " size"], 0, _type_[" name"])
									else
										FAIL("Attempt to put non number <value> into a number field '" type.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
								else if (IsObject(value))
									if (object_getBaseAddress(value) == &c.object)
										if (_type_ == value[" type", " simplestType"])
										{
											srcAddress := value[" address"]
											if (srcAddress != 0)
												memcpy(address + (key-1) * type[" type", " size"], srcAddress, _type_[" size"])
											else
												FAIL("Attempt to copy from NULL address.")
										}
										else
											FAIL("Cannot copy data from type " value[" type", " simplestType"].description() " to type " _type_[" type"].description() " as they are different types.")
									else
									{
										;tmp := c.object._tmp(_type_, address + (key-1) * type[" type", " size"])
										tmp := { " type": _type_, " address": address + (key-1) * type[" type", " size"], base: c.object }
										for key, val in value
											tmp[key] := val
									}
								else
									FAIL("Cannot assign <value> to object of type '" type.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
								return this
							}
						}
						else
							FAIL("Attempt to write to element " key " when array has " type[" arraySize"] " elements.")
					else
						FAIL("Attempt to access element <value> when the C language doesn't have associative arrays." object_elementList(key, "value", OBJECT_SHOW.DEFAULT, "`n  "))
				else ;; should be a base type from here out
				{
					;return c.object._assign(type, address, value)
					;_assign(_type_, address, value)
					{
					;	c.ndebug ? 0 : c.debug("_assign (" object_elementList(_type_, "type") ", " hex(address, 8) ", " (object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  ")) ")")
					;	if address is not integer
					;		FAIL("Address must be an integer, found '" address "' instead.")
					;	if (0 == address)
					;		FAIL("Cannot assign anything through a NULL pointer")
						_type_ := type[" simplestType"]
						if (_type_[" isBaseType"])
							if (_type_[" name"] = "Str")
								if (IsObject(value))
									FAIL("Attempt to put non number <value> into a number field '" type.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
								else 
									return StrPut(value, NumGet(address+0))
							else if value is number
								return NumPut(value, address+0, 0, _type_[" name"])
							else
								FAIL("Attempt to put non number <value> into a number field '" type.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
						else if (IsObject(value))
							if (object_getBaseAddress(value) == &c.object)
								if (_type_ == value[" type", " simplestType"])
								{
									srcAddress := value[" address"]
									if (srcAddress != 0)
										memcpy(address, srcAddress, _type_[" size"])
									else
										FAIL("Attempt to copy from NULL address.")
								}
								else
									FAIL("Cannot copy data from type " value[" type", " simplestType"].description() " to type " _type_[" type"].description() " as they are different types.")
							else
							{
								;tmp := c.object._tmp(_type_, address)
								tmp := { " type": _type_, " address": address, base: c.object }
								for key, val in value
									tmp[key] := val
							}
						else
							FAIL("Cannot assign <value> to object of type '" type.description() "'." object_elementList(value, "value", OBJECT_SHOW.DEFAULT, "`n  "))
						return this
					}
				}
			}
		}
		
		; Allow for iterating over object's elements.
		; Simple element that has no sub components (i.e. not an array
		; structure or union) will return a key of "" (empty string)
		_NewEnum()
		{
			if (this == c.object)
				return
				
			return new c.object.enum(this)
		}
		
		class enum
		{
			current := 0
			__new(obj, p*)
			{
				this["obj"] := obj
			}
			
			next(ByRef key, ByRef val)
			{
				type := this["obj", " type"]
				obj := this["obj"]
				if ("" ==  MaxIndex := type.MaxIndex())
					if (0 < arraySize := type[" arraySize"])
					{
						; deling with array
						if (++this.current <= arraySize)
						{
							key := this.current
							val := obj[key]
							return 1
						}
						else
							return 0
					}
					else if (this.current++)
						; dealig with base type for the second time
						return 0
					else
					{
						; dealing with base type for the first time
						val := this["obj"]
						, key := ""
						return 1
					}
				else if (++this.current <= MaxIndex)
				{
					; dealing with structure
					key := type[this.current, " name"]
					val := obj[key]
					return 1
				}
				else
					return 0
			}
		}

		elementList(name, indent="`n")
		{
			type := this[" type"]
			simplestType := type[" simplestType"]
			if (name != "")
				output := indent name "="
			
			indent .= " "
			if (simplestType[" arraySize"])
			{
				output .= type.description()
				arrayOfBaseTypes := simplestType[" type", " simplestType", " isBaseType"]
				loop % simplestType[" arraySize"]
				{
					output .= indent "[" A_Index "] = "
					if (arrayOfBaseTypes)
					{
						value := this[A_Index]
						if (IsObject(value))
							FAIL("Type should be a '" type.description() "', but found <object> instead:" object_elementList(value, "object"))
						if value is number ; don't put single quotes around numbers, and if address, make it a hex number
							output .= type.hasKey(" indirectionCount") ? hex(value, c.ptrSize * 2) : value
						else ; put single quotes around strings
							output .= "'" value "'"
					}
					else
					{
						value := this[A_Index]
						if (!IsObject(value))
							FAIL("Type should be a '" type.description() "', but found a simple object instead: '" value "'")
						output .= value.elementList("", indent)
					}
				}
			}
			else if (simplestType[" isComplex"])
			{
				if (simplestType[" isStruct"])
					output .= "STRUCT " type.description()
				else
					output .= "UNION " type.description()
				loop % simplestType.MaxIndex()
				{
					output .= indent "." simplestType[A_Index, " name"] " = "
					if (simplestType[A_Index, " simplestType", " isBaseType"])
					{
						value := this[simplestType[A_Index, " name"]]
						if (IsObject(value))
							FAIL("Type should be a '" type.description() "', but found an object instead:" object_elementList(value, 0, "object", "`n  "))
						if value is number ; don't put single quotes around numbers, and if address, make it a hex number
							output .= type.hasKey(" indirectionCount") ? hex(value, c.ptrSize * 2) " (" type.description() ")" : value
						else ; put single quotes around strings
							output .= "'" value "'"
					}
					else
					{
						value := this[simplestType[A_Index, " name"]]
						if (!IsObject(value))
							FAIL("Type should be a '" type.description() "', but found a simple object instead: '" value "'")
						output .= value.elementList("", indent)
					}
				}
			}
			else if (simplestType[" indirectionCount"])
			{
				output .= hex(value, c.ptrSize * 2) " (" type.description() ")"
			}
			else if (simplestType[" isBaseType"])
				output .= this.Get()
			else
				FAIL("Found type '" type[" name"] "' which is not a base type.")
			return output
		}
		
		_tmp(type, address)
		{
			if (!IsObject(type))
				FAIL("Type is not a type object.")
			if address is not number
				FAIL("Address needs to be a number.")
			return { " type": type, " address": address, base: c.object }
		}

		; potential to reuse objects.  May not be worth it.
		_del()
		{
			this.recycle.Insert(this)
		}
		
		; potential to reuse objects.  May not be worth it.
		__tmp(type, address)
		{
			if (this.recycle.MaxIndex() = "")
			{
				tmpObj := { (" "): { " type": type, address: address }, base: c.object }
				tmpObj.base.__Delete := this.__del
			}
			else
			{
				index := this.recycle.MaxIndex()
				tmpObj := this.recycle[index]
				this.recycle.Remove(index)
				tmpObj[" type"] := Type
				tmpObj.address := address
			}
			return  tmpObj
		}
	}

	class objectArray extends c.object
	{
		__New(typeName, arraySize, operation = 0, byref value = 0)
		{
			if(!c.types.hasKey(typeName))
				FAIL("Type name '" typeName "' is not a defined c type.")
			
			type := new c.type(c.types[typeName])
			type[" arraySize"] := arraySize
			type[" size"] := arraySize * type[" type", " size"]
			type[" simplestType"] := type
			type[" name"] := c.newName(type[" type", " name"] " array")
			this.init(type, operation, value)
		}
		
		__Delete()
		{
			this[" type"].__Delete() ; must call destructor explicitly to ensure recursive references are broken
		}
	}

	class objectPointer extends c.object
	{
		__New(typeName, indirectionCount, operation = 0, byref value = 0)
		{
			if(!c.types.hasKey(typeName))
				FAIL("Type name '" typeName "' is not a defined c type.")
			
			type := new c.type(c.types[typeName], 0)
			type[" indirectionCount"] := indirectionCount
			type[" size"] := c.ptrSize
			type[" simplestType"] := type
			type[" name"] := c.newName(type[" type", " name"] " pointer")
			this.init(type, operation, value)
		}
		
		__Delete()
		{
			this[" type"].__Delete() ; must call destructor explicitly to ensure recursive references are broken
		}
	}

	class objectArrayOfPointers extends c.object
	{
		__New(typeName, indirectionCount, arraySize, operation = 0, byref value = 0)
		{
			if(!c.types.hasKey(typeName))
				FAIL("Type name '" typeName "' is not a defined c type.")
			
			type := new c.type(c.types[typeName], 0)
			type[" indirectionCount"] := indirectionCount
			type[" arraySize"] := arraySize
			type[" size"] := arraySize * c.ptrSize
			type[" simplestType"] := type
			type[" name"] := c.newName(type[" type", " name"] " pointer array")
			this.init(type, operation, value)
		}
		
		__Delete()
		{
			this[" type"].__Delete() ; must call destructor explicitly to ensure recursive references are broken
		}
	}

	use(type)
	{
		static fnsList = { (c): [ "parseType__" ], (c.object): [ "Get", "Set", "__Set", "__Get" ] }
		; This ensures that the code starts up in release mode.
		static _ := c.use("ReleaseCode")
		
		OutputDebug("C interface library using " type ".")
		for object, fnList in fnsList
			for index, fn in fnList
				if (IsFunc(object[newFn := fn "_" type]))
					object[fn] := object[newFn]
				else
					OutputDebug("No function named '" object.class "." newFn "'.  Leaving '" object.class "." fn "' pointing at '" object[fn, "name"] "'.")
		return 0
	}
	
	;; Simple preprocessor.  Doesn't currently handle macros with parameters
	preprocess_macroReplace(tokens)
	{
		index := 1
		while index <= tokens.MaxIndex()
		{
			token := tokens[index]
			if(StrLen(token) != 1 and !InStr(c.operators, token)) ; is token not an operator?
			{
				if (c.defines.hasKey(token)) ; is there something to replace?
				{
					replace := c.defines[token]
					tokens.Remove(index)
					tokens.Insert(index, replace*)
					continue
				}
			}
			++index
		}
		return tokens
	}
	
	;; Simple preprocessor.  Doesn't currently handle macros with parameters
	preprocess_macroReplace___(tokens)
	{
		index := 1
		while index <= tokens.MaxIndex() or tokens.tokenAvailable(index) ; doing a test to see if the index < MaxIndex() and if not then testing to see if the token can be made available is much faster.
		{
			if ("" == token := tokens[index])
			{
				tokens.Remove(index)
				continue
			}
			else if (token == "`n")
			{
				tokens.Remove(index)
				continue
			}
			else if (c.defines.hasKey(token)) ; is there something to replace?
			{
				replace := c.defines[token]
				tokens.Remove(index)
				tokens.Insert(index, replace*)
				continue
			}
			++index
		}
		return tokens
	}
	
	;; Simple preprocessor.  Doesn't currently handle macros with parameters
	preprocess_macroReplace____(tokens)
	{
		index := 1
		while index <= tokens.MaxIndex() or tokens.tokenAvailable(index)
		{
			if ((token := tokens[index])[2])
			{
				tokens.Remove(index)
				continue
			}
			else if (token[11])
			{
				tokens.Remove(index)
				continue
			}
			else if (c.defines.hasKey(token.string)) ; is there something to replace?
			{
				replace := c.defines[token.string]
				tokens.Remove(index)
				tokens.Insert(index, replace*)
				continue
			}
			++index
		}
		return tokens
	}
	
	;; Used to generate an anonymous name for types
	newName(type)
	{
		static counter := {}
		if (!counter.hasKey(type))
			counter[type] := 0
			
		return "anonymous " type " " counter[type]++
	}
	
	; struct {...
	; struct x {...
	; struct x y...
	
	;; Parse a type and return that type object.  Handles embedded structs and unions
	parseType(tokens, byref position)
	{
		if (tokens[position] == "struct")
		{
			if ("{" == token := tokens[++position])
			{
				; anonymous struct
				return c.struct_parser(c.newName("struct"), tokens, position)
			}
			else if (c.isTypeDefined(token.value))
			{
				; type
				return c.getType(tokens[position++])
			}
			else if ("{" == token := tokens[++position])
			{
				; named struct
				return c.struct_parser(tokens[position-1], tokens, position) ; skeptical about this parse, name seems to be set to "{"
			}
			else
				FAIL("Invalid token.  Expected '{' or '<struct typename>' '{' after 'struct' keyword.")
		}
		else if (tokens[position] == "union")
		{
			if ("{" == token := tokens[++position])
			{
				return c.union_parser(c.newName("union"), tokens, position)
			}
			else if (c.isTypeDefined(token))
			{
				return c.getType(tokens[position++])
			}
			else if (tokens[++position] == "{")
			{
				return c.union_parser(tokens[position-1], tokens, position)
			}
			else
				FAIL("Invalid token.  Expected '{' or '<union typename>' '{' after 'union' keyword.")
		}
		else
		{
			; Currently don't support types with modifiers.  But if I were to do it
			; it would be done here.
			return c.getType(tokens[position++])
		}
		FAIL("Failed to parse tokens at index " position "." object_elementList(tokens, "tokens"))
	}
	
	;; Parse a type and return that type object.  Handles embedded structs and unions
	parseType___(tokens, byref position)
	{
		if ((token := tokens[position]) == "struct")
		{
			if ("{" == token := tokens[++position])
			{
				; anonymous struct
				return c.struct_parser___(c.newName("struct"), tokens, position)
			}
			else if (c.isTypeDefined(token))
			{
				; type
				return c.getType((token, ++position))
			}
			else if ("{" == tokens[++position])
			{
				; named struct
				return c.struct_parser___(token, tokens, position)
			}
			else
				FAIL("Invalid token.  Expected '{' or '<struct typename>' '{' after 'struct' keyword.")
		}
		else if (token == "union")
		{
			if ("{" == token := tokens[++position])
			{
				return c.union_parser___(c.newName("union"), tokens, position)
			}
			else if (c.isTypeDefined(token))
			{
				return c.getType((token, ++position))
			}
			else if ("{" == tokens[++position])
			{
				return c.union_parser___(token, tokens, position)
			}
			else
				FAIL("Invalid token.  Expected '{' or '<union typename>' '{' after 'union' keyword.")
		}
		else
		{
			; Currently don't support types with modifiers.  But if I were to do it
			; it would be done here.
			return c.getType((token, ++position))
		}
		FAIL("Failed to parse tokens at index " position "." object_elementList(tokens, "tokens"))
	}
	
	;; Parse a type and return that type object.  Handles embedded structs and unions
	parseType____(tokens, byref position)
	{
		if ((token := tokens[position]).isStruct)
		{
			if ((token := tokens[++position]).isOpenBrace)
			{
				; anonymous struct
				return c.struct_parser____(c.newName("struct"), tokens, position)
			}
			else if (c.isTypeDefined(token.string))
			{
				; type
				return c.getType((token.string, ++position))
			}
			else if (tokens[++position, "isOpenBrace"])
			{
				; named struct
				return c.struct_parser____(token.string, tokens, position)
			}
			else
				FAIL("Invalid token.  Expected '{' or '<struct typename>' '{' after 'struct' keyword.")
		}
		else if (tokenString == "union")
		{
			if ((token := tokens[++position]).isOpenBrace)
			{
				return c.union_parser____(c.newName("union"), tokens, position)
			}
			else if (c.isTypeDefined(token.string))
			{
				return c.getType((token.string, ++position))
			}
			else if (tokens[++position, "isOpenBrace"])
			{
				return c.union_parser____(token.string, tokens, position)
			}
			else
				FAIL("Invalid token.  Expected '{' or '<union typename>' '{' after 'union' keyword.")
		}
		else
		{
			; Currently don't support types with modifiers.  But if I were to do it
			; it would be done here.
			return c.getType((token.string, ++position))
		}
		FAIL("Failed to parse tokens at index " position "." object_elementList(tokens, "tokens"))
	}
	
	;; Parse a type and return that type object.  Handles embedded structs and unions
	parseType___DebugCode(lexer)
	{
		if ("struct" == (tokenValue := (token := lexer.get()).value))
		{
			if ((token := lexer.incGet()) == "{")
			{
				; annonymous struct
				return c.struct_parser__(c.newName("struct"), lexer)
			}
			else if (c.isTypeDefined(token.value))
			{
				; already defined struct
				return c.getType(lexer.getInc().value)
			}
			else if (lexer.incGet() == "{")
			{
				; named struct
				return c.struct_parser__(token.value, lexer)
			}
			else
				FAIL("Invalid token.  Expected '{' or '<struct typename>' '{' after 'struct' keyword, from " this.currentParseFrom.diagnositicInfo())
		}
		else if (tokenValue == "union")
		{
			if ((tokenValue := lexer.incGet()) == "{")
			{
				; anonymous union
				return c.union_parser__(c.newName("union"), lexer)
			}
			else if (c.isTypeDefined(token.alue))
			{
				; already defined union
				return c.getType(lexer.getInc().value) ; should increment t_pos and use tokenValue
			}
			else if (lexer.incGet() == "{")
			{
				; named union
				return c.union_parser__(token.value, lexer) ; think lexer.getPrev().value should be replaced by tokenValue
			}
			else
				FAIL("Invalid token.  Expected '{' or '<union typename>' '{' after 'union' keyword, from " this.currentParseFrom.diagnositicInfo())
		}
		else
		{
			; Currently don't support types with modifiers.  But if I were to do it
			; it would be done here.
			return c.getType(lexer.getInc().value) ;tokens[position++])
		}
	}

    /*
	if (a)
		b
	else if (c)
		d
	else
		e
	
	a 
		? b
	: c
		? d
	: e
	
	if (a)
		if (b)
			c
		else if (d)
			e
		else
			f
	else if (g)
		if (h)
			i
		else if (j)
			k
		else
			l
	else
		if (m)
			n
		else if (o)
			p
		else
			q

	a
		? (b
			? c
		: d
			? e
		: f)
	: g
		? (h
			? i
		: j
			? k
		: l)
	:(m
			? n
		: o
			? p
		: q)
	*/
	
		

	;; Parse a type and return that type object.  Handles embedded structs and unions
	parseType___ReleaseCode(lexer)
	{
		return "struct" == (tokenValue := (token := lexer.get()).value)
			? (((token := lexer.incGet()) == "{")
				; annonymous struct
				? c.struct_parser__(c.newName("struct"), lexer)
			: (c.isTypeDefined(token.value))
				; already defined struct
				? c.getType(lexer.getInc().value)
			: (lexer.incGet() == "{")
				; named struct
				? c.struct_parser__(token.value, lexer)
			: FAIL("Invalid token.  Expected '{' or '<struct typename>' '{' after 'struct' keyword, from " this.currentParseFrom.diagnositicInfo()))
		: (tokenValue == "union")
			? (((tokenValue := lexer.incGet()) == "{")
				; anonymous union
				? c.union_parser__(c.newName("union"), lexer)
			: (c.isTypeDefined(token.alue))
				; already defined union
				? c.getType(lexer.getInc().value) ; should increment t_pos and use tokenValue
			: (lexer.incGet() == "{")
				; named union
				? c.union_parser__(token.value, lexer) ; think lexer.getPrev().value should be replaced by tokenValue
			: FAIL("Invalid token.  Expected '{' or '<union typename>' '{' after 'union' keyword, from " this.currentParseFrom.diagnositicInfo()))
		; Currently don't support types with modifiers.  But if I were to do it
		; it would be done here.
		: c.getType(lexer.getInc().value) ;tokens[position++])
	}
	
	;; Parse a decorated name and return the last token found.
	;; A decorated name is a name that can have indirection markers '*' or array specifiers.
	;; Function pointers are not supported at this time.
	;; returns nothing
	parseDecoratedName(tokens, byref position, newType)
	{
		while (position <= tokens.MaxIndex())
		{
			if (tokens[position] == "*") ; found pointer
			{
				if (newType.hasKey(" indirectionCount"))
					++newType[" indirectionCount"]
				else
					newType[" indirectionCount"] := 1
				++position
			}
			else if (InStr(c.operators, tokens[position])) ; confirm identifier
				FAIL("Expected typedef name, found '" tokens[position] "'")
			else ; identifier confirmed
			{
				newType[" name"] := tokens[position++]
				if (tokens[position] == "[")
					if tokens[position+1] is Integer
					{
						newType[" arraySize"] := tokens[++position]
						if (tokens[++position] != "]")
							FAIL("Array terminator ']' not found.  Instead found '" tokens[--position] "'.")
						else
							++position
					}
					else
						FAIL("Array requires a numerical size.  Instead found '" tokens[++position] "'.")
					
				if (InStr(",;", tokens[position]))
					return tokens[position]
				else
					FAIL("Expected ';' or ',', but found '" tokens[position] "' instead.")
			}
		}
		return ";"
	}
	
	;; Parse a decorated name and return the last token found.
	;; A decorated name is a name that can have indirection markers '*' or array specifiers.
	;; Function pointers are not supported at this time.
	;; returns nothing
	parseDecoratedName___(tokens, byref position, newType)
	{
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
		{
			if (tokens[position] == "*") ; found pointer
			{
				if (newType.hasKey(" indirectionCount"))
					++newType[" indirectionCount"]
				else
					newType[" indirectionCount"] := 1
				++position
			}
			else if (RegExMatch(tokens[position], "[a-zA-Z_][a-zA-Z0-9_]*")) ; confirm identifier
			{
				newType[" name"] := tokens[position++]
				if (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
				{
					if (tokens[position] == "[")
					{
						if tokens[position+1] is Integer
						{
							newType[" arraySize"] := tokens[++position]
							if (tokens[++position] != "]")
								FAIL("Array terminator ']' not found.  Instead found '" tokens[--position] "'.")
							else
								++position
						}
						else
							FAIL("Array requires a numerical size.  Instead found '" tokens[++position] "'.")
					}
						
					if (InStr(",;", tokens[position]))
						return tokens[position]
					else
						FAIL("Expected ';' or ',', but found '" tokens[position] "' instead.")
				}
				else
					break
			}
			else ; not an identifier
				FAIL("Expected typedef name, found '" tokens[position] "'")
		}
		return ";"
	}
	
	;; Parse a decorated name and return the last token found.
	;; A decorated name is a name that can have indirection markers '*' or array specifiers.
	;; Function pointers are not supported at this time.
	;; returns nothing
	parseDecoratedName____(tokens, byref position, newType)
	{
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
		{
			if (tokens[position, "isAstrix"]) ; found pointer
			{
				if (newType.hasKey(" indirectionCount"))
					++newType[" indirectionCount"]
				else
					newType[" indirectionCount"] := 1
				++position
			}
			else if (tokens[position, 1]) ; confirm identifier
			{
				newType[" name"] := tokens[position++].string
				if (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
				{
					if (tokens[position, "isOpenBracket"])
					{
						if tokens[position+1].string is Integer
						{
							newType[" arraySize"] := tokens[++position].string
							if (tokens[++position, "isCloseBracket"])
								FAIL("Array terminator ']' not found.  Instead found '" tokens[--position].string "'.")
							else
								++position
						}
						else
							FAIL("Array requires a numerical size.  Instead found '" tokens[++position].string "'.")
					}
						
					if ((token := tokens[position]).isCommaOrSemicolon)
						return token
					else
						FAIL("Expected ';' or ',', but found '" tokens[position].string "' instead.")
				}
				else
					break
			}
			else ; not an identifier
				FAIL("Expected typedef name, found '" tokens[position].string "'")
		}
		return { isSemicolon: 1 }
	}
	
	;; Parse a decorated name and return the last token found.
	;; A decorated name is a name that can have indirection markers '*' or array specifiers.
	;; Function pointers are not supported at this time.
	;; returns nothing
	parseDecoratedName__(lexer, newType)
	{
		while (lexer.hasMoreTokens()) ;position <= tokens.MaxIndex())
		{
			if (lexer.get() == "*") ; found pointer
			{
				if (newType.hasKey(" indirectionCount"))
					++newType[" indirectionCount"]
				else
					newType[" indirectionCount"] := 1
				++lexer.t_pos ;++position
			}
			else if (lexer.get().isWord) ;tokens[position])) ; confirm identifier
			{
				newType[" name"] := lexer.getInc().value ;tokens[position++]
				if (lexer.hasMoreTokens())
				{
					if (lexer.get() == "[")
					{
						if lexer.getNext().value is Integer
						{
							newType[" arraySize"] := lexer.incGet().value ;tokens[++position]
							if (lexer.incGet() != "]")
								FAIL("Array terminator ']' not found.  Instead found " lexer.tokenTypeInfo(lexer.decGet()) ".")
							else
								++lexer.t_pos ;++position
						}
						else
							FAIL("Array requires a numerical size.  Instead found '" lexer.tokenTypeInfo(lexer.incGet()) "'.")
					}
						
					if (InStr(",;", lexer.get()))
						return lexer.get()
					else
						FAIL("Expected ';' or ',', but found '" lexer.tokenTypeInfo(lexer.get()) "' instead.")
				}
			}
			else ; not an identifier
				FAIL("Expected typedef name.  Instead found " lexer.tokenTypeInfo(lexer.get()) ".")
		}
		return ";"
	}
	
	;; Parses a struct definition.  Expects that token position be pointing at the opening brace.
	;; Returns type object
	struct_parser(name, tokens, byref position)
	{
		if (tokens[position++] != "{")
			FAIL("Missing required open brace '{'.  Instead found '" tokens[--position] "'.")
		offset := 0
		structType := { " name": name, " isComplex": 1, " isStruct": 1, base: c.type }
		structType[" simplestType"] := structType
		while (position <= tokens.MaxIndex())
		{
			type := c.parseType(tokens, position)
			while (position <= tokens.MaxIndex())
			{
				memberType := new c.type(type, offset)
				, memberType[" isTypedefOrMember"] := 1
				, memberType[" isMember"] := 1
				token := c.parseDecoratedName(tokens, position, memberType)
				if (structType.hasKey(memberType[" name"]))
					FAIL("Union already has a member '" memberType[" name"] "' defined as '" structType[memberType[" name"], " name"] "'.")
				
				memberType[" simplestType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type", " simplestType"]
				, memberType[" simplerType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type"]
				, memberType[" size"] := (memberType[" indirectionCount"] ? c.ptrSize : memberType[" type", " size"])
					 * (memberType[" arraySize"] ? memberType[" arraySize"] : 1)
				, structType.Insert(memberType)
				, structType.Insert(memberType[" name"], memberType)
				
				, ++position
				, offset += memberType[" size"]
				if (token == ";")
					break
			}
			if (tokens[position] == "}")
			{
				++position
				break
			}
		}
		if (1 and c.types.hasKey(name))
			FAIL("Type '" name "' has already been defined as '" c.types[name, " name"] "'.")
		structType[" size"] := offset
		c.types.Insert(name, structType)
		return structType
	}
	
	;; Parses a struct definition.  Expects that token position be pointing at the opening brace.
	;; Returns type object
	struct_parser___(name, tokens, byref position)
	{
		if (tokens[position++] != "{")
			FAIL("Missing required open brace '{'.  Instead found '" tokens[--position] "'.")
		offset := 0
		structType := { " name": name, " isComplex": 1, " isStruct": 1, base: c.type }
		structType[" simplestType"] := structType
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
		{
			type := c.parseType___(tokens, position)
			while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
			{
				memberType := new c.type(type, offset)
				, memberType[" isTypedefOrMember"] := 1
				, memberType[" isMember"] := 1
				token := c.parseDecoratedName___(tokens, position, memberType)
				if (structType.hasKey(memberType[" name"]))
					FAIL("Union already has a member '" memberType[" name"] "' defined as '" structType[memberType[" name"], " name"] "'.")
				
				memberType[" simplestType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type", " simplestType"]
				, memberType[" simplerType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type"]
				, memberType[" size"] := (memberType[" indirectionCount"] ? c.ptrSize : memberType[" type", " size"])
					 * (memberType[" arraySize"] ? memberType[" arraySize"] : 1)
				, structType.Insert(memberType)
				, structType.Insert(memberType[" name"], memberType)
				
				, ++position
				, offset += memberType[" size"]
				if (token == ";")
					break
			}
			if (tokens[position] == "}")
			{
				++position
				break
			}
		}
		if (1 and c.types.hasKey(name))
			FAIL("Type '" name "' has already been defined as '" c.types[name, " name"] "'.")
		structType[" size"] := offset
		c.types.Insert(name, structType)
		return structType
	}
	
	;; Parses a struct definition.  Expects that token position be pointing at the opening brace.
	;; Returns type object
	struct_parser____(name, tokens, byref position)
	{
		if (!tokens[position++, "isOpenBrace"])
			FAIL("Missing required open brace '{'.  Instead found '" tokens[--position].string "'.")
		offset := 0
		structType := { " name": name, " isComplex": 1, " isStruct": 1, base: c.type }
		structType[" simplestType"] := structType
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
		{
			type := c.parseType____(tokens, position)
			while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
			{
				memberType := new c.type(type, offset)
				, memberType[" isTypedefOrMember"] := 1
				, memberType[" isMember"] := 1
				token := c.parseDecoratedName____(tokens, position, memberType)
				if (structType.hasKey(memberType[" name"]))
					FAIL("Union already has a member '" memberType[" name"] "' defined as '" structType[memberType[" name"], " name"] "'.")
				
				memberType[" simplestType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type", " simplestType"]
				, memberType[" simplerType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type"]
				, memberType[" size"] := (memberType[" indirectionCount"] ? c.ptrSize : memberType[" type", " size"])
					 * (memberType[" arraySize"] ? memberType[" arraySize"] : 1)
				, structType.Insert(memberType)
				, structType.Insert(memberType[" name"], memberType)
				
				, ++position
				, offset += memberType[" size"]
				if (token.isSemicolon)
					break
			}
			if (tokens[position, "isCloseBrace"])
			{
				++position
				break
			}
		}
		if (1 and c.types.hasKey(name))
			FAIL("Type '" name "' has already been defined as '" c.types[name, " name"] "'.")
		structType[" size"] := offset
		c.types.Insert(name, structType)
		return structType
	}
	
	;; Parses a struct definition.  Expects that token position be pointing at the opening brace.
	;; Returns type object
	struct_parser__(name, lexer)
	{
		if (lexer.getInc() != "{")
			FAIL("Missing required open brace '{'.  Instead found " lexer.tokenTypeInfo(lexer.decGet()) ".")
		offset := 0
		structType := { " name": name, " isComplex": 1, " isStruct": 1, base: c.type }
		structType[" simplestType"] := structType
		while (lexer.hasMoreTokens())
		{
			type := c.parseType__(lexer)
			while (lexer.hasMoreTokens())
			{
				memberType := new c.type(type, offset)
				, memberType[" isTypedefOrMember"] := 1
				, memberType[" isMember"] := 1

				token := c.parseDecoratedName__(lexer, memberType)
				if (structType.hasKey(memberType[" name"]))
					FAIL("Union already has a member '" memberType[" name"] "' defined as '" structType[memberType[" name"], " name"] "'.")

				memberType[" simplestType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type", " simplestType"]
				, memberType[" simplerType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type"]
				, memberType[" size"] := (memberType[" indirectionCount"] ? c.ptrSize : memberType[" type", " size"])
					 * (memberType[" arraySize"] ? memberType[" arraySize"] : 1)
				, structType.Insert(memberType)
				, structType.Insert(memberType[" name"], memberType)
				, ++lexer.t_pos
				, offset += memberType[" size"]
				if (token == ";")
					break
			}
			if (lexer.get() == "}")
			{
				++lexer.t_pos
				break
			}
		}
		if (1 and c.types.hasKey(name))
			FAIL("Type '" name "' has already been defined as '" c.types[name, " name"] "'.")
		structType[" size"] := offset
		c.types.Insert(name, structType)
		return structType
	}
	
	;; Parses a union definition.  Expects that token position be pointing at the opening brace.
	;; Returns type object
	union_parser(name, tokens, byref position)
	{
		if (tokens[position++] != "{")
			FAIL("Missing required open brace '{'.  Instead found '" tokens[--position] "'.")
		offset := 0
		unionType := { " name": name, " isComplex": 1, " isUnion": 1, base: c.type }
		unionType[" simplestType"] := unionType
		MaxSize := 0
		while (position <= tokens.MaxIndex())
		{
			type := c.parseType(tokens, position)
			while (position <= tokens.MaxIndex())
			{
				memberType := new c.type(type, 0)
				, memberType[" isTypedefOrMember"] := 1
				, memberType[" isMember"] := 1
				
				token := c.parseDecoratedName(tokens, position, memberType)
				if (unionType.hasKey(memberType[" name"]))
					FAIL("Union already has a member '" memberType[" name"] "' defined as '" unionType[memberType[" name"], " name"] "'.")
				
				memberType[" simplestType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type", " simplestType"]
				, memberType[" simplerType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type"]
				, memberType[" size"] := (memberType[" indirectionCount"] ? c.ptrSize : memberType[" type", " size"])
					 * (memberType[" arraySize"] ? memberType[" arraySize"] : 1)
				, unionType.Insert(memberType)
				, unionType.Insert(memberType[" name"], memberType)
				, typeObjSize := memberType[" size"]
				, MaxSize := MaxSize > typeObjSize ? MaxSize : typeObjSize

				, ++position
				if (token == ";")
					break
			}
			if (tokens[position] == "}")
			{
				++position
				break
			}
		}
		if (1 and c.types.hasKey(name))
			FAIL("Type '" name "' has already been defined as '" c.types[name, " name"] "'.")
		unionType[" size"] := MaxSize
		c.types.Insert(name, unionType)
		return unionType
	}

	;; Parses a union definition.  Expects that token position be pointing at the opening brace.
	;; Returns type object
	union_parser___(name, tokens, byref position)
	{
		if (tokens[position++] != "{")
			FAIL("Missing required open brace '{'.  Instead found '" tokens[--position] "'.")
		offset := 0
		unionType := { " name": name, " isComplex": 1, " isUnion": 1, base: c.type }
		unionType[" simplestType"] := unionType
		MaxSize := 0
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
		{
			type := c.parseType___(tokens, position)
			while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
			{
				memberType := new c.type(type, 0)
				, memberType[" isTypedefOrMember"] := 1
				, memberType[" isMember"] := 1
				
				token := c.parseDecoratedName___(tokens, position, memberType)
				if (unionType.hasKey(memberType[" name"]))
					FAIL("Union already has a member '" memberType[" name"] "' defined as '" unionType[memberType[" name"], " name"] "'.")
				
				memberType[" simplestType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type", " simplestType"]
				, memberType[" simplerType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type"]
				, memberType[" size"] := (memberType[" indirectionCount"] ? c.ptrSize : memberType[" type", " size"])
					 * (memberType[" arraySize"] ? memberType[" arraySize"] : 1)
				, unionType.Insert(memberType)
				, unionType.Insert(memberType[" name"], memberType)
				, typeObjSize := memberType[" size"]
				, MaxSize := MaxSize > typeObjSize ? MaxSize : typeObjSize

				, ++position
				if (token == ";")
					break
			}
			if (tokens[position] == "}")
			{
				++position
				break
			}
		}
		if (1 and c.types.hasKey(name))
			FAIL("Type '" name "' has already been defined as '" c.types[name, " name"] "'.")
		unionType[" size"] := MaxSize
		c.types.Insert(name, unionType)
		return unionType
	}

	;; Parses a union definition.  Expects that token position be pointing at the opening brace.
	;; Returns type object
	union_parser____(name, tokens, byref position)
	{
		if (tokens[position++, "isOpenBrace"])
			FAIL("Missing required open brace '{'.  Instead found '" tokens[--position].string "'.")
		offset := 0
		unionType := { " name": name, " isComplex": 1, " isUnion": 1, base: c.type }
		unionType[" simplestType"] := unionType
		MaxSize := 0
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
		{
			type := c.parseType____(tokens, position)
			while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
			{
				memberType := new c.type(type, 0)
				, memberType[" isTypedefOrMember"] := 1
				, memberType[" isMember"] := 1
				
				token := c.parseDecoratedName____(tokens, position, memberType)
				if (unionType.hasKey(memberType[" name"]))
					FAIL("Union already has a member '" memberType[" name"] "' defined as '" unionType[memberType[" name"], " name"] "'.")
				
				memberType[" simplestType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type", " simplestType"]
				, memberType[" simplerType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type"]
				, memberType[" size"] := (memberType[" indirectionCount"] ? c.ptrSize : memberType[" type", " size"])
					 * (memberType[" arraySize"] ? memberType[" arraySize"] : 1)
				, unionType.Insert(memberType)
				, unionType.Insert(memberType[" name"], memberType)
				, typeObjSize := memberType[" size"]
				, MaxSize := MaxSize > typeObjSize ? MaxSize : typeObjSize

				, ++position
				if (token.isSemicolon)
					break
			}
			if (tokens[position, "isCloseBrace"])
			{
				++position
				break
			}
		}
		if (1 and c.types.hasKey(name))
			FAIL("Type '" name "' has already been defined as '" c.types[name, " name"] "'.")
		unionType[" size"] := MaxSize
		c.types.Insert(name, unionType)
		return unionType
	}

	;; Parses a union definition.  Expects that token position be pointing at the opening brace.
	;; Returns type object
	union_parser__(lexer)
	{
		if (lexer.getInc() != "{")
			FAIL("Missing required open brace '{'.  Instead found " lexer.tokenTypeInfo(lexer.decGet()) ".")
		offset := 0
		unionType := { " name": name, " isComplex": 1, " isUnion": 1, base: c.type }
		unionType[" simplestType"] := unionType
		MaxSize := 0
		while (lexer.hasMoreTokens())
		{
			type := c.parseType__(lexer)
			while (lexer.hasMoreTokens())
			{
				memberType := new c.type(type, 0)
				, memberType[" isTypedefOrMember"] := 1
				, memberType[" isMember"] := 1
				token := c.parseDecoratedName__(lexer, memberType)
				if (unionType.hasKey(memberType[" name"]))
					FAIL("Union already has a member '" memberType[" name"] "' defined as '" unionType[memberType[" name"], " name"] "'.")
				
				memberType[" simplestType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type", " simplestType"]
				, memberType[" simplerType"]
					:= (memberType[" arraySize"] or memberType[" isComplex"]) ? memberType : memberType[" type"]
				, memberType[" size"] := (memberType[" indirectionCount"] ? c.ptrSize : memberType[" type", " size"])
					 * (memberType[" arraySize"] ? memberType[" arraySize"] : 1)
				, unionType.Insert(memberType)
				, unionType.Insert(memberType[" name"], memberType)
				, typeObjSize := memberType[" size"]
				, MaxSize := MaxSize > typeObjSize ? MaxSize : typeObjSize

				, ++lexer.t_pos
				if (token == ";")
					break
			}
			if (lexer.get() == "}")
			{
				++lexer.t_pos
				break
			}
		}
		if (1 and c.types.hasKey(name))
			FAIL("Type '" name "' has already been defined as '" c.types[name, " name"] "'.")
		unionType[" size"] := MaxSize
		c.types.Insert(name, unionType)
		return unionType
	}

	;; Parses a typedef definition
	;; returns ";" if found "" if ran out of stuff to parse
	typedef_parser(tokens, byref position)
	{
		type := c.parseType(tokens, position)
		while (position <= tokens.MaxIndex())
		{
			; ignore parenthisis
			if (InStr("()", tokens[position]))
				++position
			else
			{
				newType := new c.type(type)
				, newType[" isTypedefOrMember"] := 1
				, newType[" isTypedef"] := 1
				token := c.parseDecoratedName(tokens, position, newType)
				if (1 and c.types.hasKey(newType[" name"]))
					FAIL("Type '" newType[" name"] "' has already been defined as '" c.types[newType[" name"], " name"] "'.")
				
				newType[" simplerType"]
					:= (newType[" arraySize"] or newType[" isComplex"]) or newType[" indirectionCount"] ? newType : newType[" type"]
				, newType[" simplestType"]
					:= (newType[" arraySize"] or newType[" isComplex"] or newType[" indirectionCount"]) ? newType : newType[" type", " simplestType"]
				, newType[" size"] := (newType[" indirectionCount"] ? c.ptrSize : newType[" type", " size"])
					 * (newType[" arraySize"] ? newType[" arraySize"] : 1)
				, c.types.Insert(newType[" name"], newType)  ; store typedef
				, ++position
				if (token == ";")
					return token
			}
		}
		return
	}
	
	;; Parses a typedef definition
	;; returns ";" if found "" if ran out of stuff to parse
	typedef_parser___(tokens, byref position)
	{
		type := c.parseType___(tokens, position)
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
		{
			; ignore parenthisis
			if (InStr("()", tokens[position]))
				++position
			else
			{
				newType := new c.type(type)
				, newType[" isTypedefOrMember"] := 1
				, newType[" isTypedef"] := 1
				token := c.parseDecoratedName___(tokens, position, newType)
				if (1 and c.types.hasKey(newType[" name"]))
					FAIL("Type '" newType[" name"] "' has already been defined as '" c.types[newType[" name"], " name"] "'.")
				
				newType[" simplerType"]
					:= (newType[" arraySize"] or newType[" isComplex"]) or newType[" indirectionCount"] ? newType : newType[" type"]
				, newType[" simplestType"]
					:= (newType[" arraySize"] or newType[" isComplex"] or newType[" indirectionCount"]) ? newType : newType[" type", " simplestType"]
				, newType[" size"] := (newType[" indirectionCount"] ? c.ptrSize : newType[" type", " size"])
					 * (newType[" arraySize"] ? newType[" arraySize"] : 1)
				, c.types.Insert(newType[" name"], newType)  ; store typedef
				, ++position
				if (token == ";")
					return token
			}
		}
		return
	}
	
	;; Parses a typedef definition
	;; returns ";" if found "" if ran out of stuff to parse
	typedef_parser____(tokens, byref position)
	{
		type := c.parseType____(tokens, position)
		while (position <= tokens.MaxIndex() or tokens.tokenAvailable(position))
		{
			; ignore parenthisis
			if (tokens[position, "isOpenCloseParenthisis"])
				++position
			else
			{
				newType := new c.type(type)
				, newType[" isTypedefOrMember"] := 1
				, newType[" isTypedef"] := 1
				token := c.parseDecoratedName____(tokens, position, newType)
				if (1 and c.types.hasKey(newType[" name"]))
					FAIL("Type '" newType[" name"] "' has already been defined as '" c.types[newType[" name"], " name"] "'.")
				
				newType[" simplerType"]
					:= (newType[" arraySize"] or newType[" isComplex"]) or newType[" indirectionCount"] ? newType : newType[" type"]
				, newType[" simplestType"]
					:= (newType[" arraySize"] or newType[" isComplex"] or newType[" indirectionCount"]) ? newType : newType[" type", " simplestType"]
				, newType[" size"] := (newType[" indirectionCount"] ? c.ptrSize : newType[" type", " size"])
					 * (newType[" arraySize"] ? newType[" arraySize"] : 1)
				, c.types.Insert(newType[" name"], newType)  ; store typedef
				, ++position
				if (token.isSemicolon)
					return token
			}
		}
		return
	}
	
	;; Parses a typedef definition
	;; returns ";" if found "" if ran out of stuff to parse
	typedef_parser__(lexer) ;(tokens, byref position)
	{
		type := c.parseType__(lexer) ;(tokens, position)
		while (lexer.hasMoreTokens())
		{
			; ignore parenthisis
			if (InStr("()", lexer.get()) and !IsObject(lexer.get()))
				++lexer.t_pos
			else
			{
				newType := new c.type(type)
				, newType[" isTypedefOrMember"] := 1
				, newType[" isTypedef"] := 1
				token := c.parseDecoratedName__(lexer, newType)
				
				if (1 and c.types.hasKey(newType[" name"]))
					FAIL("Type '" newType[" name"] "' has already been defined as '" c.types[newType[" name"], " name"] "'.")
				
				newType[" simplerType"]
					:= (newType[" arraySize"] or newType[" isComplex"]) or newType[" indirectionCount"] ? newType : newType[" type"]
				, newType[" simplestType"]
					:= (newType[" arraySize"] or newType[" isComplex"] or newType[" indirectionCount"]) ? newType : newType[" type", " simplestType"]
				, newType[" size"] := (newType[" indirectionCount"] ? c.ptrSize : newType[" type", " size"])
					 * (newType[" arraySize"] ? newType[" arraySize"] : 1)
				, c.types.Insert(newType[" name"], newType)  ; store typedef
				, ++lexer.t_pos
				if (token == ";")
					return token
			}
		}
		return
	}
	
	;; Defines the type object which defines all c types.  It is a recursive structure.
	class type
	{
		__New(type, offset="")
		{
			this[" type"] := type
			if offset is integer
				this[" offset"] := offset
		}
		
		description()
		{
			if (this[" isMember"])
				return this[" type"].description()
			else
				return "'" this[" name"] "'" 
					. repeat("*", this[" indirectionCount"]) (this[" arraySize"] ? "[" this[" arraySize"] "]" : "")
					. (this[" simplestType"] != this ? " which is a/an " this[" simplerType"].description() : "")
		}
		
		isASimplerTypeOf(simplerTypeToCheckFor)
		{
			while (this != simplerTypeToCheckFor and simplerTypeToCheckFor[" simplerType"])
			{
				simplerTypeToCheckFor := simplerTypeToCheckFor[" simplerType"]
			}
			return this == simplerTypeToCheckFor
		}
		
		hasSameRootTypeAs(otherType)
		{
			return this[" simplestType"] == otherType[" simplestType"]
		}
		
		__Delete()
		{
			if (isObject(this[" simplestType"]))
			{
				;OutputDebug("type.__Delete() called on type " this.description() ".")
				this[" simplestType"] := 0
				this[" type"] := 0
				if(this[" isComplex"])
				{
					loop % this.MaxIndex()
					{
						this[this[A_Index, " name"]] := 0
						this[A_Index] := 0
						this[" simplerType"] := 0
						this[" simplestType"] := 0
						this[" type"] := 0
					}
				}
			}
		}
	}

	;; Returns a type object given its name
	getType(name)
	{
		if (c.types.hasKey(name))
			return c.types[name]
		FAIL("Type '" name "' not defined.")
	}

	;; removes a type from the type system.  Unkinks pointers to prevent memory leaks
	deleteType(typeObj)
	{
		;OutputDebug(object_elementList(typeObj, "deleting typeObj", OBJECT_SHOW.DEFAULT | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
		
		typeObj.__Delete()

		; Currently, removing a string key from an object results in the key string never being deallocated.
		c.types.Remove(typeObj[" name"])
		;c.types[typeObj[" name"]] := 0
		
		;OutputDebug(object_elementList(typeObj, "deleted typeObj", OBJECT_SHOW.NONE | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
	}
	
	; Would use this function to make names case sensitive.
	; Not sure if it is worth it.
	name(name)
	{
		caseCode = 0
		loop, parse, name, % ""
		{
			if A_LoopField is upper
				caseCode := (caseCode << 1) | 1
			else
				caseCode <<= 1
		}
		return hex(caseCode,0,HEX.MAKE_UNSIGNED) " " name
	}

	;; Tokenizes a command returning an array of tokens
	;; Whitespace are collapsed to a single space and are never 
	;; added to the token array. Operators are always kept.
	tokenizer_orig(command, operators, whitespace)
	{
		command := Trim(RegExReplace(command, "[" whitespace "]+", " "))
		position := 0
		tokens := []
		loop, parse, command, %operators%%whitespace%
		{
			position += Strlen(A_LoopField) + 1
			Delimiter := SubStr(command, position, 1)
			if (A_LoopField != "" and A_LoopField != " ")
				tokens.Insert(A_LoopField)
			if (Delimiter != "" and Delimiter != " ")
				tokens.Insert(Delimiter)
		}
		;c.ndebug ? 0 : c.debug(object_elementList(tokens, "tokens"))
		return tokens
	}
	
	;; Tokenizes a command returning an array of tokens
	;; Whitespace are collapsed to a single space and are never 
	;; added to the token array. Operators are always kept.
	tokenizer(command, operators, whitespace)
	{
		static TOKENIZER_RE_ := "SAxmP`a)
		(
			(
					(?:[lL](?!"")|[a-km-zA-KM-Z_])[a-zA-Z_0-9]* # WORD
				|	[ \t]+ # WHITESPACE
				|	(?:==?|\+[+=]?|-[-=]?|&[&=]?|\|[|=]?|\*=?|/(?![/*])=?|\^=?|!=?|<=?|>=?|`%=?|\.(?![0-9])|\#\#?|[(){}\[\],?:;]) # OPERATORS
				|	(?:\\$) # QUOTED NEWLINE
				|	(?://.*$) # COMMENT LINE
				|	(?:/\*.*?\*/) # COMMENT BLOCK
				|	(?:/\*.*$) # COMMENT BLOCK INCOMPLETE
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
				|	(?:\r\n?|\n) # NEW LINE
			`)
		)"
		, TOKENIZER_RE := removeCommentsAndWhitespaceFromRegEx(TOKENIZER_RE_)
		, RS := chr(8)
		, FS := chr(7)

		position := 0
		
;		if (InStr(command, "`r"))
;			command := RegExReplace(command, "(\r\n?|\n\r)", "`n") ; ensure all versions of new line are replaced by `n
		command := RegExReplace(command, TOKENIZER_RE, FS "$1" RS, replacementCount) ; insert a seperator after every token
		
		tokens := []
		loop, parse, command, %RS%, %FS%
		{
			if (Trim(A_LoopField) == "" or InStr("`r`n`r", A_LoopField)) {
;				tokens.Insert("")
			} else
				tokens.Insert(A_LoopField)
		}
		;c.ndebug ? 0 : c.debug(object_elementList(tokens, "tokens"))
		return tokens
	}
	
	static tokens := [], nextOffsetToProcess := 1, startPos := 1
	
	; Since I'm using this member function as a callback which expects a regular function
	; this takes on the value of the 1st parameter, and the rest of the parameters are shifted
	; down one.
	;
	; Since the regex uses the P option, the 1st parameter states the length of the string matched.
	t0f(calloutNumber, foundPos, haystack) ; WORD
	{
		c.tokens.Insert({isWord: 1, value: x:=substr(haystack, c.nextOffsetToProcess, this - (c.nextOffsetToProcess - c.startPos)) } )
		c.nextOffsetToProcess := c.startPos + this
	}
	
	t1f(calloutNumber, foundPos) ; WHITESPACE
	{
		static WHITESPACE := {isWhitespace: 1}
		c.tokens.Insert(WHITESPACE)
		c.nextOffsetToProcess := c.startPos + this
	}
	
	t2f(calloutNumber, foundPos, haystack) ; OPERATOR
	{
		c.tokens.Insert(x:=substr(haystack, c.nextOffsetToProcess, this - (c.nextOffsetToProcess - c.startPos)) )
		c.nextOffsetToProcess := c.startPos + this
	}
	
	t3f(calloutNumber, foundPos, haystack) ; QUOTED NEWLINE
	{
		static QUOTED_NEWLINE := { isQuotedNewLine: 1 }
		c.tokens.Insert(QUTOED_NEWLINE)
		c.nextOffsetToProcess := c.startPos + this
	}
	
	t4f(calloutNumber, foundPos, haystack) ; COMENT LINE
	{
		;c.tokens.Insert({isCommentLine: 1, value: x:=substr(haystack, c.nextOffsetToProcess, this - (c.nextOffsetToProcess - c.startPos)) } )
		c.nextOffsetToProcess := c.startPos + this
	}
	
	t5f(calloutNumber, foundPos, haystack) ; COMMENT BLOCK
	{
		;c.tokens.Insert({isCommentBlock: 1, value: x:=substr(haystack, c.nextOffsetToProcess, this - (c.nextOffsetToProcess - c.startPos)) } )
		c.nextOffsetToProcess := c.startPos + this
	}
	
	t6f(calloutNumber, foundPos, haystack) ; COMMENT BLOCK INCOMPLETE
	{
		c.tokens.Insert({isCommentBlock: 1, value: x:=substr(haystack, c.nextOffsetToProcess, this - (c.nextOffsetToProcess - c.startPos)) } )
		c.nextOffsetToProcess := c.startPos + this
	}
	
	t7f(calloutNumber, foundPos, haystack) ; NUMERIC LITERAL
	{
		c.tokens.Insert({isNumericLiteral: 1, value: x:=substr(haystack, c.nextOffsetToProcess, this - (c.nextOffsetToProcess - c.startPos)) } )
		c.nextOffsetToProcess := c.startPos + this
	}
	
	t8f(calloutNumber, foundPos, haystack) ; STRING LITERAL
	{
		c.tokens.Insert({isStringLiteral: 1, value: x:=substr(haystack, c.nextOffsetToProcess, this - (c.nextOffsetToProcess - c.startPos)) } )
		c.nextOffsetToProcess := c.startPos + this
	}
	
	t9f(calloutNumber, foundPos, haystack) ; CHARACTER LITERAL
	{
		c.tokens.Insert({isCharacterLiteral: 1, value: x:=substr(haystack, c.nextOffsetToProcess, this - (c.nextOffsetToProcess - c.startPos)) } )
		c.nextOffsetToProcess := c.startPos + this
	}
	
	tAf(calloutNumber, foundPos, haystack) ; CHARACTER LITERAL
	{
		c.nextOffsetToProcess := c.startPos + this
	}
	
	tnf(calloutNumber, foundPos, haystack)
	{
		FAIL("Unknown token")
	}
	
	
	;  This is a lexer which generates tokens on a line by line basis.  It has 
	;  a C preprocessor built into it for effecency reasons.  This means that
	;  the lexer will not output preprocessor commands, and any invoked macros
	;  will also not be scene coming out of the lexer, only the result of the 
	;  macros.
	class lexer extends lexer
	{
		; NOTE: Even though I define these enums, I'm not using them.  Using flags instead to increase perfomance.
		; Don't use c.lexer to be operated on by addTokenNames() or it will result in missing default token names.
		static tnames := lexer.addTokenNames("WORD", "OPERATOR", "WHITESPACE", "QUOTED_NEWLINE", "NUMERIC_LITERAL", "STRING_LITERAL", "CHARACTER_LITERAL", "COMMENT_LINE", "COMMENT_BLOCK")
		static tenums := c.lexer.generateEnums() ; NOTE: object that generateEnums() was called on is c.lexer not lexer like with lexer.addTokenNames()
		
		tokenType(token)
		{
			return IsObject(token)
				? token.isWhitespace
						? "WHITESPACE"
					: token.isWord
						? "WORD"
					: token.isCharacterLiteral
						? "CHARACTER_LITERAL"
					: token.isQuotedNewLine
						? "QUTOED_NEWLINE"
					: token.isStringLiteral
						? "STRING_LITERAL"
					: token.isNumericLiteral
						? "NUMERIC_LITERAL"
					: "UNKNOWN"
				: "OPERATOR"
		}

		tokenTypeInfo(token)
		{
			return IsObject(token)
				? (token.isWhitespace
						? "WHITESPACE"
					: token.isWord
						? "WORD"
					: token.isCharacterLiteral
						? "CHARACTER_LITERAL"
					: token.isQuotedNewLine
						? "QUTOED_NEWLINE"
					: token.isStringLiteral
						? "STRING_LITERAL"
					: token.isNumericLiteral
						? "NUMERIC_LITERAL"
					: "UNKNOWN") " '" token.value "'"
				: "OPERATOR '" token "'"
		}
		
		; Tokenizes a command returning an array of token tuples.  The 1st is the token type,
		; the 2nd is the actual token.
		;
		; lineReader - a lineReader class object to get lines of text from
		; tokens - token list to add on to or replace
		; gettingLineContinuation - states that the line is incomplete on its own.
		;                           to be forwareded to lineReader.GetLine()
		;
		; USES Regex Callouts.  This works but is actully slower then piecemeal matching.
		; I'm assuming this is due to the callback overhead.
		;
		; Difference is by about 100us (1.16x slower) to parse:
		;
		;    c.typedef("int LONG")
		;    c.typedef("
		;    (
		;    	struct _RECT {
		;    	  LONG left;
		;    	  LONG top;
		;    	  LONG right;
		;    	  LONG bottom;
		;    	} RECT, *PRECT;
		;    )")
		tokenizer_callback(lineReader, tokens, gettingLineContinuation)
		{
			; RegEx options:
			;   S - study
			;  `a - $ matches all types of EOLs
			;   A - Anchors to begining of string
			;   m - multiline - $ matches to EOL not just end of the string
			static TOKENIZER_RE_ := "SAxmP`a)
			(
				(?:
						(?:[lL]?""(?:\\""|.)*?"")(?Cc.t8f) # STRING LITERAL
					|	(?:[a-zA-Z_][a-zA-Z_0-9]*)(?Cc.t0f) # WORD
					|	[ \t]+(?Cc.t1f) # WHITESPACE
					|	(?:==?|\+[+=]?|-[-=]?|&[&=]?|\|[|=]?|\*=?|/(?![/*])=?|\^=?|!=?|<=?|>=?|`%=?|\.(?![0-9])|\#\#?|[(){}\[\],?:;])(?Cc.t2f) # OPERATORS
					|	(?:\\$)(?Cc.t3f) # QUOTED NEWLINE
					|	(?://.*$)(Cc.t4f) # COMMENT LINE
					|	(?:/\*.*?\*/)(Cc.t5f) # COMMENT BLOCK
					|	(?:/\*.*$)(Cc.t6f) # COMMENT BLOCK INCOMPLETE
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
							(?Cc.t7f) # NUMERIC LITERAL
					|	(?:(?:\\'|.)+')(?Cc.t9f) # CHARACTER LITERAL
					|	$ # END OF THE LINE
					|	(?Cc.tnf) # TOKEN NOT FOUND
				`)*
			)"
			, TOKENIZER_RE := TOKENIZER_RE_ ;removeCommentsAndWhitespaceFromRegEx(TOKENIZER_RE_)
			
			if (lineReader.GetLine(startPos, endPos, gettingLineContinuation))
			{
				; if GetLine() sets endPos to startPos - 1 then there is nothing to parse
				if (endPos < startPos)
					return 1
				
				c.tokens := tokens
				RegExMatch(lineReader.buffer, TOKENIZER_RE, length, c.startPos := c.nextOffsetToProcess := startPos)
				return 1
			}
			else
			{
				tokens.Insert({isEndOfStream: 1})
				return 0
			}
		}
		
		; Tokenizes a command returning an array of token tuples.  The 1st is the token type,
		; the 2nd is the actual token.
		;
		; lineReader - a lineReader class object to get lines of text from
		; tokens - token list to add on to or replace
		; gettingLineContinuation - states that the line is incomplete on its own.
		;                           to be forwareded to lineReader.GetLine()
		;
		; USES: RegEx piecemeal matching.  This is about 2.28x slower then the original 
		; tokenizer which collapses whitespaces with a regex and then breaks the line up
		; using a parsing loop seperating the tokens by whitespace and operators of a
		; single character in length.
		;
		; Perhaps a regex could be made to insert a special character into the string
		; which could be used to parse the tokens on.  This would normally be a bad idea
		; but may be faster in the AHK language.
		tokenizer_piecemeal(lineReader, tokens, gettingLineContinuation)
		{
			; RegEx options:
			;   S - study
			;  `a - $ matches all types of EOLs
			;   A - Anchors to begining of string
			;   m - multiline - $ matches to EOL not just end of the string
			static WORD_RE := "S`aA)(?:[lL]""(*FAIL)|[a-zA-Z_])[a-zA-Z_0-9]*"
				, WHITESPACE_RE := "S`aA)[ \t]+"
				, OPERATOR_RE := "S`aA)==?|\+[+=]?|-[-=]?|&[&=]?|\|[|=]?|\*=?|/(?![/*])=?|\^=?|!=?|<=?|>=?|`%=?|\.(?![0-9])|##?|[(){}\[\],?:;]"
				; , NEWLINE_RE := "S`aA)\r\n?|\n\r?" ; Will never get a newline as GetLine() remove them from the stream
				, QUOTED_NEWLINE_RE := "S`amA)\\$" ;(?:\r\n?|\n\r?)"
				, NUMERIC_LITERAL_RE := "Sx`aA)
					(
						(
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
									| [Uu]?[Ll]? # int/float/double
								`)
							|
								\.[0-9]* # float/double
								(?:[Ee][+-]?[0-9]+)? # possible exponential notaion
								[Ff]?  # possible float suffix
						`)\b # end on a word boundry
					)"
				, NUMERIC_LITERAL_RE_ := removeCommentsAndWhitespaceFromRegEx(NUMERIC_LITERAL_RE_)
				, COMMENT_LINE_RE := "S`amA)//.*$"
				, COMMENT_BLOCK_RE := "S`aA)/\*.*?\*/"
				, COMMENT_BLOCK_INCOMPLETE_RE := "S`amA)/\*.*$"
				, STRING_LITERAL_RE := "S`aA)[lL]?""(?:\\""|.)*?"""
				, CHARACTER_LITERAL_RE := "S`aA)'(?:\\'|.)+'"
				, COMMENT_END_RE := "S`aAm).*?\*/"

				, WHITESPACE := { isWhitespace: 1 }
				, QUOTED_NEWLINE := { isQuotedNewLine: 1 }
			if (lineReader.GetLine(startPos, endPos, gettingLineContinuation))
			{
				; if GetLine() sets endPos to startPos - 1 then there is nothing to parse
				if (endPos < startPos)
					return 1
				
				Loop
				{
					; Ifs are marganally slower than short circuting and's and or's which are equivilant in speed to &&'s and ||'s.
					; Originally had one big RegEx, but it would take longer to execute
					; the RegExMatch as the string got longer.  This seems to be due to
					; the string comparison to determine what precompiled RegEx to use 
					; if one is available.
					RegExMatch(lineReader.buffer, WORD_RE, match, startPos)
						? tokens.Insert({isWord: 1, value: match})
					: RegExMatch(lineReader.buffer, WHITESPACE_RE, match, startPos)
						? tokens.Insert(WHITESPACE) ; don't care about contetnts
						; ? tokens.Insert({isWhitespace: 1, value: match}) ; store contents
					: RegExMatch(lineReader.buffer, OPERATOR_RE, match, startPos)
						? tokens.Insert(match)
					: RegExMatch(lineReader.buffer, QUOTED_NEWLINE_RE, match, startPos)
						? tokens.Insert(QUOTED_NEWLINE)
					: RegExMatch(lineReader.buffer, COMMENT_LINE_RE, match, startPos)
						? 1 ; don't care about comment contents
						;? tokens.Insert({isCommentLine: 1, value: substr(match, 3)}) ; store comment contents
					: RegExMatch(lineReader.buffer, COMMENT_BLOCK_RE, match, startPos)
						? 1 ; don't care about comment contents
						;? tokens.Insert({isCommentBlock:1, value: substr(match, 3, -2)}) ; store comment contents
					: RegExMatch(lineReader.buffer, COMMENT_BLOCK_INCOMPLETE_RE, match, startPos)
						? this.tokenizer_dropMultiLineToken(lineReader, tokens, startPos, endPos, match, COMMENT_END_RE) ; don't care about comment contents
						;? tokens.Insert({isCommentBlock: 1, value: substr(match, 3) "`n" substr(this.tokenizer_readMultiLineToken(lineReader, tokens, startPos, endPos, match, COMMENT_END_RE), 1, -2)}) ; store comment contents
					: RegExMatch(lineReader.buffer, STRING_LITERAL_RE, match, startPos)
						? tokens.Insert({isStringLiteral: 1, value: match})
					: RegExMatch(lineReader.buffer, CHARACTER_LITERAL_RE, match, startPos)
						? tokens.Insert({isCharacterLiteral: 1, value: match})
					: RegExMatch(lineReader.buffer, NUMERIC_LITERAL_RE, match, startPos)
						? tokens.Insert({isNumericLiteral: 1, value: match})
					: FAIL("Token wasn't recognized from here: '" substr(lineReader.buffer, startPos) "' from " this.currentParseFrom.diagnositicInfo())
					startPos += strlen(match)
				} until (startPos > endPos)
				return 1
			}
			else
			{
				tokens.Insert({isEndOfStream: 1})
				return 0
			}
		}
		
		static tokenizer := c.lexer.tokenizer_piecemeal
		
		someTokensAreNotIgnored(ByRef tokens)
		{
			; since comments are not inserted into the comment stream
			; and whitespaces are removed by the preparser, then if
			; there are any tokens left, they are not ignored.
			return tokens.MaxIndex() != ""
			
			maxIndex := tokens.MaxIndex()
			index := 1
			while index <= maxIndex
			{
				if (!((token := tokens[index]).isCommentBlock or token.isCommentLine or token.isWhitespace))
					return 1
				++index
			}
			; all tokens are ignored so might as well just remove them all.
			tokens := []
			return 0
		}

		; Returns 0 if preparser needs to get another line or 1 if it does not.
		; tokens are modified in place if necessary.  Preprocessor commands
		; and comments are removed from the token stream.
		preparser(byref tokens)
		{
			if (tokens[maxIndex := tokens.MaxIndex()].isQuotedNewLine)
			{
				tokens.Remove(maxIndex)
				return 0 ; does need the next line in the stream, so get it
			}
			; check to see if token is a preprocessor command
			if ((token := tokens[index := 1]) == "#" or token.isWhitespace and tokens[++index] == "#")
			{
				; preprocessor command.  command name at index+1 unless there's a whitespace between # and command, in which case it is at index+2
				if ((token := tokens[++index]).isWhitespace)
					token := tokens[++index]
					
				if (token.isWord)
				{
					if (IsLabel(cmd := "CPP_" token.value))
						goto %cmd%
					
					; Unknown preprossor command so ignoring it by deleting it and getting a new line.
					OutputDebug("Ignoring unrecognized preprocessor command '" token.value "' from " this.currentParseFrom.diagnositicInfo())
					tokens := []
					return 1 ; does NOT need the next line in the stream
					
					CPP_DEFINE:
						if (tokens[++index].isWhitespace) {
						} else
							FAIL("Expected a whitespace but found " this.tokenTypeInfo(tokens[index]) " instead from " this.currentParseFrom.diagnositicInfo())
						
						if ((token := tokens[++index]).isWord) {
						} else
							FAIL("Expected WORD but found " this.tokenTypeInfo(tokens[index]) " instead from " this.currentParseFrom.diagnositicInfo())
						
						name := token.value
						if ((token := tokens[++index]).isWhitespace) {
						} else
							FAIL("Expected WHITESPACE but found " this.tokenTypeInfo(tokens[index]) " instead from " this.currentParseFrom.diagnositicInfo())
						
						tokens.Remove(1, index) ; remove all tokens that are part of the command
						this.defines.Insert(name, tokens) ; insert the tokens to be replaced into the defines dictionary
						tokens := []
						return 1 ; does NOT need the next line in the stream
						
					CPP_UNDEF:
						if (tokens[++index].isWhitespace) {
						} else
							FAIL("Expected WHITESPACE but found " this.tokenTypeInfo(tokens[index]) " instead from " this.currentParseFrom.diagnositicInfo())
						
						if ((token := tokens[++index]).isWord) {
						} else
							FAIL("Expected WORD but found " this.tokenTypeInfo(tokens[index]) " instead from " this.currentParseFrom.diagnositicInfo())
						
						this.defines.Remove(token.value)
						tokens := []
						return 1 ; does NOT need the next line in the stream
					
					CPP_INCLUDE:
						tokens := []
						return 1 ; does NOT need the next line in the stream

					CPP_IF:
						tokens := []
						return 0 ; does need the next line in the stream, so get it

					CPP_ELSE:
						tokens := []
						return 0 ; does need the next line in the stream, so get it

					CPP_ENDIF:
						tokens := []
						return 1 ; does NOT need the next line in the stream
				}
				else
					FAIL("Garbage preproccor statement from " this.currentParseFrom.diagnositicInfo())
			}
			else
			{
				; not a Preprocessor command so preprocess line
				index := 1
				while index <= maxIndex := tokens.MaxIndex()
				{
					; removing WHITESPACE.  Unsure if better to remove WHITESPACE or override get functions to skip over it.
					; comments can have whitespaces on either side.  Since comments are not inserted into the token stream
					; consecutive comments are possible.
					while(tokens[index].isWhitespace)
						tokens.Remove(index)

					if ((token := tokens[index]).isWord)
					{
						if (this.defines.hasKey(tokenValue := token.value)) ; is there something to replace?
						{
							replacementTokens := this.defines[tokenValue]
							tokens.Remove(index)
							tokens.Insert(index, replacementTokens*)
							continue ; done, continue processing
						}
						; nothing to replace continue to the next token
					}
					++index
				}
			}
			return  1 ; does NOT need the next line in the stream
		}
	}
	
	static whitespace := "`n`r`t "
	, whitespaceSansLF := "`r`t "
	, operators := "/*;,{}[]()"
	, operatorsWithLF := "/*;,{}[]()`n"
	, ptrSize := A_PtrSize
	; not sure how I'm going to map to Str.  Do I need to map to Str?  Maybe for BSTR?  HMMMMMM....
	, types := c.processBaseTypes({ char: 1, uchar: 1, short: 2, ushort: 2, int: 4, uint: 4, int64: 8, uint64: 8, float: 4, double: 8, ptr: c.ptrSize, uptr: c.ptrSize})
	; These are not necessary since all c.objects store their data always as binary data.
	;		, charp: 1, ucharp: 1, shortp: 2, ushortp: 2, intp: 4, uintp: 4, int64p: 8, uint64p: 8, floatp: 4, doublep: 8, ptrp: c.ptrSize, uptrp: c.ptrSize})
	, defines := { }
	, defines_ := { }
	, ndebug := 1 ; No debug.  Set to 0 to turn debugging output on

	debug(x)
	{
		OutputDebug(x)
	}
	
	processBaseTypes(typesAndSizes)
	{
		; These types are not being deleted before exiting the application.  
		; This is because these types are referencing themselves and so cannot be.
		types := {}
		for typename, size in typesAndSizes
			type := { " name": typename, " size": size, " isBaseType": 1, base: c.type }
			, type[" simplestType"] := type
			, types.Insert(typename, type)

		return types
	}

	isTypeDefined(name)
	{
		return c.types.hasKey(name)
	}
	
	test1()
	{
		; a bunch of random tests to show what can be done.  Should formalise this.
		;c.use("DebugCode")
		c.typedef("ushort WORD")
		c.struct("
		(
			hello {
				WORD *s[5];
				WORd t, o, p;
			}
		)")
		c.union("
		(
			there {
				hello there2;
				char a;
			}
		)")
		;c.use("ReleaseCode")
		c.typedef("int number, anotherNumber")

		;OutputDebug(object_elementList(c.types, "c.types"))
		c.struct("abc { char a[5], b, c; hello x; }")
;		OutputDebug(object_elementList(c.types, "c.types", OBJECT_SHOW.NONE | OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
		abc := new c.object("abc", C.ASSIGN_VALUE, {a: [1], b: 2, x: {s: [3,4] } })
		OutputDebug(hex_dump(abc[], c.sizeof(abc)))
		;OutputDebug(object_elementList(abc, "ABC"), OBJECT_SHOW.NONE | OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN)
		;OutputDebug(object_elementList(abc, "abc LIST", OBJECT_SHOW.NONE | OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
		OutputDebug(object_elementList(abc, "ABC", OBJECT_SHOW.REAL_STRUCTURE | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
		OutputDebug(object_elementList(abc, "ABC", OBJECT_SHOW.NONE))
		OutputDebug(abc.b)
		OutputDebug(abc.c)
		OutputDebug(abc.elementList("abc"))
		abc.a.3 := 64
		abc.a[4] := 65
		abc.b := 66
		abc.c := 67
		abc.x.s.1 := 68
		abc.x.s.5 := 69
		abc.x.t := 70
		c.use("DebugCode")
		OutputDebug("abc`n" hex_dump(abc[], c.sizeof(abc)))
		OutputDebug("abc.x.s[1] = " abc.x.s[1])
		OutputDebug(abc.elementList("abc"))
		c.use("ReleaseCode")
		OutputDebug("abc`n" hex_dump(abc[], c.sizeof(abc)))
		OutputDebug(abc.elementList("abc"))

		number := new c.object("float", C.ASSIGN_VALUE, 5)
		OutputDebug(number.Get() ":" number.elementList("number"))
		number.Set(12)
		OutputDebug(number.Get() ":" number.elementList("number"))

		;MsgBox % object_elementList(result, "result")
		OutputDebug(object_getBase(abc).__Class)
		;OutputDebug(object_elementList(c.types, "c.types"))
		OutputDebug(abc.elementList("abc +"))
		OutputDebug(object_elementList(c.types, "c.types", OBJECT_SHOW.NONE | OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
		;OutputDebug(object_elementList(abc, "abc"))
		MsgBox % abc.d
	}
	
	test2()
	{
		; tests generating type using original regex and loop parse method.
		c.typedef("int LONG")
		c.typedef("
		(
			struct _RECT {
			  LONG left;
			  LONG top;
			  LONG right;
			  LONG bottom;
			} RECT, *PRECT;
		)")
		OutputDebug(object_elementList(c.types, "c.types", OBJECT_SHOW.NONE | OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
		rect := new c.object("rect", [ 1, 2, 3, 4 ])
		rect2 := new c.object("rect", [9,8,7,6])
		rect.Set(rect2)
		OutputDebug(rect.elementList("rect"))
	}

	test2___()
	{
		; tests generating type using original regex and loop parse method.
		c.typedef___("int LONG")
		c.typedef___("
		(
			struct _RECT {
			  LONG left;
			  LONG top;
			  LONG right;
			  LONG bottom;
			} RECT, *PRECT;
		)")
		OutputDebug(object_elementList(c.types, "c.types", OBJECT_SHOW.NONE | OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
		rect := new c.object("rect", [ 1, 2, 3, 4 ])
		rect2 := new c.object("rect", [9,8,7,6])
		rect.Set(rect2)
		OutputDebug(rect.elementList("rect"))
	}

	test2____()
	{
		; tests generating type using original regex and loop parse method.
		c.typedef____("int LONG")
		c.typedef____("
		(
			struct _RECT {
			  LONG left;
			  LONG top;
			  LONG right;
			  LONG bottom;
			} RECT, *PRECT;
		)")
		OutputDebug(object_elementList(c.types, "c.types", OBJECT_SHOW.NONE | OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
		rect := new c.object("rect", [ 1, 2, 3, 4 ])
		rect2 := new c.object("rect", [9,8,7,6])
		rect.Set(rect2)
		OutputDebug(rect.elementList("rect"))
	}

	test2__()
	{
		; tests generating type using c.lexer object
		c.typedef__("int LONG")
		c.typedef__("
		(
			struct _RECT {
			  LONG left;
			  LONG top;
			  LONG right;
			  LONG bottom;
			} RECT, *PRECT;
		)")
		OutputDebug(object_elementList(c.types, "c.types", OBJECT_SHOW.NONE | OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED | OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN))
		rect := new c.object("rect", [ 1, 2, 3, 4 ])
		rect2 := new c.object("rect", [9,8,7,6])
		rect.Set(rect2)
		OutputDebug(rect.elementList("rect"))
	}


	test_lexerFromString()
	{
		stream := new c.lexer(new stringLineReader("
		(
		
		#define Hello bye
	/ /= what /* the
	 hgg g
	 hgdhre
	 // hgjhgjgh
	Hello */ is going on? //hghgfhgfhgf
	h//jhkjhk
	.0 ul
	hello there
	#undef hello
	hello there
	#boo
	#hi there\
		out	`t	`tthere [ ]\
		k
		
		/*
	j
		)"))
		OutputDebug("==================")
		while stream.hasMoreTokens()
		{
			OutputDebug("Found " c.lexer.tokenTypeInfo(stream.get()) " from " stream.currentParseFrom.diagnositicInfo())
			++stream.t_pos
		}
	}

	test_lexerFromFile()
	{
		stream := new c.lexer(new fileLineReader("linestream-test-win.txt"))
		OutputDebug("==================")
		while stream.hasMoreTokens()
		{
			OutputDebug("Found " c.lexer.tokenTypeInfo(stream.get()) " from " stream.currentParseFrom.diagnositicInfo())
			++stream.t_pos
		}
	}

	test_transientTypes()
	{
		; test transient array type

		; a typedef will delete itself upon exiting the application if it is an alias to a simpler type.
		; This is because if it has no simpler type, it references itself.  Such a type must have it's destructor
		; called explictly which will break these references.
		c.typedef("int a") 
		c.typedef("a b")
		c.typedef("int *c")

		x := new c.objectArray("int", 20)
		x[3] := 3
		OutputDebug(x.elementList("x"))
		x := new c.objectPointer("int", 2)
		OutputDebug(x.elementList("x"))
		x := new c.objectArrayOfPointers("int", 2, 4)
		OutputDebug(x.elementList("x"))
	}
	
	test_typeComparisons()
	{
		MsgBox % c.types["a"].isASimplerTypeOf(c.types["b"]) " should be true."
		MsgBox % c.types["a"].isASimplerTypeOf(c.types["int"]) " should be false."
		MsgBox % c.types["b"].isASimplerTypeOf(c.types["a"]) " should be false."
		MsgBox % c.types["int"].isASimplerTypeOf(c.types["a"]) " should be true."
		MsgBox % c.types["a"].hasSameRootTypeAs(c.types["b"]) " should be true."
		MsgBox % c.types["b"].hasSameRootTypeAs(c.types["a"]) " should be true."
		MsgBox % c.types["a"].hasSameRootTypeAs(c.types["int"]) " should be true."
		MsgBox % c.types["b"].hasSameRootTypeAs(c.types["int"]) " should be true."
		MsgBox % c.types["double"].hasSameRootTypeAs(c.types["int"]) " should be false."
		MsgBox % c.types["b"].hasSameRootTypeAs(c.types["double"]) " should be false."
	}
}
;c.use("DebugCode")
;c.test1()
;c.test_lexerFromString()
;c.test_lexerFromFile()
;c.test2()
;c.test2____()
;c.test2___()
;c.test2__()
;c.test_transientTypes()
