# WinStructs
A collection of definitions for Windows structures for decoding DLL call and OnMessage results etc. For use with HotkeyIt's [_Struct library](https://github.com/HotKeyIt/_Struct).

##What?
WinStructs is just a collection of text strings, there is no logic.  
It would be semantically similar to a "Header file" in C, as it provides information about the makeup of data structures.  
If working in AutoHotkey with DllCall or OnMessage, you are likely to get a Structure back, which you must interpret via bitwise operations. _Struct frees you from this by allowing you to interpret the data like an object, but you need a correctly crafted definition for the Structure - this is what WinSctructs seeks to provide.

##Why?
Because it is a job that only ever needs to be done once for each structure. There is only one "correct" way to do it, so the only thing that would vary between implementations is naming convention.  
Therefore, in an ideal world, the first person to use a Structure decodes it properly and submits to this repostiory, and nobody else ever needs to bother do it again.

##How?...
... Do I decode a structure?  
The rules are fairly simple, but I am not hugely up on it yet. A part of this project is also to try and build a simple tutorial on how to convert the definition from an MSDN page into a valid definition.  

##Who?
Anyone is welcome to contribute - the AHKScript group is a non-exclusive group and all group members can make commits to the project.  
Make a post [here](http://ahkscript.org/boards/viewtopic.php?t=936) to request access.
