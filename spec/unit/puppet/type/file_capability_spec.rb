# file_capability_spec.rb --- Test the file_capability type

require 'spec_helper'
require 'tempfile'
require 'fileutils'

describe Puppet::Type.type(:file_capability) do
  let(:tempfile) { Tempfile.new('foo').path }

  let :file_capability do
    FileUtils.touch(tempfile)

    Puppet::Type.type(:file_capability).new(
      file:       tempfile,
      capability: 'cap_foo=eip'
    )
  end

  it 'accepts a string as capability' do
    file_capability[:capability] = 'cap_bar=eip'
    expect(file_capability[:capability]).to eq(['cap_bar=eip'])
  end

  it 'accepts an array as capability' do
    file_capability[:capability] = ['cap_bar=eip']
    expect(file_capability[:capability]).to eq(['cap_bar=eip'])
  end

  it 'accepts a two element array as capability' do
    file_capability[:capability] = ['cap_bar=eip', 'cap_foo=eip']
    expect(file_capability[:capability]).to eq(['cap_bar=eip', 'cap_foo=eip'])
  end

  it 'accepts two items as capability' do
    file_capability[:capability] = ['cap_bar,cap_foo=eip']
    expect(file_capability[:capability]).to eq(['cap_bar,cap_foo=eip'])
  end

  it 'fails for a boolean as capability' do
    expect do
      Puppet::Type.type(:file_capability).new(
        name:       'foo',
        file:       '/foo/bar/baz.42',
        capability: true
      )
    end.to raise_error(Puppet::Error)
  end

  it 'fails for a number as capability' do
    expect do
      Puppet::Type.type(:file_capability).new(
        name:       'foo',
        file:       '/foo/bar/baz.42',
        capability: 42
      )
    end.to raise_error(Puppet::Error)
  end

  it 'fails for a missing capability flag' do
    expect do
      Puppet::Type.type(:file_capability).new(
        name:       'foo',
        file:       tempfile,
        capability: 'cap_foo'
      )
    end.to raise_error(Puppet::Error)
  end

  it 'fails for a wrong capability flag' do
    expect do
      Puppet::Type.type(:file_capability).new(
        name:       'foo',
        file:       tempfile,
        capability: 'cap_foo=x'
      )
    end.to raise_error(Puppet::Error)
  end

  it 'fails for a wrong capability operator' do
    expect do
      Puppet::Type.type(:file_capability).new(
        name:       'foo',
        file:       tempfile,
        capability: 'cap_foo$eip'
      )
    end.to raise_error(Puppet::Error)
  end

  it 'does autorequire the file it manages' do
    catalog = Puppet::Resource::Catalog.new
    file = Puppet::Type.type(:file).new(name: tempfile)

    catalog.add_resource file
    catalog.add_resource file_capability

    relationship = file_capability.autorequire.find do |rel|
      (rel.source.to_s == "File[#{tempfile}]") && (rel.target.to_s == file_capability.to_s)
    end
    expect(relationship).to be_a Puppet::Relationship
  end

  it 'does not autorequire the file it manages if it is not managed' do
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource file_capability
    expect(file_capability.autorequire).to be_empty
  end
end
