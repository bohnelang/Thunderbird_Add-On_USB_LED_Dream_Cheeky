// "use strict";

/*
 ***** BEGIN LICENSE BLOCK *****
 * This file is part of USBMailAction Custom Filter Actions.
 *
 * USBMailAction is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * You should have received a copy of the GNU General Public License
 * along with USBMailAction.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is FiltaQuilla code.
 *
 * The Initial Developer of the Original Code is
 * Kent James <rkent@mesquilla.com>
 * Axel Grude 
 * Portions created by the Initial Developer are Copyright (C) 2008
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): Andreas Bohne-Lang
 *
 * ***** END LICENSE BLOCK *****
 */


(function USBMailAction()
{
	debugger;
  
  Components.utils.import("resource://usbmailaction/inheritedPropertiesGrid.jsm");
  try {
    var { Services } = ChromeUtils.import("resource://gre/modules/Services.jsm");
  }
  catch(ex) {
    Components.utils.import("resource://gre/modules/Services.jsm");
  }
  
	var {USBMailAction} = Components.utils.import("chrome://usbmailaction/content/usbmailaction-util.js"); // USBMailAction object

  const Cc = Components.classes,
        Ci = Components.interfaces,
        Cu = Components.utils,
				util = USBMailAction.Util;


  // parameters for MoveLater
  //  delay (in milliseconds) between calls to move later
  const MOVE_LATER_DELAY = 5000,
        //  Maximum number of callbacks before we just go ahead and move it.
        MOVE_LATER_LIMIT = 12;

  // global scope variables
  this.usbmailaction = {}; // use strict leads to "this is undefined" error

  // local shorthand for the global reference
  var self = this.usbmailaction;

  self.initialized = false;
  self.name = USBMailAction;
  
  // (main window only) start version checker.
  try {
    let isCorrectWindow =
      (document && document.getElementById('messengerWindow') &&
       document.getElementById('messengerWindow').getAttribute('windowtype') === "mail:3pane");
    if (isCorrectWindow)
      window.addEventListener("load", 
        function() { 
          util.VersionProxy(window); 
        }, true);
  }
  catch (ex) { util.logDebug("calling VersionProxy failed\n" + ex.message); }

  const usbmailactionStrings = Cc["@mozilla.org/intl/stringbundle;1"]
                                .getService(Ci.nsIStringBundleService)
                                .createBundle("chrome://usbmailaction/locale/usbmailaction.properties"),
        headerParser = Cc["@mozilla.org/messenger/headerparser;1"].getService(Ci.nsIMsgHeaderParser),
        tagService = Cc["@mozilla.org/messenger/tagservice;1"].getService(Ci.nsIMsgTagService),
        abManager = Cc["@mozilla.org/abmanager;1"].getService(Ci.nsIAbManager),
        // cache the values of commonly used search operators
        nsMsgSearchOp = Ci.nsMsgSearchOp,
				Contains = nsMsgSearchOp.Contains,
				DoesntContain = nsMsgSearchOp.DoesntContain,
				Is = nsMsgSearchOp.Is,
				Isnt = nsMsgSearchOp.Isnt,
				IsEmpty = nsMsgSearchOp.IsEmpty,
				IsntEmpty = nsMsgSearchOp.IsntEmpty,
				BeginsWith = nsMsgSearchOp.BeginsWith,
				EndsWith = nsMsgSearchOp.EndsWith,
				Matches = nsMsgSearchOp.Matches,
				DoesntMatch = nsMsgSearchOp.DoesntMatch;

  let maxThreadScan = 20; // the largest number of thread messages that we will examine
  
  // Enabling of filter actions.
    let  runFileEnabled = true;


  // inherited property object
  let applyIncomingFilters = {
    defaultValue: function defaultValue(aFolder) {
      return false;
    },
    name: usbmailactionStrings.GetStringFromName("usbmailaction.applyIncomingFilters"),
    accesskey: usbmailactionStrings.GetStringFromName("usbmailaction.applyIncomingFilters.accesskey"),
    property: "applyIncomingFilters",
    //hidefor: "nntp,none,pop3,rss" // That is, this is only valid for imap.
    hidefor: "nntp,none" // That is, this is only valid for imap.
  };

  // javascript mime emitter functions
  self._mimeMsg = {};
  Cu.import("resource:///modules/gloda/mimemsg.js", self._mimeMsg);

  self._init = function() {
    self.strings = usbmailactionStrings;
    //self.strings = Services.strings.createBundle("chrome://usbmailaction/locale/usbmailaction.properties");

    /*
     * custom action implementations
     */

    // prepend to subject. This was called "append" due to an earlier bug
     
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



    // run file
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



    /*
     * Custom searches
     */



  };

  // extension initialization

  self.onLoad = function() {
		debugger;
    if (self.initialized)
      return;
    self._init();

    // Determine enabled actions from preferences

    let prefs = Cc["@mozilla.org/preferences-service;1"].getService(Ci.nsIPrefService);
    prefs = prefs.getBranch("extensions.usbmailaction.");

    try {
      maxThreadScan = prefs.getIntPref("maxthreadscan");
    } catch (e) { maxThreadScan = 20;}



    try {
      runFileEnabled = prefs.getBoolPref("runFile.enabled");
    } catch (e) {}



    var filterService = Cc["@mozilla.org/messenger/services/filters;1"]
                        .getService(Ci.nsIMsgFilterService);
    filterService.addCustomAction(self.runFile);



    // Inherited properties setup
    // standard format for inherited property rows
    //   defaultValue:  value if inherited property missing (boolean true or false)
    //   name:          localized display name
    //   property:      inherited property name
    InheritedPropertiesGrid.addPropertyObject(applyIncomingFilters);

    self.initialized = true;
  };

  // local private functions



  function dl(text) {dump(text + '\n');}


})();

window.addEventListener("load", function(e) { usbmailaction.onLoad(e); }, false);

// vim: set expandtab tabstop=2 shiftwidth=2:
