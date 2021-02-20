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