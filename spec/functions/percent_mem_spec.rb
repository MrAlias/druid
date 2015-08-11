require 'puppetlabs_spec_helper/module_spec_helper'

describe 'percent_mem' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  before :each do
    scope.stubs(:lookupvar).with('memorysize').returns('10.0 GB')
    scope.stubs(:lookupvar).with('::memorysize').returns('10.0 GB')
  end

  it { should run.with_params(50).and_return('5g') }
  it { should run.with_params(0.1).and_return('256m') }
  it { should run.with_params(10.1).and_return('1g') }
  it { should run.with_params().and_raise_error(ArgumentError) }
  it { should run.with_params(-1).and_raise_error(Puppet::ParseError) }
  it { should run.with_params(101).and_raise_error(Puppet::ParseError) }
  it { should run.with_params('wrong').and_raise_error(ArgumentError) }
end
