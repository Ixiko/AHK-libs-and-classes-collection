;prevent this script from being opened on its own
if A_ScriptName = web.ahk
	ExitApp

;some web operations
web_request(url, method := "GET", params := "", headers := "", redirect := true){
	try {
		params_data := ""
		if !IsObject(params)
			params_data := params
		else
			for key, val in params
				params_data .= params_data = "" ? key "=" UriEncode(val) : "&" key "=" UriEncode(val)
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open(method, url, true)
		if IsObject(headers)
			for key, val in headers
				if (xtrim(key) != "" && xtrim(val) != "")
					whr.SetRequestHeader(xtrim(key), xtrim(val))
		if params_data !=
			whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")		
		if !redirect
			whr.Option(6) := False
		if params_data !=
			whr.Send(params_data)
		else whr.Send()
		whr.WaitForResponse()
		whrResponse := whr.ResponseText
		response := {done : true, text : whrResponse, headers : whr.GetAllResponseHeaders(), error : "No error!"}
		ObjRelease(whr)
		return response
	}
	catch e
	{
		ObjRelease(whr)
		return {done : false, text : "", headers : "", error : e.What " " e.Message " " e.Extra}
	}
}

web_headers(){
	global GLOBAL_SESSION_COOKIES
	cookies_string := ""
	if IsObject(GLOBAL_SESSION_COOKIES)
		for key, val in GLOBAL_SESSION_COOKIES
			cookies_string .= cookies_string = "" ? key "=" val : "; " key "=" val
	headers := Object()
	headers["Cache-Control"] := "no-cache"
	headers["Connection"] := "keep-alive"
	headers["Cookie"] := cookies_string
	headers["DNT"] := "1"
	headers["Host"] := "www.healthjobsnationwide.com"
	headers["Origin"] := "http://www.healthjobsnationwide.com"
	headers["Referer"] := "http://www.healthjobsnationwide.com/"
	headers["Pragma"] := "no-cache"
	headers["Upgrade-Insecure-Requests"] := "1"
	headers["User-Agent"] := "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36"
	return headers
}

web_get_header(headers, key){
	loop, parse, headers, `n
	{
		line = %A_LoopField%
		if line =
			continue
		if line contains %key%
		{
			sep := instr(line, ":")
			line_key := substr(line, 1, sep - 1)
			line_value := substr(line, sep + 1)
			if line_key = %key%
				return xtrim(line_value)
		}
	}
	return ""
}

web_save_cookies(headers){
	global GLOBAL_SESSION_COOKIES
	if !IsObject(GLOBAL_SESSION_COOKIES)
		GLOBAL_SESSION_COOKIES := Object()
	loop, parse, headers, `n
	{
		line = %A_LoopField%
		if line =
			continue
		if line contains Set-Cookie
		{
			line := substr(line, instr(line, ":") + 1)
			parts := StrSplit(line, ";")
			loop, % parts.Length()
			{
				part := parts[A_Index]
				StringSplit, part, part, `=
				if (part1 != "" AND part2 != "")
					GLOBAL_SESSION_COOKIES[xtrim(part1)] := xtrim(part2)
			}
		}
	}
}

web_start_session(byref email, byref password){
	global GLOBAL_SESSION_COOKIES, GLOBAL_SESSION_URL
	GLOBAL_SESSION_COOKIES := ""
	GLOBAL_SESSION_URL := ""
	headers := web_headers()
	params := {userid : email, passwd : password}
	timer := A_TickCount
	request := web_request("http://www.healthjobsnationwide.com/my.php", "POST", params, headers, false)
	if request.done
	{
		web_save_cookies(request.headers)
		GLOBAL_SESSION_URL := web_get_header(request.headers, "location")
		if instr(GLOBAL_SESSION_URL, "http")
		{
			headers := web_headers()
			request := web_request(GLOBAL_SESSION_URL, "GET",, headers)
			if request.done
			{
				web_save_cookies(request.headers)
				response := {done : true, error : "No error!", eta : (A_TickCount - timer)}
			}
			else
				response := {done : false, error : "Load session error: " request.error, eta : (A_TickCount - timer)}
		}
		else
			response := {done : false, error : "Failed to start session.`n`t-Password or email may be invalid`n`t-Missing session URL in headers`n`t-Invalid session cookies", eta : (A_TickCount - timer)}		
	}
	else
		response := {done : false, error : "Login session error: " request.error, eta : (A_TickCount - timer)}
	return response
}

web_get_limits(){
	global GLOBAL_SESSION_URL
	if instr(GLOBAL_SESSION_URL, "http")
	{
		headers := web_headers()
		timer := A_TickCount
		request := web_request(GLOBAL_SESSION_URL "?action=do_search",,, headers)
		if request.done
		{
			RegExMatch(request.text, "\(Your Current Daily Views/Downloads(.+?(?=\)))", found)
			views_pos := RegExMatch(found, "([0-9\.\,]+)", found_views)
			RegExMatch(found, "([0-9\.\,]+)", found_remaining, (views_pos + strlen(found_views)))
			views := RegExReplace(found_views, "[^0-9\.]") * 1
			remaining := RegExReplace(found_remaining, "[^0-9\.]") * 1
			ObjRelease(found_views)
			ObjRelease(found_remaining)
			response := {done : true, views : views, remaining : remaining, error : "", eta : (A_TickCount - timer)}
		}
		else
			response := {done : false, views : 0, remaining : 0, error : request.error, eta : (A_TickCount - timer)}
	}
	else
		response := {done : false, views : 0, remaining : 0, error : "Invalid session details!", eta : (A_TickCount - timer)}
	ObjRelease(request)
	return response
}

web_search(start := 0){
	global GLOBAL_SESSION_URL, GLOBAL_FILTERS_DATA
	if IsObject(GLOBAL_FILTERS_DATA)
	{
		if instr(GLOBAL_SESSION_URL, "http")
		{
			GLOBAL_FILTERS_DATA.start := start
			headers := web_headers()
			headers["X-Requested-With"] := "XMLHttpRequest"
			headers["Referer"] := GLOBAL_SESSION_URL "?action=do_search"
			timer := A_TickCount
			request := web_request(GLOBAL_SESSION_URL "?action=do_search&&sub_page=1", "POST", GLOBAL_FILTERS_DATA, headers)
			if request.done
			{
				web_save_cookies(request.headers)
				search_results := request.text
				items := Object()
				RegExMatch(search_results, "Showing(.*?(?=<))", parse_found)
				parse_count := xnum(RegExReplace(substr(parse_found, instr(parse_found, "of") + 2), "[^0-9\.]"))
				parse_found := "", parse_start := 1
				loop {
					parse_pos := RegExMatch(search_results, "Oi)candidate=([0-9]+)[0-9a-z=&]+sort_order=0\\"">(.+?(?=<))", parse_found, parse_start)
					if (parse_pos < 1 OR !IsObject(parse_found))
						break
					parse_start := parse_pos + strlen(parse_found[0])
					parse_id := xnum(parse_found[1])
					if parse_id > 0
						items.Insert({id : parse_id, name : parse_found[2]})
				}
				response := {done : true, count: parse_count, items : items, error : "No error!", eta : (A_TickCount - timer)}
			}
			else
				response := {done : false, count: 0, items : [], error : request.error, eta : (A_TickCount - timer)}
		}
		else
			response := {done : false, count: 0, items : [], error : "Invalid session details!", eta : (A_TickCount - timer)}
	}
	else
		response := {done : false, count: 0, items : [], error : "Invalid search filters: " filters_data, eta : (A_TickCount - timer)}
	return response
}

web_zip_search(query){
	return web_request("http://www.healthjobsnationwide.com/ajax/city.php?target=" query)
}

web_fetch_csv(start, csv_ids){
	global GLOBAL_SESSION_URL
	if instr(GLOBAL_SESSION_URL, "http")
	{
		headers := web_headers()
		headers["Referer"] := GLOBAL_SESSION_URL "?action=do_search"
		fetch_url := GLOBAL_SESSION_URL "?action=download_resume_csv&start=" start
		fetch_params := {ids : csv_ids}
		timer := A_TickCount
		request := web_request(fetch_url, "POST", fetch_params, headers, false)
		if request.done
		{
			web_save_cookies(request.headers)
			content_type := web_get_header(request.headers, "Content-Type")
			if instr(content_type, "text/csv", false)
			{
				content := xtrim(request.text)
				parts := Object()
				loop, parse, content, `n
				{
					line := xtrim(A_LoopField)
					if A_Index = 1
					{
						line := line ",Resume"
						parts.Insert({line : line, resume_id : "", title : true})
					}
					else if line !=
					{
						RegExMatch(line, "iO)candidate=([0-9]+)", matches)
						resume_id := matches[1]
						if resume_id in %csv_ids%
							parts.Insert({line : line, resume_id : resume_id, title : false})
					}
				}
				response := {done : true, content : content, parts : parts, dtime : "", error : "No error!", eta : (A_TickCount - timer)}
			}
			else
				response := {done : false, content : "", parts : [], dtime : "", error : "Invalid response content type: " content_type, eta : (A_TickCount - timer)}
		}
		else
			response := {done : false, content : "", parts : [], dtime : "", error : request.error, eta : (A_TickCount - timer)}
	}
	else
		response := {done : false, content : "", parts : [], dtime : "", error : "Invalid session details!", eta : (A_TickCount - timer)}
	return response
}

web_get_resume(resume_id){
	global GLOBAL_SESSION_URL
	if instr(GLOBAL_SESSION_URL, "http")
	{
		headers := web_headers()
		headers["Referer"] := GLOBAL_SESSION_URL "?action=do_search"
		RegExMatch(GLOBAL_SESSION_URL, "([0-9a-zA-Z]+?(?=\/$))", SESSION_ID)
		fetch_url := "http://www.healthjobsnationwide.com/word_resume.php/" SESSION_ID "/?candidate=" resume_id
		timer := A_TickCount
		request := web_request(fetch_url,,, headers, false)
		if request.done
		{
			web_save_cookies(request.headers)
			content_type := web_get_header(request.headers, "Content-Type")
			content := request.text
			ext := instr(content_type, "octet", false) ? "doc" : "htm"
			name := resume_id "." ext
			response := {done : true, content : content, name : name, error : "No error!", eta : (A_TickCount - timer)}
		}
		else
			response := {done : false, content : "", name : "", error : request.error, eta : (A_TickCount - timer)}
	}
	else
		response := {done : false, content : "", name : "", error : "Invalid session details!", eta : (A_TickCount - timer)}
	return response
}
