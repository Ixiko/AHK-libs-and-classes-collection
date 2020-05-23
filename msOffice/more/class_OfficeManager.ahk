class OfficeManager{
	Path := ""
	p := ""
	__New(){
		this.p := new Properties()
		this.Path := this.p.getProperty("officepath")
	}
}