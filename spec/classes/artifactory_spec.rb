require 'spec_helper'

describe 'artifactory' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "artifactory class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('artifactory::install').that_comes_before('Class[artifactory::config]') }
          it { is_expected.to contain_class('artifactory::config') }
          it { is_expected.to contain_class('artifactory::service').that_subscribes_to('Class[artifactory::config]') }

          it { is_expected.to contain_service('artifactory') }
          it { is_expected.to contain_package('jfrog-artifactory-oss').with_ensure('present') }

          it { is_expected.to contain_class('artifactory::yum') }
          it { is_expected.to contain_class('artifactory') }
          it { is_expected.to contain_package('java-1.6.0-openjdk-devel').with_ensure('absent') }
          it { is_expected.to contain_package('java-1.6.0-openjdk').with_ensure('absent') }
          it { is_expected.to contain_package('java-1.7.0-openjdk-devel').with_ensure('absent') }
          it { is_expected.to contain_package('java-1.7.0-openjdk').with_ensure('absent') }
          it {
            is_expected.to contain_yumrepo('bintray-jfrog-artifactory-rpms').with(
              'baseurl'  => 'http://jfrog.bintray.com/artifactory-rpms',
              'descr'    => 'bintray-jfrog-artifactory-rpms',
              'gpgcheck' => '0',
              'enabled'  => '1'
            )
          }
        end

        context "artifactory class with jdbc_driver_url parameter" do
          let(:params) {
            {
              'jdbc_driver_url' => 'puppet:///modules/my_module/mysql.jar',
              'db_url' => 'oracle://some_url',
              'db_username' => 'username',
              'db_password' => 'password',
              'db_type' => 'oracle',
            }
          }

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/tomcat/lib/mysql.jar').with(
              'source' => 'puppet:///modules/my_module/mysql.jar',
              'mode' => '0775',
              'owner' => 'artifactory'
            )
          }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/db.properties').with(
              'ensure' => 'file'
            )
          }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/storage.properties').with(
              'ensure' => 'link',
              'target' => '/var/opt/jfrog/artifactory/etc/db.properties'
            )
          }
        end
      end
    end
  end
end
