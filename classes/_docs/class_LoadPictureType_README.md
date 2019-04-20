# LoadPictureType
Load a picture and specify the type of the returned handle; `hBitmap, hIcon or hCursor.`

Use the regular LoadPicture parameters, see [LoadPicture](https://autohotkey.com/docs/commands/LoadPicture.htm "I like pie")

The parameter ImageType specifies the type of the returned handle, `IMAGE_BITMAP:=0, IMAGE_ICON:=1, IMAGE_CURSOR:=2`

If getting an icon or cursor handle, specify the background color (RGB) of the bitmap, via the `bkColor` parameter, this color will be transparent.

For cursors, you may specify the hotspot coordinates, via the `xHotspot` and `yHotspot` parameters.

For circular reference: [AutoHotkey community](https://autohotkey.com/boards/viewtopic.php?f=6&t=33209 "AHK forum")