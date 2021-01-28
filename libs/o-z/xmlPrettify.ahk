XmlPrettify(input, params) {
	return sXML_Pretty(input)
}


XmlUglify(input, params) {
	return sXML_Pretty(input, "")
}


sXML_Pretty( XML, IndentationUnit="`t" ) { ; Adds linefeeds (LF, asc 10) and indentation between XML tags.
; NOTE: If the XML does not begin with a "<?xml...?>" tag, the output will begin with a newline.
	StringLen, il, IndentationUnit
	Loop, Parse, XML, <
		If ( A_Index = 1 )
			VarSetCapacity( XML, Round( StrLen( XML ) * ( A_IsUnicode ? 2.3 : 1.15 ) ), 0 )
		Else
			Loop, Parse, A_LoopField, >, % "`t`n`r " Chr( 160 )
				If ( A_Index = 1 )
				{
					closetag := SubStr( A_LoopField, 1, 1 )
					emptytag := SubStr( A_LoopField, 0 )
					If ( closetag = "?" ) && ( emptytag = "?" )
						XML := "<" A_LoopField
					Else
					{
						If ( closetag = "/" )
						{
							StringTrimRight, indent, indent, il
							If ( priortag ) {
								If ( il )
									XML .= "`n"
								XML .= indent
							}
						}
						Else
						{
							If ( il )
									XML .= "`n"
							XML .= indent
							If ( emptytag != "/" ) && ( closetag != "!" )
								indent .= IndentationUnit
						}
						XML .= "<" A_LoopField
					}
					priortag := closetag = "/" || closetag = "!" || emptytag = "/"
				}
				Else
					XML .= ">" A_LoopField
	Return Trim(XML, " `t`n`r")
} ; END - sXML_Pretty( XML, IndentationUnit="`t" )
