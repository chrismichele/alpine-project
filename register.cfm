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