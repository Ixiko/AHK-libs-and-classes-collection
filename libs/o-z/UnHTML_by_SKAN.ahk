; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=319141#p319141
; Author:	SKAN
; Date:
; for:     	AHK_L

/*

  Please do not expect UnHTMl() to unformat a whole HTML file. If you have already parsed out a string, and need to unformat it to plain text, then UnHTML() would be handy.
  I originally wrote this function intending to post in topic HTML Decoder by @Freire.
  I don't recognize or remember the RegEx used in this function. Any suggestion/improvement is most welcome.


  UnHTML( HTM, PPT , RUE )
  A basic version that supports all HTML 4 entitties

  Parameters:
  HTM : Source text with HTML formatting
  PPT: Pre-process Text? Default value is true,. When true will remove all HTML tags from result.
  RUE: Remove undefined entities? Default value is true. When false, will prefix a & to the undefined entity. for eg. &undef; will be replaced with &&undef;
  Usage example:
  Code: Select all - Toggle Line numbers

  HTM := "<a href='https://en.wikipedia.org/wiki/Romeo_and_Juliet'><b>Romeo &amp; Juliet</b></a>"
  MsgBox, % UnHTML(HTM) ; Romeo & Juliet

*/

UnHTML( HTM, PPT:=1, RUE:=1 ) {                              ; By SKAN on D1BN/D33P @ tiny.cc/unhtml
Local Asc, E, K, P:=1
Static HEN := "
 (  LTrim Join
             {HTML4:,Aacute:193,aacute:225,Acirc:194,acirc:226,acute:180,add:43,AElig:198,aelig:230,
    Agrave:192,agrave:224,alefsym:8501,Alpha:913,alpha:945,amp:38,and:8743,ang:8736,apos:39,Aring:19
    7,aring:229,asymp:8776,Atilde:195,atilde:227,Auml:196,auml:228,bdquo:8222,Beta:914,beta:946,brvb
    ar:166,bull:8226,cap:8745,Ccedil:199,ccedil:231,cedil:184,cent:162,Chi:935,chi:967,circ:710,club
    s:9827,cong:8773,copy:169,crarr:8629,cup:8746,curren:164,dagger:8224,Dagger:8225,darr:8595,dArr:
    8659,deg:176,Delta:916,delta:948,diams:9830,divide:247,Eacute:201,eacute:233,Ecirc:202,ecirc:234
    ,Egrave:200,egrave:232,empty:8709,emsp:8195,ensp:8194,Epsilon:917,epsilon:949,equal:61,equiv:880
    1,Eta:919,eta:951,ETH:208,eth:240,Euml:203,euml:235,euro:8364,exclamation:33,exist:8707,fnof:402
    ,forall:8704,frac12:189,frac14:188,frac34:190,frasl:8260,Gamma:915,gamma:947,ge:8805,gt:62,harr:
    8596,hArr:8660,hearts:9829,hellip:8230,horbar:8213,Iacute:205,iacute:237,Icirc:206,icirc:238,iex
    cl:161,Igrave:204,igrave:236,image:8465,infin:8734,int:8747,Iota:921,iota:953,iquest:191,isin:87
    12,Iuml:207,iuml:239,Kappa:922,kappa:954,Lambda:923,lambda:955,lang:9001,laquo:171,larr:8592,lAr
    r:8656,lceil:8968,ldquo:8220,le:8804,lfloor:8970,lowast:8727,loz:9674,lrm:8206,lsaquo:8249,lsquo
    :8216,lt:60,macr:175,mdash:8212,micro:181,middot:183,minus:8722,Mu:924,mu:956,nabla:8711,nbsp:16
    0,ndash:8211,ne:8800,ni:8715,not:172,notin:8713,nsub:8836,Ntilde:209,ntilde:241,Nu:925,nu:957,Oa
    cute:211,oacute:243,Ocirc:212,ocirc:244,OElig:338,oelig:339,Ograve:210,ograve:242,oline:8254,Ome
    ga:937,omega:969,Omicron:927,omicron:959,oplus:8853,or:8744,ordf:170,ordm:186,Oslash:216,oslash:
    248,Otilde:213,otilde:245,otimes:8855,Ouml:214,ouml:246,para:182,part:8706,percent:37,permil:824
    0,perp:8869,Phi:934,phi:966,Pi:928,pi:960,piv:982,plusmn:177,pound:163,prime:8242,Prime:8243,pro
    d:8719,prop:8733,Psi:936,psi:968,quot:34,radic:8730,rang:9002,raquo:187,rarr:8594,rArr:8658,rcei
    l:8969,rdquo:8221,real:8476,reg:174,rfloor:8971,Rho:929,rho:961,rlm:8207,rsaquo:8250,rsquo:8217,
    sbquo:8218,Scaron:352,scaron:353,sdot:8901,sect:167,shy:173,Sigma:931,sigma:963,sigmaf:962,sim:8
    764,spades:9824,sub:8834,sube:8838,sum:8721,sup:8835,sup1:185,sup2:178,sup3:179,supe:8839,szlig:
    223,Tau:932,tau:964,there4:8756,Theta:920,theta:952,thetasym:977,thinsp:8201,THORN:222,thorn:254
    ,tilde:732,times:215,trade:8482,Uacute:218,uacute:250,uarr:8593,uArr:8657,Ucirc:219,ucirc:251,Ug
    rave:217,ugrave:249,uml:168,upsih:978,Upsilon:933,upsilon:965,Uuml:220,uuml:252,weierp:8472,Xi:9
    26,xi:958,Yacute:221,yacute:253,yen:165,yuml:255,Yuml:376,Zeta:918,zeta:950,zwj:8205,zwnj:8204,}
 )"

  HTM := !PPT ? HTM : RegExReplace(HTM,"<[^>]+>") ; Remove all text wrapped within "<" and ">"

  While ( P := RegExMatch(HTM, "(?<!&)&[#a-zA-Z0-9]+;", E, P) )  and  (K := Trim(E,"&#;") )    {
       Asc  := ( SubStr(E,1,3) = "&#x" ? ("0" . K)
            :    SubStr(E,1,2) = "&#"  ? (      K)
            :    RegExMatch(HEN,   "(?<=," . K . ":)[0-9]+(?=,)", Asc) ? Asc
            :    RegExMatch(HEN, "i)(?<=," . K . ":)[0-9]+(?=,)", Asc) ? Asc : 0)

     , HTM  := RegExReplace(HTM, E, Asc ? Chr(Asc) : RUE=0 ? ("&" . E)  : "")
    }

Return HTM
}

; UnHTML5( HTM, PPT , RUE )
; An extended version that supports all HTML 5 entitties
UnHTML5( HTM, PPT:=1, RUE:=1 ) {                             ; By SKAN on D1BN/D33P @ tiny.cc/unhtml
Local Asc, E, K, P:=1
Static HEN := ""
  If ! VarSetCapacity(HEN)
    {
    HEN := "                             ; Data source: https://dev.w3.org/html5/html-author/charref
    ( LTrim Join
                   {HTML5:,Tab:9,NewLine:10,excl:33,quot:34,QUOT:34,num:35,dollar:36,percnt:37,amp:3
    8,AMP:38,apos:39,lpar:40,rpar:41,ast:42,midast:42,plus:43,comma:44,period:46,sol:47,colon:58,sem
    i:59,lt:60,LT:60,equals:61,gt:62,GT:62,quest:63,commat:64,lsqb:91,lbrack:91,bsol:92,rsqb:93,rbra
    ck:93,Hat:94,lowbar:95,grave:96,DiacriticalGrave:96,lcub:123,lbrace:123,verbar:124,vert:124,Vert
    icalLine:124,rcub:125,rbrace:125,nbsp:160,NonBreakingSpace:160,iexcl:161,cent:162,pound:163,curr
    en:164,yen:165,brvbar:166,sect:167,Dot:168,die:168,DoubleDot:168,uml:168,copy:169,COPY:169,ordf:
    170,laquo:171,not:172,shy:173,reg:174,circledR:174,REG:174,macr:175,OverBar:175,strns:175,deg:17
    6,plusmn:177,pm:177,PlusMinus:177,sup2:178,sup3:179,acute:180,DiacriticalAcute:180,micro:181,par
    a:182,middot:183,centerdot:183,CenterDot:183,cedil:184,Cedilla:184,sup1:185,ordm:186,raquo:187,f
    rac14:188,frac12:189,half:189,frac34:190,iquest:191,Agrave:192,Aacute:193,Acirc:194,Atilde:195,A
    uml:196,Aring:197,AElig:198,Ccedil:199,Egrave:200,Eacute:201,Ecirc:202,Euml:203,Igrave:204,Iacut
    e:205,Icirc:206,Iuml:207,ETH:208,Ntilde:209,Ograve:210,Oacute:211,Ocirc:212,Otilde:213,Ouml:214,
    times:215,Oslash:216,Ugrave:217,Uacute:218,Ucirc:219,Uuml:220,Yacute:221,THORN:222,szlig:223,agr
    ave:224,aacute:225,acirc:226,atilde:227,auml:228,aring:229,aelig:230,ccedil:231,egrave:232,eacut
    e:233,ecirc:234,euml:235,igrave:236,iacute:237,icirc:238,iuml:239,eth:240,ntilde:241,ograve:242,
    oacute:243,ocirc:244,otilde:245,ouml:246,divide:247,div:247,oslash:248,ugrave:249,uacute:250,uci
    rc:251,uuml:252,yacute:253,thorn:254,yuml:255,Amacr:256,amacr:257,Abreve:258,abreve:259,Aogon:26
    0,aogon:261,Cacute:262,cacute:263,Ccirc:264,ccirc:265,Cdot:266,cdot:267,Ccaron:268,ccaron:269,Dc
    aron:270,dcaron:271,Dstrok:272,dstrok:273,Emacr:274,emacr:275,Edot:278,edot:279,Eogon:280,eogon:
    281,Ecaron:282,ecaron:283,Gcirc:284,gcirc:285,Gbreve:286,gbreve:287,Gdot:288,gdot:289,Gcedil:290
    ,Hcirc:292,hcirc:293,Hstrok:294,hstrok:295,Itilde:296,itilde:297,Imacr:298,imacr:299,Iogon:302,i
    ogon:303,Idot:304,imath:305,inodot:305,IJlig:306,ijlig:307,Jcirc:308,jcirc:309,Kcedil:310,kcedil
    :311,kgreen:312,Lacute:313,lacute:314,Lcedil:315,lcedil:316,Lcaron:317,lcaron:318,Lmidot:319,lmi
    dot:320,Lstrok:321,lstrok:322,Nacute:323,nacute:324,Ncedil:325,ncedil:326,Ncaron:327,ncaron:328,
    napos:329,ENG:330,eng:331,Omacr:332,omacr:333,Odblac:336,odblac:337,OElig:338,oelig:339,Racute:3
    40,racute:341,Rcedil:342,rcedil:343,Rcaron:344,rcaron:345,Sacute:346,sacute:347,Scirc:348,scirc:
    349,Scedil:350,scedil:351,Scaron:352,scaron:353,Tcedil:354,tcedil:355,Tcaron:356,tcaron:357,Tstr
    ok:358,tstrok:359,Utilde:360,utilde:361,Umacr:362,umacr:363,Ubreve:364,ubreve:365,Uring:366,urin
    g:367,Udblac:368,udblac:369,Uogon:370,uogon:371,Wcirc:372,wcirc:373,Ycirc:374,ycirc:375,Yuml:376
    ,Zacute:377,zacute:378,Zdot:379,zdot:380,Zcaron:381,zcaron:382,fnof:402,imped:437,gacute:501,jma
    th:567,circ:710,caron:711,Hacek:711,breve:728,Breve:728,dot:729,DiacriticalDot:729,ring:730,ogon
    :731,tilde:732,DiacriticalTilde:732,dblac:733,DiacriticalDoubleAcute:733,DownBreve:785,UnderBar:
    818,Alpha:913,Beta:914,Gamma:915,Delta:916,Epsilon:917,Zeta:918,Eta:919,Theta:920,Iota:921,Kappa
    :922,Lambda:923,Mu:924,Nu:925,Xi:926,Omicron:927,Pi:928,Rho:929,Sigma:931,Tau:932,Upsilon:933,Ph
    i:934,Chi:935,Psi:936,Omega:937,alpha:945,beta:946,gamma:947,delta:948,epsiv:949,varepsilon:949,
    epsilon:949,zeta:950,eta:951,theta:952,iota:953,kappa:954,lambda:955,mu:956,nu:957,xi:958,omicro
    n:959,pi:960,rho:961,sigmav:962,varsigma:962,sigmaf:962,sigma:963,tau:964,upsi:965,upsilon:965,p
    hi:966,phiv:966,varphi:966,chi:967,psi:968,omega:969,thetav:977,vartheta:977,thetasym:977,Upsi:9
    78,upsih:978,straightphi:981,piv:982,varpi:982,Gammad:988,gammad:989,digamma:989,kappav:1008,var
    kappa:1008,rhov:1009,varrho:1009,epsi:1013,straightepsilon:1013,bepsi:1014,backepsilon:1014,IOcy
    :1025,DJcy:1026,GJcy:1027,Jukcy:1028,DScy:1029,Iukcy:1030,YIcy:1031,Jsercy:1032,LJcy:1033,NJcy:1
    034,TSHcy:1035,KJcy:1036,Ubrcy:1038,DZcy:1039,Acy:1040,Bcy:1041,Vcy:1042,Gcy:1043,Dcy:1044,IEcy:
    1045,ZHcy:1046,Zcy:1047,Icy:1048,Jcy:1049,Kcy:1050,Lcy:1051,Mcy:1052,Ncy:1053,Ocy:1054,Pcy:1055,
    Rcy:1056,Scy:1057,Tcy:1058,Ucy:1059,Fcy:1060,KHcy:1061,TScy:1062,CHcy:1063,SHcy:1064,SHCHcy:1065
    ,HARDcy:1066,Ycy:1067,SOFTcy:1068,Ecy:1069,YUcy:1070,YAcy:1071,acy:1072,bcy:1073,vcy:1074,gcy:10
    75,dcy:1076,iecy:1077,zhcy:1078,zcy:1079,icy:1080,jcy:1081,kcy:1082,lcy:1083,mcy:1084,ncy:1085,o
    cy:1086,pcy:1087,rcy:1088,scy:1089,tcy:1090,ucy:1091,fcy:1092,khcy:1093,tscy:1094,chcy:1095,shcy
    :1096,shchcy:1097,hardcy:1098,ycy:1099,softcy:1100,ecy:1101,yucy:1102,yacy:1103,iocy:1105,djcy:1
    106,gjcy:1107,jukcy:1108,dscy:1109,iukcy:1110,yicy:1111,jsercy:1112,ljcy:1113,njcy:1114,tshcy:11
    15,kjcy:1116,ubrcy:1118,dzcy:1119,ensp:8194,emsp:8195,emsp13:8196,emsp14:8197,numsp:8199,puncsp:
    8200,thinsp:8201,ThinSpace:8201,hairsp:8202,VeryThinSpace:8202,ZeroWidthSpace:8203,NegativeVeryT
    hinSpace:8203,NegativeThinSpace:8203,NegativeMediumSpace:8203,NegativeThickSpace:8203,zwnj:8204,
    zwj:8205,lrm:8206,rlm:8207,hyphen:8208,dash:8208,ndash:8211,mdash:8212,horbar:8213,Verbar:8214,V
    ert:8214,lsquo:8216,OpenCurlyQuote:8216,rsquo:8217,rsquor:8217,CloseCurlyQuote:8217,lsquor:8218,
    sbquo:8218,ldquo:8220,OpenCurlyDoubleQuote:8220,rdquo:8221,rdquor:8221,CloseCurlyDoubleQuote:822
    1,ldquor:8222,bdquo:8222,dagger:8224,Dagger:8225,ddagger:8225,bull:8226,bullet:8226,nldr:8229,he
    llip:8230,mldr:8230,permil:8240,pertenk:8241,prime:8242,Prime:8243,tprime:8244,bprime:8245,backp
    rime:8245,lsaquo:8249,rsaquo:8250,oline:8254,caret:8257,hybull:8259,frasl:8260,bsemi:8271,qprime
    :8279,MediumSpace:8287,NoBreak:8288,ApplyFunction:8289,af:8289,InvisibleTimes:8290,it:8290,Invis
    ibleComma:8291,ic:8291,euro:8364,tdot:8411,TripleDot:8411,DotDot:8412,Copf:8450,complexes:8450,i
    ncare:8453,gscr:8458,hamilt:8459,HilbertSpace:8459,Hscr:8459,Hfr:8460,Poincareplane:8460,quatern
    ions:8461,Hopf:8461,planckh:8462,planck:8463,hbar:8463,plankv:8463,hslash:8463,Iscr:8464,imaglin
    e:8464,image:8465,Im:8465,imagpart:8465,Ifr:8465,Lscr:8466,lagran:8466,Laplacetrf:8466,ell:8467,
    Nopf:8469,naturals:8469,numero:8470,copysr:8471,weierp:8472,wp:8472,Popf:8473,primes:8473,ration
    als:8474,Qopf:8474,Rscr:8475,realine:8475,real:8476,Re:8476,realpart:8476,Rfr:8476,reals:8477,Ro
    pf:8477,rx:8478,trade:8482,TRADE:8482,integers:8484,Zopf:8484,ohm:8486,mho:8487,Zfr:8488,zeetrf:
    8488,iiota:8489,angst:8491,bernou:8492,Bernoullis:8492,Bscr:8492,Cfr:8493,Cayleys:8493,escr:8495
    ,Escr:8496,expectation:8496,Fscr:8497,Fouriertrf:8497,phmmat:8499,Mellintrf:8499,Mscr:8499,order
    :8500,orderof:8500,oscr:8500,alefsym:8501,aleph:8501,beth:8502,gimel:8503,daleth:8504,CapitalDif
    ferentialD:8517,DD:8517,DifferentialD:8518,dd:8518,ExponentialE:8519,exponentiale:8519,ee:8519,I
    maginaryI:8520,ii:8520,frac13:8531,frac23:8532,frac15:8533,frac25:8534,frac35:8535,frac45:8536,f
    rac16:8537,frac56:8538,frac18:8539,frac38:8540,frac58:8541,frac78:8542,larr:8592,leftarrow:8592,
    LeftArrow:8592,slarr:8592,ShortLeftArrow:8592,uarr:8593,uparrow:8593,UpArrow:8593,ShortUpArrow:8
    593,rarr:8594,rightarrow:8594,RightArrow:8594,srarr:8594,ShortRightArrow:8594,darr:8595,downarro
    w:8595,DownArrow:8595,ShortDownArrow:8595,harr:8596,leftrightarrow:8596,LeftRightArrow:8596,varr
    :8597,updownarrow:8597,UpDownArrow:8597,nwarr:8598,UpperLeftArrow:8598,nwarrow:8598,nearr:8599,U
    pperRightArrow:8599,nearrow:8599,searr:8600,searrow:8600,LowerRightArrow:8600,swarr:8601,swarrow
    :8601,LowerLeftArrow:8601,nlarr:8602,nleftarrow:8602,nrarr:8603,nrightarrow:8603,rarrw:8605,righ
    tsquigarrow:8605,Larr:8606,twoheadleftarrow:8606,Uarr:8607,Rarr:8608,twoheadrightarrow:8608,Darr
    :8609,larrtl:8610,leftarrowtail:8610,rarrtl:8611,rightarrowtail:8611,LeftTeeArrow:8612,mapstolef
    t:8612,UpTeeArrow:8613,mapstoup:8613,map:8614,RightTeeArrow:8614,mapsto:8614,DownTeeArrow:8615,m
    apstodown:8615,larrhk:8617,hookleftarrow:8617,rarrhk:8618,hookrightarrow:8618,larrlp:8619,loopar
    rowleft:8619,rarrlp:8620,looparrowright:8620,harrw:8621,leftrightsquigarrow:8621,nharr:8622,nlef
    trightarrow:8622,lsh:8624,Lsh:8624,rsh:8625,Rsh:8625,ldsh:8626,rdsh:8627,crarr:8629,cularr:8630,
    curvearrowleft:8630,curarr:8631,curvearrowright:8631,olarr:8634,circlearrowleft:8634,orarr:8635,
    circlearrowright:8635,lharu:8636,LeftVector:8636,leftharpoonup:8636,lhard:8637,leftharpoondown:8
    637,DownLeftVector:8637,uharr:8638,upharpoonright:8638,RightUpVector:8638,uharl:8639,upharpoonle
    ft:8639,LeftUpVector:8639,rharu:8640,RightVector:8640,rightharpoonup:8640,rhard:8641,rightharpoo
    ndown:8641,DownRightVector:8641,dharr:8642,RightDownVector:8642,downharpoonright:8642,dharl:8643
    ,LeftDownVector:8643,downharpoonleft:8643,rlarr:8644,rightleftarrows:8644,RightArrowLeftArrow:86
    44,udarr:8645,UpArrowDownArrow:8645,lrarr:8646,leftrightarrows:8646,LeftArrowRightArrow:8646,lla
    rr:8647,leftleftarrows:8647,uuarr:8648,upuparrows:8648,rrarr:8649,rightrightarrows:8649,ddarr:86
    50,downdownarrows:8650,lrhar:8651,ReverseEquilibrium:8651,leftrightharpoons:8651,rlhar:8652,righ
    tleftharpoons:8652,Equilibrium:8652,nlArr:8653,nLeftarrow:8653,nhArr:8654,nLeftrightarrow:8654,n
    rArr:8655,nRightarrow:8655,lArr:8656,Leftarrow:8656,DoubleLeftArrow:8656,uArr:8657,Uparrow:8657,
    DoubleUpArrow:8657,rArr:8658,Rightarrow:8658,Implies:8658,DoubleRightArrow:8658,dArr:8659,Downar
    row:8659,DoubleDownArrow:8659,hArr:8660,Leftrightarrow:8660,DoubleLeftRightArrow:8660,iff:8660,v
    Arr:8661,Updownarrow:8661,DoubleUpDownArrow:8661,nwArr:8662,neArr:8663,seArr:8664,swArr:8665,lAa
    rr:8666,Lleftarrow:8666,rAarr:8667,Rrightarrow:8667,zigrarr:8669,larrb:8676,LeftArrowBar:8676,ra
    rrb:8677,RightArrowBar:8677,duarr:8693,DownArrowUpArrow:8693,loarr:8701,roarr:8702,hoarr:8703,fo
    rall:8704,ForAll:8704,comp:8705,complement:8705,part:8706,PartialD:8706,exist:8707,Exists:8707,n
    exist:8708,NotExists:8708,nexists:8708,empty:8709,emptyset:8709,emptyv:8709,varnothing:8709,nabl
    a:8711,Del:8711,isin:8712,isinv:8712,Element:8712,in:8712,notin:8713,NotElement:8713,notinva:871
    3,niv:8715,ReverseElement:8715,ni:8715,SuchThat:8715,notni:8716,notniva:8716,NotReverseElement:8
    716,prod:8719,Product:8719,coprod:8720,Coproduct:8720,sum:8721,Sum:8721,minus:8722,mnplus:8723,m
    p:8723,MinusPlus:8723,plusdo:8724,dotplus:8724,setmn:8726,setminus:8726,Backslash:8726,ssetmn:87
    26,smallsetminus:8726,lowast:8727,compfn:8728,SmallCircle:8728,radic:8730,Sqrt:8730,prop:8733,pr
    opto:8733,Proportional:8733,vprop:8733,varpropto:8733,infin:8734,angrt:8735,ang:8736,angle:8736,
    angmsd:8737,measuredangle:8737,angsph:8738,mid:8739,VerticalBar:8739,smid:8739,shortmid:8739,nmi
    d:8740,NotVerticalBar:8740,nsmid:8740,nshortmid:8740,par:8741,parallel:8741,DoubleVerticalBar:87
    41,spar:8741,shortparallel:8741,npar:8742,nparallel:8742,NotDoubleVerticalBar:8742,nspar:8742,ns
    hortparallel:8742,and:8743,wedge:8743,or:8744,vee:8744,cap:8745,cup:8746,int:8747,Integral:8747,
    Int:8748,tint:8749,iiint:8749,conint:8750,oint:8750,ContourIntegral:8750,Conint:8751,DoubleConto
    urIntegral:8751,Cconint:8752,cwint:8753,cwconint:8754,ClockwiseContourIntegral:8754,awconint:875
    5,CounterClockwiseContourIntegral:8755,there4:8756,therefore:8756,Therefore:8756,becaus:8757,bec
    ause:8757,Because:8757,ratio:8758,Colon:8759,Proportion:8759,minusd:8760,dotminus:8760,mDDot:876
    2,homtht:8763,sim:8764,Tilde:8764,thksim:8764,thicksim:8764,bsim:8765,backsim:8765,ac:8766,mstpo
    s:8766,acd:8767,wreath:8768,VerticalTilde:8768,wr:8768,nsim:8769,NotTilde:8769,esim:8770,EqualTi
    lde:8770,eqsim:8770,sime:8771,TildeEqual:8771,simeq:8771,nsime:8772,nsimeq:8772,NotTildeEqual:87
    72,cong:8773,TildeFullEqual:8773,simne:8774,ncong:8775,NotTildeFullEqual:8775,asymp:8776,ap:8776
    ,TildeTilde:8776,approx:8776,thkap:8776,thickapprox:8776,nap:8777,NotTildeTilde:8777,napprox:877
    7,ape:8778,approxeq:8778,apid:8779,bcong:8780,backcong:8780,asympeq:8781,CupCap:8781,bump:8782,H
    umpDownHump:8782,Bumpeq:8782,bumpe:8783,HumpEqual:8783,bumpeq:8783,esdot:8784,DotEqual:8784,dote
    q:8784,eDot:8785,doteqdot:8785,efDot:8786,fallingdotseq:8786,erDot:8787,risingdotseq:8787,colone
    :8788,coloneq:8788,Assign:8788,ecolon:8789,eqcolon:8789,ecir:8790,eqcirc:8790,cire:8791,circeq:8
    791,wedgeq:8793,veeeq:8794,trie:8796,triangleq:8796,equest:8799,questeq:8799,ne:8800,NotEqual:88
    00,equiv:8801,Congruent:8801,nequiv:8802,NotCongruent:8802,le:8804,leq:8804,ge:8805,GreaterEqual
    :8805,geq:8805,lE:8806,LessFullEqual:8806,leqq:8806,gE:8807,GreaterFullEqual:8807,geqq:8807,lnE:
    8808,lneqq:8808,gnE:8809,gneqq:8809,Lt:8810,NestedLessLess:8810,ll:8810,Gt:8811,NestedGreaterGre
    ater:8811,gg:8811,twixt:8812,between:8812,NotCupCap:8813,nlt:8814,NotLess:8814,nless:8814,ngt:88
    15,NotGreater:8815,ngtr:8815,nle:8816,NotLessEqual:8816,nleq:8816,nge:8817,NotGreaterEqual:8817,
    ngeq:8817,lsim:8818,LessTilde:8818,lesssim:8818,gsim:8819,gtrsim:8819,GreaterTilde:8819,nlsim:88
    20,NotLessTilde:8820,ngsim:8821,NotGreaterTilde:8821,lg:8822,lessgtr:8822,LessGreater:8822,gl:88
    23,gtrless:8823,GreaterLess:8823,ntlg:8824,NotLessGreater:8824,ntgl:8825,NotGreaterLess:8825,pr:
    8826,Precedes:8826,prec:8826,sc:8827,Succeeds:8827,succ:8827,prcue:8828,PrecedesSlantEqual:8828,
    preccurlyeq:8828,sccue:8829,SucceedsSlantEqual:8829,succcurlyeq:8829,prsim:8830,precsim:8830,Pre
    cedesTilde:8830,scsim:8831,succsim:8831,SucceedsTilde:8831,npr:8832,nprec:8832,NotPrecedes:8832,
    nsc:8833,nsucc:8833,NotSucceeds:8833,sub:8834,subset:8834,sup:8835,supset:8835,Superset:8835,nsu
    b:8836,nsup:8837,sube:8838,SubsetEqual:8838,subseteq:8838,supe:8839,supseteq:8839,SupersetEqual:
    8839,nsube:8840,nsubseteq:8840,NotSubsetEqual:8840,nsupe:8841,nsupseteq:8841,NotSupersetEqual:88
    41,subne:8842,subsetneq:8842,supne:8843,supsetneq:8843,cupdot:8845,uplus:8846,UnionPlus:8846,sqs
    ub:8847,SquareSubset:8847,sqsubset:8847,sqsup:8848,SquareSuperset:8848,sqsupset:8848,sqsube:8849
    ,SquareSubsetEqual:8849,sqsubseteq:8849,sqsupe:8850,SquareSupersetEqual:8850,sqsupseteq:8850,sqc
    ap:8851,SquareIntersection:8851,sqcup:8852,SquareUnion:8852,oplus:8853,CirclePlus:8853,ominus:88
    54,CircleMinus:8854,otimes:8855,CircleTimes:8855,osol:8856,odot:8857,CircleDot:8857,ocir:8858,ci
    rcledcirc:8858,oast:8859,circledast:8859,odash:8861,circleddash:8861,plusb:8862,boxplus:8862,min
    usb:8863,boxminus:8863,timesb:8864,boxtimes:8864,sdotb:8865,dotsquare:8865,vdash:8866,RightTee:8
    866,dashv:8867,LeftTee:8867,top:8868,DownTee:8868,bottom:8869,bot:8869,perp:8869,UpTee:8869,mode
    ls:8871,vDash:8872,DoubleRightTee:8872,Vdash:8873,Vvdash:8874,VDash:8875,nvdash:8876,nvDash:8877
    ,nVdash:8878,nVDash:8879,prurel:8880,vltri:8882,vartriangleleft:8882,LeftTriangle:8882,vrtri:888
    3,vartriangleright:8883,RightTriangle:8883,ltrie:8884,trianglelefteq:8884,LeftTriangleEqual:8884
    ,rtrie:8885,trianglerighteq:8885,RightTriangleEqual:8885,origof:8886,imof:8887,mumap:8888,multim
    ap:8888,hercon:8889,intcal:8890,intercal:8890,veebar:8891,barvee:8893,angrtvb:8894,lrtri:8895,xw
    edge:8896,Wedge:8896,bigwedge:8896,xvee:8897,Vee:8897,bigvee:8897,xcap:8898,Intersection:8898,bi
  )"

    HEN .= "
  ( LTrim Join
    gcap:8898,xcup:8899,Union:8899,bigcup:8899,diam:8900,diamond:8900,Diamond:8900,sdot:8901,sstarf:
    8902,Star:8902,divonx:8903,divideontimes:8903,bowtie:8904,ltimes:8905,rtimes:8906,lthree:8907,le
    ftthreetimes:8907,rthree:8908,rightthreetimes:8908,bsime:8909,backsimeq:8909,cuvee:8910,curlyvee
    :8910,cuwed:8911,curlywedge:8911,Sub:8912,Subset:8912,Sup:8913,Supset:8913,Cap:8914,Cup:8915,for
    k:8916,pitchfork:8916,epar:8917,ltdot:8918,lessdot:8918,gtdot:8919,gtrdot:8919,Ll:8920,Gg:8921,g
    gg:8921,leg:8922,LessEqualGreater:8922,lesseqgtr:8922,gel:8923,gtreqless:8923,GreaterEqualLess:8
    923,cuepr:8926,curlyeqprec:8926,cuesc:8927,curlyeqsucc:8927,nprcue:8928,NotPrecedesSlantEqual:89
    28,nsccue:8929,NotSucceedsSlantEqual:8929,nsqsube:8930,NotSquareSubsetEqual:8930,nsqsupe:8931,No
    tSquareSupersetEqual:8931,lnsim:8934,gnsim:8935,prnsim:8936,precnsim:8936,scnsim:8937,succnsim:8
    937,nltri:8938,ntriangleleft:8938,NotLeftTriangle:8938,nrtri:8939,ntriangleright:8939,NotRightTr
    iangle:8939,nltrie:8940,ntrianglelefteq:8940,NotLeftTriangleEqual:8940,nrtrie:8941,ntrianglerigh
    teq:8941,NotRightTriangleEqual:8941,vellip:8942,ctdot:8943,utdot:8944,dtdot:8945,disin:8946,isin
    sv:8947,isins:8948,isindot:8949,notinvc:8950,notinvb:8951,isinE:8953,nisd:8954,xnis:8955,nis:895
    6,notnivc:8957,notnivb:8958,barwed:8965,barwedge:8965,Barwed:8966,doublebarwedge:8966,lceil:8968
    ,LeftCeiling:8968,rceil:8969,RightCeiling:8969,lfloor:8970,LeftFloor:8970,rfloor:8971,RightFloor
    :8971,drcrop:8972,dlcrop:8973,urcrop:8974,ulcrop:8975,bnot:8976,profline:8978,profsurf:8979,telr
    ec:8981,target:8982,ulcorn:8988,ulcorner:8988,urcorn:8989,urcorner:8989,dlcorn:8990,llcorner:899
    0,drcorn:8991,lrcorner:8991,frown:8994,sfrown:8994,smile:8995,ssmile:8995,cylcty:9005,profalar:9
    006,topbot:9014,ovbar:9021,solbar:9023,angzarr:9084,lmoust:9136,lmoustache:9136,rmoust:9137,rmou
    stache:9137,tbrk:9140,OverBracket:9140,bbrk:9141,UnderBracket:9141,bbrktbrk:9142,OverParenthesis
    :9180,UnderParenthesis:9181,OverBrace:9182,UnderBrace:9183,trpezium:9186,elinters:9191,blank:925
    1,oS:9416,circledS:9416,boxh:9472,HorizontalLine:9472,boxv:9474,boxdr:9484,boxdl:9488,boxur:9492
    ,boxul:9496,boxvr:9500,boxvl:9508,boxhd:9516,boxhu:9524,boxvh:9532,boxH:9552,boxV:9553,boxdR:955
    4,boxDr:9555,boxDR:9556,boxdL:9557,boxDl:9558,boxDL:9559,boxuR:9560,boxUr:9561,boxUR:9562,boxuL:
    9563,boxUl:9564,boxUL:9565,boxvR:9566,boxVr:9567,boxVR:9568,boxvL:9569,boxVl:9570,boxVL:9571,box
    Hd:9572,boxhD:9573,boxHD:9574,boxHu:9575,boxhU:9576,boxHU:9577,boxvH:9578,boxVh:9579,boxVH:9580,
    uhblk:9600,lhblk:9604,block:9608,blk14:9617,blk12:9618,blk34:9619,squ:9633,square:9633,Square:96
    33,squf:9642,squarf:9642,blacksquare:9642,FilledVerySmallSquare:9642,EmptyVerySmallSquare:9643,r
    ect:9645,marker:9646,fltns:9649,xutri:9651,bigtriangleup:9651,utrif:9652,blacktriangle:9652,utri
    :9653,triangle:9653,rtrif:9656,blacktriangleright:9656,rtri:9657,triangleright:9657,xdtri:9661,b
    igtriangledown:9661,dtrif:9662,blacktriangledown:9662,dtri:9663,triangledown:9663,ltrif:9666,bla
    cktriangleleft:9666,ltri:9667,triangleleft:9667,loz:9674,lozenge:9674,cir:9675,tridot:9708,xcirc
    :9711,bigcirc:9711,ultri:9720,urtri:9721,lltri:9722,EmptySmallSquare:9723,FilledSmallSquare:9724
    ,starf:9733,bigstar:9733,star:9734,phone:9742,female:9792,male:9794,spades:9824,spadesuit:9824,c
    lubs:9827,clubsuit:9827,hearts:9829,heartsuit:9829,diams:9830,diamondsuit:9830,sung:9834,flat:98
    37,natur:9838,natural:9838,sharp:9839,check:10003,checkmark:10003,cross:10007,malt:10016,maltese
    :10016,sext:10038,VerticalSeparator:10072,lbbrk:10098,rbbrk:10099,lobrk:10214,LeftDoubleBracket:
    10214,robrk:10215,RightDoubleBracket:10215,lang:10216,LeftAngleBracket:10216,langle:10216,rang:1
    0217,RightAngleBracket:10217,rangle:10217,Lang:10218,Rang:10219,loang:10220,roang:10221,xlarr:10
    229,longleftarrow:10229,LongLeftArrow:10229,xrarr:10230,longrightarrow:10230,LongRightArrow:1023
    0,xharr:10231,longleftrightarrow:10231,LongLeftRightArrow:10231,xlArr:10232,Longleftarrow:10232,
    DoubleLongLeftArrow:10232,xrArr:10233,Longrightarrow:10233,DoubleLongRightArrow:10233,xhArr:1023
    4,Longleftrightarrow:10234,DoubleLongLeftRightArrow:10234,xmap:10236,longmapsto:10236,dzigrarr:1
    0239,nvlArr:10498,nvrArr:10499,nvHarr:10500,Map:10501,lbarr:10508,rbarr:10509,bkarow:10509,lBarr
    :10510,rBarr:10511,dbkarow:10511,RBarr:10512,drbkarow:10512,DDotrahd:10513,UpArrowBar:10514,Down
    ArrowBar:10515,Rarrtl:10518,latail:10521,ratail:10522,lAtail:10523,rAtail:10524,larrfs:10525,rar
    rfs:10526,larrbfs:10527,rarrbfs:10528,nwarhk:10531,nearhk:10532,searhk:10533,hksearow:10533,swar
    hk:10534,hkswarow:10534,nwnear:10535,nesear:10536,toea:10536,seswar:10537,tosa:10537,swnwar:1053
    8,rarrc:10547,cudarrr:10549,ldca:10550,rdca:10551,cudarrl:10552,larrpl:10553,curarrm:10556,cular
    rp:10557,rarrpl:10565,harrcir:10568,Uarrocir:10569,lurdshar:10570,ldrushar:10571,LeftRightVector
    :10574,RightUpDownVector:10575,DownLeftRightVector:10576,LeftUpDownVector:10577,LeftVectorBar:10
    578,RightVectorBar:10579,RightUpVectorBar:10580,RightDownVectorBar:10581,DownLeftVectorBar:10582
    ,DownRightVectorBar:10583,LeftUpVectorBar:10584,LeftDownVectorBar:10585,LeftTeeVector:10586,Righ
    tTeeVector:10587,RightUpTeeVector:10588,RightDownTeeVector:10589,DownLeftTeeVector:10590,DownRig
    htTeeVector:10591,LeftUpTeeVector:10592,LeftDownTeeVector:10593,lHar:10594,uHar:10595,rHar:10596
    ,dHar:10597,luruhar:10598,ldrdhar:10599,ruluhar:10600,rdldhar:10601,lharul:10602,llhard:10603,rh
    arul:10604,lrhard:10605,udhar:10606,UpEquilibrium:10606,duhar:10607,ReverseUpEquilibrium:10607,R
    oundImplies:10608,erarr:10609,simrarr:10610,larrsim:10611,rarrsim:10612,rarrap:10613,ltlarr:1061
    4,gtrarr:10616,subrarr:10617,suplarr:10619,lfisht:10620,rfisht:10621,ufisht:10622,dfisht:10623,l
    opar:10629,ropar:10630,lbrke:10635,rbrke:10636,lbrkslu:10637,rbrksld:10638,lbrksld:10639,rbrkslu
    :10640,langd:10641,rangd:10642,lparlt:10643,rpargt:10644,gtlPar:10645,ltrPar:10646,vzigzag:10650
    ,vangrt:10652,angrtvbd:10653,ange:10660,range:10661,dwangle:10662,uwangle:10663,angmsdaa:10664,a
    ngmsdab:10665,angmsdac:10666,angmsdad:10667,angmsdae:10668,angmsdaf:10669,angmsdag:10670,angmsda
    h:10671,bemptyv:10672,demptyv:10673,cemptyv:10674,raemptyv:10675,laemptyv:10676,ohbar:10677,omid
    :10678,opar:10679,operp:10681,olcross:10683,odsold:10684,olcir:10686,ofcir:10687,olt:10688,ogt:1
    0689,cirscir:10690,cirE:10691,solb:10692,bsolb:10693,boxbox:10697,trisb:10701,rtriltri:10702,Lef
    tTriangleBar:10703,RightTriangleBar:10704,race:10714,iinfin:10716,infintie:10717,nvinfin:10718,e
    parsl:10723,smeparsl:10724,eqvparsl:10725,lozf:10731,blacklozenge:10731,RuleDelayed:10740,dsol:1
    0742,xodot:10752,bigodot:10752,xoplus:10753,bigoplus:10753,xotime:10754,bigotimes:10754,xuplus:1
    0756,biguplus:10756,xsqcup:10758,bigsqcup:10758,qint:10764,iiiint:10764,fpartint:10765,cirfnint:
    10768,awint:10769,rppolint:10770,scpolint:10771,npolint:10772,pointint:10773,quatint:10774,intla
    rhk:10775,pluscir:10786,plusacir:10787,simplus:10788,plusdu:10789,plussim:10790,plustwo:10791,mc
    omma:10793,minusdu:10794,loplus:10797,roplus:10798,Cross:10799,timesd:10800,timesbar:10801,smash
    p:10803,lotimes:10804,rotimes:10805,otimesas:10806,Otimes:10807,odiv:10808,triplus:10809,triminu
    s:10810,tritime:10811,iprod:10812,intprod:10812,amalg:10815,capdot:10816,ncup:10818,ncap:10819,c
    apand:10820,cupor:10821,cupcap:10822,capcup:10823,cupbrcap:10824,capbrcup:10825,cupcup:10826,cap
    cap:10827,ccups:10828,ccaps:10829,ccupssm:10832,And:10835,Or:10836,andand:10837,oror:10838,orslo
    pe:10839,andslope:10840,andv:10842,orv:10843,andd:10844,ord:10845,wedbar:10847,sdote:10854,simdo
    t:10858,congdot:10861,easter:10862,apacir:10863,apE:10864,eplus:10865,pluse:10866,Esim:10867,Col
    one:10868,Equal:10869,eDDot:10871,ddotseq:10871,equivDD:10872,ltcir:10873,gtcir:10874,ltquest:10
    875,gtquest:10876,les:10877,LessSlantEqual:10877,leqslant:10877,ges:10878,GreaterSlantEqual:1087
    8,geqslant:10878,lesdot:10879,gesdot:10880,lesdoto:10881,gesdoto:10882,lesdotor:10883,gesdotol:1
    0884,lap:10885,lessapprox:10885,gap:10886,gtrapprox:10886,lne:10887,lneq:10887,gne:10888,gneq:10
    888,lnap:10889,lnapprox:10889,gnap:10890,gnapprox:10890,lEg:10891,lesseqqgtr:10891,gEl:10892,gtr
    eqqless:10892,lsime:10893,gsime:10894,lsimg:10895,gsiml:10896,lgE:10897,glE:10898,lesges:10899,g
    esles:10900,els:10901,eqslantless:10901,egs:10902,eqslantgtr:10902,elsdot:10903,egsdot:10904,el:
    10905,eg:10906,siml:10909,simg:10910,simlE:10911,simgE:10912,LessLess:10913,GreaterGreater:10914
    ,glj:10916,gla:10917,ltcc:10918,gtcc:10919,lescc:10920,gescc:10921,smt:10922,lat:10923,smte:1092
    4,late:10925,bumpE:10926,pre:10927,preceq:10927,PrecedesEqual:10927,sce:10928,succeq:10928,Succe
    edsEqual:10928,prE:10931,scE:10932,prnE:10933,precneqq:10933,scnE:10934,succneqq:10934,prap:1093
    5,precapprox:10935,scap:10936,succapprox:10936,prnap:10937,precnapprox:10937,scnap:10938,succnap
    prox:10938,Pr:10939,Sc:10940,subdot:10941,supdot:10942,subplus:10943,supplus:10944,submult:10945
    ,supmult:10946,subedot:10947,supedot:10948,subE:10949,subseteqq:10949,supE:10950,supseteqq:10950
    ,subsim:10951,supsim:10952,subnE:10955,subsetneqq:10955,supnE:10956,supsetneqq:10956,csub:10959,
    csup:10960,csube:10961,csupe:10962,subsup:10963,supsub:10964,subsub:10965,supsup:10966,suphsub:1
    0967,supdsub:10968,forkv:10969,topfork:10970,mlcp:10971,Dashv:10980,DoubleLeftTee:10980,Vdashl:1
    0982,Barv:10983,vBar:10984,vBarv:10985,Vbar:10987,Not:10988,bNot:10989,rnmid:10990,cirmid:10991,
    midcir:10992,topcir:10993,nhpar:10994,parsim:10995,parsl:11005,fflig:64256,filig:64257,fllig:642
    58,ffilig:64259,ffllig:64260,Ascr:119964,Cscr:119966,Dscr:119967,Gscr:119970,Jscr:119973,Kscr:11
    9974,Nscr:119977,Oscr:119978,Pscr:119979,Qscr:119980,Sscr:119982,Tscr:119983,Uscr:119984,Vscr:11
    9985,Wscr:119986,Xscr:119987,Yscr:119988,Zscr:119989,ascr:119990,bscr:119991,cscr:119992,dscr:11
    9993,fscr:119995,hscr:119997,iscr:119998,jscr:119999,kscr:120000,lscr:120001,mscr:120002,nscr:12
    0003,pscr:120005,qscr:120006,rscr:120007,sscr:120008,tscr:120009,uscr:120010,vscr:120011,wscr:12
    0012,xscr:120013,yscr:120014,zscr:120015,Afr:120068,Bfr:120069,Dfr:120071,Efr:120072,Ffr:120073,
    Gfr:120074,Jfr:120077,Kfr:120078,Lfr:120079,Mfr:120080,Nfr:120081,Ofr:120082,Pfr:120083,Qfr:1200
    84,Sfr:120086,Tfr:120087,Ufr:120088,Vfr:120089,Wfr:120090,Xfr:120091,Yfr:120092,afr:120094,bfr:1
    20095,cfr:120096,dfr:120097,efr:120098,ffr:120099,gfr:120100,hfr:120101,ifr:120102,jfr:120103,kf
    r:120104,lfr:120105,mfr:120106,nfr:120107,ofr:120108,pfr:120109,qfr:120110,rfr:120111,sfr:120112
    ,tfr:120113,ufr:120114,vfr:120115,wfr:120116,xfr:120117,yfr:120118,zfr:120119,Aopf:120120,Bopf:1
    20121,Dopf:120123,Eopf:120124,Fopf:120125,Gopf:120126,Iopf:120128,Jopf:120129,Kopf:120130,Lopf:1
    20131,Mopf:120132,Oopf:120134,Sopf:120138,Topf:120139,Uopf:120140,Vopf:120141,Wopf:120142,Xopf:1
    20143,Yopf:120144,aopf:120146,bopf:120147,copf:120148,dopf:120149,eopf:120150,fopf:120151,gopf:1
    20152,hopf:120153,iopf:120154,jopf:120155,kopf:120156,lopf:120157,mopf:120158,nopf:120159,oopf:1
    20160,popf:120161,qopf:120162,ropf:120163,sopf:120164,topf:120165,uopf:120166,vopf:120167,wopf:1
    20168,xopf:120169,yopf:120170,}
  )"
  }

  HTM := !PPT ? HTM : RegExReplace(HTM,"<[^>]+>") ; Remove all text wrapped within "<" and ">"

  While ( P := RegExMatch(HTM, "(?<!&)&[#a-zA-Z0-9]+;", E, P) )  and  (K := Trim(E,"&#;") )
    {
       Asc  := ( SubStr(E,1,3) = "&#x" ? ("0" . K)
            :    SubStr(E,1,2) = "&#"  ? (      K)
            :    RegExMatch(HEN,   "(?<=," . K . ":)[0-9]+(?=,)", Asc) ? Asc
            :    RegExMatch(HEN, "i)(?<=," . K . ":)[0-9]+(?=,)", Asc) ? Asc : 0)

     , HTM  := RegExReplace(HTM, E, Asc ? Chr(Asc) : RUE=0 ? ("&" . E)  : "")
    }

Return HTM
}


