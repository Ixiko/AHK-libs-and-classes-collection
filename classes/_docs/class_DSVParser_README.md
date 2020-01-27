# DSVParser-AHK

A simple utility for parsing delimiter-separated values (i.e., DSV) in
AutoHotkey scripts, whether that be comma-separated (i.e., CSV), tab-separated
(i.e., TSV), or something else, possibly even exotic ones.

## Features

- [RFC 4180](https://tools.ietf.org/html/rfc4180) compliant.
- Supports newlines and other weird characters in cells enclosed in [text
qualifiers](https://www.quora.com/What-is-a-text-qualifier).
- Allows custom delimiters and text qualifiers.
- Supports multiple delimiters (like Microsoft Excel).
- Supports multiple qualifiers (unlike Microsoft Excel).
- Proper support for malformed inputs (e.g., `"hello" world "foo bar"` will be
parsed as `hello world "foo bar"`).
	- Achieved by treating cells as composed of two components: a
	text-qualified part (i.e., any raw string, excluding unescaped qualifier
	characters), and a delimited text part (i.e., any raw string, including
	qualifier characters, except newlines and delimiter characters).
	- The behavior for ill-formed cells are therefore not undefined.
	- The above treatment is also similar to that of Microsoft Excel.
- Recognizes many ASCII and Unicode line break representations:
	- i.e., `CR`, `LF`, `CR+LF`, `LF+CR`, `VT`, `FF`, `NEL`, `RS`, `GS`,
	`FS`, `LS`, `PS`
	- References:
		- [Newline - Wikipedia](https://en.wikipedia.org/wiki/Newline)
		- [Field separators | C0 and C1 control codes -
		Wikipedia](https://en.wikipedia.org/wiki/C0_and_C1_control_codes#Field_separators)
		- [`str.splitlines([keepends])` | Built-in Types — Python 3.8.0
		documentation](https://docs.python.org/3/library/stdtypes.html#str.splitlines)

## Example

### Basic usage

```AutoHotkey
; Load a TSV data string
FileRead tsvStr, data.tsv

; Parse the TSV data string
MyTable := TSVParser.ToArray(tsvStr)

; Do something with `MyTable`

MsgBox % MyTable[2][1] ; Access 1st cell of 2nd row

; ... do something else with `MyTable` ...

; Convert into a CSV, with custom line break settings
csvStr := CSVParser.FromArray(MyTable, "`n", false)

FileDelete new-data.csv
FileAppend %csvStr%, *new-data.csv
```

### And there's more!

Both `TSVParser` and `CSVParser` are premade instances of the class `DSVParser`.
To read and write in other formats, create a new instance of `DSVParser` and
specify your desired configuration.

Here's a `DSVParser` for pipe-separated values (aka., bar-separated):

```AutoHotkey
global BSVParser := new DSVParser("|")
```

Many more utility functions are provided for parsing and formatting DSV strings,
including parsing just a single DSV cell.

Check out the source code! It's really just a tiny file.
