psTool_get() { ; http://stackoverflow.com/questions/29109677/photoshop-javascript-how-to-get-set-current-tool
	app := ComObjActive("Photoshop.Application")
	actRef := ComObjCreate("Photoshop.ActionReference")

	actRef.putEnumerated( app.charIDToTypeID("capp")
	                    , app.charIDToTypeID("Ordn")
	                    , app.charIDToTypeID("Trgt") )

	ActionDescriptor := app.executeActionGet(actRef)
	tool_id  := ActionDescriptor.getEnumerationType( app.stringIDToTypeID("tool") )
	tool_str := app.typeIDToStringID(tool_id)
	return tool_str
}

; psTool_set("moveTool")
psTool_set(tool) { ; https://autohotkey.com/boards/viewtopic.php?p=23679#p23679
	app := ComObjActive("Photoshop.Application")
		desc9 := ComObjCreate("Photoshop.ActionDescriptor")
			ref7 := ComObjCreate("Photoshop.ActionReference")
			ref7.putClass( app.stringIDToTypeID(tool) )
		desc9.putReference( app.charIDToTypeID("null"), ref7 )
		app.executeAction( app.charIDToTypeID("slct"), desc9, psDisplayNoDialogs := 3 )
}

/*
	moveTool
	marqueeRectTool
	marqueeEllipTool
	marqueeSingleRowTool
	marqueeSingleColumnTool
	lassoTool
	polySelTool
	magneticLassoTool
	quickSelectTool
	magicWandTool
	cropTool
	sliceTool
	sliceSelectTool
	spotHealingBrushTool
	magicStampTool
	patchSelection
	redEyeTool
	paintbrushTool
	pencilTool
	colorReplacementBrushTool
	cloneStampTool
	patternStampTool
	historyBrushTool
	artBrushTool
	eraserTool
	backgroundEraserTool
	magicEraserTool
	gradientTool
	bucketTool
	blurTool
	sharpenTool
	smudgeTool
	dodgeTool
	burnInTool
	saturationTool
	penTool
	freeformPenTool
	addKnotTool
	deleteKnotTool
	convertKnotTool
	typeCreateOrEditTool
	typeVerticalCreateOrEditTool
	typeCreateMaskTool
	typeVerticalCreateMaskTool
	pathComponentSelectTool
	directSelectTool
	rectangleTool
	roundedRectangleTool
	ellipseTool
	polygonTool
	lineTool
	customShapeTool
	textAnnotTool
	soundAnnotTool
	eyedropperTool
	colorSamplerTool
	rulerTool
	handTool
	zoomTool
*/