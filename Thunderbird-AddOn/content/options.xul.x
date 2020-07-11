<?xml version="1.0" encoding="UTF-8"?>
<!--
/*
 ***** BEGIN LICENSE BLOCK *****
 * This file is part of USBMailAction Custom Filter Actions 
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
 * The Original Code is FiltaQuilla code by Axel Grude.
 *
 * The Initial Developer of the Original Code is
 * Kent James <rkent@mesquilla.com>
 * Portions created by the Initial Developer are Copyright (C) 2008
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
 */
-->

<?xml-stylesheet href="chrome://global/skin/" type="text/css"?>
<?xml-stylesheet href="chrome://messenger/skin/preferences/preferences.css" type="text/css" ?>
<?xml-stylesheet href="chrome://usbmailaction/skin/usbmailaction-prefs.css" type="text/css" ?>

<!DOCTYPE prefwindow SYSTEM "chrome://usbmailaction/locale/prefwindow.dtd">
<dialog id="usbmailactionPreferences"
            xmlns="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul"
            title="&prefwindow.title;"
            onload="onLoad();">
  <script type="application/javascript" src="chrome://usbmailaction/content/options.js"/>
  <script type="application/javascript" src="chrome://usbmailaction/content/usbmailaction-util.js"/>

  <hbox class="title">USBMailAction - <spacer flex="5" />
    <label id="fq-options-header-version"> </label>
  </hbox>

  <prefpane id="pane1" label="&pane1.title;">

    <preferences>
      <preference id="runFileEnabled" name="extensions.usbmailaction.runFile.enabled" type="bool"/>
      <preference id="debug" name="extensions.usbmailaction.debug" type="bool"/>
    </preferences>

    <vbox>


    <tabbox id="usbmailactiontabbox" flex="1">
      <tabs class="icontabs">
        <tab label="&filterActions;" id="filterActionsTab"/>
        <tab label="&searchTerms;" id="conditionsTab"/>
        <tab label="&aboutAndSupport;" id="supportTab"/>
      </tabs>

      <tabpanels flex="1">
        <!-- Filter actions -->
        <tabpanel orient="vertical">
          <label value="&optionsIntro;"/>
          <grid>
            <columns id="actionCols">
              <column flex="1"/>
              <column flex="1"/>
              <column flex="1"/>
              <column flex="1"/>
            </columns>
            <rows>
              <row>

Content

              </row>
              <row>
              <!-- dummy row because I have complaints about size ? -->
                <spacer height="20px" />
              </row>
            </rows>
          </grid>
        </tabpanel>


        <tabpanel orient="vertical">
          <label value="&optionsIntro;"/>
          <grid>
            <columns>
              <column flex="1"/>
              <column flex="1"/>
              <column flex="1"/>
              <column flex="1"/>
            </columns>
            <rows>
							<row>
							  <spacer></spacer>
								<hr />
							</row>
            </rows>
          </grid>
        </tabpanel>
        
        <tabpanel orient="vertical">
				  <vbox class="linkBox">
						<hbox>
							<spacer flex="1" />
							<spacer flex="1" />
						</hbox>
	<table class="linkDescriptionBox">
              <tr>
                <td>
                  <img src="chrome://usbmailaction/skin/usbmailaction-32.png"
                       class="customLogo"
                       id="usbmailaction_img" />
                </td>
                <td>
                  <p class="linkDescription">
                    &supportPage_desc;
                  </p>
                </td>
              </tr>
	</table>
					</vbox>
				 	<hbox> 
								<span>
									<checkbox id="checkRunFileEnabled" preference="runFileEnabled"
														label="&checkRunFileEnabled.label;"
														accesskey="&checkRunFileEnabled.accesskey;"/>
									<toolbarbutton
										class="helpLink"
										onclick="USBMailAction.Util.openHelpTab('run_file');"
										tooltiptext="&helpFeatureTip;"
										/>
</span>
					</hbox>
          
					<hbox>
						<spacer flex="1" />
						<checkbox id="checkJavascriptEnabled"
											preference="debug"
											instantApply="true"
											label="Debug"
											oncontextmenu="USBMailAction.Util.toggleBoolPreference(this,true);USBMailAction.Util.showAboutConfig(this, 'usbmailaction.debug', true);return false;"
											/>
					</hbox>
				</tabpanel>
			</tabpanels>
    </tabbox>
</vbox>




  </prefpane>
	<script type="application/javascript" src="chrome://global/content/preferencesBindings.js" />
	<script>
	  USBMailAction.Util.loadPreferences(); /* Tb 66 compatibility. Should be called _before_ DOMcontent Loaded event */
	</script>

</dialog>
