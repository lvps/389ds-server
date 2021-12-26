# 389ds-server

[![Build Status](https://travis-ci.com/lvps/389ds-server.svg?branch=master)](https://travis-ci.com/lvps/389ds-server)
[![Ansible Galaxy](https://img.shields.io/ansible/role/40529.svg)](https://galaxy.ansible.com/lvps/389ds-server)

This role installs the 389DS server (LDAP server) on the target machine(s).

```shell
ansible-galaxy install lvps.389ds_server
```

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

Replication is managed with [another role](https://github.com/lvps/389ds-replication).

## Requirements

- Ansible 2.10 or newer, for Ansible 2.8 and 2.9 use the 3.1.x releases of this role
- CentOS 7 or CentOS 8 or other RHEL based OS

## Role Variables

The variables that can be passed to this role and a brief description about them are as follows.

#### dirsrv_product
Default: OS dependent · Can be changed: **No**

There are two main branches. The free **389 Directory Server** and the supported **Red Hat Directory Server**. With the free releases you can trust on the default setting. Otherwise you can configure this value for your need. At the moment the only non default value tested is  `'@redhat-ds:11'` for the Red Hat Directory Server 11, available in Red Hat EL8 OS.

#### dirsrv_port
Default: `389` · Can be changed: **No**

The port where the 389ds listen.

#### dirsrv_suffix
Default: `dc=example,dc=com` · Can be changed: **No**

Suffix of the DIT. All entries in the server will be placed under this suffix. Normally it's made from the domain components (*dc*) of your company main domain. E.g. if you're from example.co.uk and the server will be at ldap-server.example.co.uk, set the suffix to `dc=example,dc=co,dc=uk`, leaving out the subdomain part (`ldap-server`) since it's irrelevant.

#### dirsrv_bename
Default: `userRoot` · Can be changed: **No**

internal database name of the suffix.

#### dirsrv_othersuffixes
Default: `[]` · Can be changed: **No**

List of other suffixes dicts in the form `{ name: <bename>, dn: <rootDN>}`

#### dirsrv_rootdn
Default: `cn=Directory Manager` · Can be changed: **No**

Root DN, or "administrator" account username. Bind with this DN to bypass all authorization controls.

#### dirsrv_rootdn_password
Can be changed: **No**

Password for root DN, you *must* define this variable or the role will fail.

#### dirsrv_fqdn
Default: `{{ansible_nodename}}` · Can be changed: **No**

Server FQDN, e.g. `ldap.example.com`. If the server hostname is already an FQDN, the default should pick it up.

#### dirsrv_serverid
Default: `default` · Can be changed: ¹

Server ID or instance ID. All the data related to the instance configured by this role will end up in /etc/dirsrv/slapd-*default*, /var/log/dirsrv/slapd-*default*, etc... You could use your company name, e.g. for Foo Bar, Inc set the variable to `foobar` and the directories will be named slapd-foobar.

#### dirsrv_listen_host
Can be changed: Yes

Listen on these addresses/hostnames. If not set (default) does nothing, if set to a string will set the `nsslapd-listenhost` attribute. Set to `[]` to delete the attribute.

#### dirsrv_secure_listen_host
Can be changed: Yes

Same as dirsrv_listen_host but for LDAPS. If not set (default) does nothing, if set to a string will set the `nsslapd-securelistenhost` attribute. Set to `[]` to delete the attribute.

#### dirsrv_server_uri
Default: `ldap://localhost` · Can be changed: ¹

Server URI for tasks that connect via LDAP. Since tasks are running on the same server as 389DS, this will be localhost in most cases, no need to customize it.

#### dirsrv_factory
Default: `false` · Can be changed: Yes

Keep factory defaults about authentication and logging parameters. If `true`, `dirsrv_logging`, `dirsrv_simple_auth_enabled`, `dirsrv_password_storage_scheme`, `dirsrv_ldapi_enabled`, `dirsrv_sasl_plain_enabled` will be completely ignored.

#### dirsrv_install_examples
Default: `false` · Can be changed: **No**

Create example entries under the suffix during installation

#### dirsrv_install_additional_ldif
Default: `[]` · Can be changed: **No**

Install these additional LDIF files, by default none (empty array). This corresponds to the `InstallLdifFile` directive in the inf installation file for 389DS <= 1.3. From 1.4 onward, this is done via dsconf.

#### dirsrv_install_additional_ldif_dir
Default: `/var/lib/dirsrv/slapd-{{ dirsrv_serverid }}/ldif` · Can be changed: **No**

Directory where ldif files for dirsrv_install_additional_ldif are temporarily stored. Cannot be /tmp as 389DS service has systemd PrivateTmp set to true from CentOS/RHEL 8.3.

#### dirsrv_logging
Default: see below · Can be changed: Yes

See below

#### dirsrv_plugins_enabled
Default: `{}` · Can be changed: Yes

Enable or disable plugins, see below for details. By default no plugins are enabled or disabled.

#### dirsrv_dna_plugin
Default: see below · Can be changed: Yes

Configuration for the DNA (Distributed Numeric Assignment) plugin.

#### dirsrv_custom_schema
Default: `[]` · Can be changed: Yes

Paths to custom schema files. They will be dropped into `/etc/dirsrv/slapd-{{ dirsrv_serverid }}/schema` and a schema reload will be request when anything chages.

#### dirsrv_allow_other_schema_files
Default: `false` · Can be changed: Yes

If false (default value), this role will add the specified schema files to `/etc/dirsrv/slapd-{{ dirsrv_serverid }}/schema`, then delete all other schema files there except `99user.ldif`. If your schema files are managed only by this role or dynamically (i.e. from `cn=schema`, which writes to `99user.ldif`), you can leave this variable to its default of false. If you have more schema files in that directory (added manually or by other tasks), set this to true to leave them there. The downside is that if you deploy e.g. `50example.ldif`, then you rename it to `50my_example.ldif`, when the role runs again it considers it a new file and leaves the previous one there, wreaking havoc on your directory.

#### dirsrv_tls_enabled
Default: `false` · Can be changed: Yes

Enable TLS (LDAPS and StartTTLS). All "dirsrv_tls" variables have effect only if this is enabled.

#### dirsrv_tls_min_version
Default: `'1.2'` · Can be changed: Yes

Minimum TLS version: 1.0, 1.1 or 1.2. Possibly even 1.3, if supported by your 389DS version. SSLv2 and SSLv3 are always disabled by this role.

#### dirsrv_tls_certificate_trusted
Default: `true` · Can be changed: Yes

The server certificate is publicly trusted. Set to false only in development (for self-signed certificates)!

#### dirsrv_tls_enforced
Default: `false` · Can be changed: Yes

Enforce TLS by requiring secure binds and minimum SSF

#### dirsrv_tls_minssf
Default: `256` · Can be changed: Yes

Minimum SSF, used *only when dirsrv_tls_enforced is true*. 128 seems reasonable, 256 should be very secure. Set this to 0 to enforce TLS only with secure binds.

#### dirsrv_allow_anonymous_binds
Default: `'rootdse'` · Can be changed: Yes

Allow anonymous binds: boolean true for Yes, boolean false for No, or 'rootdse'. The Administration Guide suggests to use rootdse instead of No, because it allows anonymous binds to search some data that clients may require before doing a bind. Allowing anonymous binds basically makes your directory public, unless you restrict access with ACIs.

#### dirsrv_simple_auth_enabled
Default: `true` · Can be changed: Yes

Enable SIMPLE authentication, probably true unless you want to use SASL PLAIN only or configure other methods manually.

#### dirsrv_password_storage_scheme
Default: `[]` · Can be changed: Yes

A single value, possibly the string "PBKDF2_SHA256". Or leave the default, which will delete any custom value and use 389DS default, which should be pretty secure.

#### dirsrv_ldapi_enabled
Default: `false` · Can be changed: Yes

Enable LDAPI (connect to the server via a UNIX socket at `ldapi:///var/run/dirsrv/slapd-{{ dirsrv_serverid }}.socket`). Note that this is subject to TLS enforcing and TLS is not supported, so it's useless if you set dirsrv_tls_enforced to true.

#### dirsrv_sasl_plain_enabled
Default: `true` · Can be changed: Yes

Enable SASL PLAIN authentication: if a client tries to authenticate without TLS and TLS is enforced, this kind of authentication should stop it before it sends the plaintext password, while a SIMPLE bind will send the password and then fail because SSF is too low.

### Variables exclusive to 389DS version 1.4.X

These variables only affect on installations of 389DS version 1.4.X and have no effect on previous versions even if defined.

#### dirsrv_defaults_version
Default: `999999999`² · Can be changed: **No**

The defaults configuration values will be the ones of the specified version of 389DS. The format is XXXYYYZZZ, where XXX is the major version, YYY is the minor version and ZZZ is the patch level (all three values are padded with zeros to the length of three). If 999999999 is selected, the latest version of the defaults will be used.

#### dirsrv_selfsigned_cert
Default: `True`² · Can be changed: **No**

Determines wether 389DS will generate a self-signed certificate and enable TLS automatically.

#### dirsrv_selfsigned_cert_duration
Default: `24`² · Can be changed: **No**

Validity in months of the self-signed certificate generated by 389DS.

#### dirsrv_create_suffix_entry
Default: `False`² · Can be changed: **No**

Determines wether 389DS will generate a suffix entry in the directory with the given suffix: `cn={{ dirsrv_suffix }}`

#### dirsrv_rundir
Can be changed: **No**

If defined, configure a specific path for `db_home_dir`.

#### dirsrv_rundir
Can be changed: **No**

If defined, configures a specific path for `run_dir`.

### Interoperability between 1.3.X and 1.4.X

To have a playook that behaves in the same way on 1.3 and 1.4 verions of 389DS, the following values should be used:

| Variable                        | Value                |
|---------------------------------|----------------------|
| dirsrv_defaults_version         | 001004002³           |
| dirsrv_selfsigned_cert          | False                |
| dirsrv_create_suffix_entry      | True                 |

### Notes

Some variables cannot be changed by this role (or at all) after creating an instance of 389DS. If one of them is changed and the role is applied again, undefined behaviour ranging from "nothing" to "the role fails" may happen. Some of them, e.g. the root DN password, can be changed manually: please refer to the [Administration Guide](https://access.redhat.com/documentation/en-us/red_hat_directory_server/10/html/administration_guide/index) for details.

¹ Changing this variable from a previous run will lead to the creation of another instance, another directory completely separated from the previous one, which should work fine if that's your goal.

² These are the default values as of 389DS version 1.4.2.15 and may change for later versions: run `dscreate create-template` in your machine to see the default for the current version.

³ This is the version of defaults on top of which this role has been written and validated. Setting the `dirsrv_defaults_version` is not technically required, but can prevent future updates to the defaults from breaking the playbook by being incompatible with 389DS 1.3. On the other hand, setting the variable will essentially lock the configuration in time and if done for a prolonged period of time might render it obsolete. Use with discrection.

All variables are prefixed with dirsrv because starting a variable name with a number ("389ds") doesn't work that well.

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
dirsrv_plugins_enabled:
  MemberOf Plugin: true
```

If it's enabled and you want to disable it, set it to:

```yaml
dirsrv_plugins_enabled:
  MemberOf Plugin: false
```

If you want to enable more plugins:

```yaml
dirsrv_plugins_enabled:
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

Ansible doesn't merge dicts by default, i.e. if you want to change only uid_max and gid_max you have to define the \_min variables too. When you define dirsrv_dna_plugin, it replaces this default dict entirely.

This configuration is only applied if "Distributed Numeric Assignment Plugin" is true in dirsrv_plugins_enabled, and is removed when it is false. If it's not mentioned, nothing is done.

`dirsrv_replica_role` has to be defined to configure DNA with replication. That variable is also defined in the [lvps/389ds-recplication](https://github.com/lvps/389ds-replication) role, so refer to that one for documentation.
For this role it is sufficient for it to be defined if you are using replication, the value does not matter.

## Tags

There are some tags available, so can launch e.g.:

```shell
ansible-playbook some-playbook.yml --tags dirsrv_schema
```

and this will only update custom schema files, without changing anything else.
`some-playbook.yml` should apply this role, obviously.

The tags are:

- **dirsrv_schema**: custom schema tasks
- **dirsrv_tls**: all TLS configuration tasks, including certificates and enforcing
- **dirsrv_cert**: TLS certificate tasks, a subset of dirsrv_tls

All the tags also include a few checks at the beginning of the play and a "flush handlers" at the end, since 389DS may need to be restarted or a schema reload may be required.

`dirsrv_cert` is particularly useful for automated certificate management with ACME: see the "TLS with Let's Encrypt (or other ACME providers)" example below. If the same tag is added to all the ACME related tasks, it will be possible to run `ansible-playbook some-playbook.yml --tags dirsrv_cert` periodically and automatically to update certificates.

## Dependencies

None.

## Usage and Examples

### Minimum working example

```yaml
- name: An example playbook
  hosts: example
  roles:
    - role: lvps.389ds_server
      dirsrv_rootdn_password: secret
```

Bind with DN `cn=Directory Manager` and password `secret` on port 389, the suffix will be `dc=example,dc=local`, everything else is mostly like a clean 389DS install.

Ansible Vault would be a good idea to avoid exposing the root DN password as plaintext in production.

### Configure firewall

Not part of this role, but you may need to open the LDAP port (389) to access the server remotely:

```yaml
- name: Allow ldap port on firewalld
  firewalld: service=ldap permanent=true state=enabled
```

The same may be needed for the LDAPS port (636), if you enable TLS and want to use that instead of StartTLS.

### Example entries and some customization

```yaml
- name: An example playbook
  hosts: example
  roles:
    - role: lvps.389ds_server
      dirsrv_suffix: dc=custom,dc=example,dc=com
      dirsrv_rootdn: cn=admin
      dirsrv_rootdn_password: secret
      dirsrv_serverid: customized
      dirsrv_install_examples: true
      dirsrv_logging:
        audit:
          enabled: true
          logrotationtimeunit: day
          logmaxdiskspace: 400
          maxlogsize: 200
          maxlogsperdir: 14
          mode: 600
        access:
          enabled: true
          logrotationtimeunit: day
          logmaxdiskspace: 400
          maxlogsize: 200
          maxlogsperdir: 14
          mode: 600
        error:
          enabled: true
          logrotationtimeunit: day
          logmaxdiskspace: 400
          maxlogsize: 200
          maxlogsperdir: 14
          mode: 600
      dirsrv_plugins_enabled:
        MemberOf Plugin: true
      dirsrv_custom_schema:
        - "50example.ldif"
        - "60foobar.ldif"
```

Bind with DN `cn=admin` and password `secret` on port 389, look at the example entries provided by 389DS.

Audit logs are also enabled, and all logs are kept for 14 days (or until they become too large).

MemberOf Plugin is also enabled.

Look into the `molecule` directory for a custom schema file that is known to work with 389DS, if you want to test that part but you don't have a valid schema file. Delete that part to remove all custom schema files. Schema reload is done automatically.

### TLS

```yaml
- name: An example playbook
  hosts: example
  roles:
    - role: lvps.389ds_server
      dirsrv_suffix: "dc=example,dc=local"
      dirsrv_serverid: example
      dirsrv_rootdn_password: secret
      dirsrv_tls_enabled: true
      dirsrv_tls_cert_file: example_cert.pem
      dirsrv_tls_key_file: example.key
      dirsrv_tls_files_remote: false # True if the files are already on remote host (e.g. provided by certbot)
      dirsrv_tls_certificate_trusted: true # Or false if self-signed
      # If you want to avoid plain LDAP and enforce TLS, also consider these settings:
      dirsrv_tls_enforced: true
      dirsrv_tls_minssf: 256
      # Nothing to do with TLS, but for improved security you may consider:
      dirsrv_password_storage_scheme: "PBKDF2_SHA256"
      # even though the default password storage scheme is already strong enough.
```

[Here](https://github.com/WEEE-Open/sso/tree/master/ca) you can find a script to generate self-signed certificates that have been repeatedly tested with 389DS. Or look into the `molecule` directory for an example certificate and key that is used for role testing.

However, keep in mind that the script is provided as an example for **testing only**, it is not recommended for production use.

389DS is restarted automatically when needed to apply configuration. Both LDAPS (port 636) and StartTLS (port 389) are enabled.

If you get tired of having a secure connection, set `dirsrv_tls_enabled: false` but the certificate will stay in 389DS NSS database. It can be removed manually.

Certificate rollover (replacing certificate and key with a new one, e.g. because old ones are expired) seems to work with self signed and Let's Encrypt certificates, but the process is still very complicated and full of hacks and workarounds. If you want to use this in production, it is advisable that you read the relevant parts of [section 9.3 of the Administration Guide](https://access.redhat.com/documentation/en-us/red_hat_directory_server/10/html/administration_guide/managing_the_nss_database_used_by_directory_server) and the comments in `tasks/configure_tls.yml` to understand what's happening and why.

### TLS with Let's Encrypt (or other ACME providers)

The key point is that you need to feed the "fullchain" (server certificate and all intermediate ones, no root certificate) into the 389ds-server role.
Since I couldn't find many other examples on the http-01 challenge with `acme_certificate` I've added it here to give you a better idea of all the necessary steps.

```yaml
- name: An example playbook
  hosts: example
  pre_tasks:
    - name: Ensure ACME account exists
      acme_account:
        # acme_directory: "http://..."  # Your provider. Leave this off to use the Let's Encrypt staging directory
        account_key_content: "{{ acme_account_key }}"  # "openssl genrsa 2048" to generate it, but read https://docs.ansible.com/ansible/latest/modules/acme_account_module.html for more up to date information
        acme_version: 2
        state: present
        terms_agreed: true
        contact:
          - mailto:example@example.com

    # You need a CSR (certificate signing request). And a private key.
    # Do *not* reuse the account key, make a new one!
    # Generate them:
    #
    # openssl genrsa 2048 -out example.key
    # openssl req -new -key example.key -out example.csr -subj "/C=/ST=/L=/O=/OU=/CN=your.domain.example.com"
    #
    # Only the domain is important. Both example.key and your account key should be kept secret,
    # you could place them into Ansible Vault and use a template to create example.key from the variable.
    - name: Copy CSR and private key
      copy:
        src: "{{ item }}"
        dest: "/etc/some/secret/directory"
        owner: root
        group: root
        mode: "400"  # The csr could be world-readable, actually, it's not secret
        setype: cert_t
      loop:
        - "path/to/your/example.csr"
        - "path/to/your/example.key"

    - name: Create challenge
      acme_certificate:
        acme_directory: "http://..."
        account_key_content: "{{ acme_account_key }}"
        acme_version: 2
        challenge: "http-01"
        # You'll need the full chain (which contains your certificate and all
        # intermediate ones, but no root certificate). This will be fed into
        # NSS/389DS, which should serve all of them.
        fullchain: "/etc/some/secret/directory/example.fullchain.pem"
        csr: "/etc/some/secret/directory/example.csr"
        # remaining_days: 10
      register: acme_challenge

    # You need an HTTP server running. Imagine there is a NGINX instance that
    # serves pages on example.com from /var/www/html/example.com
    # If you find that an always running HTTP server is annoying, "when: acme_challenge is changed"
    # can be used to start it for the challenge and stop it at the end...
    #
    # You will also need a few directories, or the next task fails because they
    # don't exist...
    - name: Create HTTP directories for ACME http-01 challenge
      file:
        name: "{{ item }}"
        state: directory
        owner: root
        group: root
        # These should not be secret (they're accessible from the Internet),
        # just don't make them writeable by anyone
        mode: "755"
        setype: httpd_sys_content_t  # read-only
      loop:
        - "/var/www/html/example.com"
        - "/var/www/html/example.com/.well-known"
        - "/var/www/html/example.com/.well-known/acme-challenge"

    - name: Fulfill the http-01 challenge
      copy:
        dest: "/var/www/html/example.com/{{ acme_challenge['challenge_data']['example.com']['http-01']['resource'] }}"
        content: "{{ acme_challenge['challenge_data']['example.com']['http-01']['resource_value'] }}"
      when: acme_challenge is changed

    # Same as the previous acme_certificate task, just add "data"
    - name: Do challenge
      acme_certificate:
        acme_directory: "http://..."
        account_key_content: "{{ acme_account_key }}"
        acme_version: 2
        challenge: "http-01"
        fullchain: "/etc/some/secret/directory/example.fullchain.pem"
        csr: "/etc/some/secret/directory/example.csr"
        data: "{{ acme_challenge }}"
      when: acme_challenge is changed

    # Not optimal (for a few moments before this happens the certificate has the
    # wrong permissions)
    # It may be possible to set this task to "state: touch" and place it before
    # the previous one, though.
    - name: Ensure permissions for example certificate
      file:
        state: file
        path: "/etc/some/secret/directory/example.fullchain.pem"
        owner: root
        group: root
        mode: "400"
        setype: cert_t

  # In this example I have used almost no variables for greater clarity
  # (i.e. you see what these strings should look like, instead of an arbitrary
  # name that I invented), but in a real playbook it may be better to use
  # some variables.

  roles:
    - role: lvps.389ds_server
      dirsrv_suffix: "dc=example,dc=local"
      dirsrv_serverid: example
      dirsrv_rootdn_password: secret
      dirsrv_tls_enabled: true
      dirsrv_tls_cert_file: /etc/some/secret/directory/example.fullchain.pem
      dirsrv_tls_key_file: /etc/some/secret/directory/example.key
      dirsrv_tls_files_remote: true  # Both files are on the server
      dirsrv_tls_certificate_trusted: true  # No need to disable certificate checks, yay!
```

Since certificate rollovers are supported by this role, you just need to run this
playbook periodically to update the certificate when it is about to expire.

### What about replication?

There's [another role](https://github.com/lvps/389ds-replication) for that.

## Tests

> Tests make use of the [docker systemctl replacement](https://github.com/gdraheim/docker-systemctl-replacement) script created and distributed by [gdraheim](https://github.com/gdraheim) under the EUPL license. This script gets downloaded and copied to a local container to allow for the tests to execute correctly. Such distribution happens under the same license and terms upon which gdraheim created and published their work. The script is downloaded as-is and no alteration to it is made whatsoever. By running the tests on their machines the end user agrees to handle the downloaded script under the same terms of the EUPL as intended by its author. Note that the tests themselves (and the role overall) are still licensed under the Apache 2 license.

This role uses molecule for its tests. Install it with pip probably and test all the scenarios:

```shell
python -m venv venv
venv/bin/activate
pip install -r requirements.txt
molecule test --all
```

Or to test a single scenario: `molecule test -s tls`

## Future extensions

### Could be done, but not planned for the short term
- Support for Debian/Ubuntu/FreeBSD or any other platform that 389DS supports
- Support for other plugins that need more than enabled/disabled
- Support for other DNA attributes

## License

Apache 2.0 for the role and and associated tests  
EUPL v 1.2 for the "docker systemctl replacement" script by gdraheim (not included but downloaded when running tests)

## Author Information

Maintainer: Ludovico Pavesi  
Contributor/original author: Colby Prior  
Contributor/original author: Artemii Kropachev  
Thanks to Firstyear for the [comments](https://github.com/colbyprior/389-ldap-server/pull/1)
