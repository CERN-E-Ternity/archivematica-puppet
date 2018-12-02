# Class: dashboard
#
# This class installs the storage environment
#
# Parameters:
#
# db_name - the name of the database (MCP)
# db_host - the host of the database
# db_port - the port on the host to reach the database
# db_user - the user to access the database
# db_password - the password for the database
class example::archivematica::dashboard (
    $db_name = undef,
    $db_host = undef,
    $db_port = undef,
    $db_user = undef,
    $db_password = undef,
){
    # do not change the local user, otherwise everything will brake!
    $user = 'archivematica'
    $group = 'archivematica'
    $django_secretkey = generate('/bin/sh', '-c', "mkpasswd -l 64 | tr -d '\n'")

# includes
    require example::archivematica
    # requirements
    require example::archivematica::requirements::clamav
    require example::archivematica::requirements::dashboard_requirements
    include example::archivematica::requirements::automation_tools
    if $db_host == 'localhost' {
        require class {'example::archivematica::requirements::maria_db':
            db_name     => $db_name,
            db_user     => $db_user,
            db_password => $db_password
        }
    }

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

# repos
# TODO: replace yum with your package manager if needed
    yumrepo {'archivematica-extras':
        baseurl  => 'https://packages.archivematica.org/1.6.x/centos-extras',
        descr    => 'ArchiveMatica extra repo',
        enabled  => 1,
        gpgcheck => 0,
        name     => 'archivematica-extras'
    }

# packages
    # archivematica
    package {'nginx':}
    package {'archivematica-common':}
    package {'archivematica-dashboard':}
    package {'archivematica-mcp-server':}
    package {'archivematica-mcp-client':
        require => [
            Exec['archivematica_setup'],
            Yumrepo['archivematica-extras']
        ]
    }
    # What happens here:
    # - we install ClamAV and the different archivematica packages
    # - we setup everything via the script called in the exec
    # - we install the package archivematica-mcp-client

# files
    file {'/var/archivematica/setup-scripts/':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0555'
    }
    file {'/var/archivematica/setup-scripts/setup-dashboard.sh':
        ensure  => present,
        content => template('example/setup-dashboard.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0540',
        require => File['/var/archivematica/setup-scripts/']
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
    file_line {'archivematica-dashboard.conf':
        path    => '/etc/nginx/conf.d/archivematica-dashboard.conf',
        line    => '  listen 80 default_server;',
        match   => 'listen',
        notify  => Service['nginx'],
        require => Package['archivematica-dashboard']
    }

    # MySQL config
    file {'/etc/sysconfig/archivematica-dashboard':
        content => template('example/archivematica-dashboard.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['archivematica-dashboard'],
        before  => Exec['archivematica_setup']
    }
    file {'/etc/sysconfig/archivematica-mcp-server':
        content => template('example/archivematica-mcp-server.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['archivematica-mcp-server'],
        before  => Exec['archivematica_setup']
    }
    file {'/etc/sysconfig/archivematica-mcp-client':
        content => template('example/archivematica-mcp-client.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['archivematica-mcp-client']
    }
    file_line {'dbsettings_password':
        path    => '/etc/archivematica/archivematicaCommon/dbsettings',
        line    => "password=${db_password}",
        match   => 'password=',
        require => Package['archivematica-common'],
        before  => Exec['archivematica_setup']
    }
    file_line {'dbsettings_host':
        path    => '/etc/archivematica/archivematicaCommon/dbsettings',
        line    => "host=${db_host}",
        match   => 'host=',
        require => Package['archivematica-common'],
        before  => Exec['archivematica_setup']
    }
    file_line {'common.py':
        path    => '/usr/share/archivematica/dashboard/settings/common.py',
        line    => "        'PORT': '${db_port}'",
        match   => "'PORT':",
        require => Package['archivematica-common'],
        before  => Exec['archivematica_setup']
    }

# setup
    exec {'archivematica_setup':
        command => '/var/archivematica/setup-scripts/setup-dashboard.sh > /var/log/archivematica/setup-dashboard.log || rm -f /var/log/archivematica/setup-dashboard.log',
        creates => '/var/log/archivematica/setup-dashboard.log',
        require => [
            File['/var/archivematica/setup-scripts/setup-dashboard.sh'],
            Package['archivematica-common'],
            Package['archivematica-dashboard'],
            Package['archivematica-mcp-server']
        ]
    }
    file {'/usr/bin/7z':
        ensure  => link,
        target  => '/usr/bin/7za',
        require => Exec['archivematica_setup']
    }

# start services
    service {'archivematica-dashboard': require => Exec['archivematica_setup']}
    service {'archivematica-mcp-client': require => Package['archivematica-mcp-client']}
    service {'archivematica-mcp-server': require => Exec['archivematica_setup']}
    service {'fits-nailgun': require => Exec['archivematica_setup']}
    service {'nginx': require => Package['nginx']}
}
