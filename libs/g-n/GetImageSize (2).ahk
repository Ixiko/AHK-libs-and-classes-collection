/*
#NoEnv
#SingleInstance Force
ListLines Off
SetBatchLines 250ms  ;-- To start

;-- Initialize
MaxFiles :=2000
FileCount:=0
ArrayOfFiles:=Array()
ArrayOfFile.SetCapacity(MaxFiles)

SplashImage,,w200 B2,,Finding files...
Sleep 1

;;;;;Loop Files,%A_ScriptDir%\_Example Files\ani\*.ani,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\bmp\*.bmp,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\cur\*.cur,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\emf\*.emf,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\gif\*.gif,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\ico\*.ico,R
Loop Files,%A_ScriptDir%\_Example Files\jpg\*.jpg,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\pcx\*.pcx,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\png\*.png,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\svg\*.svg,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\tif\*.tif,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\wdp\*.wdp,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\webp\*.webp,R
;;;;;Loop Files,%A_ScriptDir%\_Example Files\wmf\*.wmf,R
;;;;;Loop Files,C:\*.jpg,R
    {
    FileCount++
    ArrayOfFiles.Push(A_LoopFileLongPath)
    }
Until (FileCount>=MaxFiles)


BuildGUI:

;-- Build GUI
gui -DPIScale  ; +hWndhGUI +Resize
gui Add,ListView,w1000 r22 Count%MaxFiles%,Files|Width|Height

;-- Get image length and load ListView
SplashImage,,w400 B2,,Getting size and loading ListView...
Sleep 1

SetBatchLines -1  ;-- Full speed
StartTime:=A_TickCount
For Key,File in ArrayOfFiles
    {
    IMG_GetImageSize(File,Width,Height)
    LV_Add("",File,Width,Height)
    }

ElapsedTime:=A_TickCount-StartTime

;;;;;outputdebug FileCount: %FileCount%

LV_ModifyCol(1,800)
LV_ModifyCol(2,"80 Integer")
LV_ModifyCol(3,"80 Integer")

gui Add,Text,xm,File Count: %FileCount%
gui Add,Text,xm,Elapsed Time: %ElapsedTime% ms

;-- After
gui Add,Text,xm w500,
   (ltrim join`s
   Press the "Test Again" button to recollect the image size information.  This
   test will be performed on the current list of files.  The program will not
   search for files again.
   )

gui Add,Button,xm y+1     gRetest,%A_Space% Test Again %A_Space%
gui Add,Button,xm Default gReload,%A_Space% Rebuild example... %A_Space%

;-- Show it
SplashImage Off
gui Show

;-- Restore default priority
SetBatchLines 10ms
return


GUIEscape:
GUIClose:
ExitApp


Reload:
Reload
return


Retest:
gui Destroy
gosub BuildGUI
return
*/

;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
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
;   p_DPI - [Possible Future] For the few image formats that use the current DPI
;       to calculate the image size, this parameter allows the developer the
;       option to specify the DPI that will be used to calculate the image size.
;       If not specified or null (the default), the value from A_ScreenDPI will
;       be used.
;
;   p_Options - [Possible Future] Options that determine TBD stuff.
;
; Returns:
;
;   An object (tests as TRUE) if successful, otherwise FALSE.  If returned, the
;   object contains the following properties:
;
;   Width, Height - The width and height of the image.
;
; Credit:
;
;   This function is a hodgepodge of code, examples, and specifications
;   extracted from the internet.  The idea and the first large hunk of code was
;   adapted from Python and Rust code published by Paulo Scardine.  For the
;   rest, there are too many other sources to credit here.  A few of the sources
;   have been lost.  Most of the sources are posted within the function.  There
;   are probably many alternate sources for this information.
;
; Calls To Other Functions:
;
; * <IMG_ByteSwap>
; * <IMG_GetBitmapSize>
; * <IMG_GetIconSize>
; * <IMG_SystemMessage>
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
;   If the icon file only has one icon and the icon size is less than 256x256,
;   the size of the only icon is returned.  Otherwise, the function uses the
;   LoadImage system function to identity and load the default (or only) icon
;   and then return the size of that icon.  LoadImage is used because it's fast
;   and it uses a consistent method for determining which icon is the default
;   icon.  This approach is slower than other image types but icon files are
;   relatively small and the image size is usually 256x256 or less so the time
;   it takes to load and evaluate an icon from an icon file is relatively fast.
;
;   Standard cursors files (.cur) are similar to icon files in that they can
;   contain multiple cursors with different sizes.  However, most cursor files
;   contain two cursors at the most and the quality of the images are the same.
;   The LoadImage system function always returns the first cursor in the file
;   when no size is specified.  This function uses the same approach and returns
;   the size of the first cursor in the file.
;
;   Animated cursor files (.ani) contain many images but the size of the images
;   are all the same.  The size of the first image in the file is returned.
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
;   For EMF files, 1 pixel is added to each dimension (width and height) so that
;   the return value will match the size returned from GDI+.  This adjustment
;   will ensure that the size matches the value returned from the AutoHotkey
;   LoadPicture command which appears to use GDI+ for EMF files.  Other programs
;   (Ex: IrfanView) may show a size that is 1 pixel less for the width and
;   height.
;
;   Please note that these observations and adjustments are based on _very_
;   limited data.  Real world testing may return different results and
;   additional adjustments may be needed.
;
;   Although use of WMF and EMF files has waned sharply since they were
;   introduced by Microsoft in the 1990s, they are still in use by various
;   programs.  Support for these formats was specifically included in this
;   function because they are still supported by GDI+ which is used by
;   AutoHotkey.
;
; Remarks:
;
;   ##### UC/Experimental
;   ##### Pre-Beta
;   ##### Testing
;
;   ##### Formats UC
;   Scalable Vector Graphics (.svg)
;
;   The following image formats are supported: Animated Cursor (ANI), Bitmap
;   (BMP), Standard Cursor (CUR), Exchangeable Image File (Exif), Graphics
;   Interchange Format (GIF), Icons (ICO), Joint Photographic Experts Group
;   (JPEG), JPEG extended range (JPEG XR), PiCture eXchange (PCX), Portable
;   Network Graphics (PNG), Tag Image File Format (TIFF), and WebP (VP8, VP8L,
;   and VP8X).  "Supported" means that most of the documented formats for these
;   image types are supported.  There are several old or deprecated formats from
;   these image types that were purposely excluded. In most cases, these old
;   formats are not supported by GDI+ and other image programs.
;
;   Icon and cursor files can contain multiple images with different sizes.  See
;   the *Icons and Cursors* section for more information.
;
;   The following formats are partially supported: Windows Metafile (WMF), and
;   Enhanced MetaFile (EMF).  See the *WMF and EMF* section for more
;   information.
;
;   Please note that the contents of the file determine the image type, not
;   the file's extention.  For example, JPEG files are usually stored in (but
;   are not limited to) files with the following file extensions: .jpg, .jpeg,
;   .jpe .jif, .jfif, and .jfi.  If unsure, give it a try/see.
;
;   The JPEG extended range (JPEG XR), PiCture eXchange (PCX), and WebP image
;   types are supported by this function but they are not directly supported by
;   AutoHotkey (GUIs and the LoadPicture function).
;
; Observations and Notes:
;
;   This function was written to get the size of images stored in stand-alone
;   files without loading the entire image into memory.  In theory, this
;   function should be faster than loading the image because 1) only a small
;   portion of the file is read, 2) there is no need to decompress (JPEG, PNG,
;   etc.) or render (EMF, WMP, etc.) the image.  Unfortunately, file system
;   requests have always been the primary bottle neck for most computer
;   operations.  If the file is not in the system cache, the time it takes for
;   this function to determine the image size of most small image files when
;   compared to the time it takes to load the image and then determine the size
;   of the loaded image is not as much as you might think.  This function will
;   always be faster for most files but often there is not that much of a
;   difference.  For larger image files, the gap is much wider.  However, if the
;   file is in the system cache, this function can be anywhere from 2 to 40
;   times faster or more.  You results will vary.
;
;-------------------------------------------------------------------------------
IMG_GetImageSize(p_FileOrHandle,ByRef r_Width:=0,ByRef r_Height:=0)
    {
    Static Dummy27649730

          ;-- Image types
          ,IMAGE_BITMAP:=0
          ,IMAGE_ICON  :=1
          ,IMAGE_CURSOR:=2

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
                ;-- Seek from the end of the file.  The Distance should usually
                ;   be a negative value

    ;-- Initialize
    r_Width:=r_Height:=0

    ;[===========]
    ;[  Handle?  ]
    ;[===========]
    if p_FileOrHandle is Integer
        {
        if (DllCall("GetObjectType","UPtr",p_FileOrHandle)=OBJ_BITMAP)
            IMG_GetBitmapSize(p_FileOrHandle,r_Width,r_Height)
         else  ;-- Assume icon or cursor
            IMG_GetIconSize(p_FileOrHandle,r_Width,r_Height)

        Return {Width:r_Width,Height:r_Height}
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

;;;;;    outputdebug % "File Length: " . File.Length

    ;-- Bounce if the file is not at least 30 bytes
    if (File.Length<30)
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

    ;-- Read the first 30 bytes
    VarSetCapacity(FileData,30,0)
    File.RawRead(FileData,30)

    ;-- Convert the first 30 bytes to a string (Encoding=ANSI)
    ;
    ;   Note 1: This step allows some of the first 30 bytes to be evaluated as
    ;   a string of characters instead of having to evaluate each byte as a
    ;   number.
    ;
    ;   Note 2: The StrGet command will automatically stop converting data when
    ;   a null character is found so if the first 30 bytes includes dynamic data
    ;   or a null character, it is possible that not all 30 characters will make
    ;   it to the FileString variable.  Hint: It is only safe to use the leading
    ;   characters in this string.  If there are any non-static or null
    ;   characters after the initial characters, it's best to reconvert the
    ;   characters after the gap if needed.  Ex:
    ;   NewString:=StrGet(&FileData+12,4,"CP0")
    ;
    FileString:=StrGet(&FileData,30,"CP0")
;;;;;    outputdebug FileString: %FileString%

    ;[===================]
    ;[  Animated Cursor  ]
    ;[===================]
    ;-- https://www.gdgsoft.com/anituner/help/aniformat.htm
    ;-- https://en.wikipedia.org/wiki/ANI_(file_format)
    ;-- https://en.wikipedia.org/wiki/Resource_Interchange_File_Format
    if (SubStr(FileString,1,4)="RIFF" and StrGet(&FileData+8,4,"CP0")="ACON")
        {
;;;;;        outputdebug ANI File!
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

;;;;;            if ChunkString in anih,rate,seq%A_Space%
;;;;;                {
;;;;;                FilePos+=ChunkDataLength
;;;;;                File.Seek(FilePos,SEEK_SET)
;;;;;                Continue
;;;;;                }

            if (ChunkString="LIST")
                {
                File.RawRead(LISTType,8)
                LISTType:=StrGet(&LISTType,8,"CP0")
;;;;;                outputdebug LISTType: %LISTType%

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

        ;-- ##### For now, assume that we found what we were looking for
        File.Close()
        Return {Width:r_Width,Height:r_Height}
        }

    ;[==========]
    ;[  Bitmap  ]
    ;[==========]
    ;-- https://en.wikipedia.org/wiki/BMP_file_format
    if (SubStr(FileString,1,2)="BM")
        {
;;;;;        outputdebug Bitmap file.
        DIBHeaderSize:=NumGet(FileData,14,"UInt")
;;;;;        outputdebug DIBHeaderSize: %DIBHeaderSize%

        if (DIBHeaderSize=12) ;-- BITMAPCOREHEADER (Windows 2.0+)
            {
            outputdebug p_FileOrHandle: %p_FileOrHandle%
            outputdebug BITMAPCOREHEADER (Windows 2.0+)
            r_Width :=NumGet(FileData,18,"UShort")
            r_Height:=NumGet(FileData,20,"UShort")
            outputdebug r_Width: %r_Width%, r_Height: %r_Height%
            }
         else  ;-- everything else
            {
            r_Width :=NumGet(FileData,18,"Int")
            r_Height:=Abs(NumGet(FileData,22,"Int"))
            }

        File.Close()
        Return {Width:r_Width,Height:r_Height}
        }

    ;[==========]
    ;[  Cursor  ]
    ;[==========]
    ;-- https://en.wikipedia.org/wiki/ICO_(file_format)
    if (NumGet(FileData,0,"UInt")=0x00020000)  ;-- 4 bytes
        {
;;;;;        outputdebug Cursor_1!
;;;;;        NbrOfImages:=NumGet(FileData,4,"UShort")
;;;;;        outputdebug NbrOfImages: %NbrOfImages%

        r_Width :=NumGet(FileData,6,"UChar")
        r_Height:=NumGet(FileData,7,"UChar")
        File.Close()
        Return {Width:r_Width,Height:r_Height}
        }

    ;[=======]
    ;[  EMF  ]
    ;[=======]
    if (NumGet(FileData,0,"UInt")=0x1)  ;-- 4 bytes
        {
        ;-- Get the frame size (measured in 0.01 millimeter units)
        File.Seek(24,SEEK_SET)
        FrameLeft  :=File.ReadInt()
        FrameTop   :=File.ReadInt()
        FrameRight :=File.ReadInt()
        FrameBottom:=File.ReadInt()
        FrameWidth :=FrameRight-FrameLeft
        FrameHeight:=FrameBottom-FrameTop
;;;;;        outputdebug FrameLeft, Top, Right, Bottom, %FrameLeft%, %FrameTop%, %FrameRight%, %FrameBottom%
;;;;;        outputdebug FrameWidth, Height: %FrameWidth%, %FrameHeight%

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
        Return {Width:r_Width,Height:r_Height}
        }

    ;[=======]
    ;[  GIF  ]
    ;[=======]
     if (SubStr(FileString,1,3)="GIF"
    and  SubStr(FileString,4,3)="89a" or SubStr(FileString,4,3)="87a")
        {
        r_Width :=NumGet(FileData,6,"UShort")
        r_Height:=NumGet(FileData,8,"UShort")
        File.Close()
        Return {Width:r_Width,Height:r_Height}
        }

    ;[=========]
    ;[   Icon  ]
    ;[  ##### Version 4  ]
    ;[=========]
    ;-- https://en.wikipedia.org/wiki/ICO_(file_format)
    if (NumGet(FileData,0,"UInt")=0x00010000)  ;-- 4 bytes
        {
        NbrOfImages:=NumGet(FileData,4,"UShort")
;;;;;        outputdebug NbrOfImages: %NbrOfImages%
        r_Width :=NumGet(FileData,6,"UChar")
        r_Height:=NumGet(FileData,7,"UChar")

        ;-- Width and height < 256 and only 1 icon in the file
        if (r_Width and r_Height and NbrOfImages=1)
            {
            File.Close()
            Return {Width:r_Width,Height:r_Height}
            }

        ;-- Everything else

        ;-- Close the file
        ;   Note: This is performed here because the LoadImage system function
        ;   needs to open the file in the following statements.
        File.Close()

        ;-- Reset to the default (not found) values
        r_Width:=r_Height:=0

        ;-- Use LoadImage to determined the icon size or the default icon size
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

        Return {Width:r_Width,Height:r_Height}
        }

    ;[========]
    ;[  JPEG  ]
    ;[========]
     if (NumGet(FileData,0,"UChar")=0xFF
    and  NumGet(FileData,1,"UChar")=0xD8
    and  NumGet(FileData,2,"UChar")=0xFF)
        {
;;;;;        outputdebug JPEG file
;;;;;        IDString:=StrGet(&FileData+6,4,"CP0")
;;;;;        outputdebug IDString: %IDString%

        ;-- Loop through the tags
        FilePos:=2
        File.Seek(FilePos,SEEK_SET)
        ThisByte:=File.ReadUChar()

;;;;;            outputdebug % "Before the loop -  ThisByte: " . Format("0x{:X}",ThisByte)
        While (ThisByte=0xFF)
            {
;;;;;           outputdebug % "Top of the loop -  ThisByte: " . Format("0x{:X}",ThisByte)
            ThisByte:=File.ReadUChar()

            /*
                #####
                Note: Only found images with 0xC0 and 0xC2 tags.  Need to find
                all the formats to ensure that this works right.
            */
;;;;;           if (ThisByte>=0xC0 and ThisByte<=0xC3)
           if ThisByte Between 0xC0 and 0xC3
                {
;;;;;               outputdebug % "Desire header Hit! -  ThisByte: " . Format("0x{:X}",ThisByte)

                if (ThisByte<>0xC0 and ThisByte<>0xC2)
                    outputdebug % "Found image with odd tag!: " . Format("0x{:X}",ThisByte)
                        . ", File: " . p_FileOrHandle

                File.Seek(3,SEEK_CUR)
                r_Height:=IMG_ByteSwap(File.ReadUShort(),"UShort")
                r_Width :=IMG_ByteSwap(File.ReadUShort(),"UShort")
;;;;;                outputdebug r_Width: %r_Width%, r_Height: %r_Height%
                File.Close()
                Return {Width:r_Width,Height:r_Height}
                }

;;;;;            outputdebug % "Not the desired header.  Keep trying -  ThisByte: " . Format("0x{:X}",ThisByte)
            BlockSize:=IMG_ByteSwap(File.ReadUShort(),"UShort")
;;;;;           outputdebug BlockSize: %BlockSize%
            FilePos+=BlockSize+2
            File.Seek(FilePos,SEEK_SET)
            ThisByte:=File.ReadUChar()
;;;;;           outputdebug % "Bottom of the loop -  ThisByte: " . Format("0x{:X}",ThisByte)
            }

        ;-- If we get to this point, a size tag was not found
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
;;;;;        outputdebug JPEG XR (little endian)!

        ;-- Get the offset of the first Image File Directory (IFD)
        FilePos:=4
        File.Seek(FilePos,SEEK_SET)
        IFDOffset:=File.ReadUInt()
;;;;;        outputdebug IFDOffset: %IFDOffset%

        ;-- Collect the number of tags in the first IFD
        FilePos:=IFDOffset
        File.Seek(FilePos,SEEK_SET)
        IFDTagCount:=File.ReadUShort()
;;;;;        outputdebug IFDTagCount: %IFDTagCount%

        ;-- Update the file position
        FilePos:=File.Position

        ;-- Loop through the Image File Directory
        ;   Note: Only the Width and Height tags are used (for now)
        Loop %IFDTagCount%
            {
;;;;;            outputdebug % "Tag: " . A_Index
            TagID:=File.ReadUShort()
;;;;;            outputdebug % "TagID: " . TagID . ", Len: " . StrLen(TagID)
;;;;;            outputdebug % "TagID: " . Format("0x{:X}",TagID)

            ;-- Image Width
            if (TagID=0xBC80)
                {
                DataType :=File.ReadUShort()
;;;;;                outputdebug DataType: %DataType%
                DataCount:=File.ReadUInt()  ;-- Always 1 for this tag
                r_Width:=DataType=3 ? File.ReadUShort():File.ReadUInt()
;;;;;                outputdebug ########## r_Width: %r_Width%
                }

            ;-- Image Height
            if (TagID=0xBC81)
                {
                DataType :=File.ReadUShort()
;;;;;                outputdebug DataType: %DataType%
                DataCount:=File.ReadUInt()  ;-- Always 1 for this tag
                r_Height:=DataType=3 ? File.ReadUShort():File.ReadUInt()
;;;;;                outputdebug ########## r_Height: %r_Height%
                }

            ;-- Set the file position for the next tag
            ;   Note: Each tag is 12 bytes.  The file position is set on
            ;   every iteration so that regardless of what file activity is
            ;   performed in the loop, the file will be positioned correctly
            ;   for the next tag.
            FilePos+=12
            File.Seek(FilePos,SEEK_SET)
            }

        /*
            #####
            For now, assume that we found what we were looking for.  This might
            change in the future.
        */
        File.Close()
        Return {Width:r_Width,Height:r_Height}
        }

    ;[=======]
    ;[  PCX  ]
    ;[=======]
    ;-- https://www.fileformat.info/format/pcx/egff.htm
    if (NumGet(FileData,0,"UChar")=0x0A and NumGet(FileData,1,"UChar")<=0x5)
        {
;;;;;        outputdebug PCX!
        XStart  :=NumGet(FileData,4,"UShort")
        YStart  :=NumGet(FileData,6,"UShort")
        XEnd    :=NumGet(FileData,8,"UShort")
        YEnd    :=NumGet(FileData,10,"UShort")
        r_Width :=XEnd-XStart+1
        r_Height:=YEnd-YStart+1
        File.Close()
        Return {Width:r_Width,Height:r_Height}
        }

    ;[=======]
    ;[  PNG  ]
    ;[=======]
    if (NumGet(FileData,0,"UChar")=0x89
   and  SubStr(FileString,2,5)="PNG`r`n"
   and  NumGet(FileData,6,"UChar")=0x1A
   and  NumGet(FileData,7,"UChar")=0x0A     ;-- LF
   and  StrGet(&FileData+12,4,"CP0")="IHDR")
        {
;;;;;        outputdebug PNG!
        r_Width :=IMG_ByteSwap(NumGet(FileData,16,"UInt"))
        r_Height:=IMG_ByteSwap(NumGet(FileData,20,"UInt"))
        File.Close()
        Return {Width:r_Width,Height:r_Height}
        }

    ;[=======]
    ;[  SVG  ]
    ;[=======]
    ;-- https://en.wikipedia.org/wiki/Scalable_Vector_Graphics
    /*
        This only works if the character encoding for the file is ASCII, ANSI,
        UTF-8, or any other compatible single-byte character encoding system
        where the first printable characters are the same as ASCII.  Anything
        else (Ex: UTF-16) and the function will not find what we need.  There
        is close to a 100% chance that SVG files are encoded using a compatible
        character encoding system so we should get what we need in most cases.
        Adding code to deal with the rare exceptions may reduce the efficiency
        of this function.
    */
    if InStr(FileString,"<?xml") or InStr(FileString,"<svg")  ;-- Within the first 30 bytes
        {
        ;-- Possible SVG.  We need to look further to be sure.
;;;;;        outputdebug Possible SVG

        ;-- Read up to the first 1.5K characters
        File.Seek(0,SEEK_SET)
        SVGString:=File.Read(1536)

;;;;;        outputdebug % SubStr(SVGString,1,200)

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
;;;;;                outputdebug r_Width: %r_Width%, %r_Height%
                Return {Width:r_Width,Height:r_Height}
                }

            ;-- Width and/or Height not found.  Reset and move on to the next
            r_Width:=r_Height:=0
            }
        }

    ;[===================]
    ;[        TIFF       ]
    ;[  (Little Endian)  ]
    ;[===================]
    ;-- http://paulbourke.net/dataformats/tiff/tiff_summary.pdf
     if (SubStr(FileString,1,2)="II"
    and  NumGet(FileData,2,"UShort")=42)  ;-- TIFF version
        {
;;;;;        outputdebug TIFF_II!

        ;-- Get the offset of the first Image File Directory (IFD)
        FilePos:=4
        File.Seek(FilePos,SEEK_SET)
        IFDOffset:=File.ReadUInt()
;;;;;       outputdebug IFDOffset: %IFDOffset%

        ;-- Collect the number of tags in the first IFD
        FilePos:=IFDOffset
        File.Seek(FilePos,SEEK_SET)
        IFDTagCount:=File.ReadUShort()
;;;;;       outputdebug IFDTagCount: %IFDTagCount%

        ;-- Update the file position
        FilePos:=File.Position

        ;-- Loop through the Image File Directory
        ;   Note: Only the Width and Height tags are used (for now)
        Loop %IFDTagCount%
            {
;;;;;           outputdebug % "Tag: " . A_Index
            TagID:=File.ReadUShort()
;;;;;            outputdebug % "TagID: " . TagID . ", Len: " . StrLen(TagID)
;;;;;            outputdebug % "TagID: " . Format("0x{:X}",TagID)

            ;-- Image Width
            if (TagID=0x100)
                {
                DataType :=File.ReadUShort()
                DataCount:=File.ReadUInt()  ;-- Always 1 for this tag
                r_Width:=DataType=3 ? File.ReadUShort():File.ReadUInt()
                }

            ;-- Image Length (i.e. Height)
            if (TagID=0x101)
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

        /*
            #####
            For now, assume that we found what we were looking for.  This might
            change in the future.
        */
        File.Close()
        Return {Width:r_Width,Height:r_Height}
        }

    ;[================]
    ;[      TIFF      ]
    ;[  (Big Endian)  ]
    ;[================]
    ;-- http://paulbourke.net/dataformats/tiff/tiff_summary.pdf
     if (SubStr(FileString,1,2)="MM"
    and  IMG_ByteSwap(NumGet(FileData,2,"UShort"),"UShort")=42)  ;-- TIFF version
        {
;;;;;        outputdebug TIFF_MM!
;;;;;        outputdebug p_FileOrHandle: %p_FileOrHandle%

        ;-- Get the offset of the first Image File Directory (IFD)
        FilePos:=4
        File.Seek(FilePos,SEEK_SET)
        IFDOffset:=IMG_ByteSwap(File.ReadUInt())
;;;;;        outputdebug IFDOffset: %IFDOffset%

        ;-- Collect the number of tags in the first IFD
        FilePos:=IFDOffset
        File.Seek(FilePos,SEEK_SET)
        IFDTagCount:=IMG_ByteSwap(File.ReadUShort(),"UShort")
;;;;;        outputdebug IFDTagCount: %IFDTagCount%

        ;-- Update the file position
        FilePos:=File.Position

        ;-- Loop through the Image File Directory
        ;   Note: Only the Width and Height tags are used (for now)
        Loop %IFDTagCount%
            {
;;;;;            outputdebug % "Tag: " . A_Index
            TagID:=IMG_ByteSwap(File.ReadUShort(),"UShort")
;;;;;            outputdebug % "TagID: " . TagID . ", Len: " . StrLen(TagID)
;;;;;            outputdebug % "TagID: " . Format("0x{:X}",TagID)

            ;-- Image Width
            if (TagID=0x100)
                {
                DataType :=IMG_ByteSwap(File.ReadUShort(),"UShort")
                DataCount:=IMG_ByteSwap(File.ReadUInt())  ;-- Always 1 for this tag
                r_Width:=DataType=3 ? IMG_ByteSwap(File.ReadUShort(),"UShort"):IMG_ByteSwap(File.ReadUInt())
                }

            ;-- Image Length (i.e. Height)
            if (TagID=0x101)
                {
                DataType :=IMG_ByteSwap(File.ReadUShort(),"UShort")
                DataCount:=IMG_ByteSwap(File.ReadUInt())  ;-- Always 1 for this tag
                r_Height:=DataType=3 ? IMG_ByteSwap(File.ReadUShort(),"UShort"):IMG_ByteSwap(File.ReadUInt())
                }

            ;-- Set the file position for the next tag
            ;   Note: Each tag is 12 bytes.  The file position is set on
            ;   every iteration so that regardless of what file activity is
            ;   performed in the loop, the file will be positioned correctly
            ;   for the next tag.
            FilePos+=12
            File.Seek(FilePos,SEEK_SET)
            }

        /*
            #####
            For now, assume that we found what we were looking for.  This might
            change in the future.
        */
        File.Close()
        Return {Width:r_Width,Height:r_Height}
        }

    ;[========]
    ;[  WebP  ]
    ;[========]
    if (SubStr(FileString,1,4)="RIFF" and StrGet(&FileData+8,4,"CP0")="WEBP")
        {
        ImageSizeFound:=False
        VP8Format:=StrGet(&FileData+12,4,"CP0")
;;;;;        outputdebug WEBP!
        if (VP8Format="VP8 ")
            {
            ;-- https://wiki.tcl-lang.org/page/Reading+WEBP+image+dimensions
            ;-- https://tools.ietf.org/html/rfc6386#page-30

            ;-- Check for valid code block identifier
            if (NumGet(FileData,23,"UChar")<>0x9D
            or  NumGet(FileData,24,"UChar")<>0x01
            or  NumGet(FileData,25,"UChar")<>0x2A)
                outputdebug Missing start code block!
             else
                {
;;;;;                outputdebug VP8
                File.Seek(26,SEEK_SET)

                ;-- Collect the width and height
                ;   Note: Each size field is stored in a 16-bit space but only
                ;   14-bits are used.  Since the program reads a UShort value
                ;   (16-bit unsigned integer), the high 2 bits are truncated to
                ;   ensure that correct value is returned.
                r_Width :=File.ReadUShort()&0x3FFF
                r_Height:=File.ReadUShort()&0x3FFF
;;;;;                outputdebug r_Width: %r_Width%, %r_Height%
                ImageSizeFound:=True
                }
            }
        else if (VP8Format="VP8L")
            {
            ;-- https://wiki.tcl-lang.org/page/Reading+WEBP+image+dimensions
;;;;;            outputdebug VP8L
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
;;;;;            outputdebug VP8X
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
        Return ImageSizeFound ? {Width:r_Width,Height:r_Height}:False
        }

    ;[=============================]
    ;[             WMF             ]
    ;[  Aldus Placeable Metafiles  ]
    ;[          (D7CDC69A)         ]
    ;[=============================]
    ;-- http://wvware.sourceforge.net/caolan/ora-wmf.html
    if (NumGet(FileData,0,"UInt")=0x9AC6CDD7)
        {
;;;;;        outputdebug WMF: D7CDC69A (aka 9AC6CDD7)
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
        Return {Width:r_Width,Height:r_Height}
        }

    ;-- Shut it down
    ;   Note: If we get to this point, the file was not recognized or no valid
    ;   size information was found.
    File.Close()
    Return False
    }

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
;   p_Short - Set to a string that includes the word "Short" to reverse the
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
; Returns:
;
;   An object (tests as TRUE) if successful, otherwise FALSE.  If returned, the
;   object contains the following properties:
;
;   Width, Height - The width and height of the bitmap.
;
;-------------------------------------------------------------------------------
IMG_GetBitmapSize(hBitmap,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy89628542
          ,sizeofBITMAP:=A_PtrSize=8 ? 32:24

    ;-- Initialize
    r_Width:=r_Height:=0

    ;-- Get bitmap info
    VarSetCapacity(BITMAP,sizeofBITMAP,0)
    if not DllCall("GetObject","UPtr",hBitmap,"Int",sizeofBITMAP,"UPtr",&BITMAP)
        Return False

    ;-- Update the output variables
    r_Width :=NumGet(BITMAP,4,"Int")                    ;-- bmWidth
    r_Height:=NumGet(BITMAP,8,"Int")                    ;-- bmHeight
    Return {Width:r_Width,Height:r_Height}
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
    VarSetCapacity(ICONINFO,A_PtrSize=8 ? 32:20,0)
    if not DllCall("GetIconInfo","UPtr",hIcon,"UPtr",&ICONINFO)
        Return False

    hMask :=NumGet(ICONINFO,A_PtrSize=8 ? 16:12,"UPtr")
    hColor:=NumGet(ICONINFO,A_PtrSize=8 ? 24:16,"UPtr")

    ;-- Get bitmap info
    VarSetCapacity(BITMAP,sizeofBITMAP,0)
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
    Return {Width:r_Width,Height:r_Height}
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
    VarSetCapacity(l_Message,1024*(A_IsUnicode ? 2:1),0)
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
