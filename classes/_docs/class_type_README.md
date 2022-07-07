Type Checking
=============

This is a backport of most of AutoHotkey v2’s type checking features to v1.  They are useful for validation and dispatching.

[Design](docs/Design.md) contains the reasons for the design decisions.


## Installation

The files in [src](src) must be placed in a [library directory](https://www.autohotkey.com/docs/Functions.htm#lib).


## Usage

Directly calling a function will cause its library to be auto-included.  If the function is only called dynamically or indirectly, its library must be explicitly included.

[`IsInteger(Value)`](docs/IsInteger.md)

[`IsFloat(Value)`](docs/IsFloat.md)

[`IsNumber(Value)`](docs/IsNumber.md)

[`IsString(Value)`](docs/IsString.md)

[`Type(Value)`](docs/Type.md)

[`IsInstance(Value, Class)`](docs/IsInstance.md) is v2’s `is` operator as a function.

[`HasProp(Value, Name)`](docs/HasProp.md)

[`HasMethod(Value, Name)`](docs/HasMethod.md)

Be aware that these functions do not recognize implicitly-defined members, except for `base`, of primitives or user-defined types.
