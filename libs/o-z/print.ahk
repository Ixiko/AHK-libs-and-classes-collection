/**
 * Lib: Print.ahk
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Version:
 *     v2.0.1 [updated 04/03/2016 (MM/DD/YYYY)]
 * Requirement:
 *     Latest version of AutoHotkey v1.1+ or v2.0-a
 * Installation:
 *     Copy into a function library folder
 */

/**
 * Function: print
 *     Prints 'value' to 'dest' followed by 'end'
 * Syntax:
 *     r := print( value [, dest, end, space ] )
 * Parameter(s):
 *     r      [retval] - the number of bytes written to 'dest'. Otherwise, if
 *                       'dest' is a callable object, 'r' stores the  return
 *                       value of the called object.
 *     value      [in] - any AHK value
 *     dest  [in, opt] - file name or callable obect. Default is stdout
 *     end   [in, opt] - ending char(s), default is newline(`n)
 *     space [in, opt] - pretty printing, object indentation
 */
print(value, dest:="*", end:="`n", space:="")
{
	if IsObject(value)
		value := print_(value, space)
	value .= end

	return IsObject(dest) ? %dest%(value) : FileOpen(dest, "w").Write(value)
}
/**
 * Function: print_args
 *     Print each item in 'args' to 'dest' joined by 'sep' followed by 'end'
 * Syntax:
 *     r := print_args( args [, sep, dest, end ] )
 * Parameter(s):
 *     args       [in] - an array of AHK values
 *     sep   [in, opt] - string used to separate each item in 'args'
 */
print_args(args, sep:=" ", dest:="*", end:="`n")
{
	joined := ""
	len := args.Length()
	for i, arg in args
		joined .= (IsObject(arg) ? print_(arg) : arg) . (i<len ? sep : end)

	return print(joined, dest, "")
}
/**
 * Function: print_f
 *     Print formatted text to 'dest'
 * Syntax:
 *     r := print_f( fmt_str, args [, dest ] )
 * Parameter(s):
 *     fmt_str    [in] - format string similar to Format()
 *     args       [in] - an array values to be formatted and inserted into the
 *                       final string
 */
print_f(fmt_str, args, dest:="*")
{
	for i, arg in args
		if IsObject(arg)
			args[i] := print_(arg)
	
	return print(Format(fmt_str, args*), dest)
}

print_(value, indent:="", gap:="")
{
	static offset := A_AhkVersion<"2" ? -2 : -3
	if (Exception(0, offset).What != A_ThisFunc) { ; traceback, first iter
		gap := ""
		if (indent) {
			static integer := "integer"
			if indent is %integer%
				Loop % ((n := Abs(indent))>10 ? 10 : n)
					gap .= " "
			else
				gap := SubStr(indent, 1, 10)

			indent := "`n"
		}
	}

	if IsObject(value) {
		static type       := A_AhkVersion<"2" ? "" : Func("Type")
		static match_obj  := A_AhkVersion<"2" ? NumGet(&(m, RegExMatch("", "O)", m))) : ""
		static bound_func := NumGet(&(f := Func("FileOpen").Bind("*", 1)))
		static file_obj   := NumGet(&(f := f.Call()))
		static enum_obj   := NumGet(&(e := ObjNewEnum({})))

		obj_type := type                         ? type.Call(value)
		         :  ObjGetCapacity(value) != ""  ? "Object"
		         :  IsFunc(value)                ? "Func"
		         :  ComObjType(value) != ""      ? "ComObject"
		         :  NumGet(&value) == match_obj  ? "RegExMatchObject"
		         :  NumGet(&value) == bound_func ? "BoundFunc"
		         :  NumGet(&value) == file_obj   ? "FileObject"
		         :  NumGet(&value) == enum_obj   ? "Object::Enumerator"
		         :                                 "Property"

		if (obj_type != "Object")
			return Format("<{1} at 0x{2:p}>", obj_type, &value)

		if (gap) {
			stepback := indent
			indent .= gap
		}

		is_array := 0
		enum := ObjNewEnum(value) ; bypass _NewEnum()
		while enum.Next(k)
			if !(is_array := k == A_Index)
				break
		
		str := ""
		enum := ObjNewEnum(value) ; reset enumerator
		colon := gap  ? ": " : ":"
		while enum.Next(k, v) {
			if (gap)
				str .= indent
			
			if (!is_array)
				str .= print_(k, indent, gap) . colon
			
			str .= print_(v, indent, gap) . ","
		}

		if (str != "") {
			str := RTrim(str, ",")
			if (gap)
				str .= stepback
		}

		return is_array ? "[" . str . "]" : "{" . str . "}"
	
	} else if (ObjGetCapacity([value], 1) == "") {
		return value
	}

	static quot := Chr(34), _quot := "``" . quot
	if (value != "") {
		  value := StrReplace(value, "``", "````")
		, value := StrReplace(value, quot,  _quot)
		, value := StrReplace(value, "`n",  "``n")
		, value := StrReplace(value, "`r",  "``r")
		, value := StrReplace(value, "`b",  "``b")
		, value := StrReplace(value, "`t",  "``t")
		, value := StrReplace(value, "`v",  "``v")
		, value := StrReplace(value, "`a",  "``a")
		, value := StrReplace(value, "`f",  "``f")
	}

	return quot . value . quot
}