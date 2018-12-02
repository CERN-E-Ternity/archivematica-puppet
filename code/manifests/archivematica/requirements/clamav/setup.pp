# Class: setup
#
# Setup ClamAV
#
# Requires: example::archivematica::requirements::clamav::install
class example::archivematica::requirements::clamav::setup {
# includes
    include stdlib

# files
    # ensure both files are the same
    file {'/etc/clamd.conf':
        ensure => link,
        target => '/etc/clamd.d/scan.conf'
    }
    file {'/usr/bin/clamdscan':
        ensure => link,
        target => '/usr/bin/clamscan'
    }

    # removes unnecessary "Example"
    file_line {'freshclam.conf':
        ensure            => 'absent',
        path              => '/etc/freshclam.conf',
        line              => 'Example',
        match             => '^Example$',
        match_for_absence => true
    }
    # removes FRESHCLAM_DELAY
    file_line {'freshclam':
        ensure            => 'absent',
        path              => '/etc/sysconfig/freshclam',
        line              => 'FRESHCLAM_DELAY',
        match             => '^FRESHCLAM_DELAY=disabled-warn',
        match_for_absence => true
    }
    # removes unnecessary "Example"
    file_line {'scan.conf_example':
        ensure            => 'absent',
        path              => '/etc/clamd.d/scan.conf',
        line              => 'Example',
        match             => '^Example$',
        match_for_absence => true,
        require           => File['/etc/clamd.conf']
    }
    # uncomment LocalSocket
    file_line {'scan.conf_localsocket':
        path    => '/etc/clamd.d/scan.conf',
        line    => 'LocalSocket /var/run/clamd.scan/clamd.sock',
        match   => 'LocalSocket /var/run/clamd.scan/clamd.sock',
        require => File['/etc/clamd.conf']
    }
}
