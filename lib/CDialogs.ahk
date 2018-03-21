/*
This file contains standard dialog classes like CFileDialog
*/

/*
Class: CFileDialog
This class is used for open/save file dialogs.
*/
Class CFileDialog
{
	/*
	Variable: Mode
	Possible values:
	- Open: Shows a dialog to select a file which is opened.
	- Save: Shows a dialog to select a file which is saved.
	*/
	;Variable: Multi
	;If true, multiple files can be selected.
	
	;Variable: FileMustExist
	;If true, the dialog requires that the file exists. Often used to open files.
	
	;Variable: PathMustExist
	;If true, the dialog requires that the path exists.
	
	;Variable: CreateNewFilePrompt
	;If true, the dialog will ask the user to create a new file if it does not exist.
	
	;Variable: OverwriteFilePrompt
	;If true, the dialog asks the user to overwrite an existing file.
	
	;Variable: FollowShortcuts
	;If true(default), shortcuts are followed. Otherwise the shortcut file itself will be used.
	
	;Variable: InitialDirectory
	;Initial directory of the dialog.
	
	;Variable: Filename
	;Initial filename in the filename edit field.
	
	;Variable: Title
	;Title of the dialog window.
	
	;Variable: Filter
	;File extension filter. AHK only supports a single user defined entry, but it may have different file extensions. An example would be "Audio files (*.mp3;*.wav)".
	
	/*
	Constructor: __New
	Creates the instance but does not show the dialog. It can be used to store a configuration of the dialog that can be reused.
	
	Parameters:
		Mode - Possible values:
				- Open: Shows a dialog to select a file which is opened.
				- Save: Shows a dialog to select a file which is saved.
	
	Returns:
	An instance of the <CFileDialog> class.
	*/
	__New(Mode="")
	{
		this.Mode := Mode ? Mode : "Open"
		this.Multi := 0
		this.FileMustExist := 0
		this.PathMustExist := 0
		this.CreateNewFilePrompt := 0
		this.OverwriteFilePrompt := 0
		this.FollowShortcuts := 1
		this.InitialDirectory := ""
		this.Filename := ""
		this.Title := ""
		this.Filter := ""
	}
	__Delete()
	{
	}
	/*
	Function: Show
	Shows a file dialog window. To show a modal window, set OwnDialogs := 1 for the GUI thread that calls this.
	
	Returns:
	1 if the user confirmed the selection and pressed OK, 0 if the file selection was cancelled.
	*/
	Show()
	{
		FileSelectFile, result, % (this.Multi ? "M" : "" ) (this.Mode = "Open" ? "" : "S") ((this.FileMustExist > 0) + (this.PathMustExist>0) * 2 + (this.CreateNewFilePrompt > 0) * 8 + (this.OverwriteFilePrompt > 0) * 16 + (this.FollowShortcuts = 0) * 32), % this.InitialDirectory (this.InitialDirectory && this.Filename ? "\" : "") this.Filename, % this.Title, % this.Filter
		if(Multi)
		{
			this.Filenames := Array()
			Loop, Parse, result, `n
				this.Filenames.Insert(A_LoopField)
		}
		else
			this.Filename := result
		return result != ""
	}
}