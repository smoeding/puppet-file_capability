require 'spec_helper'

describe 'file_capability' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end

    context "on #{os} with manage_package => true" do
      let(:facts) { os_facts }
      let(:params) do
        { manage_package: true }
      end

      case os_facts[:os]['family']
      when 'Debian'
        it {
          is_expected.to contain_package('libcap2-bin')
            .with_ensure('installed')
        }
      when 'RedHat'
        it {
          is_expected.to contain_package('libcap')
            .with_ensure('installed')
        }
      else
        raise "Unsupported os #{os}"
      end
    end

    context "on #{os} with manage_package => false" do
      let(:facts) { os_facts }
      let(:params) do
        { manage_package: false }
      end

      case os_facts[:os]['family']
      when 'Debian'
        it {
          is_expected.not_to contain_package('libcap2-bin')
        }
      when 'RedHat'
        it {
          is_expected.not_to contain_package('libcap')
        }
      else
        raise "Unsupported os #{os}"
      end
    end

    context "on #{os} with package_name => bar" do
      let(:facts) { os_facts }
      let(:params) do
        { package_name: 'bar' }
      end

      it {
        is_expected.to contain_package('bar')
          .with_ensure('installed')
      }
    end

    context "on #{os} with package_ensure => 1.2.3" do
      let(:facts) { os_facts }
      let(:params) do
        { package_ensure: '1.2.3' }
      end

      case os_facts[:os]['family']
      when 'Debian'
        it {
          is_expected.to contain_package('libcap2-bin')
            .with_ensure('1.2.3')
        }
      when 'RedHat'
        it {
          is_expected.to contain_package('libcap')
            .with_ensure('1.2.3')
        }
      else
        raise "Unsupported os #{os}"
      end
    end

    context "on #{os} with file_capabilities set" do
      let(:facts) { os_facts }
      let(:params) do
        {
          file_capabilities: {
            '/bin/ping' => { capability: 'cap_net_raw=ep' },
          },
        }
      end

      case os_facts[:os]['family']
      when 'Debian'
        it {
          is_expected.to contain_package('libcap2-bin')
            .with_ensure('installed')

          is_expected.to contain_file_capability('/bin/ping')
            .with_capability('cap_net_raw=ep')
            .that_requires('Package[libcap2-bin]')
        }
      when 'RedHat'
        it {
          is_expected.to contain_package('libcap')
            .with_ensure('installed')

          is_expected.to contain_file_capability('/bin/ping')
            .with_capability('cap_net_raw=ep')
            .that_requires('Package[libcap]')
        }
      else
        raise "Unsupported os #{os}"
      end
    end
  end
end
