ReplaceHtmlDecodedChars(fnText)
{
	; MsgBox fnText:`n%fnText%
	; StringReplace, fnText, fnText, !   , &#33;     , All
	; StringReplace, fnText, fnText, `"  , &#34;     , All
	; StringReplace, fnText, fnText, `"  , &quot;    , All
	; StringReplace, fnText, fnText, #   , &#35;     , All
	; StringReplace, fnText, fnText, $   , &#36;     , All
	; StringReplace, fnText, fnText, `%  , &#37;     , All
	; StringReplace, fnText, fnText, &   , &#38;     , All
	StringReplace, fnText, fnText, &   , &amp;     , All
	; StringReplace, fnText, fnText, '   , &#39;     , All
	; StringReplace, fnText, fnText, (   , &#40;     , All
	; StringReplace, fnText, fnText, )   , &#41;     , All
	; StringReplace, fnText, fnText, *   , &#42;     , All
	; StringReplace, fnText, fnText, +   , &#43;     , All
	; StringReplace, fnText, fnText, `,  , &#44;     , All
	; StringReplace, fnText, fnText, -   , &#45;     , All
	; StringReplace, fnText, fnText, .   , &#46;     , All
	StringReplace, fnText, fnText, /   , &#47;     , All
	; StringReplace, fnText, fnText, 0   , &#48;     , All
	; StringReplace, fnText, fnText, 1   , &#49;     , All
	; StringReplace, fnText, fnText, 2   , &#50;     , All
	; StringReplace, fnText, fnText, 3   , &#51;     , All
	; StringReplace, fnText, fnText, 4   , &#52;     , All
	; StringReplace, fnText, fnText, 5   , &#53;     , All
	; StringReplace, fnText, fnText, 6   , &#54;     , All
	; StringReplace, fnText, fnText, 7   , &#55;     , All
	; StringReplace, fnText, fnText, 8   , &#56;     , All
	; StringReplace, fnText, fnText, 9   , &#57;     , All
	; StringReplace, fnText, fnText, :   , &#58;     , All
	; StringReplace, fnText, fnText, `;  , &#59;     , All
	; StringReplace, fnText, fnText, <   , &#60;     , All
	StringReplace, fnText, fnText, <   , &lt;      , All
	; StringReplace, fnText, fnText, =   , &#61;     , All
	; StringReplace, fnText, fnText, >   , &#62;     , All
	StringReplace, fnText, fnText, >   , &gt;      , All
	; StringReplace, fnText, fnText, @   , &#64;     , All
	; StringReplace, fnText, fnText, A   , &#65;     , All
	; StringReplace, fnText, fnText, B   , &#66;     , All
	; StringReplace, fnText, fnText, C   , &#67;     , All
	; StringReplace, fnText, fnText, D   , &#68;     , All
	; StringReplace, fnText, fnText, E   , &#69;     , All
	; StringReplace, fnText, fnText, F   , &#70;     , All
	; StringReplace, fnText, fnText, G   , &#71;     , All
	; StringReplace, fnText, fnText, H   , &#72;     , All
	; StringReplace, fnText, fnText, I   , &#73;     , All
	; StringReplace, fnText, fnText, J   , &#74;     , All
	; StringReplace, fnText, fnText, K   , &#75;     , All
	; StringReplace, fnText, fnText, L   , &#76;     , All
	; StringReplace, fnText, fnText, M   , &#77;     , All
	; StringReplace, fnText, fnText, N   , &#78;     , All
	; StringReplace, fnText, fnText, O   , &#79;     , All
	; StringReplace, fnText, fnText, P   , &#80;     , All
	; StringReplace, fnText, fnText, Q   , &#81;     , All
	; StringReplace, fnText, fnText, R   , &#82;     , All
	; StringReplace, fnText, fnText, S   , &#83;     , All
	; StringReplace, fnText, fnText, T   , &#84;     , All
	; StringReplace, fnText, fnText, U   , &#85;     , All
	; StringReplace, fnText, fnText, V   , &#86;     , All
	; StringReplace, fnText, fnText, W   , &#87;     , All
	; StringReplace, fnText, fnText, X   , &#88;     , All
	; StringReplace, fnText, fnText, Y   , &#89;     , All
	; StringReplace, fnText, fnText, Z   , &#90;     , All
	; StringReplace, fnText, fnText, [   , &#91;     , All
	; StringReplace, fnText, fnText, \   , &#92;     , All
	; StringReplace, fnText, fnText, ]   , &#93;     , All
	; StringReplace, fnText, fnText, ^   , &#94;     , All
	; StringReplace, fnText, fnText, _   , &#95;     , All
	; StringReplace, fnText, fnText, ``  , &#96;     , All
	; StringReplace, fnText, fnText, a   , &#97;     , All
	; StringReplace, fnText, fnText, b   , &#98;     , All
	; StringReplace, fnText, fnText, c   , &#99;     , All
	; StringReplace, fnText, fnText, d   , &#100;    , All
	; StringReplace, fnText, fnText, e   , &#101;    , All
	; StringReplace, fnText, fnText, f   , &#102;    , All
	; StringReplace, fnText, fnText, g   , &#103;    , All
	; StringReplace, fnText, fnText, h   , &#104;    , All
	; StringReplace, fnText, fnText, i   , &#105;    , All
	; StringReplace, fnText, fnText, j   , &#106;    , All
	; StringReplace, fnText, fnText, k   , &#107;    , All
	; StringReplace, fnText, fnText, l   , &#108;    , All
	; StringReplace, fnText, fnText, m   , &#109;    , All
	; StringReplace, fnText, fnText, n   , &#110;    , All
	; StringReplace, fnText, fnText, o   , &#111;    , All
	; StringReplace, fnText, fnText, p   , &#112;    , All
	; StringReplace, fnText, fnText, q   , &#113;    , All
	; StringReplace, fnText, fnText, r   , &#114;    , All
	; StringReplace, fnText, fnText, s   , &#115;    , All
	; StringReplace, fnText, fnText, t   , &#116;    , All
	; StringReplace, fnText, fnText, u   , &#117;    , All
	; StringReplace, fnText, fnText, v   , &#118;    , All
	; StringReplace, fnText, fnText, w   , &#119;    , All
	; StringReplace, fnText, fnText, x   , &#120;    , All
	; StringReplace, fnText, fnText, y   , &#121;    , All
	; StringReplace, fnText, fnText, z   , &#122;    , All
	; StringReplace, fnText, fnText, {   , &#123;    , All
	; StringReplace, fnText, fnText, |   , &#124;    , All
	; StringReplace, fnText, fnText, }   , &#125;    , All
	; StringReplace, fnText, fnText, ~   , &#126;    , All
	                                   
	; StringReplace, fnText, fnText,     , &#160;    , All
	; StringReplace, fnText, fnText,     , &nbsp;    , All
	; StringReplace, fnText, fnText, ¡  , &#161;    , All
	StringReplace, fnText, fnText, ¡  , &iexcl;   , All
	; StringReplace, fnText, fnText, ¢  , &#162;    , All
	StringReplace, fnText, fnText, ¢  , &cent;    , All
	; StringReplace, fnText, fnText, £  , &#163;    , All
	StringReplace, fnText, fnText, £  , &pound;   , All
	; StringReplace, fnText, fnText, ¤  , &#164;    , All
	StringReplace, fnText, fnText, ¤  , &curren;  , All
	; StringReplace, fnText, fnText, ¥  , &#165;    , All
	StringReplace, fnText, fnText, ¥  , &yen;     , All
	; StringReplace, fnText, fnText, ¦  , &#166;    , All
	StringReplace, fnText, fnText, ¦  , &brvbar;  , All
	; StringReplace, fnText, fnText, §  , &#167;    , All
	StringReplace, fnText, fnText, §  , &sect;    , All
	; StringReplace, fnText, fnText, ¨  , &#168;    , All
	StringReplace, fnText, fnText, ¨  , &uml;     , All
	; StringReplace, fnText, fnText, ©  , &#169;    , All
	StringReplace, fnText, fnText, ©  , &copy;    , All
	; StringReplace, fnText, fnText, ª  , &#170;    , All
	StringReplace, fnText, fnText, ª  , &ordf;    , All
	; StringReplace, fnText, fnText, «  , &#171;    , All
	StringReplace, fnText, fnText, «  , &laquo;   , All
	; StringReplace, fnText, fnText, ¬  , &#172;    , All
	StringReplace, fnText, fnText, ¬  , &not;     , All
	; StringReplace, fnText, fnText,     , &#173;    , All
	; StringReplace, fnText, fnText,     , &shy;     , All
	; StringReplace, fnText, fnText, ®  , &#174;    , All
	StringReplace, fnText, fnText, ®  , &reg;     , All
	; StringReplace, fnText, fnText, ¯  , &#175;    , All
	StringReplace, fnText, fnText, ¯  , &macr;    , All
	; StringReplace, fnText, fnText, °  , &#176;    , All
	StringReplace, fnText, fnText, °  , &deg;     , All
	; StringReplace, fnText, fnText, ±  , &#177;    , All
	StringReplace, fnText, fnText, ±  , &plusmn;  , All
	; StringReplace, fnText, fnText, ²  , &#178;    , All
	StringReplace, fnText, fnText, ²  , &sup2;    , All
	; StringReplace, fnText, fnText, ³  , &#179;    , All
	StringReplace, fnText, fnText, ³  , &sup3;    , All
	; StringReplace, fnText, fnText, ´  , &#180;    , All
	StringReplace, fnText, fnText, ´  , &acute;   , All
	; StringReplace, fnText, fnText, µ  , &#181;    , All
	StringReplace, fnText, fnText, µ  , &micro;   , All
	; StringReplace, fnText, fnText, ¶  , &#182;    , All
	StringReplace, fnText, fnText, ¶  , &para;    , All
	; StringReplace, fnText, fnText, ·  , &#183;    , All
	StringReplace, fnText, fnText, ·  , &middot;  , All
	; StringReplace, fnText, fnText, ¸  , &#184;    , All
	StringReplace, fnText, fnText, ¸  , &cedil;   , All
	; StringReplace, fnText, fnText, ¹  , &#185;    , All
	StringReplace, fnText, fnText, ¹  , &sup1;    , All
	; StringReplace, fnText, fnText, º  , &#186;    , All
	StringReplace, fnText, fnText, º  , &ordm;    , All
	; StringReplace, fnText, fnText, »  , &#187;    , All
	StringReplace, fnText, fnText, »  , &raquo;   , All
	; StringReplace, fnText, fnText, ¼  , &#188;    , All
	StringReplace, fnText, fnText, ¼  , &frac14;  , All
	; StringReplace, fnText, fnText, ½  , &#189;    , All
	StringReplace, fnText, fnText, ½  , &frac12;  , All
	; StringReplace, fnText, fnText, ¾  , &#190;    , All
	StringReplace, fnText, fnText, ¾  , &frac34;  , All
	; StringReplace, fnText, fnText, ¿  , &#191;    , All
	StringReplace, fnText, fnText, ¿  , &iquest;  , All
	; StringReplace, fnText, fnText, À  , &#192;    , All
	StringReplace, fnText, fnText, À  , &Agrave;  , All
	; StringReplace, fnText, fnText, Á   , &#193;    , All
	StringReplace, fnText, fnText, Á   , &Aacute;  , All
	; StringReplace, fnText, fnText, Â  , &#194;    , All
	StringReplace, fnText, fnText, Â  , &Acirc;   , All
	; StringReplace, fnText, fnText, Ã  , &#195;    , All
	StringReplace, fnText, fnText, Ã  , &Atilde;  , All
	; StringReplace, fnText, fnText, Ä  , &#196;    , All
	StringReplace, fnText, fnText, Ä  , &Auml;    , All
	; StringReplace, fnText, fnText, Å  , &#197;    , All
	StringReplace, fnText, fnText, Å  , &Aring;   , All
	; StringReplace, fnText, fnText, Æ  , &#198;    , All
	StringReplace, fnText, fnText, Æ  , &AElig;   , All
	; StringReplace, fnText, fnText, Ç  , &#199;    , All
	StringReplace, fnText, fnText, Ç  , &Ccedil;  , All
	; StringReplace, fnText, fnText, È  , &#200;    , All
	StringReplace, fnText, fnText, È  , &Egrave;  , All
	; StringReplace, fnText, fnText, É  , &#201;    , All
	StringReplace, fnText, fnText, É  , &Eacute;  , All
	; StringReplace, fnText, fnText, Ê  , &#202;    , All
	StringReplace, fnText, fnText, Ê  , &Ecirc;   , All
	; StringReplace, fnText, fnText, Ë  , &#203;    , All
	StringReplace, fnText, fnText, Ë  , &Euml;    , All
	; StringReplace, fnText, fnText, Ì  , &#204;    , All
	StringReplace, fnText, fnText, Ì  , &Igrave;  , All
	; StringReplace, fnText, fnText, Í   , &#205;    , All
	StringReplace, fnText, fnText, Í   , &Iacute;  , All
	; StringReplace, fnText, fnText, Î  , &#206;    , All
	StringReplace, fnText, fnText, Î  , &Icirc;   , All
	; StringReplace, fnText, fnText, Ï   , &#207;    , All
	StringReplace, fnText, fnText, Ï   , &Iuml;    , All
	; StringReplace, fnText, fnText, Ð   , &#208;    , All
	StringReplace, fnText, fnText, Ð   , &ETH;     , All
	; StringReplace, fnText, fnText, Ñ  , &#209;    , All
	StringReplace, fnText, fnText, Ñ  , &Ntilde;  , All
	; StringReplace, fnText, fnText, Ò  , &#210;    , All
	StringReplace, fnText, fnText, Ò  , &Ograve;  , All
	; StringReplace, fnText, fnText, Ó  , &#211;    , All
	StringReplace, fnText, fnText, Ó  , &Oacute;  , All
	; StringReplace, fnText, fnText, Ô  , &#212;    , All
	StringReplace, fnText, fnText, Ô  , &Ocirc;   , All
	; StringReplace, fnText, fnText, Õ  , &#213;    , All
	StringReplace, fnText, fnText, Õ  , &Otilde;  , All
	; StringReplace, fnText, fnText, Ö  , &#214;    , All
	StringReplace, fnText, fnText, Ö  , &Ouml;    , All
	; StringReplace, fnText, fnText, ×  , &#215;    , All
	StringReplace, fnText, fnText, ×  , &times;   , All
	; StringReplace, fnText, fnText, Ø  , &#216;    , All
	StringReplace, fnText, fnText, Ø  , &Oslash;  , All
	; StringReplace, fnText, fnText, Ù  , &#217;    , All
	StringReplace, fnText, fnText, Ù  , &Ugrave;  , All
	; StringReplace, fnText, fnText, Ú  , &#218;    , All
	StringReplace, fnText, fnText, Ú  , &Uacute;  , All
	; StringReplace, fnText, fnText, Û  , &#219;    , All
	StringReplace, fnText, fnText, Û  , &Ucirc;   , All
	; StringReplace, fnText, fnText, Ü  , &#220;    , All
	StringReplace, fnText, fnText, Ü  , &Uuml;    , All
	; StringReplace, fnText, fnText, Ý   , &#221;    , All
	StringReplace, fnText, fnText, Ý   , &Yacute;  , All
	; StringReplace, fnText, fnText, Þ  , &#222;    , All
	StringReplace, fnText, fnText, Þ  , &THORN;   , All
	; StringReplace, fnText, fnText, ß  , &#223;    , All
	StringReplace, fnText, fnText, ß  , &szlig;   , All
	; StringReplace, fnText, fnText, à  , &#224;    , All
	StringReplace, fnText, fnText, à  , &agrave;  , All
	; StringReplace, fnText, fnText, á  , &#225;    , All
	StringReplace, fnText, fnText, á  , &aacute;  , All
	; StringReplace, fnText, fnText, â  , &#226;    , All
	StringReplace, fnText, fnText, â  , &acirc;   , All
	; StringReplace, fnText, fnText, ã  , &#227;    , All
	StringReplace, fnText, fnText, ã  , &atilde;  , All
	; StringReplace, fnText, fnText, ä  , &#228;    , All
	StringReplace, fnText, fnText, ä  , &auml;    , All
	; StringReplace, fnText, fnText, å  , &#229;    , All
	StringReplace, fnText, fnText, å  , &aring;   , All
	; StringReplace, fnText, fnText, æ  , &#230;    , All
	StringReplace, fnText, fnText, æ  , &aelig;   , All
	; StringReplace, fnText, fnText, ç  , &#231;    , All
	StringReplace, fnText, fnText, ç  , &ccedil;  , All
	; StringReplace, fnText, fnText, è  , &#232;    , All
	StringReplace, fnText, fnText, è  , &egrave;  , All
	; StringReplace, fnText, fnText, é  , &#233;    , All
	StringReplace, fnText, fnText, é  , &eacute;  , All
	; StringReplace, fnText, fnText, ê  , &#234;    , All
	StringReplace, fnText, fnText, ê  , &ecirc;   , All
	; StringReplace, fnText, fnText, ë  , &#235;    , All
	StringReplace, fnText, fnText, ë  , &euml;    , All
	; StringReplace, fnText, fnText, ì  , &#236;    , All
	StringReplace, fnText, fnText, ì  , &igrave;  , All
	; StringReplace, fnText, fnText, í   , &#237;    , All
	StringReplace, fnText, fnText, í   , &iacute;  , All
	; StringReplace, fnText, fnText, î  , &#238;    , All
	StringReplace, fnText, fnText, î  , &icirc;   , All
	; StringReplace, fnText, fnText, ï  , &#239;    , All
	StringReplace, fnText, fnText, ï  , &iuml;    , All
	; StringReplace, fnText, fnText, ð  , &#240;    , All
	StringReplace, fnText, fnText, ð  , &eth;     , All
	; StringReplace, fnText, fnText, ñ  , &#241;    , All
	StringReplace, fnText, fnText, ñ  , &ntilde;  , All
	; StringReplace, fnText, fnText, ò  , &#242;    , All
	StringReplace, fnText, fnText, ò  , &ograve;  , All
	; StringReplace, fnText, fnText, ó  , &#243;    , All
	StringReplace, fnText, fnText, ó  , &oacute;  , All
	; StringReplace, fnText, fnText, ô  , &#244;    , All
	StringReplace, fnText, fnText, ô  , &ocirc;   , All
	; StringReplace, fnText, fnText, õ  , &#245;    , All
	StringReplace, fnText, fnText, õ  , &otilde;  , All
	; StringReplace, fnText, fnText, ö  , &#246;    , All
	StringReplace, fnText, fnText, ö  , &ouml;    , All
	; StringReplace, fnText, fnText, ÷  , &#247;    , All
	StringReplace, fnText, fnText, ÷  , &divide;  , All
	; StringReplace, fnText, fnText, ø  , &#248;    , All
	StringReplace, fnText, fnText, ø  , &oslash;  , All
	; StringReplace, fnText, fnText, ù  , &#249;    , All
	StringReplace, fnText, fnText, ù  , &Ugrave;  , All
	; StringReplace, fnText, fnText, ú  , &#250;    , All
	StringReplace, fnText, fnText, ú  , &Uacute;  , All
	; StringReplace, fnText, fnText, û  , &#251;    , All
	StringReplace, fnText, fnText, û  , &Ucirc;   , All
	; StringReplace, fnText, fnText, ü  , &#252;    , All
	StringReplace, fnText, fnText, ü  , &Uuml;    , All
	; StringReplace, fnText, fnText, ý  , &#253;    , All
	StringReplace, fnText, fnText, ý  , &yacute;  , All
	; StringReplace, fnText, fnText, þ  , &#254;    , All
	StringReplace, fnText, fnText, þ  , &thorn;   , All
	; StringReplace, fnText, fnText, ÿ  , &#255;    , All
	StringReplace, fnText, fnText, ÿ  , &yuml;    , All
	; StringReplace, fnText, fnText, OE  , &#338;    , All
	StringReplace, fnText, fnText, OE  , &OElig;   , All
	; StringReplace, fnText, fnText, oe  , &#339;    , All
	StringReplace, fnText, fnText, oe  , &oelig;   , All
	; StringReplace, fnText, fnText, Š  , &#352;    , All
	StringReplace, fnText, fnText, Š  , &Scaron;  , All
	; StringReplace, fnText, fnText, š  , &#353;    , All
	StringReplace, fnText, fnText, š  , &scaron;  , All
	; StringReplace, fnText, fnText, Ÿ  , &#376;    , All
	StringReplace, fnText, fnText, Ÿ  , &Yuml;    , All
	; StringReplace, fnText, fnText, ƒ  , &#402;    , All
	StringReplace, fnText, fnText, ƒ  , &fnof;    , All
	; StringReplace, fnText, fnText, ˆ  , &#710;    , All
	StringReplace, fnText, fnText, ˆ  , &circ;    , All
	; StringReplace, fnText, fnText, ˜  , &#732;    , All
	StringReplace, fnText, fnText, ˜  , &tilde;   , All
	; StringReplace, fnText, fnText, G   , &#915;    , All
	; StringReplace, fnText, fnText, G   , &Gamma;   , All
	; StringReplace, fnText, fnText, T   , &#920;    , All
	; StringReplace, fnText, fnText, T   , &Theta;   , All
	; StringReplace, fnText, fnText, S   , &#931;    , All
	; StringReplace, fnText, fnText, S   , &Sigma;   , All
	; StringReplace, fnText, fnText, F   , &#934;    , All
	; StringReplace, fnText, fnText, F   , &Phi;     , All
	; StringReplace, fnText, fnText, O   , &#937;    , All
	; StringReplace, fnText, fnText, O   , &Omega;   , All
	; StringReplace, fnText, fnText, a   , &#945;    , All
	; StringReplace, fnText, fnText, a   , &alpha;   , All
	; StringReplace, fnText, fnText, ß  , &#946;    , All
	StringReplace, fnText, fnText, ß  , &beta;    , All
	; StringReplace, fnText, fnText, d   , &#948;    , All
	; StringReplace, fnText, fnText, d   , &delta;   , All
	; StringReplace, fnText, fnText, e   , &#949;    , All
	; StringReplace, fnText, fnText, e   , &epsilon  , All
	; StringReplace, fnText, fnText, µ  , &#956;    , All
	StringReplace, fnText, fnText, µ  , &mu;      , All
	; StringReplace, fnText, fnText, p   , &#960;    , All
	; StringReplace, fnText, fnText, p   , &pi;      , All
	; StringReplace, fnText, fnText, s   , &#963;    , All
	; StringReplace, fnText, fnText, s   , &sigma;   , All
	; StringReplace, fnText, fnText, t   , &#964;    , All
	; StringReplace, fnText, fnText, t   , &tau;     , All
	; StringReplace, fnText, fnText, f   , &#966;    , All
	; StringReplace, fnText, fnText, f   , &phi;     , All
	; StringReplace, fnText, fnText,     , &#8194;   , All
	; StringReplace, fnText, fnText,     , &ensp;    , All
	; StringReplace, fnText, fnText,     , &#8195;   , All
	; StringReplace, fnText, fnText,     , &emsp;    , All
	; StringReplace, fnText, fnText,     , &#8201;   , All
	; StringReplace, fnText, fnText,     , &thinsp;  , All
	; StringReplace, fnText, fnText,     , &#8204;   , All
	; StringReplace, fnText, fnText,     , &zwnj;    , All
	; StringReplace, fnText, fnText,     , &#8205;   , All
	; StringReplace, fnText, fnText,     , &zwj;     , All
	; StringReplace, fnText, fnText,     , &#8206;   , All
	; StringReplace, fnText, fnText,     , &lrm;     , All
	; StringReplace, fnText, fnText,     , &#8207;   , All
	; StringReplace, fnText, fnText,     , &rlm;     , All
	; StringReplace, fnText, fnText, – , &#8211;   , All
	StringReplace, fnText, fnText, – , &ndash;   , All
	; StringReplace, fnText, fnText, — , &#8212;   , All
	StringReplace, fnText, fnText, — , &mdash;   , All
	; StringReplace, fnText, fnText, ‘ , &#8216;   , All
	StringReplace, fnText, fnText, ‘ , &lsquo;   , All
	; StringReplace, fnText, fnText, ’ , &#8217;   , All
	StringReplace, fnText, fnText, ’ , &rsquo;   , All
	; StringReplace, fnText, fnText, ‚ , &#8218;   , All
	StringReplace, fnText, fnText, ‚ , &sbquo;   , All
	; StringReplace, fnText, fnText, “ , &#8220;   , All
	StringReplace, fnText, fnText, “ , &ldquo;   , All
	; StringReplace, fnText, fnText, ”  , &#8221;   , All
	StringReplace, fnText, fnText, ”  , &rdquo;   , All
	; StringReplace, fnText, fnText, „ , &#8222;   , All
	StringReplace, fnText, fnText, „ , &bdquo;   , All
	; StringReplace, fnText, fnText, † , &#8224;   , All
	StringReplace, fnText, fnText, † , &dagger;  , All
	; StringReplace, fnText, fnText, ‡ , &#8225;   , All
	StringReplace, fnText, fnText, ‡ , &Dagger;  , All
	; StringReplace, fnText, fnText, • , &#8226;   , All
	StringReplace, fnText, fnText, • , &bull;    , All
	; StringReplace, fnText, fnText, … , &#8230;   , All
	StringReplace, fnText, fnText, … , &hellip;  , All
	; StringReplace, fnText, fnText, ‰ , &#8240;   , All
	StringReplace, fnText, fnText, ‰ , &permil;  , All
	; StringReplace, fnText, fnText, '   , &#8242;   , All
	; StringReplace, fnText, fnText, '   , &prime;   , All
	; StringReplace, fnText, fnText, ‹ , &#8249;   , All
	StringReplace, fnText, fnText, ‹ , &lsaquo;  , All
	; StringReplace, fnText, fnText, › , &#8250;   , All
	StringReplace, fnText, fnText, › , &rsaquo;  , All
	; StringReplace, fnText, fnText, /   , &#8260;   , All
	; StringReplace, fnText, fnText, /   , &frasl;   , All
	; StringReplace, fnText, fnText, € , &#8364;   , All
	StringReplace, fnText, fnText, € , &euro;    , All
	; StringReplace, fnText, fnText, I   , &#8465;   , All
	; StringReplace, fnText, fnText, I   , &image;   , All
	; StringReplace, fnText, fnText, P   , &#8472;   , All
	; StringReplace, fnText, fnText, P   , &weierp;  , All
	; StringReplace, fnText, fnText, R   , &#8476;   , All
	; StringReplace, fnText, fnText, R   , &real;    , All
	; StringReplace, fnText, fnText, ™ , &#8482;   , All
	StringReplace, fnText, fnText, ™ , &trade;   , All
	; StringReplace, fnText, fnText, Ø  , &#8709;   , All
	StringReplace, fnText, fnText, Ø  , &empty;   , All
	; StringReplace, fnText, fnText, S   , &#8721;   , All
	; StringReplace, fnText, fnText, S   , &sum;     , All
	; StringReplace, fnText, fnText, -   , &#8722;   , All
	; StringReplace, fnText, fnText, -   , &minus;   , All
	; StringReplace, fnText, fnText, *   , &#8727;   , All
	; StringReplace, fnText, fnText, *   , &lowast;  , All
	; StringReplace, fnText, fnText, v   , &#8730;   , All
	; StringReplace, fnText, fnText, v   , &radic;   , All
	; StringReplace, fnText, fnText, 8   , &#8734;   , All
	; StringReplace, fnText, fnText, 8   , &infin;   , All
	; StringReplace, fnText, fnText, n   , &#8745;   , All
	; StringReplace, fnText, fnText, n   , &cap;     , All
	; StringReplace, fnText, fnText, ~   , &#8764;   , All
	StringReplace, fnText, fnText, ~   , &sim;     , All
	; StringReplace, fnText, fnText, ˜  , &#8776;   , All
	StringReplace, fnText, fnText, ˜  , &asymp;   , All
	; StringReplace, fnText, fnText, =   , &#8801;   , All
	; StringReplace, fnText, fnText, =   , &equiv;   , All
	; StringReplace, fnText, fnText, =   , &#8804;   , All
	; StringReplace, fnText, fnText, =   , &le;      , All
	; StringReplace, fnText, fnText, =   , &#8805;   , All
	; StringReplace, fnText, fnText, =   , &ge;      , All
	; StringReplace, fnText, fnText, ·  , &#8901;   , All
	StringReplace, fnText, fnText, ·  , &sdot;    , All
	; StringReplace, fnText, fnText, <   , &#9001;   , All
	; StringReplace, fnText, fnText, <   , &lang;    , All
	; StringReplace, fnText, fnText, >   , &#9002;   , All
	; StringReplace, fnText, fnText, >   , &rang;    , All
	
	; MsgBox fnText:`n%fnText%
	Return fnText
}
