#SingleInstance force
#NoEnv

jf := new JSONFile("test.json")

; jf now behaves (nearly) identical to a normal object when setting/getting keys

; you can set keys/value pairs
jf.key := "value"
msgbox % jf.JSON(true)

; you can also make subobjects like normally
jf.arr := ["sub", "array", 42]
msgbox % jf.JSON(true)

jf.obj := {mykey: "my value", subobj: {morekeys: "more values", keyseverywhere: "and even more values!"}}
msgbox % jf.JSON(true)

; you can also use object functions and methods like normally
msgbox % jf.HasKey("obj")
jf.obj.Delete("subobj")
msgbox % jf.JSON(true)
jf.Delete("obj")
msgbox % jf.JSON(true)

; you can also call several methods

; this method fills the object with keys from another object, in this case the default settings object from a project
; if a key already exists, it does nothing, it will only fill in keys that are missing
jf.Fill({ StartUp: true
	, Font: "Segoe UI Light"
	, Color: {Selection: 0x44C6F6, Tab: {Dark: 0x404040, Orange: 0xFE9A2E}} ; FE9A2E
	, GuiState: {ActiveTab: 1, GameListPos: 1, BindListPos: 1}
	, Plugins: ["text", "moretext"]
	, VibrancyScreens: [1]
	, VibrancyDefault: 50})

; to get the json call JSON(). you can call JSON(true) to get the prettified JSON
msgbox % jf.JSON(true)

; to save do Save()
jf.Save(true) ; save prettified JSON

; to for-loop over the shallow object, you have to get the actual data object and not the instance, so you gotta do
; this is practically the only difference from using a normal object
for Key, Value in jf.Object()
	msgbox % Key " => " (IsObject(Value) ? "*OBJECT*" : Value)

; similarly you can get the file name and file object via
msgbox % "File: " jf.File()
msgbox % "FileObj is object: " IsObject(jf.FileObj())

; to close the file object and clean up, simply delete the instance
jf := ""

ExitApp