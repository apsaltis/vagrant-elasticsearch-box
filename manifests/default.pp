define append_if_no_such_line($file, $line, $refreshonly = 'false') {
   exec { "/bin/echo '$line' >> '$file'":
      unless      => "/bin/grep -Fxqe '$line' '$file'",
      path        => "/bin",
      refreshonly => $refreshonly,
   }
}



class must-have {
  include apt
  apt::ppa { "ppa:webupd8team/java": }
 exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  exec { 'apt-get update 2':
    command => '/usr/bin/apt-get update',
    require => [ Apt::Ppa["ppa:webupd8team/java"]],
  }

  exec { "accept_license":
    command => "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
    cwd => "/home/vagrant",
    user => "vagrant",
    path => "/usr/bin/:/bin/",
    logoutput => true,
  } ->
  package { 'oracle-java7-installer':
    ensure => present,
  } ->
  file { '/vagrant/elasticsearch':
    ensure => directory,
    owner => 'vagrant',
    group => 'vagrant',
  } ->
  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb',
    config => {
      'cluster.name' => 'vagrant_elasticsearch',
      'node.name' => $::ipaddress,
      'index' => {
        'number_of_replicas' => '0',
        'number_of_shards' => '1',
      },
      'network' => {
        'host' => '0.0.0.0',
      }
    }
  }
}

include must-have