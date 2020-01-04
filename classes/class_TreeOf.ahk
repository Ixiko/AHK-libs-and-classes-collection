/*
	TreeOf.ahk
		- nnnik rev. 0.1
	
	TreeOf is a library that provides implementations for a few commonly 
	used Tree Data structures that I use in my scripts.
	I want to avoid circular references and indirect references are a pain to work with, 
	when the script shuts down.
	The Trees should automatically create a clone of a default object wherever the tree, 
	has data in its structure.
	Access and should be fast memory usage should be low.
	The interfaces should be similar wherever possible and easy to use/remember.
	The Trees should support all data types and names the normal associative array/map supports.
	Base as a string should be supported too and not lead to issues.
	
	Generally there are a few things that can be different about tree data types:
		- Linear vs. back referencing:
		  a linear tree will have branches with only one direct parent.
		  back referencing trees allows each branch to have many parent branches.
		  
		- Leaf Data vs. Branch Data
		  a Leaf Data tree will have its data added as special branches called leafs that have no childs
		  a Branch data tree contains data on each branch
*/



/*
	LinearBranchDataTreeOf:
	A linear tree to represent for example categories (Movies -> Horror -> Slasher)(?)
	Branch Data to allow the creation and modification of data at each branch
	
	This class represents the entire tree - to get the root branch call - getBranch()
	
	The class does not store the branch classes directly.
	Rather it stores the child data and data at each branch and creates new branch classes
	as an interface for the user to access the data it provides.
	That avoids circular references and simplifies the writing of the library at the cost of access speed.
*/

class LinearBranchDataTreeOf {
	
	branchData := {} ;a associative array containing the data elements at each branch (branch as key, data as value)
	children := {} ;the root elements and its children
	
	;tree := new LinearBranchDataTreeOf(dataPrototype)
	;	dataPrototype - the data structure that is cloned for each branch
	;		the object provided by the caller will be automatically cloned
	;		when anything attempts to get the data at a branch
	
	__New(dataPrototype) {
		local
		if (!isObject(dataPrototype)) {
			throw exception("ERR_PROTOTYPE_NOT_OBJECT", -1, "Cannot clone none-object - the provided data is not suitable as prototype")
		}
		this.dataPrototype := dataPrototype
	}
	
	;rootBranch := Tree.getBranch()
	;	gets the root branch
	;	 - rootBranch: a Branch object representing the root of this tree
	;additionally:
	;branch := getBranch(path*)
	;	- path: multiple parameters that name the next descendant of the last descendant of... the root branch
	;	- branch: a branch object representing this branch
	getBranch(path*) {
		local
		static init := 0
		if (!init) {
			baseObj := ObjGetBase(this)
			ObjRawSet(baseObj, "_branchLookup", ObjRawGet(ObjRawGet(baseObj, "Branch"), "_branchLookup")) ;copy branchlookup into this class
			init := 1
		}
		currentBranch := this._branchLookup(path)
		branchClass := this.Branch
		return new branchClass(this, path.clone(), currentBranch)
	}
	
	;branch class: interface used by the user of this class to
	; interact with the branches and the data of the tree structure
	
	class Branch {
		
		;called internally
		; - tree is the tree that contains the branch
		; - path is the path that leads to this branch (an array)
		; - children is the array that contains the children of 
		;   this branch and acts as the key for the data this Branch holds in the trees
		;   branchData array
		__New(tree, path, children) {
			local
			this.tree := tree
			this.path := path
			this.children := children
		}
		
		;data := Branch.getData()
		;	gets the data object this tree holds
		;	if it isn't buffered yet look it up and buffer it
		;	if it doesn't exist yet create it
		getData() {
			local
			this._checkValid()
			if (!data := this.data) { ;if it isnt buffered
				if (!data := this.tree.branchData[this.children]) ;if it isn't created
					this.tree.branchData[this.children] := data := this.tree.dataPrototype.clone() ;create
				this.data := data ;buffer
			}
			if !data
				throw exception("ERR_PROTOTYPE_CLONE_NULL", -1, "Cloning prototype yielded false - the provided object is not suitabe as prototype")
			return data
		}
		
		;child := Branch.getBranch(name)
		;	returns child branch with the name name
		;	- name: the name of a direct child
		;	- child: a branch object representing the child
		;additionally:
		;child := Branch.getBranch(path*)
		;	returns the branch following the path provided:
		/*
			slasherBranch := dataBase.getBranch("movies", "horror", "slasher")
		*/
		;	- path: the name of a children of a children of a children of... this branch
		;	- child: a branch class representing that branch
		getBranch(path*) {
			local
			this._checkValid()
			;funny, getBranch() would return a new instance of this branch
			childBranch := this._branchLookup(path)
			newPath := this.path.clone()
			newPath.push(path*)
			branchClass := ObjGetBase(this) ;create a new branch using this.base as basis
			return new branchClass(this.tree, newPath, childBranch) ;return a new instance
		}
		
		;children := Branch.getBranches()
		;	returns an associative array of all the child branches this branch contains
		;	the key is the name of the child branch, the value is a branch object representing the child branch
		;	will return an empty array if the Branch has no children
		;additionally:
		;children := Branch.getBranches(path*)
		;	returns an associative array of all the child branches at a branch with the path path:
		/*
			horrorBranchChildren := database.getChildBranches("movies", "horror")
		*/
		;	- path: the name of a children of a children of a children of... this branch
		;	- children an associative array 
		getChildBranches(path*) {
			local
			this._checkValid()
			childrenData := this._branchLookup(path)
			children := childrenData.clone()
			branchClass := ObjGetBase(this)
			tree := this.tree
			cPath := this.path.cone()
			cPath.push(path)
			for each, childBranch in this._rawLoop(childrenData) {
				newPath := cPath.clone()
				newPath.push(each)
				ObjRawSet(children, each, new branchClass(tree, newPath, childBranch)) ;objRawSet to avoid issues with .base
			}
			return children
		}
		
		;hasBranch := Branch.hasChild(name)
		;	returns whether this branch has a child branch with the name name
		;additionally:
		;hasBranch := Branch.hasChild(path*)
		;	returns whether a branch with that path exists or not
		;	you know the drill by now
		hasBranch(path*) {
			local
			this._checkValid()
			currentlySearching := this.children
			for each, childName in path
				if (!currentlySearching := ObjRawGet(currentlySearching, childName))
					return 0
			return 1
		}
		
		;childBranch := Branch.addBranch("name")
		;	creates and returns a new child branch with the name name
		;	throws an exception if childBranch already exists
		;additionally:
		;childBranch := Branch.addBranch(path*)
		;	creates and returns a new child branch at the path path
		;	creates all necessary branches it encounters along the way
		;	throws an exception if all branches already exist
		addBranch(path*) {
			local
			this._checkValid()
			currentChilds := this.children
			
			for each, branchPath in path {
				if (!nextChilds := ObjRawGet(currentChilds, branchPath)) {
					nextChilds := {}
					ObjRawSet(currentChilds, branchPath, nextChilds)
				} else if (each = path.length())
					throw exception("ERR_BRANCH_EXISTS", -1, "Branch already exists - The branch that was supposed to be added already exists")
				currentChilds := nextChilds
			}
			
			branchClass := ObjGetBase(this)
			newPath := this.path.clone()
			newPath.push(path*)
			return new branchClass(this.tree, newPath, currentChilds)
		}
		
		;Branch.removeBranch()
		;	removes this branch and all childs - returns nothing
		;	future accesses to any invalid branches will throw
		;additionally:
		;Branch.removeBranch(path*)
		;	removes the branch with the path path and all of its children - returns nothing
		;	future accesses to any invalid branches will throw
		removeBranch(path*) {
			local
			this._checkValid()
			branchData := this.tree.branchData
			if (path.length()=0) { ;if this branch is the target we need to lookup the parent differently
				limit = this.path.length() - 1
				if (limit < 0) { ;reset the tree when removing the root
					this.tree.children := {}
				} else { ;lookup parent if the current branch gets deleted
					currentBranch := this.tree.children
					for each, branchName in this.path {
						currentBranch := ObjRawGet(currentBranch, branchName)
					} until each = limit
					ObjDelete(currentBranch, this.path[limit+1])
				}
				currentContainer := this.children
				this._isValid := this._isValidFalse
			} else {
				childName := path.pop() ;otherwise we can just not do this step of the lookup to get the parent
				parentContainer := this._branchLookup(path) 
				currentContainer := ObjRawGet(parentContainer, childName)
				ObjDelete(parentContainer, childName)
			}
			
			possibleContainers := [] ;need to remove all children from all parents to free the keys
			Loop {
				ObjDelete(branchData, currentContainer)
				namesToRemove := []
				for childName, newChild in this._rawLoop(currentContainer) {
					possibleContainers.push(newChild)
					namesToRemove.push(childName)
				}
				for each, childName in namesToRemove {
					ObjDelete(currentContainer, childName)
				}
			} until !(currentContainer := possibleContainers.pop())
		}
		
		;ancestorBranches := Branch.getAncestors()
		;	gets all the ancestors of this branch in an array and returns it
		;	the root branch will return an empty array
		getAncestors() {
			local
			this._checkValid()
			ancestors := []
			
			branchClass := ObjGetBase(this)
			tree := this.tree
			newPath := []
			currentBranch := tree.children
			
			for each, branchName in this.path {
				ancestors.push(new branchClass(tree, newPath.clone(), currentBranch))
				currentBranch := ObjRawGet(currentBranch, branchName)
				newPath.push(branchName)
			}
			
			return ancestors
		}
		
		;descendatBranches := Branch.getDescendants()
		;	gets all the descendants of this branch in an array and returns it
		;	branches withoutdescendants will return an empty array
		getDescendants() {
			local
			this._checkValid()
			descendants := []
			
			branchClass := ObjGetBase(this)
			tree := this.tree
			
			childrenBacklog := [this.children]
			pathBacklog := [this.path.clone()]
			
			while (currentChildren := childrenBacklog.pop()) { ;recursive loop
				cPath := pathBacklog.pop()
				for branchName, childBranch in this._rawLoop(currentChildren) {
					nextChildren := childBranch
					newPath := cPath.clone()
					newPath.push(branchName)
					descendants.push(new branchClass(tree, newPath, nextChildren))
					
					childrenBacklog.push(nextChildren)
					pathBacklog.push(newPath)
				}
			}
			return descendants
		}
		
		;internal methods for internal use only
		_branchLookup(path) {
			local
			currentlyFoundBranch := this.children
			for each, nameOfSubBranch in path {
				if (!currentlyFoundBranch := ObjRawGet(currentlyFoundBranch, nameOfSubBranch)) {
					throw exception("ERR_BRANCH_NOT_FOUND", -2, "Accessing branch yielded false - the provided path does not exist after " . each . " steps")
				}
			}
			return currentlyFoundBranch
		}
		
		_checkValid() { ;do ot like this overhead
			if (!this._isValid()) {
				throw exception("ERR_BRANCH_INVALID", -2, "Valid check yielded 0 - attempting to access a branch that probably has been removed")
			}
		}
		
		_isValid() { ;initial method to setup valid checking
			local
			limit := this.path.length() - 1
			if (limit < 0) {
				this._isValid := this._isValidRoot
			} else {
				currentParent := this.tree.children
				for each, childName in this.path {
					currentParent := objRawGet(currentParent, childName)
				} until each = limit
				this.parent := currentParent
				this._isValid := this._isValidBranch
			}
			return this._isValid()
		}
		
		_isValidRoot() {
			local
			if (this.tree.children != this.children) {
				this._isValid := this._isValidFalse
				return 0
			}
			return 1
		}
		
		_isValidBranch() {
			local
			path := this.path
			if (ObjRawGet(this.parent, path[path.length()]) != this.children) {
				this._isValid := this._isValidFalse
				return 0
			}
			return 1
		}
		
		_isValidFalse() {
			local
			return 0
		}
		
		;helps with creating enumerators even when _newEnum is overwritten for the object
		_rawLoop(child) { ;does not work with multiple parralel enumerations
			local
			static enumBase := {_NewEnum:""}
			static enum := {base:enumBase}
			static bindFunc
			if (!bindFunc)
				bindFunc := this._rawReturn
			ObjRawSet(enumBase, "_NewEnum", bindFunc.bind(ObjNewEnum(child)))
			return enum
		}
		
		;just returns the first parameter - used in the method above
		_rawReturn() {
			local
			return this
		}
	}
	
}