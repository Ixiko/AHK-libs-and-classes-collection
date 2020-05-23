;Simple Dictionary/Map/Hashtable and Linked List implementation by icuurd12b42, free to use, have fun
; Thanks to Brian Kernighan's description on computerphile on yt for the cheap implementation of the idea
; https://www.youtube.com/watch?v=qTZJLJ3Gm6Q

; V1.2 
; added linked list replacing the bucket array, you can use the linked list system on it's own
; tweaked the stringed key hash to give power to the character order to prevent collision between small string keys with same characters so that "KEY" != "YEK"
; added growth/re-hashing of the main hash table

;See bottom of file for example use and api tests

;LinkedListItem
;A Linked List Item has data, a next and a Prev item. Linked list items point to the next item in a chain of data
; It's easy to manage insertion and removal and connecting chains of data by setting the next and prev values of the item
class LinkedListItem
{
	m_Next :=
	m_Prev :=
	m_Data :=
	;New
	__New(data)
	{
		this.LLItemInit(data) ;call the init func
	}
	__Delete() ;you must delete your data held by m_Data yourself
    {
        this.Destroy()
    }
	;init
	LLItemInit(data)
	{
		this.m_Next :=
		this.m_Prev :=
		this.m_Data := data
	}
	Destroy()
	{
		this.Unlink()
		this.m_Next :=
		this.m_Prev :=
		this.m_Data :=
		
	}
	;get/set next prev
	GetNext()
	{
		return this.m_Next
	}
	GetPrev()
	{
		return this.m_Prev
	}
	SetNext(Nxt)
	{
		this.m_Next := Nxt
	}
	SetPrev(Prev)
	{
		this.m_Prev := Prev
	}
	
	;get set data
	GetData()
	{
		return this.m_Data
	}
	SetData(Data)
	{
		this.m_Data := Data
	}
	
	;Unlink this from next and prev and preserve re-attaches the chain with this item gone from it
	UnLink()
	{
		prv := this.GetPrev()
		nxt := this.GetNext()
		if(prv) ;Fix broken chain...
		{
			prv.SetNext(nxt)
			this.SetPrev(0)
		}
		if(nxt) ;Fix broken chain...
		{
			nxt.SetPrev(prv)
			this.SetNext(0)
		}
	}
	;Chain/De-chain functions
	UnlinkFromPrev() ;breaks the chain in 2, terminating it at prev (making prev the end of a chain) and this becoming the start of the chain
	{
		prv := this.GetPrev()
		if(prv) ;Fix broken chain...
		{
			prv.SetNext(0)
			this.SetPrev(0)
		}
	}
	UnlinkFromNext() ;breaks the chain in 2, terminating it at next (making nxt the start of a chain) and this becoming the end of the chain
	{
		nxt := this.GetNext()
		if(nxt) ;Fix broken chain...
		{
			nxt.SetPrev(0)
			this.SetNext(0)
		}
	}
	
	LinkAfter(Prev) ; reconnects the chain, it is assumed that Prev is the end of a chain or a link and this is a start of a chain or a link
	{
		this.SetPrev(Prev)
		Prev.SetNext(this)
	}
	LinkBefore(Nxt) ; reconnects the chain, it is assumed that Nxt is the start of a chain or a link and this is a end of a chain or a link
	{
		this.SetNext(Nxt)
		Nxt.SetPrev(this)
	}
	
	;
	InsertAfter(Prev) ; Inserts itself in a chain between Prev and it's next link. It is assumed that this item is a single link, no part of a chain
	{
		old_next := Prev.GetNext()
		if(old_next)
		{
			old_next.SetPrev(this)
			this.SetNext(old_next)
		}
		this.SetPrev(Prev)
		Prev.SetNext(this)
	}
	InsertBefore(Nxt) ; Inserts itself in a chain between Nxt and it's prev link. It is assumed that this item is a single link, no part of a chain
	{
		old_prev := Nxt.GetPrev()
		if(old_prev)
		{
			old_prev.SetNext(this)
			this.SetPrev(old_prev)
		}
		this.SetNext(Nxt)
		Nxt.SetPrev(this)
	}
}



;Dictionary item container, will eventually hold the data stored to the dictionary
;Has a Key to compare with, the data to store is provided by the based linked list class.
;Internal Use Only
Class DicItem extends LinkedListItem
{
	m_Key :=
	__New(Key,Data)
	{
		this.DicItemInit()
	}
	__Delete()
    {
        this.DicItemDelete()
    }
	DicItemInit()
	{
		this.LLItemInit()
		this.m_Key :=
	}
	DicItemDelete()
	{
		this.LLItemDelete()
	}
	GetKey()
	{
		return this.m_Key
	}
	SetKey(Key)
	{
		this.m_Key := Key
	}
}

;DicEntry (bucket) is a linked list to holds DicItems at a key location
; since a key hash may resolve to the same entry in the dictionary
; it is necessary to have each dictionary spot be capable of holding multiple
; entries. if data is well distributed, this array should only have 1 to a few entries
; when set.
; The class has an Linked List (Tail) and a count for the number of items in the linked list
;Internal Use Only
Class DicEntry
{
	m_Tail :=
	__New()
	{
		this.m_Tail := 
		
	}
	;add new item 
	AddItem(key, data)
	{
		
		item := new DicItem()
		item.SetKey(key)
		item.SetData(data)
		
		if(this.m_Tail)
		{
			item.LinkAfter(this.m_Tail)
			
		}
		this.m_Tail := item
		
	}
	;Find item, used internally
	FindItem(Key)
	{
		item := this.m_Tail
		while(item)
		{
			if(item.GetKey() = Key)
			{
				return item
			}
			item := item.GetPrev()
		}
		return 0
	}
	
	;Set Item, used to add or set item to the array, if a deleted entry is found, re-use it
	SetItemData(Key,Data)
	{
		item := this.FindItem(Key)
		if(item)
		{
			item.SetData(Data)
			return 0 ;tells the caller an item was changed
		}
		else
		{
			this.AddItem(key, data)
			return 1 ;tells the caller an item was added
		}
	}
	;get the item data
	GetItemData(Key)
	{
		item := this.FindItem(Key)
		if(item)
		{
			return item.GetData()
		}
		else 
		{
			return 0
		}
	}
	;delete the item, you have to destroy the data held in the key yourself
	DeleteItem(Key)
	{
		ret := 0
		item := this.FindItem(Key)
		if(item)
		{
			if(item = this.m_Tail)
			{
				this.m_Tail := item.GetPrev()
			}
			item.Destroy()
			
			ret := 1
		}
		return ret ;tell caller item was deleted
	}
}

;Dictionary
; The main dictionary is basically an array of fixed size
; The simple dictionary is a Key Based Entry system
; the key is converted to a number (if it was a string) 
; and ranged, with modulo so that it fits in the index range of the allocated array
; Then the data is added to that array location. A location may hold multiple data if
; there was collision.
; For example, creating a dictionary with an array of 1000 spots... therefore an average of 1 chance to 1000 of collision
; Dic := New Dictionary(1000)
; Dic.SetItem(1,"Hello1") ;1 modulo 1000 is 1, this is store at pos 1 in array
; Dic.SetItem(2,"Hello2") ; spot 2
; Dic.SetItem(1002,"Hello3") ; Spot 2 again, collision, spot 2 hold 2 keys
; Dic.SetItem("Greeting","Hello4") ; "Greeting" is converted to a number prior
; 
; Dont be ridiculous and create a super large dictionary; 10000 items should fit in a 1000 size dictionary 
;   which would, given an even distribution, fill up the array with 10 entries per slot
;   a 1 lookup for the slot and 10 lookups for the exact keyed item is way efficient enough
;   compared to a single loop through 10000 items
; the system will grow and re-hash the table if the number of items get too crowded creating too large buckets per slot
;   Each growth is twice the previous size
Class Dictionary
{
	m_Array := ;the array of size specified
	m_Size := ;the size of the array, may grow over time
	m_Count := ;the number of items in the dictionary
	m_GrowthFactor :=
	__New(Size:=1024,GrowthFactor:=2)
	{
		this.m_Size := Size
		if(this.m_Size < 1024)
		{
			this.m_Size := 1024
		}
		
		this.m_GrowthFactor := GrowthFactor
		if(this.m_GrowthFactor < 1.25)
		{
			this.m_GrowthFactor := 1.25
		}
		
		this.m_Count := 0
		
		sz := this.m_Size
		
		
		
	}
	;convert the key to a valid number modulo size + 1 to give 1 to array size range
	ConvertKey(Key)
	{
		if Key is number
		{
			;number are floored, and made positive... then modulo-ed
			return mod(abs(floor(Key)),this.m_Size) + 1
		}
		else
		{
			;strings are set to use the compound ASCII values of each character
			val := 0
			loop parse, Key
			{
				val += Asc(A_LoopField) * A_Index
			}
			return Mod(val,this.m_Size) + 1
		}
	}
	; count and size. mainly to monitor and growing the array and for debugging
	GetCount()
	{
		return this.m_Count
	}
	GetSize()
	{
		return this.m_Size
	}
	GetArray()
	{
		return this.m_Array
	}
	GetGrowthFactor()
	{
		return this.m_GrowthFactor
	}
	;Redo the dictionary a new size... or grow (if size not specified),
	rehash(newSize:=0)
	{
		sz := newSize == 0 ? this.m_Size*this.m_GrowthFactor : newSize
		tempDic := New Dictionary(sz)
		Size := this.m_Size
		Loop %Size%
		{
			bucket := this.m_Array[A_Index]
			while(bucket.m_Tail)
			{
				item := bucket.m_Tail
				tempDic.SetItem(item.GetKey(),item.GetData())
				bucket.m_Tail := item.GetPrev()
				item.Destroy()
			}
		}
		this.m_Size := tempDic.GetSize()
		this.m_Count := tempDic.GetCount()

		this.m_Array := tempDic.GetArray()
		tempDic :=
	}
	
	;set or adds an item to the dictionary
	SetItem(Key,Data)
	{
		index := this.ConvertKey(Key)
		entry := this.m_Array[index]
		if !entry
		{
			entry := new DicEntry()
			this.m_Array[index] := entry
		}
		this.m_Count := this.m_Count + entry.SetItemData(Key,Data)
		if(this.m_Count > this.m_Size * 2)
		{
			this.rehash()
		}
	}
	;gets an item from the dictionary
	GetItem(Key)
	{
		index := this.ConvertKey(Key)
		entry := this.m_Array[index]
		return entry.GetItemData(Key)
	}
	;delete an item from the dictionary
	DeleteItem(Key)
	{
		index := this.ConvertKey(Key)
		entry := this.m_Array[index]
		this.m_Count := this.m_Count - entry.DeleteItem(Key)
	}
	;check if an item exists
	KeyExists(Key)
	{
		index := this.ConvertKey(Key)
		entry := this.m_Array[index]
		item := entry.FindItem(Key)
		if(item)
		{
			return true
		}
		return false
	}
	
}



; Feature tests and examples
/*
Debug(Text)
{
   MsgBox, %Text%
}
*/
; Linked list test
/*
Start := New LinkedListItem("Item 1")
item2 := New LinkedListItem("Item 2")
item2.LinkAfter(Start)
item3 := New LinkedListItem("Item 3")
item3.LinkAfter(item2)
item4 := New LinkedListItem("Item 4")
item4.LinkAfter(item3)
End := Item4

Debug("should show 1,2,3,4")
DebugForward(Start)
Debug("should show 4,3,2,1")
DebugBackwards(End)

item3.Unlink()

Debug("should show 1,2,4")
DebugForward(Start)
Debug("should show 4,2,1")
DebugBackwards(End)

item3.LinkAfter(item2)
item3.LinkBefore(item4)

Debug("should show 1,2,3,4")
DebugForward(Start)
Debug("should show 4,3,2,1")
DebugBackwards(End)

item3.UnlinkFromPrev()

Debug("should show 1,2")
DebugForward(Start)
Debug("should show 4,3")
DebugBackwards(End)

item3.LinkAfter(item2)

Debug("should show 1,2,3,4")
DebugForward(Start)
Debug("should show 4,3,2,1")
DebugBackwards(End)

braket1 := New LinkedListItem("[")
braket2 := New LinkedListItem("]")
braket1.InsertAfter(item2)
braket2.InsertBefore(item4)

Debug("should show 1,2,[,3,],4")
DebugForward(Start)
Debug("should show 4,],3,[,2,1")
DebugBackwards(End)

;example iterations
DebugForward(Start)
{
	item := Start
	while(item)
	{
		Debug(item.GetData())
		item := item.GetNext()
	}
}
DebugBackwards(End)
{
	item := End
	while(item)
	{
		Debug(item.GetData())
		item := item.GetPrev()
	}
}
*/

;Hash table test, set/get
/*
Dic := New Dictionary(1000)

Debug("Pass 1 of Set Get Test")
Dic.SetItem(1,"Item 1") ;1 modulo 1000 is 1, this is store at pos 1 in array
Dic.SetItem(2,"Item 2") ; spot 2
Dic.SetItem(1002,"Item 3") ; Spot 2 again, collision, spot 2 hold 2 keys
Dic.SetItem("Greeting","Item 4") ; "Greeting" is converted to a number prior
Debug("Test 1, Item 1 == " . Dic.GetItem(1))
Debug("Test 2, Item 2 == " . Dic.GetItem(2))
Debug("Test 3, Item 3 == " . Dic.GetItem(1002))
Debug("Test 4, Item 4 == " . Dic.GetItem("Greeting"))
Debug("Test 5, 1 == " . Dic.KeyExists(1))
Debug("Test 6, 1 == " . Dic.KeyExists(2))
Debug("Test 7, 1 == " . Dic.KeyExists(1002))
Debug("Test 8, 1 == " . Dic.KeyExists("Greeting"))

Dic.DeleteItem(1)
Dic.DeleteItem(1002)
Dic.DeleteItem("Greeting")
Debug("Test 9, 0 == " . Dic.KeyExists(1))
Debug("Test 10, 1 == " . Dic.KeyExists(2))
Debug("Test 11, 0 == " . Dic.KeyExists(1002))
Debug("Test 12, 0 == " . Dic.KeyExists("Greeting"))

Dic.SetItem(1,"New Item 1") 
Dic.SetItem(1002,"New Item 3") 
Debug("Test 13, 1 == " . Dic.KeyExists(1))
Debug("Test 14, 1 == " . Dic.KeyExists(2))
Debug("Test 15, 1 == " . Dic.KeyExists(1002))
Debug("Test 16, 0 == " . Dic.KeyExists("Greeting"))

Debug("Test 17, New Item 1 == " . Dic.GetItem(1))
Debug("Test 18, Item 2 == " . Dic.GetItem(2))
Debug("Test 19, New Item 3 == " . Dic.GetItem(1002))

Dic.DeleteItem(1)
Dic.DeleteItem(2)
Dic.DeleteItem(1002)
Dic.DeleteItem("Greeting")
Debug("Test 21, 0 == " . Dic.KeyExists(1))
Debug("Test 22, 0 == " . Dic.KeyExists(2))
Debug("Test 23, 0 == " . Dic.KeyExists(1002))
Debug("Test 24, 0 == " . Dic.KeyExists("Greeting"))


;Reshash test

Dic.SetItem(1,"Item 1") ;1 modulo 1000 is 1, this is store at pos 1 in array
Dic.SetItem(2,"Item 2") ; spot 2
Dic.SetItem(1002,"Item 3") ; Spot 2 again, collision, spot 2 hold 2 keys
Dic.SetItem("Greeting","Item 4") ; "Greeting" is converted to a number prior
size := Dic.GetSize()
Debug("Rehash Test Size: " . size)
testsize :=50000
loop %testsize%
{
	Dic.SetItem(A_Index,A_Index)
	if(Dic.GetSize() != size)
	{
		size := Dic.GetSize()
		Debug("New Size: " . size)
	}
}
loop %testsize%
{
	if(Dic.GetItem(A_Index) <> A_Index)
	{
		Debug("Failed the rehash check test")
		break
	}
}

Debug("Set Get Test after re-hash")

Debug("Test 1, 1 == " . Dic.GetItem(1))
Debug("Test 2, 2 == " . Dic.GetItem(2))
Debug("Test 3, 3 == " . Dic.GetItem(1002))
Debug("Test 4, Item 4 == " . Dic.GetItem("Greeting"))
Debug("Test 5, 1 == " . Dic.KeyExists(1))
Debug("Test 6, 1 == " . Dic.KeyExists(2))
Debug("Test 7, 1 == " . Dic.KeyExists(1002))
Debug("Test 8, 1 == " . Dic.KeyExists("Greeting"))

Dic.DeleteItem(1)
Dic.DeleteItem(1002)
Dic.DeleteItem("Greeting")
Debug("Test 9, 0 == " . Dic.KeyExists(1))
Debug("Test 10, 1 == " . Dic.KeyExists(2))
Debug("Test 11, 0 == " . Dic.KeyExists(1002))
Debug("Test 12, 0 == " . Dic.KeyExists("Greeting"))

Dic.SetItem(1,"New Item 1") 
Dic.SetItem(1002,"New Item 3") 
Debug("Test 13, 1 == " . Dic.KeyExists(1))
Debug("Test 14, 1 == " . Dic.KeyExists(2))
Debug("Test 15, 1 == " . Dic.KeyExists(1002))
Debug("Test 16, 0 == " . Dic.KeyExists("Greeting"))

Debug("Test 17, New Item 1 == " . Dic.GetItem(1))
Debug("Test 18, Item 2 == " . Dic.GetItem(2))
Debug("Test 19, New Item 3 == " . Dic.GetItem(1002))

Dic.DeleteItem(1)
Dic.DeleteItem(2)
Dic.DeleteItem(1002)
Dic.DeleteItem("Greeting")
Debug("Test 21, 0 == " . Dic.KeyExists(1))
Debug("Test 22, 0 == " . Dic.KeyExists(2))
Debug("Test 23, 0 == " . Dic.KeyExists(1002))
Debug("Test 24, 0 == " . Dic.KeyExists("Greeting"))
*/