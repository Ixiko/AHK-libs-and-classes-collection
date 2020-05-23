/*
___________________________________________________________________________________

***THE FOLLOWING METHOD(s) ARE USING SIMILAR ROUTINES AND ARE CALLED DYNAMICALLY.
THEY REDIRECT TO INTERNAL METHOD(s), THUS, DOCUMENTATION IS STATED HERE***
____________________________________________________________________________________

METHOD(s): addElement/insertElement
DEFINITION: Appends or inserts an element node
PARAMETER(s):
    element -   Tag name(string or an IXMLDOMNode object)
    ps      -   If the user is calling the "addElement" method,
                this contains the parent node. Otherwise, if it's
                the "insertElement" method, this contains the
                reference node, the element will be inserted to
                the left of this node.
                Can be an XPath expression or an  IXMLDOMNode object
    prm*    -   Attributes and text. see Remarks
USAGE:
    e := xmlObj.addElement("Node", "//Parent", {name: "Element"}, "Text")
    e := xmlObj.insertElement("Node", "//Sibling", {name: "Element"}, {att: "Value"})
RETURN VALUE: An object. Returns the new element node
REMARKS:
    FOR THE 'PRM' PARAMETER:

    To assign/associate an attribute(s), specify an object with the 'key'
    as the attribute name and the 'value' as the attribute value.
    Specify multiple arrays if you want to retain order, internally
    it does a for-loop thus keys are re-arranged in the output.
	
    To add a text node, specify a string.
	
    Since this is a variadic parameter, the 'text' node must be specified last.
	
    E.G.:
    (Attribute and text)
    x.addElement("Node", "//Parent", {name: "Element"}, "Text")
    (Multiple attributes and a text node)
    x.addElement("Node", "//Parent", {name: "Element"}, {att: "value"}, "Text")
    (Text only)
    x.addElement("Node", "//Parent", "Text")
    (Attribute(s) only, note that 1 object[with multiple members] is passed)
    x.addElement("Node", "//Parent", {name: "Element", att: "Value"})
____________________________________________________________________________________

METHOD(s): addChild/insertChild
DEFINITION: Appends or inserts a new child node as the last child of the node.
PARAMETER(s):
    ps      -   If the user is calling the "addChild" method,
                this contains the parent node. Otherwise, if it's
                the "insertChild" method, this contains the
                reference node, the element will be inserted to
                the left of this node.
                can be an XPath expression or an IXMLDOMNode object
    type    -   The type of node to append.
                A value that uniquely identifies the node type.
                Specify the 'nodeType'(http://msdn.microsoft.com/en-us/library/ms753745(v=vs.85).aspx)
                or 'nodeTypeString'(http://msdn.microsoft.com/en-us/library/ms757895(v=vs.85).aspx)
                property of the node to be appended. A short-hand way is to use an
                acronym(see remarks).
                NODE TYPES: http://msdn.microsoft.com/en-us/library/ms766473(v=vs.85).aspx
    params* -   value(s) is dependent on the type of node to be appended. See remarks.
USAGE:
    xmlObj.addChild("//Node", 1, "Tag_Name") ; 'nodeType'
    xmlObj.addChild("//Parent", "element", "Tag_Name") ; 'nodeTypeString'
    xmlObj.addChild("//Parent", "e", "Tag_Name") ; Short-hand(acronym)
RETURN VALUE:   If successful this method returns an object representing the
                newly added node, otherwise it returns 'false'
REMARKS:
    =======================================================================
    NODE TYPES
    [nodeType, nodeTypeString, Short-hand]
    1       element                 'e'
    3       text                    't'
    4       cdatasection            'cds'
    5       entityreference         'er'
    6       entity                  'en'
    7       processinginstruction   'pi'
    8       comment                 'c'
    10      documenttype            'dt'
    11      documentfragment        'df'
    12      notation                'n'
    =======================================================================
    PARAMS* Value
    element             A string specifying the name for the new element node.
                        The name is case-sensitive.
    text                String specifying the value to be supplied to the new
                        text object's nodeValue property.
    cdatasection        same as 'text'
    entityreference     A string specifying the name of the entity referenced.
    entity
        params[1]       The name of the entity.
        params[2]       (Optional) The namespace URI. If specified, the node
                        is created in the context of the namespaceURI parameter
                        with the prefix specified on the node name. If the name
                        parameter does not have a prefix, this is treated as
                        the default namespace.
    processinginstruction
        params[1]       A string specifying the target part of the processing instruction.
        params[2]       A string specifying the rest of the processing instruction
                        preceding the closing ?> characters.
    comment             same as 'text'
    documenttype        same as 'entity'
    documentfragment    No parameters
    notation            same as 'entity'
    =======================================================================
____________________________________________________________________________________

*/

class xml
{
	
	/*
	METHOD: __New
	DEFINITION: Constructor for the class
	PARAMETER(s):
	    source  -  can be a string containing XML string or a 
	               filepattern specifying the location of an XML resource.
	               Omit to start off with an empty document.
	USAGE: Use the 'new' keyword
	    xmlDoc := new xml("<root><child/></root>") ; XML string
	    xmlDoc := new xml("MyFile.xml") ; XML file
	RETURN VALUE: A derived object
	REMARKS: Throws an exception
	*/
	
	__New(src:="") {
		static MSXML := "MSXML2.DOMDocument" (A_OSVersion ~= "WIN_(7|8)" ? ".6.0" : "")
		
		; Create object to store "file" property
		; this is to make sure that __Set() is always called everytime
		; there's an attempt to alter the property's value
		ObjInsert(this, "_", []) ; ByPass __Set()/__Call()?
		
		; Create IXMLDOMDocument object
		this.doc := ComObjCreate(MSXML)
		, this.setProperty("SelectionLanguage", "XPath")
		
		if src {
			if (src ~= "s)^<.*>$")  ; XML string
				this.loadXML(src)
			else if (src ~= "[^<>:""/\\|?*]+\.[^<>:""/\\|?*\s]+$") {
				if FileExist(src) ; Path/URL to XML file/resource
					this.load(src)
				this.file := ""
			} else throw Exception("The parameter '" src "' is neither an XML file "
				. " nor a string containing XML string.`n", -1, src)
			
			; Get last parsing error
			if (pe := this.parseError).errorCode {
				m := pe.url ? ["file", "load"] : ["string", "loadXML"]
				
				; throw exception
				throw Exception("Invalid XML " m.1 ".`nError Code: " pe.errorCode
				. "`nFilePos: " pe.filePos "`nLine: " pe.line "`nLinePos: " pe.linePos
				. "`nReason: " pe.reason "`nSource Text: " pe.srcText
				. "`nURL: " pe.url "`n", -1, m.2)
			}
			
			if (this.file <> false)
				this.file := src
		}
		
	}
	
	__Delete() {
		ObjRelease(Object(this.doc)) ; Is this necessary??
		OutputDebug, % "Object freed."
	}
	
	__Set(property, value) {
		if (property ~= "i)^(doc|file)$") { ; Class property
			if (property = "file") {
				if (value ~= "(^$|[^<>:""/\\|?*]+\.[^<>:""/\\|?*\s]+$)")
					return this._[property] := value
				else return false
			}
		} else { ; XML DOM property
			try return (this.doc)[property] := value
			catch
				return false
		}
	}
	
	__Get(property) {
		if !ObjHasKey(this, property) { ; Redundant??
			if (property = "file")
				return this._.HasKey(property)
					? this._[property]
					: false
			else {
				try return (this.doc)[property]
				catch
					; Allow user to select a node by providing an
					; XPath expression as key (short-hand way)
					; e.g. xmlObj["//Element/Child"] is equivalent
					; to xmlObj.selectSingleNode("//Element/Child")
					try return this.selectSingleNode(property)
			}
		}
	}
	
	__Call(method, params*) {
		static BF := "i)^(Insert|Remove|(Min|Max)Index|(Set|Get)Capacity"
			. "|GetAddress|_NewEnum|HasKey|Clone)$"
		
		if !ObjHasKey(xml, method) {
			if RegExMatch(method, "iJ)^(add|insert)((?P<_>E)lement|(?P<_>C)hild)$", m)
				return this["addInsert" m_](method, params*)
			else {
				try return (this.doc)[method](params*)
				catch e
					if !(method ~= BF)
						throw e
			}
		}
	}
	
	/*
	METHOD: rename
	DEFINITION: Renames an element node
	PARAMETER(s):
	    node    -   the element node to be renamed
	                can be an XPath expression or an IXMLDOMNode object
	    newName -   A string, the new name of the element node
	USAGE:
	    node := xmlObj.rename("//Node", "New_Name")
	RETURN VALUE:   An object
	*/
	
	rename(node, newName) {
		new := this.createElement(newName)
		, old := IsObject(node) ? node : this.selectSingleNode(node)
		
		while old.hasChildNodes()
			new.appendChild(old.firstChild)
		
		while (old.attributes.length > 0)
			new.setAttributeNode(old.removeAttributeNode(old.attributes[0]))
		
		old.parentNode.replaceChild(new, old)
		
		return new
	}
	
	/*
	METHOD: setAtt
	DEFINITION: Sets the attribute for an element node
	PARAMETER(s):
	    element -   the element node
	                can be an XPath expression or an IXMLDOMNode object
	    att     -   Attribute nodes to be associated with the element node
	                Specify an associative array with the key as the 'attribute name'
	                and the value as the 'attribute value'.
	USAGE:
	    xmlObj.setAtt("//Node", {name: "Name", age: "20"}) or
	    xmlObj.setAtt("//Node", {name: "Name"}, {age: "20"})
	RETURN VALUE: None
	*/
	
	setAtt(element, att*) {
		e := IsObject(element) ? element : this.selectSingleNode(element)
		
		for a, b in att {
			if !IsObject(b)
				continue
			for x, y in b
				e.setAttribute(x, y)
		}
	}
	
	/*
	METHOD: getAtt
	DEFINITION: Gets the value of the attribute.
	PARAMETER(s):
	    element -   the element node
	                can be an XPath expression or an IXMLDOMNode object
	    name    -   A string specifying the name of the attribute to return.
	USAGE:
	    xmlObj.getAtt("//Node", "name")
	RETURN VALUE:   The string that contains the attribute value.
	*/
	
	getAtt(element, name) {
		e := IsObject(element) ? element : this.selectSingleNode(element)
		return e.getAttribute(name)
	}
	
	/*
	METHOD: setText
	DEFINITION: Sets the text of an element node
	PARAMETER(s):
	    element -   the element node
	                can be an XPath expression or an IXMLDOMNode object
	    text    -   A string specifying the 'nodeValue' property of the child
	                'text' node associated with the specified 'element' node.
	                If blank the 'text' node(if any) will be removed.
	    idx     -   The index of the particular 'text' node whose value
	                will be set. Defaults to the first 'text' node.
	                *Though not a best-practice, it is very possible
	                to append multiple 'text' nodes to an element.
	                This parameter is for those cases only.
	USAGE:
	    xmlObj.setText("//Node", "New Text")
	    xmlObj.setText("//Node", "") ; removes/clears the 'text' node
	RETURN VALUE:   If the 'text' node exists and its value is altered
	                or cleared this method returns 'true'. Otherwise
	                this method creates a 'text' node and sets it value
	                to the one specified and then it returns an object
	                representing the newly added 'text' node
	*/
	
	setText(element, text:="", idx:=1) {
		e := IsObject(element) ? element : this.selectSingleNode(element)
		
		if (t := this.getChild(e, "t", idx)) {
			text <> "" ? t.nodeValue := text : e.removeChild(t)
			return true
		} else {
			t := this.createTextNode(text)
			, c := this.getChild(e, "", idx)
			return c ? e.insertBefore(t, c) : e.appendChild(t)
		}
	}
	
	/*
	METHOD: getText
	DEFINITION: Gets the 'nodeValue' property of the child 'text' node
	            of the specified element node
	PARAMETER(s):
	    element -   the element node
	                can be an XPath expression or an IXMLDOMNode object
	    idx     -   The index of the particular 'text' node whose value
	                will be retrieved . Defaults to the first 'text' node.
	                *Though not a best-practice, it is very possible
	                to append multiple 'text' nodes to an element.
	                This parameter is for those cases only. 
	USAGE:
	    xmlObj.getText("//Node")
	RETURN VALUE:   The string that contains the value
	*/
	
	getText(element, idx:=1) {
		e := IsObject(element) ? element : this.selectSingleNode(element)
		t := this.getChild(e, "t", idx)
			return t.text
	}
	
	/*
	METHOD: getChild
	DEFINITION: Gets the child node(of the specifiied 'type')
	            of the specified node.
	PARAMETER(s):
	    node    -   the parent node
	                can be an XPath expression or an IXMLDOMNode object
	    type    -   The type of node to get
	                see 'addChild' method for value(s)
	    idx     -   The index of the child node to be retrieved
	                Defaults to the first of its type 
	USAGE:
	    xmlObj.getChild("//Node", "element") ; 1st 'element' child
	    xmlObj.getChild("//Node", "element", 2) ; 2nd 'element' child
	RETURN VALUE:   An object representing the child node
	*/
	
	getChild(node, type:="element", idx:=1) {
		if !idx
			return
		n := IsObject(node) ? node : this.selectSingleNode(node)
		if !type
			return n.childNodes.item(idx-1)
		cn := this.getChildren(n, type)
		return ObjHasKey(cn, idx) ? cn[idx] : (idx<0 ? cn[cn.MaxIndex()+idx+1] : false)
	}
	
	/*
	METHOD: getChildren
	DEFINITION: Returns a list of children(of the specified 'type')
	            of the specified node
	PARAMETER(s):
	    node    -   the parent node
	                can be an XPath expression or an IXMLDOMNode object
	    type    -   The type of node to get
	                see 'addChild' method for value(s) 
	USAGE:
	    xmlObj.getChildren("//Node", "element")
	    xmlObj.getChildren("//Node", "text")
	RETURN VALUE:   An object containing a list of children
	                Each item in the list is an IXMLDOMNode object
	*/
	
	getChildren(node, type:="element") {
		static nts := {e:"element", t:"text", cds:"cdatasection"
		, er:"entityreference", en:"entity", pi:"processinginstruction"
		, c:"comment", dt:"documenttype", df:"documentfragment"
		, n:"notation"} ; nodeTypeString
		
		static _NT := "nodeType" , _NTS := "nodeTypeString"
		
		n := IsObject(node) ? node : this.selectSingleNode(node)
		if !n.hasChildNodes()
			return false
		cn := n.childNodes
		
		if (type ~= "^(1($|0|1|2)|[3-8])$")
			nType := _NT
		else if (type ~= "^[[:alpha:]]+$") {
			if (t := (StrLen(type)<=3))
				nType := ObjHasKey(nts, type) ? _NTS : false
			else {
				for a, b in nts
					continue
				until (nType := (type = b) ? _NTS : false)
			}
		} else return false
		
		if !nType
			return false
		
		c := []
		Loop, % cn.length {
			if (cn.item(A_Index-1)[nType] == (t ? nts[type] : type))
				c[(i := i ? i : 1)] := cn.item(A_Index-1), i+=1
		}
		return c
	}
	
	saveXML() {
		if this.file
			return this.save(this.file)
	}
	
	transformXML() {
		this.transformNodeToObject(this.style(), this.doc)
	}
	
	toEntity(ByRef str) {
		static e := [["&", "&amp;"], ["<", "&lt;"], [">", "&gt;"], ["'", "&apos;"], ["""", "&quot;"]]
		
		for a, b in e
			str := RegExReplace(str, b.1, b.2)
		return !(str ~= "s)([<>'""]|&(?!(amp|lt|gt|apos|quot);))")
	}
	
	toChar(ByRef str) {
		static e := [["<", "&lt;"], [">", "&gt;"], ["'", "&apos;"], ["""", "&quot;"], ["&", "&amp;"]]
		
		for a, b in e
			str := RegExReplace(str, b.2, b.1)
		return true
	}
	
	viewXML(ie:=true) {
		static dir := (FileExist(A_ScriptDir) ? A_ScriptDir : A_Temp)
		static _v := []
		
		dhw := A_DetectHiddenWindows
		DetectHiddenWindows, On
		
		if !this.documentElement
			return
		if WinExist("ahk_id " _v[this].hwnd)
			return
		if ie {
			this.save((f := dir "\tempXML_" A_TickCount ".xml"))
			if !FileExist(f)
				return
		} else (f := this.xml)
		
		if (hwnd := this._view(f)) {
			_v[this] := {hwnd: hwnd, res:f}
			WinWaitClose, % "ahk_id " hwnd
			ObjRemove(_v, this)
		}
		if (ie ? FileExist(f) : false)
			FileDelete, % f
		DetectHiddenWindows, % dhw
	}
	
	style(){
		static xsl
		
		if !IsObject(xsl) {
			RegExMatch(ComObjType(this.doc, "Name"), "IXMLDOMDocument\K(?:\d|$)", m)
			MSXML := "MSXML2.DOMDocument" (m < 3 ? "" : ".6.0")
			xsl := ComObjCreate(MSXML)
			style =
			(LTrim
			<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
			<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
			<xsl:template match="@*|node()">
			<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:for-each select="@*">
			<xsl:text></xsl:text>
			</xsl:for-each>
			</xsl:copy>
			</xsl:template>
			</xsl:stylesheet>
			)
			xsl.loadXML(style), style := NULL
		}
		return xsl
	}
	
	; ###################################
	;  INTERNAL METHOD(s) - DO NOT USE
	; ###################################
	
	addInsertE(m, en, pr:="", prm*) {
		n := pr
			? (IsObject(pr) ? pr : this.selectSingleNode(pr))
			: (m = "addElement" ? this.doc : false)
		e := IsObject(en) ? en : this.createElement(en)
		
		if prm.1 {
			if !IsObject(prm[prm.maxIndex()]) {
				t := prm.Remove(prm.maxIndex())
				if prm.1
					this.setAtt(e, prm*)
				if (t <> "")
					e.text := t
			} else this.setAtt(e, prm*)
		}
		
		if (m = "addElement")
			return n.appendChild(e)
		if (m = "insertElement")
			return n ? n.parentNode.insertBefore(e, n) : n
		
	}
	
	addInsertC(m, pr, type:="element", prm*) {
		static ntm := {1:"createElement", 3:"createTextNode", 4:"createCDATASection"
		, 5: "createEntityReference", 6:"createNode", 7:"createProcessingInstruction"
		, 8:"createComment", 10:"createNode", 11:"createDocumentFragment"
		, 12:"createNode"}
		
		static nt := {element:1, text:3, cdatasection:4, entityreference:5, entity:6
		, processinginstruction:7, comment:8, documenttype:10, documentfragment:11
		, notation:12, e:1, t:3, cds:4, er:5, en:6, pi:7, c:8, dt:10, df:11, n:12}
		
		n := IsObject(pr) ? pr : this.selectSingleNode(pr)
		
		if (type ~= "^(1($|0|1|2)|[3-8])$")
			_m := ntm[t := type]
		else if (type ~= "^[[:alpha:]]+$")
			_m := ntm[t := nt[type]]
		else return false
		
		if !_m
			return false
		
		if (_m == "createNode")
			_n := this[_m](t, prm*)
		else (_n := this[_m](prm*))
		
		if (m = "addChild")
			return _n ? n.appendChild(_n) : false
		if (m = "insertChild")
			return _n ? n.parentNode.insertBefore(_n, n) : false
		
	}
	
	_view(p*) {
		static _v := []
		
		if !ObjHasKey(_v, p.1) {
			if (p.1 ~= "^(\Q" A_ScriptDir "\E|\Q" A_Temp "\E)\\tempXML_\d+\.xml$")
				f := true
			else if (p.1 ~= "s)^<.*>$")
				f := false
			else return
			Gui, New
			Gui, +LastFound +LabelviewXML +Resize
			hwnd := WinExist()
			_v[hwnd] := {button:"", res: (f ? p.1 : false), xv:""}
			Gui, Margin, 0, 12
			Gui, Font, s10, Consolas
			Gui, Color, % f ? "" : 0xFFFFFF
			Gui, Add, % f ? "ActiveX" : "Edit"
			, % "y0 w600 h400 HwndhXV" (f ? "" : " HScroll -Wrap ReadOnly T8")
			, % f ? "Shell.Explorer" : p.1
			if f {
				GuiControlGet, IE,, % hXV
				IE.Navigate((_v[hwnd].res))
			}
			Gui, Add, Button, y+12 x+-100 w88 h26 Default HwndhBtn gviewXMLClose, OK
			Gui, Show,, % A_ScriptName " - viewXML"
			if !f
				SendMessage, 0x00B1, 0, 0,, % "ahk_id " hXV ; EM_SETSEL
			_v[hwnd].xv := hXV , _v[hwnd].button := hBtn
			return hwnd
		} else {
			if (p.2 == "viewXMLClose") {
				if (_v[p.1].res ? FileExist(_v[p.1].res) : false)
					FileDelete, % _v[p.1].res
				Gui, % p.1 ":Destroy"
				_v.Remove(p.1, "")
			}
			if (p.2 == "viewXMLSize") {
				if (A_EventInfo == 1) ; Minimized, do nothing
					return
				
				DllCall("SetWindowPos", "Ptr", _v[p.1].button, "Ptr", 0
				, "UInt", (A_GuiWidth-100), "UInt", (A_GuiHeight -38) ; x|y
				, "Uint",  88, "UInt", 26 ; w|h (ignored in this case)
				, "UInt", 0x0010|0x0001|0x0004) ; SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOZORDER
				
				DllCall("SetWindowPos", "Ptr", _v[p.1].xv, "Ptr", 0
				, "UInt", 0, "UInt", 0 ; x|y (ignored in this case)
				, "Uint",  A_GuiWidth, "UInt", (A_GuiHeight-50) ; w|h
				, "UInt", 0x0010|0x0002|0x0004) ; SWP_NOACTIVATE|SWP_NOMOVE|SWP_NOZORDER
				
			}
		}
		return
		viewXMLSize:
		viewXMLClose:
		xml._view(A_Gui, A_ThisLabel)
		return
	}
	
}