Class CImageConverter extends CGUI
{
	/*
	Vars:
	Files := Array()
	AspectRatio
	*/
	__New(Action)
	{
		this.Title := "Image Converter & Uploader"
		this.Files := Array()
		this.TemporaryFiles := Action.TemporaryFiles
		this.ReuseWindow := Action.ReuseWindow
		
		this.ListView := this.AddControl("ListView", "ListView", "-Multi NoSort r13 w350", "File|Target Filename")
		this.ListView.IndependentSorting := true
		this.ListView.ModifyCol(1, 150)
		this.ListView.ModifyCol(2, "AutoHdr")
		this.Picture := this.AddControl("Picture", "Picture", "x+10 w" this.BitmapGUIWidth " h" this.BitmapGUIHeight " +0xE +0x40", "") ; +0xE is needed for setting the picture to a hbitmap
		this.Picture.Tooltip := "Click the image to edit it in the registered image editing program.`n Save it and quit the program to refresh it here."
		
		this.txtPath := this.AddControl("Text", "txtPath", "x10 y275 Section", "Target Path:")
		this.editPath := this.AddControl("Edit", "editPath", "x+14 ys-4 w196", "")
		if(Action.TargetPath)
			this.editPath.Text := Action.TargetPath
		this.btnBrowse := this.AddControl("Button", "btnBrowse", "x+5 ys-6 w26", "...")
		this.txtName := this.AddControl("Text", "txtName", "x10 ys+30", "Target Name:")
		this.editName := this.AddControl("Edit", "editName", "x+8 ys+26 w196", "")
		this.txtTargetFormat := this.AddControl("Text", "txtTargetFormat", "x10 ys+60", "Target Format:")
		this.ddlTargetExtension := this.AddControl("DropDownList", "ddlTargetExtension", "Choose1 x+4 ys+56", "Keep Extension|bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png")
		
		;Make sure to show quality setting only on specific items
		for index, item in this.ddlTargetExtension.Items
		{
			if(InStr("JPG,JPEG,JPE,JFIF", item.text))
			{
				if(!this.txtQuality)
				{
					this.txtQuality := item.AddControl("Text", "txtQuality", "x+10 ys+60", "Quality:")
					this.editQuality := item.AddControl("Edit", "EditQuality", "x+10 ys+56", Settings.Misc.ImageQuality)
				}
				else
				{
					item.Controls.Insert(this.txtQuality)
					item.Controls.Insert(this.editQuality)
				}
			}
		}
		this.chkOverwriteFiles := this.AddControl("Checkbox", "chkOverwriteFiles", "xs ys+90", "Overwrite existing files")
		this.chkDeleteSourceFiles := this.AddControl("Checkbox", "chkDeleteSourceFiles", "x+4" (Action.TemporaryFiles ? " Checked Disabled" : ""), "Delete source files")
		this.txtUpload := this.AddControl("Text", "txtUpload", "x10 y405", "Upload")
		this.ddlWhichFiles := this.AddControl("DropDownList", "ddlWhichFiles", "x+10 y401 w70", "selected||all")
		this.txtFilesTo := this.AddControl("Text", "txtFilesTo", "x+10 y405", "files to:")
		for index, FTPProfile in  CFTPUploadAction.FTPProfiles
			Hosters .= (index != 1 ? "|" : "") index ": " FTPProfile.Hostname (Action.Hoster = index ? "|" : "")
		Hosters .= "|" GetImageHosterList().ToString("|")
		if(!IsNumeric(Action.Hoster))
			Hosters := RegexReplace(Hosters, Action.Hoster "\|?", Action.Hoster "||")
		this.ddlHoster := this.AddControl("DropDownList", "ddlHoster", "x+10 y401 w183", Hosters)
		
		;Make ftp target directory controls enabled only when an ftp server is selected
		for index, item in this.ddlHoster.Items
		{
			if(IsNumeric(SubStr(item.text, 1, 1)))
			{
				if(!this.txtDirectory)
				{
					this.txtDirectory := item.AddControl("Text", "txtDirectory", "x+10 y405", "Directory:", 1)
					this.editFTPTargetDir := item.AddControl("Edit", "editFTPTargetDir", "x+10 y401 w120", Action.FTPTargetDir, 1)
				}
				else
				{
					item.Controls.Insert(this.txtDirectory)
					item.Controls.Insert(this.editFTPTargetDir)
				}
			}
		}

		this.btnUpload := this.AddControl("Button", "btnUpload", "x+5 y400 w69", "&Upload")
		this.btnUpload.SetImage(A_WinDir "\system32\shell32.dll:13", 16, 16, 0)
		this.btnCopyToClipboard := this.AddControl("Button", "btnCopyToClipboard", "x+30 y400 w111", "&Copy to Clipboard")
		this.btnCopyToClipboard.SetImage(A_ScriptDir "\Icons\copy.ico", 16, 16, 0)
		this.btnConvertAndSave := this.AddControl("Button", "btnConvertAndSave", "x+5 y400 w140", "Convert && &Save && Close")
		this.btnConvertAndSave.SetImage(A_ScriptDir "\Icons\save.ico", 16, 16, 0)
		this.btnCancel := this.AddControl("Button", "btnCancel", "x+5 y400 w60", "Cancel")
		LV_Modify(1, "Select")
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		this.Show("Autosize")
	}

	PreClose()
	{
		;Possibly delete old files
		;Get list of involved files
		Files := []
		TargetDir := this.editPath.Text
		for index, Item in this.ListView.Items
		{
			SplitPath(this.Files[index].SourceFile, "", SourceDir)
			Target := (TargetDir ? TargetDir : SourceDir) "\" Item[2]
			;Strategy: Delete all files from temp directory (from screenshots) and source files if the user chooses to delete them after the conversion process.
			;		   Images which couldn't be converted (and therefore don't exist in their target destination) are left untouched, same for overwritten files
			if((this.chkDeleteSourceFiles.Checked && FileExist(Target) && this.Files[index].SourceFile != Target) || InStr(this.Files[index].SourceFile, A_Temp "\7plus\"))
				Files.Insert(this.Files[index].SourceFile)
		}
		;Check if an upload is still running and possibly attach an action to it to delete the involved files
		;Enable Critical so the event processing doesn't interfere here (should be unlikely but better be sure)
		Critical, On
		if(this.tmpQueuedUploadEvent && EventSystem.EventSchedule.IndexOf(this.tmpQueuedUploadEvent))
		{
			Action := new CFileDeleteAction()
			Action.SourceFile := this.ddlWhichFiles.Text = "All" ? Files : this.tmpQueuedUploadEvent.Actions[1].SourceFiles
			Action.Silent := 1
			this.tmpQueuedUploadEvent.Actions.Insert(Action)
			for index, File in Action.SourceFile ;Remove all files which will be delete when the upload action finishes so that all other files can be deleted here
				Files.Delete(File)
		}
		Critical, Off
		;Delete all other files
		for index, File in Files
			FileDelete, % File
	}

	;Adds files to the list of images
	AddFiles(Files)
	{
		Files := ToArray(Files)
		if(Files.MaxIndex() < 1)
		{
			Notify("Image Converter Error", "No files selected!", 5, NotifyIcons.Error)
			return
		}
		Added := false
		for index, file in Files
		{
			SplitPath(file, Filename, "", Extension)
			if Extension not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
			{
				Notify("Image Converter Error", file " is no supported image format!", 5, NotifyIcons.Error)
				continue
			}
			if(!this.Files.GetItemWithValue("SourceFile", file)) ;Append files which aren't yet in the list
			{
				this.ListView.Items.Add("", Filename)
				this.Files.Insert({SourceFile : File})
				Added := true
			}
		}
		if(Added)
		{
			this.FillTargetFilenames()
			this.ListView.SelectedIndex := this.Files.MaxIndex() - Files.MaxIndex() + 1
			if(this.TemporaryFiles && this.Files.MaxIndex() = Files.MaxIndex() && !this.editPath.Text) ;Select first file if list was empty before
			{
				SplitPath(this.Files[1].SourceFile,"",Path)
				this.editPath.Text := Path
			}
			this.Show()
		}
		else
			Notify("Image Converter Error", "No new files!", 5, NotifyIcons.Error)
		return
	}
	
	;Calculates target filenames and shows them
	FillTargetFilenames()
	{
		Targets := Array()
		for index, item in this.ListView.Items
		{
			SplitPath(this.Files[A_Index].SourceFile, "", dir, Extension, Filename)
			if(this.Files[A_Index].HasKey("TargetFilename") && this.Files[A_Index].TargetFilename != "")
				Filename := this.Files[A_Index].TargetFilename
			if(this.ddlTargetExtension.Text != "Keep extension")
				Extension := this.ddlTargetExtension.Text
				
			Testpath := (this.editPath.Text ? this.editPath.Text : dir) "\" Filename "." Extension
			i := 1 ;Find free Filename. Use custom code instead of FindFreeFileName() to include the target paths from other images.
			while((!this.chkOverwriteFiles.Checked && FileExist(TestPath)) || (Targets.IndexOf(TestPath) > 0 && Targets.IndexOf(TestPath) < index))
			{
				i++
				Testpath := dir "\" Filename " (" i ")." Extension
			}
			SplitPath(Testpath,Filename)
			
			Targets[index] := TestPath
			this.ListView.Items[A_Index][2] := Filename
		}
	}

	BitmapGUIWidth := 600
	BitmapGUIHeight := 380
	LoadImage(Path)
	{
		if(Path != this.Picture.Picture)
		{
			this.PreviousPicturePath := this.Picture.Picture
			SplitPath(this.Picture.Picture, cFilename, cPath)
			WatchDirectory(cPath "|" cFilename "\", "")
		}
		pBitmap := Gdip_CreateBitmapFromFile(Path)
		pBitmap := this.ScaleBitmapIntoRectangle(pBitmap, Width := this.BitmapGUIWidth, Height := this.BitmapGUIHeight)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
		this.Picture.SetImageFromHBitmap(hBitmap)
		this.Picture._.Picture := Path ;Using internal details of classes isn't the nice way, but I need to store this path here :P
		this.Picture._.PictureWidth := Width
		this.Picture._.PictureHeight := Height
		; this.Picture.Picture := Path ;Set picture by path so its path property can be retrieved later.   ;;;;Unfortunately this won't preserve the aspect ratio
		DeleteObject(hBitmap)
		Gdip_DisposeImage(pBitmap)
	}

	;Scales an image proportionally to fit into Width and Height. Width and Height receive the new dimensions of the image.
	;pBitmap is disposed and the new bitmap pointer is returned.
	ScaleBitmapIntoRectangle(pBitmap, ByRef Width, ByRef Height)
	{
		MaxWidth := Width
		MaxHeight := Height
		;Calculate the aspect ratio of the image to make it fit in the boundary box in the GUI
		Width := Gdip_GetImageWidth(pBitmap)
		Height := Gdip_GetImageHeight(pBitmap)
		this.AspectRatio := Width / Height
		sw := min(MaxWidth / Width, 1)
		sh := min(MaxHeight / Height, 1)
		s := min(sw, sh)
		pThumbnail := Gdip_CreateBitmap(this.BitmapGUIWidth, this.BitmapGUIHeight)
		pGraphics := Gdip_GraphicsFromImage(pThumbnail)
		Gdip_SetInterpolationMode(pGraphics, 7)
		;Draw the resized image in the bounding box
		Gdip_DrawImage(pGraphics, pBitmap, 0, 0, Width * s, Height * s)
		Gdip_DeleteGraphics(pGraphics)
		Gdip_DisposeImage(pBitmap)
		return pThumbnail
	}

	ListView_SelectionChanged(Row)
	{
		if(this.ListView.SelectedIndex && this.ListView.SelectedIndex != this.ListView.PreviouslySelectedIndex)
		{
			Selected := this.Files[this.ListView.SelectedIndex ? this.ListView.SelectedIndex : this.ListView.FocusedIndex].SourceFile
			this.LoadImage(Selected)
			SplitPath(this.ListView.SelectedItem[2], "", "", "", FileName)
			this.editName.Text := FileName
			this.ActiveControl := this.ListView
			SplitPath(Selected, Filename, Path)
			WatchDirectory(Path "|" Filename "\", "ImageConverter_OpenedFileChange")
		}
	}

	editName_TextChanged()
	{
		this.Files[(index := this.ListView.SelectedIndex) ? index : this.ListView.FocusedIndex].TargetFilename := this.editName.Text
		this.FillTargetFilenames()
	}

	ddlTargetExtension_SelectionChanged()
	{
		this.FillTargetFilenames()
	}

	Picture_Click()
	{
		ImageEditor := ExpandPathPlaceholders(Settings.Misc.DefaultImageEditor)
		if(FileExist(ImageEditor))
			OpenFileWithProgram(this.Picture.Picture, ImageEditor)
		else
			run, % "edit """ this.Picture.Picture """",,UseErrorLevel
	}
	
	btnCopyToClipboard_Click()
	{
		pBitmap := Gdip_CreateBitmapFromFile(this.Files[this.ListView.SelectedIndex ? this.ListView.SelectedIndex : this.ListView.FocusedIndex].SourceFile)
		if(pBitmap)
		{
			hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
			WinClip.Clear()
			WinClip.SetBitmap(hbitmap)
			DeleteObject(hBitmap)
			Gdip_DisposeImage(pBitmap)
		}
		else
			Notify("Image Converter Error", "Failed to load image for copying!", 5, NotifyIcons.Error)
	}

	btnUpload_Click()
	{
		this.Upload()
	}

	btnConvertAndSave_Click()
	{
		this.ConvertAndSave()
	}

	btnCancel_Click()
	{
		this.Close()
	}

	chkOverwriteFiles_CheckedChanged()
	{
		this.FillTargetFilenames()
	}

	btnBrowse_Click()
	{
		FolderDialog := new CFolderDialog()
		SplitPath(this.editPath.Text ? this.editPath.Text : this.Files[this.ListView.SelectedIndex ? this.Listview.SelectedIndex : this.ListView.FocusedIndex].SourceFile, "", Path)
		FolderDialog.Folder := Path
		FolderDialog.Title := "Select output directory"
		if(!FolderDialog.Show())
			return false
		this.editPath.Text := FolderDialog.Folder
		this.FillTargetFilenames()
		return true
	}

	;Converts the images contained in the ListView and saves them at their target paths.
	;ConvertedImages and FailedImages are output parameters from this function and should be initiliazed as arrays before calling this function.
	;If TemporaryFiles is set the function will save the images to a temporary location so they can easily be deleted after uploading.
	;If the conversion process is canceled this function returns false, otherwise true.
	ConvertImages(ConvertedImages, FailedImages, SelectedOnly = 0, TemporaryFiles = 0)
	{
		if(TemporaryFiles)
			FileCreateDir, % A_Temp "\7plus\Upload"
		else if(this.TemporaryFiles && !this.editPath.Text)
		{
			if(!this.btnBrowse_Click())
				return false
		}
		for index, item in this.ListView.Items
		{
			if(SelectedOnly && !item.Selected)
				continue
			Source := this.Files[A_Index].SourceFile
			SplitPath(Source, "", SourceDir)
			Target := TemporaryFiles ? A_Temp "\7plus\Upload\" item[1] : ((this.editPath.Text ? this.editPath.Text : (this.TemporaryFiles ? FolderDialog.Folder : SourceDir)) "\" item[2])
			pBitmap := Gdip_CreateBitmapFromFile(Source)
			if(pBitmap)
			{
				if(Source = Target || Gdip_SaveBitmapToFile(pBitmap, ExpandPathPlaceholders(Target), this.editQuality.Text) = 0)
					ConvertedImages.Insert(Target)
				else
					FailedImages.Insert(Source)
				Gdip_DisposeImage(pBitmap)
			}
			else
				FailedImages.Insert(Source)
		}
		return true
	}

	ConvertAndSave()
	{
		if(this.ConvertImages(ConvertedImages := Array(), FailedImages := Array()))
		{
			if(FailedImages.MaxIndex() > 0)
			{
				for index, image in FailedImages
					Files .= (index := 1 ? "" : "`n") Image
				Notify("Image Conversion failed!", "Failed to convert these files:`n" Files, 5, NotifyIcons.Error)
			}
			else
				Notify("Image Conversion completed!", "Successfully converted " ConvertedImages.MaxIndex() " files.", 5, NotifyIcons.Success)
			this.Close()
		}
	}
	
	Upload()
	{
		this.ConvertImages(ConvertedImages := Array(), FailedImages := Array(), this.ddlWhichFiles.Text = "Selected", 1)
		;Let's build an event that uploads the files using the selected hoster and deletes them afterwards (if they are temporary (screenshot) files located in temp dir)
		Event := new CEvent()
		if(IsNumeric(SubStr(this.ddlHoster.Text, 1, max(InStr(this.ddlHoster.Text, ":") - 1, 1))))
		{
			Event.Actions.Insert(new CFTPUploadAction())
			Event.Actions[1].SourceFiles := ConvertedImages
			Event.Actions[1].TargetFolder := this.editFTPTargetDir.Text
			Event.Actions[1].FTPProfile := SubStr(this.ddlHoster.Text, 1, max(InStr(this.ddlHoster.Text, ":") - 1, 1))
		}
		else
		{
			Event.Actions.Insert(new CImageUploadAction())
			Event.Actions[1].SourceFiles := ConvertedImages
		}
		Event.Actions.Insert(new CFileDeleteAction())
		Event.Actions[2].SourceFile := ConvertedImages
		Event.Actions[2].Silent := 1
		EventSystem.TemporaryEvents.RegisterEvent(Event)
		this.tmpQueuedUploadEvent := Event.TriggerThisEvent()
	}
}

ImageConverter_OpenedFileChange(from, to) ;This gets called when a file that is being watched was modified
{
	for index, ImageConverter in CImageConverter.Instances
	{
		if(ImageConverter.Picture.Picture = from)
		{
			Selected := ImageConverter.Files[ImageConverter.ListView.SelectedIndex ? ImageConverter.ListView.SelectedIndex : ImageConverter.ListView.FocusedIndex].SourceFile
			ImageConverter.LoadImage(Selected)
		}
	}
}