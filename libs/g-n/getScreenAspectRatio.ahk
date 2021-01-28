getScreenAspectRatio()
{ 	;ROUND as this should group 1366x768 (1.7786458333) in with 16:9
	AspectRatio := Round(A_ScreenWidth / A_ScreenHeight, 2)
	if ( AspectRatio = Round(1680/1050, 2)) 	; 1.6
		AspectRatio := "16:10"
	else if (AspectRatio = Round(1920/1080, 2)) ; 1.78
		AspectRatio := "16:9"
	else if (AspectRatio = Round(1280/1024, 2)) ; 1.25
		AspectRatio := "5:4"
	else if (AspectRatio = Round(1600/1200, 2)) ; 1.33
		AspectRatio := "4:3"
	else AspectRatio := "Unknown"
	return AspectRatio
}