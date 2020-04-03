## Helix Security

### Authentication and Authorization

Helix Sandbox doesn't provide "native" authentication nor any authorization mechanisms to enforce access control of data. 

However, authentication/authorization can be achieved the [access control framework](https://forge.fiware.org/plugins/mediawiki/wiki/fiware/index.php/FIWARE.ArchitectureDescription.Security.Access_Control_Generic_Enabler) provided by FIWARE GEs.

More specifically, Orion is integrated in this framework using the FIWARE PEP Proxy GE. At the present moment, there are two GE implementations (GEis) that can work with Orion Context Broker:

[Wilma](https://fiware-pep-proxy.readthedocs.io/en/latest/user_guide/) (the GE reference implementation)

