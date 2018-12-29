;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Object functions
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
#include <ClassCheck>
#include <misc>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Object functions
;;
;; LOG
;;  Nov 22/2012
;;  - Object_elementList() now handles self referenced and recursive referenced
;;    objects as well as nested classes.
;;  - Added OBJECT_SHOW constants and changed viewRealStructure parameter to
;;    an options bitfield.  This shouldn't break existing code as long as only
;;    0, 1, true or false were used as a passed value to viewRealStructure 
;;    parameter.
;;  - Added ability to show regular strings and numbers.  I.e.:
;;     x := 5
;;     object_elementList(x, "x") ; returns <x> = 5
;;  Nov 30/2012
;;  - Added a maximum depth option to object_elementList().
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Constants used for object_elementList() function's options.  Using a class
;; to keep people from misspelling errors.  Also keeps related constants 
;; together.
class OBJECT_SHOW extends checkMemberExists
{
		static NONE := 0
		 , REAL_STRUCTURE := 1
		 , PROTOTYPES := 1 << 1
		 , ALL := OBJECT_SHOW.REAL_STRUCTURE | OBJECT_SHOW.PROTOTYPES
		 , NUMBER_KEYS_AS_ADDRESS := 1 << 2
		 , NUMBER_VALS_AS_ADDRESS := 1 << 3
		 , KEYS_WITH_BINARY_DUMPED := 1 << 4
		 , NOT_OBJECTS_ALREADY_SHOWN := 1 << 5
		 , DEFAULT := OBJECT_SHOW.PROTOTYPES | OBJECT_SHOW.TO_DEPTH(-1)
	TO_DEPTH(x)
	{
		if x between -1 and 254
			return ((x+1) & 0xff) << 6
		else
			FAIL("Max specifiable depth is 254.  Use -1 to allow for unlimited depth.")
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; object_elementList(obj:any, name:string, options:OBJECT_SHOW constants
;;     , indent:string, traversedObjects:string)
;;
;; Traverses the object's member variables and build a string to see what it
;; contains.
;;
;;                 obj - The object to display
;;                name - The name you want to show for the object.
;;             options - Options that will modify the result:
;;
;;                         OBJECT_SHOW.NONE = 0
;;                          - Shows structure as given by the object, which
;;                            may differ from the real structure, and doesn't
;;                            show the prototypes.
;;                         OBJECT_SHOW.REAL_STRUCTURE = 1
;;                          - view the real structure, not the one that the
;;                            object is presenting.
;;                         OBJECT_SHOW.PROTOTYPES = 2
;;                          - show the prototypes of any objects that have
;;                            them.
;;                         OBJECT_SHOW.ALL = 4
;;                          - Shows the real structure and any prototypes.
;;                         OBJECT_SHOW.NUMBER_KEYS_AS_ADDRESS
;;                          - Shows keys that are numbers as hex addresses.
;;                         OBJECT_SHOW.NUMBER_VALS_AS_ADDRESS
;;                          - Shows values that are numbers as hex addresses.
;;                         OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED
;;                          - If key name contains "BINARY", dump the contents
;;                            using hex_dump() function instead of showing as
;;                            string.
;;                         OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN
;;                          - Mmmmmmm, strong is the force, this one is. :)
;;                            Keeps from displaying already shown objects.
;;                            This is mainly to reduce the output of a 
;;                            complex structure that points at the same
;;                            objects in several different places.
;;                         OBJECT_SHOW.TO_DEPTH(x)
;;                          - Specify how deep into the data structure you are
;;                            wanting to go.  0 stays on the top level, i.e.
;;                            you only see the pointer of an object.  1 goes in
;;                            one level, 2 goes in 2 levels, etc.  -1 means go 
;;                            as deep as necessary to show the entire structure.
;;
;;                            Func pointers are different in that they will show
;;                            their name even if that means going past the 
;;                            maximum depth.
;;
;;                            A x == -1 results in all the bits to be clear and 
;;                            x == 254 results in all the bits to be set.  Because
;;                            of this, oring directly to the DEFAULT or to a new
;;                            option that you are building will result in an
;;                            expected result.
;;                         OBJECT_SHOW.DEFAULT
;;                          - default value.
;;
;;                       Default: OBJECT_SHOW.PROTOTYPES | OBJECT_SHOW.TO_DEPTH(-1)
;;              indent - What do you want to use as your initial indent. Best 
;;                       not to muck with this, but if you do, have it start
;;                       with a "`n"
;;                       Default: "`n"
;;    traversedObjects - Internal use only.  Keep track of already traversed
;;                       objects so not to go into an infinite recursion.
;;                       Default: 0
;;        shownObjects - Internal use only. Keeps track of already shown 
;;                       objects elsewhere in the structure.
;;                       Default: 0
;;
;; Displays the value(s) stored in (theoretically) any type of object passed.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
object_elementList(obj, name, options = 2, indent = "`n", traversedObjects = 0, shownObjects = 0) {
	static mask := OBJECT_SHOW.TO_DEPTH(254)
	strObjAddress := "_" objAddress := hex_address(&obj)
	if (!IsObject(traversedObjects))
		traversedObjects := { }
	else if (traversedObjects[strObjAddress])
		return object_debug(indent "<" name "> = " objAddress " <- RECURSIVE REFERENCE" )
	if (options & OBJECT_SHOW.NOT_OBJECTS_ALREADY_SHOWN)
		if (!IsObject(shownObjects))
			shownObjects := { }
		else if (shownObjects.hasKey(objAddress))
			return object_debug(indent "<" name "> = " objAddress " <- ALREADY SHOWN" )

	; Using address with "_" prepended to it so that when removed, will not 
	; decrement any addresses that are higher than it.
	traversedObjects[strObjAddress] := 1
	shownObjects[objAddress] := 1
	output := object_debug(indent "<" name "> = " )
	indent .= " ."
	if (isFunc(obj))
	{
		output .= object_debug("Func " objAddress
							  . indent "<Name> = '" obj.Name "'")
	}
	else if (IsObject(obj))
	{
		output .= object_debug("Object " objAddress)
		depth := ((options & mask) >> 6) - 1
		if (-1 = depth or depth > 0)
		{
			if (-1 != depth)
			{
				options := options & ~mask | OBJECT_SHOW.TO_DEPTH(--depth)
			}
			if (options & OBJECT_SHOW.PROTOTYPES)
			{
				; Iterate through base class object (prototype)
				base := object_getBase(obj)
				if (isObject(base))
				{
					passOptions := options | mask
					output .= object_debug(object_elementList(base, "base", passOptions, indent, traversedObjects, shownObjects))
				}
			}
			if (options & OBJECT_SHOW.REAL_STRUCTURE)
			{
				enum := ObjNewEnum(obj)
				while enum[key, val]
					gosub object_elementList__showKeyValue
			}
			else
			{
				for key, val in obj
					gosub object_elementList__showKeyValue
			}
		}
		else
		{
			output .= object_debug(" <- MAX DEPTH REACHED")
		}
			
	}
	else
	{
		val := obj
		gosub object_elementList__showValue
	}
	traversedObjects.Remove(strObjAddress)
	return output
	
; Using this as it keeps same scope so all vars are available without function parameter overhead
object_elementList__showKeyValue:
	StringReplace, key, key, `t, ``t, 1
	StringReplace, key, key, `n, ``n, 1
	StringReplace, key, key, `r, ``r, 1
	if (options & OBJECT_SHOW.NUMBER_KEYS_AS_ADDRESS )
		keyOutput := indent "<" hex_address(key) "> = "
	else
		keyOutput := indent "<" key "> = "

object_elementList__showValue:
	if (IsObject(val))
		if (val == obj)
			output .= object_debug(keyOutput objAddress " <- SELF REFERENCE")
		else
		{
			output .= object_debug(object_elementList(val, key, options, indent, traversedObjects, shownObjects))
		}
	else
	{
		if val is number
			if (options & OBJECT_SHOW.NUMBER_VALS_AS_ADDRESS )
				output .= object_debug(keyOutput hex_address(val))
			else
				output .= object_debug(keyOutput val)
		else if (options & OBJECT_SHOW.KEYS_WITH_BINARY_DUMPED and instr(key, "binary"))
			output .= object_debug(keyOutput " HEX DUMP"
				. hex_dump(ObjGetAddress(obj, key), ObjGetCapacity(obj, key), HEX_DUMP.DEFAULT, indent "  "))
		else
			output .= object_debug(keyOutput "'" val "'")
	}
	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; object_GetBase(obj)
;;
;;  Get the base object.
;;
;; Given by Lexikos 
;; http://www.autohotkey.com/board/topic/86546-give-me-your-class/#entry551043
;; This is subject to change.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
object_getBase(obj) {
	if (IsFunc(obj))
		return ""
	return Object(NumGet(&obj, 2*A_PtrSize))
}

object_getBaseAddress(obj) {
	return NumGet(&obj, 2*A_PtrSize)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Used to debug output of objects_elementList(). INTERNAL USE ONLY.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
object_debug(str)
{
	return str
	static cached := ""
	if (pos := instr(str, "`n"))
	{
		cached .= substr(str, 1, pos-1)
		loop parse, cached, `n
			OutputDebug("DEBUG: " A_LoopField)
		cached := substr(str, pos+1)
	}
	else
		cached .= str
	return str
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Used to test output of objects_elementList(). INTERNAL USE ONLY.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
class object_test
{
	class x
	{
		static boo := "3"
		hoo := 2
		class y
		{
			foo := 3
		}
	}
	object_test()
	{
		a:= ""
		fn := Func("object_test.object_test")
		fnx := object_getBase("")
		xx := new object_test.x
		xx.x := xx
		xx.base.xx := xx
		OutputDebug % object_elementList(a, "a")
		OutputDebug  % object_elementList(fn, "fn")
		OutputDebug  % object_elementList(object_test.x, "object_test.x", OBJECT_SHOW.DEFAULT | OBJECT_SHOW.TO_DEPTH(0)) 
		OutputDebug  % object_elementList(xx, "xx (NONE)", OBJECT_SHOW.NONE, "`n") 
		OutputDebug  % object_elementList(xx, "xx (REAL)", OBJECT_SHOW.REAL_STRUCTURE, "`n") 
		OutputDebug  % object_elementList(xx, "xx (PROTO)", OBJECT_SHOW.PROTOTYPES, "`n") 
		OutputDebug  % object_elementList(xx, "xx (ALL)", OBJECT_SHOW.ALL | OBJECT_SHOW.NUMBER_VALS_AS_ADDRESS, "`n") 
		OutputDebug  % object_elementList(object_test, "object_test (ALL)", OBJECT_SHOW.ALL | OBJECT_SHOW.NUMBER_VALS_AS_ADDRESS | OBJECT_SHOW.TO_DEPTH(1), "`n") 
		OutputDebug  % object_elementList(object_getBase(object_test.x), "object_getBase(object_test.x)")
		OutputDebug  % object_elementList(object_getBase(xx), "object_getBase(xx)")
	}
}
;object_test.object_test()
