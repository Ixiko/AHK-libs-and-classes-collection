/* Class for placing text controls onto a GUI, in a special table where the whole table can wrap around to new columns.
	
	Concept:
		If whole table, unconstrained would look like this:
			1	2	3
			4	5
			6
			7	8
			9	10	11
			12	13	14	15
		We could break it up into multiple columns, like this:
			1	2	3	|	7	8
			4	5		|	9	10	11
			6			|	12	13	14	15
	
	Usage:
		Create a new FlexTable instance
		Start adding cells (.addCell)
		Add new rows (.addRow) and break into new columns (.addColumn) as needed.
		
	Notes:
		Cell width is not enforced at all - if given it will be used, and if not it will be calculated based on the label's contents (not relative to other rows).
		The first column, and the first row per column, are implied and do not need to be explicitly added.
		New columns will start <columnPadding> pixels away from the right-most edge of any cells added in the previous column.
	
	Example:
		Code:
			flex := new FlexTable("Gui105") ; Start table at 0,0 in gui and use default properties.
													  ; First column and row are implied, so no need to add them
			flex.addCell("a")               ; First cell on first row, with calculated width to match contents
			flex.addCell("b", 10, 50)       ; Another cell on same row, starting 10px out from the previous one with a width of 50px
			flex.addCell("c")               ; Another cell on same row, starting at end of previous cell
			
			flex.addRow()                   ; New row (like hitting return in a text editor)
			flex.addHeaderCell("HEADER")    ; Special kind of cell with formatting (bold/underline)
			
			flex.addRow()                   ; New row
			flex.addCell("d")               ; First cell in row, calculated width
			flex.addCell("e")               ; Next cell in row, starting immediately after
			
			flex.addRow()
			flex.addCell("f")
			flex.addCell("g")
			
			flex.addColumn()
			flex.addHeaderCell("NEXT COLUMN HEADER")
			flex.addRow()
			flex.addCell("Right-aligned value", 0, 100, "Right")
			
		Result (ALL CAPS are bolded/underlined):
			a	b			c			NEXT COLUMN HEADER
			HEADER!						Right-aligned value
			de
			fg
*/

class FlexTable {
	
	; ==============================
	; == Public ====================
	; ==============================
	
	;---------
	; DESCRIPTION:    Create a new FlexTable instance.
	; PARAMETERS:
	;  guiId          (I,REQ) - ID of the GUI that we should add text controls to
	;  x              (I,OPT) - X coordinate (in pixels) where the table should start. Defaults to 0 (left edge).
	;  y              (I,OPT) - Y coordinate (in pixels) where the table should start. Defaults to 0 (top edge).
	;  rowHeight      (I,OPT) - The height (in pixels) that a row should be in the table. Defaults to 25.
	;  columnPadding  (I,OPT) - How much space (in pixels) should be between the end of the right-most 
	;                           cell in the previous column, and a new column. Defaults to 30.
	;  minColumnWidth (I,OPT) - Minimum width that a column must be (regardless of where 
	;                           its right-most cell ends). Defaults to 0 (width of contents).
	; RETURNS:        Reference to new FlexTable object
	;---------
	__New(guiId, x := 0, y := 0, rowHeight := 25, columnPadding := 30, minColumnWidth := 0) {
		this.guiId          := guiId
		this.rowHeight      := rowHeight
		this.columnPadding  := columnPadding
		this.minColumnWidth := minColumnWidth
		
		this.xMin := x
		this.yMin := y
		this.setX(x)
		this.setY(y)
		this.xCurrColumn := x
		this.xMax := minColumnWidth ; Make the minimum column width the starting point for the right edge of the column.
	}
	
	;---------
	; DESCRIPTION:    Add a "cell" to the current row.
	; PARAMETERS:
	;  cellText        (I,OPT) - Text to show in the cell
	;  leftPadding     (I,OPT) - How far out from the previous cell (or start of the row/column if it's the 
	;                            first cell) this one should start.
	;  width           (I,OPT) - How wide the cell should be. If not given, will calculate the width of the given text and use that.
	;  extraProperties (I,OPT) - Any extra properties you want to apply to the text control (i.e. "Right" for right-aligned text)
	; RETURNS:        Reference to new FlexTable object
	;---------
	addCell(cellText := "", leftPadding := "", width := "", extraProperties := "") {
		this.makeGuiTheDefault()
		
		if(leftPadding)
			this.addToX(leftPadding)
		
		propString := "x" this.xCurr " y" this.yCurr
		if(width != "")
			propString .= " w" width
		if(extraProperties != "")
			propString .= " " extraProperties
		
		displayText := escapeCharUsingRepeat(cellText, "&") ; Escape any ampersands in the string, as they'll otherwise turn the next character into an underlined hotkey.
		Gui, Add, Text, % propString, % displayText
		
		if(width = "")
			width := getLabelWidthForText(cellText, FlexTable.getNextUniqueControlId())
		this.addToX(width)
	}
	
	;---------
	; DESCRIPTION:    Add a specially-formatted (bold + underline) cell to the current row.
	; PARAMETERS:
	;  titleText       (I,REQ) - Text to show in the cell
	;  leftPadding     (I,OPT) - How far out from the previous cell (or start of the row/column if it's the 
	;                            first cell) this one should start.
	;  width           (I,OPT) - How wide the cell should be. If not given, will calculate the width of the given text and use that.
	;  extraProperties (I,OPT) - Any extra properties you want to apply to the text control (i.e. "Right" for right-aligned text)
	; RETURNS:        Reference to new FlexTable object
	;---------
	addHeaderCell(titleText, leftPadding := "", width := "", extraProperties := "") {
		this.makeGuiTheDefault()
		
		applyTitleFormat()
		this.addCell(titleText, leftPadding, width, extraProperties)
		clearTitleFormat()
	}
	
	;---------
	; DESCRIPTION:    Add a "cell" to the current row.
	; PARAMETERS:
	;  cellText        (I,OPT) - Text to show in the cell
	;  leftPadding     (I,OPT) - How far out from the previous cell (or start of the row/column if it's the 
	;                            first cell) this one should start.
	;  width           (I,OPT) - How wide the cell should be. If not given, will calculate the width of the given text and use that.
	;  extraProperties (I,OPT) - Any extra properties you want to apply to the text control (i.e. "Right" for right-aligned text)
	;---------
	addRow() {
		this.addToY(this.rowHeight)
		this.setX(this.xCurrColumn)
	}
	
	;---------
	; DESCRIPTION:    Add a new column (that wraps the whole table, not within the table) to the table
	;---------
	addColumn() {
		this.forceLastColumnToMinWidth()
		
		this.xCurrColumn := this.xMax + this.columnPadding
		this.setX(this.xCurrColumn)
		this.setY(this.yMin)
		
		; Start the right edge of the column at the minimum column width (if anything pushes it over the edge, that will be the new max)
		this.xMax := this.xCurrColumn + this.minColumnWidth
	}
	
	;---------
	; DESCRIPTION:    Get the total height of the table
	; RETURNS:        The total height of the table, from its starting point to the bottom of the lowest row.
	;---------
	getTotalHeight() {
		return this.yMax - this.yMin + this.rowHeight
	}
	
	;---------
	; DESCRIPTION:		Get the total width of the table
	; RETURNS:			The total width of the table, from its starting point to the right edge of the last cell.
	;---------
	getTotalWidth() {
		this.forceLastColumnToMinWidth()
		return this.xMax - this.xMin
	}
	
	
	; ==============================
	; == Private ===================
	; ==============================
	
	guiId := ""
	static uniqueControlNum := 0 ; Used to get a unique name for each control we have to figure out the width of.
	
	; Top-left corner of table
	xMin := ""
	yMin := ""
	
	; Bottom-right corner of table
	xMax := ""
	yMax := ""
	
	; Current position within gui
	xCurr := ""
	yCurr := ""
	
	; Starting X for current column
	xCurrColumn := ""
	
	; Gui sizing/spacing properties
	rowHeight      := ""
	columnPadding  := ""
	minColumnWidth := ""
	
	;---------
	; DESCRIPTION:    Add the given value to the current X/Y coordinate.
	; PARAMETERS:
	;  value (I,REQ) - Number to add
	;---------
	addToX(value) {
		this.setX(this.xCurr + value)
	}
	addToY(value) {
		this.setY(this.yCurr + value)
	}
	
	;---------
	; DESCRIPTION:    Set the current X/Y coordinate to the given value.
	; PARAMETERS:
	;  value (I,REQ) - New value
	; SIDE EFFECTS:   Updates the maximum value for X/Y accordingly
	;---------
	setX(value) {
		this.xCurr := value
		this.xMax := max(this.xMax, value)
	}
	setY(value) {
		this.yCurr := value
		this.yMax := max(this.yMax, value)
	}
	
	;---------
	; DESCRIPTION:    Get a unique ID to use for determining the width of text within a label.
	; RETURNS:        "FlexTableControl" + a globally incremented value.
	;---------
	getNextUniqueControlId() {
		FlexTable.uniqueControlNum++
		return "FlexTableControl" FlexTable.uniqueControlNum
	}
	
	;---------
	; DESCRIPTION:    Make the gui ID that we were given the default GUI (so 
	;                 all of the relevant Gui, * commands apply to it)
	;---------
	makeGuiTheDefault() {
		Gui, % this.guiId ":Default"
	}
	
	
	; Debug info (used by the Debug class)
	debugName := "FlexTable"
	debugToString(debugBuilder) {
		debugBuilder.addLine("Gui ID",                this.guiId)
		debugBuilder.addLine("Unique control number", this.uniqueControlNum)
		debugBuilder.addLine("Min X",                 this.xMin)
		debugBuilder.addLine("Min Y",                 this.yMin)
		debugBuilder.addLine("Max X",                 this.xMax)
		debugBuilder.addLine("Max Y",                 this.yMax)
		debugBuilder.addLine("Row height",            this.rowHeight)
		debugBuilder.addLine("Column padding",        this.columnPadding)
		debugBuilder.addLine("Min column width",      this.minColumnWidth)
	}
}