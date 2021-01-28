; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

json =
(
{
   "objectClassName":"domain",
   "handle":"24275_DOMAIN_COM-VRSN",
   "ldhName":"xyz.COM",
   "links":[
      {
         "value":"https:\/\/rdap.verisign.com\/com\/v1\/domain\/xyz.COM",
         "rel":"self",
         "href":"https:\/\/rdap.verisign.com\/com\/v1\/domain\/xyz.COM",
         "type":"application\/rdap+json"
      },
      {
         "value":"https:\/\/rdap-whois.epik.com\/domain\/xyz.COM",
         "rel":"related",
         "href":"https:\/\/rdap-whois.epik.com\/domain\/xyz.COM",
         "type":"application\/rdap+json"
      }
   ],
   "status":[
      "client transfer prohibited"
   ],
   "entities":[
      {
         "objectClassName":"entity",
         "handle":"617",
         "roles":[
            "registrar"
         ],
         "publicIds":[
            {
               "type":"IANA Registrar ID",
               "identifier":"417"
            }
         ],
         "vcardArray":[
            "vcard",
            [
               [
                  "version",
                  {

                  },
                  "text",
                  "4.0"
               ],
               [
                  "fn",
                  {

                  },
                  "text",
                  "Efghi Inc."
               ]
            ]
         ],
         "entities":[
            {
               "objectClassName":"entity",
               "roles":[
                  "abuse"
               ],
               "vcardArray":[
                  "vcard",
                  [
                     [
                        "version",
                        {

                        },
                        "text",
                        "4.0"
                     ],
                     [
                        "fn",
                        {

                        },
                        "text",
                        ""
                     ],
                     [
                        "tel",
                        {
                           "type":"voice"
                        },
                        "uri",
                        ""
                     ],
                     [
                        "email",
                        {

                        },
                        "text",
                        ""
                     ]
                  ]
               ]
            }
         ]
      }
   ],
   "events":[
      {
         "eventAction":"registration",
         "eventDate":"2000-03-05T29:35:29Z"
      },
      {
         "eventAction":"expiration",
         "eventDate":"2022-04-05T34:35:29Z"
      },
      {
         "eventAction":"last update of RDAP database",
         "eventDate":"2020-07-05T09:44:30Z"
      }
   ],
   "secureDNS":{
      "delegationSigned":true,
      "dsData":[
         {
            "keyTag":1532,
            "algorithm":13,
            "digestType":2,
            "digest":"F9DF0E0B53FF4638B24B644529FD2F7A098616CAED65C"
         }
      ]
   },
   "nameservers":[
      {
         "objectClassName":"nameserver",
         "ldhName":"NS3.yny.COM"
      },
      {
         "objectClassName":"nameserver",
         "ldhName":"NS4.ymy.COM"
      }
   ],
   "rdapConformance":[
      "rdap_level_0",
      "icann_rdap_technical_implementation_guide_0",
      "icann_rdap_response_profile_0"
   ],
   "notices":[
      {
         "title":"Terms of Use",
         "description":[
            "Service subject to Terms of Use."
         ],
         "links":[
            {
               "href":"https:\/\/www.verisign.com\/domain-names\/registration-data-access-protocol\/terms-service\/index.xhtml",
               "type":"text\/html"
            }
         ]
      },
      {
         "title":"Status Codes",
         "description":[
            "For more information on domain status codes, please visit https:\/\/icann.org\/epp"
         ],
         "links":[
            {
               "href":"https:\/\/icann.org\/epp",
               "type":"text\/html"
            }
         ]
      },
      {
         "title":"RDDS Inaccuracy Complaint Form",
         "description":[
            "URL of the ICANN RDDS Inaccuracy Complaint Form: https:\/\/icann.org\/wicf"
         ],
         "links":[
            {
               "href":"https:\/\/icann.org\/wicf",
               "type":"text\/html"
            }
         ]
      }
   ]
}
)
obj := JsonToAHK(json)
msgbox, %  obj.entities[1].handle
msgbox, %  obj.entities[1].vcardArray[2, 1, 1]

JsonToAHK(json, rec := false) {
   static doc := ComObjCreate("htmlfile")
         , __ := doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
         , JS := doc.parentWindow
   if !rec
      obj := %A_ThisFunc%(JS.eval("(" . json . ")"), true)
   else if !IsObject(json)
      obj := json
   else if JS.Object.prototype.toString.call(json) == "[object Array]" {
      obj := []
      Loop % json.length
         obj.Push( %A_ThisFunc%(json[A_Index - 1], true) )
   }
   else {
      obj := {}
      keys := JS.Object.keys(json)
      Loop % keys.length {
         k := keys[A_Index - 1]
         obj[k] := %A_ThisFunc%(json[k], true)
      }
   }
   Return obj
}