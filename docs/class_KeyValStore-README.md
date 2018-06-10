# KeyValStore.ahk

> Key-value store for convenient local data persistence for config, caching, etc.. Heavily inspired by [configstore](https://github.com/yeoman/configstore).

Data is stored in XML format.

Requirements: Latest version of [AutoHotkey](https://autohotkey.com/) [v1.1](https://autohotkey.com/download) or [v2.0-a](https://autohotkey.com/v2/)

# Usage:

    #Include <KeyValStore>

    dat := new KeyValStore("test.xml") ; assumed in %A_WorkingDir%
    
    dat.Set("foo", "Some value")
    
    MsgBox % dat.Get("foo") ; displays 'Some value'

    ; use dot notation to access nested properties
    dat.Set("bar.baz", "Another value") ; escape literal dot with '\' e.g.: 'foo.bar\.baz'
    MsgBox % dat.Get("bar.baz") ; 'Another value'

    bar := dat.Get("bar") ; {baz: "Another value"}

    ; get entire contents
    all := dat[] ; {foo: "Some value", bar: {baz: "Another value"}}
    ; set new contents
    dat[] := {hello: "Hello World", ahk: "AutoHotkey"}

    dat.Del("foo") ; delete an item, returns the removed item

    dat.Clear() ; delete all items

    MsgBox % dat.Path ; full path to file