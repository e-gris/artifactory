# Ensure Artifactory is running
class artifactory::service {
  service { 'artifactory':
    ensure => running,
  }
}
