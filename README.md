# 389-ldap-server
This role installs the 389-server (LDAP server)  on the target machine(s).

## Features
- Configuring single LDAP server
- Repcation support:
  - Configuring replication supplier
  - Configuring replication consumer
  - Multi slaves replications

## ToDo
- Multi-Master replication support
- Hub support
- Configuration speed improvements
- Advanced configuration support

## Requirements
- Ansible version: 1.4 or higher
- OS: RHEL 7.x, CentOS 7.x
- Valid FQDN (hostname) is in place

## Role Variables
The variables that can be passed to this role and a brief description about them are as follows:
```
    ldap_password: Admin123
    ldap_suffix: dc=example,dc=com
    ldap_rootdn: cn=root
    serverid: ldapsrv

    admin_password: Admin123
    admin_domain: example.com

    enable_replication_supplier: false
    replication_nsds5replicaid: 7
    replication_agreement_name: ExampleAgreement
    replication_consumer_host: consumer.example.com

    enable_replication_consumer: false
    replication_user: replmanager
    replication_user_password: Admin123
```

## Installation (CentOS 7.x or RHEL 7.x)
```
# yum install -y git ansible
# mkdir -p /etc/ansible/roles
# cd /etc/ansible/roles
# git clone https://github.com/neoncyrex/389-ldap-server.git
# vi /etc/ansible/hosts
```
## Usage and Examples

### 1. Configure a single 389-server on the targed machine(s):
If variables are not set in the yaml file - default values will be used
> $ cat ldap.yaml
```
	- hosts: all
	  sudo: true
          roles:
		- { role: 389-ldap-server }
```
> $ ansible-playbook ldap.yaml

### 2. Configure a single 389-server on the targed machine(s) (variables in playbook):

> $ cat ldap.yaml
```
	- hosts: all
	  sudo: true
          roles:
		- { role: 389-ldap-server, admin_password: secret, ldap_suffix="dc=example,dc=com" }
```
> $ ansible-playbook ldap.yaml


### 3. Configure a single 389-server on the targed machine(s) (variables in CLI):

> $ cat ldap.yaml
```
	- hosts: all
          sudo: true
          roles:
		- 389-ldap-server
```
> $ ansible-playbook -e 'admin_domain=example.com admin_password:secret' ldap.yaml

### 4. Configuring single replication master
```
---
- hosts: ldapserver1
  roles:
     - { role: 389-ldap-server, enable_replication_supplier: true, replication_consumer_host: ldap96.example.com }
```
It is assumed that consumer hostname is known before configuring supplier.

### 5. Configuring master->slave replications
```
---
- hosts: ldapserver2
  roles:
     - { role: 389-ldap-server, enable_replication_consumer: true }

- hosts: ldapserver1
  roles:
     - { role: 389-ldap-server, enable_replication_supplier: true, replication_consumer_host: ldap96.example.com }
```
Note! it is important to configure consumer(slave) before supplier (master).
If the order is wrong you can fix the problem by re-runing the syncronization process as shown below:
- connect to supplier (master LDAP server)
- Find agreement information in LDAP server configuration:
```
$ ldapsearch -x -D cn=root -wAdmin123 -b cn=config objectClass=nsds5replicationagreement'
```
you will have something like:
```
# ExampleAgreement, supplierreplica, dc\3Dexample\2Cdc\3Dcom, mapping tree, con
 fig
dn: cn=ExampleAgreement,cn=supplierreplica,cn=dc\3Dexample\2Cdc\3Dcom,cn=mappi
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
$ ldapmodify -D cn=root -wYOUR_PASSWORD
dn: cn=ExampleAgreement,cn=supplierreplica,cn="dc=example,dc=com",cn=mapping tree,cn=config
changetype: modify
replace: nsds5BeginReplicaRefresh
nsds5BeginReplicaRefresh: start
<CTRL + D>
```

### 5. Configuring multi-slaves
```
---

- hosts: ldapslaves
  roles:
     - { role: 389-ldap-server, enable_replication_consumer: true }

- hosts: ldapmaster
  roles:
     - { role: 389-ldap-server, enable_replication_supplier: true, replication_consumer_host: ldap96.example.com, replication_agreement_name: agreement1 }
     - { role: 389-ldap-server, enable_replication_supplier: true, replication_consumer_host: ldap97.example.com , replication_agreement_name: agreement2}
     - { role: 389-ldap-server, enable_replication_supplier: true, replication_consumer_host: ldap98.example.com , replication_agreement_name: agreement3}
```

## Author Information
Name: Artemii Kropachev
