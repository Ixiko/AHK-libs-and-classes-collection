/*
Group: IMG_GIS Functions

    This mini-library includes the <IMG_GetImageSize> function along with a few
    supporting functions.
*/
;------------------------------
;
; Function: IMG_ByteSwap
;
; Description:
;
;   Reverse the ordering of bytes in a 16-bit or 32-bit unsigned integer.
;
; Parameters:
;
;   p_Nbr - A 16-bit or 32-bit unsigned integer.
;
;   p_Type - Set to a string that includes the word "Short" to reverse the
;       ordering of the two bytes in a 16-bit unsigned integer value.  Ex:
;       "UShort".  Don't specify or set to any other value including null (the
;       default) to reverse the ordering of the four bytes in a 32-bit unsigned
;       integer value.
;
; Returns:
;
;   A UShort or UInt value.
;
; Remarks:
;
;   This function is commonly used to convert the endianness of integers read
;   from a file or integers that will be written to a file.
;
;-------------------------------------------------------------------------------
IMG_ByteSwap(p_Nbr,p_Type:="")
    {
    if InStr(p_Type,"Short")
        Return ((p_Nbr&0xFF)<<8|(p_Nbr&0xFF00)>>8)
     else
        Return (p_Nbr&0xFF)<<24|(p_Nbr&0xFF00)<<8|(p_Nbr&0xFF0000)>>8|(p_Nbr&0xFF000000)>>24
    }

;------------------------------
;
; Function: IMG_GetBitmapSize
;
; Description:
;
;   Get the size of a bitmap.
;
; Parameters:
;
;   hBitmap - The handle to a bitmap.
;
;   r_Width, r_Height - [Output, Optional] If defined, these variables are set
;       to the width and height of the bitmap.  If there is an error, these
;       variables are set to 0.
;
;   r_bpp - [Output, Optional] Bits per pixel.  If defined, this variable
;       contains the number of bits used to define a pixel.  If there is an
;       error, the variable is set to 0.
;
; Returns:
;
;   An object (tests as TRUE) if successful, otherwise FALSE.  If returned, the
;   object contains the following properties:
;
;   bpp - Bits per pixel.
;
;   SizeStr - The dimensions of the bitmap as a string of characters.  Ex:
;       "1024x768".  This property can be useful when debugging or testing.
;
;   Width, Height - The width and height of the bitmap.
;
; Remarks:
;
;   To use this function to also determine if the handle of the bitmap is
;   valid, test the return value of this function.  If the hBitmap parameter
;   does not contain a valid bitmap, this function will dump a message to the
;   debugger and return FALSE (0).
;
;-------------------------------------------------------------------------------
IMG_GetBitmapSize(hBitmap,ByRef r_Width:="",ByRef r_Height:="",ByRef r_bpp:="")
    {
    Static Dummy89628542
          ,sizeofBITMAP:=A_PtrSize=8 ? 32:24

    ;-- Get bitmap info
    VarSetCapacity(BITMAP,sizeofBITMAP)
    if not DllCall("GetObject","UPtr",hBitmap,"Int",sizeofBITMAP,"UPtr",&BITMAP)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            The hBitmap parameter does not contain the handle to a valid bitmap.
            hBitmap: %hBitmap%
           )

        r_Width:=r_Height:=r_bpp:=0
        Return False
        }

    ;-- Set the output variables
    r_Width :=NumGet(BITMAP,4,"Int")                    ;-- bmWidth
    r_Height:=NumGet(BITMAP,8,"Int")                    ;-- bmHeight
    r_bpp   :=NumGet(BITMAP,18,"UShort")                ;-- bmBitsPixel
    Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
    }

;------------------------------
;
; Function: IMG_GetIconSize
;
; Description:
;
;   Get the size of an icon or cursor.
;
; Parameters:
;
;   hIcon - The handle to an icon or cursor.
;
;   r_Width, r_Height - [Output, Optional] If defined, these variables are set
;       to the width and height of the icon or cursor.  If there is an error,
;       these variables are set to 0.
;
; Returns:
;
;   An object (tests as TRUE) if successful, otherwise FALSE.  If returned, the
;   object contains the following properties:
;
;   SizeStr - The dimensions of the icon or cursor as a string of characters.
;       Ex: "64x64".  This property can be useful when debugging or testing.
;
;   Width, Height - The width and height of the icon or cursor.
;
;-------------------------------------------------------------------------------
IMG_GetIconSize(hIcon,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy42372945
          ,sizeofBITMAP:=A_PtrSize=8 ? 32:24

    ;-- Initialize
    r_Width:=r_Height:=0

    ;-- Get icon info.  Bounce if not a valid icon or cursor.
    VarSetCapacity(ICONINFO,A_PtrSize=8 ? 32:20)
    if not DllCall("GetIconInfo","UPtr",hIcon,"UPtr",&ICONINFO)
        Return False

    hMask :=NumGet(ICONINFO,A_PtrSize=8 ? 16:12,"UPtr")
    hColor:=NumGet(ICONINFO,A_PtrSize=8 ? 24:16,"UPtr")

    ;-- Get bitmap info
    VarSetCapacity(BITMAP,sizeofBITMAP)
    l_Return:=DllCall("GetObject","UPtr",hMask,"Int",sizeofBITMAP,"UPtr",&BITMAP)

    ;-- Delete the bitmaps created by GetIconInfo
    if hMask
        DllCall("DeleteObject","UPtr",hMask)

    if hColor
        DllCall("DeleteObject","UPtr",hColor)

    ;-- Bounce if GetObject failed (rare at this point)
    if not l_Return
        Return False

    ;-- Update the output variables
    r_Width :=NumGet(BITMAP,4,"Int")                    ;-- bmWidth
    bmHeight:=NumGet(BITMAP,8,"Int")                    ;-- bmHeight
    r_Height:=hColor ? bmHeight:bmHeight//2
    Return {Width:r_Width,Height:r_Height,SizeStr:r_Width . "x" . r_Height}
    }

;------------------------------
;
; Function: IMG_GetImageSize
;
; Description:
;
;   Get the image size (width and height) from a stand-alone image file.
;
; Parameters:
;
;   p_FileOrHandle - The path to a file containing the image or the handle to a
;       bitmap, icon, or cursor.
;
;   r_Width, r_Height - [Output, Optional] If defined, these variables contain
;       the width and height of the image.  If the function is not successful
;       (i.e. returns FALSE), these variables will be set to 0.
;
;   r_bpp - [Output, Optional] If defined, this variable contains the bits per
;       pixel (bpp) value if available.  See the *Bits Per Pixel* section for
;       more information.
;
; Returns:
;
;   An object (tests as TRUE) if successful, otherwise FALSE.  If returned, the
;   object contains the following properties:
;
;   bpp - Bits Per Pixel.  See the *Bits Per Pixel* section for more
;       information.
;
;   SizeStr - The dimensions of the image as a string of characters.  Ex:
;       "1024x768".  This property can be useful when debugging or testing.
;
;   Width, Height - The width and height of the image.
;
; Credit:
;
;   This function is a hodgepodge of code, examples, and specifications
;   extracted from the internet.  The idea and the first hunk of code was
;   adapted from Python and Rust code published by Paulo Scardine.  The Python
;   code from Paulo Scardine which is based on code from Emmanuel VAÏSSE can be
;   found here:
;
;   <https://stackoverflow.com/questions/15800704/get-image-size-without-loading-image-into-memory>
;
;   The Rust code from Paulo Scardine can be found here:
;
;   <https://github.com/scardine/imsz>
;
;   For the rest, there are too many other sources to credit here.  Most of the
;   sources that were used are posted in the comments within the function.
;
; Calls To Other Functions:
;
; * <IMG_ByteSwap>
; * <IMG_GetBitmapSize>
; * <IMG_GetIconSize>
; * <IMG_SystemMessage>
;
; Bits Per Pixel:
;
;   Bits Per Pixel (bpp) is an integer value that represents the amount of space
;   used to represent each pixel in the image.  Ex: 24.  In most cases this
;   value represent the amount of space used to represent a pixel in a color
;   image but in some cases this value is the number of pixels used to represent
;   a pixel in a monochrome image (value is always 1) or a pixel in a grayscale
;   image (value is usually 8 or less).
;
;   The bits per pixel value can be identified for most image types but it is
;   not always readily available.  To ensure that this function runs as quickly
;   as possible, only image types where the bits per pixel value is readily
;   available in the header or in a easy-to-decrypt first frame of the image are
;   supported.  At this writing only the Bitmap (BMP), Standard Cursor (CUR),
;   Graphics Interchange Format (GIF), Joint Photographic Experts Group (JPEG),
;   Portable Bitmap Format (PBM), PiCture eXchange (PCX), Portable Graymap
;   Format (PGM), Portable Network Graphics (PNG), and Portable Pixmap Format
;   (PPM), Tag Image File Format (TIFF) image types are supported.  Icon (ICO)
;   files are partially supported.  If the icon file contains only one icon, the
;   bit per pixel value is collected.
;
;   If available, the image's bits per pixel value is returned in the r_bpp
;   output variable and in the bpp property of the return object. Otherwise,
;   these values are set to 0.
;
; Exchangeable Image File (EXIF):
;
;   The Exchangeable Image File (EXIF) is not an image format.  It is a
;   standard for embedding technical metadata in image files that many camera
;   manufacturers use and many image-processing programs support.  EXIF metadata
;   can be embedded in JPEG and TIFF images.
;
;   At this writing, this function does not read EXIF data in order to get the
;   image width and height values.  Most JPEG files store image width and height
;   values within specific Start of Frame tags.  See the JPEG section below for
;   more information.
;
;   There are a very small number of JPEG image files that do not have Start of
;   Frame tags but may have EXIF data.  For now, the function will return 0 for
;   the width, height, and bits per pixel values when these files are processed.
;   The function may be modified in the future to look for image width and
;   height values from within the EXIF data in the few files with condition.
;
;   There are a small number of JPEG image files that do not have Start of Frame
;   tags or EXIF data.  This function will return 0 for the width, height and
;   bits per pixel values when these files are processed.  Other image programs
;   are able to identify the image width and height for these files but it
;   likely that that entire image must be loaded in order to determine the image
;   width, height, and bits per pixel.  For now, this function will not load the
;   entire image in order to determine with image width and height but that may
;   change in the future.
;
; GIF:
;
;   For GIF files, the value returned for the Bits Per Pixel value (the r_bpp
;   output variable and the bpp property on the return object) is collected from
;   a 3-bit color resolution field from the Logical Screen Descriptor section of
;   the file.  According to the GIF89a Specification document, "This value
;   represents the size of the entire palette from which the colors in the
;   graphic were selected, not the number of colors actually used in the
;   graphic."  In addition, this value does not affect the way the images are
;   decoded and so the value can be manually changed by the author or anybody
;   for that matter.
;
;   Observation: The Bits Per Pixel value returned by this function for GIF
;   files is often correct but the developer should not depend on the accuracy
;   of the data for this image type.
;
; Icons and Cursors:
;
;   Icon files (.ico) can contain multiple icons with different icon sizes and
;   different image qualities.  In addition, icons can be any size but the file
;   format only allocates 1 byte of space per dimension to identify the size so
;   the maximum size is 255x255.  0x0 usually indicates a 256x256 icon but it
;   could be any size over 255x255.  To resolve these issues, this function uses
;   the following approach.
;
;   If the icon file only has one icon, the size of the only icon is returned.
;   Otherwise, the function uses the *LoadImage* system function to identity and
;   load the default icon and then return the size of that icon.  LoadImage is
;   used because it is fast and it uses a consistent method for determining
;   which icon is the default icon.  This approach is a bit slower than other
;   image types but icon files are relatively small so the time it takes to load
;   and evaluate an icon from an icon file is relatively fast.
;
;   Standard cursors files (.cur) are similar to icon files in that they can
;   contain multiple cursors with different sizes.  However, most cursor files
;   contain one or two cursors and the quality of the images are usually the
;   same.  The *LoadImage* system function always returns the first cursor in
;   the file when no size is specified.  This function uses the same approach
;   and returns the size of the first cursor in the file.
;
;   Animated cursor files (.ani) contain many images but the size of the images
;   are all the same.  The size of the first image in the file is returned.
;
; Joint Photographic Experts Group (JPEG):
;
;   The Joint Photographic Experts Group (JPEG) image format is not the oldest
;   image format but it is probably the most popular, at least for now.  The
;   first version of the JPEG format was released in 1992, the latest version in
;   1994.  The JPEG format supports a large number of encoding formats.  Because
;   of it's popularity, finding JPEG samples is very easy but finding samples
;   that use the more obscure encoding formats can be very difficult if not
;   impossible.  Some of the early encoding formats were abandoned in lieu of
;   newer/better encoding formats.
;
;   This function supports JPEG image files with Start of Frame 0 (0xFFC0), 1
;   (0xFFC1), and 2 (0xFFC2) tags.  The function includes code for a few other
;   tags but they have never been tested because no samples with these tags have
;   been found.  If the JPEG file does not contain any of these tags, the width,
;   height, and bits per pixel fields will be set to 0.
;
;   There are a few files out there that have no Start of Frame tags at all.
;   They do have an Application Segment 0 (0xE0) tag but no Start of Frame
;   flags.  Some image programs will decode application segment flags but
;   technically, these are "application" specific so those programs include
;   extra code to figure out which application program was used to populate the
;   tag and then extract the information from that.  At this time, this function
;   does not try to decode Application Segment tags.  That may change in the
;   future.
;
; PBM, PGM, and PPM:
;
;   The value returned for the r_bpp output variable and the bpp property on the
;   return object depends on the file type.
;
;   For Portable Bitmap Format (PBM) files, the bits per pixel value is always
;   1 since all PBM images are monochrome.
;
;   For Portable Graymap Format (PGM) and Portable Pixmap Format (PPM) files,
;   the bits per pixel value is calculated based on the MaxValue field which for
;   PGM files is the maximum gray value (usually 255) and for PPM files is the
;   maximum color value (usually 255).
;
;   Please note that the calculated bits per pixel value is not necessarily
;   the actual amount of space used on the file to represent each pixel.  The
;   monochrome, grayscale, or color values can be stored as ASCII characters, so
;   the actual amount of space used on the files can be much larger than in the
;   binary version of files.
;
; Supported Image Formats:
;
;   The following image formats are supported: Animated Cursor (ANI), Bitmap
;   (BMP), Standard Cursor (CUR), Exchangeable Image File (Exif), Graphics
;   Interchange Format (GIF), Icon (ICO), Joint Photographic Experts Group
;   (JPEG), Portable Network Graphics (PNG), and Tag Image File Format (TIFF).
;   "Supported" means that most of the documented formats for these image types
;   are supported.  There are several old or deprecated formats from these image
;   types that were purposely excluded.  In most cases, these old formats are
;   not supported by GDI+ and other image programs.
;
;   The following formats are partially supported: Windows Metafile (WMF), and
;   Enhanced MetaFile (EMF).  See the *WMF and EMF* section for more
;   information.
;
; Supported Image Formats, Part 2:
;
;   The image formats included in this section are not supported by AutoHotkey
;   which includes AutoHotkey GUIs, the LoadPicture function, the IL_Add
;   function, etc.
;
;   The following image formats are supported: JPEG extended range (JPEG XR,
;   little-endian only), PiCture eXchange (PCX), Portable Bitmap Format (PBM),
;   Portable Graymap Format (PGM), Portable Pixmap Format (PPM), and WebP (VP8,
;   VP8L, and VP8X). "Supported" means that most of the documented formats for
;   these image types are supported.  There may be old or deprecated formats
;   from these image types that were purposely excluded.  In most cases, these
;   old formats are not supported by other image programs.
;
;   Preliminary support has been added for the Scalable Vector Graphics (SVG)
;   format.  Please note that many SVG files don't have "Width" and "Height"
;   tags.  The rendering engine will fill the space allocated to the image.  In
;   these cases, 0 is returned for the width and height.  Additional testing is
;   needed.
;
; WMF and EMF:
;
;   This function provides limited support for Windows Metafile (WMF), and
;   Enhanced MetaFile (EMF).  Although the most common formats for these image
;   types are supported, not all formats are supported yet.  Since the size of
;   the image from these image types is calculated and can vary depending on the
;   current DPI, the values returned by this function may not be exactly the
;   same as what is returned by other programs in all cases.
;
;   For most WMF files, the return values are usually an exact match to other
;   programs but for a few files, the width and/or height (usually not both)
;   might be 1 pixel larger than from other programs.
;
;   Please note that the original/official WMF file format is not supported by
;   this function.  The original file format does not include size information
;   in the header so it is useless to this function.  The WMF format supported
;   by this function is known as Placeable Metafile and was created by Aldus
;   Corporation as a non-standard way of specifying how a metafile is mapped and
;   scaled on an output device.  Although this format is not officially
;   supported by Windows, it is widely used and some Windows programs,
;   specifically GDI+, support this format.
;
;   For EMF files, 1 pixel is added to each dimension (width and height) so that
;   the return value will match the size returned from GDI+.  This adjustment
;   will ensure that the size matches the value returned from the AutoHotkey
;   LoadPicture command which uses GDI+ for EMF files.  Other image programs
;   (Ex: IrfanView) may show a size that is 1 pixel less for the width and
;   height.
;
;   Although use of WMF and EMF files has waned sharply since they were
;   introduced by Microsoft in the 1990s, they are still in use by various
;   programs.  Support for these formats was specifically included in this
;   function because they are still supported by GDI+ which is used by
;   AutoHotkey.
;
;   The observations and adjustments in this section are based on _very_ limited
;   data.  Real world testing may return different results and additional
;   adjustments may be needed.
;
; Remarks:
;
;   This function identifies and returns the dimensions (width and height) of a
;   image from a stand-alone image file (Ex: MyPhoto.jpg) without loading the
;   image into memory.
;
;   The contents of the file determines the image type, not the file's
;   extension.  For example, JPEG files are usually stored in 6 standard file
;   extensions (.jpg, .jpeg, .jif, etc.) but can also be stored in a
;   non-standard file extension (Ex: .MyPic)  This function will recognize the
;   image format regardless of the file extension.  If unsure, give it a
;   try/see.
;
;   Please note that although a considerable amount of time and effort has been
;   spend developing and testing this function, the testing has been limited to
;   the images files that were available and to a select number of files that
;   were downloaded from the internet.  Because is impossible to test all
;   situations, it is likely that a few issues will pop up after this library is
;   released.  If you find a problem, please report it.
;
; Performance Observations:
;
;   This function was written to get the size of images stored in stand-alone
;   files without loading the entire image into memory.  In theory, this
;   function should be much faster than loading the image because 1) only a
;   small portion of the file is read, 2) there is no need to decompress the
;   image (GIF, TIF, etc.) or render the image (EMF, WMF, etc.)
;
;   File system requests for files on standard hardware (i.e. hard drives) have
;   always been the primary speed bottleneck for most computer operations.  The
;   performance of this function depends on whether the image file has been
;   loaded to the system cache or not.
;
;   If the image file has not been loaded to the system cache, performance
;   varies depending on the size of the image.  For small images, this function
;   does not offer much of a performance improvement over loading the image from
;   the file and then determining the size of the image.  For larger image
;   files, the performance gap is wider but not as much as you would think.  For
;   very large image files or if the image is compressed, this function is
;   significantly faster than loading the entire image.
;
;   If the image file has been loaded to the system cache, the performance
;   improvement can be very significant, even for small images.  In these cases,
;   this function can be anywhere from 2 to 40 times faster (or more) than
;   loading the entire image.  For compressed images or images that must be
;   rendered, this function can be more than 50 times faster in some cases.
;   Your results will vary.
;
;-------------------------------------------------------------------------------
IMG_GetImageSize(p_FileOrHandle,ByRef r_Width:=0,ByRef r_Height:=0,ByRef r_bpp:=0)
    {
    Static Dummy27649730

          ;-- Image types
          ,IMAGE_ICON:=1

          ;-- LoadImage flags
          ,LR_LOADFROMFILE:=0x10

          ;-- Object types
          ,OBJ_BITMAP:=7

          ;-- Seek origin
          ,SEEK_SET:=0
                ;-- Seek from the beginning of the file.
          ,SEEK_CUR:=1
                ;-- Seek from the current position of the file pointer.
          ,SEEK_END:=2
                ;-- Seek from the end of the file.  The distance should usually
                ;   be a negative value.

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    r_Width:=r_Height:=r_bpp:=0

    ;[===========]
    ;[  Handle?  ]
    ;[===========]
    if p_FileOrHandle is Integer
        {
        if (DllCall("GetObjectType","UPtr",p_FileOrHandle)=OBJ_BITMAP)
            IMG_GetBitmapSize(p_FileOrHandle,r_Width,r_Height,r_bpp)
         else  ;-- Assume icon or cursor
            IMG_GetIconSize(p_FileOrHandle,r_Width,r_Height)

        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[========]
    ;[  Open  ]
    ;[========]
    if not File:=FileOpen(p_FileOrHandle,"r","CP0")
        {
        l_Message:=IMG_SystemMessage(A_LastError)
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Unexpected return code from FileOpen function.
            A_LastError=%A_LastError% - %l_Message%
            File: %p_FileOrHandle%
           )

        Return False
        }

    ;-- Bounce if the file is not at least 25 bytes
    if (File.Length<25)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            The file is too small to contain an image.
            File: %p_FileOrHandle%
           )

        File.Close()
        Return False
        }

    ;-- Read (up to) the first 25 bytes
    VarSetCapacity(FileData,25,0)
    File.RawRead(FileData,25)

    ;-- Convert the first 25 bytes to a string (Encoding=ANSI)
    ;
    ;   This step allows some of the first 25 bytes to be evaluated as a string
    ;   of characters instead of having to evaluate each byte as a number.
    ;
    ;   The StrGet command will automatically stop converting data when a null
    ;   character is found so if the first 25 bytes includes dynamic data or a
    ;   null character, it is possible that not all 25 characters will make it
    ;   to the FileString variable.  Hint: With the exception of text files, it
    ;   is only safe to use the leading characters in this string.  If there are
    ;   any non-static or null characters after the initial characters, it's
    ;   best to reconvert the characters after the gap if needed.  Ex:
    ;   NewString:=StrGet(&FileData+12,4,"CP0")
    ;
    FileString:=StrGet(&FileData,25,"CP0")

    ;[===================]
    ;[  Animated Cursor  ]
    ;[===================]
    ;-- https://www.gdgsoft.com/anituner/help/aniformat.htm
    ;-- https://en.wikipedia.org/wiki/ANI_(file_format)
    ;-- https://en.wikipedia.org/wiki/Resource_Interchange_File_Format
    if (SubStr(FileString,1,4)="RIFF" and StrGet(&FileData+8,4,"CP0")="ACON")
        {
        FilePos:=12
        File.Seek(FilePos,SEEK_SET)
        VarSetCapacity(Chunk,4,0)
        VarSetCapacity(LISTType,8,0)
        Loop 6  ;-- Limit to the first 6 ACON chunks
            {
            ;-- Get the next chunk string
            File.RawRead(Chunk,4)
            FilePos+=4
            ChunkString:=StrGet(&Chunk,4,"CP0")

            ;-- Get the length of the chunk data
            ChunkDataLength:=File.ReadUInt()
            FilePos+=4

            ;-- Add 1 to ChunkDataLength if it is an odd number (rare)
            if ChunkDataLength & 0x1
                ChunkDataLength+=1

            if (ChunkString="LIST")
                {
                File.RawRead(LISTType,8)
                LISTType:=StrGet(&LISTType,8,"CP0")
                if (LISTType="framicon")
                    {
                    File.Seek(10,SEEK_CUR)
                    r_Width :=File.ReadUChar()
                    r_Height:=File.ReadUChar()
                    Break
                    }
                }

            ;-- Position past the chunk data
            FilePos+=ChunkDataLength
            File.Seek(FilePos,SEEK_SET)
            }

        ;-- Assume that we found what we were looking for (for now)
        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[==========]
    ;[  Bitmap  ]
    ;[==========]
    ;-- https://en.wikipedia.org/wiki/BMP_file_format
    if (SubStr(FileString,1,2)="BM")
        {
        DIBHeaderSize:=NumGet(FileData,14,"UInt")
        if (DIBHeaderSize=12) ;-- BITMAPCOREHEADER (Windows 2.0+)
            {
            r_Width :=NumGet(FileData,18,"UShort")
            r_Height:=NumGet(FileData,20,"UShort")
            r_bpp   :=NumGet(FileData,24,"UShort")
            }
         else  ;-- everything else
            {
            r_Width :=NumGet(FileData,18,"Int")
            r_Height:=Abs(NumGet(FileData,22,"Int"))

            File.Seek(28,SEEK_SET)
            r_bpp:=File.ReadUShort()
            }

        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[==========]
    ;[  Cursor  ]
    ;[==========]
    ;-- https://en.wikipedia.org/wiki/ICO_(file_format)
    if (NumGet(FileData,0,"UInt")=0x00020000)  ;-- First 4 bytes
        {
        FilePos:=NumGet(FileData,18,"UInt")             ;-- dwImageOffset
        File.Seek(FilePos,SEEK_SET)
        Size          :=File.ReadUInt()                 ;-- biSize

        if (Size=40)
            {
            ;-- BITMAPINFOHEADER structure
            r_Width :=File.ReadInt()                    ;-- biWidth
            r_Height:=File.ReadInt()//2                 ;-- biHeight
            Planes  :=File.ReadUShort()                 ;-- biPlanes (not used)
            r_bpp   :=File.ReadUShort()                 ;-- biBitCount
            }
         else  ;-- assume (for now) PNG
            {
            ;-- PNG
            ;   Note: The PNG format is rarely (never?) used for cursors.  OK,
            ;   I've never seen it.  It is probably because cursor bitmaps are
            ;   very small (usually 48x48 or smaller) and size/compression is
            ;   not an issue.  Although this section has never been tested
            ;   (need a sample), this code remains jic a cursor with a PNG
            ;   image shows up IRL.
            FilePos:=NumGet(FileData,18,"UInt")         ;-- dwImageOffset
            File.Seek(FilePos+16,SEEK_SET)
            r_Width  :=IMG_ByteSwap(File.ReadUInt())
            r_Height :=IMG_ByteSwap(File.ReadUInt())
            BitDepth :=File.ReadUChar()
            ColorType:=File.ReadUChar()

            ;-- Convert BitDepth to bits per pixel
            if (ColorType=2)        ;-- Each pixel value is an R,G,B series
                r_bpp:=BitDepth*3
             else if (ColorType=6)  ;-- Each pixel value is an R,G,B,A series
                r_bpp:=BitDepth*4
             else
                r_bpp:=BitDepth
            }

        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[=======]
    ;[  EMF  ]
    ;[=======]
    ;-- http://wvware.sourceforge.net/caolan/ora-wmf.html
    if (NumGet(FileData,0,"UInt")=0x1)  ;-- First 4 bytes
        {
        ;-- Get the frame size (measured in 0.01 millimeter units)
        File.Seek(24,SEEK_SET)
        FrameLeft  :=File.ReadInt()
        FrameTop   :=File.ReadInt()
        FrameRight :=File.ReadInt()
        FrameBottom:=File.ReadInt()
        FrameWidth :=FrameRight-FrameLeft
        FrameHeight:=FrameBottom-FrameTop

        ;-- Get the reference device sizes (in pixels and in millimeters)
        File.Seek(72,SEEK_SET)
        WidthDevPixels :=File.ReadInt()
        HeightDevPixels:=File.ReadInt()
        WidthDevMM     :=File.ReadInt()
        HeightDevMM    :=File.ReadInt()

        ;-- Calculate the size
        r_Width :=1+Round(WidthDevPixels*(FrameWidth/100/WidthDevMM))
        r_Height:=1+Round(HeightDevPixels*(FrameHeight/100/HeightDevMM))
        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[=======]
    ;[  GIF  ]
    ;[=======]
    ;-- https://en.wikipedia.org/wiki/GIF
    ;-- https://www.fileformat.info/format/gif/egff.htm
    ;-- http://fileformats.archiveteam.org/wiki/GIF
    ;-- https://www.w3.org/Graphics/GIF/spec-gif87.txt
    ;-- https://www.w3.org/Graphics/GIF/spec-gif89a.txt
     if (SubStr(FileString,1,3)="GIF"
    and  SubStr(FileString,4,3)="89a" or SubStr(FileString,4,3)="87a")
        {
        r_Width :=NumGet(FileData,6,"UShort")
        r_Height:=NumGet(FileData,8,"UShort")
        r_bpp   :=(NumGet(FileData,10,"UChar")>>4&0x7)+1
        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[=========]
    ;[   Icon  ]
    ;[=========]
    ;-- https://en.wikipedia.org/wiki/ICO_(file_format)
    if (NumGet(FileData,0,"UInt")=0x00010000)  ;-- First 4 bytes
        {
        NbrOfImages:=NumGet(FileData,4,"UShort")        ;-- idCount

        ;-- Only one icon in the file?
        if (NbrOfImages=1)
            {
            FilePos:=NumGet(FileData,18,"UInt")         ;-- dwImageOffset
            File.Seek(FilePos,SEEK_SET)
            Size          :=File.ReadUInt()             ;-- biSize

            if (Size=40)  ;-- size of BITMAPINFOHEADER structure
                {
                ;-- BITMAPINFOHEADER structure
                r_Width :=File.ReadInt()                ;-- biWidth
                r_Height:=File.ReadInt()//2             ;-- biHeight
                                File.ReadUShort()       ;-- biPlanes (not used)
                r_bpp   :=File.ReadUShort()             ;-- biBitCount
                }
             else
                {
                ;-- PNG
                FilePos:=NumGet(FileData,18,"UInt")     ;-- dwImageOffset
                File.Seek(FilePos+16,SEEK_SET)
                r_Width  :=IMG_ByteSwap(File.ReadUInt())
                r_Height :=IMG_ByteSwap(File.ReadUInt())
                BitDepth :=File.ReadUChar()
                ColorType:=File.ReadUChar()

                ;-- Convert BitDepth to bits per pixel
                if (ColorType=2)        ;-- Each pixel value is an R,G,B series
                    r_bpp:=BitDepth*3
                 else if (ColorType=6)  ;-- Each pixel value is an R,G,B,A series
                    r_bpp:=BitDepth*4
                 else
                    r_bpp:=BitDepth
                }

            File.Close()
            Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
            }

        ;-- Everything else, i.e. 2 or more icons in the file

        ;-- Close the file
        ;   Note: This is performed here because the LoadImage system function
        ;   needs to open the file in the following statements.
        File.Close()

        ;-- Use LoadImage to determine the default icon size
        hIcon:=DllCall("LoadImage"
            ,"UPtr",0                               ;-- hinst
            ,"Str",p_FileOrHandle                   ;-- lpszName
            ,"UInt",IMAGE_ICON                      ;-- uType
            ,"Int",0                                ;-- cxDesired
            ,"Int",0                                ;-- cyDesired
            ,"UInt",LR_LOADFROMFILE)                ;-- fuLoad

        if hIcon
            {
            IMG_GetIconSize(hIcon,r_Width,r_Height)
            DllCall("DestroyIcon","UPtr",hIcon)
            }

        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[========]
    ;[  JPEG  ]
    ;[========]
    ;-- https://en.wikipedia.org/wiki/JPEG
    ;-- https://en.wikipedia.org/wiki/JPEG_File_Interchange_Format
    ;-- https://www.disktuna.com/list-of-jpeg-markers/
    if (NumGet(FileData,0,"UShort")=0xD8FF and NumGet(FileData,2,"UChar")=0xFF)
        {
        ;-- Loop through the tags
        FilePos:=2
        File.Seek(FilePos,SEEK_SET)
        ThisByte:=File.ReadUChar()

        While (ThisByte=0xFF)
            {
            ;-- Get the next byte
            ThisByte:=File.ReadUChar()

            ;-- Start of Frame tags, i.e. 0xC0, 0xC1, 0xC2, 0xC3, and 0xF7
            ;   Note: Samples for 0xC3 (195) and 0xF7 (247) not found (yet)
            if ThisByte in 192,193,194,195,247
                {
                ;-- ##### Begin temporary
                if ThisByte not in 192,193,194  ;-- Not 0xC0, 0xC1, or 0xC2
                    outputdebug % "##### Found image with odd/untested tag!: "
                        . Format("0x{:X}",ThisByte)
                        . ", File: " . p_FileOrHandle
                ;-- ##### End temporary

                File.Seek(2,SEEK_CUR)
                DataPrecision     :=File.ReadUChar()
                r_Height          :=IMG_ByteSwap(File.ReadUShort(),"UShort")
                r_Width           :=IMG_ByteSwap(File.ReadUShort(),"UShort")
                NumberOfComponents:=File.ReadUChar()
                r_bpp    :=DataPrecision*NumberOfComponents
                File.Close()
                Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
                }

            ;-- Set the position for the next tag
            BlockSize:=IMG_ByteSwap(File.ReadUShort(),"UShort")
            FilePos+=BlockSize+2
            File.Seek(FilePos,SEEK_SET)
            ThisByte:=File.ReadUChar()
            }

        ;-- No usable Start of Frame tags found.  Close and bounce.
        File.Close()
        Return False
        }

    ;[===================]
    ;[      JPEG XR      ]
    ;[    HDP/JXR/WDP    ]
    ;[  (Little Endian)  ]
    ;[===================]
    ;-- http://paulbourke.net/dataformats/tiff/tiff_summary.pdf
    ;-- https://www.loc.gov/preservation/digital/formats/content/tiff_tags.shtml
    if (NumGet(FileData,0,"UInt")=0x01BC4949)  ;-- 01=Version 1 (##### may need to add Version 0 later)
        {

        ;-- Get the offset of the first Image File Directory (IFD)
        FilePos:=4
        File.Seek(FilePos,SEEK_SET)
        IFDOffset:=File.ReadUInt()

        ;-- Collect the number of tags in the first IFD
        FilePos:=IFDOffset
        File.Seek(FilePos,SEEK_SET)
        IFDTagCount:=File.ReadUShort()

        ;-- Update the file position
        FilePos:=File.Position

        ;-- Loop through the Image File Directory
        ;   Note: Only the Width and Height tags are used (for now)
        Loop %IFDTagCount%
            {
            TagID:=File.ReadUShort()

            ;-- Image width
            if (TagID=0xBC80)  ;-- 48256
                {
                DataType :=File.ReadUShort()
                DataCount:=File.ReadUInt()  ;-- Always 1 for this tag
                r_Width:=DataType=3 ? File.ReadUShort():File.ReadUInt()
                }

            ;-- Image height
            if (TagID=0xBC81)  ;-- 48257
                {
                DataType :=File.ReadUShort()
                DataCount:=File.ReadUInt()  ;-- Always 1 for this tag
                r_Height:=DataType=3 ? File.ReadUShort():File.ReadUInt()
                }

            ;-- Set the file position for the next tag
            ;   Note: Each tag is 12 bytes.  The file position is set on
            ;   every iteration so that regardless of what file activity is
            ;   performed in the loop, the file will be positioned correctly
            ;   for the next tag.
            FilePos+=12
            File.Seek(FilePos,SEEK_SET)
            }

        ;-- For now, assume that we found what we were looking for
        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[=======]
    ;[  PBM  ]
    ;[  PGM  ]
    ;[  PPM  ]
    ;[=======]
    ;-- http://netpbm.sourceforge.net/doc/pbm.html
    ;-- http://netpbm.sourceforge.net/doc/pgm.html
    ;-- http://netpbm.sourceforge.net/doc/ppm.html
     if (SubStr(FileString,1,1)="P"
    and (SubStr(FileString,2,1)="1"     ;-- PBM
     or  SubStr(FileString,2,1)="2"     ;-- PGM
     or  SubStr(FileString,2,1)="3"     ;-- PPM
     or  SubStr(FileString,2,1)="4"     ;-- PBM
     or  SubStr(FileString,2,1)="5"     ;-- PGM
     or  SubStr(FileString,2,1)="6"))   ;-- PPM
        {
        MagicNumber:=SubStr(FileString,1,2)

        ;-- Read up to the first 1K characters
        File.Seek(0,SEEK_SET)
        P0MString:=File.Read(1024)

        ;-- Extract values
        HeaderArray:=Array()
        HeaderArray.SetCapacity(4)
        Loop Parse,P0MString,`n,`r
            {
            Loop Parse,A_LoopField,%A_Space%`t
                {
                if A_LoopField is Space  ;-- Only whitespace characters
                    Continue

                if (SubStr(A_LoopField,1,1)="#")
                    Break

                HeaderArray.Push(A_LoopField)
                if (HeaderArray.Count()>=4)
                    Break
                }

            if MagicNumber in P1,P4  ;-- PBM
                if (HeaderArray.Count()>=3)
                    Break
             else
                if (HeaderArray.Count()>=4)
                    Break
            }

        r_Width :=HeaderArray[2]
        r_Height:=HeaderArray[3]

        ;-- Determine bits per pixel
        if MagicNumber in P1,P4  ;-- PBM
            r_bpp:=1
         else
            {
            if MaxValue:=HeaderArray[4]  ;-- Any non-zero value
                if MagicNumber in P2,P5  ;-- PGM
                    r_bpp:=Floor((Log(MaxValue)/Log(2))+1)
                 else  ;-- PPM
                    r_bpp:=Floor((Log(MaxValue**3)/Log(2))+1)
            }

        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[=======]
    ;[  PCX  ]
    ;[=======]
    ;-- https://www.fileformat.info/format/pcx/egff.htm
    if (NumGet(FileData,0,"UChar")=0x0A and NumGet(FileData,1,"UChar")<=0x5)
        {
        r_bpp   :=NumGet(FileData,3,"UChar")
        XStart  :=NumGet(FileData,4,"UShort")
        YStart  :=NumGet(FileData,6,"UShort")
        XEnd    :=NumGet(FileData,8,"UShort")
        YEnd    :=NumGet(FileData,10,"UShort")
        r_Width :=XEnd-XStart+1
        r_Height:=YEnd-YStart+1
        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[=======]
    ;[  PNG  ]
    ;[=======]
    ;-- https://en.wikipedia.org/wiki/Portable_Network_Graphics
    ;-- http://www.fileformat.info/format/png/corion.htm
    if (NumGet(FileData,0,"UInt64")=0x0A1A0A0D474E5089  ;-- 89 50 4e 47 0d 0a 1a 0a
   and  StrGet(&FileData+12,4,"CP0")="IHDR")
        {
        FilePos:=16
        File.Seek(FilePos,SEEK_SET)
        r_Width  :=IMG_ByteSwap(File.ReadUInt())
        r_Height :=IMG_ByteSwap(File.ReadUInt())
        BitDepth :=File.ReadUChar()
        ColorType:=File.ReadUChar()

        ;-- Convert BitDepth to bits per pixel
        if (ColorType=2)        ;-- Each pixel value is an R,G,B series
            r_bpp:=BitDepth*3
         else if (ColorType=6)  ;-- Each pixel value is an R,G,B,A series
            r_bpp:=BitDepth*4
         else
            r_bpp:=BitDepth

        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[=======]
    ;[  SVG  ]
    ;[=======]
    ;-- https://en.wikipedia.org/wiki/Scalable_Vector_Graphics
    /*
        This only works if the character encoding for the file is ASCII, ANSI,
        UTF-8, or any other compatible single-byte character encoding system
        where the first printable characters are the same as ASCII.  Anything
        else (Ex: UTF-16) and the function won't find usable information.  There
        is close to a 100% chance that SVG files are encoded using a compatible
        character encoding system so the function should get what is needed in
        most cases.  Adding code to deal with the rare exceptions will reduce
        the efficiency of this function.
    */
    if InStr(FileString,"<?xml") or InStr(FileString,"<svg")  ;-- Within the first 25 bytes
        {
        ;-- Possible SVG.  We need to look further to be sure.
        ;-- Read up to the first 1.5K characters
        File.Seek(0,SEEK_SET)
        SVGString:=File.Read(1536)

        ;-- Look for the SVG tag
        if SVGPos:=InStr(SVGString,"<svg")
            {
            SVGPos+=4
            if FoundPos1:=InStr(SVGString,"width=",False,SVGPos)
                {
                FoundPos1+=7
                FoundPos2:=InStr(SVGString,"""",False,FoundPos1)
                r_Width:=Floor(SubStr(SVGString,FoundPos1,FoundPos2-FoundPos1))
                }

            if FoundPos1:=InStr(SVGString,"height=",False,SVGPos)
                {
                FoundPos1+=8
                FoundPos2:=InStr(SVGString,"""",False,FoundPos1)
                r_Height:=Floor(SubStr(SVGString,FoundPos1,FoundPos2-FoundPos1))
                }

            if r_Width and r_Height
                {
                File.Close()
                Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
                }
            }

        ;-- At this point, we did not find a SVG tag or did not find Width AND
        ;   Height.   Reset the output variables and bounce.  Since this is the
        ;   only XML image format (for now), it's OK to bounce here.
        r_Width:=r_Height:=0
        File.Close()
        Return False
        }

    ;[===================]
    ;[        TIFF       ]
    ;[  (Little Endian)  ]
    ;[===================]
    ;-- http://paulbourke.net/dataformats/tiff/tiff_summary.pdf
     if (SubStr(FileString,1,2)="II"
    and  NumGet(FileData,2,"UShort")=42)  ;-- TIFF version
        {
        ;-- Get the offset of the first Image File Directory (IFD)
        FilePos:=4
        File.Seek(FilePos,SEEK_SET)
        IFDOffset:=File.ReadUInt()

        ;-- Collect the number of tags in the first IFD
        FilePos:=IFDOffset
        File.Seek(FilePos,SEEK_SET)
        IFDTagCount:=File.ReadUShort()

        ;-- Update the file position
        FilePos:=File.Position

        ;-- Loop through the Image File Directory
        ;   Note: Only the Width and Height tags are used (for now)
        Loop %IFDTagCount%
            {
            TagID:=File.ReadUShort()

            ;-- Image Width
            if (TagID=0x100)
                {
                DataType :=File.ReadUShort()
                DataCount:=File.ReadUInt()  ;-- Always 1 for this tag
                r_Width:=DataType=3 ? File.ReadUShort():File.ReadUInt()
                }

            ;-- Image Height
            if (TagID=0x101)
                {
                DataType :=File.ReadUShort()
                DataCount:=File.ReadUInt()  ;-- Always 1 for this tag
                r_Height:=DataType=3 ? File.ReadUShort():File.ReadUInt()
                }

            ;-- Bits Per Sample
            if (TagID=0x102)
                {
                DataType :=File.ReadUShort()
                DataCount:=File.ReadUInt()
                if (DataCount=1)
                    r_bpp:=File.ReadUShort()
                 else
                    {
                    DataOffset:=File.ReadUInt()
                    File.Seek(DataOffset,SEEK_SET)
                    r_bpp:=File.ReadUShort()
                    }
                }

            ;-- Set the file position for the next tag
            ;   Note: Each tag is 12 bytes.  The file position is set on
            ;   every iteration so that regardless of what file activity is
            ;   performed in the loop, the file will be positioned correctly
            ;   for the next tag.
            FilePos+=12
            File.Seek(FilePos,SEEK_SET)
            }

        ;-- Assume that we found what we were looking for (for now)
        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[================]
    ;[      TIFF      ]
    ;[  (Big Endian)  ]
    ;[================]
    ;-- http://paulbourke.net/dataformats/tiff/tiff_summary.pdf
     if (SubStr(FileString,1,2)="MM"
    and  IMG_ByteSwap(NumGet(FileData,2,"UShort"),"UShort")=42)  ;-- TIFF version
        {
        ;-- Get the offset of the first Image File Directory (IFD)
        FilePos:=4
        File.Seek(FilePos,SEEK_SET)
        IFDOffset:=IMG_ByteSwap(File.ReadUInt())

        ;-- Collect the number of tags in the first IFD
        FilePos:=IFDOffset
        File.Seek(FilePos,SEEK_SET)
        IFDTagCount:=IMG_ByteSwap(File.ReadUShort(),"UShort")

        ;-- Update the file position
        FilePos:=File.Position

        ;-- Loop through the Image File Directory
        ;   Note: Only the Width and Height tags are used (for now)
        Loop %IFDTagCount%
            {
            TagID:=IMG_ByteSwap(File.ReadUShort(),"UShort")

            ;-- Image width
            if (TagID=0x100)
                {
                DataType :=IMG_ByteSwap(File.ReadUShort(),"UShort")
                DataCount:=IMG_ByteSwap(File.ReadUInt())  ;-- Always 1 for this tag
                r_Width:=DataType=3 ? IMG_ByteSwap(File.ReadUShort(),"UShort"):IMG_ByteSwap(File.ReadUInt())
                }

            ;-- Image Height
            if (TagID=0x101)
                {
                DataType :=IMG_ByteSwap(File.ReadUShort(),"UShort")
                DataCount:=IMG_ByteSwap(File.ReadUInt())  ;-- Always 1 for this tag
                r_Height:=DataType=3 ? IMG_ByteSwap(File.ReadUShort(),"UShort"):IMG_ByteSwap(File.ReadUInt())
                }

            ;-- Bits Per Sample
            if (TagID=0x102)
                {
                DataType :=IMG_ByteSwap(File.ReadUShort(),"UShort")
                DataCount:=IMG_ByteSwap(File.ReadUInt())
                if (DataCount=1)
                    r_bpp:=IMG_ByteSwap(File.ReadUShort(),"UShort")
                 else
                    {
                    DataOffset:=IMG_ByteSwap(File.ReadUInt())
                    File.Seek(DataOffset,SEEK_SET)
                    r_bpp:=IMG_ByteSwap(File.ReadUShort(),"UShort")
                    }
                }

            ;-- Set the file position for the next tag
            ;   Note: Each tag is 12 bytes.  The file position is set on
            ;   every iteration so that regardless of what file activity is
            ;   performed in the loop, the file will be positioned correctly
            ;   for the next tag.
            FilePos+=12
            File.Seek(FilePos,SEEK_SET)
            }

        ;-- For now, assume that we found what we were looking for
        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;[========]
    ;[  WebP  ]
    ;[========]
    if (SubStr(FileString,1,4)="RIFF" and StrGet(&FileData+8,4,"CP0")="WEBP")
        {
        ImageSizeFound:=False
        VP8Format:=StrGet(&FileData+12,4,"CP0")
        if (VP8Format="VP8 ")
            {
            ;-- https://wiki.tcl-lang.org/page/Reading+WEBP+image+dimensions
            ;-- https://tools.ietf.org/html/rfc6386#page-30

            ;-- Check for a valid code block identifier
            File.Seek(23,SEEK_SET)
             if (File.ReadUChar()=0x9D
            and  File.ReadUChar()=0x01
            and  File.ReadUChar()=0x2A)
                {
                ;-- File position is now at offset 26

                ;-- Collect the width and height
                ;   Note: Each size field is stored in a 16-bit space but only
                ;   14-bits are used.  Since the program reads a UShort value
                ;   (16-bit unsigned integer), the 2 high bits are truncated to
                ;   ensure that correct value is returned.
                r_Width :=File.ReadUShort()&0x3FFF
                r_Height:=File.ReadUShort()&0x3FFF
                ImageSizeFound:=True
                }
             else
                outputdebug Missing start code block!
            }
        else if (VP8Format="VP8L")
            {
            ;-- https://wiki.tcl-lang.org/page/Reading+WEBP+image+dimensions
            File.Seek(16,SEEK_SET)
            Size     :=File.ReadUInt()  ;-- Not used (yet)
            Signature:=File.ReadUChar() ;-- Not used (yet)

            b0:=File.ReadUChar()
            b1:=File.ReadUChar()
            b2:=File.ReadUChar()
            b3:=File.ReadUChar()
            r_width :=1+(((b1&0x3F)<<8)|b0)
            r_Height:=1+(((b3&0xF)<<10)|(b2<<2)|((b1&0xC0)>>6))
            ImageSizeFound:=True
            }
        else if (VP8Format="VP8X")
            {
            ;-- https://github.com/webmproject/webp-wic-codec/blob/master/src/libwebp/dec/webp.c
            File.Seek(24,SEEK_SET)
            b0:=File.ReadUChar()
            b1:=File.ReadUChar()
            b2:=File.ReadUChar()
            r_width:=1+(b2<<16|b1<<8|b0)

            b0:=File.ReadUChar()
            b1:=File.ReadUChar()
            b2:=File.ReadUChar()
            r_Height:=1+(b2<<16|b1<<8|b0)
            ImageSizeFound:=True
            }
        else
            outputdebug % "WebP format not supported: " . VP8Format

        File.Close()
        Return ImageSizeFound ? {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}:False
        }

    ;[=============================]
    ;[             WMF             ]
    ;[  Aldus Placeable Metafiles  ]
    ;[        (D7 CD C6 9A)        ]
    ;[=============================]
    ;-- http://wvware.sourceforge.net/caolan/ora-wmf.html
    if (NumGet(FileData,0,"UInt")=0x9AC6CDD7)  ;-- First 4 bytes
        {
        Left  :=NumGet(FileData,6,"Short")
        Top   :=NumGet(FileData,8,"Short")
        Right :=NumGet(FileData,10,"Short")
        Bottom:=NumGet(FileData,12,"Short")
        Inch  :=NumGet(FileData,14,"UShort")
            ;-- The number of metafile units per inch

        ;-- Calculate and return size
        r_Width :=Round((Right-Left)/Inch*A_ScreenDPI)
        r_Height:=Round((Bottom-Top)/Inch*A_ScreenDPI)
        File.Close()
        Return {Width:r_Width,Height:r_Height,bpp:r_bpp,SizeStr:r_Width . "x" . r_Height}
        }

    ;-- Shut it down
    ;   Note: If we get to this point, the file does not contain a recognized
    ;   image type.
    File.Close()
    Return False
    }

;------------------------------
;
; Function: IMG_SystemMessage
;
; Description:
;
;   Convert a system message number into a readable message.
;
; Type:
;
;   Internal function.  Subject to change.
;
;-------------------------------------------------------------------------------
IMG_SystemMessage(p_MessageNbr)
    {
    Static FORMAT_MESSAGE_FROM_SYSTEM:=0x1000

    ;-- Convert system message number into a readable message
    VarSetCapacity(l_Message,1024*(A_IsUnicode ? 2:1))
    DllCall("FormatMessage"
           ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM           ;-- dwFlags
           ,"UPtr",0                                    ;-- lpSource
           ,"UInt",p_MessageNbr                         ;-- dwMessageId
           ,"UInt",0                                    ;-- dwLanguageId
           ,"Str",l_Message                             ;-- lpBuffer
           ,"UInt",1024                                 ;-- nSize (in TCHARS)
           ,"UPtr",0)                                   ;-- *Arguments

    ;-- If set, remove the trailing CR+LF characters
    if (SubStr(l_Message,-1)="`r`n")
        StringTrimRight l_Message,l_Message,2

    ;-- Return system message
    Return l_Message
    }
