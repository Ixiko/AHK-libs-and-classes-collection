#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
MaxFiles:=50000  ;-- Arbitrary limit

;-- Build main and drop GUI
gui 1:Default
gui -DPIScale hWndhPromptGUI -MinimizeBox
gui Margin,10,10

gui Add,Text,xm w900,
   (ltrim join`s
   The IMG_GetImageSize function is used to identify the dimensions (width and
   height) of the image contained in stand-alone image file.  This function can
   determine the image size of large number of image types.  Please see the
   function documentation for more information.
   )

gui Font,Bold
gui Add,Text,xm Section,Options:
gui Font
gui Add,Text,xm,File extension:
gui Add
   ,ComboBox
   ,xm y+1 w100 vFileExt
   ,ANI|BMP|CUR|DIB|EMF|GIF|ICO|JFI|JFIF|JIF|JPE|JPEG|JPG||JXR|PBM|PCX|PGM|PPM|PNG|RLE|SVG|TIF|TIFF|WDP|WEBP|WMF

gui Add,Text,xm,Max dropped files:
gui Add,Edit,y+1 w100 vMaxDropFiles Number,1000
gui Add,CheckBox,xm vShowFullPath gToggleName Checked,Show full path

gui Font,Bold
gui Add,Text,ys,Instructions:
gui Font
gui Add,Text,y+5,1) Choose the desired options on the left.
gui Add,Text,y+5,
   (ltrim join`s
    2) Drag one or more files and/or folders that contains image files with the
    specified file extension and drop on this window.
   )

gui Add,Text,y+5,
   (ltrim join`s
    3) Press the "Get Image Size" button to get the image size for all the
    files.
   )

gui Add,Text,y+5,4) Repeat if desired.

;-- ListView
gui Add
   ,ListView
   ,xm w900 r20 Count%MaxFiles% vLV
   ,Files|Files|Width|Height|bpp

gui Add,Text,xm w125,Number of files:
gui Font,Bold cNavy
gui Add,Text,x+0 w100 vFileCount,0
gui Font

gui Add,Text,xm w125,Elapsed time:
gui Font,Bold cNavy
gui Add,Text,x+0 w100 vGISElapsedTime
gui Font

;-- Buttons
gui Font,Boldx
gui Add,Button,xm w200 gGetImageSize,Get Image Size
gui Font
gui Add,Button,xm wp   gReload Default,Rebuild example...

;-- Show it
SplashImage Off
gui Show
SetBatchLines 10ms
return


GetImageSize:
SplashImage,,w400 B1,,Using IMG_GetImageSize`nto get the image size...
Sleep 1

StartTime:=A_TickCount
SetBatchLines -1
Loop %FileCount%
    {
    LV_GetText(File,A_Index,1)
    GIS:=IMG_GetImageSize(File,Width,Height,bpp)
    LV_Modify(A_Index,"Col3",Width,Height,bpp)
    }

ElapsedTime:=A_TickCount-StartTime
SplashImage Off
GUIControl,,GISElapsedTime,%ElapsedTime% ms
return


GUIEscape:
GUIClose:
ExitApp


GUIDropFiles:
gui Submit,NoHide

;;;;;;-- Clear the current ListView
;;;;;LV_Delete()

;-- Get files
ArrayOfDropFiles:=Array()
ArrayOfDropFiles.SetCapacity(MaxFiles)

SplashImage,,w350 B1,,Building a list of files...
Sleep 1

SetBatchLines 100ms

;-- Build array of files
FileCount:=0
Loop Parse,A_GUIEvent,`n,`r
    {
    if (FileCount>=MaxDropFiles)
        Break

    ;-- Assign and remove all leading/trailing white space
    DropFile:=Trim(A_LoopField," `f`n`r`t`v")

    ;-- Skip if the file or folder is not found
    IfNotExist %DropFile%
        Continue

    ;-- Dropped a folder?
    if InStr(FileExist(DropFile),"D")
        {
        DropFolder:=DropFile
        Loop Files,%DropFolder%\*.%FileExt%,R
            {
            FileCount++
            ArrayOfDropFiles.Push(A_LoopFileLongPath)
            if (FileCount>=MaxDropFiles)
                Break
            }

        ;-- Note: There is a >=MaxDropFiles test at the top of the loop
        Continue
        }

    SplitPath DropFile,,,DropFileExt
    if (FileExt<>DropFileExt)
        Continue

    FileCount++
    ArrayOfDropFiles.Push(DropFile)
    }

SplashImage Off

;-- No valid files found
if (FileCount=0)
    {
    gui +OwnDialogs
    MsgBox 0x10,Drop Error,No valid files dropped.
    return
    }

;-- Load ListView
SplashImage,,w350 B1,,Loading ListView...
Sleep 1

GUIControl -Redraw,LV
LV_Delete()
For Key,File in ArrayOfDropFiles
    {
    SplitPath File,OutFileName
    LV_Add("",File,OutFileName)
    }

;-- Adjust column size
LV_ModifyCol(1,ShowFullPath ? 625:0)
LV_ModifyCol(2,ShowFullPath ? 0:625)
Loop 3
    LV_ModifyCol(A_Index+2,"75 Integer")

GUIControl +Redraw,LV
SplashImage Off

;-- Update gui fields
GUIControl,,FileCount,%FileCount%
GUIControl,,GISElapsedTime,%A_Space%
return


Reload:
Reload
return


ToggleName:
gui Submit,NoHide
GUIControl -Redraw,LV
LV_ModifyCol(1,ShowFullPath ? 625:0)
LV_ModifyCol(2,ShowFullPath ? 0:625)
GUIControl +Redraw,LV
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%/_Functions
#include IMG_GIS.ahk
