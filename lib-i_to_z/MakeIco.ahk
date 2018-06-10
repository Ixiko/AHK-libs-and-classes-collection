; MakeIco(["test.png"])

MakeIco(sourceImages, icon:="") { ;Credits to kon - http://ahkscript.org/boards/viewtopic.php?p=14093#p14093
    If (!icon) {
        SplitPath, % sourceImages[1],, si_dir,, si_name
        If (si_dir)
            icon := si_dir "\" si_name ".ico"
        Else
            icon := si_name ".ico"
    }
	ICO_ContainerSize := 16
	O := 0
	Total_PotentialSize := 6
 
	for i, img in sourceImages {
		FileGetSize, imgSize, % img
		if (imgSize)
			Total_PotentialSize += ICO_ContainerSize + imgSize
	}
 
	VarSetCapacity(ICO_Data, Total_PotentialSize, 0)
	NumPut(0, ICO_Data, O, "UShort"), O += 2 ;reserved - always 0
	NumPut(1, ICO_Data, O, "UShort"), O += 2 ;ico = 1, cur = 2
	NumPut(0, ICO_Data, O, "UShort"), O += 2 ;number of images in file (will be updated below)
 
	For i, img in sourceImages {
        dim := ImgGetDimensions(img)
        width := (dim.width=256 ? 0 : dim.width)
        height := (dim.height=256 ? 0 : dim.height)
		If (width <= 255 && height <= 255 && File := FileOpen(img, "r")) {
			NumPut(width, ICO_Data, O, "UChar"),      O += 1 ;image width (256 = 0)
			NumPut(height, ICO_Data, O, "UChar"),     O += 1 ;image height (256 = 0)
			NumPut(0, ICO_Data, O, "UChar"),          O += 1 ;color palatte: 0 if not used
			NumPut(0, ICO_Data, O, "UChar"),          O += 1 ;reserved - always 0
			NumPut(1, ICO_Data, O, "UShort"),         O += 2 ;ico - color planes (0/1), cur - horizontal coordinates of the hotspot in pixels from left
			NumPut(32, ICO_Data, O, "UShort"),        O += 2 ;ico - bits per pixel, cur - vertical coordinates of hotspot in pixels from top
			NumPut(File.Length, ICO_Data, O, "UInt"), O += 4 ;size of image data in bytes
			NumPut(O + 4, ICO_Data, O, "UInt"),       O += 4 ;offset of image data from begining of ico/cur file
			File.RawRead(&ICO_Data + O, File.Length), O += File.Length ;actual image data
			NumPut(NumGet(ICO_Data, 4, "UShort") + 1, ICO_Data, 4, "UShort") ;adds one to the total number of images
			File.Close()
		}
	}
 
	If (O > 6){
		File := FileOpen(icon, "w")
		File.RawWrite(&ICO_Data, O)
		File.Close()
		VarSetCapacity(ICO_Data, O, 0)
		VarSetCapacity(ICO_Data, 0)
        Return True
	}
}
ImgGetDimensions(fileFullPath) {
    dimensions := {}
    RegexMatch(FileGetProperty(fileFullPath, "Height"), "(\d+)", match)
    dimensions.height := match1
    RegexMatch(FileGetProperty(fileFullPath, "Width"), "(\d+)", match)
    dimensions.width := match1
    Return dimensions
}
FileGetProperty(FilePath, Property) { ;Credits to kon - http://www.autohotkey.com/boards/viewtopic.php?f=6&t=3806
    static PropTable
    if (!PropTable) {
        PropTable := {Name: {}, Num: {}}, Gap := 0
        oShell := ComObjCreate("Shell.Application")
        oFolder := oShell.NameSpace(0)
        while (Gap < 11)
            if (PropName := oFolder.GetDetailsOf(0, A_Index - 1)) {
                PropTable.Name[PropName] := A_Index - 1
                PropTable.Num[A_Index - 1] := PropName
                Gap := 0
            }
            else
                Gap++
    }
    If (!InStr(FilePath,":") && !InStr(FilePath,"\\"))
        FilePath := A_ScriptDir "\" FilePath
    if ((PropNum := PropTable.Name[Property] != "" ? PropTable.Name[Property]
    : PropTable.Num[Property] ? Property : "") != "") {
        SplitPath, FilePath, FileName, DirPath
        oShell := ComObjCreate("Shell.Application")
        oFolder := oShell.NameSpace(DirPath)
        oFolderItem := oFolder.ParseName(FileName)
        if (PropVal := oFolder.GetDetailsOf(oFolderItem, PropNum))
            return PropVal
        return 0
    }
    return -1
}