; AHK v2
; Example ===================================================================================
; ===========================================================================================
; a := Map(), b := Map(), c := Map(), d := Map(), e := Map(), f := Map() ; Object() is more technically correct than {} but both will work.

; d["g"] := 1, d["h"] := 2, d["i"] := ["purple","pink","pippy red"]
; e["g"] := 1, e["h"] := 2, e["i"] := Map("1","test1","2","test2","3","test3")
; f["g"] := 1, f["h"] := 2, f["i"] := [1,2,Map("a",1.0009,"b",2.0003,"c",3.0001)]

; a["test1"] := "test11", a["d"] := d
; b["test3"] := "test33", b["e"] := e
; c["test5"] := "test55", c["f"] := f

; myObj := Map()
; myObj["a"] := a, myObj["b"] := b, myObj["c"] := c, myObj["test7"] := "test77", myObj["test8"] := "test88"

; g := ["blue","green","red"], myObj["h"] := g ; add linear array for testing

; q := Chr(34)
; textData2 := XA_Save(myObj) ; ===> convert array to XML
; msgbox "XML Breakdown:`r`n(Should match second breakdown.)`r`n`r`n" textData2


; ===========================================================================================
; Error Test - Duplicate Node ; =============================================================
; ===========================================================================================
; textData2 := StrReplace(textData2,"</Base>","<test8 type=" q "String" q ">test88</test8>`r`n</Base>") ; <--- test error, duplicate node
; ===========================================================================================
; ===========================================================================================


; newObj := XA_Load(textData2) ; ===> convert XML back to array

; textData3 := XA_Save(newObj) ; ===> break down array into 2D layout again, should be identical
; msgbox "Second Breakdown:`r`n(should be identical to first breakdown)`r`n`r`n" textData3

; ExitApp
; ===========================================================================================
; End Example ; =============================================================================
; ===========================================================================================


; =============================================================
; XA_Save(Array,BaseName := "Base")		>>> dumps XML text from associative array var
; XA_Load(XMLText)						>>> converts XML text to associative array
;		Originally posted by trueski
;		https://autohotkey.com/board/topic/85461-ahk-l-saveload-arrays/
;		Modified for AHKv2 by TheArkive
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Root node by default is called "Base".  It doesn't matter because it isn't
; used and is not part of the array after using XA_Load().
;
; User must choose how to handle output, ie.
;		1) Save XML to file after ... var := XA_Save()
;		2) Load XML text from file before converting with ... myArray := XA_Load()
; =============================================================
XA_Save(arr,BaseName := "Base") { ; XA_Save(Array, Path)
	q := Chr(34)
	outVar := "<?xml version=" q "1.0" q " encoding=" q "UTF-8" q "?>`n<" BaseName " type=" q Type(arr) q ">`n" XA_ArrayToXML(arr) "`n</" BaseName ">"
	return OutVar
}
XA_Load(XMLText) { ; orig param was ... XA_Load(Path) ... Path = XML file location
	Local XMLObj, XMLRoot, Root1, Root2 ; XMLText
	
	XMLObj    := XA_LoadXML(XMLText)
	XMLObj    := XMLObj.selectSingleNode("/*")
	
	If (IsObject(XMLObj)) { ; check if settings are blank
		XMLRoot   := XMLObj.nodeName
		curType := ""
		Try curType := XMLObj.getAttribute("type")
		outputArray := XA_XMLToArray(XMLObj.childNodes,,curType)
		return outputArray
	} Else
		return "" ; if settings are blank return a blank Map()
}
XA_XMLToArray(nodes, NodeName:="", curType:="") {
	If (!IsSet(Obj) And curType = "Array")
		Obj := []
	Else If (!IsSet(Obj) And curType = "Map")
		Obj := Map()
	Else If (!IsSet(Obj))
		Obj := ""
	
	for node in nodes {
		if (node.nodeName != "#text") { ;NAME
			If (node.nodeName == "Invalid_Name" && node.getAttribute("ahk") == "True")
				NodeName := node.getAttribute("id")
			Else
				NodeName := node.nodeName
		} else { ;VALUE
			If (curType = "String") {
				Obj := String(node.nodeValue)
			} Else If (curType = "Integer") {
				Obj := Integer(node.nodeValue)
			} Else If (curType = "Float") {
				Obj := Float(node.nodeValue)
			} Else {
				Obj := node.nodeValue
			}
		}
		
		if node.hasChildNodes {
			prevSib := ""
			Try prevSib := node.previousSibling.nodeName
			
			nextSib := ""
			Try  nextSib := node.nextSibling.nodeName
			
			nextType := ""
			Try nextType := node.getAttribute("type")
			
			If ((nextSib = node.nodeName || node.nodeName = prevSib) && node.nodeName != "Invalid_Name" && node.getAttribute("ahk") != "True") { ;Same node name was used for multiple nodes
				pN := "", cN := "", nN := ""
				Try pN := node.previousSibling.xml
				Try cN := node.xml
				Try nN := node.nextSibling.xml
				
				Throw "Duplicate node:`r`n`r`nPrev:`r`n" pN "`r`n`r`nCurrent:`r`n" cN "`r`n`r`nNext:`r`n" nN
				; If (!prevSib) { ;Create object - previous -> !node.previousSibling.nodeName
					; Obj[NodeName] := Map()
					; ItemCount := 0
				; }
			  
				; ItemCount++
			  
				; If (node.getAttribute("id") != "") ;Use the supplied ID if available
					; Obj[NodeName][node.getAttribute("id")] := XA_XMLToArray(node.childNodes, node.getAttribute("id"))
				; Else ;Use ItemCount if no ID was provided
					; Obj[NodeName][ItemCount] := XA_XMLToArray(node.childNodes, ItemCount)
			} Else {
				If (curType = "Map") {
					Obj[NodeName] := XA_XMLToArray(node.childNodes, NodeName, nextType)
				} Else If (curType = "Array") {
					Obj.InsertAt(NodeName,XA_XMLToArray(node.childNodes, NodeName, nextType))
				}
			}
		}
	}
	
	return Obj
}
XA_LoadXML(ByRef data){
	o := ComObjCreate("MSXML2.DOMDocument.6.0")
	o.async := false
	o.LoadXML(data)
	return o
}
XA_ArrayToXML(theArray, tabCount:=1, NodeName:="") {     
    Local tabSpace, extraTabSpace, tag, val, theXML, root
	q := Chr(34)
	tabCount++
    tabSpace := "", extraTabSpace := "", curType := ""
	If (!IsSet(theXML))
		theXML := ""
	
	if (!IsObject(theArray)) {
		root := theArray
		theArray := %theArray%
    }
	
	While (A_Index < tabCount) {
		tabSpace .= "`t" 
		extraTabSpace := tabSpace . "`t"
    }
     
	for tag, val in theArray {
		If (!IsObject(val)) { ; items/values
			iTag := "Invalid_Name"
			eTag := XA_XMLEncode(tag) ; xml encoded tag
			eVal := XA_XMLEncode(val)
			If (XA_InvalidTag(tag))
				theXML .= "`n" tabSpace "<" iTag " id=" q eTag q " ahk=" q "True" q " type=" q Type(val) q ">" eVal "</" iTag ">"
			Else
				theXML .= "`n" tabSpace "<" tag " type=" q Type(val) q ">" eVal "</" tag ">"
		} Else {
			iTag := "Invalid_Name"
			eTag := XA_XMLEncode(tag) ; xml encoded tag
			aXML := XA_ArrayToXML(val, tabCount, "")
			If (XA_InvalidTag(tag))
				theXML .= "`n" tabSpace "<" iTag " id=" q eTag q " ahk=" q "True" q " type=" q Type(val) q ">`n" aXML "`n" tabSpace "</" iTag ">"
			Else
				theXML .= "`n" tabSpace "<" tag " type=" q Type(val) q ">" "`n" aXML "`n" tabSpace "</" tag ">"
	    }
    } 
	
	theXML := SubStr(theXML, 2)
	Return theXML
} 
XA_InvalidTag(Tag) {
	q := Chr(34)
	Char1      := SubStr(Tag, 1, 1) 
	Chars3     := SubStr(Tag, 1, 3)
	StartChars := "~``!@#$%^&*()_-+={[}]|\:;" q "'<,>.?/1234567890 	`n`r"
	Chars := q "'<>=/ 	`n`r"
	
	Loop Parse StartChars
	{
		If (Char1 = A_LoopField)
		  Return 1
	}
	
	Loop Parse Chars
	{
		If (InStr(Tag, A_LoopField))
			Return 1
	}
	
	If (Chars3 = "xml")
		Return 1
	Else
		Return 0
}

; XA_XMLEncode references:
; https://en.wikipedia.org/wiki/XML#Escaping
; https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references#Predefined_entities_in_XML
; added again as original source code posted at forum was lost due to forum upgrade 

XA_XMLEncode(Text) {
	Text := StrReplace(Text,"&","&amp;")
	Text := StrReplace(Text,"<","&lt;")
	Text := StrReplace(Text,">","&gt;")
	Text := StrReplace(Text,Chr(34),"&quot;")
	Text := StrReplace(Text,"'","&apos;")
	Return XA_CleanInvalidChars(Text)
}

XA_CleanInvalidChars(text, replace:="") {
	re := "[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]"
	Return RegExReplace(text, re, replace)
	
	/*
		Source: http://stackoverflow.com/questions/730133/invalid-characters-in-xml
		public static string CleanInvalidXmlChars(string text) 
		{ 
		// From xml spec valid chars: 
		// #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]     
		// any Unicode character, excluding the surrogate blocks, FFFE, and FFFF. 
		string re = @"[^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\u10000-u10FFFF]"; 
		return Regex.Replace(text, re, ""); 
		}
	*/
}