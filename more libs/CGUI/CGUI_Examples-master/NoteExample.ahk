gui := new NoteExample()
#include <CGUI>
;json modifies #Escapechar and #Commentflag unfortunately so they're restored here
#include <json>
#Escapechar ` 
#Commentflag ;
Class NoteExample Extends CGUI
{
	;The TreeView control is added as a subclass here because it allows better grouping of control-related functions and properties
	Class treeNoteList
	{
		static Type := "TreeView"
		static Options := "x12 y12 w214 h400"
		static Text := ""
		__New()
		{
			j := FileExist(A_ScriptDir "\Notes.json") ? json_load(A_ScriptDir "\Notes.json") : {Categories : [], Notes : [], IsCategory : true} ;Load notes and categories
			this.FillTreeView(j) ;Add loaded notes/categories to the TreeView
		}
		;Fill tree view and assign the treeview IDs to the object
		FillTreeView(j, Parent=0)
		{
			if(Parent=0) ;Root
				Parent := this.Items ;There is a root item of class CTreeViewControl.CItem. It's ID is 0.
			else
				Parent := Parent.Add(j.Name)
			Parent.IsCategory := true
			if(j.HasKey("Categories")) ;Add sub-categories
				for index, Category in j.Categories
					this.FillTreeView(Category, Parent)
			if(j.HasKey("Notes")) ;Add notes
				for index2, Note in j.Notes
				{
					Node := Parent.Add(Note.Name)
					Node.NoteText := Note.Text
				}
		}
		
		;Triggered when the selected item in the TreeView was changed by the user or through code
		ItemSelected(GUI, Item)
		{
			t1 := this.PreviouslySelectedItem.Text
			t2 := this.SelectedItem.Text
			if(this.PreviouslySelectedItem.ID) ;if a note was selected before, store its text
				if(!this.PreviouslySelectedItem.IsCategory) ;if selected item was a note, store its text
					this.PreviouslySelectedItem.NoteText := GUI.txtNote.Text
			if(Item.IsCategory) ;If new item is a category
			{
				GUI.txtNote.Enabled := false
				GUI.txtNote.Text := ""
			}
			else
			{
				GUI.txtNote.Enabled := true
				GUI.txtNote.Text := Item.NoteText
			}
			GUI.txtName.Text := Item.Text ;display the name of the category/note
		}
	}
	
	btnAddCategory			:= this.AddControl("Button", "btnAddCategory", "x12 y418 w79 h23", "Add category")		
	btnDelete					:= this.AddControl("Button", "btnDelete", "x164 y418 w62 h23", "Delete")		
	txtName						:= this.AddControl("Edit", "txtName", "x232 y12 w508 h23", "")		
	txtNote							:= this.AddControl("Edit", "txtNote", "x232 y42 w508 h400", "")
	btnAddNote					:=	this.AddControl("Button", "btnAddNote", "x97 y418 w61 h23", "Add note")
	
	__New()
	{
		this.txtNote.Multi := 1
		this.Title := "NoteExample"
		this.DestroyOnClose := true ;By Setting this the window will destroy itself when the user cloeses it
		this.Show()
	}
	
	BuildSaveTree(j, Node)
	{
		if(Node.IsCategory)
		{
			for Index, Child in Node
			{
				if(Child.IsCategory)
				{
					if(!j.HasKey("Categories"))
						j.Insert("Categories", [])
					jNode := {Name : Child.Text}
					j.Categories.Insert(jNode)
					this.BuildSaveTree(jNode, Child)
				}
				else
				{
					if(!j.HasKey("Notes"))
						j.Insert("Notes", [])
					jNode := {Name : Child.Text, Text : Child.NoteText}
					j.Notes.Insert(jNode)
				}
			}
		}
		return j
	}
	
	;Called when btnAddCategory was clicked
	btnAddCategory_Click()
	{
		if(this.treeNoteList.SelectedItem.IsCategory)
			TreeParent := this.treeNoteList.SelectedItem
		else
			TreeParent :=this.treeNoteList.SelectedItem.Parent
		SelectedTreeItem := TreeParent.Add(Name := "New category") ;Add a new item as child node
		SelectedTreeItem.IsCategory := true
		SelectedTreeItem.Selected := true ;This will trigger treeNoteList.ItemSelected()
	}
	;Called when btnAddNote was clicked
	btnAddNote_Click()
	{
		if(this.treeNoteList.SelectedItem.IsCategory)
			TreeParent := this.treeNoteList.SelectedItem
		else
			TreeParent := this.treeNoteList.SelectedItem.Parent
		SelectedTreeItem := TreeParent.Add(Name := "New Note") ;Add a new item to the tree and store it
		SelectedTreeItem.Selected := true ;This will trigger treeNoteList_ItemSelected()
	}
	;Called when btnDelete was clicked
	btnDelete_Click()
	{
		SelectedTreeItem := this.treeNoteList.SelectedItem
		SelectedTreeItem.Parent.Remove(SelectedTreeItem)
	}
	;Called when the text of txtName was changed
	txtName_TextChanged()
	{
		this.treeNoteList.SelectedItem.Text := this.txtName.Text
	}
	;Catch this event to make sure current note gets saved when window gets closed
	txtNote_TextChanged()
	{
		this.treeNoteList.SelectedItem.NoteText := this.txtNote.Text
	}
	;Called when the window was destroyed (e.g. closed here)
	PreClose()
	{
		json_save(this.BuildSaveTree({Categories : [], Notes : []},this.TreeNoteList.Items), A_ScriptDir "\notes.json") ;Save all notes/categories
		ExitApp
	}
}