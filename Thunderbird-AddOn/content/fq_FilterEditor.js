"use strict";
/*
 ***** BEGIN LICENSE BLOCK *****
 * This file is part of FiltaQuilla, Custom Filter Actions
 * rereleased by Axel Grude (original project by R Kent James
 * under the Mesquilla Project)
 *
 * USBMailAction is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * You should have received a copy of the GNU General Public License
 * along with FiltaQuilla.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 */

{
  var {USBMailAction} = Components.utils.import("chrome://usbmailaction/content/usbmailaction-util.js"); // USBMailAction object
  const util = USBMailAction.Util,
        Ci = Components.interfaces,
        Cc = Components.classes;

  	if (util.isDebug) util.logDebug("fq_FilterEditor.js - start...");


  function getChildNode(type) {
      const elementMapping = { "usbmailaction@bohne-lang.de#runFile": "usbmailaction-ruleactiontarget-runpicker" };
      const elementName = elementMapping[type];
      return elementName ? document.createXULElement(elementName) : null;
  }

  function patchRuleactiontargetWrapper() {
    let wrapper = customElements.get("ruleactiontarget-wrapper");
    if (wrapper) {
      let alreadyPatched = wrapper.prototype.hasOwnProperty("_patchedByUSBMailActionExtension") ?
                           wrapper.prototype._patchedByUSBMailActionExtension :
                           false;
      if (alreadyPatched) {
        // already patched
        return;
      }
      let prevMethod = wrapper.prototype._getChildNode;
      if (prevMethod) {
        wrapper.prototype._getChildNode = function(type) {
          let element = getChildNode(type);
          return element ? element : prevMethod(type);
        };
        wrapper.prototype._patchedByUSBMailActionExtension = true;
      }
    }
  }

  patchRuleactiontargetWrapper();

  const updateParentNode = (parentNode) => {
    if (parentNode.hasAttribute("initialActionIndex")) {
      let actionIndex = parentNode.getAttribute("initialActionIndex");
      let filterAction = gFilter.getActionAt(actionIndex);
      parentNode.initWithAction(filterAction);
    }
    parentNode.updateRemoveButton();
  };

  class USBMailActionRuleactiontargetBase extends MozXULElement { }


  /* CODE CONVERTED USING https://bgrins.github.io/xbl-analysis/converter/ */

  /* This Source Code Form is subject to the terms of the Mozilla Public
   * License, v. 2.0. If a copy of the MPL was not distributed with this
   * file, You can obtain one at http://mozilla.org/MPL/2.0/. */



  class USBMailActionRuleactiontargetRunPicker extends USBMailActionRuleactiontargetBase {
    connectedCallback() {
      if (this.delayConnectedCallback()) {
        return;
      }
      this.textContent = "";
      this.appendChild(MozXULElement.parseXULToFragment(`
        <hbox>
          <textbox class="ruleactionitem" value="1" onchange="this.parentNode.value = this.value;"></textbox>
        </hbox>
      `));

      this.hbox = this.getElementsByTagName("hbox")[0]; // document.getAnonymousNodes(this)[0];
      this.textbox =  this.hbox.firstChild;             // document.getAnonymousNodes(this)[0].firstChild;

      updateParentNode(this.closest(".ruleaction"));
      this.textbox.setAttribute('value', this.hbox.value);

    }

  } // run picker

  customElements.define("usbmailaction-ruleactiontarget-runpicker", USBMailActionRuleactiontargetRunPicker);


  if (util.isDebug) util.logDebug("fq_FilterEditor.js - Finished.");


} // javascript action


// vim: set expandtab tabstop=2 shiftwidth=2:
