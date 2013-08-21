# == Class: redmine
#
class redmine (
  $docroot              = '/var/www/redmine',
  $database_config_path = '/var/www/redmine/config/database.yml',
  $mysql_user           = 'redmine',
  $mysql_password       = 'redmine',
  $server_name          = "redmine.${::domain}",
) {

  include apache::mod::ssl
  include passenger
  include mysql::server
  include mysql::ruby

  # replace these with a package{} resource
  common::mkdir_p { 'redmine_docroot':
    name => $docroot,
  }

  file { 'redmine_docroot':
    ensure  => directory,
    path    => $docroot,
    require => Common::Mkdir_p['redmine_docroot'],
  }

  # manage config/configuration.yml - needed for SMTP
#  file { 'redmine_smtp_config':
#  }

  file { 'redmine_database_config':
    ensure  => file,
    content => template('redmine/database.yml.erb'),
    path    => $database_config_path,
#    owner  => $database_config_owner,
#    group  => $database_config_group,
#    mode   => $database_config_mode,
    require => File['redmine_docroot'],
  }

  file { 'redmine.conf':
    ensure  => file,
    path    => '/etc/httpd/conf.d/redmine.conf',
    content => template('redmine/redmine.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['httpd'],
  }

  mysql::db { 'redmine':
    user     => $mysql_user,
    password => $mysql_password,
    host     => 'localhost',
    grant    => ['all'],
    require  => Class['mysql::server'],
  }
}
