; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=84399
; Author:
; Date:
; for:     	AHK_L

/*


*/

class RebrandlyApi
{
	static RebrandlyApiCallDelay := 200	;number in milliseconds to wait between calls
	static RebrandlyApiLastCallTimestamp := 0	;Timestamp of last returned call, to be used in conjunction with RebrandlyApiCallDelay
	static rb := "https://api.rebrandly.com/v1/"
	static Account := []
	static Brands := []
	static Brands_id := []
	static apiKey := ""
	static tags := []
	static tagColors := []
	static tagsInit := 0

	registerApiKey(apiKey,getAccount := 1){
		this.apiKey := apiKey
		if (getAccount = 1)
			this.getAccount(1)
		return
	}

	setCallDelay(delay := ""){	;adjusts how long in milliseconds the class waits between API calls; default = 200, minimum = 100 ;*[Rebrandly]
		if (!IfIs(delay,"integer"))
			delay := 200
		else if (delay < 100)
			delay := 100
		return RebrandlyApiCallDelay := delay
	}

	callDelay(){
		;msgbox % this.RebrandlyApiLastCallTimestamp

		Loop{
			If ((A_NowUTC - this.RebrandlyApiLastCallTimestamp) > this.RebrandlyApiCallDelay)
				return
			else
				Sleep, 0
		}
	}

	call(byref url, byref InOutData := "", byref LoginHeaders := "",byref debug := 0){
		this.callDelay()	;wait until sufficient time has elapsed
		;msgbox
		If !IsObject(LoginHeaders)
			LoginHeaders := []

		LoginHeaders["Content-Type"] := "application/json"
		LoginHeaders["apikey"] := this.apikey

		For k,v in LoginHeaders
			If !IsObject(v)
				InOutHeaders .= k ": " v "`n"
		else
			InOutHeaders .= k ": " JSON.dump(v) "`n"	;dunno if this is needed, but whatever

		;todo	-	gracefully and incrementally delay in the event of connection failure

		if (debug != 3)
			r := WinHttpRequest(url, InOutData, InOutHeaders, "Timeout: 1`nNO_AUTO_REDIRECT")	;query api
		this.RebrandlyApiLastCallTimestamp := A_TickCount	;update info used in this.callDelay()

		return this.errorHandler(InOutData,InOutHeaders,debug)
	}


	errorHandler(byref jsonStr, byref headers, debug := 0){

		HeaderObj := []
		headersPreObj := StrSplit(headers,"`n","`r",2)
		HeaderObj["Status Code"] := RegExMatchGlobal(headersPreObj[1],"^.+ (\d+)",0)[1,1]
		For k,v in StrSplit(headersPreObj[2],"`n","`r")
		{
			if (v != "")
				line := StrSplit(v,":",,2)
			HeaderObj[line[1]] := Trim(line[2])
		}

		;todo	-	catch e
		Try
			DataObj := Json.Load(jsonStr)

		if (debug = 1)
			msgbox % clipboard := st_printarr(DataObj)
		else if (debug = 2)
			msgbox % clipboard := st_printarr(HeaderObj)
		return DataObj
	}

	/*	account
	*/
	getAccount(associate := 1){
		;LoginHeaders := "apikey: " this.apiKey

		retObj := this.call(this.rb "account",InOutData,LoginHeaders,0)
		if (associate = 1)
			This.associateBrands()
		return retObj
	}


	/*	domain
	*/
	getDomains(){
		;todo	-	paginate domains
		return this.call(this.rb "domains",InOutData,LoginHeaders)
	}

	associateBrands(){	;collects the brands->ids into an easy to reference array
		;todo	-	paginate domains
		DataObj := this.call(this.rb "domains",InOutData,LoginHeaders)
		Loop, % DataObj.count()
		{
			Record := DataObj[a_index]
			this.Brands[Record["fullname"]] := Record["id"]
			this.Brands_id[Record["id"]] := Record["fullname"]
		}
	}

	/*	link
	*/
	createLink(destination,slashtag := "", domainFullName := "", title := "", description := "",workspace := "", tagObj := "", tagColorObj := ""){
		if (domainFullName = "")  || (!this.Brands.HasKey(domainFullName))
			domainFullName := "rebrand.ly"	;fallback on rebrandly in the event of mismatched keys or other error

		If (workspace != "")
			LoginHeaders := []
			,LoginHeaders["workspace"] := workspace


		DestObj := []
		,DestObj["domain","id"] := this.Brands[domainFullName]
		,DestObj["domain","fullName"] := this.Brands_id[this.Brands[domainFullName]]
		,DestObj["slashtag"] := slashtag
		,DestObj["title"] := SubStr(title,1,255)	;max 255 characters
		,DestObj["description"] := SubStr(description,1,2000)	;max 2000 characters
		,DestObj["destination"] := destination
		;msgbox % st_printarr(DestObj)

		OutObj := this.call(this.rb "links",json.dump(DestObj),LoginHeaders)
		if IsObject(tagObj)
			this.attachTags(OutObj["id"],tagObj,tagColorObj,workspace)

		return OutObj
	}

	gatherLinks(domainId := "", domainFullName := "", slashtag := "", creatorId := "", orderBy := "",orderDir := "", favourite := "", workspace := "", maxResults := "", last := ""){
		;maxResults is NOT limit. maxResults is the maximum amount of results *this* method will return.

		retObj := []

		If (workspace != "")
			LoginHeaders := []
			,LoginHeaders["workspace"] := workspace

		ParamObj := []
		,ParamObj["orderBy"] := orderBy
		,ParamObj["orderDir"] := orderDir
		,ParamObj["domain.id"] := domainId
		,ParamObj["domain.fullName"] := domainFullName
		,ParamObj["creator.id"] := creatorId	;accepts comma-delimited list
		,ParamObj["favourite"] := favourite
		,ParamObj["last"] := last
		,ParamObj["slashtag"] := slashtag


		;ParamObj["limit"] := 1	; only for testing
		Loop
		{
			tempObj := this.call(this.rb "links" this.UrlParams(ParamObj),,LoginHeaders.clone())

			If (tempObj.count() = 0)
				Break

			Loop, % tempObj.count()
			{
				Record := tempObj[a_index]
				retObj.push(Record)
				;msgbox % retObj.count()
				If (retObj.count() = maxResults)
					Break 2
			}
			If (slashtag != "")	;infinite loop if there's a slashtag
				return retObj

			ParamObj["last"] := Record["id"]	;used in pagination
		}
		return retObj
	}

	/*	tag
	*/
	attachTags(linkId,tagObj,tagColorObj := "",workspace := ""){
		/*
			"tagObj" and "tagColorObj" must be 2D arrays

			key names don't matter to tagObj, will use the value

			tagColorObj is in the format...		tagColorObj[tagName] := FFFFFF
		*/

		If !IsObject(tagObj)
			return

		If (workspace != "")
			LoginHeaders := []
			,LoginHeaders["workspace"] := workspace


		this.queryLinkTags(linkId, workspace)	;hopefully reduce future issues... I have no idea if it's required.

		For k,v in tagObj
		{
			tagName := v

			If !HasVal(this.tags.clone(),tagName)	;want to avoid duplicating names
			{
				;msgbox,here

				this.createTag(tagName,tagColor,workspace)
				;tagId := HasVal(this.tags,tagName)
				;msgbox % HasVal(this.tags,tagName)

			}

			tagId := HasVal(this.tags,tagName)



			checkObj := this.call(this.rb "links/" linkId "/tags/" HasVal(this.tags,tagName),InOutData,LoginHeaders)
			;MsgBox % st_printarr(checkobj)
			If (checkObj["Message"] = "Not Found")
				checkObj := this.call(this.rb "links/" linkId "/tags/" HasVal(this.tags,tagName),InOutData,LoginHeaders)	;sometimes required... whatever.
			;MsgBox % st_printarr(checkobj)
		}


	}

	createTag(tagName, tagColor := "", workspace := ""){
		If !tagsInit
			this.initTags()

		If (HasVal(this.tags,tagName) != 0)	;want to avoid duplicating names
			return

		If (workspace != "")
			LoginHeaders := []
			,LoginHeaders["workspace"] := workspace

		InOutData := []
		InOutData["name"] := tagName
		If RegExMatch(tagColor,"[a-fA-F0-9]{6}")
			InOutData["color"] := tagColor

		newTagObj := this.call(this.rb "tags",Json.dump(InOutData),LoginHeaders)

		;add the new tag data to the class's reference object
		this.tags[newTagObj["id"]] := newTagObj["name"]
		If newTagObj.HasKey("color")
			this.tagColors[newTagObj["id"]] := newTagObj["color"]
		return newTagObj
	}

	initTags(){
		tagPreObj := this.gatherTags()
		Loop, % tagPreObj.count()
		{
			Record := tagPreObj[a_index]
			this.tags[Record["id"]] := Record["name"]
			if Record.HasKey("color")
				this.tagColors[Record["id"]] := Record["color"]
		}
		this.initTags := 1
	}

	queryLinkTags(linkId, workspace := ""){
		If (workspace != "")
			LoginHeaders := []
			,LoginHeaders["workspace"] := workspace

		return this.call(this.rb "links/" linkId "/tags/",InOutData,LoginHeaders)
	}

	gatherTags(orderBy := "",orderDir := "", workspace := "", linkId := ""){
		retObj := []

		If (workspace != "")
			LoginHeaders := []
			,LoginHeaders["workspace"] := workspace

		ParamObj := []
		,ParamObj["orderBy"] := orderBy
		,ParamObj["orderDir"] := orderDir

		;ParamObj["limit"] := 1	; only for testing
		Loop
		{
			tempObj := this.call(this.rb "tags" this.UrlParams(ParamObj),,LoginHeaders.clone())

			If (tempObj.count() = 0)
				Break

			Loop, % tempObj.count()
			{
				Record := tempObj[a_index]
				retObj.push(Record)
			}
			ParamObj["last"] := Record["id"]	;used in pagination
		}
		return retObj
	}

	;called internally
	UrlParams(ParamObj){
		for k,v in ParamObj
			ParamObj[k] := v

		for k,v in ParamObj
		{
			if (k = "") || (v = "")
				Continue
			if (ParamStr != "")
				ParamStr .= "&"
			ParamStr .= k "=" v
		}
		if (ParamStr != "")
			ParamStr := "?" ParamStr
		return ParamStr
	}

}