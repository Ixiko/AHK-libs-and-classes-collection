#Include, %A_LineFile%\..\lib\Edge\Edge.ahk
class SpotifyAPI{
    static js_find_declr:= "let request=e=>{if(e&&this._cache)return this._cache;let t;return'webpackJsonp'in window?t=window.webpackJsonp.push([[],{[this.id]:(e,t,i)=>e.exports=i},[[this.id]]]):'webpackChunkdiscord_app'in window&&window.webpackChunkdiscord_app.push([[this.id],{},e=>t=e]),this._cache=t},FindModule=e=>{const i=request(e),s=[];for(let t in i.c){var n=i.c[t].exports;if(n&&n.__esModule&&n.default&&n.default[e])return n.default;if(n&&n[e])return n}return t?s:s.shift()};"
    , js_getUserId:= "FindModule('getActiveSocketAndDevice').getActiveSocketAndDevice()?.socket.accountId;"
    , js_getToken:= "FindModule('SpotifyAPI').getAccessToken('{}');"
    
    __New(SpotifyUserName:=""){
        this.EdgeProfile:= "spotifyEdgeProfile"
        this.spotifyUserName:= SpotifyUserName
        FileCreateDir, % A_ScriptDir "\" this.EdgeProfile
        authCheck:
        sleep 200
        if(!this.isDiscordAuthed()){
            this.discordLogin()
            Goto, authCheck
        }
        this.edgeInst := new Edge(A_ScriptDir "\" this.EdgeProfile,"https://discord.com/login","--no-first-run --headless --disable-gpu")
        this.pageInst := this.edgeInst.GetPageByURL("discord.com", "contains")
        this.pageInst.WaitForLoad()
        this.updateToken()
        this.ws:= new SpotifyWebSocket(this.token)
        OnExit(ObjBindMethod(this,"onExit"))
        funcObj:= objBindMethod(this,"updateToken")
        SetTimer, % funcObj, 60000
    }

    CallAPI(method, endPoint, body:=""){
        url:= "https://api.spotify.com/v1/" . endpoint
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		http.Open(method, url, false)
        http.SetRequestHeader("Authorization", "Bearer " . this.token)
        http.Send(body)
        Try reponse:= Edge.JSON.load(http.ResponseText)
        if(http.Status == 401){
            this.updateToken()
            return this.CallAPI(method, endPoint, body)
        }else if(http.Status > 299){ ;error
            throw, Exception(Format("(Status code: {1:}) {2:}: {3:}", http.Status, reponse.Error.Reason, reponse.Error.Message))
        }
        return reponse
    }

    ResumePlayback(){
        return this.CallAPI("PUT", "me/player/play")
    }

    PausePlayback(){
        return this.CallAPI("PUT", "me/player/pause")
    }

    TogglePlayback() {
		return ((this.GetCurrentPlaybackInfo()["is_playing"] = 0) ? (this.ResumePlayback()) : (this.PausePlayback()))
	}

    SetVolume(volume, IncDec:=0){
        if(IncDec)
            volume:= this.GetVolume() + volume
        volume:= Min(Max(volume, 0), 100) ;to make sure it stays between 0 and 100
        response:= this.CallAPI("PUT", "me/player/volume?volume_percent=" . volume)
        return response=""? volume : response
    }

    GetVolume(){
        return this.GetCurrentPlaybackInfo().device.volume_percent
    }

    GetCurrentPlaybackInfo(){
        return this.CallAPI("GET", "me/player")
    }

    GetCurrentTrackInfo(){
        return this.CallAPI("GET", "me/player/currently-playing?market=from_token")
    }

    NextTrack(){
        return this.CallAPI("POST", "me/player/next")
    }

    PreviousTrack(){
        return this.CallAPI("POST", "me/player/previous")
    }

    isDiscordAuthed(){
        timeTicked:= A_TickCount
        this.authState:= -1
        edg := new Edge(A_ScriptDir "\" this.EdgeProfile,"https://discord.com/login","--no-first-run --mute-audio --headless --disable-gpu")
        page := edg.GetPageByURL("discord.com", "contains",, ObjBindMethod(this, "onPageMsg"))
        page.Call("Console.enable")
        while (this.authState == -1 && A_TickCount - timeTicked < 10000)
            sleep 500
        if(this.authState == -1)
            throw, Exception("Failed to authenticate")
        edg.Kill()
        page.Disconnect()
        return this.authState
    }

    onPageMsg(event){
        if(event.Method == "Console.messageAdded"){
            if(InStr(event.params.message.text,"handshake complete")) ; Transitioning to /app
                this.authState:= 0
            else if (InStr(event.params.message.text,"Transitioning to /app"))
                this.authState:= 1
        }
    }

    discordLogin(){
        this.authState:=0
        MsgBox, 65, SpotifyNonPremiumAPI, You need to sign in to your discord account
        IfMsgBox, Cancel
            Throw, Exception("Could not sign in to discord")
        Try{
            edg := new Edge(A_ScriptDir "\" this.EdgeProfile,"","--no-first-run --new-window --windows-size=500,500 --app=https://discord.com/login")
            page := edg.GetPageByURL("discord.com", "contains",, ObjBindMethod(this, "onPageMsg"))
            page.Call("Console.enable")
            page.WaitForLoad()
            while (this.authState != 1)
                sleep 500
            page.WaitForLoad()
            Try page.Call("Browser.close")
            edg.Kill()
            page.Disconnect()
        }catch err {
            MsgBox,16, SpotifyNonPremiumAPI, % "An error occured: " . err.message
            return 0
        }
        MsgBox, 64, SpotifyNonPremiumAPI, Sign in successful
        return 1
    }

    updateToken(){
        Try this.pageInst.Evaluate("FindModule")
        catch err { ;function not defined
            this.pageInst.Evaluate(this.js_find_declr)
        }
        if(!this.spotifyUserName)
            this.spotifyUserName:= this.getUserName()
        promise:= this.pageInst.Evaluate(Format(this.js_getToken, this.spotifyUserName)).objectId
        this.token:= this.pageInst.Await(promise).value.body.access_token
    }

    getUserName(){
        static retries:= 0
        userNameLbl:
        Try val:= this.pageInst.Evaluate(this.js_getUserId).value
        if(!val || val = "undefined"){
            if(retries++ < 3){
                Sleep, 1000
                Goto, userNameLbl
            }
            MsgBox, 49, SpotifyNonPremiumAPI, Could not fetch your Spotify username`nPlay anything on spotify then click OK
            IfMsgBox, Cancel
                Throw, "Could not fetch your Spotify username"
            sleep 1000
            Goto, userNameLbl
        }
        retries:= 0
        return val
    }

    onExit(){
        this.edgeInst.Kill()
        this.pageInst.Disconnect()
    }

    class SpotifyWebSocket{ ; https://github.com/G33kDude/WebSocket.ahk
        __New(token)
        {
            static wb
            WS_URL:= "wss://dealer.spotify.com/?access_token=" token
            ; Create an IE instance
            Gui, +hWndhOld
            Gui, New, +hWndhWnd
            this.hWnd := hWnd
            Gui, Add, ActiveX, vWB, Shell.Explorer
            Gui, %hOld%: Default
            
            ; Write an appropriate document
            WB.Navigate("about:<!DOCTYPE html><meta http-equiv='X-UA-Compatible'"
            . "content='IE=edge'><body></body>")
            while (WB.ReadyState < 4)
                sleep, 50
            this.document := WB.document
            
            ; Add our handlers to the JavaScript namespace
            this.document.parentWindow.ahk_savews := this._SaveWS.Bind(this)
            this.document.parentWindow.ahk_event := this._Event.Bind(this)
            this.document.parentWindow.ahk_ws_url := WS_URL
            
            ; Add some JavaScript to the page to open a socket
            Script := this.document.createElement("script")
            Script.text := "ws = new WebSocket(ahk_ws_url);`n"
            . "ws.onopen = function(event){ ahk_event('Open', event); };`n"
            . "ws.onclose = function(event){ ahk_event('Close', event); };`n"
            . "ws.onerror = function(event){ ahk_event('Error', event); };`n"
            . "ws.onmessage = function(event){ ahk_event('Message', event); };"
            this.document.body.appendChild(Script)
        }
        
        ; Called by the JS in response to WS events
        _Event(EventName, Event)
        {
            this["On" EventName](Event)
        }
        
        ; Sends data through the WebSocket
        Send(Data)
        {
            this.document.parentWindow.ws.send(Data)
        }
        
        ; Closes the WebSocket connection
        Close(Code:=1000, Reason:="")
        {
            this.document.parentWindow.ws.close(Code, Reason)
        }
        
        ; Closes and deletes the WebSocket, removing
        ; references so the class can be garbage collected
        Disconnect()
        {
            if this.hWnd
            {
                this.Close()
                Gui, % this.hWnd ": Destroy"
                this.hWnd := False
            }
        }
    }
}