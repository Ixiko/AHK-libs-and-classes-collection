HashTable
=========

HashTable is an improvement on storing key-value pairs in AutoHotkey Objects.

With HashTable you can
* store any string key without losing access to HashTable's properties or methods
* prevent string keys from being case folded
* prevent floating point keys from being indexed by their string representation instead of their value

HashTable supports the following interfaces from Object:
```AutoHotkey
HashTable.Clone()
HashTable.Delete(Key)
HashTable.HasKey(Key)
HashTable._NewEnum()
```

HashTable has the following additional properties and methods:
```AutoHotkey
HashTable.Count
HashTable.Get(Key)
HashTable.Set(Key, Value)
```

`Count` is a property containing the number of items in the hash table.

`Get(Key)` is a method used to read the value associated with a key.

`Set(Key, Value)` is a method used to write the value associated with a key.

HashTable will throw exceptions upon trying to get or delete nonexistent keys.

:warning: Hash tables are inherently unordered.  When enumerating a hash table, do not expect to process keys in sorted order or the order they were set.  If you need to process keys in a certain order, store them in that order in an Array and enumerate that while operating on the HashTable or use something other than a hash table (like a [red-black tree](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree)).

:warning: Calling any methods other than `_NewEnum()` on a HashTable while enumerating it might cause elements to be processed more than once or skipped.  You can get the desired effect safely by creating a temporary clone of the HashTable and enumerating the clone while operating on the HashTable you intend to keep.

:warning: Floating point keys are rarely useful because it is rarely safe to compare the result of a floating point calculation exactly.  Converting mathematical constants bidirectionally between their names and values is an example of a valid use.

:warning: Object keys are rarely useful because they are indexed by their address.  Two objects might behave identically in every way but if they are not the *same* object (stored in the same location in memory), they will not be associated with the same value.  Using object keys to record visited nodes in a graph traversal algorithm is an example of a valid use.

Design.txt explains the reasoning behind the design decisions.

HashTable is written for AutoHotkey L v1.



####Design



                            HashTable

Everything is defined inside one class to minimize global namespace pollution.

The parts of the Object interface that made sense for an unordered data structure were adopted in the interest of consistency.  A Count property (like most Automation collections have) was used instead of a Length() method because the documentation for Length() indicates it is only useful for ordered data structures.

I considered but rejected the idea of allowing Objects to customize their hashing and equality comparison because it is unlikely it would see much use while AutoHotkey does not support operator overloading.  I avoided using the names I would have used for the methods, Hash() and Eq(Other), so that it could be added in the future.

I prioritized fast lookup over ease of use because some uses of hash tables are performance-sensitive (like call stack frames in an interpreter).  Specifically, chain reordering (described in comments in the source code) makes it unsafe to use most non-destructive methods (like HasKey(Key) and Get(Key)) while enumerating the same hash table.  I made certain that enumeration is safe to use, even in nested loops operating on the same hash table.  This seems like a small price to pay to me because destructive methods (like Set(Key, Value) and Delete(Key)) would inherently cause this problem and working around it is trivial.