# ObjCSV Library
##Library to load and save CSV files to/from objects and ListView

Written using AutoHotkey_L v1.1.09.03+ (http://l.autohotkey.net/)
By JnLlnd on AHK forum
Library home on GitHub [https://github.com/JnLlnd/ObjCSV](https://github.com/JnLlnd/ObjCSV)
2013-08-22+, last update (v0.5.1): 2016-06-06

AutoHotkey_L (AHK) functions to load from CSV files, sort, display and save collections of records using the Object data type
* Read and save files in any delimited format (CSV, semi-colon, tab delimited, single-line or multi-line, etc.).
* Display, edit and read Collections in GUI ListView objects.
* Export Collection to fixed-width, HTML or XML files.
* Read and save files supporting the following file encoding: ANSI (default), UTF-8, UTF-16, UTF-8-RAW, UTF-16-RAW or CPnnnn (nnnn being a code page numeric identifier), new in v0.5

For more info on CSV files, see [http://en.wikipedia.org/wiki/Comma-separated_values](http://en.wikipedia.org/wiki/Comma-separated_values).  

Even if you don't know much about AHK objects, simply using these functions will help to:
* Transform a tab or semi-colon delimited CSV file to a straight coma-delimited file (any single character delimited is supported).
* Load a CSV file with multi-line fields (for example, Notes fields in a Google Contact or Outlook tasks export) and save it in a single line CSV file (with the end-of-line replacement character of your choice) that can be imported easily in Excel.
* Load a list and export it in an HTML file ready for your website.

Other usages:
* Load a file to object to run any scripted manipulation on the content of the file with the ease and safety of AHK objets.
* Add/change CSV header names, change the order of fields or remove fields in a CSV file programatically.
* Display the file content in a ListView for further viewing or editing (multiple Gui and ListView controls are supported).
* Sort the data on any field combination before loading to the ListView or saving to a CSV file.
* Save all or selected rows of a ListView to a CSV file.
* Save to a file with or without header, with the fields delimiter and encapsulator of your choice.

The most up-to-date version of this library can be found on GitHub:
[https://github.com/JnLlnd/ObjCSV](https://github.com/JnLlnd/ObjCSV)

INSTRUCTIONS

Copy this script in a file named ObjCSV.ahk and save this file in one of these \Lib folders:
  * %A_ScriptDir%\Lib\
  * %A_MyDocuments%\AutoHotkey\Lib\
  * [path to the currently running AutoHotkey_L.exe]\Lib\

You can use the functions in this library by calling ObjCSV_FunctionName. No #Include required!


DOCUMENTATION, DISCUSSION AND TUTORIAL

Library documentation:  
http://code.jeanlalonde.ca/ahk/ObjCSV/ObjCSV-doc/ (updated to v0.5)

A discussion on this library and tutorials can be found on the AutoHotkey forum:  
http://www.autohotkey.com/board/topic/96618-lib-objcsv-library-v01-library-to-load-and-save-csv-files-tofrom-objects-and-listview/  
http://www.autohotkey.com/board/topic/96619-objcsv-library-tutorial-basic/  
http://www.autohotkey.com/board/topic/97147-parsing-csv-files-with-multi-line-fields/  
