# Class: storage
#
# This class installs the storage environment
#
# Parameters:
#
# db_engine - the engine to use ('sqlite3' or 'mysql')
# db_name - the name of the database (STORAGE) or the path if using sqlite3
# db_host - the host of the database
# db_port - the port on the host to reach the database
# db_user - the user to access the database
# db_password - the password for the database
class example::archivematica::storage (
    $db_engine = undef,
    $db_name = undef,
    $db_host = undef,
    $db_port = undef,
    $db_user = undef,
    $db_password = undef,
) {
    # do not change the local user, otherwise everything will brake!
    $user = 'archivematica'
    $group = 'archivematica'
    $django_secretkey = generate('/bin/sh', '-c', "mkpasswd -l 64 | tr -d '\n'")

# includes
    require example::archivematica
    require example::archivematica::requirements::storage_requirements

# defaults
    Exec {
        path => ['/usr/bin', '/usr/sbin', '/bin', '/sbin']
    }
    Package {
        ensure => latest
    }
    Service {
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true
    }

# files
    file {'/var/archivematica/setup-scripts/':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0555'
    }
    file {'/var/archivematica/setup-scripts/setup-storage.sh':
        ensure  => present,
        content => template('example/setup-storage.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0540',
        require => File['/var/archivematica/setup-scripts/']
    }

    # MYSQL
    file {'/etc/sysconfig/archivematica-storage-service':
        content => template('example/archivematica-storage-service.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['archivematica-storage-service'],
        before  => Exec['archivematica_setup']
    }

    # NGINX
    file {'nginx.conf':
        ensure  => present,
        path    => '/etc/nginx/nginx.conf',
        content => file('example/nginx.conf'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['nginx'],
        require => Package['nginx']
    }
    file_line {'archivematica-storage-service.conf':
        path    => '/etc/nginx/conf.d/archivematica-storage-service.conf',
        line    => '  listen 80 default_server;',
        match   => 'listen',
        notify  => Service['nginx'],
        require => Package['archivematica-storage-service']
    }

# packages
    package {'nginx':}
    package {'archivematica-storage-service':}

# setup
    exec {'archivematica_setup':
        command => '/var/archivematica/setup-scripts/setup-storage.sh > /var/log/archivematica/setup-storage.log || rm -f /var/log/archivematica/setup-storage.log',
        creates => '/var/log/archivematica/setup-storage.log',
        require => [
            File['/var/archivematica/setup-scripts/setup-storage.sh'],
            Package['archivematica-storage-service']
        ]
    }

# start services
    service {'archivematica-storage-service': require => Exec['archivematica_setup']}
    service {'nginx': require => Package['nginx']}
}
