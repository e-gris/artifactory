# Manage the artifactory service
class artifactory::service {
  ## Can't manage service run/stopped state because of artifactory bug
  ## if this is a non-primary node.

  if ($artifactory::is_primary) {
    service { 'artifactory':
      ensure => running,
    }
  }
}
