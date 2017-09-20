class artifactory::config {

  file_line { "artifactory file limits":
    path => "/etc/security/limits.conf",
    line => "artifactory -  nofile 32000",
  }

  $home_paths = split(dirname($::artifactory::artifactory_home), '/')
  notify { "XXXXXX home_paths == $home_paths": }
  notify { "XXXXXX artifactory_home == $artifactory_home": }

  #each ($home_paths) | $directory | {
  #  file { $directory: ensure => directory, }
  #}


  # each ($home_paths) | $directory | {
  #   if (!defined(File[$directory])) {
  #     file { $directory:
  #       ensure => directory,
  #     }
  #   }
  # }
  # file { "${::artifactory::artifactory_home}":
  #   ensure => directory,
  #   owner  => $::artifactory::artifactory_user,
  #   group  => $::artifactory::artifactory_group,
  #   mode   => '0755',
  # }

  
  # $etc_paths = split(dirname($::artifactory::artifactory_etc), '/')
  # each ($etc_paths) | $directory | {
  #   if (!defined(File[$directory])) {
  #     file { $directory:
  #       ensure => directory,
  #     }
  #   }
  # }
  # file { "${::artifactory::artifactory_etc}":
  #   ensure => directory,
  #   owner  => $::artifactory::artifactory_user,
  #   group  => $::artifactory::artifactory_group,
  #   mode   => '0755',
  # }

  $etc_files = [
                "${::artifactory::artifactory_etc}/artifactory.config.xml",
                "${::artifactory::artifactory_etc}/artifactory.system.properties",
                "${::artifactory::artifactory_etc}/binarystore.xml",
                "${::artifactory::artifactory_etc}/default",
                "${::artifactory::artifactory_etc}/logback.xml",
                "${::artifactory::artifactory_etc}/mimetypes.xml"
                ]
               
  file { $etc_files :
    ensure => present,
    owner  => $::artifactory::artifactory_user,
    group  => $::artifactory::artifactory_group,
    mode   => '0644',
  }

  #file { "/var/opt/jfrog/run":
  #  ensure => directory,
  #  owner  => 'artifactory',
  #  group  => 'artifactory',
  #}

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
    info("HA secondary node. No db.properties needed")
  }
  elsif ($database_variables_defined_size == 0) {
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
          db_url      => $::artifactory::db_url,
          db_username => $::artifactory::db_username,
          db_password => $::artifactory::db_password,
          db_type     => $::artifactory::db_type,
        }),
      mode    => '0664',
    }
  }
}
