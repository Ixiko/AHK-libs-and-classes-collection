;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Reference strings/numbers/objects in AHK_L
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

#include <object> ; strange, including object has to occur before misc. Why???
#Include <misc>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; REF
;;
;;  This is (AFAIK) currently the cleanest way of passing a references to
;;  string/numbers/objects around and storing them for later use.  But there are
;;  some cavets.
;;
;;  PLEASE READ THIS ENTIRELY BEFORE ASKING QUESTIONS!
;;
;;  AHK_L variables are able to store strings/numbers/objects.  However, strings
;;  and numbers, although similar to objects, have different copy sematics.
;;
;;  When a variable is passed to a function who's parameter doesn't use the
;;  byref keyword, or when a variable is returned, the original contents of the
;;  variable is not accessable.  This is because variable's contents are copied,
;;  unless the contents was an object, in which case a reference to the original
;;  object is copied allowing changes to be seen across function boundaries.
;;
;;  Storage of references is disallowed, most likely due to the storage for 
;;  these strings and numbers are transient due to their copy semantics.  For
;;  instance, new storage areas may be created and old ones destroyed when
;;  a value or variable is assigned to a another variable.  So even if
;;  something has a reference to the string/number, if the original variable is
;;  assigned a new value, the variable's address would have changed.
;;
;;  However, there are instance where it would sometimes be nice to be able to
;;  have this capacity, though in a limited fashion. I.e. passing an array of 
;;  references, instead of just copies, or variadic function parameters.  Used
;;  in the same way that ByRef variables are used.
;;
;;  Here is where the _ref class comes in.  It creates a pointer to the original
;;  variable's string space, which is accessable and can be written to.  However
;;  the memory cannot be adjusted on the end of the ref object holder.  But if
;;  the upper bound is known a head of time, this problem can be worked around.
;;  And what's memory anyway? *PSHWA*  I think we might need more then 640k of
;;  RAM. :)
;;
;;  NOTE: Changes have been made such that you can adjust the length of the 
;;  memory on the side of the ref obejct holder, iif the reference is that of
;;  an object's member *and* you specify a capacity of -2.
;;
;; USAGE
;;
;;  Don't bother using the _ref class directly, there is a ref() function to act
;;  on your behalf to behave more like an operator.
;;
;;    a := "STRING"
;;    b := { a: "string" }
;;    refa := ref(a)
;;    refb := ref(b)
;;    refba := ref(b, "a")
;;
;;  NOTE: a minimum capacity can be added to the end of each ref() call.
;;
;;  Now that you have the references, you use them by using the [] operator.
;;
;;    if (refa[] = "STRING")
;;      refa[] := "Hello"
;;
;;  However, due to some issues, to access the changed string's length, it's a
;;  good idea to use refFix() before accessing them.  It doesn't need to be 
;;  called for member variables or objects.
;;
;;    refFix(a)
;;    OutputDebug '%a%'  ; outputs 'Hello'
;;
;;  NOTE: You cannot assign an object to a string/number reference, or a vice 
;;        versa.
;;
;;  For convience, an array of refs can be made using the refs() function:
;;
;;    a1 := refs(a, b, ref(b, "a"))
;;
;;  is equivilant to:
;;
;;    a1 := [ ref(a), ref(b), ref(b, "a") ]
;;
;;  refs() can take 99 parameters, but you can insert on the returned array
;;  like this.
;;
;;    a2 := refs(a)
;;    a2.Insert(a2.MaxIndex()+1, refs(b, ref(b, "a"))*)
;;
;;  If you want your array to contain refs that all can take a minimum size, use
;;  refsWithMinSize().  The first parameter is the minimum size, and the rest
;;  are the elements of the array.
;;
;;  If you wish to see a working example, go to the end of this file.  There
;;  are two functions, ref_example() and ref_example_fn().  The 2nd function
;;  is called by the 1st.
;;
;;  Enjoy!
;;
;; THINGS TO DO:
;;   - May make it so that you can modify the object by assigning an object
;;     to the reference.  As in:
;;
;;        x := {a: 1}
;;        refx := ref(x)
;;        refx[] = {b: 1}
;;
;; CHANGE LOG
;;   Nov 21, 2012
;;     - published
;;   Nov 21, 2012
;;     - Before publishing, I encapsulated some tests to show as examples into
;;       a function.  However, I forgot that I encapsultated a function within
;;       a function which is illegal.  Moved outside and works now.  Call
;;       ref_example() to run it.  To see it, go to the end of the source code.
;;     - Added isRef() function.
;;   Nov 22, 2012
;;     - Added ability to make object member references allow dynamic changing
;;       of strings, if necessary.
;;     - Assignment now returns copy of assigned string. (NEED TO TEST)
;;   Nov 25, 2012
;;     - Fixed some potential overrun errors as the StrPut takes max number of
;;       chars not number of bytes. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ref(object)
;; ref(object, key, capacity=-1)
;; ref(string)
;; ref(string, capacity=-1)
;;
;; Helper function to create a new _ref object. Saves typing of 5 chars. ;)
;;
;;     object - the object who's member to get the address of
;;        key - the key of the object to get the address of
;;     string - the string to get the address of
;;   capacity - the minimum capacity to allocate to the string
;;              Can have the following values:
;;
;;                +ve number
;;                  - Set the minimum capacity to that many bytes.
;;                -1
;;                  - Do not change capacity.
;;                -2
;;                  - Object member references can be reallocated.
;;
;; Returns a reference object of an object, an object's member or a string/
;; number.
;;
;; This is ment to make the ref class behave more like an operator.
;;
;; NOTE ON CAPACITY
;;
;;  If capacity is -1 (default), it will not change the capacity of the 
;;  variable passed.  If capacity is > -1, it will attempt to change the 
;;  capacity of the variable passed if not enough is available, which means 
;;  that the caller could possibly get a new address for that variable.  If the 
;;  ref is a member of an object and the capacity is set to -2, the code 
;;  assigning to the ref object will resize the address if necessary, again 
;;  chaning the address for the original variable.
;;
;;  If somewhere you have a ref of a nonmember variable or a pointer to any 
;;  type of variable and you allow the changing of the capacity of the ref, 
;;  that other pointer or ref may not be looking at the address where the data 
;;  will be updated to.  So be aware of what you are doing.
;;
;;  YOU HAVE BEEN WARNED!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ref(ByRef var, p*)
{
	return new _ref(var, p*)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; isRef(var)
;;
;; Tests to see if var is a reference or not.
;;
;;   var - var to test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isRef(ByRef var)
{
	return IsObject(var) and var.__class = "_ref"
}

; reference object
;  TODO: Maybe make it so that object members can have their capacity automaticly
;        adjusted.
class _ref
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; new _ref(object)
	;; new _ref(object, key, capacity=-1)
	;; new _ref(string)
	;; new _ref(string, capacity=-1)
	;;
	;; Constructor to create a new _ref object. 
	;;
	;;     object - the object who's member to get the address of
	;;        key - the key of the object to get the address of
	;;     string - the string to get the address of
	;;   capacity - the minimum capacity to allocate to the string. Default: -1.
	;;              Can have the following values:
	;;
	;;                +ve number
	;;                  - Set the minimum capacity to that many bytes.
	;;                -1
	;;                  - Do not change capacity.
	;;                -2
	;;                  - Object member references can be reallocated.
	;;
	;; Returns a reference object of an object, an object's member or a string/
	;; number.
	;;
	;; NOTE ON CAPACITY
	;;
	;;  If capacity is -1 (default), it will not change the capacity of the 
	;;  variable passed.  If capacity is > -1, it will attempt to change the 
	;;  capacity of the variable passed if not enough is available, which means 
	;;  that the caller could possibly get a new address for that variable.  If 
	;;  the ref is a member of an object and the capacity is set to -2, the code 
	;;  assigning to the ref object will resize the address if necessary, again 
	;;  chaning the address for the original variable.
	;;
	;;  If somewhere you have a ref of a nonmember variable or a pointer to any 
	;;  type of variable and you allow the changing of the capacity of the ref, 
	;;  that other pointer or ref may not be looking at the address where the data 
	;;  will be updated to.  So be aware of what you are doing.
	;;
	;; YOU HAVE BEEN WARNED!
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	__new(byref ref, p*)
	{
		if (IsObject(ref))
			if (ref.__Class == "_ref") ; got a ref object
				return ref
			else if ((size := p.MaxIndex()) = "") ; got some other object
				ObjInsert(this, "object", ref)
			else ; got an object + a key to reference
			{
				if (size != 1 and size != 2)
					FAIL("Expecting 1 or 3 parameters when passed an object as 1st parameter.  Received " size+1 " instead.")
				else
				{
					key := p[1]
					capacity := p[2]
					if (capacity = -2)
						ObjInsert(this, "capacity", -1)
					else if (capacity > -1)
						ObjInsert(this, "capacity", ref.SetCapacity(key, capacity))
					else
						ObjInsert(this, "capacity", ref.GetCapacity(key))
					address := ref.GetAddress(key)
					if (capacity == -2 or address != "")
						ObjInsert(this, "address", address)
					else
						FAIL("There is no string space allocated to object member '" key "'.  Use a capacity of -2 to have it dynamicly allocate.")
					ObjInsert(this, "_object", ref)
					ObjInsert(this, "key", key)
				}
			}
		else ; got a string/number
		{
			if (p.MaxIndex() > -1)
				capacity := p[1]
			else
				capacity := -1

			if (capacity < 0)
			{
				ObjInsert(this, "address", &ref)
				,ObjInsert(this, "capacity", VarSetCapacity(ref))
			}
			else
			{
				originalVal := ref
				,capacity := VarSetCapacity(ref, capacity)
				,ObjInsert(this, "address", &ref)
				,ObjInsert(this, "capacity", capacity)
				,this.__set(originalVal)
				,VarSetCapacity(ref, -1)
			}
		}
		;ObjInsert(this, "BOO", "HOO!")
	}
	
	__get(key="", p*)
	{
		if (key == "")
		{
			if (IsObject(this.object))
				return this.object
			else
				return StrGet(this.address, this.capacity, A_IsUnicode ? "UTF-16" : "")
		}
		else if (key = "__class")
			return "_ref"
	}
	
	__set(byref p, rest*)
	{
		if(rest.MaxIndex() = "") ; no key given
		{
			if (IsObject(this.object)) ; ref is an obj ref
			{
				if (IsObject(p))
				{
					FAIL("Assigning a completely new object to the reference is not yet supported.")
					;ObjInsert(this, "newObject", p[1])
					;ObjInsert(this, "__Delete", ref._clone_)
					;this._clone_()
				}
				else
					FAIL("Cannot set object reference to '" p "'.")
			
			}
			else if (IsObject(p)) ; ref is not an obj ref but attempt to assign an object to it
				FAIL("Cannot store an object to a string/number reference.")
			else if (IsObject(this._object) and this.capacity < 0) ; ref is an obj's member and capacity is resizable
			{
				this._object[this.key] := p
				ObjInsert(this, "capacity", this._object.GetCapacity(this.key))
				OutputDebug % "Reallocated string space for object member.  New size is " this.capacity "."
				return this._object[this.key]
			}
			else if ((chars2copy := StrPut(p)) <= (capacity := A_IsUnicode ? this.capacity // 2 : this.capacity))
			{
				OutputDebug % "Characters copied: " StrPut(p, this.address, chars2copy, A_IsUnicode ? "UTF-16" : "") " into " capacity "."
			}
			else
			{
				OutputDebug % "Truncated!  Characters copied: " StrPut(SubStr(p, 1, (capacity - 1)), this.address, capacity, A_IsUnicode ? "UTF-16" : "") " out of " chars2copy
			}
			return StrGet(this.address, capacity, A_IsUnicode ? "UTF-16" : "")
		}
	}
	
	GetAddress(p*)
	{
		OutputDebug % "GetAddress called with '" p.MaxIndex() "' parameters."
		if(p.MaxIndex() = "") ; empty array
			return this.address
		else
			return ObjGetAddress(this, p[1]) ; don't really need this
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; _move(srcObj)
	;;
	;; Move all relevant members to srcObj to object referenced by ref object.
	;;
	;;  srcObj - the object to take the data from.
	;;
	;; This simulate being able to do myrefObj[] := { aNew: "ref obj" }
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_move(srcObj)
	{
		; erase members from this.object including base and __class

		; copy members from this.newObject to this.object including base (I don't think is supported) and __class
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; refs(p1, ..., p99)
;;
;; Creates an array of ref objects.
;;
;;   p1 ... p99 - variables that are to be referenced.  All are optional.
;;
;; If you want to get a ref of an object's member, pass a ref(varToObject, 
;; memberName).  A ref of a ref is just a ref. :)
;;
;; Also, if a paticular variable needs to have a minimum size, pass a ref that
;; specifies the size you want.
;;
;;  refs(a, ref(b, 20), c)
;;
;; Will cause b to have a minimum allocation of 20 bytes.  a and c will be left
;; as is.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
refs(                   ByRef p1="",  ByRef p2="",  ByRef p3="",  ByRef p4="",  ByRef p5="",  ByRef p6="",  ByRef p7="",  ByRef p8="",  ByRef p9=""
		, ByRef p10="", ByRef p11="", ByRef p12="", ByRef p13="", ByRef p14="", ByRef p15="", ByRef p16="", ByRef p17="", ByRef p18="", ByRef p19=""
		, ByRef p20="", ByRef p21="", ByRef p22="", ByRef p23="", ByRef p24="", ByRef p25="", ByRef p26="", ByRef p27="", ByRef p28="", ByRef p29=""
		, ByRef p30="", ByRef p31="", ByRef p32="", ByRef p33="", ByRef p34="", ByRef p35="", ByRef p36="", ByRef p37="", ByRef p38="", ByRef p39=""
		, ByRef p40="", ByRef p41="", ByRef p42="", ByRef p43="", ByRef p44="", ByRef p45="", ByRef p46="", ByRef p47="", ByRef p48="", ByRef p49=""
		, ByRef p50="", ByRef p51="", ByRef p52="", ByRef p53="", ByRef p54="", ByRef p55="", ByRef p56="", ByRef p57="", ByRef p58="", ByRef p59=""
		, ByRef p60="", ByRef p61="", ByRef p62="", ByRef p63="", ByRef p64="", ByRef p65="", ByRef p66="", ByRef p67="", ByRef p68="", ByRef p69=""
		, ByRef p70="", ByRef p71="", ByRef p72="", ByRef p73="", ByRef p74="", ByRef p75="", ByRef p76="", ByRef p77="", ByRef p78="", ByRef p79=""
		, ByRef p80="", ByRef p81="", ByRef p82="", ByRef p83="", ByRef p84="", ByRef p85="", ByRef p86="", ByRef p87="", ByRef p88="", ByRef p89=""
		, ByRef p90="", ByRef p91="", ByRef p92="", ByRef p93="", ByRef p94="", ByRef p95="", ByRef p96="", ByRef p97="", ByRef p98="", ByRef p99="")
{
	array := []
	loop 99
		if (IsByRef(p%A_Index%) or IsObject(p%A_Index%))
			if (IsObject(p%A_Index%) and p%A_Index%.__Class = "_ref")
				array.Insert(p%A_Index%)
			else
				array.Insert(new _ref(p%A_Index%))
		else
			break
	return array
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; refsWithMinSize(minsize, p1, ..., p99)
;;
;; Same as refs(), but makes them so that they all have a minimum allocated size 
;; for each one.
;;
;;   minsize - minimum size that each variable needs to have allocated
;;             This is ignored for objects.
;;   p1 ... p99 - variables that are to be referenced.  All are optional.
;;
;; If minsize is -1, then don't resize.  If someone using the reference trys to
;; put something in it that is bigger than what is stored, the value will be
;; truncated.
;;
;; If you pass a ref, it is excluded from the minsize requirement.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
refsWithMinSize(minsize
					  , ByRef p1="",  ByRef p2="",  ByRef p3="",  ByRef p4="",  ByRef p5="",  ByRef p6="",  ByRef p7="",  ByRef p8="",  ByRef p9=""
		, ByRef p10="", ByRef p11="", ByRef p12="", ByRef p13="", ByRef p14="", ByRef p15="", ByRef p16="", ByRef p17="", ByRef p18="", ByRef p19=""
		, ByRef p20="", ByRef p21="", ByRef p22="", ByRef p23="", ByRef p24="", ByRef p25="", ByRef p26="", ByRef p27="", ByRef p28="", ByRef p29=""
		, ByRef p30="", ByRef p31="", ByRef p32="", ByRef p33="", ByRef p34="", ByRef p35="", ByRef p36="", ByRef p37="", ByRef p38="", ByRef p39=""
		, ByRef p40="", ByRef p41="", ByRef p42="", ByRef p43="", ByRef p44="", ByRef p45="", ByRef p46="", ByRef p47="", ByRef p48="", ByRef p49=""
		, ByRef p50="", ByRef p51="", ByRef p52="", ByRef p53="", ByRef p54="", ByRef p55="", ByRef p56="", ByRef p57="", ByRef p58="", ByRef p59=""
		, ByRef p60="", ByRef p61="", ByRef p62="", ByRef p63="", ByRef p64="", ByRef p65="", ByRef p66="", ByRef p67="", ByRef p68="", ByRef p69=""
		, ByRef p70="", ByRef p71="", ByRef p72="", ByRef p73="", ByRef p74="", ByRef p75="", ByRef p76="", ByRef p77="", ByRef p78="", ByRef p79=""
		, ByRef p80="", ByRef p81="", ByRef p82="", ByRef p83="", ByRef p84="", ByRef p85="", ByRef p86="", ByRef p87="", ByRef p88="", ByRef p89=""
		, ByRef p90="", ByRef p91="", ByRef p92="", ByRef p93="", ByRef p94="", ByRef p95="", ByRef p96="", ByRef p97="", ByRef p98="", ByRef p99="")
{
	array := []
	loop 99
		if (IsByRef(p%A_Index%) or IsObject(p%A_Index%))
			if (IsObject(p%A_Index%) and p%A_Index%.__Class = "_ref")
				array.Insert(p%A_Index%)
			else
				array.Insert(new _ref(p%A_Index%))
		else
			break
	return array
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; refFix(p1, ..., p99)
;;
;; Fixes refs after they have been modified.
;;
;;   p1 ... p99 - variables that have been referenced.  All are optional.
;;
;; As it stands currently, if you try and store a string using StrPut into a
;; (non-member) variable given the variable's string address, the original 
;; variable won't know about the change of size correctly.  VarSetCapacity() 
;; needs to be called on it using -1 as the capacity to reset the string storage
;; capacity on the original variable.  That is what this function does but allows
;; 1 or more than 1 to be done at the same time.
;;
;; This doesn't appear to be necessary for member variables and is ignored for
;; objects.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
refFix(                 ByRef p1="",  ByRef p2="",  ByRef p3="",  ByRef p4="",  ByRef p5="",  ByRef p6="",  ByRef p7="",  ByRef p8="",  ByRef p9=""
		, ByRef p10="", ByRef p11="", ByRef p12="", ByRef p13="", ByRef p14="", ByRef p15="", ByRef p16="", ByRef p17="", ByRef p18="", ByRef p19=""
		, ByRef p20="", ByRef p21="", ByRef p22="", ByRef p23="", ByRef p24="", ByRef p25="", ByRef p26="", ByRef p27="", ByRef p28="", ByRef p29=""
		, ByRef p30="", ByRef p31="", ByRef p32="", ByRef p33="", ByRef p34="", ByRef p35="", ByRef p36="", ByRef p37="", ByRef p38="", ByRef p39=""
		, ByRef p40="", ByRef p41="", ByRef p42="", ByRef p43="", ByRef p44="", ByRef p45="", ByRef p46="", ByRef p47="", ByRef p48="", ByRef p49=""
		, ByRef p50="", ByRef p51="", ByRef p52="", ByRef p53="", ByRef p54="", ByRef p55="", ByRef p56="", ByRef p57="", ByRef p58="", ByRef p59=""
		, ByRef p60="", ByRef p61="", ByRef p62="", ByRef p63="", ByRef p64="", ByRef p65="", ByRef p66="", ByRef p67="", ByRef p68="", ByRef p69=""
		, ByRef p70="", ByRef p71="", ByRef p72="", ByRef p73="", ByRef p74="", ByRef p75="", ByRef p76="", ByRef p77="", ByRef p78="", ByRef p79=""
		, ByRef p80="", ByRef p81="", ByRef p82="", ByRef p83="", ByRef p84="", ByRef p85="", ByRef p86="", ByRef p87="", ByRef p88="", ByRef p89=""
		, ByRef p90="", ByRef p91="", ByRef p92="", ByRef p93="", ByRef p94="", ByRef p95="", ByRef p96="", ByRef p97="", ByRef p98="", ByRef p99="")
{
	loop 100
		if (IsByRef(p%A_Index%))
		{
			if (!IsObject(p%A_Index%))
				OutputDebug % "Reset var " A_Index " to " VarSetCapacity(p%A_Index%, -1) " bytes."
		}
		else if (!IsObject(p%A_Index%))
			break
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ref_example()
;;
;;  Example function showing how one can use ref.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ref_example()
{
	OutputDebug % "========================================================================="
	OutputDebug Showing an example where passing different things to a variadic function.
	a := 1
	b := "hello there"
	c := { a: 7, c: "yyy", d: "aaa" }
	d := ref(a)
	e := ref(d)
	
	if (d = e) 
		OutputDebug Correct! Ref of ref are the SAME.
	else
		OutputDebug FAIL! Ref of ref are DIFFERENT.

	OutputDebug % "Before:"
	OutputDebug % "  a = '" a "'"
	OutputDebug % "  b = '" b "'"
	OutputDebug % "  c.a = '" c.a "'"
	OutputDebug % "  c.b = '" c.b "'"
	OutputDebug % "  c.c = '" c.c "'"
	OutputDebug % "  c.d = '" c.d "'"
	ref_example_fn(refs(a, ref(c, "c", 167*2), c, ref(c, "d"))*)
	refFix(a, b, c, c.d)
	OutputDebug % "After:"
	OutputDebug % "  a = '" a "'"
	OutputDebug % "  b = '" b "'"
	OutputDebug % "  c.a = '" c.a "'"
	OutputDebug % "  c.b = '" c.b "'"
	OutputDebug % "  c.c = '" c.c "'"
	OutputDebug % "  c.d = '" c.d "'"

	OutputDebug --------------------------------------------------------------------------------------
	OutputDebug Redoing the example with 2nd parameter as a string instead of a reference to a string.
	a := 1
	b := "hello there"
	c := { a: 7, c: "yyy", d: "aaa" }
	d := ref(a)
	e := ref(d)
	
	if (d = e) 
		OutputDebug Correct! Ref of ref are the SAME.
	else
		OutputDebug FAIL! Ref of ref are DIFFERENT.

	OutputDebug % "Before:"
	OutputDebug % "  a = '" a "'"
	OutputDebug % "  b = '" b "'"
	OutputDebug % "  c.a = '" c.a "'"
	OutputDebug % "  c.b = '" c.b "'"
	OutputDebug % "  c.c = '" c.c "'"
	OutputDebug % "  c.d = '" c.d "'"
	ref_example_fn(ref(a), b, refs(c, ref(c, "d"))*)
	;ref_example_fn(ref(a), b, ref(c), ref(c, "d")) ; this is also equivilant
	refFix(a, b, c, c.c)
	OutputDebug % "After:"
	OutputDebug % "  a = '" a "'"
	OutputDebug % "  b = '" b "'"
	OutputDebug % "  c.a = '" c.a "'"
	OutputDebug % "  c.b = '" c.b "'"
	OutputDebug % "  c.c = '" c.c "'"
	OutputDebug % "  c.d = '" c.d "'"
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ref_example_fn(array*)
;;
;;  Called by ref_example() to show it in action.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ref_example_fn(array*)
{
	OutputDebug % "Param 1   (ref str): '" array[1][] "'.  Setting to 2."
	array[1][] := 2

	if (isRef(array[2]))
	{
		OutputDebug % "Param 2   (ref str): '" array[2][] "'.  Setting to 'bye bye'."
		;                                                                                                                 1         1         1         1         1         1         1
		;                       1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
		;              12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567 (167)
		array[2][] := "bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye bye"
		;array[2][] := "bye bye"
	}
	else if (IsObject(array[2]))
	{
		OutputDebug % "Param 2   (obj)    : some object"
	}
	else
	{
		OutputDebug % "Param 2   (str)    : '" array[2] "'."
	}
	
	OutputDebug % "Param 3.a (ref obj): '" array[3][] "'.  Setting to 8."
	array[3][].a := 8
	
	OutputDebug % "Param 3.b (ref obj): '" array[3][] "'.  Setting to 9."
	array[3][].b := 9
	
	OutputDebug % "Param 4   (ref str): '" array[4][] "'.  Setting to 'zzz'."
	array[4][] := "zzz"
}
;ref_example()
