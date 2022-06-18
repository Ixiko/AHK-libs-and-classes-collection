/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;Sign PDF;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	actually I place sign as stamp so I made it sign pdf.. yah yah I know it should be stamp pdf
	
	rectangle
	when you enable acrobat edit mode and try to edit text you see text in rectangle
	
	
	`rect` has rectangle coordinates of text 
	rect.left
	rect.top
	rect.right
	rect.bottom
	
	`l` `t` `r` `b` are the rectangle coordinate of stamp
	left 
	top
	bottom 
	right
	
	sizing stamp may confuse you so here is the trick
	Manupulating with `left` and `top` will defines intitial point of stamp like x1 and y1
	Changing `bottom` and `right` defines how big or small stamp should be compare to text rectangle
	
;;;;;;;;;;;;;Dynamic PDF Stamps (DPS);;;;;;;;;;;;
	
	
	How to Create a custom dynamic stamp using Acrobat DC
	https://helpx.adobe.com/acrobat/using/adding-stamp-pdf.html
	
	following link describes how to extract Custom DPS AP i.e my custom DPS AP is "#DqYJkNdha_RxWUIh-SVFVD"
	https://acrobatusers.com/tutorials/print/dynamic_stamp_secrets/
	
	OR if you know acroba console 
	
	1 . manually sign pdf using acrobat (or create custom stamp then sign)
	2 . while stamp is selected
	3 . open acrobat console called JavaScriptdebugger (tool >> Java Script >> JavaScriptdebugger)
	4 . put the code `this.selectedAnnots[0].AP` into the console
	5 . Press enter to go for next line AP will appear ; (take care cursor should be at the end of line) 
	
	; 
	; AP: "NotApproved"
	
	
*/

signpdf(rect,pagenum, l=0, t=0, r=50, b=50)
{
	left := rect.left + l
	top := rect.top + t
	right := rect.right + r
	bottom := rect.bottom - b
	stamp1script =
(
var annot = this.addAnnot({
	page: %pagenum%,
	type: "Stamp",
	author: "Yaseen",
	name: "Yaseen",
	rect: [%left%, %top%, %right%, %bottom%],
	contents: "",
	AP: "Approved"
	});
)
	
	CustomStamp2script =
(
var annot = this.addAnnot({
	page: %pagenum%,
	type: "Stamp",
	author: "Yaseen",
	name: "Yaseen",
	rect: [%left%, %top%, %right%, %bottom%],
	contents: "",
	AP: "#DqYJkNdha_RxWUIh-SVFVD"
	});
)
	AForm := ComObjCreate("AFormAut.App")
	;msgbox, % stampscript
	AForm.Fields.ExecuteThisJavaScript(stamp1script) ; default stamp
}


/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;;;;;;;;;;;;;PDFtext;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	extracting text coordinates though Acrobat COM was way complicated than I imagine but in the end I found out who it works,
	
	There are 2 rules...
	1 . Text does not have rectangular coordinates 
	2 . Text selection has rectangular coordinates 
	
	so if I understand how to select required text then I got the coordinates 
	
	I read the whole idiotic API from "Acrobat Exchange COM API with QTP.pdf" which I do not remember from where It was downloaded
	
	how it works
	
	1 . find text on page if found the proceed further
	2 . get total word from `.getPageNumWords`
	3 . check text one by one `.objJSO.getPageNthWord(pagenumber, a_index)` amazingly its very very fast do not know why
	4 . select text with `.SetTextSelection(` and I didn't know it was whole and different com object `"AcroExch.HiliteList"` 
	5 . get selection coordniates by `.GetBoundingRect`
	
*/


PDFtext(Inputfile,TextToFind)
{
	objAcroApp := ComObjCreate("AcroExch.App")
	;objAcroApp.Show()
	objAcroAVDoc := ComObjCreate("AcroExch.AVDoc")
	objAcroAVDoc.Open(Inputfile, "")
	
	objAcroAVDoc.BringToFront()
	objAcroAVDoc.Maximize( True )
	objAcroPDDoc := objAcroAVDoc.GetPDDoc
	
	objJSO := objAcroPDDoc.GetJSObject
	i := objAcroAVDoc.FindText(TextToFind, 1, 0, 1)
	if i
	{
		loop, % objAcroPDDoc.GetNumPages()
		{
			pagenumber := a_index - 1
			acroPageView := objAcroAVDoc.GetAVPageView()
			acroPageView.Goto( pagenumber )
			acroHiList := ComObjCreate("AcroExch.HiliteList")
			acroHiList.Add( 0, 32767 ) 
			acroPDPage := acroPageView.GetPage()
			acroPDTextSel := acroPDPage.CreateWordHilite( acroHiList ) 
			If !acroPDTextSel
				return
			
			objAcroAVDoc.SetTextSelection( acroPDTextSel ) 
			objAcroAVDoc.ShowTextSelect() 
			TotalWords := objJSO.getPageNumWords(pagenumber)
			pdPage := objAcroPDDoc.AcquirePage( pagenumber ) 
			acroPoint := pdPage.GetSize()
			
			loop, %TotalWords%
			{
				if ( TextToFind = objJSO.getPageNthWord(pagenumber, a_index))
				{
					nword := a_index
					nwordhtl := ComObjCreate("AcroExch.HiliteList")
					nwordhtl.Add(nword, pagenumber)
					nwordTextSel := pdPage.CreateWordHilite(nwordhtl)
					objAcroAVDoc.SetTextSelection( nwordTextSel ) 
					objAcroAVDoc.ShowTextSelect() 
					rect := nwordTextSel.GetBoundingRect
				}
			} 
			if rect.left
			{
				signpdf(rect,pagenumber)
			}
		}
	}
	
	
	objAcroPDDoc := objAcroPDDoc.save(1, Inputfile)
	avdoc := objAcroAVDoc.Close(1)
	avdoc := objAcroApp.Exit
	objAcroPDDoc := 
	objAcroAVDoc := 
	objAcroApp := 
}
