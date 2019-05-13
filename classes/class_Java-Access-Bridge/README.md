# Java Access Bridge Wrapper for AutoHotkey

The [Java Access Bridge](http://www.oracle.com/technetwork/articles/javase/index-jsp-136191.html) for Windows is an API provided by Oracle to use the accessibility features of Java-Swing GUIs. This repository contains wrappers for this API to use the Java Access Bridge from AutoHotkey.

The files in this repository are:
- [JavaAccessBridge.ahk](JavaAccessBridge.ahk): A function based wrapper for the Java Access Bridge
- [JavaAccessBridge_class.ahk](JavaAccessBridge_class.ahk): A class based wrapper for the Java Access Bridge
- [JControlWriter.ahk](JControlWriter.ahk): A browser for accessible controls in Java applications
- [JAB Swingset3 Demo.ahk](JAB%20Swingset3%20Demo.ahk): A demo how to use the JAB with SwingSet3.jar (various download locations)
- [JCWGUIStrings.ini](JCWGUIStrings.ini): The GUI-strings for JControlWriter

## How to use

Before you can access Java applications through the Java access bridge you need to enable or install the Java Access Bridge first.

- **Java SE 7 Update 6 or later**: Java Access Bridge can be enabled through the Control Panel in the Ease of Access Center. (See *[Enabling and Testing Java Access Bridge](https://docs.oracle.com/javase/7/docs/technotes/guides/access/enable_and_test.html)*)
- **Java SE 7 Update 5 or earlier**: Java Access Bridge must be installed manually. (See *[Installing Java Access Bridge](http://www.oracle.com/technetwork/articles/javase/index-jsp-136191.html)*)

To get an overview of which accessible information is published by your Java application you can use [JControlWriter.ahk](JControlWriter.ahk).

With your Java application as the active window, press either Ctrl-Alt-F10 or Ctrl-Alt-F11 to show a list of the accessible controls.

## Known issues

- Not all functions are wrapped yet; see comment section at the end of [JavaAccessBridge.ahk](JavaAccessBridge.ahk)
- Java applications can sometimes behave strangely. For instance when you use an action to call a function that opens a dialog, this call may not return until the dialog is closed again, effectively freezing your script. Use the "left click" action in those cases.

