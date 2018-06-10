
Manifest_FromPackage(fileName)
{
	try
	{
		if !FileExist(fileName)
			throw Exception("File does not exist!`nFile: """ fileName """")
		FileRead, data, *c %fileName%
		pData := &data
		if StrGet(pData, 8, "UTF-8") != "AHKPKG00"
			throw Exception("Invalid format!`nFile: """ fileName """")
		sz := NumGet(pData+8, "UInt")
		return StrGet(pData+12, sz, "UTF-8")
	}
	catch e
		throw e ; Propagate exception
	return 0
}

Manifest_FromFile(fileName)
{
	try FileRead, tman, % fileName
	catch
		throw Exception("Cannot read manifest!")
	
	return Manifest_FromStr(tman)
}

Manifest_FromStr(tman)
{
	man := JSON_ToObj(tman)
	if !IsObject(man)
		throw Exception("Manifest parse error!")
	
	out := {}
	
	; Validation
	_ManValidateField(out, man, "id")
	if !_IsValidAHKIdentifier(out.id)
		throw Exception("Invalid package identifier (should be a valid AHK identifier): '" out.id "'")
	_ManValidateField(out, man, "name")
	_ManValidateField(out, man, "version")
	_ManValidateField(out, man, "type")
	_ManValidateField(out, man, "ahkbranch")
	_ManValidateField(out, man, "ahkversion")
	_ManValidateField(out, man, "ahkflavour")
	_ManValidateField(out, man, "author")
	_ManOptionalField(out, man, "description")
	_ManOptionalField(out, man, "license", "ASPDM Default License")
	_ManOptionalField(out, man, "tags")
	_ManOptionalField(out, man, "required")
	_ManOptionalField(out, man, "forumurl")
	_ManOptionalField(out, man, "screenshot")
	return out
}

_IsValidAHKIdentifier(x)
{
	return !!RegExMatch(x, "^(?:[a-zA-Z0-9#_@\$]|[^\x00-\x7F])+$")
}

ObjHasNonEmptyKey(obj, field)
{
	return ObjHasKey(obj, field) && obj[field] != ""
}

_ManValidateField(out, man, field)
{
	if !ObjHasNonEmptyKey(man, field)
		throw Exception("Missing manifest field: '" field "'")
	out[field] := man[field]
}

_ManOptionalField(out, man, field, defValue := "")
{
	out[field] := ObjHasNonEmptyKey(man, field) ? man[field] : defValue
}

