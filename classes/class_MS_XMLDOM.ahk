

;https://msdn.microsoft.com/en-us/library/ms764730(v=vs.85).aspx
;https://msdn.microsoft.com/en-us/library/aa468547.aspx
New_DOMDocument(handlerPrefix:="")  {
    Com := 0
    try
    {
        Com := ComObjCreate("Msxml2.DOMDocument.6.0")
    }
    catch e
    {
        throw Exception("New_DOMDocument ComObjCreate " . e.Message)
    }
    if(handlerPrefix!="")
    {
        try
        {
            ComObjConnect(Com , handlerPrefix)
        }
        catch e
        {
            throw Exception("New_DOMDocument ComObjConnect " . e.Message)
        }
    }
    return Com
}

class DOMNodeType {
    static NODE_INVALID := 0
    static NODE_ELEMENT := 1
    static NODE_ATTRIBUTE := 2
    static NODE_TEXT := 3
    static NODE_CDATA_SECTION := 4
    static NODE_ENTITY_REFERENCE := 5
    static NODE_ENTITY := 6
    static NODE_PROCESSING_INSTRUCTION := 7
    static NODE_COMMENT := 8
    static NODE_DOCUMENT := 9
    static NODE_DOCUMENT_TYPE := 10
    static NODE_DOCUMENT_FRAGMENT := 11
    static NODE_NOTATION := 12
}

;Back mapping array
;use gArrName[Retval+1] to translate a value from the enum
global gDOMNodeTypeArr := ["NODE_INVALID"
                        ,"NODE_ELEMENT"
                        ,"NODE_ATTRIBUTE"
                        ,"NODE_TEXT"
                        ,"NODE_CDATA_SECTION"
                        ,"NODE_ENTITY_REFERENCE"
                        ,"NODE_ENTITY"
                        ,"NODE_PROCESSING_INSTRUCTION"
                        ,"NODE_COMMENT"
                        ,"NODE_DOCUMENT"
                        ,"NODE_DOCUMENT_TYPE"
                        ,"NODE_DOCUMENT_FRAGMENT"
                        ,"NODE_NOTATION"]


DOMDecodeErrorFromExceptionString(ExceptionString) {
    StartPos := InStr(ExceptionString, "0x")
    err := SubStr(ExceptionString, StartPos , 10)
    if(err == "0xC00CE200")
    {
        return err . " - A Duplicate ID was detected."
    }
    else if(err == "0xC00CE201")
    {
        return err . " - Error parsing data type."
    }
    else if(err == "0xC00CE202")
    {
        return err . " - There was a Namespace conflict."
    }
    else if(err == "0xC00CE204")
    {
        return err . " - Unable to expand an attribute with Object value"
    }
    else if(err == "0xC00CE205")
    {
        return err . " - Cannot have 2 data type attributes on one element."
    }
    else if(err == "0xC00CE206")
    {
        return err . " - Insert position node not found"
    }
    else if(err == "0xC00CE207")
    {
        return err . " - Node not found"
    }
    else if(err == "0xC00CE208")
    {
        return err . " - This operation can not be performed on a specified node type."
    }
    else if(err == "0xC00CE209")
    {
        return err . " - Invalid attribute on the XML Declaration. Only 'version', 'encoding', or 'standalone' attributes are allowed."
    }
    else if(err == "0xC00CE20A")
    {
        return err . " - Inserting a node or its ancestor under itself is not allowed."
    }
    else if(err == "0xC00CE20B")
    {
        return err . " - Insert position node must be a Child of the node to insert under."
    }
    else if(err == "0xC00CE20C")
    {
        return err . " - Attribute-less nodes type what given attributes."
    }
    else if(err == "0xC00CE20D")
    {
        return err . " - The parameter node is not a child of this node."
    }
    else if(err == "0xC00CE20E")
    {
        return err . " - A named node type is missing a name."
    }
    else if(err == "0xC00CE20F")
    {
        return err . " - Unexpected NameSpace parameter."
    }
    else if(err == "0xC00CE210")
    {
        return err . " - Required parameter is missing (or null/empty)."
    }
    else if(err == "0xC00CE211")
    {
        return err . " - Namespace node is invalid."
    }
    else if(err == "0xC00CE212")
    {
        return err . " - Attempt to modify a read-only node."
    }
    else if(err == "0xC00CE213")
    {
        return err . " - Access Denied."
    }
    else if(err == "0xC00CE214")
    {
        return err . " - Attributes must be removed before adding them to a different node."
    }
    else if(err == "0xC00CE215")
    {
        return err . " - Invalid data for node type."
    }
    else if(err == "0xC00CE216")
    {
        return err . " - Operation aborted by caller."
    }
    else if(err == "0xC00CE217")
    {
        return err . " - Unable to recover node list iterator position."
    }
    else if(err == "0xC00CE218")
    {
        return err . " - The offset must be 0 or a positive number that is not greater than the number of characters in the data."
    }
    else if(err == "0xC00CE219")
    {
        return err . " - The provided node is not a specified attribute on this node."
    }
    else if(err == "0xC00CE21A")
    {
        return err . " - This operation cannot be performed on DOCTYPE node."
    }
    else if(err == "0xC00CE21B")
    {
        return err . " - Cannot mix different threading models in document."
    }
    else if(err == "0xC00CE21C")
    {
        return err . " - Datatype is not supported."
    }
    else if(err == "0xC00CE21D")
    {
        return err . " - Property name is invalid."
    }
    else if(err == "0xC00CE21E")
    {
        return err . " - Property value is invalid."
    }
    else if(err == "0xC00CE21F")
    {
        return err . " - Object is read-only."
    }
    else if(err == "0xC00CE220")
    {
        return err . " - Only XMLSchemaCache schema collections can be used."
    }
    else if(err == "0xC00CE223")
    {
        return err . " - Validate failed because the document does not contain exactly one root node."
    }
    else if(err == "0xC00CE224")
    {
        return err . " - The node is neither valid nor invalid because no DTD/Schema declaration was found."
    }
    else if(err == "0xC00CE225")
    {
        return err . " - Validate failed."
    }
    else if(err == "0xC00CE226")
    {
        return err . " - Index refers beyond end of list."
    }
    else if(err == "0xC00CE227")
    {
        return err . " - A nameless node type cannot have a name."
    }
    else if(err == "0xC00CE228")
    {
        return err . " - Required property does not have a valid value."
    }
    else if(err == "0xC00CE229")
    {
        return err . " - Illegal operation while a transformation is currently in progress."
    }
    else if(err == "0xC00CE22A")
    {
        return err . " - User aborted transform."
    }
    else if(err == "0xC00CE22B")
    {
        return err . " - Document is not completely parsed."
    }
    else if(err == "0xC00CE22C")
    {
        return err . " - This object cannot sink the event. An error occurred marshalling the object's IDispatch interface."
    }
    else if(err == "0xC00CE22D")
    {
        return err . " - The XSL stylesheet document must be free threaded in order to be used with the XSLTemplate object."
    }
    else if(err == "0xC00CE22E")
    {
        return err . " - SelectionNamespaces property value is invalid. Only well-formed xmlns attributes are allowed."
    }
    else if(err == "0xC00CE22F")
    {
        return err . " - Invalid Name"
    }
    else if(err == "0xC00CE230")
    {
        return err . " - Invalid Name"
    }
    else if(err == "0xC00CE231")
    {
        return err . " - An empty string '' is not a valid name."
    }
    else if(err == "0xC00CE232")
    {
        return err . " - The ServerHTTPRequest property can not be used when loading a document asynchronously and is only supported on Windows NT 4.0 and above."
    }
    else if(err == "0xC00CE233")
    {
        return err . " - Not supported when building DOM from SAX."
    }
    else if(err == "0xC00CE234")
    {
        return err . " - Method is not valid until after startDocument() is called."
    }
    else if(err == "0xC00CE235")
    {
        return err . " - Method unexpected."
    }
    else if(err == "0xC00CE236")
    {
        return err . " - Method unexpected."
    }
    else if(err == "0xC00CE237")
    {
        return err . " - The buffer passed in has insufficient length."
    }
    else if(err == "0xC00CE238")
    {
        return err . " - There are no contexts left to pop in the Namespace Manager."
    }
    else if(err == "0xC00CE239")
    {
        return err . " - The prefix can not be redeclared. The Namespace Manager is not in override mode."
    }
    else if(err == "0xC00CE23A")
    {
        return err . " - It is an error to mix objects from different versions of MSXML."
    }
    else if(err == "0xC00CE23B")
    {
        return err . " - Current operating system does not have WINHTTP.DLL. WINHTTP.DLL must be registered to use the ServerXMLHTTP object."
    }
    else if(err == "0xC00CE23C")
    {
        return err . " - The XSLPattern selection language is not supported in this version of MSXML."
    }
    else if(err == "0xC00CE23D")
    {
        return err . " - DTD Validation when using the NewParser option or MXXMLWriter to build a DOMDocument is not supported."
    }
    else if(err == "0xC00CE23E")
    {
        return err . " - Validate failed because the node provided does not belong to this document."
    }
    else if(err == "0xC00CE23F")
    {
        return err . " - This method can only be called from top level error object when the MultipleErrorMessages property is enabled."
    }
    else if(err == "0xC00CE240")
    {
        return err . " - While loading schema an error has occurred:"
    }
    else if(err == "0xC00CE241")
    {
        return err . " - 'importNode' requires the 'deep' parameter to be true."
    }
    else
    {
        return "Unknown Error: " . ExceptionString
    }
}