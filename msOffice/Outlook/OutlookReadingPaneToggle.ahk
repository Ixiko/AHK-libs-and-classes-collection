
/*
	======================================================================
	
	Outlook Reading Pane Toggle
	
	by Casper Harkin - 14/06/2022

	======================================================================
*/

        ShowAndChangePreviewPane()

        Exit ;EOAES

        ShowAndChangePreviewPane() {
            Application := ComObjActive("Outlook.Application")
            myOlExp := Application.ActiveExplorer 
            PaneLoc := Application.ActiveExplorer.CommandBars

            ; Check if the Reading Pane is Visible, if its not turn it on
            If (myOlExp.IsPaneVisible(3) = 0)
                myOlExp.ShowPane(olPreview := 3, Boolean := True)  

            ; Checking the location of the Reading Pane; options are ReadingPaneBottom, ReadingPaneRight and ReadingPaneOff
            If (PaneLoc.GetPressedMso("ReadingPaneBottom") = -1)
                PaneLoc.ExecuteMso("ReadingPaneRight")
            else 
                PaneLoc.ExecuteMso("ReadingPaneBottom")     
        }