class Edge
{
	static DebugPort := 9222
	
	/*
		Escape a string in a manner suitable for command line parameters
	*/
	CliEscape(Param)
	{
		return """" RegExReplace(Param, "(\\*)""", "$1$1\""") """"
	}
	
	/*

	*/
	GetFullPathName(path) {
		cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
		VarSetCapacity(buf, cc*(A_IsUnicode?2:1))
		DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
		return buf
	}

	/*
		Finds instances of edge in debug mode and the ports they're running
		on. If no instances are found, returns a false value. If one or more
		instances are found, returns an associative array where the keys are
		the ports, and the values are the full command line texts used to start
		the processes.
		
		One example of how this may be used would be to open edge on a
		different port if an instance of edge is already open on the port
		you wanted to used.
		
		```
		; If the wanted port is taken, use the largest taken port plus one
		DebugPort := 9222
		if (Edges := Edge.FindInstances()).HasKey(DebugPort)
			DebugPort := Edges.MaxIndex() + 1
		EdgeInst := new Edge(ProfilePath,,,, DebugPort)
		```
		
		Another use would be to scan for running instances and attach to one
		instead of starting a new instance.
		
		```
		if (Edges := Edge.FindInstances())
			EdgeInst := {"base": Edge, "DebugPort": Edges.MinIndex()}
		else
			EdgeInst := new Edge(ProfilePath)
		```
	*/
	FindInstances()
	{
		static Needle := "--remote-debugging-port=(\d+)"
		Out := {}
		for Item in ComObjGet("winmgmts:")
			.ExecQuery("SELECT CommandLine FROM Win32_Process"
			. " WHERE Name = 'msedge.exe'")
			if RegExMatch(Item.CommandLine, Needle, Match)
				Out[Match1] := Item.CommandLine
		return Out.MaxIndex() ? Out : False
	}
	
	/*
		ProfilePath - Path to the user profile directory to use. Will use the standard if left blank.
		URLs        - The page or array of pages for Edge to load when it opens
		Flags       - Additional flags for edge when launching
		EdgePath  - Path to edge.exe, will detect from start menu when left blank
		DebugPort   - What port should Edge's remote debugging server run on
	*/
	__New(ProfilePath:="", URLs:="about:blank", Flags:="", EdgePath:="", DebugPort:="")
	{
		; Verify ProfilePath
		if (ProfilePath != "" && !InStr(FileExist(ProfilePath), "D")){
			Try FileRemoveDir, % ProfilePath, 1
			FileCreateDir, % ProfilePath
		}
		this.ProfilePath := this.GetFullPathName(ProfilePath)
		
		; Verify EdgePath
		if (EdgePath == "")
			; By using winmgmts to get the path of a shortcut file we fix an edge case where the path is retreived incorrectly
			; if using the ahk executable with a different architecture than the OS (using 32bit AHK on a 64bit OS for example)
			 EdgePath := ComObjGet("winmgmts:").ExecQuery("Select * from Win32_ShortcutFile where Name=""" StrReplace(A_StartMenuCommon "\Programs\Microsoft Edge.lnk", "\", "\\") """").ItemIndex(0).Target
			; FileGetShortcut, %A_StartMenuCommon%\Programs\Microsoft Edge.lnk, EdgePath
		if (EdgePath == "")
			RegRead, EdgePath, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe
		if !FileExist(EdgePath)
			throw Exception("Edge could not be found")
		this.EdgePath := EdgePath
		
		; Verify DebugPort
		if (DebugPort != "")
		{
			if DebugPort is not integer
				throw Exception("DebugPort must be a positive integer")
			else if (DebugPort <= 0)
				throw Exception("DebugPort must be a positive integer")
			this.DebugPort := DebugPort
		}
		
		; Escape the URL(s)
		for Index, URL in IsObject(URLs) ? URLs : [URLs]
			URLString .= " " this.CliEscape(URL)
		
		Run, % this.CliEscape(EdgePath)
		. " --remote-debugging-port=" this.DebugPort
		. (this.ProfilePath ? " --user-data-dir=" this.CliEscape(this.ProfilePath) : "")
		. (Flags ? " " Flags : "")
		. URLString
		,,, OutputVarPID
		this.PID := OutputVarPID
	}
	
	/*
		End Edge by terminating the process.
	*/
	Kill()
	{
		Process, Close, % this.PID
	}
	
	/*
		Queries edge for a list of pages that expose a debug interface.
		In addition to standard tabs, these include pages such as extension
		configuration pages.
	*/
	GetPageList()
	{
		http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		http.open("GET", "http://127.0.0.1:" this.DebugPort "/json")
		http.send()
		return this.JSON.Load(http.responseText)
	}
	
	/*
		Returns a connection to the debug interface of a page that matches the
		provided criteria. When multiple pages match the criteria, they appear
		ordered by how recently the pages were opened.
		
		Key        - The key from the page list to search for, such as "url" or "title"
		Value      - The value to search for in the provided key
		MatchMode  - What kind of search to use, such as "exact", "contains", "startswith", or "regex"
		Index      - If multiple pages match the given criteria, which one of them to return
		fnCallback - A function to be called whenever message is received from the page
	*/
	GetPageBy(Key, Value, MatchMode:="exact", Index:=1, fnCallback:="", fnClose:="")
	{
		Count := 0
		for n, PageData in this.GetPageList()
		{
			if (((MatchMode = "exact" && PageData[Key] = Value) ; Case insensitive
			|| (MatchMode = "contains" && InStr(PageData[Key], Value))
			|| (MatchMode = "startswith" && InStr(PageData[Key], Value) == 1)
			|| (MatchMode = "regex" && PageData[Key] ~= Value))
			&& ++Count == Index)
				return new this.Page(PageData.webSocketDebuggerUrl, fnCallback, fnClose)
		}
	}
	
	/*
		Shorthand for GetPageBy("url", Value, "startswith")
	*/
	GetPageByURL(Value, MatchMode:="startswith", Index:=1, fnCallback:="", fnClose:="")
	{
		return this.GetPageBy("url", Value, MatchMode, Index, fnCallback, fnClose)
	}
	
	/*
		Shorthand for GetPageBy("title", Value, "startswith")
	*/
	GetPageByTitle(Value, MatchMode:="startswith", Index:=1, fnCallback:="", fnClose:="")
	{
		return this.GetPageBy("title", Value, MatchMode, Index, fnCallback, fnClose)
	}
	
	/*
		Shorthand for GetPageBy("type", Type, "exact")
		
		The default type to search for is "page", which is the visible area of
		a normal Edge tab.
	*/
	GetPage(Index:=1, Type:="page", fnCallback:="", fnClose:="")
	{
		return this.GetPageBy("type", Type, "exact", Index, fnCallback, fnClose)
	}
	
	/*
		Connects to the debug interface of a page given its WebSocket URL.
	*/
	class Page
	{
		Connected := False
		ID := 0
		Responses := []
		
		/*
			wsurl      - The desired page's WebSocket URL
			fnCallback - A function to be called whenever message is received
			fnClose    - A function to be called whenever the page connection is lost
		*/
		__New(wsurl, fnCallback:="", fnClose:="")
		{
			this.fnCallback := fnCallback
			this.fnClose := fnClose
			this.BoundKeepAlive := this.Call.Bind(this, "Browser.getVersion",, False)
			
			; TODO: Throw exception on invalid objects
			if IsObject(wsurl)
				wsurl := wsurl.webSocketDebuggerUrl
			
			wsurl := StrReplace(wsurl, "localhost", "127.0.0.1")
			this.ws := {"base": this.WebSocket, "_Event": this.Event, "Parent": this}
			this.ws.__New(wsurl)
			
			while !this.Connected
				Sleep, 50
		}

		Await(promiseId){
			return this.Call("Runtime.awaitPromise", {"promiseObjectId": promiseId
														 ,"returnByValue": Edge.JSON.True}).result
		}
		
		/*
			Calls the specified endpoint and provides it with the given
			parameters.
			
			DomainAndMethod - The endpoint domain and method name for the
				endpoint you would like to call. For example:
				PageInst.Call("Browser.close")
				PageInst.Call("Schema.getDomains")
			
			Params - An associative array of parameters to be provided to the
				endpoint. For example:
				PageInst.Call("Page.printToPDF", {"scale": 0.5 ; Numeric Value
					, "landscape": Edge.Jxon_True() ; Boolean Value
					, "pageRanges: "1-5, 8, 11-13"}) ; String value
				PageInst.Call("Page.navigate", {"url": "https://autohotkey.com/"})
			
			WaitForResponse - Whether to block until a response is received from
				Edge, which is necessary to receive a return value, or whether
				to continue on with the script without waiting for a response.
		*/
		Call(DomainAndMethod, Params:="", WaitForResponse:=True)
		{
			if !this.Connected
				throw Exception("Not connected to tab")
			
			; Use a temporary variable for ID in case more calls are made
			; before we receive a response.
			ID := this.ID += 1
			this.ws.Send(StrReplace(Edge.JSON.Dump({"id": ID, "params": Params ? Params : {}, "method": DomainAndMethod}),"[]",chr(123)chr(125)))
			
			if !WaitForResponse
				return
			
			; Wait for the response
			this.responses[ID] := False
			while !this.responses[ID]
				Sleep, 50
			
			; Get the response, check if it's an error
			response := this.responses.Delete(ID)
			if (response.error)
				throw Exception("Edge indicated error in response",, Edge.JSON.Dump(response.error))
			
			return response.result
		}
		
		/*
			Run some JavaScript on the page. For example:
			
			PageInst.Evaluate("alert(""I can't believe it's not IE!"");")
			PageInst.Evaluate("document.getElementsByTagName('button')[0].click();")
		*/
		Evaluate(JS)
		{
			response := this.Call("Runtime.evaluate",
			( LTrim Join
			{
				"expression": JS,
				"objectGroup": "console",
				"includeCommandLineAPI": Edge.JSON.True,
				"silent": Edge.JSON.False,
				"returnByValue": Edge.JSON.False,
				"userGesture": Edge.JSON.True,
				"awaitPromise": Edge.JSON.False
			}
			))
			
			if (response.exceptionDetails)
				throw Exception(response.result.description, -1
					, Edge.JSON.Dump({"Code": JS
					, "exceptionDetails": response.exceptionDetails}))
			
			return response.result
		}
		
		/*
			Waits for the page's readyState to match the DesiredState.
			
			DesiredState - The state to wait for the page's ReadyState to match
			Interval     - How often it should check whether the state matches
		*/
		WaitForLoad(DesiredState:="complete", Interval:=100)
		{
			while this.Evaluate("document.readyState").value != DesiredState
				Sleep, Interval
		}
		
		/*
			Internal function triggered when the script receives a message on
			the WebSocket connected to the page.
		*/
		Event(EventName, Event)
		{
			; If it was called from the WebSocket adjust the class context
			if this.Parent
				this := this.Parent
			
			; TODO: Handle Error events
			if (EventName == "Open")
			{
				this.Connected := True
				BoundKeepAlive := this.BoundKeepAlive
				SetTimer, %BoundKeepAlive%, 15000
			}
			else if (EventName == "Message")
			{
				data := Edge.JSON.Load(Event.data)
				
				; Run the callback routine
				fnCallback := this.fnCallback
				if (newData := %fnCallback%(data))
					data := newData
				
				if this.responses.HasKey(data.ID)
					this.responses[data.ID] := data
			}
			else if (EventName == "Close")
			{
				this.Disconnect()
				fnClose := this.fnClose
				%fnClose%(this)
			}
		}
		
		/*
			Disconnect from the page's debug interface, allowing the instance
			to be garbage collected.
			
			This method should always be called when you are finished with a
			page or else your script will leak memory.
		*/
		Disconnect()
		{
			if !this.Connected
				return
			
			this.Connected := False
			this.ws.Delete("Parent")
			this.ws.Disconnect()
			
			BoundKeepAlive := this.BoundKeepAlive
			SetTimer, %BoundKeepAlive%, Delete
			this.Delete("BoundKeepAlive")
		}
		
		#Include %A_LineFile%\..\lib\WebSocket.ahk\WebSocket.ahk
	}
	
	#Include %A_LineFile%\..\lib\JSON\Dist\JSON.ahk
}
