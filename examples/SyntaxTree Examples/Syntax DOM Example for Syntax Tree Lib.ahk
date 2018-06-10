#Include %A_ScriptDir%\..\SyntaxTree.ahk
#Persistent
SetBatchLines, -1

expressionElement := new SyntaxTree( "classSyntax.xml" )
text := fileOpen( "classSyntax.example", "r" ).Read()
parsed := new expressionElement( text )

s :=  "All the classes and subclasses `ninside classSyntax.example: `t"
for each, className in parsed.document.getElementsBySEID( "className" )
	s .= className.getText() . ", "
s .= "`nOnly the classes `ninside classSyntax.example: `t"
for each, sClass in parsed.document.getChildrenBySEID( "class" )
	s .= sClass.getElementBySEID( "className" ).getText() . ", "
s .= "`nAll the methods `ninside classSyntax.example: `t"
for each, sMethod in parsed.document.getElementsBySEID( "methodName" )
	s .= sMethod.getText() . ", "
Msgbox % s
ExitApp