class Connection
{
	static hModule := DllCall("LoadLibrary", "str", "WinInet")

	URL := ""

	__New(URL)
	{
		this.URL := URL
	}

	getUserList(start = 0, count = "all")
	{
		local RequestURL := this.URL . "/users/list?start=" . start . "&count=" . count
			, NamespaceURI := "ald://api/users/list/schema/2012"

		doc := this._GETRequest(RequestURL, NamespaceURI)
		, array := []
		, list := doc.selectNodes("/ald:user-list/ald:user")

		Loop % list.length
		{
			array.Insert(list.item(A_Index - 1).getAttribute("ald:name"))
		}

		return array
	}

	getUser(name, request_user = "", request_password = "")
	{
		local RequestURL := this.URL . "/users/describe/" . name
			, NamespaceURI := "ald://api/users/describe/schema/2012"

		doc := this._GETRequest(RequestURL, NamespaceURI, request_user, request_password)
		, user := {}

		user["name"] := doc.documentElement.getAttribute("ald:name")
		, user["mail"] := doc.documentElement.getAttribute("ald:mail")
		, user["joined"] := doc.documentElement.getAttribute("ald:joined")
		, user["privileges"] := doc.documentElement.getAttribute("ald:privileges")

		return user
	}

	getItemById(id)
	{
		local RequestURL := this.URL "/items/describe/" . id
			, NamespaceURI := "ald://api/items/describe/schema/2012"

		return this._parseItemXML(this._GETRequest(RequestURL, NamespaceURI))
	}

	getItem(name, version)
	{
		local RequestURL := this.URL "/items/describe/" . name . "/" . version
			, NamespaceURI := "ald://api/items/describe/schema/2012"

		return this._parseItemXML(this._GETRequest(RequestURL, NamespaceURI))
	}

	_parseItemXML(doc)
	{
		item := {}

		; ...

		return item
	}

	getItemList(start = 0, count = "all", type = "", user = "", name = "")
	{
		local RequestURL := this.URL . "/items/list?start=" . start . "&count=" . count . (type ? "&type=" . type : "") . (user ? "&user=" . user : "") . (name ? "&name=" . name : "")
			, NamespaceURI := "ald://api/items/list/schema/2012"

		doc := this._GETRequest(RequestURL, NamespaceURI)
		, array := []
		, list := doc.selectNodes("/ald:item-list/ald:item")

		Loop % list.length
		{
			item := list.item(A_Index - 1)
			, array.Insert( { "name" : item.getAttribute("ald:name"), "id" : item.getAttribute("ald:id"), "version" : item.getAttribute("ald:version") } )
		}

		return array
	}

	_GETRequest(URL, NamespaceURI, user = "", password = "")
	{
		local headers := "Accept: text/xml"
			, response := ""

		if (!result := this._Request("GET", URL, headers, response, NamespaceURI, user, password))
		{
			if (!result  := this._Request("GET", URL, headers, response, NamespaceURI))
				throw Exception("No response received")
		}
		return result
	}

	_POSTRequest(URL, headers, byRef data, NamespaceURI = "", user = "", password = "")
	{
		return this._Request("POST", URL, headers, data, NamespaceURI, user, password)
	}

	_Request(method, URL, headers, byRef data, NamespaceURI = "", user = "", password = "")
	{
		if (user && password)
			headers .= "`nAuthorization: Basic " . Base64_Encode(user . ":" . password)

		isXml := RegExMatch(headers, "`am)^Accept:\s+.*(application\/xml|text\/xml)") != 0

		bytes := HttpRequest(URL, data, headers, "Method: " . method)
		if (RegExMatch(headers, "`am)^HTTP/1.1\s+(\d{3})\s+(.*)$", match))
		{
			code := match1, msg := match2
			if (code < 200 || code >= 300)
			{
				throw Exception("Failure code: " . code . " - " . msg " - " " - " data)
			}
			if (bytes > 0)
			{
				if (isXml)
				{
					doc := ComObjCreate("MSXML.DOMDocument")
					, doc.setProperty("SelectionNamespaces", "xmlns:ald='" NamespaceURI . "'")
					, doc.LoadXML(data)

					return doc
				}
				else
				{
					return data
				}
			}
		}
		throw Exception("HTTP Status code missing")
	}

	uploadItem(package, user, password)
	{
		; thanks to [VxE] for helping me with this code.

		static Boundary := "------------fg1215---------"
			, CRLF := "`r`n"
			, bytesPerChar := A_IsUnicode ? 2 : 1
		local headers := "Accept: text/xml`nContent-Type: multipart/form-data; boundary=""" Boundary """`n"
			, RequestURL := this.URL . "/items/add"
			, NamespaceURI := "ald://api/items/add/schema/2012"

		FileRead pack, *c %package%
		FileGetSize size, %package%
		SplitPath package, file

		; For AHK UNICODE or ANSI. To assemble a multipart payload with UTF-8 text and binary data
		VarSetCapacity( data, size + 4096 ) ; Allocate enough space in a var for both the data and text

		leadingtext := "--" Boundary CRLF
					. "Content-Disposition: form-data; name=""package""; filename=""" . file . """" CRLF
					. "Content-Type: application/octet-stream" CRLF CRLF
		; Use StrPut to both convert and insert the leading text component of the multipart data.
		; Also, StrPut returns the offset at which the binary data should be inserted.
		offset := StrPut( leadingtext, &data + 0, StrLen( leadingtext ), "UTF-8" )

		; Copy the binary data into the variable at the offset
		DllCall("RtlMoveMemory", "Ptr", &data + offset, "Ptr", &pack, "UInt", size)

		; Once more, use StrPut to convert and insert text. This time it's the final boundary
		size += offset + StrPut( CRLF "--" Boundary "--", &data + offset + size, StrLen( CRLF "--" Boundary "--" ), "UTF-8" )

		; Use the sum of the lengths of the parts as the total size of the POST data
		headers .= "Content-Length: " size

		result := this._POSTRequest(RequestURL, headers, data, NamespaceURI, user, password)
		if (!result)
		{
			throw Exception("No response received")
		}
		return result.documentElement.getAttribute("ald:id")
	}
}