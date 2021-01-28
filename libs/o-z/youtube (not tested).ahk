;	Raljeta AHK, version: 0.3.x
;	Copyright (C) 2011-2014  Litew <litew9@gmail.com>
;
;	This program is free software: you can redistribute it and/or modify
;	it under the terms of the GNU General Public License as published by
;	the Free Software Foundation, either version 3 of the License, or
;	(at your option) any later version.
;
;	This program is distributed in the hope that it will be useful,
;	but WITHOUT ANY WARRANTY; without even the implied warranty of
;	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	GNU General Public License for more details.
;
;	You should have received a copy of the GNU General Public License
;	along with this program. If not, see <http://www.gnu.org/licenses/>.

Youtube_GetVideoInfo(TrackId, ByRef Clip) {
	global cfg

	;~ APIUrl			:= "youtube.com" . Trim(TrackId) . "/?format=xml"
	APIUrl			:= "http://youtube.com/api/video/" . Trim(TrackId) . "/?format=xml"

	;~ VideoExp		:= "i)\<embed_url\>http:\/\/(?:video\.)?youtube\.com\/(?:video/)?(?:embed\/)?(?P<VIDEO_ID>\d{5,35}|[\d\w]{5,35})\<\/embed_url\>"
	VideoExp		:= "i)src=""(?:http:\/\/|\/\/)?(?:video\.)?youtube\.com\/(?:video\/)?(?:play/)?(?:embed\/)?(?P<VIDEO_ID>\d{5,35}|[\d\w]{5,35})(\?p=(?P<VIDEO_TOKEN>[\w\d-%]+))?"""
	NameExp			:= "i).*\<title\>(.+)\<\/title\>.*"
	UA				:= cfg.UserAgent
	hdrs =
	(
	User-Agent: %UA%
	)

	debug("API URL:`r`n" APIUrl)
	if (HTTPRequest(APIUrl, Response, hdrs) <> 0)
	{
		if (RegExMatch(Response, NameExp, NameMatch) <> 0)
			Clip.Name := NameMatch1
		Clip.Name := NormalizeFilename(TrackId, Clip.Name, cfg.FileExt)

		if (RegExMatch(Response, VideoExp, Match) <> 0)
		{
			Clip.VideoId := (MatchVIDEO_ID <> "") ? MatchVIDEO_ID : ""
			Clip.PToken := MatchVIDEO_TOKEN
			debug("Name: " Clip.Name "`r`nVideoId: " Clip.VideoId "`r`nPToken: " Clip.PToken)
			if (Clip.VideoId <> "")
				return, 0
			else
				return, -1
		} else
		{
			debug("Response:`r`n" Response)
			return, -1
		}
	} else
	{
		debug("Fail to get API URL:`r`n" APIUrl)
		return, -1
	}
}

Youtube_GetVideoLink(VideoID, PToken, ByRef VideoLink) {
	global cfg

	Quality := cfg.Quality
	FileExt	:= cfg.FileExt

	XMLExp			:= "i).*CDATA\[(.+)]].*"
	HostAppExp		:= "i)(rtmp://video-\d{1,3}-\d{1,3}\.youtube\.com:?\d{0,5}/)(youtube_vod(?:_\d{1,2})?(?:/_definst_)?|vod|youtube)?"
	BitrateExp		:= "iO)(/mp4:.+?/([\w\d-_]+)\.(flv|mp4|f4f).+?)""\sbitrate=""(\d{0,})"""
	HDSExp			:= "i)(http:\/\/video-\d{1,3}-\d{1,3}\.youtube\.com)"
	PlaypathExp		:= "im)(/mp4:.+/([\w\d_]+)\.(flv|mp4|f4f).+?)\"""
	PlaypathHDSExp	:= "im)href=""([/\w\d_-]+\.mp4\.f4m)""\s"
	;~ ManifestExp		:= "i)http:\/\/bl\.youtube\.com\/(?:route/).+\.f4m.*\<\/default\>"
	ManifestExp		:= "iS)\<default\>(.*.f4m.*)\<\/default\>"

	TrackInfo		:= ""
	HostApp			:= ""
	Playpath		:= ""
	FileExt			:= "mp4"
	CurPos			:= 1
	QualArray		:= {1: 0, 2: 512, 3: 1024, 4: 2048, 5:4096}
	LinksArray		:= {}

	PToken			:= (PToken <> "") ? "&p=" . PToken : ""
	TrackInfoUrl	:= "http://youtube.com/api/play/options/" . Trim(VideoID) . "/?format=xml&referer=" . UriEncode("http://video.youtube.com/" . Trim(VideoID)) . PToken

	if (HTTPRequest(TrackInfoUrl, TrackInfo) <> 0)
	{
		if (RegExMatch(TrackInfo, ManifestExp, Match4m) <> 0)
		{
			ManifestUrl := Match4m1
			debug("ManifestUrl: " Match4m1)
		}
		else
			return, -1
	} else
		return, -1

	if (HTTPRequest(ManifestUrl, f4mFile) <> 0)
	{
		if (RegExMatch(f4mFile, HostAppExp, Match) <> 0)
		{
			HostApp := Match
			Loop
			{
				CurPos := RegExMatch(f4mFile, BitrateExp, Match, CurPos + StrLen(Match.Value))
				if (!CurPos)
					break
				debug("CurPos + Match.Len: " CurPos + StrLen(Match.Value)"`r`nMatch: " Match[4])
				LinksArray.Insert(Match[1])

			}

			if (Quality = 1)
				Playpath := LinksArray[LinksArray.MinIndex()]
			if (Quality = 2) and (LinksArray.HasKey(LinksArray.MaxIndex()-1))
				Playpath := LinksArray[LinksArray.MaxIndex()-1]
			else
				Playpath := LinksArray[LinksArray.MinIndex()]
			if (Quality = 3)
				Playpath := LinksArray[LinksArray.MaxIndex()]

			if (RegExMatch(Playpath, PlaypathExp, PlaypathMatch) <> 0)
					{
						Playpath := PlaypathMatch1
						FileExt := PlaypathMatch2
					}

			if (FileExt = "f4f")
				return, -2
			StringReplace, Playpath, Playpath, &amp;, &, All
			VideoLink := Trim(HostApp, "`r`t`n") . Trim(Playpath, "`r`t`n")
			if (VideoLink <> "")
				return, 0
			else
				return, -1
		}
		else
		if RegExMatch(f4mFile, HDSExp, Match)
		{
			HostApp := Match1
			if (RegExMatch(f4mFile, "im).+(href|url)=""([/\w\d-_]+\.mp4(?:\.f4m.*)?)"".*", PlaypathMatch))
				VideoLink := ManifestUrl
			else
				VideoLink := ""
			if (VideoLink <> "")
				return, 1
			else
				return, -1
		} else
			return, -1
	}
	 else
		return, -1
}

Youtube_GetCMD(VideoLink, FileName, ByRef CommandLine) {
	global sysp, cfg

	CommandLine		:= ""
	Resume			:= false
	RtmpExp			:= "i)(rtmp://video-\d{1,3}-\d{1,3}\.youtube\.com:?\d{0,5}/)(youtube_vod(?:_\d{1,2})?(?:/_definst_)?|vod|youtube)\/(mp4:.+/([a-z0-9_]+)\.(flv|mp4|f4f).+)"
	HttpExp			:= "i)http://video-\d{1,3}-\d{1,3}\.youtube\.com/.+/movies/(.+)-\d{1,}\.(flv|mp4)$"
	HDSExp			:= "i)http://((video-\d{1,3}-\d{1,3}\\)|bl)\.youtube\.com[/\w\d-_]+\.(mp4|f4m)?"
	SwfPlayer		:= "http://Youtube.com/player.swf"

	if (RegExMatch(VideoLink, RtmpExp, Match) <> 0)
	{
		if FileExist(FileName)
		{
			FileGetSize, FileSize, FileName
			if (FileSize != 0)
				Resume := true
		}

		OptRtmp 		:= " --rtmp """ . Match1 . """"
		OptApp 			:= " --app """ . Match2 . """"
		OptPlaypath 	:= " --playpath """ . Match3 . """"
		OptPlayer 		:= " --swfUrl """ . SwfPlayer . """"
		OptFlv 			:= " --flv """ . FileName . """"
		OptLive			:= (OptApp = "vod") ? " --live" : ""
		OptResume		:= ((Resume = true) and (!OptLive))? " --resume --skip 5" : ""

		CommandLine		:= CheckQuotes(sysp.FileRtmpdump) . OptRtmp . OptApp . OptPlaypath . OptPlayer . OptResume . OptFlv . OptLive
		return, 0
	}
	else
	if (RegExMatch(VideoLink, HDSExp, Match) <> 0)
	{
		SplitPath, FileName, outFile, outDir
		OptCurlExt		:= " -n -d extension=.\php_curl.dll"
		OptFileHDS		:= " -f """ . sysp.FileHDS . """ --"
		OptDelete		:= " --delete"
		if (cfg.VideoQuality = 1)
			Qual := "low"
		else if (cfg.VideoQuality = 2)
			Qual := "medium"
		else
			Qual := "high"
		OptUserAgent	:= " --useragent """ . cfg.UserAgent . """"
		OptQuality		:= " --quality " . Qual
		OptManifest		:= " --manifest """ . VideoLink . """"
		OptOutDir		:= " --outdir """ .  outDir . """"
		OptOutFile		:= " --outfile """ . outFile . """"
		OptParallel		:= " --parallel 2"

		CommandLine		:= % CheckQuotes(sysp.FilePHP) . OptCurlExt . OptFileHDS . OptDelete . OptUserAgent . OptParallel . OptQuality . OptManifest . OptOutDir . OptOutFile
		return, 0
	}
	else
		return, -1
}