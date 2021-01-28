/*
This function accepts all or part of a tab's name and returns the relevant actionable object.
You can then use accDoDefaultAction(0) to activate the tab in Firefox. 

Note that using accDoDefaultAction will disrupt any previously defined tab objects.
Attempting to act on a previously defined tab after running accDoDefaultAction
will result in an AHK error. You will therefore need to define a tab, activate it,
and only after that can you establish a second tab on which to act.

Requires the Acc Library: 
http://www.autohotkey.com/board/topic/77303-acc-library-ahk-l-updated-09272012/
*/


GetFFTab(TabName=""){
for each, child in Acc_Children(Acc_Get("Object", "4", 0, "ahk_class MozillaWindowClass")) ; "4" is a constant in Firefox. We don't need to loop to find this part of the path.
{
	c1 := a_index ; We will use the c variables to map the path to our tab.
	try role := Acc_GetRoleText(child.accRole(0)) ; The remaining piece of the path are not constant. They need to be sought out each time.
	If InStr(role, "tool bar") ; When we see this, we have found the first part of the path.
		for each, child in Acc_Children(child)
		{
			c2 := a_index ; Start counting for the second part.
			try role := Acc_GetRoleText(child.accRole(0))
			if inStr(role, "page tab list") ; Found the second part, which is a list of our open tabs.
				for each, child in Acc_Children(child)
				{
					try name := child.AccName(0)
					if InStr(name, TabName) ; Here, we've found a tab containing the string passed to the function
					{
						c3 := a_index ; So store the last part of the tab, and
						break  ; break the inner loop.
					}
				}
			if c3
				break ; Break the middle loop.
		}
	if c3
		break ; Break the outer loop.
}

path := "4." c1 "." c2 "." c3 ; This is the full path to our desired tab.
return Acc_Get("Object", path, 0, Title)

}
