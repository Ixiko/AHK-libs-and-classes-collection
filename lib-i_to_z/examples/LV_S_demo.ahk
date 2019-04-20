#NoEnv

	testdata = 
	( LTrim
		1,Bulbasaur,Fushigidane,Fushigidane
		2,Ivysaur,Fushigiso,Fushigisou
		3,Venusaur,Fushigibana,Fushigibana
		4,Charmander,Hitokage,Hitokage
		5,Charmeleon,Rizado,Lizardo
		6,Charizard,Rizadon,Lizardon
		7,Squirtle,Zenigame,Zenigame
		8,Wartortle,Kameru,Kameil
		9,Blastoise,Kamekkusu,Kamex
		10,Caterpie,Kyatapi,Caterpie
		11,Metapod,Toranseru,Trancell
		12,Butterfree,Batafuri,Butterfree
		13,Weedle,Bidoru,Beedle
		14,Kakuna,Kokun,Cocoon
		15,Beedrill,Supia,Spear
		16,Pidgey,Poppo,Poppo
		17,Pidgeotto,Pijon,Pigeon
		18,Pidgeot,Pijotto,Pigeot
		19,Rattata,Koratta,Koratta
		20,Raticate,Ratta,Ratta
		21,Spearow,Onisuzume,Onisuzume
		22,Fearow,Onidoriru,Onidrill
		23,Ekans,Abo,Arbo
		24,Arbok,Abokku,Arbok
		25,Pikachu,Pikachu,Pikachu
	)
	; data from https://bulbapedia.bulbagarden.net/wiki/List_of_Japanese_Pokémon_names
	
	LVS_Init("callback", "Index|English|Japanese|Trademarked", 2, -1)  ; args: callbackfunc, col names, col to be returned, col to be searched (-1 for all).
	LVS_SetList(testdata, ",")  ; args: data, field delimiter.
	LVS_UpdateColOptions("AutoHdr|100|Right Auto|Left AutoHdr")  ; call with no args to make them all AutoHdr.
	LVS_SetBottomText("Press (Pg)Up/Down to select; try selecting multiple rows with Ctrl/Shift + movements or Space")
	
	LVS_Show()
return


callback(selected, escaped := False) {  ; escaped is true if gui was closed or esc was pressed
	if escaped
		msgbox escaped from gui
	else
		msgbox % selected
	
	exitapp
}


#Include %A_ScriptDir%\LVS.ahk
