class github{
	static http:=[]
	__New(){
		ea:=settings.ea("//github")
		if !(ea.owner&&ea.token)
			return Gui("expandsettings"),m("Please setup your Github info")
		for a,b in ea
			this[a]:=b
		this.http:=ComObjCreate("WinHttp.WinHttpRequest.5.1"),this.token:="?access_token=" ea.token,this.tok:="&access_token=" ea.token
		this.url:="https://api.github.com"
		return this
	}
	CreateRepo(name,description="Created with AHK Studio",homepage="http://www.maestrith.com",private="false",issues="false",wiki="true",downloads="true"){
		url:=this.url "/user/repos" this.token
		this.http.Open("POST",url)
		json={"name":"%name%","description":"%description%","homepage":"%homepage%","private":%private%,"has_issues":%issues%,"has_wiki":%wiki%,"has_downloads":%downloads%,"auto_init":"true"}
		this.http.Send(json)
		return this.http.ResponseText
	}
	getrepos(){
		;GET /users/:username/repos
		if !this.owner
			return Gui("expandsettings"),m("Please setup your Github info")
		url:=this.url "/users/" this.owner "/repos" this.token,info:=this.Send("GET",url),LV_Delete()
		for a,b in StrSplit(info,"{" Chr(34) "id" Chr(34) ":"){
			if (b="[")
				continue
			RegExMatch(b,"U),.name.:.(.*)" Chr(34),name),RegExMatch(b,"(\d+)",id)
			if !repository.ssn("//repos/repo[@name='" name1 "']")
				repository.Add({path:"repos/repo",att:{name:name1,id:id},dup:1})
		}
		SB_SetText("Rate Limit = " this.http.getresponseheader("X-RateLimit-Remaining"),1)
		SetTimer,populate,-1
	}
	delete(repo,filenames){
		url:=this.url "/repos/" this.owner "/" repo "/commits" this.token ;get the tree sha
		tree:=this.sha(this.Send("GET",url))
		url:=this.url "/repos/" this.owner "/" repo "/git/trees/" tree "?recursive=1" this.tok ;full tree info
		info:=this.Send("GET",url),fz:=[],info:=SubStr(info,InStr(info,"tree" Chr(34)))
		for a,b in strsplit(info,"{"){
			if path:=this.find("path",b)
				fz[path]:=this.find("sha",b)
		}
		for c in filenames{
			StringReplace,cc,c,\,/,All
			url:=this.url "/repos/" this.owner "/" repo "/contents/" cc this.token,sha:=fz[cc]
			json={"message":"Deleted","sha":"%sha%"}
			this.http.Open("DELETE",url),this.http.send(json)
			if (this.http.status!=200)
				m("Error deleting " c,this.http.ResponseText)
			FileDelete,github\%repo%\%c%
		}
	}
	find(search,text){
		RegExMatch(text,"U)" Chr(34) search Chr(34) ":(.*),",found)
		return Trim(found1,Chr(34))
	}
	sha(text){
		RegExMatch(this.http.ResponseText,"U)" Chr(34) "sha" Chr(34) ":(.*),",found)
		return Trim(found1,Chr(34))
	}
	getref(repo){
		url:=this.url "/repos/" this.owner "/" repo "/git/refs" this.token
		this.cmtsha:=this.sha(this.Send("GET",url)),url:=this.url "/repos/" this.owner "/" repo "/commits/" this.cmtsha this.token
		RegExMatch(this.Send("GET",url),"U)tree.:\{.sha.:.(.*)" Chr(34),found)
		return found1
	}
	blob(repo,text){
		text:=this.utf8(text)
		json={"content":"%text%","encoding":"utf-8"}
		return this.sha(this.Send("POST",this.url "/repos/" this.owner "/" repo "/git/blobs" this.token,json))
	}
	send(verb,url,data=""){
		this.http.Open(verb,url),this.http.send(data)
		return this.http.ResponseText
	}
	tree(repo,parent,blobs){
		url:=this.url "/repos/" this.owner "/" repo "/git/trees" this.token ;POST /repos/:owner/:repo/git/trees
		json={"base_tree":"%parent%","tree":[
		for a,blob in blobs{
			add={"path":"%a%","mode":"100644","type":"blob","sha":"%blob%"}, 
			json.=add
		}
		return this.sha(this.Send("POST",url,Trim(json,",") "]}"))
	}
	commit(repo,tree,parent,message="Updated the file",name="placeholder",email="placeholder@gmail.com"){
		message:=this.utf8(message)
		parent:=this.cmtsha,url:=this.url "/repos/" this.owner "/" repo "/git/commits" this.token
		json={"message":"%message%","author":{"name": "%name%","email": "%email%"},"parents":["%parent%"],"tree":"%tree%"}
		return this.sha(this.Send("POST",url,json))
	}
	ref(repo,sha){
		url:=this.url "/repos/" this.owner "/" repo "/git/refs/heads/master" this.token
		this.http.Open("PATCH",url)
		json={"sha":"%sha%","force":true}
		this.http.send(json)
		SplashTextOff
		return this.http.status
	}
	Limit(){
		return this.Send("GET",this.url "/rate_limit" this.token)
	}
	CreateFile(repo,filefullpath,text,commit="First Commit",realname="Testing",email="Testing"){
		SplitPath,filefullpath,filename
		url:=this.url "/repos/" this.owner "/" repo "/contents/" filename this.token,file:=this.utf8(text)
		json={"message":"%commit%","committer":{"name":"%realname%","email":"%email%"},"content": "%file%"}
		this.http.Open("PUT",url),this.http.send(json),RegExMatch(this.http.ResponseText,"U)"Chr(34) "sha" Chr(34) ":(.*),",found)
	}
	utf8(info){
		info:=RegExReplace(info,"([" Chr(34) "\\])","\$1")
		for a,b in {"`n":"\n","`t":"\t","`r":""}
			StringReplace,info,info,%a%,%b%,All
		return info
	}
}