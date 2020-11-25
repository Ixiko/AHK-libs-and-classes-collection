# AHKDb

### What is AHKDb?

AHKDb is a database library for [AutoHotkey](https://www.autohotkey.com/). It makes it possible to store, modify and extract information from tab separated databases.

#

### Features

* No external dependencies (100% AHK)
* Efficient
* Lightweight
* Easy to use
* Over [100 functions](https://github.com/AHKDb/AHKDb#list-of-functions)
* Built-in [graphical database viewer](https://github.com/AHKDb/AHKDb#database-viewer)
* Well-commented code
* Extensive [documentation](https://github.com/AHKDb/AHKDb/blob/master/AHKDb%20Documentation.pdf)
* Practice datasets included

#

### How to Use AHKDb

To start using AHKDb, two things have to be done.
1. Place [AHKDb.ahk](https://raw.githubusercontent.com/AHKDb/AHKDb/master/AHKDb.ahk) in the working directory.
2. Put `#Include AHKDb.ahk` somewhere in your .ahk file.

AHKDb can now be used. For a start, it can be a good idea to try the code example below. For information about the functions of AHKDb, the [documentation](https://github.com/AHKDb/AHKDb/blob/master/AHKDb%20Documentation.pdf) may be useful.

#

### Code Example

The following code example demonstrates some of the functionality of AHKDb:
```autohotkey
#Include AHKDb.ahk

; Create a test database of type "AIRPORTS"
DatabaseCreateTest( "database.txt", "AIRPORTS" )
DatabaseView( "database.txt" )

; Add a new airport
DatabaseAddRow( "database.txt", "HFA", "Haifa Airport", "Haifa, Israel", "1934", "9" )
DatabaseView( "database.txt" )

; Sort airports by opening year
DatabaseSortByColumn( "database.txt", 4, , , TRUE )
DatabaseView( "database.txt" )

; Keep only airports opened in 1936
DatabaseKeepIfEqual( "database.txt", 4, 1936, TRUE )
DatabaseView( "database.txt" )

; Remove the third column
DatabaseRemoveColumn( "database.txt", 3 )
DatabaseView( "database.txt" )

; Find the airport with the highest elevation
HighestElevation := DatabaseGetLargest( "database.txt", , 4, , TRUE )
Airport := DatabaseMatchGetColumn( "database.txt", 2, TRUE, , , , HighestElevation )
MsgBox, %Airport% has the highest elevation of %HighestElevation% meter above sea level.

; Delete database
DatabaseDelete( "database.txt" )
```

#

### Database Viewer

AHKDb includes a database viewer, which can be opened using `DatabaseView( "database.txt" )`. The viewer can display up to 50 columns and practically unlimited rows. By default, the AHK script that opened the viewer is paused until the viewer is closed, but this can be changed by a passing a `TRUE` argument.

![AHKDb comes with a simple database viewer.](https://raw.githubusercontent.com/AHKDb/AHKDb/master/readme_files/database_viewer.png)

#

### Tab-separated data

Data is stored using tab separation. The principle is the same as for comma-separated values (CSV), but with *tab* as separator instead of *comma*. This way of storing data has pros and cons, as outlined in [this blog post](https://www.astronomer.io/blog/data-formats-101/) which compares it with other formats. One disadvantage is that the format is not suited for nesting data. An advantage is that the data is stored relatively compactly, and another is that the tab-separated data format can be read by many programs (as seen below with Microsoft Excel, Notepad, Brackets and Mozilla Firefox), although columns may not be well aligned if data within columns are of varying length.

![Many programs can read tab-separated data.](https://raw.githubusercontent.com/AHKDb/AHKDb/master/readme_files/tab_separated_data.png)

#

### List of Functions

The following list shortly describes each function of AHKDb. More details about each function is found in the [documentation](https://github.com/AHKDb/AHKDb/blob/master/AHKDb%20Documentation.pdf).

Nr | Function | Description
--- | --- | --- 
1 | DatabaseAbsoluteValue | Replaces the content of specified cells with their absolute values.
2 | DatabaseAddColumn | Adds a new column to the right end of database.
3 | DatabaseAddition | Adds a constant to each cell value.
4 | DatabaseAddNA | Replaces empty cells with "NA".
5 | DatabaseAddNumerationColumn | Adds a new column containing 1, 2, 3 … to the right end of database.
6 | DatabaseAddRandomColumn | Adds a new column containing random numbers to the right end of database.
7 | DatabaseAddRow | Adds a new row to the bottom end of database.
8 | DatabaseArcCos | Replaces the content of specified cells with arccosine of each cell value.
9 | DatabaseArcSin | Replaces the content of specified cells with arcsine of each cell value.
10 | DatabaseArcTan | Replaces the content of specified cells with arctangent of each cell value.
11 | DatabaseBackup | Backup database using a built-it naming system.
12 | DatabaseCeiling | Replaces the content of specified cells with each cell value rounded up (to closest integer).
13 | DatabaseCheck | Inspects database for two types of constructional errors.
14 | DatabaseColumnSplitDelimiter | Splits a column, at the instance of a specified delimiter, into two columns.
15 | DatabaseColumnSplitLeft | Splits a column after a specified number of characters (starting from left) into two columns.
16 | DatabaseColumnSplitRight | Splits a column after a specified number of characters (starting from right) into two columns.
17 | DatabaseCompare | Compares content of two databases.
18 | DatabaseCompareDimensions | Compares the number of rows and columns between two databases.
19 | DatabaseConcatenateColumns | Concatenates two database columns. New column is based on the right end of database.
20 | DatabaseConcatenateRows | Concatenates two database rows. New row is placed in the bottom of database.
21 | DatabaseCopy | Store a copy of a database (or a part of a database) as a new file.
22 | DatabaseCos | Replaces the content of specified cells with cosine of each cell value.
23 | DatabaseCreate | Creates a new database file.
24 | DatabaseCreateTest | Creates a test database (useful when testing functions).
25 | DatabaseDelete | Deletes database.
26 | DatabaseDivideColumns | Adds a new column containing cells of one column divided by another.
27 | DatabaseDivision | Divides specified cells by a specified divisor.
28 | DatabaseDuplicateColumn | Creates a copy of a column.
29 | DatabaseDuplicateRow | Creates a copy of a row.
30 | DatabaseExp | Replaces the content of specified cells with exp() of each value.
31 | DatabaseExportCSV | Export a tab-separated database as a comma-separated database.
32 | DatabaseFind | Find cell containing a specified search term.
33 | DatabaseFloor | Replaces the content of specified cells with each cell value rounded down (to closest integer).
34 | DatabaseGet | Returns a row, column or cell from a database. Both Row and Column cannot be unspecified.
35 | DatabaseGetEncoding | Returns the encoding of the database file.
36 | DatabaseGetLargest | Returns the nth (set by Order) largest value from the specified cells.
37 | DatabaseGetMean | Returns the (arithmetic) mean value from the specified cells.
38 | DatabaseGetMedian | Returns the median value from the specified cells.
39 | DatabaseGetNumberOfCells | Returns the number of cells in the database.
40 | DatabaseGetNumberOfColumns | Returns the number of columns in the database.
41 | DatabaseGetNumberOfRows | Returns the number of rows in the database.
42 | DatabaseGetRandomCell | Returns the content of a randomly selected database cell.
43 | DatabaseGetRandomCellLocation | Returns the location (as an array) of a randomly selected database cell.
44 | DatabaseGetRandomColumn | Returns a randomly selected column (as an array).
45 | DatabaseGetRandomColumnNumber | Returns the column number of a randomly selected column.
46 | DatabaseGetRandomRow | Returns a randomly selected row (as an array).
47 | DatabaseGetRandomRowNumber | Returns the row number of a randomly selected row.
48 | DatabaseGetSmallest | Returns the nth (set by Order) smallest value from the specified cells.
49 | DatabaseGetSum | Returns the sum of all values in the specified cells.
50 | DatabaseImportCSV | Import a comma-separated database (i.e., convert a comma-separated file to a tab-separated file).
51 | DatabaseInsertColumn | Inserts a column at a specified location.
52 | DatabaseInsertRow | Inserts a row at a specified location.
53 | DatabaseIsNumeric | Returns 1 if all cells are numeric, 0 otherwise.
54 | DatabaseKeepIfEqual | Keeps only rows for which a column value is equal to a specified value.
55 | DatabaseKeepIfGreater | Keeps only rows for which a column value is greater than a specified value.
56 | DatabaseKeepIfGreaterOrEqual | Keeps only rows for which a column value is greater than or equal to a specified value.
57 | DatabaseKeepIfLess | Keeps only rows for which a column value is less than a specified value.
58 | DatabaseKeepIfLessOrEqual | Keeps only rows for which a column value is less than or equal to a specified value.
59 | DatabaseKeepIfNotEqual | Keeps only rows for which a column value is not equal to a specified value.
60 | DatabaseLog | Replaces the content of specified cells with the (base 10) logarithm of each value.
61 | DatabaseMatchCountRows | Counts the number of rows with cell content as specified.
62 | DatabaseMatchGetColumn | Retrieves column content from a row that matches a given set of column criteria.
63 | DatabaseMatchGetRowNumber | Retrieves a row number of a row that matches a given set of column criteria.
64 | DatabaseMatchSetColumn | Sets the column content of a specified column from a row that matches a given set of column criteria.
65 | DatabaseMergeByColumns | Merges two databases by columns (i.e., stacks vertically).
66 | DatabaseMergeByRows | Merges two databases by rows (i.e., attaches horizontally).
67 | DatabaseModifyCell | Modifies the content of a cell.chrome 
68 | DatabaseModifyColumn | Modifies cells of a column.
69 | DatabaseModifyRow | Modifies cells of a row.
70 | DatabaseModulo | Replaces the content of specified cells with modulo of each value.
71 | DatabaseMoveColumn | Moves a column to a new location within the database.
72 | DatabaseMoveRow | Moves a row to a new location within the database.
73 | DatabaseMultiplication | Multiplies each cell value by a factor.
74 | DatabaseMultiplyColumns | Multiplies cells of one column by elements of another column, and stores the result in a new column.
75 | DatabaseNaturalLog | Replaces the content of specified cells with the (base e) natural logarithm of each value.
76 | DatabasePower | Replaces the content of specified cells with each value to the nth power.
77 | DatabaseRecycle | Recycles database (places the database in the Recycle Bin).
78 | DatabaseRemoveColumn | Deletes a database column.
79 | DatabaseRemoveDuplicates | Remove rows with the same content in a specified column.
80 | DatabaseRemoveDuplicatesByColumn | Removes any row that is a complete copy (each column content is the same) of another row, and keeps only the first (top) row among duplicates.
81 | DatabaseRemoveIfEqual | Removes rows for which a column value is equal to a specified value.
82 | DatabaseRemoveIfGreater | Removes rows for which a column value is greater than a specified value.
83 | DatabaseRemoveIfGreaterOrEqual | Removes rows for which a column value is greater than or equal to a specified value.
84 | DatabaseRemoveIfLess | Removes rows for which a column value is less than a specified value.
85 | DatabaseRemoveIfLessOrEqual | Removes rows for which a column value is less than or equal to a specified value.
86 | DatabaseRemoveIfNotEqual | Removes rows for which a column value is not equal to a specified value.
87 | DatabaseRemoveNA | Empties database cells containing NA.
88 | DatabaseRemoveRow | Deletes a database row.
89 | DatabaseReplace | Replaces a specified cell content with another specified cell content.
90 | DatabaseRound | Rounds cell values.
91 | DatabaseSin | Replaces the content of specified cells with sine of each cell value.
92 | DatabaseSortByColumn | Sorts rows of database by content in a specified column.
93 | DatabaseSquareRoot | Replaces the content of specified cells with the square root of each cell value.
94 | DatabaseSubString | Replace the content of specified cells with a substring of the original content.
95 | DatabaseSubtractColumns | Adds a new column containing one column subtracted by another column.
96 | DatabaseSubtraction | Subtracts a value from the specified cells.
97 | DatabaseSumColumns | Adds a new column containing the sum of (the corresponding cells of) two columns.
98 | DatabaseSwitchColumns | Switches the location of two database columns.
99 | DatabaseSwitchRows | Switches the location of two database row. 
100 | DatabaseTan | Replaces the content of specified cells with tangent of each cell value.
101 | DatabaseTranspose | Transposes database (i.e., turns columns into rows, and rows into columns).
102 | DatabaseTrimLeft | Removes a specified number of characters from each cell content.
103 | DatabaseTrimRight | Removes a specified number of characters from each cell content.
104 | DatabaseView | Opens database in the graphical Database Viewer.

#

### Looking for AHK-DB?

AHKDb can easily be confused with [AHK-DB](https://github.com/Uberi/AHK-DB), an SQLite database library for AHK.

