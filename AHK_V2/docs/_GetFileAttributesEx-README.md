# GetFileAttributesEx_ahk2
Alternate basic file attributes with DllCall().  Faster then built-in functions when called in an array loop.

## GetFileAttributesEx(file, attrib_list)
attrib_list:  "ACWTS"

A = access time\
C = create time\
W = write (modified) time\
T = attributes\
S = file size

## Benchmarks

```
See examples/comments at the top of the lib file.

280,361 -  8.77s  / 8.89s  calling GetFileAttributesEx(file,"CSW")
280,361 - 11.09s  / 11.14s calling GetFileAttributesEx(file,"ACWTS")
280,361 - 28.08s  / 28.38s calling same properties ahk_attribs() (Size/Modified/Created)
280,340 - 52.296s / 52.50s calling ahk_attribs2() all properties
```