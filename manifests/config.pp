# == Class artifactory::config
#
# This class is called from artifactory for service config.
#
class artifactory::config {

  file { "${::artifactory::artifactory_home}":
    ensure => directory,
    owner  => 'artifactory',
    mode   => '0755',
  }

  file { "/etc/opt/jfrog":
    ensure => directory,
    owner  => 'artifactory',
    group  => 'artifactory',
  }

  file { "/etc/opt/jfrog/artifactory":
    ensure => directory,
    owner  => 'artifactory',
    group  => 'artifactory',
  }

  file { "/etc/opt/jfrog/artifactory/default":
    ensure => present,
    owner  => 'artifactory',
    group  => 'artifactory',
  }

  file { "/etc/opt/jfrog/artifactory/artifactory.system.properties":
    ensure => present,
    owner  => 'artifactory',
    group  => 'artifactory',
    mode   => '0644',
  }

  file { "/var/opt/jfrog/run":
    ensure => directory,
    owner  => 'artifactory',
    group  => 'artifactory',
  }

  # Install db.properties if we can
  $database_variables = [
    $::artifactory::jdbc_driver_url,
    $::artifactory::db_url,
    $::artifactory::db_username,
    $::artifactory::db_password,
    $::artifactory::db_type]
  $database_variables_size = size($database_variables)

  ##
  ## Try to figure out of some, all or none of the database_variables
  ## have been set.
  ##
  $database_variables_defined = $database_variables.filter | $dbv | {
    $dbv != undef
  }
  $database_variables_defined_size = size($database_variables_defined)

  if (!$is_primary) {
    notify { "HA secondary node. No db.properties needed": }
    info("HA secondary node. No db.properties needed")
  }
  elsif ($database_variables_defined_size == 0) {
    notify { "Default database": }
    info("No database details provided, providing default")
  }
  elsif ($database_variables_defined_size != $database_variables_size) {
    warning('Database port, hostname, username, password and type must be all be set, or not set. Install proceeding without storage.')
  }
  else {
    file { "${::artifactory::artifactory_home}/etc/db.properties":
      ensure  => file,
      content => epp(
        'artifactory/db.properties.epp', {
          db_url                         => $::artifactory::db_url,
          db_username                    => $::artifactory::db_username,
          db_password                    => $::artifactory::db_password,
          db_type                        => $::artifactory::db_type,
        }),
      mode    => '0664',
    }
  }
}
