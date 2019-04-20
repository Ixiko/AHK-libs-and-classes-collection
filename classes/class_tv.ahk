;tv.ahk
;Tuesday, June 10, 2014
;a class and wrapper library for Autohotkey's treeview control
;http://ahkscript.org/boards/viewtopic.php?f=6&t=3716
;by Brother Gabriel-Marie
;contributors:  JoeDF and Just Me from the ahkscript.org forum

;NOTES:
;the class does not need to be initiated

;--------SPECIAL-----------------------------------------------
; selection()
; count()

;-------FETCH ID's-------------------------------------------------
; first()
; next(whatid, ifchecked=false)
; previous(whatid)
; sibling(whatid, ifchecked=false)
; parent(whatid)
; child(whatid)
; lastchild(whatid)
; firstchild(whatid)

;-----RELATIONSHIPS--------------------------------------
; isparent(whatid)
; ischild(whatid)
; isroot(whatid)
; islastchild(whatid)
; isfirstchild(whatid)

;-----ATTRIBUTES------------------------------------------
; ischecked(whatid)
; isexpanded(whatid)
; isbold(whatid)
; hasattribute(whatid, whatattribute="checked")
; haschild(whatid)
; hasparent(whatid)
; allChildrenHaveAttribute(whatid, whatattribute := "checked", recurse := true, checkparents := true)

;------METHODS-----------------------------------------------
; text(whatid, whattext="")		;get or set the text of an item
; parenttext(whatid, whattext="")
; delete(whatid, deleteall=false)
; add(whatname, whatparentid=0, whatoptions="")

; check(whatid, value=1)
; expand(whatid, value=1)
; bold(whatid, value=1)
; checkparent(whatid, value=true)
; boldparent(whatid, value=true)
; expandparent(whatid, value=true)

; toggleTree(modify="check", setparent=true, setsubfamilies=true, setsubparents=true)
; toggleFamily(whatid=0, modify="check", setparent=true, setsubfamilies=true, setsubparents=true)

;--------------------------------------------------------------------------------------------------------------------------------------


class tv
{



;--------SPECIAL-----------------------------------------------

;returns the id of the current selection
selection(){
	return tv_getselection()
}

;returns a count of all items in the tree
count(){
	return tv_getcount()
}


;-------GET ID's-------------------------------------------------

;get the very first element in the tree
first(){
	return tv_getnext()
}


;returns the next item in the tree regardless of structure
;set ifchecked to true to locate the next checked item
next(whatid, ifchecked=false){
	if(ifchecked)
		return tv_getnext(whatid, "checked |full")
	else
		return tv_getnext(whatid, "full")
}

;returns the node previous to this one
previous(whatid){
	return tv_getprev(whatid)
}


;returns the id of the next sibling; returns 0 if none
;set ifchecked to true to locate the next checked item
sibling(whatid, ifchecked=false){
	if(ifchecked)
		return tv_getnext(whatid, "checked")
	else
		return tv_getnext(whatid)
}


;return the parent id of the item
parent(whatid){
	return tv_getparent(whatid)
}

;return the id of the first child of an item
;if there are no children or this is a parent item, it will return 0
child(whatid){
	return tv_getchild(whatid)
}


;returns the id of the last child of the node
;if this function is called on a node that is root, it will return the last root node
lastchild(whatid){
	thisid := whatid
	loop{
		if(!thisid)
			break
		nextnode := this.sibling(thisid)	
		if(!nextnode)
			return thisid
		thisid := this.lastchild(nextnode)
	}
}

;returns the first child of a family (does not recurse subfamilies)
;if the node has no children, it returns 0
firstchild(whatid){
	if(!this.isparent(whatid) ){
		thisid := this.parent(whatid)
		if(thisid)
			return this.child(thisid)
	}else{
		return this.child(whatid)
	}
}

;-----RELATIONSHIPS--------------------------------------

;return true if it is a parent node
isparent(whatid){
	return tv_getchild(whatid)
}

;return true if it is a child node
ischild(whatid){
	return tv_getparent(whatid)
}

isroot(whatid){
	if(!this.isparent(whatid) && !this.ischild(whatid) )
		return true
}

;returns true if the node is the last child in a family
islastchild(whatid){
	if(whatid = this.lastchild(whatid) )
		return true
}

;returns true if the node is the first child in a family
isfirstchild(whatid){
	if(whatid = this.firstchild(whatid) )
		return true
}


;-----ATTRIBUTES------------------------------------------


;return true if the item is checked
ischecked(whatid){
	if(tv_get(whatid, "checked") )
		return true
}

;return true if the item is expanded
isexpanded(whatid){
	if(tv_get(whatid, "expanded") )
		return true
}

;return true if the item is bolded
isbold(whatid){
	if(tv_get(whatid, "bold") )
		return true
}


hasattribute(whatid, whatattribute="checked"){
	if(tv_get(whatid, whatattribute) )
		return true
}


haschild(whatid){
	return tv_getchild(whatid)
}

hasparent(whatid){
	return tv_getparent(whatid)
}



;determine whether all members of a node are set to a certain attribute
;whatid  		--> is the id of a member of the node you want to check
;whatattribute 	--> should be one of either "checked" "bold" or "expanded"
;recurse		--> whether or not to confirm attributes in subtrees
;checkparents	--> whether or not to confirm subparents (nodes that have children)
;you can only check for one attribute at a time
;RETURNS:
;if the attribute is found in every member, it will return true
;if the attribute is missing from any member, it will return false
;USAGE:
;tv.allChildrenHaveAttribute(thiselement, "checked", true, true) --> should report true if all nodes are checked
;tv.allChildrenHaveAttribute(thiselement, "checked", true, false) --> should report true if all child elements (that are not parents and have no subtrees of their own) are checked (subparents are skipped)
;tv.allChildrenHaveAttribute(thiselement, "checked", false, true) --> should report true if all children of the parent are checked, not checking items in subtrees (subparents are treated as children only)
;Much thanks to JoeDF and JustMe for their diligence with this function
allChildrenHaveAttribute(whatid, whatattribute := "checked", recurse := true, checkparents := true){
    ; invalid item ID
    if(whatid < 0)
        return false
    ;store the parent of whatid in the 'parents' array for non-recursive checks
    parents := [this.parent(whatid)]
    ;walk through the node, as long as the 'parents' array contains parent nodes ...
    while(parents.maxindex() <> ""){
        currentid := this.firstchild(parents[1])
        ;as long as child items are found
        while(currentid){
            ;if it is a parent ...
            if(this.isparent(currentid)){
               ;if checkparents is true, check the attribute.
               if(checkparents) && !(this.hasattribute(currentid, whatattribute))
                  return false
               ;if recurse is true, add the parent to the 'parents' array.
               if(recurse)
                  parents.insert(currentid)
            }else{
               if !(this.hasattribute(currentid, whatattribute))
                  return false
			}
            ;get the next sibling, if any.
            currentid := this.sibling(currentid)
        }
        ;remove the current parent node from the 'parents' array
        parents.remove(1)
    }
    ;done, all items have been checked
    return true
}


;------METHODS-----------------------------------------------


;gets or sets an item's text
;to set the value, specifiy the second parameter - function will return 1 for success and 0 for failure
;to get the text, do not use the second parameter; returns false if there is no text or there is a failure
text(whatid, whattext=""){
	if(whattext){
		return tv_modify(whatid, whattext)
	}else{
		tv_gettext(thistext, whatid)
		return thistext
	}
}


;gets or sets the text of the item's parent.
;if there is no parent, it returns false
parenttext(whatid, whattext=""){
	thisid := this.parent(whatid)
	return this.text(thisid, whattext)
}


;deletes a particular item in the tree
;specify the second parameter as true to delete the entire tree
;returns 1 upon success
delete(whatid, deleteall=false){
	if(deleteall)
		return tv_delete(whatid)
	else if(whatid)
		return tv_delete(whatid)
}

;adds a new item to the tree
;returns the new item's id
;if parentid is not specified, the item will be added at root
add(whatname, whatparentid=0, whatoptions=""){
	if(!whatname)
		return 0
	return tv_add(whatname, whatparentid, whatoptions)
}




;check or uncheck the item
check(whatid, value=true){
	if(value)
		tv_modify(whatid, "check")
	else
		tv_modify(whatid, "-check")
}

;check or uncheck the item
expand(whatid, value=true){
	if(value)
		tv_modify(whatid, "expand")
	else
		tv_modify(whatid, "-expand")
}

;check or uncheck the item
bold(whatid, value=true){
	if(value)
		tv_modify(whatid, "bold")
	else
		tv_modify(whatid, "-bold")
}


checkparent(whatid, value=true){
	thisid := this.parent(whatid)
	this.check(thisid, value)
}

boldparent(whatid, value=true){
	thisid := this.parent(whatid)
	this.bold(thisid, value)
}

expandparent(whatid, value=true){
	thisid := this.parent(whatid)
	this.expand(thisid, value)
}






;This will allow you to operate on the entire tree
;modify is the value to add/subtract to the tree items
;checkparent is whether to check the main item if it is a parent (don't choose this if you attach this to an event launched when the user clicks the checkbox)
;checksubfamilies is whether to check any families within the parent's element
;checksubparents is whether to check any other parents in the family under the main parent
;note that if you set all the settings to false, it will only operate on root nodes without any subtrees
;the last parameter should not be used - it's only for the function to be able to recurse
toggleTree(modify="check", setparent=true, setsubfamilies=true, setsubparents=true, nextid=0){
	;if the firstid is recorded already, don't start over
	if(!nextid){
		thisid := this.first()
	}else{
		thisid := nextid
	}
	
	if(thisid){
		;got to add this in order to check a root item that has no children
		if(this.isroot(thisid) )
			tv_modify(thisid, modify)
		this.toggleFamily(thisid, modify, setparent, setsubfamilies, setsubparents)	
		nextid := this.sibling(thisid)
		if(nextid){
			this.toggleTree(modify, setparent, setsubfamilies, setsubparents, nextid)
		}

	}
} ;end toggleTree


;toggleFamily	- allows you to recurse a tree and set attributes for all the sub-parents, a family, or just the elements in a family
;whatid is which item to work upon
;modify is the value to add/subtract to the tree items
;checkparent is whether to check the main item if it is a parent (don't choose this if you attach this to an event launched when the user clicks the checkbox)
;checksubfamilies is whether to check any families within the parent's element
;checksubparents is whether to check any other parents in the family under the main parent
;usage:
;	tv.toggleFamily(myitemid, "check expand", true, false, true)
toggleFamily(whatid=0, modify="check", setparent=true, setsubfamilies=true, setsubparents=true){
	;if whatid is not specified, then operate on the entire tree
	if(!whatid){
		whatid := this.first()		
	}
		
	;check this item if it is a parent item, depending on the parameters	
	if(setparent && this.isparent(whatid)){
		tv_modify(whatid, modify)	
	}

	thisid := this.child(whatid)
	if(thisid){
		loop{
			if(!thisid)
				break

			if(setsubfamilies){
				;check this particular item if it isn't a parent item
				if(!this.isparent(thisid) )
					tv_modify(thisid, modify)
			}
			;set up for the next item and recurse
			thisid := this.sibling(thisid)	
			if(thisid)
				this.toggleFamily(thisid, modify, setsubparents, setsubfamilies, setsubparents)			
		} ;end loop
	} ;end if	
} ;end togglefamily



 


} ;end tv class
