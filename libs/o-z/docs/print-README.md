# Print

A `print()` function for [AutoHotkey](https://autohotkey.com/)

License: [WTFPL](http://wtfpl.net/)

Requirement: Latest version of AutoHotkey [v1.1+](https://autohotkey.com/download) or [v2.0-a](https://autohotkey.com/v2/)

Installation:  Copy into a [function library folder](http://ahkscript.org/docs/Functions.htm#lib)

- - -

### Examples:

_See code comments for additonal info_

#### print()

`print( value [, dest, end, space ] )`

    print("Hello World")
    ; Hello World
    
    print("Hello World", "test.txt", "?")
    ; Writes 'Hello World?' to 'test.txt'
    
    print({foo: "Foo", bar: "Bar"},,, 4) ; indent w/ 4 spaces
    /* Output
    {
        "foo": "Foo",
        "bar": "Bar"
    }
    */
    
    print("Test message", Func("SomeFunc")) ; calls SomeFunc() passing "Test message" 


- - -

#### print_args()

`print_args( args [, sep, dest, end ] )`

    print_args(["Auto", "Hot", "key"]) ; items are joined by a single space by default
    ; Auto Hot key
    
    print_args(["Hello", "World"], "+++")
    ; Hello+++World

- - -

#### print_f()


`print_f( fmt_str, args, [, dest ] )`

    print_f("{2} {1}`n", ["World", "Hello"])
    ; Hello World
    
    print_f("Object: {1}", {foo: "Foo", bar: "Bar"})
    ; Object: {foo:"Foo",bar:"Bar"}