# SerDes
#### Serialize / de-serialize an [AutoHotkey](http://ahkscript.org) [object](http://ahkscript.org/docs/Objects.htm) structure.

Requires AHK _v1.1+_ OR _v2.0-a049+_

License: [WTFPL](http://wtfpl.net)

- - -

### Serialize

**Syntax**

```
str   := SerDes( obj [ ,, indent := "" ] )
bytes := SerDes( obj, outfile [ , indent := "" ] )
```

**Parameters**

```
str      [retval]   - String representation of the object
bytes    [retval]   - Bytes written to 'outfile'.
obj      [in]       - AHK object to serialize.
outfile  [in, opt]  - The file to write to. If no absolute path is specified, %A_WorkingDir% is used.
indent   [in, opt]  - If indent is an integer or string, then array elements and object members will
                      be pretty-printed with that indent level. Blank(""), the default, OR 0, selects
                      the most compact representation. Using an integer indent indents that many spaces
                      per level. If indent is a string, (such as "`t"), that string is used to indent
                      each level. Negative integer is treated as positive.
```


### Deserialize

**Syntax**

```
obj   := SerDes( src )
```

**Parameters**

```
obj      [retval]   - An AHK object
src      [in]       - Either a 'SerDes()' formatted string or the path to the file containing 'SerDes()' formatted text.
```

## Remarks:
* Serilaized output is similar to [JSON](http://json.org/) except for escape sequences which follows [AHK's specification](http://ahkscript.org/docs/commands/_EscapeChar.htm#Escape_Sequences_when_accent_is_the_escape_character). Also, strings, numbers and objects are allowed as `object/{}` keys unlike JSON which restricts it to string data type only.
* Non-standard AHK objects such as _COM_, _Func_, _FileObject_, _RegExMatchObject_ are not supported.
* Object references, including circular ones, are supported and notated as _$n_, where _n_ is the _1-based_ index of the referenced object in the heirarchy tree when encountered during enumeration _(for-loop)_ OR as it appears from left to right _(for string representation)_ as marked by an opening brace`{` or bracket`[`.
```javascript
1         2
{ "key1": ["Hello World"], "key2": $2 } // -> $2 references the object stored in 'key1'
```