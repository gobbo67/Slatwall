<!---

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

--->
<cfparam name="rc.edit" default="false" />
<cfparam name="rc.optiongroup" type="any" />
 
<cfoutput>
	<ul id="navTask">
		<cf_SlatwallActionCaller action="admin:option.listoptiongroups" type="list">
		<cfif !rc.edit>
			<cf_SlatwallActionCaller action="admin:option.editoptiongroup" querystring="optiongroupid=#rc.optionGroup.getOptionGroupID()#" type="list">
		<cfelse>
			<cf_SlatwallActionCaller action="admin:option.detailoptiongroup" querystring="optiongroupid=#rc.optionGroup.getOptionGroupID()#" type="list">
		</cfif>
	</ul>

	<cfif rc.edit>
		<form name="OptionGroupForm" id="OptionGroupForm" enctype="multipart/form-data" method="post">
			<input type="hidden" name="slatAction" value="admin:option.saveoptiongroup" />
			<input type="hidden" name="optionGroupID" value="#rc.optionGroup.getOptionGroupID()#" />
	</cfif>
	
		    <dl class="twoColumn">
		    	<cf_SlatwallPropertyDisplay object="#rc.OptionGroup#" property="optionGroupName" edit="#rc.edit#" />
				<cf_SlatwallPropertyDisplay object="#rc.OptionGroup#" property="optionGroupCode" edit="#rc.edit#" toggle="true" />
				<cf_SlatwallPropertyDisplay object="#rc.OptionGroup#" property="imageGroupFlag" edit="#rc.edit#" />
				<cfif rc.edit>
					<!--- if editing, display field for image uploading --->
					<cf_SlatwallPropertyDisplay object="#rc.OptionGroup#" property="OptionGroupImage" edit="#rc.edit#" fieldType="file" tooltip=true>
				</cfif>
				<cfif len(rc.OptionGroup.getOptionGroupImage())>
					<!--- if editing, and optiongroup has an image, display it  --->
					<dt>
						#rc.$.Slatwall.rbKey("entity.optiongroup.optiongroupimage")#
					</dt>
					<dd>
						<a href="#rc.OptionGroup.getImagePath()#">#rc.OptionGroup.getImage("40")#</a>
					<cfif rc.edit>
						<input type="checkbox" name="removeImage" value="1" id="chkRemoveImage"> <label for="chkRemoveImage">#rc.$.Slatwall.rbKey("admin.option.removeimage")#</label>
					</cfif>
					</dd>
				</cfif>
			</dl>
			
			<div class="tabs initActiveTab ui-tabs ui-widget ui-widget-content ui-corner-all clear">
				<ul>
					<li><a href="##tabOptions" onclick="return false;"><span>#rc.$.Slatwall.rbKey("entity.optionGroup.options")#</span></a></li>	
					<li><a href="##tabDescription" onclick="return false;"><span>#rc.$.Slatwall.rbKey("entity.optionGroup.optionGroupDescription")#</span></a></li>
				</ul>
			
				<div id="tabOptions">
					#view("option/optiongrouptabs/options")#
				</div>
				<div id="tabDescription">
					<cf_SlatwallPropertyDisplay object="#rc.optionGroup#" property="optionGroupDescription" edit="#rc.edit#" fieldType="wysiwyg" displayType="plain">
				</div>
			</div>
			
	<cfif rc.edit>
			<div id="actionButtons" class="clearfix">
				<cf_SlatwallActionCaller action="admin:option.listoptiongroups" type="link" class="button" text="#rc.$.Slatwall.rbKey('sitemanager.cancel')#">
				<cf_SlatwallActionCaller action="admin:option.saveoptiongroup" type="submit" class="button">
			</div>
		</form>
	</cfif>
	
</cfoutput>
