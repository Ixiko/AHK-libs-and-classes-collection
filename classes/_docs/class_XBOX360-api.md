#Xbox360Lib API

```
Xbox360LibXInput
    Methods:
        + GetState ( index : UInt,  out stateOutAddress : UPtr ) : Int
        + SetState ( index : Uint, inout xvibration : Xbox360LibXInputVibration ) : Int
        + GetKeystroke ( index : UInt,  out keystoreOutAddress : UPtr ) : Int
        + GetBatteryInformation ( index : UInt, type: UChar, out keystoreOutAddress : UPtr ) : Int
        + CallPowerOffController ( index : UInt ) : Int


Xbox360LibXInputVibration
    Attributes:
        + leftMotorSpeed : Int (0 - 65535)
        + rightMotorSpeed : Int (0 - 65535)
        + raw : Short
        + address : Int
    Methods:
        + ParseToBinaryFormat


Xbox360LibController
    Attributes:
        + GUIDE : Bool readOnly
        + BACK : Bool readOnly
        + START : Bool readOnly
        + LEFT : Bool  readOnly
        + RIGHT : Bool readOnly
        + UP : Bool readOnly
        + DOWN : Bool readOnly
        + LEFT : Bool readOnly
        + RIGHT : Bool readOnly
        + A : Bool readOnly
        + B : Bool readOnly
        + X : Bool readOnly
        + Y : Bool readOnly
        + LB : Bool readOnly
        + RB : Bool readOnly
        + LS : Bool readOnly
        + RS : Bool readOnly
        + LT : Int (0 - 255) readOnly
        + RT : Int (0 - 255) readOnly
        + LSX : Int (-32768 - 32767) readOnly
        + RSX : Int (-32768 - 32767) readOnly
        + BV : Array<LeftMotorSpeed : Int (0 - 65535), RightMotorSpeed: (0 - 65535)>
        + LV : Int (0 - 65535)
        + RV : Int (0 - 65535)
    Methods:
        + __New ( index : Int, xinput : Xbox360LibXInput)
        + Update ()
        + IsConnected : Bool

        
Xbox360LibControllerManager
    Methods:
        InitializeController ( index : Int ) : Xbox360LibController
        PowerOffController ( index : Int )

Xbox360Lib.Enum.Buttons
    Attributes
        + GUIDE : Int
        + BACK : Int
        + START : Int
        + LEFT : Int
        + RIGHT : Int
        + UP : Int
        + DOWN : Int
        + LEFT : Int
        + RIGHT : Int
        + A : Int
        + B : Int
        + X : Int
        + Y : Int
        + LB : Int
        + RB : Int
        + LS : Int
        + RS : Int
        + LT : Int
        + RT : Int
        + LSX : Int
        + RSX : Int

Xbox360Lib.Enum.Buttons
    Attributes
        + Xbox360Lib.Enum.Buttons.UP : Bitmask
        + Xbox360Lib.Enum.Buttons.DOWN : Bitmask
        + Xbox360Lib.Enum.Buttons.LEFT : Bitmask
        + Xbox360Lib.Enum.Buttons.RIGHT : Bitmask
        + Xbox360Lib.Enum.Buttons.START : Bitmask
        + Xbox360Lib.Enum.Buttons.BACK : Bitmask
        + Xbox360Lib.Enum.Buttons.LS : Bitmask
        + Xbox360Lib.Enum.Buttons.RS : Bitmask
        + Xbox360Lib.Enum.Buttons.LB : Bitmask
        + Xbox360Lib.Enum.Buttons.RB : Bitmask
        + Xbox360Lib.Enum.Buttons.GUIDE : Bitmask
        + Xbox360Lib.Enum.Buttons.A : Bitmask
        + Xbox360Lib.Enum.Buttons.B : Bitmask
        + Xbox360Lib.Enum.Buttons.X : Bitmask
        + Xbox360Lib.Enum.Buttons.Y : Bitmask
        
Xbox360Lib.Enum.XInputStateGamepad
    Attributes
        + Xbox360Lib.Enum.Buttons.LT : Object
        + Xbox360Lib.Enum.Buttons.RT : Object
        + Xbox360Lib.Enum.Buttons.LSX : Object
        + Xbox360Lib.Enum.Buttons.LSY : Object
        + Xbox360Lib.Enum.Buttons.RSX : Object
        + Xbox360Lib.Enum.Buttons.RSY : Object

Xbox360Lib.Enum.Threshold
    Attributes
        + Xbox360Lib.Enum.Buttons.LT : Int
        + Xbox360Lib.Enum.Buttons.RT : Int

Xbox360Lib.Enum.Deadzone
    Attributes
        + Xbox360Lib.Enum.Buttons.LSX : Int
        + Xbox360Lib.Enum.Buttons.LSY : Int
        + Xbox360Lib.Enum.Buttons.RSX : Int
        + Xbox360Lib.Enum.Buttons.RSY : Int
```        
