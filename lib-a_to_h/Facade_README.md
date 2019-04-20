:warning: **This is pre-alpha software.  The API might change, and it might have defects.** :warning:

# Facade

Facade provides a safe and sane interface to AutoHotkey.

AutoHotkey Problem | Facade Solution
--- | ---
AutoHotkey ignores errors when possible.<br><br>This maximizes the destructiveness of defects and the difficulty of debugging. | Facade reports errors when possible.
AutoHotkey is inconsistent.<br><br>This requires the programmer to remember things that have nothing to do with solving the problem their program is meant to solve and to write code to abstract over differences that should not exist. | Facade is consistent.
AutoHotkey's function objects' `Bind(Args*)` method returns a function object without a `Bind(Args*)` method.<br><br>This is just one example of AutoHotkey's inconsistency.  It makes AutoHotkey's function objects less useful. | Facade's function objects' `Bind(Args*)` method always returns a function object with a `Bind(Args*)` method.
AutoHotkey is verbose.<br><br>This makes writing code difficult by requiring the programmer to write more to describe the same behavior and makes reading code difficult by limiting how much of it the programmer can see at once. | Code written atop Facade is less verbose.
AutoHotkey uses 1-based array indexing.<br><br>This avoids the problem of inexperienced programmers having to spend a few minutes to learn the difference between counting and array indexing by causing the problem of experienced programmers having to forever make adjustments wherever array indexing is used.<br><br>An array index is the distance in elements from the first element, and the distance from the first element to the first element is 0.  Therefore, 0 is the only correct array index base. | Facade makes it possible to avoid using array indexing most of the time by operating on entire arrays.<br><br>Facade uses 0-based array indexing when necessary.  This is an illusion maintained for the sake of the programmer.  Arrays constructed by Facade are still 1-based so that they are compatible with the rest of AutoHotkey.
AutoHotkey Arrays can have missing elements.<br><br>This destroys useful semantics of most array operations. | Facade exclusively uses Arrays without missing elements, except for functions used to convert from and to arrays with missing elements and supporting variadic function calls with missing arguments to cope with AutoHotkey's design.
AutoHotkey makes heavy use of mutable state.<br><br>This makes code difficult to test and reuse. | Facade does not use mutable state.

Facade uses [HashTable](https://github.com/Shambles-Dev/AutoHotkey-HashTable) to solve other AutoHotkey problems.

AutoHotkey Problem | HashTable Solution
--- | ---
AutoHotkey conflates Objects with dictionaries.<br><br>All user-defined types have methods that only make sense for dictionaries. | HashTables were intentionally designed to be dictionaries.
AutoHotkey conflates Objects' interfaces with their contents.<br><br>Storing a string key containing the name of a method clobbers that method. | HashTable uses `Get(Key)` and `Set(Key, Value)` methods to avoid conflating its interface with its contents.
AutoHotkey Objects have unreliable indexing.<br><br>String keys are case-folded and floating point number keys are associated by their current string representation instead of their value. | HashTables have reliable indexing.

Design.txt explains the reasoning behind the design decisions.

Facade is compatible with AutoHotkey v1.

<details>
  <summary><strong>Table of Contents</strong> (click to expand)</summary>

* [Installation](#installation)
* [Usage](#usage)
  * [Validate](#validate)
  * [Op](#op)
  * [Func](#func)
  * [Math](#math)
  * [Array](#array)
  * [Ht](#ht)
  * [Nested](#nested)
</details>


## Installation

The files with an `ahk` file extension from the [Type Checking](https://github.com/Shambles-Dev/AutoHotkey-Type_Checking), [HashTable](https://github.com/Shambles-Dev/AutoHotkey-HashTable), and Facade repositories must be placed in a [library directory](https://autohotkey.com/docs/Functions.htm#lib).


## Usage

Directly calling a function will cause its library to be auto-included.  If the function is only called dynamically or indirectly, its library must be explicitly included.


### Validate

This library contains input validation code used by the other libraries.  It does not contain any code intended for external use.


### Op

This library contains functions corresponding to AutoHotkey's referentially transparent operators.

Functions corresponding to the `%Func%(Args*)`, `not`, `and`, `or` and `?:` operators are in the [Func](#func) library.

These functions are useful as building blocks for constructing functions at run-time.

Function              | Operator                | Corrections
--------------------- | ----------------------- | -----------
`Op_Get(Obj, Key)`    | `Obj[Key]`              | Uses a `Get(Key)` method if present.
`Op_Pow(X, Y)`        | `X ** Y`                |
`Op_Neg(X)`           | `-X`                    |
`Op_BitNot(X)`        | `~X`                    | Works correctly for all values.
`Op_Mul(X, Y)`        | `X * Y`                 |
`Op_Div(X, Y)`        | `X / Y`                 |
`Op_FloorDiv(X, Y)`   | `X // Y`                |
`Op_Add(X, Y)`        | `X + Y`                 |
`Op_Sub(X, Y)`        | `X - Y`                 |
`Op_BitAsl(X, N)`     | `X << N`                | Works correctly for all values of `N`.
`Op_BitAsr(X, N)`     | `X >> N`                | Works correctly for all values of `N`.
`Op_BitAnd(X, Y)`     | `X & Y`                 |
`Op_BitXor(X, Y)`     | `X ^ Y`                 |
`Op_BitOr(X, Y)`      | <code>X &#124; Y</code> |
`Op_Concat(Strings*)` | `A . B`                 | Efficiently concatenates > 2 strings.
`Op_Lt(A, B)`         | `A < B`                 |
`Op_Gt(A, B)`         | `A > B`                 |
`Op_Le(A, B)`         | `A <= B`                |
`Op_Ge(A, B)`         | `A >= B`                |
`Op_EqCi(A, B)`       | `A = B`                 |
`Op_EqCs(A, B)`       | `A == B`                |
`Op_Ne(A, B)`         | `A != B`                |


### Func

This library contains functions that construct and apply functions.

`Func_Bindable(Func)` adapts the `Func` function object to be bindable.  It is useful when the function object is otherwise suited for purpose.

`Func_Applicable(Obj)` adapts the `Obj` object for use as a function object.  These function objects map a key argument to a value return value.  It can be applied to objects that are not dictionaries.  Applicable instances of a type should be accepted anywhere Facade accepts that type unwrapped.  It is useful when a function requires a function object to process data but a lookup in a data structure is desired.

`Func_Apply(Func, Args)` is the A combinator.  It evaluates the `Func` function object with the `Args` Array contents as its arguments.

`Func_Comp(Funcs*)` is the B combinator.  It returns a function object that is the composition of the function objects passed to it.  If no function objects are passed to it, it returns `Func_Id(X)`, its identity element.  Its arguments should be arranged from outermost (leftmost) to innermost (rightmost), as in mathematics.

`Func_Reparam(Func, Positions)` adapts the `Func` function object to have rearranged parameters as specified by integers in the `Positions` Array.  Positions are 0-based.  To omit a parameter, do not specify a position for it.  To duplicate arguments, specify the same position for more than one parameter.  Arguments after the highest specified position are passed in the order they were received so that it can be applied to variadic functions.  It is useful for adapting a function object to the signature required or to move parameters to be bound to the beginning of the signature.

`Func_Flip(F)` is the C combinator.  It adapts the `F(X, Y)` function object to have its first and second parameters flipped.  It is useful for adapting a function object to the signature required or to move a parameter to be bound to the beginning of the signature.

`Func_Id(X)` is the I combinator.  It returns `X`.  It is useful when a function requires a function object to process data but no processing is desired.

`Func_Const(X)` is the K combinator.  It returns a function object that ignores its arguments and returns `X`.  It is useful when a function requires a function object to process data but the data is irrelevant.

`Func_On(G, F)` is the P combinator.  It accepts the function objects `G(X, Y)` and `F(X)` and returns a function object that accepts the arguments `X` and `Y` and evaluates `G(F(X), F(Y))`.  It is useful for constructing predicates for filtering (when the first argument is bound) and sorting.

`Func_Hook1(G, F)` is the S combinator.  It accepts the function objects `G(X, Y)` and `F(X)` and returns a function object that accepts the argument `X` and evaluates `G(X, F(X))`.

`Func_Hook2(G, F)` accepts the function objects `G(X, Y)` and `F(X)` and returns a function object that accepts the arguments `X` and `Y` and evaluates `G(X, F(Y))`.

`Func_Fork(F, H, G)` accepts the function objects `F(Args*)`, `H(X, Y)`, and `G(Args*)` and returns a function object that accepts an arbitrary number of arguments `Args*` and evaluates `H(F(Args*), G(Args*))`.

`Func_Dup(F)` is the W combinator.  It adapts the `F(X, Y)` function object to have its first argument duplicated as its second argument.

`Func_Not(Pred)` accepts the `Pred(Args*)` function object and returns a function object that accepts an arbitrary number of arguments `Args*` and evaluates `not Pred(Args*)`.

`Func_And(Preds*)` returns a function object that accepts an arbitrary number of arguments and evaluates the `Preds*` function objects from leftmost to rightmost with those arguments until a predicate returns `false`, in which case it returns `false`, or it runs out of predicates, in which case it returns `true`.  This short-circuit evaluation is sometimes required for termination.  If no function objects are passed to `Func_And(Preds*)`, it returns `Func_Const(true)`, its identity element.

`Func_Or(Preds*)` returns a function object that accepts an arbitrary number of arguments and evaluates the `Preds*` function objects from leftmost to rightmost with those arguments until a predicate returns `true`, in which case it returns `true`, or it runs out of predicates, in which case it returns `false`.  This short-circuit evaluation is sometimes required for termination.  If no function objects are passed to `Func_Or(Preds*)`, it returns `Func_Const(false)`, its identity element.

`Func_If(Pred, ThenFunc, ElseFunc)` accepts the function objects `Pred(Args*)`, `ThenFunc(Args*)`, and `ElseFunc(Args*)` and returns a function object that accepts an arbitrary number of arguments `Args*` and evaluates `Pred(Args*) ? ThenFunc (Args*) : ElseFunc(Args*)`.

`Func_Conv(F)` is a fixed-point combinator like the Y and Z combinators.  It accepts the function object `F(X)` and returns a function object that accepts the argument `X`.  During the first iteration, `X`'s value is passed to `F(X)`.  During later iterations, `F(X)`'s return value is passed to `F(X)`.  The loop terminates when `F(X)` returns the same value as the preceding iteration.  The return value is the last return value of `F(X)`.  It is useful for constructing functions that use convergence.

`Func_Adverse(Funcs*)` returns a function object that accepts an arbitrary number of arguments and evaluates the `Funcs*` function objects from leftmost to rightmost with those arguments until a function succeeds (does not throw an exception), in which case it returns that function's return value, or it runs out of functions, in which case it throws the exception the last function threw.  It is useful for specifying failsafes for partial functions and functions that can experience system errors.


### Math

This library contains functions corresponding to AutoHotkey's [math](https://autohotkey.com/docs/commands/Math.htm) functions.  To call the equivalent function with error handling, prepend `Math_` to its name.

Some corrections were made.

`Math_Mod(X, Y)` uses floor division (like `//`), instead of truncation.

`Math_Rem(X, Y)` is the remainder function (what AutoHotkey calls `Mod(X, Y)`).

`Math_Round(X, N)` uses the round half to even tie-breaking rule, instead of round away from zero.

This library also includes some new functions.

`Math_BitLsr(X, N)` performs logical shift right on the integer `X` `N` places.

`Math_Bin(X)` converts the integer `X` to a string containing its representation in binary.

`Math_Hex(X)` converts the integer `X` to a string containing its representation in hexadecimal.

`Math_Integer(X)` converts the number or string containing the representation of a number `X` to an integer.  It can convert strings containing the representation of an integer in binary.  It does not corrupt the sign bit of hexadecimal numbers, unlike AutoHotkey's built-in conversion.  Floating-point numbers are truncated.

`Math_Float(X)` converts the number or string containing the representation of a number `X` to a floating-point number.  It can convert strings containing the representation of an integer in binary.  It does not corrupt the sign bit of hexadecimal numbers, unlike AutoHotkey's built-in conversion.


### Array

This library contains functions that construct and process Arrays.

`Array_Fill(Func, Array [, Length])` returns a copy of `Array` with missing elements filled with the value returned by the `Func(N)` function object, where `N` is the 0-based index.  The optional `Length` argument can be used to fill trailing missing elements.  It is useful for adapting an Array for use with Facade or constructing an Array algorithmically (e.g. `Array_Fill(Func("Func_Id"), [], 3)` returns `[0, 1, 2]`).

`Array_Empty(Pred, Array)` returns a copy of `Array` with missing elements where the `Pred(N, X)` function object returned `true`, where `N` is the 0-based index and `X` is the value.  It tolerates Array arguments with missing elements.  It is useful for adapting an Array for use with AutoHotkey procedures that require missing elements.

`Array_Length(Array)` returns the length of `Array`.

`Array_Index(Array, N)` returns the value at `Array`'s `N` 0-based index.  Negative indices are relative to the end of the Array.  It is useful when the index is computed (e.g. when using modulo to access an Array like a circular buffer).

`Array_Slice(Array, Start, Stop)` returns an Array containing the values of `Array` from `Start` to `Stop`, where `Start` and `Stop` denote the interval [`Start`, `Stop`) of 0-based indices.  Negative indices are relative to the end of the Array.  Indices are clamped to bounds.  If `Start` >= `Stop`, it returns an empty Array.

`Array_Concat(Arrays*)` returns an Array that is the concatenation of the Arrays passed to it.  If no Arrays are passed to it, it returns an empty Array, its identity element.  It is more efficient to concatenate > 2 Arrays with a single call because it only allocates and copies once.

`Array_GetMany(Keys, Obj)` accepts a `Keys` Array and an `Obj` object and returns an Array containing the respective values.  It can read the properties of objects that are not dictionaries.  It is useful for constructing Arrays for use as function arguments.

`Array_FoldL(Func, Init, Array)` returns the result of applying the `Func(A, X)` combining function object, where `A` is the accumulator and `X` is the value, recursively to the elements of `Array` from left (first) to right (last).  The accumulator is on the left so that the recursive explanation of the expression tree makes sense.  `Init` is often `Func(A, X)`'s identity element.  If `Array` is empty, `Init` is returned.  If `Array` is not empty, `Init` is the initial value of `A`.  It is useful for iterating over an Array.

`Array_FoldR(Func, Init, Array)` returns the result of applying the `Func(X, A)` combining function object, where `X` is the value and `A` is the accumulator, recursively to the elements of `Array` from right (last) to left (first).  The accumulator is on the right so that the recursive explanation of the expression tree makes sense.  `Init` is often `Func(X, A)`'s identity element.  If `Array` is empty, `Init` is returned.  If `Array` is not empty, `Init` is the initial value of `A`.  It is useful for iterating over an Array.

`Array_FoldL1(Func, Array)` is like `Array_FoldL(Func, Init, Array)` except that the initial value of the accumulator is the leftmost (first) element of `Array`.  `Array` must not be empty.  If `Array` contains 1 element, that element is returned.  It is useful when `Func(A, X)` has no identity element.

`Array_FoldR1(Func, Array)` is like `Array_FoldR(Func, Init, Array)` except that the initial value of the accumulator is the rightmost (last) element of `Array`.  `Array` must not be empty.  If `Array` contains 1 element, that element is returned.  It is useful when `Func(X, A)` has no identity element.

`Array_Filter(Pred, Array)` returns an Array constructed by left folding over `Array` and appending values that the `Pred(X)` function object returned `true` for, where `X` is the value.

`Array_Unique(Array)` filters `Array` to remove trailing duplicates.  Trailing duplicates need not be consecutive.

`Array_Map(Func, Array)` returns an Array constructed by folding over `Array` and setting the same index to the value returned by the `Func(X)` function object, where `X` is the value.

`Array_Reverse(Array)` returns an Array constructed by folding over `Array` to reverse the order of the elements.  It is useful for correcting the order of the elements in an Array that was constructed by appending because prepending is less efficient.

`Array_Sort(Pred, Array)` returns a copy of `Array` sorted according to the `Pred(A, B)` less than function object (e.g. to sort an Array of numbers or strings in descending order, use `Array_Sort(Func("Op_Gt"), Array)`).  It is a stable sort, so it can be used to sort within different criteria (e.g. to sort by grade within age, first sort by grade, then sort by age).

`Array_Zip(Arrays*)` accepts 0 or more Arrays and returns an Array containing Arrays where the nth Array contains the nth element from each of the argument Arrays (e.g. `Array_Zip(["a", "b"], [1, 2])` returns `[["a", 1], ["b", 2]]`).  The Arrays must be the same length.  If no Arrays are passed to it, it returns an empty Array.  To invert the operation, apply it to the result or call it variadically with the result (e.g. `Array_Zip([["a", 1], ["b", 2]]*)` returns `[["a", "b"], [1, 2]]`).  It is useful for constructing Arrays for use as arguments to HashTable's constructor.


### Ht

This library contains functions that construct and process HashTables.

Many functions in this library process items, key-value pairs.  An item is represented as an Array containing a key and a value, in that order.

`Ht(Items*)` is the HashTable constructor.  It returns a HashTable containing the items passed to it.

`Ht_FromObject(Object)` returns a HashTable containing the items from `Object` (a dictionary).  It is useful for converting an Object (dictionary) for use with Facade.

`Ht_ToObject(HashTable)` returns an Object (dictionary) containing the items from `HashTable`.  `HashTable` must not contain keys that would collide when case-folded.  It is useful for converting a HashTable for use with AutoHotkey procedures that require an Object (dictionary).

`Ht_Count(HashTable)` returns the count of the items in `HashTable`.

`Ht_HasKey(Key, HashTable)` returns whether the `Key` exists in `HashTable`.

`Ht_GetMany(Keys, Obj)` accepts a `Keys` Array and an `Obj` object and returns a HashTable containing the respective items.  It can read the properties of objects that are not dictionaries.  It is useful for constructing HashTables containing a subset of the items in a HashTable.

`Ht_SetMany(Defaults, HashTable)` accepts two HashTables and returns a HashTable of the items from both HashTables where the values from `Defaults` are only used if the same key does not exist in `HashTable`.  It is useful for constructing HashTables containing a superset of the items in a HashTable or implementing configuration data defaults.

`Ht_Fold(Func, Init, HashTable)` returns the result of applying the `Func(A, X)` combining function object, where `A` is the accumulator and `X` is the item, recursively to the items from `HashTable`.  `Init` is often `Func(A, X)`'s identity element.  If `HashTable` is empty, `Init` is returned.  If `HashTable` is not empty, `Init` is the initial value of `A`.  It is useful for iterating over a HashTable.

`Ht_Fold1(Func, HashTable)` is like `Ht_Fold(Func, Init, HashTable)` except that the initial value of the accumulator is an item from `HashTable`.  `HashTable` must not be empty.  If `HashTable` contains 1 item, that item is returned.  It is useful when `Func(A, X)` has no identity element.

`Ht_Filter(Pred, HashTable)` returns a HashTable constructed by folding over `HashTable` and inserting items that the `Pred(X)` function object returned `true` for, where `X` is the item.

`Ht_Map(Func, HashTable)` returns a HashTable constructed by folding over `HashTable` and inserting items returned by the `Func(X)` function object, where `X` is the item.

`Ht_Invert(HashTable)` returns a HashTable constructed by mapping over `HashTable` to invert the items.  `HashTable` must not contain duplicate values.  It is useful for implementing a bimap.

`Ht_Items(HashTable)` returns an Array containing the items from `HashTable`.

`Ht_Keys(HashTable)` returns an Array containing the keys from `HashTable`.

`Ht_Values(HashTable)` returns an Array containing the values from `HashTable`.


### Nested

This library contains functions that construct and process nested dictionaries (Objects and HashTables).  It is useful for processing configuration data.

`Path` is an Array of keys.  An empty `Path` is valid.

`Nested_Count(Path, Dict)` traverses the `Path` beginning at `Dict` and returns the count of the items in the dictionary at the end.  If the `Path` is empty, it returns the count of the items in `Dict`.

`Nested_HasKey(Path, Dict)` returns whether the `Path` beginning at `Dict` exists.  If the `Path` is empty, it returns `true`.

`Nested_Get(Path, Dict)` traverses the `Path` beginning at `Dict` and returns the value of the item in the dictionary at the end.  If the `Path` is empty, it returns `Dict`.

`Nested_Set(Path, Value, Dict)` returns a copy of the nested dictionaries along the `Path` beginning at `Dict` with the value of the item in the dictionary at the end set to `Value`.  If the `Path` is empty, it returns a copy of `Dict`.

`Nested_Update(Path, Func, Dict)` returns a copy of the nested dictionaries along the `Path` beginning at `Dict` with the value of the item in the dictionary at the end set to the return value of the `Func(X)` function object, where `X` is the current value.  If the `Path` is empty, it returns a copy of `Dict`.  It is equivalent to `Nested_Set(Path, Func(Nested_Get(Path, Dict)), Dict)`, but it is more efficient because it only performs one traversal.

`Nested_Delete(Path, Dict)` returns a copy of the nested dictionaries along the `Path` beginning at `Dict` with the item associated with the key at the end deleted from the dictionary at the end.  If the `Path` is empty, it returns a copy of `Dict`.
