/*
	Name: DUnit.ahk
	Version 0.1 (13.10.22)
	Created: 07.10.22
	Author: Descolada

	Description:
	Unit testing library for AHK v2

    DUnit(TestClasses*)
    Tests the provided test classes sequentially: eq DUnit(TestSuite1, TestSuite2)
    
    A prototype TestClass:
    class TestSuite {
        static Fail() { ; Required static method if Coverage option is used, otherwise is optional.
            throw Error()
        }
        __New() {
            ; Ran before calling a test method from this class
        }
        Begin() {
            ; Ran before calling a test method from this class. Alternative to __New
        }
        __Delete() {
            ; Ran after calling a test method from this class.
        }
        End() {
            ; Ran after calling a test method from this class. Alternative to __Delete
        }
        Test_Func() {
            ; The methods to test. No specific name nomenclature required. The method cannot be static.
        }
    }

    DUnit methods:

    DUnit.True(a, msg := "Not True")
        Checks whether the condition a is not false (0, '', False). msg is the error message displayed.
    DUnit.False(a, msg := "Not False")
        Checks whether the condition a is false (0, '', False). msg is the error message displayed.
    DUnit.Equal(a, b, msg?, compareFunc?)
        Checks conditions a and b for equality. msg is the error message displayed.
        Optionally compareFunc(a,b) can be provided, otherwise Print(a) == Print(b) is used to check equality.
    DUnit.NotEqual(a, b, msg?, compareFunc?)
        Checks conditions a and b for non-equality. msg is the error message displayed.
        Optionally compareFunc(a,b) can be provided, otherwise Print(a) == Print(b) is used to check equality.
    DUnit.Assert(condition, msg := "Fail", n := -1)
        Functionally equivalent to DUnit.True
        n is the What argument for Error()
    DUnit.Throws(func, errorType?, msg := "FAIL (didn't throw)")
        Checks whether the provided func throws an error (optionally the type of the error is checked)
    DUnit.SetOptions(options?)
        Applies or resets DUnit options (see more below)
    
    DUnit properties/options:

    DUnit.Verbose
        Causes DUnit to also report successful tests by name. Otherwise only failed tests are reported.
    DUnit.FailFast
        Causes DUnit to return after the first encountered error.
    DUnit.Coverage
        Calculates the test coverage by the class. This option requires a static Fail() method
        to be implemented in the TestClass. Also the name of the script needs to start with "Test_"
        (that is, if the main script is Script.ahk then the one containing the test class should
        be named Test_Script.ahk).
    Notes about "Coverage": with long functions and multiple tests assertions in one test method
        this might fail to recognize some lines. Also when testing multiple testclasses in a row, then
        the autoexecute part of the testable file might not be recognized. 
        "Coverage" is also quite slow, testing dozens-hundreds of methods might take seconds to even
        minutes. For this reason it is disabled by default. 
    
    The properties can also be provided in the main DUnit() call as a string, and will
    be applied to all tests after the string: "Verbose"/"V", "FailFast"/"F", "Coverage"/"C"
    Example: DUnit("C", TestSuite) will apply Coverage option to TestSuite
    Options can also be applied with SetOptions(options?), where leaving options blank will reset
    to default options.
*/

class DUnit {
    static Verbose := "", FailFast  := "", Coverage := ""
    /**
     * Applies DUnit options
     * @param options Space-separated options to apply: Verbose (V), FailFast (F), Coverage (C). If 
     *     left empty then will reset to default.
     */
    static SetOptions(options?) {
        if IsSet(options) {
            for option in StrSplit(options, " ") {
                Switch option, 0 {
                    case "V", "Verbose":
                        DUnit.Verbose := True
                    case "F", "FailFast":
                        DUnit.FailFast := True
                    case "C", "Coverage":
                        DUnit.Coverage := True
                }
            }
        } else
            DUnit.Verbose := False, DUnit.FailFast := False, DUnit.Coverage := False
    }
    static __New() => DUnit.SetOptions()
    /**
     * New instance will test the provided testClasses, optionally also apply options
     * @param testClasses The classes to be tested
     * @example
     * DUnit(TestSuite1, "V", TestSuite2) ; tests two classes, and applies "Verbose" option for TestSuite2
     */
    __New(testClasses*) {
        this.Print("Beginning unit testing:`n`n")
        totalFails := 0, totalSuccesses := 0, startTime := A_TickCount
        ; First try to capture the auto-execute sections in all the classes
        for testClass in testClasses {
            if testClass is String
                continue
            testClass()
            DUnit.GetCoverage(testClass)
        }
        ; Start the testing for real
        for testClass in testClasses {
            ; If there are any options provided, reset all options and apply new ones.
            if testClass is String { 
                DUnit.SetOptions(testClass)
                continue
            }
            fails := 0, successes := 0, currentListLines := A_ListLines, coverage := 0
            this.Print(Type(testClass()) ": ")
            if DUnit.Coverage && !currentListLines
                ListLines 1
            ; Test all methods in testClass sequentially
            for test in ObjOwnProps(testClass.Prototype) {
                ; Reset environment so one test doesn't affect another
                env := testClass() 
                ; Ignore init/cleanup methods, and Fail (which is only required for "Coverage")
                if !(test ~= "i)^Begin$|^End$|^Fail$") and SubStr(test, 1, 2) != '__' {
                    if env.base.HasOwnProp("Begin")
                        env.Begin()
                    try
                        env.%test%()
                    catch as e {
                        fails++
                        this.Print("`nFAIL: " Type(env) "." test "`n" StrReplace(e.File, A_InitialWorkingDir "\") " (" e.Line ") : " e.Message)
                        if DUnit.FailFast
                            break
                    } else {
                        successes++
                        if DUnit.Verbose
                            this.Print("`nSuccess: " Type(env) "." test)
                    }
                    if env.base.HasOwnProp("End")
                        env.End()
                    if DUnit.Coverage
                        coverage := DUnit.GetCoverage(testClass)
                }
                env := ""
            }
            if DUnit.Coverage && !currentListLines
                ListLines 0
            if !fails {
                this.Print(DUnit.Verbose ? "`nAll pass." : "all pass.")
            } else {
                if DUnit.FailFast {
                    this.Print("`n`n")
                    break
                }
            }
            if DUnit.Coverage
                this.Print("`n---- Test coverage: " coverage "% ----")
            this.Print("`n`n")
            totalFails += fails, totalSuccesses += successes
        }
        this.Print("=========================`nTotal " (totalFails+totalSuccesses) " tests in " Round((A_TickCount-startTime)/1000, 3) "s: " totalSuccesses " successes, " totalFails " fails.")
    }
    /**
     * Checks whether the condition a is True
     * @param a Condition (value) to check
     * @param msg Optional: error message to display
     */
    static True(a, msg := "Not True") => DUnit.Assert(a, msg, -2)
    /**
     * Checks whether the condition a is False
     * @param a Condition (value) to check
     * @param msg Optional: error message to display
     */
    static False(a, msg := "Not False") => DUnit.Assert(!a, msg, -2)
    /**
     * Checks whether two conditions/values are equal
     * @param a First condition
     * @param b Second condition
     * @param msg Optional: error message to display
     * @param compareFunc Optional: the function used to compare the values. By default Print() is used.
     */
    static Equal(a, b, msg?, compareFunc?) {
        currentListLines := A_ListLines
        ListLines 0
        if IsSet(compareFunc) && HasMethod(compareFunc)
            DUnit.Assert(compareFunc(a,b), msg ?? "Not equal", -2)
        else
            DUnit.Assert((pa := DUnit.Print(a)) == (pb := DUnit.Print(b)), msg ?? pa ' != ' pb, -2)
        ListLines currentListLines
    }
    /**
     * Checks whether two conditions/values are not equal
     * @param a First condition
     * @param b Second condition
     * @param msg Optional: error message to display
     * @param compareFunc Optional: the function used to compare the values. By default Print() is used.
     */
    static NotEqual(a, b, msg?, compareFunc?) {
        currentListLines := A_ListLines
        ListLines 0
        if IsSet(compareFunc) && HasMethod(compareFunc)
            DUnit.Assert(!compareFunc(a,b), msg ?? "Are equal", -2)
        else
            DUnit.Assert((pa := DUnit.Print(a)) != (pb := DUnit.Print(b)), msg ?? pa ' == ' pb, -2)
        ListLines currentListLines
    }
    /**
     * Checks whether the condition is not 0, "", or False
     * @param a Condition (value) to check
     * @param msg Optional: error message to display
     * @param n Optional: Error message What argument. Default is -1.
     */
    static Assert(condition, msg := "Fail", n := -1) {
        if !condition
            throw Error(msg?, n)
    }
    /**
     * Checks whether the condition (function) throws an error when called.
     * @param func The function to test
     * @param errorType Optional: checks whether a specific error type needs to be thrown
     * @param msg Optional: Error message to show
     */
    static Throws(func, errorType?, msg := "FAIL (didn't throw)") {
        try 
            func()
        catch as e {
            if IsSet(errorType) && (Type(e) != errorType)
                DUnit.Assert(False, msg)
            return
        }
        DUnit.Assert(false, msg)
    }

    /**
     * Internal method used to print out the results.
     */
    Print(value) => OutputDebug(value)

    /**
     * Internal method used to calculate the tested scripts' effective line-count.
     * It excludes the comments, empty lines, nonfunctional lines ("else", "get", "class" etc), etc.
     * @param file The full path of the file to be analyzed
     */
    static GetScriptEffectiveLineCount(file) {
        static files := Map()
        if files.Has(file)
            return files[file]
        fileContent := FileRead(file)
        
        fileContent := RegExRemove(fileContent, "\/\*[\w\W]*?\*\/") ; remove block comments
        fileContent := RegExRemove(fileContent, "m)^[ \t]*;.*\s*") ; remove single comments
        fileContent := RegExRemove(fileContent, "m)^[ \t\{\}\(\)]*(\s+|$)") ; remove empty lines or ones with brackets
        fileContent := RegexRemove(fileContent, "im)[ \t]*\}?[ \t]*(else|get|set|class .*)[ \t]*\{?(\s+|$)")
        fileContent := StrSplit(fileContent, "`n")
        ; For debugging reasons could display fileContent to see the remaining parts of the script
        return files[file] := fileContent.Length

        RegExRemove(Haystack, Needle) {
            count := 0
            Haystack := RegExReplace(Haystack, Needle,, &count:=0)
            While count
                Haystack := RegExReplace(Haystack, Needle,, &count:=0)
            return Haystack
        }
    }

    /**
     * Internal function used to calculate the coverage and keep track of already visited lines.
     * This needs to be called multiple times after visitid each method in testClass, because
     * ListLines can "overflow" and thus some visited lines might be missed.
     * @param testClass The class currently being tested.
     */
    static GetCoverage(testClass) {
        currentListLines := A_ListLines
        ListLines 0
        static knownClasses := Map()
        classType := Type(testClass())
        if !knownClasses.Has(classType) {
            ; First find the testfile name, which in turn will give us the name of the actual file.
            ; If trying to analyze Script.ahk, then Fail() will give us Test_Script.ahk, then we know
            ; what to look for.
            if !ObjHasOwnProp(testClass, "Fail")
                throw Error("The class " Type(classType) " doesn't have the necessary static Fail method implemented.", -1)
            try testClass.Fail()
            catch as e {
                testLine := e.Line, testFile := e.File
            }
            SplitPath testFile, &file
            if !SubStr(file, 1, 5) = "Test_"
                throw Error("Lib file corresponding to '" file "' not found!")
            file := SubStr(file, 6) ; Trim away "Test_"
            lines := DUnit.ScriptInfo("ListLines")
            ; Try to find the corresponding file in ListLines
            if RegExMatch(lines, "i)---- (.*\Q\" file "\E)\s+", &match)
                filePath := match[1]
            else
                throw Error("Corresponding script file to '" file "' not found in ListLines")
            if !FileExist(filePath)
                throw Error("Script file not found at '" filePath "'")

            ; Now that we have the file, calculate the effective line count (trim away comments, empty lines etc)
            effectiveLineCount := DUnit.GetScriptEffectiveLineCount(filePath)
            thisClass := knownClasses[classType] := Map()
            thisClass["LineCount"] := effectiveLineCount
            thisClass["FilePath"] := filePath
        } else
            lines := DUnit.ScriptInfo("ListLines"), thisClass := knownClasses[classType]
        
        startPos := 1, executedLines := ""
        While startPos := RegExMatch(lines, "im)^---- \Q" thisClass["FilePath"] "\E\s+([\w\W]*?)\n---- ", &match, startPos) {
            ;MsgBox("Found " match.Count " matches at " startPos " + " StrLen(match[0])) ; debugging line
            ;MsgBox(match[0]) ; debugging line
            executedLines .= match[1] "`n"
            for i, val in StrSplit(match[1], "`n") {
                if RegExMatch(val, "^(\d+):", &lineNum:="") ; verify that the line has a line number
                    thisClass[Integer(lineNum[1])] := 1 ; map the line number
            }
            startPos += StrLen(match[])
        }
        ListLines currentListLines
        return Round(((thisClass.Count - 2) / thisClass["LineCount"]) * 100, 1) ; subtract LineCount and FilePath
    }

    /**
     * Prints the formatted value of a variable (number, string, object).
     * Leaving all parameters empty will return the current function and newline in an Array: [func, newline]
     * @param value Optional: the variable to print. 
     *     If omitted then new settings (output function and newline) will be set.
     *     If value is an object/class that has a ToString() method, then the result of that will be printed.
     * @param func Optional: the print function to use. Default is OutputDebug.
     *     Not providing a function will cause the output to simply be returned as a string.
     * @param newline Optional: the newline character to use (applied to the end of the value). 
     *     Default is newline (`n).
     */
    static Print(value?, func?, newline?) {
        static p := "", nl := ""
        if IsSet(func)
            p := func
        if IsSet(newline)
            nl := newline
        if IsSet(value) {
            val := _Print(value) nl
            return HasMethod(p) ? p(val) : val
        }
        return [p, nl]

        _Print(val?) {
            if !IsSet(val)
                return "unset"
            valType := Type(val)
            switch valType, 0 {
                case "String":
                    return "'" StrReplace(StrReplace(StrReplace(val, "`n", "``n"), "`r", "``r"), "`t", "``t") "'"
                case "Integer", "Float":
                    return val
                default:
                    self := "", iter := "", out := ""
                    try self := _Print(val.ToString()) ; if the object has ToString available, print it
                    if valType != "Array" { ; enumerate object with key and value pair, except for array
                        try {
                            enum := val.__Enum(2) 
                            while (enum.Call(&val1, &val2))
                                iter .= _Print(val1) ":" _Print(val2?) ", "
                        }
                    }
                    if !IsSet(enum) { ; if enumerating with key and value failed, try again with only value
                        try {
                            enum := val.__Enum(1)
                            while (enum.Call(&enumVal))
                                iter .= _Print(enumVal?) ", "
                        }
                    }
                    if !IsSet(enum) && (valType = "Object") && !self { ; if everything failed, enumerate Object props
                        for k, v in val.OwnProps()
                            iter .= SubStr(_Print(k), 2, -1) ":" _Print(v?) ", "
                    }
                    iter := SubStr(iter, 1, StrLen(iter)-2)
                    if !self && !iter && !((valType = "Array" && val.Length = 0) || (valType = "Map" && val.Count = 0) || (valType = "Object" && ObjOwnPropCount(val) = 0))
                        return valType ; if no additional info is available, only print out the type
                    else if self && iter
                        out .= "value:" self ", iter:[" iter "]"
                    else
                        out .= self iter
                    return (valType = "Object") ? "{" out "}" : (valType = "Array") ? "[" out "]" : valType "(" out ")"
            }
        }
    }

    /**
     * Returns the text that would have been shown in AutoHotkey's main window if you had called Command, 
     * but without actually showing or activating the window.
     * @param Command must be "ListLines", "ListVars", "ListHotkeys" or "KeyHistory"
     * @author Lexikos
     */
    static ScriptInfo(Command) {
        static hEdit := 0, pfn, bkp, cmds := {ListLines:65406, ListVars:65407, ListHotkeys:65408, KeyHistory:65409}
        if !hEdit {
            hEdit := DllCall("GetWindow", "ptr", A_ScriptHwnd, "uint", 5, "ptr")
            user32 := DllCall("GetModuleHandle", "str", "user32.dll", "ptr")
            pfn := [], bkp := []
            for i, fn in ["SetForegroundWindow", "ShowWindow"] {
                pfn.Push(DllCall("GetProcAddress", "ptr", user32, "astr", fn, "ptr"))
                DllCall("VirtualProtect", "ptr", pfn[i], "ptr", 8, "uint", 0x40, "uint*", 0)
                bkp.Push(NumGet(pfn[i], 0, "int64"))
            }
        }
     
        if (A_PtrSize=8) {  ; Disable SetForegroundWindow and ShowWindow.
            NumPut("int64", 0x0000C300000001B8, pfn[1], 0)  ; return TRUE
            NumPut("int64", 0x0000C300000001B8, pfn[2], 0)  ; return TRUE
        } else {
            NumPut("int64", 0x0004C200000001B8, pfn[1], 0)  ; return TRUE
            NumPut("int64", 0x0008C200000001B8, pfn[2], 0)  ; return TRUE
        }
     
        cmds.%Command% ? DllCall("SendMessage", "ptr", A_ScriptHwnd, "uint", 0x111, "ptr", cmds.%Command%, "ptr", 0) : 0
     
        NumPut("int64", bkp[1], pfn[1], 0)  ; Enable SetForegroundWindow.
        NumPut("int64", bkp[2], pfn[2], 0)  ; Enable ShowWindow.
    
        return ControlGetText(hEdit)
    }
}