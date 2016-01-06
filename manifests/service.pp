# Configures the NetWorker service
class networker::service (
  $connection_portrange = $::networker::connection_portrange,
  $service_portrange    = $::networker::service_portrange,) {
  case $::osfamily {
    'RedHat', 'Debian', 'Solaris' : {
      service { 'networker':
        ensure     => 'running',
        enable     => true,
        hasrestart => false,
        require    => File['/nsr/res/servers'],
      }
    }
    # end RedHat

    default : {
      fail("${::osfamily} is not yet supported by this module.
       Please file a bug report if it should be.")
    }

  }

  # end case

  # Set Portranges once the service is running
  case $::kernel {
    'Linux', 'SunOs' : {
      if $::nsr_serviceports != $service_portrange {
        exec { 'set_nsr_serviceports':
          command   => "/usr/bin/nsrports -S ${service_portrange}",
          require   => Service['networker'],
          subscribe => Service['networker'],
        }
      }

      if $::nsr_connectionports != $connection_portrange {
        exec { 'set_nsr_connectionports':
          command   => "/usr/bin/nsrports -C ${connection_portrange}",
          require   => Service['networker'],
          subscribe => Service['networker'],
        }
      }
    }
    # end Linux

    default          : {
      fail("Setting port ranges on ${::kernel} is not yet supported by this
       module. Please file a bug report if it should be."
      )
    }

  }
  # end case $::kernel
}
