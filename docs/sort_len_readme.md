	sort_len(byref str, del := "`n", shortFirst:=true, omitEmpty:=true)

Function for sorting delimited substrings in ascending or declining order of string length. Order of appearance is preserved.

* `str`, the string to sort, null terminated.
* `del`, the delimiter, can be any length string, null terminated.
* `shortFirst`, set to true to output the shortest substrings first. `false` outputs the longer strings first.
* `omitEmpty`, if `true`, _empty_ substrings are omitted, eg, `"aa,b,"` -> `"b,aa"` instead of `",b,aa`".

### Example

```autohotkey
str := "aaa,b,,cc"		; note the empty substring between b and cc
sort_len(str, ",", shortFirst:=true, omitEmpty:=true) 
msgbox(str) ; b,cc,aaa
```