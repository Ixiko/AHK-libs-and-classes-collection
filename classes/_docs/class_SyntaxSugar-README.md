# Auxilium
Syntax sugar for Autohotkey: you can treat strings as objects, and use a few extra methods on normal arrays and objects.

You can do e.g. `"Hello".Match("g)l").Msgbox()` or `"Hello Mr".Split(" ").Msgbox()`.

The `.Replace()` method accepts function objects, like `Result := String.Replace("gi)hello", Func("MyReplacementFunc"))` (see `Demonstration.ahk`).

Both `.Match()` and `.Replace()` use regular expressions.

You can use the "global" flag `g` to get all matches from a string.

Trying to access non-existing indices or group names on Regex match objects gives you an error message (though the script will only pause, not exit). The same applies to non-existing properties or methods of strings, or when you use the wrong number of arguments in a string method.

Such error messages can be suppressed like so: `"Hello".Silent().BadPropertyName`"

## Version

Current version is alpha (it seems to work for me without problems, but I might want or need to change substantial things).

In addition, various bits are spaghetti code and uncommented, so viewer discretion advised.

## Installation:
Put the files `SyntaxSugar.ahk` and `ObjectToString.ahk` in your `Lib` folder (e.g. `...\Program Files\Autohotkey\Lib\`).

You can run the file `Demonstration.ahk` anywhere to test the library.
