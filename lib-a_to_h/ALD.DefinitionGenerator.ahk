class DefinitionGenerator
{
	static Template := "
					(LTrim
					<ald:package xmlns:ald='ald://package/schema/2012' ald:unique-id='' ald:type='' ald:name='' ald:version=''>
						<ald:description></ald:description>
						<ald:authors></ald:authors>
						<ald:dependencies></ald:dependencies>
						<ald:requirements></ald:requirements>
						<ald:files>
							<ald:doc></ald:doc>
							<ald:src></ald:src>
						</ald:files>
						<ald:tags></ald:tags>
						<ald:links></ald:links>
					</ald:package>
					)"

	Authors := []
	Dependencies := []
	Requirements := []
	SrcFiles := []
	DocFiles := []
	Tags := []
	Links := []

	GUID := ""
	Type := ""
	Name := ""
	Version := ""
	LogoFile := ""
	Description := ""

	_doc := ComObjCreate("MSXML.DOMDocument")

	SaveToFile(file)
	{
		this._doc.save(file)
	}

	Write()
	{
		this._doc.setProperty("SelectionNamespaces", "xmlns:ald='" . ALD.NamespaceURI . "'")
		, this._doc.loadXML(ALD.DefinitionGenerator.Template)

		this._doc.documentElement.setAttributeNode(this._createNamespaceAttribute("ald:unique-id", this.GUID))
		, this._doc.documentElement.setAttributeNode(this._createNamespaceAttribute("ald:type", this.Type))
		, this._doc.documentElement.setAttributeNode(this._createNamespaceAttribute("ald:name", this.Name))
		, this._doc.documentElement.setAttributeNode(this._createNamespaceAttribute("ald:version", this.Version))

		if (this.LogoFile != "")
			this._doc.documentElement.setAttributeNode(this._createNamespaceAttribute("ald:logo-image", this.LogoFile))

		this._doc.selectSingleNode("/*/ald:description").text := this.Description

		this._createAuthorList()
		, this._createDependencyList()
		, this._createRequirementsList()
		, this._createFileLists()
		, this._createTagList()
		, this._createLinkList()
	}

	_createAuthorList()
	{
		authorList := this._doc.selectSingleNode("/*/ald:authors")
		for each, obj in this.Authors
		{
			authorList.appendChild(this._createAuthorElement(obj))
		}
	}

	_createAuthorElement(obj)
	{
		elem := this._createNamespaceElement("ald:author")

		elem.setAttributeNode(this._createNamespaceAttribute("ald:name", obj["name"]))
		if (obj.HasKey("user-name"))
			elem.setAttributeNode(this._createNamespaceAttribute("ald:user-name", obj["user-name"]))
		if (obj.HasKey("homepage"))
			elem.setAttributeNode(this._createNamespaceAttribute("ald:homepage", obj["homepage"]))
		if (obj.HasKey("email"))
			elem.setAttributeNode(this._createNamespaceAttribute("ald:email", obj["email"]))

		return elem
	}

	_createDependencyList()
	{
		depList := this._doc.selectSingleNode("/*/ald:dependencies")
		for each, obj in this.Dependencies
		{
			depList.appendChild(this._createDependencyElement(obj))
		}
	}

	_createDependencyElement(obj)
	{
		elem := this._createNamespaceElement("ald:dependency")

		elem.setAttributeNode(this._createNamespaceAttribute("ald:name", obj["name"]))
		if (obj.HasKey("version"))
			elem.setAttributeNode(this._createNamespaceAttribute("ald:version", obj["version"]))
		if (obj.HasKey("min-version"))
			elem.setAttributeNode(this._createNamespaceAttribute("ald:min-version", obj["min-version"]))
		if (obj.HasKey("max-version"))
			elem.setAttributeNode(this._createNamespaceAttribute("ald:max-version", obj["max-version"]))
		if (obj.HasKey("version-list"))
		{
			for each, version in obj["version-list"]
			{
				ver_elem := this._createNamespaceElement("ald:version")
				ver_elem.text := version
				elem.appendChild(ver_elem)
			}
		}

		return elem
	}

	_createRequirementsList()
	{
		reqList := this._doc.selectSingleNode("/*/ald:requirements")
		for each, obj in this.Requirements
		{
			reqList.appendChild(this._createRequirementElement(obj))
		}
	}

	_createRequirementElement(obj)
	{
		elem := this._createNamespaceElement("ald:requirement")

		elem.setAttributeNode(this._createNamespaceAttribute("ald:type", obj["type"]))
		if (obj.HasKey("value"))
				elem.setAttributeNode(this._createNamespaceAttribute("ald:value", obj["value"]))
		if (obj.HasKey("min-value"))
				elem.setAttributeNode(this._createNamespaceAttribute("ald:min-value", obj["min-value"]))
		if (obj.HasKey("max-value"))
				elem.setAttributeNode(this._createNamespaceAttribute("ald:max-value", obj["max-value"]))
		if (obj.HasKey("value-list"))
		{
			for each, value in obj["value-list"]
			{
				val_elem := this._createNamespaceElement("ald:value")
				val_elem.text := value
				elem.appendChild(val_elem)
			}
		}
	}

	_createFileLists()
	{
		this._createDocFileList()
		this._createSrcFileList()
	}

	_createDocFileList()
	{
		docList := this._doc.selectSingleNode("/*/ald:files/ald:doc")
		for each, obj in this.DocFiles
		{
			docList.appendChild(this._createFileElement(obj))
		}
	}

	_createSrcFileList()
	{
		srcList := this._doc.selectSingleNode("/*/ald:files/ald:src")
		for each, obj in this.SrcFiles
		{
			srcList.appendChild(this._createFileElement(obj))
		}
	}

	_createFileElement(obj)
	{
		elem := this._createNamespaceElement("ald:file")
		elem.setAttributeNode(this._createNamespaceAttribute("ald:path", obj["path"]))
		return elem
	}

	_createTagList()
	{
		tagList := this._doc.selectSingleNode("/*/ald:tags")
		for each, obj in this.Tags
		{
			tagList.appendChild(this._createTagElement(obj))
		}
	}

	_createTagElement(obj)
	{
		elem := this._createNamespaceElement("ald:tag")
		elem.setAttributeNode(this._createNamespaceAttribute("ald:name", obj["name"]))
		return elem
	}

	_createLinkList()
	{
		linkList := this._doc.selectSingleNode("/*/ald:links")
		for each, obj in this.Links
		{
			linkList.appendChild(this._createLinkElement(obj))
		}
	}

	_createLinkElement(obj)
	{
		elem := this._createNamespaceElement("ald:link")
		elem.setAttributeNode(this._createNamespaceAttribute("ald:name", obj["name"]))
		elem.setAttributeNode(this._createNamespaceAttribute("ald:description", obj["description"]))
		elem.setAttributeNode(this._createNamespaceAttribute("ald:href", obj["href"]))
		return elem
	}

	_createNamespaceAttribute(name, value)
	{
		static NODE_ATTRIBUTE  := 2
		attr := this._doc.createNode(NODE_ATTRIBUTE, name, ALD.NamespaceURI)
		attr.Value := value
		return attr
	}

	_createNamespaceElement(name)
	{
		static NODE_ELEMENT := 1
		return this._doc.createNode(NODE_ELEMENT, name, ALD.NamespaceURI)
	}
}