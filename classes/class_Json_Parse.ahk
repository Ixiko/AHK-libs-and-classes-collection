; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; ====================================================================================================
; NAME ...............: JSON
; VERSION ............: 1.0.0
; AUTHOR .............: DuyMinh
; SPECIAL THANKS......: HuanHoang, Okamize
; ====================================================================================================

; ====================================================================================================
; DECLARE GLOBAL VARIABLES
; ====================================================================================================
global JSON_LIBRARY := JSON_INIT := JSON_OBJECT := ""

; [ JSON FUNCTION ] ==================================================================================
; #PUBLIC FUNCTION# ==================================================================================
; NAME ...............: 	_Json_Parse
; ====================================================================================================
_Json_Parse(sJson) {
	Local
	JSON_INIT := __Json_Init()
	; ------------------------------------------------------------
	; Can't initialize HTMLFile Object
	if (ErrorLevel || !IsObject(JSON_INIT))
		return ErrorLevel := 1
	; ------------------------------------------------------------
	JSON_PARSE := JSON_INIT.parse(sJson)
	; ------------------------------------------------------------
	; Can't parse json string
	if (ErrorLevel || !IsObject(JSON_PARSE))
		return ErrorLevel := 2
	return JSON_PARSE
}

; [ JSON FUNCTION ] ==================================================================================
; #PRIVATE FUNCTION# =================================================================================
; NAME ...............: 	__Json_Init
; ====================================================================================================
__Json_Init(JSON_DEFAULT := "{}") {
	Local iError := 0, oReturn := ""
	; ------------------------------------------------------------
	; → Add json library
	; ------------------------------------------------------------
	if (JSON_LIBRARY == "")
	{
		JSON_LIBRARY .= "function buildParamlist(t){var e="" p0"";t=t||1;for(var r=1;r<t;r++)e=e+"" , p""+r;return e}Object.prototype.propAdd=function(prop,val){eval(""this.""+prop+"
		JSON_LIBRARY .= """=""+val)},Object.prototype.methAdd=function(meth,def){eval(""this.""+meth+""= new ""+def)},Object.prototype.jsFunAdd=function(funname,numParams,objectType"
		JSON_LIBRARY .= "Name){var x=buildParamlist(numParams);return objectTypeName=objectTypeName||""Object"",eval(objectTypeName+"".prototype.""+funname+"" = function(""+x+"") { r"
		JSON_LIBRARY .= "eturn ""+funname+""(""+x+""); }"")},Object.prototype.protoAdd=function(methName,jsFunction,objectTypeName){objectTypeName=objectTypeName||""Object"",eval(obj"
		JSON_LIBRARY .= "ectTypeName+"".prototype.""+methName+""=""+jsFunction)},Object.keys||(Object.keys=function(){""use strict"";var o=Object.prototype.hasOwnProperty,a=!{toStri"
		JSON_LIBRARY .= "ng:null}.propertyIsEnumerable(""toString""),u=[""toString"",""toLocaleString"",""valueOf"",""hasOwnProperty"",""isPrototypeOf"",""propertyIsEnumerable"",""constructo"
		JSON_LIBRARY .= "r""],i=u.length;return function(t){if(""object""!=typeof t&&(""function""!=typeof t||null===t))throw new TypeError(""Object.keys called on non-object"");var "
		JSON_LIBRARY .= "e,r,n=[];for(e in t)o.call(t,e)&&n.push(e);if(a)for(r=0;r<i;r++)o.call(t,u[r])&&n.push(u[r]);return n}}()),Object.prototype.objGet=function(s){return "
		JSON_LIBRARY .= "eval(s)},Array.prototype.index=function(t){return this[t]},Object.prototype.index=function(t){return this[t]},Array.prototype.item=function(t){return "
		JSON_LIBRARY .= "this[t]},Object.prototype.item=function(t){return this[t]},Object.prototype.keys=function(){if(""object""==typeof this)return Object.keys(this)},Object."
		JSON_LIBRARY .= "prototype.keys=function(t){return (typeof t==""object""?Object.keys(t):Object.keys(this))},Object.prototype.arrayAdd=function(t,e){this[t]=e},Object.pro"
		JSON_LIBRARY .= "totype.arrayDel=function(t){this.splice(t,1)},Object.prototype.isArray=function(){return this.constructor==Array},Object.prototype.type=function(){ret"
		JSON_LIBRARY .= "urn typeof this},Object.prototype.type=function(t){if(""undefined""==typeof t){return typeof this}else{return typeof t}};var JSON=new Object;function js"
		JSON_LIBRARY .= "onPath(obj,expr,arg){var P={resultType:arg&&arg.resultType||""VALUE"",result:[],normalize:function(t){var r=[];return t.replace(/[\['](\??\(.*?\))[\]']/"
		JSON_LIBRARY .= "g,function(t,e){return""[#""+(r.push(e)-1)+""]""}).replace(/'?\.'?|\['?/g,"";"").replace(/;;;|;;/g,"";..;"").replace(/;$|'?\]|'$/g,"""").replace(/#([0-9]+)/g,fu"
		JSON_LIBRARY .= "nction(t,e){return r[e]})},asPath:function(t){for(var e=t.split("";""),r=""$"",n=1,o=e.length;n<o;n++)r+=/^[0-9*]+$/.test(e[n])?""[""+e[n]+""]"":""['""+e[n]+""']"
		JSON_LIBRARY .= """;return r},store:function(t,e){return t&&(P.result[P.result.length]=""PATH""==P.resultType?P.asPath(t):e),!!t},trace:function(t,e,r){if(t){var n=t.spli"
		JSON_LIBRARY .= "t("";""),o=n.shift();if(n=n.join("";""),e&&e.hasOwnProperty(o))P.trace(n,e[o],r+"";""+o);else if(""*""===o)P.walk(o,n,e,r,function(t,e,r,n,o){P.trace(t+"";""+r,"
		JSON_LIBRARY .= "n,o)});else if(""..""===o)P.trace(n,e,r),P.walk(o,n,e,r,function(t,e,r,n,o){""object""==typeof n[t]&&P.trace(""..;""+r,n[t],o+"";""+t)});else if(/,/.test(o))f"
		JSON_LIBRARY .= "or(var a=o.split(/'?,'?/),u=0,i=a.length;u<i;u++)P.trace(a[u]+"";""+n,e,r);else/^\(.*?\)$/.test(o)?P.trace(P.eval(o,e,r.substr(r.lastIndexOf("";"")+1))+"";"
		JSON_LIBRARY .= """+n,e,r):/^\?\(.*?\)$/.test(o)?P.walk(o,n,e,r,function(t,e,r,n,o){P.eval(e.replace(/^\?\((.*?)\)$/,""$1""),n[t],t)&&P.trace(t+"";""+r,n,o)}):/^(-?[0-9]*):"
		JSON_LIBRARY .= "(-?[0-9]*):?([0-9]*)$/.test(o)&&P.slice(o,n,e,r)}else P.store(r,e)},walk:function(t,e,r,n,o){if(r instanceof Array)for(var a=0,u=r.length;a<u;a++)a in"
		JSON_LIBRARY .= " r&&o(a,t,e,r,n);else if(""object""==typeof r)for(var i in r)r.hasOwnProperty(i)&&o(i,t,e,r,n)},slice:function(t,e,r,n){if(r instanceof Array){var o=r.l"
		JSON_LIBRARY .= "ength,a=0,u=o,i=1;t.replace(/^(-?[0-9]*):(-?[0-9]*):?(-?[0-9]*)$/g,function(t,e,r,n){a=parseInt(e||a),u=parseInt(r||u),i=parseInt(n||i)}),a=a<0?Math.m"
		JSON_LIBRARY .= "ax(0,a+o):Math.min(o,a),u=u<0?Math.max(0,u+o):Math.min(o,u);for(var p=a;p<u;p+=i)P.trace(p+"";""+e,r,n)}},eval:function(x,_v,_vname){try{return $&&_v&&e"
		JSON_LIBRARY .= "val(x.replace(/@/g,""_v""))}catch(t){throw new SyntaxError(""jsonPath: ""+t.message+"": ""+x.replace(/@/g,""_v"").replace(/\^/g,""_a""))}}},$=obj;if(expr&&obj&&"
		JSON_LIBRARY .= "(""VALUE""==P.resultType||""PATH""==P.resultType))return P.trace(P.normalize(expr).replace(/^\$;/,""""),obj,""$""),!!P.result.length&&P.result}function oLiter"
		JSON_LIBRARY .= "al(t){this.literal=t}function protectDoubleQuotes(t){return t.replace(/\\/g,""\\\\"").replace(/""/g,'\\""')}JSON.jsonPath=function(t,e,r){return jsonPath("
		JSON_LIBRARY .= "t,e,r)},""object""!=typeof JSON&&(JSON={}),function(){""use strict"";function f(t){return t<10?""0""+t:t}var cx,escapable,gap,indent,meta,rep;function quote"
		JSON_LIBRARY .= "(t){return escapable.lastIndex=0,escapable.test(t)?'""'+t.replace(escapable,function(t){var e=meta[t];return""string""==typeof e?e:""\\u""+(""0000""+t.charCo"
		JSON_LIBRARY .= "deAt(0).toString(16)).slice(-4)})+'""':'""'+t+'""'}function str(t,e){var r,n,o,a,u,i=gap,p=e[t];switch(p&&""object""==typeof p&&""function""==typeof p.toJSON"
		JSON_LIBRARY .= "&&(p=p.toJSON(t)),""function""==typeof rep&&(p=rep.call(e,t,p)),typeof p){case""string"":return quote(p);case""number"":return isFinite(p)?String(p):""null"";"
		JSON_LIBRARY .= "case""boolean"":case""null"":return String(p);case""object"":if(!p)return""null"";if(gap+=indent,u=[],""[object Array]""===Object.prototype.toString.apply(p)){f"
		JSON_LIBRARY .= "or(a=p.length,r=0;r<a;r+=1)u[r]=str(r,p)||""null"";return o=0===u.length?""[]"":gap?""[\n""+gap+u.join("",\n""+gap)+""\n""+i+""]"":""[""+u.join("","")+""]"",gap=i,o}if("
		JSON_LIBRARY .= "rep&&""object""==typeof rep)for(a=rep.length,r=0;r<a;r+=1)""string""==typeof rep[r]&&(o=str(n=rep[r],p))&&u.push(quote(n)+(gap?"": "":"":"")+o);else for(n in "
		JSON_LIBRARY .= "p)Object.prototype.hasOwnProperty.call(p,n)&&(o=str(n,p))&&u.push(quote(n)+(gap?"": "":"":"")+o);return o=0===u.length?""{}"":gap?""{\n""+gap+u.join("",\n""+gap"
		JSON_LIBRARY .= ")+""\n""+i+""}"":""{""+u.join("","")+""}"",gap=i,o}}""function""!=typeof Date.prototype.toJSON&&(Date.prototype.toJSON=function(){return isFinite(this.valueOf())?"
		JSON_LIBRARY .= "this.getUTCFullYear()+""-""+f(this.getUTCMonth()+1)+""-""+f(this.getUTCDate())+""T""+f(this.getUTCHours())+"":""+f(this.getUTCMinutes())+"":""+f(this.getUTCSeco"
		JSON_LIBRARY .= "nds())+""Z"":null},String.prototype.toJSON=Number.prototype.toJSON=Boolean.prototype.toJSON=function(){return this.valueOf()}),""function""!=typeof JSON.s"
		JSON_LIBRARY .= "tringify&&(escapable=/[\\\""\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,meta={"
		JSON_LIBRARY .= """\b"":""\\b"",""\t"":""\\t"",""\n"":""\\n"",""\f"":""\\f"",""\r"":""\\r"",'""':'\\""',""\\"":""\\\\""},JSON.stringify=function(t,e,r){var n;if(indent=gap="""",""number""==typeof r"
		JSON_LIBRARY .= ")for(n=0;n<r;n+=1)indent+="" "";else""string""==typeof r&&(indent=r);if((rep=e)&&""function""!=typeof e&&(""object""!=typeof e||""number""!=typeof e.length))thr"
		JSON_LIBRARY .= "ow new Error(""JSON.stringify"");return str("""",{"""":t})}),""function""!=typeof JSON.parse&&(cx=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u"
		JSON_LIBRARY .= "2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,JSON.parse=function(text,reviver){var j;function walk(t,e){var r,n,o=t[e];if(o&&""object""==typeof o)for("
		JSON_LIBRARY .= "r in o)Object.prototype.hasOwnProperty.call(o,r)&&(void 0!==(n=walk(o,r))?o[r]=n:delete o[r]);return reviver.call(t,e,o)}if(text=String(text),cx.lastI"
		JSON_LIBRARY .= "ndex=0,cx.test(text)&&(text=text.replace(cx,function(t){return""\\u""+(""0000""+t.charCodeAt(0).toString(16)).slice(-4)})),/^[\],:{}\s]*$/.test(text.repla"
		JSON_LIBRARY .= "ce(/\\(?:[""\\\/bfnrt]|u[0-9a-fA-F]{4})/g,""@"").replace(/""[^""\\\n\r]*""|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,""]"").replace(/(?:^|:|,)(?:\s*"
		JSON_LIBRARY .= "\[)+/g,"""")))return j=eval(""(""+text+"")""),""function""==typeof reviver?walk({"""":j},""""):j;throw new SyntaxError(""JSON.parse"")})}(),Object.prototype.stringi"
		JSON_LIBRARY .= "fy=function(){return JSON.stringify(this)},Object.prototype.parse=function(t){return JSON.parse(t)},Object.prototype.jsonPath=function(t,e){return JSO"
		JSON_LIBRARY .= "N.jsonPath(this,t,e)},Object.prototype.objToString=function(){return JSON.stringify(this)},Object.prototype.strToObject=function(t){return JSON.parse("
		JSON_LIBRARY .= "t)},Object.prototype.dot=function(str,jsStrFun){return""string""==typeof str?eval('""'+protectDoubleQuotes(str)+'"".'+jsStrFun):eval(str+"".""+jsStrFun)},Ob"
		JSON_LIBRARY .= "ject.prototype.toObj=function(literal){return""string""==typeof literal?eval('new oLiteral(""'+protectDoubleQuotes(literal)+'"")'):eval(""new oLiteral(""+li"
		JSON_LIBRARY .= "teral+"")"")},Object.prototype.jsMethAdd=function(funname,numParams){var x=buildParamlist(numParams);return eval(""oLiteral.prototype.""+funname+"" = funct"
		JSON_LIBRARY .= "ion(""+x+""){return this.literal.""+funname+""(""+x+""); }"")},Object.prototype.beautify=function(r){return JSON.stringify(this,null,typeof r=='undefined'?4:"
		JSON_LIBRARY .= "r)},Object.prototype.toStr=function(r){if(r<0){return JSON.stringify(this.stringify())}else{return JSON.stringify(this,null,typeof r=='undefined'?null"
		JSON_LIBRARY .= ":r)}},Object.prototype.toParent=function(){return JSON},Object.prototype.remove=function(key_name){eval(""delete this.""+key_name)},Object.prototype.upd"
		JSON_LIBRARY .= "ate=function(key_name,val){if(val==""{del}""){eval(""delete this.""+key_name)}else{eval(""this.""+key_name+""=""+val)}},Object.prototype.sort=function(){},Obj"
		JSON_LIBRARY .= "ect.prototype.reverse=function(){},Object.prototype.min=function(){return Math.min.apply(null,this)},Object.prototype.max=function(){return Math.max.a"
		JSON_LIBRARY .= "pply(null,this)},JSON.filter=JSON.jsonPath,Object.prototype.filter=Object.prototype.jsonPath;"
	}
	; ------------------------------------------------------------
	; → Create HTMLFile Object
	; ------------------------------------------------------------
	if !IsObject(JSON_INIT)
	{
		JSON_OBJECT := ComObjCreate("HTMLFILE")
		; ------------------------------------------------------------
		if ErrorLevel
			iError := 1
		; ------------------------------------------------------------
		else
		{
			JSON_OBJECT.parentwindow.execScript(JSON_LIBRARY)
			if (ErrorLevel)
				iError := 2
			else
			{
				JSON_OBJECT.parentwindow.eval("var z = " . JSON_DEFAULT)
				oReturn := JSON_OBJECT.parentwindow.eval("z").objGet("JSON")
				if (ErrorLevel || !IsObject(oReturn))
					iError := 3
				else
					JSON_INIT := oReturn
			}
		}
	}
	else
		return JSON_INIT
	; ------------------------------------------------------------
	if iError
		JSON_INIT := ""
	; ------------------------------------------------------------
	ErrorLevel := iError
	return oReturn
}