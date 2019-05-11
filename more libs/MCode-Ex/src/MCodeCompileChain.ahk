#Include %A_LineFile%/../Compiler/VSCompiler.ahk
#Include %A_LineFile%/../Packages/MCodeExPackage.ahk
#Include %A_LineFile%/../CompileResult.ahk
#Include %A_LineFile%/../Binary.ahk


;a class that makes the parts interact with one another with regards to specific settings
;in order to create the MCode
class MCodeCompileChain {
	
	static compilers := {vs:VSCompiler} ;a list of all valid compilers
	static packages := {MCodeEx:MCodeExPackage}
	
	select(attribute, value) {
		if !this[attribute . "s"]
			throw exception("unknown attribute: " . attribute, -1)
		if IsObject(value) {
			for vName, vObject in this[attribute . "s"] {
				if (vObject = value) {
					valueName := vName
					valueObject := vObject
				}
			}
		} else {
			if (this[attribute . "s"].hasKey(value)) {
				valueName := value
				valueObject := this[attribute . "s", value]
			}
		}
		if (!valueName  || !valueObject) {
			throw exception("invalid value for selection: " . attribute . " : " . value, -1)
		}
		this[attribute] := valueObject
	}
	
	selectCompiler(value) {
		try {
			this.select("compiler", value)
		} catch e {
			e2 := exception("", -1)
			e2.message := e.message
			e2.extra   := e.extra
			throw e2
		}
	}
	
	selectPackage(value) {
		try {
			this.select("package", value)
		} catch e {
			e2 := exception("", -1)
			e2.message := e.message
			e2.extra   := e.extra
			throw e2
		}
	}
	
	compile(inputFile, outputFile) {
		this.compiler.setInputFile(inputFile)
		resultingString := this.package.buildPackage(this.compiler)
		fileOpen(outputFile, "w").write(resultingString)
	}
	
}