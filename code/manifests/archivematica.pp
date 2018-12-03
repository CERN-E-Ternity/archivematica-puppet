# Class: example::archivematica
#
# This class contains the common setup shared between all the archivematica
# setups.
#
# It installs YUM packages on CentOS linux distribution.
#
class example::archivematica {
    # do not change the local user, otherwise everything will brake!
    $user = 'archivematica'
    $group = 'archivematica'

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

    group {$group:
        ensure     => present,
        forcelocal => true
    }
    user {$user:
        ensure     => present,
        groups     => $group,
        home       => "/home/${user}",
        shell      => '/bin/bash',
        forcelocal => true,
        require    => Group[$group]
    }
    file {"/home/${user}":
        ensure  => directory,
        owner   => $user,
        group   => $group,
        mode    => '0755',
        require => User[$user]
    }
    class {'example::utils':
        require         => File["/home/${user}/"]
    }

# repos
    # gpg keys
    exec {'elastic_pgp':
        command => 'rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch',
        unless  => 'rpm -qa --nodigest --nosignature --qf "%{VERSION}-%{RELEASE} %{SUMMARY}\n" | grep d88e42b4'
    }

# TODO: replace yum with your package manager if needed
    # repos
    yumrepo {'elasticsearch':
        baseurl  => 'https://packages.elastic.co/elasticsearch/1.7/centos',
        descr    => 'Elasticsearch repository for 1.7 packages',
        enabled  => 1,
        gpgcheck => 1,
        gpgkey   => 'https://packages.elastic.co/GPG-KEY-elasticsearch',
        require  => Exec['elastic_pgp']
    }
    yumrepo {'archivematica':
        baseurl  => 'https://packages.archivematica.org/1.6.x/centos',
        descr    => 'ArchiveMatica repo',
        enabled  => 1,
        gpgcheck => 0,
        name     => 'archivematica'
    }

# packages
    # defaults
    package {'htop':}
    package {'nano':}
    package {'wget':}
    # needed by archivematica
    package {'elasticsearch': require => Yumrepo['elasticsearch']}
    package {'epel-release':}
    package {'gearmand':}
    package {'java-1.8.0-openjdk-headless':}
    package {'mariadb':}
    package {'python2-pip':}

# files
    file_line {'ES_security':
        path    => '/etc/elasticsearch/elasticsearch.yml',
        line    => 'discovery.zen.ping.multicast.enabled: false',
        match   => 'discovery.zen.ping.multicast.enabled',
        notify  => Service['elasticsearch'],
        require => Package['elasticsearch']
    }
    $directory_tree = [
        '/var/archivematica/',
        '/var/archivematica/sharedDirectory/',
        '/var/lib/archivematica/',
        '/var/log/archivematica/'
    ]
    file {$directory_tree:
        ensure  => directory,
        owner   => $user,
        group   => $group,
        mode    => '0775',
        require => User[$user]
    }

# start services
    service {'elasticsearch': require => Package['elasticsearch']}
    service {'gearmand': require => Package['gearmand']}

# open ports for web and ElasticSearch
# TODO: configure iptables in your machine. Here an example on how we do it at CERN with an in-house custom module
    # firewall {'200 allow access to webUI on 80 and elasticsearch on 9200':
    #     dport  => [80, 9200],
    #     proto  => 'tcp',
    #     action => 'accept'
    # }
}
