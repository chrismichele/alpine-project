<cfscript>
include 'header.cfm';
if(structKeyExists(session,"isAdmin") && session.isAdmin === 1){
    getUsers = objUser.read();
}
else{
    writeOutput('Sorry, you do not have permission. Please <a href="login.cfm">login</a> using an admin account.');
    abort;
}
</cfscript>

<h1>User Accounts Report</h1>
<table class="table table-hover table-border table-striped">
<tr>
  <th>First Name</th>
  <th>Last Name</th>
  <th>Email Address</th>
</tr>
  
<cfoutput query="getUsers">
  <tr>
    <td>#getUsers.firstName#</td>
    <td>#getUsers.lastName#</td>
    <td>#getUsers.emailAddress#</td>
  </tr>
</cfoutput>
</table>