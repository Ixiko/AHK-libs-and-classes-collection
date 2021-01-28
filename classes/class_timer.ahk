; timer := timer.new("Function Name", interval, priority)
class timer {
    error[] {
        get {
            return this._error
        }
    }
    isRunning[]{
        get {
            return this._isRunning
        }
    }
    count[]{
        get {
            return this._count
        }
    }
    name[]{
        get{
            return this._func
        }
    }
    func[]{
        get {
            return this._func
        }
    }

    interval[]{
        get {
            return this._interval
        } 
        set {
            if (this._isInteger(value)){
                this._interval := value
                if (this._isRunning)
                    this.Restart()
                this._error := false
            } else{
                this._Exception("'" value "' is not an integer`nInterval is unchanged")
            }
        }
    }
    priority[]{
        get {
            return this._priority
        }
        set {
            if (this._isInteger(value)){
                this._priority := value
                if (this._isRunning)
                    this.Restart()
                this._error := false
            } else{
                this._Exception("'" value "' is not an integer`nPriority is unchanged")
            }
        }
    }
    __New(func,i:=250,p:=0) {

        this._count := 0
        this._timer := ObjBindMethod(this, "_Tick")
        this._isRunning := false
        this._error := false

        if (this._isInteger(i))
            this._interval:=i
        else 
            this._Exception("'" value "' is not an integer`nInterval is unchanged")

        if (this._isInteger(p))
            this._priority:=p
        else 
            this._Exception("'" value "' is not an integer`nPriority is unchanged")
        if (isfunc(func)){
            this._func:=func
            this._name:=func
        }
        else {
            this._error := true
            this._func := null
            this._Exception("That function doesn't exist`nSpecifically: " func)
        }

    }

    Start() {
        if (!this._error){
            SetTimer this._timer, this._interval, this._priority
            this._isRunning := true
        }
    }
    Stop() {
        this._count := 0
        SetTimer this._timer, 0
        this._isRunning:=false
    }
    Restart(){
    	this.Stop()
        this.Start()
    }
    _Exception(m){
        this.Stop()
        this._error := true
        Throw(m)
    }
    _isInteger(i){
        if (i is "Integer")
            return True
        else 
            return False
    }
    _Tick() {
        if (this._isRunning && this.func != null){
    	   this._count++
            f:= this._func
            try {
                %f%()
            }
        }
    }
}
