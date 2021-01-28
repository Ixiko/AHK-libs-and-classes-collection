; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

#NoEnv
#SingleInstance force
#persistent
#Include ieCOM.ahk ;https://autohotkey.com/boards/viewtopic.php?f=6&t=19300

script= 
(
	function MoveLogo() {
		var elem = document.getElementById("ahk_logo"); 
		var pos = 0;
		var id = setInterval(moveright, 5);
		
		function moveright() {
			if (pos == 350) {
				clearInterval(id);
				id = setInterval(moveleft, 5);
			} else {
				pos++; 
				elem.style.left = pos + 'px'; 
			}
		}
		function moveleft() {
			if (pos == -350) {
				clearInterval(id);
				id = setInterval(moveright, 5);
			} else {
				pos--; 
				elem.style.left = pos + 'px'; 
			}
		}
	}
)

nav("http://autohotkey.com/boards/")
rs()
logo := d.getElementById("logo").getelementsbytagname("img")[0]
logo.id := "ahk_logo"
logo.style.position := "relative"
jsappend(script)
js("MoveLogo();")

DocWait()

;Spreadsheet Table settings
MyTableID:="MyTableID"
rows := 31
cols := 27
Height := 300 

gosub, css

;create <div id='ahk'>
div := d.createElement("div")
div.setAttribute("id", "ahk")
div.setAttribute("style","height:" Height "px;overflow:scroll;")
d.queryselectorall(".navbar.nav-breadcrumbs")[0].appendChild(div)

;Create a html table element child of <div id='ahk'>
;set the id as "MyTableID"
createTable(d.getElementByID("ahk"),MyTableID,rows,cols)


;store each <td> element in an array
myarray := table2array(MyTableID)

;change the InnerHTML of our first <td> element
myarray[0,0].InnerHTML := "#"
myarray[0,0].SetAttribute("class", "head")

;array of column headers
headers := ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

;loop rows
loop, % rows
{
	;A_Index starts from a value of 1
	;write our row numbers
	myarray[A_Index,0].InnerHTML := A_Index
	myarray[A_Index,0].SetAttribute("class", "head")
	
	;store our current row
	row := A_Index
	
	;loop  columns
	loop, % cols
	{
		if (row == 1) {
			;write our column headers
			myarray[0,A_Index].InnerHTML := headers[A_Index]
			myarray[0,A_Index].SetAttribute("class", "head")
		}
		
		;store the current cell reference 
		cell := headers[A_Index] . row
				
		;write an input box with an id of the cell reference
		myarray[row, A_Index].InnerHTML:= "<input id='" cell "' value='' size='5' >"
		
		;Create script cell refrence variables
		Cell_%cell% := myarray[row, A_Index].FirstChild
		
	}
}

;check the browser is ready & update the script variables
DocWait()

;++++++++++++++++++++++++++++++++

;write new values to cell ref
Cell_A1.Value := 5
Cell_B1.Value := 6

;math
Cell_C1.Value := Cell_A1.Value * Cell_B1.Value

;++++++++++++++++++++++++++++++++

;Create cell references by html id's 
B2 := d.getElementByID("B2")
C2 := d.getElementByID("C2")
D2 := d.getElementByID("D2")

;write new values to cell ref
B2.Value := 5
C2.Value := 6

;math
D2.Value := B2.Value * C2.Value

;++++++++++++++++++++++++++++++++

;Create cell references by array
B4 := myarray[4,2].FirstChild
C4 := myarray[4,3].FirstChild
D4 := myarray[4,4].FirstChild

;write new values to cell ref
B4.Value := 4
C4.Value := 9

;math
D4.Value := B4.Value * C4.Value

return



css:
;css table style
css=
(
	
	#%MyTableID% {border: 1px solid black; border-collapse: collapse;}
	
	#%MyTableID% tr:nth-child(even) {background-color: #f2f2f2}
	
	#%MyTableID% td.head {border: 1px solid black; background-color: #f1f1f1;}
	#%MyTableID% td.head:hover {border: 1px solid black; background-color: #f1f1f1;}
	
	#%MyTableID% td {border: 1px solid black; background-color: #ffffff;}
	#%MyTableID% td:hover {border: 1px solid red; background-color: lightblue;}
	
	#%MyTableID% input {background: transparent;border: none;}
)
;apply css rules
s := d.createElement("style")
s.appendChild(d.createTextNode(css))
d.head.appendChild(s)
return


GuiClose:
quit:
ESC::
try wb.quit()
ExitApp
return

`::Reload
