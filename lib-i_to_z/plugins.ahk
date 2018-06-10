/*
Plugins for CL3

To add a plugin:
Make a file named "MyPlugins.ahk" with the following content below
(between the lines)

PluginScriptFunction.ahk: function you made that modifies
the content of the clipboard before it will be pasted.
MyPlugins.ahk will not be part of CL3 so will never be overwritten
by updates.

To add each plugins:
1. Create a script and place it in the plugins\ directory
2. edit plugins\Myplugins.ahk and add the name of script TWICE
   in the "join list" at the top and in the #include section below it as well.
   The order in which they are listed is used for the menu entries.

; -----------------------------
MyPluginlistFunc=
(join|
PluginScriptFunction.ahk
)

#include %A_ScriptDir%\plugins\PluginScriptFunction.ahk
; etc
; -----------------------------

*/

pluginlistFunc=
(join|
AutoReplace.ahk
ClipChain.ahk
Compact.ahk
DumpHistory.ahk
Search.ahk
Slots.ahk
Fifo.ahk
)

pluginlistClip=
(join|
Lower.ahk
Title.ahk
Send.ahk
LowerReplaceSpace.ahk
Upper.ahk
)

Gosub, SlotsInit
Gosub, ClipChainInit
Gosub, FifoInit

#include *i %A_ScriptDir%\plugins\MyPlugins.ahk

#include %A_ScriptDir%\plugins\LowerReplaceSpace.ahk
#include %A_ScriptDir%\plugins\Lower.ahk
#include %A_ScriptDir%\plugins\Title.ahk
#include %A_ScriptDir%\plugins\Upper.ahk
#include %A_ScriptDir%\plugins\Send.ahk
#include %A_ScriptDir%\plugins\AutoReplace.ahk
#include %A_ScriptDir%\plugins\Slots.ahk
#include %A_ScriptDir%\plugins\Search.ahk
#include %A_ScriptDir%\plugins\DumpHistory.ahk
#include %A_ScriptDir%\plugins\ClipChain.ahk	
#include %A_ScriptDir%\plugins\Compact.ahk	
#include %A_ScriptDir%\plugins\Fifo.ahk