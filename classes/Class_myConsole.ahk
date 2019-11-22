myConsole 			:= new scConsole({"Control Width": 800, "Control Height": 300})
;==========================================================================================================================
myConsole.addItem("scConsole: [italic 0x00FF00]Thank you for using my software.[/]")
myConsole.addItem("scConsole: [red]Current Script file:[/] [bold]" A_ScriptFullPath "[/]")
myConsole.addItem("scConsole [background0xFFFFFF 0xAA0000]has the ability to colour the output from the cmd window thanks to [bold underline]RegEx![/][/]")
myConsole.addItem("scConsole also has universal RegEx coloring. Thank you RegEx! By default, all words 'scConsole' are colored yellow.")
myConsole.addItem("You can also easily change the color of these texts. With something like [red]Red Text Here.[/ ]")
myConsole.addItem("[red]Without the space in the [/ ] it looks like this.[/]")
myConsole.cmdCommand("ipconfig", 1, ["(IPv4 Address.*)", "[red]$1[/]"], ["(Default Gateway.*)","[yellow]$1[/]"], ["(Subnet Mask.*)", "[green]$1[/]"])
myConsole.addItem("[green]Starting File scann[/]")
myConsole.addItem("[green]Files Found:[/]", 1)
currentLine				:= myConsole.currentLine
Loop, C:\*.*,, 1
{
	myConsole.changeLine("[red]Files Found[/]:		" A_Index, currentLine )
}
;==========================================================================================================================

class scConsole
{
	__New( optionsArray="", RegExColor* ){	
		static msHTML
		o 					:= optionsArray
		this.guiW 			:= o["Control Width"] ? o["Control Width"] : 500
		this.guiH			:= o["Control Height"] ? o["Control Height"] : 500
		this.guiC 			:= o["Gui Color"] ? o["Gui Color"] : "000"
		this.guiNumber 		:= o["Gui Number"] ? o["Gui Number"] : 1
		this.numC 			:= o["Line Number Color"] ? o["Line Number Color"] : "aqua"
		this.guiF 			:= o["Font"] ? o["Font"] : "Consolas"
		this.guiX				:= o["PosX"] ? o["PosX"] : "p"
		this.guiY				:= o["PosY"] ? o["PosY"] : "p"
		this.regexColorData := RegExColor[1] ? RegExColor : [["(scConsole)","[yellow]$1[/]"]]
		this.mshtml			:=msHTML
		guiN					:= this.guiNumber
		guiW 				:= this.guiW
		guiH 				:= this.guiH
		guiC 				:= this.guiC
		guiF 				:= this.guiF
		guiX					:= this.guiX
		guiY					:= this.guiY
		
		;Gui, %guiN%:+ToolWindow -caption +border +OwnerMain
		;Gui, %guiN%: Add, ActiveX, w%guiW% h%guiH% vmsHTML x0 y0 +HScroll, MSHTML:
		Gui, %guiN%: Add, ActiveX, HwndHwnd x%guiX% y%guiY% w%guiW% h%guiH% vmsHTML hwndhwnd +HScroll, MSHTML:
		this.hwnd:=hwnd
		htmlData 			=
		(	<DOCTYPE !HTML>
			<html><head>
				<style type="text/css">
				body { background-color: #%guiC%; }
				body * { border: 0px; padding: 0px; margin: 0px; }
				p { color: #FFF; font-family: %guiF%; font-size: 12px; } .num { color: #33A; padding: 0px; margin: 0px; }
				.num { padding-right: 30px; } .padLeft { padding-left: 30px; } .padRight { padding-right: 30px; }
				.red { color: #D00; } .blue { color: #00D; } .green { color: #0D0; }
				.grey { color: #AAA; } .aqua { color: #0DD; } .yellow { color: #DD0; }
				.bred { background-color: #D00; } .bblue { background-color: #00D; } .bgreen { background-color: #0D0; }
				.bgrey { background-color: #AAA; } .baqua { background-color: #0DD; } .byellow { background-color: #DD0; }
				
				.big { font-size: 18px } .small { font-size: 8px; } .med { font-size: 12px; } .huge { font-size: 24px; }
				.underline { text-decoration: underline; } .bold { font-weight: bold; } .italic { font-style: italic; }
				</style>
				</head>
				
			<body>
				<div id="console">
				</div>
			</body>
			</html>
		)
		msHTML.write( htmlData )
		msHTML.close()
		this.currentLine 	:= 0
		this.var 			:= msHTML
		Gui, %guiN%: Show, Hide w%guiW% h%guiH%
		return this
	}
	addItem( data, scroll=0, reformatThis* ){
		lineNC				:= this.numC
		if this.currentline>8
			this.currentLine 	:= this.currentLine + 1
		Else
			this.currentLine 	:= "0" this.currentLine + 1
		for key, val in reformatThis
			data 			:= RegExReplace( data, val[1], val[2] )
		data 		:= this.colorData( data )
		element 				:= this.var.createElement("p")
		;element.innerHtml		:= "<span class=""num " lineNC """>" this.currentLine ".</span>" data
		element.innerHtml		:= "<span class=""num " lineNC """>" A_Hour ":" A_Min "." A_Sec "</span>" data
		element.Id 				:= this.currentLine
		if scroll
			this.var.getElementById("console").appendChild( element ).scrollIntoView( true )
		else
			this.var.getElementById("console").appendChild( element )
	}
	cmdCommand( command, scroll=0, reformatThis* ){
		RunWait, %ComSpec% /c %command% > temp.file,, Hide
		FileRead, data, temp.file
		FileDelete, temp.file
		for key, val in reformatThis
			data 			:= RegExReplace( data, val[1], val[2] )
		Loop, parse, data, `n
			this.addItem( A_LoopField, scroll)
	}
	changeLine( data, lineNum ){
		
		for key, val in reformatThis
			data 			:= RegExReplace( data, val[1], val[2] )
		
		data 		:= this.colorData( data )
		;newData		:= "<span class=""num " this.numC """>" lineNum ".</span>" data
		newData		:= "<span class=""num " this.numC """>" A_Hour ":" A_Min "." A_Sec "</span>" data
		
		this.var.getElementById( lineNum ).innerHtml 			:= newData
	}
	clear(){
		this.var.getElementById("console").innerHtml 			:= ""
		this.currentLine 			:= 0
	}
	addSeperator(){
		element 				:= this.var.createElement("p")
		element.style.width 	:= this.guiW - 50
		element.Id 				:= "sep"
		this.var.getElementById("console").appendChild( element )
	}
	colorData( data ){
		for key, val in this.regexColorData
			data 			:= RegExReplace( data, val[1], val[2] )
		
		while ( inStr( data, "[/]" ) || A_Index != 100 )
			data 		:= RegExReplace( data, "\[(.*?)\](.*?)\[/[^\s]?\]", "<span class=""$1"">$2</span>" )
		
		data 		:= RegExReplace( data, "(class="".*?)background0x(.{6})(.*?"")(.*?)", "$1$3 style=""background-color: #$2;""$4")
		data 		:= RegExReplace( data, "(class="".*?)0x(.{6})(.*?"")(.*?)", "$1$3 style=""color: #$2;""$4")
		
		return data
	}
	Hide(){
		GuiNumber:=this.guiNumber
		Gui,%GuiNumber%:Show,Hide
	}
	Show(){
		GuiNumber:=this.guiNumber
		Gui,%GuiNumber%:Show
	}
	Resize(width,height){
		GuiControl,% this.guinumber ": Move",% this.hwnd, % "w" width " h" height-this.guiy
	}
}