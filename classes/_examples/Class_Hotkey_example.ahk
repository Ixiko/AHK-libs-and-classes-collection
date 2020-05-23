#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
CoordMode, ToolTip, Screen
#Warn
; Windows 8.1 64 bit - Autohotkey v1.1.28.00 32-bit Unicode


#Include %A_ScriptDir%\Hotkey.ahk
; Hotkey.__Delete := Func("onDelete")

joystick := false

new Hotkey("^!a", "f1") ; un hotkey qui exécute la fonction 'f1' lorque la combinaison 'CTRL+ALT+A' est réalisée
new Hotkey("!^a", Func("f1"), true) ; identique au précédent - le premier paramètre étant normalisé en '^!a' - mais plus explicite dans la syntaxe
new Hotkey("^!b", "f1", "f2", false) ; en effet, le dernier paramètre - ici 'false' - détermine si le hotkey est initialement actif ou non
new Hotkey("^!c", "f1", "f2", "f3", "f4") ; exemple d'un hotkey à 4 callbacks
hk1 := new Hotkey("^!e", "f1", "f2", false) ; par ailleurs, l'instance peut être sauvegardée dans une variable - ici 'hk1'
hk2 := new Hotkey("^!h", bind("DllCall", "MessageBox", "Int", 0, "Str", "message", "Str", "titre", "Int", 0)) ; un hotkey qui affiche un MsgBox via 'dllcall'
; MsgBox % hk2.context.type "," hk2.context.title
; ====================================================================================================== créer des hotkeys sensibles au contexte

Hotkey.setContext("IfWinExist", "ahk_exe mspaint.exe") ; crée un contexte pour les hotkeys subséquents, lesquels ne s'executeront que si le contexte retourne 'true' au moment où la (combinaison de) touche(s) est réalisée
	new Hotkey("^!i", bind("f1"), bind("stop", true, bind("WinActive", "ahk_exe notepad.exe")), bind("f2")) ; la fonction 'stop' est une manière d'interrompre l'exécution de la chaîne des callbacks si une condition n'est pas satisfaite
Hotkey.setContext("If", Func("MouseIsOver").bind("ahk_exe notepad.exe")) ; les hotkeys subséquents ne s'executeront que si la souris est au-dessus d'une fenêtre appartenant au processus 'notepad' (que si la fonction objet passée en argument retourne 'true')
	new Hotkey("^!j", bind("DllCall", "MessageBox", "Int", 0, "Str", "message", "Str", "titre", "Int", 0))
Hotkey.clearContext() ; désactive la sensibilité au contexte: les hotkeys créés par la suite fonctionneront quel que soit le contexte

;  ====================================================================================================== activer/désactiver des hotkeys

new Hotkey("^!f", bind(hk1, "enable")) ; un hotkey qui active - si besoin est - l'instance de la classe Hotkey sauvegardée dans la variable 'hk1' (nécessite la fonction 'bind')
new Hotkey("^!g", ObjBindMethod(hk1, "disable")) ; fonction inverse du précédent hotkey (et en utilisant cette fois par exemple la fonction native 'ObjBindMethod')

new Hotkey("!k", Func("ListHotkeys"), bind(Hotkey, "disableAll"), Func("ListHotkeys")) ; un hotkey qui désactive l'ensemble des instances créées à l'aide de la classe Hotkey
Gosub, sub
	!e::ListHotkeys(), Hotkey.enableAll(), ListHotkeys() ; si la tâche de réactiver l'ensemble des hotkeys désactivés par la méthode 'disableAll' est confiée à un hotkey, il doit nécessairement être un '::'-label hotkey
sub:

; ====================================================================================================== joy hotkeys

if (joystick:=(GetKeyState("1JoyPOV") <> "")) { ; détermine si une manette est connectée au port 1

	Hotkey.setGroup("joystick") ;  spécifie un groupe pour les hotkeys, le créant si nécessaire
		Hotkey.setContext("IfWinActive", "ahk_exe explorer.exe")
			hk3 := new Hotkey("1Joy3 Up", "joyOnReleased", false) ; la classe Hotkey supporte la variante 'Up' pour les bouttons du joystick
			hk3.enable() ; active l'instance 'hk3' (initialement inactive)
		Hotkey.setContext("IfWinActive", "ahk_exe notepad.exe")
			hk4 := new Hotkey("1Joy3", "joyWhileDown")
		Hotkey.setContext("If", Func("MouseIsOver").bind("ahk_exe mspaint.exe"))
			hk5 := new Hotkey("1Joy3", bind("stop", false, bind("MouseIsOver", "ahk_exe mspaint.exe")), bind("joyWhileDown")) ; un hotkey qui ne s'enclenche ET ne continue de s'exécuter que si la souris est au-dessus d'une fenêtre appartenant au processus 'paint'
			hk5.ITERATOR_PERIOD := 25 ; l'instance 'hk5' exécutera à intervalle beaucoup plus rapide 'joyWhileDown' le cas échéant (la valeur de la propriété ITERATOR_PERIOD étant par défaut de 95 en effet)
		Hotkey.setContext("IfWinActive", "ahk_class WorkerW") ; si le desktop - le bureau - est actif
			hk6 := (new Hotkey("Joy4", "joyWhileDown", "joyWhileDown", "joyWhileDown")).onReleased("joyOnReleased")
			; les deux variantes peuvent partager le même contexte et malgré tout toutes deux s'executer à l'aide de la méthode 'onReleased', qui retourne un dual hotkey
			; MsgBox % hk6.portNumber
	Hotkey.setGroup()

}

; ======================================================================================================

new Hotkey("ц", "f1") ; par défaut, aucun message n'est affiché si, le cas échéant, la (combinaison de) touche(s) n'est pas supportée par le keyboard layout actuel

OnExit, handleExit
var := true ; un simple variable utilisée par le 'toggle' défini un peu plus bas
return

; ===============================================================================================================================

#If joystick
	!d::ListHotkeys(), Hotkey.disableAll("joystick"), ListHotkeys() ; désactive tous les hotkeys appartenant au groupe 'joystick'
	^!x::hk3:=hk3.delete(), hk5:=hk5.delete() ; suppression de quelques instances de la classe Hotkey
#If

!t::hk2.enable(var:=!var) ; un simple 'toggle'
!x::hk1:=hk1.delete()
!i::MsgBox % st_printArr(Hotkey)

handleExit:
Hotkey.deleteAll()
ExitApp

; ***************************************************************************************

f1() {
MsgBox % "A_TickCount > " . A_TickCount
}
f2() {
MsgBox % "A_Now > " . A_Now
}
f3() {
MsgBox % "A_AhkVersion > " . A_AhkVersion
}
f4() {
MsgBox % "A_OSVersion > " . A_OSVersion
}

joyWhileDown() {
static _i := 0
	ToolTip % ++_i
}
joyOnReleased() {
MsgBox % A_ThisFunc
}

MouseIsOver(_winTitle) { ; une fonction qui détermine si la souris est au-dessus d'une fenêtre donnée (https://www.autohotkey.com/docs/commands/_If.htm#Examples)
	MouseGetPos,,, _ID
return WinExist(_winTitle . " ahk_id " . _ID)
}
stop(_v, _f) {
if (!!%_f%() = !!_v)
	Exit
}

ListHotkeys() {
ListHotkeys
WinWait % "ahk_id " . A_ScriptHwnd
WinWaitClose
}

; la fonction ci-dessous nous permet en particulier ici de pouvoir utiliser indifféremment 'bind' en lieu et place des fonctions 'func' et 'objbindmethod'
bind(_fn, _args*) {
return new Bound.Func(_fn, _args*)
}

st_printArr(_array, _depth:=5, _indentLevel:="") { ; cf. https://autohotkey.com/boards/viewtopic.php?f=6&t=53

	for _k, _v in _array, _list := "" {
		if (SubStr(_k, 1, 1) = "_")
			continue
		_list .= _indentLevel . "[" . _k . "]"
		if (IsObject(_v) && _depth > 1)
			_list .= "`n" . st_printArr(_v, _depth - 1, _indentLevel . A_Tab)
		else _list .= " => " . _v
		_list .= "`n"
	}
	return RTrim(_list)

}
; onDelete(this) {
; static _i := 0
	; ToolTip % this.keyName . " - " . ++_i
; sleep, 300
; }
