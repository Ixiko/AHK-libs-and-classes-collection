; Constants.
global LIST_ESC_CHAR := 1
global LIST_PASS_ROW_CHAR := 2
global LIST_COMMENT_CHAR := 3
global LIST_PRE_CHAR := 4
global LIST_ADD_MOD_LABEL_CHAR := 5
global LIST_REMOVE_MOD_LABEL_CHAR := 6
global LIST_IGNORE_MOD_CHAR := 7
global LIST_MOD_BEGIN_CHAR := 8
global LIST_MOD_MODIFY_CHAR := 9
global LIST_MOD_INSERT_CHAR := 10
global LIST_MOD_END_CHAR := 11

; Default chars.
global LIST_DEFAULT_ESC_CHAR := "\"
global LIST_DEFAULT_PASS_ROW_CHAR := "#"
global LIST_DEFAULT_COMMENT_CHAR := ";"
global LIST_DEFAULT_PRE_CHAR := "*"
global LIST_DEFAULT_ADD_MOD_LABEL_CHAR := "+"
global LIST_DEFAULT_REMOVE_MOD_LABEL_CHAR := "-"
global LIST_DEFAULT_IGNORE_MOD_CHAR := "/"
global LIST_DEFAULT_MOD_BEGIN_CHAR := "b"
global LIST_DEFAULT_MOD_MODIFY_CHAR := "m"
global LIST_DEFAULT_MOD_INSERT_CHAR := "i"
global LIST_DEFAULT_MOD_END_CHAR := "e"

; Generic custom class for parsing lists.
class TableList {
	static whiteSpaceChars := [ A_Space, A_Tab ]
	
	__New(lines, chars = "") {
		this.init(lines, chars)
	}
	
	init(lines, char = "") {
		; Load any given chars.
		this.escChar := chars[LIST_ESC_CHAR] ? chars[LIST_ESC_CHAR] : LIST_DEFAULT_ESC_CHAR
		this.passChar := chars[LIST_PASS_ROW_CHAR] ? chars[LIST_PASS_ROW_CHAR] : LIST_DEFAULT_PASS_ROW_CHAR
		this.commentChar := chars[LIST_COMMENT_CHAR] ? chars[LIST_COMMENT_CHAR] : LIST_DEFAULT_COMMENT_CHAR
		this.preChar := chars[LIST_PRE_CHAR] ? chars[LIST_PRE_CHAR] : LIST_DEFAULT_PRE_CHAR
		this.addChar := chars[LIST_ADD_MOD_LABEL_CHAR] ? chars[LIST_ADD_MOD_LABEL_CHAR] : LIST_DEFAULT_ADD_MOD_LABEL_CHAR
		this.remChar := chars[LIST_REMOVE_MOD_LABEL_CHAR] ? chars[LIST_REMOVE_MOD_LABEL_CHAR] : LIST_DEFAULT_REMOVE_MOD_LABEL_CHAR
		this.ignoreModChar := chars[LIST_IGNORE_MOD_CHAR] ? chars[LIST_IGNORE_MOD_CHAR] : LIST_DEFAULT_IGNORE_MOD_CHAR
		this.modBeginChar := chars[LIST_MOD_BEGIN_CHAR] ? chars[LIST_MOD_BEGIN_CHAR] : LIST_DEFAULT_MOD_BEGIN_CHAR
		this.modModifyChar := chars[LIST_MOD_MODIFY_CHAR] ? chars[LIST_MOD_MODIFY_CHAR] : LIST_DEFAULT_MOD_MODIFY_CHAR
		this.modInsertChar := chars[LIST_MOD_INSERT_CHAR] ? chars[LIST_MOD_INSERT_CHAR] : LIST_DEFAULT_MOD_INSERT_CHAR
		this.modEndChar := chars[LIST_DEFAULT_MOD_END_CHAR] ? chars[LIST_DEFAULT_MOD_END_CHAR] : LIST_DEFAULT_MOD_END_CHAR
		
		; Initialize the objects.
		this.mods := Object()
		this.table := Object()
	}
	
	parseFile(fileName, chars = "") {
		if(!fileName || !FileExist(fileName)) {
			; DEBUG.popup(fPath, "File does not exist")
			return ""
		}
		
		; Read the file into an array.
		lines := fileLinesToArray(fileName)
		; DEBUG.popup(fileName, "Filename", lines, "Lines from file")
		
		return this.parseList(lines, chars)
	}
	
	parseList(lines, chars = "") {
		this.init(lines, chars)
		
		currItem := Object()
		
		; Loop through and do work on them.
		For i,row in lines {
			; Strip off any leading whitespace.
			Loop {
				firstChar := SubStr(row, 1, 1)
			
				if(!contains(TableList.whiteSpaceChars, firstChar)) {
					; DEBUG.popup(firstChar, "First not blank, moving on.")
					Break
				}
				
				; originalRow := row
				
				StringTrimLeft, row, row, 1
				
				; DEBUG.popup(originalRow, "Row", firstChar, "First Char", row, "Trimmed")
			}
			
			firstChar := SubStr(row, 1, 1)
			
			; Ignore it entirely if it's an empty line or beings with ; (a comment).
			if(firstChar = this.commentChar || firstChar = "") {
				; DEBUG.popup(firstChar, "Comment or blank line")
			
			; Special row for modifying the current modifications in play.
			} else if(firstChar = "[") {
				; DEBUG.popup(row, "Modifier Line", firstChar, "First Char")
				this.updateMods(row)
			
			; Special row for label/title later on, leave it untouched.
			} else if(firstChar = this.passChar) {
				; DEBUG.popup(row, "Hash Line", firstChar, "First Char")
				currItem := Object()
				currItem.Insert(row)
				this.table.Insert(currItem)
			
			; Your everyday line, the average Joe-Billy-Bob-Jacob.
			} else {
				; originalRow := row
				
				; Apply any active modifications.
				currItem := this.applyMods(row)
				; DEBUG.popup(originalRow, "Normal Row", this.mods, "Current Mods", currItem, "Processed Row")
				
				this.table.Insert(currItem)
			}
			
		}
		
		return this.table
	}

	; Kill mods with the given label.
	killMods(killLabel = 0) {
		; DEBUG.popup(killLabel, "Killing all mods with label")
		
		i := 1
		modsLen := this.mods.MaxIndex()
		Loop, %modsLen% {
			if(this.mods[i].label = killLabel) {
				; DEBUG.popup(mods[i], "Removing Mod")
				this.mods.Remove(i)
				i--
			}
			i++
		}
	}

	; Update the given modifier string given the new one.
	updateMods(newRow) {
		; DEBUG.popup(this.mods, "Current Mods", newRow, "New Mod")
		
		label := 0
		
		; Strip off the square brackets.
		newRow := SubStr(newRow, 2, -1)
		
		; If it's just blank, all previous mods are wiped clean.
		if(newRow = "") {
			this.mods := Object()
		} else {
			; Check for a remove row label.
			; Assuming here that it will be the first and only thing in the mod row.
			if(SubStr(newRow, 1, 1) = this.remChar) {
				remLabel := SubStr(newRow, 2)
				this.killMods(remLabel)
				label := 0
				
				return
			}
			
			; Split new into individual mods.
			newModsSplit := specialSplit(newRow, "|", [this.escChar])
			; newModsSplit := specialSplit(newRow, "|", this.escChar)
			; DEBUG.popup(newRow, "Row", newModsSplit, "Row Split")
			For i,currMod in newModsSplit {
				firstChar := SubStr(currMod, 1, 1)
				
				; Check for an add row label.
				if(i = 1 && firstChar = this.addChar) {
					label := SubStr(currMod, 2)
					; DEBUG.popup(label, "Adding label")
				} else {
					; Allow backwards stacking - that is, a later mod can go first in mod order.
					if(firstChar = this.preChar) {
					
						; preMod := true
						
						newMod := this.parseModLine(SubStr(currMod, 2), label)
						this.mods := insertFront(this.mods, newMod)
					} else {
						newMod := this.parseModLine(currMod, label)
						this.mods.Insert(newMod)
					}
				}
				
				; DEBUG.popup(currMod, "Mod processed", firstChar, "First Char", label, "Label", preMod, "Premod", this.mods, "Current Mods")
			}
		}
	}

	; Takes a modifier string and spits out the mod object/array. Assumes no [] around it, and no special chars at start.
	parseModLine(modLine, label = 0) {
		; origModLine := modLine
		
		currMod := new TableListMod(modLine, 1, 0, "", label, "")
		
		; Next, check to see whether we have an explicit bit. Syntax: starts with {#}
		firstChar := SubStr(modLine, 1, 1)
		if(firstChar = "{") {
			closeCurlyPos := InStr(modLine, "}")
			currMod.bit := SubStr(modLine, 2, closeCurlyPos - 2)
			; DEBUG.popup(currMod.bit, "Which bit")
			
			modLine := SubStr(modLine, closeCurlyPos + 1)
			; DEBUG.popup(modLine, "Trimmed current mod")
		}
		
		; First character of remaining string indicates what sort of operation we're dealing with: b, e, or m.
		currMod.operation := Substr(modLine, 1, 1)
		if(currMod.operation = this.modBeginChar) {
			currMod.start := 1
		} else if(currMod.operation = this.modEndChar) {
			currMod.start := -1
		}
		
		; Shave that off too.
		StringTrimLeft, modLine, modLine, 2
		
		; Figure out the rest of the innards: parentheses and string.
		commaPos := InStr(modLine, ",")
		closeParenPos := InStr(modLine, ")")
		
		; Snag the rest of the info.
		if(SubStr(modLine, 1, 1) = "(") {
			currMod.text := SubStr(modLine, closeParenPos + 1)
				if(commaPos) { ; m: operation, two arguments in parens.
					currMod.start := SubStr(modLine, 2, commaPos - 2)
					currMod.len := SubStr(modLine, commaPos + 1, closeParenPos - (commaPos + 1))
				} else {
					if(operation = this.modModifyChar) {
						currMod.start := SubStr(modLine, 2, closeParenPos - 2)
						currMod.len := 0
					} else {
						currMod.len := SubStr(modLine, 2, closeParenPos - 2)
					}
				}
		} else {
			currMod.text := modLine
		}
		
		; DEBUG.popup(origModLine, "Mod Line", currMod, "Mod processed", commaPos, "Comma position", closeParenPos, "Close paren position")
		return currMod
	}

	; Apply currently active string modifications to given row.
	applyMods(row) {
		; Split up the row by tabs.
		rowBits := specialSplit(row, A_Tab, [this.escChar])
		
		; DEBUG.popup(row, "Row", rowBits, "Row bits")
		; origBits := rowBits
		
		; If there aren't any mods, just split the row and send it on.
		if(this.mods.MaxIndex() != "") {
			; Apply the mods.
			For i,currMod in this.mods {
				; beforeBits := rowBits
				
				rowBits := currMod.executeMod(rowBits)
				
				; DEBUG.popup(beforeBits, "Row bits", currMod, "Mod to apply", rowBits, "Processed bits")
			}
			
			; DEBUG.popup(origBits, "Row bits", rowBits, "Finished bits")
			return rowBits
		}
		
		return rowBits
	}
}