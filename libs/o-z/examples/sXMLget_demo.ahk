; #Include sXMLget.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

xml = <container><Node2>Node 2 before nest<NestedNode><tripleNest attr1="wow">stuff</tripleNest>nested node value</NestedNode><egg>yolk</egg>stuff<stuffing>turkey</stuffing> after nestednode</Node2><Node3>stuff b4 double nested<Node3>Stuff inside double nest</Node3>stuff after double nest</Node3></container>

MsgBox % sXMLGet(xml, "Node2")
MsgBox % sXMLGet(xml, "Node3")
MsgBox % sXMLGet(xml, "tripleNest", "attr1")