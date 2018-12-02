# Class: dashboard_requirements
#
# Installs extra requirements needed by Archivematica.
# The reason why we install manually the repo, instead of using the rpm
# packages is because puppet uses a non-standard folder /etc/yum-puppet-repos.d/
# instead of /etc/yum.repos.d/
class example::archivematica::requirements::dashboard_requirements {
# Forensic tools repo
    # get the PGP key
    exec {'forensics_pgp':
        command => 'rpm --import https://forensics.cert.org/forensics.asc',
        unless  => 'rpm -qa --nodigest --nosignature --qf "%{VERSION}-%{RELEASE} %{SUMMARY}\n" | grep 87e360b8'
    }
    # install repos
    yumrepo {'forensics':
        baseurl  => 'http://www.cert.org/forensics/repository/centos/cert/$releasever/$basearch',
        descr    => 'CERT Forensics Tools Repository',
        enabled  => 1,
        gpgcheck => 1,
        gpgkey   => 'https://forensics.cert.org/forensics.asc',
        require  => Exec['forensics_pgp']
    }
# Nux multimedia repo
    # get the PGP key
    exec {'nux_pgp':
        command => 'rpm --import https://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro',
        unless  => 'rpm -qa --nodigest --nosignature --qf "%{VERSION}-%{RELEASE} %{SUMMARY}\n" | grep 85c6cd8a'
    }
    # install repos
    yumrepo {'nux-dextop':
        baseurl  => 'http://linuxsoft.cern.ch/mirror/li.nux.ro/download/nux/dextop/el7/$basearch/',
        descr    => 'Nux.Ro RPMs for general desktop use',
        enabled  => 1,
        gpgcheck => 1,
        gpgkey   => 'https://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro',
        require  => Exec['nux_pgp']
    }
}
