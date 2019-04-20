/*
Class: CFolderDialog
This class is used for open/save file dialogs.
*/
Class CFolderDialog
{
	;Property: ShowNewFolderButton
	;If true, a button to create a new folder will be shown.
	
	;Property: ShowEditField
	;If true, an edit field to enter a folder name will be shown.
	
	;Property: NewDialogStyle
	;Makes sure that this will work in a Preinstallation Environment like WinPE or BartPE. However, this prevents the appearance of a "make new folder" button, at least on Windows XP.
	
	;Property: Folder
	;Initial directory of the dialog and the selected directory when the user confirmed the selection.
		
	;Property: Title
	;Title of the dialog window.
	
	/*
	Constructor: __New
	Creates the instance but does not show the dialog. It can be used to store a configuration of the dialog that can be reused.
	
	Returns:
	An instance of the <CFolderDialog> class.
	*/
	__New()
	{
		this.ShowNewFolderButton := 0
		this.ShowEditField := 0
		this.NewDialogStyle := 0
		this.InitialDirectory := ""
		this.Title := ""
	}
	/*
	Function: Show
	Shows a folder dialog window. To show a modal window, set OwnDialogs := 1 for the GUI thread that calls this.
	
	Returns:
	1 if the user confirmed the selection and pressed OK, 0 if the folder selection was cancelled.
	*/
	Show()
	{
		FileSelectFolder, result, ((this.ShowNewFolderButton > 0) + (this.ShowEditField>0) * 2 + (this.NewDialogStyle > 0) * 4, % this.Folder, % this.Title
		this.Folder := result
		return result != ""
	}
}