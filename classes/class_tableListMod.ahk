/* Modification class for parsing lists.
*/

global MODOP_REPLACE := "r"
global MODOP_BEGIN   := "b"
global MODOP_END     := "e"

class TableListMod {
	bit       := 1
	operation := ""
	text      := ""
	label     := 0
	
	__New(b, o, t, l) {
		this.bit       := b
		this.operation := o
		this.text      := t
		this.label     := l
	}
	
	; Actually do what this mod describes to the given row.
	executeMod(rowBits, temp = false) {
		rowBit := rowBits[this.bit]
		
		if(this.operation = MODOP_REPLACE)
			outBit := this.text
		else if(this.operation = MODOP_BEGIN)
			outBit := this.text rowBit
		else if(this.operation = MODOP_END)
			outBit := rowBit this.text
		
		; DEBUG.popup("Row bits", rowBits, "Row bit to modify", rowBit, "Operation", this.operation, "Text", this.text, "Result", outBit, "Begin", MODOP_BEGIN)
		
		; Put the bit back into the full row.
		rowBits[this.bit] := outBit
		
		return rowBits
	}
	
	; Debug info
	debugName := "TableListMod"
	debugToString(debugBuilder) {
		debugBuilder.addLine("Bit",       this.bit)
		debugBuilder.addLine("Operation", this.operation)
		debugBuilder.addLine("Text",      this.text)
		debugBuilder.addLine("Label",     this.label)
	}
}