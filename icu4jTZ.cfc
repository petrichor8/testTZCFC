<cfcomponent displayname="timezone" hint="various timezone functions not included in mx based on ICU4J: version 2.1 icu4j mar-2006 Paul Hastings (paul@sustainbleGIS.com)" output="No">
<!--- 
author:		paul hastings <paul@sustainableGIS.com>
date:		27-mar-2006
revisions:	30-mar-2006 added 1 method (getServerTZShort) contributed by dan switzer: 
			dswitzer@pengoworks.com
			
notes:		this cfc contains methods to handle some timezone functionality not in cfmx 
			as well as when you need to "cast" to a specific timezone (cf's timezone 
			functions are tied to the server). this implementation uses ICU4J's 
			com.ibm.icu.util.TimeZone. 
			
methods in this CFC:
			- isDST determines if a given date & timezone are in DST. if no date or timezone is passed
			the method defaults to current date/time and server timezone. PUBLIC.
			- getAvailableTZ returns an array of available timezones on this server (ie according to 
			server's icu4j version). PUBLIC.
			- getTZByOffset returns an array of available timezones on this server (ie according to 
			server's icu4j version) with the same UTC offset. PUBLIC.
			- getTZByCountry returns an array of available timezones on this server (ie according to 
			server's icu4j version) within a given country. PUBLIC.
			- isValidTZ determines if a given timezone is valid according to getAvailableTZ. PUBLIC.
			- usesDST determines if a given timezone uses DST. PUBLIC.
			- getRawOffset returns the raw (as opposed to DST) offset in hours for a given timezone. 
			PUBLIC.
			- getTZOffset returns offset in hours for a given date/time & timezone, uses DST if timezone 
			uses and is currently in DST. PUBLIC.	
			- getDST returns DST savings for given timezone. PUBLIC.
			- castToUTC return UTC from given datetime in given timezone. required argument thisDate,
			optional argument thisTZ valid timezone ID, defaults to server timezone. PUBLIC.
			- castfromUTC return date in given timezone from UTC datetime. required argument thisDate,
			optional argument thisTZ valid timezone ID, defaults to server timezone. PUBLIC.
			- castToServer returns server datetime from given datetime in given timezone. required argument 
			thisDate valid datetime, optional argument thisTZ valid timezone ID, defaults to server 
			timezone. PUBLIC.
			- castfromServer return datetime in given timezone from server datetime. required argument 
			thisDate valdi datetime, optional argument thisTZ valid timezone ID, defaults to server 
			timezone. PUBLIC.
			- getServerTZ returns server timezone. PUBLIC
			- getServerTZShort returns "short" name for the server's timezone. PUBLIC
			- getServerId returns ID for the server's timezone. PUBLIC
 --->

<cffunction name="init" output="No" access="public">
	<cfset variables.timeZone=createObject("java","com.ibm.icu.util.TimeZone")>
	<cfreturn this>
</cffunction>

<cffunction access="public" name="getTZByCountry" output="No" hint="gets timezone by country" returntype="array">
<cfargument name="country" required="yes" type="string" hint="2-letter ISO country code to get timezone for">
	<cfreturn variables.timeZone.getAvailableIDs(arguments.country)>
</cffunction>

<cffunction name="getAvailableTZ" output="No" returntype="array" access="public" hint="returns a list of timezones available on this server">  
		<cfreturn variables.timeZone.getAvailableIDs()>
</cffunction>

<cffunction name="isValidTZ" output="No" returntype="boolean" access="public" hint="validates if a given timezone is in list of timezones available on this server">
<cfargument name="tzToTest" required="yes">
	<cfif listFindNoCase(arrayToList(getAvailableTZ()),arguments.tzTotest)>
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction name="usesDST" output="No" returntype="boolean" access="public" hint="determines if a given timezone uses DST">
<cfargument name="tz" required="no" default="#variables.timeZone.getDefault().getDisplayName()#">
	<cfreturn variables.timeZone.getTimeZone(arguments.tz).useDaylightTime()>
</cffunction>

<cffunction name="getRawOffset" output="No" access="public" returntype="numeric" hint="returns rawoffset in hours">
<cfargument name="tZ" required="no" default="#variables.timeZone.getDefault().getDisplayName()#">
		<cfset var thisTZ=variables.timeZone.getTimeZone(arguments.tZ)>
		<cfreturn thisTZ.getRawOffset()/3600000>
</cffunction>

<cffunction name="getDST" output="No" access="public" returntype="numeric" hint="returns DST savings in hours">  
<cfargument name="thisTZ" required="no" default="#variables.timeZone.getDefault().getDisplayName()#">
	<cfset var tZ=variables.timeZone.getTimeZone(arguments.thisTZ)>
	<cfreturn tZ.getDSTSavings()/3600000>
</cffunction>

<cffunction name="getTZByOffset" output="No" returntype="array" access="public" hint="returns a list of timezones available on this server for a given raw offset">  
<cfargument name="thisOffset" required="Yes" type="numeric">
	<cfset var rawOffset=javacast("long",arguments.thisOffset * 3600000)>
	<cfreturn variables.timeZone.getAvailableIDs(rawOffset)>
</cffunction>

<cffunction name="getServerTZ" output="No" access="public" returntype="any" hint="returns server TZ">
	<cfset serverTZ=variables.timeZone.getDefault()>
	<cfreturn serverTZ.getDisplayName(true,variables.timeZone.LONG)>
</cffunction>

<cffunction name="isDST" output="No" returntype="boolean" access="public" hint="determines if a given date in a given timezone is in DST">  
<cfargument name="dateToTest" required="no" type="date" default="#now()#">
<cfargument name="tzToTest" required="no" default="#variables.timeZone.getDefault().getDisplayName()#">
	<cfset var thisTZ=variables.timeZone.getTimeZone(arguments.tzToTest)>
	<cfreturn thisTZ.inDaylightTime(arguments.dateTotest)>
</cffunction>

<cffunction name="getTZOffset" output="No" access="public" returntype="numeric" hint="returns offset in hours">  
<cfargument name="thisDate" required="no" type="date" default="#now()#">
<cfargument name="thisTZ" required="no" default="#variables.timeZone.getDefault().getDisplayName()#">
<cfscript>
	var tZ=variables.timeZone.getTimeZone(arguments.thisTZ);
	var tYear=javacast("int",Year(arguments.thisDate));
	var tMonth=javacast("int",month(arguments.thisDate)-1); //java months are 0 based
	var tDay=javacast("int",Day(thisDate));
	var tDOW=javacast("int",DayOfWeek(thisDate));	//day of week
	return tZ.getOffset(1,tYear,tMonth,tDay,tDOW,0)/3600000; //1 here == AD era
</cfscript>
</cffunction>

<cffunction name="castToUTC" output="No" access="public" returntype="date" hint="returns UTC from given date in given TZ, takes DST into account, accurate to the second">  
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="thisTZ" required="no" default="#variables.timeZone.getDefault().getDisplayName()#">
<cfscript>
	var tZ=variables.timeZone.getTimeZone(arguments.thisTZ);
	var tYear=javacast("int",Year(arguments.thisDate));
	var tMonth=javacast("int",month(arguments.thisDate)-1); //java months are 0 based
	var tDay=javacast("int",Day(thisDate));
	var tDOW=javacast("int",DayOfWeek(thisDate));	//day of week
	var thisOffset=(tZ.getOffset(1,tYear,tMonth,tDay,tDOW,0)/1000)*-1.00;
	return dateAdd("s",thisOffset,arguments.thisDate);
</cfscript>
</cffunction>

<cffunction name="castFromUTC" output="No" access="public" returntype="date" hint="returns date in given TZ from given UTC date, takes DST into account, accurate to the second">  
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="thisTZ" required="no" default="#variables.timeZone.getDefault().getDisplayName()#">
<cfscript>
	var tZ=variables.timeZone.getTimeZone(arguments.thisTZ);
	var tYear=javacast("int",Year(arguments.thisDate));
	var tMonth=javacast("int",month(arguments.thisDate)-1); //java months are 0 based
	var tDay=javacast("int",Day(thisDate));
	var tDOW=javacast("int",DayOfWeek(thisDate));	//day of week
	var thisOffset=tZ.getOffset(1,tYear,tMonth,tDay,tDOW,0)/1000;
	return dateAdd("s",thisOffset,arguments.thisDate);
</cfscript>
</cffunction>

<cffunction name="castToServer" output="No" access="public" returntype="date" hint="returns server date in given TZ from given UTC date, takes DST into account">  
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="thisTZ" required="no" default="#variables.timeZone.getDefault().getDisplayName()#">
	<cfreturn dateConvert("utc2Local",castToUTC(arguments.thisDate,arguments.thisTZ))>
</cffunction>

<cffunction name="castFromServer" output="No" access="public" returntype="date" hint="returns date in given TZ from given server date, takes DST into account">  
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="thisTZ" required="no" default="#variables.timeZone.getDefault().getDisplayName()#">
	<cfreturn castFromUTC(dateConvert("local2UTC",arguments.thisDate),arguments.thisTZ)>
</cffunction>

<!--- contributed by dan switzer: dswitzer@pengoworks.com --->
<cffunction name="getServerTZShort" output="No" access="public" returntype="string">
	<cfreturn variables.timeZone.getDefault().getDisplayName(true,variables.timeZone.SHORT)>
</cffunction>

<!--- contributed by dan switzer: dswitzer@pengoworks.com --->
<cffunction name="getServerId" output="No" access="public" returntype="any" hint="returns server TZ">
	<cfreturn variables.timeZone.getDefault().getID()>
</cffunction>

<!--- remove for production? --->
<cffunction name="dumpMe" access="public" returntype="any" output="No">
	<cfset var tmpStr="">
	<cfsavecontent variable="tmpStr">
		<cfdump var="#variables#"/>
	</cfsavecontent>
	<cfreturn tmpStr>
</cffunction>

</cfcomponent>