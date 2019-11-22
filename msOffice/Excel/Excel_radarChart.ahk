; Pass a simple or associative array to this function to have it return a radar chart. 
;
; Simple array: myArray := [3, 5, 3, 2, 1, 5, 3, 4, 2]
; Associative array:  myArray := {"Thesis": 3, "Introduction": 4, "Conclusion": 1, "Sentences": 2, "Orangization": 3, "Vocabulary": 5, "Grammar & spelling": 2}
; radarChart(myArray)

myArray := [3, 5, 3, 2, 1, 5, 3, 4, 2]
radarChart(myArray)

radarChart(myArray) { 
	xl := ComObjCreate("Excel.Application") ; Excel object 
	xl.WorkBooks.Add ; Add workbook (invisible)
	
	for index, element in myArray ; Loop through the array
	{
	    xl.Cells(A_Index, 1).Value := index ; Column A = index ; In simple arrays, This will just be sequential numbers 
	    xl.Cells(A_Index, 2).Value := element ; Column B = element 
	}

	xl.ActiveCell.CurrentRegion.Select ; Select current region of cells 
	xl.ActiveSheet.Shapes.AddChart.Select ; Add chart 
	xl.ActiveChart.ChartType := 82 ; Radar chart - TODO: pass chart type variable 
	xl.ActiveChart.ClearToMatchStyle 
	xl.ActiveChart.ChartStyle := 11 
	xl.ActiveChart.ClearToMatchStyle

	xl.Worksheets(1).ChartObjects(1).Chart.Export("C:\pic1.png") ; Save as PNG 

	xl.ActiveWorkbook.Close(0) 
	xl.Quit ; Quit Excel

	Gui, Add, Picture, , d:\pic1.png ; Simple GUI for showing image 
	Gui, Show
}


