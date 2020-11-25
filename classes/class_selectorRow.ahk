/* Row data structure class for use in Selector.
	
	Important pieces that actions will want to interact with:
		data[]		- Associative array of other data from the choice. Subscripted using the labels set in the input file's model row.
		isDebug		- True if the user requested that this action be run in debug mode (i.e., don't do the action, just show debug info at the end). Note that the individual action function must check this in order for it to do anything.
		debugResult - Output once we finish running the action in debug mode. Output is determined by the action function.
	
*/
class SelectorRow {
	userInput := ""
	data := []
	isDebug := false
	
	; Constructor.
	__New(arr = "", name = "", abbrev = "", action = "", addActionToTitle = false) {
		if(arr) {
			this.data := arr
			; DEBUG.popup("Constructing", "SelectorRow", "Input array", arr, "Internal data", this.data)
		} else {
			this.data["NAME"] := name
			if(addActionToTitle)
				this.data["NAME"] .= " (" action ")"
			this.data["ABBREV"] := abbrev
			this.data["DOACTION"] := action
		}
	}
	
	buildSelectorRow(title, abbrev, action, addActionToTitle = false) {
		return new SelectorRow()
	}
	
	; Deep copy function.
	clone() {
		temp := new SelectorRow()
		temp.userInput := this.userInput
		
		For l,d in this.data
			temp.data[l] := d
		
		return temp
	}
	
	; Debug info
	debugName := "SelectorRow"
	debugToString(debugBuilder) {
		debugBuilder.addLine("Data",        this.data)
		debugBuilder.addLine("IsDebug",     this.isDebug)
		debugBuilder.addLine("DebugResult", this.debugResult)
	}
}