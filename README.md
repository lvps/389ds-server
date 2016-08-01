389-ldap-server
===============

This role installs the 389-server (LDAP server)  on the target machine(s).

Requirements
------------
This role requires Ansible 1.4 or higher. 
Currently it supports only Red Hat-based systems with systemd  (RHEL 7.x, CentOS 7.x).
It is assumed that proper hostname is configured and resolving works fine.

Role Variables
--------------

The variables that can be passed to this role and a brief description about
them are as follows:

    admin_password: Admin123                  # Administration server password (user admin)
    admin_domain: example.com                 # Admin domain
    ldap_password: Admin123                   # This is the password for admin for LDAP server
    ldap_suffix: dc=example,dc=com            # The domain prefix for ldap
    ldap_rootdn: cn=root                      # This is rootdn for admin for LDAP server
    serverid: ldapsrv                         # dirsrv service 
    replication_password: Admin123



Examples
--------

1. Configure an 389-server on the targed machine (variables in playbook):
\$ cat ldap.yaml
    - hosts: all
      sudo: true
      roles:
      - { role: 389-ldap-server, admin_domain: example.com, admin_password: secret }

\$ ansible-playbook ldap.yaml

2. Configure an 389-server on the targed machine (variables in CLI):
\$ cat ldap.yaml
    - hosts: all
      sudo: true
      roles:
      - 389-ldap-server

\$ ansible-playbook -e 'admin_domain=example.com admin_password:secret' ldap.yaml


Author Information
------------------

Artemii Kropachev
