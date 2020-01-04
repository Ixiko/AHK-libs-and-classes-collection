
#include %A_LineFile%\..
#include DbgOut.ahk

class Colory {
	/*
	Class: Colory
	Handling colors
		
	Adapted from Color (https://msdn.microsoft.com/en-us/library/gg427627.aspx)
		
	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original	
		
	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.	
	*/
	_version := "0.1.0"
	_debug := 0
	a := 0
	r := 0
	g := 0
	b := 0
	
	; ##################### Start of Properties ############################################################################
	debug[] {
	/* ------------------------------------------------------------------------------- 
	Property: debug [get/set]
	Debug flag for debugging the object
			
	Value:
	flag - *true* or *false*
	*/
		get {
			return this._debug
		}
		set {
			mode := value<1?0:1
			this._debug := mode
			return this._debug
		}
	}
	hex[] {
	/* ------------------------------------------------------------------------------- 
	Property: hex [get]
	Get hex-color value
	*/
		get {
			return format("0x{1:02x}{2:02x}{3:02x}", this.r, this.g, this.b)
		}
	}
	/* --------------------------------------------------------------------------------------
	Method: dump()
	Dumps object to a string
		
	Returns:
	printable string containing object properties
	*/
	dump() {
		return this.toJSON()
	}
	; ##################### End of Properties ##############################################################################
	/* ---------------------------------------------------------------------------------------
	Method: fromRGB(obj)
	Constructor - Fills values from given hex value
	
	Parameters:
	new - <Colory at http://hoppfrosch.github.io/AHK_Tooly/files/Colory.html>
	
	Returns:
	new instance of this class
	*/
	fromRGB(hex) {
		global debug
		Red   := ((hex & 0xFF0000) >> 16)
		Green := ((hex & 0x00FF00) >> 8)
		Blue  :=  (hex & 0x0000FF)
		obj := new Colory(,Red,Green,Blue,debug)
		dbgOut("=[" A_ThisFunc "hex:" hex ")] -> " obj.toJSON(), this.debug)
		return obj
	}
	/* -------------------------------------------------------------------------------
	Method:	fromJSON
	Constructor - extracts info from a JSON string into a new instance
	
	Parameters:
	str - JSON-string
	
	Returns:
	new instance of this class
	*/
	fromJSON(str) {
		dbgOut("=[" A_ThisFunc "(str=" str ")]", this._debug)
		objJSON := JSON.Load(str)
		obj := new Colory()
		for key, value in objJSON {
			if (SubStr(key, 1, 1) == "_") { ; Klasseninterne Variable werden ja automatisch gesetzt - und nicht von extern!
				if (key == "_version") { ; Hier koennen evtl. Versionunterschiede angepasst werden
					continue
				}
				else
					continue
			}
			obj[key] := value
		}
		return obj
	}
	/* -------------------------------------------------------------------------------
	Method:	toJSON
	Dumps the class content into JSON String
		
	Parameters:
	indent - amount of	spaces used for indentification
		
	Returns:
	JSON-String
	*/
	toJSON(indent:=0) {
		clone := {}
		for key, value in this {
			clone[key]:=value
		}
		str := JSON.Dump(clone,,indent)
		dbgOut("=[" A_ThisFunc "(indent: " indent ")] -> " str, this.debug)
		return str
	}
	/* ---------------------------------------------------------------------------------------
	Method: __New
	Constructor (*INTERNAL*)
		
	Parameters:
	a - Transparency
	r,g,b- red, green, blue
	debug - Flag to enable debugging (*Optional* - Default: false)
	*/  
	__New(a:=0, r:=0, g:=0, b:=0, debug:=false) {   
		this._debug := debug
		dbgOut("=[" A_ThisFunc "(a=" a ", r=" r ", g=" g ", b=" b ", _debug=" debug ")] (version: " this._version ")", this._debug)
		this.a := a
		this.r := r
		this.g := g
		this.b := b
	}
}