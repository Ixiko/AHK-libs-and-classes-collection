#include <mkex>
#if guiex.tabHelp.focused(guiex.tabHelp.loops) && not mkex.inKW
#if
detectHiddenWindows 1

class guiex{
	align(byRef changing, reference, xywh, alignment := .5){ ;aligns one control with another
		if xywh = 'x' or xywh = 'y'{
			wh := xywh = 'x' ? 'w' : 'h'
			changing.move xywh round((reference.pos)[xywh] + (reference.pos)[wh] * alignment - (changing.pos)[wh] * alignment)
		}else{
			xy := xywh = 'w' ? 'x' : 'y'
			changing.move xywh round((reference.pos)[xy] + (reference.pos)[xywh] * alignment - (changing.pos)[xy])
			}
		}
	backMove(byRef gui, winTitle := '' , winText := '', excludeTitle := '', exludeText := ''){ ;makes the non-interactable client aera able to move the window via click and drag
		gui.addText(format('x{} y{} w{} h{} backgroundTrans', 0, 0, gui.clientPos.w, gui.clientPos.h)).onEvent('click', ()=> postMessage('0xA1', 2))
		}
	hkGroup(byRef gui, text, names, limits := '', positioning := '', hkBoxWidth := '', xPadding := 'm', yPadding := 'm'){ ;creates a group of hotkey boxes with text to the left explaining what they're for
		global
		static hkGroup_c := 1
		if limits{ ;sets up the hotkey limits
			if not isObject(limits)
				local limNum := limits
				limits := []
				loop text.length()
					limits.push(limNum)
		}else{
			limits := []
			loop text.length()
				limits.push(0)
			}
		textName(k) => 'hkGroup' hkGroup_c '_text1' k
		gui.addText(format('v{} {} right section', textName(1), positioning), text[1] ':')
		local k, v
		for k, v in text
			if k >= 2
				gui.addText(format('v{} right', textName(k)), v ':')
		if hkBoxWidth
			hkBoxWidth := "w" hkBoxWidth
		gui.addHotkey(format("v{} x+{} ys {} limit{}", names[1], xPadding, hkBoxWidth, limits[1]), %names[1]%)
		for k, v in names
			if k >= 2
				gui.addHotkey(format("v{} y+{} {} limit{}", v, yPadding, hkBoxWidth, limits[k]), %v%)
		local maxTextWidth := 0
		for k, v in text{ ;gets info for positioning{
			local w := gui.control[textName(k)].pos.w
			if w > maxTextWidth
				maxTextWidth := w
			}		
		if xPadding = 'm'
			xPadding := gui.marginX
		for k, v in names{ ;positions controls
			local hk := gui.control[v]
			local textCont := gui.control[textName(k)]
			textCont.move(format('w{} y{}', maxTextWidth, hk.pos.y + round((hk.pos.h - textCont.pos.h) / 2)))
			if hk.pos.x - (textCont.pos.x + maxTextWidth) != xPadding
				hk.move('x' textCont.pos.x + maxTextWidth + xPadding)
			}
		local hk1 := gui.control[names[1]].pos
		local hkLast := gui.control[names[names.length()]].pos
		local x1 := gui.control[textName(1)].pos.x
		local y1 := hk1.y
		local x2 := x1 + maxTextWidth + xPadding + hk1.w
		local y2 := hkLast.y + hkLast.h
		gui.addText(format('v{} x{} y{} w{} h{} hidden', 'hkGroup' hkGroup_c '_boundry', x1, y1, x2 - x1, y2 - y1))
		hkGroup_c++
		}
	/*keyWait(options := "", waitText := "waiting...", guiName := "") ;makes a button that when pressed waits for a key to be pressed, similar to a hotkey but can use more keys and only takes in one key
		{
		global
		static c := 0
		local var, var1
		regExMatch(options, "i)v(\S+)", var)
		if(var1)
			guiex.kwHelp.text[var1] := waitText	
		else
			{
			local vLabel := "vkeyWait" ++c
			guiex.kwHelp.text["keyWait" c] := waitText
			}
		if(guiName)
			guiName .= ":"
		gui, %guiName%add, button, % vLabel " gguiex.kwHelp.getKey " options , % waitText ;if vLable is empty, the assigned variable is in the options
		if(%var1%)
			guiControl, %guiName%text, % var1, % %var1%
		else
			guiControl, %guiName%text, % var1
		}
	class kwHelp ;support for keyWait
		{
		static text := {}
		static currentKW
		static inTimer
		getKey()
			{
			if(guiex.kwHelp.inTimer)
				{
				guiName := guiex.kwHelp.currentKW.guiName ":"
				guiControl, %guiName%text, % guiex.kwHelp.currentKW.id
				guiex.kwHelp.inTimer := false
				}
			guiControl, text, % a_guiControl ;, % guiex.kwHelp.text[a_guiControl]
			%a_guiControl% := ;Has to be here because if you close a window in the middle of a mkex keyWait the variable won't update
			t := guiex.kwHelp.waitingTimer.bind(kwHelp)
			guiex.kwHelp.currentKW := {id: a_guiControl, guiName: a_gui, text: guiex.kwHelp.text[a_guiControl]}
			setTimer, % t, 1400
			;guiex.kwHelp.waitingTimer()
			if(%a_guiControl% := mkex.keyWait())
				{
				setTimer, % t, delete
				guiControl, text, % a_guiControl, % %a_guiControl%
				}
			else
				{
				setTimer, % t, delete
				guiControl, text, % a_guiControl
				}
			}
		waitingTimer()
			{
			guiex.kwHelp.inTimer := true
			guiName := guiex.kwHelp.currentKW.guiName ":"
			guiControl, %guiName%text, % guiex.kwHelp.currentKW.id, % guiex.kwHelp.currentKW.text
			t := a_tickCount
			while a_tickCount - t < 700 and a_timeIdleKeyboard >= 500 and mkex.inKW
				{}
			guiControl, %guiName%text, % guiex.kwHelp.currentKW.id
			guiex.kwHelp.inTimer := false
			}
			
		}
	kwGroup(kws, vars, waitText := "waiting...", positioning := "", kwBoxWidth := "", xPadding := "m", yPadding := "m", guiName := "") ;creates a group of keyWait buttons with text to the left explaining what they're for
		{
		local firstVarStr := vars[1]
		local lastVarStr := vars[vars.length()]
		static c := 1
		if(kwBoxWidth)
			kwBoxWidth := "w" kwBoxWidth
		if(guiName)
			guiName .= ":"
		gui, %guiName%add, text, % format("v{} {} right section", "kwGroup" c "_text1", positioning), % kws[1] ":"
		local k, v
		for k, v in kws
			if(k >= 2)
				gui, %guiName%add, text, % format("v{} right", "kwGroup" c "_text" k), % v ":"
		guiex.keyWait(format("v{} x+{} ys {}", vars[1], xPadding, kwBoxWidth), waitText, guiName)
		for k, v in vars
			if(k >= 2)
				guiex.keyWait(format("v{} y+{} {} limit{}", v, yPadding, kwBoxWidth), waitText, guiName)
		local maxTextWidth := 0
		for k, v in vars ;gets info for positioning
			{
			guiControlGet, %v%, %guiName%pos
			guiControlGet, kwGroup%c%_text%k%, %guiName%pos
			if(kwGroup%c%_text%k%W > maxTextWidth)
				maxTextWidth := kwGroup%c%_text%k%W
			}
		local l := kws.length()
		local m
		if(xPadding = "m")
			m := %lastVarStr%X - (kwGroup%c%_text%l%X + kwGroup%c%_text%l%W)
		else
			m := xPadding
		for k, v in vars ;positions the controls
			{
			guiControl, %guiName%move, kwGroup%c%_text%k%, % format("w{} y{}", maxTextWidth, %v%Y + round((%v%H - kwGroup%c%_text%k%H) / 2))
			if(%v%X - (kwGroup%c%_text%k%X + maxTextWidth) != m)
				guiControl, %guiName%move, %v%, % "x" kwGroup%c%_text%k%X + maxTextWidth + m
			}
		local x1 := kwGroup%c%_text1X
		local y1 := %firstVarStr%Y
		local x2 := kwGroup%c%_text1X + maxTextWidth + m + %firstVarStr%W
		local y2 := %lastVarStr%Y + %lastVarStr%H
		gui, %guiName%add, text, % format("x{} y{} w{} h{} hidden", x1, y1, x2 - x1, y2 - y1)
		c++
		;gui, %guiName%show, hide autoSize
		}*/
	setCursor(guiOrCont, cursor, options := 'n l r m'){
		static cursors := {
			appstarting: 32650,
			arrow: 32512,
			cross: 32515,
			hand: 32649,
			help: 32651,
			ibeam: 32513,
			no: 32648,
			sizeall: 32646,
			sizenesw: 32643,
			sizens: 32645,
			sizenwse: 32642,
			sizewe: 32644,
			uparrow: 32516,
			wait: 32514,
			hide: 0,
			}
		changeCurs(cursor2){
			dllCall 'SetCursor', 'int', dllCall(
				'LoadImageW',
				'int', 0,
				'int', cursors[cursor2],
				'int', 2,
				'int', 0,
				'int', 0,
				'int', 0x8000)
			}
		curCheckMove(wParam){
			static guiObjs := {}
			if not guiObjs[guiOrCont]
				guiObjs[guiOrCont] := {}
			downFlags := guiObjs[guiOrCont]
			if gFlagL
				downFlags.lDown := cursor
			if gFlagR
				downFlags.rDown := cursor
			if gFlagM
				downFlags.mDown := cursor
			mouseGetPos ,, win, cont
			if type(guiOrCont) != 'gui' and win = guiOrCont.gui.hwnd and cont = guiOrCont.classNN
			or type(guiOrCont) = 'gui' and win = guiOrCont.hwnd and not cont{
				if downFlags.lDown and wParam = 1
					changeCurs(downFlags.lDown)
				else if downFlags.rDown and wParam = 2
					changeCurs(downFlags.rDown)
				else if downFlags.mDown and wParam = 0x10
					changeCurs(downFlags.mDown)
				else if nFlag
					changeCurs(cursor)
				}
			}
		curCheckClick(){
			mouseGetPos ,, win, cont
			if type(guiOrCont) != 'gui' and win = guiOrCont.gui.hwnd and cont = guiOrCont.classNN
			or type(guiOrCont) = 'gui' and win = guiOrCont.hwnd and not cont
				changeCurs(cursor)
			}
		if options ~= 'i)n'
			nFlag := 1		
		local gFlagL, gFlagR, gFlagM
		flags := {l: 0, r: 3, m: 6}
		for flag, offset in flags
			if options ~= 'i)' flag{
				regExMatch(options, flag '(\S+)', subOptions)
				if not subOptions
					loop 3
						onMessage 0x200 + offset + a_index, 'curCheckClick'
				else{
					if subOptions.1 ~= 'i)d'
						onMessage 0x201 + offset, 'curCheckClick'
					if subOptions.1 ~= 'i)g'{
						gFlag%flag% := 1
						}
					if subOptions.1 ~= 'i)u'
						onMessage 0x202 + offset, 'curCheckClick'
					if subOptions.1 ~= '2'
						onMessage 0x203 + offset, 'curCheckClick'
					}
				}			
		onMessage 0x200, 'curCheckMove'
		}
	/*tab(T)
		{
		for guiName, tabLoops in T
			{
			guiex.tabHelp.loops[guiName] := {}
			for k, tabLoop in tabLoops
				guiex.tabHelp.loops[guiName].push(tabLoop)
			}	
		next := guiex.tabHelp.next.bind(guiex.tabHelp)
		hotkey, if, guiex.tabHelp.focused(guiex.tabHelp.loops) && not mkex.inKW
		hotkey, tab, % next
		hotkey, +tab, % next
		hotkey, if
		}
	class tabHelp
		{
		static loops := {}
		static c := 0
		focused(T)
			{
			for guiName, tabLoops in T
				{
				guiControlget, control, %guiName%:focusV
				for k, tabLoop in tabLoops
					for j, cont in tabLoop
						if(control = cont)
							return {guiName: guiName
								,loop: tabLoop
								,spot: j}
				}
			}
		next(control := "")
			{
			if(not control)
				control := guiex.tabHelp.focused(guiex.tabHelp.loops)
			if(not a_thisHotkey ~= "\+")
				nextSpot := control.spot = control.loop.length() ? 1 : control.spot + 1
			else
				nextSpot := control.spot = 1 ? control.loop.length() : control.spot - 1
			guiName := control.guiName
			guiControlGet, visible, %guiName%:visible, % control.loop[nextSpot]
			guicontrolGet, enabled, %guiName%:enabled, % control.loop[nextSpot]
			if(visible and enabled)
				{
				guiControl, %guiName%:focus, % control.loop[nextSpot]
				try guiControl, %guiName%:+default, % control.loop[nextSpot]
				}
			else
				guiex.tabHelp.next({guiName: guiName
					,loop: control.loop
					,spot: nextSpot})
			}
		}*/
	}