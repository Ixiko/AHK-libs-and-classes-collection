; #Include yaml.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Example copied from posting of HotKeyIt.

yamlText= ;example yaml data
(
`%yaml
--- testdata, this is a comment only
Settings:
  Size:
    width: 1
    height: 2
  Colors:
    background: blue
    foreground: black
    text: white
  ButtonText:
    Button1: AutoHotkey
    Button2: OK
)
yml:=Yaml_Init(yamlText) ;create database from text
MsgBox % Yaml_Get(yml,"Settings.Colors.background") ;get a key
Yaml_Add(yml,"Settings.ButtonText.Button3","Exit") ;add a key
MsgBox % Yaml_Save(yml) ;Show dump of database