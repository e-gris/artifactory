# == Class artifactory::install
#
# This class is called from artifactory for install.
#

if ($::artifactory::package_version) {
  $artifactory_package_ensure = $::artifactory::package_version
}
else {
  $artifactory_package_ensure = "present"
}

class artifactory::install {
  package { $::artifactory::package_name:
    ensure  => $artifactory_package_ensure,
  }
}
