# AHK TaskBar_SetAttr
Make the Windows 10 Taskbar translucent / blur / coloring


## Example
```AutoHotkey
TaskBar_SetAttr(1, 0xc1e3c791)    ; <- Set gradient    with color 0xd7a78f ( rgb = 0x91c7e3 ) and alpha 0xc1

TaskBar_SetAttr(2, 0xa1e3c791)    ; <- Set transparent with color 0xd7a78f ( rgb = 0x91c7e3 ) and alpha 0xa1

TaskBar_SetAttr(2)                ; <- Set transparent

TaskBar_SetAttr(3)                ; <- Set blur

TaskBar_SetAttr(0)                ; <- Set standard value
```
![TaskBar_SetAttr_01](img/TaskBar_SetAttr_01.png)
![TaskBar_SetAttr_02](img/TaskBar_SetAttr_02.png)
![TaskBar_SetAttr_03](img/TaskBar_SetAttr_03.png)
![TaskBar_SetAttr_04](img/TaskBar_SetAttr_04.png)


## Limitations
* Run only on Windows 10


## Info
* [AHK Thread](https://autohotkey.com/boards/viewtopic.php?f=6&t=26752)


## Contributing
* thanks to AutoHotkey Community


## Questions / Bugs / Issues
Report any bugs or issues on the [AHK Thread](https://autohotkey.com/boards/viewtopic.php?f=6&t=26752). Same for any questions.


## Donations
[Donations are appreciated if I could help you](https://www.paypal.me/smithz)


## Copyright and License
[Unlicense](http://unlicense.org/)