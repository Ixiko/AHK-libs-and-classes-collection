#NoEnv
SetBatchLines, -1

#Include ../Chrome.ahk

TestPages := 3


; --- Define a data URL for the test page ---

; https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs
DataURL =
( Comments
data:Text/html, ; This line makes it a URL
<!DOCTYPE html>
<html>
	<head>
		; Use {} to allow text insertion using Format() later
		<title>Test Page {}</title>
	</head>
	<body>
		<button class="someclass">Click Me!</button>
	</body>
</html>
)


; --- Define some JavaScript to be injected into each page ---

JS =
( Comments
; Using a self-invoking anonymous function for scope management
; https://blog.mgechev.com/2012/08/29/self-invoking-functions-in-javascript-or-immediately-invoked-function-expression/
(function(){
	var clickCount = 0;
	
	; Whenever the button tag with class someclass is clicked
	document.querySelector("button.someclass").onclick = function() {
		clickCount++;
		
		; Prefix the message with AHK: so it can be
		; filtered out in the AHK-based callback function
		console.log("AHK:" + clickCount);
	};
})();
)


; --- Create a new Chrome instance ---

; Define an array of pages to open
DataURLs := []
Loop, %TestPages%
	DataURLs.Push(Format(DataURL, A_Index))

; Open Chrome with those pages
FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile", DataURLs)


; --- Connect to the pages ---

PageInstances := []
Loop, %TestPages%
{
	; Bind the page number to the function for extra information in the callback
	BoundCallback := Func("Callback").Bind(A_Index)
	
	; Get an instance of the page, passing in the callback function
	if !(PageInst := ChromeInst.GetPageByTitle(A_Index, "contains",, BoundCallback))
	{
		MsgBox, Could not retrieve page %A_Index%!
		ChromeInst.Kill()
		ExitApp
	}
	PageInstances.Push(PageInst)
	
	; Enable console events and inject the JS payload
	PageInst.WaitForLoad()
	PageInst.Call("Console.enable")
	PageInst.Evaluate(JS)
}

MsgBox, Running... Click OK to exit


; --- Close the Chrome instance ---

try
	PageInstances[1].Call("Browser.close") ; Fails when running headless
catch
	ChromeInst.Kill()
for Index, PageInst in PageInstances
	PageInst.Disconnect()

ExitApp
return


Callback(PageNum, Event)
{
	; Filter for console messages starting with "AHK:"
	if (Event.Method == "Console.messageAdded"
		&& InStr(Event.params.message.text, "AHK:") == 1)
	{
		; Strip out the leading AHK:
		Text := SubStr(Event.params.message.text, 5)
		
		ToolTip, Clicked %Text% times on page %PageNum%
	}
}
