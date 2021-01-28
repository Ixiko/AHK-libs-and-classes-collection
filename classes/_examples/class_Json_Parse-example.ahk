; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

#Include class_JSON_Parse.ahk

; ALL METHOD IS CASESENTITY

_EXAMPLE1()
_EXAMPLE2()

_EXAMPLE1() {
	sJson = {"user_info":{"email_v":1,"authenticator_enable":0,"nickname":"","level":26,"two_step_verify_enable":0,"fb_account":null},"sensitive_operation":[{"abc":0},{"date":"2018-05-11 23:29:11","country":"VN","operation":"change_password","ip":"27.2.128.91"},true,1999],"country":"VN","init_ip":"27.3.120.180","login_history":[{"date":"2019-01-05 16:27:21","country":"VN","source":"Garena Account Center","ip":"27.3.120.180"},{"date":"2019-01-05 16:27:21","country":"VN","source":"Garena Account Center","ip":"27.3.120.180"},{"date":"2019-01-05 16:25:24","country":"VN","ip":"27.3.120.180","source":"Garena Account Center"}]}
	oJson := _JSON_Parse(sJson)
	; ------------------------------------------------------------
	; Get value at node user_info > level
	; ------------------------------------------------------------
	MsgBox, 4096, "Value at node user_info.level", % oJson.user_info.level
	; ------------------------------------------------------------
	; Array of node begin with → [, so get value from node array we use method .item(iIndex) or .index(iIndex) with index is the element number and begin at 0
	; Get value at node sensitive_operation > array[1] của sensitive_operation > date
	; ------------------------------------------------------------
	MsgBox, 4096, "Value at node user_info.level", % oJson.sensitive_operation.index(1).date
	; ------------------------------------------------------------
	; Get length of array of node, we use method .length
	; ------------------------------------------------------------
	MsgBox, 4096, "length of array sensitive_operation", % oJson.sensitive_operation.length
	; ------------------------------------------------------------
	; Convert json object or node object to string we use method .toStr
	; ------------------------------------------------------------
	MsgBox, 4096, "JSON Object", % oJson.toStr()
	MsgBox, 4096, "Node sensitive_operation", % oJson.sensitive_operation.toStr()
	; ------------------------------------------------------------
	; Want beautify json, we use method .toStr(Indent) or method beautify(Indent), indent can be number of space or any character
	; NOTE: If want beautify, .toStr must be set Indent, .beautify no need cuz default indent = 4
	; ------------------------------------------------------------
	MsgBox, 4096, "Beautify JSON with .beautify", % oJson.beautify() ; Indent := 4
	MsgBox, 4096, "Beautify JSON with .beautify (Indent is char : →)", % oJson.beautify("→")
	MsgBox, 4096, "Beautify JSON with .toStr", % oJson.toStr(4)
	MsgBox, 4096, "Beautify sensitive_operation node", % oJson.sensitive_operation.beautify()
	; ------------------------------------------------------------
	; Get all keys of json we use method .keys()
	; ------------------------------------------------------------
	MsgBox, 4096, "Get all keys of json", % oJson.keys().toStr()
	MsgBox, 4096, "Get all keys at node login_history > array[0]", % oJson.login_history.item(0).keys().toStr()
	; ------------------------------------------------------------
	; Change value of node we assign value directly
	; ------------------------------------------------------------
	oJson.user_info.level := 30
	MsgBox, 4096, "Value of node user_info > level change from 26 to 30", % oJson.user_info.level
	; ------------------------------------------------------------
	; We have 2 ways to add new node to json object
	; 1. First way: use JSON_Parse
	; ------------------------------------------------------------
	; Add new node in user_info.level
	oJson.user_info.level := _JSON_Parse("{""new_node"":""100""}")
	MsgBox, 4096, "Add new node in user_info.level", % oJson.toStr()
	MsgBox, 4096, "Value at node user_info > level > new_node", % oJson.user_info.level.new_node
	; ------------------------------------------------------------
	; 2. Using method .update
	; method .update can use to add, remove or change properties of json with syntax .update(key, value)
	; ------------------------------------------------------------
	; Add new_node to json
	oJson.update("new_node", 123456789)
	MsgBox, 4096, "Add new_node", % oJson.toStr()
	; ------------------------------------------------------------
	; Change value of user_info > level
	oJson.user_info.update("level", 69)
	MsgBox, 4096, "Value of user_info > level change from 30 to 69", % oJson.toStr()
	; ------------------------------------------------------------
	; Change node login_history to null
	; NOTE: if you want update an string then this string must be surrounded by ""
	; login_history below is an examples, 6 → " because AutoHotkey must be double "" to know itself
	oJson.update("login_history", """""")
	MsgBox, 4096, "Node login_history change all array to null", % oJson.toStr()
	; ------------------------------------------------------------
	; Adding new node in node level
	; Simple than example using _JSON_Parse above
	oJson.user_info.update("level", "{""rank"":""gold""}")
	MsgBox, 4096, "Change node level to new node", % oJson.toStr()
	; ------------------------------------------------------------
	; Said about update string again, if you want to update string, the string must be surrounded by ""
	oJson.update("login_history", """Hello World""")
	MsgBox, 4096, "login_history", % oJson.toStr()
	; ------------------------------------------------------------
	; Remove one property then value we put {del}
	oJson.update("sensitive_operation", "{del}")
	MsgBox, 4096, "Node sensitive_operation was delete", % oJson.toStr()
	; ------------------------------------------------------------
	; We can using method .remove(key) to delete 1 node
	; ------------------------------------------------------------
	oJson.remove("user_info")
		MsgBox, 4096, "Node user_info was delete", % oJson.toStr()
}

_EXAMPLE2() {
	sJson =
	(
	{"store":{
		"book":[
			{"category":"reference","author":"Nigel Rees","title":"Sayings of the Century","price":8.95},
			{"category":"fiction","author":"Evelyn Waugh","title":"Sword of Honour","price":12.99},
			{"category":"fiction","author":"Herman Melville","title":"Moby Dick","isbn":"0-553-21311-3","price":8.99},
			{"category":"fiction","author":"J. R. R. Tolkien","title":"The Lord of the Rings","isbn":"0-395-19395-8","price":22.99}
		],
		"bicycle":[
			{"color":"red","price":19.95},
			{"color":"white","price":20.5},
			{"color":"blue","price":16}
		]
		}
	}
	)
	; ------------------------------------------------------------
	oJson := _JSON_Parse(sJson)
	; ------------------------------------------------------------
	; Want to search value of node with condition, we using method .jsonPath(filter) or .filter(filter)
	; LINK: https://github.com/json-path/JsonPath
	; ------------------------------------------------------------
	MsgBox, 4096, "All price of book in store", % oJson.filter("$.store..price").toStr(4)
	MsgBox, 4096, "Author of all book in store", % oJson.filter("$.store.book[*].author").toStr(4)
	MsgBox, 4096, "Author of all book in store and sort from A → Z", % oJson.filter("$.store.book[*].author").sort().toStr(4)
	MsgBox, 4096, "Author of all book in store and sort from Z → A", % oJson.filter("$.store.book[*].author").sort().reverse().toStr(4)
	MsgBox, 4096, "Information of 3rd book (because array begin from 0)", % oJson.filter("$..book[2]").toStr(4)
	MsgBox, 4096, "Information of 1st and 2nd book", % oJson.filter("$..book[0,1]").toStr(4)
	MsgBox, 4096, "Information of books in store have price < 10", % oJson.filter("$.store.book[?(@.price < 10)]").toStr(4)
	MsgBox, 4096, "All name of car", % oJson.filter("$.store.bicycle[*].color").toStr(4)
	; .max() return highest value in array
	MsgBox, 4096, "Car have highest price", % oJson.filter("$.store.bicycle[*].price").max()
	; .min() return lowest value in array
	MsgBox, 4096, "Car have lowest price", % oJson.filter("$.store.bicycle[*].price").min()
}