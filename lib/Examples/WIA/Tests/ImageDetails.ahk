#SingleInstance, force
#Persistent

;WIA image details

FileSelectFile, file,,%a_desktop%,Select image
if ErrorLevel
	ExitApp
if file=
	ExitApp

Img := ComObjCreate("WIA.ImageFile")

Img.LoadFile(file)

s := "Width = " Img.Width "`n"
    .    "Height = " Img.Height "`n"
    .    "Depth = " Img.PixelDepth "`n"
    .    "HorizontalResolution = " Img.HorizontalResolution "`n"
    .    "VerticalResolution = " Img.VerticalResolution "`n"
    .    "FrameCount = " Img.FrameCount "`n"

If Img.IsIndexedPixelFormat
{
    s := s "Pixel data contains palette indexes" "`n"
}

If Img.IsAlphaPixelFormat
{
    s := s "Pixel data has alpha information" "`n"
}

If Img.IsExtendedPixelFormat
{
    s := s "Pixel data has extended color information (16 bit/channel)" "`n"
}

If Img.IsAnimated
{
    s := s "Image is animated" "`n"
}

If Img.Properties.Exists("40091")
{
    v := Img.Properties("40091").Value
    s := s "Title = " v.String "`n"
}

If Img.Properties.Exists("40092")
{
    v := Img.Properties("40092").Value
    s := s "Comment = " v.String "`n"
}

If Img.Properties.Exists("40093")
{
    v := Img.Properties("40093").Value
    s := s "Author = " v.String "`n"
}

If Img.Properties.Exists("40094")
{
    v := Img.Properties("40094").Value
    s := s "Keywords = " v.String "`n"
}

If Img.Properties.Exists("40095")
{
    v := Img.Properties("40095").Value
    s := s "Subject = " v.String "`n"
}

MsgBox, % s
return