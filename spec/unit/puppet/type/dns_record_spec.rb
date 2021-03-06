require 'spec_helper'

type_class = Puppet::Type.type(:dns_record)

describe type_class do

  let :params do
    [
      :name,
      :domain,
      :zone_id,
      :username,
      :customername,
      :password,
      :ddns_key,
    ]
  end

  let :properties do
    [
      :content,
      :type,
      :ttl,
    ]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(type_class.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(type_class.parameters).to be_include(param)
    end
  end

  it 'should require a name' do
    expect {
      type_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should require a non-blank name' do
    expect {
      type_class.new({ name: '' })
    }.to raise_error(Puppet::Error, /Empty values are not allowed/)
  end

  it 'should fail when ttl is not a number' do
    expect {
      type_class.new({ name: 'valid', ttl: 'invalid' })
    }.to raise_error(Puppet::Error, /TTL must be an integer/)
  end

  it 'should pass when ttl is a number' do
      expect( 
        type_class.new({name:'valid', ttl: 3600 })[:ttl]
      ).to eql(3600)
  end

  context 'with full properties' do
    before :all do
      @instance_valid = type_class.new({name: 'testing', domain: 'trailing.com', ttl: "3600" })
      @instance_trailing = type_class.new({name: 'testing', domain: 'trailing.com.', ttl: "3600" })
      @name_valid = type_class.new({name: 'testing.trailing.com', domain: 'trailing.com', ttl: "3600" })
      @name_trailing = type_class.new({name: 'testing.trailing.com.', domain: 'trailing.com', ttl: "3600" })
    end

    it 'should remove a trailing . in the domain' do
      expect(@instance_trailing[:domain]).to eql('trailing.com')
    end

    it 'should not fail without a trailing . in the domain' do
      expect(@instance_valid[:domain]).to eql('trailing.com')
    end

    it 'should remove a trailing . in the name'  do
      expect(@name_trailing[:name]).to eql('testing.trailing.com')
    end

    it 'should not fail without a trailing . in the name' do
      expect(@name_valid[:name]).to eql('testing.trailing.com')
    end
  end

end
