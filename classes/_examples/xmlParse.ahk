#NoEnv

;[========]
;[  Load  ]
;[========]
;-- Note: XML data from fincs.  The data has been edited to remove all formatting.
xmldata=
(ltrim join
   <compactdiscs>
   <compactdisc>
   <artist type="individual">Frank Sinatra</artist>
   <title numberoftracks="4">In The Wee Small Hours</title>
   <tracks>
   <track>In The Wee Small Hours</track>
   <track>Mood Indigo</track>
   <track>Glad To Be Unhappy</track>
   <track>I Get Along Without You Very Well</track>
   </tracks>
   <price>$12.99</price>
   </compactdisc>
   <compactdisc>
   <artist type="band">The Offspring</artist>
   <title numberoftracks="5">Americana</title>
   <tracks>
   <track>Welcome</track>
   <track>Have You Ever</track>
   <track>Staring At The Sun</track>
   <track>Pretty Fly (For A White Guy)</track>
   </tracks>
   <price>$12.99</price>
   </compactdisc>
   </compactdiscs>
)

MsgBox Before:`n%xmldata%

;-- Create DOM object
xmlDoc:=ComObjCreate("msxml2.DOMDocument.6.0")
xmlDoc.async:=False

;-- Load XML data to DOM object
xmlDoc.loadXML(xmldata)
if   xmlDoc.parseError.errorCode
   {
      MsgBox
       ,16
       ,XML Load Error
       ,%   "Unable to load XML data."
        . "`nError: " . xmlDoc.parseError.errorCode
        . "`nReason: " . xmlDoc.parseError.reason
      return
   }

;[==========]
;[  Format  ]
;[==========]
;-- Create SAXXMLReader and MXXMLWriter objects
xmlReader:=ComObjCreate("msxml2.SAXXMLReader.6.0")
xmlWriter:=ComObjCreate("msxml2.MXXMLWriter.6.0")

;-- Set properties on the XML writer.
;   Note: Some of the property assignments  have been commented out so that the
;   default values will be used.  Uncomment and set to another value if desired.

xmlWriter.byteOrderMark:=True
   ;-- Determines whether to write the Byte Order Mark (BOM). The
   ;   byteOrderMark property has no effect for BSTR or DOM output.

xmlWriter.disableOutputEscaping:=False
   ;-- Matches the disable-output-escaping attribute of the <xsl:text> and
   ;   <xsl:value-of> elements.  When set to True, special symbols such as
   ;   "&" are passed through literally.

;;;;;xmlWriter.encoding:="UTF-8"
;;;;;    ;-- Sets and gets encoding for the output.  Observation: For some
;;;;;    ;   reason, encoding is not displayed in the processing instructions
;;;;;    ;   node if this property is set to "UTF-8".

xmlWriter.omitXMLDeclaration:=False
   ;-- Forces the IMXWriter to skip the XML declaration.  Useful for
   ;   creating document fragments.  Observation: For some reason (bug?),
   ;   this property is assumed to be TRUE if the "output" property is a
   ;   DOM object.

xmlWriter.indent:=True
   ;-- Sets whether to indent output.  There is no real need for the
   ;   xmlWriter without this feature

;;;;;xmlWriter.standAlone:=True
;;;;;    ;-- Sets the value of the standalone attribute in the XML declaration to
;;;;;    ;   "yes" or "no".

;;;;;xmlWriter.version:="1.0"
;;;;;    ;-- Specifies the version to include in XML declarations.
   
;;;;;xmlWriter.output:=""
;;;;;    ;-- Sets the destination and the type of output for IMXWriter.
;;;;;    ;   Observation: If set, this property should (must?) be set last.
   
;-- Set the XML writer to the SAX content handler
xmlReader.contentHandler :=xmlWriter
xmlReader.dtdHandler     :=xmlWriter
xmlReader.errorHandler   :=xmlWriter
xmlReader.putProperty("http://xml.org/sax/properties/lexical-handler",xmlWriter)
xmlReader.putProperty("http://xml.org/sax/properties/declaration-handler",xmlWriter)

;-- Trigger the xmlWriter format engine.  Show results.
xmlReader.parse(xmlDoc)
MsgBox %   "After:`n" . xmlWriter.output
   
;;;;;;[========]
;;;;;;[  Save  ]
;;;;;;[========]
;;;;;;-- Create output DOM object
;;;;;xmlOutputDoc:=ComObjCreate("Msxml2.DOMDocument.6.0")
;;;;;xmlOutputDoc.async:=False
;;;;;
;;;;;;-- Load and save
;;;;;xmlOutputDoc.loadXML(xmlWriter.output)
;;;;;xmlOutputDoc.save("FormattedXMLFile.xml")
;;;;;if xmlOutputDoc.parseError.errorCode
;;;;;    {
;;;;;    MsgBox
;;;;;        ,16
;;;;;        ,XML Save Error
;;;;;        ,%   "Unable to save XML data."
;;;;;        . "`nError: " . xmlOutputDoc.parseError.errorCode
;;;;;        . "`nReason: " . xmlOutputDoc.parseError.reason
;;;;;
;;;;;    return
;;;;;    }
;;;;;
;;;;;MsgBox Formatted XML saved to "FormattedXMLFile.xml".  %A_Space%