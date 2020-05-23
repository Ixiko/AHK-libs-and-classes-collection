#include class_EasyXML.ahk

xml := class_EasyXML("xmlTest.xml")

xml.AddSection("testSection")
xml.AddKey("testSection","testKey","testVal")


xml.Save()
