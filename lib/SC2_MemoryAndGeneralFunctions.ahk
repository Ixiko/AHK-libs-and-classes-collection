;lets make all of the offsets super global (cant be fucked putting them in
; a global memory address array)
Global B_LocalCharacterNameID
, B_LocalPlayerSlot
, B_pStructure
, S_pStructure
, O_pStatus
, O_pXcam
, O_pCamDistance
, O_pCamAngle
, O_pCamRotation
, O_pYcam
, O_pTeam
, O_pType
, O_pVictoryStatus 
, O_pName
, O_pRacePointer
, O_pColour
, O_pAccountID
, O_pAPM
, O_pEPM
, O_pWorkerCount
, O_pWorkersBuilt
, O_pHighestWorkerCount
, O_pBaseCount
, O_pSupplyCap
, O_pSupply
, O_pMinerals
, O_pGas
, O_pArmySupply
, O_pMineralIncome
, O_pGasIncome
, O_pArmyMineralSize
, O_pArmyGasSize

, P_IdleWorker
, O1_IdleWorker
, O2_IdleWorker
, B_Timer
, B_rStructure
, S_rStructure
, P_ChatFocus
, O1_ChatFocus
, O2_ChatFocus
, P_MenuFocus
, O1_MenuFocus
, P_SocialMenu
, B_uCount
, B_uHighestIndex
, B_uStructure
, S_uStructure
, O_uModelPointer
, O_uTargetFilter
, O_uBuildStatus
, O_XelNagaActive
, O_uOwner
, O_uX
, O_uY
, O_uZ
, O_uDestinationX
, O_uDestinationY
, O_P_uCmdQueuePointer
, O_P_uAbilityPointer
, O_uChronoState
, O_uInjectState
, O_uHpDamage
, O_uShieldDamage
, O_uEnergy
, O_uTimer
, O_cqState

, O_mUnitID
, O_mSubgroupPriority
, O_mMiniMapSize
, B_SelectionStructure
, B_CtrlGroupOneStructure
, S_CtrlGroup
, S_scStructure
, O_scTypeCount
, O_scTypeHighlighted
, O_scUnitIndex

, B_localArmyUnitCount
, O1_localArmyUnitCount
, O2_localArmyUnitCount
, B_TeamColours
, P_SelectionPage
, O1_SelectionPage
, O2_SelectionPage
, O3_SelectionPage
, DeadFilterFlag
, BuriedFilterFlag
, B_MapStruct
, O_mLeft
, O_mBottom
, O_mRight
, O_mTop
, aUnitMoveStates
, B_UnitCursor
, O1_UnitCursor
, O2_UnitCursor

, P_IsUserPerformingAction
, O1_IsUserPerformingAction
, P_IsBuildCardDisplayed
, 01_IsBuildCardDisplayed
, 02_IsBuildCardDisplayed
, 03_IsBuildCardDisplayed
, P_ChatInput
, O1_ChatInput
, O2_ChatInput
, O3_ChatInput
, O4_ChatInput
, B_CameraDragScroll
, B_InputStructure
, B_iMouseButtons
, B_iSpace
, B_iNums
, B_iChars
, B_iTilda
, B_iNonAlphNumChars
, B_iNonCharKeys
, B_iFkeys
, B_iModifiers

, B_CameraMovingViaMouseAtScreenEdge
, 01_CameraMovingViaMouseAtScreenEdge
, 02_CameraMovingViaMouseAtScreenEdge
, 03_CameraMovingViaMouseAtScreenEdge
, B_IsGamePaused
, B_FramesPerSecond
, B_Gamespeed
, B_ReplayFolder
, B_HorizontalResolution
, B_VerticalResolution


global aUnitModel := []
, aStringTable := []
, aMiniMapUnits := []

/*
  O_pTimeSupplyCapped := 0x840
  O_pActionsPerformed := 0x5A0 ; accumulative user commands
*/

loadMemoryAddresses(base, version := "")
{
	if (version = "2.1.0.28667")
	{
		versionMatch := "2.1.0.28667"
		#include %A_ScriptDir%\Included Files\oldOffsets\2.1.0.28667.ahk
	}
	else 
	{
		if (version = "2.1.1.29261" || !version) ; !version encase the findVersion function stuffs up and returns 0/blank, thereby just assume match with latest offsets
			versionMatch := "2.1.1.29261"

		;	[Memory Addresses]
			B_LocalCharacterNameID := base + 0x04F15C14 ; stored as string Name#123
			B_LocalPlayerSlot := base + 0x112E5F0 ; note 1byte and has a second 'copy' (ReplayWatchedPlayer) just after +1byte eg LS =16d=10h, hex 1010 (2bytes) & LS =01d = hex 0101
			B_ReplayWatchedPlayer := B_LocalPlayerSlot + 0x1
			B_pStructure := base + 0x35F55A8  			 
			S_pStructure := 0xE10
			 O_pStatus := 0x0
			 O_pXcam := 0x8
			 O_pYcam := 0xC	
			 O_pCamDistance := 0x10 ; 0xA - Dont know if this is correct - E
			 O_pCamAngle := 0x14
			 O_pCamRotation := 0x18
			

			 O_pTeam := 0x1C
			 O_pType := 0x1D ;
			 O_pVictoryStatus := 0x1E
			 O_pName := 0x60 ;+8
			 
			 O_pRacePointer := 0x158
			 O_pColour := 0x1B0
			 O_pAccountID := 0x1C0 ; ????

			 O_pAPM := 0x5E8 	; 0x598 	
			 O_pEPM := 0x5D8 	; ?????

			 O_pWorkerCount := 0x7D8 ; **Care dont confuse this with HighestWorkerCount
			 O_pTotalUnitsBuilt := 0x658 ; eg numbers of units made (includes 6 starting scvs) 
			 O_pWorkersBuilt := 0x7E8 ; number of workers made (includes the 6 at the start of the game)
			 O_pHighestWorkerCount := 0x800 ; the current highest worker account achieved
			 O_pBaseCount := 0x848 
			 O_pSupplyCap := 0x898		
			 O_pSupply := 0x8B0 ;+ 12		
			 O_pMinerals := 0x8F0 ;+18
			 O_pGas := 0x8F8

			 O_pArmySupply := 0x8D0	 
			 O_pMineralIncome := 0x970
			 O_pGasIncome := 0x978
			 O_pArmyMineralSize := 0xC58 	; there are two (identical?) values for minerals/gas 
			 O_pArmyGasSize := 0xC80 		; ** care dont use max army gas/mineral size! 

		 P_IdleWorker := base + 0x03114D30		
			 O1_IdleWorker := 0x358
			 O2_IdleWorker := 0x244 	; tends to always end with this offset if finding via pointer scan

		; 	This can be found via three methods, pattern scan:
		;	C1 EA 0A B9 00 01 00 00 01 0D ?? ?? ?? ?? F6 D2 A3 ?? ?? ?? ?? F6 C2 01 74 06 01 0D ?? ?? ?? ?? 83 3D ?? ?? ?? ?? 00 56 BE FF FF FF 7F
		; 	Timer Address = readMemory(patternAddress + 0x1C)
		; 	It can also be found as there are two (identical?) 4-byte timers next to each other.
		; 	So do the usual search between times to find the timer value, then search for an 8 byte representation of 
		;   two timers which have the same value.  GameGetMissionTime() refers to the second (+0x4) of these two timers.
		;	And via IDA (Function: GameGetMissionTime) (-0x800000 from IDA address)

		 B_Timer := base + 0x35428DC ; 0x353C41C 			

		 B_rStructure := base + 0x02F6C850	; ?? Havent updated as dont use this
			 S_rStructure := 0x10

		 P_ChatFocus := base + 0x03114D30 ;Just when chat box is in focus ; value = True if open
			 O1_ChatFocus := 0x394 
			 O2_ChatFocus := 0x174 		; tends to end with this offset

		 P_MenuFocus := base + 0x04FFA324 	;this is all menus and includes chat box when in focus ; old 0x3F04C04
			 O1_MenuFocus := 0x17C 			; tends to end with this offse

		P_SocialMenu := base + 0x0409B098 ; ???? Havent updated as dont use it

		 B_uCount := base + 0x3672FA8 ; or 0x2F75568	; This is the units alive (and includes missiles) 			
		 												; There are two of these values and they only differ the instant a unit dies esp with missle fire (ive used the higher value) - perhaps one updates slightly quicker - dont think i use this offset anymore
		 							
		 B_uHighestIndex := base + 0x3672FC0  			; this is actually the highest currently alive unit (includes missiles while alive) and starts at 1 NOT 0! i.e. 1 unit alive = 1
		 B_uStructure := base + 0x3673000 			
		 S_uStructure := 0x1C0
			 O_uModelPointer := 0x8
			 O_uTargetFilter := 0x14
			 O_uBuildStatus := 0x18		; buildstatus is really part of the 8 bit targ filter!
			 O_XelNagaActive := 0x34 	; dont use as doesnt work all the time
			; something added in here in vr 2.10

			 O_uOwner := 0x41  ; this and the rest below +4
			 O_uX := 0x4C
			 O_uY := 0x50
			 O_uZ := 0x54
			 O_uDestinationX := 0x80
			 O_uDestinationY := 0x84
			 O_P_uCmdQueuePointer := 0xD4 ;+4
			 O_P_uAbilityPointer := 0xDC

										; there are other offsets which can be used for chrono/inject state
			 O_uChronoState := 0xE6				; pre 210 chrono and inject offsets were the same
			 O_uInjectState := 0xE7 ; +5 Weird this was 5 not 4 (and its values changed) chrono state just +4

			 O_uHpDamage := 0x114
			 O_uShieldDamage := 0x118
			 O_uEnergy := 0x11c 
			 O_uTimer := 0x16C ;+4
			
		;CommandQueue 	; separate structure
			 O_cqState := 0x40	

		
		; Unit Model Structure	
		 O_mUnitID := 0x6	
		 O_mSubgroupPriority := 0x3A8 ;0x398
		 O_mMiniMapSize := 0x3AC ;0x39C
		
		; selection and ctrl groups
		 B_SelectionStructure := base + 0x31D8508

		; Note: This is actually the second control group in the group structure. 
		; The structure begins with ctrl group 0, then goes to 1, But i used ctrl group 1 as base for simplicity 
		; when getting info for group 1, the negative offset will work fine 

		 B_CtrlGroupOneStructure := base + 0x31DD730
		 S_CtrlGroup := 0x1B60
		 S_scStructure := 0x4	; Unit Selection & Ctrl Group Structures
			 O_scTypeCount := 0x2
			 O_scTypeHighlighted := 0x4
			 O_scUnitIndex := 0x8

	;	P_PlayerColours := base + 0x03D28A84 ; 0 when enemies red  1 when player colours
	;		O1_PlayerColours := 0x4
	;		O2_PlayerColours := 0x17c

		; give the army unit count (i.e. same as in the select army icon) - unit count not supply
		; dont confuse with similar one which includes army unit counts in production 
		B_localArmyUnitCount := base + 0x03114D30
			O1_localArmyUnitCount := 0x354
			O2_localArmyUnitCount := 0x248

		 B_TeamColours := base + 0x3115E7C ; 2 when team colours is on, else 0
		; another one at + 0x4FBCB98

		 P_SelectionPage := base + 0x03114D30  	; ***theres one other 3 lvl pointer but for a split second (every second or so) it points to 
			 O1_SelectionPage := 0x320			; the wrong address! You need to increase CE timer resolution to see this happening! Check it!
			 O2_SelectionPage := 0x15C			;this is for the currently selected unit portrait page ie 1-6 in game (really starts at 0-5)
			 O3_SelectionPage := 0x14C 			;might actually be a 2 or 1 byte value....but works fine as 4

		DeadFilterFlag := 0x0000000200000000	
		BuriedFilterFlag := 0x0000000010000000

		 B_MapStruct := base + 0x3542874 		;0x353C3B4 ;0x3534EDC ; 0X024C9E7C 
			 O_mLeft := B_MapStruct + 0xDC	                                   
			 O_mBottom := B_MapStruct + 0xE0	                                   
			 O_mRight := B_MapStruct + 0xE4	    ; MapRight 157.999756 (akilon wastes) after dividing 4096   (647167 before)                  
			 O_mTop := B_MapStruct + 0xE8	   	; MapTop: 622591 (akilon wastes) before dividing 4096  

		 aUnitMoveStates := { Idle: -1  ; ** Note this isn't actually a read in game type/value its just what my funtion will return if it is idle
							, Amove: 0 		
							, Patrol: 1
							, HoldPosition: 2
							, Move: 256
							, Follow: 512
							, FollowNoAttack: 515} ; This is used by unit spell casters such as infestors and High temps which dont have a real attack 
							; note I have Converted these hex numbers from their true decimal conversion 
			
		B_UnitCursor :=	base + 0x03114D30 
			O1_UnitCursor := 0x2C0	 					
			O2_UnitCursor := 0x21C 					

	 															; If used as 4byte value, will return 256 	there are 2 of these memory addresses
		 P_IsUserPerformingAction := base + 0x03114D30 			; This is a 1byte value and return 1  when user is casting or in is rallying a hatch via gather/rally or is in middle of issuing Amove/patrol command but
			 O1_IsUserPerformingAction := 0x230 					; if youre searching for a 4byte value in CE offset will be at 0x254 (but really if using it as 1 byte it is 0x255) - but im lazy and use it as a 4byte with my pointer command
																; also 1 when placing a structure (after structure is selected) or trying to land rax to make a addon Also gives 1 when trying to burrow spore/spine
																; When searching for 4 byte value this offset will be 0x254 
																; this address is really really useful!
																; it is even 0 with a burrowed swarm host selected (unless user click 'y' for rally which is even better)

	/* 	Not Currently Used
		P_IsUserBuildingWithWorker := base + 0x0209C3C8  	 	; this is like the one but will give 1 even when all structure are greyed out (eg lair tech having advanced mutations up)
			01_IsUserBuildingWithWorker := 0x364 				; works for workers of all races
			02_IsUserBuildingWithWorker := 0x17C           		; even during constructing SVC will give 0 - give 1 when selection card is up :)
			03_IsUserBuildingWithWorker := 0x3A8   				; also displays 1 when the toss hallucination card is displayed
			04_IsUserBuildingWithWorker := 0x168 				; BUT will also give 1 when a hatch is selected!!!

	*/
		 P_IsBuildCardDisplayed := base + 0x0312872C 		; this displays 1 (swarm host) or 0 with units selected - displays 7 when targeting reticle displayed/or placing a building (same thing)
			 01_IsBuildCardDisplayed := 0x7C 				; **but when either build card is displayed it displays 6 (even when all advanced structures are greyed out)!!!!
			 02_IsBuildCardDisplayed := 0x74 				; also displays 6 when the toss hallucination card is displayed
			 03_IsBuildCardDisplayed := 0x398 				; could use this in place of the current 'is user performing action offset'
	 														; Note: There is another address which has the same info, but when placing a building it will swap between 6 & 7 (not stay at 7)!


	 	; There are two chat buffers - One blanks after you press return (to send chat)
	 	; while the other one keeps the text even after the chat is sent/closed
	 	; this is the latter

	 	; note there are two of these so make sure pick the right one as there addresses 
	 	; can go from high to low so the one at the top of CE scan might not be the same one
	 	; that was at the top last time!
	 															
	 	 P_ChatInput := base + 0x0310EDEC 		; ?????? not updated/used currently
	 		 O1_ChatInput := 0x16C 
	 		 O2_ChatInput := 0xC
	 		 O3_ChatInput := 0x278
	 		 O4_ChatInput := 0x0

	/*
	Around this modifier area are other values which contain the logical states
	SC2.exe+1FDF7C6 is a 2byte value which contains the state of the numbers 0-9
	SC2.exe+1FDF7D0 contains the state F-keys as well as keys like tab, backspace, Ins, left, right etc
	SC2.exe+1FDF7C8 (8 bytes) contains the state of most keys eg a-z etc

	*/

												; there are two of these the later 1 is actually the one that affects the game
												; Also the 1st one, if u hold down a modifier then go out of the game (small window mode)
												; it will remain 1 even when back in and shift isn't down as moving a unit wont be shift-commanded! so dont use that one
											  	;shift = 1, ctrl = 2, alt = 4 (and add them together)

															
		 B_CameraDragScroll := base + 0x3057DB0  			; 1 byte Returns 1 when user is moving camera via DragScroll i.e. mmouse button the main map But not when on the minimap (or if mbutton is held down on the unit panel)

		
		 B_InputStructure := base + 0x30580C0  		
			 B_iMouseButtons := B_InputStructure + 0x0 		; 1 Byte 	MouseButton state 1 for Lbutton,  2 for middle mouse, 4 for rbutton
			 B_iSpace := B_iMouseButtons + 0x8 				; 1 Bytes
			 B_iNums := B_iSpace + 0x2  					; 2 Bytes
			 B_iChars := B_iNums + 0x2 						; 4 Bytes 
			 B_iTilda := B_iChars + 0x4 					; 1 Byte  (could be 2 bytes)
			 B_iNonAlphNumChars := B_iTilda + 0x2 			; 2 Bytes - keys: [];',./ Esc Entr \
			 B_iNonCharKeys := B_iNonAlphNumChars + 0x2 	; 2 Bytes - keys: BS Up Down Left Right Ins Del Hom etc scrl lock pause caps + tab
			 B_iFkeys := B_iNonCharKeys + 0x2 				; 2 bytes		
			 B_iModifiers := B_iFkeys + 0x6 				; 1 Byte



		 B_CameraMovingViaMouseAtScreenEdge := base + 0x03114D30  		; Really a 1 byte value value indicates which direction screen will scroll due to mouse at edge of screen
			 01_CameraMovingViaMouseAtScreenEdge := 0x2C0				; 1 = Diagonal Left/Top 		4 = Left Edge
			 02_CameraMovingViaMouseAtScreenEdge := 0x20C				; 2 = Top 						5 = Right Edge			
			 03_CameraMovingViaMouseAtScreenEdge := 0x5A4				; 3 = Diagonal Right/Top 	  	6 = Diagonal Left/ Bot	
																		; 7 = Bottom Edge 			 	8 = Diagonal Right/Bot 
																		; Note need to do a pointer scan with max offset > 1200d!
		 B_IsGamePaused := base + 0x31FEF1D 						

		 B_FramesPerSecond := base + 0x04FBD484
		 B_Gamespeed  := base + 0x4EFE5E8

		; example: D:\My Computer\My Documents\StarCraft II\Accounts\56021244\6-S2-1-34722\Replays\
		; this works for En, Fr, and Kr languages 
		 B_ReplayFolder :=  base + 0x4F7B228 ;0x04F701F8

		; Horizontal resolution ; 4 bytes
		; vertical resolution ; The next 4 bytes immediately after the Horizontal resolution 
		; cheat and search for 8 bytes 4638564681600 (1920 1080)
		; There will be 3 green static addresses (+many non-statics) One of them will change depending on resolution
		; Can resize in window mode and it will change too

		 B_HorizontalResolution := base + 0x4FF9DD8
		 B_VerticalResolution := B_HorizontalResolution + 0x4

	/*
		; There is value reached via a pointer which will change the rendered resolution (even in widowed mode)
		P_HorizontalResolutionReal := base + 0x01106654
			01_HorizontalResolutionReal := 0x90 
		P_VerticalResolutionReal := base + 0x01106654
			01_VerticalResolutionReal := 0x94

	*/

	 ; The below offsets are not Currently used but are current for 2.0.8

	/*

	 	P_IsUserCasting := base +	0x0209C3C8					; this is probably something to do with the control card
			O1_IsUserCasting := 0x364 							; 1 indicates user is casting a spell e.g. fungal, snipe, or is trying to place a structure
			O2_IsUserCasting := 0x19C 							; auto casting e.g. swarm host displays 1 always 
			O3_IsUserCasting := 0x228
			O4_IsUserCasting := 0x168

		P_IsCursorReticleBurrowedInfestor:= base + 0x021857EC			; 1 byte	;seems to return 1 when cursors is reticle but not for inject larva on queen
			O1_IsCursorReticleBurrowedInfestor := 0x1C 					; also retursn 1 for burrowed swarm hosts though - auto cast? (and fungal - but reticle present for fungal)
			O2_IsCursorReticleBurrowedInfestor := 0x14 					; 0 when placing a building

		P_IsUserBuildingWithDrone := base + 0x0209C3C8		; gives 1 when drone has basic mutation or advance mutaion/ open
			01_IsUserBuildingWithDrone := 0x364 				; Note: If still on hatch tech and all advanced building 'greyed out' will give 0!!!!!
			02_IsUserBuildingWithDrone := 0x17C 				; also gives 1 when actually attempting to place building
			03_IsUserBuildingWithDrone := 0x228
			04_IsUserBuildingWithDrone := 0x168
	*/

	/* Not Currently used
		B_CameraBounds := base + 0x209A094
			O_x0Bound := 0x0
			O_XmBound := 0x8
			O_Y0Bound := 0x04
			O_YmBound := 0x0C
		
		B_CurrentBaseCam := 0x017AB3C8	;not current
			P1_CurrentBaseCam := 0x25C		;not current
	*/	
	}
	return versionMatch
}	

getMapLeft()
{	global
	return ReadMemory(O_mLeft, GameIdentifier) / 4096
}
getMapBottom()
{	global
	return ReadMemory(O_mBottom, GameIdentifier) / 4096
}
getMapRight()
{	global
	return ReadMemory(O_mRight, GameIdentifier) / 4096
}
getMapTop()
{	global
	return ReadMemory(O_mTop, GameIdentifier) / 4096
}

IsInControlGroup(group, unitIndex)
{
	count := getControlGroupCount(Group)
	ReadRawMemory(B_CtrlGroupOneStructure + S_CtrlGroup * (group - 1), GameIdentifier, Memory,  O_scUnitIndex + count * S_scStructure)
	loop, % count 
	{
		if (unitIndex = (NumGet(Memory, O_scUnitIndex + (A_Index - 1) * S_scStructure, "UInt") >> 18))		
			Return 1
	}
	Return 0	
}

/*
isInControlGroup(group, unit) 
{	; group# = 1, 2,3-0  
	global  
	loop, % getControlGroupCount(Group)
		if (unit = getCtrlGroupedUnitIndex(Group,  A_Index - 1))
			Return 1	;the unit is in this control group
	Return 0			
}	;	ctrl_unit_number := ReadMemory(B_CtrlGroupOneStructure + S_CtrlGroup * (group - 1) + O_scUnitIndex +(A_Index - 1) * S_scStructure, GameIdentifier, 2)/4
*/

getCtrlGroupedUnitIndex(group, i=0)
{	global
	Return ReadMemory(B_CtrlGroupOneStructure + S_CtrlGroup * (group - 1) + O_scUnitIndex + i * S_scStructure, GameIdentifier) >> 18
}

getControlGroupCount(Group)
{	global
	Return	ReadMemory(B_CtrlGroupOneStructure + S_CtrlGroup * (Group - 1), GameIdentifier, 2)
}	

getTime()
{	global 
	Return Round(ReadMemory(B_Timer, GameIdentifier)/4096, 1)
}

getGameTickCount()
{	global 
	Return ReadMemory(B_Timer, GameIdentifier)
}

ReadRawUnit(unit, ByRef Memory)	; dumps the raw memory for one unit
{	GLOBAL
	ReadRawMemory(B_uStructure + unit * S_uStructure, GameIdentifier, Memory, S_uStructure)
	return
}


getSelectedUnitIndex(i=0) ;IF Blank just return the first selected unit (at position 0)
{	global
	Return ReadMemory(B_SelectionStructure + O_scUnitIndex + i * S_scStructure, GameIdentifier) >> 18	;how the game does it
	; returns the same thing ; Return ReadMemory(B_SelectionStructure + O_scUnitIndex + i * S_scStructure, GameIdentifier, 2) /4
}

getSelectionTypeCount()	; begins at 1
{	global
	Return	ReadMemory(B_SelectionStructure + O_scTypeCount, GameIdentifier, 2)
}
getSelectionHighlightedGroup()	; begins at 0 
{	global
	Return ReadMemory(B_SelectionStructure + O_scTypeHighlighted, GameIdentifier, 2)
}

getSelectionCount()
{ 	global 
	Return ReadMemory(B_SelectionStructure, GameIdentifier, 2)
}
getIdleWorkers()
{	global 	
	return pointer(GameIdentifier, P_IdleWorker, O1_IdleWorker, O2_IdleWorker)
}
getPlayerSupply(player="")
{ global
	If (player = "")
		player := aLocalPlayer["Slot"]
	Return round(ReadMemory(((B_pStructure + O_pSupply) + (player-1)*S_pStructure), GameIdentifier)  / 4096)		
	; Round Returns 0 when memory returns Fail
}
getPlayerSupplyCap(player="")
{ 	Local SupplyCap 
	If (player = "")
		player := aLocalPlayer["Slot"]
		SupplyCap := round(ReadMemory(((B_pStructure + O_pSupplyCap) + (player-1)*S_pStructure), GameIdentifier)  / 4096)
		if (SupplyCap > 200)	; as this will actually report the amount of supply built i.e. can be more than 200
			return 200
		else return SupplyCap 
}
getPlayerSupplyCapTotal(player="")
{ 	GLOBAL 
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return round(ReadMemory(((B_pStructure + O_pSupplyCap) + (player-1)*S_pStructure), GameIdentifier)  / 4096)
}
getPlayerWorkerCount(player="")
{ global
	If (player = "")
		player := aLocalPlayer["Slot"]
	Return ReadMemory(((B_pStructure + O_pWorkerCount) + (player-1)*S_pStructure), GameIdentifier)
}

;  Number of workers made (includes the 6 at the start of the game)
; eg have 12 workers, but 2 get killed, and then you make one more
; this value will be 13.

getPlayerWorkersBuilt(player="")
{ global
	If (player = "")
		player := aLocalPlayer["Slot"]
	Return ReadMemory(((B_pStructure + O_pWorkersBuilt) + (player-1)*S_pStructure), GameIdentifier)
}
getPlayerWorkersLost(player="")
{ 	global aLocalPlayer
	If (player = "")
		player := aLocalPlayer["Slot"]
	return getPlayerWorkersBuilt() - getPlayerWorkerCount()
}
getPlayerHighestWorkerCount(player="")
{ global
	If (player = "")
		player := aLocalPlayer["Slot"]
	Return ReadMemory(B_pStructure + O_pHighestWorkerCount + (player-1)*S_pStructure, GameIdentifier)
}
getUnitType(Unit) ;starts @ 0 i.e. first unit at 0
{ global 

	LOCAL pUnitModel := ReadMemory(B_uStructure + (Unit * S_uStructure) + O_uModelPointer, GameIdentifier) ; note - this isnt really the correct pointer still have to << 5 
	if !aUnitModel[pUnitModel]
    	getUnitModelInfo(pUnitModel)
  	return aUnitModel[pUnitModel].Type
;	Return ReadMemory(((ReadMemory(B_uStructure + (Unit * S_uStructure) 
;				+ O_uModelPointer, GameIdentifier)) << 5) + O_mUnitID, GameIdentifier, 2) ; note the pointer is 4byte, but the unit type is 2byte/word
}

getUnitName2(unit)
{	global 
	Return substr(ReadMemory_Str(ReadMemory(ReadMemory(((ReadMemory(B_uStructure + (Unit * S_uStructure) 
			+ O_uModelPointer, GameIdentifier)) << 5) + 0xC, GameIdentifier), GameIdentifier) + 0x29, GameIdentifier), 6)
	;	pNameDataAddress := ReadMemory(unit_type + 0x6C, "StarCraft II")
	;	NameDataAddress  := ReadMemory(pNameDataAddress, "StarCraft II") + 0x29 
	;	Name := ReadMemory_Str(NameDataAddress, , "StarCraft II")
	;	NameLength := ReadMemory(NameDataAddress, "StarCraft II") 		
}
getUnitName(unit)
{
	mp := ReadMemory(B_uStructure + Unit * S_uStructure + O_uModelPointer, GameIdentifier) << 5 ; 
	pNameDataAddress := ReadMemory(mp + 0xC, GameIdentifier) ; mp + pName_address
	pNameDataAddress := ReadMemory(pNameDataAddress, GameIdentifier) 
	NameDataAddress := ReadMemory(pNameDataAddress, GameIdentifier) 
	return substr(ReadMemory_Str(NameDataAddress + 0x20, GameIdentifier), 11) ; trim name/unit/
}

getUnitOwner(Unit) ;starts @ 0 i.e. first unit at 0 - 2.0.4 starts at 1?
{ 	global
	Return	ReadMemory((B_uStructure + (Unit * S_uStructure)) + O_uOwner, GameIdentifier, 1) ; note the 1 to read 1 byte
}


getMiniMapRadius(Unit)
{	
	LOCAL pUnitModel := ReadMemory(B_uStructure + (Unit * S_uStructure) + O_uModelPointer, GameIdentifier) ; note - this isnt really the correct pointer still have to << 5 
	if !aUnitModel[pUnitModel]
    	getUnitModelInfo(pUnitModel)
  	return aUnitModel[pUnitModel].MiniMapRadius	
	;Return ReadMemory(((ReadMemory(B_uStructure + (unit * S_uStructure) + O_uModelPointer, GameIdentifier) << 5) & 0xFFFFFFFF) + O_mMiniMapSize, GameIdentifier) /4096
}


getUnitCount()
{	global
	return ReadMemory(B_uCount, GameIdentifier)
}

getHighestUnitIndex() 	; this is the highest alive units index - note its out by 1 - ie it starts at 1
{	global				; if 1 unit is alive it will return 1 (NOT 0)
	Return ReadMemory(B_uHighestIndex, GameIdentifier)	
}
getPlayerName(i) ; start at 0
{	global
	Return ReadMemory_Str(B_pStructure + O_pName + (i-1) * S_pStructure, GameIdentifier) 
}
getPlayerRace(i) ; start at 0
{	global
	local Race
	; Race := ReadMemory_Str((B_rStructure + (i-1) * S_rStructure), ,GameIdentifier) ;old easy way
	Race := ReadMemory_Str(ReadMemory(ReadMemory(B_pStructure + O_pRacePointer + (i-1)*S_pStructure, GameIdentifier) + 4, GameIdentifier), GameIdentifier) 
	If (Race == "Terr")
		Race := "Terran"
	Else if (Race == "Prot")
		Race := "Protoss"
	Else If (Race == "Zerg")
		Race := "Zerg"	
	Else If (Race == "Neut")
		Race := "Neutral"
	Else 
		Race := "Race Error" ; so if it ever gets read out in speech, easily know its just from here and not some other error
	Return Race
}

getPlayerType(i)
{	global
	static oPlayerType := {	  0: "None"
							, 1: "User" 	; I believe all human players in a game have this type regardless if ally or on enemy team
							, 2: "Computer"
							, 3: "Neutral"
							, 4: "Hostile"
							, 5: "Referee"
							, 6: "Spectator" }

	Return oPlayerType[ ReadMemory((B_pStructure + O_pType) + (i-1) * S_pStructure, GameIdentifier, 1) ]
}

getPlayerVictoryStatus(i)
{	global
	static oPlayerStatus := {	  0: "Playing"
								, 1: "Victorious" 	
								, 2: "Defeated"
								, 3: "Tied" }

	Return oPlayerStatus[ ReadMemory((B_pStructure + O_pVictoryStatus) + (i-1) * S_pStructure, GameIdentifier, 1) ]
}

/*
Nuke's Enum
oPlayerStatus := {	  0: "Unused"
								, 1: "Active" 	
								, 2: "Left"
								, 3: "Tied"
								, 5: "Win"
								, 7: "SeeBuildings" 
								, 9: "Active9" 
								, 17: "Active14" 
								, 24: "Left" 
								, 25: "Active25" }
 all of these values occured while player was still 'active'
; all are diviseable by 4 after subtracting 1
;5 ;9 ;13 ;17 ;33 ;65 ;73 ;81 ;129 ;133 ;137 ;145 ;161 ;193 ;209

unused when a plyer leaves on the replay
I wonder if the structure is more is just active and left


getPlayerActiveStatus(i)
{	global
	static oPlayerStatus := {	  0: "Unused"
								, 1: "Active" 	
								, 2: "Left"
								, 3: "Tied" } ; wonder if there is no tied

	Return oPlayerStatus[ mod(ReadMemory((B_pStructure + O_pStatus) + (i-1) * S_pStructure, GameIdentifier, 1), 4) ]
}
*/

isPlayerActive(player)
{
	Return (ReadMemory((B_pStructure + O_pStatus) + (player-1) * S_pStructure, GameIdentifier, 1) & 1)
}



getPlayerTeam(player="") ;team begins at 0
{	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory((B_pStructure + O_pTeam) + (player-1) * S_pStructure, GameIdentifier, 1)
}
getPlayerColour(i)
{	static aPlayerColour
	if !isObject(aPlayerColour)
	{
		aPlayerColour := []
		Colour_List := "White|Red|Blue|Teal|Purple|Yellow|Orange|Green|Light Pink|Violet|Light Grey|Dark Green|Brown|Light Green|Dark Grey|Pink"
		Loop, Parse, Colour_List, |
			aPlayerColour[a_index - 1] := A_LoopField
	}
	Return aPlayerColour[ReadMemory((B_pStructure + O_pColour) + (i-1) * S_pStructure, GameIdentifier)]
}
getLocalPlayerNumber() ;starts @ 1
{	global
	Return ReadMemory(B_LocalPlayerSlot, GameIdentifier, 1) ;Local player slot is 1 Byte!!
}
getBaseCameraCount(player="")
{ 	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory((B_pStructure + O_pBaseCount) + (player-1) * S_pStructure, GameIdentifier)
}
getPlayerMineralIncome(player="")
{ 	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + O_pMineralIncome + (player-1) * S_pStructure, GameIdentifier)
}
getPlayerGasIncome(player="")
{ 	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + O_pGasIncome + (player-1) * S_pStructure, GameIdentifier)
}
getPlayerArmySupply(player="")
{ 	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + O_pArmySupply + (player-1) * S_pStructure, GameIdentifier) / 4096
}
getPlayerArmySizeMinerals(player="")
{ 	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + O_pArmyMineralSize + (player-1) * S_pStructure, GameIdentifier)
}
getPlayerArmySizeGas(player="")
{ 	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + O_pArmyGasSize + (player-1) * S_pStructure, GameIdentifier)
}
getPlayerMinerals(player="")
{ 	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + O_pMinerals + (player-1) * S_pStructure, GameIdentifier)
}
getPlayerGas(player="")
{ 	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + O_pGas + (player-1) * S_pStructure, GameIdentifier)
}
getPlayerCameraPositionX(Player="")
{	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + (Player - 1)*S_pStructure + O_pXcam, GameIdentifier) / 4096
}
getPlayerCameraPositionY(Player="")
{	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + (Player - 1)*S_pStructure + O_pYcam, GameIdentifier) / 4096
}
getPlayerCameraDistance(Player="")
{	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + (Player - 1)*S_pStructure + O_pCamDistance, GameIdentifier) / 4096
}
getPlayerCameraAngle(Player="")
{	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + (Player - 1)*S_pStructure + O_pCamAngle, GameIdentifier) / 4096
}
getPlayerCameraRotation(Player="")
{	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + (Player - 1)*S_pStructure + O_pCamRotation, GameIdentifier) / 4096
}


;	Note if in game without other players (get instant victory)
;	then this value will remain zero
;	I think it might get frozen after a real game finishes 
;	but user decides to remain in the game

getPlayerCurrentAPM(Player="")
{	global
	If (player = "")
		player := aLocalPlayer["Slot"]	
	Return ReadMemory(B_pStructure + (Player - 1)*S_pStructure + O_pAPM, GameIdentifier)
}

isUnderConstruction(building) ; starts @ 0 and only for BUILDINGS!
{ 	global  ; 0 means its completed
;	Return ReadMemory(B_uStructure + (building * S_uStructure) + O_uBuildStatus, GameIdentifier) ;- worked fine
	return getUnitTargetFilterFast(building) & aUnitTargetFilter.UnderConstruction
}

isUnitAStructure(unit)
{	GLOBAL 
	return getUnitTargetFilterFast(unit) & aUnitTargetFilter.Structure
}

getUnitEnergy(unit)
{	global
	Return Floor(ReadMemory(B_uStructure + (unit * S_uStructure) + O_uEnergy, GameIdentifier) / 4096)
}

numgetUnitEnergy(ByRef unitDump, unit)
{	global
	Return Floor(numget(unitDump, unit * S_uStructure + O_uEnergy, "Uint") / 4096)
}

; Damage which has been delt to the unit
; need to substract max hp in unit to find actual health value/percentage
getUnitHpDamage(unit)
{	global
	Return Floor(ReadMemory(B_uStructure + (unit * S_uStructure) + O_uHpDamage, GameIdentifier) / 4096)
}

getUnitShieldDamage(unit)
{	global
	Return Floor(ReadMemory(B_uStructure + (unit * S_uStructure) + O_uShieldDamage, GameIdentifier) / 4096)
}

getUnitPositionX(unit)
{	global
	Return ReadMemory(B_uStructure + (unit * S_uStructure) + O_uX, GameIdentifier) /4096
}
getUnitPositionY(unit)
{	global
	Return ReadMemory(B_uStructure + (unit * S_uStructure) + O_uY, GameIdentifier) /4096
}


getUnitPositionZ(unit)
{	global
	Return ReadMemory(B_uStructure + (unit * S_uStructure) + O_uZ, GameIdentifier) /4096
}


/*
	Move Structure
	+0x0 next Command ptr either (& -2) or (& 0xFFFFFFFE)
	+0x4 unit Structure Address
	+08 Some ptr - maybe ability


	When at the last command, the Command ptr & 0xFFFFFFFE
	will = the adress of the first command
	also, the last bit of the Command ptr (pre &) will be set to 1

;  O_cqState := 0x40

<Struct Name="QueuedCommand" Size="-1">
<Member Name="pNextCommand" Type="Unsigned" Size="4" Offset="0"/>
<!--
 A Struct very similar to Command starts here. It is a bit different though. 
-->
<Member Name="AbilityPointer" Type="Unsigned" Size="4" Offset="pNextCommand+0x18" AbsoluteOffset="0x18"/>
<Member Name="TargetUnitID" Type="Unsigned" Size="4" Offset="AbilityPointer+8" AbsoluteOffset="0x20"/>
<Member Name="TargetUnitModelPtr" Type="Unsigned" Size="4" Offset="TargetUnitID+4" AbsoluteOffset="0x24"/>
<Member Name="TargetX" Type="Fixed" Size="4" Offset="TargetUnitModelPtr+4" AbsoluteOffset="0x28"/>
<Member Name="TargetY" Type="Fixed" Size="4" Offset="TargetX+4" AbsoluteOffset="0x2C"/>
<Member Name="TargetZ" Type="Fixed" Size="4" Offset="TargetY+4" AbsoluteOffset="0x30"/>
<Member Name="Unknown" Type="Unsigned" Size="4" Offset="TargetZ+4" AbsoluteOffset="0x34"/>
<Member Name="TargetFlags" Type="Unsigned" Size="4" Offset="Unknown+4" AbsoluteOffset="0x38"/>
<Member Name="Flags" Type="Unsigned" Size="4" Offset="TargetFlags+4" AbsoluteOffset="0x3C"/>
<Member Name="AbilityCommand" Type="Unsigned" Size="1" Offset="Flags+4" AbsoluteOffset="0x40"/>
<Member Name="Player" Type="Unsigned" Size="1" Offset="AbilityCommand+2" AbsoluteOffset="0x42"/>
</Struct>

*/
; Check if a medivac, prism or overlord has a drop queued up
; unload command movestate = 2
; target flag  = 15 for drop and for movement
; target flag = 7 for hold position but movestate is the same
isTransportDropQueued(transportIndex)
{
	getUnitQueuedCommands(transportIndex, aCommands)
	for i, command in aCommands
	{
		if (command.ability = "MedivacTransport"
		|| command.ability = "WarpPrismTransport"
		|| command.ability = "OverlordTransport")
			return i
	}
	return 0
}

getUnitQueuedCommands(unit, byRef aQueuedMovements)
{
	static aTargetFlags := { "overrideUnitPositon":  0x1
							, "unknown02": 0x2
							, "unknown04": 0x4
							, "targetIsPoint": 0x8
							, "targetIsUnit": 0x10
							, "useUnitPosition": 0x20 }
	aQueuedMovements := []
	if (CmdQueue := ReadMemory(B_uStructure + unit * S_uStructure + O_P_uCmdQueuePointer, GameIdentifier)) ; points if currently has a command - 0 otherwise
	{
		pNextCmd := ReadMemory(CmdQueue, GameIdentifier) ; If & -2 this is really the first command ie  = BaseCmdQueStruct
		loop 
		{
			ReadRawMemory(pNextCmd & -2, GameIdentifier, cmdDump, 0x42)
			targetFlag := numget(cmdDump, 0x38, "UInt")

			if !aStringTable.hasKey(pString := numget(cmdDump, 0x18, "UInt"))
				aStringTable[pString] := ReadMemory_Str(readMemory(pString + 0x4, GameIdentifier), GameIdentifier)

			state := numget(cmdDump, O_cqState, "Short")

			aQueuedMovements.insert({ "targetX": targetX := numget(cmdDump, 0x28, "Int") / 4096
									, "targetY": numget(cmdDump, 0x2C, "Int") / 4096
									, "targetZ": numget(cmdDump, 0x30, "Int") / 4096
									, "ability": aStringTable[pString] 
								;	, "flag" : targetFlag
									, "state": state })

			if (A_Index > 20 || !(targetFlag & aTargetFlags.targetIsPoint || targetFlag & aTargetFlags.targetIsUnit || targetFlag = 7))
			{
				; something went wrong or target isnt a point/unit and the targ flag isnt 7 either 
				aQueuedMovements := []
				return 0
			}

		} Until (1 & pNextCmd := numget(cmdDump, 0, "Int"))				; loop until the last/first bit of pNextCmd is set to 1
		return aQueuedMovements.MaxIndex() 	; interstingly after -2 & pNextCmd (the last one) it should = the first address
	}
	else return 0
}

/*
	QueenBuild = make creepTumour (or on way to making it) - state = 0
	Transfusion  - state = 0

*/

getUnitQueuedCommandString(aQueuedCommandsOrUnitIndex)
{
	if !isObject(aQueuedCommandsOrUnitIndex)
	{
		unitIndex := aQueuedCommandsOrUnitIndex	 ; safer to do this
		aQueuedCommandsOrUnitIndex := [] 			; as AHK has a weird thing where variables in functions can alter themselves strangely
		getUnitQueuedCommands(unitIndex, aQueuedCommandsOrUnitIndex) 
	}
	for i, command in aQueuedCommandsOrUnitIndex
	{
		if (command.ability = "move")
		{
			if (command.state = aUnitMoveStates.Patrol)
				s .= "Patrol,"
			else if (command.state	= aUnitMoveStates.Move)
				s .= "Move,"
			else if (command.state	= aUnitMoveStates.Follow)
				s .= "Follow,"
			else if (command.state = aUnitMoveStates.HoldPosition)
				s .= "Hold,"
			else if (movement.state	= aUnitMoveStates.FollowNoAttack)
				s .= "FNA,"
		}
		else if (command.ability = "attack")
			s .= "Attack,"
		else s .= command.ability ","
	}
	; just sort to remove duplicates
	if s
		Sort, s, D`, U
	return s
}
	; when a unit is on hold position the target flag = 7
	; real movestate/0x40 = 2
	; unload command movestate = 2
	; target flag = 15 for drop and for movement

; This is just returns the state, which depends on the ability command (so its kind of wrong by itself)
getUnitMoveState(unit)
{	
	local CmdQueue, BaseCmdQueStruct
	if (CmdQueue := ReadMemory(B_uStructure + unit * S_uStructure + O_P_uCmdQueuePointer, GameIdentifier)) ; points if currently has a command - 0 otherwise
	{
		BaseCmdQueStruct := ReadMemory(CmdQueue, GameIdentifier) & -2
		return ReadMemory(BaseCmdQueStruct + O_cqState, GameIdentifier, 2) ;current state
	}
	else return -1 ;cant return 0 as that ould indicate A-move
}

arePlayerColoursEnabled()
{	global
	return !ReadMemory(B_TeamColours, GameIdentifier) ; inverse as this is true when player colours are off
	;Return pointer(GameIdentifier, P_PlayerColours, O1_PlayerColours, O2_PlayerColours) ; this true when they are on
}

; give the army unit count (i.e. same as in the select army icon) - unit count not supply
getArmyUnitCount()
{
	return Round(pointer(GameIdentifier, B_localArmyUnitCount, O1_localArmyUnitCount, O2_localArmyUnitCount))
}

isGamePaused()
{	global
	Return ReadMemory(B_IsGamePaused, GameIdentifier)
}


isMenuOpen()
{ 	global
	Return  pointer(GameIdentifier, P_MenuFocus, O1_MenuFocus)
}

isChatOpen()
{ 	global
	Return  pointer(GameIdentifier, P_ChatFocus, O1_ChatFocus, O2_ChatFocus)
}

; True when previous chat box or the social menu has text focus.
; invalid outside of game

isSocialMenuFocused()
{	 
	Return  pointer(GameIdentifier, P_SocialMenu, 0x3DC, 0x3C4, 0x3A8, 0xA4)
}


getUnitTimer(unit)
{	global 
	return ReadMemory(B_uStructure + unit * S_uStructure + O_uTimer, GameIdentifier)
}

/*
01DFD4C0 - 8B 07  - mov eax,[edi]
01DFD4C2 - 89 55 08  - mov [ebp+08],edx
01DFD4C5 - 89 44 8E 28  - mov [esi+ecx*4+28],eax <<
01DFD4C9 - 8D 7E 28  - lea edi,[esi+28]
01DFD4CC - C7 45 10 10000000 - mov [ebp+10],00000010

EAX=00080001
EBX=00000000
ECX=00000001
EDX=00080001
ESI=05D88800 = p1 := ReadMemory(getUnitAbilityPointer(Xelnaga) + 0x18, GameIdentifier)
EDI=08C1B94C
ESP=08C1B4B4
EBP=08C1B4E4
EIP=01DFD4C9

*/

; 
; There can be multiple units on the xelnaga, 1 spot for each of the 16 players
; If one player has multiple units holding the xelnaga, only the unit with the highest
; unit index will be listed in their player slot on the tower

; returns a ',' delimited list of unit indexes of units which are capturing the tower
; these units can be owned by any player
getUnitsHoldingXelnaga(Xelnaga)
{
	p1 := ReadMemory(getUnitAbilityPointer(Xelnaga) + 0x18, GameIdentifier)
	if (ReadMemory(p1 + 0xC, GameIdentifier) = 227) ; 227 when towerCaptured / 35 when not captured
	{
		loop, 16
		{
			if (unit := ReadMemory(p1 + (A_Index - 1) * 4 + 0x28 , GameIdentifier))
				units .= unit >> 18 ","
		}
		return RTrim(units, ",")
	}
	return -1
}

; if a local unit is on the tower, then its Index will be returned
; if multiple units are on the tower, the one with the highest index will be
; returned
getLocalUnitHoldingXelnaga(Xelnaga)
{
	p1 := ReadMemory(getUnitAbilityPointer(Xelnaga) + 0x18, GameIdentifier)
	; 227 when towerCaptured / 35 when not captured
	; though don't really need to check this, as if local unit isn't on
	; the tower, then unit/address = 0
	if (ReadMemory(p1 + 0xC, GameIdentifier) = 227) 
	{
		if (unit := ReadMemory(p1 + aLocalPlayer.slot * 4 + 0x28 , GameIdentifier))
			return unit >> 18 
	}
	return -1
}


; call this function at the start of every match
findXelnagas(byRef aXelnagas)
{
	aXelnagas := []
	loop, % getHighestUnitIndex()
	{
		if (aUnitID.XelNagaTower = getUnitType(A_Index - 1))
			aXelnagas.insert(A_Index - 1)
	}
	if aXelnagas.MaxIndex()
		return aXelnagas.MaxIndex()
	else return 0
}

; aXelnagas is a global array read at the start of each game

isLocalUnitHoldingXelnaga(unitIndex)
{	
	static tickCount := 0, unitsOnTower
	; Prevent lots of unnecessary memory reads
	; Though its not like it really matters
	; for a user invoked function
	if (A_TickCount - tickCount > 5)
	{
		tickCount := A_TickCount
		unitsOnTower := ""
		for i, xelnagaIndex in aXelnagas
		{
			if ((unitOnTower := getLocalUnitHoldingXelnaga(xelnagaIndex)) > 0)
				unitsOnTower .= unitOnTower ","	
		}	
	}
	if unitIndex in %unitsOnTower%
		return 1
	return 0
}

;  	for some reason this offset can be reversed for some units 
; 	perhaps if they kill a unit which is already on the tower?
; 	but it happens quite often
;	return ReadMemory(B_uStructure + unit * S_uStructure + O_XelNagaActive, GameIdentifier)
	;if (256 = ReadMemory(B_uStructure + unit * S_uStructure + O_XelNagaActive, GameIdentifier))
	;	return 1
	;else return 0


; example: D:\My Computer\My Documents\StarCraft II\Accounts\56064144\6-S2-1-79722\Replays\
getReplayFolder()
{	GLOBAL
	Return ReadMemory_Str(B_ReplayFolder, GameIdentifier) 
}

getChatText()
{ 	Global
	Local ChatAddress := pointer(GameIdentifier, P_ChatInput, O1_ChatInput, O2_ChatInput
									, O3_ChatInput, O4_ChatInput)

	return ReadMemory_Str(ChatAddress, GameIdentifier)	
}

getFPS()
{
	return ReadMemory(B_FramesPerSecond, GameIdentifier)
}

getGameSpeed()
{
	static aGameSpeed := { 	0: Slower
						,	1: Slow
						,	2: Normal
						,	3: Fast
						,	4: Faster }
	return aGameSpeed[ReadMemory(B_Gamespeed, GameIdentifier)]
}


; I noticed with this function, it will return 0 when there is less than half a second of cool down left - close enough
; should really be finding the pointer by looking up the ability index ID in the byte array.
; but im lazy and this works

getWarpGateCooldown(WarpGate) ; unitIndex
{	global B_uStructure, S_uStructure, O_P_uAbilityPointer, GameIdentifier
	u_AbilityPointer := B_uStructure + WarpGate * S_uStructure + O_P_uAbilityPointer
	ablilty := ReadMemory(u_AbilityPointer, GameIdentifier) & 0xFFFFFFFC
	p1 := ReadMemory(ablilty + 0x28, GameIdentifier)	
	if !(p2 := ReadMemory(p1 + 0x1C, GameIdentifier)) ; 0 if it has never warped in a unit
		return 0
	p3 := ReadMemory(p2 + 0xC, GameIdentifier)
	cooldown := ReadMemory(p3 + 0x4, GameIdentifier)
	; as found in map editor some warpgates gave -1....but this could just be due to it being in the mapeditor (and was never a gateway...but doubtful)
	; or i could have just stuffed something up when testing no harm in being safe.
	if (cooldown >= 0) 		
		return cooldown
	else return 0
}

getMedivacBoostCooldown(unit)
{
	; This is a bit weird. 
	; In mapeditor if never boosted p1 = 0, but in a real game
	; p1 is valid and p2 = 0
	if (!(p1 := ReadMemory(getUnitAbilityPointer(unit) + 0x28, GameIdentifier))
		|| !(p2 := readmemory(p1+0x1c, GameIdentifier)) )
		return 0	
	p3 := readmemory(p2+0xc, GameIdentifier)
	return ReadMemory(p3+0x4, GameIdentifier)
}

getUnitAbilityPointer(unit) ;returns a pointer which still needs to be read. The pointer will be different for every unit, but for units of same type when read point to same address
{	global
	return ReadMemory(B_uStructure + unit * S_uStructure + O_P_uAbilityPointer, GameIdentifier) & 0xFFFFFFFC
}

numgetUnitAbilityPointer(byRef unitDump, unit)
{
	return numget(unitDump, unit * S_uStructure + O_P_uAbilityPointer, "UInt") & 0xFFFFFFFC
}

; 6144 when stimmed 4096 when not
isUnitStimed(unit)
{
	structure := readmemory(getUnitAbilityPointer(unit) + 0x20, GameIdentifier)
	return (readmemory(structure + 0x38, GameIdentifier) = 6144) ? 1 : 0
}

isUnitChronoed(unit)
{	global	; 1 byte = 18h chrono for protoss structures 10h normal state This is pre patch 2.10
			; pre 210 i used the same offset to check injects and chrono state
			; now this has changed
			; post 210 seems its 0 when idle and 128 when chronoed 
			; dont think i have to do the if = 128 check now, but leave it just in case - havent checked 
			; every building for a default value
	
	if (128 = ReadMemory(B_uStructure + unit * S_uStructure + O_uChronoState, GameIdentifier, 1))	
		return 1
	else return 0
}

numgetIsUnitChronoed(byref unitDump, unit)
{	global	
	if (128 = numget(unitDump, unit * S_uStructure + O_uChronoState, "UChar"))	
		return 1
	else return 0
}


; pre patch 2.10
; 16 dec / 0x10 when not injected
; 48 dec / 0x30 when injected
; hatch/lair/hive unit structure + 0xE2 = inject state 
isHatchInjected(Hatch)
{	global	; 1 byte = 18h chrono for protoss structures, 48h when injected for zerg -  10h normal state
			; this changed in 2.10 - 0 idle 4 for inject (probably dont need the if = 4 check)
	if (4 = ReadMemory(B_uStructure + Hatch * S_uStructure + O_uInjectState, GameIdentifier, 1))	
		return 1
	else return 0
}
isWorkerInProductionOld(unit) ; units can only be t or P, no Z
{										;state = 1 in prod, 0 not, -1 if doing something else eg flying
	local state
	local type := getUnitType(unit)
	if (type = aUnitID["CommandCenterFlying"] || type = aUnitID["OrbitalCommandFlying"])
		state := -1
	else if ( type = aUnitID["Nexus"]) 	; this stuffs up
	{
		local p2 := ReadMemory(getUnitAbilityPointer(unit) + 0x24, GameIdentifier)
		state := ReadMemory(p2 + 0x88, GameIdentifier, 1)
		if (state = 0x43)	;probe Or mothership	
			state := 1
		else 	; idle 0x3
			state := 0
	}
	Else if (type = aUnitID["CommandCenter"])
	{
		 state := ReadMemory(getUnitAbilityPointer(unit) + 0x9, GameIdentifier, 1)
		if (state = 0x12)	;scv in produ
			state := 1
		else if (state = 32 || state = 64)	;0x0A = flying 32 ->PF | 64 -> orbital
			state := -1										; yeah i realise this flying wont e
		else ; state = 0x76 idle
			state := 0
	}
	Else if  (type =  aUnitID["PlanetaryFortress"])
	{
		local p1 := ReadMemory(getUnitAbilityPointer(unit) + 0x5C, GameIdentifier)
		state := ReadMemory(p1 + 0x28, GameIdentifier, 1) ; This is acutally the queue size
	}
	else if (type =  aUnitID["OrbitalCommand"])
	{
		state := ReadMemory(getUnitAbilityPointer(unit) + 0x9, GameIdentifier, 1)
		if (state = 0x11)	;scv
			state := 1
		else state := 0 ; 99h  	;else if (state = 0)	;flying
	}
	return state
}

 ; returns state which is really the queue size
isWorkerInProduction(unit) ; units can only be t or P, no Z
{										;state = 1 in prod, 0 not, -1 if doing something else eg flying
	GLOBAL aUnitID
	type := getUnitType(unit)
	if (type = aUnitID["CommandCenterFlying"] || type = aUnitID["OrbitalCommandFlying"])
		state := 0
	Else if (type = aUnitID["CommandCenter"] && isCommandCenterMorphing(unit))
		state := 1
	else if (type = aUnitID["PlanetaryFortress"]) 
		getBuildStatsPF(unit, state) ;state = queue size 1 means 1 worker is in production
	else 
		getBuildStats(unit, state)
	return state

}

; state =	0x0A = flying | 32 ->PF | 64 -> orbital
; state = 	0x76 idle
isCommandCenterMorphing(unit)
{
	local state
	state := ReadMemory(getUnitAbilityPointer(unit) + 0x9, GameIdentifier, 1)
	if (state = 32 )	;	->PF
		return aUnitID["PlanetaryFortress"]
	else if (state = 64)	; 	-> Orbital
		return aUnitID["OrbitalCommand"]
	return 0
}


isHatchLairOrSpireMorphing(unit, type := 0)
{
			/*
			hatchery
			getUnitAbilityPointer(unit) + 0x8
			111 / 0x6f idle (same if making drones etc - doesnt effect it)
			103 / 0x67 when researching e.g. burrow, pneumatic carapace, ventral sacs
			9 / 0x9 when going to lair
			lair
			119  / 0x77 idle
			103 / 0x67 when researching e.g. burrow, pneumatic carapace, ventral sacs
			9 / 0x9 when going to lair
			17 /0x11 when going to hive
			*/
	local state
	if !type
		type := getUnitType(unit)
	state := ReadMemory(getUnitAbilityPointer(unit) + 0x8, GameIdentifier, 1)
	if (state = 9 && type = aUnitID["Hatchery"])	;	->PF
		return aUnitID["Lair"]
	else if (state = 17 && type = aUnitID["Lair"])	; 	-> Orbital
		return aUnitID["Hive"]
	else if (state = 4 && type = aUnitID["Spire"])
		return aUnitID["GreaterSpire"]
	return 0
}


isMotherShipCoreMorphing(unit)
{
	state := ReadMemory(getUnitAbilityPointer(unit) + 0x8, GameIdentifier, 1)
	return state = 8 ? 1 : 0
}

IsUserMovingCamera()
{
	if (IsCameraDragScrollActivated() || IsCameraDirectionalKeyScrollActivated() || IsCameraMovingViaMouseAtScreenEdge())
		return 1
	else return 0
}

; 4 = left, 8 = Up, 16 = Right, 32 = Down  ; can be used with bitmasks
; these are added together if multiple keys are down e.g.  if Left, Up and Right are all active result = 28
IsCameraDirectionalKeyScrollActivated()  
{
	GLOBAL
	Return ReadMemory(B_iNonCharKeys, GameIdentifier, 1)
}

 	;1 byte - MouseButton state 1 for Lbutton,  2 for middle mouse, 4 for rbutton - again these can add togther eg lbutton + mbutton = 4
IsMouseButtonActive()
{	GLOBAL
	Return ReadMemory(B_iMouseButtons, GameIdentifier, 1)
}

; Really a 1 byte value
; 1 = Diagonal Left/Top 		4 = Left Edge
; 2 = Top 						5 = Right Edge			
; 3 = Diagonal Right/Top 	  	6 = Diagonal Left/ Bot	
; 7 = Bottom Edge 			 	8 = Diagonal Right/Bot
 

IsCameraMovingViaMouseAtScreenEdge()
{	GLOBAL
	return pointer(GameIdentifier, B_CameraMovingViaMouseAtScreenEdge, 01_CameraMovingViaMouseAtScreenEdge, 02_CameraMovingViaMouseAtScreenEdge, 03_CameraMovingViaMouseAtScreenEdge)
}

IsKeyDownSC2Input(CheckMouseButtons := False)
{	GLOBAL
	if (CheckMouseButtons && IsMouseButtonActive())
	|| ReadMemory(B_iSpace, GameIdentifier, 1)	
	|| ReadMemory(B_iNums, GameIdentifier, 2)	
	|| ReadMemory(B_iChars, GameIdentifier, 4)
	|| ReadMemory(B_iTilda, GameIdentifier, 1)
	|| ReadMemory(B_iNonAlphNumChars, GameIdentifier, 2)
	|| ReadMemory(B_iNonCharKeys, GameIdentifier, 2)
	|| ReadMemory(B_iFkeys, GameIdentifier, 2)
	|| ReadMemory(B_iModifiers, GameIdentifier, 1)
		return 1
	return 0
}

; 1 byte Returns 1 when user is moving camera via DragScroll i.e. Mmouse button the main map

IsCameraDragScrollActivated() 
{	GLOBAL
	Return ReadMemory(B_CameraDragScroll, GameIdentifier, 1)
}

	; there are two of these the later 1 is actually the one that affects the game
	; Also the 1st one, if u hold down a modifier then go out of the game (small window mode)
	; it will remain 1 even when back in and shift isn't down as moving a unit wont be shift-commanded! so dont use that one
  	;shift = 1, ctrl = 2, alt = 4 (and add them together)

	; these will return the same as if you check logical state of the key
	; there are two of these the later 1 is actually the one that affects the game
	; shift = 1, ctrl = 2, alt = 4 (and add them together)
	; left and right modifers give same values
	; if you modify these values will actually affect in game
readModifierState()
{	GLOBAL 
	return ReadMemory(B_iModifiers, GameIdentifier, 1)
}

readKeyBoardNumberState()
{	GLOBAL 
	return ReadMemory(B_iNums, GameIdentifier, 2)
}

getSCModState(KeyName)
{
	state := readModifierState()
	if instr(KeyName, "Shift")
		return state & 1 
	else if instr(KeyName, "Ctrl") || instr(KeyName, "Control") 
		return state & 2
	else if instr(KeyName, "Alt")
		return state & 4
	else return 0
}
; this will only have a temporary affect
; as sc2 continually poles the modifier states
; use exact value if you want to write a number
WriteModifiers(shift := 0, ctrl := 0, alt := 0, ExactValue := 0)
{
	LOCAL value 
	if shift
		value += 1
	if ctrl 
		value += 2 
	if alt 
		value += 4
	if ExactValue
		value := ExactValue
	Return WriteMemory(B_iModifiers, GameIdentifier, value,"Char")
}

; can check if producing by checking queue size via buildstats()
isGatewayProducingOrConvertingToWarpGate(Gateway)
{ 
;	gateway 
;	ability pointer + 0x8 
;	0x2F Idle
;	0x0F building unit
;	0x21 when converting to warpgate
;	0x40 when converting back to gateway from warpgate
; 	note there is a byte at +0x4 which indicates the previous state of the gateway/warpgate while morphing

	GLOBAL GameIdentifier
	state := readmemory(getUnitAbilityPointer(Gateway) + 0x8, GameIdentifier, 1)
	if (state = 0x0F || state = 0x21)
		return 1
	else return 0
}
isGatewayConvertingToWarpGate(Gateway)
{ 
	GLOBAL GameIdentifier
	state := readmemory(getUnitAbilityPointer(Gateway) + 0x8, GameIdentifier, 1)
	if (state = 0x21)
		return 1
	else return 0
}


SetPlayerMinerals(amount=99999)
{ 	global
	player := getLocalPlayerNumber()
	Return WriteMemory(B_pStructure + O_pMinerals + (player-1) * S_pStructure, GameIdentifier, amount,"UInt")   	 
}
SetPlayerGas(amount=99999)
{ 	global
	player := getLocalPlayerNumber()
	Return WriteMemory(B_pStructure + O_pGas + (player-1) * S_pStructure, GameIdentifier, amount,"UInt")   
}


getBuildStatsPF(unit, byref QueueSize := "",  QueuePosition := 0) ; dirty hack until i can be bothered fixing this function
{	GLOBAL GameIdentifier
	STATIC O_pQueueArray := 0x34, O_IndexParentTypes := 0x18, O_unitsQueued := 0x28
	CAbilQueue := ReadMemory(getUnitAbilityPointer(unit) + 0x5C, GameIdentifier)

	localQueSize := ReadMemory(CAbilQueue + O_unitsQueued, GameIdentifier, 1) ; This is acutally the queue size

	if IsByRef(QueueSize)
		QueueSize := localQueSize
	queuedArray := readmemory(CAbilQueue + O_pQueueArray, GameIdentifier)
	B_QueuedUnitInfo := readmemory(queuedArray + 4 * QueuePosition, GameIdentifier)

	if localQueSize
		return getPercentageUnitCompleted(B_QueuedUnitInfo)
	else return 0
}

cHex(dec, useClipboard := True)
{
	return useClipboard ? clipboard := substr(dectohex(dec), 3) : substr(dectohex(dec), 3)
}

getBuildStats(building, byref QueueSize := "", byRef item := "")
{
	pAbilities := getUnitAbilityPointer(building)
	AbilitiesCount := getAbilitiesCount(pAbilities)
	CAbilQueueIndex := getCAbilQueueIndex(pAbilities, AbilitiesCount)

	B_QueuedUnitInfo := getPointerToQueuedUnitInfo(pAbilities, CAbilQueueIndex, localQueSize)

	if IsByRef(QueueSize)
		QueueSize := localQueSize

	if IsByRef(item)
	{
		if localQueSize
		{
			if !aStringTable.hasKey(pString := readMemory(B_QueuedUnitInfo + 0xD0, GameIdentifier))
				aStringTable[pString] := ReadMemory_Str(readMemory(pString + 0x4, GameIdentifier), GameIdentifier)
			item := aStringTable[pString]
		}
		else item := ""
	}
	if localQueSize
		return getPercentageUnitCompleted(B_QueuedUnitInfo)
	else return 0
}


; this will return 1 or 2 units in production for use in unit panel
; hence this accounts for if a reactor is present
; it doesn't return the full list of units queued, just the one/two which are currently being produced
; byref totalQueueSize will return the total number of units queued though
getStructureProductionInfo(unit, type, byRef aInfo, byRef totalQueueSize := "")
{
	STATIC O_pQueueArray := 0x34, O_IndexParentTypes := 0x18, O_unitsQueued := 0x28
		, aOffsets := []

	aInfo := []
	if (!pAbilities := getUnitAbilityPointer(unit))
		return 0
	if !aOffsets.HasKey(type)
	{
		if (type = aUnitID.PlanetaryFortress)
			aOffsets[type] := 0x5C ;que5PassiveCancelToSelection - getCAbilQueueIndex will point to que5CancelToSelection which is for CC/orbital
		else 
		{
			CAbilQueueIndex := getCAbilQueueIndex(pAbilities, getAbilitiesCount(pAbilities)) ; CAbilQueueIndex
			if (CAbilQueueIndex != -1)
				aOffsets[type] := O_IndexParentTypes + 4 * CAbilQueueIndex
			else 
				aOffsets[type] := -1
		}
	}
	if (aOffsets[type] = -1)
		return 0 ; refinery,reactor, depot, spine, extractor etc

	CAbilQueue := readmemory(pAbilities + aOffsets[type], GameIdentifier)
	totalQueueSize := readmemory(CAbilQueue + O_unitsQueued, GameIdentifier) ; this is how many units are produced at once eg 1 normal - 2 reactor / this is not the total/real queue size!
	queuedArray := readmemory(CAbilQueue + O_pQueueArray, GameIdentifier)

	while (A_Index <= totalQueueSize && B_QueuedUnitInfo := readmemory(queuedArray + 4 * (A_index-1), GameIdentifier) )   ; A_index-1 = queue position ;progress = 0 not being built, but is in queue
	{
		if !aStringTable.hasKey(pString := readMemory(B_QueuedUnitInfo + 0xD0, GameIdentifier))
			aStringTable[pString] := ReadMemory_Str(readMemory(pString + 0x4, GameIdentifier), GameIdentifier)
		item := aStringTable[pString]
		if progress := getPercentageUnitCompleted(B_QueuedUnitInfo) ; 0.0 will be seen as false but doesnt really matter
			aInfo.insert({ "Item": item, "progress": progress})
		else break ; unit with highest complete percent is ALWAYS first in this queuedArray
	} 
	return round(aInfo.maxIndex())
}


getStructureProductionInfoCurrent(unit, byRef aInfo)
{
	STATIC O_pQueueArray := 0x34, O_IndexParentTypes := 0x18, O_unitsQueued := 0x28
	aInfo := []
	if (!pAbilities := getUnitAbilityPointer(unit))
		return 0
	if (-1 = CAbilQueueIndex := getCAbilQueueIndex(pAbilities, getAbilitiesCount(pAbilities)))
		return 0 ; refinery,reactor, depot, spine, extractor

	CAbilQueue := readmemory(pAbilities + O_IndexParentTypes + 4 * CAbilQueueIndex, GameIdentifier)
	QueueSize := readmemory(CAbilQueue + O_unitsQueued, GameIdentifier)
	queuedArray := readmemory(CAbilQueue + O_pQueueArray, GameIdentifier)

	while (A_Index <= QueueSize && B_QueuedUnitInfo := readmemory(queuedArray + 4 * (A_index-1), GameIdentifier) )   ; A_index-1 = queue position ;progress = 0 not being built, but is in queue
	{
		if !aStringTable.hasKey(pString := readMemory(B_QueuedUnitInfo + 0xD0, GameIdentifier))
			aStringTable[pString] := ReadMemory_Str(readMemory(pString + 0x4, GameIdentifier), GameIdentifier)
		item := aStringTable[pString]
		if progress := getPercentageUnitCompleted(B_QueuedUnitInfo) ; 0.0 will be seen as false 
			aInfo.insert({ "Item": item, "progress": progress})
		else break 
	} 
	return round(aInfo.maxIndex())  ;? aInfo.maxIndex() : 0
}

getZergProductionStringFromEgg(eggUnitIndex)
{
	p := readmemory(getUnitAbilityPointer(eggUnitIndex) + 0x1C, GameIdentifier)
	p := readmemory(p + 0x34, GameIdentifier) 		; cAbilQueueUse
	p := readmemory(p, GameIdentifier) 				; LarvaTrain  - this pointer structure will also have the production time/total
	p := readmemory(p + 0xf4, GameIdentifier)
	if !aStringTable.haskey(pString := readmemory(p, GameIdentifier) ) ; pString
		return aStringTable[pString] := ReadMemory_Str(readMemory(pString + 0x4, GameIdentifier), GameIdentifier)
	return aStringTable[pString]
}

getZergProductionFromEgg(eggUnitIndex)
{
	item := []
	p := readmemory(getUnitAbilityPointer(eggUnitIndex) + 0x1C, GameIdentifier)
	p := readmemory(p + 0x34, GameIdentifier) 		; cAbilQueueUse
	p := readmemory(p, GameIdentifier) 				; LarvaTrain  - this pointer structure will also have the production time/total
	timeRemaing := readmemory(p + 0x6C, GameIdentifier) 	
	totalTime := readmemory(p + 0x68, GameIdentifier) 		
	p := readmemory(p + 0xf4, GameIdentifier)
	if !aStringTable.haskey(pString := readmemory(p, GameIdentifier) ) ; pString
		aStringTable[pString] := ReadMemory_Str(readMemory(pString + 0x4, GameIdentifier), GameIdentifier)
	item.Progress := round((totalTime - timeRemaing)/totalTime, 2) 
	item.Type := aUnitID[(item.Item := aStringTable[pString])] 
	item.Count := item.Type = aUnitID.Zergling ? 2 : 1
	return item
}

/*
	Queued Unit info (B_QueuedUnitInfo)
	+0x1c = pString Action e.g. barracks train
	+0xB0 = string Ability e.g. abil/BarracksTrain
	+0xC0 = string Ability e.g. abil/BarracksTrain
	+0xDO = pString Current item in production
	+0x108 = pString to unit ID e.g. barracks
*/

/*
	player alerts (stuff on the left hand side of the screen)

01C14C2B - FF 87 18030000  - inc [edi+00000318]
01C14C31 - 8B 87 18030000  - mov eax,[edi+00000318]
01C14C37 - 89 B4 87 18030000  - mov [edi+eax*4+00000318],esi <<
01C14C3E - 85 F6  - test esi,esi
01C14C40 - 75 1E - jne SC2.AssertAndCrash+116C90

EAX=00000004
EBX=0000009A
ECX=00000000
EDX=0894B6A8
ESI=22F0F614
EDI=27270F3C
ESP=0894B6C0
EBP=0894B70C
EIP=01C14C3E
*/

; byteArrayDump can be used to pass an already dumped byte array, saving reading it again
getAbilityIndex(abilityID, abilitiesCount, ByteArrayAddress := "", byRef byteArrayDump := "")
{
	if !byteArrayDump
		ReadRawMemory(ByteArrayAddress, GameIdentifier, byteArrayDump, abilitiesCount)
	loop % abilitiesCount
	{
		if (abilityID = numget(byteArrayDump, A_Index-1, "Char"))
			return A_Index - 1
	}
	return -1 ; as above can return 0
}

; the specific ability pointer for units of the same type doesn't change relative to the unit's specific pAbilties.
; This uses a slow string read to find the pointer offset the first time, then any subsequent calls for the same unit type are
; returned immediately from the static array

findAbilityTypePointer(pAbilities, unitType, abilityString)
{
	static aUnitAbilitiesOffsets := [], B_AbilityStringPointer := 0xA4 ; string pointers for abilities start here
		, O_IndexParentTypes := 0x18 ; base where pointers to specific ability areas begin

	if aUnitAbilitiesOffsets[unitType].hasKey(abilityString)
		return pAbilities + aUnitAbilitiesOffsets[unitType, abilityString]
	p1 := readmemory(pAbilities, GameIdentifier)
	loop
	{
		if (!p := ReadMemory(p1 + B_AbilityStringPointer + (A_Index - 1)*4, GameIdentifier))
			return 0
		if (abilityString = string := ReadMemory_Str(ReadMemory(p + 0x4, GameIdentifier), GameIdentifier))
			return pAbilities + (aUnitAbilitiesOffsets[unitType, abilityString] :=  O_IndexParentTypes + (A_Index - 1)*4)	
	} until (A_Index > 100)
	return  0 ; something went wrong
}



/*	cAbilityRallyStruct
	Rally Stucture Size := 0x1C 
	+0x0 = rally count - (max 4)
	Following Repeats for each rally (data only gets chagned when a new rally point >= current one is made)
	; eg 4 rally points, then set to rally on self structure, then none are changed 
	; rally count = 0 when self rallied
		+0x04 = rallied unit ID reference? (as in the unit which the building is rallied to)
		+0x08 = rally/unit reference (changes depending on what is rallied to/type)
		+0xc = x1 
		+0x10 = y1
		+0x14 = z1
	
	Werdly a lifted CC (or spawning floating CC in the map editor) still has the
	rally ability present (its rally count is zero though) even though it lacks this 
	ability in map/unit editor data
*/

getStructureRallyPoints(unitIndex, byRef aRallyPoints := "")
{
	static O_IndexParentTypes := 0x18, cAbilRally := 0x1a

	aRallyPoints := []
	pAbilities := getUnitAbilityPointer(unitIndex)
	abilitiesCount := getAbilitiesCount(pAbilities)	
	ByteArrayAddress := ReadMemory(pAbilities, GameIdentifier) + 0x3  ; gets the address of a byte array which contains the ID list of the units abilities
	cAbilRallyIndex := getAbilityIndex(cAbilRally, abilitiesCount, ByteArrayAddress) ;find the position/index of the rally ability in the ID list
	
	if (cAbilRallyIndex >= 0)
	{
		pCAbillityStruct := readmemory(pAbilities + O_IndexParentTypes + 4 * cAbilRallyIndex, GameIdentifier)
		bRallyStruct := readmemory(pCAbillityStruct + 0x34, GameIdentifier)
		if (rallyCount := readMemory(bRallyStruct, GameIdentifier))
		{	
			ReadRawMemory(bRallyStruct, GameIdentifier, rallyDump, 0x14 + 0x1C * rallyCount)
			while (A_Index <= rallyCount)
			{
				aRallyPoints.insert({ "x": numget(rallyDump, (A_Index-1) * 0x1C + 0xC, "Int") / 4096
							  		, "y": numget(rallyDump, (A_Index-1) * 0x1C + 0x10, "Int") / 4096
							  		, "z": numget(rallyDump, (A_Index-1) * 0x1C + 0x14, "Int") / 4096 })	
			}
		}
		return rallyCount ; self rallied = 0
	}
	return -1 ; not rallyable
}


getPercentageUnitCompleted(B_QueuedUnitInfo)
{	GLOBAL GameIdentifier
	STATIC O_TotalTime := 0x68, O_TimeRemaining := 0x6C

	TotalTime := ReadMemory(B_QueuedUnitInfo + O_TotalTime, GameIdentifier)
	RemainingTime := ReadMemory(B_QueuedUnitInfo + O_TimeRemaining, GameIdentifier)

	return round( (TotalTime - RemainingTime) / TotalTime, 2) ;return .47 (ie 47%)
}

; this doesnt correspond to the unit in production for all structures!
; 	+0x48 != 0 when reactor present
getPointerAddressToQueuedUnitInfo(pAbilities, CAbilQueueIndex, byref QueueSize := "")
{	GLOBAL GameIdentifier
	STATIC O_pQueueArray := 0x34, O_IndexParentTypes := 0x18, O_unitsQueued := 0x28

	CAbilQueue := readmemory(pAbilities + O_IndexParentTypes + 4 * CAbilQueueIndex, GameIdentifier)

	QueueSize := readmemory(CAbilQueue + O_unitsQueued, GameIdentifier)

	return queuedArray := readmemory(CAbilQueue + O_pQueueArray, GameIdentifier)
}

getPointerToQueuedUnitInfo(pAbilities, CAbilQueueIndex, byref QueueSize := "", QueuePosition := 0)
{	GLOBAL GameIdentifier
	STATIC O_pQueueArray := 0x34, O_IndexParentTypes := 0x18, O_unitsQueued := 0x28

	CAbilQueue := readmemory(pAbilities + O_IndexParentTypes + 4 * CAbilQueueIndex, GameIdentifier)

	if IsByRef(QueueSize) 
		QueueSize := readmemory(CAbilQueue + O_unitsQueued, GameIdentifier)

	queuedArray := readmemory(CAbilQueue + O_pQueueArray, GameIdentifier)
	return readmemory(queuedArray + 4 * QueuePosition, GameIdentifier)
}

getAbilitiesCount(pAbilities)
{	GLOBAL GameIdentifier
	return ReadMemory(pAbilities + 0x16, GameIdentifier, 1)
}

getCAbilQueueIndex(pAbilities, AbilitiesCount)
{	GLOBAL GameIdentifier
	STATIC CAbilQueue := 0x19
	ByteArrayAddress := ReadMemory(pAbilities, GameIdentifier) + 0x3 
	ReadRawMemory(ByteArrayAddress, GameIdentifier, MemDump, AbilitiesCount)
	loop % AbilitiesCount
		if (CAbilQueue = numget(MemDump, A_Index-1, "Char"))
			return A_Index-1
	 return -1 ;error
}

; this is just used for testing
getAbilListIndex(pAbilities, AbilitiesCount)
{	GLOBAL GameIdentifier
	STATIC CAbilQueue := 0x19
	abilties := []
	ByteArrayAddress := ReadMemory(pAbilities, GameIdentifier) + 0x3 
	ReadRawMemory(ByteArrayAddress, GameIdentifier, MemDump, AbilitiesCount)
	loop % AbilitiesCount
		abilties.insert(CAbilQueue := dectohex(numget(MemDump, A_Index-1, "Char")))
	 return abilties
}

; These values are stored right next to each other, so to quickly find the correct ones again search for an 8byte value
SC2HorizontalResolution()
{	GLOBAL
	return  ReadMemory(B_HorizontalResolution, GameIdentifier)
}
SC2VerticalResolution()
{	GLOBAL
	return  ReadMemory(B_VerticalResolution, GameIdentifier)
}


; This is the character name and ID which is different for each region (obviously the name can be the same)
; Stored format = CharacterName#123 where 123 is the character ID

getCharacerInfo(byref returnName := "", byref returnID := "")
{	GLOBAL B_LocalCharacterNameID, GameIdentifier
	CharacterString := ReadMemory_Str(B_LocalCharacterNameID, GameIdentifier) 
	StringSplit, OutputArray, CharacterString, #
	returnName := OutputArray1
	returnID := OutputArray2
	return OutputArray0 ; contains the number of substrings
}


; this is a buffer which is only written to when issuing ctrl/shift grouping actions
; therefore the units it refers to may change as units die
; and their unit indexs are reused!!!!!  So must use this CAREFULLY and only in certain situations!!!! 
; have to check if unit is alive  and control group buffer isn't updated

; unit dies and is replaced with own local unit
; when a unit dies and is replaced by a local unit of same type it obviously wont respond or the 'ctrl grouped' command group
; so dont have to worry about that scenario

; BUT still need to worry about the fact that the wrong units will be READ as alive
; so if you know what unit should be in this control group, then just check unit type matches, is local unit and is alive
; and this should work for most scenarios (or at least the chances of it causing a problem are quite low)


; note ctrl group base address really starts with ctrl group 0 - but the negative offset from ctrl group 1 works fine
numGetControlGroupObject(Byref oControlGroup, Group)
{	GLOBAL B_CtrlGroupOneStructure, S_CtrlGroup, GameIdentifier, S_scStructure, O_scUnitIndex
	oControlGroup := []
	GroupSize := getControlGroupCount(Group)

	ReadRawMemory(B_CtrlGroupOneStructure + S_CtrlGroup * (group - 1), GameIdentifier, MemDump, GroupSize * S_scStructure + O_scUnitIndex)
;	oControlGroup["Count"]	:= numget(MemDump, 0, "Short")
;	oControlGroup["Types"]	:= numget(MemDump, O_scTypeCount, "Short") ;this will get whats actually in the memory
	oControlGroup["Count"]	:= oControlGroup["Types"] := 0
	oControlGroup.units := []
	loop % numget(MemDump, 0, "Short")
	{
		unit := numget(MemDump,(A_Index-1) * S_scStructure + O_scUnitIndex , "Int") >> 18
		if (!isUnitDead(unit) && isUnitLocallyOwned(unit))
		{

			oControlGroup.units.insert({ "UnitIndex": unit
										, "Type": Type := getUnitType(unit)
										, "Energy": getUnitEnergy(unit)
										, "x": getUnitPositionX(unit)
										, "y": getUnitPositionY(unit)
										, "z": getUnitPositionZ(unit)}) ;note the object is unitS not unit!!!
			oControlGroup["Count"]++
			if Type not in %typeList%
			{
				typeList .= "," Type 
				oControlGroup["Types"]++
			}

		}
	}
	return oControlGroup["Count"]
}


; On a side note, I discovered that there is a value 2-byte which represents of units in each subgroup
; for both the current selection and control groups
; the following subgroup count will be at +0x8

; Function When reversed:
; the first unit (in aSelection.units) is the last unit in the selection panel (i.e. furtherest from the start)
; the last unit (aSelection.units) is the very first unit (top left) of the selection panel
; otherwise they appear in the same order as they do in the unit panel

; Sorting Rules: (in order of priority)
; 	higher priority come first
; 		lower unitID/SubgroupAlias comes first
;			(hallucinated units come immediately before non-hallucinated counterparts)
; 				lower unit Index comes first

; Units with different unitID/SubgroupAliases are tabbable 

; hallucinated units come before their real counterparts. They can also be tabbed between
; hallucinated units are also selected with the select army hotkey (unless theyre probes)
; so easy/dirty fix is to give them a new subgroup alias slightly lower than their non-hallucinated brothers

; A subgroup alias is really just a unitID/type i.e. the unit belongs in the tank group

; This method does not call bubbleSort2DArray. bubbleSort2DArray uses a bubble method of sorting
; Which is very slow, and becomes much much slower as the array size grows
; Not only that, but calling  bubbleSort2DArray three times is required to get the units in the 
; correct order. Hence this takes a very long time!
;
; This new method exploits AHKs internal sorting method for objects, so no manual sorting is required!
; If aSelection is to be reversed, then reverseArray() is called.
; reverseArray() is very basic and fast.

; Test Case: 238 units were selected in SC2
; numGetSelectionBubbleSort i.e. bubble sort took 86.56 ms
; numGetSelectionSorted took just 4.75 ms ~18X faster!

numGetSelectionSorted(ByRef aSelection, ReverseOrder := False)
{
	aSelection := []
	selectionCount := getSelectionCount()
	ReadRawMemory(B_SelectionStructure, GameIdentifier, MemDump, selectionCount * S_scStructure + O_scUnitIndex)

	aSelection.Count := numget(MemDump, 0, "Short")
	aSelection.Types := numget(MemDump, O_scTypeCount, "Short")
	
	aSelection.HighlightedGroup := numget(MemDump, O_scTypeHighlighted, "Short")

	aStorage := []
	loop % aSelection.Count
	{
		; Use a negative priority so AHKs normal object enumerates them in the correct 
		; unit panel order (backwards to how they would normally be enumerated)
		priority := -1 * getUnitSubGroupPriority(unitIndex := numget(MemDump,(A_Index-1) * S_scStructure + O_scUnitIndex , "Int") >> 18)
		, unitId := getUnitType(unitIndex)
		, subGroupAlias := getUnitTargetFilterFast(unitIndex) & aUnitTargetFilter.Hallucination 
													? unitId  - .1 ; Dirty hack for hallucinations
													: (aUnitSubGroupAlias.hasKey(unitId) 
															? aUnitSubGroupAlias[unitId] 
															:  unitId)
		, sIndices .= "," unitIndex
		if !isUnitLocallyOwned(unitIndex)
			nonLocalUnitSelected := True										
	; AHK automatically creates an object if it doesn't exist when using this syntax
	; So i only have to check and make one object
	;	if !isObject(aStorage[priority])
	;		aStorage[priority] := []
		if !isObject(aStorage[priority, subGroupAlias])
		  	aStorage[priority, subGroupAlias] := []
		aStorage[priority, subGroupAlias].insert({"unitIndex": unitIndex, "unitId": unitId})
		
		; when aStorage is enumerated, units will be accessed in the same order
		; as they appear in the unit panel ie top left to bottom right 	
	}
	aSelection.IndicesString := substr(sIndices, 2) ; trim first "," 

	if (aSelection.Count && !nonLocalUnitSelected)
		aSelection.IsGroupable := True
	; This will convert the data into a simple indexed object
	; The index value will be 1 more than the unit portrait location
	aSelection.units := []
	aSelection.TabPositions := []
	aSelection.TabSizes := []
	TabPosition := unitPortrait := 0
	for priority, object in aStorage
	{
		for subGroupAlias, object2 in object 
		{
			; I put the next couple of lines here so they don't get needlessly looped
			; inside the next for loop
			if (TabPosition = aSelection.HighlightedGroup)
				aSelection.HighlightedId :=  object2[object2.minIndex()].unitId
			; Tab positions are stored with the unitId as key
			; so can just look up the tab location of unit type directly with no looping
			; cant use .insert(key, tabposition) as that adjusts higher keys (adds 1 to them)!
			aSelection.TabPositions[object2[object2.minIndex()].unitId] := TabPosition
			tabSize := 0
			for index, unit in object2 ; (unit is an object)
			{
				aSelection.units.insert({ "priority": -1*priority ; convert back to positive
										, "subGroupAlias": subGroupAlias
										, "unitIndex": unit.unitIndex
										, "unitId": unit.unitId
										, "tabPosition": TabPosition
										, "unitPortrait": unitPortrait++}) ; will be 1 less than A_index when iterated
										; Note unitPortrait++ increments after assigning value to unitPortrait
				tabSize++ ; how many unitsa re in each tab
			}
			aSelection.TabSizes[object2[object2.minIndex()].unitId] := tabSize								
			TabPosition++	
		}
	}
	if ReverseOrder
		aSelection.units := reverseArray(aSelection.units) ; Have to := as byRef wont work while inside another object
  	return aSelection["Count"]	
}

numGetSelectionBubbleSort(ByRef aSelection, ReverseOrder := False)
{
	aSelection := []
	selectionCount := getSelectionCount()
	ReadRawMemory(B_SelectionStructure, GameIdentifier, MemDump, selectionCount * S_scStructure + O_scUnitIndex)

	aSelection.Count := numget(MemDump, 0, "Short")
	aSelection.Types := numget(MemDump, O_scTypeCount, "Short")
	
	aSelection.HighlightedGroup := numget(MemDump, O_scTypeHighlighted, "Short")

	aSelection.units := []
	loop % aSelection.Count
	{

		aSelection.units.insert({ "unitIndex": unit := numget(MemDump,(A_Index-1) * S_scStructure + O_scUnitIndex , "Int") >> 18
								, "unitId": unitId := getUnitType(unit)
								, "priority": getUnitSubGroupPriority(unit)
							
								; What this does is: 
								; if unit is hallucinated assign a value (subgroup alias) .1 lower than 
								; the non-hallucinated version (so they will be sorted before real units)
								; If the unit isn't hallucinated check if check has a subgroup alias
								; if it does, then assign that subgroup alias, otherwise assign the unitID/type

								, "subGroup": getUnitTargetFilterFast(unit) & aUnitTargetFilter.Hallucination 
												? unitId  - .1 ; Dirty hack for hallucinations
												: (aUnitSubGroupAlias.hasKey(unitId) 
														? aUnitSubGroupAlias[unitId] 
														:  unitId) ;})
								, name: aUnitName[unitId]}) ; Include name for easy testing
	}

	bubbleSort2DArray(aSelection.units, "unitIndex", !ReverseOrder)   ; 0 on reverse
	bubbleSort2DArray(aSelection.units, "subGroup", !ReverseOrder)
	bubbleSort2DArray(aSelection.units, "Priority", ReverseOrder)

  	return aSelection["Count"]	
}

isInSelection(unitIndex)
{
	selectionCount := getSelectionCount()
	ReadRawMemory(B_SelectionStructure, GameIdentifier, MemDump, selectionCount * S_scStructure + O_scUnitIndex)
	loop % selectionCount
	{
		if (unitIndex = numget(MemDump, (A_Index-1) * S_scStructure + O_scUnitIndex, "Int") >> 18)
			return 1
	}
	return 0
}


numGetUnitSelectionObject(ByRef aSelection, mode = 0)
{	GLOBAL O_scTypeCount, O_scTypeHighlighted, S_scStructure, O_scUnitIndex, GameIdentifier, B_SelectionStructure
	aSelection := []
	selectionCount := getSelectionCount()
	ReadRawMemory(B_SelectionStructure, GameIdentifier, MemDump, selectionCount * S_scStructure + O_scUnitIndex)
	; aSelection.insert({"SelectedTypes:"})
	aSelection["Count"]	:= numget(MemDump, 0, "Short")
	aSelection["Types"]	:= numget(MemDump, O_scTypeCount, "Short")
	aSelection["HighlightedGroup"]	:= numget(MemDump, O_scTypeHighlighted, "Short")

	aSelection.units := []
	if (mode = "Sort")		
	{
		loop % aSelection["Count"]
		{
			unit := numget(MemDump,(A_Index-1) * S_scStructure + O_scUnitIndex , "Int") >> 18
			aSelection.units.insert({ "Type": getUnitType(unit), "UnitIndex": unit, "Priority": getUnitSubGroupPriority(unit)})	;NOTE this object will be accessed differently than the one below
		}
		bubbleSort2DArray(aSelection.units, "UnitIndex", 1) ; sort in ascending order
		bubbleSort2DArray(aSelection.units, "Priority", 0)	; sort in descending order
	}
	else if (mode = "UnSortedWithPriority")		
		loop % aSelection["Count"]
		{
			unit := numget(MemDump,(A_Index-1) * S_scStructure + O_scUnitIndex , "Int") >> 18
			aSelection.units.insert({ "Type": getUnitType(unit), "UnitIndex": unit, "Priority": getUnitSubGroupPriority(unit)})
		}	
	else
		loop % aSelection["Count"]
		{
			unit := numget(MemDump,(A_Index-1) * S_scStructure + O_scUnitIndex , "Int") >> 18
			, owner := getUnitOwner(unit), Type := getUnitType(unit), aSelection.units.insert({"UnitIndex": unit, "Type": Type, "Owner": Owner})
		}
	return aSelection["Count"]
}

getUnitSelectionPage()	;0-5 indicates which unit page is currently selected (in game its 1-6)
{	global 	
	return pointer(GameIdentifier, P_SelectionPage, O1_SelectionPage, O2_SelectionPage, O3_SelectionPage)
}
/*
numgetUnitTargetFilter(ByRef Memory, unit)
{
	local result 		;ahk has a problem with Uint64
	loop 8 
		result += numget(Memory, Unit * S_uStructure + O_uTargetFilter + A_index-1 , "Uchar") << 8*(A_Index-1)
	return result
  ; return numget(Memory, Unit * S_uStructure + O_uTargetFilter, "UDouble") ;not double!
}
*/
numgetUnitTargetFilter(ByRef Memory, unit)
{
	return numget(Memory, Unit * S_uStructure + O_uTargetFilter, "Int64")
}
getUnitTargetFilter(Unit) ;starts @ 0 i.e. first unit at 0
{
	return ReadMemory(B_uStructure + Unit * S_uStructure + O_uTargetFilter, GameIdentifier, 8)
}
getUnitTargetFilterFast(unit)	;only marginally faster ~12%
{	
	return ReadMemory(B_uStructure + Unit * S_uStructure + O_uTargetFilter, GameIdentifier, 8)
}

/*
getUnitTargetFilter(Unit) ;starts @ 0 i.e. first unit at 0
{	local Memory, result 		;ReadRawMemory/numget is only ~11% faster

	ReadRawMemory(B_uStructure + Unit * S_uStructure + O_uTargetFilter, GameIdentifier, Memory, 8)
	loop 8 
		result += numget(Memory, A_index-1 , "Uchar") << 8*(A_Index-1)
	return result
;	Return	ReadMemoryOld((B_uStructure + (Unit * S_uStructure)) + O_uTargetFilter, GameIdentifier, 8) ;This is required for the reading of the 8 bit target filter - cant work out how to do this properly with numget without looping a char
}
*/


; AHK cant read 64 bit unsigned integers properly,
; but doesnt really matter as using bitmask on them
; and even then the bitmasks are less than the extreme non-supported values
/*
getUnitTargetFilterFast(unit)	;only marginally faster ~12%
{	local Memory, result
	ReadRawMemory(B_uStructure + Unit * S_uStructure + O_uTargetFilter, GameIdentifier, Memory, 8)
	loop 8 
		result += numget(Memory, A_index-1 , "Uchar") << 8*(A_Index-1)
	return result
}
*/

numgetUnitOwner(ByRef Memory, Unit)
{ global 
  return numget(Memory, Unit * S_uStructure + O_uOwner, "Char")  
}

numgetUnitModelPointer(ByRef Memory, Unit)
{ global 
  return numget(Memory, Unit * S_uStructure + O_uModelPointer, "Int")  
}

 getGroupedQueensWhichCanInject(ByRef aControlGroup,  CheckMoveState := 0)
 {	GLOBAL aUnitID, O_scTypeCount, O_scTypeHighlighted, S_CtrlGroup, O_scUnitIndex, GameIdentifier, B_CtrlGroupOneStructure
 	, S_uStructure, GameIdentifier, MI_Queen_Group, S_scStructure, aUnitMoveStates
	aControlGroup := []
	group := MI_Queen_Group
	groupCount := getControlGroupCount(Group)

	ReadRawMemory(B_CtrlGroupOneStructure + S_CtrlGroup * (Group - 1), GameIdentifier, MemDump, groupCount * S_CtrlGroup + O_scUnitIndex)

	aControlGroup["UnitCount"]	:= numget(MemDump, 0, "Short")
	aControlGroup["Types"]	:= numget(MemDump, O_scTypeCount, "Short")
;	aControlGroup["HighlightedGroup"]	:= numget(MemDump, O_scTypeHighlighted, "Short")
	aControlGroup.Queens := []
	aControlGroup.AllQueens := []

	loop % groupCount
	{
		unit := numget(MemDump,(A_Index-1) * S_scStructure + O_scUnitIndex , "Int") >> 18
		if (isUnitDead(unit) || !isUnitLocallyOwned(Unit)) ; as this is being reead from control group buffer so dead units can still be included!
			continue 
		
		if (aUnitID["Queen"] = type := getUnitType(unit)) 
		{
			; this is used to keep track of if some queens shouldnt inject 
			aControlGroup.AllQueens.insert({ "unit": unit})

			; I do this because my blocking of keys isnt 100% and if the user is pressing H e.g. hold posistion army or make hydras 
			; and so can accidentally put queen on hold position thereby stopping injects!!!
			; so queen is not moving/patrolling/a-moving ; also if user right clicks queen to catsh, that would put her on a never ending follow command
			; QueenBuild = make creepTumour (or on way to making it) - state = 0
			if (energy := getUnitEnergy(unit) >= 25)
			{
				if CheckMoveState
				{
					commandString := getUnitQueuedCommandString(unit)
					if !(InStr(commandString, "SpawnLarva") || InStr(commandString, "Patrol") || InStr(commandString, "Move") || InStr(commandString, "Attack")
					|| InStr(commandString, "QueenBuild") || InStr(commandString, "Transfusion"))
						aControlGroup.Queens.insert(objectGetUnitXYZAndEnergy(unit)), aControlGroup.Queens[aControlGroup.Queens.MaxIndex(), "Type"] := Type
				}
				else 
					aControlGroup.Queens.insert(objectGetUnitXYZAndEnergy(unit)), aControlGroup.Queens[aControlGroup.Queens.MaxIndex(), "Type"] := Type
			}
		}

	} 																																					
	aControlGroup["QueenCount"] := round(aControlGroup.Queens.maxIndex()) ; as "SelectedUnitCount" will contain total selected queens + other units in group
	return 	aControlGroup.Queens.maxindex()
 }

	; CheckMoveState for forced injects
 getSelectedQueensWhichCanInject(ByRef aSelection, CheckMoveState := 0)
 {	GLOBAL aUnitID, O_scTypeCount, O_scTypeHighlighted, S_scStructure, O_scUnitIndex, GameIdentifier, B_SelectionStructure
 	, S_uStructure, GameIdentifier, aUnitMoveStates 
	aSelection := []
	selectionCount := getSelectionCount()
	ReadRawMemory(B_SelectionStructure, GameIdentifier, MemDump, selectionCount * S_scStructure + O_scUnitIndex)
	aSelection["SelectedUnitCount"]	:= numget(MemDump, 0, "Short")
	aSelection["Types"]	:= numget(MemDump, O_scTypeCount, "Short")
	aSelection["HighlightedGroup"]	:= numget(MemDump, O_scTypeHighlighted, "Short")
	aSelection.Queens := []

	loop % selectionCount
	{
		unit := numget(MemDump,(A_Index-1) * S_scStructure + O_scUnitIndex , "Int") >> 18
		type := getUnitType(unit)
		if (isUnitLocallyOwned(Unit) && aUnitID["Queen"] = type && ((energy := getUnitEnergy(unit)) >= 25)) 
		{
			if CheckMoveState
			{
				commandString := getUnitQueuedCommandString(unit)
				if !(InStr(commandString, "Patrol") || InStr(commandString, "Move") || InStr(commandString, "Attack")
				|| InStr(commandString, "QueenBuild") || InStr(commandString, "Transfusion"))		
					aSelection.Queens.insert(objectGetUnitXYZAndEnergy(unit)), aSelection.Queens[aSelection.Queens.MaxIndex(), "Type"] := Type
			}
			else 
				aSelection.Queens.insert(objectGetUnitXYZAndEnergy(unit)), aSelection.Queens[aSelection.Queens.MaxIndex(), "Type"] := Type
		}
	} 																								; also if user right clicks queen to catsh, that would put her on a never ending follow command
	aSelection["Count"] := round(aSelection.Queens.maxIndex())		; as "SelectedUnitCount" will contain total selected queens + other units in group
	return 	aSelection.Queens.maxindex()
 }

isQueenNearHatch(Queen, Hatch, MaxXYdistance) ; takes objects which must have keys of x, y and z
{
	x_dist := Abs(Queen.X - Hatch.X)
	y_dist := Abs(Queen.Y- Hatch.Y)																									
																								; there is a substantial difference in height even on 'flat ground' - using a max value of 1 should give decent results
	Return Result := (x_dist > MaxXYdistance) || (y_dist > MaxXYdistance) || (Abs(Queen.Z - Hatch.Z) > 1) ? 0 : 1 ; 0 Not near
}

isUnitNearUnit(Queen, Hatch, MaxXYdistance) ; takes objects which must have keys of x, y and z
{
	x_dist := Abs(Queen.X - Hatch.X)
	y_dist := Abs(Queen.Y- Hatch.Y)																											
												; there is a substantial difference in height even on 'flat ground' - using a max value of 1 should give decent results
	Return Result := (x_dist > MaxXYdistance) || (y_dist > MaxXYdistance) || (Abs(Queen.Z - Hatch.Z) > 1) ? 0 : 1 ; 0 Not near
}

 objectGetUnitXYZAndEnergy(unit) ;this will dump just a unit
 {	Local UnitDump
	ReadRawMemory(B_uStructure + unit * S_uStructure, GameIdentifier, UnitDump, S_uStructure)
	Local x := numget(UnitDump, O_uX, "int")/4096, y := numget(UnitDump, O_uY, "int")/4096, Local z := numget(UnitDump, O_uZ, "int")/4096
	Local Energy := numget(UnitDump, O_uEnergy, "int")/4096
	return { "unit": unit, "X": x, "Y": y, "Z": z, "Energy": energy}
 }

 numGetUnitPositionXFromMemDump(ByRef MemDump, Unit)
 {	global
 	return numget(MemDump, Unit * S_uStructure + O_uX, "int")/4096
 }
 numGetUnitPositionYFromMemDump(ByRef MemDump, Unit)
 {	global
 	return numget(MemDump, Unit * S_uStructure + O_uY, "int")/4096
 }
 numGetUnitPositionZFromMemDump(ByRef MemDump, Unit)
 {	global
 	return numget(MemDump, Unit * S_uStructure + O_uZ, "int")/4096
 }
 numGetIsHatchInjectedFromMemDump(ByRef MemDump, Unit)
 {	global ; 1 byte = 18h chrono for protoss structures, 48h when injected for zerg -  10h normal state
 	return (4 = numget(MemDump, Unit * S_uStructure + O_uInjectState, "UChar")) ? 1 : 0
 }

numGetUnitPositionXYZFromMemDump(ByRef MemDump, Unit)
{	
	position := []
	, position.x := numGetUnitPositionXFromMemDump(MemDump, Unit)
	, position.y := numGetUnitPositionYFromMemDump(MemDump, Unit)
	, position.z := numGetUnitPositionZFromMemDump(MemDump, Unit)
	return position
}

SortUnitsByAge(unitlist="", units*)
{
	List := []		
	if unitlist		
	{				
		units := []	
		loop, parse, unitlist, |
			units[A_index] := A_LoopField
	}	
	for index, unit in units
		List[A_Index] := {Unit:unit,Age:getUnitTimer(unit)}
	bubbleSort2DArray(List, "Age", 0) ; 0 = descending
	For index, obj in List
		SortedList .= List[index].Unit "|"
	return RTrim(SortedList, "|")
}


getBaseCamIndex() ; begins at 0
{	global 	
	return pointer(GameIdentifier, B_CurrentBaseCam, P1_CurrentBaseCam)
}

SortBasesByBaseCam(BaseList, CurrentHatchCam)
{
	BaseList := SortUnitsByAge(BaseList)	;getBaseCameraCount()
	loop, parse, BaseList, |
		if (A_loopfield <> CurrentHatchCam)
			if CurrentIndex
				list .= A_LoopField "|"
			else
				LoList .= A_LoopField "|"
		else 
		{
			CurrentIndex := A_index
			list .= A_LoopField "|"
		}

	if LoList
		list := list LoList 
	return RTrim(list, "|")
}

; weirdly in the mapeditor the techlabs each have their own subgroup aliases
; yet they all appear in the same subgroup i.e. TechLab

; to work out the required number of tabs, i.e. how many tab presses to arrive at
; a unit group: 1 tab for every time the subGroup changes in the array

getSubGroupAliasArray(byRef object)
{
	if !isObject(object)
		object := []
	 object := {aUnitID.VikingFighter: aUnitID.VikingAssault                
       		 , aUnitID.BarracksTechLab: aUnitID.TechLab ; All tech labs come under techlab
       		 , aUnitID.FactoryTechLab: aUnitID.TechLab 
       		 , aUnitID.StarportTechLab: aUnitID.TechLab
       		 , aUnitID.BarracksReactor: aUnitID.Reactor
       		 , aUnitID.FactoryReactor: aUnitID.Reactor
       		 , aUnitID.StarportReactor: aUnitID.Reactor
       		 , aUnitID.WidowMineBurrowed: aUnitID.WidowMine 
       		 , aUnitID.SiegeTankSieged: aUnitID.SiegeTank 
       		 , aUnitID.HellBat: aUnitID.Hellion 
       		 , aUnitID.ChangelingZealot: aUnitID.Changeling 
       		 , aUnitID.ChangelingMarineShield: aUnitID.Changeling 
       		 , aUnitID.ChangelingMarine: aUnitID.Changeling 
       		 , aUnitID.ChangelingZerglingWings: aUnitID.Changeling 
       		 , aUnitID.ChangelingZergling: aUnitID.Changeling}
	return       		 
}

getUnitSubGroupPriority(unit)	
{
	; note - this isnt really the correct pointer still have to << 5 
	if !aUnitModel[pUnitModel := ReadMemory(B_uStructure + (Unit * S_uStructure) + O_uModelPointer, GameIdentifier)]
    	getUnitModelInfo(pUnitModel)
  	return aUnitModel[pUnitModel].RealSubGroupPriority	
;	Return ReadMemory(((ReadMemory(B_uStructure + (unit * S_uStructure) + O_uModelPointer, GameIdentifier) << 5) & 0xFFFFFFFF) + O_mSubgroupPriority, GameIdentifier, 2)
}



setupMiniMapUnitListsOld()
{	local list, unitlist, ListType, listCount
	list := "UnitHighlightList1,UnitHighlightList2,UnitHighlightList3,UnitHighlightList4,UnitHighlightList5,UnitHighlightList6,UnitHighlightList7,UnitHighlightExcludeList"
	Loop, Parse, list, `,
	{	
		ListType := A_LoopField
		Active%ListType% := ""		;clear incase changed via options between games	
		StringReplace, unitlist, %A_LoopField%, %A_Space%, , All ; Remove Spaces also creates var unitlist				
		unitlist := Trim(unitlist, " `t , |")	; , or `, both work - remove spaces, tabs and commas
		loop, parse, unitlist, `,
			Active%ListType% .= aUnitID[A_LoopField] ","
		Active%ListType% := RTrim(Active%ListType%, " ,")
		listCount++
	}
	allActiveActiveUnitHighlightLists := ""
	loop, % listCount - 1 ; remove the 1 count from the UnitHighlightExcludeList
	{
		loop, parse, ActiveUnitHighlightList%A_Index%, ","
			allActiveActiveUnitHighlightLists .= A_LoopField ","
	}
	; this will contain all the unit ids
	allActiveActiveUnitHighlightLists := RTrim(allActiveActiveUnitHighlightLists, " ,")
	Return
}

setupMiniMapUnitLists(byRef aMiniMapUnits)
{	local list, unitlist, ListType
	aUnitHighlights := []
	aMiniMapUnits.Highlight := []
	aMiniMapUnits.Exclude := []
	list := "UnitHighlightList1,UnitHighlightList2,UnitHighlightList3,UnitHighlightList4,UnitHighlightList5,UnitHighlightList6,UnitHighlightList7,UnitHighlightExcludeList"
	Loop, Parse, list, `,
	{	
		StringReplace, unitlist, %A_LoopField%, %A_Space%, , All ; Remove Spaces also creates var unitlist	
		StringReplace, unitlist, unitlist, %A_Tab%, , All
		unitlist := Trim(unitlist, ", |")	; , or `, both work - remove spaces, tabs and commas
		listNumber := A_Index ; If adding more custom highlights to the above list, ensure UnitHighlightExcludeList is last in the list!
		
		if (A_LoopField = "UnitHighlightExcludeList")
		{
			loop, parse, unitlist, `,
				aMiniMapUnits.Exclude[aUnitID[A_LoopField]] := True
		}
		else 
		{
			loop, parse, unitlist, `,
				aMiniMapUnits.Highlight[aUnitID[A_LoopField]] := "UnitHighlightList" listNumber "Colour"
		}
	}
	Return
}


;--------------------
;	Mini Map Setup
;--------------------
SetMiniMap(byref minimap)
{	
	; minimap is a super global (though here it is a local)
	minimap := []

	minimap.MapLeft := getmapleft()
	minimap.MapRight := getmapright()	
	minimap.MapTop := getMaptop()
	minimap.MapBottom := getMapBottom()

	AspectRatio := getScreenAspectRatio()	
	If (AspectRatio = "16:10")
	{
		ScreenLeft := (27/1680) * A_ScreenWidth		
		ScreenBottom := (1036/1050) * A_ScreenHeight	
		ScreenRight := (281/1680) * A_ScreenWidth	
		ScreenTop := (786/1050) * A_ScreenHeight

	}	
	Else If (AspectRatio = "5:4")
	{	
		ScreenLeft := (25/1280) * A_ScreenWidth
		ScreenBottom := (1011/1024) * A_ScreenHeight
		ScreenRight := (257/1280) * A_ScreenWidth 
		Screentop := (783/1024) * A_ScreenHeight
	}	
	Else If (AspectRatio = "4:3")
	{	
		ScreenLeft := (25/1280) * A_ScreenWidth
		ScreenBottom := (947/960) * A_ScreenHeight
		ScreenRight := (257/1280) * A_ScreenWidth 
		ScreenTop := (718/960) * A_ScreenHeight

	}
	Else ;16:9 Else if (AspectRatio = "16:9")
	{
		ScreenLeft 		:= (29/1920) * A_ScreenWidth
		ScreenBottom 	:= (1066/1080) * A_ScreenHeight
		ScreenRight 	:= (289/1920) * A_ScreenWidth 
		ScreenTop 		:= (807/1080) * A_ScreenHeight
	}	
	minimap.ScreenWidth := ScreenRight - ScreenLeft
	minimap.ScreenHeight := ScreenBottom - ScreenTop
	minimap.MapPlayableWidth 	:= minimap.MapRight - minimap.MapLeft
	minimap.MapPlayableHeight 	:= minimap.MapTop - minimap.MapBottom

	if (minimap.MapPlayableWidth >= minimap.MapPlayableHeight)
	{
		minimap.scale := minimap.Screenwidth / minimap.MapPlayableWidth
		X_Offset := 0
		minimap.ScreenLeft := ScreenLeft + X_Offset
		minimap.ScreenRight := ScreenRight - X_Offset	
		Y_offset := (minimap.ScreenHeight - minimap.scale * minimap.MapPlayableHeight) / 2
		minimap.ScreenTop := ScreenTop + Y_offset
		minimap.ScreenBottom := ScreenBottom - Y_offset
		minimap.Height := minimap.ScreenBottom - minimap.ScreenTop
		minimap.Width := minimap.ScreenWidth 

	}
	else
	{
		minimap.scale := minimap.ScreenHeight / minimap.MapPlayableHeight
		X_Offset:= (minimap.ScreenWidth - minimap.scale * minimap.MapPlayableWidth)/2
		minimap.ScreenLeft := ScreenLeft + X_Offset
		minimap.ScreenRight := ScreenRight - X_Offset	
		Y_offset := 0
		minimap.ScreenTop := ScreenTop + Y_offset
		minimap.ScreenBottom := ScreenBottom - Y_offset
		minimap.Height := minimap.ScreenHeight 
		minimap.Width := minimap.ScreenRight - minimap.ScreenLeft	
	}
	minimap.UnitMinimumRadius := 1 / minimap.scale
	minimap.UnitMaximumRadius  := 10
	minimap.AddToRadius := 1 / minimap.scale			
Return
}

initialiseBrushColours(aHexColours, byRef a_pBrushes)
{
	Global UnitHighlightHallucinationsColour, UnitHighlightInvisibleColour
		, UnitHighlightList1Colour, UnitHighlightList2Colour, UnitHighlightList3Colour
		, UnitHighlightList4Colour, UnitHighlightList5Colour, UnitHighlightList6Colour
		, UnitHighlightList7Colour

	; If there is already a brush, lets delete it before creating new ones
	; This is required as the userhighlight brushes colours can change

	if aHexColours[aHexColours.MinIndex()]
		deleteBrushArray(a_pBrushes)
	a_pBrushes := []
	for colour, hexValue in aHexColours
		a_pBrushes[colour] := Gdip_BrushCreateSolid(0xcFF hexValue)
	; Used in the unit overlay	
	a_pBrushes["TransparentBlack"] := Gdip_BrushCreateSolid(0x78000000)
	a_pBrushes["ScanChrono"] := Gdip_BrushCreateSolid(0xCCFF00B3)
	a_pBrushes["UnitHighlightHallucinationsColour"] := Gdip_BrushCreateSolid(UnitHighlightHallucinationsColour)
	a_pBrushes["UnitHighlightInvisibleColour"] := Gdip_BrushCreateSolid(UnitHighlightInvisibleColour)
	a_pBrushes["UnitHighlightList1Colour"] := Gdip_BrushCreateSolid(UnitHighlightList1Colour)
	a_pBrushes["UnitHighlightList2Colour"] := Gdip_BrushCreateSolid(UnitHighlightList2Colour)
	a_pBrushes["UnitHighlightList3Colour"] := Gdip_BrushCreateSolid(UnitHighlightList3Colour)
	a_pBrushes["UnitHighlightList4Colour"] := Gdip_BrushCreateSolid(UnitHighlightList4Colour)
	a_pBrushes["UnitHighlightList5Colour"] := Gdip_BrushCreateSolid(UnitHighlightList5Colour)
	a_pBrushes["UnitHighlightList6Colour"] := Gdip_BrushCreateSolid(UnitHighlightList6Colour)
	a_pBrushes["UnitHighlightList7Colour"] := Gdip_BrushCreateSolid(UnitHighlightList7Colour)

	return 
}



deleteBrushArray(byRef a_pBrushes)
{
	for colour, pBrush in a_pBrushes
		Gdip_DeleteBrush(pBrush)
	a_pBrushes := []
	return
}

; 11/02/14 
; Just realised i don't think i delete any pens
; but I thinks? they are all static static anyway so it doesnt matter.

initialisePenColours(aHexColours)
{
	a_pPens := []
	for colour, hexValue in aHexColours
		a_pPens[colour] := Gdip_CreatePen(0xcFF hexValue, 1)
	return a_pPens
}


drawUnitRectangle(G, x, y, width, height, colour := "black")
{ 	
	global minimap
	width *= minimap.scale
	height *= minimap.scale

	x := x - width / 2
	y :=y - height /2
					;as pen is only 1 pixel, it doesn't encroach into the fill paint (only occurs when >=2)
;	if !pPen
;		pPen := Gdip_CreatePen(0xFF000000, 1)	

	Gdip_DrawRectangle(G, a_pPens[colour], x, y, width, height)
}

FillUnitRectangle(G, x, y, width, height, colour)
{ 	global minimap

	width *= minimap.scale
	height *= minimap.scale
	x := x - width / 2
	y := y - height /2

;	if !a_pBrush[colour]	;faster than creating same colour again 
;		a_pBrush[colour] := Gdip_BrushCreateSolid(colour)
	Gdip_FillRectangle(G, a_pBrushes[colour], x, y, width, height)
}



isUnitLocallyOwned(Unit) ; 1 its local player owned
{	global aLocalPlayer
	Return aLocalPlayer["Slot"] = getUnitOwner(Unit) ? 1 : 0
}
isOwnerLocal(Owner) ; 1 its local player owned
{	global aLocalPlayer
	Return aLocalPlayer["Slot"] = Owner ? 1 : 0
}

GetEnemyRaces()
{	global aPlayer, aLocalPlayer
	For slot_number in aPlayer
	{	If ( aLocalPlayer["Team"] <>  team := aPlayer[slot_number, "Team"] )
		{
			If ( EnemyRaces <> "")
				EnemyRaces .= ", "
			EnemyRaces .= aPlayer[slot_number, "Race"]
		}
	}
	return EnemyRaces .= "."
}

GetGameType(aPlayer)
{	
	For slot_number in aPlayer
	{	team := aPlayer[slot_number, "Team"]
		TeamsList .= Team "|"
		Player_i ++
	}
	Sort, TeamsList, D| N U
	TeamsList := SubStr(TeamsList, 1, -1)
	Loop, Parse, TeamsList, |
		Team_i := A_Index
	If (Team_i > 2)
		Return "FFA" 
	Else	 ;sets game_type to 1v1,2v2,3v3,4v4 ;this helps with empty player slots in custom games - round up to the next game type
		Return Ceil(Player_i/Team_i) "v" Ceil(Player_i/Team_i)
}

GetEnemyTeamSize()
{	global aPlayer, aLocalPlayer
	For slot_number in aPlayer
		If aLocalPlayer["Team"] <> aPlayer[slot_number, "Team"]
			EnemyTeam_i ++
	Return EnemyTeam_i
}

GetEBases()
{	global aPlayer, aLocalPlayer, aUnitID, DeadFilterFlag
	EnemyBase_i := GetEnemyTeamSize()
	Unitcount := DumpUnitMemory(MemDump)
	while (A_Index <= Unitcount)
	{
		unit := A_Index - 1
		TargetFilter := numgetUnitTargetFilter(MemDump, unit)
		if (TargetFilter & DeadFilterFlag)
	    	Continue	
	    pUnitModel := numgetUnitModelPointer(MemDump, Unit)
	   	Type := numgetUnitModelType(pUnitModel)
	   	owner := numgetUnitOwner(MemDump, Unit) 
		IF (( type = aUnitID["Nexus"] ) OR ( type = aUnitID["CommandCenter"] ) OR ( type = aUnitID["Hatchery"] )) AND (aPlayer[Owner, "Team"] <> aLocalPlayer["Team"])
		{
			Found_i ++
			list .=  unit "|"
		}
	}
	Return SubStr(list, 1, -1)	; remove last "|"	
}

DumpUnitMemory(BYREF MemDump)
{   
  LOCAL UnitCount := getHighestUnitIndex()
  ReadRawMemory(B_uStructure, GameIdentifier, MemDump, UnitCount * S_uStructure)
  return UnitCount
}
class cUnitModelInfo
{
   __New(pUnitModel) 
   {  global GameIdentifier, O_mUnitID, O_mMiniMapSize, O_mSubgroupPriority
      ReadRawMemory((pUnitModel<< 5) & 0xFFFFFFFF, GameIdentifier, uModelData, O_mMiniMapSize+4) ; O_mMiniMapSize - 0x39C + 4 (int) is the highest offset i get from the unitmodel
      this.Type := numget(uModelData, O_mUnitID, "Short") 
      this.MiniMapRadius := numget(uModelData, O_mMiniMapSize, "int")/4096
      this.RealSubGroupPriority := numget(uModelData, O_mSubgroupPriority, "Short")
   }

}

numgetUnitModelType(pUnitModel)
{  global aUnitModel
   if !aUnitModel[pUnitModel]
      getUnitModelInfo(pUnitModel)
   return aUnitModel[pUnitModel].Type
}
numgetUnitModelMiniMapRadius(pUnitModel)
{  global aUnitModel
   if !aUnitModel[pUnitModel]
      getUnitModelInfo(pUnitModel)
   return aUnitModel[pUnitModel].MiniMapRadius
}
numgetUnitModelPriority(pUnitModel)
{  global aUnitModel
   if !aUnitModel[pUnitModel]
      getUnitModelInfo(pUnitModel)
   return aUnitModel[pUnitModel].RealSubGroupPriority
}

getUnitModelInfo(pUnitModel)
{  global aUnitModel
   aUnitModel[pUnitModel] := new cUnitModelInfo(pUnitModel)
   return
}

isUnitDead(unit)
{ 	global 
	return	getUnitTargetFilterFast(unit) & DeadFilterFlag
}


; 	provides two simple arrays
;	aUnitID takes the unit name e.g. "Stalker" and return the unit ID
; 	aUnitName takes the unit ID and Returns the unit name

SetupUnitIDArray(byref aUnitID, byref aUnitName)
{
	#include %A_ScriptDir%\Included Files\l_UnitTypes.AHK
	if !isobject(aUnitID)
		aUnitID := []
	if !isobject(aUnitName)
		aUnitName := []
	loop, parse, l_UnitTypes, `,
	{
		StringSplit, Item , A_LoopField, = 		; Format "Colossus = 38"
		name := trim(Item1, " `t `n"), UnitID := trim(Item2, " `t `n")
		aUnitID[name] := UnitID
		aUnitName[UnitID] := name
	}
	Return
}

setupTargetFilters(byref Array)
{
	#include %A_ScriptDir%\Included Files\aUnitTargetFilter.AHK
	Array := aUnitTargetFilter
	return
}

SetupColourArrays(ByRef HexColour, Byref MatrixColour)
{ 	
	If IsByRef(HexColour)
		HexColour := [] 
	If IsByRef(MatrixColour)	
		MatrixColour := []
	HexCoulourList := "White=FFFFFF|Red=B4141E|Blue=0042FF|Teal=1CA7EA|Purple=540081|Yellow=EBE129|Orange=FE8A0E|Green=168000|Light Pink=CCA6FC|Violet=1F01C9|Light Grey=525494|Dark Green=106246|Brown=4E2A04|Light Green=96FF91|Dark Grey=232323|Pink=E55BB0|Black=000000"
	loop, parse, HexCoulourList, |  
	{
		StringSplit, Item , A_LoopField, = ;Format "White = FFFFFF"
		If IsByRef(HexColour)
			HexColour[Item1] := Item2 ; White, FFFFFF - hextriplet R G B
		If IsByRef(MatrixColour)
		{
			colour := Item2
			colourRed := "0x" substr(colour, 1, 2) ;theres a way of doing this with math but im lazy
			colourGreen := "0x" substr(colour, 3, 2)
			colourBlue := "0x" substr(colour, 5, 2)	
			colourRed := Round(colourRed/0xFF,2)
			colourGreen := Round(colourGreen/0xFF,2)
			colourBlue := Round(colourBlue/0xFF,2)		
			Matrix =
		(
0		|0		|0		|0		|0
0		|0		|0		|0		|0
0		|0		|0		|0		|0
0		|0		|0		|1		|0
%colourRed%	|%colourGreen%	|%colourBlue%	|0		|1
		)
			MatrixColour[Item1] := Matrix
		}
	}
	Return
}


CreatepBitmaps(byref a_pBitmap, aUnitID)
{
	a_pBitmap := []
	l_Races := "Terran,Protoss,Zerg"
	loop, parse, l_Races, `,
	{
		loop, 2
		{
			Background := A_index - 1
			a_pBitmap[A_loopfield,"Mineral",Background] := Gdip_CreateBitmapFromFile(A_Temp "\Mineral_" Background A_loopfield ".png")
			a_pBitmap[A_loopfield,"Gas",Background] := Gdip_CreateBitmapFromFile(A_Temp "\Gas_" Background A_loopfield ".png")			
			a_pBitmap[A_loopfield,"Supply",Background] := Gdip_CreateBitmapFromFile(A_Temp "\Supply_" Background A_loopfield ".png")
		}
		a_pBitmap[A_loopfield,"Worker"] := Gdip_CreateBitmapFromFile(A_Temp "\Worker_0" A_loopfield ".png")
		a_pBitmap[A_loopfield,"Army"] := Gdip_CreateBitmapFromFile(A_Temp "\Army_" A_loopfield ".png")
		a_pBitmap[A_loopfield,"RaceFlat"]  := Gdip_CreateBitmapFromFile(A_Temp "\Race_" A_loopfield "Flat.png")
		a_pBitmap[A_loopfield,"RacePretty"] := Gdip_CreateBitmapFromFile(A_Temp "\" A_loopfield "90.png")
	}
	Loop, %A_Temp%\UnitPanelMacroTrainer\*.png
	{
		StringReplace, FileTitle, A_LoopFileName, .%A_LoopFileExt% ;remove the .ext
		if aUnitID[FileTitle]	;have a 2 pics which arnt in the unit array - bunkerfortified & thorsiegemode
			a_pBitmap[aUnitID[FileTitle]] := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
		else  ; these are upgrades and accessed by SC2 item name string
			a_pBitmap[FileTitle] := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
	}
	a_pBitmap["PurpleX16"] := Gdip_CreateBitmapFromFile(A_Temp "\PurpleX16.png")
	a_pBitmap["GreenX16"] := Gdip_CreateBitmapFromFile(A_Temp "\GreenX16.png")
	a_pBitmap["RedX16"] := Gdip_CreateBitmapFromFile(A_Temp "\RedX16.png")
}

;----------------------
;	player_team_sorter
;-----------------------
getPlayers(byref aPlayer, byref aLocalPlayer, byref aEnemyAndLocalPlayer := "")
{
	aPlayer := [], aLocalPlayer := [], aEnemyAndLocalPlayer := []
	; this should probably be 15, as I skip the first always neutral player in my player functions
	Loop, 15	;doing it this way allows for custom games with blank slots ;can get weird things if 16 (but filtering them for nonplayers)
	{
		if !getPlayerName(A_Index) ;empty slot custom games?
		|| IsInList(getPlayerType(A_Index), "None", "Neutral", "Hostile", "Referee", "Spectator")
			Continue
		aPlayer.insert( A_Index, new c_Player(A_Index) )  ; insert at player index so can call using player slot number 
		If (A_Index = getLocalPlayerNumber()) OR (debug AND getPlayerName(A_Index) == debug_name)
			aLocalPlayer :=  new c_Player(A_Index)
	}
	for slotNumber, player in aPlayer
	{
		if player.Team != aLocalPlayer.Team 
			aEnemyAndLocalPlayer.insert(player)
	}
	; so local player is last in this object so when iterating for overlays local player shows up last
	; but cant use the key as the slot number for this object!!!
	aEnemyAndLocalPlayer.Insert(aLocalPlayer) 
	return	
}


IsInList(Var, items*)
{
	for key, item in items
	{
		If (var = item)
			Return 1
	}
	return 0
}


class c_Player
{
	__New(i) 
	{	
		this.Slot := i
		this.Type := getPlayerType(i)
		this.Name := getPlayerName(i)
		this.Team := getPlayerTeam(i)
		this.Race := getPlayerRace(i)
		this.Colour := getPlayerColour(i)
	}
} 

Class c_EnemyUnit
{
	__New(unit) 
	{	
		this.Radius := getMiniMapRadius(Unit)
		this.Owner := getUnitOwner(Unit)
		this.Type := getUnitType(Unit)
		this.X := getUnitPositionX(unit)
		this.Y := getUnitPositionY(unit)
		this.TargetFilter := getUnitTargetFilter(Unit)	
	}
}

;ParseEnemyUnits(ByRef a_LocalUnits, ByRef a_EnemyUnits, ByRef aPlayer)
ParseEnemyUnits(ByRef a_EnemyUnits, ByRef aPlayer)
{ global DeadFilterFlag
	LocalTeam := getPlayerTeam(), a_EnemyUnitsTmp := []
	While (A_Index <= getHighestUnitIndex())
	{
		unit := A_Index -1
		Filter := getUnitTargetFilter(unit)	
		If (Filter & DeadFilterFlag) || (type = "Fail")
			Continue
		Owner := getUnitOwner(unit)
		if  (aPlayer[Owner, "Team"] <> LocalTeam AND Owner) 
			a_EnemyUnitsTmp[Unit] := new c_EnemyUnit(Unit)
	}
	a_EnemyUnits := a_EnemyUnitsTmp
}


areOverlaysWaitingToRedraw()
{
	global 
	if (!ReDrawIncome || !ReDrawResources || !ReDrawArmySize || !ReDrawWorker 
	|| !ReDrawIdleWorkers || !RedrawUnit || !ReDrawLocalPlayerColour || !ReDrawMiniMap)
		return False 
	return True 
}

DestroyOverlays()
{	
	global
	; destroy minimap when alttabed out
	; and at end of game
	Try Gui, APMOverlay: Destroy 
	Try Gui, MiniMapOverlay: Destroy 
	Try Gui, IncomeOverlay: Destroy
	Try Gui, ResourcesOverlay: Destroy
	Try Gui, ArmySizeOverlay: Destroy
	Try Gui, WorkerOverlay: Destroy			
	Try Gui, idleWorkersOverlay: Destroy			
	Try Gui, LocalPlayerColourOverlay: Destroy			
	Try Gui, UnitOverlay: Destroy	
	
	; as these arent in the minimap thread, if that call it, it will jump out
	local lOverlayFunctions := "DrawAPMOverlay,DrawIncomeOverlay,DrawUnitOverlay,DrawResourcesOverlay"
				. ",DrawArmySizeOverlay,DrawWorkerOverlay,DrawIdleWorkersOverlay"
	loop, parse, lOverlayFunctions, `,
	{
		; telling the function to destroy itself is more reliable that just using gui destroy
		if IsFunc(A_LoopField)
			%A_LoopField%(-1)
	}
	ReDrawOverlays := ReDrawAPM := ReDrawIncome := ReDrawResources 
				:= ReDrawArmySize := ReDrawWorker := ReDrawIdleWorkers 
				:= RedrawUnit := ReDrawLocalPlayerColour := ReDrawMiniMap := True
	return True ; used by shell to check thread actually ran the function
}

setDrawingQuality(G)
{	static lastG
	if (lastG <> G)		;as setting these each time is slow
	{	lastG := G
		Gdip_SetSmoothingMode(G, 4)
		Gdip_SetCompositingMode(G, 0) ; 0 = blended, 1= overwrite 
	}
}
Draw(G,x,y,l=11,h=11,colour=0x880000ff, Mode=0) ;use mode 3 to draw rectangle then fill it
{	; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
	static pPen, a_pBrushes := []
	if Mode	
	{
		if !pPen
			pPen := Gdip_CreatePen(0xFF000000, 1)
		addtorad := 1/minimap.ratio
		;Gdip_DrawRectangle(G, pPen, (x - l/2), (y - h/2), l, h) 	;Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
		Gdip_DrawRectangle(G, pPen, (x - l/2), (y - h/2), l * addtorad , h * addtorad) 	;Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
	}
	if (Mode = 0) || (Mode = 3)
	{
		if !a_pBrushes[colour]	;faster than creating same colour again 
			a_pBrushes[colour] := Gdip_BrushCreateSolid(colour)
		Gdip_FillRectangle(G, a_pBrushes[colour], (x - l/2), (y - h/2), l, h) ;Gdip_FillRectangle(G, pBrush, x, y, l, h)
	}
}




getUnitMiniMapMousePos(Unit, ByRef  Xvar="", ByRef  Yvar="") ; Note raounded as mouse clicks dont round decimals e.g. 10.9 = 10
{
	global minimap
	uX := getUnitPositionX(Unit), uY := getUnitPositionY(Unit)
	uX -= minimap.MapLeft, uY -= minimap.MapBottom ; correct units position as mapleft/start of map can be >0
	Xvar := round(minimap.ScreenLeft + (uX/minimap.MapPlayableWidth * minimap.Width))
	Yvar := round(minimap.Screenbottom - ( uY/minimap.MapPlayableHeight * minimap.Height))		;think about rounding mouse clicks igornore decimals
	return	
}

mapToMiniMapPos(x, y, ByRef  Xvar="", ByRef  Yvar="") ; Note raounded as mouse clicks dont round decimals e.g. 10.9 = 10
{
	global minimap
	x -= minimap.MapLeft, y -= minimap.MapBottom ; correct units position as mapleft/start of map can be >0
	Xvar := round(minimap.ScreenLeft + (x/minimap.MapPlayableWidth * minimap.Width))
	Yvar := round(minimap.Screenbottom - ( y/minimap.MapPlayableHeight * minimap.Height))		;think about rounding mouse clicks igornore decimals
	return	
}

getMiniMapPos(Unit, ByRef  Xvar="", ByRef  Yvar="") ; unit aray index Number
{
	global minimap
	uX := getUnitPositionX(Unit), uY := getUnitPositionY(Unit)
	uX -= minimap.MapLeft, uY -= minimap.MapBottom ; correct units position as mapleft/start of map can be >0
	Xvar := minimap.ScreenLeft + (uX/minimap.MapPlayableWidth * minimap.Width)
	Yvar := minimap.Screenbottom - ( uY/minimap.MapPlayableHeight * minimap.Height)		;think about rounding mouse clicks igornore decimals
	return	
}
convertCoOrdindatesToMiniMapPos(ByRef  X, ByRef  Y) 
{
	global minimap
	X -= minimap.MapLeft, Y -= minimap.MapBottom ; correct units position as mapleft/start of map can be >0
	, X := round(minimap.ScreenLeft + (X/minimap.MapPlayableWidth * minimap.Width))
	, Y := round(minimap.Screenbottom - (Y/minimap.MapPlayableHeight * minimap.Height))		;think about rounding mouse clicks igornore decimals
	return	
}











/*


	GENERAL FUNCTIONS TO BE PUT IN A LIB

*/


ifTypeInList(type, byref list)
{
	if type in %list%
		return 1
	return 0
}

IniRead(File, Section, Key="", DefaultValue="")
{
	IniRead, Output, %File%, %Section%, %Key%, %DefaultValue%
	Return Output
}


createAlertArray()
{	
	local alert_array := [] ; [1v1, unit#, parameter] - [A_LoopField, "list", "size"] alert_array[A_LoopField, "list", "size"]
	loop, parse, l_GameType, `, ;comma is the separator
	{
		IniRead, BAS_on_%A_LoopField%, %config_file%, Building & Unit Alert %A_LoopField%, enable, 1	;alert system on/off
		alert_array[A_LoopField, "Enabled"] := BAS_on_%A_LoopField% ;this style name, so it matches variable name for update
		loop,	;loop thru the building list sequentialy
		{
			IniRead, temp_name, %config_file%, Building & Unit Alert %A_LoopField%, %A_Index%_name_warning
			if (  temp_name = "ERROR" ) ;ERROR default return
			{
				alert_array[A_LoopField, "list", "size"] := A_Index-1
				break	
			}
			IniRead, temp_DWB, %config_file%, Building & Unit Alert %A_LoopField%, %A_Index%_Dont_Warn_Before_Time, 0 ;get around having blank keys in ini)=
			IniRead, temp_DWA, %config_file%, Building & Unit Alert %A_LoopField%, %A_Index%_Dont_Warn_After_Time, 54000 ;15 hours - get around having blank keys in ini		
			IniRead, Temp_repeat, %config_file%, Building & Unit Alert %A_LoopField%, %A_Index%_repeat_on_new, 0
			IniRead, Temp_IDName, %config_file%, Building & Unit Alert %A_LoopField%, %A_Index%_IDName
			alert_array[A_LoopField, A_Index, "Name"] := temp_name
			alert_array[A_LoopField, A_Index, "DWB"] := temp_DWB
			alert_array[A_LoopField, A_Index, "DWA"] := temp_DWA
			alert_array[A_LoopField, A_Index, "Repeat"] := Temp_repeat
			alert_array[A_LoopField, A_Index, "IDName"] := Temp_IDName
		}
	}
	Return alert_array
}

convertObjectToList(Object, Delimiter="|")
{
	for index, item in Object
		if (A_index = 1)
			List .= item
		else
			List .= "|" item
	return List
}

;note if the object is part of a multidimensional array it still must first be initialised
;eg
;	obj := []
;	obj["Terran", "Units"] := []
;	ConvertListToObject(obj["Terran", "Units"], l_UnitNamesTerran)
ConvertListToObject(byref Object, List, Delimiter="|", ClearObject = 0)
{
	if (!IsObject(object) || ClearObject)
		object := []
	loop, parse, List, %delimiter%
		object.insert(A_LoopField)
	return
}

; This is uesed to exit the program without causing the shutdown routine to be called
; twice. Only used in certain situations. e.g. directly closing a thread
; using the label option causes it to run twice - even when using a timer, or goto/gosub redirect
exitApp(ExitCode := 0)
{
	ExitApp, %ExitCode%
	return 
}


tSpeak(Message, SAPIVol := "", SAPIRate := "")
{	global speech_volume, aThreads

	if !SAPIVol
		SAPIVol := speech_volume

	aThreads.Speech.ahkPostFunction("speak", Message, SAPIVol, SAPIRate)
	return
}


; One of the first functions i ever wrote. Very messy. But it works and im lazy


doUnitDetection(unit, type, owner, mode = "")
{	
	global config_file, alert_array, time, MiniMapWarning, PrevWarning, GameIdentifier, aUnitID, GameType

	static Alert_TimedOut := [], Alerted_Buildings := [], Alerted_Buildings_Base := []
	static l_WarningArrays := "Alert_TimedOut,Alerted_Buildings,Alerted_Buildings_Base"
	time := getTime()
	if (Mode = "Reset")
	{
		Alert_TimedOut := [],, Alerted_Buildings := [], Alerted_Buildings_Base := []
		Iniwrite, 0, %config_file%, Resume Warnings, Resume
		return
	}
	else If (Mode = "Save")
	{

		loop, parse, l_WarningArrays, `,
		{
			For index, Object in %A_loopfield%
			{
				if (A_index <> 1)
					l_AlertShutdown .= ","
				if (A_loopfield = "Alert_TimedOut")
					For PlayerNumber, object2 in Object	;index = player name
						For Alert, warned_base in Object2
							l_AlertShutdown .= PlayerNumber " " Alert " " warned_base
				else
					For PlayerNumber, warned_base in Object	;index = player number
						l_AlertShutdown .= PlayerNumber " " warned_base	;use the space as the separator - not allowed in sc2 battletags	
			}
			Iniwrite, %l_AlertShutdown%, %config_file%, Resume Warnings, %A_loopfield%		
			l_AlertShutdown := ""
		}
		Iniwrite, 1, %config_file%, Resume Warnings, Resume
		return
	}
	Else if (Mode = "Resume")
	{
		Alert_TimedOut := [], Alerted_Buildings := [], Alerted_Buildings_Base := []
		Iniwrite, 0, %config_file%, Resume Warnings, Resume
		loop, parse, l_WarningArrays, `,
		{
			ArrayName := A_loopfield
			%ArrayName% := []
			Iniread, string, %config_file%, Resume Warnings, %ArrayName%, %A_space%
			if string
				loop, parse, string, `,
				{
					StringSplit, VarOut, A_loopfield, %A_Space%
					if (ArrayName = "Alert_TimedOut")
						%ArrayName%[A_index, VarOut1, VarOut2] := VarOut3
					else
						%ArrayName%[A_index, VarOut1] := VarOut2	
				}
		}
		IniDelete, %config_file%, Resume Warnings
		return
	}
	
		;i should really compare the unit type, as theres a chance that the warned unit has died and was replaced with another unit which should be warned
	loop_AlertList:
		loop, % alert_array[GameType, "list", "size"]
		{ 			; the below if statement for time		
			Alert_Index := A_Index	;the alert index number which corresponds to the ini file/config
			if  ( type = aUnitID[alert_array[GameType, A_Index, "IDName"]] ) ;So if its a shrine and the player is not on ur team
			{
				if ( time < alert_array[GameType, A_Index, "DWB"] OR time > alert_array[GameType, A_Index, "DWA"]  ) ; too early/late to warn - add unit to 'warned list'
				{			
					For index, object in Alert_TimedOut	; ;checks if the exact unit is in the time list already (eg if time > dont_warn_before, the original if statement wont be true so BAS_Warning will remain "give warning")			
						if ( unit = object[owner, Alert_Index] ) ;checks if type is in the list already
							continue, loop_AlertList ; dont break, as could be other alerts for same unit but with different times later/lower in list									
					Alert_TimedOut[Alert_TimedOut.maxindex() ? Alert_TimedOut.maxindex()+1 : 1, owner, Alert_Index] := unit
					continue, loop_AlertList
				}
				Else
				{	;during warn time lets check if the unit has already been warned			
					For index, object in Alert_TimedOut	; ;checks if the exact unit is in the time list already (eg if time > dont_warn_before, the original if statement wont be true so BAS_Warning will remain "give warning")			
						if ( unit = object[owner, Alert_Index] ) ;checks if type is in the list already									
								break loop_AlertList

					If  !alert_array[GameType, A_Index, "Repeat"] ;else check if this unit type has already been warned												
						For index, warned_type in Alerted_Buildings ;	if ( type = Alerted_Buildings[index, owner] ) ;checks if type is in the list already						
							if ( Alert_Index = warned_type[owner] ) ;checks if alert index i.e. alert 1,2,3 is in the list already						
								break loop_AlertList			

					For index, warned_unit in Alerted_Buildings_Base  ; this list contains all the exact units which have already been warned				
						if ( unit = warned_unit[owner] ) ;checks if type is in the list already				
							break loop_AlertList ; this warning is for the exact unitbase Address																				
				}	
				PrevWarning := []							
				MiniMapWarning.insert({ "Unit": PrevWarning.unitIndex := unit 
										, "Time": Time
										, "UnitTimer": PrevWarning.UnitTimer := getUnitTimer(unit) 
										, "Type": PrevWarning.Type := type
										, "Owner":  PrevWarning.Owner := owner})
		
				PrevWarning.speech := alert_array[GameType, A_Index, "Name"]
				
				tSpeak(alert_array[GameType, A_Index, "Name"])
				if (!alert_array[GameType, A_Index, "Repeat"])	; =0 these below setup a list like above, but contins the type - to prevent rewarning
					Alerted_Buildings.insert({(owner): Alert_Index})
					;Alerted_Buildings[Alerted_Buildings.maxindex() ? Alerted_Buildings.maxindex()+1 : 1, owner] :=  Alert_Index					
				Alerted_Buildings_Base.insert({(owner): unit})
				;Alerted_Buildings_Base[Alerted_Buildings_Base.maxindex() ? Alerted_Buildings_Base.maxindex()+1 : 1, owner] := unit	; prevents the same exact unit beings warned on next run thru
				break loop_AlertList	
			} ;End of if unit is on list and player not on our team 
		} ; loop, % alert_array[GameType, "list", "size"]
	return
}


announcePreviousUnitWarning()
{
	global
	If PrevWarning
	{
		if (getUnitTimer(PrevWarning.unitIndex) < PrevWarning.UnitTimer
		|| getUnitOwner(PrevWarning.unitIndex) != PrevWarning.Owner
		|| getUnitType(PrevWarning.unitIndex) != PrevWarning.Type)
		{
			tSpeak(PrevWarning.speech " is dead.")
		}
		else 
		{
			tSpeak(PrevWarning.speech)
			MiniMapWarning.insert({ "Unit": PrevWarning.unitIndex
							, "Time":  getTime()
							, "UnitTimer": PrevWarning.UnitTimer
							, "Type": PrevWarning.Type 
							, "Owner":  PrevWarning.Owner})
		}
	}
	Else tSpeak("There have been no alerts")
	return 
}




readConfigFile()
{
	Global 
	;[Version]
	IniRead, read_version, %config_file%, Version, version, 1 ; 1 if cant find value - IE early version
	;[Auto Inject]
	IniRead, auto_inject, %config_file%, Auto Inject, auto_inject_enable, 1
	IniRead, auto_inject_alert, %config_file%, Auto Inject, alert_enable, 1
	IniRead, auto_inject_time, %config_file%, Auto Inject, auto_inject_time, 41
	IniRead, cast_inject_key, %config_file%, Auto Inject, auto_inject_key, F5
	IniRead, Inject_control_group, %config_file%, Auto Inject, control_group, 9
	IniRead, Inject_spawn_larva, %config_file%, Auto Inject, spawn_larva, v
	IniRead, HotkeysZergBurrow, %config_file%, Auto Inject, HotkeysZergBurrow, r
	
	; [MiniMap Inject]
	section := "MiniMap Inject"
	IniRead, MI_Queen_Group, %config_file%, %section%, MI_Queen_Group, 7
	IniRead, MI_QueenDistance, %config_file%, %section%, MI_QueenDistance, 17

		
	;[Manual Inject Timer]
	IniRead, manual_inject_timer, %config_file%, Manual Inject Timer, manual_timer_enable, 0
	IniRead, manual_inject_time, %config_file%, Manual Inject Timer, manual_inject_time, 43
	IniRead, inject_start_key, %config_file%, Manual Inject Timer, start_stop_key, Lwin & RButton
	IniRead, inject_reset_key, %config_file%, Manual Inject Timer, reset_key, Lwin & LButton
	

	IniRead, InjectTimerAdvancedEnable, %config_file%, Manual Inject Timer, InjectTimerAdvancedEnable, 0
	IniRead, InjectTimerAdvancedTime, %config_file%, Manual Inject Timer, InjectTimerAdvancedTime, 43
	IniRead, InjectTimerAdvancedLarvaKey, %config_file%, Manual Inject Timer, InjectTimerAdvancedLarvaKey, e

	

	;[Inject Warning]
	IniRead, W_inject_ding_on, %config_file%, Inject Warning, ding_on, 1
	IniRead, W_inject_speech_on, %config_file%, Inject Warning, speech_on, 0
	IniRead, w_inject_spoken, %config_file%, Inject Warning, w_inject, Inject
	
	;[Forced Inject]
	section := "Forced Inject"
	IniRead, F_Inject_Enable, %config_file%, %section%, F_Inject_Enable, 0
	IniRead, FInjectHatchFrequency, %config_file%, %section%, FInjectHatchFrequency, 2500
	IniRead, FInjectHatchMaxHatches, %config_file%, %section%, FInjectHatchMaxHatches, 10
	IniRead, FInjectAPMProtection, %config_file%, %section%, FInjectAPMProtection, 190
	IniRead, F_InjectOff_Key, %config_file%, %section%, F_InjectOff_Key, Lwin & F5
	
	

	;[Idle AFK Game Pause]
	IniRead, idle_enable, %config_file%, Idle AFK Game Pause, enable, 0
	IniRead, idle_time, %config_file%, Idle AFK Game Pause, idle_time, 15
	IniRead, UserIdle_LoLimit, %config_file%, Idle AFK Game Pause, UserIdle_LoLimit, 3	;sc2 seconds
	IniRead, UserIdle_HiLimit, %config_file%, Idle AFK Game Pause, UserIdle_HiLimit, 10	
	IniRead, chat_text, %config_file%, Idle AFK Game Pause, chat_text, Sorry, please give me 2 minutes. Thanks :)


	;[Starcraft Settings & Keys]
	IniRead, name, %config_file%, Starcraft Settings & Keys, name, YourNameHere
	IniRead, pause_game, %config_file%, Starcraft Settings & Keys, pause_game, {Pause}
	IniRead, base_camera, %config_file%, Starcraft Settings & Keys, base_camera, {Backspace}
	IniRead, NextSubgroupKey, %config_file%, Starcraft Settings & Keys, NextSubgroupKey, {Tab}
	IniRead, escape, %config_file%, Starcraft Settings & Keys, escape, {escape}
	
	;[Backspace Inject Keys]
	section := "Backspace Inject Keys"
	IniRead, BI_create_camera_pos_x, %config_file%, %section%, create_camera_pos_x, +{F6}	
	IniRead, BI_camera_pos_x, %config_file%, %section%, camera_pos_x, {F6}	


	;[Forgotten Gateway/Warpgate Warning]
	section := "Forgotten Gateway/Warpgate Warning"
	IniRead, warpgate_warn_on, %config_file%, %section%, enable, 1
	IniRead, sec_warpgate, %config_file%, %section%, warning_count, 1
	IniRead, delay_warpgate_warn, %config_file%, %section%, initial_time_delay, 10
	IniRead, delay_warpgate_warn_followup, %config_file%, %section%, follow_up_time_delay, 15
	IniRead, w_warpgate, %config_file%, %section%, spoken_warning, "WarpGate"

	; ive just added the forge and stargate here as, the warpages already here
	;[Chrono Boost Gateway/Warpgate]
	section := "Chrono Boost Gateway/Warpgate"
	IniRead, CG_Enable, %config_file%, %section%, enable, 1
	IniRead, Cast_ChronoGate_Key, %config_file%, %section%, Cast_ChronoGate_Key, F5
	IniRead, CG_control_group, %config_file%, %section%, CG_control_group, 9
	IniRead, CG_nexus_Ctrlgroup_key, %config_file%, %section%, CG_nexus_Ctrlgroup_key, 4
	IniRead, chrono_key, %config_file%, %section%, chrono_key, c
	IniRead, CG_chrono_remainder, %config_file%, %section%, CG_chrono_remainder, 2
	IniRead, ChronoBoostSleep, %config_file%, %section%, ChronoBoostSleep, 50
	IniRead, ChronoBoostEnableForge, %config_file%, %section%, ChronoBoostEnableForge, 0
	IniRead, ChronoBoostEnableStargate, %config_file%, %section%, ChronoBoostEnableStargate, 0
	IniRead, ChronoBoostEnableNexus, %config_file%, %section%, ChronoBoostEnableNexus, 0
	IniRead, ChronoBoostEnableRoboticsFacility, %config_file%, %section%, ChronoBoostEnableRoboticsFacility, 0
	IniRead, ChronoBoostEnableCyberneticsCore, %config_file%, %section%, ChronoBoostEnableCyberneticsCore, 0
	IniRead, ChronoBoostEnableTwilightCouncil, %config_file%, %section%, ChronoBoostEnableTwilightCouncil, 0
	IniRead, ChronoBoostEnableTemplarArchives, %config_file%, %section%, ChronoBoostEnableTemplarArchives, 0
	IniRead, ChronoBoostEnableRoboticsBay, %config_file%, %section%, ChronoBoostEnableRoboticsBay, 0
	IniRead, ChronoBoostEnableFleetBeacon, %config_file%, %section%, ChronoBoostEnableFleetBeacon, 0
	IniRead, Cast_ChronoForge_Key, %config_file%, %section%, Cast_ChronoForge_Key, ^F5
	IniRead, Cast_ChronoStargate_Key, %config_file%, %section%, Cast_ChronoStargate_Key, +F5
	IniRead, Cast_ChronoNexus_Key, %config_file%, %section%, Cast_ChronoNexus_Key, >!F5
	IniRead, Cast_ChronoRoboticsFacility_Key, %config_file%, %section%, Cast_ChronoRoboticsFacility_Key, >!F6
	IniRead, CastChrono_CyberneticsCore_key, %config_file%, %section%, CastChrono_CyberneticsCore_key, <!F5
	IniRead, CastChrono_TwilightCouncil_Key, %config_file%, %section%, CastChrono_TwilightCouncil_Key, <!F6
	IniRead, CastChrono_TemplarArchives_Key, %config_file%, %section%, CastChrono_TemplarArchives_Key, <!F1 
	IniRead, CastChrono_RoboticsBay_Key, %config_file%, %section%, CastChrono_RoboticsBay_Key, <!F2
	IniRead, CastChrono_FleetBeacon_Key, %config_file%, %section%, CastChrono_FleetBeacon_Key, <!F3

	;[Advanced Auto Inject Settings]
	IniRead, auto_inject_sleep, %config_file%, Advanced Auto Inject Settings, auto_inject_sleep, 50
	IniRead, Inject_SleepVariance, %config_file%, Advanced Auto Inject Settings, Inject_SleepVariance, 0
	Inject_SleepVariance := 1 + (Inject_SleepVariance/100) ; so turn the variance 30% into 1.3 

	IniRead, CanQueenMultiInject, %config_file%, Advanced Auto Inject Settings, CanQueenMultiInject, 1
	IniRead, Inject_RestoreSelection, %config_file%, Advanced Auto Inject Settings, Inject_RestoreSelection, 1
	IniRead, Inject_RestoreScreenLocation, %config_file%, Advanced Auto Inject Settings, Inject_RestoreScreenLocation, 1
	IniRead, drag_origin, %config_file%, Advanced Auto Inject Settings, drag_origin, Left

	;[Read Opponents Spawn-Races]
	IniRead, race_reading, %config_file%, Read Opponents Spawn-Races, enable, 1
	IniRead, Auto_Read_Races, %config_file%, Read Opponents Spawn-Races, Auto_Read_Races, 1
	IniRead, read_races_key, %config_file%, Read Opponents Spawn-Races, read_key, LWin & F1
	IniRead, race_speech, %config_file%, Read Opponents Spawn-Races, speech, 1
	IniRead, race_clipboard, %config_file%, Read Opponents Spawn-Races, copy_to_clipboard, 0

	;[Worker Production Helper]	
	IniRead, workeron, %config_file%, Worker Production Helper, warning_enable, 1
	IniRead, workerProductionTPIdle, %config_file%, Worker Production Helper, workerProductionTPIdle, 10
	IniRead, workerproduction_time, %config_file%, Worker Production Helper, production_time_lapse, 24
		workerproduction_time_if := workerproduction_time	;this allows to swap the 2nd warning time

	;[Minerals]
	IniRead, mineralon, %config_file%, Minerals, warning_enable, 1
	IniRead, mineraltrigger, %config_file%, Minerals, mineral_trigger, 1000

	;[Gas]
	IniRead, gas_on, %config_file%, Gas, warning_enable, 0
	IniRead, gas_trigger, %config_file%, Gas, gas_trigger, 600


	;[Idle Workers]
	IniRead, idleon, %config_file%, Idle Workers, warning_enable, 1
	IniRead, idletrigger, %config_file%, Idle Workers, idle_trigger, 5

	;[Supply]
	IniRead, supplyon, %config_file%, Supply, warning_enable, 1
	IniRead, minimum_supply, %config_file%, Supply, minimum_supply, 11
	IniRead, supplylower, %config_file%, Supply, supplylower, 40
	IniRead, supplymid, %config_file%, Supply, supplymid, 80
	IniRead, supplyupper, %config_file%, Supply, supplyupper, 120
	IniRead, sub_lowerdelta, %config_file%, Supply, sub_lowerdelta, 4
	IniRead, sub_middelta, %config_file%, Supply, sub_middelta, 5
	IniRead, sub_upperdelta, %config_file%, Supply, sub_upperdelta, 6
	IniRead, above_upperdelta, %config_file%, Supply, above_upperdelta, 8

	;[Additional Warning Count]-----set number of warnings to make
	IniRead, sec_supply, %config_file%, Additional Warning Count, supply, 1
	IniRead, sec_mineral, %config_file%, Additional Warning Count, minerals, 1
	IniRead, sec_gas, %config_file%, Additional Warning Count, gas, 0
	IniRead, sec_workerprod, %config_file%, Additional Warning Count, worker_production, 1
	IniRead, sec_idle, %config_file%, Additional Warning Count, idle_workers, 0
	
	;[Auto Control Group]
	Short_Race_List := "Terr|Prot|Zerg", section := "Auto Control Group", A_UnitGroupSettings := []
	Loop, Parse, l_Races, `, ;Terran ie full name
		while (10 > i := A_index - 1)	
			A_UnitGroupSettings["LimitGroup", A_LoopField, i, "Enabled"] := IniRead(config_file, section, A_LoopField "_LimitGroup_" i, 0)
	loop, parse, Short_Race_List, |
	{			
		If (A_LoopField = "Terr")
			Race := "Terran"
		Else if (A_LoopField = "Prot")
			Race := "Protoss"
		Else If (A_LoopField = "Zerg")
			Race := "Zerg"	

		A_UnitGroupSettings["AutoGroup", Race, "Enabled"] := IniRead(config_file, section, "AG_Enable_" A_LoopField , 0)
	

		loop, 10		;this reads the auto group and removes the final |/, 
		{				;and repalces all | with better looking ,
			String := IniRead(config_file, section, "AG_" A_LoopField A_Index - 1, A_Space)
			StringReplace, String, String, |, `, %a_space%, All ;replace | with , space
			if Instr(String, A_Space A_Space)
				StringReplace, String, String, %A_Space%%A_Space%, %A_Space%, All
			list := ""
			loop, parse, String, `, ; string is a local var/copy in this command
			{
				if aUnitID.HasKey(string := Trim(A_LoopField, "`, `t")) ; get rid of spaces which cause haskey to fail
					list .= string ", "  ; leave a space for the gui
			}
			A_UnitGroupSettings[Race, A_Index - 1] := Trim(list, "`, `t")			
		}

	}
	IniRead, AG_Delay, %config_file%, %section%, AG_Delay, 0
	IniRead, AGBufferDelay, %config_file%, %section%, AGBufferDelay, 50
	IniRead, AGKeyReleaseDelay, %config_file%, %section%, AGKeyReleaseDelay, 60
	IniRead, AGRestrictBufferDelay, %config_file%, %section%, AGRestrictBufferDelay, 90
	
	; hotkeys
	aAGHotkeys := []
	loop 10 
	{
		group := A_index -1
		IniRead, AGAddToGroup%group%, %config_file%, %section%, AGAddToGroup%group%, +%group%
		IniRead, AGSetGroup%group%, %config_file%, %section%, AGSetGroup%group%, ^%group%
		aAGHotkeys["add", group] := AGAddToGroup%group%
		aAGHotkeys["set", group] := AGSetGroup%group%
	}		


	;[ Volume]
	section := "Volume"
	IniRead, speech_volume, %config_file%, %section%, speech, 100
	IniRead, programVolume, %config_file%, %section%, program, 100
	; theres an iniwrite volume in the exit routine

	;[Warnings]-----sets the audio warning
	IniRead, w_supply, %config_file%, Warnings, supply, "Supply"
	IniRead, w_mineral, %config_file%, Warnings, minerals, "Money"
	IniRead, w_gas, %config_file%, Warnings, gas, "Gas"
	IniRead, w_workerprod_T, %config_file%, Warnings, worker_production_T, "Build SCV"
	IniRead, w_workerprod_P, %config_file%, Warnings, worker_production_P, "Build Probe"
	IniRead, w_workerprod_Z, %config_file%, Warnings, worker_production_Z, "Build Drone"
	IniRead, w_idle, %config_file%, Warnings, idle_workers, "Idle"

	;[Additional Warning Delay]
	IniRead, additional_delay_supply, %config_file%, Additional Warning Delay, supply, 10
	IniRead, additional_delay_minerals, %config_file%, Additional Warning Delay, minerals, 10
	IniRead, additional_delay_gas, %config_file%, Additional Warning Delay, gas, 10
	IniRead, additional_delay_worker_production, %config_file%, Additional Warning Delay, worker_production, 25 ;sc2time
	IniRead, additional_idle_workers, %config_file%, Additional Warning Delay, idle_workers, 10


	;[Misc Hotkey]
	IniRead, worker_count_local_key, %config_file%, Misc Hotkey, worker_count_key, F8
	IniRead, worker_count_enemy_key, %config_file%, Misc Hotkey, enemy_worker_count, Lwin & F8
	IniRead, warning_toggle_key, %config_file%, Misc Hotkey, pause_resume_warnings_key, Lwin & Pause
	IniRead, ping_key, %config_file%, Misc Hotkey, ping_map, Lwin & MButton

	;[Misc Settings]
	section := "Misc Settings"
	IniRead, input_method, %config_file%, %section%, input_method, Input
	IniRead, pSendDelay, %config_file%, %section%, pSendDelay, -1
	IniRead, pClickDelay, %config_file%, %section%, pClickDelay, -1
	IniRead, EventKeyDelay, %config_file%, %section%, EventKeyDelay, -1
	IniRead, auto_update, %config_file%, %section%, auto_check_updates, 1
	IniRead, launch_settings, %config_file%, %section%, launch_settings, 0
	IniRead, MaxWindowOnStart, %config_file%, %section%, MaxWindowOnStart, 1
	IniRead, HumanMouse, %config_file%, %section%, HumanMouse, 0
	IniRead, HumanMouseTimeLo, %config_file%, %section%, HumanMouseTimeLo, 70
	IniRead, HumanMouseTimeHi, %config_file%, %section%, HumanMouseTimeHi, 110

	IniRead, UnitDetectionTimer_ms, %config_file%, %section%, UnitDetectionTimer_ms, 3500
	

	IniRead, MTCustomIcon, %config_file%, %section%, MTCustomIcon, %A_Space% ; I.e. False
	IniRead, MTCustomProgramName, %config_file%, %section%, MTCustomProgramName, %A_Space% ; I.e. False
	MTCustomProgramName := Trim(MTCustomProgramName)

	;[Key Blocking]
	section := "Key Blocking"
	IniRead, BlockingStandard, %config_file%, %section%, BlockingStandard, 1
	IniRead, BlockingFunctional, %config_file%, %section%, BlockingFunctional, 1
	IniRead, BlockingNumpad, %config_file%, %section%, BlockingNumpad, 1
	IniRead, BlockingMouseKeys, %config_file%, %section%, BlockingMouseKeys, 1
	IniRead, BlockingMultimedia, %config_file%, %section%, BlockingMultimedia, 1
	IniRead, LwinDisable, %config_file%, %section%, LwinDisable, 1
	IniRead, Key_EmergencyRestart, %config_file%, %section%, Key_EmergencyRestart, <#Space

	aButtons := [] 	; Note I no longer retreive modifier keys in this list as these will always be blocked using ~*prefix
	aButtons.List := getKeyboardAndMouseButtonArray(BlockingStandard*1 + BlockingFunctional*2 + BlockingNumpad*4
																	 + BlockingMouseKeys*8 + BlockingMultimedia*16)	;gets an object contains keys
/*
	;[Auto Mine]
	section := "Auto Mine"
	IniRead, auto_mine, %config_file%, %section%, enable, 0
	IniRead, Auto_Mine_Set_CtrlGroup, %config_file%, %section%, Auto_Mine_Set_CtrlGroup, 1
	IniRead, Auto_mineMakeWorker, %config_file%, %section%, Auto_mineMakeWorker, 1
	IniRead, AutoMineMethod, %config_file%, %section%, AutoMineMethod, Normal
	IniRead, WorkerSplitType, %config_file%, %section%, WorkerSplitType, 3x2
	IniRead, Auto_Mine_Sleep2, %config_file%, %section%, Auto_Mine_Sleep2, 100
	IniRead, AM_PixelColour, %config_file%, %section%, AM_PixelColour, 4286496753
	;this just stores the ARGB colours for the auto mine menu
	Gdip_FromARGB(AM_PixelColour, AM_MiniMap_PixelColourAlpha, AM_MiniMap_PixelColourRed, AM_MiniMap_PixelColourGreen, AM_MinsiMap_PixelColourBlue)
	IniRead, AM_MiniMap_PixelVariance, %config_file%, %section%, AM_MiniMap_PixelVariance, 0
	IniRead, Start_Mine_Time, %config_file%, %section%, Start_Mine_Time, 1
	IniRead, AM_KeyDelay, %config_file%, %section%, AM_KeyDelay, 2
	IniRead, Idle_Worker_Key, %config_file%, %section%, Idle_Worker_Key, {F1}
	IniRead, Gather_Minerals_key, %config_file%, %section%, Gather_Minerals_key, g
*/

	;[Misc Automation]
	section := "AutoWorkerProduction"	
	IniRead, EnableAutoWorkerTerranStart, %config_file%, %section%, EnableAutoWorkerTerranStart, 0 
	IniRead, EnableAutoWorkerProtossStart, %config_file%, %section%, EnableAutoWorkerProtossStart, 0 
	IniRead, ToggleAutoWorkerState_Key, %config_file%, %section%, ToggleAutoWorkerState_Key, #F2
	IniRead, AutoWorkerQueueSupplyBlock, %config_file%, %section%, AutoWorkerQueueSupplyBlock, 1
	IniRead, AutoWorkerAlwaysGroup, %config_file%, %section%, AutoWorkerAlwaysGroup, 1
	IniRead, AutoWorkerAPMProtection, %config_file%, %section%, AutoWorkerAPMProtection, 160
	IniRead, AutoWorkerStorage_T_Key, %config_file%, %section%, AutoWorkerStorage_T_Key, 3
	IniRead, AutoWorkerStorage_P_Key, %config_file%, %section%, AutoWorkerStorage_P_Key, 3
	IniRead, Base_Control_Group_T_Key, %config_file%, %section%, Base_Control_Group_T_Key, 4
	IniRead, Base_Control_Group_P_Key, %config_file%, %section%, Base_Control_Group_P_Key, 4
	IniRead, AutoWorkerMakeWorker_T_Key, %config_file%, %section%, AutoWorkerMakeWorker_T_Key, s
	IniRead, AutoWorkerMakeWorker_P_Key, %config_file%, %section%, AutoWorkerMakeWorker_P_Key, e

	IniRead, AutoWorkerMaxWorkerTerran, %config_file%, %section%, AutoWorkerMaxWorkerTerran, 80
	IniRead, AutoWorkerMaxWorkerPerBaseTerran, %config_file%, %section%, AutoWorkerMaxWorkerPerBaseTerran, 30
	IniRead, AutoWorkerMaxWorkerProtoss, %config_file%, %section%, AutoWorkerMaxWorkerProtoss, 80
	IniRead, AutoWorkerMaxWorkerPerBaseProtoss, %config_file%, %section%, AutoWorkerMaxWorkerPerBaseProtoss, 30

	
	;[Misc Automation]
	section := "Misc Automation"
	IniRead, SelectArmyEnable, %config_file%, %section%, SelectArmyEnable, 0	;enable disable
	IniRead, Sc2SelectArmy_Key, %config_file%, %section%, Sc2SelectArmy_Key, {F2}
	IniRead, castSelectArmy_key, %config_file%, %section%, castSelectArmy_key, F2
	IniRead, SleepSelectArmy, %config_file%, %section%, SleepSelectArmy, 15
	IniRead, ModifierBeepSelectArmy, %config_file%, %section%, ModifierBeepSelectArmy, 1
	IniRead, SelectArmyDeselectXelnaga, %config_file%, %section%, SelectArmyDeselectXelnaga, 1
	IniRead, SelectArmyDeselectPatrolling, %config_file%, %section%, SelectArmyDeselectPatrolling, 1
	IniRead, SelectArmyDeselectHoldPosition, %config_file%, %section%, SelectArmyDeselectHoldPosition, 0
	IniRead, SelectArmyDeselectFollowing, %config_file%, %section%, SelectArmyDeselectFollowing, 0
	IniRead, SelectArmyDeselectLoadedTransport, %config_file%, %section%, SelectArmyDeselectLoadedTransport, 0
	IniRead, SelectArmyDeselectQueuedDrops, %config_file%, %section%, SelectArmyDeselectQueuedDrops, 0
	IniRead, SelectArmyControlGroupEnable, %config_file%, %section%, SelectArmyControlGroupEnable, 0
	IniRead, Sc2SelectArmyCtrlGroup, %config_file%, %section%, Sc2SelectArmyCtrlGroup, 1	
	IniRead, SplitUnitsEnable, %config_file%, %section%, SplitUnitsEnable, 0
	IniRead, castSplitUnit_key, %config_file%, %section%, castSplitUnit_key, F4
	IniRead, SplitctrlgroupStorage_key, %config_file%, %section%, SplitctrlgroupStorage_key, 9
	IniRead, SleepSplitUnits, %config_file%, %section%, SleepSplitUnits, 20
	IniRead, l_DeselectArmy, %config_file%, %section%, l_DeselectArmy, %A_Space%
	IniRead, DeselectSleepTime, %config_file%, %section%, DeselectSleepTime, 0
	IniRead, RemoveUnitEnable, %config_file%, %section%, RemoveUnitEnable, 0
	IniRead, castRemoveUnit_key, %config_file%, %section%, castRemoveUnit_key, +Esc
	IniRead, RemoveDamagedUnitsEnable, %config_file%, %section%, RemoveDamagedUnitsEnable, 0
	IniRead, castRemoveDamagedUnits_key, %config_file%, %section%, castRemoveDamagedUnits_key, !F1
	IniRead, RemoveDamagedUnitsCtrlGroup, %config_file%, %section%, RemoveDamagedUnitsCtrlGroup, 9
	IniRead, RemoveDamagedUnitsHealthLevel, %config_file%, %section%, RemoveDamagedUnitsHealthLevel, 90
	RemoveDamagedUnitsHealthLevel := round(RemoveDamagedUnitsHealthLevel / 100, 3)

	IniRead, EasyUnloadTerranEnable, %config_file%, %section%, EasyUnloadTerranEnable, 0
	IniRead, EasyUnloadProtossEnable, %config_file%, %section%, EasyUnloadProtossEnable, 0
	IniRead, EasyUnloadZergEnable, %config_file%, %section%, EasyUnloadZergEnable, 0
	IniRead, EasyUnloadHotkey, %config_file%, %section%, EasyUnloadHotkey, F5
	IniRead, EasyUnloadQueuedHotkey, %config_file%, %section%, EasyUnloadQueuedHotkey, +F5
	IniRead, EasyUnload_T_Key, %config_file%, %section%, EasyUnload_T_Key, d
	IniRead, EasyUnload_P_Key, %config_file%, %section%, EasyUnload_P_Key, d
	IniRead, EasyUnload_Z_Key, %config_file%, %section%, EasyUnload_Z_Key, d
	IniRead, EasyUnloadStorageKey, %config_file%, %section%, EasyUnloadStorageKey, 9

	;[Alert Location]
	IniRead, Playback_Alert_Key, %config_file%, Alert Location, Playback_Alert_Key, <#F7

	alert_array := [],	alert_array := createAlertArray()
	
	;[Overlays]
	section := "Overlays"
	; This function will get return  the x,y coordinates for the top left, and bottom right of the 
	; desktop screen (the area on both monitors)
	DesktopScreenCoordinates(XminScreen, YminScreen, XmaxScreen, YmaxScreen)
	list := "APMOverlay,IncomeOverlay,ResourcesOverlay,ArmySizeOverlay,WorkerOverlay,IdleWorkersOverlay,UnitOverlay,LocalPlayerColourOverlay,APMOverlay"
	loop, parse, list, `,
	{
		IniRead, Draw%A_LoopField%, %config_file%, %section%, Draw%A_LoopField%, 0
		IniRead, %A_LoopField%Scale, %config_file%, %section%, %A_LoopField%Scale, 1
		if (%A_LoopField%Scale < .5)	;so cant get -scales (or invisibly small)
			%A_LoopField%Scale := .5
		IniRead, %A_LoopField%X, %config_file%, %section%, %A_LoopField%X, % A_ScreenWidth/2
		if (%A_LoopField%X = "" || %A_LoopField%X < XminScreen || %A_LoopField%X > XmaxScreen) ; guard against blank key
			%A_LoopField%X := A_ScreenWidth/2
		IniRead, %A_LoopField%Y, %config_file%, %section%, %A_LoopField%Y, % A_ScreenHeight/2	
		if (%A_LoopField%Y = "" || %A_LoopField%Y < YminScreen || %A_LoopField%Y > YmaxScreen)
			%A_LoopField%Y := A_ScreenHeight/2
	}


;	IniRead, DrawWorkerOverlay, %config_file%, %section%, DrawWorkerOverlay, 1
;	IniRead, DrawIdleWorkersOverlay, %config_file%, %section%, DrawIdleWorkersOverlay, 1

	IniRead, ToggleAPMOverlayKey, %config_file%, %section%, ToggleAPMOverlayKey, <#A
	IniRead, ToggleUnitOverlayKey, %config_file%, %section%, ToggleUnitOverlayKey, <#U
	IniRead, ToggleIdleWorkersOverlayKey, %config_file%, %section%, ToggleIdleWorkersOverlayKey, <#L
	IniRead, ToggleMinimapOverlayKey, %config_file%, %section%, ToggleMinimapOverlayKey, <#H
	IniRead, ToggleIncomeOverlayKey, %config_file%, %section%, ToggleIncomeOverlayKey, <#I
	IniRead, ToggleResourcesOverlayKey, %config_file%, %section%, ToggleResourcesOverlayKey, <#R
	IniRead, ToggleArmySizeOverlayKey, %config_file%, %section%, ToggleArmySizeOverlayKey, <#A
	IniRead, ToggleWorkerOverlayKey, %config_file%, %section%, ToggleWorkerOverlayKey, <#W	
	IniRead, AdjustOverlayKey, %config_file%, %section%, AdjustOverlayKey, Home
	IniRead, ToggleIdentifierKey, %config_file%, %section%, ToggleIdentifierKey, <#Q
	IniRead, CycleOverlayKey, %config_file%, %section%, CycleOverlayKey, <#Enter
	IniRead, OverlayIdent, %config_file%, %section%, OverlayIdent, 2
	IniRead, SplitUnitPanel, %config_file%, %section%, SplitUnitPanel, 1
	IniRead, DrawUnitUpgrades, %config_file%, %section%, DrawUnitUpgrades, 1
	IniRead, unitPanelDrawStructureProgress, %config_file%, %section%, unitPanelDrawStructureProgress, 1
	IniRead, unitPanelDrawUnitProgress, %config_file%, %section%, unitPanelDrawUnitProgress, 1
	IniRead, unitPanelDrawUpgradeProgress, %config_file%, %section%, unitPanelDrawUpgradeProgress, 1
;	IniRead, OverlayBackgrounds, %config_file%, %section%, OverlayBackgrounds, 0
	OverlayBackgrounds := False ; should remove this from 
	IniRead, MiniMapRefresh, %config_file%, %section%, MiniMapRefresh, 300
	IniRead, OverlayRefresh, %config_file%, %section%, OverlayRefresh, 1000
	IniRead, UnitOverlayRefresh, %config_file%, %section%, UnitOverlayRefresh, 4500
	IniRead, APMOverlayMode, %config_file%, %section%, APMOverlayMode, 0
	IniRead, drawLocalPlayerResources, %config_file%, %section%, drawLocalPlayerResources, 0
	IniRead, drawLocalPlayerIncome, %config_file%, %section%, drawLocalPlayerIncome, 0
	IniRead, drawLocalPlayerArmy, %config_file%, %section%, drawLocalPlayerArmy, 0
	
	IniRead, overlayAPMTransparency, %config_file%, %section%, overlayAPMTransparency, 255
	IniRead, overlayIncomeTransparency, %config_file%, %section%, overlayIncomeTransparency, 255
	IniRead, overlayMatchTransparency, %config_file%, %section%, overlayMatchTransparency, 255
	IniRead, overlayResourceTransparency, %config_file%, %section%, overlayResourceTransparency, 255
	IniRead, overlayArmyTransparency, %config_file%, %section%, overlayArmyTransparency, 255
	IniRead, overlayHarvesterTransparency, %config_file%, %section%, overlayHarvesterTransparency, 255
	IniRead, overlayIdleWorkerTransparency, %config_file%, %section%, overlayIdleWorkerTransparency, 255
	IniRead, overlayLocalColourTransparency, %config_file%, %section%, overlayLocalColourTransparency, 255
	IniRead, overlayMinimapTransparency, %config_file%, %section%, overlayMinimapTransparency, 255

	; [UnitPanelFilter]
	section := "UnitPanelFilter"
	aUnitPanelUnits := []	;;array just used to store the smaller lists for each race
	loop, parse, l_Races, `,
	{
		race := A_LoopField,
		IniRead, list, %config_file%, %section%, %race%FilteredCompleted, %A_Space% ;Format FleetBeacon|TwilightCouncil|PhotonCannon	
		aUnitPanelUnits[race, "FilteredCompleted"] := [] ; make it an object
		ConvertListToObject(aUnitPanelUnits[race, "FilteredCompleted"], list)
		IniRead, list, %config_file%, %section%, %race%FilteredUnderConstruction, %A_Space% ;Format FleetBeacon|TwilightCouncil|PhotonCannon	
		aUnitPanelUnits[race, "FilteredUnderConstruction"] := [] ; make it an object
		ConvertListToObject(aUnitPanelUnits[race, "FilteredUnderConstruction"], list)
		list := ""
	}

	;[MiniMap]
	section := "MiniMap" 	
	IniRead, UnitHighlightList1, %config_file%, %section%, UnitHighlightList1, SporeCrawler, SporeCrawlerUprooted, MissileTurret, PhotonCannon, Observer	;the list
	IniRead, UnitHighlightList2, %config_file%, %section%, UnitHighlightList2, DarkTemplar, Changeling, ChangelingZealot, ChangelingMarineShield, ChangelingMarine, ChangelingZerglingWings, ChangelingZergling
	IniRead, UnitHighlightList3, %config_file%, %section%, UnitHighlightList3, %A_Space%
	IniRead, UnitHighlightList4, %config_file%, %section%, UnitHighlightList4, %A_Space%
	IniRead, UnitHighlightList5, %config_file%, %section%, UnitHighlightList5, %A_Space%
	IniRead, UnitHighlightList6, %config_file%, %section%, UnitHighlightList6, %A_Space%
	IniRead, UnitHighlightList7, %config_file%, %section%, UnitHighlightList7, %A_Space%

	IniRead, UnitHighlightList1Colour, %config_file%, %section%, UnitHighlightList1Colour, 0xFFFFFFFF  ;the colour
	IniRead, UnitHighlightList2Colour, %config_file%, %section%, UnitHighlightList2Colour, 0xFFFF00FF 
	IniRead, UnitHighlightList3Colour, %config_file%, %section%, UnitHighlightList3Colour, 0xFF09C7CA 
	IniRead, UnitHighlightList4Colour, %config_file%, %section%, UnitHighlightList4Colour, 0xFFFFFF00
	IniRead, UnitHighlightList5Colour, %config_file%, %section%, UnitHighlightList5Colour, 0xFF00FFFF
	IniRead, UnitHighlightList6Colour, %config_file%, %section%, UnitHighlightList6Colour, 0xFFFFC663
	IniRead, UnitHighlightList7Colour, %config_file%, %section%, UnitHighlightList7Colour, 0xFF21FBFF

	IniRead, HighlightInvisible, %config_file%, %section%, HighlightInvisible, 1
	IniRead, UnitHighlightInvisibleColour, %config_file%, %section%, UnitHighlightInvisibleColour, 0xFFB7FF00

	IniRead, HighlightHallucinations, %config_file%, %section%, HighlightHallucinations, 1
	IniRead, UnitHighlightHallucinationsColour, %config_file%, %section%, UnitHighlightHallucinationsColour, 0xFF808080

	IniRead, UnitHighlightExcludeList, %config_file%, %section%, UnitHighlightExcludeList, CreepTumor, CreepTumorBurrowed
	IniRead, DrawMiniMap, %config_file%, %section%, DrawMiniMap, 1
	IniRead, TempHideMiniMapKey, %config_file%, %section%, TempHideMiniMapKey, !Space
	IniRead, DrawSpawningRaces, %config_file%, %section%, DrawSpawningRaces, 1
	IniRead, DrawAlerts, %config_file%, %section%, DrawAlerts, 1
	IniRead, DrawUnitDestinations, %config_file%, %section%, DrawUnitDestinations, 0
	IniRead, DrawPlayerCameras, %config_file%, %section%, DrawPlayerCameras, 0
	IniRead, HostileColourAssist, %config_file%, %section%, HostileColourAssist, 0
	
	;[Hidden Options]
	section := "Hidden Options"
	IniRead, AutoGroupTimer, %config_file%, %section%, AutoGroupTimer, 30 		; care with this setting this below 20 stops the minimap from drawing properly wasted hours finding this problem!!!!
	IniRead, AutoGroupTimerIdle, %config_file%, %section%, AutoGroupTimerIdle, 5	; have to carefully think about timer priorities and frequency
	
	; Resume Warnings
	Iniread, ResumeWarnings, %config_file%, Resume Warnings, Resume, 0

	; [Misc Info]
	section := "Misc Info"
	IniRead, MT_HasWarnedLanguage, %config_file%, %section%, MT_HasWarnedLanguage, 0
	; RestartMethod is written to in the emergency exit routine
	; it is used in a couple of checks
	IniRead, MT_Restart, %config_file%, %section%, RestartMethod, 0
	if MT_Restart
		IniWrite, 0, %config_file%, %section%, RestartMethod ; set the value back to 0	
	IniRead, MT_DWMwarned, %config_file%, %section%, MT_DWMwarned, 0
	
	if IsFunc(FunctionName := "iniReadQuickSelect") ; function not in minimapthread
		%FunctionName%(aQuickSelectCopy, aQuickSelect)

	; So custom colour highlights are updated
	initialiseBrushColours(aHexColours, a_pBrushes)

	return
}



stripModifiers(pressedKey)
{
    StringReplace, pressedKey, pressedKey, ^ 
	StringReplace, pressedKey, pressedKey, + ;	these are needed in case the hotkey/keyname in key list contains these modifiers
	StringReplace, pressedKey, pressedKey, ! 
	StringReplace, pressedKey, pressedKey, *
	StringReplace, pressedKey, pressedKey, ~
	return pressedKey
}

; This returns -1 when no unit is under the cursor

getCursorUnit()
{
	p1 := readMemory(B_UnitCursor, GameIdentifier)
	p2 := readMemory(p1 + O1_UnitCursor, GameIdentifier)
	if (index := readMemory(p2 + O2_UnitCursor, GameIdentifier))
		return index >> 18
	return -1
}

/*
	Transport Structure (includes bunker too)

	Base = readmemory(getUnitAbilityPointer(unit) + 0x24)
	+ 0x0C Current state, idle (3), load, unload(259)
			Clicking one unit portrait to unload doesn't change it
			shifting clicking two or more does (as does unload all)
	+ 0x20 	Memory Address of the unit in the unit structure
	+ 0x28 	Currently queued/loaded unit count eg 2 marines + hellbat = 3
			This includes units queued up to be loaded.
				E.g. click medivac and shift click onto 4 marines, value = 1 (even though is empty)
				the value remains current cargo + 1 until units begin loading
				select 4 marines and then click onto medivac, value = 4 (even though is empty)
	+ 0x3c 	Total units loaded (accumulative) 4bytes
	+ 0x40 	Total units unloaded
		(current loaded units = their deltas)
	+ 0x44 	UnloadTimer	Counts down to 0 (resets and occurs for each unit being unloaded)

	static aStates := {"loading": 67 ; 3 + 64d/0x40
					, "loading": 35  ; changes just before units begin loading
					, "unloading": 259 ;  3 + 256d	} 

*/

; Returns unit count inside a transport eg 2 marines + hellbat = 3
getCargoCount(unit, byRef isUnloading := "")
{
	transportStructure := readmemory(getUnitAbilityPointer(unit) + 0x24, GameIdentifier)
	totalLoaded := readmemory(transportStructure + 0x3C, GameIdentifier)
	totalUnloaded := readmemory(transportStructure + 0x40, GameIdentifier)
	isUnloading := readmemory(transportStructure + 0x0C, GameIdentifier) = 259 ? 1 : 0
	return totalLoaded - totalUnloaded
}

isTransportUnloading(unit)
{
	transportStructure := readmemory(getUnitAbilityPointer(unit) + 0x24, GameIdentifier)
	return readmemory(transportStructure + 0x0C, GameIdentifier) = 259 ? 1 : 0
}


/*
	There is some other information within the pCurrentModel 
	for example: 
		+ 0x2C 	- Max Hp /4096 (there are two of these next to each other))
		+ 0x34 	- Total armour (unit base armour + armour upgrade) /4096
		+ 0x6C	- Current armour Upgrade
		+ 0xA0  - Total Shields /4096 (there are two of these next to each other)
		+ 0xE0 	- Shield Upgrades
	
*/

getUnitMaxHp(unit)
{   global B_uStructure, S_uStructure, O_uModelPointer
    mp := readMemory(B_uStructure + unit * S_uStructure + O_uModelPointer, GameIdentifier) << 5 & 0xFFFFFFFF
    addressArray := readMemory(mp + 0xC, GameIdentifier, 4)
    pCurrentModel := readMemory(addressArray + 0x4, GameIdentifier, 4) 		
    return round(readMemory(pCurrentModel + 0x2C, GameIdentifier) / 4096)
}

getUnitMaxShield(unit)
{   global B_uStructure, S_uStructure, O_uModelPointer
    mp := readMemory(B_uStructure + unit * S_uStructure + O_uModelPointer, GameIdentifier) << 5 & 0xFFFFFFFF
    addressArray := readMemory(mp + 0xC, GameIdentifier, 4)
    pCurrentModel := readMemory(addressArray + 0x4, GameIdentifier, 4) 		
    return round(readMemory(pCurrentModel + 0xA0, GameIdentifier) / 4096)
}

getUnitCurrentHp(unit)
{
	return getUnitMaxHp(unit) - getUnitHpDamage(unit)
}
; returns 1 if something goes wrong and reads 0
getUnitPercentHP(unit)
{
	return (!percent := ((maxHP := getUnitMaxHp(unit)) - getUnitHpDamage(unit)) / maxHP) ? 1 : percent
}

getUnitPercentShield(unit)
{
	return ((maxShield := getUnitMaxShield(unit)) - getUnitShieldDamage(unit)) / maxShield
}
; will be 0 for units which dont have shields
getUnitCurrentShields(unit)
{
	return getUnitMaxShield(unit) - getUnitShieldDamage(unit)
}

getCurrentHpAndShields(unit, byRef result)
{
	global B_uStructure, S_uStructure, O_uModelPointer
    result := []
    mp := readMemory(B_uStructure + unit * S_uStructure + O_uModelPointer, GameIdentifier) << 5 & 0xFFFFFFFF
    addressArray := readMemory(mp + 0xC, GameIdentifier, 4)
    pCurrentModel := readMemory(addressArray + 0x4, GameIdentifier, 4) 		
    result.health := round(readMemory(pCurrentModel + 0x2C, GameIdentifier) / 4096) - getUnitHpDamage(unit)
    result.shields :=  round(readMemory(pCurrentModel + 0xA0, GameIdentifier) / 4096) - getUnitShieldDamage(unit)
    result.unitIndex := unit 
    return
}