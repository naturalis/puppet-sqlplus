# == Class: sqlplus
#
class sqlplus (
  $version                    = '12.1',
  $instantclient_package_name = 'oracle-instantclient12.1-basiclite-12.1.0.2.0-1.x86_64.rpm',
  $sqlplus_package_name       = 'oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm'
  ){
  
  # Copy instantclient .rpm file
    file { "/tmp/${instantclient_package_name}":
      ensure => present,
      source => "puppet:///modules/sqlplus/${instantclient_package_name}",
    }
      
    # Copy sqlplus .rpm file
    file { "/tmp/${sqlplus_package_name}":
      ensure => present,
      source => "puppet:///modules/sqlplus/${sqlplus_package_name}",
    }
  
  case $::osfamily {
    debian:{
    
      package { ['alien','libaio1','rlwrap']:
        ensure => installed, 
      }
    
      exec { "install instantclient":
        command => "/usr/bin/alien -i /tmp/${instantclient_package_name}",
        cwd     => "/tmp",
        require => [Package["alien"], 
                    File["/tmp/${instantclient_package_name}"]],
        creates => "/usr/lib/oracle/${version}/client64/bin/adrci",
      }
      
      exec { "install sqlplus":
        command => "/usr/bin/alien -i /tmp/${sqlplus_package_name}",
        cwd     => "/tmp",
        require => [Package["alien"], 
                    File["/tmp/${sqlplus_package_name}"]],
        creates => "/usr/lib/oracle/${version}/client64/bin/sqlplus",
      }
    }
    
    redhat: {
      notify { "${::osfamily} not yet implemented": }
    }
  }

  # Linking over an in-path launcher
  exec { "symlink-sqlplus":
    command => "/bin/ln -s /usr/lib/oracle/${version}/client64/bin/sqlplus /usr/local/bin/sqlplus",
    creates => "/usr/local/bin/sqlplus",
  }
  
  # Set LD_LIBRARY path system wide
  file { '/etc/ld.so.conf.d/oracle.conf':
    ensure  => file,
    content => "/usr/lib/oracle/${version}/client64/lib",
    notify  => Exec[ldconfig_refresh],
  }
  
  # Run ldconfig to apply LD_LIBRARY path
  exec { "ldconfig_refresh":
    command     => '/sbin/ldconfig',
    refreshonly => true,
  }

}
