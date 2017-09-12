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

  ## Not sure what this should be doing
  #file { "${::artifactory::artifactory_home}/etc":
  #  # Yum unpack wants this for its own
  #  ensure => absent,
  #}

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

  file { "/var/opt/jfrog/run":
    ensure => directory,
    owner  => 'artifactory',
    group  => 'artifactory',
  }

  ## Create binarystore.xml

  ## Create db.properties
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
    defined($dbv)
  }
  $database_variables_defined_size = size($database_variables_defined)

  if ($database_variables_defined_size == 0) {
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
          binary_provider_type           => $::artifactory::binary_provider_type,
          pool_max_active                => $::artifactory::pool_max_active,
          pool_max_idle                  => $::artifactory::pool_max_idle,
          binary_provider_cache_maxsize  => $::artifactory::binary_provider_cache_maxsize,
          binary_provider_filesystem_dir => $::artifactory::binary_provider_filesystem_dir,
          binary_provider_cache_dir      => $::artifactory::binary_provider_cache_dir,
        }),
      mode    => '0664',
    }

    file { "${::artifactory::artifactory_home}/etc/storage.properties":
      ensure => link,
      target => "${::artifactory::artifactory_home}/etc/db.properties",
    }

    $file_name =  regsubst($::artifactory::jdbc_driver_url, '.+\/([^\/]+)$', '\1')

    file { "${::artifactory::artifactory_home}/tomcat/lib":
      ensure => directory,
      mode   => '755',
      owner  => 'artifactory',
    }
      
    file { "${::artifactory::artifactory_home}/tomcat/lib/${file_name}":
      source => $::artifactory::jdbc_driver_url,
      mode   => '0644',
      owner  => 'artifactory',
    }
  }
    
  # if(
  #   $::artifactory::jdbc_driver_url or
  #   $::artifactory::db_url or
  #   $::artifactory::db_username or
  #   $::artifactory::db_password or
  #   $::artifactory::db_type) {
  #   if ($::artifactory::jdbc_driver_url and
  #       $::artifactory::db_url and
  #       $::artifactory::db_username and
  #       $::artifactory::db_password and
  #       $::artifactory::db_type
  #       ) {
  #     file { "${::artifactory::artifactory_home}/etc/db.properties":
  #       ensure  => file,
  #       content => epp(
  #         'artifactory/db.properties.epp',
  #         {
  #           db_url                         => $::artifactory::db_url,
  #           db_username                    => $::artifactory::db_username,
  #           db_password                    => $::artifactory::db_password,
  #           db_type                        => $::artifactory::db_type,
  #           binary_provider_type           => $::artifactory::binary_provider_type,
  #           pool_max_active                => $::artifactory::pool_max_active,
  #           pool_max_idle                  => $::artifactory::pool_max_idle,
  #           binary_provider_cache_maxsize  => $::artifactory::binary_provider_cache_maxsize,
  #           binary_provider_filesystem_dir => $::artifactory::binary_provider_filesystem_dir,
  #           binary_provider_cache_dir      => $::artifactory::binary_provider_cache_dir,
  #         }
  #       ),
  #       mode    => '0664',
  #     }

  #     file { "${::artifactory::artifactory_home}/etc/storage.properties":
  #       ensure => link,
  #       target => "${::artifactory::artifactory_home}/etc/db.properties",
  #     }

  #     $file_name =  regsubst($::artifactory::jdbc_driver_url, '.+\/([^\/]+)$', '\1')


  #     file { "${::artifactory::artifactory_home}/tomcat/lib":
  #       ensure => directory,
  #       mode   => '755',
  #       owner  => 'artifactory',
  #     }
      
  #     file { "${::artifactory::artifactory_home}/tomcat/lib/${file_name}":
  #       source => $::artifactory::jdbc_driver_url,
  #       mode   => '0644',
  #       owner  => 'artifactory',
  #     }
  #   }
  #   else {
  #     warning('Database port, hostname, username, password and type must be all be set, or not set. Install proceeding without storage.')
  #   }
  # }
}
