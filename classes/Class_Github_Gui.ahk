Gui(do:=""){
	static
	if (do="expandsettings")
		return TV_Modify(TreeView.settings,"Expand")
	Gui,+hwndmain
	Gui,Add,TreeView,w300 h400 gtree AltSubmit
	Gui,Add,Button,w300 gcontext Default,Context Sensitive Button
	Gui,Add,StatusBar,,Rate Limit
	TreeView:=[],repo:=[],hwnd(1,main),git:=new github()
	Gosub populate
	Gui,Show,,Github
	return
	tree:
	ei:=A_EventInfo
	if !ei
		return
	if set:=treeview.set[ei]
		GuiControl,,Button1,% "Edit Repository Setting " github_user_info[treeview.set[ei]]
	else if(ei=TreeView.rep)
		GuiControl,,Button1,Refresh Repository List
	else if(TV_GetParent(ei)=TreeView.rep)
		GuiControl,,Button1,Refresh Repository
	else if(ei=TreeView.newrepo)
		GuiControl,,Button1,Add New Repositiory
	else if(ei=treeview.settings){
		exp:=TV_Get(ei,"Expand")?"Contract":"Expand"
		GuiControl,,Button1,%exp% Settings Info
	}else if(TreeView.files[ei]){
		GuiControl,,Button1,File Info
	}else if(TreeView.Help[ei]){
		m("Drag/Drop files here do upload them to the selected Repository")
	}
	return
	context:
	ControlGetText,do,Button1,% hwnd([1])
	if (do="refresh repository list")
		git.getrepos()
	else if InStr(do,"settings info"){
		exp:=TV_Get(TV_GetSelection(),"Expand")?"-Expand":"Expand",TV_Modify(TV_GetSelection(),exp)
		exp:=TV_Get(ei,"Expand")?"Contract":"Expand"
		GuiControl,,Button1,%exp% Settings Info
		return
	}else if(InStr(do,"Edit Repository Setting")){
		node:=settings.ssn("//github"),set:=treeview.set[TV_GetSelection()]
		InputBox,value,Value Required,% "Enter a value for " github_user_info[set],,,,,,,,% ssn(node,"@" set).text
		if !ErrorLevel
			node.SetAttribute(set,value),TV_Modify(TV_GetSelection(),"",github_user_info[set] " = " value)
		return
	}else if(do="Add New Repositiory"){
		InputBox,name,Enter the name of this repo,Name?
		git.CreateRepo(name),git.getrepos()
		Gosub populate
		return
	}else if(do="Refresh Repository"){
		GuiControl,1:-Redraw,SysTreeView321
		TV_GetText(repo,tt:=TV_GetSelection())
		sha:=git.getref(repo),info:=git.Send("GET",git.url "/repos/" git.owner "/" repo "/git/trees/" sha git.token "&recursive=1"),top:=repository.ssn("//repos/repo[@name='" repo "']")
		while,rt:=TV_GetChild(tt)
			TV_Delete(rt)
		for a,b in StrSplit(info,"{"){
			if InStr(b,"path"){
				pos:=1,ea:=[]
				while,pos:=RegExMatch(b,"OU)(.*):(.*),",out,pos)
					ea[Trim(out.1,Chr(34))]:=Trim(out.2,Chr(34)),pos:=out.Pos(2)+out.len(2)+1
				if !repository.ssn("//repo[@name='" repo "']/file[@path='" ea.path "']")
					repository.under({under:top,node:"file",att:{path:ea.path,mode:ea.mode,sha:ea.sha}})
				if (ea.mode!=040000)
					TreeView.files[TV_Add(ea.path,tt,"Sort")]:=ea.sha
			}
		}
		TV_Modify(tt,"Expand")
		GuiControl,1:+Redraw,SysTreeView321
	}else if((do="File Info")){
		TV_GetText(repo,TV_GetParent(TV_GetSelection()))
		json:=git.Send("GET",git.url "/repos/" git.owner "/" repo "/git/blobs/" TreeView.files[TV_GetSelection()] git.token)
		text:=git.find("content",json)
		if InStr(json,Chr(34) "base64" Chr(34)){
			StringReplace,string,text,\n,,all
			DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",0,"uint*",cp:=0,"ptr",0,"ptr",0) ;getsize
			VarSetCapacity(bin,cp)
			DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",&bin,"uint*",cp,"ptr",0,"ptr",0)
			text:=StrGet(&bin,cp,"utf-8")
		}
		m(text)
	}
	SB_SetText("Rate Limit = " git.http.getresponseheader("X-RateLimit-Remaining"),1)
	return
	populate:
	GuiControl,1:-Redraw,SysTreeView321
	repos:=repository.sn("//repos/repo")
	TV_Delete(),TreeView.rep:=TV_Add("Repositories")
	Loop,% repos.length{
		rr:=xml.ea(repos.item[A_Index-1]),parent:=TV_Add(rr.name,TreeView.rep),TreeView.repository[parent]:=rr.name
		ff:=sn(repos.item[A_Index-1],"*")
		while,f1:=ff.item[A_Index-1],ea:=xml.ea(f1){
			if (ea.mode!=040000)
				TreeView.files[TV_Add(ea.path,parent,"Sort")]:=ea.sha
		}
	}
	TreeView.newrepo:=TV_Add("Add New Repository")
	github_user_info:={owner:"Owner (GitHub Username)",email:"Email",name:"Your Full Name",token:"Token"},TreeView.settings:=TV_Add("Settings")
	ea:=settings.ea("//github")
	for a,b in StrSplit("owner,email,name",",")
		TreeView.set[TV_Add(github_user_info[b] " = " ea[b],TreeView.settings)]:=b
	TreeView.set[TV_Add("Github Token = " RegExReplace(ea.token,".","*"),TreeView.settings)]:="token"
	TreeView.Help[TV_Add("Help")]:=1
	TV_Modify(TreeView.rep,"Expand")
	GuiControl,1:+Redraw,SysTreeView321
	return
	GuiDropFiles:
	if !repo:=TreeView.repository[TV_GetSelection()]
		return m("Please select a repository to send the files to")
	for a,b in StrSplit(A_GuiEvent,"`n"){
		FileRead,bin,% "*c " b
		FileGetSize,size,%b%
		DllCall("Crypt32.dll\CryptBinaryToStringW",Ptr,&bin,UInt,size,UInt,1,UInt,0,UIntP,Bytes)
		VarSetCapacity(out,Bytes*2)
		DllCall("Crypt32.dll\CryptBinaryToStringW",Ptr,&bin,UInt,size,UInt,1,Str,out,UIntP,Bytes)
		StringReplace,out,out,`r`n,,All
		SplitPath,b,filename
		InputBox,message,Commit Message,Enter a quick message
		InputBox,filename,New Filename/directory,Directory/Filename,,,,,,,,%filename%
		ea:=settings.ea("//github")
		http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
		url:=git.url "/repos/" git.owner "/" repo "/contents/" filename git.token
		name:=git.name,email:=git.email
		json={"message":"%message%","committer":{"name":"%name%","email":"%email%"},"content":
		json.= Chr(34) out chr(34) "}"
		http.open("PUT",url)
		http.Send(json)
		m(Clipboard:=http.ResponseText)
	}
	return
}