; Simple XML Get by infogulch
; http://www.autohotkey.com/forum/topic42682.html
sXMLget( xml, node, attr = "" ) {
;by infogulch - simple solution get information out of xml and html
;  supports getting the values from a nested nodes; does NOT support decendant/ancestor or sibling
;  for something more than a little complex, try Titan's xpath: http://www.autohotkey.com/forum/topic17549.html
   RegExMatch( xml
      , (attr ? ("<" node "\b[^>]*\b" attr "=""(?<match>[^""]*)""[^>]*>") : ("<" node "\b[^>/]*>(?<match>(?<tag>(?:[^<]*(?:<(\w+)\b[^>]*>(?&tag)</\3>)*)*))</" node ">"))
      , retval )
   return retvalMatch
}