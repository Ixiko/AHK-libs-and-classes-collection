#MaxThreads 2
class Spotify {
	__New() {
		this.Util := new Util(this)
		this.Player := new Player(this)
		this.Library := new Library(this)
		this.Albums := new Albums(this)
		this.Artists := new Artists(this)
		this.Tracks := new Tracks(this)
		this.Playlists := new Playlists(this)
		this.CurrentUser := new user(JSON.load(this.Util.CustomCall("GET", "me")), this, true)
		this.Users := new Users(this)
	}
}
class Util {
	static MAX_RETRY := 3

	__New(ByRef ParentObject) {
		this.ParentObject := ParentObject
		this.RefreshLoc := "HKCU\Software\SpotifyAHK"
		this.StartUp()
		this.AuthRetries := 0 ; Count of how many times we have retried auth
	}
	StartUp() {
		if (this.AuthRetries >= this.MAX_RETRY) {
			MsgBox, % "Spotify.ahk authorization attempt cap met, aborting"
			Spotify.Util := ""
			this := ""
			Spotify := ""
			return
		}
	
		RegRead, refresh, % this.RefreshLoc, refreshToken
		if (refresh) {
			this.RefreshTempToken(refresh)
		} else {
			this.auth := ""
			paths := {}
			paths["/callback"] := this["authCallback"].bind(this)
			paths["404"] := this["NotFound"]
			server := new HttpServer()
			server.SetPaths(paths)
			server.Serve(8000)
			Run, % "https://accounts.spotify.com/en/authorize?client_id=9fe26296bb7b4330ac59339efd2742b0&response_type=code&redirect_uri=http:%2F%2Flocalhost:8000%2Fcallback&scope=user-modify-playback-state%20user-read-currently-playing%20user-read-playback-state%20user-library-modify%20user-library-read%20user-read-email%20user-read-private%20user-read-birthdate%20user-follow-read%20user-follow-modify%20playlist-read-private%20playlist-read-collaborative%20playlist-modify-public%20playlist-modify-private%20user-read-recently-played%20user-top-read"
			loop {
				Sleep, -1
			} until (this.WebAuthDone() = true)
			this.FetchTokens()
		}
	}
	
	; Timeout methods
	
	SetTimeout() {
		TimeOut := A_Now
		EnvAdd, TimeOut, 1, hours
		this.TimeOut := TimeOut
	}
	CheckTimeout() {
		if (this.TimeLastChecked = A_Min) {
			return
		}
		this.TimeLastChecked := A_Min
		if (A_Now > this.TimeOut) {
			RegRead, refresh, % this.RefreshLoc, refreshToken
			this.RefreshTempToken(refresh)
		}
	}
	
	; API token operations
	
	RefreshTempToken(refresh) {
		refresh := this.DecryptToken(refresh)
		arg := {1:{1:"Content-Type", 2:"application/x-www-form-urlencoded"}, 2:{1:"Authorization", 2:"Basic OWZlMjYyOTZiYjdiNDMzMGFjNTkzMzllZmQyNzQyYjA6ZWNhNjU2ZDFkNTczNDNhOTllMWJjNWVmODQ0YmY2NGM="}}
		
		try {
			response := this.CustomCall("POST", "https://accounts.spotify.com/api/token?grant_type=refresh_token&refresh_token=" . refresh, arg, true)
		}
		catch E {
			if (InStr(E.What, "HTTP response code not 2xx")) {
				this.AuthRetries++
				MsgBox, % "Spotify.ahk could not get a valid refresh token from the Spotify API, retrying authorization."
				RegWrite, REG_SZ, % this.RefreshLoc, refreshToken, % "" ; Wipe the stored (bad) refresh token
				return this.StartUp() ; Retry auth and hope we get a valid refresh token this time
			}
		}
		
		if (InStr(response, "refresh_token")) {
			this.SaveRefreshToken(response)
		}

		try {
			Response := JSON.Load(Response) ; Oh god, this old code is really bad. If anyone bothers reading this, please just
			; use the rewrite
		}
		catch E {
			MsgBox, % "Spotify.ahk could not get a valid refresh token from the Spotify API, retrying authorization."
			this.AuthRetries++
			return this.StartUp()
		}
		
		ForceError := false
		
		if (ForceError) {
			Response["error_description"] := "Invalid refresh token"
		}
			
		if (Response["access_token"] && !ForceError) {
			; If we got an access token, we can set the flag that we're authorized
			this.authState := true
			this.Token := Response["access_token"] ; And store the new access token
			this.SetTimeout() ; And set when the new access token will expire
		}
		else {
			; Else if they didn't give us a new access token, something went wrong
			this.authState := false ; Set that auth is *not* complete
			this.AuthRetries++
			
			if (Response["error_description"] = "Invalid refresh token") {
				RegWrite, REG_SZ, % this.RefreshLoc, refreshToken, % "" ; Wipe the stored (bad) refresh token
				MsgBox, % "Spotify.ahk could not get a valid refresh token from the Spotify API, retrying authorization."
				return this.StartUp() ; Retry auth and hope we get a valid refresh token this time
			}
			
			Throw {"Message": Response["error_description"], "What": Response["error"], "File": A_LineFile, "Line": A_LineNumber}
			;this.StartUp() ; Call startup after wiping the stored refresh token, so we can try to get a new valid one
		}
	}
	FetchTokens() {
		if (this.fail) {
			ErrorLevel := 1
			return
		}
		if (this.authState) {
			return
		}
		AHKsock_Close(-1)
		arg := {1:{1:"Content-Type", 2:"application/x-www-form-urlencoded"}, 2:{1:"Authorization", 2:"Basic OWZlMjYyOTZiYjdiNDMzMGFjNTkzMzllZmQyNzQyYjA6ZWNhNjU2ZDFkNTczNDNhOTllMWJjNWVmODQ0YmY2NGM="}}
		response := this.CustomCall("POST", "https://accounts.spotify.com/api/token?grant_type=authorization_code&code=" . this.auth . "&redirect_uri=http:%2F%2Flocalhost:8000%2Fcallback", arg, true)
		RegexMatch(response, "access_token"":""\K.*?(?="")", token)
		this.token := token
		this.SaveRefreshToken(response)
	}
	
	; Local token operations
	
	SaveRefreshToken(response) {
		RegexMatch(response, "refresh_token"":""\K.*?(?="")", response)
		if !(response) {
			return
		}
		response := this.encryptToken(response)
		RegWrite, REG_SZ, % this.RefreshLoc, RefreshToken, % response
		return
	}
	
	; API call method with auto-auth/timeout check/base URL
	
	CustomCall(method, url, HeaderArray := "", noTimeOut := false, body := "", noErr := false) {
		if !(noTimeOut) {
			this.CheckTimeout()
		}
		if !((InStr(url, "https://api.spotify.com")) || (InStr(url, "https://accounts.spotify.com/api/"))) {
			url := "https://api.spotify.com/v1/" . url
		}
		if !(HeaderArray) {
			HeaderArray :=  {1:{1:"Authorization", 2:"Bearer " . this.token}}
		}
		
		SpotifyWinHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		SpotifyWinHttp.Open(method, url, false)
		
		for index, SubHeaderArray in HeaderArray {
			SpotifyWinHttp.SetRequestHeader(SubHeaderArray[1], SubHeaderArray[2])
		}
		
		SpotifyWinHttp.Send(body)
		
		if (SpotifyWinHttp.Status > 299 && !noErr) {
			throw {message: SpotifyWinHttp.Status . " not 2xx for request """ . method . ":" . url . """.", what: "HTTP response code not 2xx", file: A_LineFile, line: A_LineNumber}
		}
		
		return SpotifyWinHttp.ResponseText
	}
	
	; Web auth methods
	
	NotFound(ByRef req, ByRef res) {
		res.SetBodyText("Page not found")
	}
	authCallback(self, ByRef req, ByRef res) {
		res.SetBodyText( req.queries["error"] ? "Error, authorization not given, Spotify.ahk will not function correctly without authorization." : "Authorization complete, closing listen server.")
		res.status := 200
		this.auth := req.queries["code"]
		this.fail := req.queries["error"]
	}
	WebAuthDone() {
		return (this.auth ? true : false)
	}
	
	; Token encryption/decryption methods
	
	EncryptToken(RefreshToken) {
		return crypt.encrypt.strEncrypt(RefreshToken, this.GetIDs(), 5, 3)
	}
	DecryptToken(RefreshToken) {
		try {
			return crypt.encrypt.strDecrypt(RefreshToken, this.GetIDs(), 5, 3)
		} catch {
			this.AuthRetries++
			MsgBox, % "Spotify.ahk could not decrypt local refresh token, retrying authorization"
			RegDelete, % this.RefreshLoc, RefreshToken
			this.StartUp()
			RegRead, RefreshToken, % this.RefreshLoc, refreshToken
			return crypt.encrypt.strDecrypt(RefreshToken, this.GetIDs(), 5, 3)
		}
	}
	GetIDs() {
		static infos := [["ProcessorID", "Win32_Service"], ["SKU", "Win32_BaseBoard"], ["DeviceID", "Win32_USBController"]]
		wmi := ComObjGet("winmgmts:")
		id := ""
		for i, a in infos {
			wmin := wmi.execQuery("Select " . a[1] . " from " . a[2])._newEnum
			while wmin[wminf] {
				id .= wminf[a[1]]
			}
		}
		return id
	}
}
class Player {
	__New(ByRef ParentObject) {
		this.ParentObject := ParentObject
	}
	SaveCurrentlyPlaying() {
		/*
		* Gets the currently playing track, then tells it to save itself (10/10 OOP, I know)
		* Requires something to be playing
		* returns the text response from the API, which is empty unless there is an error
		*/
		return this.GetCurrentPlaybackInfo().Track.Save()
	}
	UnSaveCurrentlyPlaying() {
		/*
		* Gets the currently playing track, then tells it to unsave itself
		* Requires something to be playing
		* returns the text response from the API, which is empty unless there is an error
		*/
		return this.GetCurrentPlaybackInfo().track.UnSave()
	}
	SetVolume(volume) {
		/*
		* Sets the volume of playback on the active device to the percent (0-100) passed 
		*/
		return this.ParentObject.Util.CustomCall("PUT", "me/player/volume?volume_percent=" . volume)
	}
	GetCurrentPlaybackInfo() {
		/*
		* Calls me/player, which returns a whole bunch of different objects
		* Translates JSON versions of track/device/context objects into custom objects
		* Alters the original response object, so any extra info that can't be turned into an object is still returned
		*/
		Resp := JSON.load(this.ParentObject.Util.CustomCall("GET", "me/player"))
		Resp.Track := new track(Resp["item"], this.ParentObject)
		Resp.Device := new device(Resp["device"], this.ParentObject)
		Resp.Context := new context(Resp["context"], this.ParentObject)
		return Resp
	}
	ChangeContext(ContextURI) {
		/*
		* OLD - I should probably remove this
		* Change playback to a different context (AKA playlist/album/just read whatever Spotify says is a context)
		* Only to be directly called until I finish with the playlist object
		*/
		return this.ParentObject.Util.CustomCall("PUT", "me/player/play",, false, JSON.Dump({"context_uri": ContextURI}))
	}
	
	GetDeviceList() {
		/*
		* Gets an array of device objects from the API
		* Translates them into our device class, and returns an array of custom device objects
		*/
		Resp := JSON.Load(this.ParentObject.Util.CustomCall("GET", "me/player/devices"))
		RetVar := []
		for k, v in Resp["devices"] {
			RetVar.Push(new device(v, this.ParentObject))
		}
		return RetVar
	}
	GetRecentlyPlayed() {
		/*
		* Gets an array of tracks alongside other info from the API
		* You might also want to read this Spotify API docs page
		* https://developer.spotify.com/documentation/web-api/reference/player/get-recently-played/
		* WARNING, EVERYTHING IS WRAPPED IN A PAGING OBJECT, the return object is structured as follows
		* Paging Object
		* |-> ["items"] (An array of the below objects)
		* |   |-> [1] Play History Object
		* |   |       |-> ["track"] (A simplified track object)
		* |   |       |-> ["context"] (A context object the track was played in)
		* |   |       |-> ["played_at"] (A UTC timestamp formatted YYYY-MM-DDTHH:MM:SSZ) - Note, I've got no clue what T or Z mean
		* |   |-> [2] Another Play History Object (They are numerically indexed, you can loop through with a for loop)
		* I really like how easy it is to follow what this returns with that nice graphic, I think I'll do it more
		* Builds the play history objects out of functional custom objects
		*/
		Resp := JSON.Load(this.ParentObject.Util.CustomCall("GET", "me/player/recently-played?limit=50"))
		for k, v in Resp["items"] {
			v := {"track": new track(v["track"], this.ParentObject), "context": new context(v["context"], this.ParentObject), "played_at": v["played_at"]}
		}
		return Resp
	}
	SeekTime(TimeInMS) {
		/*
		* Tells the API to jump to the specified time in MS on the currently playing track
		*/
		return this.ParentObject.Util.CustomCall("PUT", "me/player/seek?position_ms=" . TimeInMS)
	}
	SetRepeatMode(mode) {
		/*
		* Tells the API to change the repeat mode
		* Passing 1 for mode will have the currently playing track repeat
		* Passing 2 for mode will have the currently playing context repeat
		* Passing 3 or any other value that isn't 1/2 will turn off repeat
		*/
		return this.ParentObject.Util.CustomCall("PUT", "me/player/repeat?state=" . (mode = 1 ? "track" : (mode = 2 ? "context" : "off")))
	}
	SetShuffle(mode) {
		/*
		* Tells the API to change the shuffle mode to true/false, depending on what it it passed
		*/
		return this.ParentObject.Util.CustomCall("PUT", "me/player/shuffle?state=" . (mode ? "true" : "false"))
	}
	NextTrack() {
		/*
		* Figure this one out on your own
		*/
		return this.ParentObject.Util.CustomCall("POST", "me/player/next")
	}
	LastTrack() {
		/*
		* Figure this one out on your own
		*/
		return this.ParentObject.Util.CustomCall("POST", "me/player/previous")
	}
	PausePlayback() {
		/*
		* Figure this one out on your own
		*/
		return this.ParentObject.Util.CustomCall("PUT", "me/player/pause")
	}
	ResumePlayback() {
		/*
		* Figure this one out on your own
		*/
		return this.ParentObject.Util.CustomCall("PUT", "me/player/play")
	}
	PlayPause() {
		/*
		* Figure this one out on your own
		*/
		return ((this.GetCurrentPlaybackInfo()["is_playing"] = 0) ? (this.ResumePlayback()) : (this.PausePlayback()))
	}
}
class Library {
	__New(ByRef ParentObject) {
		this.ParentObject := ParentObject
	}
	CheckSavedForTrack(TrackID) {
		return this.ParentObject.Util.CustomCall("GET", "me/tracks/contains?ids=" . TrackID)
	}
	GetSavedAlbums() {
		resp := JSON.load(this.ParentObject.Util.CustomCall("GET", "me/albums?limit=1"))
		RetVar := []
		RetVar[1] := ""
		RetVar.SetCapacity(resp["total"])
		loop, % Ceil(resp["total"]/50) {
			for k, v in JSON.Load(this.ParentObject.Util.CustomCall("GET", "me/albums?limit=50&offset="  . ((A_Index - 1 ) * 50)))["items"] {
				alb := new album(v["album"], this.ParentObject)
				alb.added_at := v["added_at"]
				RetVar.Push(alb)
			}
		}
		RetVar.RemoveAt(1)
		return RetVar
	}
	GetSavedTracks() {
		resp := JSON.load(this.ParentObject.Util.CustomCall("GET", "me/tracks?limit=1"))
		RetVar := []
		RetVar[1] := ""
		RetVar.SetCapacity(resp["total"])
		loop, % Ceil(resp["total"]/50) {
			for k, v in JSON.Load(this.ParentObject.Util.CustomCall("GET", "me/tracks?limit=50&offset="  . ((A_Index - 1 ) * 50)))["items"] {
				trk := new track(v["track"], this.ParentObject)
				trk.added_at := v["added_at"]
				RetVar.Push(trk)
			}
		}
		RetVar.RemoveAt(1)
		return RetVar
	}
}

class Tracks {
	__New(ByRef ParentObject) {
		this.ParentObject := ParentObject
	}
	GetTrack(TrackID) {
		return new track(JSON.Load(this.ParentObject.Util.CustomCall("GET", "tracks/" . TrackID)), this.ParentObject)
	}
}
class Albums {
	__New(ByRef ParentObject) {
		this.ParentObject := ParentObject
	}
	GetAlbum(AlbumID) {
		return new album(JSON.Load(this.ParentObject.Util.CustomCall("GET", "albums/" . AlbumID)), this.ParentObject)
	}
}

class Artists {
	__New(ByRef ParentObject) {
		this.ParentObject := ParentObject
	}
	GetArtist(ArtistID) {
		return new artist(JSON.Load(this.ParentObject.Util.CustomCall("GET", "artists/" . ArtistID)), this.ParentObject)
	}
}
class Playlists {
	__New(ByRef ParentObject) {
		this.ParentObject := ParentObject
	}
	GetPlaylist(PlaylistID) {
		return new playlist(JSON.Load(this.ParentObject.Util.CustomCall("GET", "playlists/" . PlaylistID)), this.ParentObject)
	}
	CreatePlaylist(name, description, public := true) {
		headers := {1:{1:"Authorization", 2:"Bearer " . this.ParentObject.Util.token}, 2:{1:"Content-Type", 2:"application/json"}}
		body := "{""name"":""" . name . """, ""description"":""" . description """, ""public"":" . public . "}"
		MsgBox, % body
		return new playlist(JSON.Load(this.ParentObject.Util.CustomCall("POST", "users/" . this.ParentObject.CurrentUser.id . "/playlists", headers,, body)), this.ParentObject)
	}
}
class Users {
	__New(ByRef ParentObject) {
		this.ParentObject := ParentObject
	}
	GetUser(UserID) {
		return new user(JSON.Load(this.ParentObject.Util.CustomCall("GET", "users/" . UserID)), this.ParentObject)
	}
}

class playlist {
	__New(PlaylistObj, ByRef Parent := "") {
		this.SpotifyObj := Parent
		this.json := PlaylistObj
		this.description := (this.json["description"] = "null" ? "" : this.json["description"])
		this.id := this.json["id"]
		this.name := this.json["name"]
		this.uri := this.json["uri"]
		this.owner := new user(this.json["owner"], this.SpotifyObj)
		this.public := (this.json["public"] = "null" ? true : (this.json["public"] = "true" ? true : false))
		this.tracks := []
		for k, v in this.json["tracks"]["items"] {
			this.tracks.Push(new track(v["track"], this.SpotifyObj))
		}
		this.uri := this.json["uri"]
	}
	
	AddTrack(TrackIDOrTrackOBJ) {
		if (IsObject(TrackIDOrTrackOBJ)) {
			tid := TrackIDOrTrackOBJ.id
		}
		else {
			tid := TrackIDOrTrackOBJ
		}
		this.SpotifyObj.Util.CustomCall("POST", "playlists/" . this.id . "/tracks?uris=spotify:track:" . tid)
	}
	RemoveTrack(TrackIDOrTrackOBJ) {
		if (IsObject(TrackIDOrTrackOBJ)) {
			tid := TrackIDOrTrackOBJ.id
		}
		else {
			tid := TrackIDOrTrackOBJ
		}
		this.SpotifyObj.Util.CustomCall("DELETE", "playlists/" . this.id . "/tracks",, false, JSON.Dump({"tracks": [{"uri": "spotify:track:" . tid}]}))
	}
	Play() {
		return this.SpotifyObj.Util.CustomCall("PUT", "me/player/play",, false, JSON.Dump({"context_uri": "spotify:playlist:" . this.id}))
	}
	Delete() {
		this.SpotifyObj.Util.CustomCall("DELETE", "https://api.spotify.com/v1/playlists/" . this.id "/followers")
		return
	}
	; Fuck me, all these classes feel so half-baked, what the hell am I even doing?
}

class track {
	__New(ResponseTrackObj, ByRef Parent := "") {
		this.SpotifyObj := Parent
		this.json := ResponseTrackObj
		this.id := this.json["id"]
		this.album := new album(this.json["album"], this.SpotifyObj) ; TODO -- Album objects
		this.artists := []
		for k, v in this.json["artists"] {
			this.artists.Push(new artist(v, this.SpotifyObj))
		}
		this.duration := this.json["duration_ms"]
		this.explicit := this.json["explicit"]
		this.name := this.json["name"]
	}
	IsSaved[] {
		Get {
			return (this.SpotifyObj.Util.CustomCall("GET", "me/tracks/contains?ids=" . this.id) ~= "true" ? true : false)
		}
	}

	Save() {
		return this.SpotifyObj.Util.CustomCall("PUT", "me/tracks?ids=" . this.id)
	}
	
	UnSave() {
		return this.SpotifyObj.Util.CustomCall("DELETE", "me/tracks?ids=" . this.id)
	}
	
	Play() {
		return this.SpotifyObj.Util.CustomCall("PUT", "me/player/play",, false, JSON.Dump({"uris": ["spotify:track:" . this.id]}))
	}
}

class album {
	__New(Albumjson, ByRef Parent := "") {
		this.SpotifyObj := Parent
		this.json := Albumjson
		this.artists := this.json["artists"]
		this.genres := this.json["genres"]
		this.id := this.json["id"]
		this.images := this.json["images"]
		this.name := this.json["name"]
		this.uri := this.json["uri"]
		this.tracks := []
		this.context := new context({"uri": this.uri}, this.SpotifyObj)
		for k, v in this.json["tracks"]["items"] {
			this.tracks.Push(new track(v, this.SpotifyObj))
		}
	}
	;__Get(this, key) {
	;	this.key := this.SpotifyObj.Albums.GetAlbum(this.id).key
	;}
	
	IsSaved[] {
		Get {
			return (this.SpotifyObj.Util.CustomCall("GET", "me/albums/contains?ids=" . this.id) ~= "true" ? true : false)
		}
	}
	
	Play() {
		return this.context.SwitchTo()
	}
	
	Save() {
		return this.SpotifyObj.Util.CustomCall("PUT", "me/albums?ids=" . this.id)
	}
	
	UnSave() {
		return this.SpotifyObj.Util.CustomCall("DELETE", "me/albums?ids=" . this.id)
	}
}

class device {
	__New(Devicejson, ByRef Parent := "") {
		this.SpotifyObj := Parent
		this.json := Devicejson
		this.id := this.json["id"]
		this.IsActive := this.json["is_active"]
		this.IsPrivate := this.json["is_private_session"]
		this.name := this.json["name"]
		this.type  := this.json["type"]
		this.volume := this.json["volume_percent"]
	}
	
	SwitchTo() {
		return this.SpotifyObj.Util.CustomCall("PUT", "me/player",, false, JSON.Dump({"device_ids": [this.id]}))
	}
}

class context {
	__New(Contextjson, ByRef Parent := "") {
		this.SpotifyObj := Parent
		this.json := Contextjson
		this.uri := this.json["uri"]
		this.type := this.json["type"]
	}
	
	SwitchTo() {
		return this.SpotifyObj.Util.CustomCall("PUT", "me/player/play",, false, JSON.Dump({"context_uri": this.uri}))
	}
}
class artist {
	__New(Artistjson, ByRef Parent := "") {
		this.SpotifyObj := Parent
		this.json := Artistjson
		this.genres := this.json["genres"]
		this.id := this.json["id"]
		this.images := this.json["images"]
		this.name := this.json["name"]
		this.uri := this.json["uri"]
	}
	
	GetAlbums() {
		resp := JSON.load(this.SpotifyObj.Util.CustomCall("GET", "https://api.spotify.com/v1/artists/" . this.id . "/albums?limit=1"))
		RetVar := []
		RetVar[1] := ""
		RetVar.SetCapacity(resp["total"])
		loop, % Ceil(resp["total"]/50) {
			for k, v in JSON.Load(this.SpotifyObj.Util.CustomCall("GET", "artists/" . this.id . "/albums?limit=50&offset="  . ((A_Index - 1 ) * 50)))["items"] {
				RetVar.Push(new album(v, this.SpotifyObj))
			}
		}
		RetVar.RemoveAt(1)
		return RetVar
	}	
	; Jesus, I have just fucking ruined the global namespace. TODO -- Nest these somewhere
	; TODO -- Get a plugin that actually makes "TODO --" do something
}
class user {
	__New(Userjson, ByRef Parent := "", isCur := false) {
		this.SpotifyObj := Parent
		this.json := Userjson
		this.isCur := isCur
		this.birthdate := this.json["birthdate"]
		this.name := this.json["display_name"]
		this.email := this.json["email"]
		this.id := this.json["id"]
		this.subscriptionLevel := this.json["product"]
	}
	GetPlaylists() {
		; I don't know why, but I couldn't return the array of playlists generated by this function properly, so ignore the stuff with RetVer
		; Maybe some limitation on pushing large objects onto an array
		resp := JSON.load(this.SpotifyObj.Util.CustomCall("GET", "users/" . this.id . "/playlists?limit=1"))
		RetVar := []
		RetVar[1] := ""
		RetVar.SetCapacity(resp["total"])
		loop, % Ceil(resp["total"]/50) {
			for k, v in JSON.load(this.SpotifyObj.Util.CustomCall("GET", "users/" . this.id . "/playlists?limit=50&offset=" . ((A_Index - 1 ) * 50)))["items"] {
				RetVar.Push(new playlist(v, this.SpotifyObj))
			}
		}
		RetVar.RemoveAt(1)
		return RetVar
	}
	GetTop(ArtistsOrTracks := "tracks") {
		if !(this.isCur) {
			return ""
		}
		RetVar := []
		for k, v in JSON.load(this.SpotifyObj.Util.CustomCall("GET", "me/top/" . ArtistsOrTracks))["items"] {
			if (ArtistsOrTracks = "artists") {
				RetVar.Push(new artist(v, this.SpotifyObj))
			}
			else {
				RetVar.Push(new track(v, this.SpotifyObj))
			}
		}
		return RetVar
	}
}

#Include <AHKsock>
#Include <AHKhttp>
#Include <crypt>
#Include <json>
