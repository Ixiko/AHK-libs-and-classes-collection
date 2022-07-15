class Capabilities
{
    static Simple := {"cap":{"capabilities":{"":""}}}, olduser := {}
    static _ucof := false, _hmode := false, _incog := false
    __new(browser,Options,platform:="windows",notify:=false)
    {
        this.options := Options
        this.cap := {}
        this.cap.capabilities := {}
        this.cap.capabilities.alwaysMatch := { this.options :{"w3c":json.true}}
        this.cap.capabilities.alwaysMatch.browserName := browser
        this.cap.capabilities.alwaysMatch.platformName := platform
        if(notify = false)
            this.AddexcludeSwitches("enable-automation")
        this.cap.capabilities.firstMatch := [{}]
        this.cap.desiredCapabilities := {}
        this.cap.desiredCapabilities.browserName := browser
    }

    HeadlessMode[]
    {
        set 
        {
            if value
            {
                this.addArg("--headless")
                capabilities._hmode := true
            }
            else
            {
                capabilities._hmode := false
                this.RemoveArg("--headless")
	        }	
        }

        get
        {
            return capabilities._hmode
        }
    }
    
    IncognitoMode[]
    {
        set 
        {
            if value
            {
                Capabilities.olduser.push(this.RemoveArg("--user-data-dir=","in"))
                Capabilities.olduser.push(this.RemoveArg("--profile-directory=","in"))
                this.addArg("--incognito")
                capabilities._incog := true
            }
            else
            {
                capabilities._incog := false
                for i, arg in this.cap.capabilities.alwaysMatch[this.Options].args
                    if (arg = "--incognito")
                        this.RemoveArg(arg)
                for i, arg in Capabilities.olduser
                    this.addArg(arg)
                Capabilities.olduser := {}
	        }	
        }

        get
        {
            return capabilities._incog
        }
    }

    setUserProfile(profileName:="Default", userDataDir:="") ; user data dir doesnt change often, use the default
	{
        if this.IncognitoMode
            return
		if !userDataDir
			userDataDir := "C:/Users/" A_UserName "/AppData/Local/Google/Chrome/User Data"
        userDataDir := StrReplace(userDataDir, "\", "/")
        ; removing previous args if any
        this.RemoveArg("--user-data-dir=","in")
        this.RemoveArg("--profile-directory=","in")
        ; adding new profile args
        this.addArg("--user-data-dir=" userDataDir)
        this.addArg("--profile-directory=" profileName)
	}

    Setbinary(location)
    {
        this.cap.capabilities.alwaysMatch[this.Options].binary := StrReplace(location, "\", "/")
    }

    Resetbinary()
    {
        this.cap.capabilities.alwaysMatch[this.Options].Delete("binary")
    }

    /*
    Following methods can manually be added as I haven't used them and do not know their parameters and also I don't see the need to add

    ChromeOption Methods    
    detach
    localState              
    prefs
    minidumpPath
    mobileEmulation
    perfLoggingPrefs
    windowTypes
    */

}

class ChromeCapabilities extends Capabilities
{
    useCrossOriginFrame[]
    {
        set {
            if value
            {
                this.addArg("--disable-site-isolation-trials")
		        this.addArg("--disable-web-security")
                capabilities._ucof := true
            }
            else
            {
                capabilities._ucof := false
                for i, arg in this.cap.capabilities.alwaysMatch[this.Options].args
                    if (arg = "--disable-site-isolation-trials") or (arg = "--disable-web-security")
                        this.RemoveArg(arg)
	        }	
        }

        get
        {
            return capabilities._ucof
        }
    }
    addArg(arg) ; args links https://peter.sh/experiments/chromium-command-line-switches/
    {
        if !IsObject(this.cap.capabilities.alwaysMatch[this.Options].args)
            this.cap.capabilities.alwaysMatch[this.Options].args := []
        this.cap.capabilities.alwaysMatch[this.Options].args.push(arg)
    }

    Addextensions(crxlocation)
    {
        if !IsObject(this.cap.capabilities.alwaysMatch[this.Options].extensions)
            this.cap.capabilities.alwaysMatch[this.Options].extensions := []
        crxlocation := StrReplace(crxlocation, "\", "/")
        this.cap.capabilities.alwaysMatch[this.Options].extensions.push(crxlocation)
    }

    RemoveArg(arg,match="Exact")
    {
	    for i, argtbr in this.cap.capabilities.alwaysMatch[this.Options].args
	    {
            if match = "Exact"
	        {
                if (argtbr = arg)
		            return this.cap.capabilities.alwaysMatch[this.Options].args.RemoveAt(i)
            } 
            else
            {
                if instr(argtbr, arg)
		            return this.cap.capabilities.alwaysMatch[this.Options].args.RemoveAt(i)
            }
	    }
    }

    DebugPort(Port:=9222)
    {
        this.cap.capabilities.alwaysMatch[this.Options].debuggerAddress := "http://127.0.0.1:" Port
    }

    AddexcludeSwitches(switch)
    {
        if !IsObject(this.cap.capabilities.alwaysMatch[this.Options].excludeSwitches)
            this.cap.capabilities.alwaysMatch[this.Options].excludeSwitches := []
        this.cap.capabilities.alwaysMatch[this.Options].excludeSwitches.push(switch)
    }
}

class FireFoxCapabilities extends Capabilities
{
    __new(browser,Options,platform:="windows",notify:=false)
    {
        this.options := Options
        this.cap := {}
        this.cap.capabilities := {}
        this.cap.capabilities.alwaysMatch := { this.options :{"prefs":{"dom.ipc.processCount": 8,"javascript.options.showInConsole": json.false()}}}
        this.cap.capabilities.alwaysMatch.browserName := browser
        this.cap.capabilities.alwaysMatch.platformName := platform
        this.cap.capabilities.log := {}
        this.cap.capabilities.log.level := "trace"
        this.cap.capabilities.env := {}

        ; ; reg read binary location
        ; this.cap.capabilities.Setbinary("")
        ;this.cap.desiredCapabilities := {}
        ;this.cap.desiredCapabilities.browserName := browser
    }

    DebugPort(Port:=9222)
    {
        ;this.cap.capabilities.alwaysMatch[this.Options].debuggerAddress := "http://127.0.0.1:" Port
        msgbox, debuggerAddress is not support for FireFoxCapabilities
    }

    addArg(arg) ; idk args list
    {
        arg := strreplace(arg,"--","-")
        if !IsObject(this.cap.capabilities.alwaysMatch[this.Options].args)
            this.cap.capabilities.alwaysMatch[this.Options].args := []
        this.cap.capabilities.alwaysMatch[this.Options].args.push(arg)
    }

    RemoveArg(arg,match:="Exact")
    {
        arg := strreplace(arg,"--","-")
	    for i, argtbr in this.cap.capabilities.alwaysMatch[this.Options].args
	    {
            if match = "Exact"
	        {
                if (argtbr = arg)
		            return this.cap.capabilities.alwaysMatch[this.Options].args.RemoveAt(i)
            } 
            else
            {
                if instr(argtbr, arg)
		            return this.cap.capabilities.alwaysMatch[this.Options].args.RemoveAt(i)
            }
	    }
    }

    setUserProfile(profileName:="Profile1") ; user data dir doesnt change often, use the default
	{
        if this.IncognitoMode
            return
        userDataDir := A_AppData "\Mozilla\Firefox\Profiles\"
        profileini := A_AppData "\Mozilla\Firefox\profiles.ini"
        IniRead, profilePath , % profileini, % profileName, Path
        for i, argtbr in this.cap.capabilities.alwaysMatch[this.Options].args
        {
            if (argtbr = "-profile") or instr(argtbr,"\Mozilla\Firefox\Profiles\")
                this.cap.capabilities.alwaysMatch[this.Options].RemoveAt(i)
        }
        this.addArg("-profile")
        this.addArg(StrReplace(A_AppData "\Mozilla\Firefox\" profilePath, "\", "/"))
	}

    Addextensions(crxlocation)
    {
        ; if !IsObject(this.cap.capabilities.alwaysMatch[this.Options].extensions)
        ;     this.cap.capabilities.alwaysMatch[this.Options].extensions := []
        ; crxlocation := StrReplace(crxlocation, "\", "/")
        ; this.cap.capabilities.alwaysMatch[this.Options].extensions.push(crxlocation)
    }
}

class EdgeCapabilities extends ChromeCapabilities
{
    Addextensions(crxlocation)
    {
        ; if !IsObject(this.cap.capabilities.alwaysMatch[this.Options].extensions)
        ;     this.cap.capabilities.alwaysMatch[this.Options].extensions := []
        ; crxlocation := StrReplace(crxlocation, "\", "/")
        ; this.cap.capabilities.alwaysMatch[this.Options].extensions.push(crxlocation)
    }
}

class OperaCapabilities extends ChromeCapabilities
{
    Addextensions(crxlocation)
    {
        ; if !IsObject(this.cap.capabilities.alwaysMatch[this.Options].extensions)
        ;     this.cap.capabilities.alwaysMatch[this.Options].extensions := []
        ; crxlocation := StrReplace(crxlocation, "\", "/")
        ; this.cap.capabilities.alwaysMatch[this.Options].extensions.push(crxlocation)
    }
}