/**
 * Allows us to requests data from the web.
 * You can use either WinHttpRequests or create a com instance of a browser
 * 
 *
 * @Parameters
 *    @url      - [string] expects URL
 *
 * @Remarks
 *    for better output control JSON.ahk has been included.
 *    This is by no means necessary, but it's easier dealing with 
 *    JSON objects, than working with the string responses.
*/
#Include %A_LineFile%\..\JSON.ahk

Class NetRequest {
    request_header := {"GET":"application/json", "POST":"application/x-www-form-urlencoded;charset=utf-8"}
    method := {"GET":"GET", "POST":"POST"}
    status := "instantiated"

    __New() {
    }

    /**
     * sets the host and endpoint for the api you want to use
     *
     * @Parameters
     *    @host        - [string] expects valid URL
     *    @endpoint    - [string] valid endpoint for API you want to hit
     *                            /rest/asset/v1/programs.json
     *
     * @Return
     *    Return
    */
    apiSetup(host, endpoint) {
        this.host := host
        this.endpoint := endpoint
    }

    /**
     * used for requesting data from APIs
     * returns the response text from the http request
     * 
     *
     * @Parameters
     *    @id           - [string] id of object you want to request from api
     *    @parms        - [string] parameters for api in this format
     *                             "name=Alf", "birthplace="space" etc
     *
     * @Return
     *    JSON Object
    */
    apiRequest(method:="GET", body:="", parms*) {
        start_query := 1
        for each, parm in parms {
            if (!Instr(parm, "=")) {
                parameters := "/" . parm
            } else {
                parameters .= (start_query == 1 ? "?" : "&") . parm
                start_query := 
            }
        }

        request := this.createRequestObj(this.host . "/" . this.endpoint . parameters, method, body)
        if (!request) {
            return false
        }
        if (!Isobject(request)) {
            return request
        }
        json_response := JSON.Load(request.ResponseText)
        return json_response
    }

    /**
     * checks status of URL by returning status code
     *
     * @Parameters
     *    @URL    - [string] expects valid URL
     *
     * @Return
     *    string
    */
    checkStatus(URL){
        request := this.createRequestObj(URL)
        return request.status
    }

    /**
     * opens Internet explorer and navigates to URL
     * can be visible or hidden
     * returns com Object to interact with
     *
     * @Parameters
     *    @URL           - [string] expects valid URL
     *    @visibility    - [boolean] expects true of false
     *
     * @Return
     *    object
    */
    webBrowser(URL, visibility:=false){
        wb := ComObjCreate("InternetExplorer.Application")
        wb.Visible := visibility
        wb.Navigate(URL)
        while wb.Busy || wb.ReadyState != 4 {
            Sleep, 100
        }
        return wb
    }

    /**
     * creates a com object used for http requests
     * can be used with both "GET" and "POST"
     *
     * @Parameters
     *    @endpoint     - [string] expects valid URL or endpoint
     *    @method       - [string] expects "GET" or "POST"
     *    @body         - [string] values we want to pass via POST (optional for GET)
     *    @timouts      - [object] expects timeouts passed in a key:value pairs exactly like below
     *                    {"resolve_timeout": 0, "connect_timeout": 30000, "send_timeout": 30000, "receive_timeout": 60000}
     *
     * @Return
     *    object
    */
    createRequestObj(endpoint:="", method:="GET", body:="", timeouts:=""){

        request_obj := ComObjCreate("WinHttp.WinHttpRequest.5.1")

        if (!IsObject(request_obj)) {
            msgbox, 4112,"Fatal Error","Unable to create HTTP object"
            return "Fatal Error. Unable to create HTTP object"
        }

        this.defineTimeout(request_obj, timeouts)

        try {
            request_obj.Open(method, endpoint)
        } catch error {
            MsgBox, % error.message
            FormatTime, current_time, %A_Now%, yyyy.MM.dd hh:mm:ss
            fileappend % current_time ": " error.Message ", line:" error.line "`n`nEndpoint: " . endpoint, % A_ScriptDir "\netrequest_error.txt"
            return error.Message
        }
        
        request_obj.SetRequestHeader("Content-Type", this.request_header[method])
        
        if (body == "") {
            request_obj.Send()
        } else {
            request_obj.Send(body)
        }

        try {
            request_obj.WaitForResponse()
        } catch error {
            MsgBox, % error.message
            FormatTime, current_time, %A_Now%, yyyy.MM.dd hh:mm:ss
            fileappend % current_time ": " error.Message ", line:" error.line "`n`nEndpoint: " . endpoint, % A_ScriptDir "\netrequest_error.txt"
            return error.Message
        }

        if (request_obj == "") {
            msgbox, 4112,"Fatal Error","Couldn't receive response."
            return "Fatal Error. Couldn't receive response."
        }
        return request_obj
    }

    /**
     * defines the default timeouts or allows them to be adjusted
     * timeouts are always defined in milliseconds
     *
     * @Parameters
     *    @com_obj              - [object] expects valid com_object 
     *                                     for http requests
     *    @resolve_timeout      - [int] expects time in ms (default 0ms)
     *    @connect_timeout      - [int] expects time in ms (default 30s)
     *    @send_timeout         - [int] expects time in ms (default 30s)
     *    @receive_timeout      - [int] expects time in ms (default 60s)
     *
     * @Return
     *    no return value
    */
    defineTimeout(ByRef com_obj, timeouts){
        if (IsObject(timeouts)) {
            resolve_timeout := timeouts.resolve_timeout
            connect_timeout := timeouts.connect_timeout
            send_timeout := timeouts.send_timeout
            receive_timeout := timeouts.receive_timeout
        } else {
            resolve_timeout := 0
            connect_timeout := 30000
            send_timeout := 30000
            receive_timeout := 600000
        }
        com_obj.SetTimeouts(resolve_timeout, connect_timeout, send_timeout, receive_timeout)
    }

    /**
     * searches the DOM for tags with passed attributes
     *
     * @Parameters
     *    @browser_obj     - [object] expects browser_obj + .document
     *    @item            - [string] expects valid attribute tag enclosed by "[]"
     *
     * @Return
     *    object
    */
    searchForMatches(browser_obj, item){
        matching_elements := []
        all_elements := browser_obj.querySelectorAll(item)
        Loop, % all_elements.length {
            if (all_elements[A_Index-1]) {
                matching_elements.push(all_elements[A_Index-1])
            }
        }
        return matching_elements
    }
}
