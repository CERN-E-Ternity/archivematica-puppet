# Class: storage_requirements
#
# Installs extra requirements needed by Archivematica.
class example::archivematica::requirements::storage_requirements {
# defaults
    Package {
        ensure => latest
    }

# packages
    package {'MySQL-python':}
}
