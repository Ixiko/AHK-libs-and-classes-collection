#NoEnv
SetBatchLines, -1
CoordMode, Mouse, Screen

#Include %A_ScriptDir%\..\..\class_Socket.ahk

; type: http://http://127.0.0.1:1337 in your browser

Template =
( Join`r`n
HTTP/1.0 200 OK
Content-Type: text/html

<!DOCTYPE html>
<html>
	<head>
		<title>Go AutoHotkey!</title>
		<style>
			table, td {
				border-collapse: collapse;
				border: 1px solid black;
			}
		</style>
		<script>
			// Send requests sequentially so as to not overload the server
			var update = function(){
				var xhttp = new XMLHttpRequest();
				xhttp.onreadystatechange = function() {
					if (xhttp.readyState == 4 && xhttp.status == 200) {
						document.getElementById("mouse").innerHTML = xhttp.responseText;
						setTimeout(update, 50);
					}
				};
				xhttp.open("GET", "mouse", true);
				xhttp.send();
			}
			setTimeout(update, 100);
		</script>
	</head>
	<body>
		<table>
			{}
			<tr><td>Visitor Count</td><td>{}</td></tr>
			<tr><td>Mouse Position</td><td id="mouse"></td></tr>
		</table>
	</body>
</html>
)

Server := new SocketTCP()
Server.OnAccept := Func("OnAccept")
Server.Bind(["127.0.0.1", 1337])
Server.Listen()

MsgBox, Serving on port 1337`nClose to ExitApp
ExitApp

OnAccept(Server){

	global Template
	static Counter := 0

	Sock := Server.Accept()
	Request := StrSplit(Sock.RecvLine(), " ")

	; You need to empty the Recv buffer before responding to the HTTP request whether you use that data or not
	while Line := Sock.RecvLine()
		Table .= Format("<tr><td>{}</td><td>{}</td></tr>", StrSplit(Line, ": ")*)

	if (Request[1] != "GET")
	{
		Sock.SendText("HTTP/1.0 501 Not Implemented`r`n`r`n")
		Sock.Disconnect()
		return
	}

	if (Request[2] == "/")
		Sock.SendText(Format(Template, Table, ++Counter))
	else if (Request[2] == "/mouse")
	{
		MouseGetPos, x, y
		Sock.SendText("HTTP/1.0 200 OK`r`n`r`n" x "," y)
	}
	else if (Request[2] == "/favicon.ico")
		Sock.SendText("HTTP/1.0 301 Moved Permanently`r`nLocation: https://autohotkey.com/favicon.ico`r`n")
	else
		Sock.SendText("HTTP/1.0 404 Not Found`r`n`r`nHTTP/1.0 404 Not Found")
	Sock.Disconnect()
}
