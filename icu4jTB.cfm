<cfscript>
	tz=createObject("component","remoteicu4jTZ").init();
	timezones=tz.getTZByCountry("AU");
</cfscript>

<cfdump var="#timezones#">