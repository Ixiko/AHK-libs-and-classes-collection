is_url(url) {
  ; Thanks dperini - https://gist.github.com/dperini/729294
  ; Also see for comparisons: https://mathiasbynens.be/demo/url-regex
  ; Modified to be compatible with AutoHotkey. \u0000 -> \x{0000}.
  ; Force the declaration of the protocol because WinHttp requires it.
  return url ~= "^(?i)"
	 . "(?:(?:https?|ftp):\/\/)" ; protocol identifier (FORCE)
	 . "(?:\S+(?::\S*)?@)?" ; user:pass BasicAuth (optional)
	 . "(?:"
		; IP address exclusion
		; private & local networks
		. "(?!(?:10|127)(?:\.\d{1,3}){3})"
		. "(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})"
		. "(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})"
		; IP address dotted notation octets
		; excludes loopback network 0.0.0.0
		; excludes reserved space >= 224.0.0.0
		; excludes network & broadcast addresses
		; (first & last IP address of each class)
		. "(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])"
		. "(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}"
		. "(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))"
	 . "|"
		; host & domain names, may end with dot
		; can be replaced by a shortest alternative
		; (?![-_])(?:[-\\w\\u00a1-\\uffff]{0,63}[^-_]\\.)+
		. "(?:(?:[a-z0-9\x{00a1}-\x{ffff}][a-z0-9\x{00a1}-\x{ffff}_-]{0,62})?[a-z0-9\x{00a1}-\x{ffff}]\.)+"
		; TLD identifier name, may end with dot
		. "(?:[a-z\x{00a1}-\x{ffff}]{2,}\.?)"
	 . ")"
	 . "(?::\d{2,5})?" ; port number (optional)
	 . "(?:[/?#]\S*)?$" ; resource path (optional)
}
