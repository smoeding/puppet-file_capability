source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'metadata-json-lint',     :require => false
  gem 'puppetlabs_spec_helper', :require => false
  gem 'rspec-puppet',           :require => false
  gem 'semantic_puppet',        :require => false
  gem 'json', '< 2.0.0',        :require => false if RUBY_VERSION < '2.0.0'
  gem 'json_pure', '< 2.0.0',   :require => false if RUBY_VERSION < '2.0.0'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false, :groups => [:test]
else
  gem 'puppet', :require => false, :groups => [:test]
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false, :groups => [:test]
else
  gem 'facter', :require => false, :groups => [:test]
end
