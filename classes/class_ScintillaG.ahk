;#include %A_ScriptDir%\class_RemoteBuf.ahk

Class _Scintilla {
	var hModule:=DllCall("LoadLibrary","Str",A_ScriptDir "\SciLexer.dll")
	var hwnd:=0,DirectPtr:=0
	__New(hWnd,x,y,w,h){
		global _RemoteBuf
		static WS_CHILD:=0x40000000,WS_VISIBLE:=0x10000000,WS_EX_CLIENTEDGE:=0x200
		
		If (!(this.hWnd:=DllCall("CreateWindowEx","Uint",WS_EX_CLIENTEDGE,"Str","Scintilla","Str","Test","Uint",WS_CHILD|WS_VISIBLE,"Uint",x,"Uint",y,"Uint",w,"Uint",h,"PTR",hWnd,"Uint",0,"PTR",this.hModule,"Uint",0))
			|| !(this.Func:=DllCall("GetProcAddress","Uint",this.hModule,"AStr","Scintilla_DirectFunction","UPTR"))
			|| !(this.DirectPtr:=DllCall("SendMessage","PTR",this.hwnd,"UInt",2185,"Uint",0,"Uint",0,"UPTR")) ) ;SCI_GETDIRECTPOINTER
				Return DllCall("MessageBox","PTR",0,"Str","Failed to get Function pointer","Str","FAIL","UInt",0)
		this.buf:=new _RemoteBuf(this.hwnd)
		this.buff:=new _RemoteBuf(this.hwnd)
	}
	__Delete(){
		DllCall("DestroyWindow","PTR",this.hwnd),this.buf:="",this.buff:=""
	}
	ADDREFDOCUMENT(pDoc=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2376,"Uint",0,"Uint",pDoc)
	}
	ADDSELECTION(caret=0,anchor=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2573,"Uint",caret,"Uint",anchor)
	}
	ADDSTYLEDTEXT(s=""){
		this.buf.Write(s,0,"UTF-16")
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2002,"Uint",StrLen(s)*2,"Uint",this.buf.bufAdr)
	}
	ADDTEXT(s=""){
		this.buf.Write(s,0,"CP0")
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2001,"Uint",StrLen(s),"Uint",this.buf.bufAdr)
	}
	ADDUNDOACTION(token=0,flags=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2560,"Uint",token,"Uint",flags)
	}
	ALLOCATE(bytes=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2446,"Uint",bytes,"Uint",0)
	}
	ANNOTATIONCLEARALL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2547,"Uint",0,"Uint",0)
	}
	ANNOTATIONGETLINES(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2546,"Uint",line,"Uint",0)
	}
	ANNOTATIONGETSTYLE(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2543,"Uint",line,"Uint",0)
	}
	ANNOTATIONGETSTYLEOFFSET(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2551,"Uint",0,"Uint",0)
	}
	ANNOTATIONGETSTYLES(line=0,styles=""){
		this.buf.Open(1024),DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2545,"Uint",line,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	ANNOTATIONGETTEXT(line=0,text=""){
		this.buf.Open(1024),DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2541,"Uint",line,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	ANNOTATIONGETVISIBLE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2549,"Uint",0,"Uint",0)
	}
	ANNOTATIONSETSTYLE(line=0,style=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2542,"Uint",line,"Uint",style)
	}
	ANNOTATIONSETSTYLEOFFSET(style=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2550,"Uint",style,"Uint",0)
	}
	ANNOTATIONSETSTYLES(line=0,styles=""){
		this.buf.Write(styles)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2544,"Uint",line,"Uint",this.buf.bufAdr)
	}
	ANNOTATIONSETTEXT(line=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2540,"Uint",line,"Uint",this.buf.bufAdr)
	}
	ANNOTATIONSETVISIBLE(visible=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2548,"Uint",visible,"Uint",0)
	}
	APPENDTEXT(length=0,s=""){
		this.buf.Write(s)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2282,"Uint",length,"Uint",this.buf.bufAdr)
	}
	ASSIGNCMDKEY(keyDefinition=0,sciCommand=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2070,"Uint",keyDefinition,"Uint",sciCommand)
	}
	AUTOCACTIVE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2102,"Uint",0,"Uint",0)
	}
	AUTOCCANCEL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2101,"Uint",0,"Uint",0)
	}
	AUTOCCOMPLETE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2104,"Uint",0,"Uint",0)
	}
	AUTOCGETAUTOHIDE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2119,"Uint",0,"Uint",0)
	}
	AUTOCGETCANCELATSTART(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2111,"Uint",0,"Uint",0)
	}
	AUTOCGETCHOOSESINGLE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2114,"Uint",0,"Uint",0)
	}
	AUTOCGETCURRENT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2445,"Uint",0,"Uint",0)
	}
	AUTOCGETCURRENTTEXT(){
		DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2610,"Uint",this.buf.Open(DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2610,"Uint",0,"Uint",0)),"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	AUTOCGETDROPRESTOFWORD(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2271,"Uint",0,"Uint",0)
	}
	AUTOCGETIGNORECASE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2116,"Uint",0,"Uint",0)
	}
	AUTOCGETMAXHEIGHT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2211,"Uint",0,"Uint",0)
	}
	AUTOCGETMAXWIDTH(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2209,"Uint",0,"Uint",0)
	}
	AUTOCGETSEPARATOR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2107,"Uint",0,"Uint",0)
	}
	AUTOCGETTYPESEPARATOR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2285,"Uint",0,"Uint",0)
	}
	AUTOCPOSSTART(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2103,"Uint",0,"Uint",0)
	}
	AUTOCSELECT(select=""){
		this.buf.Write(select)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2108,"Uint",0,"Uint",this.buf.bufAdr)
	}
	AUTOCSETAUTOHIDE(autoHide=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2118,"Uint",autoHide,"Uint",0)
	}
	AUTOCSETCANCELATSTART(cancel=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2110,"Uint",cancel,"Uint",0)
	}
	AUTOCSETCHOOSESINGLE(chooseSingle=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2113,"Uint",chooseSingle,"Uint",0)
	}
	AUTOCSETDROPRESTOFWORD(dropRestOfWord=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2270,"Uint",dropRestOfWord,"Uint",0)
	}
	AUTOCSETFILLUPS(chars=""){
		this.buf.Write(chars)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2112,"Uint",0,"Uint",this.buf.bufAdr)
	}
	AUTOCSETIGNORECASE(ignoreCase=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2115,"Uint",ignoreCase,"Uint",0)
	}
	AUTOCSETMAXHEIGHT(rowCount=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2210,"Uint",rowCount,"Uint",0)
	}
	AUTOCSETMAXWIDTH(characterCount=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2208,"Uint",characterCount,"Uint",0)
	}
	AUTOCSETSEPARATOR(eparator=""){
		this.buf.Write(eparator)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2106,"Uint",this.buf.bufAdr,"Uint",0)
	}
	AUTOCSETTYPESEPARATOR(eparatorCharacter=""){
		this.buf.Write(eparatorCharacter)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2286,"Uint",this.buf.bufAdr,"Uint",0)
	}
	AUTOCSHOW(lenEntered=0,list=""){
		this.buf.Write(list)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2100,"Uint",lenEntered,"Uint",this.buf.bufAdr)
	}
	AUTOCSTOPS(chars=""){
		this.buf.Write(chars)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2105,"Uint",0,"Uint",this.buf.bufAdr)
	}
	BEGINUNDOACTION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2078,"Uint",0,"Uint",0)
	}
	BRACEBADLIGHT(pos1=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2352,"Uint",pos1,"Uint",0)
	}
	BRACEHIGHLIGHT(pos1=0,pos2=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2351,"Uint",pos1,"Uint",pos2)
	}
	BRACEMATCH(pos=0,maxReStyle=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2353,"Uint",pos,"Uint",maxReStyle)
	}
	CALLTIPACTIVE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2202,"Uint",0,"Uint",0)
	}
	CALLTIPCANCEL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2201,"Uint",0,"Uint",0)
	}
	CALLTIPPOSSTART(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2203,"Uint",0,"Uint",0)
	}
	CALLTIPSETBACK(colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2205,"Uint",colour,"Uint",0)
	}
	CALLTIPSETFORE(colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2206,"Uint",colour,"Uint",0)
	}
	CALLTIPSETFOREHLT(colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2207,"Uint",colour,"Uint",0)
	}
	CALLTIPSETHLT(hlStart=0,hlEnd=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2204,"Uint",hlStart,"Uint",hlEnd)
	}
	CALLTIPSHOW(posStart=0,definition=""){
		this.buf.Write(definition)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2200,"Uint",posStart,"Uint",this.buf.bufAdr)
	}
	CALLTIPUSESTYLE(tabsize=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2212,"Uint",tabsize,"Uint",0)
	}
	CANPASTE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2173,"Uint",0,"Uint",0)
	}
	CANREDO(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2016,"Uint",0,"Uint",0)
	}
	CANUNDO(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2174,"Uint",0,"Uint",0)
	}
	CHANGELEXERSTATE(startPos=0,endPos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2617,"Uint",startPos,"Uint",endPos)
	}
	CHARPOSITIONFROMPOINT(x=0,y=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2561,"Uint",x,"Uint",y)
	}
	CHARPOSITIONFROMPOINTCLOSE(x=0,y=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2562,"Uint",x,"Uint",y)
	}
	CHOOSECARETX(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2399,"Uint",0,"Uint",0)
	}
	CLEAR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2180,"Uint",0,"Uint",0)
	}
	CLEARALL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2004,"Uint",0,"Uint",0)
	}
	CLEARALLCMDKEYS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2072,"Uint",0,"Uint",0)
	}
	CLEARCMDKEY(keyDefinition=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2071,"Uint",keyDefinition,"Uint",0)
	}
	CLEARDOCUMENTSTYLE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2005,"Uint",0,"Uint",0)
	}
	CLEARREGISTEREDIMAGES(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2408,"Uint",0,"Uint",0)
	}
	CLEARSELECTIONS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2571,"Uint",0,"Uint",0)
	}
	COLOURISE(startPos=0,endPos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4003,"Uint",startPos,"Uint",endPos)
	}
	CONTRACTEDFOLDNEXT(lineStart=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2618,"Uint",lineStart,"Uint",0)
	}
	CONVERTEOLS(eolMode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2029,"Uint",eolMode,"Uint",0)
	}
	COPY(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2178,"Uint",0,"Uint",0)
	}
	COPYALLOWLINE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2519,"Uint",0,"Uint",0)
	}
	COPYRANGE(start=0,end=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2419,"Uint",start,"Uint",end)
	}
	COPYTEXT(length=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2420,"Uint",length,"Uint",this.buf.bufAdr)
	}
	CREATEDOCUMENT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2375,"Uint",0,"Uint",0)
	}
	CUT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2177,"Uint",0,"Uint",0)
	}
	DESCRIBEKEYWORDSETS(){
		this.buf.Open(1024),DllCall(this.Func,"PTR",this.DirectPtr,"UInt",0,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	DESCRIBEPROPERTY(name=""){
		this.buf.Write(name),this.buff.Open(1024)
		DllCall(this.Func,"PTR",this.DirectPtr,"UInt",4016,"Uint",this.buf.bufAdr,"Uint",this.buff.bufAdr),this.buf.Read()
		return StrGet(this.buff.ptr,"CP0")
	}
	DOCLINEFROMVISIBLE(displayLine=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2221,"Uint",displayLine,"Uint",0)
	}
	EMPTYUNDOBUFFER(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2175,"Uint",0,"Uint",0)
	}
	ENCODEDFROMUTF8(utf8=""){
		this.buf.Open((StrLen(utf8)*4))
		this.buf.Write(utf8)
		DllCall(this.Func,"PTR",this.DirectPtr,"UInt",4016,"Uint",this.buf.bufAdr,"Uint",this.buf.bufAdr+StrLen(utf8)*2+2),this.buf.Read()
		return StrGet(this.buf.ptr+StrLen(utf8)*2+2,"CP0")
	}
	ENDUNDOACTION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2079,"Uint",0,"Uint",0)
	}
	ENSUREVISIBLE(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2232,"Uint",line,"Uint",0)
	}
	ENSUREVISIBLEENFORCEPOLICY(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2234,"Uint",line,"Uint",0)
	}
	FINDCOLUMN(line=0,column=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2456,"Uint",line,"Uint",column)
	}
	FINDTEXT(searchFlags=0,ttf=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2150,"Uint",searchFlags,"Uint",ttf)
	}
	FORMATRANGE(bDraw=0,pfr=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2151,"Uint",bDraw,"Uint",pfr)
	}
	GETADDITIONALCARETFORE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2605,"Uint",0,"Uint",0)
	}
	GETADDITIONALCARETSBLINK(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2568,"Uint",0,"Uint",0)
	}
	GETADDITIONALCARETSVISIBLE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2609,"Uint",0,"Uint",0)
	}
	GETADDITIONALSELALPHA(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2603,"Uint",0,"Uint",0)
	}
	GETADDITIONALSELECTIONTYPING(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2566,"Uint",0,"Uint",0)
	}
	GETANCHOR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2009,"Uint",0,"Uint",0)
	}
	GETBACKSPACEUNINDENTS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2263,"Uint",0,"Uint",0)
	}
	GETBUFFEREDDRAW(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2034,"Uint",0,"Uint",0)
	}
	GETCARETFORE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2138,"Uint",0,"Uint",0)
	}
	GETCARETLINEBACK(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2097,"Uint",0,"Uint",0)
	}
	GETCARETLINEBACKALPHA(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2471,"Uint",0,"Uint",0)
	}
	GETCARETLINEVISIBLE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2095,"Uint",0,"Uint",0)
	}
	GETCARETPERIOD(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2075,"Uint",0,"Uint",0)
	}
	GETCARETSTICKY(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2457,"Uint",0,"Uint",0)
	}
	GETCARETSTYLE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2513,"Uint",0,"Uint",0)
	}
	GETCARETWIDTH(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2189,"Uint",0,"Uint",0)
	}
	GETCHARACTERPOINTER(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2520,"Uint",0,"Uint",0)
	}
	GETCHARAT(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2007,"Uint",pos,"Uint",0)
	}
	GETCODEPAGE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2137,"Uint",0,"Uint",0)
	}
	GETCOLUMN(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2129,"Uint",pos,"Uint",0)
	}
	GETCONTROLCHARSYMBOL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2389,"Uint",0,"Uint",0)
	}
	GETCURLINE(){
		DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2027,"Uint",this.buf.Open(DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2027,"Uint",0,"Uint",0)),"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	GETCURRENTPOS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2008,"Uint",0,"Uint",0)
	}
	GETCURSOR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2387,"Uint",0,"Uint",0)
	}
	GETDIRECTFUNCTION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2184,"Uint",0,"Uint",0)
	}
	GETDIRECTPOINTER(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2185,"Uint",0,"Uint",0)
	}
	GETDOCPOINTER(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2357,"Uint",0,"Uint",0)
	}
	GETEDGECOLOUR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2364,"Uint",0,"Uint",0)
	}
	GETEDGECOLUMN(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2360,"Uint",0,"Uint",0)
	}
	GETEDGEMODE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2362,"Uint",0,"Uint",0)
	}
	GETENDATLASTLINE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2278,"Uint",0,"Uint",0)
	}
	GETENDSTYLED(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2028,"Uint",0,"Uint",0)
	}
	GETEOLMODE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2030,"Uint",0,"Uint",0)
	}
	GETEXTRAASCENT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2526,"Uint",0,"Uint",0)
	}
	GETEXTRADESCENT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2528,"Uint",0,"Uint",0)
	}
	GETFIRSTVISIBLELINE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2152,"Uint",0,"Uint",0)
	}
	GETFOCUS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2381,"Uint",0,"Uint",0)
	}
	GETFOLDEXPANDED(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2230,"Uint",line,"Uint",0)
	}
	GETFOLDLEVEL(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2223,"Uint",line,"Uint",0)
	}
	GETFOLDPARENT(startLine=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2225,"Uint",startLine,"Uint",0)
	}
	GETFONTQUALITY(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2612,"Uint",0,"Uint",0)
	}
	GETHIGHLIGHTGUIDE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2135,"Uint",0,"Uint",0)
	}
	GETHOTSPOTACTIVEBACK(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2495,"Uint",0,"Uint",0)
	}
	GETHOTSPOTACTIVEFORE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2494,"Uint",0,"Uint",0)
	}
	GETHOTSPOTACTIVEUNDERLINE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2496,"Uint",0,"Uint",0)
	}
	GETHOTSPOTSINGLELINE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2497,"Uint",0,"Uint",0)
	}
	GETHSCROLLBAR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2131,"Uint",0,"Uint",0)
	}
	GETINDENT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2123,"Uint",0,"Uint",0)
	}
	GETINDENTATIONGUIDES(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2133,"Uint",0,"Uint",0)
	}
	GETINDICATORCURRENT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2501,"Uint",0,"Uint",0)
	}
	GETINDICATORVALUE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2503,"Uint",0,"Uint",0)
	}
	GETKEYSUNICODE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2522,"Uint",0,"Uint",0)
	}
	GETLASTCHILD(startLine=0,level=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2224,"Uint",startLine,"Uint",level)
	}
	GETLAYOUTCACHE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2273,"Uint",0,"Uint",0)
	}
	GETLENGTH(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2006,"Uint",0,"Uint",0)
	}
	GETLEXER(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4002,"Uint",0,"Uint",0)
	}
	GETLEXERLANGUAGE(){
		DllCall(this.Func,"PTR",this.DirectPtr,"UInt",4012,"Uint",this.buf.Open(1024),"Uint",this.buf.bufAdr) ;just enough buffer to receive the text
		this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	GETLINE(line=0){
		this.buf.Open(DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2153,"Uint",line,"Uint",0))
		DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2153,"Uint",line,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	GETLINECOUNT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2154,"Uint",0,"Uint",0)
	}
	GETLINEENDPOSITION(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2136,"Uint",line,"Uint",0)
	}
	GETLINEINDENTATION(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2127,"Uint",line,"Uint",0)
	}
	GETLINEINDENTPOSITION(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2128,"Uint",line,"Uint",0)
	}
	GETLINESELENDPOSITION(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2425,"Uint",line,"Uint",0)
	}
	GETLINESELSTARTPOSITION(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2424,"Uint",line,"Uint",0)
	}
	GETLINESTATE(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2093,"Uint",line,"Uint",0)
	}
	GETLINEVISIBLE(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2228,"Uint",line,"Uint",0)
	}
	GETMAINSELECTION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2575,"Uint",0,"Uint",0)
	}
	GETMARGINCURSORN(margin=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2249,"Uint",margin,"Uint",0)
	}
	GETMARGINLEFT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2156,"Uint",0,"Uint",0)
	}
	GETMARGINMASKN(margin=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2245,"Uint",margin,"Uint",0)
	}
	GETMARGINRIGHT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2158,"Uint",0,"Uint",0)
	}
	GETMARGINSENSITIVEN(margin=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2247,"Uint",margin,"Uint",0)
	}
	GETMARGINTYPEN(margin=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2241,"Uint",margin,"Uint",0)
	}
	GETMARGINWIDTHN(margin=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2243,"Uint",margin,"Uint",0)
	}
	GETMAXLINESTATE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2094,"Uint",0,"Uint",0)
	}
	GETMODEVENTMASK(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2378,"Uint",0,"Uint",0)
	}
	GETMODIFY(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2159,"Uint",0,"Uint",0)
	}
	GETMOUSEDOWNCAPTURES(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2385,"Uint",0,"Uint",0)
	}
	GETMOUSEDWELLTIME(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2265,"Uint",0,"Uint",0)
	}
	GETMULTIPASTE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2615,"Uint",0,"Uint",0)
	}
	GETMULTIPLESELECTION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2564,"Uint",0,"Uint",0)
	}
	GETOVERTYPE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2187,"Uint",0,"Uint",0)
	}
	GETPASTECONVERTENDINGS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2468,"Uint",0,"Uint",0)
	}
	GETPOSITIONCACHE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2515,"Uint",0,"Uint",0)
	}
	GETPRINTCOLOURMODE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2149,"Uint",0,"Uint",0)
	}
	GETPRINTMAGNIFICATION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2147,"Uint",0,"Uint",0)
	}
	GETPRINTWRAPMODE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2407,"Uint",0,"Uint",0)
	}
	GETPROPERTY(key=""){
		this.buf.Write(key)
		this.buff.Open(DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4008,"Uint",this.buf.bufAdr,"Uint",0))
		If DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4008,"Uint",this.buf.bufAdr,"Uint",this.buff.bufAdr){
			this.buff.Read()
			return StrGet(this.buff.ptr,"CP0")
		}
	}
	GETPROPERTYEXPANDED(key=""){
		this.buf.Write(key,0,"CP0")
		this.buff.Open(DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4009,"Uint",this.buf.bufAdr,"Uint",0) + 2)
		If DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4009,"Uint",this.buf.bufAdr,"Uint",this.buff.bufAdr)
			return StrGet(this.buff.ptr,"CP0")
	}
	GETPROPERTYINT(key="",default=0){
		this.buf.Write(key)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4010,"Uint",this.buf.bufAdr,"Uint",default)
	}
	GETREADONLY(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2140,"Uint",0,"Uint",0)
	}
	GETRECTANGULARSELECTIONANCHOR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2591,"Uint",0,"Uint",0)
	}
	GETRECTANGULARSELECTIONANCHORVIRTUALSPACE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2595,"Uint",0,"Uint",0)
	}
	GETRECTANGULARSELECTIONCARET(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2589,"Uint",0,"Uint",0)
	}
	GETRECTANGULARSELECTIONCARETVIRTUALSPACE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2593,"Uint",0,"Uint",0)
	}
	GETRECTANGULARSELECTIONMODIFIER(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2599,"Uint",0,"Uint",0)
	}
	GETSCROLLWIDTH(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2275,"Uint",0,"Uint",0)
	}
	GETSCROLLWIDTHTRACKING(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2517,"Uint",0,"Uint",0)
	}
	GETSEARCHFLAGS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2199,"Uint",0,"Uint",0)
	}
	GETSELALPHA(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2477,"Uint",0,"Uint",0)
	}
	GETSELECTIONEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2145,"Uint",0,"Uint",0)
	}
	GETSELECTIONMODE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2423,"Uint",0,"Uint",0)
	}
	GETSELECTIONNANCHOR(selection=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2579,"Uint",selection,"Uint",0)
	}
	GETSELECTIONNANCHORVIRTUALSPACE(selection=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2583,"Uint",selection,"Uint",0)
	}
	GETSELECTIONNCARET(selection=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2577,"Uint",selection,"Uint",0)
	}
	GETSELECTIONNCARETVIRTUALSPACE(selection=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2581,"Uint",selection,"Uint",0)
	}
	GETSELECTIONNEND(selection=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2587,"Uint",selection,"Uint",0)
	}
	GETSELECTIONNSTART(selection=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2585,"Uint",selection,"Uint",0)
	}
	GETSELECTIONS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2570,"Uint",0,"Uint",0)
	}
	GETSELECTIONSTART(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2143,"Uint",0,"Uint",0)
	}
	GETSELEOLFILLED(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2479,"Uint",0,"Uint",0)
	}
	GETSELTEXT(){
		DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2161,"Uint",this.buf.Open(DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2161,"Uint",0,"Uint",0)),"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	GETSTATUS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2383,"Uint",0,"Uint",0)
	}
	GETSTYLEAT(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2010,"Uint",pos,"Uint",0)
	}
	GETSTYLEBITS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2091,"Uint",0,"Uint",0)
	}
	GETSTYLEBITSNEEDED(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4011,"Uint",0,"Uint",0)
	}
	GETSTYLEDTEXT(tr=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2015,"Uint",0,"Uint",tr)
	}
	GETTABINDENTS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2261,"Uint",0,"Uint",0)
	}
	GETTABWIDTH(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2121,"Uint",0,"Uint",0)
	}
	GETTAG(tagNumber=0){
		this.buf.Open(1024),DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2616,"Uint",tagNumber,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	GETTARGETEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2193,"Uint",0,"Uint",0)
	}
	GETTARGETSTART(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2191,"Uint",0,"Uint",0)
	}
	GETTEXT(Encoding=""){
		DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2182,"Uint",this.buf.Open(DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2182,"Uint",-1,"Uint",0)),"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,Encoding?Encoding:this.Encoding)
	}
	GETTEXTLENGTH(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2183,"Uint",0,"Uint",0)
	}
	GETTEXTRANGE(cmin=0,cmax=0,Encoding=""){
		static Sci_CharacterRange :=Struct("Sci_CharacterRange:LONG cmin,LONG cmax"),tr:=Struct("Sci_CharacterRange chrg,char *lpstrText")
		this.buf.Open(1024),tr.lpstrText:=this.buf.bufAdr,tr.chrg.cmin:=cmin,tr.chrg.cmax:=cmax
		DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2162,"Uint",0,"Uint",tr[""])
		this.buf.Read()
		return StrGet(this.buf.ptr,Encoding?Encoding:this.Encoding)
	}
	GETTWOPHASEDRAW(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2283,"Uint",0,"Uint",0)
	}
	GETUNDOCOLLECTION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2019,"Uint",0,"Uint",0)
	}
	GETUSEPALETTE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2139,"Uint",0,"Uint",0)
	}
	GETUSETABS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2125,"Uint",0,"Uint",0)
	}
	GETVIEWEOL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2355,"Uint",0,"Uint",0)
	}
	GETVIEWWS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2020,"Uint",0,"Uint",0)
	}
	GETVIRTUALSPACEOPTIONS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2597,"Uint",0,"Uint",0)
	}
	GETVSCROLLBAR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2281,"Uint",0,"Uint",0)
	}
	GETWHITESPACESIZE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2087,"Uint",0,"Uint",0)
	}
	GETWRAPINDENTMODE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2473,"Uint",0,"Uint",0)
	}
	GETWRAPMODE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2269,"Uint",0,"Uint",0)
	}
	GETWRAPSTARTINDENT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2465,"Uint",0,"Uint",0)
	}
	GETWRAPVISUALFLAGS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2461,"Uint",0,"Uint",0)
	}
	GETWRAPVISUALFLAGSLOCATION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2463,"Uint",0,"Uint",0)
	}
	GETXOFFSET(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2398,"Uint",0,"Uint",0)
	}
	GETZOOM(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2374,"Uint",0,"Uint",0)
	}
	GOTOLINE(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2024,"Uint",line,"Uint",0)
	}
	GOTOPOS(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2025,"Uint",pos,"Uint",0)
	}
	GRABFOCUS(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2400,"Uint",0,"Uint",0)
	}
	HIDELINES(lineStart=0,lineEnd=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2227,"Uint",lineStart,"Uint",lineEnd)
	}
	HIDESELECTION(hide=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2163,"Uint",hide,"Uint",0)
	}
	INDICATORALLONFOR(position=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2506,"Uint",position,"Uint",0)
	}
	INDICATORCLEARRANGE(position=0,clearLength=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2505,"Uint",position,"Uint",clearLength)
	}
	INDICATOREND(indicator=0,position=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2509,"Uint",indicator,"Uint",position)
	}
	INDICATORFILLRANGE(position=0,fillLength=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2504,"Uint",position,"Uint",fillLength)
	}
	INDICATORSTART(indicator=0,position=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2508,"Uint",indicator,"Uint",position)
	}
	INDICATORVALUEAT(indicator=0,position=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2507,"Uint",indicator,"Uint",position)
	}
	INDICGETALPHA(indicatorNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2524,"Uint",indicatorNumber,"Uint",0)
	}
	INDICGETFORE(indicatorNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2083,"Uint",indicatorNumber,"Uint",0)
	}
	INDICGETSTYLE(indicatorNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2081,"Uint",indicatorNumber,"Uint",0)
	}
	INDICGETUNDER(indicatorNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2511,"Uint",indicatorNumber,"Uint",0)
	}
	INDICSETALPHA(indicatorNumber=0,alpha=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2523,"Uint",indicatorNumber,"Uint",alpha)
	}
	INDICSETFORE(indicatorNumber=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2082,"Uint",indicatorNumber,"Uint",colour)
	}
	INDICSETSTYLE(indicatorNumber=0,indicatorStyle=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2080,"Uint",indicatorNumber,"Uint",indicatorStyle)
	}
	INDICSETUNDER(indicatorNumber=0,under=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2510,"Uint",indicatorNumber,"Uint",under)
	}
	INSERTTEXT(pos=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2003,"Uint",pos,"Uint",this.buf.bufAdr)
	}
	LINEFROMPOSITION(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2166,"Uint",pos,"Uint",0)
	}
	LINELENGTH(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2350,"Uint",line,"Uint",0)
	}
	LINESCROLL(column=0,line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2168,"Uint",column,"Uint",line)
	}
	LINESJOIN(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2288,"Uint",0,"Uint",0)
	}
	LINESONSCREEN(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2370,"Uint",0,"Uint",0)
	}
	LINESSPLIT(pixelWidth=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2289,"Uint",pixelWidth,"Uint",0)
	}
	LOADLEXERLIBRARY(path=""){
		this.buf.Write(path)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4007,"Uint",0,"Uint",this.buf.bufAdr)
	}
	MARGINGETSTYLE(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2533,"Uint",line,"Uint",0)
	}
	MARGINGETSTYLEOFFSET(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2538,"Uint",0,"Uint",0)
	}
	MARGINGETSTYLES(line=0){
		this.buf.Open(1024),DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2535,"Uint",line,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	MARGINGETTEXT(line=0){
		this.buf.Open(1024),DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2531,"Uint",line,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	MARGINSETSTYLE(line=0,style=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2532,"Uint",line,"Uint",style)
	}
	MARGINSETSTYLEOFFSET(style=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2537,"Uint",style,"Uint",0)
	}
	MARGINSETSTYLES(line=0,styles=""){
		this.buf.Write(styles)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2534,"Uint",line,"Uint",this.buf.bufAdr)
	}
	MARGINSETTEXT(line=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2530,"Uint",line,"Uint",this.buf.bufAdr)
	}
	MARGINTEXTCLEARALL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2536,"Uint",0,"Uint",0)
	}
	MARKERADD(line=0,markerNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2043,"Uint",line,"Uint",markerNumber)
	}
	MARKERADDSET(line=0,markerMask=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2466,"Uint",line,"Uint",markerMask)
	}
	MARKERDEFINE(markerNumber=0,markerSymbols=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2040,"Uint",markerNumber,"Uint",markerSymbols)
	}
	MARKERDEFINEPIXMAP(markerNumber=0,xpm=""){
		AutoTrim:=A_AutoTrim
		AutoTrim,Off
		len:=0,i:=0
		Loop,Parse,xpm,`n,`r
			string%A_Index%:=A_LoopField,i++,len:=len+StrLen(A_LoopField)
		this.buf.Open(i*8 + len*4 + 8)
		offset:=i*4
		Loop % i
			this.buf.Write(string%A_Index%,offset,"CP0")
			,this.buf.NumPut(this.buf.bufAdr+offset,(A_Index-1)*4)
			,offset:=offset+StrLen(string%A_Index%)*4
		AutoTrim % AutoTrim
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2049,"Uint",markerNumber,"Uint",this.buf.bufAdr)
	}
	MARKERDELETE(line=0,markerNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2044,"Uint",line,"Uint",markerNumber)
	}
	MARKERDELETEALL(markerNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2045,"Uint",markerNumber,"Uint",0)
	}
	MARKERDELETEHANDLE(markerHandle=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2018,"Uint",markerHandle,"Uint",0)
	}
	MARKERGET(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2046,"Uint",line,"Uint",0)
	}
	MARKERLINEFROMHANDLE(markerHandle=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2017,"Uint",markerHandle,"Uint",0)
	}
	MARKERNEXT(lineStart=0,markerMask=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2047,"Uint",lineStart,"Uint",markerMask)
	}
	MARKERPREVIOUS(lineStart=0,markerMask=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2048,"Uint",lineStart,"Uint",markerMask)
	}
	MARKERSETALPHA(markerNumber=0,alpha=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2476,"Uint",markerNumber,"Uint",alpha)
	}
	MARKERSETBACK(markerNumber=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2042,"Uint",markerNumber,"Uint",colour)
	}
	MARKERSETFORE(markerNumber=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2041,"Uint",markerNumber,"Uint",colour)
	}
	MARKERSYMBOLDEFINED(markerNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2529,"Uint",markerNumber,"Uint",0)
	}
	MOVECARETINSIDEVIEW(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2401,"Uint",0,"Uint",0)
	}
	NULL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2172,"Uint",0,"Uint",0)
	}
	PASTE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2179,"Uint",0,"Uint",0)
	}
	POINTXFROMPOSITION(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2164,"Uint",0,"Uint",pos)
	}
	POINTYFROMPOSITION(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2165,"Uint",0,"Uint",pos)
	}
	POSITIONAFTER(position=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2418,"Uint",position,"Uint",0)
	}
	POSITIONBEFORE(position=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2417,"Uint",position,"Uint",0)
	}
	POSITIONFROMLINE(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2167,"Uint",line,"Uint",0)
	}
	POSITIONFROMPOINT(x=0,y=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2022,"Uint",x,"Uint",y)
	}
	POSITIONFROMPOINTCLOSE(x=0,y=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2023,"Uint",x,"Uint",y)
	}
	PROPERTYNAMES(){
		this.buf.Open(1024),DllCall(this.Func,"PTR",this.DirectPtr,"UInt",0,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	PROPERTYTYPE(name=""){
		this.buf.Write(name)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4015,"Uint",this.buf.bufAdr,"Uint",0)
	}
	REDO(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2011,"Uint",0,"Uint",0)
	}
	REGISTERIMAGE(type=0,xpmData=""){
		this.buf.Write(xpmData)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2405,"Uint",type,"Uint",this.buf.bufAdr)
	}
	RELEASEDOCUMENT(pDoc=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2377,"Uint",0,"Uint",pDoc)
	}
	REPLACESEL(text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2170,"Uint",0,"Uint",this.buf.bufAdr)
	}
	REPLACETARGET(length=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2194,"Uint",length,"Uint",this.buf.bufAdr)
	}
	REPLACETARGETRE(length=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2195,"Uint",length,"Uint",this.buf.bufAdr)
	}
	ROTATESELECTION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2606,"Uint",0,"Uint",0)
	}
	SCROLLCARET(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2169,"Uint",0,"Uint",0)
	}
	SEARCHANCHOR(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2366,"Uint",0,"Uint",0)
	}
	SEARCHINTARGET(length=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2197,"Uint",length,"Uint",this.buf.bufAdr)
	}
	SEARCHNEXT(searchFlags=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2367,"Uint",searchFlags,"Uint",this.buf.bufAdr)
	}
	SEARCHPREV(searchFlags=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2368,"Uint",searchFlags,"Uint",this.buf.bufAdr)
	}
	SELECTALL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2013,"Uint",0,"Uint",0)
	}
	SELECTIONISRECTANGLE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2372,"Uint",0,"Uint",0)
	}
	SETADDITIONALCARETFORE(colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2604,"Uint",colour,"Uint",0)
	}
	SETADDITIONALCARETSBLINK(additionalCaretsBlink=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2567,"Uint",additionalCaretsBlink,"Uint",0)
	}
	SETADDITIONALCARETSVISIBLE(additionalCaretsVisible=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2608,"Uint",additionalCaretsVisible,"Uint",0)
	}
	SETADDITIONALSELALPHA(alpha=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2602,"Uint",alpha,"Uint",0)
	}
	SETADDITIONALSELBACK(colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2601,"Uint",colour,"Uint",0)
	}
	SETADDITIONALSELECTIONTYPING(additionalSelectionTyping=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2565,"Uint",additionalSelectionTyping,"Uint",0)
	}
	SETADDITIONALSELFORE(colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2600,"Uint",colour,"Uint",0)
	}
	SETANCHOR(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2026,"Uint",pos,"Uint",0)
	}
	SETBACKSPACEUNINDENTS(bsUnIndents=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2262,"Uint",bsUnIndents,"Uint",0)
	}
	SETBUFFEREDDRAW(isBuffered=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2035,"Uint",isBuffered,"Uint",0)
	}
	SETCARETFORE(colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2069,"Uint",colour,"Uint",0)
	}
	SETCARETLINEBACK(colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2098,"Uint",colour,"Uint",0)
	}
	SETCARETLINEBACKALPHA(alpha=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2470,"Uint",alpha,"Uint",0)
	}
	SETCARETLINEVISIBLE(show=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2096,"Uint",show,"Uint",0)
	}
	SETCARETPERIOD(milliseconds=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2076,"Uint",milliseconds,"Uint",0)
	}
	SETCARETSTICKY(useCaretStickyBehaviour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2458,"Uint",useCaretStickyBehaviour,"Uint",0)
	}
	SETCARETSTYLE(style=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2512,"Uint",style,"Uint",0)
	}
	SETCARETWIDTH(pixels=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2188,"Uint",pixels,"Uint",0)
	}
	SETCHARSDEFAULT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2444,"Uint",0,"Uint",0)
	}
	SETCODEPAGE(codePage=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2037,"Uint",codePage,"Uint",0)
	}
	SETCONTROLCHARSYMBOL(symbol=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2388,"Uint",symbol,"Uint",0)
	}
	SETCURRENTPOS(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2141,"Uint",pos,"Uint",0)
	}
	SETCURSOR(curType=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2386,"Uint",curType,"Uint",0)
	}
	SETDOCPOINTER(pDoc=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2358,"Uint",0,"Uint",pDoc)
	}
	SETEDGECOLOUR(colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2365,"Uint",colour,"Uint",0)
	}
	SETEDGECOLUMN(column=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2361,"Uint",column,"Uint",0)
	}
	SETEDGEMODE(edgeMode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2363,"Uint",edgeMode,"Uint",0)
	}
	SETENDATLASTLINE(endAtLastLine=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2277,"Uint",endAtLastLine,"Uint",0)
	}
	SETEOLMODE(eolMode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2031,"Uint",eolMode,"Uint",0)
	}
	SETEXTRAASCENT(extraAscent=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2525,"Uint",extraAscent,"Uint",0)
	}
	SETEXTRADESCENT(extraDescent=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2527,"Uint",extraDescent,"Uint",0)
	}
	SETFIRSTVISIBLELINE(lineDisplay=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2613,"Uint",lineDisplay,"Uint",0)
	}
	SETFOCUS(focus=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2380,"Uint",focus,"Uint",0)
	}
	SETFOLDEXPANDED(line=0,expanded=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2229,"Uint",line,"Uint",expanded)
	}
	SETFOLDFLAGS(flags=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2233,"Uint",flags,"Uint",0)
	}
	SETFOLDLEVEL(line=0,level=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2222,"Uint",line,"Uint",level)
	}
	SETFOLDMARGINCOLOUR(useSetting=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2290,"Uint",useSetting,"Uint",colour)
	}
	SETFOLDMARGINHICOLOUR(useSetting=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2291,"Uint",useSetting,"Uint",colour)
	}
	SETFONTQUALITY(fontQuality=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2611,"Uint",fontQuality,"Uint",0)
	}
	SETHIGHLIGHTGUIDE(column=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2134,"Uint",column,"Uint",0)
	}
	SETHOTSPOTACTIVEBACK(useHotSpotBackColour=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2411,"Uint",useHotSpotBackColour,"Uint",colour)
	}
	SETHOTSPOTACTIVEFORE(useHotSpotForeColour=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2410,"Uint",useHotSpotForeColour,"Uint",colour)
	}
	SETHOTSPOTACTIVEUNDERLINE(underline=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2412,"Uint",underline,"Uint",0)
	}
	SETHOTSPOTSINGLELINE(singleLine=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2421,"Uint",singleLine,"Uint",0)
	}
	SETHSCROLLBAR(visible=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2130,"Uint",visible,"Uint",0)
	}
	SETINDENT(widthInChars=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2122,"Uint",widthInChars,"Uint",0)
	}
	SETINDENTATIONGUIDES(indentView=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2132,"Uint",indentView,"Uint",0)
	}
	SETINDICATORCURRENT(indicator=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2500,"Uint",indicator,"Uint",0)
	}
	SETINDICATORVALUE(value=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2502,"Uint",value,"Uint",0)
	}
	SETKEYSUNICODE(keysUnicode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2521,"Uint",keysUnicode,"Uint",0)
	}
	SETKEYWORDS(keyWordSet=0,keyWordList=""){
		this.buf.Write(keyWordList,0,"CP0")
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4005,"Uint",keyWordSet,"Uint",this.buf.bufAdr)
	}
	SETLAYOUTCACHE(cacheMode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2272,"Uint",cacheMode,"Uint",0)
	}
	SETLENGTHFORENCODE(bytes=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2448,"Uint",bytes,"Uint",0)
	}
	SETLEXER(lexer=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4001,"Uint",lexer,"Uint",0)
	}
	SETLEXERLANGUAGE(name=""){
		this.buf.Write(name)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4006,"Uint",0,"Uint",this.buf.bufAdr)
	}
	SETLINEINDENTATION(line=0,indentation=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2126,"Uint",line,"Uint",indentation)
	}
	SETLINESTATE(line=0,value=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2092,"Uint",line,"Uint",value)
	}
	SETMAINSELECTION(selection=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2574,"Uint",selection,"Uint",0)
	}
	SETMARGINCURSORN(margin=0,cursor=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2248,"Uint",margin,"Uint",cursor)
	}
	SETMARGINLEFT(pixels=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2155,"Uint",0,"Uint",pixels)
	}
	SETMARGINMASKN(margin=0,mask=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2244,"Uint",margin,"Uint",mask)
	}
	SETMARGINRIGHT(pixels=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2157,"Uint",0,"Uint",pixels)
	}
	SETMARGINSENSITIVEN(margin=0,sensitive=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2246,"Uint",margin,"Uint",sensitive)
	}
	SETMARGINTYPEN(margin=0,iType=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2240,"Uint",margin,"Uint",iType)
	}
	SETMARGINWIDTHN(margin=0,pixelWidth=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2242,"Uint",margin,"Uint",pixelWidth)
	}
	SETMODEVENTMASK(eventMask=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2359,"Uint",eventMask,"Uint",0)
	}
	SETMOUSEDOWNCAPTURES(captures=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2384,"Uint",captures,"Uint",0)
	}
	SETMOUSEDWELLTIME(mSec){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2264,"Uint",mSec,"Uint",0)
	}
	SETMULTIPASTE(multiPaste=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2614,"Uint",multiPaste,"Uint",0)
	}
	SETMULTIPLESELECTION(multipleSelection=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2563,"Uint",multipleSelection,"Uint",0)
	}
	SETOVERTYPE(overType=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2186,"Uint",overType,"Uint",0)
	}
	SETPASTECONVERTENDINGS(convert=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2467,"Uint",convert,"Uint",0)
	}
	SETPOSITIONCACHE(size=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2514,"Uint",size,"Uint",0)
	}
	SETPRINTCOLOURMODE(mode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2148,"Uint",mode,"Uint",0)
	}
	SETPRINTMAGNIFICATION(magnification=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2146,"Uint",magnification,"Uint",0)
	}
	SETPRINTWRAPMODE(wrapMode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2406,"Uint",wrapMode,"Uint",0)
	}
	SETPROPERTY(key="",value=""){
		this.buf.Write(key,0,"CP0"),this.buff.Write(value,0,"CP0")
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",4004,"Uint",this.buf.bufAdr,"Uint",this.buff.bufAdr)
	}
	SETREADONLY(readOnly=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2171,"Uint",readOnly,"Uint",0)
	}
	SETRECTANGULARSELECTIONANCHOR(posAnchor=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2590,"Uint",posAnchor,"Uint",0)
	}
	SETRECTANGULARSELECTIONANCHORVIRTUALSPACE(space=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2594,"Uint",space,"Uint",0)
	}
	SETRECTANGULARSELECTIONCARET(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2588,"Uint",pos,"Uint",0)
	}
	SETRECTANGULARSELECTIONCARETVIRTUALSPACE(space=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2592,"Uint",space,"Uint",0)
	}
	SETRECTANGULARSELECTIONMODIFIER(modifier=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2598,"Uint",modifier,"Uint",0)
	}
	SETSAVEPOINT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2014,"Uint",0,"Uint",0)
	}
	SETSCROLLWIDTH(pixelWidth=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2274,"Uint",pixelWidth,"Uint",0)
	}
	SETSCROLLWIDTHTRACKING(tracking=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2516,"Uint",tracking,"Uint",0)
	}
	SETSEARCHFLAGS(searchFlags=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2198,"Uint",searchFlags,"Uint",0)
	}
	SETSEL(anchorPos=0,currentPos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2160,"Uint",anchorPos,"Uint",currentPos)
	}
	SETSELALPHA(alpha=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2478,"Uint",alpha,"Uint",0)
	}
	SETSELBACK(useSelectionBackColour=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2068,"Uint",useSelectionBackColour,"Uint",colour)
	}
	SETSELECTION(caret=0,anchor=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2572,"Uint",caret,"Uint",anchor)
	}
	SETSELECTIONEND(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2144,"Uint",pos,"Uint",0)
	}
	SETSELECTIONMODE(mode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2422,"Uint",mode,"Uint",0)
	}
	SETSELECTIONNANCHOR(selection=0,posAnchor=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2578,"Uint",selection,"Uint",posAnchor)
	}
	SETSELECTIONNANCHORVIRTUALSPACE(selection=0,space=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2582,"Uint",selection,"Uint",space)
	}
	SETSELECTIONNCARET(selection=0,pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2576,"Uint",selection,"Uint",pos)
	}
	SETSELECTIONNCARETVIRTUALSPACE(selection=0,space=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2580,"Uint",selection,"Uint",space)
	}
	SETSELECTIONNEND(selection=0,pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2586,"Uint",selection,"Uint",pos)
	}
	SETSELECTIONNSTART(selection=0,pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2584,"Uint",selection,"Uint",pos)
	}
	SETSELECTIONSTART(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2142,"Uint",pos,"Uint",0)
	}
	SETSELEOLFILLED(filled=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2480,"Uint",filled,"Uint",0)
	}
	SETSELFORE(useSelectionForeColour=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2067,"Uint",useSelectionForeColour,"Uint",colour)
	}
	SETSTATUS(status=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2382,"Uint",status,"Uint",0)
	}
	SETSTYLEBITS(bits=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2090,"Uint",bits,"Uint",0)
	}
	SETSTYLING(length=0,style=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2033,"Uint",length,"Uint",style)
	}
	SETSTYLINGEX(length=0,styles=""){
		this.buf.Write(styles)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2073,"Uint",length,"Uint",this.buf.bufAdr)
	}
	SETTABINDENTS(tabIndents=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2260,"Uint",tabIndents,"Uint",0)
	}
	SETTABWIDTH(widthInChars=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2036,"Uint",widthInChars,"Uint",0)
	}
	SETTARGETEND(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2192,"Uint",pos,"Uint",0)
	}
	SETTARGETSTART(pos=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2190,"Uint",pos,"Uint",0)
	}
	SETTEXT(text="",Encoding=""){
		this.buf.Write(text,0,Encoding?Encoding:this.Encoding)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2181,"Uint",0,"Uint",this.buf.bufAdr)
	}
	SETTWOPHASEDRAW(twoPhase=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2284,"Uint",twoPhase,"Uint",0)
	}
	SETUNDOCOLLECTION(collectUndo=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2012,"Uint",collectUndo,"Uint",0)
	}
	SETUSEPALETTE(allowPaletteUse=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2039,"Uint",allowPaletteUse,"Uint",0)
	}
	SETUSETABS(useTabs=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2124,"Uint",useTabs,"Uint",0)
	}
	SETVIEWEOL(visible=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2356,"Uint",visible,"Uint",0)
	}
	SETVIEWWS(wsMode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2021,"Uint",wsMode,"Uint",0)
	}
	SETVIRTUALSPACEOPTIONS(virtualSpace=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2596,"Uint",virtualSpace,"Uint",0)
	}
	SETVISIBLEPOLICY(caretPolicy=0,caretSlop=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2394,"Uint",caretPolicy,"Uint",caretSlop)
	}
	SETVSCROLLBAR(visible=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2280,"Uint",visible,"Uint",0)
	}
	SETWHITESPACEBACK(useWhitespaceBackColour=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2085,"Uint",useWhitespaceBackColour,"Uint",colour)
	}
	SETWHITESPACECHARS(chars=""){
		this.buf.Write(chars)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2443,"Uint",0,"Uint",this.buf.bufAdr)
	}
	SETWHITESPACEFORE(useWhitespaceForeColour=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2084,"Uint",useWhitespaceForeColour,"Uint",colour)
	}
	SETWHITESPACESIZE(size=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2086,"Uint",size,"Uint",0)
	}
	SETWORDCHARS(chars=""){
		this.buf.Write(chars)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2077,"Uint",0,"Uint",this.buf.bufAdr)
	}
	SETWRAPINDENTMODE(indentMode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2472,"Uint",indentMode,"Uint",0)
	}
	SETWRAPMODE(wrapMode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2268,"Uint",wrapMode,"Uint",0)
	}
	SETWRAPSTARTINDENT(indent=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2464,"Uint",indent,"Uint",0)
	}
	SETWRAPVISUALFLAGS(wrapVisualFlags=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2460,"Uint",wrapVisualFlags,"Uint",0)
	}
	SETWRAPVISUALFLAGSLOCATION(wrapVisualFlagsLocation=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2462,"Uint",wrapVisualFlagsLocation,"Uint",0)
	}
	SETXCARETPOLICY(caretPolicy=0,caretSlop=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2402,"Uint",caretPolicy,"Uint",caretSlop)
	}
	SETXOFFSET(xOffset=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2397,"Uint",xOffset,"Uint",0)
	}
	SETYCARETPOLICY(caretPolicy=0,caretSlop=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2403,"Uint",caretPolicy,"Uint",caretSlop)
	}
	SETZOOM(zoomInPoints=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2373,"Uint",zoomInPoints,"Uint",0)
	}
	SHOWLINES(lineStart=0,lineEnd=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2226,"Uint",lineStart,"Uint",lineEnd)
	}
	STARTRECORD(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",3001,"Uint",0,"Uint",0)
	}
	STARTSTYLING(pos=0,mask=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2032,"Uint",pos,"Uint",mask)
	}
	STOPRECORD(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",3002,"Uint",0,"Uint",0)
	}
	STYLECLEARALL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2050,"Uint",0,"Uint",0)
	}
	STYLEGETBACK(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2482,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETBOLD(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2483,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETCASE(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2489,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETCHANGEABLE(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2492,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETCHARACTERSET(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2490,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETEOLFILLED(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2487,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETFONT(styleNumber=0){
		this.buf.Open(1024),DllCall(this.Func,"PTR",this.DirectPtr,"UInt",2486,"Uint",styleNumber,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"CP0")
	}
	STYLEGETFORE(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2481,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETHOTSPOT(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2493,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETITALIC(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2484,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETSIZE(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2485,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETUNDERLINE(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2488,"Uint",styleNumber,"Uint",0)
	}
	STYLEGETVISIBLE(styleNumber=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2491,"Uint",styleNumber,"Uint",0)
	}
	STYLERESETDEFAULT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2058,"Uint",0,"Uint",0)
	}
	STYLESETBACK(styleNumber=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2052,"Uint",styleNumber,"Uint",colour)
	}
	STYLESETBOLD(styleNumber=0,bold=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2053,"Uint",styleNumber,"Uint",bold)
	}
	STYLESETCASE(styleNumber=0,caseMode=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2060,"Uint",styleNumber,"Uint",caseMode)
	}
	STYLESETCHANGEABLE(styleNumber=0,changeable=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2099,"Uint",styleNumber,"Uint",changeable)
	}
	STYLESETCHARACTERSET(styleNumber=0,charSet=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2066,"Uint",styleNumber,"Uint",charSet)
	}
	STYLESETEOLFILLED(styleNumber=0,eolFilled=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2057,"Uint",styleNumber,"Uint",eolFilled)
	}
	STYLESETFONT(styleNumber=0,fontName=""){
		this.buf.Write(fontName)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2056,"Uint",styleNumber,"Uint",this.buf.bufAdr)
	}
	STYLESETFORE(styleNumber=0,colour=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2051,"Uint",styleNumber,"Uint",colour)
	}
	STYLESETHOTSPOT(styleNumber=0,hotspot=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2409,"Uint",styleNumber,"Uint",hotspot)
	}
	STYLESETITALIC(styleNumber=0,italic=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2054,"Uint",styleNumber,"Uint",italic)
	}
	STYLESETSIZE(styleNumber=0,sizeInPoints=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2055,"Uint",styleNumber,"Uint",sizeInPoints)
	}
	STYLESETUNDERLINE(styleNumber=0,underline=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2059,"Uint",styleNumber,"Uint",underline)
	}
	STYLESETVISIBLE(styleNumber=0,visible=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2074,"Uint",styleNumber,"Uint",visible)
	}
	SWAPMAINANCHORCARET(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2607,"Uint",0,"Uint",0)
	}
	TARGETASUTF8(){
		this.buf.Open(1024),DllCall(this.Func,"PTR",this.DirectPtr,"UInt",0,"Uint",this.buf.bufAdr),this.buf.Read()
		return StrGet(this.buf.ptr,"UTF-8")
	}
	TARGETFROMSELECTION(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2287,"Uint",0,"Uint",0)
	}
	TEXTHEIGHT(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2279,"Uint",line,"Uint",0)
	}
	TEXTWIDTH(styleNumber=0,text=""){
		this.buf.Write(text)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2276,"Uint",styleNumber,"Uint",this.buf.bufAdr)
	}
	TOGGLECARETSTICKY(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2459,"Uint",0,"Uint",0)
	}
	TOGGLEFOLD(line=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2231,"Uint",line,"Uint",0)
	}
	UNDO(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2176,"Uint",0,"Uint",0)
	}
	USEPOPUP(bEnablePopup=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2371,"Uint",bEnablePopup,"Uint",0)
	}
	USERLISTSHOW(listType=0,list=""){
		this.buf.Write(list)
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2117,"Uint",listType,"Uint",this.buf.bufAdr)
	}
	VISIBLEFROMDOCLINE(docLine=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2220,"Uint",docLine,"Uint",0)
	}
	WORDENDPOSITION(position=0,onlyWordCharacters=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2267,"Uint",position,"Uint",onlyWordCharacters)
	}
	WORDSTARTPOSITION(position=0,onlyWordCharacters=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2266,"Uint",position,"Uint",onlyWordCharacters)
	}
	WRAPCOUNT(docLine=0){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2235,"Uint",docLine,"Uint",0)
	}
	ZOOMIN(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2333,"Uint",0,"Uint",0)
	}
	ZOOMOUT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2334,"Uint",0,"Uint",0)
	}
	;Keyboard commands
	HOMERECTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2430,"Uint",0,"Uint",0)
	}
	BACKTAB(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2328,"Uint",0,"Uint",0)
	}
	CANCEL(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2325,"Uint",0,"Uint",0)
	}
	CHARLEFT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2304,"Uint",0,"Uint",0)
	}
	CHARLEFTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2305,"Uint",0,"Uint",0)
	}
	CHARLEFTRECTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2428,"Uint",0,"Uint",0)
	}
	CHARRIGHT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2306,"Uint",0,"Uint",0)
	}
	CHARRIGHTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2307,"Uint",0,"Uint",0)
	}
	CHARRIGHTRECTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2429,"Uint",0,"Uint",0)
	}
	DELETEBACK(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2326,"Uint",0,"Uint",0)
	}
	DELETEBACKNOTLINE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2344,"Uint",0,"Uint",0)
	}
	DELLINELEFT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2395,"Uint",0,"Uint",0)
	}
	DELLINERIGHT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2396,"Uint",0,"Uint",0)
	}
	DELWORDLEFT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2335,"Uint",0,"Uint",0)
	}
	DELWORDRIGHT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2336,"Uint",0,"Uint",0)
	}
	DELWORDRIGHTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2518,"Uint",0,"Uint",0)
	}
	DOCUMENTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2318,"Uint",0,"Uint",0)
	}
	DOCUMENTENDEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2319,"Uint",0,"Uint",0)
	}
	DOCUMENTSTART(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2316,"Uint",0,"Uint",0)
	}
	DOCUMENTSTARTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2317,"Uint",0,"Uint",0)
	}
	EDITTOGGLEOVERTYPE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2324,"Uint",0,"Uint",0)
	}
	FORMFEED(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2330,"Uint",0,"Uint",0)
	}
	HOME(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2312,"Uint",0,"Uint",0)
	}
	HOMEDISPLAY(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2345,"Uint",0,"Uint",0)
	}
	HOMEDISPLAYEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2346,"Uint",0,"Uint",0)
	}
	HOMEEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2313,"Uint",0,"Uint",0)
	}
	HOMEWRAP(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2349,"Uint",0,"Uint",0)
	}
	HOMEWRAPEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2450,"Uint",0,"Uint",0)
	}
	LINECOPY(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2455,"Uint",0,"Uint",0)
	}
	LINECUT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2337,"Uint",0,"Uint",0)
	}
	LINEDELETE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2338,"Uint",0,"Uint",0)
	}
	LINEDOWN(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2300,"Uint",0,"Uint",0)
	}
	LINEDOWNEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2301,"Uint",0,"Uint",0)
	}
	LINEDOWNRECTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2426,"Uint",0,"Uint",0)
	}
	LINEDUPLICATE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2404,"Uint",0,"Uint",0)
	}
	LINEEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2314,"Uint",0,"Uint",0)
	}
	LINEENDDISPLAY(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2347,"Uint",0,"Uint",0)
	}
	LINEENDDISPLAYEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2348,"Uint",0,"Uint",0)
	}
	LINEENDEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2315,"Uint",0,"Uint",0)
	}
	LINEENDRECTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2432,"Uint",0,"Uint",0)
	}
	LINEENDWRAP(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2451,"Uint",0,"Uint",0)
	}
	LINEENDWRAPEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2452,"Uint",0,"Uint",0)
	}
	LINESCROLLDOWN(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2342,"Uint",0,"Uint",0)
	}
	LINESCROLLUP(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2343,"Uint",0,"Uint",0)
	}
	LINETRANSPOSE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2339,"Uint",0,"Uint",0)
	}
	LINEUP(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2302,"Uint",0,"Uint",0)
	}
	LINEUPEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2303,"Uint",0,"Uint",0)
	}
	LINEUPRECTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2427,"Uint",0,"Uint",0)
	}
	LOWERCASE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2340,"Uint",0,"Uint",0)
	}
	NEWLINE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2329,"Uint",0,"Uint",0)
	}
	PAGEDOWN(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2322,"Uint",0,"Uint",0)
	}
	PAGEDOWNEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2323,"Uint",0,"Uint",0)
	}
	PAGEDOWNRECTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2434,"Uint",0,"Uint",0)
	}
	PAGEUP(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2320,"Uint",0,"Uint",0)
	}
	PAGEUPEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2321,"Uint",0,"Uint",0)
	}
	PAGEUPRECTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2433,"Uint",0,"Uint",0)
	}
	PARADOWN(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2413,"Uint",0,"Uint",0)
	}
	PARADOWNEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2414,"Uint",0,"Uint",0)
	}
	PARAUP(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2415,"Uint",0,"Uint",0)
	}
	PARAUPEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2416,"Uint",0,"Uint",0)
	}
	SELECTIONDUPLICATE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2469,"Uint",0,"Uint",0)
	}
	STUTTEREDPAGEDOWN(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2437,"Uint",0,"Uint",0)
	}
	STUTTEREDPAGEDOWNEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2438,"Uint",0,"Uint",0)
	}
	STUTTEREDPAGEUP(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2435,"Uint",0,"Uint",0)
	}
	STUTTEREDPAGEUPEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2436,"Uint",0,"Uint",0)
	}
	TAB(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2327,"Uint",0,"Uint",0)
	}
	UPPERCASE(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2341,"Uint",0,"Uint",0)
	}
	VCHOME(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2331,"Uint",0,"Uint",0)
	}
	VCHOMEEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2332,"Uint",0,"Uint",0)
	}
	VCHOMERECTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2431,"Uint",0,"Uint",0)
	}
	VCHOMEWRAP(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2453,"Uint",0,"Uint",0)
	}
	VCHOMEWRAPEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2454,"Uint",0,"Uint",0)
	}
	VERTICALCENTRECARET(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2619,"Uint",0,"Uint",0)
	}
	WORDLEFT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2308,"Uint",0,"Uint",0)
	}
	WORDLEFTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2439,"Uint",0,"Uint",0)
	}
	WORDLEFTENDEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2440,"Uint",0,"Uint",0)
	}
	WORDLEFTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2309,"Uint",0,"Uint",0)
	}
	WORDPARTLEFT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2390,"Uint",0,"Uint",0)
	}
	WORDPARTLEFTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2391,"Uint",0,"Uint",0)
	}
	WORDPARTRIGHT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2392,"Uint",0,"Uint",0)
	}
	WORDPARTRIGHTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2393,"Uint",0,"Uint",0)
	}
	WORDRIGHT(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2310,"Uint",0,"Uint",0)
	}
	WORDRIGHTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2441,"Uint",0,"Uint",0)
	}
	WORDRIGHTENDEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2442,"Uint",0,"Uint",0)
	}
	WORDRIGHTEXTEND(){
		return DllCall(this.Func,"PTR",this.DirectPtr,"Uint",2311,"Uint",0,"Uint",0)
	}

	StyleSet(style,set){
		for k,v in set
			If k in Font,Size,Bold,Size,Italic,underline,fore,back,case,characterset,visible,changable,hotspot,eolfilled
				this["STYLESET" k](style,v)
	}
}