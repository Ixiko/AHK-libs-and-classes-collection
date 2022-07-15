# WinRT

This set of scripts provides an AutoHotkey v2 "language projection" for the Windows Runtime (WinRT). In other words, it hides the details of interop between AutoHotkey and WinRT, allowing WinRT objects to be used like native AutoHotkey objects.

The following basic types are supported:
  - Class (this covers the majority of WinRT APIs)
  - Interface (consuming, not implementing)
  - Delegate
  - Struct
  - Enum

Herein, "the projection" generally refers to this set of scripts, `WinRT`  is an AutoHotkey class defined within the projection, and "WinRT" mostly refers to the Windows Runtime in general, rather than the script.

## WinRT(typename)

```
#include winrt.ahk

if WinRT('Windows.Data.Json.JsonObject').TryParse('{"a":"b"}', &jo)
    MsgBox jo.Lookup('a').ToString() ; "b"
```
The main entry point is `WinRT(typename)`, which returns a wrapper class for *typename*. The return value can be used directly or assigned to a variable for convenience/readability.

This hasn't been tested with third-party WinRT components, but might work if each class is listed in the application's manifest (search terms: "registration-free WinRT").

## Windows.\*

```
#include windows.ahk

if Windows.Data.Json.JsonObject.TryParse('{"a":"b"}', &jo)
    MsgBox jo.Lookup('a').ToString() ; "b"
```
`Windows` provides an alternative entry point for the system-defined WinRT classes. This requires more processing than retrieving each class directly with `WinRT()`, as it must discover namespaces and types at each dot-delimited level to provide proper error handling (but note that namespaces and types are cached). The code for this is contained within `windows.ahk`, which can be omitted if not using `Windows`.

## Class

Classes are given the same structure and usage as normal AutoHotkey classes. The following are supported:

  - Constructors: just *call* the class like usual.
  - Static methods and properties
  - Instance methods and properties

Events are not directly supported, but are exposed as methods like `add_Event` and `remove_Event` (which is how they are represented in the metadata). See [Delegate](#delegate) for limitations. See [Events (Microsoft Docs)](https://docs.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system#events) for details about the two methods.

Class wrappers extend their declared superclass or `RtObject`. `x is RtObject` is true for any runtime object or interface wrapper; they are all IInspectable-derived interface pointers.

### Method Overloads

Method overloads are supported only if each overload has different *arity*.

> WinRT supports overloading on parameter types, but favors overloading on the number of input parameters—also known as the method's *arity*. 

Method overloads with equal arity but different parameter types are valid, but none were found in the system-defined classes during development of the projection. The presence of overloads with equal arity might prevent the current version of the projection from successfully wrapping the class.

The runtime metadata also provides alternative method names for languages that do not support overloading, but they are not used.

The code used to support overloads is very general, and may be reused in other scripts. It can be found in `overload.ahk`.

### Composable Classes

Constructors for composable classes (generally XAML controls) optionally accept two additional parameters that are normally omitted from language projections, but are used for class composition. For further explanation of these parameters, see [Composable activation](https://docs.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system#composable-activation).

If the declared return type of a property or method is a composable class, the projection queries the actual class of the object and wraps it as that. For instance, a property of type `UIElement` could return a `TextBox` or `StackPanel`. By contrast, if the return type is a *sealed* class (any class which isn't composable), it can only return objects of that exact class, so the class does not need to be queried each time.

## Interface

Interfaces are handled more or less the same as classes, but only have instance methods and properties.

Interface wrappers are usually only encountered for generic interfaces. For most other objects, the projection can determine the actual runtime class of the object and wrap it accordingly.

The current version of the projection does not include much type-checking, so when passing an object to a method or property that is declared to accept an interface, make sure to pass the correct interface.

The current version of the projection does not include any public method of explicitly wrapping an interface or querying for an interface.

The current version of the projection does not support passing a normal AutoHotkey object to a parameter that expects an interface, but a future version should.

Interface wrapper classes directly extend `RtObject`. `x is RtObject` is true for any runtime object or interface wrapper; or in other words, any `IInspectable` object.

## Delegate

AutoHotkey function objects are automatically wrapped in the appropriate delegate interface when passed to a parameter or property that accepts a delegate.

The current version of the projection creates a new delegate each time.

The current version of the projection does not validate the parameter count or callability of the function object, but a future version should.

The current version of the projection does not include wrapper classes for delegates, or any public method of explicitly wrapping a delegate.

## Struct

Structs are supported and have usage similar to classes. Structs are not used heavily throughout the runtime, but are sometimes accepted as parameters or returned from properties or methods.

Struct classes extend `ValueType`.

## Enum

Enums are supported, and each enum type is represented by a wrapper class herein referred to as `E`.

`v := E(n)` returns an instance of `E` with integer value `n`. If `n` corresponds to a defined enum member, it is always the same instance. The property `v.n` returns the integer value, while `String(v)`, `v.ToString()` and `v.s` return the name.

A "flags" type enum can have a bitwise combination of values that does not match any single defined member. Each such instance of `E` is typically unique, and should not be compared by reference. The current version of the projection does **not** support:
  - Parsing a string which combines multiple flags.
  - Producing a string representing multiple flags by name (it converts the integer to a string instead).

`E.Parse(value)` attempts to convert the value and return the corresponding integer value. *value* can be:
  - An integer (the current version does not perform validation, and future versions might never validate "flag" enums as it might not be clear which combinations are valid).
  - A string which is the name of a defined enum member (case-insensitive).
  - An instance of `E`.

When an enum value is returned by a property or method, it is automatically wrapped as with `v := E(n)`.

Parameters or properties that expect an enum value can accept any value that would be accepted by `E.Parse(value)`. In other words, it is valid to pass an integer, the string/name of a defined enum member, or an instance of `E`.

For each enum constant, the enum class contains a static property that returns an instance of `E`. For instance, `Windows.Foundation.PropertyType.Boolean` returns an instance of `Windows.Foundation.PropertyType`. This instance can be compared by reference to any instance returned by a property or method.

Enum classes extend `EnumValue`.

## Arrays

Some methods use [array parameters](https://docs.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system#array-parameters). These are not supported in the current version of the projection.

## GUID

GUID is considered a fundamental type for WinRT. It is passed to and returned from methods much the same as a struct, but there is no metadata describing it. The projection uses `class GUID` defined in `guid.ahk` for any GUID value returned to script. When passing a GUID, the current version of the projection requires the script to pass a pointer to a GUID (as integer or via object with `ptr` property).

## HString

HString is the string type used by WinRT. Strings are handled transparently by the projection, and should not be passed by pointer.

If there is any need to deal directly with a HString (such as with a dll function not covered by the projection), the functions in `hstring.ahk` can be used.

## Custom Projections

The projection currently has very few customizations. Some customizations that *could* be implemented to better integrate with AutoHotkey are listed below:

  - Give IVector an `__Item` property to allow access with `vector[index]`, and a Length property.
  - Give IMap an `__Item` property to allow access with `map[key]`, and a Count property.
  - Give IIterable an `__Enum` method to allow use with for loops.
  - Allow primitive values to be passed to `IInspectable` parameters by wrapping them with `PropertyValue`. (Example: TreeViewNode.Content is projected in C# as object, and can be assigned a string.)
  - Automatically convert from `IReference<T>` to `T`, at least when `T` is a primitive type. This is actually what the PropertyValue static methods return, and seems to be the standard type for boxed values returned by properties of type `IInspectable`.
  - Add methods to the various IAsync interfaces to facilitate using Async APIs.
  - Automatically convert Guid to/from string.
