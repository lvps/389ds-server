# 389ds-server
This role installs the 389DS server (LDAP server) on the target machine(s).

This is a fork of a fork, still **work in progress**, not production ready.

## Features
- Configuring single LDAP server
- Configuring logging
- Configuring MemberOf and DNA plugin
- Configuring TLS

Also: replication. I Will move it to another role, probably.

## TODO
- Support for other plugins
- Support for CentOS 8

### Could be done but not planned for the short term
- Administration Server (and Configuration Directory Server)
- Support for Debian/Ubuntu/FreeBSD or any other platform that 389DS supports

## Requirements
- Ansible version: 2.5 or higher
- OS: RHEL 7.x, CentOS 7.x
- Valid FQDN (hostname) is in place

## Role Variables
The variables that can be passed to this role and a brief description about them are as follows:
```
# TODO: rewrite this section
```

## Installation (CentOS 7.x or RHEL 7.x)
```
# yum install -y git ansible
# mkdir -p /etc/ansible/roles
# cd /etc/ansible/roles
# git clone https://github.com/lvps/389ds-server.git
# vi /etc/ansible/hosts
```
## Usage and Examples

### Configure a single 389-server on the targed machine(s):
If variables are not set in the yaml file, default values will be used.

For a base install only two variables must be specified since they have no
defaults: `suffix` and `rootdn_password`. The server will start on port 389,
with root DN `cn=Directory Manager`.

```yaml
	- hosts: all
    become: true
    roles:
      - {
          role: 389ds-server,
          suffix: "dc=example,dc=local",
          rootdn_password: secret
        }
```

Variables can also be passed via CLI:

```
ansible-playbook -e 'password:secret' ldap.yaml
```

### Configuring single replication master
```yaml
---
- hosts: ldapserver1
  roles:
     - { role: 389ds-server, rwmaster: true, replica_host: ldap96.example.com }
```
It is assumed that replica hostname is known before configuring rwmaster.

### Configuring master->slave replications
```yaml
---
- hosts: ldapserver2
  roles:
     - { role: 389ds-server, roreplica: true }

- hosts: ldapserver1
  roles:
     - { role: 389ds-server, rwmaster: true, replica_host: ldap96.example.com }
```
Note! it is important to configure roreplica before rwmaster.
If the order is wrong you can fix the problem by re-runing the syncronization process as shown below:
- connect to rwmaster (master LDAP server)
- Find agreement information in LDAP server configuration:
```
$ ldapsearch -x -D cn=root -wAdmin123 -b cn=config objectClass=nsds5replicationagreement'
```
you will have something like:
```
# ExampleAgreement, replica, dc\3Dexample\2Cdc\3Dcom, mapping tree, con
 fig
dn: cn=ExampleAgreement,cn=replica,cn=dc\3Dexample\2Cdc\3Dcom,cn=mappi
 ng tree,cn=config
objectClass: top
objectClass: nsds5replicationagreement
cn: ExampleAgreement
nsDS5ReplicaHost: ldap96.example.com
nsDS5ReplicaPort: 389
nsDS5ReplicaBindDN: cn=replmanager,cn=config
nsDS5ReplicaBindMethod: SIMPLE
nsDS5ReplicaRoot: dc=example,dc=com
description: Agreement between ldap95.example.com and ldap96.example.com
nsDS5ReplicaUpdateSchedule: 0001-2359 0123456
nsDS5ReplicatedAttributeList: (objectclass=*) $ EXCLUDE authorityRevocationLis
 t
nsDS5ReplicaCredentials: {AES-TUhNR0NTcUdTSWIzRFFFRkRUQm1NRVVHQ1NxR1NJYjNEUUVG
 RERBNEJDUmhOR0kyWlRBMU9TMWpPRE5qTXpCaA0KTmkxaFptTXdNbU13TnkwellUQXpNRFZpTVFBQ
 0FRSUNBU0F3Q2dZSUtvWklodmNOQWdjd0hRWUpZSVpJQVdVRA0KQkFFcUJCQllKMUZ5cVNUK25YSU
 tVRXVuR3FKbA==}bSvopZmv0sFDa11fJ03dKQ==
nsds5replicareapactive: 0
nsds5replicaLastUpdateStart: 19700101000000Z
nsds5replicaLastUpdateEnd: 19700101000000Z
nsds5replicaChangesSentSinceStartup:
nsds5replicaLastUpdateStatus: 402 Replication error acquiring replica: unknown
  error - Replica has different database generation ID, remote replica may nee
 d to be initialized
nsds5replicaUpdateInProgress: FALSE
nsds5replicaLastInitStart: 20160802124732Z
nsds5replicaLastInitEnd: 19700101000000Z
nsds5replicaLastInitStatus: -1  - LDAP error: Can't contact LDAP server
```
- Re-Start Sync proccess by
```
$ ldapmodify -D cn=root -w YOUR_PASSWORD
dn: cn=ExampleAgreement,cn=replica,cn="dc=example,dc=com",cn=mapping tree,cn=config
changetype: modify
replace: nsds5BeginReplicaRefresh
nsds5BeginReplicaRefresh: start
<CTRL + D>
```

### Configuring multi-slaves
```yaml
---

- hosts: ldapslaves
  roles:
     - { role: 389ds-server, roreplica: true }

- hosts: ldapmaster
  roles:
     - { role: 389ds-server, rwmaster: true, replica_host: ldap96.example.com, agreement_name: agreement1 }
     - { role: 389ds-server, rwmaster: true, replica_host: ldap97.example.com, agreement_name: agreement2, skip_config: true }
     - { role: 389ds-server, rwmaster: true, replica_host: ldap98.example.com, agreement_name: agreement3, skip_config: true}
```

## Author Information

Modified by: lvps  
Modified by: Colby Prior  
Original author: Artemii Kropachev
