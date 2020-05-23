;================Tree Node & Linked List================
;===============Multi-Tree  Data  Structure===============
;==                                                                                                                   ==
;===https://autohotkey.com/board/topic/147436-multi-tree-data-structure/====
;=== http://www.autohotkey.com/board/topic/131314-linked-list-in-ahk/=====
;==                                                                                                                   ==
;================Author: 		 Za3root=================
;============AutoHotkey Version: 	 1.1.19.03 ==============
;==You can contact the author on reddit (/u/za3root) or on AutoHotkey Forums===
;==                                                                                                                    ==
;=====This to classes are collected and combined on 16.04.2018=========


;=========Node & Linked List==============
class Node {
	data := ""
	next := ""

	__New(data)
	 {
		this.data := data
 	 }

 }

class LinkedList {
	first := ""

;-----------Adding Items-------

addFirst(a) {
; Adds an item to the front of the list.
; Parameters:
; "a" : The item to insert

		p := new Node(a)

		if !this.first
			this.first := p
		else
		 {
			p.next := this.first
			this.first := p
		 }
	 }

;-------------------

addLast(a) {
; Adds an item to the back of the list.
; Parameters:
; "a" : The item to insert

		p := new Node(a)

		if !this.first
			this.first := p
		else
		 {
			current := this.first

			while(not !current)
			{
				if (!current.next)
				{
					current.next := p
					break
				}
				else
					current := current.next
			}
		 }
	 }

;-------------------

addAt(a,v) {
; Adds an item at a specific location in the list.
; Parameters:
; "a" : The index to append the item.
; "v" : The item to insert.

		p := new Node(v)
		current := this.first
		counter := 1

			while(not !current)
			{
				if (counter + 1 = a)
				 {
					p.next := current.next
					current.next := p
					break
				 }
				else
				 {
					counter++
					current := current.next
				 }
			}
	 }

;---------------Removing Items---------------

removeFirst()  {
; Removes an item from the front of the list.

	  tempN := this.first
          this.first := this.first.next
          tempN.next := ""
          return % tempN.data
	 }

;-------------------

removeLast() {
; Removes an item from the back of the list.

		current := this.first

			while(not !current)
			{
				if (!current.next.next)
				{
					tempN := current.next
                                        current.next := ""
					return % tempN.data
				}
				else
					current := current.next
			}
	 }

;-------------------

removeAt(a) {
; Removes an item from a specific location in the list.
; Parameters:
; "a" : The index to remove the item.

		current := this.first
		counter := 1

			while(not !current)
			{
				if (counter + 1 = a)
				 {
					p := current.next

					current.next := p.next
					p.next := ""
					return % p.data
				 }
				else
				 {
					counter++
					current := current.next
				 }
			}
	 }

;---------------Other---------------

clear()  {
; Empties the list.

		current := this.first

		while(not !current)
		 {
			current.data := ""
			current := current.next
		 }
	 }

;-------------------

get(a)  {
; Retrieves an item from the list. Returns "-1" if the element didn't exist.
; Parameters:
; "a" : The index of the item to be retrieved.

		current := this.first
		counter := 1

		while(not !current)
		 {
			if (counter = a)
				return % current.data
			else
			 {
				counter++
				current := current.next
			 }
			}
		return -1
	 }

;-------------------

contains(v) {
; Checks if an element exists in a list. It returns the number of occurrences of the specific element. It returns "0" if the element doesn't exist.
; Parameters:
; "v" : The value of  the element.

		current := this.first
		occurrence := 0

		while(not !current)
		 {
			if (current.data = v)
				occurrence++
			current := current.next
		 }

		return % occurrence
	 }

;-------------------

location(v,occ := "f") {
; Retrieves the location of the first/last occurrence of the element. It returns "-1" if the element doesn't exist.
; Parameters:
; "v" : The value of  the element.
; "occ" : Whether it retrieves the location of the first or last occurrence of the element. It is first by default.

		current := this.first
		loc := -1
		counter := 1

		while(not !current)
		 {
			if (current.data = v)
			 {
				loc := counter

				if ( occ = "f")
					break
			 }
			current := current.next
			counter++
		 }

		return % loc
	 }


;I've added the following methods.

length() {
; returns the length of the linked list

    current := this.first
    counter := 0

    while(not !current)
    {
        counter++
        current := current.next
    }

    return % counter
}

toArray() {
; converts this linked list to an array

    array := [""]

    Loop, % this.length()
    Array.Insert(this.get(A_index))

    return % array
}

fromArray(array) {
; Populates this linked list from an array
; Parameters:
; array: the array to populate the linked list

    Loop, % array.MaxIndex()
    {
    this.addLast(array[A_Index])
    }

}

}


;========TreeNode & MultiTree============
; You can use an array instead of  a linked list
class TNode {

		parent := ""
		data := ""
		children := new LinkedList()
		childrenNb := 0

		__New(data)
		{
			this.data := data
		}

		setData(data)
		; Sets the data of the node
		; Parameters:
		; data: the data for the node to hold
		{
				this.data := data
		}

		add(data)
		{
			node := new TNode(data)
			this.addNode(node)
		}

		addNode(node)
		; Adds a node to the node's children
		; Parameters:
		; node: the node to add
		{
				node.parent := this
				this.children.addFirst(node)
				this.childrenNb++
		}

		getChild(index)
		; Retrives a childe node
		; Parameters:
		; index: the index of the node in the children
		{
			if(index <= this.childrenNb and index > 0)
				return this.children.get(index)
			else
				return -1
		}

		removeChild(index)
		; Deletes a childe node
		; Parameters:
		; index: the index of the node in the children
		{
				this.children.RemoveAt(index)
				this.childrenNb--
		}

		isLeaf()
		; Checks if  the node has no children
		; Parameters:
		; index: the index of the node in the children
		{
				if(this.childrenNb = 0)
					return true
				else
					return false
		}



}

class MultiTree {

		;===================================================
		; AutoHotkey Version: 	 1.1.19.03
		; Author:                Za3root
		; Contact:  	         You can contact me on reddit (/u/za3root) or on AutoHotkey Forums
		; Date(dd/mm/yyyy): 	 7/28/2015
		;===================================================

		root := new TNode("")
		path := new LinkedList

		setRootData(data)
		; Sets the data of the root node
		; Parameters:
		; data: the data for the node to hold
		{
				this.root.data := data
		}

		search(data)
		; Searches the tree for a node holding a specific value then returns it
		; Parameters:
		; data: the data to search for
		{
				return % this.searchAlt(data,this.root)
		}

		searchAlt(data, node)
		; this method is used by the search() method
		{
				if !node
					return

				if(node.data = data)
					return  node
				else
					Loop, % node.childrenNb
					{
						tempNode := node.children.get(A_Index)
						current := this.searchAlt(data, tempNode)
						if(current.data = data)
							return  current
					}
				return -1
		}

		getPathToRoot(node)
		;  after using this method, this.path will hold nodes from the specific node to the root
		{
			this.path.clear()
			this.getPath(node)
		}

		getPath(node)
		; this method id used by the getPathToRoot() method
		{
			global

			parent := node.parent

			if(!parent)
			{
			return
			}
			else
			{
					this.path.addFirst(parent)
					this.getPath(parent)
			}
		}
}
