require 'spec_helper'
describe 'sqlplus' do

  context 'with defaults for all parameters' do
    it { should contain_class('sqlplus') }
  end
end
