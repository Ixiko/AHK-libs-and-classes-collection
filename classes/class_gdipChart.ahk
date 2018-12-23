#Include %A_ScriptDir%\class_GDIp.ahk

/*
	A rewrite of Nighs gdiChart.ahk
	Thanks for gdiCharts awesome code.
	
*/

class gdipChart
{
	
	__New( hWND, controlRect := "", fieldRect := "", type := "line" )
	{
		This.API := new GDIp()
		This.allData     := []
		This.visibleData := []
		This.axes        := new This.Axes( This )
		This.grid        := new This.Grid( This )
		This.label       := new This.Label( This )
		This.sethWND( hWND )
		if controlRect
			This.setControlRect( controlRect )
		This.setFieldRect( isObject( fieldRect ) ? fieldRect : [ 0, 0, 1, 1 ] )
		This.setType( type )
		This.setColor( 0xFFFFFFFF )
		This.setMargin( [ 20, 20, 20, 20 ] )
	}
	
	__Delete()
	{
		This.setVisible( false )
		This.base := ""
	}
	
	
	setType( type := "line" )
	{
		if ( This.type!= type )
		{
			This.type := type
			This.touch()
		}
	}
	
	getType()
	{
		return This.type
	}
	
	
	setColor( color )
	{
		if ( This.color != color )
		{
			This.color := color
			This.touch()
		}
	}
	
	getColor()
	{
		return This.color
	}
	
	
	setVisible( bVisible := true )
	{
		bVisible := !!bVisible 
		if ( This.getVisible() ^ bVisible )
		{
			This.visible := bVisible
			This.sendRedraw()
		}
	}
	
	getVisible()
	{
		return This.hasKey( "visible" ) && This.visible
	}
	
	
	setFieldRect( rect )
	{
		This.fieldRect := rect
		This.touch()
	}
	
	getFieldRect()
	{
		return This.fieldRect.clone()
	}
	
	
	setControlRect( rect := "" )
	{
		if rect
			This.controlRect := rect
		This.touch()
	}
	
	getControlRect()
	{
		static rectI := "", init := VarSetCapacity( rectI, 16, 1 )
		if This.hasKey( "controlRect" )
			return This.controlRect.clone()
		DllCall( "GetClientRect", "UPtr", This.getHWND(), "UPtr", &rectI )
		outRect := []
		Loop 4
			outRect.Push( numGet( rectI, A_Index * 4 - 4, "UInt" ) )
		return outRect
	}
	
	isControlRectRelative()
	{
		return !This.hasKey( "controlRect" )
	}
	
	setHWND( hWND )
	{
		if  ( This.hWND && same := hWND != This.hWND )
			This.unregisterRedraw(), This.sendRedraw()
		This.hWND := hWND
		if !same
			This.registerRedraw(),This.touch()
	}
	
	getHWND()
	{
		return This.hWND
	}
	
	getWindowHWND()
	{
		return DllCall( "GetAncestor", "UPtr", This.hWND, "UInt", 3 )
	}
	
	
	setMargin( margin )
	{
		This.margin := margin
		This.touch()
	}
	
	getMargin()
	{
		return This.margin
	}
	
	setFreezeRedraw( bFreeze )
	{
		bFreeze := !!bFreeze
		if ( This.getFreezeRedraw() && !bFreeze && This.hasChanged )
			This.freeze := bFreeze, This.touch()
		else
			This.freeze := bFreeze
	}
	
	getFreezeRedraw()
	{
		return This.freeze
	}
	
	
	touch()
	{
		This.hasChanged := 1
		if ( This.getVisible() && !This.getFreezeRedraw() )
			This.sendRedraw()
	}
	
	sendRedraw()
	{
		PostMessage,0xF,0,0,,% "ahk_id " . This.getWindowHWND() 
	}
	
	
	addDataStream( data := "", color := 0xFF000000, name := "" )
	{
		dataStream := new This.DataStream( This, data, color, name )
		This.allData[ &dataStream ] := new indirectReference( dataStream )
		return dataStream
	}
	
	removeDataStream( dataStream )
	{
		This.allData.Delete( &dataStream )
	}
	
	class DataStream
	{
		
		__New( parent, data := "", color := 0xFF000000, name := "" )
		{
			This.parent := new indirectReference( parent )
			if data
				This.setData( data )
			This.setColor( color )
			if name
				This.setName( name )
		}
		
		__Delete()
		{
			This.setVisible( false )
			This.parent.removeDataStream( This )
			This.base := ""
		}
		
		
		setVisible( bVisible := true )
		{
			bVisible := !!bVisible 
			if ( This.getVisible() ^ bVisible )
			{
				This.visible := bVisible
				if This.visible
					This.parent.addVisibleData( This )
				else
					This.parent.removeVisibleData( This )
				This.parent.touch()
			}
		}
		
		getVisible()
		{
			return This.hasKey( "visible" ) && This.visible
		}
		
		
		setColor( color )
		{
			if ( This.color != color )
			{
				This.color := color
				This.touch()
			}
		}
		
		getColor()
		{
			return This.color
		}
		
		
		setName( name )
		{
			if ( This.name != name )
			{
				This.name := name
				if This.parent.getNameVisible()
					This.touch()
			}
		}
		
		getName()
		{
			return This.name
		}
		
		
		setData( data := "" )
		{
			If ( data )
				This.data := data
			If This.hasKey( "data" )
				This.touch()
		}
		
		getData()
		{
			return This.data
		}
		
		
		touch()
		{
			if This.getVisible()
				This.parent.touch()
		}
		
	}
	
	addVisibleData( dataStream )
	{
		This.visibleData[ &dataStream ] := new indirectReference( dataStream )
	}
	
	removeVisibleData( dataStream )
	{
		This.visibleData.Delete( &dataStream )
	}
	
	getAxes()
	{
		return This.axes
	}
	
	class Axes
	{
		
		__New( parent )
		{
			This.setColor( 0xFF000000 )
			This.setOrigin( [ 0, 0 ] )
			This.parent := new indirectReference( parent )
			This.setAttached( 1 )
			This.setVisible()
		}
		
		setVisible( bVisible := true )
		{
			bVisible := !!bVisible 
			if ( This.getVisible() ^ bVisible )
			{
				This.visible := bVisible
				This.parent.touch()
			}
		}
		
		getVisible()
		{
			return This.hasKey( "visible" ) && This.visible
		}
		
		setColor( color )
		{
			if ( color != This.color )
			{
				This.color := color
				This.touch()
			}
		}
		
		getColor()
		{
			return This.color
		}
		
		/*
			origin: A point ( an array in the form [ x, y ] ) that defines the axes position relative to or on the field.
		*/
		
		setOrigin( origin )
		{
			This.origin := origin
			This.touch()
		}
		
		getOrigin()
		{
			return This.origin
		}
		
		setAttached( bAttached )
		{
			bAttached := !!bAttached
			if ( This.getAttached() ^ bAttached )
			{
				This.attached := bAttached
				This.touch()
			}
		}
		
		getAttached()
		{
			return This.hasKey( "attached" ) && This.attached
		}
		
		touch()
		{
			If This.getVisible()
				This.parent.touch()
		}
		
	}
	
	getGrid()
	{
		return This.grid
	}
	
	class Grid
	{
		
		__New( parent )
		{
			This.parent := new indirectReference( parent )
			This.setVisible( 0 )
			This.setOrigin( [ 0, 0 ] )
			This.setFieldSize( [ 1, 1 ] )
			This.setFieldsPerView( 10 )
			This.setColor( 0xFFA0A0A0 )
			This.setVisible()
		}
		
		setVisible( bVisible := true )
		{
			bVisible := !!bVisible 
			if ( This.getVisible() ^ bVisible )
			{
				This.visible := bVisible
				This.parent.touch()
			}
		}
		
		getVisible()
		{
			return This.hasKey( "visible" ) && This.visible
		}
		
		setColor( color )
		{
			if ( color != This.color )
			{
				This.color := color
				This.touch()
			}
		}
		
		getColor()
		{
			return This.color
		}
		
		/*
			origin: type point
		*/
		
		setOrigin( origin )
		{
			This.origin := origin
			This.touch()
		}
		
		getOrigin()
		{
			return This.origin
		}
		
		/*
			size: type Point
		*/
		
		setFieldSize( size )
		{
			This.fieldSize := size
			This.touch()
		}
		
		getFieldSize()
		{
			return This.fieldSize
		}
		
		setFieldsPerView( perView )
		{
			This.fieldsPerView := perView
			This.touch()
		}
		
		getFieldsPerView()
		{
			return This.fieldsPerView
		}
		
		touch()
		{
			If This.getVisible()
				This.parent.touch()
		}
		
	}
	
	getLabel()
	{
		return This.label
	}
	
	class Label
	{
		
		__New( parent )
		{
			This.parent := new indirectReference( parent )
			This.setVisible( 0 )
			This.setFieldsPerLabel( 2 )
			This.setColor( 0xFF000000 )
			This.setFamily( "Arial" )
			This.setSize( 12 )
			This.setMargin( [ 3, 3, 3, 3 ] )
			This.setVisible()
		}
		
		setVisible( bVisible := true )
		{
			bVisible := !!bVisible 
			if ( This.getVisible() ^ bVisible )
			{
				This.visible := bVisible
				This.parent.touch()
			}
		}
		
		getVisible()
		{
			return This.hasKey( "visible" ) && This.visible
		}
		
		setFieldsPerLabel( fieldsPerLabel )
		{
			This.fieldsPerLabel := fieldsPerLabel
			This.touch()
		}
		
		getFieldsPerLabel()
		{
			return This.fieldsPerLabel
		}
		
		setColor( color )
		{
			if ( color != This.color )
			{
				This.color := color
				This.touch()
			}
		}
		
		getColor()
		{
			return This.color
		}
		
		setFamily( family )
		{
			if ( family != This.family )
			{
				This.family := family
				This.touch()
			}
		}
		
		getFamily()
		{
			return This.family
		}
		
		setSize( size )
		{
			if ( size != This.size )
			{
				This.size := size
				This.touch()
			}
		}
		
		getSize()
		{
			return This.size
		}
		
		setMargin( margin )
		{
			This.margin := margin
			This.touch()
		}
		
		getMargin()
		{
			return This.margin
		}
		
	}
	
	updateFrameRegion()
	{
		targetRect := This.getControlRect()
		marginRect := This.getMargin()
		;Get Margin and the position on the GUI
		frameRegion     := []
		modeOn          := {}
		targetFieldRect := [ targetRect.1 + marginRect.1, targetRect.2 + marginRect.2, targetRect.3 - marginRect.1 - marginRect.3 , targetRect.4 - marginRect.2 - marginRect.4 ]
		;Then combine them
		sourceRect := This.getFieldRect()
		;Get the position of the Field ( basically the part of the data the Chart is displaying )
		
		translateRectOn    := [ 0, 0, ( targetFieldRect.3 - 1 ) / sourceRect.3, -( targetFieldRect.4 - 1 ) / sourceRect.4 ]
		translateRectOn.1  := targetFieldRect.1 - sourceRect.1 * translateRectOn.3
		translateRectOn.2  := targetFieldRect.2 - ( sourceRect.2 + sourceRect.4 ) * translateRectOn.4
		translateRectRelative   := translateRectOn.Clone()
		translateRectRelative.1 := targetFieldRect.1
		translateRectRelative.2 := targetFieldRect.2 - sourceRect.4 * translateRectRelative.4
		translateRectAbsolute    := [ 0, 0, targetFieldRect.3 - 1 , -( targetFieldRect.4 - 1 ) ]
		translateRectAbsolute.1  := targetFieldRect.1
		translateRectAbsolute.2  := targetFieldRect.2 - translateRect.4
		This.frameRegion := { 0: translateRectOn, 1: translateRectRelative, 2: translateRectAbsolute, region: targetFieldRect }
	}
	
	
	getFrameRegion()
	{
		return This.frameRegion
	}
	
	/*
		point:	the point.
		
		mode:	The mode of the field that's the source ( 0|1|2 )
		0:On: The point is on the field, 1:relative: same as on but doesn't move with the field, 2:absolute: [ 0, 0 ] is the left lower point of the field [ 1, 1 ] is the right upper
		
		clamp:	Defines the behaviour of the function if the point is outside the field ( 0|1|2 )
		0:error: returns null 1:clamp: clamps the point inside 2:ignore: doesn't check if it's inside the field
		
		round:	Will round the result
		
	*/
	
	getPointFieldToPixel( point, mode := 0, clamp := 0, round := 0 )
	{
		frameRegion := This.getFrameRegion()
		region      := frameRegion.region
		translate   := frameRegion[ mode ]
		fPoint := [ point.1 * translate.3 + translate.1, point.2 * translate.4 + translate.2 ]
		if ( clamp = 1 )
		{
			if ( fPoint.1 < region.1 )
				fPoint.1 := region.1
			else if ( fPoint.1 > region.1 + region.3 )
				fPoint.1 := region.1 + region.3
			if ( fPoint.2 < region.2 )
				fPoint.2 := region.2
			else if ( fPoint.2 > region.2 + region.4 )
				fPoint := region.2 + region.4
		}
		else if ( !clamp )
			if ( ( fPoint.1 < region.1 ) || ( fPoint.2 < region.2 ) || ( fPoint.1 > region.1 + region.3 ) || ( fPoint.2 > region.2 + region.4 ) )
				return
		if ( round )
			for each, value in fPoint
				fPoint[ each ] := Round( value )
		return fPoint
	}
	
	getLineFieldToPixel( inLine,  mode := 0,  clamp := 0,  round := 0 )
	{
		outLine := []
		for each, point in inLine
			outLine[ each ] := This.getPointFieldToPixel( point,  mode, clamp, round )
		return outLine
	}
	
	getPointPixelToField( fpoint, mode := 0, clamp := 0, round := 0 )
	{
		fpoint      := fpoint.clone()
		frameRegion := This.getFrameRegion()
		region      := frameRegion.region
		translate   := frameRegion[ mode ]
		if ( clamp = 1 )
		{
			if ( fPoint.1 < region.1 )
				fPoint.1 := region.1
			else if ( fPoint.1 > region.1 + region.3 )
				fPoint.1 := region.1 + region.3
			if ( fPoint.2 < region.2 )
				fPoint.2 := region.2
			else if ( fPoint.2 > region.2 + region.4 )
				fPoint := region.2 + region.4
		}
		else if ( !clamp )
			if ( ( fPoint.1 < region.1 ) || ( fPoint.2 < region.2 ) || ( fPoint.1 > region.1 + region.3 ) || ( fPoint.2 > region.2 + region.4 ) )
				return
		point := [ ( fPoint.1 - translate.1 ) / translate.3, ( fPoint.2 - translate.2 ) / translate.4 ]
		if ( round )
			for each, value in point
				point[ each ] := Round( value )
		return point
	}
	
	clampPointToRect( point, rectNr := 0 )
	{
		point := point.clone()
		rect := { 0:fieldRect := This.getFieldRect(), 1:[ 0, 0, fieldRect.3, fieldRect.4 ], 2:[ 0, 0, 1, 1 ] }[ rectNr ]
		if ( point.1 < rect.1 )
			point.1 := rect.1
		else if ( point.1 > rect.1 + rect.3 )
			point.1 := rect.1 + rect.3
		if ( point.2 < rect.2 )
			point.2 := rect.2
		else if ( point.2 > rect.2 + rect.4 )
			point := rect.2 + rect.4
		return point
	}
	
	getFieldPointToRect( point, SourceRectNr := 1, TargetRectNr := 0 )
	{
		transSource := This.getFrameRegion()[ SourceRectNr ]
		transTarget := This.getFrameRegion()[ TargetRectNr ]
		return [ ( ( point.1 * transSource.3 + transSource.1 ) - transTarget.1 ) / transTarget.3 , ( ( point.2 * transSource.4 + transSource.2 ) - transTarget.2 ) / transTarget.4 ]
	}
	
	updateGeometry()
	{
		This.geometry := {}
		grid         := This.getGrid()
		fieldSize    := grid.getFieldSize()
		fieldsPerView:= grid.getFieldsPerView()
		origin       := grid.getOrigin()
		
		fieldRect    := This.getFieldRect()
		region       := This.getFrameRegion().region
		
		fieldsPerX   := ( region.3 / region.4 ) ** 0.5 * fieldsPerView 
		fieldsPerY   := ( region.4 / region.3 ) ** 0.5 * fieldsPerView 
		
		fieldSize    := [ fieldSize.1 * ( 2 ** Round( log2(  fieldRect.3 / fieldsPerX / fieldSize.1 ) ) ), fieldSize.2 * ( 2 ** Round( log2( fieldRect.4 / fieldsPerY / fieldSize.2  ) ) ) ]
		offset       := [ modulo( origin.1 - fieldRect.1, fieldSize.1 ),  modulo( origin.2 - fieldRect.2, fieldSize.2 ) ]
		offset.1     += ( offset.1 < 0 ) ? fieldSize.1 : 0, offset.2 += ( offset.2 < 0 ) ? fieldSize.2 : 0
		offset       := [ fieldRect.1 + offset.1, fieldRect.2 + offset.2  ]
		
		This.geometry.grid := { lines:[[], []], size:fieldSize }
		
		Loop % floor( ( fieldRect.3 - offset.1 + fieldRect.1 ) / fieldSize.1 ) + 1
			This.geometry.grid.lines.1.Push( [ [ pos := offset.1 + fieldSize.1 * ( A_Index - 1 ) , fieldRect.2 ] ,[ pos , fieldRect.2 + fieldRect.4 ] ] )
		
		Loop % floor( ( fieldRect.4 - offset.2 + fieldRect.2 ) / fieldSize.2 ) + 1
			This.geometry.grid.lines.2.Push( [ [ fieldRect.1 , pos := offset.2 + fieldSize.2 * ( A_Index - 1 ) ] ,[ fieldRect.1 + fieldRect.3 , pos ] ] )
		
		axes   := This.getAxes()
		origin := axes.getOrigin()
		if ( !axes.getAttached() )
			origin := This.getFieldPointToRect( origin )
		origin := This.clampPointToRect( origin )
		This.geometry.axes := { lines:[ [ [ fieldRect.1 , origin.2 ], [ fieldRect.1 + fieldRect.3 , origin.2 ] ], [ [ origin.1, fieldRect.2 ], [ origin.1, fieldRect.2 + fieldRect.4 ] ] ], origin: origin }
		
	}
	
	getGridLines()
	{
		return This.geometry.grid.lines
	}
	
	getAxesLines()
	{
		return This.geometry.axes.lines
	}
	
	draw()
	{
		static drawing := 0
		if ( drawing )
			return
		drawing := 1
		if This.getVisible()
		{
			if ( This.hasChanged && !This.getFreezeRedraw() )
			{
				This.hasChanged := 0
				This.prepareBuffers()
				This.drawBackGround()
				This.drawGrid()
				This.drawData()
				This.drawAxes()
				This.drawLabels()
			}
			This.flushToGUI()
		}
		drawing := 0
	}
	
	prepareBuffers()
	{
		size := This.getControlRect()
		size.removeAt( 1, 2 )
		This.bitmap := new GDIp.Bitmap( size )
		This.bitmap.getGraphics().setInterpolationMode( 7 )
		This.bitmap.getGraphics().setSmoothingMode( 4 )
		This.bitmap.getGraphics().setTextRenderingHint( 4 )
		This.updateFrameRegion()
		This.updateGeometry()
	}
	
	drawBackGround()
	{
		This.bitmap.getGraphics().clear( This.getColor() )
	}
	
	drawGrid()
	{
		grid := This.getGrid()
		if !( grid.getVisible() )
			return
		
		graphics := This.bitmap.getGraphics()
		pen      := new GDIp.Pen( grid.getColor(), 1 )
		For each,  lines in This.getGridLines()
			For each, line in lines
				graphics.drawLine( pen , This.getLineFieldToPixel( line, 0, 2, 1 ) )
	}
	
	drawData()
	{
		graphics     := This.bitmap.getGraphics()
		pen          := new GDIp.Pen( 0xFF000000, 1 )
		brush        := new Gdip.SolidBrush( 0xFF000000 )
		fieldRect    := This.getFrameRegion().region
		graphics.setClipRect( This.bitmap.getRegion() )
		graphics.setClipRect( fieldRect, 3 )
		For each, visibleDataStream in This.visibleData
		{
			streamColor := visibleDataStream.getColor()
			pen.setColor( streamColor )
			brush.setColor( streamColor )
			data := visibleDataStream.getData()
			lastPoint      := ""
			lastPointDrawn := ""
			For each, point in data
			{
				thisPoint := This.getPointFieldToPixel( point, 0, 2, 0 )
 				if ( isObject( lastpoint ) && ( thispoint.1 >= fieldRect.1 ) && ( thispoint.1 <= fieldRect.1 + fieldRect.3 ) )
					graphics.drawLine( pen, [ lastpoint, thispoint ] ), lastPointDrawn := 1
				else if ( lastPointDrawn )
				{
					graphics.drawLine( pen, [ lastpoint, thispoint ] )
					break, 1
				}
 				lastPoint := thispoint
			}
		}
		graphics.resetClip()
	}
	
	drawAxes()
	{
		axes      := This.getAxes()
		if !axes.getVisible()
			return
		graphics  := This.bitmap.getGraphics()
		pen       := new GDIp.pen( axes.getColor(), penWidth := 2 )
		
		
		xAxis   := This.getLineFieldToPixel( This.getAxesLines().1, 0, 2, 1 )
		yAxis   := This.getLineFieldToPixel( This.getAxesLines().2, 0, 2, 1 )
		
		graphics.drawLine( pen, xAxis )
		xTarget := xAxis.2
		graphics.drawLine( pen, [ [ xTarget.1 - 15, xTarget.2 - 2 ], [ xTarget.1 - 5, xTarget.2 ] ] )
		graphics.drawLine( pen, [ [ xTarget.1 - 15, xTarget.2 + 2 ], [ xTarget.1 - 5, xTarget.2 ] ] )
		;Arrows
		
		graphics.drawLine( pen, yAxis )
		yTarget := yAxis.2
		graphics.drawLine( pen, [ [ yTarget.1 - 2, yTarget.2 + 15 ], [ yTarget.1, yTarget.2 + 5 ] ] )
		graphics.drawLine( pen, [ [ yTarget.1 + 2, yTarget.2 + 15 ], [ yTarget.1, yTarget.2 + 5 ] ] )
		;Thanks to Nigh for these Awesome Arrows
	}
	
	drawLabels()
	{
		label             := This.getLabel()
		if ( label.getVisible() && This.getAxes().getVisible() )
			
		graphics  := This.bitmap.getGraphics()
		
		axesOrigin:= This.geometry.axes.origin
		grid      := This.geometry.grid
		
		margin            := label.getMargin()
		labelFamily       := new GDIp.FontFamily( label.getFamily() )
		labelFont         := new GDIp.Font( labelFamily, label.getSize() )
		labelStringFormat := new GDIp.StringFormat()
		labelBrush        := new GDIp.SolidBrush( label.getColor() )
		
		for each, pos in grid.lines.1
		{
			if ( mod( Round( pos.1.1 / grid.size.1 ), label.getFieldsPerLabel() ) )
				continue
			tPoint    := This.getPointFieldToPixel( [ xPos := pos.1.1, axesOrigin.2 ], 0, 2, 1 )
			str       := fitNr( xPos, 3 )
			strRect   := graphics.measureString( str, labelFont, This.bitmap.getRect(), labelStringFormat )
			strRect.rect.1 := tPoint.1 - strRect.rect.3/2
			strRect.rect.2 := tPoint.2 + 2 + margin.2
			graphics.drawString( str, labelFont, strRect.rect, labelStringFormat, labelBrush )
		}
		for each, pos in grid.lines.2
		{
			if ( mod( Round( pos.2.2 / grid.size.2 ), label.getFieldsPerLabel() ) )
				continue
			tPoint    := This.getPointFieldToPixel( [ axesOrigin.1, yPos := pos.2.2 ], 0, 2, 1 )
			str       := fitNr( yPos, 3 )
			strRect   := graphics.measureString( str, labelFont, This.bitmap.getRect(), labelStringFormat )
			strRect.rect.1 := tPoint.1 - 2 - margin.3 - strRect.rect.3
			strRect.rect.2 := tPoint.2 - strRect.rect.4/2
			graphics.drawString( str, labelFont, strRect.rect, labelStringFormat, labelBrush )
		}
	}
	
	flushToGUI()
	{
		targetDC := new GDI.DC( This.gethWND() )
		graphics := targetDC.getGraphics()
		graphics.drawBitmap( This.bitmap, This.getControlRect(), This.bitmap.getRect() )
		targetDC.__Delete()
	}
	
	flushToFile( fileName )
	{
		if This.hasChanged
			This.draw()
		This.bitmap.saveToFile( fileName )
	}
	
	registerRedraw()
	{
		hWND := This.getWindowhWND()
		if !( gdipChart.hasKey( "windows" ) )
		{
			OnMessage( 0xF, gdipChart.WM_PAINT )
			OnMessage( 0x214, gdipChart.WM_SIZEing )
			OnMessage( 0x5, gdipChart.WM_SIZEing )
			gdipChart.windows := { ( hWND ): { &This: new indirectReference( This ) } }
		}
		else if !gdipChart.windows.hasKey( hWND )
			gdipChart.windows[ hWND ] := { ( &This ): new indirectReference( This ) }
		else
			gdipChart.windows[ hWND, &This ] := new indirectReference( This )
	}
	
	unregisterRedraw()
	{
		hWND := This.getWindowhWND()
		gdipChart.windows[ hWND ].Delete( &This )
		if !gdipChart.windows[ hWND ]._NewEnum().Next( key, value )
			gdipChart.windows.Delete( hWND )
		else if !gdipChart.windows._NewEnum().Next( key, value )
		{
			gdipChart.Delete( "windows" )
			OnMessage( 0xF, gdipChart.WM_PAINT, 0 )
			OnMessage( 0x214, gdipChart.WM_SIZEing, 0 )
			OnMessage( 0x5, gdipChart.WM_SIZEing, 0 )
		}
	}
	
	WM_PAINT( lParam, msg, hWND )
	{
		arr := gdipChart.windows[ hWND + 0 ]
		for each, obj in arr
			obj.draw()
	}
	
	WM_SIZEing( lParam, msg, hWND )
	{
		arr := gdipChart.windows[ hWND + 0 ]
		for each, obj in arr
			if ( obj.isControlRectRelative() && ( hWND = obj.getHWND() ) )
				obj.setControlRect()
	}
	
}

log2( value )
{
	static base := log( 2 )
	return log( value ) / base
}

/*
	Thanks jNizM
*/
modulo(x, y)
{
	return x - ((x // y) * y)
}

fitNr( nr, significants )
{
	nr := Format( "{:.15f}", nr )
	neg := subStr( nr, 1, 1 ) = "-"
	splNr1 := StrSplit( nr, ".", "-" )
	nr := splNr1.1
	if ( StrLen( nr ) >= significants || splNr1.2 = "000000000000000" )
		return ( neg?"-":"" ) . nr
	splNr2 := StrSplit( splNr1.2 )
	splNr2.1 := "." . splNr2.1
	Loop % significants - StrLen( nr )
		nr .= splNr2[ A_Index ]
	return ( neg?"-":"" ) . nr
}