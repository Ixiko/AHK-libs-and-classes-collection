static SCOPE_BASE := 0
static SCOPE_ONELEVEL := 1
static SCOPE_SUBTREE := 2
static MOD_ADD := 0
static MOD_DELETE := 1
static MOD_REPLACE := 2

static OPT_API_INFO := 0x00
static OPT_API_FEATURE_INFO := 0x15
static OPT_AREC_EXCLUSIVE := 0x98
static OPT_AUTO_RECONNECT := 0x91
static OPT_CACHE_ENABLE := 0x0F
static OPT_CACHE_FN_PTRS := 0x0D
static OPT_CACHE_STRATEGY := 0x0E
static OPT_CLIENT_CERTIFICATE := 0x80
static OPT_DEREF := 0x02
static OPT_DESC := 0x01
static OPT_DNSDOMAIN_NAME := 0x3B
static OPT_ENCRYPT := 0x96
static OPT_ERROR_NUMBER := 0x31
static OPT_ERROR_STRING := 0x32
static OPT_FAST_CONCURRENT_BIND := 0x41
static OPT_GETDSNAME_FLAGS := 0x3D
static OPT_HOST_NAME := 0x30
static OPT_HOST_REACHABLE := 0x3E
static OPT_IO_FN_PTRS := 0x0B
static OPT_PING_KEEP_ALIVE := 0x36
static OPT_PING_LIMIT := 0x38
static OPT_PING_WAIT_TIME := 0x37
static OPT_PROMPT_CREDENTIALS := 0x3F
static OPT_PROTOCOL_VERSION := 0x11
static OPT_VERSION := 0x11
static OPT_REBIND_ARG := 0x07
static OPT_REBIND_FN := 0x06
static OPT_REF_DEREF_CONN_PER_MSG := 0x94
static OPT_REFERAL_CALLBACK := 0x70
static OPT_REFERAL_HOP_LIMIT := 0x10
static OPT_REFERALS := 0x08
static OPT_RESTART := 0x09
static OPT_ROOTDSE_CACHE := 0x9A
static OPT_SASL_METHOD := 0x97
static OPT_SECURITY_CONTEXT := 0x99
static OPT_SEND_TIMEOUT := 0x42
static OPT_SCH_FLAGS := 0x43
static OPT_SOCKET_BIND_ADDRESSES := 0x44
static OPT_SERVER_CERTIFICATE := 0x81
static OPT_SERVER_ERROR := 0x33
static OPT_SERVER_EXT_ERROR := 0x34
static OPT_SIGN := 0x95
static OPT_SIZELIMIT := 0x03
static OPT_SSL := 0x0A
static OPT_SSL_INFO := 0x93
static OPT_SSPI_FLAGS := 0x92
static OPT_TCP_KEEPALIVE := 0x40
static OPT_THREAD_FN_PTRS := 0x05
static OPT_TIMELIMIT := 0x04

static OPT_ON := true
static OPT_OFF := false

static DEREF_NEVER := 0x00
static DEREF_SEARCHING := 0x01
static DEREF_FINDING := 0x02
static DEREF_ALWAYS := 0x03

static VERSION1 := 1
static VERSION2 := 2
static VERSION3 := 3

static CHASE_SUBORDINATE_REFERALS := 0x20
static CHASE_EXTERNAL_REFERALS := 0x40

static AUTH_NEGOTIATE := 0x400

static NO_LIMIT := 0

static LDAP_API_INFO_VERSION := 1

static LDAP_ADMIN_LIMIT_EXCEEDED := 0x0b		; Administration limit on the server was exceeded.
static LDAP_AFFECTS_MULTIPLE_DSAS := 0x47		; Multiple directory service agents are affected.
static LDAP_ALIAS_DEREF_PROBLEM := 0x24			; Cannot dereference the alias.
static LDAP_ALIAS_PROBLEM := 0x21				; The alias is invalid.
static LDAP_ALREADY_EXISTS := 0x44				; The object already exists.
static LDAP_ATTRIBUTE_OR_VALUE_EXISTS := 0x14	; The attribute exists or the value has been assigned.
static LDAP_AUTH_METHOD_NOT_SUPPORTED := 0x07	; The authentication method is not supported. To determine the
												; authentication methods supported by an Active Directory server,
												; retrieve the SupportedSASLMechanisms property of rootDSE. For
												; more information, see Serverless Binding and RootDSE.
static LDAP_AUTH_UNKNOWN := 0x56				; Unknown authentication error occurred.
static LDAP_BUSY := 0x33						; The server is busy.
static LDAP_CLIENT_LOOP := 0x60					; Client loop was detected.
static LDAP_COMPARE_FALSE := 0x05				; For ldap_compare_ext_s and ldap_compare_s, this message is 
												; returned if the function succeeds, and the attribute and known 
												; values do not match.
static LDAP_COMPARE_TRUE := 0x06				; For ldap_compare_ext_s and ldap_compare_s, this message is 
												; returned if the function succeeds, and the attribute and known 
												; values match.
static LDAP_CONFIDENTIALITY_REQUIRED := 0x0d	; Confidentiality is required.
static LDAP_CONNECT_ERROR := 0x5b				; Cannot establish the connection.
static LDAP_CONSTRAINT_VIOLATION := 0x13		; There was a constraint violation.
static LDAP_CONTROL_NOT_FOUND := 0x5d			; The LDAP function (ldap_parse_page_control, 
												; ldap_parse_sort_control, or ldap_parse_vlv_control) did not find 
												; the specified control.
static LDAP_DECODING_ERROR := 0x54				; Decoding error occurred.
static LDAP_ENCODING_ERROR := 0x53				; Encoding error occurred.
static LDAP_FILTER_ERROR := 0x57				; The search filter is bad.
static LDAP_INAPPROPRIATE_AUTH := 0x30			; Authentication is inappropriate.
static LDAP_INAPPROPRIATE_MATCHING := 0x12		; There was an inappropriate matching.
static LDAP_INSUFFICIENT_RIGHTS := 0x32			; The user has insufficient access rights.
static LDAP_INVALID_CREDENTIALS := 0x31			; The supplied credential is invalid.
static LDAP_INVALID_DN_SYNTAX := 0x22			; The distinguished name has an invalid syntax.
static LDAP_INVALID_SYNTAX := 0x15				; The syntax is invalid.
static LDAP_IS_LEAF := 0x23						; The object is a leaf.
static LDAP_LOCAL_ERROR := 0x52					; Local error occurred. If this error occurs during a binding 
												; operation, for more information, see ldap_bind_s.
static LDAP_LOOP_DETECT := 0x36					; The chain of referrals has looped back to a referring server.
static LDAP_MORE_RESULTS_TO_RETURN := 0x5f		; More results are to be returned.
static LDAP_NAMING_VIOLATION := 0x40			; There was a naming violation.
static LDAP_NO_MEMORY := 0x5a					; The system is out of memory.
static LDAP_NO_OBJECT_CLASS_MODS := 0x45		; Cannot modify object class.
static LDAP_NO_RESULTS_RETURNED := 0x5e			; Results are not returned.
static LDAP_NO_SUCH_ATTRIBUTE := 0x10			; Requested attribute does not exist.
static LDAP_NO_SUCH_OBJECT := 0x20				; Object does not exist.
static LDAP_NOT_ALLOWED_ON_NONLEAF := 0x42		; Operation is not allowed on a nonleaf object.
static LDAP_NOT_ALLOWED_ON_RDN := 0x43			; Operation is not allowed on RDN.
static LDAP_NOT_SUPPORTED := 0x5c				; The feature is not supported.
static LDAP_OBJECT_CLASS_VIOLATION := 0x41		; There was an object class violation.
static LDAP_OPERATIONS_ERROR := 0x01			; Operations error occurred.
static LDAP_OTHER := 0x50						; Unknown error occurred.
static LDAP_PARAM_ERROR := 0x59					; A bad parameter was passed to a routine.
static LDAP_PARTIAL_RESULTS := 0x09				; Partial results and referrals received.  Note: Same error code 
												; as LDAP_REFERRAL_V2. The server returns the same result code for 
												; these two similar instances, v2 referral and continuation 
												; references.  For further information, see the protocol reference,
												; Referrals in LDAPv2 and LDAPv3.
static LDAP_PROTOCOL_ERROR := 0x02				; Protocol error occurred.
static LDAP_REFERRAL := 0x0a					; A referral was returned from the server.
static LDAP_REFERRAL_LIMIT_EXCEEDED := 0x61		; The referral limit has been exceeded.
static LDAP_REFERRAL_V2 := 0x09					; A referral was returned from the server.  Note: Same error code 
												; as LDAP_PARTIAL_RESULTS. The server returns the same result code 
												; for these two similar instances, v2 referral and continuation 
												; references.  For further information, see the protocol reference,
												; Referrals in LDAPv2 and LDAPv3.
static LDAP_RESULTS_TOO_LARGE := 0x46			; Results returned are too large.
static LDAP_SERVER_DOWN := 0x51					; Cannot contact the LDAP server.
static LDAP_SIZELIMIT_EXCEEDED := 0x04			; Size limit was exceeded.
static LDAP_STRONG_AUTH_REQUIRED := 0x08		; Strong authentication is required.
static LDAP_SUCCESS := 0x00						; The call completed successfully.
static LDAP_TIMELIMIT_EXCEEDED := 0x03			; Time limit, set by the server side time limit parameter, was exceeded.
static LDAP_TIMEOUT := 0x55						; The search was aborted due to exceeding the limit of the client side timeout parameter.
static LDAP_UNAVAILABLE := 0x34					; The server is unavailable.
static LDAP_UNAVAILABLE_CRIT_EXTENSION := 0x0c	; The control is critical and the server does not support the control.
static LDAP_UNDEFINED_TYPE := 0x11				; Type is not defined.
static LDAP_UNWILLING_TO_PERFORM := 0x35		; The server is not willing to handle directory requests.
static LDAP_USER_CANCELLED := 0x58				; The user has canceled the operation.
static LDAP_VIRTUAL_LIST_VIEW_ERROR := 0x4c		; An error occurred when attempting to perform a requested Virtual
												; List View operation. A detailed error code is returned in the 
												; ldctl_value field of the LDAP_CONTROL_VLVRESPONSE control.
; vim:fdm=manual
