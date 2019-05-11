/*

mustache manpage - https://mustache.github.io/mustache.5.html
mustache.js reference impl demo - https://codepen.io/sidola/full/jGdJvo/
mustache spec (old) - https://github.com/mustache/spec
Java impl - https://github.com/spullara/mustache.java/blob/master/compiler/src/main/java/com/github/mustachejava/MustacheParser.java#L46

 */

#Include <JSON>
#Include <print>
#Include %A_ScriptDir%/../mustache.ahk
AutoTrim, Off

QuickTest()
;Benchmark()
ExitApp

Esc::ExitApp
^r::reload

Benchmark() {
    SetBatchLines -1 ; The magic happens here

    webData := LoadWebTest()

    compileCount := 500
    renderCount := 500

    Loop % compileCount
    {
        tick := A_TickCount
        tokens := Mustache.Compile(webData.complex, webData.partials)
        compileElapsed += A_TickCount - tick
        ToolTip, Compile %A_Index%
    }

    Loop % renderCount
    {
        tick := A_TickCount
        output := Mustache.Render(tokens, webData.data)
        renderElapsed += A_TickCount - tick
        ToolTip, Render %A_Index%
    }

    ToolTip

    msg := Format("Compile avg ms: {1:}`nRender avg ms: {2:}"
        , Round((compileElapsed/compileCount), 2)
        , Round((renderElapsed/renderCount)))

    msgBox % msg
}

QuickTest() {
template =
(
Before
    {{> header}}
After
)

partial =
(
{{#objectList}}
{{name}}
{{/objectList}}
)

    hash := {}
    hash.bool := true
    hash.array := [1, 2, 3]
    hash.var := "Hello world!"
    hash.objectList := [ {name: "Alice"}, {name: "Bob"}, {name: "Catie"} ]

    partials := {header: partial}

    result := Wrapped_Runner(template, hash, partials)

    lb := "`n------------------`n"
    msgBox % template . lb . result.tokens . lb . result.output . lb
    Clipboard := result.output
}
 
Wrapped_Runner(template, hash, partials := "") {
    ts := A_TickCount

    tokens := Mustache.Compile(template, partials)
    output := Mustache.Render(tokens, hash)

    elapsed := A_TickCount - ts
    TrayTip, Compile + Render MS, %elapsed%, 3

    strTokens := RTrim(Mustache.Token.StringifyTokens(tokens), "`n")
    output := RegExReplace(output, " ", ".")

    return {tokens: strTokens, output: output}
}

LoadWebTest() {
    filePath := A_ScriptDir "/../test/html-test"

    FileRead, simpleTemplate, %filePath%/simple.mustache
    FileRead, complexTemplate, %filePath%/base.mustache

    FileRead, headerPartial, %filePath%/header.mustache
    FileRead, navigationPartial, %filePath%/navigation.mustache
    FileRead, contentPartial, %filePath%/index.mustache
    FileRead, footerPartial, %filePath%/footer.mustache

    FileRead, jsonStr, %filePath%/data.json
    jsonData := JSON.Load(jsonStr)

    partials := {}
    partials.header := headerPartial
    partials.navigation := navigationPartial
    partials.content := contentPartial
    partials.footer := footerPartial

    return {data: jsonData, simple: simpleTemplate, complex: complexTemplate, partials: partials}
}