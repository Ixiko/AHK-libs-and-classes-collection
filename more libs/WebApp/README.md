# Webapp.ahk
"AHK-Webkit" / Webapp.ahk - Library for developing web-based apps with AutoHotkey. (Actually uses IE [Trident])  
Released under the [MIT License](LICENSE)    
  
## Getting started
Webapp.ahk projects should have one AutoHotkey script (*.ahk) file. See [Example.ahk](src/Example.ahk). This file must have the following in the header:  
  
```AHK
#Include Lib\Webapp.ahk
__Webapp_AppStart:
;<< Header End >>
```  
  
Note: Do not change the working directory; Webapp.ahk handles it. Aurelain's Exo is planned to be intergrated into Webapp.ahk. Custom functions maybe added easily. See the provided example html and ahk files.  
**Important!**: It is strongly recommended to include the following meta tag in the html files:  
`<meta http-equiv='X-UA-Compatible' content='IE=edge'>`
  
A Webapp.ahk project must have a `webapp.json` configuration file.  
  
```JSON
{
  "name":                   "My App",
  "width":                  640,
  "height":                 480,
  "protocol":               "app",
  "protocol_call":          "app_call",
  "html_url":               "index.html",
  "NavComplete_call":       "app_page",
  "Nav_sounds":             true,
  "fullscreen":             true,
  "DPI_Aware":              true,
  "ZoomLevel":              100,
  "AllowZoomLevelChange":   true
}
```

- `Width` & `Height`: Webapp.ahk allows window resizing just like any other application. The `width` and `height` options here are to set the application's starting size.
- The `name` option is the text that will be displayed in the title bar. It can be changed on run-time with `setAppName()`. 
- The `html_url` option is the starting HTML file for the App to launch with. It defaults to `index.html` if none is specified.
- The `protocol` option is for filtering URL prefixes such as whether to run a function when a link like `app://msgbox/hello` is clicked. 
- The `protocol_call` option is the name of the function in your AutoHotkey that will run in these cases. It defaults to `app_call()` if none is specified.  
- The `NavComplete_call` option is the name of the function in your AutoHotkey that will run when a page is finished loading. Its first argument is the new page's URL. It defaults to `app_page()` if none is specified.  
- The `Nav_sounds` parameter (boolean) is optional. If left unspecified, it defaults to false. The Navigation sounds correspond to the sounds made by IE during navigation such as the infamous "click" sound.
- The `fullscreen` parameter (boolean) is optional. If left unspecified, it defaults to false. This sets whether the application should start in fullscreen or as a window of the specified size (`Width` & `Height`).
- The `DPI_Aware` parameter (boolean) is optional. If left unspecified, it defaults to true. This sets whether the application should do zoom level auto-correction based on the system's DPI.
- The `ZoomLevel` option is the percent scaling for the App to launch with (e.g. specify `200` for 200% scaling). It defaults to `100` if none is specified.
- The `AllowZoomLevelChange` parameter (boolean) is optional. If left unspecified, it defaults to true. This sets whether the application should allow users to change the zoom level with either `Ctrl +/-` or `Ctrl Wheel Up/Down`.

Note: For example, if `protocol` is set to `myapp` and a `myapp://test/1234` link is clicked, the set `protocol_call` function will be called and will receive `test/1234` as its first argument. If `protocol` is set to `*`, the set `protocol_call` function will run for **ANY** link clicked and it will receive `myapp://test/1234` (the whole URL) as its first argument. This is not recommended for most cases, as links with `href="#"` will also trigger the function (usually unwanted behaviour).  
  
## Special thanks
A special thanks to Coco, VxE, Lexikos, Phatricko, MrBubbles and the AutoHotkey community.
