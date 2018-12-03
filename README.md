# Sample of Puppet recipes for Archivematica Dashboard and Storage

This repo contains a set of sample recipes to install [Archivematica](https://www.archivematica.org/en/) Dashboard and Storage using Puppet.

These recipes are used in a test environment at CERN with a Puppet managed OpenStack infrastructure, to deploy Archivematica and its integration with [Invenio](https://inveniosoftware.org).

The code contains some **TODO**s: these are the parts of the recipes that use some in-house custom puppet modules and you will have to adapt to your infrastructure. In particular, they are related to secret managements.

The Puppet recipes are for CentOS linux distributions. If you are using another distributions, you will have to change all hard dependencies for CentOS, for example the `yum` packages.

## Quick overview

Archivematica is composed of:

* Dashboard machine
* Storage machine

### Dashboard

It receives/uploads SIP packages and runs the conversion to AIP. It sends the AIP packages to the Storage by using simple `scp` by default. That's why you will have to enable SSH authentication between the 2 machines.

 It is composed of:

* Nginx as reverse proxy
* Django application
* ElasticSearch
* Local [MariaDB](https://mariadb.org/) database.
* [MCP Server](https://wiki.archivematica.org/MCPServer) and [MCP Client](https://wiki.archivematica.org/MCPClient)
* [Automation tools](https://github.com/artefactual/automation-tools)

### Storage

Stores received AIP packages. It is composed of:

* Nginx as reverse proxy
* Django application
* Local [MySQL](https://www.mysql.com/) database.

## Example to prepare your secrets

### SSH access to the machine

Create a pair of public/private keys to enable ssh connections with keys between Dashboard and Storage machines. This is needed for rsync data transfer.

```bash
    # be sure to be in a secured location!!!
    $ cd ~/private
    $ ssh-keygen -f <filename> -C am_dashboard_storage
    # enter NO password!!!
    # ...
    # now store it safely in your Puppet secret manager
    $ rm <filename>
```

Add this to your hiera configuration:
```yaml
    example::utils::sshkey_publickey: 'copy here the content of <filename>.pub'
    example::utils::sshkey_privatekey_secret: '<SSH_PRIVATEKEY_KEY>'
```

## Deployment

Create one Dashboard and one Storage machine. To check if the installation went fine, you can ssh the machine and check log files:

```bash
    # For storage
    /var/log/archivematica/setup-storage.log
    # For dashboard
    /var/log/archivematica/setup-dashboard.log
```

### Add api keys in your recipes

If you have configured api keys for Dashboard and Storage, you can add them to the hiera configuration. For example:

```yaml
    # Automation tool
    # Dashboard
    example::archivematica::requirements::automation_tools::duser: 'dashboard username'
    example::archivematica::requirements::automation_tools::dashboard_apikey_secret: 'SECRET_NAME'
    # Storage
    example::archivematica::requirements::automation_tools::surl: 'http://mystorage.org'
    example::archivematica::requirements::automation_tools::suser: 'storage username'
    example::archivematica::requirements::automation_tools::storage_apikey_secret: 'SECRET_NAME'

    # UUID of the transfer location (Transfer Source location on the storage)
    example::archivematica::requirements::automation_tools::transfer: '6d7a02bc-a2ba-4eb0-b35f-aba8a7f60063'
```
