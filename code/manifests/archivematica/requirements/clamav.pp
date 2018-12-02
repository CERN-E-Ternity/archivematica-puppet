# Class: clamav
#
# Installs  and configure ClamAV
class example::archivematica::requirements::clamav {
    class {'example::archivematica::requirements::clamav::install':}
    -> class {'example::archivematica::requirements::clamav::setup':}
    ~> service {'clamd@scan':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true
    }
    # give permission to scan system
    exec {'freshclam':
        command => 'setsebool -P antivirus_can_scan_system 1; freshclam',
        unless  => 'getsebool -a | grep antivirus_can_scan_system | grep on',
        path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
        require => Class['example::archivematica::requirements::clamav::setup']
    }
}
