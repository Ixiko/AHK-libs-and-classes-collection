class IExplorerClass
{
	__new(iExplorer)
	{
		this.comObj :=  iExplorer
		iExplorer.visible := true
		return this
	}
	
	activateWindow()
	{
		windowName := this.comObj.LocationName
		WinActivate, % windowName
		return this
	}
	
	navigate(url)
	{
		this.comObj.navigate(url)
		While(this.comObj.readyState != 4)
		{
			sleep 50
		}
		return this
	}
	
	waitFor(name)
	{
		while true
		{
			url := this.comObj.Document.title
			IfInString, url, % name
			{	
				break
			}
			debug("Waiting for location: " name "`nSeeing: " url)
			sleep 500
		}
		debug("")
		return this
	}
	
	waitForFullLoad()
	{
		While(this.comObj.document.readyState != "complete" || this.comObj.busy)
		{
			notify(this.comObj.readyState "`n" this.comObj.document.readyState)
			Sleep, 50
		}
		return this		
	}
	
	getElementById(id)
	{
		return this.comObj.document.getElementById(id)
	}
	
	getElementsByClassName(name)
	{
		return this.comObj.document.getElementsByClassName(name)
	}
}