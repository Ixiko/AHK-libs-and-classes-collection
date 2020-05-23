;~ q:=new Queue
;~ q.enqueue([1,2])

;~ MsgBox % q.dequeue()[2]
;~ MsgBox % q.isEmpty()
;~ ExitApp

class DLNode
{
	data := ""
	post := ""
	prev := ""
	
	__New(data)
	{
			this.data := data
	}
}

class DLinkedList
{
	length := 0
	first := ""
	last := ""
	
	addFirst(data)
	; Adds an item to the front of the list.
	; Parameters:
	; data : The item to insert
	{
		tempN := new DLNode(data)
		secondN := this.first.post
		
		if(this.length = 0)
		{
			this.first := tempN
			this.last := tempN
			this.length++
		}
		else
		{
			tempN.post := 	this.first
			secondN.prev := tempN
			this.first := tempN
			this.lenght++
		}
			
	}
	
	addLast(data)
	; Adds an item to the back of the list.
	; Parameters:
	; data : The item to insert
	{
		tempN := new DLNode(data)
		
		if(this.length = 0)
		{
			this.first := tempN
			this.last := tempN
			this.length++
		}
		else
		{
			this.last.post := tempN
			tempN.prev := this.last
			this.last := tempN
			this.length++
		}
	}
	
	addAt(data, index)
	; Adds an item at a specified location list.
	; Parameters:
	; data : The item to insert
	; index: the index to insert the item
	{
		if(index < 0 or index > this.length)
			return -1
		tempN := new DLNode(data)

		if(index = 1)
			this.addFirst(data)
		else if(index = this.length)
			this.addLast(data)
		else if((this.length - index) < (this.length/2))
		{
			current := this.Last
			while(not !current)
			{
				if(counter+2 = this.length - index + 1)
				{
					targetN := current.prev
					prevN := targetN.prev
					
					tempN.post := targetN
					tempN.prev := prevN
					
					targetN.prev := tempN
					prevN.post := tempN
					
					this.length++
					
					break
				}
				else
				{
					current := current.prev
					counter++
				}
			}
		}
		else		
		{
			current := this.first
			counter := 1
		
			while(not !current)
			{
				frontN := current.post
			
				if(counter + 1 = index)
				{
					tempN.post := current.post
					tempN.prev := current
					current.post := tempN
					frontN.prev := tempN
					this.length++
					break
				}
				else
				{
					current := current.post
					counter++
				}
			}
		}
	}
	
	removeFirst()
	; Removes and retrieves the first item from the list 
	{
		f:=this.first.data
		secondN := this.first.post
		
		secondN.prev := ""
		this.first.post := ""
		
		this.first := secondN
		if(this.length =1)
			this.last := secondN
		this.length--
		return f
	}
	
	removeLast()
	; Removes and retrieves the last item from the list 
	{
		if(this.length = 1)
		{
			this.first := ""
			this.last := ""
		}
		else
		{
			final := this.last.prev
		
			final.post := ""
			this.last.prev := ""
			this.last := final
			this.length--
		}
	}
	
	removeAt(index)
	; Currently, this method isn't working. I'll update it once I fix it.
	{
		if(index < 0 or index > this.length)
			return -1		
		
		if(index = 1)
			this.removeFirst()
		else if(index = this.length)
			this.removeLast()
		else 
		{
			if((this.length - index) < (this.length/2))
			{
				counter := 1
				current := this.last
				while(not !current)
				{
					if(counter+1 = this.length - index + 1)
					{
						targetN := current.prev
						prevN := targetN.prev
						
						current.prev := prevN
						prevN.post := current
						
						targetN.post := ""
						targetN.prev := ""
						this.length--
						
						break
					}
					else
					{
						current := current.prev
						counter++
					}
				}
			}
			counter := 1
			current := this.first
		
			while(not !current)
			{
				if(counter + 1 = index)
				{
					tragetN := current.post
					postN := targetN.post
					
					current.display()
					targetN.display()
					postN.display()
					
					current.post := postN
					postN.prev := current

					target.post := ""
					target.prev := ""
				
					this.length--
					break
				}
				else
				{
					current := current.post
					counter++
				}
			}
		}
	}
	
	clear()
	; Empties the list.
	 {
		this.length := 0
		
		current := this.first
		
		while(not !current)
		 {			
			current.data := ""
			current := current.post
		 }
	 }
	
;-------------------	
	
	search(value)
	; Retrieves the index of the specified element. It returns "-1" if the element doesn't exist.
	; Parameters:
	; value : The value of  the element to search for
		{
			current := this.first
			index := -1
			counter := 1
		
			while(not !current)
			{			
				if (current.data = value)
				{
					index := counter
					break
				}
				current := current.post
				counter++
			}
			return % index
		}
	
	get(index)
	; Retrieves an item from the list. Returns "-1" if the element doesn't exist.
	; Parameters:
	; index : The index of the item to be retrieved.
		{
			current := this.first
			counter := 1
		
			while(not !current)
			{				
				if (counter = index)
					return % current.data 
				else
				{ 	
					counter++
					current := current.post
				}
			}
			return -1	
		}
		
	toArray()
	; converts the linked list to an array
	{
			array := [""]
			
			Loop, % this.length
				Array.Insert(this.get(A_index))
			
			return % array
	}
	 
	 
	fromArray(array)
	; Populates the linked list from an array
	; Parameters:
	; array: the array to populate the linked list
	{
			Loop, % array.MaxIndex()
			{
				this.addLast(array[A_Index])
			}
	}
}


class Queue extends DLinkedList
{
	enqueue(data)
	{
		this.addLast(data)
	}
	
	dequeue()
	{
		return this.removeFirst()
	}
	
	isEmpty()
	{
		if this.length = 0 
			return true
		else
			return false
	}
	
}


class Stack extends DLinkedList
{
	enqueue(data)
	{
		this.addFirst(data)
	}
	
	dequeue()
	{
		return this.removeFirst()
	}
	
	isEmpty()
	{
		if this.length = 0 
			return true
		else
			return false
	}
	
}
