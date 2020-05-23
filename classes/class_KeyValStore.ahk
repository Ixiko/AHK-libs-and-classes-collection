KeyValStore(store, options:="")
{
	return new KeyValStore(store, options)
}

class KeyValStore
{
	__New(store, opts:="") ; opts=reserved
	{
		try xml_doc := ComObjCreate("MSXML2.DOMDocument.6.0")
		catch {
			try xml_doc := ComObjCreate("MSXML2.DOMDocument")
			catch e
				throw e
		}

		if (!rashndoct := FileExist(store)) || InStr(rashndoct, "D")
			FileOpen(store, "w", "UTF-8").Write("<object/>") ; .loadXML(); save(); load()

		xml_doc.setProperty("SelectionLanguage", "XPath")
		xml_doc.async := false
		xml_doc.validateOnParse := false ; just check for well-formed XML
		xml_doc.preserveWhiteSpace := false

		xml_doc.load(store)

		parse_err := xml_doc.parseError
		if (parse_err.errorCode != 0) {
			msg := Format("0x{1:X} - {2}`n`nurl:`t{3}`nfilepos:`t{4}`nline:`t{5}`nlinepos:`t{6}`nsrcText:`t{7}"
				, parse_err.errorCode & 0xFFFFFFFF, parse_err.reason
				, parse_err.url, parse_err.filepos, parse_err.line
				, parse_err.linepos, parse_err.srcText)

			throw Exception(msg, -1)
		}

		ObjRawSet(this, "document", xml_doc)
	}

	class Set extends KeyValStore.Method
	{
		Call(self, key, value)
		{
			if (node := this.Node(self, key, value)) {
				if (node.hasChildNodes())
					node.selectNodes("child::node()").removeAll()

				type := this.TypeOf(value)
				if !(node.tagName == type) {
					elem := self.document.createElement(type)

					attributes := node.attributes
					while (att := attributes.nextNode())
						elem.setAttribute(att.name, att.value)

					node.parentNode.replaceChild(elem, node)
					node := elem
				}

				this.Encode(value, node)
				self.document.save(self.Path)
			}
			return value
		}

		Encode(value, node)
		{
			if IsObject(value) {
				xml_doc := node.ownerDocument
				for key, val in value {
					elem := xml_doc.createElement(this.TypeOf(val))
					elem.setAttribute("key", Format("{1:L}", key))
					this.Encode(val, elem)

					node.appendChild(elem)
				}
			} else
				node.text := value

			return value ; return node??
		}
	}

	class Get extends KeyValStore.Method
	{
		Call(self, key)
		{
			if (node := this.Node(self, key))
				return this.Decode(node)
		}

		Decode(node)
		{
			type := node.tagName
			if (type == "object") {
				obj := {}

				child := node.firstChild
				while (child) {
					obj[child.getAttribute("key")] := this.Decode(child)
					child := child.nextSibling
				}

				return obj
			}

			return type=="string" ? node.text : node.text + 0
		}
	}

	class Del extends KeyValStore.Get
	{
		Call(self, key)
		{
			if (node := this.Node(self, key)) {
				removed := this.Decode(node.parentNode.removeChild(node))
				self.document.save(self.Path)
				return removed
			}
		}
	}

	Clear()
	{
		this.Set("", {})
	}

	__Set(param, params*)
	{
		if (!params.Length())
			return this.Set("", param)
	}

	__Get(param:="", params*)
	{
		if (param == "")
			return this.Get("")

		if (param = "Path") {
			while (!pz_path := this.GetAddress("_Path"))
				this.SetCapacity("_Path", 260 * (A_IsUnicode ? 2 : 1))

			if (url := this.document.url)
			&& (DllCall("shlwapi\PathCreateFromUrl", "Str", url, "Ptr", pz_path, "UInt*", 260, "UInt", 0, "Ptr") == 0)
				return StrGet(pz_path)
		}
	}

	__Delete()
	{
		this.document.save(this.Path) ; make sure to save changes(if any)
	}

	class Method
	{
		__Call(method, args*)
		{
			if IsObject(method)
				return this.Call(method, args*)
			else if (method == "")
				return this.Call(args*)
		}

		Node(self, keys, value*)
		{
			xml_doc := self.document
			node := xml_doc.documentElement, find := true

			keys_arr := (dot_prop := !IsObject(keys)) ? StrSplit(keys, ".") : keys
			length := keys_arr.Length()
			enum := keys_arr._NewEnum()

			while enum.Next(i, key) {
				if (key != "") {
					if (find && !(node.tagName == "object"))
						return

					if (dot_prop) {
						static tail := A_AhkVersion<"2" ? 0 : -1
						while (SubStr(key, tail) == "\")
							key := SubStr(key, 1, -1) . "." . (enum.Next(i, k) ? k : "")
					}

					key := Format("{1:L}", key)

					if (!find || !elem := node.selectSingleNode("*[@key='" . key . "']")) {
						if (find) {
							if (!value.Length()) ; Get() or Del()
								return
							find := false ; skip COM calls that are no longer necessary
						}
						elem := xml_doc.createElement(i<length ? "object" : this.TypeOf(value*))
						elem.setAttribute("key", key)
						node.appendChild(elem)
					}
					node := elem
				}
			}

			return node
		}

		TypeOf(value)
		{
			return IsObject(value) ? "object" : [value].GetCapacity(1)=="" ? "number" : "string"
		}
	}
}