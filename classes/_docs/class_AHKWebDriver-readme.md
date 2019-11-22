# AHKWebSession

> __IMPORTANT NOTE__

>__¡¡This is not a Selenium port!!__

>__use json api from teadrinker (authotkey)__

## What is this

Is a Autohotkey native WebDrive client protocol.

__Url API definition:__ https://w3c.github.io/webdriver

this V1.0 inlude all functions but no actions, I'm working in this api.

They are only two objects:

- __WDSession__ representing one connection to WebDriver driver, attributes and functions.
- __WDSession.WDElement__ wraping one Web Element attributes and their functions.

WDSession.WDElement are not require to construct explicity (I think).

The functions, defined by W3Cm, are organized by this two objects and the map is (in general):

- Functions called with GET use _getNameFunciton_
- Functions called with DELETE use _delNameFunction_
- Functions called with POST are not rename, use _nameFunction_
- Functions with 2 token (window, frame, etc, except Element) use _[prefix]NameToken1NameToken2_

## Using

First you need to download one webdriver midleware for your browser (and version).
- Google Chorme: https://chromedriver.chromium.org/
- Mozilla: https://github.com/mozilla/geckodriver/releases
- IExplorer: https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver
- Edge: https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/#downloads

Run it. Read webdriver documentation to know what port it's open and other things that you might need like running parameters, if needed.

This sample show the minimun code needed to get one connection. Webdriver it's open in localhost and port 9515 (standard for Google Chrome WebDrive), finally you delete the session to disconnect.

```
#include AHKWebDriver.ahk

wd := new WDSession("http://localhost:9515")
if(wd.rc.isError){
    msgbox % "Error:" wd.rc.value.error " " wd.rc.value.message
    ExitApp
}
[... you code here ..]
wd.delete()
```

Always, when you execute one WDSession call, it returns with one object containing all data of the current status:

__wd.rc__ this is the object.

Its attributes are:

The more importants are:
- __wd.rc.isError__: true/false if there is one 
error, messaging error is in value.
- __wd.rc.value__: the true asking data (including error info).

for debug or extend information:

- __wd.rc.status__: http status from the webdriver.
- __wd.rc.raw__: raw data returning from the webdriver.

One time you are connected to and have one WDSession, it's then, when u can call the api. For example, click the documentation link in the autohotkey page:

```
; get Session
wd := new WDSession("http://localhost:9515")
; navigate to new site
wd.url("https://autohotkey.com")
; click over documentation
wd.element(WDSession.XPath,"//*[@id=""menu-0""]/div/div/div/div[3]/nav/div/ul/li[2]/a").click()
```

This, the second code, shows the use of element object as a parameter in a javascript call:

```
; get Session
wd := new WDSession("http://localhost:9515")
; navigate to new site
wd.url("https://autohotkey.com")
; click over documentation
we := wd.element(WDSession.XPath,"//*[@id=""menu-0""]/div/div/div/div[3]/nav/div/ul/li[2]/a")
wd.execute("arguments[0].click()",[we])) 
```

In the end, one more complex. Pushing an element object into another general object and using it as a parameter in a Javascript call.

```
; get Session
wd := new WDSession("http://localhost:9515")
; navigate to new site
wd.url("https://autohotkey.com")
; click over documentation
we := wd.element(WDSession.XPath,"//*[@id=""menu-0""]/div/div/div/div[3]/nav/div/ul/li[2]/a")
wd.execute("arguments[0].boton.click(); alert('arguments[0].datos')",[{datos:"Close me before continue!", boton: we}])
```
> __The API call documentation is a WIP (Work In Progress)__

Regards,

Juan Gonzalo de Silva Medina.
