Plaster
=======

Plaster provides most of the type system features most dynamically type-checked programming languages have built-in, but AutoHotkey is missing.  It also corrects flaws in the type system where doing so is possible via a library.

Plaster replaces the built-in `Object` and `Array` functions with versions that produce values that can be recognized by `IsType` without checking the type and value of all their keys, and that report errors when passed invalid arguments, or when setting or getting invalid keys and indices.  Since curly and square bracket notation is converted to calls to `Object` and `Array`, dictionaries ('objects') and arrays created using that syntax have the same improvements.

```AutoHotkey
;===============================================================================
; Examples of Improved Dictionary and Array Error Handling
;===============================================================================

ADict := Object("a", 1, "b")  ; throws Exception("type error",, "Object(""a"", 1, ""b"") odd number of arguments")

ADict := Object("HasKey", false)  ; throws Exception("key error",, "Dict key ""HasKey"" would overwrite a built-in member")
ADict := {"HasKey": false}        ; ditto

ADict := {}
ADict["_NewEnum"] := false  ; throws Exception("key error",, "Dict key ""_NewEnum"" would overwrite a built-in member")

ADict := {"a": 1}["b"]  ; throws Exception("key error",, "Dict key ""b"" does not exist")


AArray := []
AArray["a"] := false  ; throws Exception("type error",, "Array index ""a"" is not an Int")

AArray := []
AArray[0] := false  ; throws Exception("index error",, "Array index 0 < 1")

AArray := [1, 2, 3][9001]  ; throws Exception("index error",, "Array index 9001 does not exist")
```

`IsType` is a function that lets you test if a value is of a particular type.  It handles both built-in and user-defined types.  Types are organized into a hierarchy.

Programmers often introduce new subtypes when they want to make something that imitates something else (e.g. an object that imitates `Func`) or is a more specific version of something else (e.g. an `Array` of `Bool`).  `IsType` is often used to check that the arguments passed to a function or method are of the expected type before operating on them.  You can use it to indicate which guarantees you expect of arguments, and what members (properties and methods) you expect to be on them.

```AutoHotkey
;===============================================================================
; Examples of Using "IsType"
;===============================================================================

;-------------------------------------------------------------------------------
; Built-In Object Types
;-------------------------------------------------------------------------------

MsgBox, % IsType.({"a": 1, "b": 2}, "Dict")   ; Shows 1, true.  Dictionaries are dictionaries.
MsgBox, % IsType.([1, 2, 3], "Dict")          ; Shows 1, true.  Arrays are dictionaries.
MsgBox, % IsType.({"a": 1, "b": 2}, "Array")  ; Shows 0, false.  Dictionaries are not arrays.
MsgBox, % IsType.([1, 2, 3], "Array")         ; Shows 1, true.  Arrays are arrays.

;-------------------------------------------------------------------------------
; Built-In Non-Object Types
;-------------------------------------------------------------------------------

MsgBox, % IsType.(1, "Int")   ; Shows 1.  1 is an integer.
MsgBox, % IsType.(5, "Int")   ; Shows 1.  5 is an integer.
MsgBox, % IsType.(1, "Bool")  ; Shows 1.  1 is a Boolean.
MsgBox, % IsType.(5, "Bool")  ; Shows 0.  5 is not a Boolean.

;-------------------------------------------------------------------------------
; User-Defined Types
;-------------------------------------------------------------------------------

class A {
}

class B extends A {
}

MsgBox, % IsType.(new A(), "A")  ; Shows 1.  "A"s are "A"s.
MsgBox, % IsType.(new B(), "A")  ; Shows 1.  "B"s are "A"s.
MsgBox, % IsType.(new A(), "B")  ; Shows 0.  "A"s are not "B"s.
MsgBox, % IsType.(new B(), "B")  ; Shows 1.  "B"s are "B"s.

;-------------------------------------------------------------------------------
; User-Defined Types Imitating Built-In Types
;-------------------------------------------------------------------------------

class MyMod {
    static BuiltInBase := "Func"

    static Name       := "MyMod"
    static IsBuiltIn  := false
    static IsVariadic := false
    static MinParams  := 2
    static MaxParams  := 2

    __Call(MethodName, X, Y) {
        if (MethodName == "") {
            return Mod(X, Y)
        }
    }

    IsByRef(ParamsIndex := "") {
        return    (ParamsIndex == "")
               or (    IsType.(ParamsIndex, "Int")
                   and (1 <= ParamsIndex) and (ParamsIndex <= 2))
               ? false
               : ""
    }

    IsOptional(ParamsIndex := "") {
        return    (ParamsIndex == "")
               or (    IsType.(ParamsIndex, "Int")
                   and (1 <= ParamsIndex) and (ParamsIndex <= 2))
               ? false
               : ""
    }
}

MsgBox, % IsType.(Func("Mod"), "Func")  ; Shows 1.
MsgBox, % IsType.(new MyMod(), "Func")  ; Shows 1.

MsgBox, % Func("Mod").(5, 3)  ; Shows 2.
MsgBox, % new MyMod().(5, 3)  ; Shows 2.
```

`HasProperty` and `HasMethod` are functions that let you test if a value has a property or method.  They serve a similar purpose to interfaces in Java, or type classes in Haskell.

Limiting the arguments you accept to a particular type is often too restrictive.  You may not need all the guarantees, and all the members, of a type; you only need to know if performing a particular operation will work.  When this is the case it is usually communicated by the presence of certain properties and methods.  For example, if you wanted to know if an argument can be iterated over, you could use `HasMethod` to check for `_NewEnum`.

```AutoHotkey
;===============================================================================
; Examples of Using "HasProperty" and "HasMethod"
;===============================================================================

;-------------------------------------------------------------------------------
; Built-In Object Types
;-------------------------------------------------------------------------------

MsgBox, % HasProperty.(Func("Mod"), "Name")           ; Shows 1.
MsgBox, % HasProperty.(Func("Mod"), "WrongProperty")  ; Shows 0.

; HasMethod(Value, MethodName, MinParams, MaxParams, IsVariadic)
MsgBox, % HasMethod.(Func("Mod"), "IsOptional", 1, 2, false)   ; Shows 1.
MsgBox, % HasMethod.(Func("Mod"), "WrongMethod", 1, 2, false)  ; Shows 0.

;-------------------------------------------------------------------------------
; Built-In Non-Object Types
;-------------------------------------------------------------------------------

class DefaultBase {
    static AProperty := true

    AMethod() {
        return "affirmative"
    }
}

"".base.base := new DefaultBase()

MsgBox, % HasProperty.(3.1415, "AProperty")      ; Shows 1.
MsgBox, % HasProperty.(3.1415, "WrongProperty")  ; Shows 0.

MsgBox, % HasMethod.("foo", "AMethod", 1, 1, false)      ; Shows 1.
MsgBox, % HasMethod.("foo", "WrongMethod", 1, 1, false)  ; Shows 0.

;-------------------------------------------------------------------------------
; User-Defined Types
;-------------------------------------------------------------------------------

class UserDefined {
    static AProperty := true

    AMethod() {
        return "affirmative"
    }
}

MsgBox, % HasProperty.(new UserDefined(), "AProperty")      ; Shows 1.
MsgBox, % HasProperty.(new UserDefined(), "WrongProperty")  ; Shows 0.

MsgBox, % HasMethod.(new UserDefined(), "AMethod", 1, 1, false)      ; Shows 1.
MsgBox, % HasMethod.(new UserDefined(), "WrongMethod", 1, 1, false)  ; Shows 0.
```

`Repr` is a function that returns the string representation of an AutoHotkey value.  User-defined types can control what it reports for them.

`Repr` is often used to include data structures or arbitrary types (e.g. when an argument was of the wrong type) in exception messages, or with `MsgBox` for debugging.  You could use it for serialization, but AutoHotkey does not have `eval`, so a deserializer would have to be written.  You could use it to implement a REPL for AutoHotkey (since it does not have one), to show the user the result of running the code they entered.

```AutoHotkey
;===============================================================================
; Examples of Using "Repr"
;===============================================================================

; All of the following assume you have not used "SetFormat" to change the
; formatting of integers and floating point numbers from default.

; First, the point...
MsgBox, % [1, 2, 3]  ; Shows:
                     ; That is right, nothing.

;-------------------------------------------------------------------------------
; Built-In Types
;-------------------------------------------------------------------------------

MsgBox, % Repr.(ComObjCreate("Scripting.Dictionary"))  ; Shows: <ComObj IDictionary at 0x0000000001234567>
                                                       ; The address will, of course, vary.

MsgBox, % Repr.({"a": 1})  ; Shows: {"a": 1}

MsgBox, % Repr.([1, 2, 3])  ; Shows: [1, 2, 3]

MsgBox, % Repr.(Func("Mod"))  ; Shows: Func("Mod")

MsgBox, % Repr.("foo")  ; Shows: "foo"
                        ; The quotes are included.  Characters will appear as
                        ; escape sequences as necessary.

MsgBox, % Repr.(3.1415)  ; Shows: 3.1415

MsgBox, % Repr.(42)  ; Shows: 42

Mess1 := {"get": "really"}
Mess2 := ["can", Mess1, "cute"]
Mess3 := {"you": Mess2}
MsgBox, % Repr.(Mess3)           ; Shows: {"you": ["can", {"get": "really"}, "cute"]}

;-------------------------------------------------------------------------------
; User-Defined Types
;-------------------------------------------------------------------------------

class WithoutRepr {
}

class WithRepr {
    Repr() {
        ; A class's "Repr" method ideally returns an expression that will
        ; recreate the object.
        return "new WithRepr()"
    }
}

MsgBox, % Repr.(new WithoutRepr())  ; Shows: <WithoutRepr at 0x0000000001234567>
MsgBox, % Repr.(new WithRepr())     ; Shows: new WithRepr()
```

Plaster provides function references for each of its functions.  The `IsType`, `HasProperty` and `HasMethod`, and `Repr` examples use them, and show the preferred way to call those functions.  The function references are useful for techniques like functional programming and Lisp-like advice.  Advising functions only works correctly if you remember to always call the function through its reference.  That is impractical for `Object` and `Array`, so you should not try to instrument them.

Plaster.ahk documents each function in detail in comments.

Design.txt explains the reasoning behind the design choices.

To-Do.txt lists unfinished features.

Plaster is currently designed for AutoHotkey L v1.  It may be ported to v2 in the future.
