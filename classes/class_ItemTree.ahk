#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
* Author: Sid2934
*
* This script is going to be used to make a tree cand node class that will enable a searchable tree structure
*/

;This is simply a test to see if this works as a null pointer.
;If it does it is juust simply here to simplify readability
;of the code
null :=

class Node{

	;<summary>
	;This field cotains the value of the node
	; This is defaulted to a value of null
	;</summary>
	;<dataType>String</dataType>
	value  := null

	;<summary>
	;This field cotains the value of the node
	;</summary>
	;<dataType>Array of Nodes</dataType>
	children := [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]

	__New(v, noChildren := false){
		;MsgBox % "VALUE: "v
		this.value := v
		;MsgBox % this.value
		if(noChildren == true){
			this.children := "No Children"
		}
		else{
			this.children := [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
			;MsgBox % this.children[16]
		}
	}

}

class Tree{

	;<summary>
	;This field is the node at the root of of the tree
	;</summary>
	;<dataType>Node</dataType>
	rootNode := null
	
	__New(){
		this.rootNode := new Node("ROOT", false)
	}
	
	;<summary>
	;This method will be used to add each game item from the game item .csv file to the (possibly HUGE) tree structure
	;</summary>
	;<param="hexValue">This parameter is a string of the hex values of the item with only the hex characters 0-F</param>
	;<param="itemName">The name of the current item being added</param>
	;<param="ByRef currentNode">This is the current level node it is set to a default of the root is only non default when called recursivly. They ByRef makes it reference the object</param>
	;<returnType>Void</returnType>
	Add(hexValues, itemName, ByRef currentNode,  arrayLocation := 1){
		
		;MsgBox % "Array Location: "arrayLocation
				;MsgBox % currentNode.value
				;tCounter := 1
				;loop 16{
				;		MsgBox % currentNode.children[tCounter]
				;		tCounter++
				;}
		StringSplit, output, hexValues
			currentChar := output%arrayLocation%
			;MsgBox %  currentChar
			tempValue := this.customHexCharToDecimal(currentChar)
			;MsgBox % "Temp Value: "tempValue
			if(arrayLocation == output0){
				;MsgBox, BreakPoint This 3
				currentNode.children[tempValue] := new Node(itemName, true)
				return
			}
			;Below this point I need to look into how to reference nodes down the tree from the root.
			;This is needed so that I can manipulate the child array of the next Node down to add the item
			;I believe that referencing the Tree is the best way to go and make a reference tree who's root
			;changes as the tree is transversed. This may not work but where to start
			if(currentNode[tempValue] == null){
				;MsgBox, BreakPoint This 1
				;MsgBox % currentNode.children[tempValue]
				currentNode.children[tempValue] := new Node(output%arrayLocation%, false) ; <==== this is not for sure but is close if not right
				;MsgBox % currentNode.children[tempValue].value
				this.Add(hexValues, itemName, currentNode.children[tempValue], arrayLocation + 1)
			}
			else{
				;MsgBox, BreakPoint This 2 
				this.Add(hexValues, itemName, currentNode[tempValue], arrayLocation++)
			}
	}
	
	;<summary>
	;This method will convert a single character from 0-F to the correct decimal value
	;This method is written from scratch and non optimized form the simple reason that
	;I could not figure out a pre-existing way to do it
	;Suggestions are MORE THAN WELCOME ;)
	;</summary>
	;<param="hexChar">A single character containing a value of 0-9 and A-F </param>
	;<returnType>Void</returnType>
	customHexCharToDecimal(hexChar){
		StringUpper, hexChar, hexChar
		Transform,  OutputVar, Asc, %hexChar%
		 if(OutputVar >=48 && OutputVar <=57 ){
			return OutputVar - 47
		}
		else if(OutputVar >= 65 && OutputVar <= 90){
			return OutputVar - 54
		}
		else{
			throw Exception("Invalid Parameter Exception", -1)
		}
		
	}
	
	;<summary>
	;This method will convert a string of hex values that represent the hex values at the test points for an item
	;The last parameter is only to be used by the recursive function call
	;</summary>
	;<param="fullHexValue">The full string of hex values </param>
	;<returnType>String</returnType>
	searchItemByHex(fullHexValue, ByRef currentNode, counter := 1){
		StringSplit, charArray, fullHexValue
		;MsgBox % currentNode.value
		if(currentNode.children == "No Children"){
			return currentNode.value
		}
		else if(counter > charArray0 || currentNode.value == null){
			return "Not Found"
		}
		return this.searchItemByHex(fullHexValue, currentNode.children[this.customHexCharToDecimal(charArray%counter%)], counter + 1)
		
	}
	
	;<summary
	;This method returns a string containing the information of the item
	;</summary>
	;<param="delim">This option param is for a Delimiter between each property DEFAULT is a space</param>
	;<returnType>String</returnType>
	;<returns>String of propertires</returns>
	ToString(delim := " "){
		currentNode := this.rootNode
		counter := 1
		loop {
		
			;MsgBox % "Node Value: "currentNode.value
			;MsgBox % "Counter: "counter
			;MsgBox % "Result: "IsObject(currentNode.children[counter])
			if((IsObject(currentNode.children[counter]) && currentNode.children[counter] .value== null) || !IsObject(currentNode.children[counter] )){
				;MsgBox, BreakPoint 0
				counter++
			}
			else{
				;MsgBox, BreakPoint 1
				currentNode := currentNode.children[counter]
				counter := 1
			}
			
			if(currentNode.children == "No Children"){
				;MsgBox, BreakPoint
					return currentNode.value
			}
			
			;if(counter >= 100){
			;		MsgBox, Hit Limit
			;		return
			;}*
		}		
		;return "Not Implemented"
	}
}