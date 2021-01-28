/*

Save/Load Arrays - trueski 
- original source  : http://www.autohotkey.com/board/topic/85461-ahk-l-saveload-arrays/
- Updated source   : https://github.com/hi5/XA (see notes)
  AutoHotkey forum : https://autohotkey.com/boards/viewtopic.php?f=6&t=34849  

Examples:

XA_Save("Array", Path) ; put variable name in quotes
XA_Load(Path)          ; the name of the variable containing the array is returned

Notes:
- indented code to personal pref.
- added XA_CleanInvalidChars()

*/

XA_Save(Array, Path) {
	 FileDelete, % Path
	 FileAppend, % "<?xml version=""1.0"" encoding=""UTF-8""?>`n<" . Array . ">`n" . XA_ArrayToXML(Array) . "`n</" . Array . ">", % Path, UTF-8
	 If (ErrorLevel)
		Return 1
	 Return 0
	}

XA_Load(Path) {
	 Local XMLText, XMLObj, XMLRoot, Root1, Root2
	
	 If (!FileExist(Path))
		Return 1
	
	 FileRead, XMLText, % Path
	 StringReplace, XMLText, XMLText, %A_Space%&%A_Space%, %A_Space%&amp;%A_Space%, All ; dirty hack
	
	 XMLObj	:= XA_LoadXML(XMLText)
	 XMLObj	:= XMLObj.selectSingleNode("/*") ; */
	 XMLRoot   := XMLObj.nodeName
	 %XMLRoot% := XA_XMLToArray(XMLObj.childNodes)
	
	 Return XMLRoot
	}

XA_XMLToArray(nodes, NodeName="") {
	 Obj := Object()
	
	 for node in nodes
		{
		 if (node.nodeName != "#text")  ;NAME
			{
			 If (node.nodeName == "Invalid_Name" && node.getAttribute("ahk") == "True")
				NodeName := node.getAttribute("id")
			 Else
				NodeName := node.nodeName
			}
		
		 else ;VALUE
			Obj := node.nodeValue
		
		 if node.hasChildNodes
			{
			 ; Same node name was used for multiple nodes
			 If ((node.nextSibling.nodeName = node.nodeName || node.nodeName = node.previousSibling.nodeName) && node.nodeName != "Invalid_Name" && node.getAttribute("ahk") != "True")
				{
				 ; Create object
				 If (!node.previousSibling.nodeName)
					{
					 Obj[NodeName] := Object()
					 ItemCount := 0
					}
				 ItemCount++
			
				 ; Use the supplied ID if available
				 If (node.getAttribute("id") != "")
					Obj[NodeName][node.getAttribute("id")] := XA_XMLToArray(node.childNodes, node.getAttribute("id"))
			
				 ; Use ItemCount if no ID was provided
				 Else
					Obj[NodeName][ItemCount] := XA_XMLToArray(node.childNodes, ItemCount)
					}
			
			 Else
				Obj.Insert(NodeName, XA_XMLToArray(node.childNodes, NodeName))
			}
	}
   Return Obj
}

XA_LoadXML(ByRef data){
	 o := ComObjCreate("MSXML2.DOMdocument.6.0")
	 o.async := false
	 o.LoadXML(data)
	 return o
	}

XA_ArrayToXML(theArray, tabCount=1, NodeName="") {	 
	 Local tabSpace, extraTabSpace, tag, val, theXML, root
	 tabCount++
	 tabSpace := "" 
	 extraTabSpace := "" 
	 theXML := ""
	
	 if (!IsObject(theArray)) 
		{
		 root := theArray
		 theArray := %theArray%
		 ; StringReplace, theArray, theArray, %A_Space%&%A_Space%, %A_Space%&amp;%A_Space%, All ; dirty hack
		}
	
	While (A_Index < tabCount) 
		{
		 tabSpace .= "`t" 
		 extraTabSpace := tabSpace . "`t"
		} 
	
	 for tag, val in theArray 
		{
		 If (!IsObject(val))
			{
			 If (XA_InvalidTag(tag))
				theXML .= "`n" . tabSpace . "<Invalid_Name id=""" . XA_XMLEncode(tag) . """ ahk=""True"">" . XA_XMLEncode(val) . "</Invalid_Name>"
			 Else
				theXML .= "`n" . tabSpace . "<" . tag . ">" . XA_XMLEncode(val) . "</" . tag . ">"
			}
		
		 Else
			{
			 If (XA_InvalidTag(tag))
				theXML .= "`n" . tabSpace . "<Invalid_Name id=""" . XA_XMLEncode(tag) . """ ahk=""True"">" . "`n" . XA_ArrayToXML(val, tabCount, "") . "`n" . tabSpace . "</Invalid_Name>"
			 Else
				theXML .= "`n" . tabSpace . "<" . tag . ">" . "`n" . XA_ArrayToXML(val, tabCount, "") . "`n" . tabSpace . "</" . tag . ">"
			}
		} 
	
	 theXML := SubStr(theXML, 2)
	 Return theXML
	}

XA_InvalidTag(Tag) {
	 Char1	  := SubStr(Tag, 1, 1) 
	 Chars3	 := SubStr(Tag, 1, 3)
	 StartChars := "~``!@#$%^&*()_-+={[}]|\:;""'<,>.?/1234567890 	`n`r"
	 Chars := """'<>=/ 	`n`r"
	
	 Loop, Parse, StartChars
		{
		 If (Char1 = A_LoopField)
			Return 1
		}
	
	 Loop, Parse, Chars
		{
		 If (InStr(Tag, A_LoopField))
			Return 1
		}
	
	 If (Chars3 = "xml")
		Return 1
	
	 Return 0
	}

; XA_XMLEncode references:
; https://en.wikipedia.org/wiki/XML#Escaping
; https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references#Predefined_entities_in_XML
; added again as original source code posted at forum was lost due to forum upgrade 

XA_XMLEncode(Text) { 
	 StringReplace, Text, Text, &, &amp;, All
	 StringReplace, Text, Text, <, &lt;, All
	 StringReplace, Text, Text, >, &gt;, All
	 StringReplace, Text, Text, ", &quot;, All
	 StringReplace, Text, Text, ', &apos;, All
	 Return XA_CleanInvalidChars(Text)                  ; additional fix see below for reference 
	}	

XA_CleanInvalidChars(text, replace="") {
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
