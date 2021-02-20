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