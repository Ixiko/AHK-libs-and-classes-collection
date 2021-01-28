eval() - Dynamic expression evaluation
======================================

This library was written for AutoHotkey v1.1.08.

**WARNING - THIS LIBRARY ABUSES INTERNAL AHK STRUCTURES - IT IS GUARANTEED TO BE BROKEN BY A FUTURE AHK VERSION**

Readme
------

This library allows you to dynamically execute AutoHotkey expressions.

Usage:

    returnValue := eval("expression text")

You may want to run `calculator.ahk` for a simple demonstration.

Limitations
-----------

- You can only access global variables
- Double-derefs are not supported yet
- Clipboard is read-only
- ClipboardAll doesn't work
- `obj.field(something) := val` is not supported yet
- Compound object field assignment is not supported yet

Changelog
---------

- **v1.0**: Initial release
