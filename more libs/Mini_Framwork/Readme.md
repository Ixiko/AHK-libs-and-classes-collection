# Mini-Framework
Mini-Framework for AutoHotkey

Library of Mini-Framework
Copyright (c) 2013 - 2017 Paul Moss
Licensed under the GNU General Public License GPL-2.0

Requires [AutoHotkey {v1.1.21+}][1]

## Introduction
Mini-Framework is as collection of classes built for [AutoHotkey][1] that help give functionality similar to a strongly typed language.

Mini-Framework attempts to bridge the gap between the powerful scripting language of [AutoHotkey][1] and a more strongly typed language. The classes are built in a Mono/.Net style.

The [MfType][7] class can be used to get information from an object. All objects have a [GetType()][9] method that returns an instance of the [MfType][7] class. All object inherit from [MfObject][8] and therefore inherit all the methods of [MfObject][8].

The Mini-Framework classes are built with the power of strongly type objects while maintaining flexibility with [AutoHotkey][1] variables. Many of the classes accept variables as parameters in their methods. Overloades are made possible Mini-Framework.

All the Classes are prefixed in Root [System][19] Namespace with **Mf** to help avoid any conflicts with naming conventions and variables in existing projects.

There is also a package available for [Sublime Text][2] to give intellisense and syntax highlighting to Mini-Framework.

All list and collectins use a **Zero-Based index**.

There are classes that represent [Object][8], [Boolean][10], [String][11], [Byte][12], [Int16][13], [Int32][14], [Int64][15] and [Float][16].  
Mini-Framework also has many built in [Exceptions][17] as well for refined error control.  
There are many other classes incldued in the Mini-Framework as well.

### Recent changes
[Recent changes][20]

### Installation
Installation of Mini-Framework is simple and can be installed with a single installer.  
Download the latest version of [MfSetup.exe][4]

If required [AutoHotkey {v1.1.21+}][1] version of [AutoHotkey][1] is not installed then  [MfSetup.exe][4] will automatically download and installed it first.

### Getting Help
There is a package available for [Sublime Text][2] intellisense for user of [Sublime Text][2]. Get the Sublime Text package [Here][18]  
Help is available online and as a separate help file and can also be accesed online [here][3].

A program named **AutoHotKey Snippit** is built in part upon **Mini-Framework** and can be download [here][5]. **AutoHotkey Snippit** come with a preinstalled template named *AutoHotkey* that contains plugins to quickly bring up the help file for **Mini-Framework** or **AutoHotkey**. By selecting a word in your favourite AutoHotkey editor you can simply click a shortcut key to get help on that word.

Shortcut keys can be set to what ever you want in AutoHotkey Snippit but the defaults for help are `ctl+F1` to get help on a Mini-Framework class or method and `ctl+F2` to get help on an AutoHotkey keyworkd.

Note: User of [AHS Studio][5] may need to compile [AHS Studio][5] before **AutoHotKey Snippit** can act upon it.


### Getting started
Adding Mini-Framework to your project is as simple as adding `#Include <inc_mf_0_4>` in the top of your script.

To include othe namespaces sucas as System.IO and the include for theat namespace.  
`#Include <inc_mf_System_IO_0_4>`

#### AutoHotkey Snippit
AutoHotkey Snippit is an automation program that also has a template available to quickly accesss help for kewords in both AutoHotkey and Mini-Framework. Onece AutoHotkey Snippit is installed and the templet is set you can simply get help for any AutoHotkey keyworkd or any Mini-Framework class / keyword by pressing a shortcut key. AutoHotkey Snippit can be set to work with any editor that you choose to write [AutoHotkey][1] code in.

#### Future Versions
Future version of Mini-Framework will not interfere with current versions as each version in separated.

#### Distribution
See the [help][3] file for information on how to distribute with your application or project.


[1]:https://autohotkey.com
[2]:http://www.sublimetext.com
[3]:https://amourspirit.github.io/Mini-Framework/
[4]:https://github.com/Amourspirit/Mini-Framework/raw/master/Latest/stable/0.4x/MfSetup.exe
[5]:https://github.com/Amourspirit/AutoHotkey-Snippit
[6]:https://github.com/maestrith/AHK-Studio/wiki
[7]:https://amourspirit.github.io/Mini-Framework/index.html?MfType.html
[8]:https://amourspirit.github.io/Mini-Framework/index.html?MfObject.html
[9]:https://amourspirit.github.io/Mini-Framework/index.html?MfObjectGetType.html
[10]:https://amourspirit.github.io/Mini-Framework/index.html?MfBool.html
[11]:https://amourspirit.github.io/Mini-Framework/index.html?MfString.html
[12]:https://amourspirit.github.io/Mini-Framework/index.html?MfByte.html
[13]:https://amourspirit.github.io/Mini-Framework/index.html?MfInt16.html
[14]:https://amourspirit.github.io/Mini-Framework/index.html?MfInteger.html
[15]:https://amourspirit.github.io/Mini-Framework/index.html?MfInt64.html
[16]:https://amourspirit.github.io/Mini-Framework/index.html?MfFloat.html
[17]:https://amourspirit.github.io/Mini-Framework/index.html?NS_System.html#Exceptions
[18]:https://github.com/Amourspirit/SublimeMiniFrameworkAutoHotkey
[19]:https://amourspirit.github.io/Mini-Framework/index.html?NS_System.html
[20]:https://amourspirit.github.io/Mini-Framework/index.html?Changes.html
