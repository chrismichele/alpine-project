<cfscript>
include 'header.cfm';
getUser = objUser.read(userID=session.userID);
</cfscript>

<cfoutput query="getUser">
    <h1>Profile</h1>
    Account Created on #dateTimeFormat(getUser.dateCreated,"medium")#<br>
    First Name: #getUser.firstName# <br>
    Last Name: #getUser.lastName# <br>
    Email: #getUser.emailAddress# <br>
</cfoutput>

<cfinclude template="footer.cfm" />