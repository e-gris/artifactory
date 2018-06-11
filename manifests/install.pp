class artifactory::install {
  if ($::artifactory::package_version) {
    $artifactory_package_ensure = $::artifactory::package_version
  }
  else {
    $artifactory_package_ensure = "present"
  }

  info("Artifactory version set to \"$artifactory_package_ensure\"")
  
  package { $::artifactory::package_name:
    ensure  => $artifactory_package_ensure,
  }
}
