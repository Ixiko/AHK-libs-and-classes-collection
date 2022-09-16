# Edge.ahk

Automate Microsoft Edge using native AutoHotkey.


## How it works

Chrome offers a WebSocket based API they call the **Chrome DevTools Protocol**. This API is what allows web development tools to build integrations, and tools such as Selenium to perform their automation. The protocol's documentation describes a plethora of exciting endpoints accessible using this library, and can be found at the link below.

https://chromedevtools.github.io/devtools-protocol/


## Advantages

* **No external dependencies such as Selenium are required**
* Edge can be automated even when running in headless mode
	* Launching in headless mode is not currently supported by this library
* Edge consistently benchmarks better than Internet Explorer
* Edge offers extensions which provide unique opportunities for interaction
	* Automate your Chromecast
	* Connect to remote servers with FoxyProxy and update web based configs
	* Manage your password vault with LastPass
* Many features are available that would be difficult to replicate in Internet Explorer
	* `Page.printToPDF`
	* `Page.captureScreenshot`
	* Geolocation spoofing


## Limitations

* Edge **must** be started in debug mode
	* If edge is already running out of debug mode, it must either be **closed and reopened** or **launched again under a new profile** that isn't already running
	* **You cannot attach to an existing non-debug session**
* Less flexible than Internet Explorer's COM interface
	* Cannot pass function references for callbacks


## Using this Library

#### You need to clone the repository with the submodules using: 
```
git clone --recurse-submodules https://github.com/SaifAqqad/Edge.ahk.git
```

To start using this library you need to create an instance of the class `Edge`. `Edge`'s constructor accepts four optional parameters:

1. **ProfilePath** - This is the path, relative to the working directory, that your Edge user profile is located. If an empty folder is given, edge will generate a new user profile in it. **When this parameter is omitted, Edge will be launched under the default user profile.** However, if edge is already running under that user profile out of debug mode, this will fail. Because of this, **it is recommended to always launch Edge under an alternate user profile.**
2. **URLs** - The page or array of pages that edge should initially be opened to. Pass an empty string to open Edge's homepage. **When this parameter is omitted, Edge will be opened to `about:blank`.**
3. **EdgePath** - The path to find the Edge executable file. **When this parameter is omitted, Edge will be launched from the path in its start menu entry.**
4. **DebugPort** - The network port to communicate with Edge over. **When this parameter is omitted, port `9222` will be used** as specified in the Chrome DevTools Protocol documentation.

Once an instance of the class `Edge` has been created, Microsoft Edge will be launched. To connect to the newly opened page call `PageInstance := EdgeInstance.GetPage()`. Afterward, use `PageInstance.Call()` to call protocol endpoints, and `PageInstance.Evaluate()` to execute JavaScript.

```AutoHotkey
#Include Edge.ahk

; Create an instance of the Edge class using
; the folder EdgeProfile to store the user profile
FileCreateDir, EdgeProfile
EdgeInst := new Edge(A_ScriptDir "\EdgeProfile")

; Connect to the newly opened tab and navigate to another website
; Note: If your first action is to navigate away, it may be just as
; effective to provide the target URL when instantiating the Edge class
PageInst := EdgeInst.GetPage()
PageInst.Call("Page.navigate", {"url": "https://autohotkey.com/"})
PageInst.WaitForLoad()

; Execute some JavaScript
PageInst.Evaluate("alert('Hello World!');")

; Close the browser (note: this closes *all* pages/tabs)
PageInst.Call("Browser.close")
PageInst.Disconnect()

ExitApp
return
```

**You can find more sample code showing how to use this library in the Examples folder.**
