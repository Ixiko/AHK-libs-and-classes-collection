# AutoHotkey wrapper for NVIDIA NVML


## Features
* retrieves attributes (engine counts etc.)
* retrieves minor number
* retrieves power usage for this GPU in milliwatts and its associated circuitry (e.g. memory)
* retrieves the NVML index of this device
* retrieves the amount of used, free and total memory available on the device, in bytes
* retrieves the brand of this device
* retrieves the current temperature readings for the device, in degrees C
* retrieves the current utilization rates for the device's major subsystems
* retrieves the global infoROM image version
* retrieves the globally unique immutable UUID
* retrieves the intended operating speed of the device's fan
* retrieves the name of this device
* retrieves the number of compute devices in the system. A compute device is a single GPU
* retrieves the version of the NVML library
* retrieves the version of the system's graphics driver
* retrieves total energy consumption for this GPU in millijoules (mJ) since the driver was last reloaded


## Examples
![Class_NVML_Example](img/Class_NVML_Example.png)


## Supported products
- ### Full Support
	- All Tesla products, starting with the Fermi architecture
	- All Quadro products, starting with the Fermi architecture
	- All vGPU Software products, starting with the Kepler architecture
	- Selected GeForce Titan products
- ### Limited Support
	- All Geforce products, starting with the Fermi architecture


## Contributing
* special thanks to thanks to 'Oleksandr' for his "Monitoring Nvidia GPUs using API" Docu
* thanks to AutoHotkey Community


## Questions / Bugs / Issues
If you notice any kind of bugs or issues, report them on the [AHK Thread](https://www.autohotkey.com/boards/viewtopic.php?t=95175). Same for any kind of questions.


## Copyright and License
[MIT License](LICENSE) & NVIDIA Management Library (NVML) License by NVIDIA Corporation


## Donations
[Donations are appreciated if I could help you](https://www.paypal.me/smithz)