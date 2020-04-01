## Helix Security

### Authentication and Authorization

Helix Sandbox doesn't provide "native" authentication nor any authorization mechanisms to enforce access control of data. 

However, authentication/authorization can be achieved the [access control framework](https://forge.fiware.org/plugins/mediawiki/wiki/fiware/index.php/FIWARE.ArchitectureDescription.Security.Access_Control_Generic_Enabler) provided by FIWARE GEs.

More specifically, Orion is integrated in this framework using the FIWARE PEP Proxy GE. At the present moment, there are two GE implementations (GEis) that can work with Orion Context Broker:

[Wilma](https://fiware-pep-proxy.readthedocs.io/en/latest/user_guide/) (the GE reference implementation)

### Database authorization

MongoDB authorization is configured with the -db, -dbuser and -dbpwd options (see section on command line options). 
There are a few different cases to take into account:

#### Doesn't use authorization
Then do not use the -dbuser and -dbpwd options.
    
#### Uses authorization
If you run Orion in single service/tenant mode (i.e. without -multiservice) then you are using only one database (the one specified by the -db option) and the authorization is done with -dbuser and -dbpwd in that database.

If you run Orion in multi service/tenant mode (i.e. with -multiservice) then the authorization is done at admin database using -dbuser and -dbpwd. As described later in this document, in multi service/tenant mode, Orion uses several databases (which in addition can potentially be created on the fly), thus authorizing on admin DB ensures permissions in all of them.
