# Load_Save_Treeview_ahk2
Load/Save TreeView data to/from var.

## SaveTree()
```
obj := SaveTree(TV, SaveIcons:=false)
```

TV is the TV control object from the GUI.

Output obj is nested Map() objects that reflect the TreeView structure.  Preserved data includes:

* Full structure
* Bold status for each item
* Selected status for each item
* Checked status for each item
* Icon index for each item (if SaveIcons param is true)
* Expanded status for each item

NOTE:  The actual icon is not saved.  You must first recreate the ImageList (if necessary) and apply it to the TreeView for this to have the intended effect.

## LoadTree()
```
LoadTree(TV,obj)
```

TV is the TV control object from the GUI.

`obj` is the obj/var to load into the TreeView.