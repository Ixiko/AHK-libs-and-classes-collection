		### ImageFile Parameter
		The file name of an image, which is assumed to be
		in [%A_WorkingDir%](http://ahkscript.org/docs/Variables.htm#WorkingDir){_blank} if an absolute path isn't specified.
		All operating systems support GIF, JPG, BMP, ICO, CUR, and ANI images (BMP images must be 16-bit or higher).
		Other sources of icons include the following types of files: EXE, DLL, CPL, SCR, and other types that contain
		icon resources. On Windows XP or later, additional image formats such as PNG, TIF, Exif, WMF, and EMF are supported.
		Operating systems older than XP can be given support by copying Microsoft's free GDI+ DLL into the AutoHotkey.exe folder
		(but in the case of a [compiled script](http://ahkscript.org/docs/Scripts.htm#ahk2exe){_blank},
		copy the DLL into the script's folder). To download the DLL, search for the following
		phrase at [www.microsoft.com](http://www.microsoft.com/){_blank}: gdi redistributable
		
		Can be [MfString](MfString.html) instance or var containing string.
		
		**Options**: Zero or more of the following strings may be also be present immediately before the name of the file.
		Separate each option from the next with a single space or tab. For example: `\*2 \*w100 \*h-1 C:\Main Logo.bmp`.
		
		**\*IconN**: To use an icon group other than the first one in the file, specify \*Icon followed immediately by
		the number of the group. For example, `\*Icon2` would load the default icon from the second icon group.
		
		**\*n** (variation): Specify for n a number between 0 and 255 (inclusive) to indicate the allowed number of shades
		of variation in either direction for the intensity of the red, green, and blue components of each pixel's color.
		For example, `\*2` would allow two shades of variation. This parameter is helpful if the coloring of the image varies
		slightly or if ImageFile uses a format such as GIF or JPG that does not accurately represent an image on the screen.
		If you specify 255 shades of variation, all colors will match. The default is 0 shades.
		
		**\*TransN**: This option makes it easier to find a match by specifying one color within the image that will match
		any color on the screen. It is most commonly used to find PNG, GIF, and TIF files that have some transparent
		areas (however, icons do not need this option because their transparency is automatically supported).
		For GIF files, `\*TransWhite` might be most likely to work. For PNG and TIF files, `\*TransBlack` might be best.
		Otherwise, specify for **N** some other color name or RGB value
		(see the [color chart](http://ahkscript.org/docs/commands/Progress.htm#colors){_blank} for guidance, or use
		[PixelGetColor](http://ahkscript.org/docs/commands/PixelGetColor.htm){_blank} in its RGB mode).
		Examples: `\*TransBlack`, `\*TransFFFFAA`, `\*Trans0xFFFFAA`.
		
		**\*wn** and **\*hn**: Width and height to which to scale the image (this width and height also determines which
		icon to load from a multi-icon .ICO file). If both these options are omitted, icons loaded from ICO, DLL, or EXE
		files are scaled to the system's default small-icon size, which is usually 16 by 16 (you can force the actual/internal
		size to be used by specifying `\*w0 \*h0`). Images that are not icons are loaded at their actual size. To shrink or enlarge
		the image while preserving its aspect ratio, specify -1 for one of the dimensions and a positive number for the other.
		For example, specifying `\*w200 \*h-1` would make the image 200 pixels wide and cause its height to be set automatically.
		
		### Remarks  
		Wrapper for [AutoHotkey Docs - ImageSearch](http://ahkscript.org/docs/commands/ImageSearch.htm){_blank}.  
		Static method.
		
		ImageSearch can be used to detect graphical objects on the screen that either lack text or whose text cannot be easily
		retrieved. For example, it can be used to discover the position of picture buttons, icons, web page links, or game
		objects. Once located, such objects can be clicked via Click.
		
		A strategy that is sometimes useful is to search for a small clipping from an image rather than the entire image.
		This can improve reliability in cases where the image as a whole varies, but certain parts within it are always the
		same. One way to extract a clipping is to:  
			1. Press Alt+PrintScreen while the image is visible in the active window. This places a screenshot on the clipboard.  
			2. Open an image processing program such as Paint.  
			3. Paste the contents of the clipboard (that is, the screenshot).  
			3. Select a region that does not vary and that is unique to the image.  
			4. Copy and paste that region to a new image document.  
			6. Save it as a small file for use with ImageSearch.  
		
		To be a match, an image on the screen must be the same size as the one loaded via the ImageFile parameter and its options.
		
		The region to be searched must be visible; in other words, it is not possible to search a region of a window hidden behind
		another window. By contrast, images that lie partially beneath the mouse cursor can usually be detected. The exception to
		this is game cursors, which in most cases will obstruct any images beneath them.
		
		Since the search starts at the top row of the region and moves downward, if there is more than one match, the one
		closest to the top will be found.
		
		Icons containing a transparent color automatically allow that color to match any color on the screen.
		Therefore, the color of what lies behind the icon does not matter.
		
		ImageSearch supports 8-bit color screens (256-color) or higher.
		
		The search behavior may vary depending on the display adapter's color depth (especially for GIF and JPG files).
		Therefore, if a script will run under multiple color depths, it is best to test it on each depth setting.
		You can use the shades-of-variation option (\*n) to help make the behavior consistent across multiple color depths.
		
		If the image on the screen is translucent, ImageSearch will probably fail to find it. To work around this,
		try the shades-of-variation option (\*n) or make the window temporarily opaque via `WinSet, Transparent, Off`.
		
		[ErrorLevel](http://ahkscript.org/docs/misc/ErrorLevel.htm){_blank} is set to 0 if the image was found in the specified
		region, 1 if it was not found, or 2 if there was a problem that prevented the command from conducting the search
		(such as failure to open the image file or a badly formatted option).
		
		See Also:[AutoHotkey Docs - ImageSearch](http://ahkscript.org/docs/commands/ImageSearch.htm){_blank}.
		
		### Throws  
		Throws [MfException](MfException.html) if [Autohotkey - ImageSearch](http://ahkscript.org/docs/commands/ImageSearch.htm){_blank}
		throw any errors with [InnerException](MfException.InnerException.html) set to the
		[Autohotkey - ImageSearch](http://ahkscript.org/docs/commands/ImageSearch.htm){_blank} error message.  
		No error is thrown when only [ErrorLevel](http://ahkscript.org/docs/misc/ErrorLevel.htm){_blank} is set.