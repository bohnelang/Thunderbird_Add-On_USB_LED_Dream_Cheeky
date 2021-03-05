# Thunderbird Add-On for interfacing LED Dream Cheeky DL100B Webmail Notifier. 


**This add-on is outdated - the last version you can run is Thunderbird 68.0. With Thunderbird 78 a new add-on-API was implemented and at the moement I do not have the time to update implementation...**


![USB Webmail notifier](./gitmisc/LED2.jpg)

This Thunderbird add-on installs a custom action filter that provides an  interface to a binary program that can set a color and can switch on and off the USB-device. On incoming mails you can let blink the LED gadget :-)

The add-on contains binary programs to interface the hardware. Maybe a antivirus programm will check it while installation. All binaries are build on a Linux host. There are binaries for Windows, Linux and Mac in a 32bit and 64bit program. 



![Different looks same device](./gitmisc/usbwebmailnotifier.jpg)


## Installation:

Unitl this extension is not in the official Thunderbird repository you need to download and install this one manualy. 

Download the xpi-file to a local device. Then open the main menu (see section "Settings" for an image) and scroll down to the Add-ons entry. Click this entry. Click again the Add-ons entry in the new box. Then open the menu (right top) and choose "Install Add-on from File". 

![Install Add-on from File](./gitmisc/menue1.jpg)

Important: On Linux devices you need to allow normal user to access hardware like this USB-device. You need to intall an udev-rule (see 24-LED-notifier.rules). Otherwise only root is able to access the USB-device.

## Activate and enable the filter
For each mail account you can enable a mail filter and you can set different colores for different accounts. The following images shows how to enable this new custom filter. 

![Enable Filter](./gitmisc/AddFilter.JPG)


Color codes:
```
0: off 
1: green   
2: red     
3: blue   
4: cyan   
5: yellow  
6: magenta 
7: white   
```

## Settings properties
There is only one property you can set - Debug enabled.

![Show Add-on](./gitmisc/ShowAddOn.JPG)

## Acknowledgment
This project combines experience and code from other developer. The most of the Thunderbird add-on code was taken from Axel's FiltaQuilla.

- Axel Grude (Realraven) for his FiltaQuilla (and ToneQuilla [https://github.com/RealRaven2000](https://github.com/RealRaven2000) 
- R Kent James (rkent) [https://github.com/rkent/](https://github.com/rkent/glodaquilla)
- Paweł Tomulik (ptomulik) [https://github.com/ptomulik](https://github.com/ptomulik) 
- Paul Gallagher (tardate) for the blincy.c code [LittleArduinoProjects/Electronics101/UsbNotifier/](https://github.com/tardate/LittleArduinoProjects/blob/master/Electronics101/UsbNotifier/)
- Alan Ott (signal11) for his multi-platform HID-API [signal11/hidapi](https://github.com/signal11/hidapi)
- Damien Zammit (zamaudio) for the cross mac environment [zamaudio/cross-apple](https://github.com/zamaudio/cross-apple)
- phracker [phracker/MacOSX-SDKs](https://github.com/phracker/MacOSX-SDKs)

 A big thank you to all of them. Special thanks to Axel who answered my questions and provided a lot of very helpful pieces of advice!



## Related but not used information to this USB-device:
- JavaScript Node code:  [Dream-Cheeky-USB-WebMail-Notifier](https://github.com/kniffen/Dream-Cheeky-USB-WebMail-Notifier/blob/master/usbwn.js)
- Nativ Linux kernel module: [Webmail Notifier Linux Driver] (https://github.com/nathan-osman/Webmail-Notifier-Linux-Driver)
- Linux-Kernel driver for hidraw interface: [linux/drivers/hid/hid-led.c](https://github.com/torvalds/linux/blob/master/drivers/hid/hid-led.c)

```
dmesg 
 ...
  usb 3-4: new low-speed USB device number 6 using ohci-pci
  usb 3-4: New USB device found, idVendor=1294, idProduct=1320, bcdDevice= 1.00
  usb 3-4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
  usb 3-4: Product: MAIL 
  usb 3-4: Manufacturer: MAIL 
  hid-led 0003:1294:1320.0003: hidraw0: USB HID v1.10 Device [MAIL  MAIL ] on usb-0000:00:13.1-4/input0
  
 Switch led on / off on bash level:
 sudo echo "1" > /sys/class/leds/riso_kagaku0\:blue/brightness 
 sudo echo "0" > /sys/class/leds/riso_kagaku0\:blue/brightness
```


## How an add-on can use USB devices
The add-on carries for the most operating systems a binary that can interface the HID interface. The add-on can execute this binary but only as a real file in filesystem.
- Copy binaries from add-on to local file system (profile directory)
- Make them executable
- Execute them
 

```
    function copyDataURLToFile(aURL, file, callback) {
      let uri = Services.io.newURI(aURL),
          newChannelFun = Services.io.newChannelFromURI ?
                          Services.io.newChannelFromURI.bind(Services.io) :
                          Services.io.newChannelFromURI2.bind(Services.io),
          channel = newChannelFun(uri,
                    null,
                    Services.scriptSecurityManager.getSystemPrincipal(),
                    null,
                    Ci.nsILoadInfo.SEC_REQUIRE_SAME_ORIGIN_DATA_INHERITS,
                    Ci.nsIContentPolicy.TYPE_OTHER);

      NetUtil.asyncFetch(channel, function(istream) {
        var ostream = Cc["@mozilla.org/network/file-output-stream;1"].
                      createInstance(Ci.nsIFileOutputStream);
        //ostream.init(file, -1, -1,  Ci.nsIFileOutputStream.DEFER_OPEN); /
        ostream.init(file, -1, parseInt("0755", 8) ,  Ci.nsIFileOutputStream.DEFER_OPEN); // AB
        NetUtil.asyncCopy(istream, ostream, function(result) {
          callback && callback(file, result);
        });
      });
    }

	  
        let fileList = ['blinky_x86-64','blinky_x86','blinky_x86-64.app','blinky_x86.app','blinky_x86-64.exe','blinky_x86.exe'];

        for (let i=0; i<fileList.length; i++) {
          let name = fileList[i],
              file =  FileUtils.getFile("ProfD", new Array("extensions", "usbmailaction","bin", name)); 
          try {
            if (file && ( !file.exists() || util.isDebug ) ) {
              Services.console.logStringMessage("Copy Files for local: " + name );
              copyDataURLToFile("chrome://usbmailaction/content/bin/" + name, file);
            }
            else
              if (util.isDebug) Services.console.logStringMessage("File exists: " + file.path);
          }
          catch(ex) {
            re(ex);
          }
        };
        
        
        ...
        
self.runFile =
    {
      id: "usbmailaction@bohne-lang.de#runFile",
      name: self.strings.GetStringFromName("usbmailaction.runfile.name"),
      apply: function(aMsgHdrs, aActionValue, aListener, aType, aMsgWindow) {
        var file = Cc["@mozilla.org/file/local;1"]
                     .createInstance(Ci.nsILocalFile || Ci.nsIFile);

	Components.utils.import("resource://gre/modules/FileUtils.jsm");

	let binfileURL =  FileUtils.getFile("ProfD", new Array("extensions", "usbmailaction","bin"));
        var fileURL = binfileURL.path;
         
	let prefs = Cc["@mozilla.org/preferences-service;1"].getService(Ci.nsIPrefService);
    	prefs = prefs.getBranch("extensions.usbmailaction.");

	let d = new Date().getTime();

    	try {
      		let lastexecution  = prefs.getIntPref("lastexecution");
    	} catch (e) { let lastexecution = d;}
	
	
	if( 1==1 || d - lastexecution > 3) {
		 try {
		 	prefs.setIntPref("lastexecution",d);
		} catch (e) {Services.console.logStringMessage("Cannot set time");}
	
		let sysinfo = Cc["@mozilla.org/system-info;1"].getService(Ci.nsIPropertyBag2); 
        	let xr = Cc["@mozilla.org/xre/app-info;1"].getService(Ci.nsIXULRuntime);

		var OSname = sysinfo.getProperty("name")
   		var Arch = sysinfo.getProperty("arch");

	  	if(OSname == "Windows_NT") 	{ fileURL = fileURL + "\\blinky_" + Arch +".exe"; }
  		if(OSname == "Darwin") 		{ fileURL = fileURL + "/blinky_" + Arch +".app"; }
  		if(OSname == "Linux") 		{ fileURL = fileURL + "/blinky_" + Arch; }
	
		if (util.isDebug) {	
	      		Services.console.logStringMessage(OSname + " / " + Arch);
	      		Services.console.logStringMessage("Exec Blinky " + fileURL);
        	}


        	file.initWithPath(fileURL);

        	for (var messageIndex = 0; messageIndex < aMsgHdrs.length; messageIndex++) {
          		let theProcess = Cc["@mozilla.org/process/util;1"]
                           .createInstance(Ci.nsIProcess);

          		theProcess.init(file);
          		theProcess.run(false,[aActionValue],1);
        	}
      	}
      },

      isValidForType: function(type, scope) {return runFileEnabled;},
      validateActionValue: function(value, folder, type) { return null;},
      allowDuplicates: true,
      needsBody: false
    } // end runFile

 ```
 I did a long research on internet but found no solution like this. It  seems to me that is a new way that Thunderbird can execute build-in binary programs. 
