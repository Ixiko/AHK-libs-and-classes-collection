; Title:   	IsObjectEmpty() - Looking for the shortest IfObjectEmpty function.
; Link:   		https://www.autohotkey.com/boards/viewtopic.php?t=62867
; Author:	evilC
; Date:		2019-03-19
; for:     	AHK_L

/*

	Examples:
	----------------------------------------------------------------------------------------------------------------
	msgbox % "IsEmptyAssoc({}) = " IsEmptyAssoc({}) ; true
	msgbox % "IsEmptyAssoc({1:"", 2:""}) = " IsEmptyAssoc({1:"", 2:""}) ; false

	msgbox % " a(1, , 3, 4) = " a(1, , 3, 4)
	a(args*) {
		; Length of the object is 4, but let's delete 3 items and see if it is empty...
		args.Delete(4)
		args.Delete(3)
		args.Delete(1)
		return IsEmptyAssoc(args)
	}

	msgbox % "f({1:"", 2:""}) = " f({1:"", 2:""}) ; false
	f(o) { ; "IsObjectEmpty"
		local
		if !isobject(o)
			throw exception("No object to invoke.", -1)
		if objcount(o)
			for k, v in o
				if (v != "")
					return false
		return true
	}
	-----------------------------------------------------------------------------------------------------------------

	No they are not. Empty strings are perfectly valid elements for an array
	To check for an empty associative array:

*/

; Is an associative array empty?
IsEmptyAssoc(assoc) {
	return !assoc._NewEnum()[k, v]
}

ObjectCount(obj) {   ; from Helgef - count() was recently added and does not suffer from this, you are mixing it with length(). You should update your function to,
	return obj.count()
}

IsObjectEmpty(obj) {
    return (obj.length() == 0) ? true : false
}