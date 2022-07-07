I chose not to recognize implicitly-defined members, except for `base`, of primitives or user-defined types because I do not want all primitives and user-defined types to be mistaken for collections.

Implicitly-defined members of Objects (including Arrays) are recognized because they are collections.

I made an exception for `base` because it is useful on any supported type.

I did not distinguish Objects, Arrays, and Exceptions for several reasons:
* They are the same type in AutoHotkey v1.  Only their contents differ.
* When AutoHotkey v2’s type system was more similar to v1, its `Type(Value)` function also returned `"Object"` for all of them.
* It is useful to know that they are the same type because it reveals how to construct them and what operations are compatible with them.
* They cannot reliably be distinguished.  An empty Object and Array are indistinguishable.
* When context makes apparent which is expected, they can still be validated with the help of this library.
* Recognizing Arrays by their contents is very inefficient.
