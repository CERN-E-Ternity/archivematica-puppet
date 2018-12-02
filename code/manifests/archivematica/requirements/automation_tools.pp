# Class: automation_tools
#
# This class installs the automation tools used for the dashboard
#
# Requirements:
#
# - users and folders must have been created
# - pip must have been installed
#
# Parameters:
#
# amurl - URL of the dashboard (shouldn't change as it is installed on the dashboard)
# duser - user on the dashboard
# surl - URL of the storage
# suser - user on the storage
# sapi_key - its API key
# transfer - UUID of the transfer location
# transfer_type - transfer type (one of 'standard', 'unzipped bag', 'zipped bag', 'dspace')
# dashboard_apikey_secret - secret for the dashboard api key
# storage_apikey_secret - secret for the storage api key
class example::archivematica::requirements::automation_tools (
    $amurl = undef,
    $duser = undef,
    $surl = undef,
    $suser = undef,
    $sapi_key = undef,
    $transfer = undef,
    $transfer_type = 'standard',
    $dashboard_apikey_secret = undef,
    $storage_apikey_secret = undef,
){
    # do not change the local user, otherwise everything will brake!
    $user = 'archivematica'
    $group = 'archivematica'

# includes
    include stdlib

# defaults
    Package {
        ensure => latest
    }

# packages
    package {'gcc':}
    package {'git':}
    package {'libsqlite3x-devel':}
    package {'python-devel':}

    $home_dir = "/home/${user}"

# git repo
    vcsrepo {"${home_dir}/automation-tools/":
        ensure   => latest,
        provider => git,
        source   => 'https://github.com/artefactual/automation-tools.git',
        user     => $user,
        require  => User[$user]
    }

# files
    file {'/var/log/archivematica/automation-tools/':
        ensure  => directory,
        owner   => $user,
        group   => $group,
        mode    => '0755',
        require => User[$user]
    }
    file {"${home_dir}/automation-tools/install-automation-tools.sh":
        ensure  => present,
        content => file('example/install-automation-tools.sh'),
        owner   => $user,
        group   => $group,
        mode    => '0540',
        require => Vcsrepo["${home_dir}/automation-tools/"]
    }
# TODO: the file .sh accepts some secrets. Fix it by using your secret manager.
    file {"${home_dir}/automation-tools/run-automation-tools.sh":
        content    => template('example/run-automation-tools.sh.erb'),
        secret_keys => [$dashboard_apikey_secret, $storage_apikey_secret],
        owner      => $user,
        group      => $group,
        mode       => '0540',
        require    => Vcsrepo["${home_dir}/automation-tools/"]
    }

# installation
    exec {'install-automation-tools.sh':
        command => "${home_dir}/automation-tools/install-automation-tools.sh",
        cwd     => "${home_dir}/automation-tools/",
        require => Vcsrepo["${home_dir}/automation-tools/"]
    }
# cron task
    cron { 'cron-automation-tools':
        command => "${home_dir}/automation-tools/run-automation-tools.sh",
        user    => $user,
        hour    => 16,
        minute  => 30,
        require => Exec['install-automation-tools.sh']
    }
}
