; ahk: console
#NoEnv
#Warn All, StdOut

#Include <ansi>
#Include <arrays>
#Include <console>
#Include <math>
#Include <object>
#Include <string>
#Include <testcase>

#Include %A_ScriptDir%\..\datatable.ahk

class DataTableTest extends TestCase {

	@Test_class() {
		this.assertTrue(IsObject(new DataTable()))
		this.assertEquals(IsFunc(DataTable.defineColumn), 3)
		this.assertEquals(IsFunc(DataTable.addData), 2)
		this.assertEquals(IsFunc(DataTable.getTableAsString), 2)
		this.assertEquals(IsFunc(DataTable.setSortAlgorithm), 3)

		this.assertTrue(new DataTable().hasKey("tableColumns"))
		this.assertTrue(IsObject(new DataTable()["tableColumns"]))
		this.assertTrue(new DataTable().hasKey("aMaxColValue"))
		this.assertTrue(IsObject(new DataTable()["aMaxColValue"]))
		this.assertTrue(new DataTable().hasKey("tableRows"))
		this.assertTrue(IsObject(new DataTable()["tableRows"]))
		this.assertTrue(new DataTable().hasKey("iSortAlgorithm"))
		this.assertEquals(new DataTable().iSortAlgorithm
				, DataTable.SORT_QUICKSORT)
	}

	@Test_constants() {
		this.assertEquals(DataTable.COL_ALIGN_LEFT, 0)
		this.assertEquals(DataTable.COL_ALIGN_RIGHT, 1)
		this.assertEquals(DataTable.COL_ALIGN_CENTER, 2)
		this.assertEquals(DataTable.COL_RESIZE_TRUNCATE, 4)
		this.assertEquals(DataTable.COL_RESIZE_TRUNCATE_RIGHT, 4)
		this.assertEquals(DataTable.COL_RESIZE_TRUNCATE_LEFT, 8)
		this.assertEquals(DataTable.COL_RESIZE_TRUNCATE_MIDDLE, 16)
		this.assertEquals(DataTable.COL_RESIZE_USE_LARGEST_DATA, 32)
		this.assertEquals(DataTable.COL_RESIZE_SHOW_ELLIPSIS, 64)
		this.assertEquals(DataTable.SORT_SELECTIONSORT, 1)
		this.assertEquals(DataTable.SORT_QUICKSORT, 2)
	}

	@Test_columnClass() {
		this.assertTrue(IsObject(new DataTable.Column()))
		this.assertEquals(IsFunc(DataTable.Column.__new), 2)

		this.assertTrue(new DataTable.Column().hasKey("width"))
		this.assertEquals(new DataTable.Column()["width"], 40)
		this.assertTrue(new DataTable.Column().hasKey("flags"))
		this.assertEquals(new DataTable.Column()["flags"], 0)
	}

	@Test_wrappedColumnClass() {
		this.assertTrue(IsObject(new DataTable.Column.Wrapped()))
		this.assertEquals(IsFunc(DataTable.Column.Wrapped.__new), 2)

		this.assertTrue(new DataTable.Column.Wrapped().hasKey("width"))
		this.assertEquals(new DataTable.Column.Wrapped()["width"]
				, 40)
	}

	@Test_newColumn() {
		col := new DataTable.Column()
		this.assertEquals(col["width"], 40)
		col := new DataTable.Column(50)
		this.assertEquals(col["width"], 50)
		col := new DataTable.Column(50
				, DataTable.COL_RESIZE_SHORTEN | DataTable.COL_ALIGN_CENTER)
		this.assertEquals(col["width"], 50)
		this.assertEquals(col["flags"]
				, DataTable.COL_RESIZE_SHORTEN | DataTable.COL_ALIGN_CENTER)
		col := new DataTable.Column(, DataTable.COL_ALIGN_CENTER)
		this.assertEquals(col["width"], 40)
		this.assertEquals(col["flags"], DataTable.COL_ALIGN_CENTER)
	}

	@Test_newWrapapedColumn() {
		wcol := new DataTable.Column.Wrapped()
		this.assertEquals(wcol["width"], 40)
		wcol := new DataTable.Column.Wrapped(50)
		this.assertEquals(wcol["width"], 50)
	}

	@Test_defineColumn() {
		dt := new DataTable()
		col := new DataTable.Column()
		dt.defineColumn(col)
		this.assertEquals(dt.tableColumns.maxIndex(), 1)
		this.assertEquals(dt.tableColumns[1]["width"], 40)
		this.assertEquals(dt.aMaxColValue[1], 0)
		dt.defineColumn(new DataTable.Column())
		this.assertEquals(dt.tableColumns.maxIndex(), 2)
		this.assertEquals(dt.tableColumns[2]["width"], 40)
		this.assertEquals(dt.aMaxColValue[2], 0)
		dt.defineColumn(new DataTable.Column.Wrapped())
		this.assertEquals(dt.tableColumns.maxIndex(), 3)
		this.assertEquals(dt.tableColumns[3]["width"], 40)
		this.assertEquals(dt.aMaxColValue[3], 0)
		this.assertException(dt, "DefineColumn", "", "", {})
		this.assertException(dt, "DefineColumn", "", "", "A string")
	}

	@Test_1Column() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column())
		this.assertEquals(dt.addData(["Montag"], ["Dienstag"], ["Mittwoch"]
				, ["Donnerstag"], ["Freitag"], ["Samstag"], ["Sonntag"]), 7)
		this.assertEquals(dt.tableRows[1][1], "Montag")
		this.assertEquals(dt.tableRows[2][1], "Dienstag")
		this.assertEquals(dt.tableRows[3][1], "Mittwoch")
		this.assertEquals(dt.tableRows[4][1], "Donnerstag")
		this.assertEquals(dt.tableRows[5][1], "Freitag")
		this.assertEquals(dt.tableRows[6][1], "Samstag")
		this.assertEquals(dt.tableRows[7][1], "Sonntag")
	}

	@Test_2Columns() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column())
		dt.defineColumn(new DataTable.Column())
		this.assertEquals(dt.addData(["Montag", "Morgen"]
				, ["Dienstag", "Mittag"], ["Mittwoch", "Abend"]
				, ["Donnerstag", "Früh"], ["Freitag", "Nachmittag"]
				, ["Samstag", "Vormittag"], ["Sonntag", "Nacht"]), 7)
		this.assertEquals(dt.tableRows[1][1], "Montag")
		this.assertEquals(dt.tableRows[1][2], "Morgen")
		this.assertEquals(dt.tableRows[2][1], "Dienstag")
		this.assertEquals(dt.tableRows[2][2], "Mittag")
		this.assertEquals(dt.tableRows[3][1], "Mittwoch")
		this.assertEquals(dt.tableRows[3][2], "Abend")
		this.assertEquals(dt.tableRows[4][1], "Donnerstag")
		this.assertEquals(dt.tableRows[4][2], "Früh")
		this.assertEquals(dt.tableRows[5][1], "Freitag")
		this.assertEquals(dt.tableRows[5][2], "Nachmittag")
		this.assertEquals(dt.tableRows[6][1], "Samstag")
		this.assertEquals(dt.tableRows[6][2], "Vormittag")
		this.assertEquals(dt.tableRows[7][1], "Sonntag")
		this.assertEquals(dt.tableRows[7][2], "Nacht")
	}

	@Test_maxColValue() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(
				, DataTable.COL_RESIZE_USE_LARGEST_DATA))
		this.assertEquals(dt.addData(["Montag"], ["Dienstag"], ["Mittwoch"]
				, ["Donnerstag"], ["Freitag"], ["Samstag"], ["Sonntag"]), 7)
		this.assertEquals(dt.tableRows[1][1], "Montag")
		this.assertEquals(dt.tableRows[2][1], "Dienstag")
		this.assertEquals(dt.tableRows[3][1], "Mittwoch")
		this.assertEquals(dt.tableRows[4][1], "Donnerstag")
		this.assertEquals(dt.tableRows[5][1], "Freitag")
		this.assertEquals(dt.tableRows[6][1], "Samstag")
		this.assertEquals(dt.tableRows[7][1], "Sonntag")
		this.assertEquals(dt.aMaxColValue[1], 10)
	}

	@Test_alignColumn() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(10))
		dt.defineColumn(new DataTable.Column(30))
		dt.defineColumn(new DataTable.Column(30, DataTable.COL_ALIGN_RIGHT))
		dt.defineColumn(new DataTable.Column(30, DataTable.COL_ALIGN_CENTER))
		this.assertEquals(dt.renderColumn("abcdefghijklmnopqrstuvwxyz", 1)
				, "abcdefghij")
		this.assertEquals(dt.renderColumn("abcdefghijklmnopqrstuvwxyz", 2)
				, "abcdefghijklmnopqrstuvwxyz    ")
		this.assertEquals(dt.renderColumn("abcdefghijklmnopqrstuvwxyz", 3)
				, "    abcdefghijklmnopqrstuvwxyz")
		this.assertEquals(dt.renderColumn("abcdefghijklmnopqrstuvwxyz", 4)
				, "  abcdefghijklmnopqrstuvwxyz  ")
	}

	@Test_truncateColumn1() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(0
				, DataTable.COL_RESIZE_USE_LARGEST_DATA))
		dt.addData(["Januar"], ["Februar"], ["März"], ["April"], ["Mai"]
				, ["Juni"], ["Juli"], ["August"], ["September"], ["Oktober"]
				, ["November"], ["Dezember"])
		this.assertEquals(dt.getTableAsString()
				, "Januar   `n"
				. "Februar  `n"
				. "März     `n"
				. "April    `n"
				. "Mai      `n"
				. "Juni     `n"
				. "Juli     `n"
				. "August   `n"
				. "September`n"
				. "Oktober  `n"
				. "November `n"
				. "Dezember `n")
	}

	@Test_truncateColumn2() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(3))
		dt.addData(["Januar"], ["Februar"], ["März"], ["April"], ["Mai"]
				, ["Juni"], ["Juli"], ["August"], ["September"], ["Oktober"]
				, ["November"], ["Dezember"])
		this.assertEquals(dt.getTableAsString()
				, "Jan`n"
				. "Feb`n"
				. "Mär`n"
				. "Apr`n"
				. "Mai`n"
				. "Jun`n"
				. "Jul`n"
				. "Aug`n"
				. "Sep`n"
				. "Okt`n"
				. "Nov`n"
				. "Dez`n")
	}

	@Test_truncateColumn3() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(7
				, DataTable.COL_RESIZE_TRUNCATE_LEFT
				| DataTable.COL_RESIZE_SHOW_ELLIPSIS))
		dt.addData(["Januar"], ["Februar"], ["März"], ["April"], ["Mai"]
				, ["Juni"], ["Juli"], ["August"], ["September"], ["Oktober"]
				, ["November"], ["Dezember"])
		this.assertEquals(dt.getTableAsString()
				, "Januar `n"
				. "Februar`n"
				. "März   `n"
				. "April  `n"
				. "Mai    `n"
				. "Juni   `n"
				. "Juli   `n"
				. "August `n"
				. "...mber`n"
				. "Oktober`n"
				. "...mber`n"
				. "...mber`n")
	}

	@Test_truncateColumn4() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(8, DataTable.COL_RESIZE_TRUNCATE
				| DataTable.COL_RESIZE_SHOW_ELLIPSIS))
		dt.addData(["Januar"], ["Februar"], ["März"], ["April"], ["Mai"]
				, ["Juni"], ["Juli"], ["August"], ["September"], ["Oktober"]
				, ["November"], ["Dezember"])
		this.assertEquals(dt.getTableAsString()
				, "Januar  `n"
				. "Februar `n"
				. "März    `n"
				. "April   `n"
				. "Mai     `n"
				. "Juni    `n"
				. "Juli    `n"
				. "August  `n"
				. "Septe...`n"
				. "Oktober `n"
				. "November`n"
				. "Dezember`n")
	}

	@Test_truncateColumn5() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(7
				, DataTable.COL_RESIZE_TRUNCATE_MIDDLE
				| DataTable.COL_RESIZE_SHOW_ELLIPSIS))
		dt.addData(["Januar"], ["Februar"], ["März"], ["April"], ["Mai"]
				, ["Juni"], ["Juli"], ["August"], ["September"], ["Oktober"]
				, ["November"], ["Dezember"])
		this.assertEquals(dt.getTableAsString()
				, "Januar `n"
				. "Februar`n"
				. "März   `n"
				. "April  `n"
				. "Mai    `n"
				. "Juni   `n"
				. "Juli   `n"
				. "August `n"
				. "Se...er`n"
				. "Oktober`n"
				. "No...er`n"
				. "De...er`n")
	}

	@Test_truncateColumn6() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(8
				, DataTable.COL_RESIZE_TRUNCATE_MIDDLE
				| DataTable.COL_RESIZE_SHOW_ELLIPSIS))
		dt.addData(["Januar"], ["Februar"], ["März"], ["April"], ["Mai"]
				, ["Juni"], ["Juli"], ["August"], ["September"], ["Oktober"]
				, ["November"], ["Dezember"])
		this.assertEquals(dt.getTableAsString()
				, "Januar  `n"
				. "Februar `n"
				. "März    `n"
				. "April   `n"
				. "Mai     `n"
				. "Juni    `n"
				. "Juli    `n"
				. "August  `n"
				. "Sep...er`n"
				. "Oktober `n"
				. "November`n"
				. "Dezember`n")
	}

	@Test_wrapColumn() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column.Wrapped(5))
		dt.addData(["Das ist ein Test"], ["Das ist ein schwerer Test"])
		this.assertEquals(dt.getTableAsString()
				, "Das  `n"
				. "ist  `n"
				. "ein  `n"
				. "Test `n"
				. "Das  `n"
				. "ist  `n"
				. "ein  `n"
				. "schwe`n"
				. "rer  `n"
				. "Test `n")
	}

	@Test_wrapColumn2() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(5))
		dt.defineColumn(new DataTable.Column.Wrapped(5))
		dt.defineColumn(new DataTable.Column(3))
		dt.addData(["1.)", "Das ist ein Test", "AAA"], ["2.)"
				, "Das ist ein schwerer Test", "BBB"])
		this.assertEquals(dt.getTableAsString("|", "[", "]")
				, "[1.)  |Das  |AAA]`n"
				. "[     |ist  |   ]`n"
				. "[     |ein  |   ]`n"
				. "[     |Test |   ]`n"
				. "[2.)  |Das  |BBB]`n"
				. "[     |ist  |   ]`n"
				. "[     |ein  |   ]`n"
				. "[     |schwe|   ]`n"
				. "[     |rer  |   ]`n"
				. "[     |Test |   ]`n")
	}

	@Test_wrapColumn3() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(
				, DataTable.COL_RESIZE_USE_LARGEST_DATA))
		dt.defineColumn(new DataTable.Column.Wrapped(20))
		dt.addData(["autohotkey", "*.ahk"])
		dt.addData(["md", "*.md *.mkd *.markdown"])
		dt.addData(["ruby", "*.rb *.rhtml *.rjs *.rxml *.erb *.rake *.spec"])
		dt.addData(["yaml", "*.yaml *.yml"])
		this.assertEquals(dt.getTableAsString()
				, "autohotkey *.ahk               `n"
				. "md         *.md *.mkd          `n"
				. "           *.markdown          `n"
				. "ruby       *.rb *.rhtml *.rjs  `n"
				. "           *.rxml *.erb *.rake `n"
				. "           *.spec              `n"
				. "yaml       *.yaml *.yml        `n")
	}

	@Test_getTable() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(0))
		dt.defineColumn(new DataTable.Column(0))
		dt.defineColumn(new DataTable.Column(0))
		dt.addData(["_", "abc", "def"]
				, ["ghi", "jkl", "mno"]
				, ["pqrs", "tuv", "wxyz"])
		t := dt.getTable()
		this.assertEquals(t[1].MaxIndex(), 3)
		this.assertEquals(t[1, 1], "_")
		this.assertEquals(t[1, 2], "abc")
		this.assertEquals(t[1, 3], "def")
		this.assertEquals(t[2].MaxIndex(), 3)
		this.assertEquals(t[2, 1], "ghi")
		this.assertEquals(t[2, 2], "jkl")
		this.assertEquals(t[2, 3], "mno")
		this.assertEquals(t[3].MaxIndex(), 3)
		this.assertEquals(t[3, 1], "pqrs")
		this.assertEquals(t[3, 2], "tuv")
		this.assertEquals(t[3, 3], "wxyz")
	}

	@Test_getTableAsString() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(0))
		dt.defineColumn(new DataTable.Column(0))
		dt.defineColumn(new DataTable.Column(0))
		dt.addData(["_", "abc", "def"]
				, ["ghi", "jkl", "mno"]
				, ["pqrs", "tuv", "wxyz"])
		this.assertEquals(dt.getTableAsString()
				, "_ abc def`nghi jkl mno`npqrs tuv wxyz`n")
	}

	@Test_getTableAsString2() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(0))
		dt.defineColumn(new DataTable.Column(0))
		dt.defineColumn(new DataTable.Column(0))
		dt.addData(["_", "abc", "def"]
				, ["ghi", "jkl", "mno"]
				, ["pqrs", "tuv", "wxyz"])
		this.assertEquals(dt.getTableAsString(" | ", "[ ", " ]")
				, "[ _ | abc | def ]`n"
				. "[ ghi | jkl | mno ]`n"
				. "[ pqrs | tuv | wxyz ]`n")
	}

	@Test_getTableForConsoleOutput() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(5,, 93,101))
		dt.defineColumn(new DataTable.Column(3,, 97,42))
		dt.addData(["_", "123"], ["abc", "456"], ["def", "789"]
				, ["ghi", "abc"], ["jkl", "def"])
		t := dt.getTableForConsoleOutput("|", Ansi.ESC "[1m<" Ansi.reset(), ">")
		this.assertEquals(t.maxIndex(), 5)
		; TestCase.write(LoggingHelper.dump(t) "`n")
	}

	@Test_truncateMiddle() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(12
				, DataTable.COL_RESIZE_TRUNCATE_MIDDLE
				| DataTable.COL_RESIZE_SHOW_ELLIPSIS))
		dt.defineColumn(new DataTable.Column(13
				, DataTable.COL_RESIZE_TRUNCATE_MIDDLE
				| DataTable.COL_RESIZE_SHOW_ELLIPSIS))
		this.assertEquals(dt.renderColumn("f37c99f8569d4c4ab703", 1)
				, "f37c9...b703")
		this.assertEquals(dt.renderColumn("f37c99f8569d4c4ab703", 2)
				, "f37c9...ab703")
	}

	@Test_setSortAlghorithm() {
		dt := new DataTable()
		dt.setSortAlgorithm(DataTable.SORT_SELECTIONSORT)
		this.assertEquals(dt.iSortAlgorithm, DataTable.SORT_SELECTIONSORT)
		dt.setSortAlgorithm(DataTable.SORT_QUICKSORT)
		this.assertEquals(dt.iSortAlgorithm, DataTable.SORT_QUICKSORT)
		this.assertException(dt, "SetSortAlgorithm", "", "", 0)
		this.assertException(dt, "SetSortAlgorithm", "", "", 3)
	}

	@Test_sort() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(0))
		dt.addData(["aaa"])
		dt.sort()
		t := dt.getTable()
		this.assertEquals(t[1, 1], "aaa")
	}

	@Test_compare() {
		this.assertEquals(DataTable.compare([1], ["a", "z"], ["b", "x"]), -1)
		this.assertEquals(DataTable.compare([1], ["b", "x"], ["a", "z"]), +1)
		this.assertEquals(DataTable.compare([1], ["b", "x"], ["b", "z"]), 0)
		this.assertEquals(DataTable.compare([2], ["a", "z"], ["b", "x"]), +1)
		this.assertEquals(DataTable.compare([2], ["b", "x"], ["a", "z"]), -1)
		this.assertEquals(DataTable.compare([2], ["b", "x"], ["b", "x"]), 0)
		this.assertEquals(DataTable.compare([1,2], ["a", "z"], ["a", "x"]), +1)
		this.assertEquals(DataTable.compare([2,1], ["a", "z"], ["b", "z"]), -1)
	}

	@Test_sort1() {
		dt := new DataTable()
		dt.defineColumn(new DataTable.Column(0))
		dt.addData(["Montag"], ["Dienstag"], ["Mittwoch"], ["Donnerstag"]
				, ["Freitag"], ["Samstag"], ["Sonntag"])
		dt.sort()
		t := dt.getTable()
		this.assertEquals(t[1, 1], "Dienstag")
		this.assertEquals(t[2, 1], "Donnerstag")
		this.assertEquals(t[3, 1], "Freitag")
		this.assertEquals(t[4, 1], "Mittwoch")
		this.assertEquals(t[5, 1], "Montag")
		this.assertEquals(t[6, 1], "Samstag")
		this.assertEquals(t[7, 1], "Sonntag")
		dt.sort(-1)
		t := dt.getTable()
		this.assertEquals(t[7, 1], "Dienstag")
		this.assertEquals(t[6, 1], "Donnerstag")
		this.assertEquals(t[5, 1], "Freitag")
		this.assertEquals(t[4, 1], "Mittwoch")
		this.assertEquals(t[3, 1], "Montag")
		this.assertEquals(t[2, 1], "Samstag")
		this.assertEquals(t[1, 1], "Sonntag")
	}

	@Test_sort2() {
		dt := new DataTable()
		dt.setSortAlgorithm(DataTable.SORT_SELECTIONSORT)
		dt.defineColumn(new DataTable.Column(0))
		dt.defineColumn(new DataTable.Column(0))
		dt.addData(["T14", "TsA"], ["T14", "PHd"], ["T14", "SrP"]
				, ["T14", "BatJ"], ["T14", "HosB"], ["T14", "KnoA"])
		dt.addData(["T04", "Shl"], ["T04", "SCph"], ["T04", "Mkt"]
				, ["T04", "MetS"])
		dt.sort(2, 1)
		t := dt.getTable()
		this.assertEquals(t[1, 1], "T14")
		this.assertEquals(t[1, 2], "BatJ")
		this.assertEquals(t[2, 1], "T14")
		this.assertEquals(t[2, 2], "HosB")
		this.assertEquals(t[3, 1], "T14")
		this.assertEquals(t[3, 2], "KnoA")
		this.assertEquals(t[4, 1], "T04")
		this.assertEquals(t[4, 2], "MetS")
		this.assertEquals(t[5, 1], "T04")
		this.assertEquals(t[5, 2], "Mkt")
		this.assertEquals(t[6, 1], "T14")
		this.assertEquals(t[6, 2], "PHd")
		this.assertEquals(t[7, 1], "T04")
		this.assertEquals(t[7, 2], "SCph")
		this.assertEquals(t[8, 1], "T04")
		this.assertEquals(t[8, 2], "Shl")
		this.assertEquals(t[9, 1], "T14")
		this.assertEquals(t[9, 2], "SrP")
		this.assertEquals(t[10, 1], "T14")
		this.assertEquals(t[10, 2], "TsA")
		dt.sort(1, 2)
		t := dt.getTable()
		this.assertEquals(t[1, 1], "T04")
		this.assertEquals(t[1, 2], "MetS")
		this.assertEquals(t[2, 1], "T04")
		this.assertEquals(t[2, 2], "Mkt")
		this.assertEquals(t[3, 1], "T04")
		this.assertEquals(t[3, 2], "SCph")
		this.assertEquals(t[4, 1], "T04")
		this.assertEquals(t[4, 2], "Shl")
		this.assertEquals(t[5, 1], "T14")
		this.assertEquals(t[5, 2], "BatJ")
		this.assertEquals(t[6, 1], "T14")
		this.assertEquals(t[6, 2], "HosB")
		this.assertEquals(t[7, 1], "T14")
		this.assertEquals(t[7, 2], "KnoA")
		this.assertEquals(t[8, 1], "T14")
		this.assertEquals(t[8, 2], "PHd")
		this.assertEquals(t[9, 1], "T14")
		this.assertEquals(t[9, 2], "SrP")
		this.assertEquals(t[10, 1], "T14")
		this.assertEquals(t[10, 2], "TsA")
		dt.setSortAlgorithm(DataTable.SORT_QUICKSORT)
		dt.sort(1, -2)
		t := dt.getTable()
		this.assertEquals(t[1, 1], "T04")
		this.assertEquals(t[1, 2], "Shl")
		this.assertEquals(t[2, 1], "T04")
		this.assertEquals(t[2, 2], "SCph")
		this.assertEquals(t[3, 1], "T04")
		this.assertEquals(t[3, 2], "Mkt")
		this.assertEquals(t[4, 1], "T04")
		this.assertEquals(t[4, 2], "MetS")
		this.assertEquals(t[5, 1], "T14")
		this.assertEquals(t[5, 2], "TsA")
		this.assertEquals(t[6, 1], "T14")
		this.assertEquals(t[6, 2], "SrP")
		this.assertEquals(t[7, 1], "T14")
		this.assertEquals(t[7, 2], "PHd")
		this.assertEquals(t[8, 1], "T14")
		this.assertEquals(t[8, 2], "KnoA")
		this.assertEquals(t[9, 1], "T14")
		this.assertEquals(t[9, 2], "HosB")
		this.assertEquals(t[10, 1], "T14")
		this.assertEquals(t[10, 2], "BatJ")
	}
}

exitapp DataTableTest.runTests()
