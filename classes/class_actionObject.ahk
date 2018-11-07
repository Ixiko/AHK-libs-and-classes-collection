/* Generic, flexible custom class for running or linking to an object, based on both functionally-passed and prompted-for text.
	
	The programmatic entry point is ActionObject.do().
*/

global SUPERTYPE_EPIC := "EPIC"

global TYPE_UNKNOWN := ""
global TYPE_EMC2    := "EMC2"
global TYPE_PATH    := "PATH"

global ACTION_NONE := ""
global ACTION_LINK := "LINK"
global ACTION_RUN  := "RUN"

global SUBTYPE_FILEPATH := "FILEPATH"
global SUBTYPE_URL      := "URL"

global SUBACTION_EDIT := "EDIT"
global SUBACTION_VIEW := "VIEW"
global SUBACTION_WEB  := "WEB"


; Class that centralizes the ability to link to/do a variety of things based on some given text.
class ActionObject {
	; input is either full string, or if action/subaction known, just the main piece (sans actions)
	/* DESCRIPTION:   Main programmatic access point. Calls into helper functions that process given input, prompt for more as needed, then perform the action.
		PARAMETERS:
			input     - The identifier for the thing that we're opening or linking to - can be an ID, URL, filepath, etc.
			type      - From TYPE_* constants above: general type of input.
			action    - From ACTION_* constants above: what you want to actually do with input.
			subType   - From SUBTYPE_* constants above: within a given type, further divisions.
			subAction - From SUBACTION_* constants above: within a given action, further divisions.
		Example: view-only link to DLG 123456:
			ActionObject.do(123456, TYPE_EMC2, ACTION_LINK, "DLG", SUBACTION_VIEW)
	*/
	do(input, type = "", action = "", subType = "", subAction = "") { ; type = TYPE_UNKNOWN, action = ACTION_NONE
		; DEBUG.popup("ActionObject.do", "Start", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
		
		; Clean up input.
		input := getFirstLine(input) ; Comes first so that we can clean from end of first line (even if there are multiple).
		input := cleanupText(input)
		
		; Determine what we need to do.
		this.process(input, type, action, subType, subAction)
		
		; Expand shortcuts and gather more info as needed.
		this.selectInfo(input, type, action, subType, subAction)
		
		; Just do it.
		return this.perform(type, action, subType, subAction, input)
	}
	
	; Based on the parameters given, determines as many missing pieces as we can.
	process(ByRef input, ByRef type, ByRef action, ByRef subType, ByRef subAction) {
		; DEBUG.popup("ActionObject.process", "Start", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
		
		; Do a little preprocessing to pick out needed info. (All args but input are ByRef)
		isPathType := isPath(input, pathType)
		isEMC2ObjectType := isEMC2Object(input, ini, id)
		; DEBUG.popup("ActionObject.process", "Type preprocessing done", "Input", input, "Is path", isPathType, "Path type", pathType, "Is EMC2", isEMC2ObjectType, "INI", ini, "ID", id)
		
		; First, if there's no type (or a supertype), figure out what it is.
		if(type = "") {
			if(isPathType)
				type := TYPE_PATH
			else if(isEMC2ObjectType = 2)
				type := TYPE_EMC2
			else if(isEMC2ObjectType = 1) ; Not specific enough, but false positive OK considering its high usage.
				type := TYPE_EMC2
		; Only test epic things.
		} else if(type = SUPERTYPE_EPIC) {
			if(isEMC2ObjectType) ; Not specific enough, but false positive OK considering its high usage.
				type := TYPE_EMC2
		}
		; DEBUG.popup("ActionObject.process", "Type", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
		
		; Next, determine actions.
		if(action = "") {
			if (type = TYPE_PATH)
			|| (type = TYPE_EMC2)
			{
				action := ACTION_RUN
			}
		}
		; DEBUG.popup("ActionObject.process", "Action", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
		
		; Determine subType as needed.
		if(subType = "") {
			if(type = TYPE_EMC2)
				subType := ini
			else if(type = TYPE_PATH)
				subType := pathType
		}
		; DEBUG.popup("ActionObject.process", "Subtype", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
		
		; Determine subAction as needed.
		if(subAction = "") {
			if(type = TYPE_EMC2)
				subAction := SUBACTION_EDIT
		}
		; DEBUG.popup("ActionObject.process", "Subaction", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
		
		; Update input as needed.
		if(type = TYPE_EMC2)
			input := id
		; DEBUG.popup("ActionObject.process", "Input", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
	}
	
	; Prompt the user for any missing info (generally just subType) via a Selector popup.
	selectInfo(ByRef input, ByRef type, ByRef action, ByRef subType, ByRef subAction) {
		; DEBUG.popup("ActionObject.selectInfo", "Start", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
		
		; Determine if we need subType or subAction based on what we know so far.
		if(type = TYPE_EMC2) {
			needsSubType := true
			needsSubAction := true
		}
		
		if(!type || !action || (!subType && needsSubType) || (!subAction && needsSubAction)) {
			filter := MainConfig.getMachineTableListFilter()
			s := new Selector("local/actionObject.tl", "", filter)
			objInfo := s.selectGui("", {TYPE: type, ACTION: action, SUBTYPE: subType, SUBACTION: subAction, ID: input})
			
			type      := objInfo["TYPE"]
			action    := objInfo["ACTION"]
			subType   := objInfo["SUBTYPE"]
			subAction := objInfo["SUBACTION"]
			input     := objInfo["ID"]
		}
		
		; Additional processing on user-given info as needed.
		if(type = TYPE_EMC2) {
			if(subType) { ; But if it's blank, don't ask the user again.
				s := new Selector("local/actionObject.tl")
				objInfo := s.selectChoice(subType)
				subType := objInfo["SUBTYPE"]
			}
		}
		
		; DEBUG.popup("ActionObject.selectInfo", "Input", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
	}
	
	; Do the action.
	perform(type, action, subType, subAction, input) {
		; DEBUG.popup("ActionObject.perform", "Start", "Input", input, "Type", type, "Action", action, "SubType", subType, "SubAction", subAction)
		
		if(action = ACTION_NONE) {
			return
		} else if(action = ACTION_RUN) {
			if(type = TYPE_EMC2) {
				; If they never gave us a subtype, just fail silently.
				if(!subType)
					return
				
				link := this.perform(TYPE_EMC2, ACTION_LINK, subType, subAction, input)
				; DEBUG.popup("actionObject.perform", "Got link to run", "Link", link)
				
				if(link)
					Run, % link
				
			} else if(type = TYPE_PATH) {
				if(subType = SUBTYPE_FILEPATH) {
					IfExist, %input%
						Run, % input
					Else
						this.errPop("File or folder does not exist", input)
				} else if(subType = SUBTYPE_URL) {
					Run, % input
				}
				
			} else {
				Run, % input
			}
			
		} else if(action = ACTION_LINK) {
			if(type = TYPE_EMC2)
				link := buildEMC2Link(subType, input, subAction)
			
			return link
		} else if(type || action || subType || subAction || input) {
			this.errPop("Missing", "Type", "Type", type, "Action", action, "Subtype", subType, "Subaction", subAction, "Input", input)
		}
	}
	
	errPop(params*) {
		if(isFunc("DEBUG.popup")) {
			DEBUG.popup(params*)
		} else {
			errMsg := ""
			For i,p in params {
				if(mod(i, 2) = 0)
					Continue
				errMsg .= p "`n`t" params[i + 1] "`n"
			}
			MsgBox, % errMsg
		}
	}
}