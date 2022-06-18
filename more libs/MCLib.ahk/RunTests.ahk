#Include %A_ScriptDir%

#Include Yunit\Yunit.ahk
#Include Yunit\Window.ahk
#Include Yunit\Stdout.ahk

#Include MCLib.ahk

Tester := Yunit.Use(YunitStdout, YunitWindow)

Read(File) {
    return FileOpen(File, "r").Read()
}

class MCLibTests {
    class C {
        Begin() {
            SetWorkingDir, %A_ScriptDir%/Tests/C
        }

        ReturnSingleValue() {
            pCode := MCLib.FromC(Read("ReturnSingleValue.c"))

            Result := DllCall(pCode, "Int")
            Yunit.Assert(Result == 2390)
        }

        ManualFunctionImport() {
            pCode := MCLib.FromC(Read("ManualFunctionImport.c"))

            Result := DllCall(pCode, "WStr", "2390", "Int")
            Yunit.Assert(Result == 2390)
        }

        PassLotsOfParameters() {
            pCode := MCLib.FromC(Read("PassLotsOfParameters.c"))

            Result := DllCall(pCode, "Int", 2000, "Int", 150, "Int", 150, "Int", 60, "Int", 30, "Int")
            Yunit.Assert(Result == 2390)

            Result := DllCall(pCode, "Int", 1000, "Int", 1000, "Int", 1000, "Int", 1000, "Int", 1000, "Int")
            Yunit.Assert(Result == 5000)
        }

        BasicFloatMath() {
            pCode := MCLib.FromC(Read("BasicFloatMath.c"))

            Result := DllCall(pCode, "Double", 3.1, "Double", 2.8, "Double")
            Yunit.Assert(Abs(Result - 12.98) < 0.0001)
        }

        ReturnSingleValueWithHeader() {
            pCode := MCLib.FromC(Read("ReturnSingleValueWithHeader.c"))

            Result := DllCall(pCode, "Int")
            Yunit.Assert(Result == 2390)
        }

        AllocateMemoryAndWriteString() {
            pCode := MCLib.FromC(Read("AllocateMemoryAndWriteString.c"))

            pResult := DllCall(pCode, "Ptr")

            Yunit.Assert(StrGet(pResult, "UTF-8") == "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "C code generated incorrect string '" StrGet(pResult, "UTF-8") "'")
        }

        Library() {
            Library := MCLib.FromC(Read("Library.c"))

            Yunit.Assert(IsObject(Library))

            TestString := "ABC|DEF"

            PipePosition := DllCall(Library.Find, "AStr", TestString, "Int", Chr("|"), "Int")
            Yuint.Assert(PipePosition == 3)

            ReferenceHash := DllCall(Library.Hash, "AStr", "DEF")
            ActualHash := DllCall(Library.Hash, "AStr", SubStr(TestString, PipePosition))
            
            Yuint.Assert(ReferenceHash == ActualHash)
        }

        Relocations() {
            pCode := MCLib.FromC(Read("Relocations.c"))

            for k, String in ["Hello", "Goodbye", "dog", "cat"] {
                pEntry := DllCall(pCode, "Int", k - 1, "Ptr")

                pString := NumGet(pEntry + 0, 0, "Ptr")

                Yunit.Asser(StrGet(pString, "UTF-8") = String)
            }
        }
    }

    class CPP {
        Begin() {
            SetWorkingDir, %A_ScriptDir%/Tests/CPP
        }

        New() {
            pCode := MCLib.FromCPP(Read("New.cpp"))

            pPoint := DllCall(pCode, "Int", 20, "Int", 30, "Ptr")

            Yunit.Assert(NumGet(pPoint+0, 0, "Int") = 20)
            Yunit.Assert(NumGet(pPoint+0, 4, "Int") = 30)
        }

        Spooky() {
            pCode := MCLib.FromCPP(Read("Spooky.cpp"))

            Success := DllCall(pCode)

            Yunit.Assert(Success = -1)
        }
    }

    class Packed {

    }
}

Tester.Test(MCLibTests)