# User Dream Cheeky  Webmail Notifier on Windos, MacOSX or Linux

This program is designed to interface the LED gadget on multible platforms. It uses source codes from 

- Paul Gallagher (tardate) for the blincy.c code LittleArduinoProjects/8051/AT89C2051/Blinky
- Alan Ott (signal11) for his multi-platform HID-API signal11/hidapi
- Damien Zammit (zamaudio) for the cross mac environment zamaudio/cross-apple
- phracker phracker/MacOSX-SDKs

and all binaries can be created on Linux by cross-compiling. 

### Testing:
You can use the pre-build binaries or compile ist by yourown. Then just plug the USB-device in and open a command line console:

#### Windows: 

`c:\>blinky_x86-64.exe 1`

#### Linux (libudev need to be installed, test it as root): 
`me@host:$ sudo ./blinky_x86-64 1`

#### MacOSX:

`$ ./blinky_x86-64.app 1`

