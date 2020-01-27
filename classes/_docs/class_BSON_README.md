# BSON.ahk
BSON.ahk is a small(-ish) AHK library for loading/dumping objects in the [BSON](http://bsonspec.org/) format.

## How to use
Just copy the the `\lib` folder into the same folder as your script, and add `#Include <BSON>` to your script, then you can call the various methods of the `BSON` class.

## Methods

### Dumping
`BSON.Dump(Object)` will dump the object into BSON, and then return an array of bytes containing the BSON representation of the object.

`BSON.Dump.ToFile(FilePath, Object)` will do the same as `BSON.Dump()`, but will write the bytes directly into a file. 

`BSON.Dump.ToHexString(Object)` also does the same as `BSON.Dump()`, but converts the array of bytes into hex, builds a string out of each byte, seperated by a space.

### Loading
`BSON.Load(Bytes)` expects an array of bytes (Like the one `BSON.Dump(Object)` returns), and will return the decoded BSON as an AHK object.

`BSON.Load.FromFile(FilePath)` will read the BSON data from the given file, and then return the decoded BSON as an AHK object.

`BSON.Load.FromHexString(String)` will convert the hex data back into binary, load it, and then return the decoded BSON as (you guessed it) an AHK object.

## Dependencies
All dependencies are included in `\lib`, and are also written by me; however, they are not on github since they are just quick helpers.

`Conversions.ahk` is required to load/dump hex encoded BSON.

`ScanningBuffer.ahk` is required to reuse the same code for loading from a file to load from any buffer in memory. By implementing (almost) all File Object methods, the `ScanningBuffer` class can be swapped in/out for File Objects inside of the internal BSON parsing methods.
