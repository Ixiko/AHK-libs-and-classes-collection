cURL_Download(url, ioData, ByRef ioHdr, options, useFallback = true, critical = false, binaryDL = false, errorMsg = "", ByRef reqHeadersCurl = "", handleAccessForbidden = true, ByRef returnCurl = false) {
	/*	Credits: POE-TradeMacro
		https://github.com/PoE-TradeMacro/POE-TradeMacro


		url		= download url
		ioData	= uri encoded postData 
		ioHdr	= array of request headers
		options	= multiple options separated by newline (currently only "SaveAs:",  "Redirect:true/false")
		
		useFallback = Use UrlDownloadToFile if curl fails, not possible for POST requests or when cookies are required 
		critical	= exit macro if download fails
		binaryDL	= file download (zip for example)
		errorMsg	= optional error message, will be added to default message
		reqHeadersCurl = returns the returned headers from the curl request 
		handleAccessForbidden = "true" throws an error message if "403 Forbidden" is returned, "false" prevents it, returning "403 Forbidden" to enable custom error handling
	*/
	global PROGRAM

	; https://curl.haxx.se/download.html -> https://bintray.com/vszakats/generic/curl/
	Loop, 2 
	{
		curl		:= """" PROGRAM.CURL_EXECUTABLE """ "
		headers	:= ""
		cookies	:= ""
		For key, val in ioHdr {
			val := Trim(RegExReplace(val, "i)(.*?)\s*:\s*(.*)", "$1:$2"))
			If (A_Index = 2 and RegExMatch(val, "i)^Host:.*")) {
				; make sure that the host header is not included on the second try (empty first response)
			} Else {
				headers .= "-H """ val """ "	
			}		
			
			If (RegExMatch(val, "i)^Cookie:(.*)", cookie)) {
				cookies .= cookie1 " "		
			}
		}
		cookies := StrLen(cookies) ? "-b """ Trim(cookies) """ " : ""
		
		redirect := "L"
		PreventErrorMsg := false
		validateResponse := 1
		If (StrLen(options)) {
			Loop, Parse, options, `n 
			{
				If (RegExMatch(A_LoopField, "i)SaveAs:[ \t]*\K[^\r\n]+", SavePath)) {
					commandData	.= " " A_LoopField " "
					commandHdr	.= ""	
				}
				If (RegExMatch(A_LoopField, "i)Redirect:\sFalse")) {
					redirect := ""
				}
				If (RegExMatch(A_LoopField, "i)PreventErrorMsg")) {
					PreventErrorMsg := true
				}
				If (RegExMatch(A_LoopField, "i)RequestType:(.*)", match)) {
					requestType := Trim(match1)
				}
				If (RegExMatch(A_LoopField, "i)ReturnHeaders:(.*skip.*)")) {
					skipRetHeaders := true
				}
				If (RegExMatch(A_LoopField, "i)TimeOut:(.*)", match)) {
					timeout := Trim(match1)
				}
				If (RegExMatch(A_LoopField, "i)ValidateResponse:(.*)", match)) {
					If (Trim(match1) = "false") {
						validateResponse := 0
					}				
				}	
			}			
		}
		If (not timeout) {
			timeout := 30
		}

		e := {}
		Try {		
			commandData	:= ""		; console curl command to return data/content 
			commandHdr	:= ""		; console curl command to return headers
			If (binaryDL) {
				commandData .= " -" redirect "Jkv "		; save as file
				If (SavePath) {
					commandData .= "-o """ SavePath """ "	; set target destination and name
				}
			} Else {
				commandData .= " -" redirect "ks --compressed "
				If (requestType = "GET") {
					commandHdr  .= " -k" redirect "s "
				} Else {
					commandHdr  .= " -I" redirect "ks "
				}
			}			
			
			If (StrLen(headers)) {
				If (not requestType = "GET") {
					commandData .= headers
					commandHdr  .= headers	
				}				
				If (StrLen(cookies)) {
					commandData .= cookies
					commandHdr  .= cookies
				}
			}
			If (StrLen(ioData) and not requestType = "GET") {
				If (requestType = "POST") {
					commandData .= "-X POST "
				}
				commandData .= "--data """ ioData """ "
			} Else If (StrLen(ioData)) {
				url := url "?" ioData
			}
			
			If (binaryDL) {
				commandData	.= "--connect-timeout " timeout " "
				commandData	.= "--connect-timeout " timeout " "
			} Else {				
				commandData	.= "--max-time " timeout " "
				commandHdr	.= "--max-time " timeout " "
			}

			; get data
			html	:= StdOutStream(curl """" url """" commandData)
			;html := ReadConsoleOutputFromFile(commandData """" url """", "commandData") ; alternative function
			
			If (returnCurl) {
				returnCurl := "curl " """" url """" commandData
			}
			
			; get return headers in seperate request
			If (not binaryDL and not skipRetHeaders) {
				If (StrLen(ioData) and not requestType = "GET") {
					commandHdr := curl """" url "?" ioData """" commandHdr		; add payload to url since you can't use the -I argument with POST requests					
				} Else {
					commandHdr := curl """" url """" commandHdr
				}
				ioHdr := StdOutStream(commandHdr)
				;ioHrd := ReadConsoleOutputFromFile(commandHdr, "commandHdr") ; alternative function
			} Else {
				ioHdr := html
			}
			
			reqHeadersCurl := commandHdr
		} Catch e {

		}
		
		; check if response has a good status code or is valid JSON (shouldn't be an erroneous response in that case)
		goodStatusCode := RegExMatch(ioHdr, "i)HTTP\/1.1 (200 OK|302 Found)")
		Try {
			isJSON := isObject(JSON.Load(ioHdr))
		} Catch er {
			
		}
		
		If ((Strlen(ioHdr) and goodStatusCode) or (StrLen(ioHdr) and isJSON) or not validateResponse) {		
			Break	; only go into the second loop if the respone is empty or has a bad status code (possible problem with the added host header)
		}
	}

	;goodStatusCode := RegExMatch(ioHdr, "i)HTTP\/1.1 (200 OK|302 Found)")
	If (RegExMatch(ioHdr, "i)HTTP\/1.1 403 Forbidden") and not handleAccessForbidden) {
		PreventErrorMsg		:= true
		handleAccessForbidden	:= "403 Forbidden"
	}
	If (!binaryDL) {
		; Use fallback download if curl fails
		If ((not goodStatusCode or e.what) and useFallback) {
			cURL_DownloadFallback(url, html, e, critical, ioHdr, PreventErrorMsg)
		} Else If (not goodStatusCode and e.what) {
			cURL_ThrowError(e, false, ioHdr, PreventErrorMsg)
		}
	}
	; handle binary file downloads
	Else If (not e.what) {
		; check returned request headers
		ioHdr := cURL_ParseReturnedHeaders(ioHdr)
		
		goodStatusCode := RegExMatch(ioHdr, "i)HTTP\/1.1 (200 OK|302 Found)")
		If (not goodStatusCode) {
			MsgBox, 16,, % "Error downloading file to " SavePath
			Return "Error: Wrong Status"
		}
		
		; compare file sizes
		FileGetSize, sizeOnDisk, %SavePath%
		RegExMatch(ioHdr, "i)Content-Length:\s(\d+)(k|m)?", size)
		size := Trim(size1)
		If (Strlen(size2)) {
			size := size2 = "k" ? size * 1024 : size * 1024 * 1024
			sizeVariation := Round(size * 99.8 / 100) - size
		}		
		
		; give the comparison some leeway in case of the extracted filesize from the response headers being 
		; imprecise (shown in kilobyte/megabyte)
		If (sizeVariation) {
			If (not (sizeOnDisk > (size - sizeVariation) and sizeOnDisk < (size + sizeVariation))) {
				html := "Error: Different Size"
			}
		} Else {
			If (size != sizeOnDisk) {
				html := "Error: Different Size"
			}
		}
	} Else {
		cURL_ThrowError(e, false, ioHdr, PreventErrorMsg)
	}
	
	Return html
}

cURL_ParseReturnedHeaders(output) {
	headerGroups	:= []
	headerGroup	:= ""

	Pos		:= 0
	While Pos := RegExMatch(output, "is)\[5 bytes data.*?({|$)", match, Pos + (StrLen(match) ? StrLen(match) : 1)) {
		headerGroups.push(match)
		LastPos := Pos
		LastMatch := match
	}
	
	If (not headerGroups.Length()) {
		RegExMatch(output, "is).*(HTTP\/1.1.*)", dlStats)
		dlStats := dlStats1
		headerGroups.push(dlStats)
	} Else {
		LastPos := LastPos + StrLen(LastMatch)
		RegExMatch(output, "is).*", dlStats, LastPos ? LastPos : 0)
	}

	i := headerGroups.Length()
	Loop, % i {
		If (RegExMatch(headerGroups[i], "is)Content-Length")) {
			headerGroup := headerGroups[i]
			break
		}		
		i--
	}

	out := ""
	If (StrLen(headerGroup)) {
		headerGroup := RegExReplace(headerGroup, "im)^<|\[5 bytes data\]|^{")
		Loop, parse, headerGroup, `n, `r 
		{
			If (StrLen(Trim(A_LoopField))) {
				out .= Trim(A_LoopField)
			}
		}
	} Else {
		; workaround for missing content-length		
		fLength := ""
		Loop, parse, dlStats, `n`r 
		{
			If (StrLen(Trim(A_LoopField))) {
				If (RegExMatch(Trim(A_LoopField), "^\d*\s*(\d+k?m?).*(\d|\dk|\dm)$", length)) {
					fLength := length1
				}
			}
			If (RegExMatch(Trim(A_LoopField), ".*Connection.*left intact.*", length)) {
				
			}
		}
		
		RegExMatch(output, "i)HTTP\/1.1 (200 OK|302 Found)", code)		
		out := code "`n"
		out .= "Content-Length: " fLength
	}

	Return out
}

; only works if no post data required/not downloading for example .zip files
cURL_DownloadFallback(url, ByRef html, e, critical, errorMsg, PreventErrorMsg = false) {
	ErrorLevel := 0
	fileName := RandomStr() . ".txt"
	
	UrlDownloadToFile, %url%, %A_ScriptDir%\temp\%fileName%
	If (!ErrorLevel) {
		FileRead, html, %A_ScriptDir%\temp\%fileName%
		FileDelete, %A_ScriptDir%\temp\%fileName%
	} Else If (!PreventErrorMsg) {
		SplashTextOff
		msg 		:= "Error while downloading <" url "> using UrlDownloadToFile (cURL_DownloadFallback)."
		errorMsg	:= StrLen(errorMsg) ? msg "`n`n" errorMsg : msg
		cURL_ThrowError(e, critical, errorMsg)
	}
}

cURL_ThrowError(e, critical = false, errorMsg = "", PreventErrorMsg = false) {
	If (PreventErrorMsg) {
		Return
	}
	
	msg := "Exception thrown (download)!"
	If (e.what) {
		msg .= "`n`nwhat: " e.what "`nfile: " e.file "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra	
	}
	msg := StrLen(errorMsg) ? msg "`n`n" errorMsg : msg
	
	If (RegExMatch(errorMsg, "i)HTTP\/1.1 403 Forbidden")) {
		cookiesRequired := "Access forbidden, a likely reason for this is that necessary cookies are missing.`nYou may have to use"
	}
	msg := StrLen(cookiesRequired) ? msg "`n`n" cookiesRequired : msg
	
	If (critical) {
		MsgBox, 16,, % msg
	} Else {
		MsgBox, % msg
	}	
}
