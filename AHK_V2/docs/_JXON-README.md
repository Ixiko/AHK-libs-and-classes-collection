# JXON_ahk2
JSON serializer for AHK v2 (beta.3)

Thanks to cocobelgica for his initial AHK v1 release [here](https://github.com/cocobelgica/AutoHotkey-JSON).

The focus of this serializer is compatibility with JSON.

Most Array(), Map(), Object() or a nested combination are supported (with exception for maps with object type keys, those are not supported).

## JxonEncode(obj, indent:=0)

```
text := JxonEncode(obj, indent:=0)
```

Output var is the serialized text.

Indent is in spaces.  Leaving this param blank will output the JSON text as a single line.  A value of 1 or more in this param will insert a line break at every element, and every nested level will get an additional indented space.  This param indicates the number of spaces to add for indent per level.

## JxonDecode(&text)

```
obj := JxonDecode(&text)
```

Input must be properly formatted JSON text. If not properly formatted an error will be thrown.  The error message will indicate the character number where parsing failed due to improper format.

The input `&text` must be passed as a VarRef with the `&` character.  This will ensure better performance and memory savings with massive input strings.

Limitation: Class which objects are to be decoded must have a constructor able to be executed without arguments (will be called to instantiate the Class).
