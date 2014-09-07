##
# This basic puppet initfile installs a basic installation of PHP, Apache, and
# MySQL.
#
# @author Su Wang <suw@suwdo.com>
##


# Include the REMI YUM repo to install PHP and MySQL
class { 'yum' : extrarepo => [ 'remi' ] }
include yum::repo::remi

# Install MySQL and set up some sample databases and users. There's really
# no need to change the password unless you're planning on copying this file
# to use on production.
class { 'mysql': }
class { 'mysql::server':
    config_hash => { 'root_password' => 'root_password'}
}
class { 'mysql::php': }
mysql::db { 'mydb':
    user     => 'myuser',
    password => 'mypassword',
    host     => 'localhost',
    grant    => ['all'],
}

# Install Apache
package { 'httpd': }
service { 'httpd':
    ensure => running,
    require => Package['httpd'],
}
file { '/etc/httpd/conf/httpd.conf':
    notify => Service['httpd'],
    ensure => file,
    mode   => 644,
    owner  => 'root',
    group  => 'root',
    source => '/vagrant/puppet/files/httpd.conf',
    require => Package['httpd'],
}

# Install PHP and related packages
package { 'php-common':
    require => [
        Yumrepo['remi'],
    ],
}
package { 'php':
    require => [
        Yumrepo['remi'],
        Package['httpd'],
        Package['php-common']
    ],
}
package { [
    'php-mbstring',
    'php-cli',
    'php-xml',
    ]:
    require => Package['php'],
}
file { '/etc/php.ini':
    notify => Service['httpd'],
    ensure => file,
    mode   => 644,
    owner  => 'root',
    group  => 'root',
    source => '/vagrant/puppet/files/php.ini',
    require => Package['php'],
}

# Set up firewalls
service { 'iptables':
    ensure => running,
}
file { '/etc/sysconfig/iptables':
    notify => Service['iptables'],
    ensure => file,
    mode   => 600,
    owner  => 'root',
    group  => 'root',
    source => '/vagrant/puppet/files/iptables',
}

# Install some useful dev tools
package { ['vim-enhanced', 'git', 'wget', 'tmux']:
    ensure => installed,
}
