require 'spec_helper'
describe 'playlist_maker_python' do
  context 'with default values for all parameters' do
    it { should contain_class('playlist_maker_python') }
  end
end
