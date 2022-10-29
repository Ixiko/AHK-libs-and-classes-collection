	
	TextToFind := "Contributions"
	
	Find_PageNo_Via_Search_Text(TextToFind)
	
	Exit	
		
	Find_PageNo_Via_Search_Text(TextToFind)
	{
		objAcroApp := ComObjCreate("AcroExch.App")
		objAcroAVDoc := objAcroApp.GetActiveDoc()
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

			acroPageView.Goto( pagenumber )
			acroHiList := ComObjCreate("AcroExch.HiliteList")
			acroHiList.Add( 0, 32767 ) 
			acroPDPage := acroPageView.GetPage()
			acroPDTextSel := acroPDPage.CreateWordHilite( acroHiList ) 
			If !acroPDTextSel
				return
			
			objAcroAVDoc.SetTextSelection( acroPDTextSel ) 
			objAcroAVDoc.ShowTextSelect() 

		; http://www.vbforums.com/showthread.php?561501-RESOLVED-2003-How-to-highlight-text-in-pdf
		; TotalWords := acroHiList.GetNumText

			TotalWords := objJSO.getPageNumWords(pagenumber)
			pdPage := objAcroPDDoc.AcquirePage( pagenumber ) 
			acroPoint := pdPage.GetSize()


				TotalWords := objJSO.getPageNumWords(pagenumber)
	
				loop, %TotalWords%
				{
					if (TextToFind = objJSO.getPageNthWord(pagenumber, a_index))
					{	
						nword := a_index
				 		nwordhtl := ComObjCreate("AcroExch.HiliteList")
						nwordhtl.Add(nword, pagenumber)
						nwordTextSel := pdPage.CreateWordHilite(nwordhtl)

						objAcroAVDoc.SetTextSelection( nwordTextSel ) 
						objAcroAVDoc.ShowTextSelect() 

						msgbox % """" TextToFind """ Found on Page: " pagenumber+1
						break 2
					}
				} 
			}
		}
	
		; avdoc := objAcroAVDoc.Close(1)
		; avdoc := objAcroApp.Exit
		objAcroPDDoc := 
		objAcroAVDoc := 
		objAcroApp := 
	}