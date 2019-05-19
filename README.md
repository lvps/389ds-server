# 389ds-server

This role installs the 389DS server (LDAP server) on the target machine(s).

This is a fork of a fork, still **work in progress**, not production ready.

## Features
- Install a single LDAP server
- Configure logging
- Add custom schema files
- Enable/disable any plugin
- Configure DNA plugin for UID/GID numbers
- Configure TLS
- Enforce TLS (minimum SSF and require secure binds) or go back to optional TLS
- Enable/disable LDAPI
- Enable/disable SASL PLAIN

## Requirements
- Ansible version: 2.7 or higher
- OS: CentOS 7
- Valid FQDN (hostname) is in place

## Role Variables

The variables that can be passed to this role and a brief description about them are as follows.

| Variable      | Default           | Description   | Can be changed |
|---------------|-------------------|---------------|----------------|
| dirsrv_suffix | dc=example,dc=com | Suffix of the DIT. All entries in the server will be placed under this suffix. Normally it's made from the domain components (*dc*) of your company main domain. E.g. if you're from example.co.uk and the server will be at ldap-server.example.co.uk, set the suffix to `dc=example,dc=co,dc=uk`, leaving out the subdomain part (`ldap-server`) since it's irrelevant. | **No**             |
| dirsrv_rootdn | cn=Directory Manager | Root DN, or "administrator" account username. Bind with this DN to bypass all authorization controls. | **No** |
| dirsrv_rootdn_password | | Password for root DN, you *must* define this variable or the role will fail. | **No** |
| dirsrv_fqdn | {{ansible_nodename}} | Server FQDN, e.g. `ldap.example.com`. If the server hostname is already an FQDN, the default should pick it up. | **No** |
| dirsrv_serverid | default | Server ID or instance ID. All the data related to the instance configured by this role will end up in /etc/dirsrv/slapd-*default*, /var/log/dirsrv/slapd-*default*, etc... You could use your company name, e.g. for Foo Bar, Inc set the variable to `foobar` and the directories will be named slapd-foobar. | **No** |
| dirsrv_install_examples | false | Create example entries under the suffix during installation | **No** |
| dirsrv_install_additional_ldif | [] | Install these additional LDIF files, by default none (empty array). This corresponds to the `InstallLdifFile` directive in the inf installation file. | **No** |
| dirsrv_logging | see below | see below | Yes |
| dirsrv_plugins_enabled | {} | Enable or disable plugins, see below for details. By default not plugins are enabled or disabled. | Yes |
| dirsrv_dna_plugin | see below | Configuration for the DNA (Distributed Numeric Assignment) plugin. | Yes |
| dirsrv_custom_schema | [] | Paths to custom schema files. They will be dropped into `/etc/dirsrv/slapd-{{ dirsrv_serverid }}/schema` and a schema reload will be request when anything chages. | Yes |
| dirsrv_allow_other_schema_files | false | If false (default value), this role will add the specified schema files to `/etc/dirsrv/slapd-{{ dirsrv_serverid }}/schema`, then delete all other schema files there except `99user.ldif`. If your schema files are managed only by this role or dynamically (i.e. from `cn=schema`, which writes to `99user.ldif`), you can leave this variable to its default of false. If you have more schema files in that directory (added manually or by other tasks), set this to true to leave them there. The downside is that if you deploy e.g. `50example.ldif`, then you rename it to `50my_example.ldif`, when the role runs again it considers it a new file and leaves the previous one there, wreaking havoc on your directory. | Yes |
dirsrv_tls_enabled | false | Enable TLS (LDAPS and StartTTLS). All "dirsrv_tls" only take effect if this is enabled. | Yes |
dirsrv_tls_min_version | '1.2' | Minimum TLS version: 1.0, 1.1 or 1.2. Possibly even 1.3, when support is added to 389DS. SSLv2 and SSLv3 are always disabled by this role. | Yes |
dirsrv_tls_certificate_trusted | true | The server certificate is publicly trusted. Set to false if it's self-signed or from a private CA. | Yes |
dirsrv_tls_enforced | false | Enforce TLS by requiring secure binds and minimum SSF | Yes |
dirsrv_tls_minssf | 256 | Minimum SSF, used only when dirsrv_tls_enforced is true. 128 seems reasonable, 256 should be very secure. Set this to 0 to enforce TLS only with secure binds. | Yes |
dirsrv_allow_anonymous_binds | 'rootdse' | Allow anonymous binds: boolean true for Yes, boolean false for No, or 'rootdse'. The Administration Guide suggests to use rootdse instead of No, because it allows anonymous binds to search some data that clients may require before doing a bind. Allowing anonymous binds basically makes your directory public, unless you restrict access with ACIs. | Yes |
dirsrv_simple_auth_enabled | true | Enable SIMPLE authentication, probably true unless you want to use SASL PLAIN only or configure other methods manually. | Yes |
dirsrv_sasl_enabled | false | Enable SASL authentication. | Yes |
dirsrv_password_storage_scheme | [] | A single value, possibly the string "PBKDF2_SHA256". Or leave the default, which will delete any custom value and use 389DS default, which should be pretty secure. | Yes |
dirsrv_ldapi_enabled | false | Enable LDAPI (connect to the server via a UNIX socket at `ldapi:///var/run/slapd-{{ dirsrv_serverid }}.socket`). Note that this is subject to TLS enforcing and TLS is not supported, so it's useless if you set dirsrv_tls_enforced to true. | Yes |
dirsrv_sasl_plain_enabled | true | Enable SASL PLAIN authentication: if a client tries to authenticate without TLS and TLS is enforced, this kind of authentication should stop it before it sends the plaintext password, while a SIMPLE bind will send the password and then fail because SSF is too low. | Yes |

Some variables cannot be changed by this role (or at all) after creating an instance of 389DS. If one of them is changed and the role is applied again, undefined behaviour ranging from "nothing" to "the role fails" to "another instance is created" may happen. Some of them, e.g. the root DN password, can be changed manually: please refer to the [Administration Guide](https://access.redhat.com/documentation/en-us/red_hat_directory_server/10/html/administration_guide/index) for details.

All variables are prefixed with dirsrv because starting a variable with a number ("389ds") doesn't work, usually.

### dirsrv_logging

This is the default variable:

```yaml
dirsrv_logging:
  audit:
    enabled: false
    logrotationtimeunit: day
    logmaxdiskspace: 400
    maxlogsize: 200
    maxlogsperdir: 7
    mode: 600
  access:
    enabled: true
    logrotationtimeunit: day
    logmaxdiskspace: 400
    maxlogsize: 200
    maxlogsperdir: 7
    mode: 600
  error:
    enabled: true
    logrotationtimeunit: day
    logmaxdiskspace: 400
    maxlogsize: 200
    maxlogsperdir: 7
    mode: 600
```

Ansible doesn't merge dicts by default, i.e. if you want to change only audit > enabled to true you have to define all the other variables too. If you want to change the defaults, it's probably a good idea to copy this entire block into the variables and tweak what you need.

### dirsrv_plugins_enabled

If you want to enable the memberof plugin located at `cn=MemberOf Plugin,cn=plugins,cn=config`, set the variable to:

```yaml
plugins_enabled:
  MemberOf Plugin: true
```

If it's enabled and you want to disable it, set it to:

```yaml
plugins_enabled:
  MemberOf Plugin: false
```

If you want to enable more plugins:

```yaml
plugins_enabled:
  MemberOf Plugin: true
  Distributed Numeric Assignment Plugin: true
```

If a plugin doesn't appear in the list, it's left in its current status.

A plugin named Foo should have an entry under `cn=Foo,cn=plugins,cn=config`, you can look at the `cn=plugins,cn=config` tree to see which plugins are available and their status.

### dirsrv_dna_plugin

Default value:

```yaml
dirsrv_dna_plugin:
  gid_min: 2000
  gid_max: 2999
  uid_min: 2000
  uid_max: 2999
```

Ansible doesn't merge dicts by default, i.e. if you want to change only uid_max and gid_max you have to define the \_min variables too. When you define dna_plugin, it replaces this default dict entirely.

This configuration is only applied if "Distributed Numeric Assignment Plugin" is true in plugins_enabled, and is removed when it is false. If it's not mentioned, nothing is done.

## Dependencies

None.

## Usage and Examples

This section still needs to be reviewed...

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

### Configure firewall

Not part of this role, but still quite easy:

```yaml
- name: Allow ldap port on firewalld
  firewalld: service=ldap permanent=true state=enabled
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

## Tests

This role uses molecule for its tests. Install it with pipenv (pip probably works, too) and test all the scenarios:

```shell
pipenv install
pipenv shell
molecule test --all
```

## TODO

### Probably will be done
- Support for CentOS 8 when it comes out

### Could be done not planned for the short term
- Support for Debian/Ubuntu/FreeBSD or any other platform that 389DS supports
- Support for other plugins that need more than enabled/disabled
- Support for other DNA attributes

## License

Apache 2.0

## Author Information

Modified by: lvps  
Modified by: Colby Prior  
Original author: Artemii Kropachev
