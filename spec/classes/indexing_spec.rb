require 'spec_helper'

describe 'druid::indexing', :type => 'class' do
  context 'On standard system with defaults for all parameters' do
    it {
      should compile.with_all_deps
      should contain_class('druid::indexing')
    }
  end
end
