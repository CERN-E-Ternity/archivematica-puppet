# Class: maria_db
#
# Installs maria-db as the database server, if needed (if DB is in local)
#
# Parameters:
#
# db_name - the name of the database (MCP)
# db_user - the user to access the database
# db_password - the password for the database
class example::archivematica::requirements::maria_db (
    $db_name = 'MCP',
    $db_user = undef,
    $db_password = undef
){
# packages
    package {'mariadb-server': ensure => latest}
    -> file {'/var/run/mariadb/':
        ensure => directory,
        owner  => 'mysql',
        group  => 'mysql',
        mode   => '0775',
    }
    -> service {'mariadb':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true
    }
# setup user and DB
    -> exec {'mariadb_create_user':
        path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
        command => "mysql -e \"CREATE DATABASE ${db_name} CHARACTER SET utf8 COLLATE utf8_unicode_ci;CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_password}';GRANT ALL ON ${db_name}.* TO '${db_user}'@'localhost';FLUSH PRIVILEGES;\"",
        unless  => "mysql -u${db_user} -p${db_password} ${db_name} -e ''"
    }
}
