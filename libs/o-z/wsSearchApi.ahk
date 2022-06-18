; Title:   	wsSearch(api) - Contextual Web Search
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=10&t=88660
; Author:	Bobo
; Date:   	27.03.2021
; for:     	AHK_L

/*


*/

;	https://rapidapi.com/user/contextualwebsearch
;	https://rapidapi.com/contextualwebsearch/api/web-search			: Quota 100/day, 5/sec
;	https://rapidapi.com/contextualwebsearch/api/keyword-analysis	: Quota 100/day
;

#SingleInstance, Force

MsgBox % wsAutoComplete("butterfinger")			; Suggest as-you-type completion.
MsgBox % wsImage("Taylor Swift")				; Get relevant images for a given query.
MsgBox % wsNews("Boris Johnson")				; Get news articles relevant for a given query.
MsgBox % wsSpell("Cranberry")					; Check spelling.
MsgBox % wsSearch("Ursula von der Leyen")		; Get relevant web pages for a given query.
MsgBox % wsQuerySites("Taylor Swift")			; Get the popular sites for a given search query.
MsgBox % wsQueryKeywords("cyberia game review")	; Get the main keywords for a given search query.
MsgBox % wsQuerySimilar("John Wick 3")			; Get similar queries for a given search query.

wsQuerySimilar(text) {
	url	:=	"api/query/SimilarQueries?q=" . text
	Return URLDownloadToVar(url,A_ThisFunc)
	}

wsQueryKeywords(text) {
	url	:=	"api/query/QueryKeywords?q=" . text
	Return URLDownloadToVar(url,A_ThisFunc)
	}

wsQuerySites(text) {
	url	:=	"api/query/PopularDomainsForQuery?q=" . text
	Return URLDownloadToVar(url,A_ThisFunc)
	}

wsAutoComplete(text) {
	url :=	"api/spelling/AutoComplete?text=" . text
	Return URLDownloadToVar(url,A_ThisFunc)
	}

wsImage(query:="test",pNumber:=1,pSize:=50,ac:="false",ss="false") {
	url	:=	"api/Search/ImageSearchAPI?q="
		. 	 query														; string
		.	"&pageNumber="
		.	 pNumber													; number
		.	"&pageSize="
		.	 pSize														; number (maximum 50)
		.	"&autoCorrect="
		.	 ac															; boolean
		.	"&safeSearch="
		.	 ss															; boolean
	Return URLDownloadToVar(url,A_ThisFunc)
	}

wsNews(query:="test",pNumber:=1,pSize:=50,ac:="false",ss="false") {
	url	:=	"api/search/NewsSearchAPI?q="
		. 	 query
		.	"&pageNumber="
		.	 pNumber
		.	"&pageSize="
		.	 pSize
		.	"&autoCorrect="
		.	 ac
		.	"&fromPublishedDate=null"
		.	"&toPublishedDate=null"
		.	"&safeSearch="
		.	 ss
	Return URLDownloadToVar(url,A_ThisFunc)
	}

wsSpell(text) {
	url	:=	"api/spelling/SpellCheck?text=" . text
	Return URLDownloadToVar(url,A_ThisFunc)
	}

wsSearch(query:="test",pNumber:=1,pSize:=50,ac:="false",ss="false") {
	url	:=	"api/Search/WebSearchAPI?q="
		.	 query
		.	"&pageNumber="
		.	 pNumber
		.	"&pageSize="
		.	 pSize
		.	"&autoCorrect="
		.	 ac
		.	"&safeSearch="
		.	 ss
	Return URLDownloadToVar(url,A_ThisFunc)
	}

URLDownloadToVar(url,func) {
	myAPIKey := <your API key here> !!!
	if func in wsQuerySimilar,wsQueryKeywords,wsQuerySites
		host:="keyword-analysis.p.rapidapi.com", url:="https://" . host . "/" . url
	else
		host:="contextualwebsearch-websearch-v1.p.rapidapi.com", url:="https://" . host . "/" . url
	url :=	StrReplace(url,A_Space,"%20")
	req := ComObjCreate("Msxml2.XMLHTTP")
	req.open("GET", url, False)
	req.setRequestHeader("x-rapidapi-key", myAPIKey)
	req.setRequestHeader("x-rapidapi-host", host)
	req.setRequestHeader("Content-Type","application/json; charset=utf-8")
	req.setRequestHeader("useQueryString","true")
	req.Send(data)
	Return req.responseText
	}