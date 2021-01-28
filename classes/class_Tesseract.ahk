class Tesseract 
{
	static leptonica := A_ScriptDir "\Helper_ocr\bin\leptonica_util\leptonica_util.exe"
	static tesseract := A_ScriptDir "\Helper_ocr\bin\tesseract\tesseract.exe"
	static tessdata_best := A_ScriptDir "\Helper_ocr\bin\tesseract\tessdata_best"
	static tessdata_fast := A_ScriptDir "\Helper_ocr\bin\tesseract\tessdata_fast"

	static file := A_ScriptDir "\Helper_ocr\mcoc_screenshot.bmp"
	static fileProcessedImage := A_ScriptDir "\Helper_ocr\mcoc_preprocess.tif"
	static fileConvertedText := A_ScriptDir "\Helper_ocr\mcoc_text.txt"

	; OCR() can be called directly
	OCR(pBitmap, language:="", options:="")
	{
		this.language := language
		imgFile:= this.toFile(pBitmap, this.file)
		this.preprocess(imgFile, this.fileProcessedImage)
		this.convert_best(this.fileProcessedImage, this.fileConvertedText, 0, options)
		return this.read(), this.cleanup()
	}
	
	; toFile() - Saves the image as a temporary file.
	toFile(image, outputFile:="")
	{
		Gdip_SaveBitmapToFile(image, outputFile)
		return outputFile
	}
	
	__New(language:="", options:="")
	{
		this.language := language
	}

	cleanup()
	{
		FileDelete, % this.file
		FileDelete, % this.fileProcessedImage
		FileDelete, % this.fileConvertedText
	}

	convert_best(in:="", out:="", fast:=0, options:="")
	{
		;~ static q := Chr(0x22)

		;~ in := (in) ? in : this.fileProcessedImage
		;~ out := (out) ? out : this.fileConvertedText
		;~ fast := (fast) ? this.tessdata_fast : this.tessdata_best
		;~ options := (options) ? options : " -psm 6"

		;~ if !(FileExist(in))
			;~ throw Exception("Input image for conversion not found.",, in)

		;~ if !(FileExist(this.tesseract))
			;~ throw Exception("Tesseract not found",, this.tesseract)
		
		
		;~ _cmd .= q this.tesseract q " --tessdata-dir " q fast q " " q in q " " q SubStr(out, 1, -4) q " " q options q
		;~ _cmd .= (this.language) ? " -l " q this.language q : ""
		
		;~ _cmd := ComSpec " /C " q _cmd q
		;~ RunWait, % _cmd,, Hide

		;~ if !(FileExist(out))
			;~ throw Exception("Tesseract failed.",, _cmd)

		;~ return out
		
		
		in := (in) ? in : this.fileProcessedImage
		out := (out) ? out : this.fileConvertedText
		fast := (fast) ? this.tessdata_fast : this.tessdata_best
		
		if !(FileExist(in))
		   throw Exception("Input image for conversion not found.",, in)

		if !(FileExist(this.tesseract))
		   throw Exception("Tesseract not found",, this.tesseract)

		static q := Chr(0x22)
		_cmd .= q this.tesseract q " --tessdata-dir " q fast q " " q in q " " q SubStr(out, 1, -4) q 
		_cmd .= (options) ? options : " -psm 6"
		_cmd .= (this.language) ? " -l " q this.language q : ""
		_cmd := ComSpec " /C " q _cmd q
		
		;~ msgbox % _cmd
		
		RunWait % _cmd,, Hide

		if !(FileExist(out))
		   throw Exception("Tesseract failed.",, _cmd)

		return out

	}

	convert_fast(in:="", out:="")
	{
		return this.convert_best(in, out, 1)
	}


	preprocess(in:="", out:="")
	{
		static LEPT_TRUE 				:= ocrPreProcessing := 1
		static negateArg 				:= 2 ; 0=NEGATE_NO,   /* Do not negate image */  1=NEGATE_YES,  /* Force negate */  2=NEGATE_AUTO, /* Automatically negate if border pixels are dark */
		static dark_bg_threshold 		:= 0.5 ; /* From 0.0 to 1.0, with 0 being all white and 1 being all black */
		static performScaleArg 			:= LEPT_TRUE ; true/false
		static scaleFactor 				:= 3.5 ;
		static perform_unsharp_mask 	:= LEPT_TRUE ;
		static usm_halfwidth 			:= 5 ;
		static usm_fract 				:= 2.5 ;
		static perform_otsu_binarize	:= LEPT_TRUE ;
		static otsu_sx					:= 2000 ;
		static otsu_sy					:= 2000 ;
		static otsu_smoothx				:= 0 ;
		static otsu_smoothy				:= 0 ;
		static otsu_scorefract   		:= 0.0 ;
		
		static q := Chr(0x22)
		
		in := (in != "") ? in : this.file
		out := (out != "") ? out : this.fileProcessedImage

		if !(FileExist(in))
		   throw Exception("Input image for preprocessing not found.",, in)

		if !(FileExist(this.leptonica))
		   throw Exception("Leptonica not found",, this.leptonica)

		_cmd .= q this.leptonica q " " q in q " " q out q
				
		_cmd .= " " negateArg " " dark_bg_threshold 
			.	" " performScaleArg " " scaleFactor 
			.	" " perform_unsharp_mask " " usm_halfwidth " " usm_fract 
			.	" " perform_otsu_binarize  " " otsu_sx " " otsu_sy " " otsu_smoothx " " otsu_smoothy " " otsu_scorefract
			
		_cmd := ComSpec " /C " q _cmd q
		
		; leptonica_util.exe in.png out.png  2 0.5  1 3.5  1 5 2.5  1 2000 2000 0 0 0.0  1 */
		RunWait, % _cmd,, Hide
		
		if !(FileExist(out))
		   throw Exception("Preprocessing failed.",, _cmd)
		   
		return out
		
	}

	read(in:="", lines:="")
	{
		in := (in) ? in : this.fileConvertedText
		database := FileOpen(in, "r`n", "UTF-8")

		if (lines == "") 
		{
		   text := RegExReplace(database.Read(), "^\s*(.*?)\s*$", "$1")
		   text := RegExReplace(text, "(?<!\r)\n", "`r`n")
		} 
		else
		{
			while (lines > 0) 
			{
				data := database.ReadLine()
				data := RegExReplace(data, "^\s*(.*?)\s*$", "$1")
				if (data != "") 
				{
					text .= (text) ? ("`n" . data) : data
					lines--
				}
				if (!database || database.AtEOF)
					break
			}
		}
		database.Close()
		return text
	}

	readlines(lines)
	{
		return this.read(, lines)
	}
}