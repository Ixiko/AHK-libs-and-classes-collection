#Include <GActiveXCtl>

class WebBrowserCtl extends GActiveXCtl
{
	__New(gui, options:="", init:="about:<!DOCTYPE html><html><head><meta http-equiv='X-UA-Compatible' content='IE=Edge'/></head></html>")
	{
		base.__New(gui, options, init)
		while (this.Ptr.ReadyState != 4)
			Sleep, 10
	}

	Document {
		get {
			return this.Ptr.Document
		}
	}

	Window {
		get {
			return this.Document.parentWindow
		}
	}
}