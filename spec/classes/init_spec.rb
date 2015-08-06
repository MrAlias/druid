require 'spec_helper'
describe 'druid' do

  context 'with defaults for all parameters' do
    it { should contain_class('druid') }
  end
end
