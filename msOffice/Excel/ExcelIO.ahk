;20210701修复：不能设置格式问题，"ptr", format修改为"ptr", format.ptr
;20210701修复：不能设置字体问题，"ptr", font修改为"ptr", font.ptr
;20210701修复：末尾增加函数Type()  ,增加Object和富文本类型

;20210630修复：sheet__item[xx,yy] := {value: book.datePack(2010, 3, 11, 10, 25, 55), format: ft}不能赋值的问题 

;由城西[3300372390]将v2版本转为v1,其他内容未做调整 2021-3-24

hModule := DllCall("LoadLibrary", "Str", "libxl.dll", "Ptr")  ; 避免了在循环中每次都需要使用 DllCall() 装载库.

/*
 * @file: ExcelIO.ahk
 * @description: Excel xls,xlsx文件高性能读写库
 * @author thqby
 * @date 12/22/2020
 * @version 1.1
 * @documentation https://www.libxl.com/documentation.html
 * @enum var
 * Color {BLACK = 8, WHITE, RED, BRIGHTGREEN, BLUE, YELLOW, PINK, TURQUOISE, DARKRED, GREEN, DARKBLUE, DARKYELLOW, VIOLET, TEAL, GRAY25, GRAY50, PERIWINKLE_CF, PLUM_CF, IVORY_CF, LIGHTTURQUOISE_CF, DARKPURPLE_CF, CORAL_CF, OCEANBLUE_CF, ICEBLUE_CF, DARKBLUE_CL, PINK_CL, YELLOW_CL, TURQUOISE_CL, VIOLET_CL, DARKRED_CL, TEAL_CL, BLUE_CL, SKYBLUE, LIGHTTURQUOISE, LIGHTGREEN, LIGHTYELLOW, PALEBLUE, ROSE, LAVENDER, TAN, LIGHTBLUE, AQUA, LIME, GOLD, LIGHTORANGE, ORANGE, BLUEGRAY, GRAY40, DARKTEAL, SEAGREEN, DARKGREEN, OLIVEGREEN, BROWN, PLUM, INDIGO, GRAY80, DEFAULT_FOREGROUND = 0x40, DEFAULT_BACKGROUND = 0x41, TOOLTIP = 0x51, NONE = 0x7F, AUTO = 0x7FFF}
 * NumFormat {GENERAL = 0, NUMBER = 1, NUMBER_D2 = 2, NUMBER_SEP = 3, NUMBER_SEP_D2 = 4, CURRENCY_NEGBRA = 5, CURRENCY_NEGBRARED = 6, CURRENCY_D2_NEGBRA = 7, CURRENCY_D2_NEGBRARED = 8, PERCENT = 9, PERCENT_D2 = 10, SCIENTIFIC_D2 = 11, FRACTION_ONEDIG = 12, FRACTION_TWODIG = 13, DATE = 14, CUSTOM_D_MON_YY = 15, CUSTOM_D_MON = 16, CUSTOM_MON_YY = 17, CUSTOM_HMM_AM = 18, CUSTOM_HMMSS_AM = 19, CUSTOM_HMM = 20, CUSTOM_HMMSS = 21, CUSTOM_MDYYYY_HMM = 22, NUMBER_SEP_NEGBRA=37 = 23, NUMBER_SEP_NEGBRARED = 24, NUMBER_D2_SEP_NEGBRA = 25, NUMBER_D2_SEP_NEGBRARED = 26, ACCOUNT = 27, ACCOUNTCUR = 28, ACCOUNT_D2 = 29, ACCOUNT_D2_CUR = 30, CUSTOM_MMSS = 31, CUSTOM_H0MMSS = 32, CUSTOM_MMSS0 = 33, CUSTOM_000P0E_PLUS0 = 34, TEXT = 35}
 * AlignH {GENERAL = 0, LEFT = 1, CENTER = 2, RIGHT = 3, FILL = 4, JUSTIFY = 5, MERGE = 6, DISTRIBUTED = 7}
 * AlignV {TOP = 0, CENTER = 1, BOTTOM = 2, JUSTIFY = 2, DISTRIBUTED = 3}
 * BorderStyle {NONE, THIN, MEDIUM, DASHED, DOTTED, THICK, DOUBLE, HAIR, MEDIUMDASHED, DASHDOT, MEDIUMDASHDOT, DASHDOTDOT, MEDIUMDASHDOTDOT, SLANTDASHDOT}
 * BorderDiagonal {NONE = 0, DOWN = 1, UP = 2, BOTH = 3}
 * FillPattern {NONE, SOLID, GRAY50, GRAY75, GRAY25, HORSTRIPE, VERSTRIPE, REVDIAGSTRIPE, DIAGSTRIPE, DIAGCROSSHATCH, THICKDIAGCROSSHATCH, THINHORSTRIPE, THINVERSTRIPE, THINREVDIAGSTRIPE, THINDIAGSTRIPE, THINHORCROSSHATCH, THINDIAGCROSSHATCH, GRAY12P5, GRAY6P25}
 * Script {NORMAL = 0, SUPER = 1, SUB = 2}
 * Underline {NONE = 0, SINGLE, DOUBLE, SINGLEACC = 0x21, DOUBLEACC = 0x22}
 * Paper {DEFAULT, LETTER, LETTERSMALL, TABLOID, LEDGER, LEGAL, STATEMENT, EXECUTIVE, A3, A4, A4SMALL, A5, B4, B5, FOLIO, QUATRO, 10x14, 10x17, NOTE, ENVELOPE_9, ENVELOPE_10, ENVELOPE_11, ENVELOPE_12, ENVELOPE_14, C_SIZE, D_SIZE, E_SIZE, ENVELOPE_DL, ENVELOPE_C5, ENVELOPE_C3, ENVELOPE_C4, ENVELOPE_C6, ENVELOPE_C65, ENVELOPE_B4, ENVELOPE_B5, ENVELOPE_B6, ENVELOPE, ENVELOPE_MONARCH, US_ENVELOPE, FANFOLD, GERMAN_STD_FANFOLD, GERMAN_LEGAL_FANFOLD, B4_ISO, JAPANESE_POSTCARD, 9x11, 10x11, 15x11, ENVELOPE_INVITE, US_LETTER_EXTRA = 50, US_LEGAL_EXTRA, US_TABLOID_EXTRA, A4_EXTRA, LETTER_TRANSVERSE, A4_TRANSVERSE, LETTER_EXTRA_TRANSVERSE, SUPERA, SUPERB, US_LETTER_PLUS, A4_PLUS, A5_TRANSVERSE, B5_TRANSVERSE, A3_EXTRA, A5_EXTRA, B5_EXTRA, A2, A3_TRANSVERSE, A3_EXTRA_TRANSVERSE, JAPANESE_DOUBLE_POSTCARD, A6, JAPANESE_ENVELOPE_KAKU2, JAPANESE_ENVELOPE_KAKU3, JAPANESE_ENVELOPE_CHOU3, JAPANESE_ENVELOPE_CHOU4, LETTER_ROTATED, A3_ROTATED, A4_ROTATED, A5_ROTATED, B4_ROTATED, B5_ROTATED, JAPANESE_POSTCARD_ROTATED, DOUBLE_JAPANESE_POSTCARD_ROTATED, A6_ROTATED, JAPANESE_ENVELOPE_KAKU2_ROTATED, JAPANESE_ENVELOPE_KAKU3_ROTATED, JAPANESE_ENVELOPE_CHOU3_ROTATED, JAPANESE_ENVELOPE_CHOU4_ROTATED, B6, B6_ROTATED, 12x11, JAPANESE_ENVELOPE_YOU4, JAPANESE_ENVELOPE_YOU4_ROTATED, PRC16K, PRC32K, PRC32K_BIG, PRC_ENVELOPE1, PRC_ENVELOPE2, PRC_ENVELOPE3, PRC_ENVELOPE4, PRC_ENVELOPE5, PRC_ENVELOPE6, PRC_ENVELOPE7, PRC_ENVELOPE8, PRC_ENVELOPE9, PRC_ENVELOPE10, PRC16K_ROTATED, PRC32K_ROTATED, PRC32KBIG_ROTATED, PRC_ENVELOPE1_ROTATED, PRC_ENVELOPE2_ROTATED, PRC_ENVELOPE3_ROTATED, PRC_ENVELOPE4_ROTATED, PRC_ENVELOPE5_ROTATED, PRC_ENVELOPE6_ROTATED, PRC_ENVELOPE7_ROTATED, PRC_ENVELOPE8_ROTATED, PRC_ENVELOPE9_ROTATED, PRC_ENVELOPE10_ROTATED}
 * SheetType {SHEET, CHART, UNKNOWN }
 * CellType {EMPTY, NUMBER, STRING, BOOLEAN, BLANK, ERROR, STRICTDATE}
 * ErrorType {NULL = 0x0, DIV_0 = 0x7, VALUE = 0x0F, REF = 0x17, NAME = 0x1D, NUM = 0x24, NA = 0x2A, NOERROR = 0xFF}
 * PictureType {PNG, JPEG, GIF, WMF, DIB, EMF, PICT, TIFF, ERROR = 0xFF}
 * SheetState {VISIBLE, HIDDEN, VERYHIDDEN}
 * Scope {UNDEFINED = -2, WORKBOOK = -1}
 * Position {MOVE_AND_SIZE, ONLY_MOVE, ABSOLUTE}
 * Operator { EQUAL, GREATER_THAN, GREATER_THAN_OR_EQUAL, LESS_THAN, LESS_THAN_OR_EQUAL, NOT_EQUAL }
 * Filter { VALUE, TOP10, CUSTOM, DYNAMIC, COLOR, ICON, EXT, NOT_SET }
 * IgnoredError { NO_ERROR = 0, EVAL_ERROR = 1, EMPTY_CELLREF = 2, NUMBER_STORED_AS_TEXT = 4, INCONSIST_RANGE = 8, INCONSIST_FMLA = 16, TWODIG_TEXTYEAR = 32, UNLOCK_FMLA = 64, DATA_VALIDATION = 128 }
 * EnhancedProtection { DEFAULT = -1, ALL = 0, OBJECTS = 1, SCENARIOS = 2, FORMAT_CELLS = 4, FORMAT_COLUMNS = 8, FORMAT_ROWS = 16, INSERT_COLUMNS = 32, INSERT_ROWS = 64, INSERT_HYPERLINKS = 128, DELETE_COLUMNS = 256, DELETE_ROWS = 512, SEL_LOCKED_CELLS = 1024, SORT = 2048, AUTOFILTER = 4096, PIVOTTABLES = 8192, SEL_UNLOCKED_CELLS = 16384 }
 * DataValidationType { TYPE_NONE, TYPE_WHOLE, TYPE_DECIMAL, TYPE_LIST, TYPE_DATE, TYPE_TIME, TYPE_TEXTLENGTH, TYPE_CUSTOM }
 * DataValidationOperator { OP_BETWEEN, OP_NOTBETWEEN, OP_EQUAL, OP_NOTEQUAL, OP_LESSTHAN, OP_LESSTHANOREQUAL, OP_GREATERTHAN, OP_GREATERTHANOREQUAL }
 * DataValidationErrorStyle { ERRSTYLE_STOP, ERRSTYLE_WARNING, ERRSTYLE_INFORMATION }
 * CalcModeType { MANUAL, AUTO, AUTONOTABLE }
*/

class ExcelIO {
	Load(path){		;static
		if !FileExist(path)
			throw Exception("excel文件不存在")
		SplitPath,path, , , ext
		handle := 0
		handle := (ext = "xlsx") ? DllCall("libxl\xlCreateXMLBook", "cdecl ptr") : DllCall("libxl\xlCreateBook", "cdecl ptr")
		book :=New ExcelIO.IBook(handle)
		if (book.load(path))
		{	
			book.setKey("GCCG", "windows-282123090cc0e6036db16b60a1o3p0h9")
			return book
		}
		book.release()
		throw Exception("加载失败")
	}
	New(ext := "xlsx") {	;static
		IO :=New ExcelIO.IBook((ext = "xlsx") ? DllCall("libxl\xlCreateXMLBook", "cdecl ptr") : DllCall("libxl\xlCreateBook", "cdecl ptr"))	
		IO.setKey("GCCG", "windows-282123090cc0e6036db16b60a1o3p0h9")
		return IO
	}
	class IBase {
		ptr := 0, parent := 0
		__New(handle, parent := 0){
			this.parent := parent
			this.ptr := handle
		}
	}
	class IAutoFilter extends ExcelIO.IBase {
		getRef(ByRef rowFirst, ByRef rowLast, ByRef colFirst, ByRef colLast){
			return DllCall("libxl\xlAutoFilterGetRef", "ptr", this.ptr, "int*", rowFirst := 0, "int*", rowLast := 0, "int*", colFirst := 0, "int*", colLast := 0, "cdecl int")
		}
		setRef(rowFirst, rowLast, colFirst, colLast){
			return DllCall("libxl\xlAutoFilterSetRef", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "cdecl")
		}
		column(colId){
			return New ExcelIO.IFilterColumn(DllCall("libxl\xlAutoFilterColumn", "ptr", this.ptr, "int", colId, "cdecl ptr"))
		} 
		columnSize(){
			return DllCall("libxl\xlAutoFilterColumnSize", "ptr", this.ptr, "cdecl int")
		}
		columnByIndex(index){
			return new ExcelIO.IFilterColumn(DllCall("libxl\xlAutoFilterColumnByIndex", "ptr", this.ptr, "int", index, "cdecl ptr"))
		} 
		getSortRange(ByRef rowFirst, ByRef rowLast, ByRef colFirst, ByRef colLast){
			return DllCall("libxl\xlAutoFilterGetSortRange", "ptr", this.ptr, "int*", rowFirst := 0, "int*", rowLast := 0, "int*", colFirst := 0, "int*", colLast := 0, "cdecl int")	
		} 
		getSort(ByRef columnIndex, ByRef descending){
			return DllCall("libxl\xlAutoFilterGetSort", "ptr", this.ptr, "int*", columnIndex := 0, "int*", descending := 0, "cdecl int")	
		}
		setSort(columnIndex, descending := false){
			return DllCall("libxl\xlAutoFilterSetSort", "ptr", this.ptr, "int", columnIndex, "int", descending, "cdecl int")	
		}
	}
	class IBook extends ExcelIO.IBase {
		path := ""
		active{
			get{
				return this.getSheet(this.activeSheet())
			}
		}
		__Item[it] {
			get {
				count := this.sheetCount()
				if IsNumber(it) {
					if (it < 0 or it >= count)
						throw Exception("无效的index")
					return this.getSheet(it)
				}
				Loop %count%
					if (this.getSheetName(A_Index - 1) = it)
						return this.getSheet(A_Index - 1)
				throw Exception("表" it "不存在")
			}
		}
		activeSheet(){
			return DllCall("libxl\xlBookActiveSheet", "ptr", this.ptr, "cdecl int")
		}
		addCustomNumFormat(customNumFormat){
			return DllCall("libxl\xlBookAddCustomNumFormat", "ptr", this.ptr, "str", customNumFormat, "cdecl int")	
		}
		addFont(initFont := 0){
			return new ExcelIO.IFont(DllCall("libxl\xlRichStringAddFont", "ptr", this.ptr, "ptr", initFont, "cdecl ptr"))
		}
		addFormat(initFormat := 0){
			return New ExcelIO.IFormat(DllCall("libxl\xlBookAddFormat", "ptr", this.ptr, "ptr", initFormat, "cdecl ptr"))
		}
		addPicture(filename){
			return DllCall("libxl\xlBookAddPicture", "ptr", this.ptr, "str", filename, "cdecl int")
		}
		addPicture2(data, size){
			return DllCall("libxl\xlBookAddPicture2", "ptr", this.ptr, "ptr", data, "uint", size, "cdecl int")
		}
		addPictureAsLink(filename, insert := false){
			return DllCall("libxl\xlBookAddPictureAsLink", "ptr", this.ptr, "str", filename, "int", insert, "cdecl int")
		} 
		addRichString(){
			return New ExcelIO.IRichString(DllCall("libxl\xlBookAddRichString", "ptr", this.ptr, "cdecl ptr"))
		}
		addSheet(name, initSheet := 0){
			return New ExcelIO.ISheet(DllCall("libxl\xlBookAddSheet", "ptr", this.ptr, "str", name, "ptr", initSheet, "cdecl ptr"), this)
		}

		biffVersion(){
			return DllCall("libxl\xlBookBiffVersion", "ptr", this.ptr, "cdecl int")
		}
		calcMode(){
			return DllCall("libxl\xlBookCalcMode", "ptr", this.ptr, "cdecl int")
		}
		colorPack(red, green, blue){
			return DllCall("libxl\xlBookColorPack", "ptr", this.ptr, "int", red, "int", green, "int", blue, "cdecl int")
		}
		colorUnpack(color, ByRef red, ByRef green, ByRef blue){
			return DllCall("libxl\xlBookColorUnpack", "ptr", this.ptr, "int", color, "int*", red := 0, "int*", green := 0, "int*", blue := 0, "cdecl")
		}
		customNumFormat(fmt){
			return DllCall("libxl\xlBookCustomNumFormat", "ptr", this.ptr, "int", fmt, "cdecl str")
		}
		datePack(year, month, day, hour := 0, min := 0, sec := 0, msec := 0){
			return DllCall("libxl\xlBookDatePack", "ptr", this.ptr, "int", year, "int", month, "int", day, "int", hour, "int", min, "int", sec, "int", msec, "cdecl double")
		}
		dateUnpack(value, ByRef year, ByRef month, ByRef day, ByRef hour := 0, ByRef min := 0, ByRef sec := 0, ByRef msec := 0){
			return DllCall("libxl\xlBookDateUnpack", "ptr", this.ptr, "double", value, "int*", year := 0, "int*", month := 0, "int*", day := 0, "int*", hour := 0, "int*", min := 0, "int*", sec := 0, "int*", msec := 0, "cdecl int")
		}
		defaultFont(ByRef fontSize){
			return DllCall("libxl\xlBookDefaultFont", "ptr", this.ptr, "int*", fontSize := 0, "cdecl str")
		}
		delSheet(index){
			return DllCall("libxl\xlBookDelSheet", "ptr", this.ptr, "int", index, "cdecl int")
		}
		errorMessage(){
			return DllCall("libxl\xlBookErrorMessage", "ptr", this.ptr, "cdecl astr")
		}
		font(index){
			return New ExcelIO.IFont(DllCall("libxl\xlBookFont", "ptr", this.ptr, "int", index, "cdecl ptr"))
		}
		fontSize(){
			return DllCall("libxl\xlBookFontSize", "ptr", this.ptr, "cdecl int")
		}
		format(index){
			return New ExcelIO.IFormat(DllCall("libxl\xlBookFormat", "ptr", this.ptr, "int", index, "cdecl ptr"))
		}
		formatSize(){
			return DllCall("libxl\xlBookFormatSize", "ptr", this.ptr, "cdecl int")
		}
		getPicture(index, ByRef data, ByRef size){
			return DllCall("libxl\xlBookGetPicture", "ptr", this.ptr, "int", index, "ptr*", data := 0, "uint*", size := 0, "cdecl int")
		}
		getSheet(index){
			return new ExcelIO.ISheet(DllCall("libxl\xlBookGetSheet", "ptr", this.ptr, "int", index, "cdecl ptr"), this)
		}
		getSheetName(index){
			return DllCall("libxl\xlBookGetSheetName", "ptr", this.ptr, "int", index, "cdecl str")
		}
		insertSheet(index, name, initSheet := 0){
			return New ExcelIO.ISheet(DllCall("libxl\xlBookInsertSheet", "ptr", this.ptr, "int", index, "str", name, "ptr", initSheet, "cdecl ptr"), this.parent)
		}
		isDate1904(){
			return DllCall("libxl\xlBookIsDate1904", "ptr", this.ptr, "cdecl int")
		}
		isTemplate(){
			return DllCall("libxl\xlBookIsTemplate", "ptr", this.ptr, "cdecl int")
		}
		load(filename, tempFile := ""){
			this.path := filename
			return tempFile ? DllCall("libxl\xlBookLoadUsingTempFile", "ptr", this.ptr, "str", filename, "str", tempFile, "cdecl int") : DllCall("libxl\xlBookLoad", "ptr", this.ptr, "str", filename, "cdecl int")
		}
		loadInfo(filename){
			return DllCall("libxl\xlBookLoadInfo", "ptr", this.ptr, "str", filename, "cdecl int")
		}
		loadPartially(filename, sheetIndex, firstRow, lastRow, tempFile := ""){
			return (tempFile ? DllCall("libxl\xlBookLoadPartiallyUsingTempFile", "ptr", this.ptr, "str", filename, "int", sheetIndex, "int", firstRow, "int", lastRow, "str", tempFile, "cdecl int") : DllCall("libxl\xlBookLoadPartially", "ptr", this.ptr, "str", filename, "int", sheetIndex, "int", firstRow, "int", lastRow, "cdecl int"))
		}
		loadRaw(data, size, sheetIndex := -1, firstRow := -1, lastRow := -1){
			return (sheetIndex = -1 ? DllCall("libxl\xlBookLoadRaw", "ptr", this.ptr, "ptr", data, "uint", size, "cdecl int") : DllCall("libxl\xlBookLoadRawPartially", "ptr", this.ptr, "astr", data, "uint", size, "int", sheetIndex, "int", firstRow, "int", lastRow, "cdecl int"))
		}
		loadSheet(filename, sheetIndex, tempFile := ""){
			this.load(filename, tempFile)
			return this.setActiveSheet(sheetIndex)
		}
		loadWithoutEmptyCells(filename){
			return DllCall("libxl\xlBookLoadWithoutEmptyCells", "ptr", this.ptr, "str", filename, "cdecl int")
		}
		moveSheet(srcIndex, dstIndex){
			return DllCall("libxl\xlBookMoveSheet", "ptr", this.ptr, "int", srcIndex, "int", dstIndex, "cdecl int")
		}
		pictureSize(){
			return DllCall("libxl\xlSheetPictureSize", "ptr", this.ptr, "cdecl int")
		}
		refR1C1(){
			return DllCall("libxl\xlBookRefR1C1", "ptr", this.ptr, "cdecl int")
		}
		release(){
			return (this.ptr ? (DllCall("libxl\xlBookRelease", "ptr", this.ptr, "cdecl"), this.ptr := 0) : 0)
		}
		rgbMode(){
			return DllCall("libxl\xlBookRgbMode", "ptr", this.ptr, "cdecl int")
		}
		save(filename := "", useTempFile := false) {
			filename := filename ? filename : this.path
			if !(useTempFile ? DllCall("libxl\xlBookSaveUsingTempFile", "ptr", this.ptr, "str", filename, "int", useTempFile, "cdecl int") : DllCall("libxl\xlBookSave", "ptr", this.ptr, "str", filename, "cdecl int"))
				throw Exception(this.errorMessage())
		}
		saveRaw(ByRef data, ByRef size){
			return DllCall("libxl\xlBookSaveRaw", "ptr", this.ptr, "ptr*", data := 0, "uint*", size := 0, "cdecl int")
		}
		setActiveSheet(index){
			return DllCall("libxl\xlBookSetActiveSheet", "ptr", this.ptr, "int", index, "cdecl")
		}
		setCalcMode(CalcMode){
			return DllCall("libxl\xlBookSetCalcMode", "ptr", this.ptr, "int", calcMode, "cdecl")
		}
		setDate1904(date1904 := true){
			return DllCall("libxl\xlBookSetDate1904", "ptr", this.ptr, "int", date1904, "cdecl")
		}
		setDefaultFont(fontName, fontSize){
			return DllCall("libxl\xlBookSetDefaultFont", "ptr", this.ptr, "str", fontName, "int", fontSize, "cdecl")
		}
		setKey(name, key){
			return DllCall("libxl\xlBookSetKey", "ptr", this.ptr, "str", name, "str", key, "cdecl")
		}
		setLocale(locale){
			return DllCall("libxl\xlBookSetLocale", "ptr", this.ptr, "astr", locale, "cdecl int")
		}
		setRefR1C1(refR1C1 := true){
			return DllCall("libxl\xlBookSetRefR1C1", "ptr", this.ptr, "int", refR1C1, "cdecl")
		}
		setRgbMode(rgbMode := true){
			return DllCall("libxl\xlBookSetRgbMode", "ptr", this.ptr, "int", rgbMode, "cdecl")
		}
		setTemplate(tmpl := true){
			return DllCall("libxl\xlBookSetTemplate", "ptr", this.ptr, "int", tmpl, "cdecl")
		}
		sheetCount(){
			return DllCall("libxl\xlBookSheetCount", "ptr", this.ptr, "cdecl int")
		}
		sheetType(index){
			return DllCall("libxl\xlBookSheetType", "ptr", this.ptr, "int", index, "cdecl int")
		}
		version(){
			return DllCall("libxl\xlBookVersion", "ptr", this.ptr, "cdecl int")
		}
		__Delete(){
			this.release()
		}
	}
	class IFilterColumn extends ExcelIO.IBase {
		index(){
			return DllCall("libxl\xlFilterColumnIndex", "ptr", this.ptr, "cdecl int")
		}
		filterType(){
			return DllCall("libxl\xlFilterColumnFilterType", "ptr", this.ptr, "cdecl int")
		}
		filterSize(){
			return DllCall("libxl\xlFilterColumnFilterSize", "ptr", this.ptr, "cdecl int")
		}
		filter(index){
			return DllCall("libxl\xlFilterColumnFilter", "ptr", this.ptr, "int", index, "cdecl str")
		}
		addFilter(value){
			return DllCall("libxl\xlFilterColumnAddFilter", "ptr", this.ptr, "str", value, "cdecl")
		}
		getTop10(ByRef value, ByRef top, ByRef percent){
			return DllCall("libxl\xlFilterColumnGetTop10", "ptr", this.ptr, "double*", value := 0, "int*", top := 0, "int*", percent := 0, "cdecl int")
		}
		setTop10(value, top := true, percent := false){
			return DllCall("libxl\xlFilterColumnSetTop10", "ptr", this.ptr, "double", value, "int", top, "int", percent, "cdecl")
		}
		getCustomFilter(ByRef op1, ByRef v1, ByRef op2, ByRef v2, ByRef andOp){
			return DllCall("libxl\xlFilterColumnGetCustomFilter", "ptr", this.ptr, "int*", op1 := 0, "str*", v1 := "", "int*", op2 := 0, "str*", v2 := "", "int*", andOp := 0, "cdecl int")
		}
		setCustomFilter(op1, v1, op2 := 0, v2 := "", andOp := false){
			return DllCall("libxl\xlFilterColumnSetCustomFilterEx", "ptr", this.ptr, "int", op1, "str", v1, "int", op2, "str", v2, "int", andOp, "cdecl")
		}
		clear(){
			return DllCall("libxl\xlFilterColumnClear", "ptr", this.ptr, "cdecl")
		}
	}
	class IFont extends ExcelIO.IBase {
		size(){
			return DllCall("libxl\xlFontSize", "ptr", this.ptr, "cdecl int")
		}
		setSize(size){
			return DllCall("libxl\xlFontSetSize", "ptr", this.ptr, "int", size, "cdecl")
		}
		italic(){
			return DllCall("libxl\xlFontItalic", "ptr", this.ptr, "cdecl int")
		}
		setItalic(italic := true){
			return DllCall("libxl\xlFontSetItalic", "ptr", this.ptr, "int", italic, "cdecl")
		}
		strikeOut(){
			return DllCall("libxl\xlFontStrikeOut", "ptr", this.ptr, "cdecl int")
		}
		setStrikeOut(strikeOut := true){
			return DllCall("libxl\xlFontSetStrikeOut", "ptr", this.ptr, "int", strikeOut, "cdecl")
		}
		color(){
			return DllCall("libxl\xlFontColor", "ptr", this.ptr, "cdecl int")
		}
		setColor(Color){
			return DllCall("libxl\xlFontSetColor", "ptr", this.ptr, "int", color, "cdecl")
		}
		bold(){
			return DllCall("libxl\xlFontBold", "ptr", this.ptr, "cdecl int")
		}
		setBold(bold){
			return DllCall("libxl\xlFontSetBold", "ptr", this.ptr, "int", bold, "cdecl")
		}
		script(){
			return DllCall("libxl\xlFontScript", "ptr", this.ptr, "cdecl int")
		}
		setScript(Script){
			return DllCall("libxl\xlFontSetScript", "ptr", this.ptr, "int", script, "cdecl")
		}
		underline(){
			return DllCall("libxl\xlFontUnderline", "ptr", this.ptr, "cdecl int")
		}
		setUnderline(Underline){
			return DllCall("libxl\xlFontSetUnderline", "ptr", this.ptr, "int", underline, "cdecl")
		}
		name(){
			return DllCall("libxl\xlFontName", "ptr", this.ptr, "cdecl str")
		}
		setName(name){
			return DllCall("libxl\xlFontSetName", "ptr", this.ptr, "str", name, "cdecl")
		}
	}
	class IFormat extends ExcelIO.IBase {
		font(){
			return	New ExcelIO.IFont(DllCall("libxl\xlFormatFont", "ptr", this.ptr, "cdecl ptr"))
		}
		setFont(font){
			return DllCall("libxl\xlFormatSetFont", "ptr", this.ptr, "ptr", font.ptr, "cdecl int")
		}
		numFormat(){
			return DllCall("libxl\xlFormatNumFormat", "ptr", this.ptr, "cdecl int")
		}
		setNumFormat(numFormat){
			return DllCall("libxl\xlFormatSetNumFormat", "ptr", this.ptr, "int", numFormat, "cdecl")
		}
		alignH(){
			return DllCall("libxl\xlFormatAlignH", "ptr", this.ptr, "cdecl int")
		}
		setAlignH(Align){
			return DllCall("libxl\xlFormatSetAlignH", "ptr", this.ptr, "int", align, "cdecl")
		}
		alignV(){
			return DllCall("libxl\xlFormatAlignV", "ptr", this.ptr, "cdecl int")
		}
		setAlignV(Align){
			return DllCall("libxl\xlFormatSetAlignV", "ptr", this.ptr, "int", align, "cdecl")
		}
		wrap(){
			return DllCall("libxl\xlFormatWrap", "ptr", this.ptr, "cdecl int")
		}
		setWrap(wrap := true){
			return DllCall("libxl\xlFormatSetWrap", "ptr", this.ptr, "int", wrap, "cdecl")
		}
		rotation(){
			return DllCall("libxl\xlFormatRotation", "ptr", this.ptr, "cdecl int")
		}
		setRotation(rotation){
			return DllCall("libxl\xlFormatSetRotation", "ptr", this.ptr, "int", rotation, "cdecl int")
		}
		indent(){
			return DllCall("libxl\xlFormatIndent", "ptr", this.ptr, "cdecl int")
		}
		setIndent(indent){
			return DllCall("libxl\xlFormatSetIndent", "ptr", this.ptr, "int", indent, "cdecl")
		}
		shrinkToFit(){
			return DllCall("libxl\xlFormatShrinkToFit", "ptr", this.ptr, "cdecl int")
		}
		setShrinkToFit(shrinkToFit := true){
			return DllCall("libxl\xlFormatSetShrinkToFit", "ptr", this.ptr, "int", shrinkToFit, "cdecl")
		}
		setBorder(Style := 1){
			return DllCall("libxl\xlFormatSetBorder", "ptr", this.ptr, "int", style, "cdecl")
		}
		setBorderColor(Color){
			return DllCall("libxl\xlFormatSetBorderColor", "ptr", this.ptr, "int", color, "cdecl")
		}
		borderLeft(){
			return DllCall("libxl\xlFormatBorderLeft", "ptr", this.ptr, "cdecl int")
		}
		setBorderLeft(Style := 1){
			return DllCall("libxl\xlFormatSetBorderLeft", "ptr", this.ptr, "int", style, "cdecl")
		}
		borderRight(){
			return DllCall("libxl\xlFormatBorderRight", "ptr", this.ptr, "cdecl int")
		}
		setBorderRight(style := 1){
			return DllCall("libxl\xlFormatSetBorderRight", "ptr", this.ptr, "int", style, "cdecl")
		}
		borderTop(){
			return DllCall("libxl\xlFormatBorderTop", "ptr", this.ptr, "cdecl int")
		}
		setBorderTop(style := 1){
			return DllCall("libxl\xlFormatSetBorderTop", "ptr", this.ptr, "int", style, "cdecl")
		}
		borderBottom(){
			return DllCall("libxl\xlFormatBorderBottom", "ptr", this.ptr, "cdecl int")
		}
		setBorderBottom(style := 1){
			return DllCall("libxl\xlFormatSetBorderBottom", "ptr", this.ptr, "int", style, "cdecl")
		}
		borderLeftColor(){
			return DllCall("libxl\xlFormatBorderLeftColor", "ptr", this.ptr, "cdecl int")
		}
		setBorderLeftColor(color){
			return DllCall("libxl\xlFormatSetBorderLeftColor", "ptr", this.ptr, "int", color, "cdecl")
		}
		borderRightColor(){
			return DllCall("libxl\xlFormatBorderRightColor", "ptr", this.ptr, "cdecl int")
		}
		setBorderRightColor(color){
			return DllCall("libxl\xlFormatSetBorderRightColor", "ptr", this.ptr, "int", color, "cdecl")
		}
		borderTopColor(){
			return DllCall("libxl\xlFormatBorderTopColor", "ptr", this.ptr, "cdecl int")
		}
		setBorderTopColor(color){
			return DllCall("libxl\xlFormatSetBorderTopColor", "ptr", this.ptr, "int", color, "cdecl")
		}
		borderBottomColor(){
			return DllCall("libxl\xlFormatBorderBottomColor", "ptr", this.ptr, "cdecl int")
		}
		setBorderBottomColor(color){
			return DllCall("libxl\xlFormatSetBorderBottomColor", "ptr", this.ptr, "int", color, "cdecl")
		}
		borderDiagonal(){
			return DllCall("libxl\xlFormatBorderDiagonal", "ptr", this.ptr, "cdecl int")
		}
		setBorderDiagonal(Border){
			return DllCall("libxl\xlFormatSetBorderDiagonal", "ptr", this.ptr, "int", border, "cdecl")
		}
		borderDiagonalStyle(){
			return DllCall("libxl\xlFormatBorderDiagonalStyle", "ptr", this.ptr, "cdecl int")
		}
		setBorderDiagonalStyle(style){
			return DllCall("libxl\xlFormatSetBorderDiagonalStyle", "ptr", this.ptr, "int", style, "cdecl")
		}
		borderDiagonalColor(){
			return DllCall("libxl\xlFormatBorderDiagonalColor", "ptr", this.ptr, "cdecl int")
		}
		setBorderDiagonalColor(color){
			return DllCall("libxl\xlFormatSetBorderDiagonalColor", "ptr", this.ptr, "int", color, "cdecl")
		}
		fillPattern(){
			return DllCall("libxl\xlFormatFillPattern", "ptr", this.ptr, "cdecl int")
		}
		setFillPattern(Pattern){
			return DllCall("libxl\xlFormatSetFillPattern", "ptr", this.ptr, "int", pattern, "cdecl")
		}
		patternForegroundColor(){
			return DllCall("libxl\xlFormatPatternForegroundColor", "ptr", this.ptr, "cdecl int")
		}
		setPatternForegroundColor(color){
			return DllCall("libxl\xlFormatSetPatternForegroundColor", "ptr", this.ptr, "int", color, "cdecl")
		}
		patternBackgroundColor(){
			return DllCall("libxl\xlFormatPatternBackgroundColor", "ptr", this.ptr, "cdecl int")
		}
		setPatternBackgroundColor(color){
			return DllCall("libxl\xlFormatSetPatternBackgroundColor", "ptr", this.ptr, "int", color, "cdecl")
		}
		locked(){
			return DllCall("libxl\xlFormatLocked", "ptr", this.ptr, "cdecl int")
		}
		setLocked(locked := true){
			return DllCall("libxl\xlFormatSetLocked", "ptr", this.ptr, "int", locked, "cdecl")
		}
		hidden(){
			return DllCall("libxl\xlFormatHidden", "ptr", this.ptr, "cdecl int")
		}
		setHidden(hidden := true){
			return DllCall("libxl\xlFormatSetHidden", "ptr", this.ptr, "int", hidden, "cdecl")
		}
	}
	class IRichString extends ExcelIO.IBase {
		addFont(initFont := 0){
			return new ExcelIO.IFont(DllCall("libxl\xlRichStringAddFont", "ptr", this.ptr, "ptr", initFont, "cdecl ptr"))
		}
		addText(text, font := 0){
			return DllCall("libxl\xlRichStringAddText", "ptr", this.ptr, "str", text, "ptr", font.ptr, "cdecl")
		} 
		getText(index, ByRef font := 0){
			return DllCall("libxl\xlRichStringGetText", "ptr", this.ptr, "int", index, "ptr*", font := 0, "cdecl str")
		}
		textSize(){
			return DllCall("libxl\xlRichStringTextSize", "ptr", this.ptr, "cdecl int")
		}
	}
	class ISheet extends ExcelIO.IBase {
		cellType(row, col){
			return DllCall("libxl\xlSheetCellType", "ptr", this.ptr, "int", row, "int", col, "cdecl int")
		}
		isFormula(row, col){
			return DllCall("libxl\xlSheetIsFormula", "ptr", this.ptr, "int", row, "int", col, "cdecl int")
		}
		cellFormat(row, col){
			return New ExcelIO.IFormat(DllCall("libxl\xlSheetCellFormat", "ptr", this.ptr, "int", row, "int", col, "cdecl ptr"))
		}
		setCellFormat(row, col, format){
			return DllCall("libxl\xlSheetSetCellFormat", "ptr", this.ptr, "int", row, "int", col, "ptr", format.ptr, "cdecl")
		}
		readStr(row, col, ByRef format := 0) {
			ret := DllCall("libxl\xlSheetReadStr", "ptr", this.ptr, "int", row, "int", col, "ptr*", format := 0, "cdecl str")
			if (!format)
				throw Exception(this.parent.errorMessage())
			format := New ExcelIO.IFormat(format)
			return ret
		}
		writeStr(row, col, value, format := 0){
			return DllCall("libxl\xlSheetWriteStr", "ptr", this.ptr, "int", row, "int", col, "str", value, "ptr", format.ptr, "cdecl int")
		}
		readRichStr(row, col, ByRef format := 0) {
			ret :=New ExcelIO.IRichString(DllCall("libxl\xlSheetReadRichStr", "ptr", this.ptr, "int", row, "int", col, "ptr*", format := 0, "cdecl ptr"))
			if (!format)
				throw Exception(this.parent.errorMessage())
			format :=New ExcelIO.IFormat(format)
			return ret
		}
		writeRichStr(row, col, richString, format := 0){
			return DllCall("libxl\xlSheetWriteRichStr", "ptr", this.ptr, "int", row, "int", col, "ptr", richString.ptr, "ptr", format.ptr, "cdecl int")
		}
		readNum(row, col, ByRef format := 0) {
			ret := DllCall("libxl\xlSheetReadNum", "ptr", this.ptr, "int", row, "int", col, "ptr*", format := 0, "cdecl double")
			if (!format)
				throw Exception(this.parent.errorMessage())
			format :=New ExcelIO.IFormat(format)
			return ret
		}
		writeNum(row, col, value, format := 0){
			return DllCall("libxl\xlSheetWriteNum", "ptr", this.ptr, "int", row, "int", col, "double", value, "ptr", format.ptr, "cdecl int")
		}
		readBool(row, col, ByRef format := 0) {
			ret := DllCall("libxl\xlSheetReadBool", "ptr", this.ptr, "int", row, "int", col, "ptr*", format := 0, "cdecl int")
			if (!format)
				throw Exception(this.parent.errorMessage())
			format :=New ExcelIO.IFormat(format)
			return ret
		}
		writeBool(row, col, value, format := 0){
			return DllCall("libxl\xlSheetWriteBool", "ptr", this.ptr, "int", row, "int", col, "int", value, "ptr", format.ptr, "cdecl int")
		}
		readBlank(row, col, ByRef format := 0) {
			ret := DllCall("libxl\xlSheetReadBlank", "ptr", this.ptr, "int", row, "int", col, "ptr*", format := 0, "cdecl int")
			if (!format)
				throw Exception(this.parent.errorMessage())
			format :=New ExcelIO.IFormat(format)
			return ret
		}
		writeBlank(row, col, format){
			return DllCall("libxl\xlSheetWriteBlank", "ptr", this.ptr, "int", row, "int", col, "ptr", format.ptr, "cdecl int")
		}
		readFormula(row, col, ByRef format := "unset") {
			ret := DllCall("libxl\xlSheetReadFormula", "ptr", this.ptr, "int", row, "int", col, "ptr*", format := 0, "cdecl str")
			if (!format)
				throw Exception(this.parent.errorMessage())
			format :=New ExcelIO.IFormat(format)
			return ret
		}
		writeFormula(row, col, expr, format := 0){
			return DllCall("libxl\xlSheetWriteFormula", "ptr", this.ptr, "int", row, "int", col, "str", expr, "ptr", format.ptr, "cdecl int")
		}
		writeFormulaNum(row, col, expr, value, format := 0){
			return DllCall("libxl\xlSheetWriteFormulaNum", "ptr", this.ptr, "int", row, "int", col, "str", expr, "double", value, "ptr", format.ptr, "cdecl int")
		}
		writeFormulaStr(row, col, expr, value, format := 0){
			return DllCall("libxl\xlSheetWriteFormulaStr", "ptr", this.ptr, "int", row, "int", col, "str", expr, "str", value, "ptr", format.ptr, "cdecl int")
		}
		writeFormulaBool(row, col, expr, value, format := 0){
			return DllCall("libxl\xlSheetWriteFormulaBool", "ptr", this.ptr, "int", row, "int", col, "str", expr, "int", value, "ptr", format.ptr, "cdecl int")
		}
		readComment(row, col){
			return DllCall("libxl\xlSheetReadComment", "ptr", this.ptr, "int", row, "int", col, "cdecl str")
		}
		writeComment(row, col, value, author := 0, width := 129, height := 75){
			return DllCall("libxl\xlSheetWriteComment", "ptr", this.ptr, "int", row, "int", col, "str", value, "str", author, "int", width, "int", height, "cdecl")
		}
		removeComment(row, col){
			return DllCall("libxl\xlSheetRemoveComment", "ptr", this.ptr, "int", row, "int", col, "cdecl")
		}
		isDate(row, col){
			return DllCall("libxl\xlSheetIsDate", "ptr", this.ptr, "int", row, "int", col, "cdecl int")
		}
		isRichStr(row, col){
			return DllCall("libxl\xlSheetIsRichStr", "ptr", this.ptr, "int", row, "int", col, "cdecl int")
		}
		readError(row, col){
			return DllCall("libxl\xlSheetReadError", "ptr", this.ptr, "int", row, "int", col, "cdecl int")
		}
		writeError(row, col, ErrorType, format := 0){
			return DllCall("libxl\xlSheetWriteError", "ptr", this.ptr, "int", row, "int", col, "int", ErrorType, "ptr", format.ptr, "cdecl")
		}
		colWidth(col){
			return DllCall("libxl\xlSheetColWidth", "ptr", this.ptr, "int", col, "cdecl double")
		}
		rowHeight(row){
			return DllCall("libxl\xlSheetRowHeight", "ptr", this.ptr, "int", row, "cdecl double")
		}
		colWidthPx(col){
			return DllCall("libxl\xlSheetColWidthPx", "ptr", this.ptr, "int", col, "cdecl int")
		}
		rowHeightPx(row){
			return DllCall("libxl\xlSheetRowHeightPx", "ptr", this.ptr, "int", row, "cdecl int")
		}
		setCol(colFirst, colLast, width, format := 0, hidden := false){
			return DllCall("libxl\xlSheetSetCol", "ptr", this.ptr, "int", colFirst, "int", colLast, "double", width, "ptr", format.ptr, "int", hidden, "cdecl int")
		}
		setRow(row, height, format := 0, hidden := false){
			return DllCall("libxl\xlSheetSetRow", "ptr", this.ptr, "int", row, "double", height, "ptr", format.ptr, "int", hidden, "cdecl int")
		}
		rowHidden(row){
			return DllCall("libxl\xlSheetRowHidden", "ptr", this.ptr, "int", row, "cdecl int")
		}
		setRowHidden(row, hidden){
			return DllCall("libxl\xlSheetSetRowHidden", "ptr", this.ptr, "int", row, "int", hidden, "cdecl int")
		}
		colHidden(col){
			return DllCall("libxl\xlSheetColHidden", "ptr", this.ptr, "int", col, "cdecl int")
		}
		setColHidden(col, hidden){
			return DllCall("libxl\xlSheetSetColHidden", "ptr", this.ptr, "int", col, "int", hidden, "cdecl int")
		}
		getMerge(row, col, ByRef rowFirst := 0, ByRef rowLast := 0, ByRef colFirst := 0, ByRef colLast := 0){
			return DllCall("libxl\xlSheetGetMerge", "ptr", this.ptr, "int", row, "int", col, "int*", rowFirst := 0, "int*", rowLast := 0, "int*", colFirst := 0, "int*", colLast := 0, "cdecl int")
		}
		setMerge(rowFirst, rowLast, colFirst, colLast){
			return DllCall("libxl\xlSheetSetMerge", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "cdecl int")
		}
		delMerge(row, col){
			return DllCall("libxl\xlSheetDelMerge", "ptr", this.ptr, "int", row, "int", col, "cdecl int")
		}
		mergeSize(){
			return DllCall("libxl\xlSheetMergeSize", "ptr", this.ptr, "cdecl int")
		}
		merge(index, ByRef rowFirst, ByRef rowLast, ByRef colFirst, ByRef colLast){
			return DllCall("libxl\xlSheetMerge", "ptr", this.ptr, "int", index, "int*", rowFirst := 0, "int*", rowLast := 0, "int*", colFirst := 0, "int*", colLast := 0, "cdecl int")
		}
		delMergeByIndex(index){
			return DllCall("libxl\xlSheetDelMergeByIndex", "ptr", this.ptr, "int", index, "cdecl int")
		}
		pictureSize(){
			return DllCall("libxl\xlSheetPictureSize", "ptr", this.ptr, "cdecl int")
		}
		getPicture(index, ByRef rowTop := 0, ByRef colLeft := 0, ByRef rowBottom := 0, ByRef colRight := 0, ByRef width := 0, ByRef height := 0, ByRef offset_x := 0, ByRef offset_y := 0){
			return DllCall("libxl\xlSheetGetPicture", "ptr", this.ptr, "int", index, "int*", rowTop := 0, "int*", colLeft := 0, "int*", rowBottom := 0, "int*", colRight := 0, "int*", width := 0, "int*", height := 0, "int*", offset_x := 0, "int*", offset_y := 0, "cdecl int")
		}
		removePictureByIndex(index){
			return DllCall("libxl\xlSheetRemovePictureByIndex", "ptr", this.ptr, "int", index, "cdecl int")
		}
		setPicture(row, col, pictureId, scale := 1.0, offset_x := 0, offset_y := 0, pos := 0){
			return DllCall("libxl\xlSheetSetPicture", "ptr", this.ptr, "int", row, "int", col, "int", pictureId, "double", scale, "int", offset_x, "int", offset_y, "int", pos, "cdecl")
		}
		setPicture2(row, col, pictureId, width := -1, height := -1, offset_x := 0, offset_y := 0, pos := 0){
			return DllCall("libxl\xlSheetSetPicture2", "ptr", this.ptr, "int", row, "int", col, "int", pictureId, "int", width, "int", height, "int", offset_x, "int", offset_y, "int", pos, "cdecl")
		}
		removePicture(row, col){
			return DllCall("libxl\xlSheetRemovePicture", "ptr", this.ptr, "int", row, "int", col, "cdecl int")
		}
		getHorPageBreak(index){
			return DllCall("libxl\xlSheetGetHorPageBreak", "ptr", this.ptr, "int", index, "cdecl int")
		}
		getHorPageBreakSize(){
			return DllCall("libxl\xlSheetGetHorPageBreakSize", "ptr", this.ptr, "cdecl int")
		}
		getVerPageBreak(index){
			return DllCall("libxl\xlSheetGetVerPageBreak", "ptr", this.ptr, "int", index, "cdecl int")
		}
		getVerPageBreakSize(){
			return DllCall("libxl\xlSheetGetVerPageBreakSize", "ptr", this.ptr, "cdecl int")
		}
		setHorPageBreak(row, pageBreak := true){
			return DllCall("libxl\xlSheetSetHorPageBreak", "ptr", this.ptr, "int", row, "int", pageBreak, "cdecl int")
		}
		setVerPageBreak(col, pageBreak := true){
			return DllCall("libxl\xlSheetSetVerPageBreak", "ptr", this.ptr, "int", col, "int", pageBreak, "cdecl int")
		}
		split(row, col){
			return DllCall("libxl\xlSheetSplit", "ptr", this.ptr, "int", row, "int", col, "cdecl")
		}
		splitInfo(ByRef row, ByRef col){
			return DllCall("libxl\xlSheetSplitInfo", "ptr", this.ptr, "int*", row := 0, "int*", col := 0, "cdecl int")
		}
		groupRows(rowFirst, rowLast, collapsed := true){
			return DllCall("libxl\xlSheetGroupRows", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "int", collapsed, "cdecl int")
		}
		groupCols(colFirst, colLast, collapsed := true){
			return DllCall("libxl\xlSheetGroupCols", "ptr", this.ptr, "int", colFirst, "int", colLast, "int", collapsed, "cdecl int")
		}
		groupSummaryBelow(){
			return DllCall("libxl\xlSheetGroupSummaryBelow", "ptr", this.ptr, "cdecl int")
		}
		setGroupSummaryBelow(below){
			return DllCall("libxl\xlSheetSetGroupSummaryBelow", "ptr", this.ptr, "int", below, "cdecl")
		}
		groupSummaryRight(){
			return DllCall("libxl\xlSheetGroupSummaryRight", "ptr", this.ptr, "cdecl int")
		}
		setGroupSummaryRight(right){
			return DllCall("libxl\xlSheetSetGroupSummaryRight", "ptr", this.ptr, "int", right, "cdecl")
		}
		clear(rowFirst := 0, rowLast := 1048575, colFirst := 0, colLast := 16383){
			return DllCall("libxl\xlSheetClear", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "cdecl int")
		}
		insertCol(colFirst, colLast, updateNamedRanges := true){
			return DllCall("libxl\xlSheetInsertCol", "ptr", this.ptr, "int", colFirst, "int", colLast, "cdecl int")
		}
		insertRow(rowFirst, rowLast, updateNamedRanges := true){
			return DllCall("libxl\xlSheetInsertRow", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "cdecl int")
		}
		removeCol(colFirst, colLast, updateNamedRanges := true){
			return DllCall("libxl\xlSheetRemoveCol", "ptr", this.ptr, "int", colFirst, "int", colLast, "cdecl int")
		}
		removeRow(rowFirst, rowLast, updateNamedRanges := true){
			return DllCall("libxl\xlSheetRemoveRow", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "cdecl int")
		}
		insertColAndKeepRanges(colFirst, colLast){
			return DllCall("libxl\xlSheetInsertColAndKeepRanges", "ptr", this.ptr, "int", colFirst, "int", colLast, "cdecl int")
		}
		insertRowAndKeepRanges(rowFirst, rowLast){
			return DllCall("libxl\xlSheetInsertRowAndKeepRanges", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "cdecl int")
		}
		removeColAndKeepRanges(colFirst, colLast){
			return DllCall("libxl\xlSheetRemoveColAndKeepRanges", "ptr", this.ptr, "int", colFirst, "int", colLast, "cdecl int")
		}
		removeRowAndKeepRanges(rowFirst, rowLast){
			return DllCall("libxl\xlSheetRemoveRowAndKeepRanges", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "cdecl int")
		}
		copyCell(rowSrc, colSrc, rowDst, colDst){
			return DllCall("libxl\xlSheetCopyCell", "ptr", this.ptr, "int", rowSrc, "int", colSrc, "int", rowDst, "int", colDst, "cdecl int")
		}
		firstRow(){
			return DllCall("libxl\xlSheetFirstRow", "ptr", this.ptr, "cdecl int")
		}
		lastRow(){
			return DllCall("libxl\xlSheetLastRow", "ptr", this.ptr, "cdecl int")
		}
		firstCol(){
			return DllCall("libxl\xlSheetFirstCol", "ptr", this.ptr, "cdecl int")
		}
		lastCol(){
			return DllCall("libxl\xlSheetLastCol", "ptr", this.ptr, "cdecl int")
		}
		firstFilledRow(){
			return DllCall("libxl\xlSheetFirstFilledRow", "ptr", this.ptr, "cdecl int")
		}
		lastFilledRow(){
			return DllCall("libxl\xlSheetLastFilledRow", "ptr", this.ptr, "cdecl int")
		}
		firstFilledCol(){
			return DllCall("libxl\xlSheetFirstFilledCol", "ptr", this.ptr, "cdecl int")
		}
		lastFilledCol(){
			return DllCall("libxl\xlSheetLastFilledCol", "ptr", this.ptr, "cdecl int")
		}
		displayGridlines(){
			return DllCall("libxl\xlSheetDisplayGridlines", "ptr", this.ptr, "cdecl int")
		}
		setDisplayGridlines(show := true){
			return DllCall("libxl\xlSheetSetDisplayGridlines", "ptr", this.ptr, "int", show, "cdecl")
		}
		printGridlines(){
			return DllCall("libxl\xlSheetPrintGridlines", "ptr", this.ptr, "cdecl int")
		}
		setPrintGridlines(print := true){
			return DllCall("libxl\xlSheetSetPrintGridlines", "ptr", this.ptr, "int", print, "cdecl")
		}
		zoom(){
			return DllCall("libxl\xlSheetZoom", "ptr", this.ptr, "cdecl int")
		}
		setZoom(zoom){
			return DllCall("libxl\xlSheetSetZoom", "ptr", this.ptr, "int", zoom, "cdecl")
		}
		printZoom(){
			return DllCall("libxl\xlSheetPrintZoom", "ptr", this.ptr, "cdecl int")
		}
		setPrintZoom(zoom){
			return DllCall("libxl\xlSheetSetPrintZoom", "ptr", this.ptr, "int", zoom, "cdecl")
		}
		getPrintFit(ByRef wPages, ByRef hPages){
			return DllCall("libxl\xlSheetGetPrintFit", "ptr", this.ptr, "int*", wPages := 0, "int*", hPages := 0, "cdecl int")
		}
		setPrintFit(wPages := 1, hPages := 1){
			return DllCall("libxl\xlSheetSetPrintFit", "ptr", this.ptr, "int", wPages, "int", hPages, "cdecl")
		}
		landscape(){
			return DllCall("libxl\xlSheetLandscape", "ptr", this.ptr, "cdecl int")
		}
		setLandscape(landscape := true){
			return DllCall("libxl\xlSheetSetLandscape", "ptr", this.ptr, "int", landscape, "cdecl")
		}
		paper(){
			return DllCall("libxl\xlSheetPaper", "ptr", this.ptr, "cdecl int")
		}
		setPaper(Paper := 0){
			return DllCall("libxl\xlSheetSetPaper", "ptr", this.ptr, "int", paper, "cdecl")
		}
		header(){
			return DllCall("libxl\xlSheetHeader", "ptr", this.ptr, "cdecl str")
		}
		setHeader(header, margin := 0.5){
			return DllCall("libxl\xlSheetSetHeader", "ptr", this.ptr, "str", header, "double", margin, "cdecl int")
		}
		headerMargin(){
			return DllCall("libxl\xlSheetHeaderMargin", "ptr", this.ptr, "cdecl double")
		}
		footer(){
			return DllCall("libxl\xlSheetFooter", "ptr", this.ptr, "cdecl str")
		}
		setFooter(footer, margin := 0.5){
			return DllCall("libxl\xlSheetSetFooter", "ptr", this.ptr, "str", footer, "double", margin, "cdecl int")
		}
		footerMargin(){
			return DllCall("libxl\xlSheetFooterMargin", "ptr", this.ptr, "cdecl double")
		}
		hCenter(){
			return DllCall("libxl\xlSheetHCenter", "ptr", this.ptr, "cdecl int")
		}
		setHCenter(hCenter := true){
			return DllCall("libxl\xlSheetSetHCenter", "ptr", this.ptr, "int", hCenter, "cdecl")
		}
		vCenter(){
			return DllCall("libxl\xlSheetVCenter", "ptr", this.ptr, "cdecl int")
		}
		setVCenter(vCenter := true){
			return DllCall("libxl\xlSheetSetVCenter", "ptr", this.ptr, "int", vCenter, "cdecl")
		}
		marginLeft(){
			return DllCall("libxl\xlSheetMarginLeft", "ptr", this.ptr, "cdecl double")
		}
		setMarginLeft(margin){
			return DllCall("libxl\xlSheetSetMarginLeft", "ptr", this.ptr, "double", margin, "cdecl")
		}
		marginRight(){
			return DllCall("libxl\xlSheetMarginRight", "ptr", this.ptr, "cdecl double")
		}
		setMarginRight(margin){
			return DllCall("libxl\xlSheetSetMarginRight", "ptr", this.ptr, "double", margin, "cdecl")
		}
		marginTop(){
			return DllCall("libxl\xlSheetMarginTop", "ptr", this.ptr, "cdecl double")
		}
		setMarginTop(margin){
			return DllCall("libxl\xlSheetSetMarginTop", "ptr", this.ptr, "double", margin, "cdecl")
		}
		marginBottom(){
			return DllCall("libxl\xlSheetMarginBottom", "ptr", this.ptr, "cdecl double")
		}
		setMarginBottom(margin){
			return DllCall("libxl\xlSheetSetMarginBottom", "ptr", this.ptr, "double", margin, "cdecl")
		}
		printRowCol(){
			return DllCall("libxl\xlSheetPrintRowCol", "ptr", this.ptr, "cdecl int")
		}
		setPrintRowCol(print := true){
			return DllCall("libxl\xlSheetSetPrintRowCol", "ptr", this.ptr, "int", print, "cdecl")
		}
		printRepeatRows(ByRef rowFirst, ByRef rowLast){
			return DllCall("libxl\xlSheetPrintRepeatRows", "ptr", this.ptr, "int*", rowFirst := 0, "int*", rowLast := 0, "cdecl int")
		}
		setPrintRepeatRows(rowFirst, rowLast){
			return DllCall("libxl\xlSheetSetPrintRepeatRows", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "cdecl")
		}
		printRepeatCols(ByRef colFirst, ByRef colLast){
			return DllCall("libxl\xlSheetPrintRepeatCols", "ptr", this.ptr, "int*", colFirst := 0, "int*", colLast := 0, "cdecl int")
		}
		setPrintRepeatCols(colFirst, colLast){
			return DllCall("libxl\xlSheetSetPrintRepeatCols", "ptr", this.ptr, "int", colFirst, "int", colLast, "cdecl")
		}
		printArea(ByRef rowFirst, ByRef rowLast, ByRef colFirst, ByRef colLast){
			return DllCall("libxl\xlSheetPrintArea", "ptr", this.ptr, "int*", rowFirst := 0, "int*", rowLast := 0, "int*", colFirst := 0, "int*", colLast := 0, "cdecl int")
		}
		setPrintArea(rowFirst, rowLast, colFirst, colLast){
			return DllCall("libxl\xlSheetSetPrintArea", "ptr", this.ptr, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "cdecl")
		}
		clearPrintRepeats(){
			return DllCall("libxl\xlSheetClearPrintRepeats", "ptr", this.ptr, "cdecl")
		}
		clearPrintArea(){
			return DllCall("libxl\xlSheetClearPrintArea", "ptr", this.ptr, "cdecl")
		}
		getNamedRange(name, ByRef rowFirst, ByRef rowLast, ByRef colFirst, ByRef colLast, scopeId := -2, ByRef hidden := 0){
			return DllCall("libxl\xlSheetGetNamedRange", "ptr", this.ptr, "str", name, "int*", rowFirst := 0, "int*", rowLast := 0, "int*", colFirst := 0, "int*", colLast := 0, "int", scopeId, "int*", hidden := 0, "cdecl int")
		}
		setNamedRange(name, rowFirst, rowLast, colFirst, colLast, scopeId := -2, hidden := false){
			return DllCall("libxl\xlSheetSetNamedRange", "ptr", this.ptr, "str", name, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "int", scopeId, "cdecl int")
		}
		delNamedRange(name, scopeId := -2){
			return DllCall("libxl\xlSheetDelNamedRange", "ptr", this.ptr, "str", name, "int", scopeId, "cdecl int")
		}
		namedRangeSize(){
			return DllCall("libxl\xlSheetNamedRangeSize", "ptr", this.ptr, "cdecl int")
		}
		namedRange(index, ByRef rowFirst, ByRef rowLast, ByRef colFirst, ByRef colLast, ByRef scopeId := 0, ByRef hidden := 0){
			return DllCall("libxl\xlSheetNamedRange", "ptr", this.ptr, "int", index, "int*", rowFirst := 0, "int*", rowLast := 0, "int*", colFirst := 0, "int*", colLast := 0, "int*", scopeId := 0, "int*", hidden := 0, "cdecl str")
		}
		tableSize(){
			return DllCall("libxl\xlSheetTableSize", "ptr", this.ptr, "cdecl int")
		}
		table(index, ByRef rowFirst, ByRef rowLast, ByRef colFirst, ByRef colLast, ByRef headerRowCount, ByRef totalsRowCount){
			return DllCall("libxl\xlSheetTable", "ptr", this.ptr, "int", index, "int*", rowFirst := 0, "int*", rowLast := 0, "int*", colFirst := 0, "int*", colLast := 0, "int*", headerRowCount := 0, "int*", totalsRowCount := 0, "cdecl str")
		}
		hyperlinkSize(){
			return DllCall("libxl\xlSheetHyperlinkSize", "ptr", this.ptr, "cdecl int")
		}
		hyperlink(index, ByRef rowFirst, ByRef rowLast, ByRef colFirst, ByRef colLast){
			return DllCall("libxl\xlSheetHyperlink", "ptr", this.ptr, "int", index, "int*", rowFirst := 0, "int*", rowLast := 0, "int*", colFirst := 0, "int*", colLast := 0, "cdecl str")
		}
		delHyperlink(index){
			return DllCall("libxl\xlSheetDelHyperlink", "ptr", this.ptr, "int", index, "cdecl int")
		}
		addHyperlink(hyperlink, rowFirst, rowLast, colFirst, colLast){
			return DllCall("libxl\xlSheetAddHyperlink", "ptr", this.ptr, "str", hyperlink, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "cdecl")
		}
		autoFilter(){
			return New ExcelIO.IAutoFilter(DllCall("libxl\xlSheetAutoFilter", "ptr", this.ptr, "cdecl ptr"))
		}
		applyFilter(){
			return DllCall("libxl\xlSheetApplyFilter", "ptr", this.ptr, "cdecl")
		}
		removeFilter(){
			return DllCall("libxl\xlSheetRemoveFilter", "ptr", this.ptr, "cdecl")
		}
		name(){
			return DllCall("libxl\xlSheetName", "ptr", this.ptr, "cdecl str")
		}
		setName(name){
			return DllCall("libxl\xlSheetSetName", "ptr", this.ptr, "str", name, "cdecl")
		}
		protect(){
			return DllCall("libxl\xlSheetProtect", "ptr", this.ptr, "cdecl int")
		}
		setProtect(protect := true, password := 0, enhancedProtection := -1){			;这个地址函数需要解决
		;	return DllCall("libxl\xlSheetSetProtectEx", "ptr", this.ptr, "int", protect, "ptr", Type(password) = "String" ? StrPtr(password) : password, "int", enhancedProtection, "cdecl")
		}
		hidden(){
			return DllCall("libxl\xlSheetHidden", "ptr", this.ptr, "cdecl int")
		}
		setHidden(SheetState := 1){
			return DllCall("libxl\xlSheetSetHidden", "ptr", this.ptr, "int", SheetState, "cdecl int")
		}
		getTopLeftView(ByRef row, ByRef col){
			return DllCall("libxl\xlSheetGetTopLeftView", "ptr", this.ptr, "int*", row := 0, "int*", col := 0, "cdecl")
		}
		setTopLeftView(row, col){
			return DllCall("libxl\xlSheetSetTopLeftView", "ptr", this.ptr, "int", row, "int", col, "cdecl")
		}
		rightToLeft(){
			return DllCall("libxl\xlSheetRightToLeft", "ptr", this.ptr, "cdecl int")
		}
		setRightToLeft(rightToLeft := true){
			return DllCall("libxl\xlSheetSetRightToLeft", "ptr", this.ptr, "int", rightToLeft, "cdecl")
		}
		setAutoFitArea(rowFirst := 0, colFirst := 0, rowLast := -1, colLast := -1){
			return DllCall("libxl\xlSheetSetAutoFitArea", "ptr", this.ptr, "int", rowFirst, "int", colFirst, "int", rowLast, "int", colLast, "cdecl")
		}
		addrToRowCol(addr, ByRef row, ByRef col, ByRef rowRelative := 0, ByRef colRelative := 0){
			return DllCall("libxl\xlSheetAddrToRowCol", "ptr", this.ptr, "str", StrUpper(addr), "int*", row := 0, "int*", col := 0, "int*", rowRelative := 0, "int*", colRelative := 0, "cdecl")
		}
		rowColToAddr(row, col, rowRelative := true, colRelative := true){
			return DllCall("libxl\xlSheetRowColToAddr", "ptr", this.ptr, "int", row, "int", col, "int", rowRelative, "int", colRelative, "cdecl str")
		}
		setTabColor(Color){
			return DllCall("libxl\xlSheetSetTabColor", "ptr", this.ptr, "int", Color, "cdecl")
		}
		setTabRGBColor(red, green, blue){
			return DllCall("libxl\xlSheetSetTabRgbColor", "ptr", this.ptr, "int", red, "int", green, "int", blue, "cdecl")
		}
		addIgnoredError(rowFirst, colFirst, rowLast, colLast, IgnoredError){
			return DllCall("libxl\xlSheetAddIgnoredError", "ptr", this.ptr, "int", rowFirst, "int", colFirst, "int", rowLast, "int", colLast, "int", IgnoredError, "cdecl int")
		}
		addDataValidation(type, op, rowFirst, rowLast, colFirst, colLast, value1, value2){
			return DllCall("libxl\xlSheetAddDataValidation", "ptr", this.ptr, "int", type, "int", op, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "str", value1, "str", value2, "cdecl")
		}
		addDataValidationEx(type, op, rowFirst, rowLast, colFirst, colLast, value1, value2, allowBlank := true, hideDropDown := false, showInputMessage := true, showErrorMessage := true, promptTitle := 0, prompt := 0, errorTitle := 0, error := 0, errorStyle := 0){
			return DllCall("libxl\xlSheetAddDataValidationEx", "ptr", this.ptr, "int", type, "int", op, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "str", value1, "str", value2, "int", allowBlank, "int", hideDropDown, "int", showInputMessage, "int", showErrorMessage, "str", promptTitle, "str", prompt, "str", errorTitle, "str", error, "int", errorStyle, "cdecl")
		}
		addDataValidationDouble(type, op, rowFirst, rowLast, colFirst, colLast, value1, value2){
			return DllCall("libxl\xlSheetAddDataValidationDouble", "ptr", this.ptr, "int", type, "int", op, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "double", value1, "double", value2, "cdecl")
		}
		addDataValidationDoubleEx(type, op, rowFirst, rowLast, colFirst, colLast, value1, value2, allowBlank := true, hideDropDown := false, showInputMessage := true, showErrorMessage := true, promptTitle := 0, prompt := 0, errorTitle := 0, error := 0, errorStyle := 0){
			return DllCall("libxl\xlSheetAddDataValidationDoubleEx", "ptr", this.ptr, "int", type, "int", op, "int", rowFirst, "int", rowLast, "int", colFirst, "int", colLast, "double", value1, "double", value2, "int", allowBlank, "int", hideDropDown, "int", showInputMessage, "int", showErrorMessage, "str", promptTitle, "str", prompt, "str", errorTitle, "str", error, "int", errorStyle, "cdecl")
		}
		removeDataValidations(){
			return DllCall("libxl\xlSheetRemoveDataValidations", "ptr", this.ptr, "cdecl")
		}
		__Delete() {
			return (this.parent := "")
		}
		__Item[row, col := ""] {
			get {
				IsNumber(row) ? "" : this.addrToRowCol(row, row, col)
				return New ExcelIO.ISheet.ICell(row, col, this)
			} 
			set {
					ret := format := 0
					bool := formula := ""
				if (!IsNumber(row))
					this.addrToRowCol(row, row, col)
				rechecktype:
				switch Type(value) {
				case "Object":
					val := value, value := ""
					;for k in val.OwnProps()
					for k,sdfs in val
						switch StrLower(k) {
						case "format":
							format := val.format
						case "bool":
							value := val.bool, bool := true
						case "exp", "expr", "formula":
							formula := val[k]
						case "int", "integer":
							value := Integer(val[k])
						case "num", "float", "number", "double":
							value := Float(val[k])
						default:
							value := val[k]
						}
					if (formula != "") {
						if (bool)
							ret := this.writeFormulaBool(row, col, formula, !!value, format)
						else if (value = "")
							ret := this.writeFormula(row, col, formula, format)
						else if ("String" = Type(value))
							ret := this.writeFormulaStr(row, col, formula, value, format)
						else ret := this.writeFormulaNum(row, col, formula, value, format)
					} else if (bool)
						ret := this.writeBool(row, col, !!value, format)
					else goto rechecktype
				case "String":
					ret := this.writeStr(row, col, value, format)
				case "Integer", "Float":
					ret := this.writeNum(row, col, value, format)
				case "ExcelIO.IRichString":
					ret := this.writeRichStr(row, col, value, format)
				default:
					throw Exception("参数类型错误")
				}
				if (!ret && (msg := this.parent.errorMessage()) != "ok")
					throw Exception(msg)
			}
		}
		class ICell {
			__New(row, col, parent) {
				if (parent.cellType(row, col) = 0)
					throw Exception("单元格不存在")
				this.row := row, this.col := col, this.parent := parent
			}
			content {
				get {
					format := 0, ret := {value: "", type: "", format: 0}, row := this.row, col := this.col
					switch this.parent.cellType(row, col) {
					case 0:	; EMPTY
						return ""
					case 1:	; NUMBER, DATE
						if (this.parent.isDate(row, col)) {
							year := month := day := hour := min := sec := msec := 0, this.parent.dateUnpack(ret.value, year, month, day, hour, min, sec, msec)
							ret := {year: year, month: month, day: day, hour: hour, min: min, sec: sec, msec: msec}
							ret.value := this.parent.readNum(row, col, format), ret.type := "DATE"
						}
						else if (this.parent.isFormula(row, col)) {
							ret.formula := this.parent.readFormula(row, col, format), ret.type := "FORMULA"
							try ret.value := this.parent.readNum(row, col)
						}
						else
						{
							ret.type := "NUMBER", ret.value := this.parent.readNum(row, col, format)
						}	
						ret.format := format
					case 2:	; STRING, FORMULA, RICHSTRING
						if (this.parent.isRichStr(row, col))
							ret.richstr := this.parent.readRichStr(row, col, format), ret.type := "RICHSTRING", ret.value := this.parent.readStr(row, col)
						else if (this.parent.isFormula(row, col)) {
							ret.formula := this.parent.readFormula(row, col, format), ret.type := "FORMULA"
							try ret.value := this.parent.readStr(row, col)
						}
						else 
						{
							ret.type := "STRING", ret.value := this.parent.readStr(row, col, format)
						}
						ret.format := format
					case 3:	; BOOLEAN
						ret.value := this.parent.readBool(row, col, format), ret.format := format, ret.type := "BOOLEAN"
					case 4:	; BLANK
						this.parent.readBlank(row, col, format), ret.format := format, ret.type := "BLANK"
					default: ;ERROR
						ret.type := "ERROR"
						switch ret.errcode := this.parent.readError(row, col) {
						case 0:
							ret.value := "#NULL!"
						case 0x7:
							ret.value := "#DIV/0!"
						case 0xF:
							ret.value := "#VALUE!"
						case 0x17:
							ret.value := "#REF!"
						case 0x1D:
							ret.value := "#NAME?"
						case 0x24:
							ret.value := "#NUM!"
						case 0x2A:
							ret.value := "#N/A"
						default:
							ret.value := "no error"
						}
					}
					return ret
				}
			}
			value {
				get {
					return this.content.value
				}
				set {
					return (this.parent[this.row, this.col] := {value: value, format: this.format})
				}
			}
			format {
				get {
					return this.parent.cellFormat(this.row, this.col)
				}
				set {
					return this.parent.setCellFormat(this.row, this.col, value)
				}
			}
			comment {
				get {
					return this.parent.readComment(this.row, this.col)
				}	
				set {
					if (value = "")
						return this.parent.removeComment(this.row, this.col)
					author := height := width := ""
					for k in ["author", "width", "height", "value"]
						%k% := value.HasOwnProp(k) ? value[k] : ""
					return this.parent.writeComment(this.row, this.col, value, author, height || 129, width || 75)
				}
			}
			width {
				get { 
					return this.parent.colWidth(this.col)
				}
				set {
					return this.parent.setCol(this.col, this.col, value, this.format, this.parent.colHidden(this.col))
				}
			}
			height {
				get {
					return this.parent.rowHeight(this.row)
				}	
				set {
					return this.parent.setRow(this.row, this.row, value, this.format, this.parent.rowHidden(this.row))
				}
			}
			hidden(){
			return	this.parent.rowHidden(this.row) || this.parent.colHidden(this.col)	
			}
			copy(rowDst, colDst){
				return this.parent.copyCell(this.row, this.col, rowDst, colDst)
			}
		}
	}
}

;增加函数
;判断是否为数字
IsNumber(num:=""){
	num :=Trim(num)		;移除前后空格
	if RegExMatch(num,"^[+-]?\d\d*\.?\d*$")
		return 1
	else
		return 0
}

;判断变量类型
Type(str:=""){	
	if IsObject(str)
	{
		if str.parent = 0
			return "ExcelIO.IRichString"
    	return "Object"
	}
	str :=Trim(str)		;移除前后空格
	if RegExMatch(str,"^[+-]?\d\d*\.\d+$")
		return "Float"
	else if RegExMatch(str,"^[+-]?\d+$")
		return "Integer"
	else
		return "String"
}

;转大写字符
StrUpper(str:=""){
	return Format("{:U}",str)
}
;转小写字符
StrLower(str:=""){
	return Format("{:L}",str)
}

;转为整数
Integer(Value:=""){
	return Value < 0 ? Ceil(Value) : Floor(Value)
}

;将整数或字符转为浮点
Float(str:=""){
	return str * 1.0
}
