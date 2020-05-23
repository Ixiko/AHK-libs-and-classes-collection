; ~ This version was created from QMK_F24_macro_keyboard.ahk
;~ WHERE TO LOOK FOR HELP:
;~ Taran VH: 					https://youtu.be/GZEoss4XIgc
;~ Taran Github: 				https://github.com/TaranVH/2nd-keyboard/
;~ Tool for AHK:				http://fincs.ahk4.net/scite4ahk/
;~ COM help:					https://docs.microsoft.com/en-us/office/vba/api/word.application
;~ Here is the full list of scan code substitutions that I made:
;~ https://docs.google.com/spreadsheets/d/1GSj0gKDxyWAecB3SIyEZ2ssPETZkkxn67gdIwL1zFUs/edit#gid=824607963

;; COOL BONUS BECAUSE YOU'RE USING QMK:
;; The up and down keystrokes are registered seperately. Therefore, your macro can do half of its action on the down stroke,
;; and the other half on the up stroke. (using "keywait,"). This can be very handy in specific situations.

;~ This version is suited to Asian keyboard layout, 101 keys (Base: 71, Navigation: 13, NumPad: 17).

; ~ TASKS TO BE COMPLETED:
; ~ - changing the order of graphic objects - ShapeRange.ZOrder
; ~ - register the macro


HideSelectedText() 	{
	global oWord
	global  WordTrue, WordFalse

	oWord := ComObjActive("Word.Application")
	OurTemplate := oWord.ActiveDocument.AttachedTemplate.FullName
	if (OurTemplate = OurTemplateEN || OurTemplate = OurTemplatePL)
	{
		nazStyl := oWord.Selection.Style.NameLocal
		if (nazStyl = "Ukryty ms")
			Send, ^{Space}
		else
		{
			language := oWord.Selection.Range.LanguageID
			oWord.Selection.Paragraphs(1).Range.LanguageID := language
			TemplateStyle("Ukryty ms")
		}
	}
	else
	{
		StateOfHidden := oWord.Selection.Font.Hidden
		oWord.Selection.Font.Hidden := WordTrue
		If (StateOfHidden == WordFalse)
		{
			oWord.Selection.Font.Hidden := WordTrue
			}
		else
		{
			oWord.Selection.Font.Hidden := WordFalse
		}
	}

	oWord := "" ; Clear global COM objects when done with them
	}

ToggleApplyStylesPane() 	{
	global oWord
	global  WordTrue, WordFalse

	oWord := ComObjActive("Word.Application")
	ApplyStylesTaskPane := oWord.CommandBars("Apply styles").Visible
	If (ApplyStylesTaskPane = WordFalse)
		oWord.Application.TaskPanes(17).Visible := WordTrue
	Else If (ApplyStylesTaskPane = WordTrue)
		oWord.CommandBars("Apply styles").Visible := WordFalse

	oWord := ""
	}

DeleteLineOfText() 	{
	global oWord
	oWord := ComObjActive("Word.Application")
	oWord.Selection.HomeKey(Unit := wdLine := 5)
	oWord.Selection.EndKey(Unit := wdLine := 5, Extend := wdExtend := 1)
	oWord.Selection.Delete(Unit := wdCharacter := 1, Count := 1)
	oWord :=  "" ; Clear global COM objects when done with them
	}

StrikeThroughText()	{
	global oWord
	global  WordTrue, WordFalse

	oWord := ComObjActive("Word.Application")
	StateOfStrikeThrough := oWord.Selection.Font.StrikeThrough ; := wdToggle := 9999998
	if (StateOfStrikeThrough == WordFalse)
		{
		oWord.Selection.Font.StrikeThrough := wdToggle := 9999998
		}
	else
		{
		oWord.Selection.Font.StrikeThrough := 0
		}
	oWord :=  "" ; Clear global COM objects when done with them
	}

MoveCursorToBeginningOfParagraph()	{
	global oWord
	oWord := ComObjActive("Word.Application")
	oWord.Selection.MoveRight(Unit := wdCharacter := 1, Count:=1)
	oWord.Selection.MoveUp(Unit := wdParagraph := 4, Count:=1)
	oWord :=  "" ; Clear global COM objects when done with them
	}

BB_Insert(Name_BB, AdditionalText)	{
	global

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	;~ MsgBox, % oWord.ActiveDocument.AttachedTemplate.FullName
	if  ( (oWord.ActiveDocument.AttachedTemplate.FullName <> OurTemplateEN)
		and (oWord.ActiveDocument.AttachedTemplate.FullName <> OurTemplatePL) )
		{
		MsgBox, 16, Próba wywołania stylu z szablonu,
		( Join
		 Próbujesz wstawić blok konstrukcyjny przypisany do szablonu, ale szablon nie został jeszcze dołączony do tego pliku.
 Najpierw dołącz szablon, a następnie wywołaj ponownie tę funkcję.
		)
		}
	else
		{
		OurTemplate := oWord.ActiveDocument.AttachedTemplate.FullName
		oWord.Templates(OurTemplate).BuildingBlockEntries(Name_BB).Insert(oWord.Selection.Range, WordTrue)
		}
	oWord :=  "" ; Clear global COM objects when done with them
	}

TemplateStyle(StyleName)	{
	global OurTemplateEN, OurTemplatePL, oWord

	Base(StyleName)
	oWord := ComObjActive("Word.Application")
	;~ SoundBeep, 750, 500 ; to fajnie działa
	if  ( (oWord.ActiveDocument.AttachedTemplate.FullName <> OurTemplateEN)
		and (oWord.ActiveDocument.AttachedTemplate.FullName <> OurTemplatePL) )
		{
		;~ MsgBox, % oWord.ActiveDocument.AttachedTemplate.FullName
		MsgBox, 16, Próba wywołania stylu z szablonu,
		( Join
		 Próbujesz wywołać styl przypisany do szablonu, ale szablon nie został jeszcze dołączony do tego pliku.
 Najpierw dolacz szablon, a następnie wywołaj ponownie tę funkcję.
		)
		oWord := "" ; Clear global COM objects when done with them
		return
		}
	else
		{
		oWord.Selection.Style := StyleName
		oWord := "" ; Clear global COM objects when done with them
		return
		}
	}

Base(AdditionalText := "")	{
	tooltip, [F24]  %A_thishotKey% %AdditionalText%
	SetTimer, SwitchOffTooltip, -5000
	return
	}

TextBoxWithStyleVerticallyAligned(IfFrame, AdditionalText)	{
	global WordTrue, WordFalse
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.ShapeRange.CanvasItems.AddTextBox(Orientation := msoTextOrientationHorizontal := 1, Left := 50, Top := 50, Width := 75, Height := 25).Select
	if (IfFrame)
		{
		oWord.Selection.ChildShapeRange.Line.Visible := WordTrue
		}
	else
		{
		oWord.Selection.ChildShapeRange.Line.Visible := WordFalse
		}
	oWord.Selection.ChildShapeRange.Fill.Visible := WordFalse
	oWord.Selection.ChildShapeRange.TextFrame.VerticalAnchor := msoAnchorMiddle := 3
	oWord.Selection.TypeText("Fikumiku")
	oWord.Selection.StartOf(Unit := wdLine := 5, Extend := wdExtend := 1)
	oWord.Selection.Style := "Pola tekstowe ms"
	oWord := "" ; Clear global COM objects when done with them
	}

HorizontalLine(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.ShapeRange.CanvasItems.AddLine(BeginX := 50, BeginY := 50, EndX := 100, EndY:= 50).Select
	oWord.Selection.ChildShapeRange.Line.Weight := 1
	oWord.Selection.ChildShapeRange.Line.ForeColor.RGB := 0x000000 ; .RGB(0, 0, 0) czyli czarny
	oWord := "" ; Clear global COM objects when done with them
	}

FlipVertically(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.ChildShapeRange.Flip(msoFlipVertical := 1) ; MsoFlipCmd
	oWord := "" ; Clear global COM objects when done with them
	}

FlipHorizontally(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.ChildShapeRange.Flip(msoFlipHorizontal := 0) ; MsoFlipCmd
	oWord := "" ; Clear global COM objects when done with them
	}

RotateLeft90(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.ChildShapeRange.IncrementRotation(-90)
	oWord := "" ; Clear global COM objects when done with them
	}

RotateRight90(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.ChildShapeRange.IncrementRotation(+90)
	oWord := "" ; Clear global COM objects when done with them
	}

Group(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.ChildShapeRange.Group
	oWord := "" ; Clear global COM objects when done with them
	}

Ungroup(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.ChildShapeRange.Ungroup
	oWord := "" ; Clear global COM objects when done with them
	}

PrintToPdf(AdditionalText := "")	{
	global WordTrue, WordFalse
	global oWord, OutputPDFfilePath

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	;~ String := oWord.ActiveDocument.Name
	;~ StringTrimRight, OutputFileName, String, 5
	;~ OutputFileName := OutputPDFfilePath . OutputFileName . ".pdf"
	;~ ExportFormat := wdExportFormatPDF := 17
	;~ OpenAfterExport := WordFalse
	;~ OptimizeFor := wdExportOptimizeForPrint := 0
	;~ Range := wdExportAllDocument := 0
	;~ From := 1
	;~ To := 1
	;~ Item := wdExportDocumentContent := 0
	;~ IncludeDocProps := WordFalse
	;~ KeepIRM := WordTrue
	;~ CreateBookmarks := wdExportCreateHeadingBookmarks := 1
	;~ DocStructureTags := WordFalse
	;~ BitmapMissingFonts := WordTrue
	;~ UseISO19005_1 := WordFalse
	;~ oWord.ActiveDocument.ExportAsFixedFormat(OutputFileName, ExportFormat, OpenAfterExport, OptimizeFor, Range, From, To, Item, IncludeDocProps, KeepIRM, CreateBookmarks, DocStructureTags, BitmapMissingFonts, UseISO19005_1)
	Send, {LAlt}
	Send, {y}
	Send, {3}
	Send, {c}
	;~ MsgBox, 64, Zapisałem .pdf, % "Zapisałem .pdf:`n" OutputFileName
	oWord := ""
	}

ShowClipboard(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Application.ShowClipboard
	oWord := "" ; Clear global COM objects when done with them
	}

WatermarkDRAFT(AdditionalText := "")	{
;~ https://autohotkey.com/board/topic/115939-how-to-insert-a-watermark-into-an-open-word-doc-via-com/
; ~ works as bad as the macro written by AG -> askew crookedly puts the inscription in subsequent sections, but this is a topic for separate inquiries
	global oWord, WordFalse, WordTrue

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
		Loop % oWord.ActiveDocument.Sections.Count
		{
		oWord.ActiveDocument.Sections(A_Index).Range.Select
		oWord.ActiveWindow.ActivePane.View.SeekView := wdSeekCurrentPageHeader := 9
		oWord.Selection.HeaderFooter.Shapes.AddTextEffect(0, "DRAFT", "Calibri", 200, WordFalse, WordFalse, 0, 0).Select
		;~ Function AddTextEffect(PresetTextEffect As MsoPresetTextEffect, Text As String, FontName As String, FontSize As Single, FontBold As MsoTriState, FontItalic As MsoTriState, Left As Single, Top As Single) As Shape
		;~ Const msoTextEffect1 = 0
		oWord.Selection.ShapeRange.TextEffect.NormalizedHeight := WordFalse
		oWord.Selection.ShapeRange.Line.Visible := WordFalse
		oWord.Selection.ShapeRange.Fill.Visible := WordTrue
		oWord.Selection.ShapeRange.Fill.Solid
		oWord.Selection.ShapeRange.Fill.ForeColor := 0xD9D9D9 ; .RGB(217, 217, 217)
		oWord.Selection.ShapeRange.Fill.Transparency := 0,5 ; niestety tu musi być przecinek zamiast kropki, inaczej nie działa. Wątek na forum: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=63129&p=270001#p270001
		oWord.Selection.ShapeRange.Rotation := 315
		oWord.Selection.ShapeRange.LockAspectRatio := WordTrue
		oWord.Selection.ShapeRange.Height.CentimetersToPoints(8.62)
		oWord.Selection.ShapeRange.Width.CentimetersToPoints(18.94)
		oWord.Selection.ShapeRange.WrapFormat.AllowOverlap := WordTrue
		oWord.Selection.ShapeRange.WrapFormat.Side := wdWrapNone := 3
		oWord.Selection.ShapeRange.WrapFormat.Type := 3
		oWord.Selection.ShapeRange.RelativeHorizontalPosition := wdRelativeHorizontalPositionMargin := 0
		oWord.Selection.ShapeRange.RelativeVerticalPosition := wdRelativeVerticalPositionMargin := 0
		oWord.Selection.ShapeRange.Left := wdShapeCenter := -999995
		oWord.Selection.ShapeRange.Top := wdShapeCenter := -999995
		oWord.ActiveWindow.ActivePane.View.SeekView := wdSeekMainDocument := 0
		}
	oWord := "" ; Clear global COM objects when done with them
	}

SetTemplate(PLorEN := "", AdditionalText := "")	{
	global oWord, WordTrue, WordFalse
	global OurTemplate, OurTemplatePL, OurTemplateEN

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	if (PLorEN = "PL")
		{
		if (oWord.ActiveDocument.AttachedTemplate.FullName = OurTemplatePL)
			{
			MsgBox, 64, Już ustawiłeś szablon, % "Już wcześniej został wybrany szablon " oWord.ActiveDocument.AttachedTemplate.FullName
			}
		else
			{
			oWord.ActiveDocument.AttachedTemplate := OurTemplatePL
			oWord.ActiveDocument.UpdateStylesOnOpen := WordTrue
			oWord.ActiveDocument.UpdateStyles
			MsgBox, 64, Informacja, % "Dołączono szablon!`n Dołączono domyslny szablon dokumentu: `n" oWord.ActiveDocument.AttachedTemplate.FullName, 5
			oWord := "" ; Clear global COM objects when done with them
			OurTemplate := OurTemplatePL
			}
		}
	if (PLorEN = "EN")
		{
		if (oWord.ActiveDocument.AttachedTemplate.FullName = OurTemplateEN)
			{
			MsgBox, 64, Już ustawiłeś szablon, % "Już wcześniej został wybrany szablon " oWord.ActiveDocument.AttachedTemplate.FullName
			}
		else
			{
			oWord.ActiveDocument.AttachedTemplate := OurTemplateEN
			oWord.ActiveDocument.UpdateStylesOnOpen := WordTrue
			oWord.ActiveDocument.UpdateStyles
			MsgBox, 64, Informacja, % "Dołączono szablon!`n Dołączono domyslny szablon dokumentu: `n" oWord.ActiveDocument.AttachedTemplate.FullName, 5
			oWord := "" ; Clear global COM objects when done with them
			OurTemplate := OurTemplateEN
			}
		}
	}

ChangeZoom(AdditionalText := "")	{
	global oWord
	static ZoomValue

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	ZoomValue := oWord.ActiveWindow.ActivePane.View.Zoom.Percentage
	if (ZoomValue = 100)
		{
		ZoomValue := 200
		oWord.ActiveWindow.ActivePane.View.Zoom.Percentage := ZoomValue
		}
	else
		{
		ZoomValue := 100
		oWord.ActiveWindow.ActivePane.View.Zoom.Percentage := ZoomValue
		}
	oWord := "" ; Clear global COM objects when done with them
	}

NavigationPaneVisibility(AdditionalText := "")	{
	global oWord, WordTrue, WordFalse
	static StateOfNavigationPane

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	StateOfNavigationPane := oWord.ActiveWindow.DocumentMap
;	MsgBox, % StateOfParagraph_KeepTogether ; debugging
	if (StateOfNavigationPane = WordTrue)
		{
		oWord.ActiveWindow.DocumentMap := WordFalse
		}
	else
		{
		oWord.ActiveWindow.DocumentMap := WordTrue
		}
	oWord := "" ; Clear global COM objects when done with them
	}

ToggleStylePane(AdditionalText := "")	{
	global oWord, WordTrue, WordFalse

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	StateOfStylesPane := oWord.CommandBars.ExecuteMso("Format Object").Visible
	;StateOfStylesPane := oWord.Application.TaskPanes(wdTaskPaneApplyStyles := 0).Visible
	if (StateOfStylesPane = WordTrue)
		{
		oWord.CommandBars("Format Object").Visible := WordFalse
		;oWord.Application.TaskPanes(wdTaskPaneApplyStyles := 0).Visible := WordFalse
		}
	else
		{
		oWord.CommandBars("Format Object").Visible := WordTrue
		;oWord.Application.TaskPanes(wdTaskPaneApplyStyles := 0).Visible := WordTrue
		}
	oWord := "" ; Clear global COM objects when done with them
	}

DeleteCurrentComment(AdditionalText := "") 	{
	global
	local e
	;~ global oWord, cursorPosition

	Base(AdditionalText)
	try
		{
		oWord := ComObjActive("Word.Application")
		oWord.Selection.Comments(1).Delete
		cursorPosition.Select
		oWord := "" ; Clear global COM objects when done with them
		}
		catch e
		{
		MsgBox, 48, Usuwanie komentarza, By usunać komentarz musisz go najpierw wyedytować (Edytuj komentarz).
		}
	}

InsertColumnToTheRight(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.InsertColumnsRight
	oWord := "" ; Clear global COM objects when done with them
	}

InsertColumnToTheLeft(AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.InsertColumns
	oWord := "" ; Clear global COM objects when done with them
	}

AlignTableCellConntentToMiddle(AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.SelectCell
	oWord.Selection.ParagraphFormat.Alignment := wdAlignParagraphCenter := 1
	oWord.Selection.Cells.VerticalAlignment := wdCellAlignVerticalCenter := 1
	oWord := "" ; Clear global COM objects when done with them
	}

AlignTableCellConntentToLeft(AdditionalText := "") 	{ 	; Aligning the cell content to the left and the center vertically
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.SelectCell
	oWord.Selection.ParagraphFormat.Alignment := wdAlignParagraphLeft := 0
	oWord.Selection.Cells.VerticalAlignment := wdCellAlignVerticalCenter := 1
	oWord := "" ; Clear global COM objects when done with them
	}

VersionAndAdjustation(OriginalOrFinal, AdditionalText := "") 	{	; table: Insert row above
	global oWord, WordTrue, WordFalse

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	StateOfOriginalAdjustation := oWord.ActiveWindow.View.ShowRevisionsAndComments
	if (StateOfOriginalAdjustation = WordTrue)
		{
		oWord.ActiveWindow.View.ShowRevisionsAndComments := WordFalse
		}
	else
		{
		oWord.ActiveWindow.View.ShowRevisionsAndComments := WordTrue
		}
	if (OriginalOrFinal = "Original")
		{
		oWord.ActiveWindow.View.RevisionsView := wdRevisionsViewOriginal := 1
		}
	if (OriginalOrFinal = "Final")
		{
		oWord.ActiveWindow.View.RevisionsView := wdRevisionsViewFinal := 0
		}
	oWord := "" ; Clear global COM objects when done with them
	}

InsertTableRowAbove(AdditionalText := "") 	{	; table: Insert row above
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.InsertRowsAbove(1)
	oWord := "" ; Clear global COM objects when done with them
	}

InsertTableRowBelow(AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.InsertRowsBelow(1)
	oWord := "" ; Clear global COM objects when done with them
	}

GoToPreviousComment(AdditionalText := "") 	{ ; Go to previous comment
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Browser.Target := wdBrowseComment := 3
	oWord.Browser.Previous
	oWord := ""
	}

GoToNextComment(AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Browser.Target := wdBrowseComment := 3
	oWord.Browser.Next
	oWord := ""
	}

DeleteTableRow(AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Rows.Delete
	oWord := "" ; Clear global COM objects when done with them
	}

DeleteTableColumn(AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Columns.Delete
	oWord := "" ; Clear global COM objects when done with them
	}

MoveVectorObject(Direction, AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	if (Direction = "Up")
		{
		oWord.Selection.ChildShapeRange.IncrementTop(-25)
		}
	if (Direction = "Down")
		{
		oWord.Selection.ChildShapeRange.IncrementTop(25)
		}
	if (Direction = "Left")
		{
		oWord.Selection.ChildShapeRange.IncrementLeft(-25)
		}
		if (Direction = "Right")
		{
		oWord.Selection.ChildShapeRange.IncrementLeft(25)
		}
	oWord := "" ; Clear global COM objects when done with them
	}

MarkAllTableCells(AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Tables(1).Select
	oWord := "" ; Clear global COM objects when done with them
	}

MergeTableCells(AdditionalText := "") {
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Cells.Merge
	oWord := "" ; Clear global COM objects when done with them
	}

SeparateTableCell2xRow1xColumn(AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	;~ Selection.Cells.Split NumRows:=2, NumColumns:=1, MergeBeforeSplit:=False
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Cells.Split(2, 1)
	oWord := "" ; Clear global COM objects when done with them
	}

SeparateTableCell1xRow2xColumn(AdditionalText := "") 	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Cells.Split(1, 2)
	oWord := "" ; Clear global COM objects when done with them
	}

ToggleFormattingPane(AdditionalText := "") 	{
	global oWord, WordTrue, WordFalse

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	StateOfFormattingPane := oWord.Application.TaskPanes(1).Visible
	if (StateOfFormattingPane = WordTrue)
		{
		oWord.Application.TaskPanes(1).Visible :=  WordFalse
		}
	else
		{
		oWord.Application.TaskPanes(1).Visible := WordTrue
		}
	oWord := "" ; Clear global COM objects when done with them
	}

ToggleRuler(AdditionalText := "") 	{
	global oWord, WordTrue, WordFalse

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	StateOfRuler := oWord.ActiveWindow.ActivePane.DisplayRulers
	if (StateOfRuler = WordTrue)
		{
		oWord.ActiveWindow.ActivePane.DisplayRulers := WordFalse
		}
	else
		{
		oWord.ActiveWindow.ActivePane.DisplayRulers := WordTrue
		}
	oWord := "" ; Clear global COM objects when done with them
	}

ParagraphLinesKeepTogether(AdditionalText := "")	{
	global oWord, WordTrue, WordFalse

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	StateOfParagraph_KeepTogether := oWord.Selection.ParagraphFormat.KeepTogether
;	MsgBox, % StateOfParagraph_KeepTogether ; debugging
	if (StateOfParagraph_KeepTogether = WordTrue)
		{
		oWord.Selection.ParagraphFormat.KeepTogether := WordFalse
		}
	else
		{
		oWord.Selection.ParagraphFormat.KeepTogether := WordTrue
		}
	oWord := "" ; Clear global COM objects when done with them
	}

ParagraphPageBreakBefore(AdditionalText := "")	{
	global oWord, WordTrue, WordFalse

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	StateOfParagraph_PageBreakBefore := oWord.Selection.ParagraphFormat.PageBreakBefore
;	MsgBox, % StateOfParagraph_PageBreakBefore ; debugging
	if (StateOfParagraph_PageBreakBefore = WordTrue)
		{
		oWord.Selection.ParagraphFormat.PageBreakBefore := WordFalse
		}
	else
		{
		oWord.Selection.ParagraphFormat.PageBreakBefore := WordTrue
		}
	oWord := "" ; Clear global COM objects when done with themreturn
	}

ParagraphFormatKeepWithNext(AdditionalText := "")	{
	global oWord, WordTrue, WordFalse

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	StateOfParagraph_KeepWithNext := oWord.Selection.ParagraphFormat.KeepWithNext
;	MsgBox, % StateOfParagraph_KeepWithNext ; debugging
	if (StateOfParagraph_KeepWithNext = WordTrue)
		{
		oWord.Selection.ParagraphFormat.KeepWithNext := WordFalse
		}
	else
		{
		oWord.Selection.ParagraphFormat.KeepWithNext := WordTrue
		}
	oWord := "" ; Clear global COM objects when done with them
	}

TableBorderOff(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")

	oWord.Selection.Borders(wdBorderLeft := -2).LineStyle := wdLineStyleNone := 0
    oWord.Selection.Borders(wdBorderRight := -4).LineStyle := wdLineStyleNone := 0
    oWord.Selection.Borders(wdBorderVertical := -6).LineStyle := wdLineStyleNone := 0

	oWord := "" ; Clear global COM objects when done with them
	}

TableCellColorVoestalpine(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	color := oWord.Selection.Shading.BackgroundPatternColor
	;oWord.Selection.Shading.BackgroundPatternColor := 11829760 kolor voestalpine
	if (color = -603923969)
		oWord.Selection.Shading.BackgroundPatternColor := -603914241
	else
		oWord.Selection.Shading.BackgroundPatternColor := -603923969
	oWord := "" ; Clear global COM objects when done with them
	}

TableRowsAllowBreakAcrossPages(AdditionalText := "") 	{
	global oWord, WordTrue, WordFalse

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	StateOfBreakAcrossPages := oWord.Selection.Tables(1).Rows.AllowBreakAcrossPages
	if (StateOfBreakAcrossPages = WordTrue)
		{
		oWord.Selection.Tables(1).Rows.AllowBreakAcrossPages := WordFalse
		}
	else
		{
		oWord.Selection.Tables(1).Rows.AllowBreakAcrossPages := WordTrue
		}
	oWord := "" ; Clear global COM objects when done with them
	}

RejectChange(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Range.Revisions.RejectAll ; Odrzuć zmianę
	oWord := "" ; Clear global COM objects when done with them
	}

AcceptChange(AdditionalText := "")	{
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Range.Revisions.AcceptAll ; Zaakceptuj zmianę
	oWord := "" ; Clear global COM objects when done with them
	}

EditComment(AdditionalText := "")	{
	;~ global oWord, cursorPosition
	global
	local e

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	try
	{
		cursorPosition := oWord.Selection.Range
		oWord.WordBasic.AnnotationEdit
	}
	catch e
	{
		MsgBox, 48,, Aby edytować komentarz, musisz umieścić kursor w obrębie tekstu, którego komentarz dotyczy.
	}
	oWord := ""
	}

ToggleSelectionAndVisibilityPane(AdditionalText := "")	{
	global oWord, WordTrue, WordFalse
;~ https://docs.microsoft.com/en-us/office/vba/api/word.global.commandbars
;~ http://www.vbaexpress.com/forum/forumdisplay.php?20-Word-Help
;~ https://wordribbon.tips.net/T008342_Using_the_Selection_and_Visibility_Pane.html
;~ https://docs.microsoft.com/pl-pl/office/vba/api/office.commandbar.enabled
;~ z nieznanych przyczyn to nie działa za pierwszym razem - przed pierwszym wyświetleniem "Selection and Visibility" pane. Pierwsze wyświetlenie trzeba zrobić ręcznie.
	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")

	StateOfSelectionPane := oWord.CommandBars.ExecuteMso("SelectionPane").Visible
	if (StateOfSelectionPane = WordTrue)
		{
		oWord.CommandBars("SelectionPane").Visible := WordFalse
		}
	else
		{
		oWord.CommandBars.GetPressedMso("SelectionPane")
		}
	oWord := "" ; Clear global COM objects when done with them
	}

NextChangeOrComment(AdditionalText := ""){
	global oWord
	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	try
		oWord.WordBasic.NextChangeOrComment
	oWord := ""
}

PreviousChangeOrComment(AdditionalText := "") {
	global oWord
	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	try
		oWord.WordBasic.PreviousChangeOrComment
	oWord := ""
}

AlignTableToPageBorder(AdditionalText := ""){
	global oWord, WordTrue, WordFalse
	wdWithInTable := 12 ; WdInformation enumeration: wdWithInTable = 12 Returns True if the selection is in a table.

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")

	if (oWord.Selection.Information(wdWithInTable) = WordTrue)
		{
		oWord.Selection.Tables(1).PreferredWidthType := wdPreferredWidthPoints := 3
		oWord.Selection.Tables(1).PreferredWidth := oWord.Selection.PageSetup.PageWidth - (oWord.Selection.PageSetup.LeftMargin + oWord.Selection.PageSetup.RightMargin + oWord.Selection.PageSetup.Gutter)
		oWord.Selection.Tables(1).Rows.Alignment := wdAlignRowCenter := 1
		}
	oWord := "" ; Clear global COM objects when done with them
}

DeleteInterline(AdditionalText := ""){
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	varInter := oWord.Selection.ParagraphFormat.SpaceBefore
	if (varInter = 48)
		{
		oWord.Selection.ParagraphFormat.SpaceBefore := 0
		}
	else if (varInter = 0)
		{
		oWord.Selection.ParagraphFormat.SpaceBefore := 48
		}
	oWord := "" ; Clear global COM objects when done with them
}

RepeatTableHeader(AdditionalText := "") {
	global oWord

	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	if (oWord.Selection.Information(12) = -1)
		oWord.Selection.Rows.HeadingFormat := 9999998
	oWord := ""
}

FormatObjectPane(AdditionalText := "") {
	global oWord, WordTrue, WordFalse
	Base(AdditionalText)
    oWord := ComObjActive("Word.Application")
	type := oWord.Selection.Type
	state := oWord.CommandBars("Format Object").Visible
	if (state = WordFalse and (type = 7 or type = 8))
		oWord.CommandBars.ExecuteMso("ObjectFormatDialog").Enabled
	else
		oWord.CommandBars("Format Object").Visible := WordFalse
    oWord := ""
}

ChangeLanguage(AdditionalText := "") {
	global oWord
	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	Lang := oWord.Selection.LanguageID
	if (Lang = 2057 or Lang = 1033)
		oWord.Selection.LanguageID := 1045
	if (Lang = 1045)
		oWord.Selection.LanguageID := 2057
	oWord := "" ; Clear global COM objects when done with them
	}

DisplayGridLines(AdditionalText := "") {
	global oWord
	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	oWord.Options.DisplayGridLines := Not oWord.Options.DisplayGridLines
	oWord := ""
}

FullPath(AdditionalText := "") {
	global oWord
    Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
    oWord.ActiveWindow.Caption := oWord.ActiveDocument.FullName
    oWord := ""
}

Header() 	{
	global
	oWord := ComObjActive("Word.Application")
	oWord.ActiveWindow.ActivePane.View.SeekView := 9
	SetTimer, HeaderFooter, 500
	varhf := 1
	oWord := ""
	}

Footer() 	{
	global
	oWord := ComObjActive("Word.Application")
	oWord.ActiveWindow.ActivePane.View.SeekView := 10
	varhf := 0
	oWord := ""
	}

HeaderFooter:
	varhf := 0
	SetTimer, HeaderFooter, Off
return

Switching() {
	global cntWnd, cntWnd2, id
	if cntWnd2 >= %cntWnd%
		cntWnd2 := 0
	varview := id[cntWnd2]
	WinActivate, ahk_id %varview%
	cntWnd2 := cntWnd2 + 1
	return
}

ShowHiddenText(AdditionalText := "") {
	global oWord
	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	HiddenTextState := oWord.ActiveWindow.View.ShowHiddenText
	if (oWord.ActiveWindow.View.ShowAll = -1)
	{
		oWord.ActiveWindow.View.ShowAll := 0
		oWord.ActiveWindow.View.ShowTabs := -1
		oWord.ActiveWindow.View.ShowSpaces := -1
		oWord.ActiveWindow.View.ShowParagraphs := -1
		oWord.ActiveWindow.View.ShowHyphens := -1
		oWord.ActiveWindow.View.ShowObjectAnchors := -1
	}
	if (HiddenTextState = 0)
		oWord.ActiveWindow.View.ShowHiddenText := -1
	else
		oWord.ActiveWindow.View.ShowHiddenText := 0
	oWord := ""
	return
}

Source(AdditionalText := "") {
	global oWord, OurTemplate, OurTemplateEN
	Base(AdditionalText)
	oWord := ComObjActive("Word.Application")
	OurTemplate := oWord.ActiveDocument.AttachedTemplate
	Send, ^+h
	if (OurTemplate = OurTemplateEN)
		Send, Source:
	else
		Send, Źródło:
	oWord := ""
	return
}

StartWithOddOrEvenPage() 	{
	global oWord
	oWord := ComObjActive("Word.Application")
	state := oWord.ActiveDocument.PageSetup.SectionStart
	if (state != 3)
		oWord.ActiveDocument.PageSetup.SectionStart := 3
	else
		oWord.ActiveDocument.PageSetup.SectionStart := 4
	oWord :=  "" ; Clear global COM objects when done with them
	}

PrepareToPrint() {

	global oWord
	oWord := ComObjActive("Word.Application")
	OurTemplate := oWord.ActiveDocument.AttachedTemplate.FullName
	if (OurTemplate != OurTemplateEN && OurTemplate != OurTemplatePL)
	{
		MsgBox, 48, Zanim wydrukujesz...,
		(LTRIM Join
			1. Make a macro that inserts a hard space after the labels of the tables and figures
			2. Refresh the content of the entire document (Ctrl + F9)
			3. Replace all links with links
			4. Refresh the entire document again (Ctrl + F9)
			5. Look for the word "Error".
		)

	}
	else
	{
		oWord.Run("TwardaSpacja")
		oWord.Run("UpdateFieldsPasek")
		MsgBox, 64, Microsoft Word, Odświeżono dokument
		oWord.Run("HiperlaczaPasek")
		MsgBox, 64, Microsoft Word, Zamieniono odsyłacze na łącza
		oWord.Run("UpdateFieldsPasek")
		MsgBox, 64, Microsoft Word, Ponownie odświeżono dokument
		oWord.Selection.Find.ClearFormatting
		oWord.Selection.Find.Wrap := 1
		oWord.Selection.Find.Execute("Błąd")
		if (oWord.Selection.Find.Found = -1)
		{
			Msgbox, 48, Microsoft Word, Znaleziono słowo "Błąd"
		}
		else
		{
			MsgBox, 64, Microsoft Word, Nie znaleziono słowa "Błąd"
		}

	}
	Send, {F12 down}{F12 up}
	oWord := ""
}

MSWordSetFont(FontName,key) {
	global oWord
   IfWinNotActive, ahk_class OpusApp
	{
	Send {%key%}
   return
	}
   oWord := ComObjActive("Word.Application")
   OldFont := oWord.Selection.Font.Name
   oWord.Selection.Font.Name := FontName
   Send {%key%}
   oWord.Selection.Font.Name := OldFont
   oWord := ""
   return
}

References(ins, out, name, ByRef flag, title, type)  {
; ins: 0 - Numbered Item, 1 - Heading, 2 - Bookmark (wdReferenceType); out: -1 - Context Text, -4 - Number Full Contex, 7 - Page Number (wdReferenceKind)


	local vMyListBox
	static oWord, Hlb, Wlb, e, Mon, MonTop, MonRight, MonLeft, MonBottom, Var, N
	try{
		oWord := ComObjActive("Word.Application")
	}
	catch e
	{
		flag := 0
		return
	}
	in%name% := ins
	out%name% := out
	N := 2
	SysGet, Mon, MonitorWorkArea, %N%
	Var := 12
	if (flag_%name% = 0)
	{
		Y%name% := MonTop
		W%name% := (MonRight - MonLeft)/(Var/2)
		X%name% := MonRight -  W%name%
		H%name% := MonBottom - (MonTop + 5*Var/2)
		flag_%name% := 1
	}
	else
	{
		H%name% := H%name%-39
		W%name% := W%name%-16
	}
	X := X%name%
	Y := Y%name%
	H := H%name%
	W := W%name%
	Hlb := H -  Var
	Wlb := W - 2 * Var
	Gui, %name%:New, +Resize
	Gui, Add, ListBox, H%Hlb% W%Wlb% vMyListBox gMyListBox +AltSubmit
	myHeadings := oWord.ActiveDocument.GetCrossReferenceItems(in%name%)
	Loop, % myHeadings.MaxIndex()
	{
		GuiControl,, MyListBox, % myHeadings[A_Index]
	}
	Gui, %name%:Add, Button, Hidden Default gOK,OK
	Gui, %name%:Show,X%X% Y%Y% H%H% W%W%, Wstaw %title% %type%
	return

MyListBox:
	if (A_GuiEvent != "DoubleClick")
		return

OK:
	IfWinActive, Wstaw tekst nagłówka
		name := "a"
	IfWinActive, Wstaw numer nagłówka
		name := "b"
	IfWinActive, Wstaw numer elementu listy numerowanej
		name := "c"
	IfWinActive, Wstaw tekst zakładki
		name := "d"
	try
	{
		Gui, Submit, Nohide
		Index := MyListBox
		if (name = "d")
		{
			bookmark := myHeadings[Index]
			oWord.Selection.InsertCrossReference(in%name%, out%name%, bookmark, 0, 0, 0, " ")
		}
		else
			oWord.Selection.InsertCrossReference(in%name%, out%name%, Index, 1, 0, 0, " ")
	}
	return
}
