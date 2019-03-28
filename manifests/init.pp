# Manage Linux file capabilities and the required utility package
#
# @summary Manage Linux file capabilities and the required utility package
#
# @example Declare the class using hiera provided defaults
#   include file_capability
#
# @param manage_package
#   Whether to manage the package providing the `getcap` and `setcap`
#   executables with this class. If the package is managed by this class it
#   will be installed before any `file_capability` resource is created.
#
# @param package_ensure
#   The state the package should be in. Normally this is either one of the
#   strings `installed` or `latest` or a specific version number of the
#   package.
#
# @param package_name
#   The name of the package to install. This is operating system specific.
#
# @param file_capabilities
#   A hash used to create `file_capability` resources. This parameter can be
#   used to configure file capabilities as hiera hashes.
#
#
class file_capability (
  Boolean           $manage_package,
  String            $package_ensure,
  String            $package_name,
  Hash[String,Data] $file_capabilities = {},
) {
  if $manage_package {
    package { $package_name:
      ensure => $package_ensure,
    }
    -> File_capability<| |>
  }

  $file_capabilities.each |$file,$attributes| {
    file_capability { $file:
      * => $attributes,
    }
  }
}
