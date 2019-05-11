#include %A_LineFile%/../../src/MCodeCompileChain.ahk
test := new MCodeCompileChain()
test.selectCompiler("vs")
test.selectPackage("MCodeEx")
test.compile("exampleMCode.c", "exampleMCode.mcode")