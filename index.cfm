<cfscript>
    include 'header.cfm';
</cfscript>

<h1>Welcome to Alpine User Registration</h1>
<br>

<h2>create.sql</h2>
This database and table were created and tested using MySQL.
<pre>
CREATE DATABASE `alpine`;

USE `alpine`;

CREATE TABLE `users` (
 `userID` int(11) NOT NULL AUTO_INCREMENT,
 `lastName` varchar(255) DEFAULT NULL,
 `firstName` varchar(255) DEFAULT NULL,
 `emailAddress` varchar(255) DEFAULT NULL,
 `password` varchar(255) NOT NULL,
 `isAdmin` tinyint(1) NOT NULL DEFAULT 0,
 `dateCreated` timestamp NOT NULL DEFAULT current_timestamp(),
 PRIMARY KEY (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1
</pre>

<br>
<h2>user.cfc</h2>
<pre>
&lt;cfcomponent displayname="User Component" output="false">

  &lt;cffunction name="create" returntype="boolean">

    &lt;cfargument name="firstName" type="string" required="true" />
    &lt;cfargument name="lastName" type="string" required="true" />
    &lt;cfargument name="emailAddress" type="string" required="true" />
    &lt;cfargument name="password" type="string" required="true" />
    
    &lt;cfset success = true />
    
    &lt;cftry>  
    &lt;cfquery name="insertUser" datasource="alpine">
    INSERT INTO users (firstName, lastName, emailAddress, password)
    VALUES (&lt;cfqueryparam value="#arguments.firstName#" cfsqltype="CF_SQL_VARCHAR" />,
      &lt;cfqueryparam value="#arguments.lastName#" cfsqltype="CF_SQL_VARCHAR" />,
      &lt;cfqueryparam value="#arguments.emailAddress#" cfsqltype="CF_SQL_VARCHAR" />,
      &lt;cfqueryparam value="#arguments.password#" cfsqltype="CF_SQL_VARCHAR" />)
    &lt;/cfquery>
    
    &lt;cfcatch type="any">
        &lt;cfdump var="#cfcatch#" />
        &lt;cfset success = false />
    &lt;/cfcatch>
    &lt;/cftry>
    
    &lt;cfreturn success />
  &lt;/cffunction>
    
  &lt;cffunction name="read" returntype="query">
    &lt;cfargument name="userID" type="numeric" required="false" default="0" />
    
    &lt;cfquery name="getUser" datasource="alpine">
    SELECT  firstName, lastName, emailAddress, dateCreated, isAdmin
    FROM    users
    &lt;cfif arguments.userID gt 0>
        WHERE   userID = &lt;cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer" />
    &lt;/cfif>
    &lt;/cfquery>
    
    &lt;cfreturn getUser />
  &lt;/cffunction>
  
  &lt;cffunction name="login" returntype="boolean">
    &lt;cfargument name="emailAddress" type="string" required="true" />
    &lt;cfargument name="password" type="string" required="true" />
    
    &lt;cfset session = false />
    
    &lt;cfquery name="getUser" datasource="alpine">
    SELECT  userID, firstName, lastName, emailAddress,isAdmin
    FROM    users
    &lt;cfif arguments.emailAddress gt 0>
        WHERE   emailAddress = &lt;cfqueryparam value="#arguments.emailAddress#" cfsqltype="cf_sql_varchar" />
            and password = &lt;cfqueryparam value="#arguments.password#" cfsqltype="cf_sql_varchar" />
    &lt;/cfif>
    &lt;/cfquery>
    
    &lt;cfif getUser.recordcount>
        &lt;cfset success = true />
        &lt;cflock timeout=20 scope="Session" type="Exclusive">
            &lt;cfset session.userID = getUser.userID />
            &lt;cfset session.emailaddress = getUser.emailAddress />
            &lt;cfset session.fullname = "#getUser.firstName# #getUser.lastName#" />
            &lt;cfset session.isAdmin = getUser.isAdmin />
        &lt;/cflock>
    &lt;/cfif>
    
    &lt;cfreturn success />
  &lt;/cffunction>

  
&lt;/cfcomponent>
</pre>
<br>
<h2>header.cfm</h2>
<pre>
&lt;!DOCTYPE>
&lt;cfscript>
objUser = createObject('component','user');
&lt;/cfscript>
&lt;html>
    &lt;head>
        &lt;link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
        &lt;script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js" integrity="sha384-LtrjvnR4Twt/qOuYxE721u19sVFLVSA4hf/rRt6PrZTmiPltdZcI7q7PXQBYTKyf" crossorigin="anonymous">&lt;/script>
        &lt;style>
            pre{
                border:1px solid #000;
                background-color: #eee;
                padding:20px;
            }
        &lt;/style>
    &lt;/head>
    &lt;body>
        &lt;div class="container">
            &lt;br />
</pre>
<br>
<h2>footer.cfm</h2>
<pre>
&lt;/div>
&lt;/body>
&lt;/html>    
</pre>
<br>
<h2>register.cfm</h2>
<pre>
&lt;cfscript>
include 'header.cfm';
if(isDefined("form.firstName")){

  newUser = objUser.create(
    firstName=form.firstName, 
    lastName=form.lastName, 
    emailAddress=form.emailAddress,
    password=form.password
  );
}
if(isDefined("newUser") && newUser === true){
    writeOutput('&lt;div class="alert alert-success">Thank you for registering. You can &lt;a href="login.cfm">login now&lt;/a>.&lt;/div>');
}
&lt;/cfscript>

&lt;div class="alert alert-info">
    Welcome to User Account Registration. Please enter your contact information 
    below and then click the 'CREATE USER' button.
&lt;/div>

&lt;form action="register.cfm" method="post">
&lt;div class="container">
    &lt;div class="form-group">
        &lt;label for="firstName" class="control-label">First Name&lt;/label>
        &lt;input type="text" name="firstName" class="form-control" />
    &lt;/div>
    &lt;div class="form-group">
        &lt;label for="lastName" class="control-label">Last Name&lt;/label>
        &lt;input type="text" name="lastName" class="form-control" />
    &lt;/div>
    &lt;div class="form-group">
        &lt;label for="emailAddress" class="control-label">Email Address&lt;/label>
        &lt;input type="text" name="emailAddress" class="form-control" />
    &lt;/div>
    &lt;div class="form-group">
        &lt;label for="password" class="control-label">Password&lt;/label>
        &lt;input type="password" name="password" class="form-control" />
    &lt;/div>
    &lt;button class="btn btn-primary" name="submit">CREATE USER&lt;/button>
&lt;/div>
&lt;/form>
</pre>

<br>
<h2>login.cfm</h2>
<pre>
&lt;cfscript>
include 'header.cfm';
message = '';
success = false;

if(isDefined("form.submit")){

  // attempt logging in and then handle permissions and display messages
  loginAttempt = objUser.login(
    emailAddress=form.emailAddress,
    password=form.password
  );
  
  if(!structKeyExists(session,"userID") || session.userID === 0){
    message = "We're sorry we could not log you in. Please try again.";
    success = false;
  }
  
  if(isDefined("session") && structKeyExists(session,"userID")){
    message = "Welcome, &lt;strong>#session.fullName#&lt;/strong>!";
    success = true;
  
    // display success or error message 
    if(success===false && len(message)){
        writeOutput("&lt;div class='alert alert-danger'>#message#&lt;/div>");
    }  
    else if(success===true && len(message)){
        writeOutput("&lt;div class='alert alert-success'>#message#&lt;/div>");
    }
    
    if(session.isAdmin){
        include 'report.cfm';
    }
    else{
        include 'profile.cfm';
    }
  }
  
}
&lt;/cfscript>

&lt;cfif success eq false>
    &lt;div class="alert alert-info">
        Welcome! Please login below.&lt;br>&lt;br>
        Admin Login: admin@admin.com | admin&lt;br>&lt;br>
        Demo User: email@gmail.com | testing (or &lt;a href="register.cfm" target="_blank">Register for an Account!&lt;/a>
    &lt;/div>
    
    &lt;form action="login.cfm" method="post">
    &lt;div class="container">
        &lt;div class="form-group">
            &lt;label for="emailAddress" class="control-label">Email Address&lt;/label>
            &lt;input type="text" name="emailAddress" class="form-control" required="true" />
        &lt;/div>
        &lt;div class="form-group">
            &lt;label for="password" class="control-label">Password&lt;/label>
            &lt;input type="password" name="password" class="form-control" />
        &lt;/div>
        &lt;button class="btn btn-primary" name="submit" required="true">LOGIN&lt;/button>
    &lt;/div>
    &lt;/form>
&lt;/cfif>
</pre>
<br>
<h2>logout.cfm</h2>
<pre>
&lt;cfscript>
StructDelete(session,"userID");
&lt;/cfscript>

&lt;div class="alert alert-info">
    Would you like to &lt;a href="login.cfm">log back in&lt;/a>?
&lt;/div>   
</pre>
<br>
<h2>profile.cfm</h2>
<pre>
&lt;cfscript>
include 'header.cfm';
getUser = objUser.read(userID=session.userID);
&lt;/cfscript>

&lt;cfoutput query="getUser">
    &lt;h1>Profile&lt;/h1>
    Account Created on #dateTimeFormat(getUser.dateCreated,"medium")#&lt;br>
    First Name: #getUser.firstName# &lt;br>
    Last Name: #getUser.lastName# &lt;br>
    Email: #getUser.emailAddress# &lt;br>
&lt;/cfoutput>

&lt;cfinclude template="footer.cfm" />
</pre>
<br>
<h2>report.cfm</h2>
This User Account Repot is only available to users with isAdmin set to 1 in the users table.
<pre>
&lt;cfscript>
include 'header.cfm';
if(structKeyExists(session,"isAdmin") && session.isAdmin === 1){
    getUsers = objUser.read();
}
else{
    writeOutput('Sorry, you do not have permission. Please &lt;a href="login.cfm">login&lt;/a> using an admin account.');
    abort;
}
&lt;/cfscript>

&lt;h1>User Accounts Report&lt;/h1>
&lt;table class="table table-hover table-border table-striped">
&lt;tr>
  &lt;th>First Name&lt;/th>
  &lt;th>Last Name&lt;/th>
  &lt;th>Email Address&lt;/th>
&lt;/tr>
  
&lt;cfoutput query="getUsers">
  &lt;tr>
    &lt;td>#getUsers.firstName#&lt;/td>
    &lt;td>#getUsers.lastName#&lt;/td>
    &lt;td>#getUsers.emailAddress#&lt;/td>
  &lt;/tr>
&lt;/cfoutput>
&lt;/table>    
</pre>