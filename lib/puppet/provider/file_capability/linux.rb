# linux.rb --- file_capability linux provider

Puppet::Type.type(:file_capability).provide(:linux) do
  desc <<-EOT
    This provider implements the file capabilities type on Linux.
  EOT

  confine kernel: :linux

  commands setcap: 'setcap'
  commands getcap: 'getcap'

  attr_reader :capability

  def initialize(value = {})
    super(value)
    @capability = []
  end

  def exists?
    Puppet.debug("file_capability: exists? #{resource[:file]}")

    # A nonexistent file has no capabilities
    return false unless File.exist?(resource[:file])

    # Check for unset capabilities, mismatch raises Puppet::ExecutionFailure
    if resource[:capability].nil?
      setcap('-q', '-v', '', resource[:file])
      return false
    end

    # Verify existing capabilities, mismatch raises Puppet::ExecutionFailure
    setcap('-q', '-v', resource[:capability].join(' '), resource[:file])

    # If no ExecutionFailure exception was raised, the existing capabilities
    # match the required capabilities. Since the presentation format can be
    # different, we store the capabilities as they were required by the user.
    @capability = resource[:capability]

    true
  rescue Puppet::ExecutionFailure
    # Handle a capability mismatch

    filename = Regexp.escape(resource[:file])

    # Extract existing capabilities for the resource
    if getcap('-v', resource[:file]) =~ %r{^#{filename} = (.*)}
      # Remember capabilities
      @capability = Regexp.last_match(1).split(',').sort.join(' ')
      return true
    end

    false
  end

  def create
    Puppet.debug("file_capability: create #{resource[:file]}")
    setcap('-q', resource[:capability].join(' '), resource[:file])
  end

  def destroy
    Puppet.debug("file_capability: destroy #{resource[:file]}")
    setcap('-q', '-r', resource[:file])
  end

  def capability=(value)
    Puppet.debug("file_capability: capability #{resource[:file]} => #{value}")
    setcap('-q', value.join(' '), resource[:file])
  end
end
