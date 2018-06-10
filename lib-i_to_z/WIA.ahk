; ======================================================================================================================
; WIA - Windows Image Acquisition Automation Layer -> msdn.microsoft.com/en-us/library/ms630827(v=vs.85).aspx
; Function:       Functions for images.
; Namespace:      WIA
; Tested with:    AHK 1.1.22.00 (A32/U32/U64)
; Tested on:      Win 8.1 (x64)
; Changelog:
;     1.0.02.00/2015-05-03/just me     - added WIA_CreateImage()
;     1.0.01.00/2015-04-27/just me     - fixed WIA_ScaleImage() preserve-aspect-ratio handling
;     1.0.00.00/2015-04-26/just me     - initial release
; Credits:
;     maestrith   for Crop.ahk (-> http://www.autohotkey.net/~maestrith/crop/Crop.ahk)
;     sinkfaze    for his COM example (-> http://ahkscript.org/boards/viewtopic.php?f=6&t=77&p=619)
; License:
;     The Unlicense (http://unlicense.org/)
; ======================================================================================================================
; Common function parameters (not mentioned below):
;     ImgObj      -  ImageFile object returned by WIA_LoadImage().
; Common return values (except noted below):
;     A new ImageFile object on success, otherwise False.
; ======================================================================================================================
; Creates a new image.
; Parameters:
;     Px...       -  Number of pixels for the corresponding dimension.
;     ARGBData    -  Array of ARGB color data, one per pixel, to put into the image. The data will be used to create
;                    exactly PxWidth * PxHeight pixels. The alpha value will be ignored.
; ======================================================================================================================
WIA_CreateImage(PxWidth, PxHeight, ARGBData) {
   If !WIA_IsInteger(PxWidth, PxHeight) || !WIA_IsPositive(PxWidth, PxHeight)
      Return False
   DataCount := PxWidth * PxHeight
   Vector := ComObjCreate("WIA.Vector")
   I := 1
   Loop
      For Each, ARGB In ARGBData
         Vector.Add(ComObject(0x3, ARGB))
      Until (++I > DataCount)
   Until (I > DataCount)
   Return Vector.ImageFile(PxWidth, PxHeight)
}
; ======================================================================================================================
; Converts an image into the specified format.
; Parameters:
;     NewFormat   -  New format as one of the string keys of FormatID.
;     Quality     -  Quality used for JPEG compression (1 - 100).
;     Compression -  Compression method used for TIFF compression as one of the string keys of Comp.
; Note:
;     The function also sets the FileExtension property of the new ImageFile object according to the new format.
; ======================================================================================================================
WIA_ConvertImage(ImgObj, NewFormat, Quality := 100, Compression := "LZW") {
   Static FormatID := {BMP: "{B96B3CAB-0728-11D3-9D7B-0000F81EF32E}"
                     , JPEG: "{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}"
                     , GIF: "{B96B3CB0-0728-11D3-9D7B-0000F81EF32E}"
                     , PNG: "{B96B3CAF-0728-11D3-9D7B-0000F81EF32E}"
                     , TIFF: "{B96B3CB1-0728-11D3-9D7B-0000F81EF32E}"}
   Static Comp := {CCITT3: 1, CCITT4: 1, LZW: 1, RLE: 1, Uncompressed: 1}
   If (ComObjType(ImgObj, "Name") <> "IImageFile")
      Return False
   If ((NewFormat := FormatID[NewFormat]) = "")
      Return False
   If Quality Not Between 1 And 100
      Return False
   If (Comp[Compression] = "")
      Return False
   ImgProc := WIA_ImageProcess()
   ImgProc.Filters.Add(ImgProc.FilterInfos("Convert").FilterID)
   ImgProc.Filters[1].Properties("FormatID") := NewFormat
   ImgProc.Filters[1].Properties("Quality") := Quality
   ImgProc.Filters[1].Properties("Compression") := Compression
   Return ImgProc.Apply(ImgObj)
}
; ======================================================================================================================
; Crops an image.
; Parameters:
;     Px...       -  Number of pixels to crop at the corresponding edge.
; ======================================================================================================================
WIA_CropImage(ImgObj, PxLeft, PxTop, PxRight, PxBottom) {
   If (ComObjType(ImgObj, "Name") <> "IImageFile")
      Return False
   If !WIA_IsInteger(PxLeft, PxTop, PxRight, PxBottom) || !WIA_IsPositive(PxLeft, PxTop, PxRight, PxBottom)
      Return False
   If ((ImgObj.Width - PxLeft - PxRight) < 0) || ((ImgObj.Height - PxTop - PxBottom) < 0)
      Return False
   ImgProc := WIA_ImageProcess()
   ImgProc.Filters.Add(ImgProc.FilterInfos("Crop").FilterID)
   ImgProc.Filters[1].Properties("Left") := PxLeft
   ImgProc.Filters[1].Properties("Top") := PxTop
   ImgProc.Filters[1].Properties("Right") := PxRight
   ImgProc.Filters[1].Properties("Bottom") := PxBottom
   Return ImgProc.Apply(ImgObj)
}
; ======================================================================================================================
; Retrieves descriptions of all available filters or the specified filter.
; Might be useful to provide help informations.
; Parameters:
;     FilterName  -  Filter name, omit the parameter or pass an empty string to get the descriptions of all available
;                    filters.
; Return values:
;     A string containing the filter name(s), ID(s), and description(s) on success, otherwise an empty string.
; ======================================================================================================================
WIA_FilterDescriptions(FilterName := "") {
   Static SubTypes := ["Range", "List", "Flag"]
   Static Delimiter := "============================================================"
                     . "========================================`r`n"
   Description := Delimiter
   ImgProc := WIA_ImageProcess()
   For FilterInfo In ImgProc.FilterInfos {
      If (Filtername <> "") {
         If (FilterInfo.Name = FilterName) {
            Description .= FilterInfo.Name . "     (ID: " . FilterInfo.FilterId . ")`r`n`r`n"
                         . FilterInfo.Description . "`r`n" . Delimiter
            Break
         }
      }
      Else
         Description .= FilterInfo.Name . "     (ID: " . FilterInfo.FilterId . ")`r`n`r`n"
                      . FilterInfo.Description . "`r`n" . Delimiter
   }
   Return (Description <> Delimiter ? RTrim(Description) : "")
}
; ======================================================================================================================
; Flips an image.
; Parameters:
;     Mode        -  Flip "Horizontal" or "Vertical"
; ======================================================================================================================
WIA_FlipImage(ImgObj, Mode := "Horizontal") {
   Static Modes := {"Horizontal": 1, "Vertical": 1}
   If !(Modes[Mode]) || (ComObjType(ImgObj, "Name") <> "IImageFile")
      Return False
   ImgProc := WIA_ImageProcess()
   ImgProc.Filters.Add(ImgProc.FilterInfos("RotateFlip").FilterID)
   ImgProc.Filters[1].Properties("Flip" . Mode) := True
   Return ImgProc.Apply(ImgObj)
}
; ======================================================================================================================
; Retrieves the bitmap data of the image.
; Return values:
;     A new Picture object on success, otherwise false.
; Note:
;     To retrieve the HBITMAP handle for the returned object use object.Handle
; ======================================================================================================================
WIA_GetImageBitmap(ImgObj) {
   ; To retrieve the HBITMAP handle for the returned object use object.Handle
   Return (ComObjType(ImgObj, "Name") = "IImageFile") ? ImgObj.Filedata.Picture : False
}
; ======================================================================================================================
; Retrieves the extended properties of the image.
; Parameters:
;     AsString    -  Set to true to get the properties as a string instead of an array.
; Return values:
;     On success: A property string or a property array indexed by the numerical property ID. Each array element
;                 contains an object with the key/value pairs 'Name' and 'Value'.
;     On failure: False
; ======================================================================================================================
WIA_GetImageProperties(ImgObj, AsString := False) {
   If (ComObjType(ImgObj, "Name") <> "IImageFile")
      Return False
   PropObj := []
   For Prop In ImgObj.Properties {
      PropObj[Prop.PropertyID, "Name"] := Prop.Name
      If Prop.IsVector
         Value := "[vector data not emitted]"
      Else If (Prop.Type = 1006) || (Prop.Type = 1007) ; RationalImagePropertyType || UnsignedRationalImagePropertyType
         Value := Prop.Value.Value . " (" . Prop.Value.Numerator . " / " .  Prop.Value.Denominator . ")"
      Else If (Prop.Type = 1002) ; StringImagePropertyType
         Value := """" . Prop.Value . """"
      Else
         Value := Prop.Value
      PropObj[Prop.PropertyID, "Value"] := Value
   }
   If !(AsString)
      Return PropObj
   Else {
      PropString := ""
      For PropID, Prop In PropObj
         PropString .= "ID: " . PropID . " - Name: " . Prop.Name . " - Value: " . Prop.Value . "`r`n"
      Return RTrim(PropString, "`r`n")
   }
}
; ======================================================================================================================
; Loads an image file.
; Parameters:
;     ImgPath     -  Path and name of the image file.
; ======================================================================================================================
WIA_LoadImage(ImgPath) {
   ImgObj := ComObjCreate("WIA.ImageFile")
   ComObjError(0)
   ImgObj.LoadFile(ImgPath)
   ComObjError(1)
   Return A_LastError ? False : ImgObj
}
; ======================================================================================================================
; Rotates an image in steps of 90°.
; Parameters:
;     Mode        -  Direction: "Left" or "Right"
; ======================================================================================================================
WIA_RotateImage(ImgObj, Mode := "Right") {
   Static Modes := {"Left": 270, "Right": 90}
   If !(Mode := Modes[Mode]) || (ComObjType(ImgObj, "Name") <> "IImageFile")
      Return False
   ImgProc := WIA_ImageProcess()
   ImgProc.Filters.Add(ImgProc.FilterInfos("RotateFlip").FilterID)
   ImgProc.Filters[1].Properties("RotationAngle") := Mode
   Return ImgProc.Apply(ImgObj)
}
; ======================================================================================================================
; Saves an image to disk.
; Parameters:
;     ImgPath     -  Path and name of the image file.
; Return values:
;     True on success, otherwise false. The error code is stored in A_LastError.
; Note:
;     The extension of the file name passed in ImgPath must be one of "bmp", "gif", "jpg", "png", or "tif" and match
;     the extension stored in the FileExtension property of the ImageFile object. Otherwise the file won't be stored.
;     Also, the function won't overwrite existing files.
; ======================================================================================================================
WIA_SaveImage(ImgObj, ImgPath) {
   If (ComObjType(ImgObj, "Name") <> "IImageFile")
      Return False
   SplitPath, ImgPath, FileName, FileDir, FileExt
   If (ImgObj.FileExtension <> FileExt)
      Return False
   ComObjError(0)
   ImgObj.SaveFile(ImgPath)
   ComObjError(1)
   Return !A_LastError
}
; ======================================================================================================================
; Scales/resizes an image.
; Parameters:
;     Px...       -  New image width and height in pixels.
; Note:
;     If either PxWidth or PxHeight are zero or negative, the corresponding dimension will be scaled preserving the
;     aspect ratio of the image.
; ======================================================================================================================
WIA_ScaleImage(ImgObj, PxWidth, PxHeight) {
   If (ComObjType(ImgObj, "Name") <> "IImageFile")
      Return False
   If !WIA_IsInteger(PxWidth, PxHeight) || ((PxWidth < 1) && (PxHeight < 1))
      Return False
   KeepRatio := (PxWidth < 1) || (PxHeight < 1) ? True : False
   ImgProc := WIA_ImageProcess()
   ImgProc.Filters.Add(ImgProc.FilterInfos("Scale").FilterID)
   ImgProc.Filters[1].Properties("MaximumWidth") := PxWidth > 0 ? PxWidth : PxHeight
   ImgProc.Filters[1].Properties("MaximumHeight") := PxHeight > 0 ? PxHeight : PxWidth
   ImgProc.Filters[1].Properties("PreserveAspectRatio") := KeepRatio
   Return ImgProc.Apply(ImgObj)
}
; ======================================================================================================================
; Stamps the image passed in StampObj onto the image.
; Parameters:
;     StampObj    -  Image object as returned from one of the WIA functions.
;     Px...       -  Distance to the left/top edge of the image in pixels.
; Note:
;     Both PxLeft or PxTop must be positive. Also, (PxLeft + StampObj.Width) and (PxTop + STampObj.Height) must not
;     exceed the image dimensions.
; ======================================================================================================================
WIA_StampImage(ImgObj, StampObj, PxLeft, PxTop) {
   If (ComObjType(ImgObj, "Name") <> "IImageFile") || (ComObjType(StampObj, "Name") <> "IImageFile")
      Return False
   If ((PxLeft + StampObj.Width) > ImgObj.Width) || ((PxTop + StampObj.Height) > ImgObj.Height)
      Return False
   ImgProc := WIA_ImageProcess()
   ImgProc.Filters.Add(ImgProc.FilterInfos("Stamp").FilterID)
   ImgProc.Filters[1].Properties("ImageFile") := StampObj
   ImgProc.Filters[1].Properties("Left") := PxLeft
   ImgProc.Filters[1].Properties("Top") := PxTop
   Return ImgProc.Apply(ImgObj)
}
; ======================================================================================================================
; For internal use!!!
; ======================================================================================================================
WIA_ImageProcess() {
   Static ImageProcess := ComObjCreate("WIA.ImageProcess")
   While (ImageProcess.Filters.Count)
      ImageProcess.Filters.Remove(1)
   Return ImageProcess
}
; ======================================================================================================================
WIA_IsInteger(Values*) {
   If Values.MaxIndex() = ""
      Return False
   For Each, Value In Values
      If Value Is Not Integer
         Return False
   Return True
}
; ======================================================================================================================
WIA_IsPositive(Values*) {
   If Values.MaxIndex() = ""
      Return False
   For Each, Value In Values
      If (Value < 0)
         Return False
   Return True
}