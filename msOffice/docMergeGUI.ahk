docMergeGUI(){
	global
	Gui, Add, GroupBox, x12 y10 w650 h50 , Word Template
	Gui, Add, Text, x12 y190 w580 h20 +Center, AHKdocMerge 1.0
	Gui, Add, Text, x22 y30 w590 h20 vwPath, -
	Gui, Add, Button, x622 y30 w30 h20 gwPath, ...
	Gui, Add, GroupBox, x12 y70 w650 h50 , Excel Data
	Gui, Add, Text, x22 y90 w590 h20 vxlPath, -
	Gui, Add, Button, x622 y90 w30 h20 gxlPath, ...
	Gui, Add, GroupBox, x12 y130 w650 h50 , Output Folder
	Gui, Add, Text, x22 y150 w590 h20 vdirPath, -
	Gui, Add, Button, x622 y150 w30 h20 gdirPath, ...
	Gui, Add, Button, x602 y200 w60 h20 gMerge, Merge
	Gui, Add, Button, x602 y230 w60 h20 gCancel, Cancel
	Gui, Add, Text, x12 y210 w580 h30 +Center, Select Word template`, Excel data and output folder. Your Excel data will be merged with Word bookmarks bearing the name of their respective column headers.
	Gui, Add, Text, x12 y240 w580 h20 +Center, github.com/jakupmichaelsen
	; Generated using SmartGUI Creator 4.0
	Gui, Show, x376 y161 h274 w681, New GUI Window
	Return
	
	Cancel:
	GuiClose:
	xl.quit
	oWord.quit
	ExitApp

	wPath:
	FileSelectFile, template, , , Select your Word template
	GuiControl,,wPath,%template%
	Return

	xlPath:
	FileSelectFile, data, , , Select your Excel data 
	GuiControl,,xlPath,%data%
	Return

	dirPath:
	FileSelectFolder, outDir, , 4, Select the output folder for your merged documents
	GuiControl,,dirPath,%outDir%
	Return

	Merge:
	Gui, Submit
	Gui, Destroy
	Return
}