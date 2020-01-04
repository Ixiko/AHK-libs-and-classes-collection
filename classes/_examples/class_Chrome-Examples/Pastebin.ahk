#NoEnv
SetBatchLines, -1

#Include ../Chrome.ahk


; --- Create a new Chrome instance ---

; Instead of providing a URL here, let's try
; navigating later for demonstration purposes
FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile")


; --- Connect to the page ---

if !(PageInst := ChromeInst.GetPage())
{
	MsgBox, Could not retrieve page!
	ChromeInst.Kill()
}
else
{
	; --- Navigate to the desired URL ---
	
	PageInst.Call("Page.navigate", {"url": "https://p.ahkscript.org/"})
	PageInst.WaitForLoad()
	
	
	; --- Manipulate the page using the DOM endpoint ---
	; One of the ways you can interact with elements on the page is by using
	; the Chrome debugger API's DOM (Document Object Model) input. While this
	; works, it can be more difficult than injecting JavaScript to perform
	; the same manipulations.
	;
	; However, one benefit this method has over JavaScript injection is that
	; you would not need to escape values before passing them to the endpoint.
	; If you were using JavaScript injection and your value had a stray
	; non-escaped end-quote in it, the text could break out of its string and
	; be the cause of a JavaScript injection vulnerability (or just buggy code).
	
	; Find the root node
	RootNode := PageInst.Call("DOM.getDocument").root
	
	; Find and change the name element
	NameNode := PageInst.Call("DOM.querySelector", {"nodeId": RootNode.nodeId, "selector": "input[name=name]"})
	PageInst.Call("DOM.setAttributeValue", {"nodeId": NameNode.NodeId, "name": "value", "value": "ChromeBot"})
	
	; Find and change the description element
	DescNode := PageInst.Call("DOM.querySelector", {"nodeId": RootNode.nodeId, "selector": "input[name=desc]"})
	PageInst.Call("DOM.setAttributeValue", {"nodeId": DescNode.NodeId, "name": "value", "value": "Pasted with ChromeBot"})
	
	
	; --- Manipulate the page using JavaScript injection ---
	; Whatever you pass to PageInst.Evaluate will act exactly like you were
	; inputting it to the page's developer tools JavaScript console.
	
	PageInst.Evaluate("editor.setValue('test');")
	PageInst.Evaluate("document.querySelector('input[type=submit]').click();")
	PageInst.WaitForLoad()
	MsgBox, % "A new paste has been created at "
	. PageInst.Evaluate("window.location.href").value
	
	
	; --- Close the Chrome instance ---
	
	try
		PageInst.Call("Browser.close") ; Fails when running headless
	catch
		ChromeInst.Kill()
	PageInst.Disconnect()
}

ExitApp
return
