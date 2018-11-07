#Include %A_ScriptDir%\OOPFunctions.ahk
#Include %A_ScriptDir%\class_String.ahk

class SyntaxTree {

	static elementNames := { parrot: SyntaxTree.ParrotElement, val:SyntaxTree.ValueElement, nval:SyntaxTree.notValueElement, range:SyntaxTree.RangeElement, nrange:SyntaxTree.notRangeElement, alt:SyntaxTree.AlternativeElement, room:SyntaxTree.RoomElement, cons:SyntaxTree.ConsecutiveElement, null:SyntaxTree.ValidElement }

	__New( fileNameOrXMLText )
	{
		static xmlObj := ComObjCreate( "Msxml2.DOMDocument.6.0" ), init := xmlObj.async := false
		if FileExist( fileNameOrXMLText )
			FileRead, xmlText, %fileNameOrXMLText%
		else
			xmlText := fileNameOrXmlText, fileNameOrXmlText := 0
		This.xmlText := xmlText
		xmlObj.loadXML( xmlText )

		xmlObjError := xmlObj.parseError
		if (  xmlObjError.errorCode )
			Throw exception( "Error loading SyntaxTree", A_ThisFunc, xmlObjError.reason )

		definedList  := {}
		elementsID   := {}
		elementCount := {}
		for each, elementTag in This.elementNames
			elementCount[ each ] := 0

		xmlElementLayers  := []
		elementLayers     := []
		indexLayers       := []

		xmlElement        := xmlObj.documentElement.childNodes.item( 0 )

		Loop
		{

			if !( ( elementID := xmlElement.attributes.getNamedItem( "id" ).value ) && elementsID.hasKey( elementID ) )
			{
				elementBase := This.elementNames[ xmlElement.nodeName ]
				if !elementID
					elementID := xmlElement.nodeName . "." . ++elementCount[ xmlElement.nodeName ]
				element := new elementBase()
				element.setID( elementID )
				elementsID[ elementID ] := element
			}
			else
				element := elementsID[ elementID ]
				;create a new undefined element if it doesn't exist yet, load it from an array otherwise

			isElementDefinition := !( ( elementId && definedList[ elementID ] ) || ( hasClass( element, This.ContainerElement ) ? !xmlElement.childNodes.length : !xmlElement.text ) )
			;find out whether the current element is a reference or a defintion


			if ( A_Index > 1 )
				elementLayers.1.getParseData()[ indexLayers.1 ] := element
			else
				This.parseData := element
				;add current element to it's parent

			if isElementDefinition
			{
				;If the current element is not a reference read it's definition here
				xmlElementAttributes := xmlElement.attributes
				Loop % xmlElementAttributes.length()
				{
					attribute := xmlElementAttributes.item( A_Index-1 )
					if ( attribute != "id" && hasCalleable( element,  "set" . attribute.name ) )
						element[ "set" . attribute.name ].call( element, attribute.value )
				}
				;load element attributes

				if ( !isClass( element, This.ValidElement ) ) ;if an element is not a null element
				{
					if ( hasClass( element, This.ContainerElement ) ) ;check if an element is a container element
					{
						xmlElementLayers.insertAt( 1, xmlElement )
						elementLayers.insertAt( 1, element )
						indexLayers.insertAt( 1, 0 )
					;if so push it onto the evaluation stack so that it's children will be the next that get evaluated
					}
					else
						element.getParseData().1 := xmlElement.text ;otherwise define a text element
				}
				if ( elementID )
					definedList[ elementID ] := 1 ;set an element as defined
			}

			While !( ( ++indexLayers.1 - 1 ) < xmlElementLayers.1.childNodes.length )
			{
				;If the current parent element is fully evaluated

				xmlElementLayers.removeAt( 1 )
				elementLayers.removeAt( 1 )
				indexLayers.removeAt( 1 )
				;go upwards in the hierachy until you find an unevaluated one

				if !elementLayers.length()
					break, 2
				;and if the top of the hierachy is reached return the highestmost
			}
			xmlElement := xmlElementLayers.1.childNodes.item( indexLayers.1 -1 )
			;Go to the next element
		}
		This.__New    := This.match
	}

	enableDebugging( callBackProvider )
	{
		if !This.hasKey( "parseData" )
			return -1
		This.generateDebugInfo()
		This.callBackProvider := callBackProvider
		This.parseData.enableDebugging( callBackProvider, This )
		This.debug := 1
	}

	generateDebugInfo()
	{
		helper := This.getDebugHelper()
		Try
			instance := new helper( This.xmlText )
		if !isObject( instance )
			return
		This.debugInfo  := {}
		indexLayers     := []
		XElementLayers  := []
		SElementLayers  := []
		currentXElement := instance.document.getChildBySEID( "tag"  )
		currentSElement := This.parseData
		Loop
		{
			elementID := currentSElement.getID()
			if !This.debugInfo.hasKey( elementID )
				This.debugInfo[ elementID ] := debugInfo := { MentionInfo:["reserved"] }
			else
				debugInfo := This.debugInfo[ elementID ]
			isDefinition := currentXElement.content.1.getID() = "containingTag"

			debugInfo.MentionInfo[ mentionIndex := debugInfo.MentionInfo.Length() * ( !isDefinition ) + 1 ] := { start: currentXElement.getStart(), end: currentXElement.getEnd() }
			if ( A_Index > 1 )
				This.debugInfo[ SELementLayers.1.getId() ].ChildInfo.Push( {SEID:elementID, MentionIndex:MentionIndex} )

			if ( isDefinition && hasClass( currentSElement, SyntaxTree.ContainerElement ) )
			{
				debugInfo.ChildInfo := []
				XElementLayers.insertAt( 1, currentXElement )
				SElementLayers.insertAt( 1, currentSElement )
				indexLayers.insertAt( 1, 0 )
			}

			While !( ++indexLayers.1 <= SELementLayers.1.getParseData().length() )
			{
				indexLayers.removeAt( 1 )
				SElementLayers.removeAt( 1 )
				XElementLayers.removeAt( 1 )
				if !indexLayers.Length()
					break, 2
			}

			currentXElement := XElementLayers.1.getChildrenBySEID( "tag" )[ indexLayers.1 ]
			currentSElement := SELementLayers.1.getParseData()[ indexLayers.1 ]

		}
	}

	getDebugHelper()
	{
		static debugHelper
		if !debugHelper
			debugHelper := new SyntaxTree( "debug.xml" )
		return debugHelper
	}

	match( string )
	{
		This.document := ""
		This.str := new classString( string )
		if This.debug
			This.callBackProvider.startTry( This, 1, This.parseData, 1 )
		Try
			This.document := new This.parseData( This.str )
		catch e
		{
			failed := 1
			if This.debug
				This.callBackProvider.failTry( This, 1, This.parseData, 1, This.document, e )
		}
		if ( This.debug && !failed )
			This.callBackProvider.succeedTry( This, This.document.end, This.parseData, 1, This.document )
	}

	__Delete()
	{
		if ( This.hasKey( "document" ) )
		{
			This.document.freeMatched()
			This.delete( "document" )
		}
		else
		{
			This.parseData.freeSyntax()
			This.delete( "parseData" )
		}
	}

	class ValidElement
	{

		__New( parseData* )
		{
			This.parseData := parseData
			This.__New := This.matchStart
			This.init()
		}

		getEnd()
		{
			return This.end
		}

		getStart()
		{
			return This.start
		}

		getContent()
		{
			return This.content
		}

		matchStart( parent := "" )
		{
			if ( hasClass( parent, SyntaxTree.ValidElement ) )
			{
				This.end    := This.start := parent.getEnd()
				This.str    := parent.str
				This.parent := parent
				This.errors := []
			}
			else
			{
				This.end    := This.start := 1
				This.str    := parent
				This.errors := []
			}
			This.match()
		}

		pushError( AdditionalInfo )
		{
			If ( !SyntaxTree.debug )
			{
				;Msgbox % This.__Class . "`n" . This.id . "`n" . AdditionalInfo "`nat " This.getEnd()
				Throw exception( "Parsing Error", This.__Class, "Error at Position:" . This.getEnd() . " " . AdditionalInfo )
			}
			else
				This.errors.Push( exception( "Parsing Error", This.__Class, "Error at Position:" . This.getEnd() . " " . AdditionalInfo ) )
		}

		hasErrors()
		{
			return !!This.errors.Length()
		}

		isEmpty()
		{
			return ( This.getEnd() = This.getStart() )
		}

		getParseData()
		{
			return This.parseData
		}

		setID( id := "" )
		{
			This.id := id
		}

		getID()
		{
			return This.id
		}

		getParentBySEID( SEID )
		{
			parent := This
			While isObject( parent := parent.getParent() )
				if ( parent.getID() = SEID )
					return parent
		}

		getParent()
		{
			return This.parent
		}

		setOpt( optional := "" )
		{
			this.optional := optional
		}

		getOpt()
		{
			return This.optional
		}

		getText()
		{
			return This.str.subStr( This.getStart(), This.getEnd() - This.getStart() )
		}

		freeSyntax()
		{
			This.Delete( "parseData" )
		}

		freeMatched()
		{
			This.Delete( "str" )
			This.Delete( "parent" )
		}
	}

	class ContainerElement extends SyntaxTree.ValidElement
	{

		matchStart( parent := "" )
		{
			if hasClass( parent, SyntaxTree.ValidElement )
			{
				This.end    := This.start := parent.getEnd()
				This.str    := parent.str
				This.parent := parent
				This.errors  := []
				This.content := []
			}
			else
			{
				This.end     := This.start := 1
				This.str     := parent
				This.errors  := []
				This.content := []
			}
			This.match()
		}

		tryPush( elementNr )
		{
			try
			{
				element := This.parseData[ elementNr ]
				em := new element( This )
				if ( isObject( em ) && hasClass( element, SyntaxTree.validElement ) && !em.hasErrors() )
				{
					This.directPush( em )
					return 1
				}
			}
			catch e
				This.collectError( element, e )
			if ( isObject( em ) )
				This.collectErrors( em )
			if element.getOpt()
				return -1
			else
				return 0
		}

		tryPushDebug( baseTree, thisElement, elementNr )
		{
			baseTree := Object( baseTree )
			element := thisElement.parseData[ elementNr ]
			mentionIndex := baseTree.debugInfo[ thisElement.getID() ].ChildInfo[ elementNr ].mentionIndex
			This.startTry( baseTree, thisElement.end, element, mentionIndex )
			try
			{
				em := new element( thisElement )
				if ( isObject( em ) && hasClass( element, SyntaxTree.validElement ) && !em.hasErrors() )
				{
					thisElement.directPush( em )
					This.succeedTry( baseTree, thisElement.end, element, mentionIndex, em )
					return 1
				}
			}
			catch e
				thisElement.collectError( element, e )
			if ( isObject( em ) )
				thisElement.collectErrors( em )
			This.failTry( baseTree, thisElement.end, element, mentionIndex, em, e )
			if element.getOpt()
				return -1
			else
				return 0
		}

		enableDebugging( callBackProvider, baseTree )
		{
			tryPushDebug := This.tryPushDebug.bind( callBackProvider, &baseTree )
			This.debugFunction( tryPushDebug )
		}

		debugFunction( tryPushDebug )
		{
			This.tryPush := tryPushDebug
			For each, children in This.parseData
				if ( hasClass( children, SyntaxTree.ContainerElement ) && !children.hasKey( "tryPush" ) )
					children.debugFunction( tryPushDebug )
		}

		directPush( element )
		{
			if ( !element.isEmpty() )
			{
				This.content.push( element )
				This.end := element.getEnd()
			}
		}

		getElementsBySEID( SEID )
		{
			indexLayers 	:= [ 0 ]
			containers 	:= [ This ]
			results 		:= []
			if !IsObject( SEID )
				SEID := [ SEID ]
			Loop
			{
				while ( ++indexLayers.1 > containers.1.content.Length() )
				{
					indexLayers.removeAt( 1 )
					containers.removeAt( 1 )
					if ( !indexLayers.Length() )
						return results
				}
				element := containers.1.content[ indexLayers.1 ]
				if ( hasValue( SEID, element.getID() ) )
					results.push( element )
				if ( hasClass( element, SyntaxTree.ContainerElement ) )
					indexLayers.insertAt( 1, 0 ), containers.insertAt( 1, element )
			}
		}

		getElementBySEID( SEID )
		{
			indexLayers 	:= [ 0 ]
			containers 	:= [ This ]
			if !IsObject( SEID )
				SEID := [ SEID ]
			Loop
			{
				while ( ++indexLayers.1 > containers.1.content.Length() )
				{
					indexLayers.removeAt( 1 )
					containers.removeAt( 1 )
					if ( !indexLayers.Length() )
						return
				}
				element := containers.1.content[ indexLayers.1 ]
				if ( hasValue( SEID, element.getID() ) )
					return element
				if ( hasClass( element, SyntaxTree.ContainerElement ) )
					indexLayers.insertAt( 1, 0 ), containers.insertAt( 1, element )
			}
		}

		getChildrenBySEID( childSEID, parentSEID := "" )
		{
			indexLayers 	:= [ 0 ]
			containers 	:= [ This ]
			results 		:= []
			if !IsObject( childSEID )
				childSEID := [ childSEID ]
			if !IsObject( parentSEID )
				parentSEID := parentSEID ? [ parentSEID ] : []
			parentSEID.Push( This.getID() )
			Loop
			{
				while ( ++indexLayers.1 > containers.1.content.Length() )
				{
					indexLayers.removeAt( 1 )
					containers.removeAt( 1 )
					if ( !indexLayers.Length() )
						return results
				}
				element := containers.1.content[ indexLayers.1 ]
				if ( hasValue( childSEID, element.getID() ) )
					results.push( element )
				else if ( hasClass( element, SyntaxTree.ContainerElement ) && !hasValue( parentSEID, element.getID() ) )
					indexLayers.insertAt( 1, 0 ), containers.insertAt( 1, element )
			}
		}

		getChildBySEID( childSEID, parentSEID := "" )
		{
			indexLayers 	:= [ 0 ]
			containers 	:= [ This ]
			if !IsObject( childSEID )
				childSEID := [ childSEID ]
			if !IsObject( parentSEID )
				parentSEID := parentSEID ? [ parentSEID ] : []
			parentSEID.Push( This.getID() )
			Loop
			{
				while ( ++indexLayers.1 > containers.1.content.Length() )
				{
					indexLayers.removeAt( 1 )
					containers.removeAt( 1 )
					if ( !indexLayers.Length() )
						return
				}
				element := containers.1.content[ indexLayers.1 ]
				if ( hasValue( childSEID, element.getID() ) )
					return element
				else if ( hasClass( element, SyntaxTree.ContainerElement ) && !hasValue( element.getID(), parentSEID ) )
					indexLayers.insertAt( 1, 0 ), containers.insertAt( 1, element )
			}
		}

		freeSyntax()
		{
			if ( This.hasKey( "parseData" ) )
			{
				toFree := This.parseData
				This.Delete( "parseData" )
				for each, SyntaxBase in toFree
					SyntaxBase.freeSyntax()
			}
		}

		freeMatched()
		{
			if ( This.hasKey( "content" ) )
			{
				toFree := This.content
				This.Delete( "str" )
				This.Delete( "content" )
				This.Delete( "parent" )
				for each, SyntaxBase in toFree
					SyntaxBase.freeMatched()
			}
		}

	}

	class ValueElement extends SyntaxTree.ValidElement
	{

		;__New( value )

		match()
		{
			This.matchString( This.parseData.1 )
		}

		matchString( matchString )
		{
			pString := This.str.subStr( This.getStart(), strLen( matchString ) )
			if ( This.getCaseSensitive() ? pString == matchString : pString = matchString )
				This.end := This.getStart() + strLen( matchString )
			else
				This.pushError( "Value doesn't match" )
		}

		setCaseSensitive( value := 0 )
		{
			This.caseSensitive := value
		}

		getCaseSensitive()
		{
			return This.caseSensitive
		}

	}

	class notValueElement extends SyntaxTree.ValueElement
	{

		;__New( value )

		match()
		{
			pString := This.str.substr( This.getStart(), strLen( This.parseData.1 ) )
			if ( !( This.getCaseSensitive() ? pString == This.parseData.1 : pString = This.parseData.1 ) )
			{
				This.str.getNextAfter( This.getStart(), length )
				This.end := This.getStart() + length
			}
			else
				This.pushError( "Value doesn't match" )
		}
	}

	class ParrotElement extends SyntaxTree.ValueElement
	{
		match()
		{
			parent := This.getParent()
			While !element := parent.getElementBySEID( This.parseData.1 )
				if !parent := parent.getParent()
					break
			if !( element )
			{
				if ( !default )
					This.pushError( "Lonely Parrot" )
				else
					This.matchString( default )
			}
			else
				This.matchString( element.getText() )
		}
	}

	class RangeElement extends SyntaxTree.ValidElement
	{

		;__New( "0-9a-zA-Z_" ) similar to RegExMatchs []

		static groups := { "\r": [ "`r`n", "`r", "`n" ], "\s": [" ", "`t"] }
		static caseSensitive := 1


		between( min, max )
		{
			val := Ord( This.str.getNextAfter( This.getStart(), length ) ) ;potential multi code unit encoding
			;Msgbox % min . " < " . val . " < " . max
			return ( ( val >= min ) && ( val <= max ) ) * length
		}

		inGroup( grp )
		{
			val := This.str.subStr( This.getStart(), 1 )
			if ( This.getCaseSensitive() )
			{
				for each, grpVal in grp
				{
					if ( 1 = ( len := strLen( grpVal ) ) )
					{
						if ( val == grpVal )
							return 1
					}
					else
						if ( This.str.subStr( This.getStart(), len ) == grpVal )
							return len
				}
			}
			else
				for each, grpVal in grp
				{
					if ( 1 = len := strLen( grpVal ) )
					{
						if ( val = grpVal )
							return 1
					}
					else
						if ( This.str.subStr( This.getStart(), len ) = grpVal )
							return len
				}
			return 0
		}

		match()
		{
			pStr := This.parseData.1
			pos  := 1
			singleCharGrp := []
			While ( pos <= strLen( pStr ) )
			{
				char := Chr( Ord( SubStr( pStr, pos, 2 ) ) )
				pos += strLen( char )
				if ( char = "\" )
				{
					char2 := Chr( Ord( SubStr( pStr, pos, 2 ) ) )
					pos += strLen( char2 )
					if ( This.groups.hasKey( char . char2 ) && isObject( grp := This.groups[ char . char2 ] ) )
					{
						if ( length := This.inGroup( grp ) )
							return This.foundMatch( length )
						continue
					}
					else
						char := char2
				}
				if ( subStr( pStr, pos, 1 ) = "-" )
				{
					pos += 1
					if ( subStr( pStr, pos, 1 ) = "\" )
						pos += 1
					pos += strLen( Chr( ord2 := Ord( SubStr( pStr, pos, 2 ) ) ) )
					if ( len := This.between( ord( char ), ord2 ) )
						return This.foundMatch( len )
					continue
				}
				singleCharGrp.Push( char )
			}
			if ( len := This.inGroup( singleCharGrp ) )
				return This.foundMatch( len )
			This.str.getNextAfter( This.getStart(), len )
			This.noMatchFound( len )
		}

		foundMatch( len )
		{
			This.end := This.getStart() + len
		}

		noMatchFound( len )
		{
			This.pushError( "Value out of range" )
		}

		setCaseSensitive( value := 1 )
		{
			This.caseSensitive := value
		}

		getCaseSensitive()
		{
			return This.caseSensitive
		}

	}

	class notRangeElement extends SyntaxTree.RangeElement
	{

		;__New( "0-9a-zA-Z_" ) similar to RegExMatchs [^]

		static noMatchFound := SyntaxTree.RangeElement.foundMatch
		static foundMatch   := SyntaxTree.RangeElement.noMatchFound

	}

	class RoomElement extends SyntaxTree.ContainerElement
	{

		;__New( body, [seperator, padding, leftBorder, rightBorder )]

		static min := 1

		match()
		{
			if ( isObject( This.parseData.4 ) && !isClass( This.parseData.4, SyntaxTree.ValidElement ) )
				if ( !This.tryPush( 4 ) )
				{
					This.pushError( "Missing left Border" )
					return
				}
			contentCount := 0
			if ( isObject( This.parseData.2 ) && !isClass( This.parseData.2, SyntaxTree.ValidElement ) )
			{
				This.pushPadding( mString )
				if This.tryPush( 1 )
				{
					contentCount++
					Loop
					{
						This.pushPadding()
						result  := This.tryPush( 2 )
						if !result
							break
						This.pushPadding()
						result2 := This.tryPush( 1 )
						if !result2
						{
							if ( result = 1 )
								This.pushError( "Sperator without following Content" )
							else
								break
							return
						}
						contentCount++
						if ( result + result2 = -2 )
							break
					}
				}
			}
			else
				While ( This.pushPadding() && This.tryPush( 1 ) = 1 )
					contentCount++
			if ( This.getMin() && contentCount < This.getMin() )
				This.pushError( "Room too small" )
			else if ( This.getMax() && contentCount > This.getMax() )
				This.pushError( "Room too large" )
			if isObject( This.parseData.5 )
				if ( !This.tryPush( 5 ) )
				{
					This.pushError( "Missing right Border" )
					return
				}
		}

		pushPadding()
		{
			if ( isObject( This.parseData.3 ) && !isClass( This.parseData.3, SyntaxTree.ValidElement ) )
			{
				res := This.tryPush( 3 )
				;Msgbox % """" subStr( mString, This.getEnd(), 1 ) """" . "`n" . res . "`n" . disp( This.parseData.3 )
			}
			return 1
		}

		setMin( min := 1 )
		{
			This.min := min
		}

		setMax( max := "" )
		{
			This.max := max
		}

		getMin()
		{
			return This.min
		}

		getMax()
		{
			return This.max
		}

	}

	class AlternativeElement extends SyntaxTree.ContainerElement
	{
		;__New( alternatives* )

		match()
		{
			for each, alternative in This.parseData
			{
				result := This.tryPush( each )
				if ( result = 1 )
					return
				else if ( result = -1 )
					opt := 1
			}
			if ( !opt )
				This.pushError( "No match" )
		}

	}

	class ConsecutiveElement extends SyntaxTree.ContainerElement
	{

		;__New( consecutiveElements* )

		match()
		{
			for each, follower in This.parseData
				if !This.tryPush( each )
					This.pushError( "Missing Element" )
		}

	}

	class OptionlElement extends SyntaxTree.ConsecutiveElement
	{

		;Man fuck this thing

		static min := 0

		match()
		{
			for each, follower in This.parseData
				if !This.tryPush( each )
				{
					if ( !( min := This.getMin() ) || each < min )
						This.pushError( "Missing Element" )
					else
						return
				}
		}

		getMin()
		{
			return This.min
		}

		setMin( min )
		{
			This.min := min
		}

	}

}

stripIndent( str ) {
	out := ""
	For each,  line in strSplit( str, "`r`n" )
		out .= trim( line ) . "`r`n"
	return out
}

indentText( str, amount ) {
	out  := ""
	out2 := ""
	Loop %amount%
		out2 .= "`t"
	For each,  line in strSplit( str, "`r`n" )
		out .= out2 . line . "`r`n"
	return out
}