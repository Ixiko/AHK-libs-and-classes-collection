#Include <ConfOverride>

; This is an example configuration object.
CONF := {}
       CONF.SCRIPT :=
       {
           NAME                : "Script Name"
         , DESCRIPTION         : "Script Descriptiom"
	     , ICON                : A_ScriptDir "\ScriptIcon.ico"
	     , INI                 : A_ScriptDir "\ScriptIni.ini"
         , VERSION             : 0.1
         , __LOCKED            : 1
       }
       CONF.SETTINGS :=
       {
           A : "Value"
         , B : "Value"
       }
       CONF.PROFILES :=
       {
           A : "Value"
       }

MsgBox(CONF.SETTINGS.A)
ConfOverride(&CONF, CONF.SCRIPT.INI)
MsgBox(CONF.SETTINGS.A)
