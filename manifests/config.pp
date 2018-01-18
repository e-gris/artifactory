# Artifactory base (open source) configuration.
class artifactory::config {

  file_line { 'artifactory file limits':
    path => '/etc/security/limits.conf',
    line => 'artifactory -  nofile 32000',
  }

  # Ack! Ptth!
  exec { 'make artifactory home':
    command => "mkdir --parents ${::artifactory::artifactory_home}",
    unless  => "test -d ${::artifactory::artifactory_home}",
    path    => '/bin:/usr/bin',
  }

  file { $::artifactory::artifactory_home:
    ensure => directory,
    owner  => $::artifactory::artifactory_user,
    group  => $::artifactory::artifactory_group,
    mode   => '0755',
  }

  exec { 'make artifactory etc':
    command => "mkdir --parents ${::artifactory::artifactory_etc}",
    unless  => "test -d ${::artifactory::artifactory_etc}",
    path    => '/bin:/usr/bin',
  }

  file { $::artifactory::artifactory_etc:
    ensure => directory,
    owner  => $::artifactory::artifactory_user,
    group  => $::artifactory::artifactory_group,
    mode   => '0700',
  }

  $etc_files = [
                "${::artifactory::artifactory_etc}/artifactory.config.xml",
#                "${::artifactory::artifactory_etc}/artifactory.system.properties",
                "${::artifactory::artifactory_etc}/binarystore.xml",
                "${::artifactory::artifactory_etc}/default",
                "${::artifactory::artifactory_etc}/logback.xml",
                "${::artifactory::artifactory_etc}/mimetypes.xml",
                ]

  file { $etc_files :
    ensure => present,
    owner  => $::artifactory::artifactory_user,
    group  => $::artifactory::artifactory_group,
    mode   => '0644',
  }

  file_line { 'artifactory FOOBAR-1  traffic collection':
    ensure => present,
    path   => "${::artifactory::artifactory_etc}/artifactory.system.properties",
    line   => "artifactory.traffic.collectionActive=${::artifactory::traffic_collection}",
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
  ## Try to figure out if some, all or none of the database_variables
  ## have been set.
  ##
  $database_variables_defined = $database_variables.filter | $dbv | {
    $dbv != undef
  }
  $database_variables_defined_size = size($database_variables_defined)

  if (!$::artifactory::is_primary) {
    info('HA secondary node. No db.properties needed')
  }
  elsif ($database_variables_defined_size == 0) {
    info('No database details provided, providing default')
  }
  elsif ($database_variables_defined_size != $database_variables_size) {
    warning('Database port, hostname, username, password and type must be all be set, or not set. Install proceeding without storage.')
  }
  else {
    info('Primary/single node, setting up db.properties')
    file { "${::artifactory::artifactory_etc}/db.properties":
      ensure  => file,
      content => epp(
        'artifactory/db.properties.epp', {
          db_url      => $::artifactory::db_url,
          db_username => $::artifactory::db_username,
          db_password => $::artifactory::db_password,
          db_type     => $::artifactory::db_type,
          }),
      owner   => $::artifactory::artifactory_user,
      group   => $::artifactory::artifactory_group,
      mode    => '0600',
    }
  }
}
