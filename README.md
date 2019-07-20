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

- Ansible 2.7 or newer
- CentOS 7

## Role Variables

The variables that can be passed to this role and a brief description about them are as follows.

| Variable                        | Default              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Can be changed |
|---------------------------------|----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|
| dirsrv_suffix                   | dc=example,dc=com    | Suffix of the DIT. All entries in the server will be placed under this suffix. Normally it's made from the domain components (*dc*) of your company main domain. E.g. if you're from example.co.uk and the server will be at ldap-server.example.co.uk, set the suffix to `dc=example,dc=co,dc=uk`, leaving out the subdomain part (`ldap-server`) since it's irrelevant.                                                                                                                                                                                                                                                                                                                                                          | **No**         |
| dirsrv_rootdn                   | cn=Directory Manager | Root DN, or "administrator" account username. Bind with this DN to bypass all authorization controls.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | **No**         |
| dirsrv_rootdn_password          |                      | Password for root DN, you *must* define this variable or the role will fail.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | **No**         |
| dirsrv_fqdn                     | {{ansible_nodename}} | Server FQDN, e.g. `ldap.example.com`. If the server hostname is already an FQDN, the default should pick it up.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | **No**         |
| dirsrv_serverid                 | default              | Server ID or instance ID. All the data related to the instance configured by this role will end up in /etc/dirsrv/slapd-*default*, /var/log/dirsrv/slapd-*default*, etc... You could use your company name, e.g. for Foo Bar, Inc set the variable to `foobar` and the directories will be named slapd-foobar.                                                                                                                                                                                                                                                                                                                                                                                                                     | ¹              |
| dirsrv_install_examples         | false                | Create example entries under the suffix during installation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | **No**         |
| dirsrv_install_additional_ldif  | []                   | Install these additional LDIF files, by default none (empty array). This corresponds to the `InstallLdifFile` directive in the inf installation file.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | **No**         |
| dirsrv_logging                  | see below            | see below                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Yes            |
| dirsrv_plugins_enabled          | {}                   | Enable or disable plugins, see below for details. By default no plugins are enabled or disabled.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | Yes            |
| dirsrv_dna_plugin               | see below            | Configuration for the DNA (Distributed Numeric Assignment) plugin.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Yes            |
| dirsrv_custom_schema            | []                   | Paths to custom schema files. They will be dropped into `/etc/dirsrv/slapd-{{ dirsrv_serverid }}/schema` and a schema reload will be request when anything chages.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Yes            |
| dirsrv_allow_other_schema_files | false                | If false (default value), this role will add the specified schema files to `/etc/dirsrv/slapd-{{ dirsrv_serverid }}/schema`, then delete all other schema files there except `99user.ldif`. If your schema files are managed only by this role or dynamically (i.e. from `cn=schema`, which writes to `99user.ldif`), you can leave this variable to its default of false. If you have more schema files in that directory (added manually or by other tasks), set this to true to leave them there. The downside is that if you deploy e.g. `50example.ldif`, then you rename it to `50my_example.ldif`, when the role runs again it considers it a new file and leaves the previous one there, wreaking havoc on your directory. | Yes            |
| dirsrv_tls_enabled              | false                | Enable TLS (LDAPS and StartTTLS). All "dirsrv_tls" variables have effect only if this is enabled.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Yes            |
| dirsrv_tls_min_version          | '1.2'                | Minimum TLS version: 1.0, 1.1 or 1.2. Possibly even 1.3, when support is added to 389DS. SSLv2 and SSLv3 are always disabled by this role.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Yes            |
| dirsrv_tls_certificate_trusted  | true                 | The server certificate is publicly trusted. Set to false if it's self-signed or from a private CA.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Yes            |
| dirsrv_tls_enforced             | false                | Enforce TLS by requiring secure binds and minimum SSF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Yes            |
| dirsrv_tls_minssf               | 256                  | Minimum SSF, used only when dirsrv_tls_enforced is true. 128 seems reasonable, 256 should be very secure. Set this to 0 to enforce TLS only with secure binds.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Yes            |
| dirsrv_allow_anonymous_binds    | 'rootdse'            | Allow anonymous binds: boolean true for Yes, boolean false for No, or 'rootdse'. The Administration Guide suggests to use rootdse instead of No, because it allows anonymous binds to search some data that clients may require before doing a bind. Allowing anonymous binds basically makes your directory public, unless you restrict access with ACIs.                                                                                                                                                                                                                                                                                                                                                                         | Yes            |
| dirsrv_simple_auth_enabled      | true                 | Enable SIMPLE authentication, probably true unless you want to use SASL PLAIN only or configure other methods manually.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | Yes            |
| dirsrv_password_storage_scheme  | []                   | A single value, possibly the string "PBKDF2_SHA256". Or leave the default, which will delete any custom value and use 389DS default, which should be pretty secure.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | Yes            |
| dirsrv_ldapi_enabled            | false                | Enable LDAPI (connect to the server via a UNIX socket at `ldapi:///var/run/slapd-{{ dirsrv_serverid }}.socket`). Note that this is subject to TLS enforcing and TLS is not supported, so it's useless if you set dirsrv_tls_enforced to true.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | Yes            |
| dirsrv_sasl_plain_enabled       | true                 | Enable SASL PLAIN authentication: if a client tries to authenticate without TLS and TLS is enforced, this kind of authentication should stop it before it sends the plaintext password, while a SIMPLE bind will send the password and then fail because SSF is too low.                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Yes            |

Some variables cannot be changed by this role (or at all) after creating an instance of 389DS. If one of them is changed and the role is applied again, undefined behaviour ranging from "nothing" to "the role fails" may happen. Some of them, e.g. the root DN password, can be changed manually: please refer to the [Administration Guide](https://access.redhat.com/documentation/en-us/red_hat_directory_server/10/html/administration_guide/index) for details.

All variables are prefixed with dirsrv because starting a variable name with a number ("389ds") doesn't work that well.

¹ Changing this variable from a previous run will lead to the creation of another instance, another directory completely separated from the previous one. This should work, but it hasn't been tested at all.

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

### Minimum working example

```yaml
- name: An example playbook
  hosts: example
  roles:
    -
      role: lvps.389ds_server
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
    -
      role: lvps.389ds_server
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
      plugins_enabled:
        MemberOf Plugin: true
      custom_schema:
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
    -
      role: lvps.389ds_server
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

389DS is restarted automatically when needed to apply configuration.

Both LDAPS (port 636) and StartTLS (port 389) are enabled.

If you get tired of having a secure connection, set `dirsrv_tls_enabled: false` but the certificate will stay in 389DS NSS database. It can be removed manually.

Certificate rollover (replacing certificate and key with a new one, e.g. because old ones are expired) has been tested a few times and seems to work, but the process is still very complicated and full of hacks and workarounds. If you want to use this in production, it is advisable that you read the relevant parts of [section 9.3 of the Administration Guide](https://access.redhat.com/documentation/en-us/red_hat_directory_server/10/html/administration_guide/managing_the_nss_database_used_by_directory_server) and the comments in `tasks/configure_tls.yml` to understand what's the rationale for all those tasks.

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
        # NSS/389DS, which should hopefully serve all of them. At least, in my
        # tests it did and it was recognized as valid and trusted by clients.
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

This role uses molecule for its tests. Install it with pipenv (pip probably works, too) and test all the scenarios:

```shell
pipenv install
pipenv shell
molecule test --all
```

Or to test a single scenario: `molecule test -s tls`

## Future extensions

### Probably will be done
- Support for CentOS 8 when it comes out

### Could be done, but not planned for the short term
- Support for Debian/Ubuntu/FreeBSD or any other platform that 389DS supports
- Support for other plugins that need more than enabled/disabled
- Support for other DNA attributes

## License

Apache 2.0

## Author Information

Maintainer: Ludovico Pavesi  
Contributor/original author: Colby Prior  
Contributor/original author: Artemii Kropachev  
Thanks to Firstyear for the [comments](https://github.com/colbyprior/389-ldap-server/pull/1)
