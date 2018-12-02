# Class: install
#
# Installs ClamAV packages
class example::archivematica::requirements::clamav::install {
# defaults
    Package {
        ensure => latest
    }

# packages
    # clamav
    package {'clamav':}
    package {'clamav-data':}
    package {'clamav-devel':}
    package {'clamav-filesystem':}
    package {'clamav-lib':}
    package {'clamav-scanner-systemd':}
    package {'clamav-server':}
    package {'clamav-server-systemd':}
    package {'clamav-update':}
}
