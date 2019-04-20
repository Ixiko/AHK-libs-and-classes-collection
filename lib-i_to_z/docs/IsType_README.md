Type Checking
=============

These functions are useful for input validation and dispatching.

They are compatible with AutoHotkey v1.


## Installation

The files with an `ahk` file extension must be placed in a [library directory](https://autohotkey.com/docs/Functions.htm#lib).


## Usage

Directly calling a function will cause its library to be auto-included.  If the function is only called dynamically or indirectly, its library must be explicitly included.

`Is(Value, Type)` is a backport of v2's [is](https://lexikos.github.io/v2/docs/commands/is.htm) operator.  It cannot support the "byref" option.  With the exception of being a function instead of an operator, it is otherwise identical.

`IsFuncObj(Value)` returns whether `Value` is a function object.  It recognizes built-in and user-defined function objects.

`Type(Value)` is a backport of v2's [Type](https://lexikos.github.io/v2/docs/commands/Type.htm) function.  It cannot differentiate between numbers and strings containing numbers.  It is otherwise identical.
