# JSON and Jxon

#### [JSON](http://json.org/) lib for [AutoHotkey](http://ahkscript.org/)

Requirements: Latest version of AutoHotkey _(v1.1+ or v2.0-a+)_

Version: v2.1.1 _(updated 01/30/2016)_

License: [WTFPL](http://wtfpl.net/)


- - -

## JSON.ahk (class)
Works on both AutoHotkey _v1.1_ and _v2.0a_

### Installation
Use `#Include JSON.ahk` or copy into a [function library folder](http://ahkscript.org/docs/Functions.htm#lib) and use `#Include <JSON>`.

- - -

#### .Load()
Parses a JSON string into an AHK value

#### Syntax:

    value := JSON.Load( text [, reviver ] )


#### Return Value:
An AutoHotkey value _(object, string, number)_

#### Parameter(s):
 * **text** [in] - JSON formatted string
 * **reviver** [in, opt] - function object, prescribes how the value originally produced by parsing is transformed, before being returned. Similar to JavaScript's `JSON.parse()` _reviver_ parameter.

- - -

#### .Dump()
Converts an AHK value into a JSON string

#### Syntax:

    str := JSON.Dump( value, [, replacer, space ] )


#### Return Value:
A JSON formatted string

#### Parameter(s):
 * **value** [in] - AutoHotkey value _(object, string, number)_
 * **replacer** [in, opt] - function object, alters the behavior of the stringification process. Similar to JavaScript's `JSON.stringify()` _replacer_ parameter.
 * **space** [in, opt] -if _space_ is a non-negative integer or string, then JSON array elements and object members will be pretty-printed with that indent level. Blank( ``""`` ) _(the default)_ or ``0`` selects the most compact representation. Using a positive integer _space_ indents that many spaces per level, this number is capped at 10 if it's larger than that. If _space_ is a string (such as ``"`t"``), the string _(or the first 10 characters of the string, if it's longer than that)_ is used to indent each level.

- - -
 
## Jxon.ahk (function)
Similar to the JSON class above just implemented as a function. ~~Unlike JSON (class) above, this implementation provides _reading from_ and _writing to_ file~~(Removed `Jxon_Read` and `Jxon_Write`). Works on both AutoHotkey _v1.1_ and _v2.0a_

### Installation
Use `#Include Jxon.ahk` or `#Include <Jxon>`. Must be copied into a [function library folder](http://ahkscript.org/docs/Functions.htm#lib) for the latter.

- - -

### Jxon_Load()
Deserialize _src_ (a JSON formatted string) to an AutoHotkey object

#### Syntax:

    obj := Jxon_Load( ByRef src [ , object_base := "", array_base := "" ] )


#### Parameter(s):
 * **src** [in, ByRef] - JSON formatted string or path to the file containing JSON formatted string.
 * **object_base** [in, opt] - an object to use as prototype for objects( ``{}`` ) created during parsing.
 * **array_base** [in, opt] - an object to use as prototype for arrays( ``[]`` ) created during parsing.

- - -

### Jxon_Dump()
Serialize _obj_ to a JSON formatted string

#### Syntax:

    str := Jxon_Dump( obj [ , indent := "" ] )


#### Return Value:
A JSON formatted string.

#### Parameter(s):
 * **obj** [in] - this argument has the same meaning as in _JSON.Dump()_
 * **indent** [in, opt] - this argument has the same meaning as in _JSON.Dump()_