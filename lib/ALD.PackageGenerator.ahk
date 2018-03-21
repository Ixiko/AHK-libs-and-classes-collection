class PackageGenerator
{
	_doc := ComObjCreate("MSXML.DOMDocument")

	__New(defFile)
	{
		this._doc.setProperty("SelectionNamespaces", "xmlns:ald='" . ALD.NamespaceURI . "'")
		, this._doc.load(defFile)
	}

	Package(outFile)
	{
		for each, file in this._getFileList()
		{
			Zip_Archive(file, outFile)
		}
	}

	_getFileList()
	{
		fileList := []

		nodeList := this._doc.selectNodes("/*/ald:files/ald:src/ald:file")
		Loop % nodeList.Length
		{
			fileList.Insert(nodeList.Item(A_Index - 1).getAttribute("ald:path"))
		}

		nodeList := this._doc.selectNodes("/*/ald:files/ald:doc/ald:file")
		Loop % nodeList.Length
		{
			fileList.Insert(nodeList.Item(A_Index - 1).getAttribute("ald:path"))
		}

		if (logo := this._doc.documentElement.getAttribute("ald:logo-image"))
		{
			fileList.Insert(logo)
		}

		return fileList
	}
}