<cfcomponent output="false">

	<!--- set application name based on the directory path --->
	<cfset this.name = right(REReplace(getDirectoryFromPath(getCurrentTemplatePath()),'[^A-Za-z]','','all'),64) />
	<cfset this.sessionmanagement = true />
	<cfset this.errorEmail="" />
	<cfset application.cfcpath = "" />

	<cffunction name="onApplicationStart" output="false">
		<cfset this.appSetUp() />
	</cffunction>

	<cffunction name="onRequestStart" output="false">
		<cfif StructKeyExists(url, "resetapp") and url.resetapp EQ 1>
			<cfset this.appSetUp() />	
		</cfif>
	</cffunction>

	<cffunction name="appSetUp" output="false">
		<cfset application.wordjumble = CreateObject("component", "model.WordJumble").init() />
		<cfset application.wordcache = application.wordjumble.getWordCache() />
	</cffunction>
</cfcomponent>
