global GSWIN32C := A_ScriptDir . "\Ghostscript\bin\gswin32c.exe"

gswin32c_bbox_info(input_file){
	global GSWIN32C

	static gswin32c_stdout
	gswin32c_stdout := A_WorkingDir . "\gswin32c_stdout.txt"

	if FileExist(gswin32c_stdout) {
		FileSetAttrib, -R, %gswin32c_stdout%, 0, 0
		FileDelete, %gswin32c_stdout%
	}

	static command
	command =
	( LTrim RTrim Join`s&`s
		cls
		@echo off
		cd /d "%A_WorkingDir%"
		"%GSWIN32C%" -q -dBATCH -dNOPAUSE -sDEVICE=bbox -f "%input_file%" > "%gswin32c_stdout%" 2>&1 & type "%gswin32c_stdout%"
		exit
	)

	RunWait, %ComSpec% /k %command%,, Hide

	static line_text
	static match_, match_1, match_2, match_3, match_4
	static bbox_X, bbox_Y, bbox_W, bbox_H
	Loop, Read, %gswin32c_stdout%
	{
		line_text := Trim(A_LoopReadLine)
		; MsgBox, % line_text
		if RegExMatch(line_text, "i)^%%BoundingBox: ([\d.]+) ([\d.]+) ([\d.]+) ([\d.]+)$", match_) {
			bbox_X := match_1
			bbox_Y := match_2
			bbox_W := match_3
			bbox_H := match_4
		}
	}

	FileDelete, %gswin32c_stdout%

	return { x: bbox_X, y: bbox_Y, w: bbox_W, h: bbox_H }
}

gswin32c_pdf_trim(input_file, output_file, margins_x := 20, margins_y := 10){
	global GSWIN32C

	bbox := gswin32c_bbox_info(input_file)
	; MsgBox, % "X`t" . bbox.x . "`n" . "Y`t" . bbox.y . "`n" . "W`t" . bbox.w . "`n" . "H`t" . bbox.h

	/*
	bbox.x = 14
	bbox.y = 226
	bbox.w = 582
	bbox.h = 404
	*/

	static offset_x, offset_y
	static page_w, page_h

	/*
	offset_x := -bbox.x+margins_x
	offset_y := -bbox.y+margins_y

	page_w := (bbox.w + margins_x*2) * 10
	page_h := (bbox.h-bbox.y + margins_y*2) * 10
	*/

	offset_x := -bbox.x
	offset_y := -bbox.y

	page_w := bbox.w-bbox.x
	page_h := bbox.h-bbox.y

	page_w += margins_x*2
	page_h += margins_y*2

	offset_x += margins_x
	offset_y += margins_y

	page_w *= 10
	page_h *= 10

	static command
	command =
	( LTrim RTrim Join`s&`s
		cls
		@echo off
		cd /d "%A_WorkingDir%"
		"%GSWIN32C%" -o "%output_file%" -sDEVICE=pdfwrite -g%page_w%x%page_h% -c "<</PageOffset [%offset_x% %offset_y%]>> setpagedevice" -f "%input_file%"
		exit
	)

	RunWait, %ComSpec% /k %command%,, Hide

	return
}

gswin32c_pdf_combine(input_files_list, output_file, convert_to_grayscale := 0){
	global GSWIN32C

	static formatted_files_list, input_file
	formatted_files_list := ""
	Loop, Parse, input_files_list, `n, `r
	{
		input_file := Trim(A_LoopField, " `t""")
		formatted_files_list .= " " . """" input_file """"
	}
	formatted_files_list := Trim(formatted_files_list)

	if (formatted_files_list != "") {
		output_file := RegExReplace(output_file, "i)(\.pdf)+$", "") . ".pdf"
		if FileExist(output_file) {
			FileSetAttrib, -R, %output_file%, 0, 0
			FileDelete, %output_file%
		}

		static greyscale_parameters
		greyscale_parameters := convert_to_grayscale ? "-sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dCompatibilityLevel=1.4" : ""

		RunWait, %GSWIN32C% -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE="%output_file%" -dBATCH %greyscale_parameters% %formatted_files_list%,, Hide

		global COMBINED_FILE
		COMBINED_FILE := output_file
	}
}
