; Link:
; Author:
; Date:
; for:     	AHK_L

/*

	#NoEnv
	#SingleInstance Force
	SetBatchLines, -1

	; Set filenames
	dir := A_ScriptDir "\"
	inFile := "test2b.jpg" ; Filename of image
	outFile := "Resized_" inFile

	If !(IM := New MagickCoreAPI)
	   ExitApp

	; Check if MagickCore started up
	msgbox % "Core Instantiated: " IM.IsMagickCoreInstantiated()

	; Create the ExceptionInfo structure
	pException := IM.AcquireExceptionInfo()

	; Create Image_Info Structure
	pImage_Info := IM.CloneImageInfo()

	; Set the Filename in the Image_Info structure
	IM.SetImageInfoFile(pImage_Info, &inFile)

	; Check to see if the filename is in the Image_Info structure
	pFileName := IM.GetImageInfoFile(pImage_Info)
	msgbox % "Get Filename: " StrGet(pFileName)

	; Read the Image from the File
	pImage := IM.ReadImage(pImage_Info, pException)
	Msgbox % "Read Image: " pImage

	; Severity should be the first member of the ExceptionInfo structure?
	; https://imagemagick.org/api/MagickCore/struct__ExceptionInfo.html
	If(NumGet(pException+0, 0, "Int") != 0)
		IM.CatchException(pException)

	If (pImage == Chr(0))
		ExitApp

	; Convert Image to Thumbnail
	pThumbnails := IM.NewImageList()
	pResize_Image := IM.ResizeImage(pImage, 106, 80, 22, pException) ; 22 = LanczosFilter
	If (pResize_Image == Chr(0))
		IM.MagickError(NumGet(pException+0, 0, "Int")		; Severity
					,  NumGet(pException+0, 8, "Char")		; Reason
					,  NumGet(pException+0, 12, "Char"))	; Description

	IM.AppendImageToList(pThumbnails, pResize_Image)
	IM.DestroyImage(pImage)

	; Write the image Thumbnail
	IM.SetImageInfoFile(pThumbnails, &outFile)

	; Destroy the image thumbnail and exit
	pThumbnails := IM.DestroyImageList(pThumbnails)
	pImage_Info := IM.DestroyImageInfo(pImage_Info)
	pException := IM.DestroyExceptionInfo(pException)
	IM := ""


	msgbox END
	Return

*/



Class MagickCoreAPI {

	; ===================================================================================================================
	; META FUNCTION __New
	; Load and initialize CORE_RL_MagickCore_.dll which is supposed to be in the sript's folder.
	; Parameters:    LibPath  - Optional: Absolute path of CORE_RL_MagickCore_.dll
	; ===================================================================================================================
	__New(LibPath := "") {
		Static LibMagickCore := A_ScriptDir . "\CORE_RL_MagickCore_.dll"
		; Do not instantiate instances!
		If (This.Base.Base.__Class = "MagickCoreAPI") {
			MsgBox, 16, MagickCore Error!, You must not instantiate instances of MagickCore!
			Return False
		}
		; Load CORE_RL_MagickCore_.dll
		If (LibPath)
			LibMagickCore := LibPath
		If !(MagickCoreModule := DllCall("Kernel32.dll\LoadLibrary", "Str", LibMagickCore, "UPtr")) {
			If (A_LastError = 126) ; The specified module could not be found
				MsgBox, 16, MagickCore Error!, Could not find %LibMagickCore%!
			Else {
			ErrCode := A_LastError
				VarSetCapacity(ErrMsg, 131072, 0) ; Unicode
				DllCall("FormatMessage", "UInt", 0x1200, "Ptr", 0, "UInt", ErrCode, "UInt", 0, "Str", ErrMsg, "UInt", 65536, "Ptr", 0)
				MsgBox, 16, MagickCore Error!, % "Could not load " . LibMagickCore . "!`n"
										. "Error code: " . ErrCode . "`n"
										. ErrMsg
			}
			Return False
		}
		This.Module := MagickCoreModule
		This.MagickCoreGenesis(LibMagickCore, 1)
	}

	; ===================================================================================================================
	; META FUNCTION __Delete
	; Free ressources
	; ===================================================================================================================
	__Delete() {
		This.MagickCoreTerminus()
		If (This.Module)
			DllCall("Kernel32.dll\FreeLibrary", "Ptr", This.Module)
	}

	; ===================================================================================================================
	; API functions
	; ===================================================================================================================
	AcquireExceptionInfo() {
		; https://imagemagick.org/api/exception.php#AcquireExceptionInfo
		; ExceptionInfo *AcquireExceptionInfo(void)
		Return DllCall("CORE_RL_MagickCore_.dll\AcquireExceptionInfo", "ptr")
	}

	AcquireImage(Info, pException) {
		; https://imagemagick.org/api/image.php#AcquireImage
		; Image *AcquireImage(const ImageInfo *image_info,ExceptionInfo *exception)
		Return DllCall("CORE_RL_MagickCore_.dll\AcquireImage", "ptr", Info, "Ptr", pException, "Ptr")
	}

	AcquireImageInfo() {
		; https://imagemagick.org/api/image.php#AcquireImageInfo
		; ImageInfo *AcquireImageInfo(void)
		Return DllCall("CORE_RL_MagickCore_.dll\AcquireImageInfo", "ptr")
	}

	AppendImageToList(pImage_List, pImage) {
		; https://imagemagick.org/api/list.php#AppendImageToList
		; AppendImageToList(Image *images,const Image *image)
		Return DllCall("CORE_RL_MagickCore_.dll\AppendImageToList", "Ptr", pImage_List, "Ptr", pImage)
	}

	CatchException(pException) {
		; https://imagemagick.org/api/exception.php#CatchException
		; CatchException(ExceptionInfo *exception)
		Return DllCall("CORE_RL_MagickCore_.dll\CatchException", "Ptr", pException, "Ptr")
	}

	CloneImageInfo(pImage_Info := "") {
		; https://imagemagick.org/api/image.php#CloneImageInfo
		; ImageInfo *CloneImageInfo(const ImageInfo *image_info)
		Return DllCall("CORE_RL_MagickCore_.dll\CloneImageInfo", "Ptr")
	}

	DestroyExceptionInfo(pException) {
		; https://imagemagick.org/api/exception.php#DestroyExceptionInfo
		; ExceptionInfo *DestroyExceptionInfo(ExceptionInfo *exception)
		Return DllCall("CORE_RL_MagickCore_.dll\DestroyExceptionInfo", "Ptr", pException)
	}

	DestroyImage(pImage) {
		; https://imagemagick.org/api/image.php#DestroyImage
		; Image *DestroyImage(Image *image)
		Return DllCall("CORE_RL_MagickCore_.dll\DestroyImage", "Ptr", pImage)
	}

	DestroyImageInfo(pImage_Info) {
		; https://imagemagick.org/api/image.php#DestroyImageInfo
		; ImageInfo *DestroyImageInfo(ImageInfo *image_info)
		Return DllCall("CORE_RL_MagickCore_.dll\DestroyImageInfo", "Ptr", pImage_Info)
	}

	DestroyImageList(pImage_List) {
		; https://imagemagick.org/api/list.php#DestroyImageList
		; Image *DestroyImageList(Image *image)
		Return DllCall("CORE_RL_MagickCore_.dll\DestroyImageList", "Ptr", pImage_List)
	}

	FileToImage(pImage, pFilename) {
		; https://imagemagick.org/api/blob.php#FileToImage
		; MagickBooleanType FileToImage(Image *,const char *filename)
		Return DllCall("CORE_RL_MagickCore_.dll\FileToImage", "Ptr", pImage, "Ptr", pFilename, "Int")
	}

	GetImageInfoFile(pImage_Info) {
		; https://imagemagick.org/api/image.php#GetImageInfoFile
		; FILE *GetImageInfoFile(const ImageInfo *image_info)
		Return DllCall("CORE_RL_MagickCore_.dll\GetImageInfoFile", "Ptr", pImage_Info, "Ptr")
	}

	InitializeExceptionInfo(pException) {
		; https://imagemagick.org/api/exception.php#InitializeExceptionInfo
		; InitializeExceptionInfo(ExceptionInfo *exception)
		Return DllCall("CORE_RL_MagickCore_.dll\InitializeExceptionInfo", "Ptr", pException)
	}

	IsMagickCoreInstantiated() {
		; https://imagemagick.org/api/magick.php#IsMagickCoreInstantiated
		; MagickBooleanType IsMagickCoreInstantiated(void)
		Return DllCall("CORE_RL_MagickCore_.dll\IsMagickCoreInstantiated", "Int")
	}

	MagickCoreGenesis(Path, establish_signal_handlers) {
		; https://imagemagick.org/api/magick.php#MagickCoreGenesis
		; MagickCoreGenesis(const char *path,const MagickBooleanType establish_signal_handlers)
		Return DllCall("CORE_RL_MagickCore_.dll\MagickCoreGenesis", "AStr", Path, "UInt", establish_signal_handlers, "Int")
	}

	MagickCoreTerminus() {
		; https://imagemagick.org/api/list.php#NewImageList
		; MagickCoreTerminus(void)
		Return DllCall("CORE_RL_MagickCore_.dll\MagickCoreTerminus", "Int")
	}

	MagickError(Error, pReason, pDescription) {
		; https://imagemagick.org/api/exception.php#MagickError
		; void MagickError(const ExceptionType error,const char *reason,const char *description)
		Return DllCall("CORE_RL_MagickCore_.dll\MagickError", "Int", Error, "Ptr", pReason, "Ptr", pDescription)
	}

	NewImageList() {
		; https://imagemagick.org/api/magick.php#MagickCoreTerminus
		; Image *NewImageList(void)
		Return DllCall("CORE_RL_MagickCore_.dll\NewImageList", "Int")
	}

	ReadImage(pImage_Info, pException){
		; https://imagemagick.org/api/constitute.php#ReadImage
		; Image *ReadImage(const ImageInfo *image_info,ExceptionInfo *exception)
		Return DllCall("CORE_RL_MagickCore_.dll\ReadImage", "Ptr", pImage_Info, "Ptr", pException, "Ptr")
	}

	RemoveFirstImageFromList(pImage){
		; https://imagemagick.org/api/list.php#RemoveFirstImageFromList
		; Image *RemoveFirstImageFromList(Image **images)
		Return DllCall("CORE_RL_MagickCore_.dll\RemoveFirstImageFromList", "Ptr", pImage)
	}

	ResizeImage(pImage, pException){
		; https://imagemagick.org/api/resize.php#ResizeImage
		; Image *ResizeImage(Image *image,const size_t columns,const size_t rows,
		; 	const FilterType filter,ExceptionInfo *exception)
		Return DllCall("CORE_RL_MagickCore_.dll\ResizeImage", "Ptr", pImage, "Int", Columns, "Int", Rows
				, "Int", FilterType, "Ptr", pException, "Int")
	}

	SetImageInfoFile(pImage_Info, File) {
		; https://imagemagick.org/api/image.php#SetImageInfoFile
		; void SetImageInfoFile(ImageInfo *image_info,FILE *file)
		Return DllCall("CORE_RL_MagickCore_.dll\SetImageInfoFile", "Ptr", pImage_Info, "Ptr", File, "Int")
	}

	ScaleImage(pImage, Columns, Rows, pException) {
		; https://imagemagick.org/api/resize.php#ScaleImage
		; Image *ScaleImage(const Image *image,const size_t columns,const size_t rows,ExceptionInfo *exception)
		Return DllCall("CORE_RL_MagickCore_.dll\ScaleImage", "Ptr", pImage, "Int", Columns, "Int", Rows, "Ptr", pException)
	}

	WriteImage(pImage_Info, pImage, pException) {
		; https://imagemagick.org/api/constitute.php#WriteImage
		; MagickBooleanType WriteImage(const ImageInfo *image_info,Image *image, ExceptionInfo *exception)
		Return DllCall("CORE_RL_MagickCore_.dll\WriteImage", "Ptr", pImage_Info, "Ptr", pImage, "Ptr", pException, "Int")
	}
}