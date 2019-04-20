; This function created a |-separated string of items in any director. Wildcards supported. 
splashDir(dir, filter="*.*", options=""){ ; Assign a directory path to a variable at pass it to the function 
	global
	items = ; Clear previously assigned %items% variable 
	Loop, %dir%\%filter%, %options%; Loop through items in directory 
	{
		items .= A_LoopFileName . "|" ; Add each item to a |-separated string
	}
	StringTrimRight, items, items, 1 ; Remove the final | so as not to leave an empty item 
	Return ; %items% variable now contains a string of items in chosen directory 
}
/* 
Possible options for folder loop: 
0 (or blank) Folders are not retrieved (only files) 
1 All files and folders that match the wildcard pattern are retrieved
2 Only folders are retrieved (no files)
*/