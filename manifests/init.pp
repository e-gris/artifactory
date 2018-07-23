# Artifactory invocation
class artifactory(
  String $yum_name = 'bintray-jfrog-artifactory-rpms',
  String $yum_baseurl = 'http://jfrog.bintray.com/artifactory-rpms',
  String $package_name = 'jfrog-artifactory-oss',

  Optional[String] $artifactory_home = '/var/opt/jfrog/artifactory',
  Optional[String] $artifactory_etc = '/etc/opt/jfrog/artifactory',
  Optional[String] $artifactory_user = 'artifactory',
  Optional[String] $artifactory_group = 'artifactory',
  Optional[String] $service_name = 'artifactory',
  Optional[String] $package_version = undef,
  Optional[String] $jdbc_driver_url = undef,
  Optional[String] $default_file_override = undef,
  Optional[Enum['mssql', 'mysql', 'oracle', 'postgresql']] $db_type = undef,
  Optional[String] $db_url = undef,
  Optional[String] $db_username = undef,
  Optional[String] $db_password = undef,
  Optional[Boolean] $is_primary = true,
) {

  class{'::artifactory::yum': }
  -> class{'::artifactory::install': }
  -> class{'::artifactory::config': }
  ~> class{'::artifactory::service': }
}
