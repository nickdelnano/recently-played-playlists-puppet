require 'spec_helper'
describe 'recently_played_playlists' do
  context 'with default values for all parameters' do
    it { should contain_class('recently_played_playlists') }
  end
end
