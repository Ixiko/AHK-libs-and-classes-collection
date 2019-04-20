; Rough example to showcase persistent tables.
; This example is not available for v1.
#include %A_ScriptDir%\..\class_hashTable.ahk

ht:=new hashTable(,"exampleTable")	; Specifying a path (name) for the table, is all it takes to make it persistent.
									; Nothing else in this code is required to make a persistent table.
									
if !ht.loadedFromFile(){			; The first time this codes runs, the file doesn't exist, hence the table is not loaded from file.
	msgbox("New table created!","Hash table example", 0x40)				
	ht["Hello"]:= "and welcome"		; Adding a key value/pair to the new table
}
;
; Use the gui to add and delete key/value pairs to the table. Reload the script to see that your changes persisted.
; You can delete the file from the Delete file button.
; Script exit on gui-close
makeGui(ht)
return
; Gui code.
deleteFromHt(ht,btn){
	if winExist("Hash table - tree view")
		winClose()
	ht.delete(btn.gui.control["key"].value)
	local f:=objbindmethod(ht,"toTree", "R20")
	setTimer(f,-1)
}
addToHt(ht, btn){	
	if winExist("Hash table - tree view")
		winClose()
	ht[btn.gui.control["key"].value]:=btn.gui.control["val"].value
	local f:=objbindmethod(ht,"toTree", "R20")
	setTimer(f,-1)
}
deleteFromDisk(ht){
	if ht.deletePersistentFile()
		msgbox("File deleted!","Hash table example", 0x40)
	else
		msgbox("File not deleted!","Hash table example", 0x10)
	ht.makeNotPersistent()
	return
}
guiClose(hgui){
	try
		hgui.destroy()
	exitapp()
}
makeGui(ht){
	local gui,add,del,tvb,rem
	gui:=guiCreate(,"Hash table editor")
	gui.addEdit("w250","Key").name:="key"
	gui.addEdit("w250","Val").name:="val"
	gui.onEvent("close","guiClose")
	add:=gui.addButton("w250","Add")
	add.onEvent("click", func("addToHt").bind(ht))
	del:=gui.addButton("w250","Delete")
	del.onEvent("click", func("deleteFromHt").bind(ht))
	tvb:=gui.addButton("w250","Open Treeview")
	tvb.onEvent("click",hashTable.toTree.bind(ht,"R20"))
	rem:=gui.addButton("w250","Delete file")
	rem.onEvent("click",func("deleteFromDisk").bind(ht))
	onExit(func("guiClose").bind(gui))
	gui.show()
}