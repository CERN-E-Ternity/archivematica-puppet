# Class: example::utils
#
# This class contains utils functions, mainly for credential
# setups.
#
# Parameters:
#
# home_dir - the home directory of the user, it must exist
# sshkey_publickey - the SSH public key generated with the SSH key
# sshkey_privatekey_secret - the name of the secret for the private ssh key
class example::utils (
    $sshkey_publickey = undef,
    $sshkey_privatekey_secret = undef,
) {
    # do not change the local user, otherwise everything will brake!
    $user = 'archivematica'
    $group = 'archivematica'
    $home_dir = "/home/${user}/"

# folder
    file {"${home_dir}/.ssh/":
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => '0700'
    }
# files
    file {'user_ssh_config':
        path    => "${home_dir}/.ssh/config",
        content => file('example/user_ssh_config'),
        owner   => $user,
        group   => $group,
        mode    => '0644',
        require => File["${home_dir}/.ssh/"]
    }
    file {'authorized_keys':
        ensure  => present,
        path    => "${home_dir}/.ssh/authorized_keys",
        content => $sshkey_publickey,
        owner   => $user,
        group   => $group,
        mode    => '0644',
        require => File["${home_dir}/.ssh/"]
    }
    file {'default_sshkey.pub':
        ensure  => present,
        path    => "${home_dir}/.ssh/default_sshkey.pub",
        content => $sshkey_publickey,
        owner   => $user,
        group   => $group,
        mode    => '0644',
        require => File["${home_dir}/.ssh/"]
    }

# TODO: set the ssh private key by using a secret, depending on how you store secrets
    file { $sshkey_privatekey_secret:
        path    => "${home_dir}/.ssh/default_sshkey",
        owner   => $user,
        group   => $group,
        mode    => '0600',
        require => File["${home_dir}/.ssh/"]
    }
}
