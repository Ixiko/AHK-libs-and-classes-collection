#SingleInstance, Force

#Include <JSON>
#Include <print>
#Include %A_ScriptDir%/../Mustache.ahk

Gui, TestWindow:New, +LastFound +HwndTestWindow_hwnd
Gui, Margin, 10, 10
Gui, Font, s10, Consolas

editWidths := 310
editDoubleWidth := editWidths * 2 + 10
editHeights := 200
listViewHeight := editHeights * 3 + 153
listViewWidth = 400
labelWidths := editWidths * 2 + 10

Gui, Add, Checkbox, gOnlyShowFailedCB vOnlyShowFailedCB Checked Section, Only show failed
Gui, Add, Button, ys gShowLiveEditor, Show live editor
Gui, Add, TreeView, xs gTreeViewLabel vTreeView Section h%listViewHeight% w%listViewWidth% -HScroll

Global TEST_DATA
Global DEBUG

TEST_DATA := ReadTestFiles()
PopulateTreeView(TEST_DATA, true)

Gui, Add, Text, ys Section vTitleLabel w%labelWidths%, Title
Gui, Add, Text, xs vDescLabel w%labelWidths%, Description

Gui, Add, Text, Section, Template
Gui, Add, Edit, xs vTemplateEdit w%editDoubleWidth% h%editHeights%, "Template"

Gui, Add, Text, Section, Tokens
Gui, Add, Edit, vTokensEdit w%editWidths% h%editHeights%, "Tokens"

Gui, Add, Text,, Data
Gui, Add, Edit, vDataEdit w%editWidths% h%editHeights%, "Data"

Gui, Add, Text, ys Section, Expected
Gui, Add, Edit, xs vExpectedEdit w%editWidths% h%editHeights%, "Expected"

Gui, Add, Text,, Actual
Gui, Add, Edit, vActualEdit w%editWidths% h%editHeights%, "Actual"

Gui, Add, Button, x0 y0 gHiddenEnterButton Hidden Default, OK

Gui, Show,, Mustache Tester
return

#if WinActive("Mustache Tester")
    ^r::Reload
#if

TestWindowGuiClose:
    ExitApp
return

HiddenEnterButton:
    ; Why are these fucking treeview models
    ; such a pain to navigate! q_q
    ;
    ; Where is my TV_GetValue(ItemID) function?
return

ShowLiveEditor:

    Gui, LiveEditorWindow:New, +LastFound +HwndLiveEditorWindow_hwnd
    Gui, Margin, 10, 10
    Gui, Font, s10, Consolas

    editWidths := 310
    editDoubleWidth := editWidths * 2 + 10
    editHeights := 200
    listViewHeight := editHeights * 3 + 153
    listViewWidth = 400
    labelWidths := editWidths * 2 + 10

    Gui, Add, Checkbox, Section vLive_UseCompiler, Use compiler
    Gui, Add, Checkbox, xs vLive_Debug, Debug
    Gui, Add, Button, ys gLive_Render, Render

    Gui, Add, Text, xs Section, Template
    Gui, Add, Edit, xs vLive_TemplateEdit w%editDoubleWidth% h%editHeights%, "Template"

    Gui, Add, Text, Section, Tokens
    Gui, Add, Edit, vLive_TokensEdit w%editWidths% h%editHeights%, "Tokens"

    Gui, Add, Text,, Data
    Gui, Add, Edit, vLive_DataEdit w%editWidths% h%editHeights%, "Data"

    Gui, Add, Text, ys Section, Expected
    Gui, Add, Edit, xs vLive_ExpectedEdit w%editWidths% h%editHeights%, "Expected"

    Gui, Add, Text,, Actual
    Gui, Add, Edit, vLive_ActualEdit w%editWidths% h%editHeights%, "Actual"

    Gui, Show,, Live Editor

    LiveEditorWindowClose:
        Gui, LiveEditorWindowClose:Destroy
    return

    Live_Render:
        Gui, Submit, NoHide
        inputData := {}
        inputData.debug := Live_Debug
        inputData.useCompiler := Live_UseCompiler

        GuiControlGet, Live_TemplateEdit
        GuiControlGet, Live_TokensEdit
        GuiControlGet, Live_DataEdit
        GuiControlGet, Live_ExpectedEdit

        inputData.template := Live_TemplateEdit
        inputData.tokens := Live_TokensEdit
        inputData.data := Live_DataEdit
        inputData.expected := Live_ExpectedEdit

        testResult := RunTest(inputData)
        testResult.actual := RegExReplace(testResult.actual, " ", ".")
        GuiControl,, Live_ActualEdit, % testResult.actual
    return
return

OnlyShowFailedCB:
    Gui, Submit, NoHide
    PopulateTreeView(TEST_DATA, OnlyShowFailedCB)
return

TreeViewLabel:
    if (A_GuiEvent != "S" && A_GuiEvent != "DoubleClick")
        return

    selectedItem := A_EventInfo

    ; Ignore parents, they are the test categories
    if (TV_GetChild(selectedItem)) {
        return
    }

    TV_GetText(categoryTitle, TV_GetParent(selectedItem))
    TV_GetText(itemName, selectedItem)

    testState := StrSplit(itemName, " : ")[1]
    testTitle := StrSplit(itemName, " : ")[2]

    for i, category in TEST_DATA {
        if (category.name == Format("{:L}", categoryTitle)) {
            
            for j, test in category.tests {

                if (test.meta.title == testTitle) {
                    if (A_GuiEvent == "DoubleClick") {
                        Run % test.file
                        return
                    }

                    test := ReloadTestData(test)

                    DEBUG := true
                    testResult := RunTest(test)
                    DEBUG := false

                    if (!testResult.state)
                        TV_Modify(selectedItem,, "> F : " testTitle)
                    else 
                        TV_Modify(selectedItem,, "P : " testTitle)

                    UpdateGuiWithTestData(test, testResult.actual)
                }
            }
        }
    }
return

UpdateGuiWithTestData(test, actual) {
    title := test.meta.title
    desc := test.meta.desc

    GuiControl,, TitleLabel, %title%
    GuiControl,, DescLabel, %desc%

    GuiControl,, DataEdit, % test.data
    GuiControl,, TemplateEdit, % test.template
    GuiControl,, TokensEdit, % test.tokens
    GuiControl,, ExpectedEdit, % test.expected
    GuiControl,, ActualEdit, % actual
}

RunTest(test) {

    /* - Test obj structure
    {
        "data": "{}",
        "expected": "",
        "file": "",
        "meta": {
            "desc": "",
            "title": ""
        },
        "template": "",
        "tokens": "",
        "debug": bool,
        "useCompiler": bool
    }
    */

    hashObj := JSON.Load(test.data)

    try {
        tokens := Mustache.Compile(test.template)
        test.tokens := Mustache.Token.StringifyTokens(tokens)
        output := Mustache.Render(tokens, hashObj)
    } catch e {
        msgBox % print(e)
        msgBox % test.file
    }

    if (output == test.expected) {
        return {state: true, actual: output}
    } else {
        return {state: false, actual: output}
    }
}

ReadTestFiles() {
    testRootDir := A_ScriptDir "\test-data"
    
    testData := []
    testCategory := ""

    Loop, Files, %testRootDir%\*, RD
    {
        if (testCategory) {
            testData.Push(testCategory)
        }

        testCategory := {}
        testCategory.name := A_LoopFileName
        testCategory.tests := []

        Loop, Files, %testRootDir%\%A_LoopFileName%\*, F
        {
            testCategory.tests.Push(LoadTest(A_LoopFileFullPath))
        }
    }

    testData.Push(testCategory)
    return testData
}

PopulateTreeView(testData, hidePassed := false) {
    GuiControl, -Redraw, TreeView
    TV_Delete()

    for i, value in testData {
        categoryName := value.name

        treeItem := TV_Add(Format("{:T}", categoryName),, "Expand")

        for j, test in value.tests {
            result := RunTest(test)
            if (result.state) {

                if (!hidePassed)
                    TV_Add("P : " test.meta.title, treeItem)

            }
            else {
                TV_Add("> F : " test.meta.title, treeItem)
            }
        }
    }

    GuiControl, +Redraw, TreeView
}

ReloadTestData(test) {
    newTest := LoadTest(test.file)
    tests := []

    for i, category in TEST_DATA {

        while (_test := category.tests.Pop()) {
            if (_test.file == newTest.file) {
                tests.Push(newTest)
            } else {
                tests.Push(_test)
            }
        }

        category.tests := tests
        tests := []
    }

    return newTest
}

LoadTest(filePath) {
    data := {}
    data.file := filePath

    sectionData := ""

    Loop, Read, %filePath%
    {
        line := A_LoopReadLine

        if (line ~= "^--\w+") {
            ; Save previous section data
            if (sectionData) {
                data[sectionType] := Trim(sectionData, "`n")

                ; Empty section after trim is a no-no
                if (!data[sectionType]) {
                    return {error: "Section is missing data: " sectionType}
                }

                sectionData := ""
            }

            ; Trim leading dashes
            sectionType := Format("{:L}", SubStr(line, 3))
            continue
        }

        sectionData .= line . "`n"
    }

    ; Save last section
    data[sectionType] := Trim(sectionData, "`n")
    
    ; Split meta-data
    metadata := StrSplit(data.meta, "`n")
    data.meta := {title: metadata[1], desc: metadata[2]}

    return data
}

ExtractTokens(rawTokens) {
    tokens := []
    prevToken := {"token": "", "indent": 0}
    parentToken := ""
    previousParent := ""

    Loop, Parse, rawTokens, `n, `r`n
    {
        /*

            Note: This method does not handle jumping between
            multiple indentations very well. We can handle this:

            A
            .. B
            .... C
            .. D

            But not this:
            
            A
            .. B
            .... C
            ...... D
            .. E

            We can only jump back one parent.

            I can't be arsed to figure out proper parent node
            traversal. Hopefully I can get away with this
            until we have a working compiler.

         */

        ; Note: capture must be UNGREEDY, otherwise colons will break us
        RegExMatch(A_LoopField, "UO)^(\s*)\[(.+):(.+)\]", matches)        

        indentLength := StrLen(matches[1])
        type := matches[2]
        value := matches[3]

        rawToken := RegExReplace(A_LoopField, "(\[|\])", "")

        RegExMatch(rawToken, "O)^(\s+)", matches)
        indentLength := StrLen(matches[1])
        token := CreateToken(type, value)

        if (rawToken ~= "^\s+") {
        
            if (prevToken.indent < indentLength) {

                ; We're the first child of a new parent
                previousParent := parentToken
                parentToken := prevToken.token
                parentToken.tokens := []

            } else if (prevToken.indent > indentLength) {

                ; So we need the previous parent...
                parentToken := previousParent

            }
            
            parentToken.tokens.Push(token)

        } else {
            ; Kill the parent
            parentToken := ""
        }

        prevToken.token := token
        prevToken.indent := indentLength

        ; If no parent is present, push stuff
        ; onto the main stack
        if (!parentToken)
            tokens.Push( token )
    }

    return tokens
}

CreateToken(type, value) {
    return {"type": type, "value": value}
}