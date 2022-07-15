; WDM aka Web Driver management Class for Rufaydium.ahk 
; I am upto/will add support update auto download supporting Webdriver when browser gets update
; By Xeo786

Class RunDriver
{
	__New(Location,Parameters:= "--port=0000")
	{
		SplitPath, Location,Name,Dir,,DriverName
		this.Dir := Dir ? Dir : A_ScriptDir
		this.exe := Name
		this.param := Parameters
		this.Name := DriverName
		switch this.Name
		{
			case "chromedriver" :
				this.Options := "goog:chromeOptions"
				this.browser := "chrome"
				Parameters := RegExReplace(Parameters, "(--port)=(0000)", $1 "=9515")
			case "msedgedriver" : 
				this.Options := "ms:edgeOptions"
				this.browser := "msedge"
				Parameters := RegExReplace(Parameters, "(--port)=(0000)", $1 "=9516")
			case "geckodriver" : 
				this.Options := "moz:firefoxOptions"
				this.browser := "firefox"
				Parameters := RegExReplace(Parameters, "(--port)=(0000)", $1 "=9517")
			case "operadriver" :
				this.Options := "goog:chromeOptions"
				this.browser := "opera"
				Parameters := RegExReplace(Parameters, "(--port)=(0000)", $1 "=9518")
			Default:
				Parameters := RegExReplace(Parameters, "(--port)=(0000)", $1 "=9519")
		}
		
		if !FileExist(Location) and this.browser
			Location := this.GetDriver()
		This.Target := Location " " chr(34) Parameters chr(34)
		if !FileExist(Location)
		{
			Msgbox,64,Rufaydium WebDriver Support,Unable to download driver`nRufaydium exitting
			Exitapp
		}

		if RegExMatch(this.param,"--port=(\d+)",port)
			This.Port := Port1
		else
		{
			Msgbox,64,"Rufaydium WebDriver Support,Unable to download driver from`nURL :" this.DriverUrl "`nRufaydium exitting"
			exitapp
		}
		
		PID := this.GetPIDbyName(Name)
		if PID
		{
			this.PID := PID
		}
		else			
			this.Launch()
	}
	
	__Delete()
	{
		;this.exit()
	}
	
	exit()
	{
		Process, Close, % This.PID
	}
	
	Launch()
	{
		Run % this.Target,,Hide,PID
		Process, Wait, % PID
		this.PID := PID
	}
	
	help(Location)
	{
		Run % comspec " /k " chr(34) Location chr(34) " --help > dir.txt",,Hide,PID
		while !FileExist(this.Dir "\dir.txt")
			sleep, 200
		sleep, 200
		FileRead, Content, % this.Dir "dir.txt"
		while FileExist(this.Dir "\dir.txt")
			FileDelete, % this.Dir "\dir.txt"
		Process, Close, % PID
		return Content
	}
	
	visible
	{
		get
		{
			return this.visibility
		}
		
		set
		{
			if(value = 1) and !this.visibility
			{
				winshow, % "ahk_pid " this.pid
				this.visibility := 1
			}
			else
			{
				winhide, % "ahk_pid " this.pid
				this.visibility := 0
			}
		}
	}
	
	; thanks for AHK_user for driver auto-download suggestion and his code https://www.autohotkey.com/boards/viewtopic.php?f=6&t=102616&start=60#p460812
	GetDriver(Version="STABLE",bit="32")
	{
		switch this.Name
		{
			case "chromedriver" :
				this.zip := "chromedriver_win32.zip"
				if RegExMatch(Version,"Chrome version ([\d.]+).*\n.*browser version is (\d+.\d+.\d+)",bver)
					uri := "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_"  bver2
				else
					uri := "https://chromedriver.storage.googleapis.com/LATEST_RELEASE", bver1 := "unknown"
				
				DriverVersion := this.GetVersion(uri)
				this.DriverUrl := "https://chromedriver.storage.googleapis.com/" DriverVersion "/" this.zip
			
			case "msedgedriver" :
				if instr(bit,"64")
					this.zip := "edgedriver_win64.zip"
				else 
					this.zip := "edgedriver_win32.zip" 

				if RegExMatch(Version,"version ([\d.]+).*\n.*browser version is (\d+)",bver)
					uri := "https://msedgedriver.azureedge.net/LATEST_" "RELEASE_" bver2
				else if(Version != "STABLE")
					uri := "https://msedgedriver.azureedge.net/LATEST_RELEASE_" Version
				else
					uri := "https://msedgedriver.azureedge.net/LATEST_" Version, bver1 := "unknown"

				DriverVersion := this.GetVersion(uri) ; Thanks RaptorX fixing Issues GetEdgeDrive
				this.DriverUrl := "https://msedgedriver.azureedge.net/" DriverVersion "/" this.zip
			case "geckodriver" :
				; haven't received any error msg from previous driver tell about driver version 
				; therefor unable to figure out which driver to version to dowload as v0.028 support latest fireforx
				; this will be uri in case driver suggest version for firefox
				; uri := "https://api.github.com/repos/mozilla/geckodriver/releases/tags/v0.31.0"
				; till that just delete geckodriver.exe if you thing its old Rufaydium will download latest
				uri := "https://api.github.com/repos/mozilla/geckodriver/releases/latest"
				for i, asset in json.load(this.GetVersion(uri)).assets
				{
					if instr(asset.name,"win64.zip") and instr(bit,"64")
					{
						this.DriverUrl := asset.browser_download_url
						this.zip := asset.name
					}
					else if instr(asset.name,"win32.zip") 
					{
						this.DriverUrl := asset.browser_download_url
						this.zip := asset.name
					}
				}
			case "operadriver" :
				if RegExMatch(Version,"Chrome version ([\d.]+).*\n.*browser version is (\d+.\d+.\d+)",bver)
				{
					uri := "https://api.github.com/repos/operasoftware/operachromiumdriver/releases"
					for i, asset in json.load(this.GetVersion(uri)).assets
					{
						if instr(asset.name,bver1)
						{
							uri := "https://api.github.com/repos/operasoftware/operachromiumdriver/releases/tags/" asset.tag_name
						}
					}
				}	
				else
					uri := "https://api.github.com/repos/operasoftware/operachromiumdriver/releases/latest", bver1 := "unknown"
				
				for i, asset in json.load(this.GetVersion(uri)).assets
				{
					if instr(asset.name,"win64.zip") and instr(bit,"64")
					{
						this.DriverUrl := asset.browser_download_url
						this.zip := asset.name
					}
					else if instr(asset.name,"win32.zip") 
					{
						this.DriverUrl := asset.browser_download_url
						this.zip := asset.name
					}
				}
		} 

		if InStr(this.DriverVersion, "NoSuchKey"){
			MsgBox,16,Testing,Error`nDriverVersion
			return false
		}
		
		if !FileExist(this.Dir "\Backup")
			FileCreateDir, % this.Dir "\Backup"
		
		while FileExist(this.Dir "\" this.exe)
		{
			Process, Close, % this.GetPIDbyName(this.exe)
			FileMove, % this.Dir "\" this.exe, % this.Dir "\Backup\" this.name " Version " bver1 ".exe", 1
		}
		
		this.zip := this.dir "\" this.zip
		return this.DownloadnExtract()
	}
	
	GetVersion(uri)
	{
		if(this.Name = "msedgedriver")
		{
			WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			WebRequest.Open("GET", uri, false)
			WebRequest.SetRequestHeader("Content-Type","application/json")
			WebRequest.Send()
			loop, % WebRequest.GetResponseHeader("Content-Length") ;loop over  responsbody 1 byte at a time
					text .= chr(bytes[A_Index-1]) ;lookup each byte and assign a charter
			return SubStr(text, 3)
		}
		WebRequest := ComObjCreate("Msxml2.XMLHTTP")
		WebRequest.open("GET", uri, False)
		WebRequest.SetRequestHeader("Content-Type","application/json")
		WebRequest.Send()
		return WebRequest.responseText
	}

	DownloadnExtract()
	{
		static fso := ComObjCreate("Scripting.FileSystemObject")
		URLDownloadToFile, % this.DriverUrl,  % this.zip
		AppObj := ComObjCreate("Shell.Application")
		FolderObj := AppObj.Namespace(this.zip)	
		FileObj := FolderObj.ParseName(this.exe)
		if !isobject(FileObj)
			For Item in FolderObj.Items
			{
				FileObj := FolderObj.ParseName(Item.Name "\" this.exe)
				if isobject(FileObj) 
					break
			}	
		AppObj.Namespace(this.Dir "\").CopyHere(FileObj, 4|16)
		FileDelete, % this.zip
			return this.Dir "\" this.exe
	}

	GetPIDbyName(name) 
	{
		static wmi := ComObjGet("winmgmts:\\.\root\cimv2")
		for Process in wmi.ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" name "'")
			return Process.processId
	}
}



