# alpine-project

## index.cfm
You can view an overview of all files in the index.cfm file.

## create.sql
This database and table were created and tested using MySQL.
```markdown
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
```

## user.cfc
```markdown
<cfcomponent displayname="User Component" output="false">

  <cffunction name="create" returntype="boolean">

    <cfargument name="firstName" type="string" required="true" />
    <cfargument name="lastName" type="string" required="true" />
    <cfargument name="emailAddress" type="string" required="true" />
    <cfargument name="password" type="string" required="true" />
    
    <cfset success = true />
    
    <cftry>  
    <cfquery name="insertUser" datasource="alpine">
    INSERT INTO users (firstName, lastName, emailAddress, password)
    VALUES (<cfqueryparam value="#arguments.firstName#" cfsqltype="CF_SQL_VARCHAR" />,
      <cfqueryparam value="#arguments.lastName#" cfsqltype="CF_SQL_VARCHAR" />,
      <cfqueryparam value="#arguments.emailAddress#" cfsqltype="CF_SQL_VARCHAR" />,
      <cfqueryparam value="#arguments.password#" cfsqltype="CF_SQL_VARCHAR" />)
    </cfquery>
    
    <cfcatch type="any">
        <cfdump var="#cfcatch#" />
        <cfset success = false />
    </cfcatch>
    </cftry>
    
    <cfreturn success />
  </cffunction>
    
  <cffunction name="read" returntype="query">
    <cfargument name="userID" type="numeric" required="false" default="0" />
    
    <cfquery name="getUser" datasource="alpine">
    SELECT  firstName, lastName, emailAddress, dateCreated, isAdmin
    FROM    users
    <cfif arguments.userID gt 0>
        WHERE   userID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer" />
    </cfif>
    </cfquery>
    
    <cfreturn getUser />
  </cffunction>
  
  <cffunction name="login" returntype="boolean">
    <cfargument name="emailAddress" type="string" required="true" />
    <cfargument name="password" type="string" required="true" />
    
    <cfset session = false />
    
    <cfquery name="getUser" datasource="alpine">
    SELECT  userID, firstName, lastName, emailAddress,isAdmin
    FROM    users
    <cfif arguments.emailAddress gt 0>
        WHERE   emailAddress = <cfqueryparam value="#arguments.emailAddress#" cfsqltype="cf_sql_varchar" />
            and password = <cfqueryparam value="#arguments.password#" cfsqltype="cf_sql_varchar" />
    </cfif>
    </cfquery>
    
    <cfif getUser.recordcount>
        <cfset success = true />
        <cflock timeout=20 scope="Session" type="Exclusive">
            <cfset session.userID = getUser.userID />
            <cfset session.emailaddress = getUser.emailAddress />
            <cfset session.fullname = "#getUser.firstName# #getUser.lastName#" />
            <cfset session.isAdmin = getUser.isAdmin />
        </cflock>
    </cfif>
    
    <cfreturn success />
  </cffunction>

  
</cfcomponent>
```

## header.cfm
```markdown
<!DOCTYPE>
<cfscript>
objUser = createObject('component','user');
</cfscript>
<html>
    <head>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js" integrity="sha384-LtrjvnR4Twt/qOuYxE721u19sVFLVSA4hf/rRt6PrZTmiPltdZcI7q7PXQBYTKyf" crossorigin="anonymous"></script>
        <style>
            pre{
                border:1px solid #000;
                background-color: #eee;
                padding:20px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <br />
```

## footer.cfm
```markdown
</div>
</body>
</html>    
```

## register.cfm
```markdown
<cfscript>
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
    writeOutput('<div class="alert alert-success">Thank you for registering. You can <a href="login.cfm">login now</a>.</div>');
}
</cfscript>

<div class="alert alert-info">
    Welcome to User Account Registration. Please enter your contact information 
    below and then click the 'CREATE USER' button.
</div>

<form action="register.cfm" method="post">
<div class="container">
    <div class="form-group">
        <label for="firstName" class="control-label">First Name</label>
        <input type="text" name="firstName" class="form-control" />
    </div>
    <div class="form-group">
        <label for="lastName" class="control-label">Last Name</label>
        <input type="text" name="lastName" class="form-control" />
    </div>
    <div class="form-group">
        <label for="emailAddress" class="control-label">Email Address</label>
        <input type="text" name="emailAddress" class="form-control" />
    </div>
    <div class="form-group">
        <label for="password" class="control-label">Password</label>
        <input type="password" name="password" class="form-control" />
    </div>
    <button class="btn btn-primary" name="submit">CREATE USER</button>
</div>
</form>
```

## login.cfm
```markdown
<cfscript>
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
    message = "Welcome, <strong>#session.fullName#</strong>!";
    success = true;
  
    // display success or error message 
    if(success===false && len(message)){
        writeOutput("<div class='alert alert-danger'>#message#</div>");
    }  
    else if(success===true && len(message)){
        writeOutput("<div class='alert alert-success'>#message#</div>");
    }
    
    if(session.isAdmin){
        include 'report.cfm';
    }
    else{
        include 'profile.cfm';
    }
  }
  
}
</cfscript>

<cfif success eq false>
    <div class="alert alert-info">
        Welcome! Please login below.<br><br>
        Admin Login: admin@admin.com | admin<br><br>
        Demo User: email@gmail.com | testing (or <a href="register.cfm" target="_blank">Register for an Account!</a>
    </div>
    
    <form action="login.cfm" method="post">
    <div class="container">
        <div class="form-group">
            <label for="emailAddress" class="control-label">Email Address</label>
            <input type="text" name="emailAddress" class="form-control" required="true" />
        </div>
        <div class="form-group">
            <label for="password" class="control-label">Password</label>
            <input type="password" name="password" class="form-control" />
        </div>
        <button class="btn btn-primary" name="submit" required="true">LOGIN</button>
    </div>
    </form>
</cfif>
```

## logout.cfm
```markdown
<cfscript>
StructDelete(session,"userID");
</cfscript>

<div class="alert alert-info">
    Would you like to <a href="login.cfm">log back in</a>?
</div>   
```

## profile.cfm
```markdown
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
```

## report.cfm
This User Account Repot is only available to users with isAdmin set to 1 in the users table.
```markdown
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
```
