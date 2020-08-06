<cfscript>
	// point this at your timezone CFC location
	tz=createObject("component","timeZone");
	today=createdateTime(2005,8,2,9,1,1);
	timeZones=tz.getAvailableTZ();
	if (structKeyExists(form,"thisTZ")){
		inDST=tz.isDST(today,form.thisTZ);
		thisRawOffset=tz.getRawOffset(form.thisTZ);
		thisOffset=tz.getTZOffset(today,form.thisTZ);
		dstSavings=tz.getDST(form.thisTZ);
		hasDST=tz.usesDST(form.thisTZ);
		theseTZ=tz.getTZbyOffset(thisRawOffset);
		utcDate=tz.castToUTC(today,form.thisTZ);
		castDate=tz.castFromUTC(today,form.thisTZ);
		serverDate=tz.castToServer(today,form.thisTZ);
		fromServer=tz.castFromServer(today,form.thisTZ);
		serverTZ=tz.getServerTZ();
	}
</cfscript>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>timeZone.cfc testbed</title>
	<style type="text/css" media="screen">
	        TABLE {
		    font-size : 85%;
	        }
	</style>    
	
</head>

<body>
<form action="testTZCFC.cfm" method="post">
<b>timezone</b>:
&nbsp; 
<select name="thisTZ" size="1">
	<cfoutput>
	<cfloop index="i" from="1" to="#arrayLen(timeZones)#">
	<option value="#timeZones[i]#">#timeZones[i]#</option>
	</cfloop>
	</cfoutput>
</select>
&nbsp;
&nbsp;
<input type="submit" value="go">
</form>
<cfif structKeyExists(form,"thisTZ")>
<cfoutput>
<table cellspacing="2" cellpadding="1">
<tr><td align="right"><b>server datetime</b> :: </td><td>#dateformat(today)#&nbsp;&nbsp;#timeformat(today)#</td></tr>
<tr><td align="right"><b>server timezone</b> :: </td><td>#serverTZ#</td></tr>
<tr><td align="right"><b>selected timezone</b> :: </td><td>#form.thisTZ#</td></tr>
<tr><td align="right"><b>raw offset</b> :: </td><td>#numberFormat(thisRawOffset,"+__.__")# hrs</td></tr>
<tr><td align="right"><b>offset</b> :: </td><td>#numberFormat(thisOffset,"+__.__")# hrs</td></tr>
<tr><td align="right"><b>DST savings</b> :: </td><td>#numberFormat(dstSavings,"+__.__")# hrs</td></tr>
<tr><td align="right"><b>uses DST</b> :: </td><td>#hasDST#</td></tr>
<tr><td align="right"><b>in DST</b> :: </td><td>#inDST#</td></tr>
<tr><td align="right"><b>cast to UTC</b> :: </td><td>#dateFormat(UTCdate)#&nbsp;&nbsp;#timeFormat(UTCdate)#</td></tr>
<tr><td align="right"><b>cast from UTC</b> :: </td><td>#dateFormat(castDate)#&nbsp;&nbsp;#timeFormat(castDate)#</td></tr>
<tr><td align="right"><b>cast to server</b> :: </td><td>#dateFormat(serverDate)#&nbsp;&nbsp;#timeFormat(serverDate)#</td></tr>
<tr><td align="right"><b>cast from server</b> :: </td><td>#dateFormat(fromServer)#&nbsp;&nbsp;#timeFormat(fromServer)#</td></tr>
</table>
</cfoutput>
<br>
<table cellspacing="1" cellpadding="1">
	<tr><td colspan="10" height="20px"></td></tr>
	<tr valign="top" bgcolor="#c0c0c0">
		<td colspan="10"><b>Other timezones with <cfoutput>#numberFormat(thisRawOffset,"+__.__")#</cfoutput> hrs raw offset.</b></td>
	</tr>
	<cfif arrayLen(theseTZ)>
	<cfoutput>
	<cfloop index="i" from="1" to="#arrayLen(theseTZ)#">
	<tr>
		<td>#theseTZ[i]#</td>
	</tr>
	</cfloop>
	</cfoutput>
	<cfelse>
	<tr><td><b>None found.</b></td></tr>	
	</cfif>	
</table>	
</cfif>
</body>
</html>
