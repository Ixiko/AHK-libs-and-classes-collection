;Functions to be used in Translations

;t := new GoogleTranslate()
;msgbox % t.translate("bird", "hindi")
;msgbox % t.translate("bird", "french")
;return

class GoogleTranslate{

  __New()
  {
    this.o := ComObjCreate( "InternetExplorer.Application" )
    this.iURL := "http://translate.google.com/#auto/"
    this.o.Navigate( this.iURL )
    this.o.visible := 0
    while this.o.Busy
      sleep 100
  }

  Translate(str, lng){
    lngcode := getLangCode(lng)
    this.o.Navigate(this.IURL lngcode)
    while this.o.Busy
      sleep 100
    this.o.document.All.result_box.InnerHTML := ""
    this.o.document.All.source.InnerHTML := str
    this.o.document.All["gt-submit"].Click()
    while this.o.busy or ( this.o.document.All.result_box.innerHTML == "" ) or ( this.o.document.All.result_box.innerHTML == "Translating...")
        sleep 200
    return RegExReplace( this.o.document.All.result_box.InnerText, "U)<(\/|)span.*>", "")
  }
}

;------- getLangCode() ----
;returns Language Code for Google Translate use

getLangCode(Lang=""){

static codes := { Afrikaans: "af", Albanian: "sq", Amharic: "am", Arabic: "ar", Armenian: "hy", Azerbaijani: "az", Basque: "eu", Belarusian: "be", Bengali: "bn"
 , Bihari: "bh", Bork: "xx-bork", Bosnian: "bs", Breton: "br", Bulgarian: "bg", Cambodian: "km", Catalan: "ca", ChineseSimplified: "zh-CN", ChineseTraditional: "zh-TW"
 , Corsican: "co", Croatian: "hr", Czech: "cs", Danish: "da", Dutch: "nl", ElmerFudd: "xx-elmer", English: "en", Esperanto: "eo", Estonian: "et", Faroese: "fo"
 , Filipino: "tl", Finnish: "fi", French: "fr", Frisian: "fy", Galician: "gl", Georgian: "ka", German: "de", Greek: "el", Guarani: "gn", Gujarati: "gu"
 , Hackker: "xx-hacker", Hausa: "ha", Hebrew: "iw", Hindi: "hi", Hungarian: "hu", Icelandic: "is", Indonesian: "id", Interlingua: "ia", Irish: "ga", Italian: "it"
 , Japanese: "ja", Javanese: "jw", Kannada: "kn", Kazakh: "kk", Kinyarwanda: "rw", Kirundi: "rn", Klingon: "xx-klingon", Korean: "ko", Kurdish: "ku", Kyrgyz: "ky"
 , Laothian: "lo", Latin: "la", Latvian: "lv", Lingala: "ln", Lithuanian: "lt", Macedonian: "mk", Malagasy: "mg", Malay: "ms", Malayalam: "ml", Maltese: "mt"
 , Maori: "mi", Marathi: "mr", Moldavian: "mo", Mongolian: "mn", Montenegrin: "sr-ME", Nepali: "ne", Norwegian: "no", NorwegianNynorsk: "nn", Occitan: "oc"
 , Oriya: "or", Oromo: "om", Pashto: "ps", Persian: "fa", Pirate: "xx-pirate", Polish: "pl", PortugeseBR: "pt-BR", PortugesePT: "pt-PT", Punjabi: "pa", Quechua: "qu"
 , Romanian: "ro", Romansh: "rm", Russian: "ru", ScotsGaelic: "gd", Serbian: "sr", SerboCroatian: "sh", Sesotho: "st", Shona: "sn", Sindhi: "sd", Sinhalese: "si"
 , Slovak: "sk", Slovenian: "sl", Somali: "so", Spanish: "es", Sudanese: "su", Swahili: "sw", Swedish: "sv", Tajik: "tg", Tamil: "ta", Tatar: "tt", Telugu: "te"
 , Thai: "th", Tigrinya: "ti", Tonga: "to", Turkish: "tr", Turkmen: "tk", Twi: "tw", Uighur: "ug", Ukrainian: "uk", Urdu: "ur", Uzbek: "uz", Vietnamese: "vi"
 , Welsh: "cy", Xhosa: "xh", Yiddish: "yi", Yoruba: "yo", Zulu: "zu" }

	if Lang=
	{
		for k, v in codes
			r .= "|" k
		return Substr(r,2)
	}
	else return codes[Lang]
}
