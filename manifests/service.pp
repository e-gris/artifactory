# == Class artifactory::service
#
# This class is meant to be called from artifactory.
# It ensure the service is running.
#
class artifactory::service {

  ## Can't manage service run/stopped state because of artifactory bug.
  #
  #  service { 'artifactory':
  #    ensure => running,
  #  }
}
