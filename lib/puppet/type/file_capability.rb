# file_capability.rb --- file_capability type

Puppet::Type.newtype(:file_capability) do
  desc <<-EOT
    Set file capabilities on Linux. A file capability allows running a program
    with elevated privileges without the need to make that executable a setuid
    binary. Capabilities allow a more fine grained definition of privileges
    for a program. See the capabilities(7) manpage for an overview of Linux
    capabilities.

    The capability parameter can be a string if only one capability should be
    defined and an array for managing multiple capabilities.

    The implemented provider uses the 'setcap' program to check if the current
    and the defined capabilities are in sync. In some cases the textual
    represemtation may look different when in fact the capabilities are
    correctly set. By using the 'setcap' program this is handled correctly
    by the operating system.

    Example:

        file_capability { '/bin/ping':
          ensure     => present,
          capability => 'cap_net_raw=ep',
        }

    In this example, Puppet will ensure the ping executable has the correct
    capability to be able to open raw sockets without running setuid.

        file_capability { '/usr/bin/dumpcap':
          capability => 'cap_net_admin,cap_net_raw=eip',
        }

    This example shows how to set the Effective, Inheritable and Permitted
    flags for two capabilities at the same time. This ensures the executable
    used by the Wireshark network sniffer can be used by an ordinary user.

        file_capability { 'scanner-access-permissions':
          ensure     => present,
          file       => '/usr/local/sbin/scanner',
          capability => [ 'CAP_DAC_READ_SEARCH=ep', 'CAP_SYS_ADMIN=ep', ],
        }

    This example sets the capabilities to bypass file read permission checks
    and perform additional system administration operations for an
    hypothetical scanner executable.

  EOT

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:file, namevar: true) do
    desc <<-EOT
      The name of the file for which the capabilities should be managed.
      Default is the resource title. The file will be autorequired if it is
      managed by Puppet.
    EOT

    validate do |value|
      unless Pathname.new(value).absolute?
        raise ArgumentError, "file #{value} is not an absolute path"
      end
    end
  end

  newproperty(:capability, array_matching: :all) do
    desc <<-EOT
      The capabilities to ensure for the file. This parameter is mandatory
      for ensure => 'present'. The parameter can be a string if only one
      capability should be set and an array to define multiple capabilities.
      Each capability consists of one or more capability names separated by
      commas, an operator '=', '+' or '-' and capability flags. Valid flags
      are 'e', 'i' or 'p' for the Effective, Inheritable and Permitted sets.
      Flags must be given in lowercase.
    EOT

    validate do |value|
      if value.is_a?(Array)
        caps = value
      elsif value.is_a?(String)
        caps = [value]
      else
        raise Puppet::Error, "capability must be an array or a string, got #{value.class.name}"
      end

      caps.each do |cap|
        unless cap =~ %r{^([a-zA-Z0-9_]+)(,[a-zA-Z0-9_]+)*[=+-][eip]*$}
          raise Puppet::Error, "capability #{cap} has the wrong format"
        end
      end
    end
  end

  autorequire(:file) do
    self[:file]
  end

  validate do
    return if self[:ensure] == :absent

    if self[:capability].nil? || self[:capability].empty?
      raise Puppet::Error, 'capability is a required attribute'
    end

    raise Puppet::Error, 'file is a required attribute' if self[:file].nil?
  end
end
