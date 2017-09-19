# Class: artifactory:  See README.md for documentation.
# ===========================
#
#
class artifactory(
  String $yum_name = 'bintray-jfrog-artifactory-rpms',
  String $yum_baseurl = 'http://jfrog.bintray.com/artifactory-rpms',
  String $package_name = 'jfrog-artifactory-oss',
  Optional[String] $jdbc_driver_url = undef,
  Optional[Enum['mssql', 'mysql', 'oracle', 'postgresql']] $db_type = undef,
  Optional[String] $db_url = undef,
  Optional[String] $db_username = undef,
  Optional[String] $db_password = undef,
  Optional[Boolean] $is_primary = true,
) {
  $artifactory_home = '/var/opt/jfrog/artifactory'
  $service_name = 'artifactory'

  class{'::artifactory::yum': }
  -> class{'::artifactory::install': }
  -> class{'::artifactory::config': }
  ~> class{'::artifactory::service': }
}
